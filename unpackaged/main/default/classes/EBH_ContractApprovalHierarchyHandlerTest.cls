/*****************************************************************************************************************************
@ Class:       EBH_ContractApprovalHierarchyHandler
@ Author:      Mony Nou (mony.nou@gaea-sys.com)
@ Purpose:     US-0008361 test class for EBH_ContractApprovalHierarchyHandler
------------------------------------------------------------------------------------------------------------------------------
@ Change history:  17.11.2021 / Mony Nou / Created the method.
@*****************************************************************************************************************************/
@IsTest 
private class EBH_ContractApprovalHierarchyHandlerTest {
    
    @isTest static void test_method() {

        Test.startTest();

            EBH_ActiveTriggers__c cusettingTrigger = new EBH_ActiveTriggers__c();
            cusettingTrigger.Name = 'EBH Trigger Controller';
            cusettingTrigger.EBH_ContactTrigger__c = true;
            cusettingTrigger.EBH_ContractApprovalHierarchyTrigger__c = true;
            cusettingTrigger.EBH_ExecuteContractUpdateBatch__c = false;
            insert cusettingTrigger; 

            List<User> users = EBH_TestDataFactory.createUsers(4, 'Standard User');
            insert users;  

            EBH_ContractApprovalMatrix__c  matrixRecordDE = EBH_TestDataFactory.createContractApprovalMatrix ( 'DE', users[0].id, users[1].id ) ;
            EBH_ContractApprovalMatrix__c  matrixRecordFR = EBH_TestDataFactory.createContractApprovalMatrix ( 'FR', users[0].id, users[1].id ) ;
            EBH_ContractApprovalMatrix__c  matrixRecordIT = EBH_TestDataFactory.createContractApprovalMatrix ('IT', users[0].id, users[1].id ) ;
            EBH_ContractApprovalMatrix__c  matrixRecordES = EBH_TestDataFactory.createContractApprovalMatrix ( 'ES', users[0].id, users[1].id ) ;
            EBH_ContractApprovalMatrix__c  matrixRecordUK = EBH_TestDataFactory.createContractApprovalMatrix ( 'UK', users[0].id, users[1].id ) ;
            EBH_ContractApprovalMatrix__c  matrixRecordRest = EBH_TestDataFactory.createContractApprovalMatrix ( 'Rest of Europe', users[0].id, users[1].id ) ;
            insert new List<EBH_ContractApprovalMatrix__c>{matrixRecordDE,matrixRecordFR,matrixRecordIT,matrixRecordES,matrixRecordUK,matrixRecordRest};

            EBH_ContractApprovalHierarchy__c child1 = EBH_TestDataFactory.createContractApprovalHierarchy ( EBH_ConstantsUtility.HIERARCHY_CONTROLLING, users[2].id, 5000000.0);
            child1.EBH_ContractApprovalMatrix__c = matrixRecordDE.Id;
            EBH_ContractApprovalHierarchy__c child2 = EBH_TestDataFactory.createContractApprovalHierarchy ( EBH_ConstantsUtility.HIERARCHY_FINANCE, users[3].id, 5000000.0);
            child2.EBH_ContractApprovalMatrix__c = matrixRecordFR.Id;
            insert new List<EBH_ContractApprovalHierarchy__c>{child1,child2};

            cusettingTrigger.EBH_ExecuteContractUpdateBatch__c = false;
            update cusettingTrigger;

            child1.EBH_Threshold__c = 3000000.0;
            update child1;

        Test.stopTest();

    }

}