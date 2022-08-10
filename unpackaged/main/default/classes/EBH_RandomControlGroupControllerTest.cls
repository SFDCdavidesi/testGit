/*********************************************************************************************************************************
@ Class:          EBH_RandomControlGroupControllerTest
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        Test class for EBH_RandomControlGroupController class
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 23.05.2018 / NEHA LUND / Created the test class.
*********************************************************************************************************************************/

@isTest(seeAllData = False)
public class EBH_RandomControlGroupControllerTest {
    
    /*****************************************************************************************************************************
    @ Method:         testProfile_SA
    @ Version:        1.0
    @ Author:         NEHA LUND
    @ Purpose:        Profile testing for System Administrator
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 05.05.2017 / NEHA LUND / Created the test Method.
    *****************************************************************************************************************************/
    static testMethod void testProfile_SA() {       
        System.runAs(EBH_TestDataFactory.createUser('System Administrator')) { testCampaignMemberRefresh(); }        
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
        System.runAs(EBH_TestDataFactory.createUser('Standard User')) { testCampaignMemberRefresh(); }
    }
    
    /*****************************************************************************************************************************
    @ Method:         testCampaignMemberRefresh
    @ Version:        1.0
    @ Author:         NEHA LUND
    @ Purpose:        TEST CASE (*) System should be able to create the Targeted Sellers based on the attachment
                                    uploaded on Seller List Snapshot record, It will delete previous Targeted Sellers &
                                    creates the new Targeted Sellers
                      COVERAGES (*) testCampaignMemberRefresh(): Creates the Seller records
                                    Attachment records on Seller List Snapshot object
                                    Attachment Trigger and Handler class
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 05.05.2017 / NEHA LUND / Created the test Method.
    *****************************************************************************************************************************/
    static testMethod void testCampaignMemberRefresh() {
                    
        /*TEST DATA ------------------------------------------------------------------------------------------ BEGIN -----------*/
        EBH_TestDataFactory.setUpCustomSettings();     
       
        
        
       
        List<Campaign>  listCam = EBH_TestDataFactory.setUpStrategicCampaignData();
        
        EBH_TestDataFactory.setUpTargetedSellerTriggerHandlerData();
        List<EBH_Filter__c> sellerLists0 = EBH_TestDataFactory.createSellerLists(1, 'Test Seller List', 
                                                'Snapshot_Seller_List', System.today() + 365);
        EBH_Filter__c sellerL = sellerLists0[0];//[SELECT id from EBH_Filter__c where RecordType.dEveloperName = 'Snapshot_Seller_List' limit 1];
           
        /*TEST DATA ------------------------------------------------------------------------------------------ END -------------*/

        /*POSITIVE TESTING ------------------------------------------------------------------------------- BEGIN -----------*/
                         
            
            /*Excecute test*/
            
             List<EBH_Filter__c> sellerLists = EBH_TestDataFactory.createSellerLists(1, 'Test Seller List', 
                                                'Snapshot_Seller_List', System.today() + 365);
            Test.startTest();
            Campaign pRecord = listCam[0];//[SELECT id from Campaign][0];
            EBH_RandomControlGroupController controller = new EBH_RandomControlGroupController(
            new ApexPages.standardController(sellerLists[0])); 
            controller.refreshRandomGroup();
            
            
            
            sellerL.EBH_ActualControlGroupSize__c = 100;
            update sellerL;
            
            pRecord.EBH_SellerList__c = sellerL.ID;
            update pRecord;
            
            Test.stopTest();
            
            controller = new EBH_RandomControlGroupController(
            new ApexPages.standardController(sellerL)); 
            controller.refreshRandomGroup();
              
           
            sellerL.EBH_ActualControlGroupSize__c = 10;
            update sellerL;
            
            controller = new EBH_RandomControlGroupController(
            new ApexPages.standardController(sellerL)); 
            controller.refreshRandomGroup();

        
        
    }
}