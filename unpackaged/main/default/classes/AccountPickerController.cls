/*********************************************************************************************************************************
@ Class:        AccountPickerController
@ Version:      1.0
@ Author:       Mony Nou (mony.nou@gaea-sys.com)
@ Purpose:      Controller for lwcAccountPicker  
@               US-0010950 - Account Selection field on Deal Creation/List Views
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 26.04.2022 / mony nou / Created the class.
@               : 14.06.2022 / SRONG TIN / US-0011345 AC7
*********************************************************************************************************************************/
public with sharing class AccountPickerController {
    
    private static final String ELIGIBLE_FOR_DE_DEALS = 'Eligible_for_DE_Deals_Full_Access';
    private static final String ELIGIBLE_FOR_COUPONS = 'Eligible_for_Coupons_Full_Access';//SRONG TIN/14.06.2022/US-0011345

    /*********************************************************************************************************************************
    @ method:       getDEEligibleAccounts
    @ Version:      1.0
    @ Author:       Mony Nou (mony.nou@gaea-sys.com)
    @ Purpose:      US-0010950 - Account Selection field on Deal Creation/List Views
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 26.04.2022 / Mony Nou / Created the method.
    @               : 14.06.2022 / SRONG TIN / US-0011345 AC7
    *********************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> getDEEligibleAccounts()
    {
        //SRONG TIN/14.06.2022/US-0011345 AC7
        Set<String> ELIGIBLE = new Set<String>{ELIGIBLE_FOR_DE_DEALS,ELIGIBLE_FOR_COUPONS};

        List<Seller_Portal_Setting__mdt> meta = [Select Id,DeveloperName,Filter_Values__c from Seller_Portal_Setting__mdt where DeveloperName  IN:ELIGIBLE];

        User currentUser = [Select Id,UserName,Email,ContactId,Contact.RecordType.DeveloperName,Contact.AccountId,Contact.Account.OwnerId,Federated_Login__c From User Where Id=:UserInfo.getUserId()];
        
        Map<String,AccountContactRelation> mapRelation = new Map<String,AccountContactRelation>();
        Map<String,AccountContactRelation> mapRelationDeals = new Map<String,AccountContactRelation>();
        Map<String,AccountContactRelation> mapRelationCoupons = new Map<String,AccountContactRelation>();
        //SRONG TIN/14.06.2022/US-0011345 AC7
        String sFilter = meta[0].Filter_Values__c + ' OR ' +meta[1].Filter_Values__c;
        String sQuery = 'Select Id,AccountId,Account.Name,Account.SP_Coupons__c,Account.SP_Deals__c,Contact.Name,Contact.Email,ContactId,IsActive From AccountContactRelation';
        String sWhere = ' Where Account.RecordType.DeveloperName =\'EBH_Seller\' and ContactId=\'' + currentUser.ContactId + '\'' ;
        sWhere += ' AND AccountId IN (SELECT Id FROM Account WHERE '+ sFilter +')';

        for(AccountContactRelation acr : (List<AccountContactRelation>) Database.query(sQuery + sWhere)) {
            
            if(acr.Account.SP_Coupons__c == 'Full Access'){mapRelationCoupons.put(acr.AccountId,acr);}
            if(acr.Account.SP_Deals__c == 'Full Access'){mapRelationDeals.put(acr.AccountId,acr);}
            mapRelation.put(acr.AccountId,acr);
        }
        return new Map<String,Object> {'curentUser'=>currentUser,'accRelation'=>mapRelationDeals.values(),'accRelationCoupons'=>mapRelationCoupons.values(),'accRelationAll'=>mapRelation.values()};
    }

}