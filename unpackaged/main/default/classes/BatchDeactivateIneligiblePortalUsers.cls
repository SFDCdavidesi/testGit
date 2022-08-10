/*********************************************************************************************************************************
@ Class:        BatchDeactivateUsers
@ Version:      1.0
@ Author:       Chetra Sarom (chetra.sarom@gaea-sys.com)
@ Purpose:      EPH-5578: Auto deactivate SEP Users if their Account falls below minimum Standards for more than 30 Days
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 29.Apr.2022 / Chetra Sarom (chetra.sarom@gaea-sys.com) :US-0011530 - related tasks not visible
*********************************************************************************************************************************/
global with sharing class BatchDeactivateIneligiblePortalUsers implements Database.Batchable<SObject>,Schedulable ,Database.stateful {
    private static Set<String> SET_REVROLLUPS = new Set<String>{'US', 'CA'};
    private static Date last90Days = Date.today().addDays(-90);
    private static Decimal AmountGMVLast12Months = 48000; // 
    private static String EBH_PREDICTEDSTANDARD_ETRS = 'ETRS';
    private static String EBH_PREDICTEDSTANDARD_BELOWSTANDARD = 'Below Standard';
    private static String EBH_PREDICTEDSTANDARD_ABOVESTARDARD = 'Above Standard';
    private static String SOQL_CUSTOMER = 'SELECT id, EBH_PredictedStandard__c, EBH_VeROViolation__c, EBH_LastSellDate__c, EBH_ActualStandard__c, EBH_GMVLast12Months__c, Below_SP_Standard_Date__c, Name FROM Account' +
    ' WHERE (EBH_RevRollup__c IN: SET_REVROLLUPS OR (EBH_LastSellDate__c >: last90Days OR EBH_PredictedStandard__c !=: EBH_PREDICTEDSTANDARD_ETRS OR EBH_VeROViolation__c = true OR EBH_ActualStandard__c =: EBH_PREDICTEDSTANDARD_BELOWSTANDARD OR EBH_GMVLast12Months__c <=: AmountGMVLast12Months)'+
    ' OR (EBH_LastSellDate__c <: last90Days AND EBH_PredictedStandard__c =: EBH_PREDICTEDSTANDARD_ETRS AND EBH_VeROViolation__c = false AND (EBH_ActualStandard__c =: EBH_PREDICTEDSTANDARD_ABOVESTARDARD OR EBH_ActualStandard__c =: EBH_PREDICTEDSTANDARD_ETRS) AND EBH_GMVLast12Months__c >=: AmountGMVLast12Months))';

    private Set<Id> accountIds = new Set<Id>();
    
    public BatchDeactivateIneligiblePortalUsers(){
        
    }
    public BatchDeactivateIneligiblePortalUsers(Set <Id> accountIds) {
        this.accountIds = accountIds;
    }

    //private static Set<Id> accIds_forUpdate = new Set<Id>();
    global Database.querylocator start(Database.BatchableContext bc) {
        //System.debug('>>>> SOQL_CUSTOMER'+SOQL_CUSTOMER);
        return Database.getQueryLocator(accountIds.isEmpty() ? SOQL_CUSTOMER : SOQL_CUSTOMER + ' AND id IN: accountIds');
    }
    global void execute(Database.BatchableContext bc, List<Account> scope) {
        List<Account> lstAccount = new List<Account>();

        for(Account acc : scope){
            if ( 
                acc.EBH_LastSellDate__c > last90Days
                || acc.EBH_PredictedStandard__c != 'ETRS' 
                || acc.EBH_VeROViolation__c == true 
                || acc.EBH_ActualStandard__c == 'Below Standard' 
                || acc.EBH_GMVLast12Months__c <= AmountGMVLast12Months
            ){
                acc.Below_SP_Standards__c = true;
                acc.Below_SP_Standard_Date__c = Date.today();
            }
            
            System.debug('>>>>>>>>> EBH_ActualStandard__c '+ acc.EBH_ActualStandard__c);
            
            if ( 
                acc.EBH_LastSellDate__c < last90Days 
                && acc.EBH_PredictedStandard__c == 'ETRS' 
                && acc.EBH_VeROViolation__c == false 
                && (acc.EBH_ActualStandard__c == 'Above Standard' || acc.EBH_ActualStandard__c == 'ETRS') 
                && acc.EBH_GMVLast12Months__c >= AmountGMVLast12Months
            ){
                acc.Below_SP_Standards__c = false;
                acc.Below_SP_Standard_Date__c = NULL;
            }

            /* if (last90Days > acc.Below_SP_Standard_Date__c) {
                accIds_forUpdate.add(acc.Id);
            } */
            
            lstAccount.add(acc);
        }
        update lstAccount;
    }
    global void finish(Database.BatchableContext bc) {
        /* Set<String> portalProfile = new Set<String>{'NA - Seller Portal', 'DE - Seller Portal'};
        String SOQL_USER = 'SELECT Id, Profile.Name, Contact.Name From User Where Contact.AccountId IN: accIds_forUpdate AND Profile.Name IN: portalProfile ';
        List<User> lstUser = new List<User>();
        for(User usr : Database.query(SOQL_USER)){
            usr.isActive = false;
        }
        try {
            update lstUser;
        } catch (Exception ex) {

            //log error on exception to apex logger object
            EBH_ApexLogger.logError(new List<Exception> { ex }, 
            'BatchDeactivateIneligiblePortalUsers', 'finish');
        } */

        
    }
    
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchDeactivateIneligiblePortalUsers());
    }
}