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
private class BatchCalculateSellerMetricTest {

    @isTest
	static void test_method() {
		BatchCalculateSellerMetric batch = new BatchCalculateSellerMetric();
	}
    
    /* MN-19/05/2021 - US-0009522 - Retired Codes
    static testMethod void testUpdateMetric() {
    	RecordType sellerRecType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
        Account seller1 = new Account(Name='sellerxxxx001',RecordTypeId=sellerRecType.Id,EBH_PrimarySite__c=BatchCalculateSellerMetric.PRIMARYSITE_DE);
        Account seller2 = new Account(Name='sellerxxxx001',RecordTypeId=sellerRecType.Id,EBH_PrimarySite__c='United Kingdom');
        insert new Account[]{seller1,seller2};
        
        Product__c p1 = new Product__c();
        insert p1;
        
        //DE
        Seller_to_Product__c stp1 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller1.Id,Competitive_Status_seller_2__c=EBH_ConstantsUtility.COMPETITIVE_STATUS_OUTOF_STOCK);
        Seller_to_Product__c stp2 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller1.Id,Competitive_Status_seller_2__c=EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_UN);
        Seller_to_Product__c stp3 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller1.Id,Competitive_Status_seller_2__c=EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_COMPETE);
        
        //None DE
        Seller_to_Product__c stp4 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller2.Id,Competitive_Status_seller__c=EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_UN);
        Seller_to_Product__c stp5 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller2.Id,Competitive_Status_seller__c=EBH_ConstantsUtility.COMPETITIVE_STATUS_OUTOF_STOCK);
        Seller_to_Product__c stp6 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller2.Id,Competitive_Status_seller__c=EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_COMPETE);
          
        insert new List<Seller_to_Product__c>{stp1,stp2,stp3,stp4,stp5,stp6};
        
        Test.startTest();
        	 
        	BatchCalculateSellerMetric b = new BatchCalculateSellerMetric();
        	BatchCalculateSellerMetric b2 = new BatchCalculateSellerMetric(seller1.Id);
        	b.execute(null);
        Test.stopTest();
        Account seller1Sell = [Select Number_of_Top_Products__c,Top_Top_Products_Competitiveness__c,Total_Products_for_Price_Optimisation__c,Total_Products_for_Re_Stocking__c From Account where Id=:seller1.Id];
        Account seller1Sell2 = [Select Number_of_Top_Products__c,Top_Top_Products_Competitiveness__c,Total_Products_for_Price_Optimisation__c,Total_Products_for_Re_Stocking__c From Account where Id=:seller2.Id];
        //commented for removing Total_Products_for_Re_Stocking__c field
 
        //   Account seller1Sell = [Select Number_of_Top_Products__c,Top_Top_Products_Competitiveness__c From Account where Id=:seller1.Id];
        // Account seller1Sell2 = [Select Number_of_Top_Products__c,Top_Top_Products_Competitiveness__c From Account where Id=:seller2.Id];
        System.assertEquals(3,seller1Sell.Number_of_Top_Products__c,'count all related seller to product');
        Decimal numTopProduct = 3;
        Decimal numUncompet = 1;
        Decimal result = ((numTopProduct-numUncompet) /numTopProduct)*100;
        //System.debug('>>>result: '+result);
        //System.debug('>>>seller: '+seller1Sell.Top_Top_Products_Competitiveness__c);
        
        System.assertEquals(3,seller1Sell.Number_of_Top_Products__c ,'sum of STP: Competitive_Status_seller_2__c <> null');
        System.assertEquals(1,seller1Sell.Total_Products_for_Price_Optimisation__c ,'sum of STP: Competitive_Status_seller_2__c = uncompete');
        System.assertEquals(1,seller1Sell.Total_Products_for_Re_Stocking__c ,'sum of STP: Competitive_Status_seller_2__c = compete');
        
        
        System.assertEquals(3,seller1Sell2.Number_of_Top_Products__c ,'sum of STP: Competitive_Status_seller_2__c <> null');
        System.assertEquals(1,seller1Sell2.Total_Products_for_Price_Optimisation__c ,'sum of STP: Competitive_Status_seller_2__c <> null');
        System.assertEquals(1,seller1Sell2.Total_Products_for_Re_Stocking__c ,'sum of STP:Competitive_Status_seller_2__c <> null');
    }
    
    static testMethod void testUpdateMetricStep2() {
    	RecordType sellerRecType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
        Account seller1 = new Account(Name='sellerxxxx001',RecordTypeId=sellerRecType.Id,EBH_PrimarySite__c=BatchCalculateSellerMetric.PRIMARYSITE_DE);
        Account seller2 = new Account(Name='sellerxxxx001',RecordTypeId=sellerRecType.Id,EBH_PrimarySite__c='United Kingdom');
        insert new Account[]{seller1,seller2};
        
        Product__c p1 = new Product__c();
        insert p1;
        
        //DE
        Seller_to_Product__c stp1 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller1.Id,Competitive_Status_seller_2__c=EBH_ConstantsUtility.COMPETITIVE_STATUS_OUTOF_STOCK);
        Seller_to_Product__c stp2 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller1.Id,Competitive_Status_seller_2__c=EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_UN);
        Seller_to_Product__c stp3 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller1.Id,Competitive_Status_seller_2__c=EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_COMPETE);
        
        //None DE
        Seller_to_Product__c stp4 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller2.Id,Competitive_Status_seller__c=EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_UN);
        Seller_to_Product__c stp5 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller2.Id,Competitive_Status_seller__c=EBH_ConstantsUtility.COMPETITIVE_STATUS_OUTOF_STOCK);
        Seller_to_Product__c stp6 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller2.Id,Competitive_Status_seller__c=EBH_ConstantsUtility.COMPETITIVE_STATUS_SELLER_COMPETE);
          
        insert new List<Seller_to_Product__c>{stp1,stp2,stp3,stp4,stp5,stp6};
        
        Test.startTest();
        	 
    	BatchCalculateSellerMetric b2 = new BatchCalculateSellerMetric(new Set<String>{seller1.Id,seller2.Id});
        Database.executeBatch(b2);
        Test.stopTest();
        
        Account seller1Sell = [Select Number_of_Top_Products__c,Top_Top_Products_Competitiveness__c,Total_Products_for_Price_Optimisation__c,Total_Products_for_Re_Stocking__c From Account where Id=:seller1.Id];
        Account seller1Sell2 = [Select Number_of_Top_Products__c,Top_Top_Products_Competitiveness__c,Total_Products_for_Price_Optimisation__c,Total_Products_for_Re_Stocking__c From Account where Id=:seller2.Id];
 
        System.assertEquals(3,seller1Sell.Number_of_Top_Products__c,'count all related seller to product');
        Decimal numTopProduct = 3;
        Decimal numUncompet = 1;
        Decimal result = ((numTopProduct-numUncompet) /numTopProduct)*100;
        //System.debug('>>>result: '+result);
        //System.debug('>>>seller: '+seller1Sell.Top_Top_Products_Competitiveness__c);
        
        System.assertEquals(3,seller1Sell.Number_of_Top_Products__c ,'sum of STP: Competitive_Status_seller_2__c <> null');
        System.assertEquals(1,seller1Sell.Total_Products_for_Price_Optimisation__c ,'sum of STP: Competitive_Status_seller_2__c = uncompete');
        System.assertEquals(1,seller1Sell.Total_Products_for_Re_Stocking__c ,'sum of STP: Competitive_Status_seller_2__c = compete');
        
        //System.debug('>>>----------------------xx1: ');
        System.assertEquals(3,seller1Sell2.Number_of_Top_Products__c ,'sum of STP: Competitive_Status_seller_2__c <> null');
        System.assertEquals(1,seller1Sell2.Total_Products_for_Price_Optimisation__c ,'sum of STP: Competitive_Status_seller_2__c <> null');
        System.assertEquals(1,seller1Sell2.Total_Products_for_Re_Stocking__c ,'sum of STP:Competitive_Status_seller_2__c <> null');
    }
    */
}