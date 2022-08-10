/*********************************************************************************************************************************
@ Class:          EBH_CampaignMember
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        CampaignMember Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 06.06.2017 / NEHA LUND / Created the trigger.
                  21.06.2017 / NEHA LUND / Commented the Campaign Member Trigger - To be used by future releases
*********************************************************************************************************************************/
trigger EBH_CustomCampaignMember on EBH_CampaignMember__c (before insert, after insert, before update, after update, after delete) {
    
    //trigger control - proceed if trigger switched ON
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
       EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_CustomCampaignMemberTrigger__c) { 
        
        //check trigger recurssion
        //if(EBH_CheckRecursive.runOnce()){          
            
            /*BEFORE Block - BEGIN*/
                
                /*INSERT Block - BEGIN*/
                /*if(Trigger.isInsert && Trigger.isBefore) {
                    EBH_CustomCampaignMemberTriggerHandler.upsertCampaignMembers ( trigger.new, trigger.oldMap );
                }*/
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                /*if(Trigger.isUpdate && Trigger.isBefore) {
                    EBH_CampaignMemberTriggerHandler.updateCampaignMemberStatus ( trigger.new, trigger.oldMap );
                }*/
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                /*if(Trigger.isDelete && Trigger.isBefore) {
                    EBH_CampaignMemberTriggerHandler.updateCampaignMemberStatus ( trigger.new, trigger.oldMap );
                }*/
                /*DELETE Block - END*/
            
            /*BEFORE Block - END*/
            
            /*AFTER Block - BEGIN*/
            
                /*INSERT Block - BEGIN*/
                if(Trigger.isInsert && Trigger.isAfter) {                       
                    EBH_CustomCampaignTriggerHandler.upsertCampaignMembers ( trigger.new );                  
                }
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                /*if(Trigger.isUpdate && Trigger.isAfter) {  
                                        
                }*/
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                /*if(Trigger.isDelete && Trigger.isAfter) {                     
                
                }*/
                /*DELETE Block - END*/
                
                /*UNDELETE Block - BEGIN*/
                /*UNDELETE Block - END*/
            
            /*AFTER Block - END*/
       //} 
    }
}