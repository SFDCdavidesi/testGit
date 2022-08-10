public without sharing class CustomDealController {   


    private static final string DRC_STANDARD_COMPAIGN = 'Deal_Campaign_V1';
    private static final String SITE_DE = '77';
    private static final string FULL_ACCESS = 'Full Access';

    @AuraEnabled(cacheable=true)
    public static String getAccountIdUser() {
        try {           
          
            List<Contact> lstCons = [SELECT AccountId, Id FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id =:UserInfo.getUserID())];

            List<Account> lstDefaultAcc = [SELECT Id FROM Account WHERE Name = 'Trigg Digital Ltd' LIMIT 1]; 

            return (!lstCons.isEmpty()) ? lstCons[0].AccountId : lstDefaultAcc[0].Id; // fixed Id of account Trigg Digital Ltd use as default on sandbox   
            
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }

    }

    @AuraEnabled(cacheable=true)
    public static String initData() {       

            Map<String, String> mapRes = new Map<String, String>();
          
            List<Contact> lstCons = [SELECT AccountId, Id, Email FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id =:UserInfo.getUserID())];

            List<Account> lstDefaultAcc = [SELECT Id FROM Account WHERE Name = 'Trigg Digital Ltd' LIMIT 1];

            List<User> lstIntegUser = [SELECT Id FROM User WHERE Name = 'Integration User'];
            // map integration user
            mapRes.put('intUser', (!lstIntegUser.isEmpty()) ? lstIntegUser[0].Id : '');

            // map contact id
            String conId = (lstCons.isEmpty()) ? '' : lstCons[0].Id ;
            mapRes.put('contactId', conId);
            String email = (lstCons.isEmpty()) ? '' : lstCons[0].Email ;
            mapRes.put('email', email);
            // map account Id
            mapRes.put('accountId', (!lstCons.isEmpty()) ? lstCons[0].AccountId : lstDefaultAcc[0].Id);  // fixed Id of account Trigg Digital Ltd use as default on sandbox      

            System.debug('mapRes >>> '+mapRes);
            
            return JSON.serialize(mapRes); 
       
    }


    @AuraEnabled(cacheable=true)
   public static List<EBH_Deal__c> getExistingDeals(String searchKey, String sortedBy, String sortedDirection) {
    try {
    
       String query = 'SELECT Id, Name, EBH_ProductTitle__c, EBH_eBayItemID__c FROM EBH_Deal__c';
      
       if ( String.isNotBlank(searchKey)) {
           String key = '%' + searchKey + '%';
           query += ' WHERE EBH_ProductTitle__c LIKE :key';
       }
       if ( sortedBy != null && sortedDirection != null ) {
           query += ' ORDER BY ' + sortedBy + ' ' + sortedDirection;
       }

       query += ' LIMIT 5';
       system.debug('query---'+query);
    
       return Database.query( query );    
       
    } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
   }
   

     /***********************************************************************************************************************************
    @ Method:       apexUpdateDeal 
    @ Version:      1.0
    @ Author:       Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:      US-0010560 - [SP - EU Deals] Allow sellers to edit specific deal fields post deal rejection
    @ Parameter:    deal
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Returns  map result
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 11.11.2021 / Vadhanak Voun / Created the Method.
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 21.02.2022 / Mony Nou / US-0011309 - Missing Item-ID: To-Do list and List Views 
                                                - So that we can reuse this method for Enter eBay Item ID as well
    ***********************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> apexUpdateDeal(EBH_Deal__c deal, Boolean isEnterEID) 
    { 
        Map<String,Object>  mapResult = new Map<String,Object>();
       try
       {    
            if (!isEnterEID) {
                deal.EBH_Status__c = 'New';
                deal.EBH_ReasonforRejection__c = null;
            }
            
            update deal;
             
            mapResult.put('status','ok');

       }catch(DmlException dex)
       {
            mapResult.put('status','ko'); mapResult.put('error',dex.getDmlMessage(0));mapResult.put('error_detail',dex.getStackTraceString());
       }

       return mapResult;
    }
    
    /*****************************************************************************************************************************
    @ Method:         getTodayDealSetting
    @ Version:        1.0
    @ Author:          
    @ Purpose:        US-0010733 - [SP - EU Deals] [Bug] Single Deal Form should not allow 
                                    submit when seller has reached daily or DRC limit
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String dealReatilCampaingId
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 29-11-2021 /Loumang SENG/ Created the  Method.
    *****************************************************************************************************************************/
    @AuraEnabled
    public static Object getTodayDealSetting(String dealReatilCampaingId){
        Map<String, Object> mResult = new Map<String, Object>();
        mResult.put('status', 'error');
        try{ mResult = ClsBulkUploadCSV.getTodayDealSetting(dealReatilCampaingId);}catch(Exception ex) {mResult.put('message', ex.getMessage());} return mResult;  
    }


    /*****************************************************************************************************************************
    @ Method:         getTodayDEDealSetting
    @ Version:        1.0
    @ Author:          
    @ Purpose:        US-0010950 - Account Selection field on Deal Creation/List Views
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String dealReatilCampaingId
    @ Parameter:      String accountId
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 29-04-2022 /Mony Nou/ Created the  Method.
    *****************************************************************************************************************************/
    @AuraEnabled
    public static Object getTodayDEDealSetting(String dealReatilCampaingId, String accountId){
        Map<String, Object> mResult = new Map<String, Object>();
        mResult.put('status', 'error');
        if (String.isNotBlank(accountId)) ClsBulkUploadCSV.eligibleAccountId = accountId;
        try{ mResult = ClsBulkUploadCSV.getTodayDealSetting(dealReatilCampaingId);}catch(Exception ex) {mResult.put('message', ex.getMessage());} return mResult;  
    }

    /*****************************************************************************************************************************
    @ Method:         getDuplicateEbayItemID
    @ Version:        1.0
    @ Author:         SRONG TIN 
    @ Purpose:        US-0011338 - System allowing Deals with same item ID & overlapping dates
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String dealReatilCampaingId, Integer eBayItemId
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 14-03-2022 /SRONG TING/ Created the  Method.
    *****************************************************************************************************************************/
    @AuraEnabled
    public static Object getDuplicateEbayItemID(String dealReatilCampaingId,String eBayItemId){
        Map<String, Object> mResult = new Map<String, Object>();
        Id drcRecordTypeId = Schema.SObjectType.EBH_DealRetailCampaign__c.getRecordTypeInfosByDeveloperName().get(DRC_STANDARD_COMPAIGN).getRecordTypeId();
        mResult.put('status', 'error');
        List<EBH_Deal__c> deals = new List<EBH_Deal__c>();
        try{ 
            
            List<EBH_Deal__c> lstDeals = [Select Id from EBH_Deal__c where EBH_eBayItemID__c = :eBayItemId and ( EBH_DealRetailCampaign__c = :dealReatilCampaingId and EBH_DealRetailCampaign__r.RecordTypeId = :drcRecordTypeId and EBH_DealRetailCampaign__r.EBH_Country__c = :SITE_DE ) and EBH_Status__c NOT IN ('Rejected') LIMIT 1];
            mResult.put('deals', lstDeals);
            mResult.put('status', 'success');

        }catch(Exception ex) {
            mResult.put('message', ex.getMessage());
        } 
        
        return mResult;  
    }

    /*****************************************************************************************************************************
    @ Method:         getSelectedCategories
    @ Version:        1.0
    @ Author:         Sambath Seng 
    @ Purpose:        US-0010766 - [SP - EU Deals] EAN is required for specific Category
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 13-12-2021 /Sambath SENG/ Created the  Method.
    *****************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<String> getSelectedCategories(){
        Seller_Portal_Global_Variables__mdt spMdt = [SELECT DeveloperName, Value_Big__c FROM Seller_Portal_Global_Variables__mdt WHERE DeveloperName = 'Deal_Selected_Categories'];
        return String.isNotBlank(spMdt.Value_Big__c) ? spMdt.Value_Big__c.split(';') : new List<String>();
    }

    /*****************************************************************************************************************************
    @ Method:         getLinkedAccSpDeal
    @ Version:        1.0
    @ Author:         Sophal Noch
    @ Purpose:        US-0011156 - Restrict ability for Sellers to be able to create Deals - Linked Account
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 03.05.2022 /Sophal Noch/ Created the  Method.
    *****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> getLinkedAccSpDeal(){
        Map<String, Object> mResult = new Map<String, Object>();
        try{
            mResult.put('status', 'ok');
            Boolean isHavingNoFullAccess = true;
            RecordType recSeller = ApexUtil.getRecordTypeByName('Account', 'EBH_Seller');
            User cUser = [Select Id,Profile.Name,ContactId, Contact.AccountId, Contact.Account.Id, Contact.Account.SP_Deals__c From User Where Id=:UserInfo.getUserId()];
            Map<Id,Account> mapAcc = new Map<Id,Account>();
            for(AccountContactRelation acr : [Select Id,AccountId,Account.Id,Account.Name, Account.SP_Deals__c From AccountContactRelation Where Account.RecordTypeId =:recSeller.Id And ContactId =: cUser.ContactId]){
                mapAcc.put(acr.AccountId, acr.Account);
                if(isHavingNoFullAccess && acr.Account.SP_Deals__c == FULL_ACCESS){isHavingNoFullAccess = false;}
            }
            mResult.put('profileName', cUser.Profile.Name);
            mResult.put('mapAcc', mapAcc);
            mResult.put('isHavingNoFullAccess', isHavingNoFullAccess);
        }catch(Exception e){mResult.put('status', 'ko');mResult.put('error', e.getMessage());}

        return mResult;
    }
}