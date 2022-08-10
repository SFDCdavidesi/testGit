/*********************************************************************************************************************************
@ Class:          EBH_Contract
@ Version:        1.0
@ Author:         Neha Lund
@ Purpose:        Contract Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 08.05.2017 / JOY MONDOL / Created the trigger.
@ Change history: 02.03.2018 / David Herrero/ Commented Approval methods
@ Change history: 12.07.2018 / David Herrero/ Reset values when inserting a new Contract
*********************************************************************************************************************************/

trigger EBH_Contract on Contract (before insert, after insert, before update, after update ) {
    
    //trigger control - proceed if trigger switched ON
    if( EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_ContractTrigger__c) { 
        
        //check trigger recurssion
        //if(EBH_CheckRecursive.runOnce()){          
            
            /*BEFORE Block - BEGIN*/
            if(Trigger.isBefore){
                /*INSERT Block - BEGIN*/
                if(Trigger.isInsert ) {  
                    EBH_ContractTriggerHandler.resetFieldsOnInsert(Trigger.new);
                    EBH_ContractTriggerHandler.updateContractDates( trigger.new, trigger.oldMap);              
                    //EPH-4142 to validate the pre-approved templates
                    EBH_ContractTriggerHandler.validatePreApprovedTemplate(trigger.new, trigger.oldMap);
                    //EPH-89 - To update the contract take rate
                    // DHE 02 -03 - 2018 Commented custom approval process
                    //EBH_ContractTriggerHandler.updateApprovers(trigger.new, trigger.oldMap );
                    EBH_ContractTriggerHandler.updateTakeRate(trigger.new, trigger.oldMap);
                    EBH_ContractTriggerHandler.setDefaultPricingDate(trigger.new);
                    EBH_ContractTriggerHandler.assignUniqueKey(trigger.new);
                }               
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                 if(Trigger.isUpdate) { 
                 	EBH_ContractTriggerHandler.validatePricingDate(trigger.new, trigger.oldMap);  
                    EBH_ContractTriggerHandler.updateContractDates( trigger.new, trigger.oldMap);
                    EBH_ContractTriggerHandler.validatePreApprovedTemplate(trigger.new, trigger.oldMap);
                    //EPH-89 - To update the Contract Take Rate
                    EBH_ContractTriggerHandler.updateTakeRate(trigger.new, trigger.oldMap);
                    
                    EBH_ContractTriggerHandler.updateContractValueExposure( trigger.new, trigger.oldMap);
                   // DHE 02 -03 - 2018 Commented custom approval process
                   // EBH_ContractTriggerHandler.updateApprovers(trigger.new, trigger.oldMap );
                    //EPH-4159 - To lock the update of Contract when status id Ready for eBay Signature
                    EBH_ContractTriggerHandler.lockContractUpdate(trigger.new, trigger.oldMap);
                    EBH_ContractTriggerHandler.validateNotSubmittingWithZeroPricing(Trigger.new);
                    EBH_ContractTriggerHandler.validateBeforeSubmittingForPostCheck(trigger.new, trigger.oldMap);
                    EBH_ContractTriggerHandler.assignUniqueKey(trigger.new);

                    EBH_ContractTriggerHandler.resetContractStatus(trigger.oldMap, trigger.newMap);
                 }
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                /*DELETE Block - END*/
            }
            /*BEFORE Block - END*/
            
            /*AFTER Block - BEGIN*/
            if(Trigger.isAfter){
                /*INSERT Block - BEGIN*/
                
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                if(Trigger.isUpdate){
                    if(!system.isFuture() && !System.IsBatch())
                    EBH_ContractTriggerHandler.updateApprovalComments(trigger.newmap.keyset()); 
					// DHE 02 -03 - 2018 Commented custom approval process
                    //EBH_ContractTriggerHandler.setBUApprover(trigger.new, trigger.oldMap);           
                      
                    // Sophal / 07.09.2021 / US-0010204, US-0010205
                    EBH_ContractTriggerHandler.sendRefurbEmail(trigger.new, trigger.oldMap); 
                }
                
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                /*DELETE Block - END*/
                
                /*UNDELETE Block - BEGIN*/
                /*UNDELETE Block - END*/
            }
            /*AFTER Block - END*/
       //} 
    }
}