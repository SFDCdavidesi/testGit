/*********************************************************************************************************************************
@ Class:          EBH_ContentDocumentLink
@ Version:        1.0
@ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
@ Purpose:        ContentDocumentLink trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 19.06.2017 / JOY MONDOL / Created the trigger.
*********************************************************************************************************************************/
trigger EBH_ContentDocumentLink on ContentDocumentLink (after insert) {
	//Theany 29 jan 2020 : US-0003807 [Contracts] Ability to clone pricing details when cloning Contract
    if(CloneContractController.from_clone == true) return;
    //trigger control - proceed if trigger switched ON
    if( EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_ContentDocumentLinkTrigger__c) { 
        
        //check trigger recurssion
        //if(EBH_CheckRecursive.runOnce()){          
            
            /*BEFORE Block - BEGIN*/
            
             
                /*INSERT Block - BEGIN*/
                /*INSERT Block - END*/
                
                /*UPDATE Block - BEGIN*/
                /*UPDATE Block - END*/
                
                /*DELETE Block - BEGIN*/
                
                /*DELETE Block - END*/
            
            
            /*BEFORE Block - END*/
            
            /*AFTER Block - BEGIN*/
            
                /*INSERT Block - BEGIN*/
                if(Trigger.isInsert && Trigger.isAfter ) {                     
                    EBH_ContentDocumentLinkHandler.validateAttachmentInsertion(Trigger.newMap);
                     EBH_ContentDocumentLinkHandler.updateTrainingMaterialFileURL(trigger.newMap);
                     EBH_ContentDocumentLinkHandler.updateContractAttachmentCheck(trigger.new);
                   
                }
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