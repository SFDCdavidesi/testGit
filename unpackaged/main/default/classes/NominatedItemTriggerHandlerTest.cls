/*********************************************************************************************************************************
@ Class:          NominatedItemTriggerHandlerTest
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        test Handler Class for trigger NominatedItem
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 29.05.2019 / Sovantheany Dim / Created the class.
*********************************************************************************************************************************/
@isTest
private class NominatedItemTriggerHandlerTest {
    static testmethod void setupData(){
        EBH_TestDataFactory.setUpCustomSettings();   
        
       
    }
    static testMethod void myUnitTest() {
        setupdata();
    	RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	Account acc = new Account(Name='Test Acc1',RecordTypeID = sellerRecordType.Id,EBH_RevRollup__c = 'UK');
    	insert acc;
    	RecordType prodRecordType = ApexUtil.getRecordTypeByName('Product__c','TTP_Product');
    	Product__c prod = new Product__c(Price_competitor__c = 10, RecordTypeID = prodRecordType.Id,Product_ID__c='testProdId',EAN__c='testEan');
    	insert prod;
    	Seller_to_Product__c sellerToProduct = new Seller_to_Product__c(Seller__c = acc.Id,Product__c = prod.Id,EPID__c='testEpid',eBay_Link__c='testLink',Listing_Title__c='testtitle',Take_Rate__c=10,Price_seller__c=100);
    	insert sellerToProduct;
    	Final_Value_Fee_FVF__c fvf = new Final_Value_Fee_FVF__c(Discount_FVF__c = 25,Seller_Name__c = acc.Id);
    	insert fvf;
    	
    	Nominated_Item__c norItem = new Nominated_Item__c(Final_Value_Fee_FVF__c = fvf.Id,Inventory_Diagnostic__c = sellerToProduct.Id);
        Test.startTest();
        insert norItem;
		Test.stopTest();
	
	 List<Nominated_Item__c> lstItem = [select EPID_w__c,EAN_w__c,eBay_Link_w__c,Listing_Name_w__c,Take_Rate_w__c,Product_ID_w__c,Discount_FVF_w__c from Nominated_Item__c where id =: norItem.Id];
        System.assert(lstItem.size() == 1);
        for(Nominated_Item__c item : lstItem){
        	System.assertEquals(item.EPID_w__c,sellerToProduct.EPID__c);
        	System.assertEquals(item.EAN_w__c,prod.EAN__c);
        	System.assertEquals(item.eBay_Link_w__c,sellerToProduct.eBay_Link__c);
        	System.assertEquals(item.Listing_Name_w__c,sellerToProduct.Listing_Title__c);
        	System.assertEquals(item.Take_Rate_w__c,sellerToProduct.Take_Rate__c);
        	//System.assertEquals(item.Price_seller_w__c,sellerToProduct.Price_seller__c);
        	System.assertEquals(item.Product_ID_w__c,prod.Product_ID__c);
        	System.assertEquals(item.Discount_FVF_w__c,fvf.Discount_FVF__c);
        }
    }

	static testMethod void updateNominatedByOwnerAndRequestorTest(){
		
		setupdata();

		Id profileAdminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
		Id profileBAId = [SELECT Id FROM Profile WHERE Name = 'Business Admin'].Id;
		
    	RecordType contacDW_RT = ApexUtil.getRecordTypeByName('Contact','EBH_DWH');
        Contact cont = new Contact(LastName='Test Cont1',RecordTypeID=contacDW_RT.Id);
        insert cont;

        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	Account acc = new Account(Name='Test Acc1',RecordTypeID = sellerRecordType.Id,Primary_Contact__c=cont.Id,EBH_RevRollup__c = 'UK');
    	insert acc;

		User usr = new User(Username = 'test@samppp.com', Email = 'test@samp.com', Alias = 'tsamp', IsActive = true, LastName='Test', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', ProfileId=profileAdminId, LanguageLocaleKey='en_US');
		User usr2 = new User(Username = 'test2@samppp.com', Email = 'test2@samp.com', Alias = 'tsamp', IsActive = true, LastName='Test', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', ProfileId=profileAdminId, LanguageLocaleKey='en_US');
		User usr3 = new User(Username = 'test3@samppp.com', Email = 'test3@samp.com', Alias = 'tsamp', IsActive = true, LastName='Test', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', ProfileId=profileBAId, LanguageLocaleKey='en_US');
		insert new List<User>{usr, usr2, usr3};
		
    	Final_Value_Fee_FVF__c fvf = new Final_Value_Fee_FVF__c(Discount_FVF__c = 25, Seller_Name__c = acc.Id,Seller_Email__c='test@test.com', Requestor__c=usr.Id);
		Final_Value_Fee_FVF__c fvf2 = new Final_Value_Fee_FVF__c(Discount_FVF__c = 25, Seller_Name__c = acc.Id,Seller_Email__c='test2@test.com', Requestor__c=usr2.Id);
    	insert new List<Final_Value_Fee_FVF__c>{fvf, fvf2};

		Test.startTest();
		Nominated_Item__c norItem = new Nominated_Item__c(Final_Value_Fee_FVF__c = fvf.Id);
		insert norItem;
		try {
			update norItem;
			// System admin can update Nominated_Item__c
		} catch (Exception e) {
			System.debug(e.getMessage());
			System.assert(false, 'System admin should have permission to update the record!');
		}
		
		System.runAs(usr3){
			try {
				update norItem;
			} catch (Exception e) {
				System.assert(e.getMessage().contains(label.ERR_MSG_NOMINATED), 'System should alert error message = \'label.ERR_MSG_NOMINATED\', Actual = \''+e.getMessage()+'\'');
			}
		}
	
		Test.stopTest();
		
	}
	
}