/*********************************************************************************************************************************
@ Class:         BatchJobRunnerTriggerHandler
@ Version:       1.0
@ Author:        Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:       US-0009430 Batch Jobs controll object
                Create a custom object, visible for System Admin only and use it to trigger batch jobs.
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 02.10.2019 / Vadhanak Voun (vadhanak.voun@gaea-sys.com) / Created the class.
*********************************************************************************************************************************/
public without sharing class BatchJobRunnerTriggerHandler {
	
	
	/*****************************************************************************************************************************
    @ Method:       checkCreateBatchJob
    @ Version:      1.0
    @ Author:       Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:      check availability if we prodided batchclass can be executed   
	@ Event			Before Insert 
    ------------------------------------------------_------------------------------------------------------------------------------
    @ Change history: 02.10.2019 / Vadhanak Voun (vadhanak.voun@gaea-sys.com)/ Created the method.
    ****************************************************************************************************************************/
	public static void checkCreateBatchJob(List<Batch_Job_Runner__c> listNew)
	{
		if(listNew.size() >1)
		{
			listNew[0].addError('Sorry, but JOB Runner currently not support mass operation. Please reduce to 1 record.');return;
		}
		List<Batch_Job_Runner__c> listJob = new List<Batch_Job_Runner__c>();
		Set<String> setBatchNames = new Set<String>();
		for(Batch_Job_Runner__c batchJob : listNew)
		{
		    if(batchJob.Job_Status__c == EBH_ConstantsUtility.JOB_STATUS_NEW  )
		    {
		    	listJob.add(batchJob);
		    	setBatchNames.add(batchJob.Batch_Name__c);
		    }
		    batchJob.Ext_Id__c = ApexUtil.genUniqueString(20);
		}
		if(!listJob.isEmpty())
		{
			Map<String,Integer> mapCountCurrentBatch = ApexUtil.countRunningBatch(setBatchNames);
			for(Batch_Job_Runner__c runner : listJob)
			{
				Integer currentJobCount = mapCountCurrentBatch.get(runner.Batch_Name__c);
				//system.debug('-------currentJobCount: ' +currentJobCount);
				if(currentJobCount >= 1)
				{
					runner.Job_Status__c = EBH_ConstantsUtility.JOB_STATUS_NOTSTART;
					runner.Status_detail__c = 'Another job already in progress: '+currentJobCount;
				}else
				{
					//make sure the batch class is properly aligned to work with this feature
					if(runner.Batch_Name__c=='BatchCalculateSellerToProduct')
					{
						executeBatchByName('BatchCalculateSellerToProduct',runner.Ext_Id__c);
						 
					}else
					{
						runner.Job_Status__c = EBH_ConstantsUtility.JOB_STATUS_NOTSTART;
						runner.Status_detail__c = 'Batch Name is not defined.';
					}
				}
			}
		}
	}
	
	private static void executeBatchByName(String batchName,String extId)
	{
		((IBatchExecutor)Type.forName(batchName).newInstance()).runBatch(extId);
	}
}