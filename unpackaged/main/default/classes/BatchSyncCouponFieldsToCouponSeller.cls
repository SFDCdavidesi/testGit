/*********************************************************************************************************************************
@ Class     :       BatchSyncCouponFieldsToCouponSeller
@ Version   :       1.0
@ Author    : 	    Mony Nou (mony.nou@gaea-sys.com)
@ Purpose	:	    US-0010785 - Refactor Coupon Seller object to support standard search (AC3)
@					 - In case the sync logic inside CouponTriggerHandler.syncCouponInfo2CouponSellers() fail due to SF Govern limit
                    When there are heap records of coupon seller => we using this batch + schedule daily to update those failed records
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 27.06.2022 / Mony Nou/ Create Method
*********************************************************************************************************************************/
global with sharing class BatchSyncCouponFieldsToCouponSeller implements Database.Batchable<SObject>, Schedulable {
    
    private final static String COUPON_OBJNAME = 'Coupon__c';
	private final static String COUPON_CATEGORYBASE = 'Category_Based'; 
    private final static String COUPON_ITEMBASE = 'Item_Based'; 
	
    global Database.QueryLocator start(Database.BatchableContext BC){

        RecordType cpnRTypeCateBase = ApexUtil.getRecordTypeByName(COUPON_OBJNAME,COUPON_CATEGORYBASE);
		RecordType cpnRTypeItemBase = ApexUtil.getRecordTypeByName(COUPON_OBJNAME,COUPON_ITEMBASE);
        Set<Id> sValidRT = new Set<Id> {cpnRTypeCateBase.Id, cpnRTypeItemBase.Id}; 
        Set<String> sValidStage = new Set<String> {'Targeted','Reached','Commited','Contract Negotiation','Approved','Review','Contract Send','Contract Signed'};
        
        String query = 'SELECT Id,Coupon_Marketing_Name__c,Coupon_Code__c, Coupon__r.Marketing_Coupon_Name__c, Coupon__r.Coupon_ID__c  FROM Coupon_Seller__c WHERE Coupon__r.RecordTypeId IN:sValidRT' 
                        + ' AND Coupon_Seller_Stage__c IN:sValidStage'
                        + ' AND Seller__c IN (SELECT AccountId FROM Contact WHERE Community_User__c != NULL AND Active_Community_User__c = TRUE)';

        return Database.getQueryLocator(query);

    }

    global void execute(Database.BatchableContext bc, List<Coupon_Seller__c> scope) {

        List<Coupon_Seller__c> lstCS2Update = new List<Coupon_Seller__c>();

        for (Coupon_Seller__c cs : scope) {

            Coupon__c cp = (Coupon__c) cs.getSobject('Coupon__r');

            if (cs.Coupon_Marketing_Name__c != cp.Marketing_Coupon_Name__c || cs.Coupon_Code__c != cp.Coupon_ID__c) {
                
                if (cs.Coupon_Marketing_Name__c != cp.Marketing_Coupon_Name__c) cs.Coupon_Marketing_Name__c = cp.Marketing_Coupon_Name__c;
                if (cs.Coupon_Code__c != cp.Coupon_ID__c) cs.Coupon_Code__c = cp.Coupon_ID__c;
                
                lstCS2Update.add(cs);
            } 

            
        }

        if (!lstCS2Update.isEmpty()) Database.update(lstCS2Update, false);

 
    }

    global void finish(Database.BatchableContext bc) {}

    global void execute(SchedulableContext sc) 
    {
        BatchSyncCouponFieldsToCouponSeller bat = new BatchSyncCouponFieldsToCouponSeller();
        Database.executeBatch(bat,200);
    }
}