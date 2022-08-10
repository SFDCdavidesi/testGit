/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
/*
@ Change history: 19.05.2021 / Mony Nou / Retired codes / US-0009522 - [EU] [AU] Trading Engine: retire Apex
*********************************************************************************************************************************/
@isTest
private class SellerToProductTriggerHandlerTest {

	@isTest
	static void test_method() {
		SellerToProductTriggerHandler obj = new SellerToProductTriggerHandler();
		BatchCalculateSellerToProduct batch = new BatchCalculateSellerToProduct();
	}

	/*  MN-19/05/2021 - US-0009522 - Retired Codes
	static testmethod void setupData(){
        EBH_TestDataFactory.setUpCustomSettings();   
        
       
    }
    
    static testMethod void testCalculateProductFields()
	{
        setupdata();
    	RecordType sellerRecType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
        Account seller1 = new Account(Name='sellerxxxx002',RecordTypeId=sellerRecType.Id);
        insert seller1;
        
        Product__c p1 = new Product__c();
        Product__c p2 = new Product__c();
        insert new Product__c[]{p1,p2};
        
        Seller_to_Product__c stp1 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller1.Id);
        Seller_to_Product__c stp2 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller1.Id,Competitive_Status_seller__c=EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_UN);
        Seller_to_Product__c stp3 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller1.Id);
        
        Seller_to_Product__c stp4 = new Seller_to_Product__c(Product__c=p2.Id,Seller__c=seller1.Id,Competitive_Status_seller__c=EBH_ConstantsUtility.COMPETITIVE_STATUS_OUTOF_STOCK);
        Seller_to_Product__c stp5 = new Seller_to_Product__c(Product__c=p2.Id,Seller__c=seller1.Id,Competitive_Status_seller__c=EBH_ConstantsUtility.COMPETITIVE_STATUS_OUTOF_STOCK);
        
        List<Seller_to_Product__c> listSTP = new List<Seller_to_Product__c>{stp1,stp2,stp3,stp4,stp5};
        Batch_Job_Runner__c runner = new Batch_Job_Runner__c(Job_Status__c=EBH_ConstantsUtility.JOB_STATUS_NEW ,Batch_Name__c='BatchCalculateSellerToProduct');
        
        Test.startTest();
        	system.debug('---------------------------------start here--------------------');
        	insert runner;
        
        Test.stopTest();
        
        BatchCalculateSellerToProduct batchCal = new BatchCalculateSellerToProduct(runner.Id); 
          
        	system.debug('////////////////////////test insert/////////////////////////////////////');
        	insert listSTP;
        	batchCal.execute(null,listSTP);
        	Map<Id,Product__c> mapProducts = new Map<Id,Product__c>([Select Id,Total_Sellers_for_Re_stocking__c,Total_Sellers_for_Price_Optimization__c,Total_Sellers_on_eBay__c from Product__c where Id =:p1.Id OR Id=:p2.Id]);
        	Product__c p1_sel = mapProducts.get(p1.Id);
        	Product__c p2_sel = mapProducts.get(p2.Id);
        
        	System.assertEquals(3,p1_sel.Total_Sellers_on_eBay__c,'3 total records');
        	System.assertEquals(null,p1_sel.Total_Sellers_for_Re_stocking__c,'no stocking records');
        	System.assertEquals(1,p1_sel.Total_Sellers_for_Price_Optimization__c,'1 uncompetetive record');
        	
        	System.assertEquals(2,p2_sel.Total_Sellers_for_Re_stocking__c,'2 out of stock records');
        	System.assertEquals(2,p2_sel.Total_Sellers_on_eBay__c,'2 total record');
        	System.assertEquals(null,p2_sel.Total_Sellers_for_Price_Optimization__c,'no uncopetitive');
        	
        	stp1.Competitive_Status_seller__c = EBH_ConstantsUtility.COMPETITIVE_STATUS_OUTOF_STOCK;
        	system.debug('////////////////////////test update/////////////////////////////////////');
        	update stp1;
        	batchCal.execute(null,listSTP);
        	
        	mapProducts = new Map<Id,Product__c>([Select Id,Total_Sellers_for_Re_stocking__c,Total_Sellers_for_Price_Optimization__c,Total_Sellers_on_eBay__c from Product__c where Id =:p1.Id OR Id=:p2.Id]);
        	p1_sel = mapProducts.get(p1.Id);
        	System.assertEquals(1,p1_sel.Total_Sellers_for_Re_stocking__c,'1 stocking records after updated');
        	system.debug('////////////////////////test delete/////////////////////////////////////');
        	delete stp1;
        	batchCal.execute(null,listSTP);
        	
        	mapProducts = new Map<Id,Product__c>([Select Id,Total_Sellers_for_Re_stocking__c,Total_Sellers_for_Price_Optimization__c,Total_Sellers_on_eBay__c from Product__c where Id =:p1.Id OR Id=:p2.Id]);
        	p1_sel = mapProducts.get(p1.Id);
        	System.assertEquals(0,p1_sel.Total_Sellers_for_Re_stocking__c,'0 stocking records after deleted');
        	system.debug('////////////////////////test undelete/////////////////////////////////////');
        	undelete stp1;
        	batchCal.execute(null,listSTP);
        	
        	mapProducts = new Map<Id,Product__c>([Select Id,Total_Sellers_for_Re_stocking__c,Total_Sellers_for_Price_Optimization__c,Total_Sellers_on_eBay__c from Product__c where Id =:p1.Id OR Id=:p2.Id]);
        	p1_sel = mapProducts.get(p1.Id);
        	System.assertEquals(1,p1_sel.Total_Sellers_for_Re_stocking__c,'0 stocking records after restoration from undelete');
        	
        	//for unreachable methods/properties
        	batchCal.listErrorAtBatch.add(1);
        	batchCal.appandMsg('test msg');
        	batchCal.finish(null);
        	
        	Batch_Job_Runner__c runner2 = new Batch_Job_Runner__c(Job_Status__c=EBH_ConstantsUtility.JOB_STATUS_NEW ,Batch_Name__c='XXXXXX');
        	insert runner2;
    }
	*/
}