/*********************************************************************************************************************************
@ Class:          none
@ User Story:     EPH-2950
@ Version:        1.0
@ Author:         Heiko Seel
@ Purpose:        Ticket Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 11.08.2017 / Heiko Seel / Created the trigger.
*********************************************************************************************************************************/

trigger TicketTrigger on Ticket__c (after insert, after update,before insert, before update) {//NK:11/09/2017:added before update
      
        //trigger control - proceed if trigger switched ON
    if (EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_TicketTrigger__c) { 
     
      //check trigger recurssion
      if (EBH_CheckRecursive.runOnce()) {      

          /*BEFORE Block - BEGIN*/
			if ((Trigger.isBefore) &&  (Trigger.isInsert || Trigger.isUpdate)) { 
				
				TicketTriggerHandler.autoPopulateProfile(trigger.new,trigger.oldMap);
			}
            /*UPDATE Block - BEGIN*/
            if (Trigger.isBefore && Trigger.isUpdate) {            
				
              //NK:11/09/2017: #12475
              TicketTriggerHandler.checkCreateUsers(Trigger.old,Trigger.new); 

            }
            /*UPDATE Block - END*/

          /*BEFORE Block - END*/

          /*AFTER Block - BEGIN*/

            /*INSERT Block - BEGIN*/
             
            if (Trigger.isAfter && Trigger.isInsert) {
              TicketTriggerHandler.createTicketShare(Trigger.new, Trigger.oldmap);
            }
            /*INSERT Block - END*/
		 
            /*UPDATE Block - BEGIN*/
            if (Trigger.isAfter && Trigger.isUpdate) {
              TicketTriggerHandler.createTicketShare(Trigger.new, Trigger.oldmap);
            }
            /*UPDATE Block - END*/

          /*AFTER Block - END*/

      }


    }
}