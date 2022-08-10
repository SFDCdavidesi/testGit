/*********************************************************************************************************************************
@ Class:         BatchDealVerifyStatement
@ Version:       1.0
@ Author:        Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:       EPH-8050 Verify Statement Work Flow Rule is not working
@				moved from workflow to dail scheduler (formula fields does not trigger!)				 
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 04.09.2019 / Vadhanak Voun / Created the class.
@ Change history: 06.06.2022 / Sophal Noch / US-0011771 - Updating Deals to "Verify Statement" Batch
*********************************************************************************************************************************/
global without sharing class BatchDealVerifyStatement implements Database.Batchable<SObject>, Schedulable{
	private Set<String> setStatusInclude = new Set<String>{EBH_ConstantsUtility.DEAL_STATUS_EXEC};
				
	private String soqlDeal = EBH_ConstantsUtility.SOQL_DEAL;
	
	@testVisible
	// private String sWhere = ' Where NumberOfDaysSinceDealEnd__c=32 AND EBH_Status__c IN:setStatusInclude AND EBH_SubsidyFinal__c >0 ';
    private String sWhere = ' Where NumberOfDaysSinceDealEnd__c >= 32 AND EBH_Status__c IN:setStatusInclude AND EBH_SubsidyFinal__c >0 '; // 06.06.2022 / Sophal Noch / US-0011771
    
    
    private String dealId;
    public BatchDealVerifyStatement()
    {
    }
    
    //testigng purpose
	public BatchDealVerifyStatement(String dealId)
    {
    	this.dealId = dealId;
    	sWhere += ' And Id =:dealId';
    }
	
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(soqlDeal+sWhere);
    }

    global void execute(Database.BatchableContext pBc, List<EBH_Deal__c> scope){

        try 
        {
    		for (EBH_Deal__c d : scope) 
		    { 
		         d.EBH_Status__c = EBH_ConstantsUtility.DEAL_STATUS_VERIFY;
		        
		    }
    		update scope;
        		
        }catch (Exception ex) {
            EBH_ApexLogger.logError(new List<Exception> { ex }, 'BatchDealVerifyStatement','execute');
        }
    }

    global void finish(Database.BatchableContext pBc){

    }
    global void execute(SchedulableContext sc) { 
        BatchDealVerifyStatement b = new BatchDealVerifyStatement();
        Database.executeBatch(b);
    }
    
    
}