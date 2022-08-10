/*********************************************************************************************************************************
@ Class:          EBH_User
@ Version:        1.0
@ Author:         David Herrero
@ Purpose:        User Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 06.06.2018 / David Herrero / Created the trigger.

*********************************************************************************************************************************/

trigger EBH_User on User (before insert, after insert, before update, after update ) {
    
      //trigger control - proceed if trigger switched ON
    if( EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_User__c) {

        if(EBH_UserTriggerHandler.byPassUserTrigger){return;}
            
        //check trigger recurssion
        //if(EBH_CheckRecursive.runOnce()){          
            
            /*BEFORE Block - BEGIN*/
            if(Trigger.isBefore){
                /*INSERT Block - BEGIN*/
                if(Trigger.isInsert ) {  
                    //EBH_ContractTriggerHandler.updateContractDates( trigger.new, trigger.oldMap);              
                    //EPH-4142 to validate the pre-approved templates
                    //EBH_ContractTriggerHandler.validatePreApprovedTemplate(trigger.new, trigger.oldMap);
                    //EPH-89 - To update the contract take rate
                    // DHE 02 -03 - 2018 Commented custom approval process
                    //EBH_ContractTriggerHandler.updateApprovers(trigger.new, trigger.oldMap );
                    //EBH_ContractTriggerHandler.updateTakeRate(trigger.new, trigger.oldMap);
                }               
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                 if(Trigger.isUpdate) {   
                    //EBH_ContractTriggerHandler.updateContractDates( trigger.new, trigger.oldMap);
                    //EBH_ContractTriggerHandler.validatePreApprovedTemplate(trigger.new, trigger.oldMap);
                    //EPH-89 - To update the Contract Take Rate
                    //EBH_ContractTriggerHandler.updateTakeRate(trigger.new, trigger.oldMap);
                    
               //     EBH_ContractTriggerHandler.updateContractValueExposure( trigger.new, trigger.oldMap);
                   // DHE 02 -03 - 2018 Commented custom approval process
                   // EBH_ContractTriggerHandler.updateApprovers(trigger.new, trigger.oldMap );
                    //EPH-4159 - To lock the update of Contract when status id Ready for eBay Signature
                    //EBH_ContractTriggerHandler.lockContractUpdate(trigger.new, trigger.oldMap);
                     
//                    EBH_ContractTriggerHandler.validateNotSubmittingWithZeroPricing(Trigger.new) ;

                    
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
                    if(!system.isFuture() && !System.IsBatch()){
                        EBH_UserTriggerHandler.UpdatePermissionSets(trigger.new,trigger.newMap) ;
                        EBH_UserTriggerHandler.createTicketWhenChangeProfile(trigger.new, trigger.oldMap);

                    }
                        
                    //EBH_ContractTriggerHandler.updateApprovalComments(trigger.newmap.keyset()); 
					// DHE 02 -03 - 2018 Commented custom approval process
                    //EBH_ContractTriggerHandler.setBUApprover(trigger.new, trigger.oldMap);           
                    
					//NK:17/01/2019: EPH-6940:AC3
                    EBH_UserTriggerHandler.deleteDaysForInactiveUsers(trigger.new,trigger.oldMap);
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