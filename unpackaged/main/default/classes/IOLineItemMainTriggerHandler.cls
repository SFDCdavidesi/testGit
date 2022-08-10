// MN-26102021-Deprecated via US-0008416
public with sharing class IOLineItemMainTriggerHandler { //implements ITrigger {

	// List<IO_LineItem__c> IOlinesBookingToDFP = new LIst<IO_LineItem__c>();
    // List<IO_LineItem__c> changedDateIOLines = new LIst<IO_LineItem__c>();
    // Set<Id> ioIDs2BuildRS = new Set<Id>(); //RS = Revenue Schedule 

	// public IOLineItemMainTriggerHandler() {
		
	// }


    // public void bulkBefore()
    // {
        
        
    // }

    // public void bulkAfter()
    // {
    // }
    
    // public void beforeInsert(SObject so){
    // }
    
    // public void beforeUpdate(SObject oldSo, SObject so){

    //     IO_LineItem__c ioli = (IO_LineItem__c) oldSo;
    //     IO_LineItem__c old_ioli = (IO_LineItem__c) so;
    //     if(GW_sObject.oneOrMoreFieldsChanged(ioli, old_ioli, new Set<String>{Util.NS+'from_date__c', Util.NS+'until_date__c', Util.NS+'Quantity__c', Util.NS+'Sale_Price__c', Util.NS+'Total_Price__c',Util.NS+'SalesPriceNet__c'})) { 
    //         so.put(Util.NS+'IsPendingDfpPush__c',true);
    //     }
    // }

    // /**
    //  * beforeDelete
    //  *
    //  * This method is called iteratively for each record to be deleted during a BEFORE
    //  * trigger.
    //  */
    // public void beforeDelete(SObject so){   

    // }
    
    // public void afterInsert(SObject so){

    // }
    
    // public void afterUpdate(SObject oldSo, SObject so){
    //     IO_LineItem__c oldIOline = (IO_LineItem__c) oldSo;
    //     IO_LineItem__c newIOline = (IO_LineItem__c) so;
    //     if(oldIOline.Ad_Id__c==null && newIOline.Ad_Id__c!=null){
    //         IOlinesBookingToDFP.add(newIOline);
    //     }
        
    //     if(GW_sObject.oneOrMoreFieldsChanged(newIOline, oldIOline, new Set<String>{Util.NS+'from_date__c', Util.NS+'until_date__c', Util.NS+'Total_Price__c'})) { 
    //         ioIDs2BuildRS.add(newIOline.IO__c);
    //     }
        
    // }
    
    // public void afterDelete(SObject so){
    // }
    
    // /**
    //  * andFinally
    //  *
    //  * This method is called once all records have been processed by the trigger. Use this 
    //  * method to accomplish any final operations such as creation or updates of other records.
    //  */
    // public void andFinally(){
    //     // GW_IO.createRSDailyAndMonthly(IOlinesBookingToDFP); /MN-26102021-US-0010693 GW_IO will be deprecated as a part of this story
    //     // GW_IO.createRSDailyAndMonthly(ioIDs2BuildRS); /MN-26102021-US-0010693 GW_IO will be deprecated as a part of this story
    // }
}