trigger BatchJobRunnerTrigger on Batch_Job_Runner__c (before insert) {
	 if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            BatchJobRunnerTriggerHandler.checkCreateBatchJob(trigger.new);
        }
    }

}