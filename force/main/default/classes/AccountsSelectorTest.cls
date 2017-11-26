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
private class AccountsSelectorTest
{
    private static final Account[] EXISTING_ACCOUNTS = new Account[]{
        new Account(Name = 'Account1'),
        new Account(Name = 'Account2'),
        new Account(Name = 'Account3')
    };

    static
    {
        insert EXISTING_ACCOUNTS;
    }

    @isTest
    private static void getForNames_WithNullNames_ReturnsEmptyList()
    {
        // Given
        Set<String> names = null;
        Account[] expected = new Account[]{};

        // When
        Test.startTest();
        Account[] actual = AccountsSelector.newInstance().getForNames(names);
        Test.stopTest();

        // Then
        System.assertEquals(expected, actual);
    }

    @isTest
    private static void getForNames_WithEmptyNames_ReturnsEmptyList()
    {
        // Given
        Set<String> names = new Set<String>{};
        Account[] expected = new Account[]{};

        // When
        Test.startTest();
        Account[] actual = AccountsSelector.newInstance().getForNames(names);
        Test.stopTest();

        // Then
        System.assertEquals(expected, actual);
    }

    @isTest
    private static void getForNames_WithBlankAndNullInNames_ReturnsEmptyList()
    {
        // Given
        Set<String> names = new Set<String>{ null, '' };
        Account[] expected = new Account[]{};

        // When
        Test.startTest();
        Account[] actual = AccountsSelector.newInstance().getForNames(names);
        Test.stopTest();

        // Then
        System.assertEquals(expected, actual);
    }

    @isTest
    private static void getForNames_WithNonExistentName_ReturnsEmptyList()
    {
        // Given
        Set<String> names = new Set<String>{ null, '' };
        Account[] expected = new Account[]{};

        // When
        Test.startTest();
        Account[] actual = AccountsSelector.newInstance().getForNames(names);
        Test.stopTest();

        // Then
        System.assertEquals(expected, actual);
    }

    @isTest
    private static void getForNames_WithExistingName_ReturnsOneResult()
    {
        // Given
        Set<String> names = new Set<String>{ EXISTING_ACCOUNTS[0].Name };
        Account[] expected = new Account[]{ EXISTING_ACCOUNTS[0] };

        // When
        Test.startTest();
        Account[] actual = AccountsSelector.newInstance().getForNames(names);
        Test.stopTest();

        // Then
        System.assertEquals(1, actual.size(), 'Unexpected result size: ' + actual);
        fflib_System.assertEquals(fflib_Match.sObjectWithId(expected[0].Id), actual[0]);
        fflib_System.assertEquals(fflib_Match.sObjectWithName(expected[0].Name), actual[0]);
    }
}
