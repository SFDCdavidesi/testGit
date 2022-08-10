/*********************************************************************************************************************************
@ Class:          EBH_CampaignMember
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        CampaignMember Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 06.06.2017 / NEHA LUND / Created the trigger.
                  21.06.2017 / NEHA LUND / Commented the Campaign Member Trigger - To be used by future releases
*********************************************************************************************************************************/
trigger EBH_CampaignMember on CampaignMember (before insert, after insert, before update, after update, after delete) {
    
    //trigger control - proceed if trigger switched ON
    if( EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_CampaignMemberTrigger__c) { 
        
        //check trigger recurssion
        //if(EBH_CheckRecursive.runOnce()){          
            
            /*BEFORE Block - BEGIN*/
                
                /*INSERT Block - BEGIN*/
                if(Trigger.isInsert && Trigger.isBefore) {
                	
                    EBH_CampaignMemberTriggerHandler.updateCampaignMemberStatus ( trigger.new, trigger.oldMap );
                }
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                if(Trigger.isUpdate && Trigger.isBefore) {
                	
                    
                    EBH_CampaignMemberTriggerHandler.updateCampaignMemberStatus ( trigger.new, trigger.oldMap );
                   
                   //NK:27/11/2019: US-0000802
                	//NK:US-0007007 moved from 'after update' 
                    EBH_CampaignMemberTriggerHandler.updateSellerDetailToTasks(trigger.new, trigger.oldMap );      
                }
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                if(Trigger.isDelete && Trigger.isBefore) {
                	
                    EBH_CampaignMemberTriggerHandler.updateCampaignMemberStatus ( trigger.new, trigger.oldMap );
                    
                }
                /*DELETE Block - END*/
            
            /*BEFORE Block - END*/
            
            /*AFTER Block - BEGIN*/
            
                /*INSERT Block - BEGIN*/
                /*if(Trigger.isInsert && Trigger.isAfter) {                       
                     EBH_CampaignMemberTriggerHandler.updateCustomRollUpOnCampaign( trigger.new, trigger.oldMap ); 
                                         
                }*/
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                if(Trigger.isUpdate && Trigger.isAfter ) {                     
					           
                    EBH_CampaignMemberTriggerHandler.updateAccountResponse(trigger.new, trigger.oldMap );   
                    
                }
				
				//NK:27/09/2018: EPH-6485
                if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) )
                {
                	EBH_CampaignMemberTriggerHandler.aggregateCMRespone(trigger.new,trigger.oldMap);
                }
				//NK: 16/10/2018: EPH-6562
				if(Trigger.isAfter && Trigger.isUpdate)
                {
                	EBH_CampaignMemberTriggerHandler.updateCampaignToExecute(trigger.new, trigger.oldMap );
                }
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                /*if(Trigger.isDelete && Trigger.isAfter) {                     
                   EBH_CampaignMemberTriggerHandler.updateCustomRollUpOnCampaign( trigger.new, trigger.oldMap );                    
                }*/
                /*DELETE Block - END*/
                
                /*UNDELETE Block - BEGIN*/
                /*UNDELETE Block - END*/
            
            /*AFTER Block - END*/
       //} 
    }
}