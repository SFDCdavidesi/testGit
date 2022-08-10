/*********************************************************************************************************************************
@ Class:          EBH_ContractApprovalHierarchy
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        EPH-51: Campaign Approval Group Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 27.09.2017 / NEHA LUND / Created the trigger.
*********************************************************************************************************************************/
trigger EBH_ContractApprovalMatrix on EBH_ContractApprovalMatrix__c ( after insert, after update, after delete) {
    
    //trigger control - proceed if trigger switched ON
    if( EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_ContractApprovalMatrixTrigger__c) { 
        
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
                     new EBH_ContractApprovalMatrixHandler().updateContractApprovers( trigger.new, trigger.oldMap);
                }
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                if(Trigger.isUpdate && Trigger.isAfter ) {                     
                     new EBH_ContractApprovalMatrixHandler().updateContractApprovers( trigger.new, trigger.oldMap);
                    
                }
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                if(Trigger.isDelete && Trigger.isAfter ) {                     
                     new EBH_ContractApprovalMatrixHandler().updateContractApprovers( trigger.old, null);
                }
                /*DELETE Block - END*/
                
                /*UNDELETE Block - BEGIN*/
                /*UNDELETE Block - END*/
            
            /*AFTER Block - END*/
       //} 
    }
    
}