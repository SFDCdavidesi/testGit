/*********************************************************************************************************************************
@ Class:          EBH_ContentDocumentLinkHandlerTest
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        Test class for EBH_ContentDocumentLinkHandler class
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 13.06.2017 / NEHA LUND / Created the test class.
*********************************************************************************************************************************/

@isTest(seeAllData = False)
public class EBH_ContentDocumentLinkHandlerTest{
    
    /*****************************************************************************************************************************
    @ Method:         testProfile_SA
    @ Version:        1.0
    @ Author:         NEHA LUND
    @ Purpose:        Profile testing for System Administrator
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 05.05.2017 / NEHA LUND / Created the test Method.
    *****************************************************************************************************************************/
    static testMethod void testProfile_SA() {       
        System.runAs(EBH_TestDataFactory.createUser('System Administrator')) { testContentDocument(); }        
    }
    
    /*****************************************************************************************************************************
    @ Method:         testProfile_SU
    @ Version:        1.0
    @ Author:         NEHA LUND
    @ Purpose:        Profile testing for Standard User
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 05.05.2017 / NEHA LUND / Created the test Method.
    *****************************************************************************************************************************/
    static testMethod void testProfile_SU() {
        System.runAs(EBH_TestDataFactory.createUser('Business Admin')) { testContentDocument(); }
    }
    
    /*****************************************************************************************************************************
    @ Method:         testContentDocument
    @ Version:        1.0
    @ Author:         NEHA LUND
    @ Purpose:        TEST CASE (*) System should be able to create the Targeted Sellers based on the attachment
                                    uploaded on Seller List Snapshot record, It will delete previous Targeted Sellers &
                                    creates the new Targeted Sellers
                      COVERAGES (*) testContentDocument(): Creates the Seller records
                                    Attachment records on Seller List Snapshot object
                                    Attachment Trigger and Handler class
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 05.05.2017 / NEHA LUND / Created the test Method.
    *****************************************************************************************************************************/
    static testMethod void testContentDocument() {
                    
        /*TEST DATA ------------------------------------------------------------------------------------------ BEGIN -----------*/
        EBH_TestDataFactory.setUpCustomSettings();     
      //  EBH_TestDataFactory.setUpAttachmentTriggerHandlerData();     
        /*TEST DATA ------------------------------------------------------------------------------------------ END -------------*/

        Test.startTest();
            /*POSITIVE TESTING ------------------------------------------------------------------------------- BEGIN -----------*/
                         
            EBH_TestDataFactory.setUpAttachmentTriggerHandlerData();
            /*Excecute test*/
            
            /*Validate test*/
            List<EBH_TargetedSeller__c> targetedSellers = [SELECT id from EBH_TargetedSeller__c];
            System.assertEquals( 1 , targetedSellers.size() );
            
            /*POSITIVE TESTING ------------------------------------------------------------------------------- END -------------*/
            
            /*NEGETIVE TESTING ------------------------------------------------------------------------------- BEGIN -----------*/
             List<Contract> testData = EBH_TestDataFactory.setUpContractTriggerHandlerData(); 
            /*Excecute test*/
            /*EBH_TestDataFactory.createAttachment('test', 'test attachment', 
                                    EBH_TestDataFactory.createAccounts(1, 'EBH_LegalEntity')[0].id);
            
           
            System.assertEquals( 1 , targetedSellers.size() );
            
            //System.assertEquals( true, EBH_CheckRecursive.runOnce());
            //System.assertEquals( false, EBH_CheckRecursive.runOnce());
             
             List<Contract> testData = EBH_TestDataFactory.setUpContractTriggerHandlerData();     
             
             
             Attachment at = EBH_TestDataFactory.createAttachment('test', 'test attachment', testdata[0].Id);
             try{
             delete at;
             }
             catch(Exception e){
             }*/
             ContentVersion contentVersion_1 = new ContentVersion(
              Title = 'Penguins',
              PathOnClient = 'Penguins.pdf',
              VersionData = Blob.valueOf('Test Content')
              
           
            );
            insert contentVersion_1;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = documents[1].Id;
            cdl.LinkedEntityId  = testData[0].ID;
            cdl.shareType = 'V';
            insert cdl;
            delete documents;
                     
            /*EXCEPTION TESTING ------------------------------------------------------------------------------ BEGIN -----------*/
            /*Modify data for test*/             
            
            /*Excecute test*/
            
            /*Validate test*/
            
            /*EXCEPTION TESTING ------------------------------------------------------------------------------ END -------------*/
        Test.stopTest();
    }
}