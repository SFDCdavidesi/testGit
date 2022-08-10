/***************************************************************************************************************************************
@ Class:          SandboxDataGeneratorTest
@ Version:        1.0
@ Author:         Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:        Test class for SandboxDataGenerator
----------------------------------------------------------------------------------------------------------------------------------------
@ Change history: 05.02.2018 / Vadhanak Voun / Created the class.
***************************************************************************************************************************************/

@isTest
private class SandboxDataGeneratorTest {

    //MN-01102021-US-0008414 - To avoid error due to validation rule
    @testSetup 
    static void setup() {
          
          byPass__c bp = new byPass__c(SetupOwnerId = UserInfo.getUserId(), byPass_Trigger__c = false, ByPass_Validation__c=true);
          insert bp;

    }

    /************************************************************************************************************************************
    @ Method:         testBatchSandboxGenerator 
    @ Version:        1.0
    @ Author:         Vadhanak Voun
    @ Purpose:        Test method for SandboxDataGenerator stage1 to 7
    -------------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:       
    -------------------------------------------------------------------------------------------------------------------------------------
    @ Returns:         
    -------------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.02.2018 / Vadhanak Voun / Created the Method.
    ************************************************************************************************************************************/
    static testMethod void testBatchSandboxGenerator1()
    {
         SandboxDataGenerator.generateSandboxData_Stage1();
    }
    static testMethod void testBatchSandboxGenerator2()
    {
         SandboxDataGenerator.generateSandboxData_Stage2();
    }
    static testMethod void testBatchSandboxGenerator3()
    {
         SandboxDataGenerator.generateSandboxData_Stage3();
    }
    static testMethod void testBatchSandboxGenerator4()
    {
         SandboxDataGenerator.generateSandboxData_Stage4();
    }
    static testMethod void testBatchSandboxGenerator5()
    {
         SandboxDataGenerator.generateSandboxData_Stage5();
    }
    static testMethod void testBatchSandboxGenerator6()
    {
         SandboxDataGenerator.generateSandboxData_Stage6();
    }
    static testMethod void testBatchSandboxGenerator7()
    {
         SandboxDataGenerator.generateSandboxData_Stage7();
    }

    static testMethod void testBatchSandboxGenerator8()
    {
          SandboxDataGenerator.setUpCustomSettings();
          SandboxDataGenerator.setUpPreApprovedContractSettings();
         SandboxDataGenerator.setUpApexLoggerData();
         //SandboxDataGenerator.createNBARecord(sellerId);
         SandboxDataGenerator.createCampaigns( 1, 'camp1', '7', 'EBH_StrategicPriority' );
        // SandboxDataGenerator.createChildSiteApprover(String recordType, Id parentApprover,Id approverUser, decimal threshold )
         SandboxDataGenerator.createUser('Standard Ads User Profile');
         //SandboxDataGenerator.createTickets(1);
    }
}