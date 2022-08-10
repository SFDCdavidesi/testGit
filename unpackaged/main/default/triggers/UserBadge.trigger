/*********************************************************************************************************************************
@ Class:        UserBadgeHandler
@ Version:      1.0
@ Author:       SRONG TIN (srong.tin@gaea-sys.com)
@ Purpose:      trailheadapp__User_Badge__c Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 19.08.2021 / STRONG TIN / Created the trigger.
*********************************************************************************************************************************/
trigger UserBadge on trailheadapp__User_Badge__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    //trigger control - proceed if trigger switched ON
    if( EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).UserBadgeTrigger__c) {
        /*Before Block - BEGIN*/
        if(Trigger.isBefore){

            /*Insert or update Block - BEGIN*/
            if(Trigger.isUpdate){
                //23.08.2021 - SRONG TIN : US-0009878 - Hive University - Permission Set Assignment Automation for Survey Vista
                UserBadgeHandler.updatePermissionToUserBadge(trigger.oldMap,trigger.new);
            }
            /*Insert or update Block - END*/
        }
        /*Before Block - END*/

        /*After Block - BEGIN*/
        if(Trigger.isAfter){
            /*Insert or update Block - BEGIN*/
            if(Trigger.isUpdate){
                
            }
            /*Insert or update Block - END*/
        }
        /*AFTER Block - END*/
    }
}