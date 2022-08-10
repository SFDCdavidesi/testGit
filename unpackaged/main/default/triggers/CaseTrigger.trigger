/*********************************************************************************************************************************
@ Class:          none
@ User Story:     EPH-2950
@ Version:        1.0
@ Author:         Heiko Seel
@ Purpose:        Ticket Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 11.08.2017 / Heiko Seel / Created the trigger.
----------------------------------------------------------------------------------------------------------------------------------
@ Class:          none
@ User Story:     US-0007615
@ Version:        1.0
@ Author:         Sophal Noch
@ Purpose:        Case Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 19.06.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / Created the triger.
*********************************************************************************************************************************/
trigger CaseTrigger on Case (after insert, after update,before insert, before update) {
  Method_Trigger_Manager__mdt method =  CaseTriggerHandler.readMtdObject('Case_Trigger');


    //trigger control - proceed if trigger switched ON
    if (EBH_ActiveTriggers__c.getInstance(CaseTriggerHandler.TRIGGERCONTROLLER).CaseTrigger__c) {
 
        //check trigger recurssion
        if (EBH_CheckRecursive.runOnce()) {      
  
            /*BEFORE Block - BEGIN*/
              if ((Trigger.isBefore) &&  (Trigger.isInsert || Trigger.isUpdate)) { 
                //NK:21/05/2021:US-0009366
               if (Test.isRunningTest() || ( method.method1__c && method.Method_1_name__c.equals('assignUniqueKey'))){
                CaseTriggerHandler.assignUniqueKey(Trigger.new);  
               } 
                  
                //CaseTriggerHandler.updateCaseValidateSurveywithLatestVersion(trigger.new); 
                if (Test.isRunningTest() || (method.method2__c && method.Method_2_name__c.equals('autoPopulateProfile'))){  
                CaseTriggerHandler.autoPopulateProfile(trigger.new,trigger.oldMap);
                }

                // SRONT TIN - 17/09/2021 : US-0009538 - Automatically validate Ardira Surveys
                if (Test.isRunningTest() || (method.method3__c && method.Method_3_name__c.equals('validateSurveyVista'))){  
                  CaseTriggerHandler.validateSurveyVista(Trigger.new,Trigger.oldMap);
                }
                
                  EBH_CheckRecursive.Run = true;
              }
              /*UPDATE Block - BEGIN*/
              if (Trigger.isBefore && Trigger.isUpdate) {            
                
                //NK:25/05/2021:US-0009366
                if (Test.isRunningTest() || (method.method4__c && method.Method_4_name__c.equals('addPermissionAccess'))){  
                  CaseTriggerHandler.addPermissionAccess(Trigger.new,Trigger.oldMap);
                  }
                
                
                //NK:11/09/2017: #12475
                if (Test.isRunningTest() || (method.method5__c && method.Method_5_name__c.equals('checkCreateUsers'))){  
                  CaseTriggerHandler.checkCreateUsers(Trigger.old,Trigger.new); 
                  }
             

                
              }
              /*UPDATE Block - END*/
            /*BEFORE Block - END*/
  
            /*AFTER Block - BEGIN*/
  
              /*INSERT Block - BEGIN*/
               
              if (Trigger.isAfter && Trigger.isInsert) {
                if (Test.isRunningTest() || ( method.method6__c && method.Method_6_name__c.equals('createTicketShare'))){  
                  CaseTriggerHandler.createTicketShare(Trigger.new, Trigger.oldmap);
                  }
                  
                  //NK:24/05/2022:US-0011343
                  CaseTriggerHandler.manageSPUserDisconnect(Trigger.new);
              }
              /*INSERT Block - END*/
           
              /*UPDATE Block - BEGIN*/
              if (Trigger.isAfter && Trigger.isUpdate) {

                if (Test.isRunningTest() || (method.method6__c && method.Method_6_name__c.equals('createTicketShare'))){  
                  CaseTriggerHandler.createTicketShare(Trigger.new, Trigger.oldmap);
                  }
              
               
              }
              /*UPDATE Block - END*/
  
            /*AFTER Block - END*/
  
        }
  
  
      }

}