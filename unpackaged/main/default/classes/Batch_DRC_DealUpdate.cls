/*********************************************************************************************************************************
@ Class:          Batch_DRC_DealUpdate
@ Version:        1.0
@ Author:         SRONG TIN (srong.tin@gaea-sys.com)
@ Purpose:        DealRetailCampaignTriggerHandler.updateDealStatusByTimeBaseChange fix CPU limit
@ Change history: 06.July.2021 / SRONG TIN / Created the class.
*********************************************************************************************************************************/
global without sharing class Batch_DRC_DealUpdate implements Database.Batchable<SObject>{
     /****************************************************************************************************************************
	* CONSTANTS DEFINITION
	*****************************************************************************************************************************/
    private Set<ID> dealRetailCampaignIds;
    public static final String NA_Unsub_Deal = 'Deal_V3';
    public Id spotlightUsVerticalsId = null;
    public static final String OPS_REVIEW = 'Ops Review';
    public static final String CM_REVIEW = 'CM Review';
    public static final String SCHEDULED = 'Scheduled';
    public static final String RUNNING = 'Running';
    public static final String COMPLETED = 'Completed';
    // 29.July.2021 / SRONG TIN : US-0010037 
    private Set<String> STATUS_REJECTED_CANCELLED;

    Id dealRecordTypeId =  ApexUtil.getRecordTypeByName('EBH_Deal__c', NA_Unsub_Deal).Id;
    private String whereCS = ' WHERE EBH_DealRetailCampaign__c IN: dealRetailCampaignIds AND RecordTypeId =: dealRecordTypeId';
	private final static String SOQL_DEAL = 'SELECT Id, EBH_Status__c,EBH_DealRetailCampaign__c,EBH_DealRetailCampaign__r.Status__c,EBH_SpotlightCategory__c FROM EBH_Deal__c' ;
    /************************************END CONSTANTS DEFINITION*************************************************************/

    public Batch_DRC_DealUpdate(set<Id> dealRetailCampaignIds) {
        this.dealRetailCampaignIds = dealRetailCampaignIds;
        //get defualt Spotlight Category if field Spotlight Category == null
        for(EBH_SpotlightCategory__c spl: [SELECT Id FROM EBH_SpotlightCategory__c WHERE  Name = :Label.US_UnSubDeal_Default_Spotlight limit 1]){
            spotlightUsVerticalsId = spl.Id;
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) 
    {        
        return Database.getQueryLocator(SOQL_DEAL + whereCS);
    }

    global void execute(Database.BatchableContext pBc, List<EBH_Deal__c> scope)
    {
        List<EBH_Deal__c> listDeals = new List<EBH_Deal__c>();
        // 29.July.2021 / SRONG TIN : US-0010037 
        STATUS_REJECTED_CANCELLED = new Set<String>{'Cancelled','Rejected'};
        for(EBH_Deal__c oDeal : scope){
             if(oDeal.EBH_DealRetailCampaign__r.Status__c == CM_REVIEW && oDeal.EBH_Status__c == OPS_REVIEW){
                 // 2 Days at 18:00:00 PST before Deal Window Start Date: 
                 oDeal.EBH_Status__c = CM_REVIEW;
             }else if(oDeal.EBH_DealRetailCampaign__r.Status__c == SCHEDULED && oDeal.EBH_Status__c == CM_REVIEW){
                 // When 1 Day at 18:00:00 PST before Deal Window Start Date:
                 oDeal.EBH_Status__c = SCHEDULED;
                 // If Spotlight Category is NULL, Update 'Spotlight Category' field to 'US Verticals' Category
                if( String.isBlank(oDeal.EBH_SpotlightCategory__c) &&
                    String.isNotBlank(spotlightUsVerticalsId)){
                    oDeal.EBH_SpotlightCategory__c = spotlightUsVerticalsId;
                }   
            // 29.July.2021 / SRONG TIN : US-0010037 
            }else if(oDeal.EBH_DealRetailCampaign__r.Status__c == RUNNING && !STATUS_REJECTED_CANCELLED.contains(oDeal.EBH_Status__c)){
                 // When Deal Window Start Date is reached:
                 oDeal.EBH_Status__c = RUNNING;
             }else if(oDeal.EBH_DealRetailCampaign__r.Status__c == COMPLETED && !STATUS_REJECTED_CANCELLED.contains(oDeal.EBH_Status__c)){
                 // When Deal Window End Date is reached:
                 oDeal.EBH_Status__c = COMPLETED;
             }
             // add list of Deals
             listDeals.add(oDeal);
         }
         if(!listDeals.isEmpty()){
             // update list of Deals
             update listDeals;
         }
		 
    }  
    
    
    global void finish(Database.BatchableContext pBc)
    {
        
    }
}