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
private class DuplicateAccountBlockerTest
{
    @isTest
    private static void preventDuplicates_WithNullAccounts_ReturnsEmptySet()
    {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountsSelector mockSelector = (AccountsSelector)mocks.mock(AccountsSelector.class);
        AccountsSelector.instance = mockSelector;
        Utilities mockUtils = (Utilities)mocks.mock(Utilities.class);
        Utilities.instance = mockUtils;

        Set<Id> expected = new Set<Id>{};

        // When
        Set<Id> actual = DuplicateAccountBlocker.newInstance().preventDuplicates(null);

        // Then
        System.assertEquals(expected, actual);

        ((AccountsSelector)mocks.verify(mockSelector, mocks.never())).getForNames((Set<String>)fflib_Match.anyObject());
        ((Utilities)mocks.verify(mockUtils, mocks.never())).addError((SObject[])fflib_Match.anyObject(), fflib_Match.anyString());
    }
    
    @isTest
    private static void preventDuplicates_WithEmptyAccounts_ReturnsEmptySet()
    {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountsSelector mockSelector = (AccountsSelector)mocks.mock(AccountsSelector.class);
        AccountsSelector.instance = mockSelector;
        Utilities mockUtils = (Utilities)mocks.mock(Utilities.class);
        Utilities.instance = mockUtils;

        Account[] newRecords = new Account[]{};

        Set<Id> expected = new Set<Id>{};

        // When
        Set<Id> actual = DuplicateAccountBlocker.newInstance().preventDuplicates(new Map<Id, Account>(newRecords));

        // Then
        System.assertEquals(expected, actual);

        ((AccountsSelector)mocks.verify(mockSelector, mocks.never())).getForNames((Set<String>)fflib_Match.anyObject());
        ((Utilities)mocks.verify(mockUtils, mocks.never())).addError((SObject[])fflib_Match.anyObject(), fflib_Match.anyString());
    }
    
    @isTest
    private static void preventDuplicates_WithNoDuplicates_ReturnsEmptySet()
    {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountsSelector mockSelector = (AccountsSelector)mocks.mock(AccountsSelector.class);
        AccountsSelector.instance = mockSelector;
        Utilities mockUtils = (Utilities)mocks.mock(Utilities.class);
        Utilities.instance = mockUtils;

        Account[] newRecords = new Account[]{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Unique'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Even more unique')
        };

        Account[] existingRecords = new Account[]{
            new Account(Id = newRecords[1].Id, Name = 'Unique'),
            new Account(Id = newRecords[0].Id, Name = 'Even more unique')
        };

        Set<String> accountNames = new Set<String>{
            'Unique',
            'Even more unique'
        };

        mocks.startStubbing();
        mocks.when(mockSelector.getForNames((Set<String>)fflib_Match.eq(accountNames))).thenReturn(existingRecords);
        mocks.stopStubbing();

        Set<Id> expected = new Set<Id>{};

        // When
        Set<Id> actual = DuplicateAccountBlocker.newInstance().preventDuplicates(new Map<Id, Account>(newRecords));

        // Then
        System.assertEquals(expected, actual);

        ((Utilities)mocks.verify(mockUtils, mocks.never())).addError((SObject[])fflib_Match.anyObject(), fflib_Match.anyString());
    }
    
    @isTest
    private static void preventDuplicates_SwappedAccountNames_ReturnsEmptySet()
    {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountsSelector mockSelector = (AccountsSelector)mocks.mock(AccountsSelector.class);
        AccountsSelector.instance = mockSelector;
        Utilities mockUtils = (Utilities)mocks.mock(Utilities.class);
        Utilities.instance = mockUtils;

        Account[] newRecords = new Account[]{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Name swap 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Name swap 2')
        };

        Account[] existingRecords = new Account[]{
            new Account(Id = newRecords[1].Id, Name = 'Name swap 2'),
            new Account(Id = newRecords[0].Id, Name = 'Name swap 1')
        };

        Set<String> accountNames = new Set<String>{
            'Name swap 1',
            'Name swap 2'
        };

        mocks.startStubbing();
        mocks.when(mockSelector.getForNames((Set<String>)fflib_Match.eq(accountNames))).thenReturn(existingRecords);
        mocks.stopStubbing();

        Set<Id> expected = new Set<Id>{};

        // When
        Set<Id> actual = DuplicateAccountBlocker.newInstance().preventDuplicates(new Map<Id, Account>(newRecords));

        // Then
        System.assertEquals(expected, actual);

        ((Utilities)mocks.verify(mockUtils, mocks.never())).addError((SObject[])fflib_Match.anyObject(), fflib_Match.anyString());
    }
    
    @isTest
    private static void preventDuplicates_WithDuplicatesInNewSet_ReturnsDuplicateIds()
    {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountsSelector mockSelector = (AccountsSelector)mocks.mock(AccountsSelector.class);
        AccountsSelector.instance = mockSelector;
        Utilities mockUtils = (Utilities)mocks.mock(Utilities.class);
        Utilities.instance = mockUtils;

        Account[] newRecords = new Account[]{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Duplicate in new set'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Duplicate in new set')
        };

        Account[] existingRecords = new Account[]{};

        Set<String> accountNames = new Set<String>{ 'Duplicate in new set' };

        mocks.startStubbing();
        mocks.when(mockSelector.getForNames((Set<String>)fflib_Match.eq(accountNames))).thenReturn(existingRecords);
        mocks.stopStubbing();

        Set<Id> expected = new Set<Id>{
            newRecords[0].Id,
            newRecords[1].Id
        };

        // When
        Set<Id> actual = DuplicateAccountBlocker.newInstance().preventDuplicates(new Map<Id, Account>(newRecords));

        // Then
        System.assertEquals(expected, actual);

        ((Utilities)mocks.verify(mockUtils)).addError(new Account[]{ newRecords[0] }, 'You cannot create an Account with the name "' + newRecords[0].Name + '", as this would create a duplicate');
        ((Utilities)mocks.verify(mockUtils)).addError(new Account[]{ newRecords[1] }, 'You cannot create an Account with the name "' + newRecords[1].Name + '", as this would create a duplicate');
    }

    @isTest
    private static void preventDuplicates_WithDuplicatesAgainstExistingSet_ReturnsDuplicateIds()
    {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountsSelector mockSelector = (AccountsSelector)mocks.mock(AccountsSelector.class);
        AccountsSelector.instance = mockSelector;
        Utilities mockUtils = (Utilities)mocks.mock(Utilities.class);
        Utilities.instance = mockUtils;

        Account[] newRecords = new Account[]{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Duplicate on DB')
        };

        Account[] existingRecords = new Account[]{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Duplicate on DB')
        };

        Set<String> accountNames = new Set<String>{ 'Duplicate on DB' };

        mocks.startStubbing();
        mocks.when(mockSelector.getForNames((Set<String>)fflib_Match.eq(accountNames))).thenReturn(existingRecords);
        mocks.stopStubbing();

        Set<Id> expected = new Set<Id>{ newRecords[0].Id };

        // When
        Set<Id> actual = DuplicateAccountBlocker.newInstance().preventDuplicates(new Map<Id, Account>(newRecords));

        // Then
        System.assertEquals(expected, actual);

        ((Utilities)mocks.verify(mockUtils)).addError(new Account[]{ newRecords[0] }, 'You cannot create an Account with the name "' + newRecords[0].Name + '", as this would create a duplicate');
    }
    
    @isTest
    private static void preventDuplicates_WithMixOfDuplicatedAndNot_ReturnsDuplicateIds()
    {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountsSelector mockSelector = (AccountsSelector)mocks.mock(AccountsSelector.class);
        AccountsSelector.instance = mockSelector;
        Utilities mockUtils = (Utilities)mocks.mock(Utilities.class);
        Utilities.instance = mockUtils;

        Account[] newRecords = new Account[]{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Unique'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Unique on DB'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Duplicate in new set'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Duplicate in new set'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Duplicate on DB'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Name swap 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Name swap 2')
        };

        Account[] existingRecords = new Account[]{
            new Account(Id = newRecords[1].Id, Name = 'Unique on DB'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Duplicate on DB'),
            new Account(Id = newRecords[5].Id, Name = 'Name swap 2'),
            new Account(Id = newRecords[6].Id, Name = 'Name swap 1')
        };

        Set<String> accountNames = new Set<String>{
            'Unique',
            'Unique on DB',
            'Duplicate in new set',
            'Duplicate in new set',
            'Duplicate on DB',
            'Name swap 1',
            'Name swap 2'
        };

        mocks.startStubbing();
        mocks.when(mockSelector.getForNames((Set<String>)fflib_Match.eq(accountNames))).thenReturn(existingRecords);
        mocks.stopStubbing();

        Set<Id> expected = new Set<Id>{
            newRecords[2].Id,
            newRecords[3].Id,
            newRecords[4].Id
        };

        // When
        Set<Id> actual = DuplicateAccountBlocker.newInstance().preventDuplicates(new Map<Id, Account>(newRecords));

        // Then
        System.assertEquals(expected, actual);

        ((Utilities)mocks.verify(mockUtils)).addError(new Account[]{ newRecords[2] }, 'You cannot create an Account with the name "' + newRecords[2].Name + '", as this would create a duplicate');
        ((Utilities)mocks.verify(mockUtils)).addError(new Account[]{ newRecords[3] }, 'You cannot create an Account with the name "' + newRecords[3].Name + '", as this would create a duplicate');
        ((Utilities)mocks.verify(mockUtils)).addError(new Account[]{ newRecords[4] }, 'You cannot create an Account with the name "' + newRecords[4].Name + '", as this would create a duplicate');
    }
}
