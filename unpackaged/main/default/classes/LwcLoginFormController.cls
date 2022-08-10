/*********************************************************************************************************************************@ Class:          LwcLoginFormController@ Version:        1.0@ Author:       @ Purpose:        Custom controller for SEP Login Page----------------------------------------------------------------------------------------------------------------------------------@ Change history: 10.03.2022 / Mony Nou / US-0011437 - Login Page Issues
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 17.03.2022 / Mony Nou / US-0011406  - Login/Logout/ Error pages to display with respect to domain specific parameters
*********************************************************************************************************************************/
public with sharing class LwcLoginFormController {

    private static String DEF_LANG = 'en_US'; //MN-10032022-US-0011437
    private static String GER_LANG = 'de'; //MN-17032022-US-0011406
    
    @AuraEnabled
    public static string doLogin(String username, String password, String lang){ //MN-10032022-Add "lang" param so that we can control translation for DE since login page is a global page so Custom Label translation doesn't work
        try {

            String httpsUrlPrefix = 'https://';
            Site portal = [SELECT Id, Name, UrlPathPrefix  FROM Site WHERE Name = 'eBay_Seller_Portal' LIMIT 1];
            String sellerPortalUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :portal.Id].SecureUrl;
            String startUrl = sellerPortalUrl.replace(httpsUrlPrefix, '');
            ApexPages.PageReference pageRef = Site.login(username, password, startUrl);
            if(pageRef != null) return pageRef.getUrl();
            throw new CalloutException();
            
        }catch (Exception e) {
            system.debug('e.getMessagelogin+   '+e.getMessage());
            string message = e.getMessage();
            //TH:24/Feb/2022:US-0011354 - When Logged out from DE - Seller Portal it is redirecting to the EN version
            //if(message.containsIgnoreCase('Your login attempt has failed. Make sure the username and password are correct.')){message = System.Label.login_fail_message;} //MN-10032022-US-0011437 - Move to use Custom Metadata instead

            //MN-10032022-US-0011437
            if (!lang.equalsIgnoreCase(DEF_LANG)) message = errorMessageTranslation(message, lang);

            throw new AuraHandledException(message);
            
        }
    }

    /*********************************************************************************************************************************
    @ Method:       translateLoginFailedErrorMessage
    @ Version:      1.0
    @ Author:       Mony Nou (mony.nou@gaea-sys.com)
    @ Purpose:      US-0011406  - Login/Logout/ Error pages to display with respect to domain specific parameters
    @----------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 17.03.2022 / Mony Nou (mony.nou@gaea-sys.com) / create method
    *********************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> translateLoginFailedErrorMessage(String errMsg, String lang){ 

        Map<String,Object> mResult = new Map<String,Object>();
        
        String translated_msg = errorMessageTranslation(errMsg, lang);
        if (String.isNotBlank(translated_msg)) mResult.put('errorMessageTranslated', translated_msg);

        return mResult;
    }

    private static String msgToSearch = ''; //MN-17032022-US-0011406
    private static Map<String, Map<String, String>> mDEF_ERRMSG = new Map<String, Map<String, String>>(); //MN-17032022-US-0011406

    //MN-10032022-US-0011437 - Retrieve list of Login's error message with both EN & DE
    private static Map<String, Map<String, String>> GLOBALERRORMSG {

        get {

            if (GLOBALERRORMSG == null) {

                GLOBALERRORMSG = new Map<String, Map<String, String>>();
                
                List<Seller_Portal_Global_Variables__mdt> tmp = [SELECT DeveloperName, Value_Big__c, Value_in_German__c FROM Seller_Portal_Global_Variables__mdt 
                                                                    WHERE Label = 'LoginErrorMsg' AND DeveloperName like 'LoginErrorMsg%' AND Value__c LIKE:msgToSearch];
                
                if (tmp.isEmpty()) {
                    tmp = [SELECT DeveloperName, Value_Big__c, Value_in_German__c FROM Seller_Portal_Global_Variables__mdt 
                            WHERE Label = 'LoginErrorMsg' AND (DeveloperName LIKE 'LoginErrorMsg%' OR DeveloperName LIKE 'LoginErrorMsg_Global')];
                }                                                    
                
                for (Seller_Portal_Global_Variables__mdt spgv : tmp) {
                    String key = (spgv.DeveloperName == 'LoginErrorMsg_Global')?'DEFERRMSG':spgv.Value_Big__c;
                    GLOBALERRORMSG.put(key, new Map<String, String>{DEF_LANG => spgv.Value_Big__c});  
                    if (String.isNotBlank(spgv.Value_in_German__c)) GLOBALERRORMSG.get(key).put(GER_LANG, spgv.Value_in_German__c); 
                }
                // for (Seller_Portal_Global_Variables__mdt spgv : [SELECT Value_Big__c, Value_in_German__c FROM Seller_Portal_Global_Variables__mdt WHERE Label = 'LoginErrorMsg' and DeveloperName like 'LoginErrorMsg%']) {
                //     GLOBALERRORMSG.put(spgv.Value_Big__c, new Map<String, String>{DEF_LANG => spgv.Value_Big__c});
                //     if (String.isNotBlank(spgv.Value_in_German__c)) GLOBALERRORMSG.get(spgv.Value_Big__c).put(GER_LANG, spgv.Value_in_German__c);
                // }
            }
            
            return GLOBALERRORMSG;
        }

        private set;
    }

    //MN-10032022-US-0011437 - return error message in current language if exists in metadata
    private static String errorMessageTranslation(String en_msg, String lang) {

        String tmp = (String.isNotBlank(en_msg)?en_msg.trim():'');
        msgToSearch = en_msg + '%';
        if (GLOBALERRORMSG.containsKey(en_msg) && GLOBALERRORMSG.get(en_msg).containsKey(lang)) tmp = GLOBALERRORMSG.get(en_msg).get(lang);
        else if (GLOBALERRORMSG.containsKey('DEFERRMSG') && GLOBALERRORMSG.get('DEFERRMSG').containsKey(lang)) tmp = GLOBALERRORMSG.get('DEFERRMSG').get(lang);
        
        return tmp;

    }

    

    @AuraEnabled 
    public static string fectchUrl(){
        // query current user information  
        Site portal = [SELECT Id, Name, UrlPathPrefix  FROM Site WHERE Name = 'eBay_Seller_Portal' LIMIT 1];
        String sellerPortalUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :portal.Id].SecureUrl;

        return sellerPortalUrl;
    }


    /*********************************************************************************************************************************
    @ Method:       fetchLoginLabelTranslation
    @ Version:      1.0
    @ Author:       Mony Nou (mony.nou@gaea-sys.com)
    @ Purpose:      US-0011535 - Better Solution for domain switch
    @----------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 31.03.2022 / Mony Nou (mony.nou@gaea-sys.com) / create method
    *********************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String, Seller_Portal_Global_Variables__mdt> fetchLoginLabelTranslation (List<String> lstLabels) {
        
        Map<String, Seller_Portal_Global_Variables__mdt> mResult = new Map<String, Seller_Portal_Global_Variables__mdt>();

        for (Seller_Portal_Global_Variables__mdt spgv : [SELECT Label, DeveloperName, Value_Big__c, Value_in_German__c FROM Seller_Portal_Global_Variables__mdt WHERE DeveloperName LIKE 'LoginLabel%' AND Label IN:lstLabels]) {
            mResult.put(spgv.DeveloperName, spgv);
        }

        return mResult;
    }
        
}