/*********************************************************************************************************************************
@ Class:          CloneFVFControllerTest
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        EPH-7680 Clone function on FVF promo clones Nominated Items
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 20.08.2019 / Sovantheany Dim / Created the class.
*********************************************************************************************************************************/
@isTest
private class CloneFVFControllerTest {

    static testMethod void testapexCloneFVF() {
    	RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	Account acc = new Account(Name='Test Acc1',RecordTypeID = sellerRecordType.Id);
    	insert acc;
    	RecordType prodRecordType = ApexUtil.getRecordTypeByName('Product__c','TTP_Product');
    	Product__c prod = new Product__c(Price_competitor__c = 10, RecordTypeID = prodRecordType.Id,Product_ID__c='testProdId',EAN__c='testEan');
    	insert prod;
    	Seller_to_Product__c sellerToProduct = new Seller_to_Product__c(Seller__c = acc.Id,Product__c = prod.Id,EPID__c='testEpid',eBay_Link__c='testLink',Listing_Title__c='testtitle',Take_Rate__c=10,Price_seller__c=100);
    	insert sellerToProduct;
    	Final_Value_Fee_FVF__c fvf = new Final_Value_Fee_FVF__c();
    	insert fvf;
    	Nominated_Item__c norItem = new Nominated_Item__c(Final_Value_Fee_FVF__c = fvf.Id,Inventory_Diagnostic__c = sellerToProduct.Id);
        insert norItem;
        
        Test.startTest();
        Map<String,Object> mapResult = CloneFVFController.apexCloneFVF(fvf.Id);
        Test.stopTest();
        System.assertEquals('ok',mapResult.get('status'));
    }
}