/*********************************************************************************************************************************
@ Class:          EBH_Attachment
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        Attachment trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 03.12.2017 / NEHA LUND / Created the trigger.
@ Change history: 11.04.2018 / David Herrero / Added contract before insert control
*********************************************************************************************************************************/
trigger EBH_Attachment on Attachment (after insert, before delete, before insert) {
    
    //trigger control - proceed if trigger switched ON
    if( EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_AttachmentTrigger__c) { 
        
        //check trigger recurssion
        //if(EBH_CheckRecursive.runOnce()){          
            
            /*BEFORE Block - BEGIN*/
             if(Trigger.isBefore){
             
                /*INSERT Block - BEGIN*/
                 if (Trigger.isInsert){
                     EBH_AttachmentTriggerHandler.validateAttachmentInsertion(Trigger.new);
                 }
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                if(Trigger.isDelete){
                   EBH_AttachmentTriggerHandler.validateAttachmentDeletion(trigger.old);
                }
                /*DELETE Block - END*/
            
            }
            /*BEFORE Block - END*/
            
            /*AFTER Block - BEGIN*/
            if(Trigger.isInsert && Trigger.isAfter ) {                     
                   //EBH_AttachmentTriggerHandler.updateContractAttachmentCheck(trigger.new);
                }
                /*INSERT Block - BEGIN*/
                
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                /*DELETE Block - END*/
                
                /*UNDELETE Block - BEGIN*/
                /*UNDELETE Block - END*/
            
            /*AFTER Block - END*/
       //} 
    }
}