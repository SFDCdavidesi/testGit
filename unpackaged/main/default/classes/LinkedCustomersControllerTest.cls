/*********************************************************************************************************************************
@ Class:          LinkedCustomersControllerTest
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        US-0009214 - [Linked Acc]Enable Linked B2C Customers to be shown in Customer 360
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 23.03.2021 / Sovantheany Dim / Created the class.
*********************************************************************************************************************************/
@isTest
public class LinkedCustomersControllerTest {
    static testMethod void testgetAccounts(){
        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');
        Account sellerAcc1 = new Account(Linked_Acc_Group_Id__c='11111111',EBH_OracleId__c='1003293592',Name='Test Acc2',RecordTypeID = sellerRecordType.Id,EBH_RevRollup__c='UK');
    	insert sellerAcc1;
        Account sellerAcc2 = new Account(Linked_Acc_Group_Id__c='11111111', EBH_OracleId__c='1003293593',Name='Test Acc3',RecordTypeID = sellerRecordType.Id,EBH_RevRollup__c='UK');
    	insert sellerAcc2;
        Test.startTest();
        	Map<String,Object> mapResult = LinkedCustomersController.getAccounts(sellerAcc1.Id,6);                                 
        Test.stopTest();
        if(mapResult.containsKey('lstWrapper')){
            ContactsRelatedController.LightningTableWraper lstWrapper = (ContactsRelatedController.LightningTableWraper) mapResult.get('lstWrapper');
            System.assert(lstWrapper.tableRecord.size()==1);
        }
    }
}