/*********************************************************************************************************************************
@ Class:          Norminate_for_FVF_DiscountTest
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        test Class for trigger FinalValueFee_FVF
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 13.05.2019 / Sovantheany Dim / Created the class.
*********************************************************************************************************************************/
@isTest
private class Norminate_for_FVF_DiscountTest {

    static testMethod void myUnitTest() {
    	RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	Account acc = new Account(Name='Test Acc1',RecordTypeID = sellerRecordType.Id);
    	insert acc;
		RecordType prodRecordType = ApexUtil.getRecordTypeByName('Product__c','TTP_Product');
    	Product__c prod = new Product__c(Price_competitor__c = 10, RecordTypeID = prodRecordType.Id);
    	insert prod;
    	List<Seller_to_Product__c> lstSellerToProduct = new List<Seller_to_Product__c>();
    	Seller_to_Product__c sellerToProduct = new Seller_to_Product__c(Seller__c = acc.Id,Product__c = prod.Id);
    	Seller_to_Product__c sellerToProduct1 = new Seller_to_Product__c(Seller__c = acc.Id,Product__c = prod.Id);
    	lstSellerToProduct.add(sellerToProduct);
    	lstSellerToProduct.add(sellerToProduct1);
    	insert lstSellerToProduct;
        
        Test.startTest();
        Test.setCurrentPage(Page.Norminate_for_FVF_Discount);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstSellerToProduct);
        stdSetController.setSelected(lstSellerToProduct);
        Norminate_for_FVF_Discount_Controller fvfController = new Norminate_for_FVF_Discount_Controller(stdSetController);
        Test.stopTest();
        System.assert(!fvfController.isError);
    }
}