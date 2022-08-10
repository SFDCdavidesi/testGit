/*********************************************************************************************************************************
@ Class:          EBH_Campaign
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        Campaign Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 06.06.2017 / NEHA LUND / Created the trigger.
                  21.06.2017 / NEHA LUND / Commented roll up is not required for Release 1, 
                                           This will be used in future releases
                  29.06.2017 / D MAZUMDAR/ added logic to update priorities for child campaigns
                  04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
*********************************************************************************************************************************/
trigger EBH_Campaign on Campaign (after insert, after update, before insert, before update) {
    
    //trigger control - proceed if trigger switched ON
    if( EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_CampaignTrigger__c) { 
        
        //check trigger recurssion
        //if(EBH_CheckRecursive.runOnce()){          
            
            /*BEFORE Block - BEGIN*/
            
                /*INSERT Block - BEGIN*/
                if(Trigger.isInsert && Trigger.isBefore ) {
                    //TH: 18/12/2018: EPH-6851
                	//EBH_CampaignTriggerHandler.checkDuplicateCampaignName(trigger.new, trigger.oldMap);
					//End  
					EBH_CampaignTriggerHandler.updateCampaignDates( trigger.new, trigger.oldMap);  					
                    EBH_CampaignTriggerHandler.updatePrioritiesInChildCampaign(trigger.new, trigger.oldMap, 'insert');
					
                }
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                if(Trigger.isUpdate && Trigger.isBefore ) {				
                    //TH: 18/12/2018: EPH-6851
                	//EBH_CampaignTriggerHandler.checkDuplicateCampaignName(trigger.new, trigger.oldMap);  
                	//End
					EBH_CampaignTriggerHandler.updateCampaignDates( trigger.new, trigger.oldMap);     
                    EBH_CampaignTriggerHandler.updatePrioritiesInChildCampaign(trigger.new, trigger.oldMap, 'update');
					
					//NK:19/11/2018: EPH-6636
                    EBH_CampaignTriggerHandler.validateStatus(trigger.new, trigger.oldMap);
                }
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                /*DELETE Block - END*/
            
            /*BEFORE Block - END*/
            
            /*AFTER Block - BEGIN*/
            
                /*INSERT Block - BEGIN*/
                if(Trigger.isInsert && Trigger.isAfter ) {       
                    //EBH_CampaignTriggerHandler.updatePrioritiesInChildCampaign(trigger.new, trigger.oldMap, 'insert');
                    EBH_CampaignTriggerHandler.createCampaignKPIRecords(trigger.new, trigger.oldMap);
                   
                    //EPH-5854 - to update proposed control group size on Targeting List
                    EBH_CampaignTriggerHandler.updateControlGroupOnSellerList ( trigger.new, trigger.oldMap);
                    
                    //For future implementation-Release 2
                    //EBH_CampaignTriggerHandler.updateCustomRollUpOnParentCampaign( trigger.new, trigger.oldMap);
                    //EBH_CampaignTriggerHandler.createCampaignMemberRecords(trigger.new, trigger.oldMap);
                }
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                if(Trigger.isUpdate && Trigger.isAfter ) { 
                    EBH_CampaignTriggerHandler.updateChildCampaigns(trigger.new, trigger.oldMap);
                    
                     //EPH-5854 - to update proposed control group size on Targeting List
                    EBH_CampaignTriggerHandler.updateControlGroupOnSellerList ( trigger.new, trigger.oldMap);
                   
                    // EBH_CampaignTriggerHandler.updateDistinctRollUp( trigger.new, trigger.oldMap);                    
                    //For future implementation-Release 2
                    //EBH_CampaignTriggerHandler.updateCustomRollUpOnParentCampaign( trigger.new, trigger.oldMap);
                    //EBH_CampaignTriggerHandler.createCampaignMemberRecords(trigger.new, trigger.oldMap);
                    // @Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
					// EBH_CampaignTriggerHandler.updateMarketingTicketDueDate(trigger.new, trigger.oldMap);
                    // end US-0007031
					
					//NK:20/01/2019: EPH-6852
					EBH_CampaignTriggerHandler.checkOutReachStatusChanged(trigger.new, trigger.oldMap);
                }
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                /*DELETE Block - END*/
                
                /*UNDELETE Block - BEGIN*/
                /*UNDELETE Block - END*/
            
            /*AFTER Block - END*/
       //} 
    }
}