/*********************************************************************************************************************************
@ Class:         BatchCalculateSellerToProduct
@ Version:       1.0
@ Author:        Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:       US-0015716 Change Trigger to Batch Job on Seller to Product
@                moved the logic from trigger 
@               Test class at still staying at SellerToProductTriggerHandlerTest
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 02.10.2019 / Vadhanak Voun (vadhanak.voun@gaea-sys.com) / Created the class.
                  19.05.2021 / Mony Nou / Retired codes / US-0009522 - [EU] [AU] Trading Engine: retire Apex
*********************************************************************************************************************************/
global without sharing class BatchCalculateSellerToProduct {
    
/* MN-19/05/2021 - US-0009522 - Retired Codes
global without sharing class BatchCalculateSellerToProduct implements Database.Batchable<SObject>, Database.Stateful,IBatchExecutor{
    
    private String soqlSTP = EBH_ConstantsUtility.SOQL_SELLER_TO_PRODUCT;
    private String sWhere = ' Where Product__c <> NULL';
    
    private String runnerId; //external id to upsert (before insert has no id)
    private Integer batchCounter = 0;
    private String errMsg = '';
    
    @TestVisible
    private List<Integer> listErrorAtBatch = new List<Integer>(); //the batch number that get error
    

    //required a non-arg constructor for IBatchExecutor
    public BatchCalculateSellerToProduct()
    {
    	
    }
    
    public BatchCalculateSellerToProduct(String runnerId)
    {
    	// this.runnerId = runnerId;
    }
    

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        
    	updateJobStatus(EBH_ConstantsUtility.JOB_STATUS_PREP);
        return Database.getQueryLocator(soqlSTP+sWhere); 
        
        
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> records){
        
    	batchCounter++;
    	if(batchCounter <=1)
    	{
    		//so we do not need to set to inprogress in every batch
    		updateJobStatus(EBH_ConstantsUtility.JOB_STATUS_PROGRESS);
    	}
    	
    	try
    	{
    		//reuse method from triggerHandler (already disabled from trigger)
    		SellerToProductTriggerHandler.calculateProductFields(records);	
    		
    	}catch(Exception ex)
    	{
    		listErrorAtBatch.add(batchCounter);
    		appandMsg(ex.getMessage());
    		
    	}
        
    } 
       
    global void finish(Database.BatchableContext bc){
    	
    	String jobStatus = '';
    	Batch_Job_Runner__c job = new Batch_Job_Runner__c(Ext_Id__c=runnerId);
        if(listErrorAtBatch.isEmpty())
        {
        	job.Job_Status__c = EBH_ConstantsUtility.JOB_STATUS_SUCCESS;
        }else
        {
        	job.Job_Status__c = EBH_ConstantsUtility.JOB_STATUS_FAILED;
        	job.Status_detail__c = 'Number of batch Error: '+listErrorAtBatch.size()+'\n'+errMsg;
        }
        
        job.Number_of_Batch__c = batchCounter;
        
    	Database.upsert(job,Batch_Job_Runner__c.Ext_Id__c,false); //partial success Ext_Id__c
        
    }    
    
    //impl
    public void runBatch(String  runnerId)
    {
    	BatchCalculateSellerToProduct batchCalSTP = new BatchCalculateSellerToProduct(runnerId);
		Database.executeBatch(batchCalSTP);
    }
    
    @TestVisible
    private void appandMsg(String msg)
    {
    	errMsg = errMsg+'\n'+msg;
    	errMsg = errMsg.length()>32500?errMsg.substring(0,32500):errMsg;
    }
    
    private void updateJobStatus(String status)
    {
    	Batch_Job_Runner__c job = new Batch_Job_Runner__c(Ext_Id__c=runnerId,Job_Status__c=status);
    	Database.upsert(job,Batch_Job_Runner__c.Ext_Id__c,false); //partial 
    }
    */
}