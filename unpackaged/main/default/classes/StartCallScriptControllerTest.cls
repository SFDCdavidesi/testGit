/*********************************************************************************************************************************
@ Class:          StartCallScriptControllerTest
@ Version:        1.0
@ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:        test class for StartCallScriptController
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:  15.06.2021 / Sophal Noch / Created the class.
*********************************************************************************************************************************/
@isTest
private class StartCallScriptControllerTest {


    /*****************************************************************************************************************************
    @ Method:       testGetSessionId
    @ Author:       Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:      US-0009379 - test method for StartCallScriptController.getSessionId
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  15.06.2021 / Sophal Noch / Created the method.
    @*****************************************************************************************************************************/
    @isTest 
    private static void testGetSessionId(){
        String sessionId = StartCallScriptController.getSessionId();
        System.assertNotEquals(null, sessionId);
    }
    
    /*****************************************************************************************************************************
    @ Method:       testSaveContacts
    @ Author:       sovantheany.dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:      US-0011439 - Duplicate Management Contacts
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  11.07.2022 / sovantheany.dim / Created the method.
    @*****************************************************************************************************************************/
    @isTest 
    private static void testSaveContacts(){
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'Test Acc1';
        acc.RecordTypeID = ApexUtil.getRecordTypeByName('Account','EBH_Seller').Id;
        insert acc;
        Contact cont = new Contact(
            	FirstName = 'Test',
                Lastname = 'test con2',
                AccountId = acc.Id,
                Email = System.now().millisecond() + 'test2@test.com',
                RecordTypeId=ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL').Id);
        
        StartCallScriptController.saveContacts(new List<Contact>{cont});
        
        Test.stopTest();
    }
}