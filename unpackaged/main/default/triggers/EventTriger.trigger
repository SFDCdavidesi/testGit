trigger EventTriger on Event (before insert, after insert, after update, after delete,before update) {
    
    if(Trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            //NK:14/06/2019: EPH-7586
            EBH_TaskTriggerHandler.preventActivityOnInactiveContact(trigger.new,Trigger.oldMap);
        }
        
        if(trigger.isUpdate)
        {
            //NK:14/06/2019: EPH-7586
            EBH_TaskTriggerHandler.preventActivityOnInactiveContact(trigger.new,Trigger.oldMap);
        }
        
    }
    
}