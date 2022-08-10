/*********************************************************************************************************************************
@ Class:          EbayRegistrationHandler
@ Version:        1.0
@ Author:         Acmatac SEING (acmatac.seing@gaea-sys.com)
@ Purpose:        US-0010085 - [SEP] Implement matching classes for ebay SSO to identify community users based on ebay account
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 11.08.2021 / Acmatac SEING / Created the class.
@                 13.09.2021 / Acmatac SEING / US-0010353 - AC1: Update the SSO logic: to Query the Contact record which has Record Type='DWH' to pick the contact for SSO login.
@                 02.02.2022/ vadhanak voun / US-0010870 - [SP] Just in Time Provisioning of Sellers (Deals, Monetization) - NA, DE
@                 08.04.2022/ vadhanak voun / US-0010870 - rework - final?
@                 04.05.2022/ SRONG TIN / US-0011083 - SSO Adjustments for Linked Accounts
@                 27.07.2022/ Mony Nou / US-0011699 - Auto Provisioning of Sellers (Deals) - AU (Perm Set Group) - AC6
*********************************************************************************************************************************/
global class EbayRegistrationHandler implements Auth.RegistrationHandler{
    private final static Id CONTACT_DWH_RTID = '0126A000000T3OOQA0'; // Contact recordtype DWH
    private final String RECORD_TYPE_SELLER = 'EBH_Seller';

    private final String PORTAL_DE = 'DE - Seller Portal';
    private final String PORTAL_NA = 'NA - Seller Portal';
    private final String PORTAL_AU = 'AU - Seller Portal'; //MN-27072022-US-0011699
    private final String PORTAL_SUFFIX = '.ebay.portal';
    
    public final static String PSGROUP_DE = 'Seller_Portal_DE';
    private final String PSGROUP_NA = 'Seller_Portal_NA';
    private final String PSGROUP_AU = 'Seller_Portal_AU'; //MN-27072022-US-0011699
    
    private final String ELIGBILE_CHECK_PORTAL ='Eligible_for_Seller_Portal';

    // private final String ELIGBILE_CHECK_DE ='Eligible_for_DE_Deals';
    // private final String ELIGBILE_CHECK_NA ='Eligible_for_NA_Deals';
    

    // private final Set<String> DE_META_IDENTIFIER = new Set<String>{'Eligible_for_DE_Deals','Eligible_for_Account_Manager','Eligible_for_Trusted_Shops','Eligible_for_Growth_Based_Discounts'};
    // private final Set<String> NA_META_IDENTIFIER = new Set<String>{'Eligible_for_NA_Deals'};

    private String soqlSeller = 'Select Id,Name,eBay_API_User_Id__c,Seller_Portal_Group__c,User_Disconnected__c,Seller_Portal_Profile__c From Account WHERE eBay_API_User_Id__c=:sellerId AND RecordType.DeveloperName=:RECORD_TYPE_SELLER ';

    
    global User createUser(Id portalId, Auth.UserData data){

        // SRONGTIN: 6.05.2022 :US-0011083: SSO Adjustments for Linked Accounts
        User sU = checkSSOAccountLogin(portalId,data);
        return sU;
       
    }
    

    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        // SRONGTIN: 6.05.2022 : US-0011083: SSO Adjustments for Linked Accounts
        User usr = checkSSOAccountLogin(portalId,data);

   
    }
    // SRONGTIN: 6.05.2022 : US-0011083: SSO Adjustments for Linked Accounts
    private void updateUserActiveUser(Id userId, Id portalId, Auth.UserData data, Boolean isHasGroup){        
        User usr = [Select Id,Email,isActive,Permission_Sets__c,IsPortalEnabled From User Where Id=:userId];         
        if(!usr.isActive){
            // SRONGTIN: 20.05.2022 : US-0011083
            String sellerId = data.identifier;
            usr.isActive = true;
            usr.IsPortalEnabled = true;
            usr.Id = userId;
            //check if Seller have Seller Portal Group
            if(!isHasGroup){
                User userValidated = sellerValidation(sellerId,data);   //revaliate with metadata and to get Permset
                usr.Permission_Sets__c = userValidated.Permission_Sets__c;
                usr.ProfileId = userValidated.ProfileId;
                update usr;
            }else{
                    update usr; 
            } 
            
        }
    } 
    // SRONGTIN : 03.05.2022 : US-0011083 - SSO Adjustments for Linked Accounts
    private User checkSSOAccountLogin(Id portalId, Auth.UserData data){
        Boolean isDE = isFromDESite();
        String sellerId = data.identifier;
        Account[] sellers = Database.query(soqlSeller);
        if (!sellers.isEmpty()) {
            // SRONGTIN: 24.05.2022 : US-0011083
            if(sellers[0].User_Disconnected__c == true){
                throw new EbayRegistrationHandlerException(getMessage(isDE,'LoginErrorMsg_6'));
            }else 
            // IS Account have Seller Portal Group?
            if(sellers[0].Seller_Portal_Group__c != null){
                //Yes
                //Does Seller Portal Group have Contact already enabled for SSO for which there is a Active User?
                String sellerPortalGroupId = sellers[0].Seller_Portal_Group__c;
                for(User sU : [SELECT userName, email, lastName, firstName, alias,isActive FROM User 
                        WHERE Contact.Account.Id = :sellerPortalGroupId  LIMIT 1])
                {
                    
                    if(!sU.IsActive){
                        // User not Active US-0011083: AC6
                        // from old story:US-0010870
                        updateUserActiveUser(sU.Id,portalId,data,true);
                    }
                    //Yes  US-0011083: AC4
                    return sU;

                }
                // No User not found US-0011083: AC5
                throw new EbayRegistrationHandlerException(getMessage(isDE,'LoginErrorMsg_5'));

            }else{
                //No
                //Does Account have contact already enabled for SSO for which there is a Active User?
                for(User sU : [SELECT userName, email, lastName, firstName, alias,isActive FROM User 
                        WHERE Contact.Account.eBay_API_User_Id__c =: data.identifier
                        AND Contact.RecordTypeId =: CONTACT_DWH_RTID // 13.09.2021 / Acmatac SEING / US-0010353
                        LIMIT 1])
                {
                    

                    if(!sU.isActive)
                    {
                        // User not Active US-0011083: AC3
                        // from old story:US-0010870
                        updateUserActiveUser(sU.Id,portalId,data,false);       
                    }
                    // US-0011083: AC2 
                    return sU;
                }
            }
        }else{
            //incase no user found
            // Is Account not found within Hive US-0011083: AC1
            throw new EbayRegistrationHandlerException(getMessage(isDE,'LoginErrorMsg_4')); // 'Cannot find the user. For help, contact your administrator.'
        }

        return sellerValidation(sellerId,data);
    }
    
    

    private User sellerValidation(String sellerId,Auth.UserData data)
    {
        Boolean isDE = isFromDESite();
        //found seller. let check if eligible?
        Map<String,String>  mapSetting = getMetaSetting();
        //check is this is portal eligible
        Account findSeller = checkEligible(new Set<String>{ELIGBILE_CHECK_PORTAL},mapSetting,sellerId);
        
        if(findSeller <> null && findSeller.Seller_Portal_Profile__c==PORTAL_DE)
        {
            return prepareUser(findSeller.Id,data,PORTAL_DE,PSGROUP_DE);

        }else if(findSeller <> null && findSeller.Seller_Portal_Profile__c==PORTAL_NA)
        {
            return prepareUser(findSeller.Id,data,PORTAL_NA,PSGROUP_NA);

        }else if(findSeller <> null && findSeller.Seller_Portal_Profile__c==PORTAL_AU) { //MN-27072022-US-0011699
            return prepareUser(findSeller.Id,data,PORTAL_AU,PSGROUP_AU);
        }else 
        {
             //seller not eligible for portal access- Throw the error
            //throw new EbayRegistrationHandlerException(System.Label.Err_UserNotEligible); 
            throw new EbayRegistrationHandlerException( getMessage(isDE,'LoginErrorMsg_3') );
        }

        // String permSets = 'Seller_Portal_Baseline_Account_Contact_Access'; //default for both DE and NA
        // if(findSeller <> null)
        // {
        //     //seller is eligible for NA Portal - process create Portal User
        //     //check if eligible for NA
        //     String ssFilter = ' AND ('+ mapSetting.get(ELIGBILE_CHECK_NA) +') ';             
        //     Account[] sellersToVerify = Database.query(soqlSeller + ssFilter );
        //     permSets += (sellersToVerify.isEmpty() ? '' : ';NA_Seller_Portal_Deals'); //additional permset if elibile for NA DEAL. to be assigned by other flow/trigger
        //    // system.debug('---NA permSets: '+permSets);
        //     return prepareUser(findSeller.Id,data,PORTAL_NA,permSets);
        // }else  
        // {
        //     //2,not NA then DE?
        //     findSeller = checkEligible(DE_META_IDENTIFIER,mapSetting,sellerId);
        //     if(findSeller <> null) 
        //     {
        //         //seller is eligible for DE Portal - process create Portal User
        //         //check if eligible for DEAL
        //         String ssFilter = ' AND ('+ mapSetting.get(ELIGBILE_CHECK_DE) +') ';             
        //         Account[] sellersToVerify = Database.query(soqlSeller + ssFilter );
        //         permSets += ( sellersToVerify.isEmpty() ? '' : ';DE_Seller_Portal_Deals');   //additional permset if elibile for DE DEAL. to be assigned by other flow/trigger
        //         //system.debug('---DE permSets: '+permSets);
        //         return prepareUser(findSeller.Id,data,PORTAL_DE,permSets);

        //     }else 
        //     {
        //         //seller not eligible for neither NA or DE - Throw the error
        //         throw new EbayRegistrationHandlerException(System.Label.Err_UserNotEligible); 
        //     }

        // }
    }

    private User prepareUser(String accId, Auth.UserData data,String profileName,String permSets)
    {  
        Contact[] conts = [Select Id,firstName,LastName,Email From Contact Where AccountId =:accId AND RecordTypeId=:CONTACT_DWH_RTID order by Primary_Contact__c  desc LIMIT 1];
       
        if(conts.isEmpty())
        {
            throw new EbayRegistrationHandlerException('No valid contact!');  // may never reach in real case
        }
         
        Profile prof = [Select Id From Profile Where Name=:profileName];
        Profile_Mapping__mdt pmapping = [Select Id,User_Currency__c,User_Language__c,User_Locale__c,timeZoneSidKey__c From Profile_Mapping__mdt Where MasterLabel=:profileName];

        User userNew = new User();        
        userNew.username = conts[0].email + PORTAL_SUFFIX;
        userNew.email = conts[0].email;
        userNew.lastName = conts[0].lastName;
        userNew.firstName = conts[0].firstName;
        String alias = data.username;
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        userNew.alias = alias;
        userNew.languagelocalekey = pmapping.User_Language__c;
        userNew.localesidkey = pmapping.User_Locale__c;
        userNew.emailEncodingKey = 'UTF-8';
        userNew.timeZoneSidKey = pmapping.timeZoneSidKey__c;//'America/Los_Angeles'; //Europe/Berlin
        userNew.profileId = prof.Id;
        userNew.ContactId = conts[0].Id;
        userNew.Permission_Sets__c = permSets;

        return userNew;
    }    

    private Account checkEligible(Set<String> setMetaIdentity, Map<String,String> mapSetting,String sellerId)
    {
        //System.debug('---checkEligible: '+sellerId + ' - '+ setMetaIdentity);
        List<String> setFilters = new List<String>();
        for(String meta : setMetaIdentity)
        {
            //setFilters.add(mapSetting.get(meta));
            String naFilter = ' AND ('+ mapSetting.get(meta) +') ';
            //System.debug('--naFilter: '+naFilter);
            Account[] sellers = Database.query(soqlSeller + naFilter );
            if(!sellers.isEmpty())
            {
                return sellers[0];
            }
        }     
        //System.debug('---checkEligible: KO!!!');
        return null;
    }

    private Map<String,String> getMetaSetting()
    {
        Map<String,String>  mapSetting = new Map<String,String>();
        for(Seller_Portal_Setting__mdt setting: [Select Id,DeveloperName,Filter_Values__c from Seller_Portal_Setting__mdt where DeveloperName  =:ELIGBILE_CHECK_PORTAL])
        {
            mapSetting.put(setting.DeveloperName,setting.Filter_Values__c);
        }
        return mapSetting;
    }

    private Boolean isFromDESite()
    {
        return System.Label.SEP_Domain_DE.contains(URL.getSalesforceBaseUrl().getHost());
    }
    //SRONG: 03.05.2022 : US-0011083 - SSO Adjustments for Linked Accounts
    // Add dynamic parameter MessageName
    private String getMessage(Boolean isDE, String messageName)
    {
        for(Seller_Portal_Global_Variables__mdt tmp: [SELECT DeveloperName, Value__c, Value_in_German__c FROM Seller_Portal_Global_Variables__mdt WHERE DeveloperName =:messageName])
        {
            //return isDE?tmp.Value_in_German__c : tmp.Value__c;
            return tmp.Value__c;
        }

        //never reach
        return 'Cannot find the user. For help, contact your administrator..';
    }

    class EbayRegistrationHandlerException extends Exception {}
}