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
public class DuplicateAccountBlocker
{
    @TestVisible
    private static DuplicateAccountBlocker instance = null;

    public static DuplicateAccountBlocker newInstance()
    {
        if (instance == null)
        {
            instance = new DuplicateAccountBlocker();
        }

        return instance;
    }

    public Set<Id> preventDuplicates(Map<Id, Account> newAccounts)
    {
        Set<Id> result = new Set<Id>();
        if (newAccounts != null && !newAccounts.isEmpty())
        {
            Map<String, List<Account>> newAccountsByName = mapByName(newAccounts.values());
            Account[] existingAccounts = AccountsSelector.newInstance().getForNames(newAccountsByName.keySet());
            Map<Id, Account> allAccounts = mergeMap(newAccounts, existingAccounts);
            Map<String, List<Account>> allAccountsByName = mapByName(allAccounts.values());
            Set<Id> duplicateAccountIds = getDuplicates(allAccountsByName);
            Set<Id> accountsWithError = addErrorToDuplicateAccounts(duplicateAccountIds, newAccounts);

            result.addAll(accountsWithError);
        }
        return result;
    }

    private static Map<Id, Account> mergeMap(Map<Id, Account> firstSource, Account[] secondSource)
    {
        Map<Id, Account> result = new Map<Id, Account>(secondSource);
        
        // The new mappings replace any mappings that the original map had.
        result.putAll(firstSource);
        
        return result;
    }

    private static Map<String, List<Account>> mapByName(List<Account> accounts)
    {
        Map<String, List<Account>> result = new Map<String, List<Account>>();
        for (Account a : accounts)
        {
            if (result.containsKey(a.Name))
            {
                result.get(a.Name).add(a);
            }
            else
            {
                result.put(a.Name, new Account[]{ a });
            }
        }

        return result;
    }

    private static Set<Id> getDuplicates(Map<String, List<Account>> accountsByName)
    {
        Set<Id> result = new Set<Id>();
        
        for (Account[] accountsForName : accountsByName.values())
        {
            if (accountsForName.size() > 1)
            {
                result.addAll(new Map<Id, Account>(accountsForName).keySet());
            }
        }

        return result;
    }

    private static Set<Id> addErrorToDuplicateAccounts(Set<Id> duplicateAccountIds, Map<Id, Account> accounts)
    {
        Utilities utils = Utilities.newInstance();
        Set<Id> result = new Set<Id>();

        for (Id duplicateAccountId : duplicateAccountIds)
        {
            Account duplicateAccount = accounts.get(duplicateAccountId);
            if (duplicateAccount != null)
            {
                utils.addError(new Account[]{ duplicateAccount }, 'You cannot create an Account with the name "' + duplicateAccount.Name + '", as this would create a duplicate');
                result.add(duplicateAccountId);
            }
        }

        return result;
    }
}
