/*********************************************************************************************************************************
@ Class:          SEPCouponController
@ Version:        1.0
@ Author:         Sambath Seng (sambath.seng@gaea-sys.com)
@ Purpose:        Controller class for “Coupon Feature in SEP”
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 13.5.2022 / Sambath Seng / Created the class.
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 19.5.2022 / Mony Nou / US-0010656 - Ability to upload/manage items to item based coupons
@ Change history: 16.06.2022 / Chetra Sarom / US-0010436 - Ability to decline single coupon participation
@ Change history: 20.06.2022 / Sambath Seng / US-0010429 - Ability to sign Agreement in portal
@ Change history: 23.06.2022 / Chetra Sarom / US-0011912 - Bug: Remove Item List visibility for coupon seller in preparation
@ Change history: 28.06.2022 / SRONG TIN / US-0011918 - Enable deletion of Co-Invest records if not owner
@ Change history: 25.07.2022 / Mony Nou / US-0012015 - NA Localization for Coupon Contract
*********************************************************************************************************************************/
public with sharing class SEPCouponController {

    //MN-25072022-US-0012015-Added SellerShareHolder__c,eBay_Co_fund_Max__c into query
    private final static String SOQL_COUPON_SELLER = 'Select Coupon_Code__c, Name, Coupon_ID__c, Coupon_Start_Date__c, Coupon_End_Date__c, Legal_Entity_Name_w__c, Legal_Entity_Street_w__c, Legal_Entity_Zip_w__c, Seller__r.Parent.EBH_BillingCity__c, Seller__r.Name, Coupon_Start_Time__c, Coupon_End_Time__c, Additional_Terms__c, Seller__r.Parent.EBH_BillingCountry__c, Coupon__r.Couponsite_s__c, Marketing_Coupon_Name__c, Contract_Language__c, CurrencyIsoCode, Min_Transaction_Value__c, SP_Coupon_Discount_Rate__c, Coupon_Site__c, Max_Redemptions__c, Coupon_Discount_Amount__c, Legal_Entity_City__c, Maximum_Discount_Value__c, Coupon_Contract_Due_Date__c, Coupon_Seller_Stage__c, Contract_Accept_Date__c, Contract_Accepted_From__c, Contract_Signed_Declined_By__c, Legal_Entity_Country__c, Coupon_Type__c, Allow_reaccept_contract__c, Coupon_Seller_Stage_Portal__c, SellerShareHolder__c,eBay_Co_fund_Max__c From Coupon_Seller__c ' ; //SB 23.6.2022 US-0011958 - Change Requests Focus 75
    private final static String SOQL_COUPONCOINVEST = 'select Item_ID__c,Item_Title__c,Category__c, Coupon_Seller__c, Co_Invest__c, Category_ID__c, Coupon_Category__r.Name from Coupon_Co_Invest__c';
    private final static String EMAIL_COUPON_CONTRACT_DE_ITEM_SEP = 'DE_Item_Coupon_Contract_SEP';
    private final static String EMAIL_COUPON_CONTRACT_DE_CAT_SEP = 'DE_Category_Coupon_Contract_SEP';

    //MN-25072022-US-0012015
    private final static String EMAIL_COUPON_CONTRACT_NA_ITEM_SEP = 'NA_Item_Coupon_Contract_SEP';
    private final static String EMAIL_COUPON_CONTRACT_NA_CAT_SEP = 'NA_Category_Coupon_Contract_SEP';

    private final static String SOQLEMAIL_TEMPLATES = 'Select Body,Id,DeveloperName,Subject,HtmlValue from emailTemplate ';
    public final static String COUPON_CATEGORYBASE = 'Category Based';
    public final static String COUPON_ITEMBASE = 'Item Based';
    private static String htmlTableTemplate = '<table>{!tableHeader}{!rows}</tbody></table>';
    private static String htmlHeadTemplateDE = '<thead><tr><td><strong>Kategorie</strong></td><td><strong>Kategorie-ID</strong></td><td><strong>Erfolgsprämie (%)</strong></td></tr></thead><tbody>';
    //MN-29072022-US-0012015
    private static String htmlHeadTemplateNA = '<thead><tr><td><strong>Categories</strong></td><td><strong>Category-ID</strong></td><td><strong>Co-Invest (%)</strong></td></tr></thead><tbody>';

    private static String htmlRowTemplate = '<tr><td style="width: 250px;">{!catName}</td><td style="width: 250px;">{!catId}</td><td style="width: 250px;">{!coinvest%}</td></tr>'; //SB 22.06.2022 US-0010429 change table head width
    private final static String DF_DD_MM_YYYY = 'dd/MM/yyyy';
    private final static String COUPON_SELLER_STAGE_CONTRACT_SIGNED= 'Contract Signed';
    private final static String COUPON_SELLER_STAGE_CONTRACT_SEND= 'Contract Send';
    private final static String COUPON_SELLER_STAGE_SELLER_DECLINED= 'Seller Declined';
    private final static String COUPON_SELLER_STAGE_NEGO= 'Contract Negotiation';
    private final static String COUPON_SELLER_STAGE_REVIEW_SEP= 'Items in Review';//SB 23.6.2022 US-0011958 - Change Requests Focus 75

    private final static String SP_COUPON_FULL_ACCESS = 'Full Access';// US-0011991 - Acmatac SEING
    private final static String SP_COUPON_READ_ONLY = 'Read Only';// US-0011991 - Acmatac SEING
    private final static String SP_COUPON_ALLOWED = 'Allowed';// US-0011991 - Acmatac SEING

    //MN-25072022-US-0012015
    private final static String PROF_SEP_DE = 'DE - Seller Portal';
    private final static String PROF_SEP_NA = 'NA - Seller Portal';
    
    /*****************************************************************************************************************************
    @ Method:         fetchSingleSEPGlobalVar
    @ Version:        1.0
    @ Author:         Sambath Seng (sambath.seng@gaea-sys.com)
    @ Purpose:        US-0010431 - Create Coupon details view on portal
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String prefix
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 13.5.2022 / Sambath Seng / Create the method
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 10.06.2022 / Mony Nou / US-0011863
    *****************************************************************************************************************************/
    @AuraEnabled ( cacheable=true )   
    public static Seller_Portal_Global_Variables__mdt fetchSingleSEPGlobalVar(String prefix) {        
        //MN-10062022-US-0011863- Added Value_Big__c into the query => In case field Value__c is empty then showing text from Value_Big__c instead
        Seller_Portal_Global_Variables__mdt fetchMeta = [SELECT Id, Value__c, Value_Big__c, Value_in_German__c, DeveloperName FROM Seller_Portal_Global_Variables__mdt WHERE DeveloperName =: prefix];
        return fetchMeta;
    }


    /*****************************************************************************************************************************
    @ Method:         doDeleteCouponCoInvest
    @ Version:        1.0
    @ Author:         Mony Nou (mony.nouseng@gaea-sys.com)
    @ Purpose:        US-0010656 - Ability to upload/manage items to item based coupons
    @                    - To delete selected coupon co-invest from Coupon Seller Detail Page
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String cciIds - Array of selected Coupon Co-Invest's Id
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 19.05.2022 / Mony Nou / Create the method
    @               : 28.06.2022 / SRONG TIN / Update the method US-0011918
    *****************************************************************************************************************************/
    @AuraEnabled
    public static Object doDeleteCouponCoInvest(List<String> cciIds) {
        
        Map<String,Object> mResult = new Map<String,Object>();
        mResult.put('status', 'error');
        try{

            if (!cciIds.isEmpty()) {

                //SRONG:28.06.2022:US-0011918
                WithoutSharing.doDelete([select id from Coupon_Co_Invest__c where id IN:cciIds]);

                mResult.put('status', 'success');
            }
            

        } catch ( Exception ex) {
            System.debug('@@@@@messgee'+ex);
            mResult.put('message', 'Error:'+ex.getLineNumber()+':'+ ex.getMessage());
        }

        return mResult;
    }

    /*****************************************************************************************************************************
    @ Method:         updateCouponSellerStage2Review
    @ Version:        1.0
    @ Author:         Mony Nou (mony.nouseng@gaea-sys.com)
    @ Purpose:        US-0010656 - Ability to upload/manage items to item based coupons
    @                    - Change Coupon Seller Stage to Review
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String csId - Coupon Seller's Id
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 19.05.2022 / Mony Nou / Create the method
    *****************************************************************************************************************************/
    @AuraEnabled
    public static Object updateCouponSellerStage2Review(String csId) {
        
        Map<String,Object> mResult = new Map<String,Object>();
        mResult.put('status', 'error');
        try{

            if (String.isNotBlank(csId)) {

                Coupon_Seller__c cs = new Coupon_Seller__c(
                    Id = csId,
                    Coupon_Seller_Stage__c = 'Review'
                );

                update cs;

                mResult.put('status', 'success');
            }
            

        } catch ( Exception ex) { mResult.put('message', 'Error:'+ex.getLineNumber()+':'+ ex.getMessage()); }

        return mResult;
    }

    /*****************************************************************************************************************************
    @ Method:         getCouponContractTemplate
    @ Version:        1.0
    @ Author:         Sambath Seng (sambath.seng@gaea-sys.com)
    @ Purpose:        US-0010429 - Ability to sign Agreement in portal
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String csId
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 13.06.2022 / Sambath Seng / Create the method
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 25.07.2022 / Mony Nou / US-0012015
    *****************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static String getCouponContractTemplate(String csId)
    {
    	Map<Id,Coupon_Seller__c> mapCouponSeller = new Map<Id,Coupon_Seller__c>();
        String htmlBody = '';
        Coupon_Seller__c cs = getCS(csId);
        List<Coupon_Co_Invest__c> listCoInvest = getListCoinvest(csId);

        /* MN-25072022-US-0012015
        Set<String> setEmailTemplates = new Set<String>{
                EMAIL_COUPON_CONTRACT_DE_ITEM_SEP,
                EMAIL_COUPON_CONTRACT_DE_CAT_SEP
        };
        
        Map<String,EmailTemplate> mapEmailTemplate = new Map<String,EmailTemplate>();
        for(EmailTemplate emt : Database.query(SOQLEMAIL_TEMPLATES +' Where DeveloperName IN :setEmailTemplates'))
        {
            if(emt.DeveloperName == EMAIL_COUPON_CONTRACT_DE_ITEM_SEP){
                mapEmailTemplate.put(COUPON_ITEMBASE,emt);
            }else if(emt.DeveloperName == EMAIL_COUPON_CONTRACT_DE_CAT_SEP){
                mapEmailTemplate.put(COUPON_CATEGORYBASE,emt);
            }
            
        }

        EmailTemplate empt = (mapEmailTemplate.containsKey(cs.Coupon_Type__c)?mapEmailTemplate.get(cs.Coupon_Type__c):null);

        if(empt!=null){
                String htmlValue = empt.HtmlValue != null ? empt.HtmlValue : null; 
                htmlBody += mergeFieldsContractCoupon(htmlValue,cs);
                htmlBody = htmlBody.contains('{!catTable}')?htmlBody.replace('{!catTable}',generateHTMLTable(listCoInvest,htmlRowTemplate,false,empt)):htmlBody;			 
        }

        */

        //MN-25072022-US-0012015
        Map<String, Map<String, String>> mProfEmailTemp = new Map<String, Map<String,String>> {
            PROF_SEP_DE => new Map<String, String>{
                COUPON_ITEMBASE => EMAIL_COUPON_CONTRACT_DE_ITEM_SEP,
                COUPON_CATEGORYBASE => EMAIL_COUPON_CONTRACT_DE_CAT_SEP
            },
            PROF_SEP_NA => new Map<String, String>{
                COUPON_ITEMBASE => EMAIL_COUPON_CONTRACT_NA_ITEM_SEP,
                COUPON_CATEGORYBASE => EMAIL_COUPON_CONTRACT_NA_CAT_SEP
            }
        };

        User currentUser = [SELECT Contact.Account.SP_Coupons__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        

        if (String.isNotBlank(currentUser.Profile.Name) && mProfEmailTemp.containsKey(currentUser.Profile.Name) && String.isNotBlank(cs.Coupon_Type__c)) {

            String emTDevName = mProfEmailTemp.get(currentUser.Profile.Name).get(cs.Coupon_Type__c);

            for (EmailTemplate empt : Database.query(SOQLEMAIL_TEMPLATES +' Where DeveloperName  =:emTDevName')) {
                String htmlValue = empt.HtmlValue != null ? empt.HtmlValue : null; 
                htmlBody += mergeFieldsContractCoupon(htmlValue,cs);
                htmlBody = htmlBody.contains('{!catTable}')?htmlBody.replace('{!catTable}',generateHTMLTable(listCoInvest,htmlRowTemplate,false,empt,currentUser.Profile.Name)):htmlBody;
            }

        }


        
        return htmlBody;
    }

    /*****************************************************************************************************************************
    @ Method:         mergeFieldsContractCoupon
    @ Version:        1.0
    @ Author:         Sambath Seng (sambath.seng@gaea-sys.com)
    @ Purpose:        US-0010429 - Ability to sign Agreement in portal
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String s, Coupon_Seller__c cs
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 13.06.2022 / Sambath Seng / Create the method
    @               : 17.06.2022 / Loumang SENG / update to call SEPDownloadController.CouponSellerWrapper
    *****************************************************************************************************************************/
    public static String mergeFieldsContractCoupon(String s, Coupon_Seller__c cs) 
 	{
        SEPDownloadController.CouponSellerWrapper csw = new SEPDownloadController.CouponSellerWrapper(cs);
        return s==null?'':s
        .replace('{Max_Redemptions__c}',csw.maxRedmeptions)
        .replace('{LegalEntity}',csw.legalEntity)
        .replace('{StreetName}',csw.streetName)
        .replace('{Zip}',csw.zip)
        .replace('{City}',csw.city) 
        .replace('{eBaySellerID}',csw.eBaySellerID)
        .replace('{CouponSites}',csw.couponSites)
        .replace('{CouponStartTime}',csw.couponStartTime)
        .replace('{CouponStartDate}',csw.formatcouponStartDate)
        .replace('{CouponEndTime}',csw.couponEndTime)
        // .replace('{CouponDiscount%}',csw.couponDiscount)
        // .replace('{CouponDiscountAmount}',csw.couponDiscountAmount) 
        .replace('{CouponDiscount%}{CouponDiscountAmount}',csw.couponDiscountAndDiscountAmount) 
        .replace('{CouponCap}',csw.maxDisc) 
        .replace('{CouponEndDate}',csw.formatcouponEndDate)
        .replace('{AdditionalArrangement}',csw.additionalArrangement)
        .replace('{Marketing_Coupon_Name__c}',csw.marketingName)
        .replace('{Minimum_Transaction_Value__c}',csw.minTransactionVal)
        .replace('{Country}',csw.country)
        .replace('{CouponCode}',csw.couponCode) //SB 30.6.2022 US-0011998 - Business Feedback Focus 75 AC4
        .replace('{SellerShareHolder__c}', csw.sellerShareHolder) //MN-25072022-US-0012015
        .replace('{eBay_Co_fund_Max__c}', csw.eBayCofundMax) //MN-25072022-US-0012015
        ;
 	} 
     
    /*****************************************************************************************************************************
    @ Method:         getListCoinvest
    @ Version:        1.0
    @ Author:         Sambath Seng (sambath.seng@gaea-sys.com)
    @ Purpose:        US-0010429 - Ability to sign Agreement in portal
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String csId
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 13.06.2022 / Sambath Seng / Create the method
    *****************************************************************************************************************************/
    public static List<Coupon_Co_Invest__c> getListCoinvest(String csId){
    	return Database.query(SOQL_COUPONCOINVEST+' Where Coupon_Seller__c =:csId');
    }

    /*****************************************************************************************************************************
    @ Method:         generateHTMLTable
    @ Version:        1.0
    @ Author:         Sambath Seng (sambath.seng@gaea-sys.com)
    @ Purpose:        US-0010429 - Ability to sign Agreement in portal
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<Coupon_Co_Invest__c> listCovinvest,String htmlRowStringTemplate,Boolean istext,EmailTemplate emt, String userProf
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 13.06.2022 / Sambath Seng / Create the method
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.07.2022 / Mony Nou / US-0012015 - NA Localization for Coupon Contract
    *****************************************************************************************************************************/
    private static String generateHTMLTable(List<Coupon_Co_Invest__c> listCovinvest,String htmlRowStringTemplate,Boolean istext,EmailTemplate emt, String userProf)
 	{ 
 		if(listCovinvest==null || (listCovinvest <>null && listCovinvest.isEmpty()))return '';
        
        //MN-29072022-US-0012015
        Map<String, String> mHTMLHeader = new Map<String, String>{
            PROF_SEP_DE => htmlHeadTemplateDE,
            PROF_SEP_NA => htmlHeadTemplateNA
        };

 		String htmlString = htmlTableTemplate;
        // String htmlHeadString = htmlHeadTemplateDE; //MN-29072022-US-0012015
        //MN-29072022-US-0012015
        String htmlHeadString = (mHTMLHeader.containsKey(userProf))?mHTMLHeader.get(userProf):'';

 		String htmlRowString  = '';
 		for(Coupon_Co_Invest__c cci : listCovinvest)
 		{
 			htmlRowString = htmlRowString + htmlRowStringTemplate
 			.replace('{!catName}',cci.Category__c==null?'N/A': cci.Category__c)
 			.replace('{!catId}',+String.isBlank(cci.Category_ID__c)?'N/A': cci.Category_ID__c)
 			.replace('{!coinvest%}',cci.Co_Invest__c==null?'N/A':cci.Co_Invest__c+'%');
 		}
 		htmlString = istext ? htmlRowString : htmlString.replace('{!rows}',htmlRowString).replace('{!tableHeader}',htmlHeadString);
 		return htmlString;
 	}

    /*****************************************************************************************************************************
    @ Method:         getCS
    @ Version:        1.0
    @ Author:         Sambath Seng (sambath.seng@gaea-sys.com)
    @ Purpose:        US-0010429 - Ability to sign Agreement in portal
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String csId
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 14.06.2022 / Sambath Seng / Create the method
    *****************************************************************************************************************************/
    public static Coupon_Seller__c getCS(String csId)
    {  
        return Database.query(SOQL_COUPON_SELLER+' WHERE Id =:csId');
    }

    /*****************************************************************************************************************************
    @ Method:         handleContractCouponSellerAgree
    @ Version:        1.0
    @ Author:         Sambath Seng (sambath.seng@gaea-sys.com)
    @ Purpose:        US-0010429 - Ability to sign Agreement in portal
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String csId, String userId, String currentContactId
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.06.2022 / Sambath Seng / Create the method
    *****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> handleContractCouponSellerAgree(String csId, String userId, String currentContactId)
 	{
        Map<String,Object> mapResult = new Map<String,Object>();
        Savepoint sp = Database.setSavepoint();
        try{
            String couponSellerId = csId;
            String curUId = userId;
            String curCId = currentContactId;
            if(String.isNotBlank(couponSellerId))
            {
                Coupon_Seller__c cs = getCS(csId);
                 
                cs.Coupon_Seller_Stage__c = COUPON_SELLER_STAGE_CONTRACT_SIGNED;
                cs.Contract_Accept_Date__c = System.now();
                cs.Contract_Accepted_From__c = !Test.isRunningTest() ? Auth.SessionManagement.getCurrentSession().get('SourceIp') : '';
                cs.Contract_Signed_Declined_By__c = curCId;
                CouponSellerTriggerHandler.isUpdatedSellerStage = true;
                CouponSellerTriggerHandler.currUserId = curUId;
                update cs;

                Map<String,String> resultAtt = SEPCouponContractDownloadController.createAttachment(cs);
                mapResult.put('attachmentId',resultAtt.get('id'));
                mapResult.put('fileNamePDF',resultAtt.get('name'));                
                 
            }
            mapResult.put('status','ok');
        }catch(DMLException dex)
    	{	Database.rollback(sp);mapResult.put('status','ko');mapResult.put('error',dex.getDmlMessage(0));mapResult.put('errorDetail',dex.getStackTraceString());
    	}catch(Exception ex)
    	{   Database.rollback(sp);mapResult.put('status','ko');mapResult.put('error',ex.getMessage());mapResult.put('errorDetail',ex.getStackTraceString());	}

        return mapResult;
        
 	}

     /*****************************************************************************************************************************
    @ Method:         getAllPickListValue
    @ Version:        1.0
    @ Author:         Chetra Sarom (chetra.sarom@gaea-sys.com)
    @ Purpose:        US-0010436 - Ability to decline single coupon participation
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String csId, String rejectionReasons, String reasonsComments, String contactId
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 16.06.2022 / Chetra Sarom / Create the method
    *****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> handleUpdateCouponSellerStage(String csId, String rejectionReasons, String reasonsComments, String contactId)
 	{
        Map<String,Object> mapResult = new Map<String,Object>();
        Savepoint sp = Database.setSavepoint();
        Coupon_Seller__c cs = getCS(csId);
        if(cs!=null)
        {
            cs.Coupon_Seller_Stage__c = COUPON_SELLER_STAGE_SELLER_DECLINED;
            cs.Contract_Signed_Declined_By__c = contactId;
            cs.Seller_Declined_Reasons__c = rejectionReasons;
            cs.Comment__c = reasonsComments;

            try
            {	
                update cs;
                mapResult.put('results',cs);
                mapResult.put('status','ok');
                
            }catch(DMLException dex)
            {	Database.rollback(sp);mapResult.put('status','ko');mapResult.put('error',dex.getDmlMessage(0));mapResult.put('errorDetail',dex.getStackTraceString());
            }catch(Exception ex)
            {   Database.rollback(sp);mapResult.put('status','ko');mapResult.put('error',ex.getMessage());mapResult.put('errorDetail',ex.getStackTraceString());	}
           
        } 
        return mapResult;
        
 	}

    /*****************************************************************************************************************************
    @ Method:   getAllPickListValue
    @ Version:  1.0
    @ Author:         Chetra Sarom (chetra.sarom@gaea-sys.com)
    @ Purpose:        US-0010436 - Ability to decline single coupon participation
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      sObject's API Name , API Name 
    ------------------------------------------------------------------------------------------------------------------------------
     @ Change history: 16.06.2022 / Chetra Sarom / Create the method
    *****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,String> getAllPickListValue(String objectApiName, String field_name)
 	{
        Set<String> validPicklist = new Set<String>{
			'Seller did not respond',
            'Contract Breach',
            'Contract Voided',
            'Seller not reached',
            'Seller added to coupon by mistake'
		};
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectApiName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        Map<String, String> picklistFieldValues = new Map<String, String>();

        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(field_name).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            if (!validPicklist.contains(objPickList.getValue())) {
                picklistFieldValues.put(objPickList.getLabel(), objPickList.getValue());
            }
        }

        return picklistFieldValues;
 	}



    private final static Set<String> SET_STAGE_SHOW_DOWNLOAD_CONTRACT  = new Set<String>{
        'Contract Signed','Coupon Running','Coupon executed','T4 Statement Send','T34 Statement Send','Invoice paid'        
    };
    private final static Set<String> SET_STAGE_SHOW_TAB  = new Set<String>{
        'Contract Send','Contract Signed','Coupon Running','Coupon executed','T4 Statement Send','T34 Statement Send','Invoice paid'
    }; // SB 20.6.2022 US-0010429 Change variable name

    private final static Set<String> SET_STAGE_HIDE_TAB_ARTICLE  = new Set<String>{
        'Targeted','Reached','Commited'
    }; // CT 23.06.2022 / Chetra Sarom / US-0011912
   
     /*****************************************************************************************************************************
    @ Method:         getCouponSeller
    @ Version:        1.0
    @ Author:         Sambath Seng (sambath.seng@gaea-sys.com)
    @ Purpose:        US-0010429 - Ability to sign Agreement in portal
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 16.06.2022 / Sambath Seng / Create the method
    @               29.06.2022 / Acmatac SEING / US-0011991 - Fixing issues for Coupon Linked Accounts
    *****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> getCouponSeller2(String csId)
    {
        Map<String,Object> mapResult = new Map<String,Object>();
        Coupon_Seller__c cs = getCS(csId);

        Boolean isNegotiation = cs.Coupon_Seller_Stage__c== COUPON_SELLER_STAGE_NEGO;
        Boolean isItemBase = (cs.Coupon_Type__c==COUPON_ITEMBASE && !SET_STAGE_HIDE_TAB_ARTICLE.contains(cs.Coupon_Seller_Stage__c));

        mapResult.put('cs', cs);
        mapResult.put('sellerCouponType',cs.Coupon_Type__c);        
        // mapResult.put('isShowContract',SET_STAGE_SHOW_TAB.contains(cs.Coupon_Seller_Stage__c));
        mapResult.put('isCategoryBase',cs.Coupon_Type__c==COUPON_CATEGORYBASE);
        mapResult.put('isItemBased', isItemBase); // CT 23.06.2022 / Chetra Sarom / US-0011912
        mapResult.put('isNegotiation', isNegotiation);
        mapResult.put('isShowContractAgreeButton',cs.Coupon_Seller_Stage__c== COUPON_SELLER_STAGE_CONTRACT_SEND); // SB 20.6.2022 US-0010429
        mapResult.put('isCouponSellerStageNotContractSend',(cs.Coupon_Seller_Stage__c <> COUPON_SELLER_STAGE_CONTRACT_SEND));
        mapResult.put('isItemInReview',(cs.Coupon_Seller_Stage_Portal__c == COUPON_SELLER_STAGE_REVIEW_SEP));//SB 23.6.2022 US-0011958 - Change Requests Focus 75
        
        // US-0011991 - Fixing issues for Coupon Linked Accounts
        Set<String> sp_Coupon_AllowTo_UploadItems = new Set<String>{SP_COUPON_FULL_ACCESS, SP_COUPON_READ_ONLY, SP_COUPON_ALLOWED};
        User currentUser = [SELECT Contact.Account.SP_Coupons__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        mapResult.put('spCouponValue', currentUser.Contact.Account.SP_Coupons__c);
        mapResult.put('profileName', currentUser.Profile.Name);
        mapResult.put('hasUploadItemsAccess', sp_Coupon_AllowTo_UploadItems.contains(currentUser.Contact.Account.SP_Coupons__c) && isNegotiation && isItemBase);
        mapResult.put('isSPCouponReadOnly', currentUser.Contact.Account.SP_Coupons__c == SP_COUPON_READ_ONLY);
        mapResult.put('isContractAvailable', SET_STAGE_SHOW_TAB.contains(cs.Coupon_Seller_Stage__c) && (currentUser.Contact.Account.SP_Coupons__c == SP_COUPON_FULL_ACCESS || currentUser.Contact.Account.SP_Coupons__c == SP_COUPON_ALLOWED));
        mapResult.put('isNegoFullAccessOrAllowed', isNegotiation && (currentUser.Contact.Account.SP_Coupons__c == SP_COUPON_FULL_ACCESS || currentUser.Contact.Account.SP_Coupons__c == SP_COUPON_ALLOWED));//SB 05.07.2022 US-0011958 - Change Requests Focus
        
        Date tDay = System.today();
        Boolean showViewAgreement = cs.Coupon_Seller_Stage__c == COUPON_SELLER_STAGE_CONTRACT_SEND && (cs.Coupon_Contract_Due_Date__c >= tDay || (cs.Coupon_Contract_Due_Date__c < tDay && cs.Allow_reaccept_contract__c))
                                                            && (currentUser.Contact.Account.SP_Coupons__c == SP_COUPON_FULL_ACCESS || currentUser.Contact.Account.SP_Coupons__c == SP_COUPON_ALLOWED);
        mapResult.put('showViewAgreement', showViewAgreement);



        // List<Attachment> listAtt = [Select Id,Name From Attachment where ParentId=:csId ORDER BY CreatedDate DESC Limit 1];
        // if(SET_STAGE_SHOW_DOWNLOAD_CONTRACT.contains(cs.Coupon_Seller_Stage__c) && !listAtt.isEmpty())
        // {            
        //     mapResult.put('attachmentId',listAtt[0].Id);
        //     mapResult.put('fileNamePDF',listAtt[0].Name);      
            
        //     mapResult.put('showDownlaodPDF',SET_STAGE_SHOW_DOWNLOAD_CONTRACT.contains(cs.Coupon_Seller_Stage__c));
        // }
        
        List<ContentDocumentLink> listAtt = [Select Id,ContentDocumentId From ContentDocumentLink where LinkedEntityId=:csId ORDER BY ContentDocument.CreatedDate DESC Limit 1];
        if(SET_STAGE_SHOW_DOWNLOAD_CONTRACT.contains(cs.Coupon_Seller_Stage__c) && !listAtt.isEmpty())
        {            
            ContentVersion[] cv = [Select Id,Title From ContentVersion Where ContentDocumentId =:listAtt[0].ContentDocumentId ORDER BY CreatedDate DESC Limit 1];
            mapResult.put('attachmentId',cv[0].Id);
            mapResult.put('fileNamePDF',cv[0].Title);      
            
            mapResult.put('showDownlaodPDF',SET_STAGE_SHOW_DOWNLOAD_CONTRACT.contains(cs.Coupon_Seller_Stage__c));
        }

        
        return mapResult;
    }

    
}