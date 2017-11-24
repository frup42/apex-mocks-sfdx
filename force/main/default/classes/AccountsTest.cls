/**
 * Copyright (c) 2017, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
@isTest(SeeAllData=false)
private class AccountsTest
{
    @IsTest
    private static void handleTrigger_WhenAccountBlockerDoesntAddError_OnInsert_Succeeds()
    {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        DuplicateAccountBlocker mockAccountBlocker = (DuplicateAccountBlocker)mocks.mock(DuplicateAccountBlocker.class);
        DuplicateAccountBlocker.instance = mockAccountBlocker;

        // When
        Test.startTest();
        insert new Account[]{
            new Account(Name = 'Account1'),
            new Account(Name = 'Account1')
        };
        Test.stopTest();

        // Then
        ((DuplicateAccountBlocker)mocks.verify(mockAccountBlocker)).preventDuplicates((Map<Id, Account>)fflib_Match.anyObject());
    }

    @IsTest
    private static void handleTrigger_WhenAccountBlockerAddsError_OnInsert_ThrowsError()
    {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        DuplicateAccountBlocker mockAccountBlocker = (DuplicateAccountBlocker)mocks.mock(DuplicateAccountBlocker.class);
        DuplicateAccountBlocker.instance = mockAccountBlocker;

        Account[] records = new Account[]{
            new Account(Name = 'Account1'),
            new Account(Name = 'Account1')
        };

        mocks.startStubbing();
        mocks
            .when(mockAccountBlocker.preventDuplicates(mapWithSameAccounts(records)))
            .thenAnswer(new AnswerAddError());
        mocks.stopStubbing();

        // When
        try
        {
            Test.startTest();
            insert records;
            System.assert(false, 'Expected exception');
        }
        catch (DmlException e)
        {
            // Then
            Test.stopTest();
            fflib_System.assertEquals(fflib_Match.stringContains('This is my testing error'), e.getMessage());
        }
    }

    @IsTest
    private static void handleTrigger_WhenAccountBlockerDoesntAddError_OnUpdate_Succeeds()
    {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        DuplicateAccountBlocker mockAccountBlocker = (DuplicateAccountBlocker)mocks.mock(DuplicateAccountBlocker.class);
        DuplicateAccountBlocker.instance = mockAccountBlocker;

        Account[] records = new Account[]{
            new Account(Name = 'Account1'),
            new Account(Name = 'Account1')
        };
        insert records;

        ((DuplicateAccountBlocker)mocks.verify(mockAccountBlocker)).preventDuplicates((Map<Id, Account>)fflib_Match.anyObject());

        // When
        Test.startTest();
        update records;
        Test.stopTest();

        // Then
        ((DuplicateAccountBlocker)mocks.verify(mockAccountBlocker, 2)).preventDuplicates((Map<Id, Account>)fflib_Match.anyObject());
    }

    @IsTest
    private static void handleTrigger_WhenAccountBlockerAddsError_OnUpdate_ThrowsError()
    {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        DuplicateAccountBlocker mockAccountBlocker = (DuplicateAccountBlocker)mocks.mock(DuplicateAccountBlocker.class);
        DuplicateAccountBlocker.instance = mockAccountBlocker;

        Account[] records = new Account[]{
            new Account(Name = 'Account1'),
            new Account(Name = 'Account1')
        };

        insert records;

        mocks.startStubbing();
        mocks
            .when(mockAccountBlocker.preventDuplicates(mapWithSameAccounts(records)))
            .thenAnswer(new AnswerAddError());
        mocks.stopStubbing();

        // When
        try
        {
            Test.startTest();
            update records;
            System.assert(false, 'Expected exception');
        }
        catch (DmlException e)
        {
            // Then
            Test.stopTest();
            fflib_System.assertEquals(fflib_Match.stringContains('This is my testing error'), e.getMessage());
        }
    }

    @IsTest
    private static void handleTrigger_OnDelete_DoesntInvokeAccountBlocker()
    {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        DuplicateAccountBlocker mockAccountBlocker = (DuplicateAccountBlocker)mocks.mock(DuplicateAccountBlocker.class);
        DuplicateAccountBlocker.instance = mockAccountBlocker;

        Account[] records = new Account[]{
            new Account(Name = 'Account1'),
            new Account(Name = 'Account1')
        };

        insert records;

        //Expect a single invocation here
        ((DuplicateAccountBlocker)mocks.verify(mockAccountBlocker)).preventDuplicates((Map<Id, Account>)fflib_Match.anyObject());

        // When
        Test.startTest();
        delete records;
        Test.stopTest();
        
        // Then
        // Expect we still have the same invocation from the insert, but not after the delete
        ((DuplicateAccountBlocker)mocks.verify(mockAccountBlocker)).preventDuplicates((Map<Id, Account>)fflib_Match.anyObject());
    }

    private static Map<Id, Account> mapWithSameAccounts(Account[] toMatch)
    {
		return (Map<Id, Account>)fflib_Match.matches(new MapWithSameAccounts(toMatch));
	}

    private class MapWithSameAccounts implements fflib_IMatcher
	{
		private Account[] toMatch;

		public MapWithSameAccounts(Account[] toMatch)
		{
			this.toMatch = toMatch;
		}

		public Boolean matches(Object arg)
		{
			if (arg != null && arg instanceof Map<Id, Account>)
			{
                for (Account expected : toMatch)
                {
                    Boolean match = false;
                    for (Account actual : ((Map<Id, Account>)arg).values())
                    {
                        if (expected.Name == actual.Name)
                        {
                            match = true;
                        }
                    }

                    if (!match)
                    {
                        return false;
                    }
                }

				return true;
			}

			return false;
		}
	}

    public class AnswerAddError implements fflib_Answer
	{
		public Object answer(fflib_InvocationOnMock invocation)
		{
			Map<Id, Account> records = (Map<Id, Account>)invocation.getArgument(0);

            for (Account record : records.values())
            {
                record.addError('This is my testing error');
            }
			
			return records.keySet();
		}
	}
}
