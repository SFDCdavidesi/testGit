/*********************************************************************************************************************************
@ Class:          CreateTaskForSellerControllerTest
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        Test logic for CreateTaskForSellerController
@ EPH-5671 Create Contact Quality Task in Seller Record when Status = red for managed sellers
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 15.03.2019 / Sovantheany Dim / Created the class.
                : 28.04.2022 / Loumang SENG / US-0011388 - Deactivate Contact Quality Task creation in the Seller Record
*********************************************************************************************************************************/

@isTest
private class CreateTaskForSellerControllerTest {

    /*static testMethod void myUnitTest() {
    	Test.startTest();
    	EBH_TestDataFactory.setUpCustomSettings();
    	
    	RecordType sellerId = [SELECT Id FROM RecordType where SobjectType = 'Account' and DeveloperName = 'EBH_Seller'];
		RecordType legalEntityId = [SELECT Id FROM RecordType where SobjectType = 'Account' and DeveloperName = 'EBH_LegalEntity'];
        Account legalAcc0 = new Account(Name = 'testLegalAcc0',RecordTypeId = legalEntityId.Id);
        Account legalAcc1 = new Account(Name = 'testLegalAcc1',RecordTypeId = legalEntityId.Id);
        insert new List<Account>{legalAcc0,legalAcc1};
        Account acc1 = new Account(Name = 'testAccount0', RecordTypeId = sellerId.ID, ParentId = legalAcc0.Id,EBH_OracleID__c = '1111', BillingStreet = 'testStreet1',BillingState ='testState1',BillingPostalCode='testpostalcode1',BillingCountry = 'testcountry1',BillingCity='testcity1');
        Account acc2 = new Account(Name = 'testAccount1', RecordTypeId = sellerId.ID, ParentId = legalAcc1.Id,EBH_OracleID__c = '2222', BillingStreet = 'testStreet2',BillingState ='testState2',BillingPostalCode='testpostalcode2',BillingCountry = 'testcountry2',BillingCity='testcity2',EBH_BOBManaged__c = true);
        List<Account> lstAccount = new List<Account>{acc1,acc2};
        insert lstAccount;
        List<Contact> lstCont = new List<Contact>();
        for(Integer i = 0; i < 2; i++){
        	Contact con = new Contact(LastName = 'testContact' + i, AccountId = lstAccount[i].Id, EBH_Status__c='Active',Email='test'+i+'@gmail.com',
        	Phone='123456'+i,EBH_MailingStreet__c='testMailingStreet'+i,EBH_MailingPostalCode__c='testMailingPostalcode'+i,
        	EBH_MailingCountry__c='testMailingCountry'+i,EBH_MailingCity__c='testMailingCity'+i,EBH_MailingAddress__c='testMailingAddress'+i);
        	
        	lstCont.add(con);
        }
        insert lstCont;
        
        Map<String,Object> mapResult = CreateTaskForSellerController.createTask(String.valueOf(acc1.id));
        
        System.assertEquals(mapResult.get('status'), 'info');
        System.assertEquals(mapResult.get('info'), 'Task is created only when BoB Managed = TRUE and Contact Data Quality = RED or YELLOW');
        
        Account accSeller2 = [select Contact_Data_Quality__c,EBH_BOBManaged__c from Account where id =: acc2.Id];
        System.assertEquals(accSeller2.EBH_BOBManaged__c,true);
        System.assertEquals(accSeller2.Contact_Data_Quality__c,'Green');
        
        for(Contact con : lstCont){
        	con.AccountId = accSeller2.Id;
        	con.Email_Bounced__c = true;
        	con.Incorrect_Phone_Number__c = true;
        }
        update lstCont;
        
        Account accSeller3 = [select Contact_Data_Quality__c,EBH_BOBManaged__c from Account where id =: acc2.Id];
        System.assertEquals(accSeller3.EBH_BOBManaged__c,true);
        System.assertEquals(accSeller3.Contact_Data_Quality__c,'Red');
        
        Map<String,Object> mapResult2 = CreateTaskForSellerController.createTask(String.valueOf(acc2.id));
		//System.assertEquals(mapResult2.get('status'), 'ok');
        
        List<Task> taskCreated = [select id from Task where Subject = 'Contact Quality Task is created' and WhatId =: acc2.Id];
        //System.assertEquals(taskCreated.size(),1);
        Test.stopTest();
    }*/
    static testMethod void testDepreciatedClass(){
        Test.startTest();
            CreateTaskForSellerController depreciatedMSR = new CreateTaskForSellerController();
        Test.stopTest();

    }
}