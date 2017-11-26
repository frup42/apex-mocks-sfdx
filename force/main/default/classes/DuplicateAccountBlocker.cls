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
    // Instance variable for dependency injection - see README for more details.
    @TestVisible
    private static DuplicateAccountBlocker instance = null;

    // newInstance helper for dependency injection - see README for more details.
    public static DuplicateAccountBlocker newInstance()
    {
        if (instance == null)
        {
            instance = new DuplicateAccountBlocker();
        }

        return instance;
    }

    // The heart of this sample application! Prevent duplicate Accounts from being inserted/updated.
    public Set<Id> preventDuplicates(Map<Id, Account> newAccounts)
    {
        // Prepare an empty result. If there are any problem Accounts, we'll add their Id to this set in case
        // the caller is interested in them.
        // We can use this result in unit tests to check this method has worked correctly.
        Set<Id> result = new Set<Id>();

        // Check the supplied map isn't null or empty
        if (newAccounts != null && !newAccounts.isEmpty())
        {
            // Find existing Accounts from the database with the names of our new Accounts
            Map<String, List<Account>> newAccountsByName = mapByName(newAccounts.values());
            Account[] existingAccounts = AccountsSelector.newInstance().getForNames(newAccountsByName.keySet());

            // Combine the Map of new and existing Accounts
            Map<Id, Account> allAccounts = mergeMap(newAccounts, existingAccounts);

            // For each name in the record set, create a list of corresponding Accounts for that name
            Map<String, List<Account>> allAccountsByName = mapByName(allAccounts.values());

            // For any name with more than one corresponding Account, get the IDs
            Set<Id> duplicateAccountIds = getDuplicates(allAccountsByName);

            // Add an error to each of the Accounts in the newMap, **not** allAccounts.
            // There's no point adding the errors to the ones from the DB, it's too late to stop them from being saved.
            Set<Id> accountsWithError = addErrorToDuplicateAccounts(duplicateAccountIds, newAccounts);

            // Store all the problem Account Ids
            result.addAll(accountsWithError);
        }

        // And finally return the problem Account IDs
        return result;
    }

    private static Map<Id, Account> mergeMap(Map<Id, Account> firstSource, Account[] secondSource)
    {
        // Create a new Map from the second source
        Map<Id, Account> result = new Map<Id, Account>(secondSource);
        
        // Then merge add the firstSource mappings over the top.
        // If they share any keys, the values in the firstSource will take precedence.
        result.putAll(firstSource);
        
        // And return the result
        return result;
    }

    private static Map<String, List<Account>> mapByName(List<Account> accounts)
    {
        // Prepare an empty result
        Map<String, List<Account>> result = new Map<String, List<Account>>();

        // Iterate through each Account
        for (Account a : accounts)
        {
            if (result.containsKey(a.Name))
            {
                // If the Name is already in the map, then just add to the corresponding Array
                result.get(a.Name).add(a);
            }
            else
            {
                // If the Name isn't in the map yet, add a new corresponding Array, containing this Account
                result.put(a.Name, new Account[]{ a });
            }
        }

        // And return the result
        return result;
    }

    private static Set<Id> getDuplicates(Map<String, List<Account>> accountsByName)
    {
        // Prepare an empty result
        Set<Id> result = new Set<Id>();
        
        // Iterate through each Account
        for (Account[] accountsForName : accountsByName.values())
        {
            // If there are multiple accounts, they are duplicates
            if (accountsForName.size() > 1)
            {
                // Add their IDs to the result
                result.addAll(new Map<Id, Account>(accountsForName).keySet());
            }
        }

        // And return the result
        return result;
    }

    private static Set<Id> addErrorToDuplicateAccounts(Set<Id> duplicateAccountIds, Map<Id, Account> accounts)
    {
        // Prepare an empty result
        Set<Id> result = new Set<Id>();

        // Instantiate our Utilities class
        Utilities utils = Utilities.newInstance();

        // Iterate through each Account Id
        for (Id duplicateAccountId : duplicateAccountIds)
        {
            // Get the problem Account (but beware the map only contains new records,
            // and we can get a null here if it's an existing Account from the DB)
            Account duplicateAccount = accounts.get(duplicateAccountId);
            if (duplicateAccount != null)
            {
                // Add the error
                utils.addError(new Account[]{ duplicateAccount }, 'You cannot create an Account with the name "' + duplicateAccount.Name + '", as this would create a duplicate');

                // Add the Id to the result
                result.add(duplicateAccountId);
            }
        }

        // And return the result
        return result;
    }
}
