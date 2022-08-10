/*********************************************************************************************************************************
@ Class:          EBH_DocuSignStatus
@ Version:        1.0
@ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
@ Purpose:        DocuSign Status Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 06.11.2017 / JOY MONDOL / Created the trigger.
*********************************************************************************************************************************/
trigger EBH_DocuSignStatus on dsfs__DocuSign_Status__c (after insert, after update) {  
    
    //trigger control - proceed if trigger switched ON
    if( EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null && 
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_DocuSignStatusTrigger__c) { 
        
        //check trigger recurssion
        //if(EBH_CheckRecursive.runOnce()){          
            
            /*BEFORE Block - BEGIN*/
                
                /*INSERT Block - BEGIN*/
                //if(Trigger.isInsert && Trigger.isBefore) { }
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                //if(Trigger.isUpdate && Trigger.isBefore) { }
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                //if(Trigger.isDelete && Trigger.isBefore) { }
                /*DELETE Block - END*/
            
            /*BEFORE Block - END*/
            
            /*AFTER Block - BEGIN*/
            
                /*INSERT Block - BEGIN*/
                if(Trigger.isInsert && Trigger.isAfter) { 
                    EBH_DocuSignStatusTriggerHandler.updateContractStatus(trigger.new);
                }
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                if(Trigger.isUpdate && Trigger.isAfter) { 
                    EBH_DocuSignStatusTriggerHandler.updateContractStatus(trigger.new);
                }
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                //if(Trigger.isDelete && Trigger.isAfter) { }
                /*DELETE Block - END*/
                
                /*UNDELETE Block - BEGIN*/
                //if(Trigger.isDelete && Trigger.isAfter) { }
                /*UNDELETE Block - END*/
            
            /*AFTER Block - END*/
       //} 
    }
}