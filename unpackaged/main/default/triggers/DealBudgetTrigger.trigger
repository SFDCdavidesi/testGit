/*********************************************************************************************************************************
@ Class:        DealBudgetTriggerHandler
@ Version:      1.0
@ Author:       Sreymeas Nao (sreymeas.nao@gaea-sys.com)
@ Purpose:      Deal Budget Month Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 18.06.2019 / Sreymeas Nao / Created the trigger.
*********************************************************************************************************************************/

trigger DealBudgetTrigger on EBH_DealsBudget__c (after insert, after update) {
    
    if(trigger.isInsert){
    	DealBudgetTriggerHandler.createDealBudgetMonth(trigger.new);
    }
}