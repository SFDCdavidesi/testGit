/*********************************************************************************************************************************
@ Class:          EBH_ContractTriggerHandlerTest
@ Version:        1.0
@ Author:         NEHA LUND 
@ Purpose:        Test class for EBH_ContractTriggerHandler class
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 13.05.2017 / NEHA LUND / Created the test class.
*********************************************************************************************************************************/

@isTest(seeAllData = False)
public class EBH_ContractTriggerHandlerTest {
	@testSetup static void setUp() {
		//EBH_TestDataFactory.setUpCustomSettings();  
        EBH_ActiveTriggers__c cusettingTrigger = new EBH_ActiveTriggers__c();
        cusettingTrigger.Name = 'EBH Trigger Controller';
        cusettingTrigger.EBH_ContactTrigger__c = true;
        cusettingTrigger.EBH_ContractTrigger__c = true;
        insert cusettingTrigger; 
	}

    private static RecordType PricingRecordType = ApexUtil.getRecordTypeByName('EBH_Pricing__c','EBH_ListingPricing');
    /*****************************************************************************************************************************
    @ Method:         testProfile_SA
    @ Version:        1.0
    @ Author:         NEHA LUND 
    @ Purpose:        Profile testing for System Administrator
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 13.05.2017 / NEHA LUND / Created the test Method.
    @ Change history: 06.08.2021 / Sophal Noch / US-0009896 Update the test Method.
    *****************************************************************************************************************************/
    static testMethod void testProfile_SA() {
        System.runAs(EBH_TestDataFactory.createUser('System Administrator')) {
            testupdateApprovers(); 
            testupdatePreApprovedTemplate();
        }        
    }
    
    /*****************************************************************************************************************************
    @ Method:         testProfile_SU
    @ Version:        1.0
    @ Author:         NEHA LUND 
    @ Purpose:        Profile testing for Standard User
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 13.05.2017 / NEHA LUND / Created the test Method.
    *****************************************************************************************************************************/
    static testMethod void testProfile_SU() {
        System.runAs(EBH_TestDataFactory.createUser('Standard User')) { testupdatePreApprovedTemplate(); }
    }
    
    /*****************************************************************************************************************************
    @ Method:         testupdatePreApprovedTemplate
    @ Version:        1.0
    @ Author:         NEHA LUND 
    @ Purpose:        TEST CASE (*) System should be able to update the 'Pre-Approved Template' field on Contract 
                                    based on the combination of below fields stored in Custom Settings (Pre-Approved Contract template rules)
                                    - Site
                                    - Language
                                    - Record Type
                      COVERAGES (*) updatePreApprovedTemplate(): Updates the Pre-Approved Template field based on the changes of below fields
                                        |___hasPreApprovedParametersChanged(): Checks field change in Contract
                                        |
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 13.05.2017 / NEHA LUND / Created the test Method.
    *****************************************************************************************************************************/
    static testMethod void testupdatePreApprovedTemplate() {
                    
        /*TEST DATA ------------------------------------------------------------------------------------------ BEGIN -----------*/
        // List<Contract> testData = EBH_TestDataFactory.setUpContractTriggerHandlerData();
        RecordType rt = ApexUtil.getRecordTypeByName('Contract','EBH_ACP');
        RecordType leg = ApexUtil.getRecordTypeByName('Account','EBH_LegalEntity');
        
        Account legalEntities = new Account(Name='Test Acc', RecordTypeId=leg.Id);
        insert legalEntities;
        RecordType manaulconRt = ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL');
	    Contact contact = new Contact(EBH_Status__c='Active', LastName = 'testLastName', FirstName = 'testFirstName',Email='Test@test.com', AccountId = legalEntities.Id,recordTypeId = manaulconRt.Id, EBH_DataOrigin__c='test');             
	    insert contact;
        Contract testData = new Contract(RecordTypeId = rt.Id, 
                                       Name = 'Test Contract ', 
                                       accountId = legalEntities.Id, 
                                       EBH_eBayLegalEntity__c = legalEntities.Id, Status='Draft',
                                       Surcharge__c = true,
                                       StartDate = System.today(), 
                                       EndDate = System.today().addDays(1),
                                       Business_Contact__c=contact.id
        );
        insert testData;    
        /*TEST DATA ------------------------------------------------------------------------------------------ END -------------*/

        Test.startTest();
            /*POSITIVE TESTING ------------------------------------------------------------------------------- BEGIN -----------*/
            /*Modify data for test*/             
            testData.EBH_Site__c = EBH_ConstantsUtility.CONTRACT_SITE_DE;
            testData.EBH_Language__c = EBH_ConstantsUtility.CONTRACT_LANGUAGE_DE;
            // for(Contract con: testData ){
            //     con.EBH_Site__c = EBH_ConstantsUtility.CONTRACT_SITE_DE;
            //     con.EBH_Language__c = EBH_ConstantsUtility.CONTRACT_LANGUAGE_DE;
            // }
            
            /*Excecute test*/
            update testData; //on change of Site and Language, if it matches the rule defined in the custom settings, it will update Pre-Approved Template field on Contract              
            
            /*Validate test*/
            List<Contract> contracts = [SELECT EBH_PreApprovedTemplate__c
                           FROM Contract WHERE Id = : testdata.Id and  EBH_PreApprovedTemplate__c = true];
            
            //System.assertEquals(10, contracts.size() );
            /*POSITIVE TESTING ------------------------------------------------------------------------------- END -------------*/
            
            /*NEGETIVE TESTING ------------------------------------------------------------------------------- BEGIN -----------*/
            /*Modify data for test*/     
            testData.EBH_Site__c = EBH_ConstantsUtility.CONTRACT_SITE_IT;
            testData.EBH_Language__c = EBH_ConstantsUtility.CONTRACT_LANGUAGE_DE;        
            // for(Contract con: testData ){
            //     con.EBH_Site__c = EBH_ConstantsUtility.CONTRACT_SITE_IT;
            //     con.EBH_Language__c = EBH_ConstantsUtility.CONTRACT_LANGUAGE_DE;
            // }
            
            
            /*Excecute test*/
            update testData;
            /*Validate test*/
            contracts = [SELECT EBH_PreApprovedTemplate__c
                           FROM Contract WHERE Id = : testdata.Id and  EBH_PreApprovedTemplate__c = true];
            
            System.assertEquals( 0, contracts.size() );
            
            testData.EBH_Site__c = EBH_ConstantsUtility.CONTRACT_SITE_IT;
            testData.EBH_Language__c = EBH_ConstantsUtility.CONTRACT_LANGUAGE_DE;
            testData.EBH_PreApprovedTemplate__c = true;
            // for(Contract con: testData ){
            //     con.EBH_Site__c = EBH_ConstantsUtility.CONTRACT_SITE_IT;
            //     con.EBH_Language__c = EBH_ConstantsUtility.CONTRACT_LANGUAGE_DE;
            //     con.EBH_PreApprovedTemplate__c = true;
                
            // }
            
            Database.update(testdata, false);
            /*NEGETIVE TESTING ------------------------------------------------------------------------------- END -------------*/
            
            Test.stopTest();
    }
    
    /*****************************************************************************************************************************
    @ Method:         testupdateApprovers
    @ Version:        1.0
    @ Author:         NEHA LUND 
    @ Purpose:        TEST CASE (*) System should be able to update the 'Pre-Approved Template' field on Contract 
                                    based on the combination of below fields stored in Custom Settings (Pre-Approved Contract template rules)
                                    - Site
                                    - Language
                                    - Record Type
                      COVERAGES (*) updatePreApprovedTemplate(): Updates the Pre-Approved Template field based on the changes of below fields
                                        |___hasPreApprovedParametersChanged(): Checks field change in Contract
                                        |
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 13.05.2017 / NEHA LUND / Created the test Method.
    *****************************************************************************************************************************/
    public static void testupdateApprovers() {
                    
        /*TEST DATA ------------------------------------------------------------------------------------------ BEGIN -----------*/
        
        List<User> users = EBH_TestDataFactory.createUsers(4, 'Standard User');
        
        insert users;
        
        EBH_ContractApprovalMatrix__c  matrixRecordDE = EBH_TestDataFactory.createContractApprovalMatrix ( 'DE', users[0].id, users[1].id ) ;
        EBH_ContractApprovalMatrix__c  matrixRecordFR = EBH_TestDataFactory.createContractApprovalMatrix ( 'FR', users[0].id, users[1].id ) ;
        EBH_ContractApprovalMatrix__c  matrixRecordIT = EBH_TestDataFactory.createContractApprovalMatrix ('IT', users[0].id, users[1].id ) ;
        EBH_ContractApprovalMatrix__c  matrixRecordES = EBH_TestDataFactory.createContractApprovalMatrix ( 'ES', users[0].id, users[1].id ) ;
        EBH_ContractApprovalMatrix__c  matrixRecordUK = EBH_TestDataFactory.createContractApprovalMatrix ( 'UK', users[0].id, users[1].id ) ;
        EBH_ContractApprovalMatrix__c  matrixRecordRest = EBH_TestDataFactory.createContractApprovalMatrix ( 'Rest of Europe', users[0].id, users[1].id ) ;
        insert new List<EBH_ContractApprovalMatrix__c>{matrixRecordDE,matrixRecordFR,matrixRecordIT,matrixRecordES,matrixRecordUK,matrixRecordRest};
        
        EBH_ContractApprovalHierarchy__c child1 = EBH_TestDataFactory.createContractApprovalHierarchy ( EBH_ConstantsUtility.HIERARCHY_CONTROLLING, users[2].id, 5000000.0);
        child1.EBH_ContractApprovalMatrix__c = matrixRecordDE.Id;
        EBH_ContractApprovalHierarchy__c child2 = EBH_TestDataFactory.createContractApprovalHierarchy ( EBH_ConstantsUtility.HIERARCHY_FINANCE, users[3].id, 5000000.0);
        child2.EBH_ContractApprovalMatrix__c = matrixRecordFR.Id;
        insert new List<EBH_ContractApprovalHierarchy__c>{child1,child2};
        
        Account acc1 = new Account(RecordTypeId = ApexUtil.getRecordTypeByName('Account','EBH_LegalEntity').Id, Name = 'Test Account 1',EBH_BillingCountry__c = 'DE');
        Account acc2 = new Account(RecordTypeId = ApexUtil.getRecordTypeByName('Account','EBH_LegalEntity').Id, Name = 'Test Account 2',EBH_BillingCountry__c = 'FR');
        Account acc3 = new Account(RecordTypeId = ApexUtil.getRecordTypeByName('Account','EBH_LegalEntity').Id, Name = 'Test Account 3',EBH_BillingCountry__c = 'IT');
        Account acc4 = new Account(RecordTypeId = ApexUtil.getRecordTypeByName('Account','EBH_LegalEntity').Id, Name = 'Test Account 4',EBH_BillingCountry__c = 'ES');
        Account acc5 = new Account(RecordTypeId = ApexUtil.getRecordTypeByName('Account','EBH_LegalEntity').Id, Name = 'Test Account 5',EBH_BillingCountry__c = 'UK');
        Account acc6 = new Account(RecordTypeId = ApexUtil.getRecordTypeByName('Account','EBH_LegalEntity').Id, Name = 'Test Account 6',EBH_BillingCountry__c = 'Rest of Europe');
        Account acc7 = new Account(RecordTypeId = ApexUtil.getRecordTypeByName('Account','EBH_LegalEntity').Id, Name = 'Test Account 6',EBH_BillingCountry__c = 'Rest of Europe');
        insert new List<Account>{acc1,acc2,acc3,acc4,acc5,acc6,acc7};


        /*
         // Sophal: 06/08/2021: US-0009896 Disable because it Consume too much resourse, It caused SOQL 101 in Test method.
                                Create another method to handle this

        ID rt = ApexUtil.getRecordTypeByName('Contract',EBH_ConstantsUtility.CONTRACT_ACPRECORDTYPE).Id;
        Contract contr1 = createContract(rt,acc1.Id,acc7.Id);
        Contract contr2 = createContract(rt,acc2.Id,acc7.Id);
        Contract contr3 = createContract(rt,acc3.Id,acc7.Id);
        Contract contr4= createContract(rt,acc4.Id,acc7.Id);
        Contract contr5 = createContract(rt,acc5.Id,acc7.Id);
        Contract contr6 = createContract(rt,acc6.Id,acc7.Id);
        insert new List<Contract>{contr1,contr2,contr3,contr4,contr5,contr6};
        //EBH_TestDataFactory.setUpContractTriggerHandlerData()
		contr1.EBH_Site__c = 'DE';
		contr2.EBH_Site__c = 'FR';
		contr3.EBH_Site__c = 'IT';
		contr4.EBH_Site__c = 'ES';
		contr5.EBH_Site__c = 'UK';
		contr6.EBH_Site__c = 'NL';
		update new List<Contract>{contr1,contr2,contr3,contr4,contr5,contr6};
        */

        // Sophal: 06/08/2021: US-0009896 use below code to solve SOQL 101 Error
        String rtCtrACPId = ApexUtil.getRecordTypeByName('Contract',EBH_ConstantsUtility.CONTRACT_ACPRECORDTYPE).Id;
        String rtCtManualId = ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL').Id;
        List<Map<String,String>> listMapContractSetupData = new List<Map<String,String>>();
        listMapContractSetupData.add(new Map<String,String>{'rtCtrACPId'=>rtCtrACPId,'rtCtManualId'=>rtCtManualId,'customerLegalEntity'=>acc1.Id,'ebayLegalEntity'=>acc7.Id,'site'=>'DE'});
        listMapContractSetupData.add(new Map<String,String>{'rtCtrACPId'=>rtCtrACPId,'rtCtManualId'=>rtCtManualId,'customerLegalEntity'=>acc2.Id,'ebayLegalEntity'=>acc7.Id,'site'=>'FR'});
        listMapContractSetupData.add(new Map<String,String>{'rtCtrACPId'=>rtCtrACPId,'rtCtManualId'=>rtCtManualId,'customerLegalEntity'=>acc3.Id,'ebayLegalEntity'=>acc7.Id,'site'=>'IT'});
        listMapContractSetupData.add(new Map<String,String>{'rtCtrACPId'=>rtCtrACPId,'rtCtManualId'=>rtCtManualId,'customerLegalEntity'=>acc4.Id,'ebayLegalEntity'=>acc7.Id,'site'=>'ES'});
        listMapContractSetupData.add(new Map<String,String>{'rtCtrACPId'=>rtCtrACPId,'rtCtManualId'=>rtCtManualId,'customerLegalEntity'=>acc5.Id,'ebayLegalEntity'=>acc7.Id,'site'=>'UK'});
        listMapContractSetupData.add(new Map<String,String>{'rtCtrACPId'=>rtCtrACPId,'rtCtManualId'=>rtCtManualId,'customerLegalEntity'=>acc6.Id,'ebayLegalEntity'=>acc7.Id,'site'=>'NL'});

        createMultipleContract(listMapContractSetupData);
    }
    
    private static Contract createContract(Id recordTypeid, Id customerLegalEntity, Id ebayLegalEntity){
    	RecordType manaulconRt = ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL');
	    Contact contact = new Contact(EBH_Status__c='Active', LastName = 'testLastName', FirstName = 'testFirstName',Email='Test@test.com', AccountId = customerLegalEntity,recordTypeId = manaulconRt.Id, EBH_DataOrigin__c='test');             
	    insert contact;
       return new Contract(RecordTypeId = recordTypeid, Name = 'Test Contract', accountId = customerLegalEntity,EBH_eBayLegalEntity__c = ebayLegalEntity, Status='Draft', Surcharge__c = true, StartDate = System.today(), EndDate = System.today().addDays(1),Business_Contact__c=contact.id);
    }

    private static List<Contract> createMultipleContract(List<Map<String,String>> listMapContractSetupData){
        // Sophal: 06/08/2021: US-0009896 
        List<Contact> listContact = new List<Contact>();
        List<Contract> listContract = new List<Contract>();
    	for(Map<String,String> mapData: listMapContractSetupData){

            String rtCtrACPId = mapData.get('rtCtrACPId');
            String rtCtManualId = mapData.get('rtCtManualId');
            String customerLegalEntity = mapData.get('customerLegalEntity');
            String ebayLegalEntity = mapData.get('ebayLegalEntity');
            String site = mapData.get('site');

            listContact.add(new Contact(EBH_Status__c='Active', LastName = 'testLastName', FirstName = 'testFirstName',Email='Test@test.com', AccountId = customerLegalEntity,recordTypeId = rtCtManualId, EBH_DataOrigin__c='test'));
            listContract.add(new Contract(RecordTypeId = rtCtrACPId, Name = 'Test Contract', accountId = customerLegalEntity,EBH_eBayLegalEntity__c = ebayLegalEntity, Status='Draft', Surcharge__c = true, StartDate = System.today(), EndDate = System.today().addDays(1),EBH_Site__c=site));
        }
        insert listContact;
        Integer index = 0;
        for(Contact contact : listContact){
            listContract[index].Business_Contact__c = contact.Id;
            index++;
        }
        insert listContract;
        return listContract;
    }
    
    static testmethod void testAttachmentInsertion(){
         /*TEST DATA ------------------------------------------------------------------------------------------ BEGIN -----------*/
        List<Contract> testData = EBH_TestDataFactory.setUpContractTriggerHandlerData();     
        Contract c =testData[0];
        c.List_Control_Values__c='2';
        c.status='In Negotiation';
        c.EBH_FinanceAgreesinPrincipal__c=true;
        update c;
        /*TEST DATA ------------------------------------------------------------------------------------------ END -------------*/
        test.startTest();
        Attachment a = new Attachment(parentId=testData[0].id,name='test');
        
         
  		a.body = Blob.valueOf('Testing Body of Attachment');
        try{
        insert a;    
        }catch(Exception e){
            System.debug(e);
            System.debug(e.getMessage());
            
            
        }
        
        test.stopTest();
        
        
 
        
        
        
    }
    
     static testmethod void testSubmitWithoutPricing(){
         /*TEST DATA ------------------------------------------------------------------------------------------ BEGIN -----------*/
        List<Contract> testData = EBH_TestDataFactory.setUpContractTriggerHandlerData();     
        Contract c =testData[0];
        c.List_Control_Values__c='2';
        c.status='In Negotiation';
        c.EBH_FinanceAgreesinPrincipal__c=true;
        update c;
        /*TEST DATA ------------------------------------------------------------------------------------------ END -------------*/
        test.startTest();
        Attachment a = new Attachment(parentId=testData[0].id,name='test');
        
         
  		a.body = Blob.valueOf('Testing Body of Attachment');
        try{
        insert a;    
        }catch(Exception e){
            System.debug(e);
            System.debug(e.getMessage());
            
            
        }
        EBH_ContractTriggerHandler x = new EBH_ContractTriggerHandler();
        test.stopTest();
        
        
 
        
        
        
    }
    
    static testMethod void testValidatePricingDateErr1() {
    	List<Contract> testData = EBH_TestDataFactory.setUpContractTriggerHandlerData();    
        System.runAs(EBH_TestDataFactory.createUser('Standard User')) {
        test.startTest();
    	try{
        Contract c =testData[0];
        c.StartDate = System.today();
        c.EndDate = System.today();
        c.EBH_PricingStartDate__c=System.today();
        c.EBH_PricingEndDate__c=System.today();
        update c;   
        }catch(Exception e){
            System.debug(e);
            System.debug('<<<>>>'+e.getMessage());
        }
    	test.stopTest();
        }
    }
    
    static testMethod void testValidatePricingDateErr2() {
    	System.runAs(EBH_TestDataFactory.createUser('Standard User Profile')) {
    	List<Contract> testData = EBH_TestDataFactory.setUpContractTriggerHandlerData();    
        test.startTest();
    	try{
        Contract c =testData[0];
        c.StartDate = System.today();
        c.EndDate = System.today();
        c.EBH_PricingStartDate__c=System.today()-1;
        c.EBH_PricingEndDate__c=System.today();
        update c;   
        }catch(Exception e){
            System.debug(e);
            System.debug('<<<>>>'+e.getMessage());
        }
    	test.stopTest();
    	}
    }
    
    static testMethod void testValidatePricingDateErr3() {
    	System.runAs(EBH_TestDataFactory.createUser('Standard User Profile')) {
    	List<Contract> testData = EBH_TestDataFactory.setUpContractTriggerHandlerData();    
        test.startTest();
    	try{
        Contract c =testData[0];
        c.StartDate = System.today();
        c.EndDate = System.today();
        c.EBH_PricingStartDate__c=System.today();
        c.EBH_PricingEndDate__c=System.today()+1;
        update c;   
        }catch(Exception e){
            System.debug(e);
            System.debug('<<<>>>'+e.getMessage());
        }
    	test.stopTest();
    	}
    }
    
    static testMethod void testsetDefaultPricingDate() {
    	List<Account> legalEntities = EBH_TestDataFactory.createAccounts(2, 'EBH_LegalEntity');
    	RecordType manaulconRt = ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL');
	    Contact contact = new Contact(EBH_Status__c='Active', LastName = 'testLastName', FirstName = 'testFirstName',Email='Test@test.com', AccountId = legalEntities[0].Id,recordTypeId = manaulconRt.Id, EBH_DataOrigin__c='test');             
	    insert contact;
    	Contract testData1 = new Contract(RecordTypeId = ApexUtil.getRecordTypeByName('Contract',EBH_ConstantsUtility.CONTRACT_ACPRECORDTYPE).Id, 
                                       Name = 'Test Contract 1', 
                                       accountId = legalEntities[0].Id, 
                                       EBH_eBayLegalEntity__c = legalEntities[1].Id, Status='Draft',
                                       StartDate = System.today(),
                                       EndDate = System.today() + 1,
                                       Surcharge__c = true,
                                       Business_Contact__c=contact.id);
        Contract testData2 = new Contract(RecordTypeId = ApexUtil.getRecordTypeByName('Contract',EBH_ConstantsUtility.CONTRACT_LISTINGRECORDTYPE).Id, 
                                       Name = 'Test Contract 2', 
                                       accountId = legalEntities[0].Id, 
                                       EBH_eBayLegalEntity__c = legalEntities[1].Id, Status='Draft',
                                       StartDate = System.today(),
                                       EndDate = System.today() + 1,
                                       Surcharge__c = true,
                                       Business_Contact__c=contact.id);                               
    	Contract testData3 = new Contract(RecordTypeId = ApexUtil.getRecordTypeByName('Contract',EBH_ConstantsUtility.CONTRACT_RSRECORDTYPE).Id, 
                                       Name = 'Test Contract 3', 
                                       accountId = legalEntities[0].Id, 
                                       EBH_eBayLegalEntity__c = legalEntities[1].Id, Status='Draft',
                                       StartDate = System.today(),
                                       EndDate = System.today() + 1,
                                       Surcharge__c = true,
                                       Business_Contact__c=contact.id);  
    	test.startTest();
    	List<Contract> lstContractInsert = new List<Contract>{testData1,testData2,testData3};
        insert lstContractInsert;
    	test.stopTest();
    	List<Contract> lstContract = [select EBH_PricingStartDate__c, EBH_PricingEndDate__c,StartDate,EndDate from Contract where ID IN: lstContractInsert];
    	System.assert(lstContract.size() == 3);
    	for(Contract contr : lstContract){
    		System.assertEquals(contr.EBH_PricingStartDate__c,contr.StartDate);
    		System.assertEquals(contr.EBH_PricingEndDate__c,contr.EndDate);
    	}
    }

    static testmethod void testvalidateBeforeSubmittingForPostCheck(){
		Map<String,Account> accounts = EBH_TestDataFactory.setupAccountTriggerHandlerData();    
    	RecordType manaulconRt = ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL');
	    Contact contact = new Contact(EBH_Status__c='Active', LastName = 'testLastName', FirstName = 'testFirstName',Email='Test@test.com', AccountId = accounts.get('le1').Id,recordTypeId = manaulconRt.Id, EBH_DataOrigin__c='test');             
	    insert contact;  
        /****** CREATE CONTRACT RECORD ************************/
        Contract c = new Contract(RecordTypeId = ApexUtil.getRecordTypeByName('Contract',EBH_ConstantsUtility.CONTRACT_LISTINGRECORDTYPE).Id, 
            Name = 'Test Contract 1', 
            accountId = accounts.get('le1').Id,
            Status = EBH_ConstantsUtility.CONTRACT_DRAFTSTATUS,
            EBH_Site__c = 'UK',
            EBH_Language__c= 'English',
            Reason_for_Contract_Amendment__c = 'Seller / Brand Acquisition',
            EBH_RequesterNotes__c = 'test',
            Surcharge__c = true,
            PricingVersion__c = 'P1.0',
            StartDate = System.today(),
            EndDate = System.today() + 1,
            Business_Contact__c=contact.id
        );
        insert c;
        /****** CREATE CONTRACT PRICING RECORD ************************/
        EBH_ContractPricingMatrix__c contractPricingMatrix = EBH_TestDataFactory.createContractPricingMatrix('UK');
        /****** CREATE PRICING RECORD ************************/
        EBH_Pricing__c pricing = new EBH_Pricing__c(EBH_ContractId__c=c.Id,
            EBH_Site__c='UK',
            EBH_ContractPricingMatrix__c = contractPricingMatrix.Id,
            EBH_Projected12MGMV__c = 11,
            EBH_ASP__c =11,
            RecordTypeId = PricingRecordType.Id
        );
        insert pricing;
        test.startTest();
        c.List_Control_Values__c='2';
        c.status='In Negotiation';
        c.EBH_FinanceAgreesinPrincipal__c=true;
        update c;
        //US-0010190 - [Docusign] Validations to ensure Contract Document is attached before submitting for post check approval
        try {
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(c.id);
            Approval.ProcessResult result = Approval.process(app);
        } catch (Exception e) {
            System.assert(e.getMessage().contains(Label.Not_Submit_Contract_Without_PDF_Att), 'System should alert error message = \'Label.Not_Submit_Contract_Without_PDF_Att\', Actual = \''+e.getMessage()+'\'');
        }
        c.EBH_AttachmentCheck__c = true;
        update c;
        //US-0007544 - [Contracts] Contract Sellers to be made mandatory at stage "Finance Post check"
        try {
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(c.id);
            Approval.ProcessResult result = Approval.process(app);
        } catch (Exception e) {
            System.assert(e.getMessage().contains(Label.Not_Submit_Contract_Without_Contract_Seller), 'System should alert error message = \'Label.Not_Submit_Contract_Without_Contract_Seller\', Actual = \''+e.getMessage()+'\'');
        }
        /****** CREATE CONTRACT SELLER RECORD ************************/
        EBH_ContractSeller__c contractSeller = new EBH_ContractSeller__c(EBH_ContractNumber__c = c.Id, EBH_BusinessName__c = accounts.get('se1').Id);
        insert contractSeller;
        Approval.ProcessSubmitRequest app2 = new Approval.ProcessSubmitRequest();
        app2.setObjectId(c.id);
        Approval.ProcessResult result2 = Approval.process(app2);
            
        // Map<Id,Contract> contractMap  =  new Map<Id,Contract>((List<Contract>) Database.query(EBH_ConstantsUtility.CTH_CONTRACTMAPQUERY));
         //System.debug('<<<contractMap:'+contractMap);
        test.stopTest();
    }

    // Acmatac SEING, 16 June 2021, US-0009604 AC2, Validation Rule Name = Pricing_Version_Different_Pricing_RT
    static testmethod void testvalidateNotSubmitingWithDifferentPricingRecordType(){
    	Map<String,Account> accounts = EBH_TestDataFactory.setupAccountTriggerHandlerData();
    	RecordType manaulconRt = ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL');
	    Contact contact = new Contact(EBH_Status__c='Active', LastName = 'testLastName', FirstName = 'testFirstName',Email='Test@test.com', AccountId = accounts.get('le1').Id,recordTypeId = manaulconRt.Id, EBH_DataOrigin__c='test');             
	    insert contact;
        /****** CREATE CONTRACT RECORD ON PENDING STAGE ************************/
        Contract contract = new Contract(RecordTypeId = ApexUtil.getRecordTypeByName('Contract',EBH_ConstantsUtility.CONTRACT_LISTINGRECORDTYPE).Id, 
            Name = 'Test Contract 1', 
            accountId = accounts.get('le1').Id,
            Status = EBH_ConstantsUtility.CONTRACT_DRAFTSTATUS,
            EBH_Site__c = 'UK',
            EBH_Language__c= 'English',
            Reason_for_Contract_Amendment__c = 'Seller / Brand Acquisition',
            EBH_RequesterNotes__c = 'test',
            Surcharge__c = true,
            PricingVersion__c = 'P1.0',
            StartDate = System.today(),
            EndDate = System.today() + 1,
            Business_Contact__c=contact.id
        );
        insert contract;
        /****** CREATE CONTRACT PRICING RECORD ************************/
        EBH_ContractPricingMatrix__c contractPricingMatrix = EBH_TestDataFactory.createContractPricingMatrix('UK');
        /****** CREATE PRICING RECORD ************************/
        EBH_Pricing__c pricing = new EBH_Pricing__c(EBH_ContractId__c=contract.Id,
            EBH_Site__c='UK',
            EBH_ContractPricingMatrix__c = contractPricingMatrix.Id,
            EBH_Projected12MGMV__c = 11,
            EBH_ASP__c =11,
            RecordTypeId = PricingRecordType.Id
        );
        insert pricing;
        /****** EXECUTE TEST ************************/
        test.startTest();
            try{
                contract.PricingVersion__c = 'P2.0';
                update contract;   
            }catch(Exception e){
                System.debug(e);
                Boolean expectedExceptionThrown =  e.getMessage().contains('Please delete/remove the Pricing records created before changing the Pricing version.') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }

            try{
                delete pricing;
                contract.PricingVersion__c = 'P2.0';
                update contract;
            }catch(Exception e){
                System.debug(e);
                System.assert(false);
            }
    	test.stopTest();
    }

    // Acmatac SEING, 16 June 2021, US-0009604 AC1, Validation Rule Name = Prevent_Changing_Pricing_Version
    static testmethod void testvalidateNotSubmitingAboveStageInNegotiation(){
    	Map<String,Account> accounts = EBH_TestDataFactory.setupAccountTriggerHandlerData();    
    	RecordType manaulconRt = ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL');
	    Contact contact = new Contact(EBH_Status__c='Active', LastName = 'testLastName', FirstName = 'testFirstName',Email='Test@test.com', AccountId = accounts.get('le1').Id,recordTypeId = manaulconRt.Id, EBH_DataOrigin__c='test');             
	    insert contact;  
        /****** CREATE CONTRACT RECORD ************************/
        Contract contract = new Contract(RecordTypeId = ApexUtil.getRecordTypeByName('Contract',EBH_ConstantsUtility.CONTRACT_LISTINGRECORDTYPE).Id, 
            Name = 'Test Contract 1', 
            accountId = accounts.get('le1').Id,
            Status = EBH_ConstantsUtility.CONTRACT_DRAFTSTATUS,
            EBH_Site__c = 'UK',
            EBH_Language__c= 'English',
            Reason_for_Contract_Amendment__c = 'Seller / Brand Acquisition',
            EBH_RequesterNotes__c = 'test',
            Surcharge__c = true,
            PricingVersion__c = 'P1.0',
            StartDate = System.today(),
            EndDate = System.today() + 1,
            Business_Contact__c=contact.id
        );
        insert contract;
        /****** CREATE CONTRACT SELLER RECORD ************************/
        EBH_ContractSeller__c contractSeller = new EBH_ContractSeller__c(EBH_ContractNumber__c = contract.Id, EBH_BusinessName__c = accounts.get('se1').Id);
        insert contractSeller;
        /****** CREATE CONTRACT PRICING RECORD ************************/
        EBH_ContractPricingMatrix__c contractPricingMatrix = EBH_TestDataFactory.createContractPricingMatrix('UK');
        /****** CREATE PRICING RECORD ************************/
        EBH_Pricing__c pricing = new EBH_Pricing__c(EBH_ContractId__c=contract.Id,
            EBH_Site__c='UK',
            EBH_ContractPricingMatrix__c = contractPricingMatrix.Id,
            EBH_Projected12MGMV__c = 11,
            EBH_ASP__c =11,
            RecordTypeId = PricingRecordType.Id
        );
        insert pricing;

        /****** EXECUTE TEST ************************/
        test.startTest();

            // Sophal: 06/08/2021: US-0009896 move contract staus update here to avoid soql 101
            /****** UPDATE CONTRACT STATUS TO Send for Finance Post-check ************************/
            contract.EBH_FinanceAgreesinPrincipal__c = true;
            contract.List_Control_Values__c='3';
            contract.EBH_AttachmentCheck__c = true;
            contract.Status = 'Sent for Finance Post-check';
            update contract;

            try{
                contract.PricingVersion__c = 'P2.0';
                update contract;
                System.assert(false);
            }catch(Exception e){
                System.debug(e);
                System.assert(e.getMessage().contains('You can not change Pricing Version at this Contract Stage'));
            }
            contract.PricingVersion__c = 'P1.0';
            contract.List_Control_Values__c='0';
            contract.Status = 'Draft';
            update contract;
            delete pricing;
            try{
                contract.PricingVersion__c = 'P2.0';
                update contract;   
            }catch(Exception e){
                System.debug(e);
                System.assert(false);
            }
    	test.stopTest();
    }
    
    static testmethod void testsendContract(){
    	byPass__c settings = byPass__c.getOrgDefaults();
        settings.ByPass_Validation__c = true;
        upsert settings byPass__c.Id;
        ActiveValidationRules__c avr = new ActiveValidationRules__c();
		avr.All_Validation_Rules_Deactivated__c = true;
        insert avr;
        
    	Map<String,Account> accounts = EBH_TestDataFactory.setupAccountTriggerHandlerData();  
    	RecordType manaulconRt = ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL');
	    Contact contact = new Contact(EBH_Status__c='Active', LastName = 'testLastName', FirstName = 'testFirstName',Email='Test@test.com', AccountId = accounts.get('le1').Id,recordTypeId = manaulconRt.Id, EBH_DataOrigin__c='test');             
	    insert contact; 
    	Contract contract = new Contract(RecordTypeId = ApexUtil.getRecordTypeByName('Contract','Refurbished').Id, 
            Name = 'Test Contract 1', 
            accountId = accounts.get('le1').Id,
            Status = EBH_ConstantsUtility.CONTRACT_DRAFTSTATUS,
            EBH_Site__c = 'UK',
            EBH_Language__c= 'English',
            Reason_for_Contract_Amendment__c = 'Seller / Brand Acquisition',
            EBH_RequesterNotes__c = 'test',
            Surcharge__c = true,
            PricingVersion__c = 'P1.0',
            StartDate = System.today(),
            EndDate = System.today() + 1,
            Business_Contact__c=contact.id
        );
        insert contract;
        
        contract.Status = EBH_ConstantsUtility.CONTRACT_Approved;
        update contract;
        EBH_ContractSeller__c contractSeller = new EBH_ContractSeller__c(EBH_ContractNumber__c = contract.Id, EBH_BusinessName__c = accounts.get('se1').Id);
        insert contractSeller;
        test.startTest();
        	contract.Status = 'Contract Send';
        	update contract;
        test.stopTest();
        Contract contr = [select Contract_Send_Date__c from Contract where id =: contract.Id];
        System.assertEquals(Date.Today(), contr.Contract_Send_Date__c);
    }

    // Sambath SENG, 30 August 2021, US-0009869, Validation Rule Name = Refurb_Prompting_User_To_Populate_Field
    static testmethod void testShowErrorWhenFieldIsNotPopulate(){
    	Map<String,Account> accounts = EBH_TestDataFactory.setupAccountTriggerHandlerData();  
    	RecordType manaulconRt = ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL');
	    Contact contact = new Contact(EBH_Status__c='Active', LastName = 'testLastName', 
                                    FirstName = 'testFirstName',
                                    Email='Test@test.com',
                                    AccountId = accounts.get('le1').Id,
                                    recordTypeId = manaulconRt.Id,
                                    EBH_MailingAddress__c ='UK',
                                    EBH_MailingCity__c ='UK',
                                    EBH_MailingCountry__c ='UK',
                                    EBH_MailingPostalCode__c ='UK',
                                    EBH_MailingState__c ='UK',
                                    EBH_MailingStreet__c ='UK'
                                    );             
	    insert contact; 
    	Contract contract = new Contract(RecordTypeId = ApexUtil.getRecordTypeByName('Contract','Refurbished').Id, 
            Name = 'Test Contract 1', 
            accountId = accounts.get('le1').Id,
            Status = EBH_ConstantsUtility.CONTRACT_DRAFTSTATUS,
            EBH_Site__c = 'UK',
            EBH_Language__c= 'English',
            Reason_for_Contract_Amendment__c = 'Seller / Brand Acquisition',
            EBH_RequesterNotes__c = 'test',
            StartDate = System.today(),
            EndDate = System.today() + 1,
            Business_Contact__c=contact.id
        );
        insert contract;
        
        String errorMsg = 'Please complete the 2 fields';
        test.startTest();
            // change contract to Seller Declined when Declined Reason field is blank
            try{
                contract.Status = 'Seller Declined';
                update contract;
                System.assert(false);
            }catch(Exception e){
                System.debug(e);
                System.assert(e.getMessage().contains(errorMsg));
            }

            // change contract to eBay Declined when Declined Reason field is blank
            try{
                contract.Status = 'eBay Declined';
                update contract;
                System.assert(false);
            }catch(Exception e){
                System.debug(e);
                System.assert(e.getMessage().contains(errorMsg));
            }

            // change contract to eBay Declined when Declined Reason field is blank
            try{
                contract.Status = 'Program Cancelled';
                update contract;
                System.assert(false);
            }catch(Exception e){
                System.debug(e);
                System.assert(e.getMessage().contains(errorMsg));
            }

            //add value to Declined Reason field
            contract.Declined_Reason__c = 'Seller is below quality criteria';
            update contract;

            try{
                contract.Status = 'Seller Declined';
                update contract;   
            }catch(Exception e){
                System.debug(e);
                System.assert(false);
            }
        test.stopTest();

    }

    static testmethod void testSendRefurbEmailWhenStatusChanged(){

        // Sophal / 07.09.2021 / US-0010204, 0010205

        byPass__c settings = byPass__c.getOrgDefaults();
        settings.ByPass_Validation__c = true;
        upsert settings;

        Map<String,Account> accounts = EBH_TestDataFactory.setupAccountTriggerHandlerData();  
    	accounts.get('le1').EBH_BillingCountry__c = 'DE';
        update accounts.get('le1');

        RecordType manaulconRt = ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL');
	    Contact contact = new Contact(
            EBH_Status__c='Active', 
            LastName = 'testLastName', 
            FirstName = 'testFirstName',
            Email='Test@test.com', 
            AccountId = accounts.get('le1').Id,
            recordTypeId = manaulconRt.Id, 
            EBH_DataOrigin__c='test',
            EBH_MailingAddress__c = 'test',
            EBH_MailingStreet__c = 'test',
            EBH_MailingPostalCode__c = 'test',
            EBH_MailingCity__c = 'test',
            EBH_MailingCountry__c = 'test'
        );             
	    insert contact; 

        Id refurbContractId = ApexUtil.getRecordTypeByName('Contract','Refurbished').Id;

    	Contract contract1 = new Contract(RecordTypeId = refurbContractId, 
            Name = 'Test Contract 1', 
            accountId = accounts.get('le1').Id,
            Status = EBH_ConstantsUtility.CONTRACT_DRAFTSTATUS,
            EBH_Site__c = 'DE',
            EBH_Language__c= 'English',
            Reason_for_Contract_Amendment__c = 'Seller / Brand Acquisition',
            EBH_RequesterNotes__c = 'test',
            Surcharge__c = true,
            PricingVersion__c = 'P1.0',
            StartDate = System.today(),
            EndDate = System.today() + 1,
            Business_Contact__c=contact.id
        );

        Contract contract2 = new Contract(RecordTypeId = refurbContractId, 
            Name = 'Test Contract 2', 
            accountId = accounts.get('le1').Id,
            Status = EBH_ConstantsUtility.CONTRACT_DRAFTSTATUS,
            EBH_Site__c = 'DE',
            EBH_Language__c= 'English',
            Reason_for_Contract_Amendment__c = 'Seller / Brand Acquisition',
            EBH_RequesterNotes__c = 'test',
            Surcharge__c = true,
            PricingVersion__c = 'P1.0',
            StartDate = System.today(),
            EndDate = System.today() + 1,
            Business_Contact__c=contact.id
        );

        List<Contract> listContract = new List<Contract>{contract1,contract2}; 
        insert listContract;

        contract1.Status = 'Program Cancelled';
        contract2.Status = 'eBay Declined';

        update listContract;

        List<Task> listTask = [Select Id,WhatId From Task Where WhatId IN: listContract];
        System.assertEquals(contract1.Id, listTask[0].WhatId);
        System.assertEquals(contract2.Id, listTask[1].WhatId);




    }

    @isTest
    private static void testResetContractStatus(){
    	byPass__c settings = byPass__c.getOrgDefaults();
        settings.ByPass_Validation__c = true;
        upsert settings byPass__c.Id;
        ActiveValidationRules__c avr = new ActiveValidationRules__c();
		avr.All_Validation_Rules_Deactivated__c = true;
        insert avr;
        
    	Map<String,Account> accounts = EBH_TestDataFactory.setupAccountTriggerHandlerData();  
    	RecordType manaulconRt = ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL');
	    Contact contact = new Contact(EBH_Status__c='Active', LastName = 'testLastName', FirstName = 'testFirstName',Email='Test@test.com', AccountId = accounts.get('le1').Id,recordTypeId = manaulconRt.Id, EBH_DataOrigin__c='test');             
	    insert contact; 

        User standardUsr = EBH_TestDataFactory.createUser('Standard User Profile');
        Contract contract;
        System.runAs(standardUsr){
            contract = new Contract(RecordTypeId = EBH_ContractTriggerHandler.CONTRACT_ACP_RECORDTYPEID, 
                Name = 'Test Contract 1', 
                accountId = accounts.get('le1').Id,
                Status = EBH_ContractTriggerHandler.CONTRACT_STATUS_DRAFT,
                EBH_Site__c = 'UK',
                EBH_Language__c= 'English',
                Reason_for_Contract_Amendment__c = 'Seller / Brand Acquisition',
                EBH_RequesterNotes__c = 'test',
                Surcharge__c = true,
                PricingVersion__c = 'P1.0',
                StartDate = System.today(),
                EndDate = System.today() + 1,
                Business_Contact__c=contact.id,
                EBH_FinancePostCheckDone__c = true,
                EBH_FinanceApproved__c = true
            );
            insert contract;
        }
        
        contract.Status = EBH_ConstantsUtility.CONTRACT_Approved;
        update contract;
        EBH_ContractSeller__c contractSeller = new EBH_ContractSeller__c(EBH_ContractNumber__c = contract.Id, EBH_BusinessName__c = accounts.get('se1').Id);
        insert contractSeller;
        test.startTest();
            System.runAs(standardUsr){
        	    contract.Status = EBH_ContractTriggerHandler.CONTRACT_STATUS_DRAFT;
        	    update contract;
            }

            Contract contr = [select EBH_FinancePostCheckDone__c,EBH_FinanceApproved__c,EBH_Approved__c  from Contract where id =: contract.Id];
            System.assertEquals(false, contr.EBH_FinancePostCheckDone__c);
            System.assertEquals(false, contr.EBH_FinanceApproved__c);
            System.assertEquals(false, contr.EBH_Approved__c);

            contract.Status = 'Executed';
            update contract;

            System.runAs(standardUsr){
                try{
                    contract.Status = EBH_ContractTriggerHandler.CONTRACT_STATUS_DRAFT;
        	        update contract;
                    System.assert(false);
                }catch(Exception ex){
                    System.assert(ex.getMessage().contains(Label.CONTRACT_SET_TO_DRAFT_ERROR_MSG));
                }
            }

        test.stopTest();
    }

    

}