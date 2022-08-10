/*********************************************************************************************************************************
	@ Method:         Batch_CreateCoInvest
	@ Version:       1.0
	@ Author:        Vadhanak Voun (vadhanak.voun@gaea-sys.com)
	@ Purpose:       US-0007195 - Coupon Co-Invest records creation is causing System.LimitException: Too many SOQL queries: 101 error
	@               CouponTriggerHandler.createCoInvestWithRecordType
	@               to fix CPU limit
	----------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 15.05.2020/ Vadhanak Voun (vadhanak.voun@gaea-sys.com) / Created the Method.
	*********************************************************************************************************************************/
global without sharing class Batch_CreateCoInvest implements Database.Batchable<SObject>{
	 /****************************************************************************************************************************
	* CONSTANTS DEFINITION
	*****************************************************************************************************************************/
	private Set<ID> sCoupon;
    private String whereCS = ' where Coupon__c IN: sCoupon';
	private final static String SOQL_COUPON_SELLER_2 = 'Select Coupon__r.Couponsite_s__c,Seller__r.Strategic_Seller_Share_w__c,Coupon__r.Seller_Co_funding_share_forecast__c,Coupon__r.Contract_Language__c, Date_4days_Sent__c, Date_34_days_Sent__c, TriggerEmailManhattan__c, Id,Seller__c,Seller__r.EBH_OracleID__c,Coupon__c,Coupon_Seller_Stage__c,Coupon__r.RecordTypeID,Coupon__r.RecordType.DeveloperName,Coupon__r.Stage__c,SellerShareHolder__c From Coupon_Seller__c' ;
	/************************************END CONSTANTS DEFINITION*************************************************************/

    public Batch_CreateCoInvest(Set<ID> sCoupon) 
    {
        this.sCoupon = sCoupon;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) 
    {        
        return Database.getQueryLocator(SOQL_COUPON_SELLER_2 + whereCS);
    }

    global void execute(Database.BatchableContext pBc, List<Coupon_Seller__c> scope)
    {
       CouponTriggerHandler.processCoInvest(scope);
		 
    }  
    
    
    global void finish(Database.BatchableContext pBc)
    {
        
    }
}