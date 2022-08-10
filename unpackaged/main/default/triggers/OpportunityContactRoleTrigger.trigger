trigger OpportunityContactRoleTrigger on OpportunityContactRole (after insert,after update, after delete) {

    if(EBH_ActiveTriggers__c.getInstance('EBH Trigger Controller').OpportunityContactRole__c) 
    { 

        if(Trigger.isAfter)
        {
            if(Trigger.isInsert || Trigger.isUpdate)
            {
                OpportunityContactRoleTriggerHandler.updatePrimaryContactAndSAP( Trigger.new , Trigger.oldMap);

            }else if(Trigger.isDelete)
            {
                OpportunityContactRoleTriggerHandler.reassignPrimaryContact(Trigger.old);
            }
        }
    }

}