trigger DocuSignRecipientStatusTrigger on dsfs__DocuSign_Recipient_Status__c (after update) {
    
    if(Trigger.isUpdate && Trigger.isAfter) {
        // 22.07.2021 / Sophal Noch / US-0009886
        DocuSignRecipientStatusTriggerHandler.updateContractSellerContact(trigger.new, trigger.oldMap);
    }
}