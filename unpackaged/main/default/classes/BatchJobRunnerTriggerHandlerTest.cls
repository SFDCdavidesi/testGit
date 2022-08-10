@isTest
private class BatchJobRunnerTriggerHandlerTest {
     static testMethod void insertBatchJobRunnerTest() {
         List<Batch_Job_Runner__c> batchJobs = [Select Id, Name, Job_Purpose__c, Status_detail__c, Job_Status__c, Batch_Name__c From Batch_Job_Runner__c ];
         Test.startTest();
         //BatchJobRunnerTriggerHandler.insertBatchJobRunner(batchJobs);
         Test.stopTest();
     }

}