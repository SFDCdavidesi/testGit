/*********************************************************************************************************************************
@ Class:          ContactsRelatedControllerTest
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        US-0007434 - [AU & EU] Related Contact
test class for ContactsRelatedController
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 15.04.2020 / Sovantheany Dim / Created the class.
*********************************************************************************************************************************/
@isTest
public class ContactsRelatedControllerTest {
    static testMethod void testgetContacts() {
        RecordType recTypeAuSMBLead = ApexUtil.getRecordTypeByName('Lead','EBH_eBayAUSMB');
    	Lead l = EBH_TestDataFactory.createLeads();
    	l.LeadSource = EBH_ConstantsUtility.LEAD_SOURCE_SELF_GEN;
    	l.RecordTypeId = recTypeAuSMBLead.Id;
    	l.isapproved__c = false;
    	l.Site__c = 'UK';
    	l.LeadSegment__c = 'SMB';
    	insert l;
    	RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	RecordType legalRecordType = ApexUtil.getRecordTypeByName('Account','EBH_LegalEntity');
    	Account legal = new Account(EBH_OracleId__c='1003293591',Name='Test Acc1',RecordTypeID = legalRecordType.Id,EBH_RevRollup__c='UK',EBH_DealsProgram__c ='Accepted');
		insert legal;
		Account sellerAcc = new Account(ParentId = legal.Id, EBH_OracleId__c='1003293592',Name='Test Acc2',RecordTypeID = sellerRecordType.Id,EBH_RevRollup__c='UK',EBH_DealsProgram__c ='Accepted');
    	insert sellerAcc;
    	Contact con = new Contact(LastName = 'testContact', AccountId = legal.Id,EBH_Status__c='Active');
    	insert con;
    	EBH_Project__c p1 = new EBH_Project__c(LegalEntity__c = legal.Id,Lead__c = l.Id, EBH_Seller__c=sellerAcc.Id,ProjectName__c='Project 1',RecordTypeId=ApexUtil.getRecordTypeByName('EBH_Project__c','eBayAUSMB').Id);
    	insert p1;
        Test.startTest();
        	Map<String,Object> mapResult = ContactsRelatedController.getContacts(p1.Id);
        	Id recorType = ContactsRelatedController.getRecTypeId();
        Test.stopTest();
        system.assert(mapResult.get('contactNumber') == 1);
    }
    
    static testMethod void testgetContactsForAccount() {
    	RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
    	RecordType legalRecordType = ApexUtil.getRecordTypeByName('Account','EBH_LegalEntity');
    	Account legal = new Account(EBH_OracleId__c='1003293591',Name='Test Acc1',RecordTypeID = legalRecordType.Id,EBH_RevRollup__c='UK',EBH_DealsProgram__c ='Accepted');
		insert legal;
		Account sellerAcc = new Account(ParentId = legal.Id, EBH_OracleId__c='1003293592',Name='Test Acc2',RecordTypeID = sellerRecordType.Id,EBH_RevRollup__c='UK',EBH_DealsProgram__c ='Accepted');
    	insert sellerAcc;
    	
    	Contact con = new Contact(LastName = 'testContact', AccountId = legal.Id,EBH_Status__c='Active');
    	insert con;
    	Test.startTest();
        	Map<String,Object> mapResult = ContactsRelatedController.getContacts(sellerAcc.Id);
        	Id recorType = ContactsRelatedController.getRecTypeId();
        Test.stopTest();
        system.assert(mapResult.get('contactNumber') == 1);
    }
}