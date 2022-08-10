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
@isTest
private class ForwardToSellerControllerTest {

    static testMethod void forwardToSeller() {
    	
         EBH_TestDataFactory.setUpCustomSettings();
         
         RecordType rec_seller = ApexUtil.getRecordTypeByName('Account','EBH_Seller'); 
         Account seller1 = new Account(Name = 'seller 1234',RecordTypeId=rec_seller.Id,Record_Type_Text__c='EBH_Seller');
         insert seller1;
         
        Contact con = new Contact(LastName='last name',Email='test@test.com');
        Contact con2 = new Contact(LastName='last name');//no email 
        insert new Contact[]{con,con2};
         
        Product__c p1 = new Product__c();
        insert new Product__c[]{p1};
        
        Seller_to_Product__c stp1 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller1.Id);
        Seller_to_Product__c stp2 = new Seller_to_Product__c(Product__c=p1.Id,Seller__c=seller1.Id);
        insert new List<Seller_to_Product__c>{stp1,stp2};
         
         Test.startTest();
         
	         Map<String,Object> mapResult = ForwardToSellerController.apexInit(seller1.Id);
	         
	         String sellerToProductIds = stp1.Id+','+stp2.Id;
	         mapResult = ForwardToSellerController.apexContactAndSellerToProductInfo(con.Id+'',sellerToProductIds);
	         
	         mapResult = ForwardToSellerController.apexContactList(seller1.Id);
	         
	         mapResult = ForwardToSellerController.apexGetEmailTemplate(seller1.Id+'',con.Id+'');
         
         	Sourcing_Opportunity__c sopp1 = new Sourcing_Opportunity__c(Seller__c=seller1.Id);
         	Sourcing_Opportunity__c sopp2 = new Sourcing_Opportunity__c(Seller__c=seller1.Id);
         	insert new Sourcing_Opportunity__c[]{sopp1,sopp2};
         
         	Map<String,String> mapSelectedSOPP = new Map<String,String>{sopp1.Id+''=>'true',sopp2.Id+''=>'true'};
         	mapResult = ForwardToSellerController.apexSendEmailComplete(seller1.Id+'',con.Id+'','test@test.com','Subject New','<htmlbodynew>',sellerToProductIds,mapSelectedSOPP,'');
         Test.stopTest();
         	system.debug('>>test:mapResult: '+mapResult);
         	Final_Value_Fee_FVF__c[] fvfs =[Select Id from Final_Value_Fee_FVF__c where Seller_Name__c=:seller1.Id];
//         	System.assertEquals(1,fvfs.size(),'1 FVF to be created after sending complete');
         	Nominated_Item__c[] nitems = [Select Id from Nominated_Item__c where Final_Value_Fee_FVF__c=:fvfs[0].Id];
         //	System.assertEquals(4,nitems.size(),'4 Nominated_Item__c to be created after sending complete (2 from selected seller to product, 2 from selected sourcing opportunity)');
         	
         	mapResult = ForwardToSellerController.apexSendEmailComplete(seller1.Id+'',con2.Id+'','test@test.com,test2@test.com','Subject New','<htmlbodynew>',sellerToProductIds,mapSelectedSOPP,'');
        
    }
    
    static testMethod void testApexCreateNorminatedItems() {
        
    	RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	Account acc = new Account(Name='Test Acc1',RecordTypeID = sellerRecordType.Id);
    	insert acc;
		RecordType prodRecordType = ApexUtil.getRecordTypeByName('Product__c','TTP_Product');
    	Product__c prod = new Product__c(Price_competitor__c = 10, RecordTypeID = prodRecordType.Id);
    	insert prod;
    	Seller_to_Product__c sellerToProduct = new Seller_to_Product__c(Seller__c = acc.Id,Product__c = prod.Id);
    	insert sellerToProduct;
    	
    	String fvfIdx = ApexUtil.genUniqueString(20);
    	Final_Value_Fee_FVF__c fvf = new Final_Value_Fee_FVF__c(Unique_Id__c=fvfIdx,Seller_to_Product_IDS__c = sellerToProduct.Id,Seller_Email__c='test@test.com');
    	
        insert fvf;
        
        Test.startTest();
        
         Map<String,Object> restult = ForwardToSellerController.apexCreateNorminatedItems(fvfIdx,new String[]{sellerToProduct.Id});
         
        Test.stopTest();
        Nominated_Item__c norminatedItem = [select id,Inventory_Diagnostic__c from Nominated_Item__c where Final_Value_Fee_FVF__c =: fvf.Id];
        System.assertEquals(norminatedItem.Inventory_Diagnostic__c,sellerToProduct.Id);
    }

    static testMethod void testApexGetAllRecordId() {

        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
        Account acc = new Account(Name='Test Acc1',RecordTypeID = sellerRecordType.Id);
        insert acc;
        RecordType prodRecordType = ApexUtil.getRecordTypeByName('Product__c','TTP_Product');
        Product__c prod = new Product__c(Price_competitor__c = 10, RecordTypeID = prodRecordType.Id);
        insert prod;
        Seller_to_Product__c sellerToProduct = new Seller_to_Product__c(Seller__c = acc.Id,Product__c = prod.Id);
        insert sellerToProduct;
        
        String sqlWhere = 'Seller_to_Product__c Where Seller__c = ' + '\''+ acc.Id + '\'';
        Map<String,Object> mapResult = ForwardToSellerController.apexGetAllRecordId(sqlWhere);
        System.assertEquals('ok', mapResult.get('status'));

        String objJsonResult = JSON.serialize(mapResult.get('mapAllRecordId'));

        // System.debug('nsp: objJsonResult '+objJsonResult);

        Map<String, Object> sellerToProductResult = (Map<String, Object>) JSON.deserializeUntyped(objJsonResult); 

        System.assertEquals(1, sellerToProductResult.size());

        System.assertNotEquals(null, sellerToProductResult.get(sellerToProduct.Id));

        System.assertEquals(true, (Boolean)sellerToProductResult.get(sellerToProduct.Id));
    
    
    }

}