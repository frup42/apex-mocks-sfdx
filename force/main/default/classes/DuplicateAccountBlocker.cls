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
        Set<Id> result = new Set<Id>();

        for (Id duplicateAccountId : duplicateAccountIds)
        {
            Account duplicateAccount = accounts.get(duplicateAccountId);
            if (duplicateAccount != null)
            {
                duplicateAccount.addError('You cannot create an Account with the name "' + duplicateAccount.Name + '", as this would create a duplicate');
                result.add(duplicateAccountId);
            }
        }

        return result;
    }
}
