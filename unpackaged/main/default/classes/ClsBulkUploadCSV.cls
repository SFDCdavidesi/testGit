/*********************************************************************************************************************************
@ Class:          ClsBulkUploadCSV
@ Version:        1.0
@ Author:         Sochettra Saing
@ Purpose:        Ability to create multiple Deals in one time(EBAY-228)
@ ClsSubmitMultipleDealsController for LWC lwcSubmitMultipleDeals
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 20.07.2021 / Sochettra Saing / Created the class.
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 20.12.2021 / Mony Nou / US-0010730- [SP - EU Deals] [Bug] Deleted Deals not removed from recycle bin affecting daily limit count
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 21.12.2021 / Mony Nou / US-0011048 - Remove codes that try to query DRC & Deal when page on load because when page on load there is no DRC selected yet
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 17.05.2022 / Mony Nou / US-0010656 - Ability to upload/manage items to item based coupons
*********************************************************************************************************************************/
public without sharing class ClsBulkUploadCSV {
    private static String DE_pfName = 'DE - Seller Portal';
    private static final String STATUS_REJECTED = 'Rejected';
    private static final String STATUS_INVREJECTED = 'Invoice Rejected (Email resend to Seller)';

    
    /*****************************************************************************************************************************
    @ Method:         doSubmitMultipleCouponItems
    @ Version:        1.0
    @ Author:         Mony Nou
    @ Purpose:        US-0010656 - Ability to upload/manage items to item based coupons
    @                 Bulk Create Coupon Co-Inves Records
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<Coupon_Co_Invest__c> lstCPItems (Multiples Coupon Co-Invest from uploaded CSV)
    @ Parameter:      String csCouponType (Coupon Seller's Coupon Type)
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 17-05-2022 /Mony Nou/ Created the  Method.
    *****************************************************************************************************************************/
    private static Map<String, String> mCouponCoInvestRT = new Map<String, String>{
        'Item Based' => 'Coupon Co-Invest Item'
    };

    @AuraEnabled
    public static Object doSubmitMultipleCouponItems (List<Coupon_Co_Invest__c> lstCPItems, String csCouponType) {
        
        Map<String,Object> mResult = new Map<String,Object>();
        mResult.put('status', 'error');
        try{

            if (String.isNotBlank(csCouponType) && mCouponCoInvestRT.containsKey(csCouponType)) {
                Id cciRT = Schema.SObjectType.Coupon_Co_Invest__c.getRecordTypeInfosByName().get(mCouponCoInvestRT.get(csCouponType)).getRecordTypeId();
                for (Coupon_Co_Invest__c cci : lstCPItems) {
                    cci.RecordTypeId = cciRT;
                }
            } 
            
            Database.SaveResult[] srList = Database.insert(lstCPItems, false);
            mResult.put('srList', JSON.serialize(srList));
            mResult.put('message', '');
            mResult.put('status', 'success');
            mResult.put('lstCPItems', lstCPItems);
            
        } catch ( Exception ex) {
            System.debug('@@@@@messgee'+ex);
            mResult.put('message', 'Error:'+ex.getLineNumber()+':'+ ex.getMessage());
        }
        return mResult;
    }
    
    @AuraEnabled
    public static Object doSubmitMultipleDeals(List<EBH_Deal__c> lstDeals, String accountId) {
        
        Map<String,Object> mResult = new Map<String,Object>();
        mResult.put('status', 'error');
        try{
            // SRONG TIN - 17/03/2022 : US-0011338
            String dealReatilCampaingId = '';
            String currUserLang = '';
            for(User u : [SELECT Id, Profile.Name From User WHERE Id =: UserInfo.getUserID()]) {
                currUserLang = u.Profile.Name;
            }
            //insert lstDeals;
            for(EBH_Deal__c deal : lstDeals){
                deal.EBH_BusinessName__c = accountId;
                // SRONG TIN - 17/03/2022 : US-0011338
                if(currUserLang == DE_pfName){
                    if(String.isNotBlank(deal.EBH_DealRetailCampaign__c)){
                        dealReatilCampaingId = deal.EBH_DealRetailCampaign__c;
                    }
                }
            }
            // SRONG TIN - 17/03/2022 : US-0011338
            if(currUserLang == DE_pfName && String.isNotBlank(dealReatilCampaingId)){
                EBH_DealTriggerHandler.isFromBulkUpload_DE = true;
            }

            Database.SaveResult[] srList = Database.insert(lstDeals, false);
            mResult.put('srList', JSON.serialize(srList));
            mResult.put('message', 'The Deals are submitted successfully!');
            mResult.put('status', 'success');
            mResult.put('isFromBulkUpload_DE', EBH_DealTriggerHandler.isFromBulkUpload_DE);
            mResult.put('lstDeals', lstDeals);

            // Iterate through each returned result
            /*for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }*/
            
            
        } catch ( Exception ex) {
            System.debug('@@@@@messgee'+ex);
            mResult.put('message', 'Error:'+ex.getLineNumber()+':'+ ex.getMessage());
        }
        return mResult;
    }

    /*@AuraEnabled
    public static Object doClearHalfCompleteDeals(List<EBH_Deal__c> lstDeals) {
        Map<String,Object> mResult = new Map<String,Object>();
        mResult.put('status', 'error');
        try{
            delete lstDeals;
            Database.emptyRecycleBin(lstDeals);
            mResult.put('status', 'success');
            //mResult.put('lstDeals', lstDeals);
            mResult.put('message', 'The Deals are removed successfully!');
            
        } catch ( Exception ex) {
            mResult.put('message', 'Error:'+ex.getLineNumber()+':'+ ex.getMessage());
        }
        return mResult;
    }*/

    @AuraEnabled
    public static Object doLoadSetting(String dealReatilCampaingId){
        Map<String, Object> mResult = new Map<String, Object>();
        mResult.put('status', 'error');
        try{
            //LA-29-11-2021-US-0010733: commmend this code and move to method getTodayDealSetting(dealReatilCampaingId);
            /*Decimal maxDealWindow = 100; 
            String userId = '';
            String accountId = '';
            String contactId = '';
            String fullContactName = '';
            String conEmail = '';
            String currUserLang = '';
            String parentAccId = '';
            for(User u : [SELECT Id, Profile.Name, ContactId, Contact.LastName, Contact.FirstName, Contact.Email, Contact.AccountId, Contact.Account.Parent_Account_ID__c, Contact.Account.Deal_Window_Limit__c, Contact.Account.EBH_RegistrationSite__c From User WHERE Id =: UserInfo.getUserID()]) {
                userId = u.Id;
                if(u.ContactId != null) {
                    conEmail = u.Contact.Email;
                    contactId = u.ContactId;
                    fullContactName = u.Contact.FirstName+ ' ' + u.Contact.LastName ;
                }
                if(u.ContactId != null && u.Contact.AccountId != null ) {
                    maxDealWindow = u.Contact.Account.Deal_Window_Limit__c;
                    accountId = u.Contact.AccountId;
                    parentAccId = u.Contact.Account.Parent_Account_ID__c;
                    //currUserLang = u.Contact.Account.EBH_RegistrationSite__c;
                }
                if(u.ProfileId != null) {
                    currUserLang = u.Profile.Name;
                }
            }*/
            // 'a0u1F0000022jpnQAA'
            //Decimal totalDeal = [SELECT Count() FROM EBH_Deal__c WHERE EBH_DealRetailCampaign__c =: dealReatilCampaingId AND EBH_Status__c != 'Rejected'];
            //List<EBH_Deal__c> lstDeal = [SELECT EBH_eBayItemID__c FROM EBH_Deal__c WHERE EBH_DealRetailCampaign__c =: dealReatilCampaingId AND EBH_Status__c != 'Rejected'];
            mResult = getTodayDealSetting(dealReatilCampaingId);//LA-29-11-2021-US-0010733
            if(mResult.get('status') == 'error') return mResult;
            String currUserLang= (String)mResult.get('currUserLang');

            /* //MN-21122021-US-0011048 - When page is onload, user not yet select any DRC yet so there is no use to query it with NULL DRC's ID => query EVERYTHING
            String query = 'SELECT EBH_eBayItemID__c FROM EBH_Deal__c WHERE EBH_DealRetailCampaign__c =: dealReatilCampaingId AND EBH_Status__c !=: STATUS_REJECTED ';
            query += (currUserLang == DE_pfName ? ' AND EBH_DealSiteId__c = \'77\' ': '');
            System.debug('query: '+query);
            List<EBH_Deal__c> lstDeal = new List<EBH_Deal__c>();
            for(EBH_Deal__c[] deals: Database.query(query)){
                lstDeal.addAll(deals);
            }
            */
            String dd_DuplicateError = System.Label.DD_DuplicateError ;
            // mResult.put('query', query+ '   :'+ dealReatilCampaingId); //MN-21122021-US-0011048
            mResult.put('dd_DuplicateError', dd_DuplicateError); 

            // mResult.put('lstDeal', lstDeal); //MN-21122021-US-0011048 - When page is onload, user not yet select any DRC yet so there is no use to query it with NULL DRC's ID => query EVERYTHING

            /****LA-29-11-2021-US-0010733: commmend this code and move to method getTodayDealSetting(dealReatilCampaingId);***/
            //SELECT COUNT() FROM Account WHERE Name LIKE 'a%'
            //mResult.put('availableDeal', maxDealWindow - lstDeal.size());
            /* mResult.put('availableDeal', maxDealWindow - ([SELECT COUNT() FROM EBH_Deal__c WHERE EBH_DealRetailCampaign__c =: dealReatilCampaingId AND EBH_BusinessName__c =: accountId AND EBH_Status__c != 'Rejected']));
            if(currUserLang == DE_pfName) {
                mResult.put('totalDealOfDEToday', [SELECT COUNT() FROM EBH_Deal__c WHERE CreatedDate = TODAY AND EBH_BusinessName__r.Parent_Account_ID__c =: parentAccId]);
                mResult.put('fieldDependencies', ClsBulkUploadCSV.getFieldDependencies('EBH_Deal__c','EBH_DealSiteId__c','EBH_Category__c'));
            }
            mResult.put('userId', userId);
            mResult.put('accountId', accountId);
            mResult.put('contactId', contactId);
            mResult.put('fullContactName', fullContactName);
            mResult.put('conEmail', conEmail);
            mResult.put('currUserLang', currUserLang);
            mResult.put('status', 'success');*/

        } catch(Exception ex) {
            mResult.put('message', ex.getMessage());
        }
        
        return mResult;  
    }

    /*****************************************************************************************************************************
    @ Method:         doDELoadSetting
    @ Version:        1.0
    @ Author:         Mony Nou
    @ Purpose:        US-0010950 - Account Selection field on Deal Creation/List Views
    @                 Individual init function for dealBulkUploadDE
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String dealReatilCampaingId
    @ Parameter:      String accountId
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 29-11-2021 /Mony Nou/ Created the  Method.
    *****************************************************************************************************************************/
    @AuraEnabled
    public static Object doDELoadSetting(String dealReatilCampaingId, String accountId){
        Map<String, Object> mResult = new Map<String, Object>();
        mResult.put('status', 'error');
        try{
            eligibleAccountId = accountId;
            
            mResult = getTodayDealSetting(dealReatilCampaingId);
            if(mResult.get('status') == 'error') return mResult;
            String currUserLang= (String)mResult.get('currUserLang');

            String dd_DuplicateError = System.Label.DD_DuplicateError ;
            
            mResult.put('dd_DuplicateError', dd_DuplicateError); 

        } catch(Exception ex) {
            mResult.put('message', ex.getMessage());
        }
        
        return mResult;  
    }

    @AuraEnabled
    public static Object getDealRetailCampaign(String recordId){
        Map<String, Object> mResult = new Map<String, Object>();
        mResult.put('status', 'error');
        try{
            EBH_DealRetailCampaign__c dealRetailCampaign = [SELECT Id, Start_Time__c, EBH_Date__c, End_Time__c, EPH_EndDate__c, EBH_Country__c FROM EBH_DealRetailCampaign__c WHERE Id = :recordId];
            mResult.put('status', 'success');
            mResult.put('dealRetailCampaign', dealRetailCampaign);
            mResult.put('message', 'The Deal Retail Campaign was retrived successfully!');
        }
        catch(Exception ex) {
            mResult.put('message', ex.getMessage());
        }
        return mResult;  
    }

    //MN-21122021-US-0011048 - add one more param currUserLang because we move some logic m doLoadSetting() to here 
    @AuraEnabled
    public static Object getDealOverlapDateDRC(String drcId, String currUserLang){
        Map<String, Object> mResult = new Map<String, Object>();
        mResult.put('status', 'error');
        try{
            Date startDate;
            Date endDate;
            for(EBH_DealRetailCampaign__c drc : [SELECT Id, Start_Time__c, EBH_Date__c, End_Time__c, EPH_EndDate__c, EBH_Country__c FROM EBH_DealRetailCampaign__c WHERE Id = :drcId]) {
                startDate = drc.EBH_Date__c;
                endDate = drc.EPH_EndDate__c;
            }

            List<EBH_Deal__c> lstDeal = new List<EBH_Deal__c>();
            if(startDate != null && endDate != null){
                lstDeal = [SELECT Id, EBH_eBayItemID__c, EBH_DealRetailCampaign__r.EBH_Date__c, EBH_DealRetailCampaign__r.EPH_EndDate__c FROM EBH_Deal__c WHERE EBH_DealSiteId__c = '77' AND ((EBH_DealRetailCampaign__r.EBH_Date__c <= : startDate AND EBH_DealRetailCampaign__r.EPH_EndDate__c >=: startDate) OR (EBH_DealRetailCampaign__r.EBH_Date__c >= : startDate AND EBH_DealRetailCampaign__r.EBH_Date__c <=: endDate))];
            }

            //MN-21122021-US-0011048 - Move from doLoadSetting()
            String query = 'SELECT EBH_eBayItemID__c FROM EBH_Deal__c WHERE EBH_DealRetailCampaign__c =: drcId AND EBH_Status__c !=: STATUS_REJECTED ';
            query += (currUserLang == DE_pfName ? ' AND EBH_DealSiteId__c = \'77\' ': '');
            // System.debug('query: '+query);
            List<EBH_Deal__c> lstTmp = new List<EBH_Deal__c>();
            for(EBH_Deal__c[] deals: Database.query(query)){
                lstTmp.addAll(deals);
            }
            mResult.put('lstExistedDeal', lstTmp);
            //=====MN-21122021-US-0011048

            mResult.put('status', 'success');
            mResult.put('lstDeal', lstDeal);
            mResult.put('message', 'The Deals were retrived successfully!');
        }
        catch(Exception ex) {
            mResult.put('message', ex.getMessage());
        }
        return mResult;  
    }


    public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField)
    {
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);

        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();

        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            //System.debug('ControllingField: Label:' + currControllingValue.getLabel());
            //controllingInfo.put(currControllingValue.getLabel(), new List<String>());
            controllingInfo.put(currControllingValue.getValue(), new List<String>());
        }

        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);

            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);

            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();

            //System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);

            Integer baseCount = 0;

            for(Integer curr : hexString.getChars())
            {
                Integer val = 0;

                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }

                if((val & 8) == 8)
                {
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getLabel());
                    //controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                    controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(currDependentValue.getValue());
                }
                if((val & 4) == 4)
                {
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(currDependentValue.getValue());                    
                }
                if((val & 2) == 2)
                {
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(currDependentValue.getValue());                    
                }
                if((val & 1) == 1)
                {
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(currDependentValue.getValue());                    
                }

                baseCount += 4;
            }       
        } 

        //System.debug('ControllingInfo: ' + controllingInfo);

        return controllingInfo;
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
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 20-12-2021 /Mony Nou/ US-0010730 - [SP - EU Deals] [Bug] Deleted Deals not removed from recycle bin affecting daily limit count
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 25-02-2022 /Mony Nou/ US-0011332 - Daily Limit counter issue - Rejected deals are also counting in the daily limit
    *****************************************************************************************************************************/
    
    public static String eligibleAccountId; //MN-26042021-US-0010950

    public static Map<String,Object> getTodayDealSetting(String dealReatilCampaingId){
        Map<String, Object> mResult = new Map<String, Object>();
        mResult.put('status', 'error');
        try{
            Decimal maxDealWindow = 100; 
            String userId = UserInfo.getUserID();
            String accountId = '';
            String contactId = '';
            String fullContactName = '';
            String conEmail = '';
            String currUserLang = '';
            String parentAccId = '';
            List<EBH_DealRetailCampaign__c> listDrc = new List<EBH_DealRetailCampaign__c> ();
            for(User u : [SELECT Id, Profile.Name, ContactId, Contact.LastName, Contact.FirstName, Contact.Email, Contact.AccountId, Contact.Account.Parent_Account_ID__c, Contact.Account.Deal_Window_Limit__c, Contact.Account.EBH_RegistrationSite__c From User WHERE Id =: UserInfo.getUserID()]) {
                //userId = u.Id;
                //if(u.ContactId != null) {
                    conEmail = u.Contact.Email;
                    contactId = u.ContactId;
                    fullContactName = u.Contact.FirstName+ ' ' + u.Contact.LastName ;
                //}
                //if(u.ContactId != null && u.Contact.AccountId != null ) {
                    maxDealWindow = u.Contact.Account.Deal_Window_Limit__c;
                    accountId = u.Contact.AccountId;
                    parentAccId = u.Contact.Account.Parent_Account_ID__c;
                //}
                //if(u.ProfileId != null) {
                    currUserLang = u.Profile.Name;
                //}
            }
            //MN-20122021-US-0010730 - Add IsDeleted = FALSE into Query so we won't count the deleted records ( that existed in Recycle Bin) in the Deal Limitation
            
            /* //MN-21122021-US-0011048 - When page is onload, user not yet select any DRC yet so there is no use to query it with NULL DRC's ID => query EVERYTHING
            Integer totalDealPerCampaign = [SELECT COUNT() FROM EBH_Deal__c WHERE EBH_DealRetailCampaign__c =: dealReatilCampaingId AND EBH_BusinessName__c =: accountId AND EBH_Status__c !=: STATUS_REJECTED AND IsDeleted = FALSE];
            mResult.put('totalDealPerCampaign', totalDealPerCampaign);
            mResult.put('availableDeal', maxDealWindow - totalDealPerCampaign);
            */
            if(currUserLang == DE_pfName) {

                //MN-25022022-US-0011332 - Status(es) that we won't count in the Deal Limitation 
                Set<String> sOptOutStatus = new Set<String>{ STATUS_REJECTED};

                //MN-20122021-US-0010730 - Add IsDeleted = FALSE into Query so we won't count the deleted records ( that existed in Recycle Bin) in the Deal Limitation
                //MN-25022022-US-0011332 - Add EBH_Status__c NOT IN:sOptOutStatus into Query so we won't count it in the Deal Limitation
                //MN-26042021-US-0010950 //mResult.put('totalDealOfDEToday', [SELECT COUNT() FROM EBH_Deal__c WHERE CreatedDate = TODAY AND EBH_BusinessName__r.Parent_Account_ID__c =: parentAccId AND EBH_Status__c NOT IN:sOptOutStatus AND  IsDeleted = FALSE]);
                
                //MN-26042021-US-0010950
                Integer totalDealOfDEToday = (String.isBlank(eligibleAccountId)?0:[SELECT COUNT() FROM EBH_Deal__c WHERE CreatedDate = TODAY AND EBH_BusinessName__r.Parent_Account_ID__c =: eligibleAccountId AND EBH_Status__c NOT IN:sOptOutStatus AND  IsDeleted = FALSE]);
                mResult.put('totalDealOfDEToday', totalDealOfDEToday);

                mResult.put('fieldDependencies', ClsBulkUploadCSV.getFieldDependencies('EBH_Deal__c','EBH_DealSiteId__c','EBH_Category__c'));
            }else 
            {
                Integer totalDealPerCampaign = [SELECT COUNT() FROM EBH_Deal__c WHERE EBH_DealRetailCampaign__c =: dealReatilCampaingId AND EBH_BusinessName__c =: accountId AND EBH_Status__c !=: STATUS_REJECTED AND IsDeleted = FALSE];
                mResult.put('totalDealPerCampaign', totalDealPerCampaign);
                mResult.put('availableDeal', maxDealWindow - totalDealPerCampaign);
            }
            
            mResult.put('userId', userId);
            mResult.put('accountId', accountId);
            mResult.put('contactId', contactId);
            mResult.put('fullContactName', fullContactName);
            mResult.put('conEmail', conEmail);
            mResult.put('currUserLang', currUserLang);
            mResult.put('status', 'success');
            //Loumang:03-02-2022:US-0011290: add condition to prevent null Id in query
            if(String.isNotBlank(dealReatilCampaingId)){
                listDrc = [Select Id,EBH_OpenSeatsAvailable__c from EBH_DealRetailCampaign__c where Id=:dealReatilCampaingId limit 1];
                //Loumang:03-02-2022:US-0011290: Uncomment code because we have prevent at condition if(String.isNotBlank(dealReatilCampaingId))
                mResult.put('drc', !listDrc.isEmpty() ? listDrc[0] : null); //MN-21122021-US-0011048 -  When page is onload, user not yet select any DRC yet so there is no use to query it with NULL DRC's ID => query EVERYTHING
            } 

        } catch(Exception ex) {mResult.put('message', ex.getMessage());}
        
        return mResult;  
    }


    /*****************************************************************************************************************************
    @ Method:         doLoadCouponUploadItems
    @ Author:         Acmatac SEING
    @ Purpose:        US-0010660 - Items upload validations
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String couponSellerId
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 23-05-2022 / Acmatac SEING / Created the  Method.
    *****************************************************************************************************************************/    
    @AuraEnabled
    public static Map<String, Object> doLoadCouponUploadItems(String couponSellerId){
        Map<String, Object> mResult = new Map<String, Object>();
        try{
            String currUserProfileName = '';
            for(User u : [SELECT Id, Profile.Name From User WHERE Id =: UserInfo.getUserID()]) {
                currUserProfileName = u.Profile.Name;
            }

            Set<String> couponCoInvestItemIds = new Set<String>();
            for(Coupon_Co_Invest__c oCCI : [SELECT Item_ID__c FROM Coupon_Co_Invest__c WHERE Coupon_Seller__c =: couponSellerId]){
                couponCoInvestItemIds.add(oCCI.Item_ID__c);
            }

            mResult.put('currUserProfileName', currUserProfileName);
            mResult.put('couponCoInvestCount', couponCoInvestItemIds.size());
            mResult.put('couponCoInvestItemIds', couponCoInvestItemIds);

            mResult.put('status', 'success');
        }
        catch(Exception ex) {
            mResult.put('status', 'error');
            mResult.put('message', ex.getMessage());
        }
        return mResult; 
    }

}