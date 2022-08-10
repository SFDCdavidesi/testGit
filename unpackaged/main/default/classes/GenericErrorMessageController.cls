/*********************************************************************************************************************************
@ Class:        GenericErrorMessageController
@ Version:      1.0
@ Author:       Mony Nou (mony.nou@gaea-sys.com)
@ Purpose:      Controller for lwcGenericErrorMessage  
@              
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 25.04.2022 / mony nou / Created the class.
*********************************************************************************************************************************/
public with sharing class GenericErrorMessageController {
    
    private final static String SPDEAL_FULLACCESS = 'Full Access';

    /*********************************************************************************************************************************
    @ method:       validateAllLinkedAccounts
    @ Version:      1.0
    @ Author:       Mony Nou (mony.nou@gaea-sys.com)
    @ Purpose:     US-0011156 - Restrict ability for Sellers to be able to create Deals - Linked Account
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 25.04.2022 / Mony Nou / Created the method.
    *********************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> validateAllLinkedAccounts()
    {
        
        User currentUser = [Select Id,UserName,Email,ContactId,Contact.RecordType.DeveloperName,Contact.AccountId,Contact.Account.OwnerId,Federated_Login__c From User Where Id=:UserInfo.getUserId()];
        
        Map<String,AccountContactRelation> mapRelation = new Map<String,AccountContactRelation>();

        String sQuery = 'Select Id,AccountId,Account.SP_Deals__c From AccountContactRelation';
        String sWhere = ' Where Account.RecordType.DeveloperName =\'EBH_Seller\' and ContactId=\'' + currentUser.ContactId + '\'' ;

        Boolean spDealFullAccess = false;
        String spDealVal = '';
        for(AccountContactRelation acr : (List<AccountContactRelation>) WithoutSharing.doQuery(sQuery, sWhere, '')) {
            //mapRelation.put(acr.AccountId,acr);
            spDealFullAccess = spDealFullAccess || (acr.Account.SP_Deals__c == SPDEAL_FULLACCESS);
            if (acr.AccountId == currentUser.Contact.AccountId) spDealVal = acr.Account.SP_Deals__c;
        }

        Map<String,Object> result = new Map<String,Object> ();
        
        if (spDealFullAccess) result.put('spDealFullAccess',true);
            
        result.put('spDeal', spDealVal);

        return result;
    }

}