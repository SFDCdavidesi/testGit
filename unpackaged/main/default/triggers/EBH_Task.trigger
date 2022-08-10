/*********************************************************************************************************************************
@ Class:          EBH_Task
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        EPH-3780: Campaign Approval Group Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 11.10.2017 / NEHA LUND / Created the trigger.
@ Change history: 15.07.2022/ Sophal Noch / US-0011996 - Call booking for Ads
*********************************************************************************************************************************/
trigger EBH_Task on Task ( before insert, after insert, after update, after delete,before update,before delete) {
    
    //trigger control - proceed if trigger switched ON
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_TaskTrigger__c) { 
        
        //check trigger recurssion
        //if(EBH_CheckRecursive.runOnce()){          
            
            /*BEFORE Block - BEGIN*/
            
                /*INSERT Block - BEGIN*/
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                /*DELETE Block - END*/
             if(Trigger.isInsert && Trigger.isBefore ) {  
                     //EPH-4122: to map Account with whatId   
                     EBH_TaskTriggerHandler.captureUrgencyAccountID(trigger.new);
                     EBH_TaskTriggerHandler.PopulateCampaignCountry(trigger.new, trigger.oldMap); //2019-01-23 Added by DHE   
                 	 EBH_TaskTriggerHandler.updatePriorityOrderFromFollowUpTasks(trigger.new); //2019-06-20 Added by DHE

					//NK:12/02/2019: EPH-7043
                    EBH_TaskTriggerHandler.populateTargetDateFromTask(trigger.new, trigger.oldMap);
                  EBH_TaskTriggerHandler.updateCallBackDateTime(trigger.new,Trigger.oldMap);//2019-04-17 Added by DHE
                  
                  //NK:14/06/2019: EPH-7586
                  EBH_TaskTriggerHandler.preventActivityOnInactiveContact(trigger.new,Trigger.oldMap);
                }

            // put back the missing line
            if ((Trigger.isUpdate || Trigger.isDelete) && Trigger.isBefore){
                List<Task> listTaskToPrevent = Trigger.isUpdate ? trigger.new : trigger.old;
                EBH_TaskTriggerHandler.preventLogTask(listTaskToPrevent);
            }


           	if (Trigger.isUpdate && Trigger.isBefore){
                EBH_TaskTriggerHandler.PopulateCampaignCountry(trigger.new, trigger.oldMap); //2019-01-23 Added by DHE
                EBH_TaskTriggerHandler.updateCampaignMember(trigger.new,Trigger.oldMap);//2019-04-08 Added by DHE
                EBH_TaskTriggerHandler.updateCallBackDateTime(trigger.new,Trigger.oldMap);//2019-04-17 Added by DHE
				
				//NK:12/02/2019: EPH-7043
                EBH_TaskTriggerHandler.populateTargetDateFromTask(trigger.new, trigger.oldMap);
                
                //NK:14/06/2019: EPH-7586
                EBH_TaskTriggerHandler.preventActivityOnInactiveContact(trigger.new,Trigger.oldMap);
                
                //NK:18/06/2019: EPH-7525
                EBH_TaskTriggerHandler.historyTask(trigger.new,Trigger.oldMap);

            }
            /*BEFORE Block - END*/
            
            /*AFTER Block - BEGIN*/
            
                /*INSERT Block - BEGIN*/
                if(Trigger.isInsert && Trigger.isAfter ) {     
                    EBH_TaskTriggerHandler.captureMemberResponseCode(trigger.new, trigger.oldMap);              
                    EBH_TaskTriggerHandler.createFulfilmentProject(trigger.new);
                    EBH_TaskTriggerHandler.populateSchduleSlotsWithTask(trigger.new, trigger.oldMap);  //15.07.2022/ Sophal Noch / US-0011996
                }
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                if(Trigger.isUpdate && Trigger.isAfter ) {       
                    EBH_TaskTriggerHandler.captureMemberResponseCode(trigger.new, trigger.oldMap);
                    EBH_TaskTriggerHandler.sendEventAfterStartCallScript(Trigger.new,Trigger.oldMap);   // 14.06.2021 / Sophal Noch / US-0009379        
                    EBH_TaskTriggerHandler.populateSchduleSlotsWithTask(trigger.new, trigger.oldMap); //15.07.2022/ Sophal Noch / US-0011996
                }
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                if(Trigger.isDelete && Trigger.isAfter ) {
                    EBH_TaskTriggerHandler.populateSchduleSlotsWithTask(trigger.old, null); //15.07.2022/ Sophal Noch / US-0011996            
                }
                /*DELETE Block - END*/
                
                /*UNDELETE Block - BEGIN*/
                /*UNDELETE Block - END*/
            
            /*AFTER Block - END*/
       //} 
    }
    
}