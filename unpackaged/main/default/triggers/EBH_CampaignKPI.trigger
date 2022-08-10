/*********************************************************************************************************************************
@ Class:          EBH_CampaignKPI
@ Version:        1.0
@ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
@ Purpose:        CampaignKPI Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 08.05.2017 / JOY MONDOL / Created the trigger.
*********************************************************************************************************************************/

trigger EBH_CampaignKPI on EBH_CampaignKPI__c (after insert, after update) {
    
    //trigger control - proceed if trigger switched ON
    if( EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_CampaignKPITrigger__c) { 
        
        //check trigger recurssion
        //if(EBH_CheckRecursive.runOnce()){          
            
            /*BEFORE Block - BEGIN*/
            
                /*INSERT Block - BEGIN*/
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                /*DELETE Block - END*/
            
            /*BEFORE Block - END*/
            
            /*AFTER Block - BEGIN*/
            
                /*INSERT Block - BEGIN*/
                if(Trigger.isInsert && Trigger.isAfter ) {                     
                     //EBH_CampaignKPITriggerHandler.createParentKPIRecords2(trigger.new, trigger.oldMap);
                     EBH_CampaignKPITriggerHandler.createChildKPIRecords( trigger.new );
                }
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                if(Trigger.isUpdate && Trigger.isAfter ) {                     
                      //EBH_CampaignKPITriggerHandler.createParentKPIRecords2(trigger.new, trigger.oldMap);
                }
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                /*DELETE Block - END*/
                
                /*UNDELETE Block - BEGIN*/
                /*UNDELETE Block - END*/
            
            /*AFTER Block - END*/
       //} 
    }
}