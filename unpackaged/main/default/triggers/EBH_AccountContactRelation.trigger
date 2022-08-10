/*********************************************************************************************************************************
@ Class:          EBH_AccountContactRelation
@ Version:        1.0
@ Author:         NEHA LUND (nalund@deloitte.co.uk)
@ Purpose:        Account Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 31.08.2017 / NEHA LUND / Created the trigger.
*********************************************************************************************************************************/

trigger EBH_AccountContactRelation on AccountContactRelation (before insert, before update, before delete) {
    
    
    //trigger control - proceed if trigger switched ON
    if( EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_AccountContactRelationTrigger__c) { 
        
        //check trigger recurssion
        //if(EBH_CheckRecursive.runOnce()){          
            
            /*BEFORE Block - BEGIN*/
            if(Trigger.isBefore){
                
                /*INSERT Block - BEGIN*/
                if(Trigger.isInsert){
                    //EPH-3293 - to prevent edit/delete of related relationships 
                    //when associated account/contact is deleted or pending termination
                    //US-0011082/vadhanak/29/04/2022: bypassing to allow Linking Account from SEP
                    if(!LinkedAccountsController.IS_LINKING_ACCOUNT)EBH_AccountContactRelationTriggerHandler.validateUpdates(Trigger.new);
                }
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                if(Trigger.isupdate){
                   
                   //EPH-3293 - to prevent edit/delete of related relationships 
                   //when associated account/contact is deleted or pending termination
                   //US-0011082/vadhanak/29/04/2022: bypassing to allow Linking Account from SEP
                   if(!LinkedAccountsController.IS_LINKING_ACCOUNT)EBH_AccountContactRelationTriggerHandler.validateUpdates(Trigger.new);
                }
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                 if(Trigger.isDelete) { 
                 
                    //EPH-3293 - to prevent edit/delete of related relationships 
                    //when associated account/contact is deleted or pending termination
                    //US-0011082/vadhanak/29/04/2022: bypassing to allow Linking Account from SEP
                    if(!LinkedAccountsController.IS_LINKING_ACCOUNT)EBH_AccountContactRelationTriggerHandler.validateUpdates(Trigger.old);
                     
                 }
               
                /*DELETE Block - END*/
             }
            /*BEFORE Block - END*/
            
            /*AFTER Block - BEGIN*/
            
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