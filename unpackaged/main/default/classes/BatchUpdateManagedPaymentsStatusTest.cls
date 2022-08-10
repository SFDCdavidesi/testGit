/*********************************************************************************************************************************
@ Class:            BatchUpdateManagedPaymentsStatusTest
@ Version:          1.0
@ Author:           Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:          US-0007611 Test class for: BatchUpdateManagedPaymentsStatus
@				 
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 25.05.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / Created the class.
----------------------------------------------------------------------------------------------------------------------------------
@ Class:            BatchUpdateManagedPaymentsStatusTest
@ Version:          2.0
@ Author:           Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:          US-0007888 new method testUpdateManagedPaymentStatusFieldViaBatchIfProjectStageAlreadyIsPreboarded		 
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 30.07.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / Created the method.
*********************************************************************************************************************************/

@isTest
private class BatchUpdateManagedPaymentsStatusTest {

    static EBH_Project__c projectPreboarded;
    static EBH_Project__c projectOnboarded;
    static EBH_Project__c projectNoStage;

    private static void initData(){


        Account customerSellerOne = new Account(
            Name='Seller One', 
            RecordTypeId=BatchUpdateManagedPaymentsStatus.CUSTOMER_SELLER_RECORDTYPE_ID,
            Managed_Payments_Status__c = BatchUpdateManagedPaymentsStatus.PREBOARDED_STATUS
        );

        Account customerSellerTwo = new Account(
            Name='Seller Two', 
            RecordTypeId=BatchUpdateManagedPaymentsStatus.CUSTOMER_SELLER_RECORDTYPE_ID,
            Managed_Payments_Status__c = BatchUpdateManagedPaymentsStatus.ONBOARDED_STATUS
        );

        Account customerSellerThree = new Account(
            Name='Seller Three', 
            RecordTypeId=BatchUpdateManagedPaymentsStatus.CUSTOMER_SELLER_RECORDTYPE_ID
        );

        insert new List<Account>{customerSellerOne,customerSellerTwo,customerSellerThree};

        projectPreboarded = new EBH_Project__c(
            Name = 'Project Preboarded', 
            RecordTypeId = BatchUpdateManagedPaymentsStatus.PROJECT_MANAGED_PAYMENT_RECORDTYPE_ID,
            EBH_Seller__c = customerSellerOne.Id
        );

        projectOnboarded = new EBH_Project__c(
            Name = 'Project Onboarded', 
            RecordTypeId = BatchUpdateManagedPaymentsStatus.PROJECT_MANAGED_PAYMENT_RECORDTYPE_ID,
            EBH_Seller__c = customerSellerTwo.Id
        );

        projectNoStage = new EBH_Project__c(
            Name = 'Project No Stage', 
            RecordTypeId = BatchUpdateManagedPaymentsStatus.PROJECT_MANAGED_PAYMENT_RECORDTYPE_ID,
            EBH_Seller__c = customerSellerThree.Id
        );


        insert new List<EBH_Project__c>{projectPreboarded,projectOnboarded,projectNoStage};
    }

    static testMethod void testUpdateManagedPaymentStatusFieldViaBatch() {

        initData();

        Test.startTest();
            Database.executeBatch(new BatchUpdateManagedPaymentsStatus());
        Test.stopTest();

        List<EBH_Project__c> queriedProject = [SELECT Id, Name, EBH_Stage__c From EBH_Project__c];
        System.assertEquals(3,queriedProject.size());
         
        // note: assert equals for project 1 and 2
        // project 1 and 2 lookup to customer that have Managed_Payments_Status__c IN ('Preboarded','Onboarded')

        System.assertEquals(BatchUpdateManagedPaymentsStatus.PREBOARDED_STATUS, queriedProject[0].EBH_Stage__c);

        System.assertEquals(BatchUpdateManagedPaymentsStatus.ONBOARDED_STATUS, queriedProject[1].EBH_Stage__c);

        // note: assert not equals for project 3
        // project 3 lookup to customer that have Managed_Payments_Status__c NOT IN ('Preboarded','Onboarded')

        System.assertNotEquals(BatchUpdateManagedPaymentsStatus.PREBOARDED_STATUS, queriedProject[2].EBH_Stage__c);

        System.assertNotEquals(BatchUpdateManagedPaymentsStatus.ONBOARDED_STATUS, queriedProject[2].EBH_Stage__c);
        
    


    }

    static testMethod void testUpdateManagedPaymentStatusFieldViaSchedule() {

        initData();

        Test.startTest();   
            String sch = '0 0 23 * * ?';
            System.schedule('Test check', sch, new BatchUpdateManagedPaymentsStatus());
        Test.stopTest();
    
    }

    static testMethod void testUpdateManagedPaymentStatusFieldViaBatchIfProjectStageAlreadyIsPreboarded() {

        initData();

        projectOnboarded.EBH_Stage__c = BatchUpdateManagedPaymentsStatus.PREBOARDED_STATUS;
        update projectOnboarded;

        Test.startTest();
            Database.executeBatch(new BatchUpdateManagedPaymentsStatus());
        Test.stopTest();

        List<EBH_Project__c> queriedProject = [SELECT Id, Name, EBH_Stage__c From EBH_Project__c Where Id =: projectOnboarded.Id];
         
        System.assertEquals(BatchUpdateManagedPaymentsStatus.ONBOARDED_STATUS, queriedProject[0].EBH_Stage__c);



    }


}