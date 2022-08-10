/*********************************************************************************************************************************
@ Class:          EBH_Pricing
@ Version:        1.0
@ Author:         NEHA LUND 
@ Purpose:        Pricing Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 18.05.2017 / NEHA LUND / Created the trigger.
*********************************************************************************************************************************/

trigger EBH_Pricing on EBH_Pricing__c (before insert, before update, after insert, after update) {
    
    
    //trigger control - proceed if trigger switched ON
    if( EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_PricingTrigger__c) { 
        
        //check trigger recurssion
        //if(EBH_CheckRecursive.runOnce()){          
            
            /*BEFORE Block - BEGIN*/
            if(Trigger.isBefore){
                /*INSERT Block - BEGIN*/
                if(Trigger.isInsert){
                    EBH_PricingTriggerHandler.updateFFExposure(trigger.new, trigger.oldMap);
                    EBH_PricingTriggerHandler.updatePricingCapDiscount(trigger.new, trigger.oldMap);
                }
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                if(Trigger.isUpdate){
                     EBH_PricingTriggerHandler.updateFFExposure(trigger.new, trigger.oldMap);
                     EBH_PricingTriggerHandler.updatePricingCapDiscount(trigger.new, trigger.oldMap);
                }
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                /*DELETE Block - END*/
            }
            /*BEFORE Block - END*/
            
            /*AFTER Block - BEGIN*/
            
                /*INSERT Block - BEGIN*/
                if(Trigger.isInsert && Trigger.isAfter ) {   
                     EBH_PricingTriggerHandler.updateCustomRollUp(trigger.new, trigger.oldMap);
                }
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                if(Trigger.isUpdate && Trigger.isAfter ) {                     
                      EBH_PricingTriggerHandler.updateCustomRollUp(trigger.new, trigger.oldMap);
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