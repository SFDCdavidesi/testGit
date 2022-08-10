/*********************************************************************************************************************************
@ Class:          EBH_InviteToDealsProgramControllerTest
@ Version:        1.0
@ Author:         SRONG TIN (srong.tin@gaea-sys.com)
@ Purpose:        Test class for EBH_InviteToDealsProgramController class
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 14.09.2021 / SRONG TIN / Created the test class.
*********************************************************************************************************************************/
@isTest
public class EBH_InviteToDealsProgramControllerTest {
	
     @isTest
     private static void testMethod1(){
         
        RecordType sellerRecordType = ApexUtil.getRecordTypeByName('Account','EBH_Seller');            
        Account acc = new Account(Name='Test se2',RecordTypeID = sellerRecordType.Id);
        insert acc;
         

        Test.startTest();
         	EBH_InviteToDealsProgramController cInstance = new EBH_InviteToDealsProgramController(
                                                           new ApexPages.standardController(acc));
            cInstance.updateInvitedtoDealProgram();
            cInstance.selectedCulture = 'DE';
            cInstance.updateInvitedtoDealProgram();
         	cInstance.isAllowed = true;
         	acc = [Select Id,EBH_DealsProgram__c From Account Where Id =:acc.Id];
         	System.assertEquals('Allow', acc.EBH_DealsProgram__c);
            
        Test.stopTest();
    }
    
}