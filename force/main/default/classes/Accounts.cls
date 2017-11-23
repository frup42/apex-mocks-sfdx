public with sharing class Accounts
{
    @TestVisible
    private static Accounts instance = null;

    public static Accounts newInstance()
    {
        if (instance == null)
        {
            instance = new Accounts();
        }

        return instance;
    }

    public void handleTrigger()
    {
        if (Trigger.isAfter)
        {
            if (Trigger.isInsert || Trigger.isUpdate)
            {
                DuplicateAccountBlocker.newInstance().preventDuplicates((Map<Id, Account>)Trigger.newMap);
            }
        }
    }    
}
