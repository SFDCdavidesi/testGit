trigger DealInvoiceTrigger on EBH_DealInvoice__c (before insert, after update) {
    //trigger control - proceed if trigger switched ON
    if(EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER) != null &&
        EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).Deal_Invoice_Trigger__c) {

		if(trigger.isBefore)
		{
			if(trigger.isInsert)
			{
				DealInvoiceTriggerHandler.setDefaultCurrency(trigger.new);
				//12.10.2021 - SRONG TIN : US-0010453 - [UK-Deals] Deal Invoice - eBay billing address and VAT changes
				DealInvoiceTriggerHandler.updateEbayVATIsUK(trigger.new);
				
			}
		}

		if(trigger.isAfter){
			if(trigger.isUpdate){
				DealInvoiceTriggerHandler.changeDealStatus(trigger.new);
			}
		}
	}
}