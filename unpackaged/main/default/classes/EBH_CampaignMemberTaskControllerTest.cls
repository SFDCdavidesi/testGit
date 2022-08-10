/*********************************************************************************************************************************
@ Class:          EBH_CampaignMemberTaskControllerTest
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        Test class for EBH_CampaignMemberTaskController class
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 06.10.2017 / NEHA LUND / Created the test class.
*********************************************************************************************************************************/

@isTest(seeAllData = False)
public class EBH_CampaignMemberTaskControllerTest {
    
    /*****************************************************************************************************************************
    @ Method:         testProfile_SA
    @ Version:        1.0
    @ Author:         NEHA LUND
    @ Purpose:        Profile testing for System Administrator
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 06.10.2017 / NEHA LUND / Created the test Method.
    *****************************************************************************************************************************/
    static testMethod void testProfile_SA() {       
        System.runAs(EBH_TestDataFactory.createUser('System Administrator')) { testFrontEndMetrics(); }        
    }
    
    /*****************************************************************************************************************************
    @ Method:         testProfile_SU
    @ Version:        1.0
    @ Author:         NEHA LUND
    @ Purpose:        Profile testing for Standard User
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 06.10.2017 / NEHA LUND / Created the test Method.
    *****************************************************************************************************************************/
    static testMethod void testProfile_SU() {
        System.runAs(EBH_TestDataFactory.createUser('Standard User')) { testFrontEndMetrics(); }
    }
    
    /*****************************************************************************************************************************
    @ Method:         testFrontEndMetrics
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
    @ Change history: 05.05.2017 / NEHA LUND / Created the test Method.
					  25.10.2021 / SRONG TIN / Update the test Method. US-0008400, update coverage.
    *****************************************************************************************************************************/
    static testMethod void testFrontEndMetrics() {
                    
        /*TEST DATA ------------------------------------------------------------------------------------------ BEGIN -----------*/
        EBH_TestDataFactory.setUpCustomSettings();     
        List<CampaignMember> campaignMembers = EBH_TestDataFactory.setUpOutreachCampaignHandlerData();  
         
        /*TEST DATA ------------------------------------------------------------------------------------------ END -------------*/

        Test.startTest();
            /*POSITIVE TESTING ------------------------------------------------------------------------------- BEGIN -----------*/
            Campaign cRecord =  new Campaign(Id = [SELECT campaignId from CampaignMember limit 1].CampaignId );
                   
            EBH_CampaignMemberTaskController instance = new EBH_CampaignMemberTaskController(new ApexPages.standardController(cRecord));
            instance.createTasks();
            
            instance.createTasks();
            
            List<Task> tasks = [SELECT id from Task];
            
            tasks[0].EBH_Response__c = EBH_ConstantsUtility.AOC_TASKPHONE;
            update tasks;
            
            tasks[0].EBH_Response__c = EBH_ConstantsUtility.AOC_TASKCALLNOTANSWERED;
            update tasks;
            
            tasks[0].EBH_Response__c = EBH_ConstantsUtility.AOC_TASKWRONGPHONE;
            update tasks;
            
            tasks[0].EBH_Response__c = EBH_ConstantsUtility.AOC_TASKDMCNOTREACHED;
            update tasks;
            
            tasks[0].EBH_Response__c = EBH_ConstantsUtility.AOC_TASKDMCNOTINTERESTED;
            update tasks;
            
            tasks[0].EBH_Response__c = EBH_ConstantsUtility.AOC_UNSUBSCRIBE;
            update tasks;
            
            tasks[0].EBH_Response__c = EBH_ConstantsUtility.AOC_TASKDMCINTERESTED;
            update tasks;
            
            tasks[0].EBH_Response__c = EBH_ConstantsUtility.AOC_TASKDMCCOMMITTED;
            update tasks;
            
            
            cRecord.EBH_LastResponseDate__c = Date.today().addDays(-14);
            crecord.Status = 'Execution';
            update cRecord;
            Database.executeBatch(new EBH_PhoneCampaignCompletionBatch());
            
            List<CampaignMember> cMembers = [SELECT EBH_LastResponseDate__c from CampaignMember where campaignId = :cRecord.Id ];
            
            for(CampaignMember cm : cMembers){
                cm.EBH_LastResponseDate__c = Date.today()-15;
            }
        
            update cMembers;
            EBH_PhoneCampaignCompletionBatch pBatch = new EBH_PhoneCampaignCompletionBatch() ;
            Database.executeBatch(pBatch);
            SchedulableContext sc;
            pBatch.execute(sc);
        	// SRONG TIN : 25.10.2021 | US-0008400
            pBatch.execute(null,cMembers);
        	
            /*NEGETIVE TESTING ------------------------------------------------------------------------------- END -------------*/
            
            /*EXCEPTION TESTING ------------------------------------------------------------------------------ BEGIN -----------*/
            /*Modify data for test*/             
            
            /*Excecute test*/
            
            /*Validate test*/
            
            /*EXCEPTION TESTING ------------------------------------------------------------------------------ END -------------*/
        Test.stopTest();
    }
}