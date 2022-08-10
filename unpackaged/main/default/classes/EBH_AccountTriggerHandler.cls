/*********************************************************************************************************************************
@ Class:          EBH_AccountTriggerHandler
@ Version:        1.0
@ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
@ Purpose:        Handler Class for Account Trigger
                  EPH-5 : Customer Management
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 08.05.2017 / JOY MONDOL / Created the class.
                  29.03.2018 / Neha Lund / Modified as part of EPH-5459 to replace <OWNER_NAME> in email with Owner Name
                                           for Urgency email notifications
                  28.07.2021 / Mony Nou / US-0009966 - [EU][GROWTH PORTAL] Deactivate email alert "DE Deals Terms & Conditions V1"
                  28.04.2022 / Loumang SENG / US-0011388 - Deactivate Contact Quality Task creation in the Seller Record
*********************************************************************************************************************************/

public with sharing class EBH_AccountTriggerHandler {
    
    /*****************************************************************************************************************************
    @ Author:   Vadhanak Voun
    @ Purpose:  US-0006885 Hypercare - BoB Activation is not working
    @			To preven cpu exceed, from BoB activation that cause to update all the related account's fields. no logic related to this update; so no need trigger involved
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 16.12.2019 /Vadhanak Voun/ Created the  flag.
    *****************************************************************************************************************************/
    public static Boolean NO_TRIGGER_RUN = false;
    
    /*****************************************************************************************************************************
    @ Method:         updateCustomRollUp
    @ Version:        1.0
    @ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
    @ Purpose:        EPH-1796 : Updates custom roll ups on account (record type: Legal Entity) from all child accounts 
                      across one level of seller hierarchy and child legal entities records for the following fields:
                       - GMV
                       - Revenue 
                       - Sold Items
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      accounts:      accounts from the trigger scope
                      accountOldMap: accounts old map from the trigger scope
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 08.05.2017 / JOY MONDOL / Created the  Method.
    *****************************************************************************************************************************/
    public static void updateCustomRollUp(List<Account> accounts, Map<Id, Account> accountOldMap) {
        
        Set<Id> parentIds = new Set<Id>();    //distinct parent ids of the accounts in trigger scope
        List<Account> parents;                //list of distinct parents from parentIds
        
        if(accounts != null) {
            for(Account acc : accounts) { 
            
                //get distinct parent ids from trigger scope accounts and populate parentIds if any aggregate fields has changed
                if(hasRollupChanged(acc, accountOldMap)) {              
                    
                    Id pId = acc.ParentId;
                    
                    if(!String.isBlank(pId)) {
                        parentIds.add(pId); 
                    }
                }
                
                //if parent lookup/legal entity lookup is changed, then both old and new parents need to be updated
                if(hasParentChanged(acc, accountOldMap)){
                    
                    Id pId = accountOldMap.get(acc.id).ParentId;
                    
                    if(!String.isBlank(pId)) {
                        parentIds.add(pId); 
                    }
                }
            }
        } else {            
            for( Account acc : accountOldMap.values()){
                
                Id pId = accountOldMap.get(acc.id).ParentId;
                
                if(!String.isBlank(pId)) {
                    parentIds.add(pId); 
                }
            } 
        }
        
        //fetch the parents and the childs and sellers from parentIds
        parents = Database.query(EBH_ConstantsUtility.ATH_PARENTCHILDQUERY);
        
        //fetch the childs and sellers of parents from parentIds and populate parentChildMap
        for(Account acc : parents) {
            
            //reset the roll ups
            acc.EBH_SoldItems__c = acc.EBH_GMVLast12Months__c = acc.EBH_RevenueLast12Months__c = EBH_ConstantsUtility.ATH_RESET;
            
            //aggregate from child accounts
            for(Account cAcc : acc.ChildAccounts) {                
                //aggregate and populate roll ups at parent
                acc.EBH_SoldItems__c += cAcc.EBH_SoldItems__c != Null ? cAcc.EBH_SoldItems__c : EBH_ConstantsUtility.ATH_RESET;
                acc.EBH_GMVLast12Months__c += cAcc.EBH_GMVLast12Months__c != Null ? cAcc.EBH_GMVLast12Months__c : 
                                                EBH_ConstantsUtility.ATH_RESET;
                acc.EBH_RevenueLast12Months__c += cAcc.EBH_RevenueLast12Months__c != Null ? cAcc.EBH_RevenueLast12Months__c : 
                                                EBH_ConstantsUtility.ATH_RESET; 
            }
        }

        //update parents
        try {
            Database.update(parents);
        } catch(Exception ex) {
            EBH_ApexLogger.logError(new List<Exception> { ex }, EBH_ConstantsUtility.ATH_CLASS, EBH_ConstantsUtility.ATH_METHOD);
        }
    }
    
    /*****************************************************************************************************************************
    @ Method:         hasRollupChanged
    @ Version:        1.0
    @ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
    @ Purpose:        Check and returns true if any of the following fields has changed in account passed in param:
                       - GMV Last 12 Months
                       - Revenue 
                       - Sold Items
                       - Legal Entity
                       - Parent
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      acc:           account to check field(s) change for
                      accountOldMap: account old map from trigger scope to compare
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        Boolean: True if any of the field changed
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 08.05.2017 / JOY MONDOL / Created the  Method.
    *****************************************************************************************************************************/
    public static Boolean hasRollupChanged(Account acc, Map<Id, Account> accountOldMap) {
        
        Account oldAcc = accountOldMap != Null ? accountOldMap.get(acc.Id) : acc;
        
        return acc.EBH_SoldItems__c != oldAcc.EBH_SoldItems__c ||
               acc.EBH_GMVLast12Months__c != oldAcc.EBH_GMVLast12Months__c ||
               acc.EBH_RevenueLast12Months__c != oldAcc.EBH_RevenueLast12Months__c ||
               acc.ParentId != oldAcc.ParentId || accountOldMap == null; 
    } 
    
    /*****************************************************************************************************************************
    @ Method:         hasParentChanged
    @ Version:        1.0
    @ Author:         Neha Lund
    @ Purpose:        Check and returns true if parent has changed in old account passed in param
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      acc:           account to check field(s) change for
                      accountOldMap: account old map from trigger scope to compare
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        Boolean: True if any of the field changed
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 08.05.2017 / NEHA LUND / Created the  Method.
    *****************************************************************************************************************************/
    public static Boolean hasParentChanged(Account acc, Map<Id, Account> accountOldMap) {
        
        Account oldAcc = accountOldMap != Null ? accountOldMap.get(acc.Id) : acc;
        
        return acc.ParentId != oldAcc.ParentId;
    }    
    
     /*****************************************************************************************************************************
    @ Method:         updateRelatedContactStatus
    @ Version:        1.0
    @ Author:         NEHA LUND
    @ Purpose:        EPH-3270 : Updates related Contacts's Status from the related Account's Status 
                      - Pending Termination
                      - Deleted
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      accounts:      accounts from the trigger scope
                      accountOldMap: accounts old map from the trigger scope
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 28.09.2017 / NEHA LUND / Created the  Method.
    *****************************************************************************************************************************/
    public static void updateRelatedContactStatus(List<Account> accounts, Map<Id, Account> accountOldMap) {
        
        Set<ID> accountIds = new Set<ID>();
        List<Contact> contactRecords  = new List<Contact>();
         //loop through trigger scope
        for(Account acc : accounts) { 
            //get distinct parent ids from trigger scope Campaigns and populate parentIds 
            if(hasStatusChanged(acc, accountOldMap)) {   
                accountIds.add(acc.Id); 
            }
        }
        
        if(!accountIds.isEmpty()){
            contactRecords = Database.query(EBH_ConstantsUtility.ATH_ACCOUNTCONTACTQUERY);
            for( Contact con: contactRecords){
                con.EBH_Status__c = con.Account.EBH_Status__c;
            }
        }
        
        //update Contacts
        try {
            Database.update(contactRecords);
        } catch(Exception ex) {
            EBH_ApexLogger.logError(new List<Exception> { ex }, EBH_ConstantsUtility.ATH_CLASS, EBH_ConstantsUtility.ATH_METHOD);
        }
         
    }
     /*****************************************************************************************************************************
    @ Method:         validateUpsert
    @ Version:        1.0
    @ Author:         NEHA LUND
    @ Purpose:        EPH-3270 : Do not upsert any accounts if the status is
                      - Deleted
                      - Pending Termination
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      accounts:      accounts from the trigger scope
                      accountOldMap: accounts old map from the trigger scope
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 28.09.2017 / NEHA LUND / Created the  Method.
    *****************************************************************************************************************************/
    public static void validateDeleteUpsert(List<Account> accounts, Map<ID, Account> accountOldMap) {
       
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(EBH_ConstantsUtility.ATH_OBJECTNAME).getDescribe().fields.getMap();
        
         //loop through trigger scope
        for(Account acc : accounts) { 
        
            //get distinct parent ids from trigger scope Campaigns and populate parentIds 
            if(!hasStatusChanged(acc, accountOldMap) && !String.isBlank(acc.EBH_Status__c) && 
               (acc.EBH_Status__c.equalsIgnoreCase(EBH_ConstantsUtility.ACRTH_TERMINATEDSTATUS) || 
                acc.EBH_Status__c.equalsIgnoreCase(EBH_ConstantsUtility.ACRTH_DELETEDSTATUS)) ) {
              
                 for(String fieldName : fieldMap.keyset()){
                     if( fieldMap.get(fieldName).getDescribe().isUpdateable())
                     acc.put(fieldName,  accountOldMap.get(acc.Id).get(fieldName));
                 }
                 
            }
        }
        
    }
     /*****************************************************************************************************************************
    @ Method:         notifyUrgencyTaskOwner
    @ Version:        1.0
    @ Author:         Neha Lund
    @ Purpose:        EPH-4122: Check and returns true if Urgency Flag is true
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      acc:           account to check field(s) change for
                      accountOldMap: account old map from trigger scope to compare
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        Void
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 26.10.2017 / NEHA LUND / Created the  Method.
    @               : 02.02.2018/ Vadhanak Voun / fixed Owner.Name by issue soql (Owner.Name is null from pure trigger)
    *****************************************************************************************************************************/
    public static void notifyUrgencyTaskOwner(List<Account> accounts, Map<ID,Account> accountOldMap){
    
        
        Set<String> setOwnerId = new Set<String>();
        for( Account acc: accounts){
            setOwnerId.add(acc.OwnerId);
         }
        Map<String,User> mapOwner = new Map<String,User>([Select Id,Name from User Where Id IN:setOwnerId]);  
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        String plainBody =' ';
        String urgencyReason, defectReason;
        for( Account acc: accounts){                   
             
            if( String.isBlank(acc.EBH_UrgencyReason__c)){
                urgencyReason ='';
            }
            else{
                urgencyReason = acc.EBH_UrgencyReason__c;
            }
            if( String.isBlank(acc.EBH_DefectReason__c)){
                defectReason ='';
            }
            else{
                defectReason = acc.EBH_DefectReason__c;
            }
            
            if(hasUrgencyFlag(acc, accountOldMap,mapOwner)){       
            
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTargetObjectId(acc.ownerId);
                email.setSubject(EBH_ConstantsUtility.TTH_URGENCYTASK);
                plainBody = EBH_ConstantsUtility.ATH_URGENCYEMAILBODY;
                if(!String.isBlank(acc.EBH_AccountManageName__c)){
                    plainBody = plainBody.replace(EBH_ConstantsUtility.ATH_OWNERNAME, acc.EBH_AccountManageName__c);
                }
                else{
                    //EPH-5459 - to fix <OWNER_NAME> issue
                    plainBody = plainBody.replace(EBH_ConstantsUtility.ATH_OWNERNAME, mapOwner.get(acc.ownerID).Name);
                }
                plainBody = plainBody.replace(EBH_ConstantsUtility.ATH_ACCOUNTNAME, acc.Name);
                plainBody = plainBody.replace(EBH_ConstantsUtility.ATH_URGENCYREASON, urgencyReason);
                plainBody = plainBody.replace(EBH_ConstantsUtility.ATH_DEFECTREASON, defectReason);
                email.setplainTextBody(plainBody);
                email.setSaveAsActivity(false);
                emailsToSend.add(email);
               
            }
        
        }
        if(!emailsToSend.isEmpty()){
            Messaging.sendEmail(emailsToSend);
        }
        
    }
    /*****************************************************************************************************************************
    @ Method:         hasUrgencyFlag
    @ Version:        1.0
    @ Author:         Neha Lund
    @ Purpose:        Check and returns true if Account Status has changed in old account passed in param
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      acc:           account to check field(s) change for
                      accountOldMap: account old map from trigger scope to compare
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        Boolean: True if any of the field changed
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 08.05.2017 / NEHA LUND / Created the  Method.
    @               : 02.02.2018/ Vadhanak Voun / fixed Owner.Name by issue soql (Owner.Name is null from pure trigger)
    @               : added param: Map<String,User> mapOwner
    @               : used map instead of: acc.Owner.Name
    *****************************************************************************************************************************/
    public static Boolean hasUrgencyFlag(Account acc, Map<Id, Account> accountOldMap,Map<String,User> mapOwner) {     
                
        Account oldAcc = accountOldMap != Null ? accountOldMap.get(acc.Id) : acc;
        
        return ((acc.EBH_UrgencyFlag__c != oldAcc.EBH_UrgencyFlag__c ||
               acc.ownerId != oldAcc.ownerID ) || accountOldMap==null ) &&
               mapOwner.get(acc.OwnerId).Name != Label.EBH_IntegrationUser &&            
               acc.EBH_UrgencyFlag__c ;
               
    }   
     /*****************************************************************************************************************************
    @ Method:         removeGDPRContact
    @ Version:        1.0
    @ Author:         NEHA LUND
    @ Purpose:        EPH-5413 : Remove GDPR contact and related contacts
                     
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      accounts:      accounts from the trigger scope
                      accountOldMap: accounts old map from the trigger scope
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 01.05.2018 / NEHA LUND / Created the  Method.
    *****************************************************************************************************************************/
    public static void removeGDPRContact(List<Account> accounts, Map<ID, Account> accountOldMap) {
                
                List<Account> removeAccounts = new List<Account>();
                
                for( Account acc: accounts){  
                    
                    if( hasGDPRRemoved(acc, accountOldMap)){
                        
                        removeAccounts.add(acc);
                    
                    }
                    
                }
                
               
                
                if(!removeAccounts.isEmpty()){
                
                   removeGDPRContacts([SELECT Email, Phone, MobilePhone, EBH_SecondaryEmail__c
                    from Contact where accountID IN : removeAccounts limit 10000], true);
               }
                    
                   
    }
     /*****************************************************************************************************************************
    @ Method:         removeGDPRContacts
    @ Version:        1.0
    @ Author:         NEHA LUND
    @ Purpose:        EPH-5413 : Remove GDPR contact and related contacts
                     
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      contacts:      contacts from the trigger scope
                      accountTrigger: boolean to have a explicit DML
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 01.05.2018 / NEHA LUND / Created the  Method.
    *****************************************************************************************************************************/
    
    public static void removeGDPRContacts(List<Contact> contacts, boolean accountTrigger){
         List<Contact> contactRecords = new List<Contact>();
                List<Contact> relatedContacts = new List<Contact>();
                Set<String> emails = new Set<String>();
                Set<String> phones = new Set<String>();
                
                
                RecordType rec = [SELECT id from RecordType where sobjectType = 'Contact' and DeveloperName = 'EBH_GDPR_Removed'];
                
                
         for(Contact con: contacts){
                        
                        con.recordTypeId =  rec.Id;
                        
                        if( con.Email != null ){
                           
                            emails.add(con.Email);
                        }
                        if(con.EBH_SecondaryEmail__c != null){
                          
                            emails.add(con.Ebh_SecondaryEMail__c);
                        }
                       
                        if( con.phone != null){
                            
                            phones.add(con.Phone);
                        }
                        if( con.MobilePhone != null){
                            phones.add(con.MobilePhone);
                        }
                        
                        con =  updateGDPRDeletedData(con);
                        if(accountTrigger)
                        contactRecords.add(con);
                    }
                     if(!contactRecords.isEmpty()){
                        update contactRecords;
                    }
        /*            
         * COMMENTED BY DHE in order to avoid unwanted deletions
         * 20190416
                    System.debug('£££££'+emails);
        
                    if( !emails.isEmpty() || !phones.isEmpty())
                    {
                       updateGDPRContacts(emails, phones, rec.ID); 
                    }
          */          
                   
    
    }
    
    public static Contact updateGDPRDeletedData(Contact con){
        
                        con.salutation = '';
                        con.EBH_ContactPreference__c = 'DELETED';
                        con.EBH_Status__c = 'Deleted';
                        con.EBH_DoNotContact__c= true;
                        con.EBH_emailOut__c = true;
                        con.EBH_MailingAddress__c = 'DELETED';
                        con.EBH_MailingCity__c = 'DELETED';
                        con.EBH_MailingCountry__c = 'DELETED';
                        con.EBH_MailingPostalCode__c = 'DELETED';
                        con.EBH_MailingStreet__c ='DELETED';
                        con.EBH_PhoneOptOut__c = true;
                        con.EBH_SecondaryEmail__c = 'DELETED@DELETED.com';
                        con.EMail = 'DELETED@DELETED.com';
                        con.FirstName = 'DELETED';
                        con.LastName  = 'DELETED';
                        con.MiddleName = 'DELETED';
                        con.Title = 'DELETED';
                        con.Suffix = 'DELETED';
                        con.MobilePhone = '###############';
                        con.HomePhone = '###############';
                        con.Phone = '###############';
                        return con;
                        
    }
    
    @future
    public static void updateGDPRContacts(Set<String> emails, Set<String> phones, String recID){
         List<Contact> contactRecords = new List<Contact>();       
        for(Contact con: [SELECT email from Contact where 
                    (Email IN :emails  OR  EBH_SecondaryEmail__c IN :emails OR MobilePhone IN :phones OR Phone IN :phones)
                     AND
                     (RecordType.DEveloperName = 'EBH_DWH' OR RecordType.DeveloperName = 'EBH_MANUAL')
                       limit 10000]){
                        
                        
                        con.recordTypeId =  recId;
                        con = updateGDPRDeletedData(con);
                        contactRecords.add(con);
                    }
                    
                
                
                if( !contactRecords.isEmpty() ){
                    Database.update(contactRecords,false);
                }
              
    }
     
     /*****************************************************************************************************************************
    @ Method:         hasGDPRRemoved
    @ Version:        1.0
    @ Author:         Neha Lund
    @ Purpose:        Check and returns true if Seller has been removed via GDPR removed
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      acc:           account to check field(s) change for
                      accountOldMap: account old map from trigger scope to compare
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        Boolean: True if any of the field changed
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 01.05.2018 / NEHA LUND / Created the  Method.
    *****************************************************************************************************************************/
    public static Boolean hasGDPRRemoved(Account acc, Map<Id, Account> accountOldMap) {
        
        Account oldAcc = accountOldMap != Null ? accountOldMap.get(acc.Id) : acc;
        
        return acc.EBH_GDPR_Removed__c != oldAcc.EBH_GDPR_Removed__c && (acc.EBH_GDPR_Removed__c || accountOldMap == null);
               
    }  
    
     /*****************************************************************************************************************************
    @ Method:         hasStatusChanged
    @ Version:        1.0
    @ Author:         Neha Lund
    @ Purpose:        Check and returns true if Account Status has changed in old account passed in param
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      acc:           account to check field(s) change for
                      accountOldMap: account old map from trigger scope to compare
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        Boolean: True if any of the field changed
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 08.05.2017 / NEHA LUND / Created the  Method.
    *****************************************************************************************************************************/
    public static Boolean hasStatusChanged(Account acc, Map<Id, Account> accountOldMap) {
        
        Account oldAcc = accountOldMap != Null ? accountOldMap.get(acc.Id) : acc;
        
        return acc.EBH_Status__c != oldAcc.EBH_Status__c;
               
    }  

/* MN-28072021-Deprecated via US-0009966
   public static void sendDealMailtoContact(List<Account> accounts,Map<Id, Account> accountOldMap) {
        
        Set<ID> accountIds = new Set<ID>();
        List<Contact> contactRecords  = new List<Contact>();
        map<String,String> maplanguages= new Map<String,String>{'ES'=>'ES','DE'=>'DE','EN-GB'=>'UK','IT'=>'IT','FR'=>'FR'};
        //EmailTemplate template = [Select Id,name from EmailTemplate where developername = 'EBH_DealsTermsConditionsV1'];
        //updated 2018 -03-08 by DHE to send emails in local languages
        
         Map<String,EmailTemplate>mapLanguageTemplate = new map<String,EmailTemplate>();
        for (EmailTemplate et : [Select Id,name,developername from EmailTemplate where developername like '%EBH_DealsTermsConditionsV1']){
        if (et.developername.indexOf('_')>=0){
            String language=et.developername.left(et.developername.indexOf('_'));
            
            mapLanguageTemplate.put(language,et);
        }
        }

         //loop through trigger scope
        for(Account acc : accounts) { 
            //get distinct parent ids from trigger scope Campaigns and populate parentIds 
            if(
               accountOldMap != null &&
               acc.EBH_DealsProgram__c != accountOldMap.get(acc.Id).EBH_DealsProgram__c &&
               acc.EBH_DealsProgram__c =='Accepted') {   
                accountIds.add(acc.Id); 
            }
        }
        
        if(!accountIds.isEmpty()){
            System.debug('####'+accountIds);
            //contactRecords = [Select I																																																		d,AccountId, Email From Contact Where AccountId in : accountIds];
            contactRecords = [Select Id,AccountId,Account.EBH_GBCulture__c, Email From Contact Where AccountId in : accountIds];
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'produkt-aktionen@ebay.de'];
            
            List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
            
            for(Contact con: contactRecords){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
                String[] toAddresses = new String[] {con.Email};
                mail.setToAddresses(toAddresses);
                mail.setTargetObjectId(Con.Id);
                mail.setWhatId(con.AccountId);
                //Updated by DHE 2018-03-08 to allow emails in different languages
                //mail.setTemplateID(template.Id);
                Id templateId;
                if (String.isNotBlank(con.Account.EBH_GBCulture__c) && maplanguages.containsKey(con.Account.EBH_GBCulture__c.toUpperCase())){
                    templateId=mapLanguageTemplate.get(maplanguages.get(con.Account.EBH_GBCulture__c.toUpperCase())).ID;
                }else{
                    //UK by default
                    templateId=mapLanguageTemplate.get(maplanguages.get('EN-GB')).ID;
                }
                mail.setTemplateID(templateId);
                mail.setSaveAsActivity(false);
               if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
                //system.debug('===>mail : '+mail);
               
                if(toAddresses[0] != null) {
                    listEmail.add(mail);
                }
            }
            
            //NK:27/03/2019: moved from the loop
            if(!listEmail.isEmpty())
            {
            	Messaging.sendEmail(listEmail);
            }
        }
    }  
*/

       /*****************************************************************************************************************************
@ Method:         createRecordtypeField
@ Author:         David Herrero
@ Purpose:        Create a field in before trigger for using duplicate rules
------------------------------------------------------------------------------------------------------------------------------
@ Parameter:      ListAccounts:       List of Accounts

------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------
@ Change history: 18-10-2018 /David Herrero / Created the  Method.
*****************************************************************************************************************************/
    public static void createRecordtypeField(List<Account>listAccounts){
        Map<id,string> mapRecordType = new Map<id,STring>();
        for(RecordType rt : [select id,developername from recordtype where sobjecttype='Account']){
            mapRecordType.put(rt.id,rt.developername);
        }
        for (Account a : listAccounts){
            //if (mapRecordType.get(a.RecordTypeId)=='EBH_Brand'){
                a.Record_Type_Text__c=mapRecordtype.get(a.RecordTypeId);    
            //}
            
        }
        
    }
    
/*****************************************************************************************************************************
@ Method:         createTask
@ Author:         Sovantheany Dim
@ Purpose:        EPH-5671 Create Contact Quality Task in Seller Record when Status = red for managed sellers
------------------------------------------------------------------------------------------------------------------------------
@ Parameter:      ListAccounts:       List of Accounts
				  mapOldAccount : map Old Accounts

------------------------------------------------------------------------------------------------------------------------------

------------------20.03.2019 /Sovantheany Dim / Created the  Method.
            :     28.04.2022/ Loumang SENG/ Deprecated via US-0011388
*****************************************************************************************************************************/
   /* public static void createTask(List<Account>listAccountNew, Map<Id, Account> mapOldAccount){
		
		List<Account>listAccounts = new List<Account>(); //list to process. only acc that changed and match the condition
		for(Account acc: listAccountNew)
		{
			if(isQualified(acc,mapOldAccount.get(acc.Id)))
			{
				listAccounts.add(acc);
			}
		}
		if(listAccounts.isEmpty())return;
		
		EmailTemplate emailTemplate = Database.query(EBH_ConstantsUtility.SOQL_EMAILTEMPLATE_CONTACTDATAUPDATETASKSELLER); 
    	
    	List<Task> lstTasks = new List<Task>();
    	List<Messaging.SingleEmailMessage> listMessage = new List<Messaging.SingleEmailMessage>();
    	for(Account acc : Database.query(EBH_ConstantsUtility.SOQL_ACCOUNT_SELLER)){
    			
    			lstTasks.add(new Task(Subject='Contact Quality Task is created',Status='Open',Priority='High',Description=system.label.Description_Task_For_Seller,WhatId=acc.Id));
    			
    			//send email if owner is not Integration User)
    			if(String.valueOf(acc.OwnerId).substring(0,15) != EBH_ConstantsUtility.INTEGRATION_USER_ID){
	    			String subject = emailTemplate.Subject.replace('{!Account.Name}',acc.Name);
	    			
		    		String sellerUrl = URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/r/Account/'+acc.Id+'/view';
		    		
		    		String body = emailTemplate.HtmlValue;
		    		body = body.replace('{!Account.Name}',acc.Name).replace('{!Account.OwnerFullName}',acc.Owner.Name).replace('{sellerUrl}',sellerUrl);
		    		if(!acc.contacts.isEmpty()){
		    			Contact contact = acc.contacts[0];
		    			body = body.replace('{Contact Name}',contact.Name).replace('{Email_Bounced__c}',String.valueOf(contact.Email_Bounced__c)).replace('{Incorrect_Phone_Number__c}',String.valueOf(contact.Incorrect_Phone_Number__c)).replace('{RecordTypeId}',contact.RecordType.Name);
		    		}
		    		
		    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					        mail.setToAddresses(new String[]{acc.Owner.Email});
					        mail.setSenderDisplayName('Hive Support');
					        mail.setSubject(subject);
					        mail.setBccSender(false);
					        mail.setUseSignature(false); 
					        mail.setHtmlBody(body);
    				listMessage.add(mail);
    			}
    			
    		 
    	}
    	
    	if(!lstTasks.isEmpty()) insert lstTasks;
    	
    	if(!Test.isRunningTest() && !listMessage.isEmpty()){ Messaging.sendEmail(listMessage);}
    }
 	
 	//NK:08/04/2019
    private static Boolean isQualified(Account accNew,Account accOld)
    {
    	if( ((accNew.EBH_BOBManaged__c <> accOld.EBH_BOBManaged__c) || accNew.Contact_Data_Quality__c <> accOld.Contact_Data_Quality__c )
    		&& accNew.Contact_Data_Quality__c <> null
    		&& EBH_ConstantsUtility.DATA_Q_CREATE_TASK.contains(accNew.Contact_Data_Quality__c.toUpperCase())
    		&& accNew.EBH_BOBManaged__c
    	)
		{
			return true;
		}    		
    	 return false;
    }   */ 
}