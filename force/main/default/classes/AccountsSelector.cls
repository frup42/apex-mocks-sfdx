public class AccountsSelector
{
    @TestVisible
    private static AccountsSelector instance = null;

    public static AccountsSelector newInstance()
    {
        if (instance == null)
        {
            instance = new AccountsSelector();
        }

        return instance;
    }

    public Account[] getForNames(Set<String> names)
    {
        // Check the requested names are sensible
        names = sanitize(names);
     
        // If there are no names, just return an empty array.
        // Otherwise run SOQL to retrieve matching Accounts.
        return names.isEmpty() ? new Account[]{} : [SELECT Id, Name FROM Account WHERE Name IN :names];
    }

    private static Set<String> sanitize(Set<String> input)
    {
        if (input == null)
        {
            // Prevent null pointer exception
            input = new Set<String>();
        }
        else
        {
            // Don't bother searching for blank names.
            // It's just as easy to remove them from the set as it is to check if they're present first.
            input.remove('');
            input.remove(null);
        }
        
        return input;
    }
}
