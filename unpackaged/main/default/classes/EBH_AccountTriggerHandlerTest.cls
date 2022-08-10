/*********************************************************************************************************************************
@ Class:          EBH_AccountTriggerHandlerTest
@ Version:        1.0
@ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
@ Purpose:        Test class for EBH_AccountTriggerHandler class
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 05.05.2017 / JOY MONDOL / Created the test class.
*********************************************************************************************************************************/

@isTest(seeAllData = False)
public class EBH_AccountTriggerHandlerTest {
    
    /*****************************************************************************************************************************
    @ Method:         testProfile_SA
    @ Version:        1.0
    @ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
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
    @ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
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
    @ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
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
        EBH_TestDataFactory.setUpCustomSettings();     
        Map<String, Account> testDataMap = EBH_TestDataFactory.setUpAccountTriggerHandlerData();     
        /*TEST DATA ------------------------------------------------------------------------------------------ END -------------*/

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
            
            testDataMap.get('se3').EBH_AccountManageName__c = [SELECT lastName from User where id = :UserInfo.getUserID()].LastName;
            testDataMap.get('se3').EBH_UrgencyFlag__c = true;
            
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
                           
            System.assertEquals(332, le1.EBH_SoldItems__c);
            System.assertEquals(165, le1.EBH_GMVLast12Months__c);
            System.assertEquals(198, le1.EBH_RevenueLast12Months__c);
                                     
            System.assertEquals(77, le2.EBH_SoldItems__c);
            System.assertEquals(88, le2.EBH_GMVLast12Months__c);
            System.assertEquals(99, le2.EBH_RevenueLast12Months__c);
            
            /*System.assertEquals(200, le1.EBH_SoldItems__c);
            System.assertEquals(0, le1.EBH_GMVLast12Months__c);
            System.assertEquals(0, le1.EBH_RevenueLast12Months__c);
                                     
            System.assertEquals(null, le2.EBH_SoldItems__c);
            System.assertEquals(null, le2.EBH_GMVLast12Months__c);
            System.assertEquals(null, le2.EBH_RevenueLast12Months__c);*/
            /*POSITIVE TESTING ------------------------------------------------------------------------------- END -------------*/
            
            /*NEGETIVE TESTING ------------------------------------------------------------------------------- BEGIN -----------*/
            /*Modify data for test*/             
            testDataMap.get('le3').EBH_SoldItems__c = 9999;
            
            /*Excecute test*/
            update testDataMap.values(); //change in legal entity should not roll up
            
            /*Validate test*/
            le2 = [SELECT EBH_SoldItems__c FROM Account WHERE Id =: testDataMap.get('le2').Id][0];
            
            System.assertEquals(10076, le2.EBH_SoldItems__c);
            
            System.assertEquals(0, le3.EBH_SoldItems__c);
            System.assertEquals(0, le3.EBH_GMVLast12Months__c);
            System.assertEquals(0, le3.EBH_RevenueLast12Months__c);
            
            System.assertEquals(0, le4.EBH_SoldItems__c);
            
            /*System.assertEquals(null, le2.EBH_SoldItems__c);
            
            System.assertEquals(null, le3.EBH_SoldItems__c);
            System.assertEquals(null, le3.EBH_GMVLast12Months__c);
            System.assertEquals(null, le3.EBH_RevenueLast12Months__c);
            
            System.assertEquals(null, le4.EBH_SoldItems__c);*/
            /*NEGETIVE TESTING ------------------------------------------------------------------------------- END -------------*/
            
            /*EXCEPTION TESTING ------------------------------------------------------------------------------ BEGIN -----------*/
            /*Modify data for test*/             
            testDataMap.get('se1').EBH_RevenueLast12Months__c = 99999999999999.0;
            
            /*Excecute test*/
            update testDataMap.values(); //change in legal entity should not roll up
            
            /*Validate test*/
            System.assertEquals(1, [SELECT EBH_MethodName__c FROM EBH_ApexLog__c 
                                    WHERE EBH_MethodName__c = 'updateCustomRollUp'].size());
            
            testDataMap.get('le3').EBH_Status__c = 'Deleted';
            update testDataMap.values();
            
            testDataMap.get('le3').EBH_Status__c = 'Deleted';
            update testDataMap.values();
            EBH_InviteToDealsProgramController cInstance = new EBH_InviteToDealsProgramController(
                                                           new ApexPages.standardController(testDataMap.get('se7')));
            cInstance.updateInvitedtoDealProgram();
            
            EBH_InviteToDealsProgramController cInstance2 = new EBH_InviteToDealsProgramController(
                                                           new ApexPages.standardController(testDataMap.get('se7')));
            cInstance2.selectedCulture = 'DE';
            cInstance2.updateInvitedtoDealProgram();
            
            
             
            
            delete testDataMap.values();
            
            
            /*EXCEPTION TESTING ------------------------------------------------------------------------------ END -------------*/
        Test.stopTest();
    }
    
    /*****************************************************************************************************************************
    @ Method:         testcreateTask
    @ Version:        1.0
    @ Author:         sovantheany.dim
    @ Purpose:        EPH-5671 Create Contact Quality Task in Seller Record when Status = red for managed sellers
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 20.03.2019 / sovantheany.dim / Created the test Method.
                    : 28.04.2022 / Loumang SENG / US-0011388 - Deactivate Contact Quality Task creation in the Seller Record
    *****************************************************************************************************************************/
    /*static testMethod void testcreateTask() {
    	Test.startTest();
    	EBH_TestDataFactory.setUpCustomSettings(); 
    	List<Account> sellers = EBH_TestDataFactory.createAccounts(2, 'EBH_Seller');
    	sellers[0].EBH_BOBManaged__c = true;
    	update sellers;
    	List<Contact> con1 = EBH_TestDataFactory.createContacts(1, 'Test Contact', sellers[0].id);
    	List<Contact> con2 = EBH_TestDataFactory.createContacts(1, 'Test Contact', sellers[1].id);
    	con1[0].Incorrect_Phone_Number__c = true;
    	con2[0].Incorrect_Phone_Number__c = true;
    	List<Contact> lstContact = new List<Contact>();
    	lstContact.addAll(con1);
    	lstContact.addAll(con2);
    	update lstContact;
    	
    	Account accSeller = [select Contact_Data_Quality__c,EBH_BOBManaged__c from Account where id =: sellers[0].Id];
        System.assertEquals(accSeller.EBH_BOBManaged__c,true);
        System.assertEquals(accSeller.Contact_Data_Quality__c,'Red');
    	
    	Test.stopTest();
    	List<Task> lstTaskCreated = [select id from Task where WhatId IN: sellers and Subject = 'Contact Quality Task is created'];
    		System.assertEquals(lstTaskCreated.size(), 1);
    }*/
    
    static testMethod void testRemoveGDPRContacts()
    {
    	RecordType recGDPR = ApexUtil.getRecordTypeByName('Contact','EBH_GDPR_Removed');
    	RecordType recM = ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL');
    	EBH_TestDataFactory.setUpCustomSettings();
   		List<Account> lstAcc = EBH_TestDataFactory.createAccounts(1,'EBH_Seller');
    		
    	Contact con = new Contact(Email='test@test.com',EBH_SecondaryEmail__c='test2@test.com',phone='123456',MobilePhone='1234567',LastName = 'testPrim', AccountId = lstAcc[0].Id, EBH_DataOrigin__c='test',EBH_Status__c='Active',Primary_Contact__c = true);
    	Contact con2 = new Contact(RecordTypeId=recM.Id,Email='test2@test.com',EBH_SecondaryEmail__c='test2@test.com',phone='0123456',MobilePhone='1234567',LastName = 'testPrim', AccountId = lstAcc[0].Id, EBH_DataOrigin__c='test',EBH_Status__c='Active',Primary_Contact__c = true);
    	insert new Contact[]{con,con2};
    	
    	EBH_AccountTriggerHandler.removeGDPRContacts(new Contact[]{con} , false);
    	Test.startTest();
    	
    	EBH_AccountTriggerHandler.updateGDPRContacts(new Set<String> {'test@test.com'}, new Set<String> {'0123456'}, recGDPR.Id);
    	
    	Test.stopTest();
    }
    /* MN-28072021-Deprecated via US-0009966
    static testMethod void testSendDealMailtoContact()
    {
        EBH_TestDataFactory.setUpCustomSettings();

        RecordType recSeller = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
        RecordType recM = ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL');
        Account acc = new Account(Name='Test acc 1223xxx24',EBH_DealsProgram__c ='Allow',EBH_GBCulture__c ='DE');
        insert acc;
        Contact con = new Contact(Email='test23@test.com',EBH_SecondaryEmail__c='test2@test.com',phone='123456',MobilePhone='1234567',LastName = 'testPrim', AccountId = acc.Id, EBH_DataOrigin__c='test',EBH_Status__c='Active',Primary_Contact__c = true);
        insert con;
        Test.startTest();
            EBH_CheckRecursive.Run = true;
            acc.EBH_DealsProgram__c ='Accepted';
            update acc;

            Account acc_sel = [Select Id,Name,EBH_DealsProgram__c From Account Where Id =: acc.Id];
            System.assertEquals('Accepted', acc_sel.EBH_DealsProgram__c);

        Test.stopTest();
        
    }
    */
}