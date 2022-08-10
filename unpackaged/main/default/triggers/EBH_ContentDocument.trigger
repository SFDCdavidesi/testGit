/*********************************************************************************************************************************
@ Class:          EBH_ContentDocument
@ Version:        1.0
@ Author:         Neha Lund
@ Purpose:        Content Document Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 08.12.2017 / JOY MONDOL / Created the trigger.
*********************************************************************************************************************************/
trigger EBH_ContentDocument on ContentDocument (before delete, after insert) {
    
    //trigger control - proceed if trigger switched ON
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) !=null &&
       EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).EBH_ContentDocumentTrigger__c) { 
    System.debug(Trigger.isAfter);
           System.debug(Trigger.isInsert);
        if(Trigger.isBefore && trigger.isDelete){
            
                     Set<ID> contentIds = new Set<ID>();
                     for(ContentDocument cd: trigger.old){
                         contentIds.add(cd.Id);
                     }
                        EBH_ContentDocumentLinkHandler.validateAttachmentDeletion(trigger.oldMap);
                    
        }
        /* else if (Trigger.isafter && Trigger.isInsert){
               System.debug('###################' + Trigger.newMap);
               EBH_ContentDocumentLinkHandler.validateAttachmentInsertion(Trigger.newMap);
               
           }*/
    }

}