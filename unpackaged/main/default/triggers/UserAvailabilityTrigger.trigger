/*********************************************************************************************************************************
@ Class:        UserAvailabilityTrigger
@ Version:      1.0
@ Author:       Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:      US-0011996 - Call booking for Ads
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 15.07.202 2/ Sophal Noch / Created the trigger
*********************************************************************************************************************************/
trigger UserAvailabilityTrigger on User_Availability__c (before insert, before update) {

    if( EBH_ActiveTriggers__c.getInstance(UserAvailabilityTriggerHandler.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(UserAvailabilityTriggerHandler.TRIGGERCONTROLLER).UserAvailabilityTrigger__c) {

            if(Trigger.isBefore){

                if(Trigger.isInsert || Trigger.isUpdate){
                    UserAvailabilityTriggerHandler.populateSchduleSlots(Trigger.new, Trigger.oldMap);
                }
        
            }

        }




}