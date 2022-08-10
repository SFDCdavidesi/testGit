/*********************************************************************************************************************************
@ Class:          EBH_Account
@ Version:        1.0
@ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
@ Purpose:        Account Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 08.05.2017 / JOY MONDOL / Created the trigger.
                  29.03.2018 / NEHA LUND / To enable/disable the urgency email notifications with the help of checkbox added as 
                                           part of Active Triggers
                  28.07.2021 / Mony Nou / US-0009966 - [EU][GROWTH PORTAL] Deactivate email alert "DE Deals Terms & Conditions V1"
                                - Deactivate method sendDealMailtoContact()
                  28.04.2022 / Loumang SENG / US-0011388 - Deactivate Contact Quality Task creation in the Seller Record
*********************************************************************************************************************************/

trigger EBH_Account on Account (before update, before insert, after insert, after update, after delete) {
    
    
    //trigger control - proceed if trigger switched ON
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) !=null &&
       EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_AccountTrigger__c) { 
        
        //NK:16/12/2019:US-0006885:  in case mass updated by BoB Activation; so no need trigger involved to eat the cpu!
        if(EBH_AccountTriggerHandler.NO_TRIGGER_RUN)
        {
        	return;
        }
        
        //check trigger recurssion
        //if(EBH_CheckRecursive.runOnce()){          
            
            /*BEFORE Block - BEGIN*/
                if(Trigger.isBefore){
                 
                    if(Trigger.isUpdate){
                        if(UserInfo.getUserName().equalsIgnoreCase(Label.EBH_IntegrationUserName) || Test.isRunningTest()){
                            EBH_AccountTriggerHandler.validateDeleteUpsert(trigger.new, trigger.oldMap);
                        } EBH_AccountTriggerHandler.createRecordtypeField(trigger.new);
                        }
                    if (Trigger.isInsert){
                        EBH_AccountTriggerHandler.createRecordtypeField(trigger.new);
                    }
                }
                /*INSERT Block - BEGIN*/
                /*INSERT Block - END*/
                /*DELETE Block - BEGIN*/
                
               
                /*DELETE Block - END*/
            
            /*BEFORE Block - END*/
            
            /*AFTER Block - BEGIN*/
            if(Trigger.isAfter){
            
                 if(Trigger.isDelete) { 
                      //EPH-1796 - to roll up the data through hierarchy for legal entities and sellers                                        
                      EBH_AccountTriggerHandler.updateCustomRollUp(trigger.new, trigger.oldMap);
                 }
                 
                /*INSERT Block - BEGIN*/
                if(Trigger.isInsert ) { 
                     //EPH-1796 - to roll up the data through hierarchy for legal entities and sellers                    
                     EBH_AccountTriggerHandler.updateCustomRollUp(trigger.new, trigger.oldMap);
                }
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                if(Trigger.isUpdate) {   
                     //EPH-1796 - to roll up the data through hierarchy for legal entities and sellers                    
                     EBH_AccountTriggerHandler.updateCustomRollUp(trigger.new, trigger.oldMap);
                     //EPH-3270 - to update the related contact's status based on the Account's Status
                     EBH_AccountTriggerHandler.updateRelatedContactStatus(trigger.new, trigger.oldMap);
                     //EPH-5459 - to enable or disable urgency task notifications
                     if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_EnableUrgencyEmail__c){
                         EBH_AccountTriggerHandler.notifyUrgencyTaskOwner(trigger.new, trigger.oldMap);
                         
                     }
                     EBH_AccountTriggerHandler.removeGDPRContact(trigger.new, trigger.oldMap);
                     
                     /* MN-28072021-Deprecated via US-0009966
                     //deal email to contact user
                     if(EBH_CheckRecursive.runOnce()){ 
                         EBH_AccountTriggerHandler.sendDealMailtoContact(trigger.new,trigger.oldMap);
                     }
                     */
                     /* Loumang-28.04.2022-Deprecated via US-0011388
                     //EPH-5671 Create Contact Quality Task in Seller Record when Status = red for managed sellers
                     EBH_AccountTriggerHandler.createTask(trigger.new, trigger.oldMap); */
                     
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