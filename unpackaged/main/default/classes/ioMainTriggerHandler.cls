// MN-26102021-Deprecated via US-0008416
public with sharing class ioMainTriggerHandler { // implements ITrigger{

    // //List<IO__C> lstIOtoCreateAdCampaign = new List<IO__C> ();
	// Set<Id> ioIDsNeedApprovers = new Set<Id>();
	// Set<Id> ioIDsLegal = new Set<Id>();
    // Set<Id> ioIDs2BuildRS = new Set<Id>(); //RS = Revenue Schedule 

	// List<IO__c> termUpdatedIO = new List<IO__c>();
    // public ioMainTriggerHandler() {
        
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
    //     //IO__c io = (IO__c) so;
    //     //IO__c oldIo = (IO__c) oldSo;
    //     //if (io.IO_Status__c == Label.IO_STATUS_APPROVED && GW_sObject.oneOrMoreFieldsChanged(so, oldSo, new Set<String>{Util.NS+'IO_Status__c'})) {
    //     //    lstIOtoCreateAdCampaign.add(io);
    //     //}
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
    // 	IO__c io = (IO__c) so;
    //     IO__c oldIo = (IO__c) oldSo;
    // 	if(GW_sObject.oneOrMoreFieldsChanged(so, oldSo, new Set<String>{Util.NS+'Rollup_Summary_Total_Order_Amount__c'})) { 
    // 		ioIDsNeedApprovers.add(io.Id);
    // 	}
    // 	if(GW_sObject.oneOrMoreFieldsChanged(so, oldSo, new Set<String>{Util.NS+'Rollup_Summary_Total_Order_Amount__c', Util.NS+'IO_Paper__c'})) {
    // 		ioIDsLegal.add(io.Id);
    // 	}

    //     if( GW_sObject.isFieldChanged(so, oldSo, Util.NS +'IO_Paper__c') ){
    //         if(!setErrorIfSigned(io)){
    //             termUpdatedIO.add(io);    
    //         }     
    //     }

    //     if( GW_sObject.isFieldChanged(so, oldSo, Util.NS +'Dually_Signed_IO__c') && io.Dually_Signed_IO__c ){
    //         ioIDs2BuildRS.add(io.Id);    
    //     }
    // }

    // private boolean setErrorIfSigned(IO__c io){
    //     if(io.Dually_Signed_IO__c) {
    //         io.IO_Paper__c.addError(Label.ERR_UPDATE_TERMS);
    //         return true;
    //     }
    //     return false;
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
    //     //GW_IO.createAdCampaign(lstIOtoCreateAdCampaign, true);
    //     /* MN-26102021-US-0010693 GW_IO will be deprecated as a part of this story
    //     GW_IO.setApprovers(ioIDsNeedApprovers, ioIDsLegal);
    //     GW_IO.syncRec(termUpdatedIO);
    //     GW_IO.createRSDailyAndMonthly(ioIDs2BuildRS);
    //     */
    // }
 
 }