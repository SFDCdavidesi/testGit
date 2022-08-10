/*********************************************************************************************************************************
@ Class:          EBH_Contact
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        EPH-3270: Sprint 7: Contact Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 28.09.2017 / NEHA LUND / Created the trigger.
*********************************************************************************************************************************/

trigger EBH_Contact on Contact (before update, before insert, after insert, after update, after delete,after undelete) {
    
    //trigger control - proceed if trigger switched ON
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
       EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_ContactTrigger__c) { 

         /*BEFORE Block - BEGIN*/
          if(Trigger.isBefore){
              if(Trigger.isUpdate){
                      if(UserInfo.getUserName().equalsIgnoreCase(Label.EBH_IntegrationUserName) || Test.IsRunningTest()){
                           EBH_ContactTriggerHandler.validateDeleteUpsert(trigger.new, trigger.oldMap);
                      }
                      
                      EBH_ContactTriggerHandler.removeGDPRContact (trigger.new, trigger.oldMap);
              }
              if(trigger.isInsert ||Trigger.isUpdate){
                  //EPH-5629 Contact - Quality & Preference
                  //   EBH_ContactTriggerHandler.checkPrimaryContact(trigger.new, trigger.oldMap,Trigger.isUpdate);
              }
              //NK:04/05/2022:US-0011343
              if(trigger.isInsert)
              {
                  EBH_ContactTriggerHandler.setCloneSource(trigger.new);
              }
                 
          }
                /*INSERT Block - BEGIN*/
                /*INSERT Block - END*/
                /*DELETE Block - BEGIN*/
                
               
                /*DELETE Block - END*/
            
            /*BEFORE Block - END*/
            
            /*AFTER Block - BEGIN*/
            
             if((trigger.isAfter && trigger.isUpdate) ||
             (trigger.isAfter && trigger.isInsert) ||
             (trigger.isAfter && trigger.isDelete) ||
             (trigger.isAfter && trigger.isUndelete)
            )
            {
                    EBH_ContactTriggerHandler.countNumberOfContactsWithIssues((trigger.isDelete?trigger.old:trigger.new));
            }   
          if(trigger.isAfter && (trigger.isInsert|| trigger.isUpdate)){
          	 
              
              EBH_ContactTriggerHandler.updatePrimaryContactFlag(Trigger.new,Trigger.isupdate);
              
              EBH_ContactTriggerHandler.UpdateAccountPrimaryContactRelatedFields(Trigger.new);
          }
            /*AFTER Block - END*/
      
    }
}