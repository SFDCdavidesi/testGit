/*********************************************************************************************************************************
@ Class:         AccountManagementController
@ Version:       1.0
@ Author:       Trigg
@ Purpose:        
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 21.12.2021 / vadhanak.voun (vadhanak.voun@gaea-sys.com) / US-0010561 - [AM] Store Account Manager Subscription Requests in Hive
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 23.12.2021 / Mony Nou (mony.nou@gaea-sys.com) / US-0010562 - [AM] Display account manager details in portal for subscribed & Platinum sellers
*********************************************************************************************************************************/
public with sharing class AccountManagementController {
    private final static String STATUS_NEW = 'New';
 
    private final static String COHORTSELLER_RT_MANAGED = 'Managed'; //MN-23122021-US-0010562
    private final static String STATUS_SUBSCRIBED = 'Subscribed';
    private final static String STATUS_UNSUBSCRIBE_REQUEST = 'Unsubscribe Request';

    @AuraEnabled(cacheable=true) 
        public static Account getStoreSubscription() {
            // let currentUser=UserInfo.getUserId();
          

            System.debug('>>>>current user'+UserInfo.getUserId());
          
            Account StoreSubscription;
            list<Contact> lstAccount=[SELECT AccountId FROM Contact where Id in (SELECT ContactId FROM User where id=:UserInfo.getUserId())];
           if(lstAccount.size()>0)
           {
               StoreSubscription= [SELECT EBH_StoreSubscription__c FROM Account where Id=:lstAccount[0].AccountId];
           }
           return StoreSubscription;
        }

        @AuraEnabled(cacheable=true) 
        public static Account getAccountName() { 
            
            // let currentUser=UserInfo.getUserId();
            //User.Contact.Account.Name

            System.debug('>>>>current user'+UserInfo.getUserId());
             
            Account AccountName;
            list<Contact> lstAccount=[SELECT AccountId FROM Contact where Id in (SELECT ContactId FROM User where id=:UserInfo.getUserId())];
           if(lstAccount.size()>0)
           {
            AccountName= [SELECT  Name FROM Account where Id=:lstAccount[0].AccountId];
           }
           return AccountName;
           

         
        } 
    /*****************************************************************************************************************************
    @ Method:   createSubscription
    @ Version:  1.0
    @ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:  US-0010561 - [AM] Store Account Manager Subscription Requests in Hive
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter: none
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 21.12.2021 / vadhanak.voun (vadhanak.voun@gaea-sys.com) / US-0010561 - [AM] Store Account Manager Subscription Requests in Hive
    *****************************************************************************************************************************/
    @AuraEnabled(cacheable=true) 
    public static Map<String,Object> getSellerInfo() 
    {
        Map<String,Object> mapResult = new Map<String,Object>();

        User currentUser = [Select Id,ContactId,Contact.Account.Name, Contact.AccountId,Contact.Account.EBH_StoreSubscription__c From User Where Id=:UserInfo.getUserId()];

        Map<String,Object> mapParam = new Map<String,Object>{
            'Seller__c='=>currentUser.Contact.AccountId
        };
        String soqlSubscription = 'Select Id,Status__c FROM Subscription_Request__c ';
        String sWhere = ' WHERE Seller__c='+ ApexUtil.closeSQoute(currentUser.Contact.AccountId);
        Sobject[] ex_request = WithoutSharing.doQuery(soqlSubscription, sWhere, ' ORDER BY CreatedDate DESC LIMIT 1');
        mapResult.put('account',currentUser.Contact.Account);
        mapResult.put('subscription',ex_request);

        return mapResult;
    }

    /*****************************************************************************************************************************
    @ Method:   getActiveCohortSeller
    @ Version:  1.0
    @ Author:   Mony Nou (mony.nou@gaea-sys.com)
    @ Purpose:  US-0010562 - [AM] Display account manager details in portal for subscribed & Platinum sellers
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter: none
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 23.12.2021 / Mony Nou (mony.nou@gaea-sys.com) / US-0010562 - [AM] Display account manager details in portal for subscribed & Platinum sellers
    *****************************************************************************************************************************/
    @AuraEnabled(cacheable=true) 
    public static Map<String,Object> getActiveCohortSeller() {

        Map<String,Object> mapResult = new Map<String,Object>();

        User currentUser = [Select Id,ContactId,Contact.Account.Name, Contact.AccountId,Contact.Account.EBH_StoreSubscription__c From User Where Id=:UserInfo.getUserId()];

        String soqlSubscription = 'Select Initial_Cohort_Seller__r.Account_Manager__c FROM Subscription_Request__c';
        String sWhere = ' WHERE Seller__c='+ ApexUtil.closeSQoute(currentUser.Contact.AccountId) + ' AND Initial_Cohort_Seller__c != null AND Initial_Cohort_Seller__r.RecordType.DeveloperName = ' + ApexUtil.closeSQoute(COHORTSELLER_RT_MANAGED) + ' AND Initial_Cohort_Seller__r.Active__c = true AND Initial_Cohort_Seller__r.Account_Manager__c != null';
        Sobject[] ex_request = WithoutSharing.doQuery(soqlSubscription, sWhere, ' ORDER BY CreatedDate DESC LIMIT 1');

        String accMgmntId;
        
        for (Subscription_Request__c sr : (List<Subscription_Request__c>) ex_request) { accMgmntId = sr.Initial_Cohort_Seller__r.Account_Manager__c; }
        
        User accMgmntUsr = new User();
        
        if (String.isNotBlank(accMgmntId)) {
            String soqlUser = 'SELECT Id, Name, FirstName, MiddleName, LastName, Email, Phone FROM User';
            sWhere = ' WHERE Id='+ ApexUtil.closeSQoute(accMgmntId);
            ex_request = WithoutSharing.doQuery(soqlUser, sWhere, '');

            if (!ex_request.isEmpty()) accMgmntUsr = (User)  ex_request[0];
        }
        
        mapResult.put('accountMgmtInfo',accMgmntUsr);

        return mapResult;

    }


    /*****************************************************************************************************************************
    @ Method:   createSubscription
    @ Version:  1.0
    @ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:  US-0010561 - [AM] Store Account Manager Subscription Requests in Hive
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter: none
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 21.12.2021 / vadhanak.voun (vadhanak.voun@gaea-sys.com) / US-0010561 - [AM] Store Account Manager Subscription Requests in Hive
    *****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> createSubscription() 
    {
        Map<String,Object> mapResult = new Map<String,Object>{'status'=>'ok'};

        RecordType rt_AM = ApexUtil.getRecordTypeByName('Subscription_Request__c', 'Account_Manager');
        User currentUser = [Select ContactId,Contact.AccountId From User Where Id=:UserInfo.getUserId()];
        Subscription_Request__c s_request = new Subscription_Request__c
        (
            Request_Date__c =  Date.today(),
            Opt_In_Effective_Date__c = Date.today().addMonths(1).toStartOfMonth(),    //is set to the first day of the next calendar month            
            Status__c = STATUS_NEW,
            Requestor__c = currentUser.ContactId ,
            Seller__c = currentUser.Contact.AccountId,
            CurrencyIsoCode = 'EUR',
            RecordTypeId  = rt_AM.Id

        );
        
        try 
        {
            WithoutSharing.doInsert(new List<SObject>{s_request});
            mapResult.put('recordId',s_request.Id);
        }catch(DmlException dex)
        {
            mapResult.put('status','ko'); mapResult.put('error',dex.getDmlMessage(0)); mapResult.put('error_detail',dex.getMessage());
        }
        return mapResult;
    }

      /*****************************************************************************************************************************
    @ Method:   requestUnsubscription
    @ Version:  1.0
    @ Author:   Loumang SENG (loumang.seng@gaea-sys.com)
    @ Purpose:  
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter: none
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 24.12.2021 / Loumang SENG (loumang.seng@gaea-sys.com) / US-0010562 - [AM] Display account manager details in portal for subscribed & Platinum sellers
    *****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> requestUnsubscription() {
        Map<String,Object>  mapResult = new Map<String,Object>();
        try 
        {
            
            RecordType rt_AM = ApexUtil.getRecordTypeByName('Subscription_Request__c', 'Account_Manager');
            User currentUser = [Select ContactId,Contact.AccountId From User Where Id=:UserInfo.getUserId()];
            List<Subscription_Request__c> listSubscription = [SELECT Id,Earliest_Unsubscribe_Date__c,Opt_Out_Date__c,Opt_Out_Effective_Date__c,Status__c FROM Subscription_Request__c WHERE Status__c=:STATUS_SUBSCRIBED AND RecordTypeId=:rt_AM.Id AND Seller__c =: currentUser.Contact.AccountId];
            Date currentDate = Date.today();
            for (Subscription_Request__c sr : listSubscription) {

                if(sr.Earliest_Unsubscribe_Date__c < Date.today() && sr.Earliest_Unsubscribe_Date__c != null){

                    sr.Opt_Out_Effective_Date__c = currentDate.addMonths(2).toStartOfMonth().addDays(-1);
                    
                }else{
                    sr.Opt_Out_Effective_Date__c = sr.Earliest_Unsubscribe_Date__c;
                }
                sr.Status__c = STATUS_UNSUBSCRIBE_REQUEST;
                sr.Opt_Out_Date__c = currentDate;
                

            }
            WithoutSharing.doUpdate(listSubscription);
            mapResult.put('status','ok');
        }catch(DmlException dex)
        {
            mapResult.put('status','ko'); mapResult.put('error',dex.getDmlMessage(0)); mapResult.put('error_detail',dex.getMessage());
        }
        return mapResult;

    }
}