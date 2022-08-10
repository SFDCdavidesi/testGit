// @ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
trigger SprintCapacityUserTrigger on Sprint_Capacity_Users__c (before insert, before update) {
    // @ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
    /* if(trigger.isBefore){
        if(trigger.isInsert){
            SprintCapacityUserTriggerHandler.updatedSprintCapacityUser(trigger.new,null);
        }
        else if(trigger.isUpdate){
            
            SprintCapacityUserTriggerHandler.updatedSprintCapacityUser(trigger.new, trigger.oldMap);
            
        } 
    }*/
    // end US-0007031 wtih old US-0001226 and US-0001238 
}