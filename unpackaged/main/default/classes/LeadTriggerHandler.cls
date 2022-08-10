/*********************************************************************************************************************************
@ Class:          LeadTriggerHandler
@ Version:        1.0
@ Author:         Vadhanak.Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:        Handler Class for Lead Trigger
@                  [#EPH-5656] SF - GDPR - Data Deletion from Leads Object
@                  So in summary the unique identifer between Lead Object and contact record should be 
@
@				  Cases
@					CHECK IF eBay ID (from Lead Object) =  Business Name (from Contact Record) 
@					IF NOT THEN 
@					CHECK  Oracle ID (from Lead Object) = Oracle ID (from related seller) 
@					IF NOT THEN 
@					EMAIL (from Lead Object) = Primary Email (from Contact Record)
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 12.06.2018 / Vadhanak.Voun / Created the class.
                  24.03.2020 / Acmatac SEING / Created the moveTask_LeadProject Method.
                  14.01.20201/ Mony Nou / Modified leadOnboardingProcess Method
*********************************************************************************************************************************/
public without sharing class LeadTriggerHandler {
    public static final String ACCOUNT_SOQL = 'SELECT Id, Name, Website, EBH_VATNumber__c FROM Account ';
    public static final String PROJECT_SOQL = 'SELECT Id, Lead__c FROM EBH_Project__c';
    public static final String SOQL_TASK = 'Select EBH_ResponseCode__c,Campaign_related_Seller_Details__c, OwnerId,Owner.Name,Survey_ID__c,IsClosed,Id,EBH_CampaignMemberId__c,WhatId,WhoId,Status,Order_Priority__c,EBH_Response__c,Call_attempts__c From Task ';
    public static final String SOQL_PROJECT = 'Select Lead__c, count(Id) projectCount from EBH_Project__c';
    public static final String SOQL_OPPORTUNITY = 'SELECT Id, RecordType.DeveloperName FROM Opportunity ';
    public static final String SOQL_LEAD = 'SELECT Id, ConvertedOpportunityId, ConvertedAccount.RecordType.DeveloperName, ConvertedOpportunity.RecordType.DeveloperName FROM Lead ';
    public static final String SOQL_CAMPAIGNMEMBER = 'select id, LeadId, CampaignId from CampaignMember';

    public static final String LEAD_STATUS_QLY = 'Qualified';
    public static final String LEAD_SITE_AU = 'AU';
    public static final String LEAD_SEGMENT_SMB = 'SMB';
    public static final String LEAD_SEGMENT_ENTERPRISE = 'Enterprise';
    public static final String ACCOUNT_LEGAL_ENTITY_RT_DEVNAME = 'EBH_LegalEntity';
    public static final String OPPORTUNITY_NA_RT_DEVNAME = 'eBay_NA_Acquisition';
    public static final String LEAD_NA_RT_DEVNAME = 'eBay_NA_Acquisition';
   
    /*****************************************************************************************************************************
    @ Method:         removeLeadGDPR
    @ Version:        1.0
    @ Author:         Vadhanak Voun
    @ Purpose:        [#EPH-5656] SF - GDPR - Data Deletion from Leads Object
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      Contacts:      Contacts sent from EBH_ContactTriggerHandler.removeGDPRContact()  
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 12.08.2018 / Vadhanak Voun / Created the  Method.
    *****************************************************************************************************************************/
    public static void removeLeadGDPR(Set<String> setAccountIds,Set<String> setEmails)
    {
    	Set<String> setEbayIds = new Set<String>();
    	Set<String> setOracleIds = new Set<String>();
    	for(Account a: Database.query(EBH_ConstantsUtility.SOQL_ACCOUNT))
    	{
    		setEbayIds.add(a.Name);
    		if(a.EBH_OracleID__c<>null)setOracleIds.add(a.EBH_OracleID__c);
    	}
    	//system.debug('removeLeadGDPR>>>setAccountIds:'+setAccountIds+'>>>setEmails:'+setEmails+'>>>setEbayIds:'+setEbayIds+'>>>setOracleIds:'+setOracleIds);  
    	List<Lead> listLeads = Database.query(EBH_ConstantsUtility.SOQL_LEAD);
    	for(Lead l: listLeads)
    	{
    		doRemoveData(l);
    	}
    	if(!listLeads.isEmpty())
    	{
    		try
    		{
    			update listLeads;
    		} catch(Exception ex) {
                EBH_ApexLogger.logError(new List<Exception> { ex }, 'LeadTriggerHandler', 'removeLeadGDPR');
            } 
    	}
    }
	/*****************************************************************************************************************************
    @ Method:         changeConvertedContactRecordType
    @ Version:        1.0
    @ Author:         Acmatac SEING
    @ Purpose:        US-0018712	After convert Lead, Seller record doesn't populate values for some fields
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      Contacts:      Contacts sent from EBH_ContactTriggerHandler.removeGDPRContact()  
	@ Event:	 	  before update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 4.10.2019 / Acmatac SEING / Created the  Method.
    *****************************************************************************************************************************/
    public static void changeConvertedContactRecordType(List<Lead> lstNewLead){
		Set<Id> sContactId = new Set<Id>();
		for(Lead oLead : lstNewLead){
			if (oLead.IsConverted){
				sContactId.add(oLead.ConvertedContactId);
			}
		}
		List<Contact> lstContact = new List<Contact>();
        Id contactRTManual= Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('EBH_MANUAL').getRecordTypeId();
		for(Contact oCont : [SELECT Id FROM Contact WHERE Id IN: sContactId]){
			oCont.RecordTypeId = contactRTManual;
			lstContact.add(oCont);
		}
		if(!lstContact.isEmpty()){
			update lstContact;
		}
    }
    private static void doRemoveData(Lead l)
    {
    	l.Salutation = 'deleted';
    	l.FirstName = 'deleted';
    	l.LastName = 'deleted';
    	l.Suffix = 'deleted';
    	l.Title = 'deleted';
    	l.Email = 'deleted@deleted.com';
    	l.Phone = 'deleted';
    	l.MobilePhone = 'deleted';
    	l.EBH_PreferredContactTime__c = 'deleted';
    	l.Website = 'deleted';
    	l.GDPR_Removed__c = true;
    }
     /*****************************************************************************************************************************
    @ Method:         validateAUSMBLead
    @ Version:        1.0
    @ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:        US-0006886 [AU] Approval Process for eBay AU SMB Project with lead Source "Self Gen"
    @ Rule 2 ->When Lead: Record Type EQUALS eBay AU SMB AND Lead Source = "Self Gen" and isapproved = "False"
    @ When attempting to set the Lead Status to "Qualified" throw the below error.
    @ Should NOT allow the Self Gen Leads to be qualified until they are approved.
    @ "Please submit the Lead for Approval."
    @ Note - This is applicable only for SMB Leads and not for Enterprise Leads.
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<Lead> lstNewLead
	@ Event:	 	  before update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 27.12.2019 / Sovantheany Dim / Created the  Method.
    25.03.2020 / Sovantheany Dim /Updated the methode : US-0007330 - [EU & AU] Approval Process.
    Rule 2 ->When Lead: record type "New Seller Registration Process" (previously EBH_eBayAUSMB record type) AND Lead Source = "Self Gen" and isapproved = "False" and LeadSegment__c = SMB (small medium business) and Site__c = AU
    When attempting to set the Lead Status to "Qualified" throw the below error.
    Should NOT allow the Self Gen Leads to be qualified until they are approved.
    "Please submit the Lead for Approval."
    *****************************************************************************************************************************/
    public static void validateAUSMBLead(List<Lead> lstNewLead){
    	RecordType recTypeAuSMBLead = ApexUtil.getRecordTypeByName('Lead','EBH_eBayAUSMB');
		for(Lead newLead : lstNewLead){
			if (newLead.RecordTypeId == recTypeAuSMBLead.Id && newLead.LeadSource != null && newLead.LeadSource == EBH_ConstantsUtility.LEAD_SOURCE_SELF_GEN && newLead.isapproved__c == false && newLead.Status == EBH_ConstantsUtility.LEAD_STATUS_QUALIFIED && newLead.Site__c == EBH_ConstantsUtility.LEAD_COUNTRY_AU && newLead.LeadSegment__c == EBH_ConstantsUtility.LEAD_SEGMENT_SMB){
				newLead.addError(System.label.eBayAuSBM_Err_2,false);
			}
		}
	}
	/*****************************************************************************************************************************
    @ Method:         leadOnboardingProcess
    @ Version:        1.0
    @ Author:         Acmatac SEING (acmatac.seing@gaea-sys.com)
    @ Purpose:        US-0007400 - [EU & AU] Create Legal Entity & Project & Contact
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      Map<Id, Lead> mOldLead => Old Map Lead, 
                      Map<Id, Lead> mNewLead => New Map Lead
    @ Event:	 	  after update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 20.04.2020 / Acmatac SEING / Created the  Method.
                    26.05.2020 / Acmatac SEING / US-0007584 [AU & EU] Existing Legal Entity for Lead
                                                Given that in the system there is already Legal Entity record where Lead.Company = Legal Entity. Business Name
                                                When I try to move this Lead to status "Qualified"
                                                Then I see the following error message: 
                    19.04.2020 / Sreymeas Nao / US-0007643 : [AU & EU] Only one project per Lead is possible
                    20.04.2020 / Acmatac SEING / US-0007645 [AU] Changes to AU Acquisition Process
                    08.07.2020 / Acmatac SEING / US-0007797 [EU & AU] Validation for Lead. Changes & unprioritized field
                    14.01.2021 / Mony Nou/ US-0008828 - [EU & AU] Create Legal Entity & Project & Contact. Adjustments 2
                    22.03.2022 / Acmatac SEING / US-0010974 - Users unable to qualify lead with existing related project.
    *****************************************************************************************************************************/
    public static void leadOnboardingProcess(Map<Id, Lead> mOldLead, Map<Id, Lead> mNewLead){
        Id leadNSRP_RT = ApexUtil.getRecordTypeByName('Lead', 'EBH_eBayAUSMB').Id;
        Id projEU_RT = ApexUtil.getRecordTypeByName('EBH_Project__c', 'EUOnboarding').Id;
        Id projAUSMB_RT = ApexUtil.getRecordTypeByName('EBH_Project__c', 'eBayAUSMB').Id;
        Id accLegalEntt_RT =  ApexUtil.getRecordTypeByName('Account', 'EBH_LegalEntity').Id;
        Map<Id, Lead> mapLead = new Map<Id, Lead>();
        Set<Id> legalEnttIds = new Set<Id>();
        Set<String> leadCompanys = new Set<String>();
        Set<String> leadCompanyExistings = new Set<String>();
        Set<String> projWithLead = new Set<String>();
        Set<Id> leadId = new Set<Id>();
        for(Lead oldLead : mOldLead.values()){
            Lead newLead = mNewLead.get(oldLead.Id);
            if(newLead.RecordTypeId == leadNSRP_RT && newLead.Status == LEAD_STATUS_QLY
                && oldLead.Status != newLead.Status){
                //
                mapLead.put(newLead.Id, newLead);
                leadId.add(newLead.Id);
                leadCompanys.add(newLead.Company);
                if(String.isNotBlank(newLead.LegalEntity__c)){
                    legalEnttIds.add(newLead.LegalEntity__c);
                }
            }
        }
        if(mapLead.keySet().isEmpty()) return;
        // ***** Project Creation *****
        Map<Id, Account> mLegalEntt = new Map<Id, Account>((List<Account>) Database.query(ACCOUNT_SOQL + ' WHERE Id IN: legalEnttIds'));
        //Map<Id,EBH_Project__c> projWithLead = new Map<Id,EBH_Project__c>((List<EBH_Project__c>) Database.query(EBH_ConstantsUtility.BATCH_LEAD_SQL+ ' where Lead__c IN :leadId'));
        
        for(Account oAcc : Database.query(ACCOUNT_SOQL + ' WHERE Name IN: leadCompanys ')){
            leadCompanyExistings.add(oAcc.Name);
        }

        // US-0010974 - Users unable to qualify lead with existing related project but with filtering recordtype.
        Set<String> projectFilterRT = new Set<String>{'eBayAUSMB', 'EUOnboarding'};
        
        // US-0007643 SRM: [AU & EU] Only one project per Lead is possible
        for(AggregateResult proj : Database.query(SOQL_PROJECT+ ' WHERE Lead__c IN :leadId AND RecordType.DeveloperName IN:projectFilterRT GROUP BY Lead__c')){
            mapLead.remove(String.valueOf(proj.get('Lead__c')));
        }
        List<Account> lstUpsertLegalEntt = new List<Account>();
        // Mapping Collect Legal Entity in one object with Project and Contact,
        // Purpose: To link Legal Entity to them later after inserted
        List<LegalEntityMappingWrapper> lstLegEnttMapping = new List<LegalEntityMappingWrapper>();
        
        // To Map between Lead and Project
        // Purpose: To move Task from Lead to Project later after Project inserted
        Map<String, EBH_Project__c> mLeadProj = new Map<String, EBH_Project__c>();
        for(Lead oLead : mapLead.values()){
            EBH_Project__c oProj = mappingLeadProject_Qualified(oLead);

            // If Site__c = AU then create project record of type “AU Onboarding”
            if(oLead.Site__c == LEAD_SITE_AU){    
                oProj.RecordTypeId = projAUSMB_RT;
            }
            // If  Site__c DOES NOT EQUAL AU , then create project record of type “EU Onboarding”
            else{
                oProj.RecordTypeId = projEU_RT;
                oProj.Priority__c = oLead.Priority__c; //AMT: 08/07/2020:US-0007797
            }
            oProj.Lead__c = oLead.Id;
            
            // ***** Legal Entity Creation *****
            Account oAcc = new Account(RecordTypeId=accLegalEntt_RT);
            LegalEntityMappingWrapper legalEnttMapping = new LegalEntityMappingWrapper();
            // If Lead.Legal Entity is not empty, then relate this Legal Entity to the newly created project
            // And prepopulate : Website, EBH_VATNumber__c
            if(String.isNotBlank(oLead.LegalEntity__c) && mLegalEntt.containsKey(oLead.LegalEntity__c)) {
                oAcc = mLegalEntt.get(oLead.LegalEntity__c);
                oAcc.Website = String.isBlank(oAcc.Website) ? oLead.Website : oAcc.Website;
                oAcc.EBH_VATNumber__c = String.isBlank(oAcc.EBH_VATNumber__c) ? oLead.VAT_Number__c : oAcc.EBH_VATNumber__c;
                oProj.LegalEntity__c = oAcc.Id;
            }
            // Lead.Legal Entity is empty, then create a new Legal Entity and relate it to a project
            else{
                // @AMT, US-0007584 [AU & EU] Existing Legal Entity for Lead, If any LegalEntity Exist, throw error and skip the event
                if(leadCompanyExistings.contains(oLead.Company)){
                    oLead.addError(Label.LeadAccount_Duplicate_ErrorMsg);
                    continue;
                }
                oAcc.Name = oLead.Company;
                oAcc.OwnerId = UserInfo.getUserId();
                oAcc.EBH_BillingStreet__c = oLead.Street;
                oAcc.EBH_BillingCity__c = oLead.City;
                oAcc.EBH_BillingCountry__c = oLead.Country;
                oAcc.EBH_BillingPostalCode__c = oLead.PostalCode;
                oAcc.Website = oLead.Website;
                oAcc.EBH_VATNumber__c = oLead.VAT_Number__c;
            }
            // ***** Contact Creation *****
            Contact oCont = new Contact(
                FirstName = oLead.FirstName,
                MiddleName = oLead.MiddleName,
                LastName = oLead.LastName,
                Title = oLead.Title,
                Email = oLead.Email,
                Phone = oLead.Phone,
                MobilePhone = oLead.MobilePhone,
                RecordTypeId = ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL').Id
            );
            // Legal Entity
            lstUpsertLegalEntt.add(oAcc);
            // Project
            mLeadProj.put(oLead.Id, oProj);
            legalEnttMapping.legalEntt = oAcc;
            legalEnttMapping.project = oProj;
            legalEnttMapping.contact = oCont;
            lstLegEnttMapping.add(legalEnttMapping);
        }
       
        if(!lstUpsertLegalEntt.isEmpty()) upsert lstUpsertLegalEntt;
        List<Contact> lstCont = new List<Contact>();
        for(LegalEntityMappingWrapper oLEMW: lstLegEnttMapping){
            // If Lead. Legal Entity is Empty we need to create new and Link to th new Project
            if(mLeadProj.containsKey(oLEMW.project.Lead__c) && String.isBlank(oLEMW.project.LegalEntity__c)) {
                mLeadProj.get(oLEMW.project.Lead__c).LegalEntity__c = oLEMW.legalEntt.Id;
            }
            oLEMW.contact.AccountId = oLEMW.legalEntt.Id;
            lstCont.add(oLEMW.contact);
        }
        if(!lstCont.isEmpty()) insert lstCont;
        if(!mLeadProj.values().isEmpty()) insert mLeadProj.values();
        // ***** Move Task from Lead to Project *****
        List<Task> lstTask = new List<Task>();
        Set<String> leadIds = mLeadProj.keySet();
        for(Task oneTask : Database.query(SOQL_TASK + ' WHERE WhoId IN: leadIds')){
            if(mLeadProj.containsKey(oneTask.WhoId)){
                oneTask.WhatId = mLeadProj.get(oneTask.WhoId).Id;
                oneTask.WhoId = null;
                lstTask.add(oneTask);
            }
        }
        if(!lstTask.isEmpty()) update lstTask;

        // US-0008828 - [EU & AU] Create Legal Entity & Project & Contact. Adjustments 2
        Map<Id, Id> mLeadLastestCampaignId = new Map<Id,Id>(); //Key: LeadId => Value: CampaignId from the lastest CampaignMember that the lead associate to
        // Finding the latest CampaignMember of each Lead
        for (CampaignMember cm : Database.query(SOQL_CAMPAIGNMEMBER + ' WHERE LeadId IN:leadId ORDER BY LastModifiedDate DESC')) {
            if (!mLeadLastestCampaignId.containsKey(cm.LeadId)) mLeadLastestCampaignId.put(cm.LeadId, cm.CampaignId);
        }
        // Populate the above latest CampaignId to the Project that link to each Lead
        List<EBH_Project__c> lstProj = new List<EBH_Project__c>();
        for (EBH_Project__c proj : Database.query(PROJECT_SOQL + ' WHERE Lead__c IN:leadId')) {
            if (mLeadLastestCampaignId.containsKey(proj.Lead__c)) lstProj.add(new EBH_Project__c(Id=proj.Id, Campaign__c=mLeadLastestCampaignId.get(proj.Lead__c)));
        }

        if (!lstProj.isEmpty()) update lstProj;
    }
    /*****************************************************************************************************************************
    @ Method:         leadConversionNA_Validation
    @ Version:        1.0
    @ Author:         Acmatac SEING (acmatac.seing@gaea-sys.com)
    @ Purpose:        US-0008556 - [NA] Lead Conversion to Opportunity
                        Checks whether the Account Record Type of the Lead.convertedAccountId is a Legal Entity. If not, show the error message
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      mNewLead
    @ Event:	 	  after update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 09.11.2020 / Acmatac SEING / Created the  Method.
    *****************************************************************************************************************************/
    public static void leadConversionNA_Validation(Map<Id, Lead> mNewLead){
        Id leadNA_RT_Id =  ApexUtil.getRecordTypeByName('Lead', LEAD_NA_RT_DEVNAME).Id;
        Set<Id> leadIds = new Set<Id>();
        for(Lead newLead : mNewLead.values()){
            if(newLead.IsConverted && newLead.RecordTypeId == leadNA_RT_Id && String.isNotBlank(newLead.ConvertedAccountId)){
                leadIds.add(newLead.Id);
            }
        }
        if(!leadIds.isEmpty()){
            String whereSOQL = ' WHERE Id IN: leadIds';
            for(Lead oLead : Database.query(SOQL_LEAD + whereSOQL)){
                if(oLead.ConvertedAccount.RecordType.DeveloperName != ACCOUNT_LEGAL_ENTITY_RT_DEVNAME){
                    mNewLead.get(oLead.Id).addError(Label.LEAD_CONVERSION_NA_VALIDATION_ERROR_ACC_MSG);
                }
            }
        }
	}
    
    /******************************************  PRIVATE METHOD  ***********************************************************/

    private static EBH_Project__c mappingLeadProject_Qualified(Lead oLead){
        return new EBH_Project__c(
            OwnerId = oLead.OwnerId,
            Name = ('Onboarding '+ oLead.Site__c + ' ' + oLead.Company).left(80),
            OracleID__c = oLead.EBH_OracleID__c,
            Vertical__c = oLead.EBH_Vertical__c,
            LeadSegment__c = oLead.LeadSegment__c,
            LeadSource__c = oLead.LeadSource,
            OtherLeadSource__c = oLead.OtherLeadSource__c,
            Campaign__c = oLead.Campaign__c,
            ABNVATNumber__c = oLead.VAT_Number__c,
            Website__c = oLead.Website,
            OtherMarketPlaces__c = oLead.EBH_OtherMarketplaces__c,
            OnlineRank__c = oLead.OnlineRank__c,
            Comments__c = oLead.EBH_CommentsBusinessReview__c,
            Shopping_Card__c = oLead.Shopping_Card__c,
            ShippingTechnology__c = oLead.ShippingTechnology__c,
            Theoretical_Revenue__c = oLead.TheoreticalRevenue__c,
            CurrencyIsoCode = oLead.CurrencyIsoCode,
            Integration_partner__c = oLead.Integration_partner__c,
            Site__c = oLead.Site__c,
            Points__c = oLead.Points__c,
            Main_Meta_Category__c= oLead.Main_Meta_Category__c//TH: 19/06/2020:US-0007644 - [AU & EU] Meta Category
        );
    }
    private class LegalEntityMappingWrapper{
        Account legalEntt;
        EBH_Project__c project;
        Contact contact;
        public LegalEntityMappingWrapper(){
            this.legalEntt = new Account();
            this.project = new EBH_Project__c();
            this.contact = new Contact();
        }
    }
}