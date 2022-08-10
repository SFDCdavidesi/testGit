/*********************************************************************************************************************************
@ Class:          EBH_PricingTriggerHandlerTest
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        Test class for EBH_PricingTriggerHandler class
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 05.05.2017 / JOY MONDOL / Created the test class.
*********************************************************************************************************************************/

@isTest(seeAllData = False)
public class EBH_PricingTriggerHandlerTest {
    @testSetup static void setup(){
        EBH_TestDataFactory.setUpCustomSettings();
    }
    /*****************************************************************************************************************************
@ Method:         testProfile_SA
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        Profile testing for System Administrator
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 05.05.2017 / JOY MONDOL / Created the test Method.
*****************************************************************************************************************************/
    static testMethod void testProfile_SA() {       
        System.runAs(EBH_TestDataFactory.createUser('System Administrator')) { testUpdateCustomRollUp(); }        
    }
    
    /*****************************************************************************************************************************
@ Method:         testProfile_SU
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        Profile testing for Standard User
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 05.05.2017 / JOY MONDOL / Created the test Method.
*****************************************************************************************************************************/
    static testMethod void testProfile_SU() {
        System.runAs(EBH_TestDataFactory.createUser('Standard User')) { testUpdateCustomRollUp(); }
    }
    
    /*****************************************************************************************************************************
@ Method:         testUpdateCustomRollUp
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        TEST CASE (*) System should be able to rollup the following fields in sellers to its legal entity 
(which is a one to many relationship of one level of depth) 
on insert and update and reparenting:
- GMV
- Revenue 
- Sold Items
COVERAGES (*) updateCustomRollUp(): Updates custom roll ups on legal entity from child sellers 
|___hasRollupChanged(): Checks field change in seller
|___hasParentChanged(): Checks parent change in seller
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 05.05.2017 / JOY MONDOL / Created the test Method.
*****************************************************************************************************************************/
    static testMethod void testUpdateCustomRollUp() {
        
        /*TEST DATA ------------------------------------------------------------------------------------------ BEGIN -----------*/
        //EBH_TestDataFactory.setUpCustomSettings();     
        Map<String, Account> testDataMap = EBH_TestDataFactory.setUpAccountTriggerHandlerData();     
        /*TEST DATA ------------------------------------------------------------------------------------------ END -------------*/
        createData();
        Test.startTest();
        /*POSITIVE TESTING ------------------------------------------------------------------------------- BEGIN -----------*/
        /*Modify data for test*/             
        testDataMap.get('se1').EBH_SoldItems__c = 11;
        testDataMap.get('se1').EBH_GMVLast12Months__c = 22;
        testDataMap.get('se1').EBH_RevenueLast12Months__c = 33;
        
        testDataMap.get('se2').EBH_SoldItems__c = 44;
        testDataMap.get('se2').EBH_GMVLast12Months__c = 55;
        testDataMap.get('se2').EBH_RevenueLast12Months__c = 66;
        
        testDataMap.get('se3').EBH_SoldItems__c = 77;
        testDataMap.get('se3').EBH_GMVLast12Months__c = 88;
        testDataMap.get('se3').EBH_RevenueLast12Months__c = 99;
        
        testDataMap.get('se7').ParentId = testDataMap.get('le1').Id;
        
        /*Excecute test*/
        insert new Account(Name = 'se8', ParentId = testDataMap.get('le1').Id, EBH_SoldItems__c = 100); //on insert
        update testDataMap.values(); //on update + reparenting               
        
        /*Validate test*/
        Account le1 = [SELECT EBH_SoldItems__c, EBH_GMVLast12Months__c, EBH_RevenueLast12Months__c
                       FROM Account WHERE Id =: testDataMap.get('le1').Id][0];
        Account le2 = [SELECT EBH_SoldItems__c, EBH_GMVLast12Months__c, EBH_RevenueLast12Months__c
                       FROM Account WHERE Id =: testDataMap.get('le2').Id][0];
        Account le3 = [SELECT EBH_SoldItems__c, EBH_GMVLast12Months__c, EBH_RevenueLast12Months__c
                       FROM Account WHERE Id =: testDataMap.get('le3').Id][0];
        Account le4 = [SELECT EBH_SoldItems__c, EBH_GMVLast12Months__c, EBH_RevenueLast12Months__c
                       FROM Account WHERE Id =: testDataMap.get('le4').Id][0];
        /*System.assertEquals(200, le1.EBH_SoldItems__c);
        System.assertEquals(0, le1.EBH_GMVLast12Months__c);
        System.assertEquals(0, le1.EBH_RevenueLast12Months__c);*/
        System.assertEquals(332, le1.EBH_SoldItems__c);
        System.assertEquals(165, le1.EBH_GMVLast12Months__c);
        System.assertEquals(198, le1.EBH_RevenueLast12Months__c);
        

        /*POSITIVE TESTING ------------------------------------------------------------------------------- END -------------*/
        
        /*NEGETIVE TESTING ------------------------------------------------------------------------------- BEGIN -----------*/
        /*Modify data for test*/             
        testDataMap.get('le3').EBH_SoldItems__c = 9999;
        
        /*Excecute test*/
        update testDataMap.values(); //change in legal entity should not roll up
        
        /*Validate test*/
        le2 = [SELECT EBH_SoldItems__c FROM Account WHERE Id =: testDataMap.get('le2').Id][0];
        
        /*System.assertEquals(null, le2.EBH_SoldItems__c);
        
        System.assertEquals(null, le3.EBH_SoldItems__c);
        System.assertEquals(null, le3.EBH_GMVLast12Months__c);
        System.assertEquals(null, le3.EBH_RevenueLast12Months__c);
        
        System.assertEquals(null, le4.EBH_SoldItems__c);*/
        /*NEGETIVE TESTING ------------------------------------------------------------------------------- END -------------*/
        
        /*EXCEPTION TESTING ------------------------------------------------------------------------------ BEGIN -----------*/
        /*Modify data for test*/             
        testDataMap.get('se1').EBH_RevenueLast12Months__c = 9999.9;
        
        /*Excecute test*/
        update testDataMap.values(); //change in legal entity should not roll up
        
        /*Validate test*/
        System.assertEquals(0, [SELECT EBH_MethodName__c FROM EBH_ApexLog__c 
                                WHERE EBH_MethodName__c = 'updateCustomRollUp'].size());
        /*EXCEPTION TESTING ------------------------------------------------------------------------------ END -------------*/
        Test.stopTest();
    }
    static testMethod void testUpdateCustomRollUp2(){
        //EBH_TestDataFactory.setUpCustomSettings();     
        createData();
        /*EXCEPTION TESTING ------------------------------------------------------------------------------ BEGIN -----------*/
        /*Modify data for test*/             
        //contracts[0].EBH_RebateTierrebate__c = 200000.09;
        //contracts[0].EBH_ContractExposure__c = Decimal.valueof('abc');
        /*Excecute test*/
        //update testDataList[0]; //change in legal entity should not roll up
        //update contracts[0]; //change in legal entity should not roll up
        /*Validate test*/
        
        List<Account> legalEntty = EBH_TestDataFactory.createAccounts(2, 'EBH_LegalEntity');
        
        List<Contract> contractslst  = EBH_TestDataFactory.createContracts (2, 'Listing Agreement', 
                                                                            legalEntty[0].id, legalEntty[1].id );
        
        List<EBH_Pricing__c> pricingslst = EBH_TestDataFactory.createPricing (2, 'EBH_ListingPricing', 
                                                                              contractslst[0].id, 15, 900.00, 800.00, 2000000, 800, 'UK');
        Test.startTest();  
        contractslst = EBH_TestDataFactory.createContracts (2, 'Revenue Share', 
                                                            legalEntty[0].id, legalEntty[1].id );                                 
        pricingslst = EBH_TestDataFactory.createPricing (2, 'EBH_RevenueShareTargets', 
                                                         contractslst[0].id, 15, 900.00, 800.00, 2000000, 800, 'UK');   
        System.assertEquals(0, [SELECT EBH_MethodName__c FROM EBH_ApexLog__c 
                                WHERE EBH_MethodName__c = 'updateCustomRollUp'].size());
        /*EXCEPTION TESTING ------------------------------------------------------------------------------ END -------------*/
        
        Test.stopTest();
    }

	static testMethod void testUpdateCustomRollUp1() {
    
    /*TEST DATA ------------------------------------------------------------------------------------------ BEGIN -----------*/
    //EBH_TestDataFactory.setUpCustomSettings();     
    // List<EBH_Pricing__c> testDataList = EBH_TestDataFactory.setUpPricingTriggerHandlerData();     
    /*TEST DATA ------------------------------------------------------------------------------------------ END -------------*/
    //testDataList[0].EBH_Projected12MGMV__c = 200000;
    //  update testDataList[0];
    
    /*POSITIVE TESTING ------------------------------------------------------------------------------- BEGIN -------------*/
    List<Account> legalEntty = EBH_TestDataFactory.createAccounts(2, 'EBH_LegalEntity');
    createData();
    
    List<Contract> contractslst = EBH_TestDataFactory.createContracts (10, 'ACP', 
                                                                       legalEntty[0].id, legalEntty[1].id );
    
    List<EBH_Pricing__c> pricingslst = EBH_TestDataFactory.createPricing (10, 'EBH_ACPTargets', 
                                                                          contractslst[0].id, 15, 900.00, 800.00, 2000000, 800, 'UK');
    Test.startTest();  
    try{
        pricingslst[0].EBH_contractPricingMatrix__c = EBH_TestDataFactory.createContractPricingMatrix('UK').ID;
        update pricingslst[0];}
    catch(Exception e){
    }
    System.assertEquals(1, [SELECT Id,Name FROM Account WHERE Id=:legalEntty[0].id].size());
    System.assertEquals(1, [SELECT Id,Name FROM Contract WHERE Id=:contractslst[0].id].size()); 
    System.assertEquals(1, [SELECT Id,Name FROM EBH_Pricing__c WHERE Id=:pricingslst[0].id].size());                                        
    /*POSITIVE TESTING ------------------------------------------------------------------------------- END -------------*/
    
    /*NEGETIVE TESTING ------------------------------------------------------------------------------- BEGIN -----------*/    
    //    System.assertEquals('Test Account 0', [SELECT Id,Name FROM Account WHERE Id=:legalEntty[0].id].Name);
    System.assertEquals('Test Contract 0', [SELECT Id,Name FROM Contract WHERE Id=:contractslst[0].id].Name); 
    /*NEGETIVE TESTING ------------------------------------------------------------------------------- END -----------*/
    Test.stopTest();
}

	/*****************************************************************************************************************************
	@ Method:         testContractValue_ExposureCal
	@ Version:        1.0
	@ Author:         Vadhanak Voun
	@ Purpose:        test for: EPH-5479 Additional bolt-ons for Listing and ACP
	------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 26.04.2018 / Vadhanak Voun / Created the test Method.
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  02.09.2021 / Sophal Noch / US-0010295 Modified the method.
	*****************************************************************************************************************************/
	static testMethod void testContractValue_ExposureCal() {
	    
	    EBH_TestDataFactory.setupContractCustomSettingFee();
        
	    //EBH_TestDataFactory.setUpCustomSettings();     
        createData();
	    List<Account> legalEntty = EBH_TestDataFactory.createAccounts(2, 'EBH_LegalEntity');

        // Sophal / 02.09.2021 / US-0010295 : disable calling method below because it can not set startDate and endDate. 
        //                                    uncertain startDate and endDate can give unexpected Contract.EBH_ContractValue__c value
        // List<Contract> contractsACP = EBH_TestDataFactory.createContracts (1, 'ACP', legalEntty[0].id, legalEntty[1].id );

        // Sophal / 02.09.2021 / US-0010295 : make sure number of days between start date and end date are always same every time this test method run
        //                                    so EBH_PricingTriggerHandler.calDatePeriod can return unchanged value.
        Date startDate = System.today();
        Date endDate = System.today().addDays(31);
        // Sophal / 02.09.2021 / US-0010295 calling new method below because we can set startDate and endDate.
        List<Contract> contractsACP = createContracts(1, 'ACP', legalEntty[0].id, legalEntty[1].id, startDate, endDate);
        insert contractsACP;

		List<EBH_Pricing__c> pricingsACP = EBH_TestDataFactory.createPricing (2, 'EBH_ACPTargets', contractsACP[0].id, 15, 900.00, 800.00, 2000000, 800, 'DE');
	                                                                          
        Test.startTest();
	    contractsACP[0].EBH_Site__c = 'DE';
        contractsACP[0].AM_Bolt_on__c = 'Standard Price';
        contractsACP[0].VolumeBasedDiscount__c=true;
        contractsACP[0].EBH_AverageTakeRate__c=10;
        contractsACP[0].EBH_RebateTierrebate__c =10;
        contractsACP[0].EBH_StoreSubscription__c = 'Free Basic'; 
        update contractsACP;

        List<Contract> listContractResultACP = [Select recordtype.Name,Id,EBH_ContractValue__c,EBH_ContractExposure__c from Contract WHERE Id=:contractsACP[0].Id];
	    System.assertEquals(0.86, listContractResultACP[0].EBH_ContractValue__c.setScale(2),' calc from table in custom setting'); 
	    System.assertEquals(1.72, listContractResultACP[0].EBH_ContractExposure__c.setScale(2),' calc from table in custom setting'); 
	    
	    Test.stopTest();
	}

    private static Map<String,Object> createData()
    {
        byPass__c settings = byPass__c.getOrgDefaults();
        settings.ByPass_Validation__c = true;
        upsert settings byPass__c.Id;

        Map<String,Object> mapResult = new Map<String,Object>();
        EBH_ListingPricingExposure__c lp = new EBH_ListingPricingExposure__c( Name='DE', EBH_InsertionFees__c =5 );
        insert lp;

        mapResult.put('lp',lp);
        return mapResult;
    }

/*****************************************************************************************************************************
	@ Method:         test_ShowFriendlyMessage
	@ Version:        1.0
	@ Author:         Sophal Noch
	@ Purpose:        US-0010295 - Error Message is non friendly when Seller Signatory Contract is missing during Pricing creation
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  02.09.2021 / Sophal Noch / US-0010295 Create the method.
	*****************************************************************************************************************************/
	static testMethod void test_ShowFriendlyMessage(){

        EBH_TestDataFactory.setupContractCustomSettingFee();

        byPass__c settings = byPass__c.getOrgDefaults();
        settings.ByPass_Validation__c = false;
        upsert settings byPass__c.Id;

        insert new EBH_ActiveTriggers__c(Name = 'EBH Trigger Controller',EBH_PricingTrigger__c = true);
        insert  new EBH_ListingPricingExposure__c( Name='DE', EBH_InsertionFees__c =5 );
      
	    List<Account> legalEntty = EBH_TestDataFactory.createAccounts(2, 'EBH_LegalEntity');

        Date startDate = System.today();
        Date endDate = System.today().addDays(31);
    
        List<Contract> contractsACP = createContracts(1, 'ACP', legalEntty[0].id, legalEntty[1].id, startDate, endDate);
        contractsACP[0].Status = 'Draft';
        contractsACP[0].EBH_Site__c = 'DE';
        contractsACP[0].AM_Bolt_on__c = 'Standard Price';
        contractsACP[0].VolumeBasedDiscount__c=true;
        contractsACP[0].EBH_AverageTakeRate__c=10;
        contractsACP[0].EBH_RebateTierrebate__c =10;
        contractsACP[0].EBH_StoreSubscription__c = 'Free Basic'; 
        insert contractsACP;

        // update contractsACP;

        Test.startTest();

        System.assertNotEquals(Null, contractsACP[0].Business_Contact__c);

        Contact businessContact = [Select Id, FirstName from Contact where Id =: contractsACP[0].Business_Contact__c];
        businessContact.FirstName = '';
        update businessContact;

        try {
            List<EBH_Pricing__c> pricingsACP = EBH_TestDataFactory.createPricing (2, 'EBH_ACPTargets', contractsACP[0].id, 15, 900.00, 800.00, 2000000, 800, 'DE');
        } catch (Exception e) {
            System.assert(e.getMessage().contains(Label.ErrorInvalidSellerSignatoryContact));
        }
       

	    Test.stopTest();
    }


    /*********************************************************************************************************************************
    @ Method:         createContracts
    @ Version:        1.0
    @ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:        US-0010295 - Error Message is non friendly when Seller Signatory Contract is missing during Pricing creation
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  02.09.2021 / Sophal Noch / Created the method.
    *********************************************************************************************************************************/
    private static List<Contract> createContracts(Integer numRecords, String recordType, Id customerLegalEntity, Id ebayLegalEntity, Date startDate, Date endDate) {
        
        // Sophal / 02.09.2021 / US-0010295 copy from EBH_TestDataFactory.createContracts

        List<Contract> contracts = new List<Contract>();
        
        RecordType rt = Database.query(EBH_TestDataFactory.CONTRACTRECTYPQUERY);
        RecordType manaulconRt = EBH_TestDataFactory.getRecordTypeByName('Contact','EBH_MANUAL');
        Contact contact = new Contact(EBH_Status__c='Active', LastName = 'testLastName', FirstName = 'testFirstName',Email='Test@test.com', AccountId = customerLegalEntity,recordTypeId = manaulconRt.Id, EBH_DataOrigin__c='test');             
        insert contact;
        for(Integer iCounter = 0; iCounter < numRecords; iCounter++) {
            contracts.add(new Contract(RecordTypeId = rt.Id, 
                                       Name = 'Test Contract ' + iCounter, 
                                       accountId = customerLegalEntity, 
                                       EBH_eBayLegalEntity__c = ebayLegalEntity, Status='Draft'
                                       ,StartDate=startDate,EndDate=endDate, Surcharge__c = true,Business_Contact__c=contact.id));
        }
        return contracts;
    }

}