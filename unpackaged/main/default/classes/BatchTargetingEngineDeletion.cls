/*********************************************************************************************************************************
@ Class:         BatchTargetingEngineDeletion
@ Version:       1.0
@ Author:        Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:       EPH-6898 Target Engine - Deletion of redundant targetlists
@				AC2) Create weekly batch job in HIVE that will delete a targetlists that matches following criteria EBH_TE_Expiration_Date__c < CURRENT_DATE
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 09.01.2019 / Vadhanak Voun (vadhanak.voun@gaea-sys.com) / Created the class.
*********************************************************************************************************************************/
global without sharing class BatchTargetingEngineDeletion implements Database.Batchable<SObject>,Schedulable{
    
    String soql_where = ' WHERE EBH_TE_Expiration_Date__c < TODAY';
    public BatchTargetingEngineDeletion()
    {
    	
    }
    
    global Database.querylocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(EBH_ConstantsUtility.SOQL_TARGETING_ENGINE+soql_where);
    }
    
    global void execute(Database.BatchableContext bc,List<SObject> scope)
    {
       try 
       {
             delete scope;
             
		}catch(Exception ex) {
			system.debug(ex);EBH_ApexLogger.logError(new List<Exception> { ex }, 'BatchTargetingEngineDeletion', 'execute');
		} 
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
    //for scheduler
    global void execute(SchedulableContext ctx){
    	BatchTargetingEngineDeletion bTEDelete = new BatchTargetingEngineDeletion();
    	Database.executeBatch(bTEDelete);
    }
    
}