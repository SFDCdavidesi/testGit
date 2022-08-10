// @ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
trigger MarketingTicket on Marketing_Ticket__c (before insert) {
    // @ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
    /*
    if(trigger.isBefore && trigger.isInsert)
    {
        
        MarketingTicketTriggerHandler.setCounter(trigger.new);
        MarketingTicketTriggerHandler.setDueDate(trigger.new);
        
    } */
    // end US-0007031 with old US-0001616
    
    // @ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
    /*
    else if(trigger.isAfter){
        if(trigger.isInsert){
            // @ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
            //MarketingTicketTriggerHandler.sumEstimatedEffortOnSprintAndSprintCapacityUser(trigger.new,null);
            // end US-0007031 with old US-0001225
        }
        else if(trigger.isUpdate){
            // @ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
            //MarketingTicketTriggerHandler.sumEstimatedEffortOnSprintAndSprintCapacityUser(trigger.new,trigger.oldMap);
            // end US-0007031 with old US-0001225
        }else if(trigger.isDelete) {
            // @ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
            //MarketingTicketTriggerHandler.sumEstimatedEffortOnSprintAndSprintCapacityUser(null,trigger.oldMap);
            // end US-0007031 with old US-0001225
        }
    }*/
}