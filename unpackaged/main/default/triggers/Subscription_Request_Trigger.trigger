trigger Subscription_Request_Trigger on Subscription_Request__c (before update) {
    if (EBH_ActiveTriggers__c.getInstance('EBH Trigger Controller').Subscription_Request_Trigger__c) 
    {
        if(Trigger.isBefore)
        {
            if(Trigger.isUpdate)
            {
                Subscription_Request_TriggerHandler.populateFields(Trigger.new,Trigger.OldMap);
            }
            
        }

        
    }
}