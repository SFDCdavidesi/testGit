/*********************************************************************************************************************************
@ Class:        BoBSellerTriggerHandler
@ Version:      1.0
@ Author:       Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:      Handler for BoB_Seller__c Trigger
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 14.08.2018 / Vadhanak Voun / Created the Class.
@ Change history: 10.01.2022 / Sophal Noch / US-0011008 - Clear the seller Managed fields for removed Cohort [P2] Bug - Seller and when entire Cohort is moved to status "Cohort Inactive"
@ Change history: 15.07.2022 / Sophal Noch / US-0011996 - Call booking for Ads
@ Change history: 19.07.2022 / Chetra Sarom / US-0012010 - Add New Button "Deactivate Sellers" Button next to "Remove Sellers"
*********************************************************************************************************************************/
public without sharing class BoBSellerTriggerHandler {
	/****************************************************************************************************************************
	* CONSTANTS DEFINITION
	*****************************************************************************************************************************/
	private static String BOBSELLER_LTTM_RECORDTYPE = 'LTTM';
	private static String BOBSELLER_MANAGED_RECORDTYPE = 'Managed';
	private static String BOBSELLER_DRAFT_STATUS = 'Draft';

	private static String BOB_LTTM_RECORDTYPE = 'Light_Touch_Category_Cohort';
	public static final Set<String> SET_BOB_RTYPES = new Set<String>{BOB_LTTM_RECORDTYPE,'Managed_Cohort'};

	//@ Change history: 19.07.2022 / Chetra Sarom / US-0012010
	private final static String BOB_ACTIVE_STATUS = 'BoB Active';
	private final static String BOBSELLER_INACTIVE_STATUS = 'Inactive';
	private final static String SOQL_BOBSELLER_CHECK_BOB_ACTIVE = 'Select  BoB__r.OwnerId,BoB__r.Owner.Name, Id,BoB__c,BoB__r.Name,Seller__c,Seller__r.Name, BoB__r.Status__c, BoB__r.RecordType.DeveloperName, Status__c from BoB_Seller__c WHERE BoB__c NOT IN :setBoBIds AND Seller__c IN :setSellers';
	private final static String BOB_SELLER_STATUS_SUBMITTED = 'Submitted';
	private final static String BOB_SELLER_STATUS_DRAFT = 'Draft';
	//@ end : 19.07.2022 / Chetra Sarom / US-0012010

	/************************************END CONSTANTS DEFINITION*************************************************************/
    /*****************************************************************************************************************************
    @ Method:   assignActiveBoBFieldsToSeller
    @ Version:  1.0
    @ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:  [EPH-5727] BOB MGMT - Seller BOB Object - Fields
    @			Then the following fields now show the below based on the Active related BoB Seller record
	@
	@		Existing ?	Field Lable			FLS			Comment
	@		Existing	BoB Managed?		Checkbox	TRUE = at least 1 related BoB Seller is Active
	@		Existing	BoB Country			Read Only	Take parent BoB Country of Active BoB Seller record
	@		Existing	BoB Vertical		Read Only	Take parent BoB Vertical of Active BoB Seller record
	@		Existing	BoB Segment			Read Only	Take BoB Segment on Active BoB Seller record
	@		New			BoB Subsegment		Read Only	Take BoB Subsegment on Active BoB Seller record
	@	    
	@		Trigger: After Insert, After Update		
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<BoB_Seller__c> list of BoB Seller
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 14.08.2018 / Vadhanak Voun / Created the  Method.
    @				: 15.10.2018/ Vadhanak Voun	/ EPH-6545 BOB MGMT. - Seller Record not updated after removal of sellers from active BOB
    @				: 11.02.2020/ Vadhanak Voun / Disabled U:S-0007164: handle by batch from button, or nightly job
    *****************************************************************************************************************************/
    /*
    public static void assignActiveBoBFieldsToSeller(List<BoB_Seller__c> listBoBSellers,Map<Id,BoB_Seller__c>mapOld)
    {
    	Set<String> setSellerId = new Set<String>();
    	Set<String> setBSId = new Set<String>();
    	Boolean isUpdate = (mapOld <>null);
    	for(BoB_Seller__c bs: listBoBSellers)
    	{
    		if(!isUpdate || (isUpdate && bs.Status__c <> mapOld.get(bs.Id).Status__c)) //new or status changed//EPH-6545
    		{
    			setSellerId.add(bs.Seller__c);
    			setBSId.add(bs.Id);
    		}
    	}
    	//system.debug('>>>setSellerId: '+setSellerId);
    	if(!setSellerId.isEmpty())
    	{
    		Map<Id,Account> mapSellerToUpdate = new Map<Id,Account>();
    		Map<Id,SObject> mapAcccount = new Map<Id,SObject>(Database.query(EBH_ConstantsUtility.SOQL_BOB_SELLER));
    		for(BoB_Seller__c bs: listBoBSellers)
	    	{
	    		Account acc = mapSellerToUpdate.containsKey(bs.Seller__c)?mapSellerToUpdate.get(bs.Seller__c):(Account)mapAcccount.get(bs.Seller__c);
	    		Map<Id,BoB_Seller__c> mapChildren = new Map<Id,BoB_Seller__c>(acc.BoB_Sellers__r);
	    		BoB_Seller__c qBS = mapChildren.get(bs.Id);
	    		if(qBS.Active__c)
	    		{
	    			acc.EBH_BOBManaged__c =  true;
    				acc.EBH_BOBCNTRY__c  =  EBH_ConstantsUtility.MAP_CODE_TO_COUNTRY.containsKey(qBS.BoB__r.EBH_BOBCNTRY__c)?EBH_ConstantsUtility.MAP_CODE_TO_COUNTRY.get(qBS.BoB__r.EBH_BOBCNTRY__c):'Unknown';
    				acc.EBH_BOBVertical__c =  qBS.BoB__r.EBH_BOBVertical__c;
    				acc.EBH_BOBSegment__c =   qBS.EBH_BOBSegment__c;
    				acc.BoB_Subsegment__c =   qBS.BoB_Subsegment__c;
    				acc.From_BoB__c  = true; //NK:22/10/2018: EPH-6623
	    			mapSellerToUpdate.put(acc.Id,acc);
	    		}
	    		if(qBS.Status__c == EBH_ConstantsUtility.BOB_SELLER_STATUS_REMOVED) //restore owner to Integration User
	    		{
	    			acc.EBH_BOBManaged__c = false;
    				acc.EBH_BOBCNTRY__c  = null;
    				acc.EBH_BOBVertical__c = null;
    				acc.EBH_BOBSegment__c = null;
    				acc.BoB_Subsegment__c = null;
	    			acc.OwnerId = EBH_ConstantsUtility.INTEGRATION_USER_ID; 
	    			acc.From_BoB__c  = true; //NK:22/10/2018: EPH-6623
	    			mapSellerToUpdate.put(acc.Id,acc);
	    		}
	    	}
	    	//system.debug('>>>mapSellerToUpdate: '+JSON.serialize(mapSellerToUpdate));
    		if(!mapSellerToUpdate.isEmpty())
    		{
	    		//NK:16/12/2019:US-0006885: prevent account trigger to useless fire
	    		EBH_AccountTriggerHandler.NO_TRIGGER_RUN  = true;  
    			update mapSellerToUpdate.values();
    		}
    	}
    }
    */
    /*****************************************************************************************************************************
    @ Method:   checkBoBSellerDelete
    @ Version:  1.0
    @ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:  [EPH-5727] BOB MGMT - Seller BOB Object - Fields
    @			AC1b)
	@			Users should be able to Create/Edit
	@			Users can only delete records that are status = New. Users can NOT delete BoB Seller records in any other status
    @			Trigger: Before Delete
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<BoB_Seller__c> list of BoB Seller
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.08.2018 / Vadhanak Voun / Created the  Method.
    *****************************************************************************************************************************/
    public static void checkBoBSellerDelete(List<BoB_Seller__c> listBoBSellers)
    {
    	RecordType bobSellerRecordTypeManaged = ApexUtil.getRecordTypeByName('BoB_Seller__c',BOBSELLER_MANAGED_RECORDTYPE);
    	for(BoB_Seller__c bs: listBoBSellers)
    	{
    		 if(bs.Status__c != EBH_ConstantsUtility.BOB_SELLER_STATUS_NEW && bs.RecordTypeId == bobSellerRecordTypeManaged.Id)//TH: 05/05/2020: US-0007538 - [LTTM] "Managed Type" to be added for LTTM //Nirmala said:this msg is not developed for LTTM and we need to shown only for record type “Managed Cohort”
    		 {
    		 	bs.addError(System.Label.ErrorBoBSellerDelete);
    		 }
    	}
    }

	/*****************************************************************************************************************************
    @ Method:   removeRelatedRecordWithCohortSeller
    @ Version:  1.0
    @ Author:   Mony Nou (mony.nou@gaea-sys.com)
    @ Purpose:  US-0010407 - [BoB] Empty Seller."Owner" when Category Leads click "Remove Sellers"
    @			Trigger: Before Delete
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<BoB_Seller__c> list of BoB Seller
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 23.09.2021 / Mony Nou / Created the  Method.
	@ Change history: 10.01.2022 / Sophal Noch / Modified the Method. US-0011008
	@ Change history: 07.02.2022 / Sophal Noch / US-0011283 - [P1] Managed Cohorts are not set to inactive automatically when cloned cohort is Activated
    *****************************************************************************************************************************/
    public static void removeRelatedRecordWithCohortSeller(List<BoB_Seller__c> listBoBSellers)
    {	

		List<BoB_Seller__c> lstLTTMBoBSeller = new List<BoB_Seller__c>();
		Set<Id> setRemovedBsId = new Set<Id>();

		//Filtering for Cohort Seller that link with BoB's Record Type = "Light_Touch_Category_Cohort" only
		// for (BoB_Seller__c bs : [SELECT Seller__c FROM BoB_Seller__c WHERE Id IN:listBoBSellers AND BoB__r.RecordType.DeveloperName='Light_Touch_Category_Cohort']) {
		// for (BoB_Seller__c bs : [SELECT Seller__c FROM BoB_Seller__c WHERE Id IN:listBoBSellers AND BoB__r.RecordType.DeveloperName IN : SET_BOB_RTYPES]) { // 10.01.2022 / Sophal Noch / US-0011008 query both record types (Light_Touch_Category_Cohort, Managed_Cohort)
		for (BoB_Seller__c bs : [SELECT Seller__c FROM BoB_Seller__c WHERE Id IN:listBoBSellers AND BoB__r.RecordType.DeveloperName =: BOB_LTTM_RECORDTYPE]) { // 07.02.2022 / Sophal Noch / US-0011283 no need to run on Managed_Cohort because when bob RT = Managed_Cohort is active, other bobs will be inactive and account fields will be reset anyway.
			lstLTTMBoBSeller.add(bs);
			setRemovedBsId.add(bs.Seller__c);
		}

		if (lstLTTMBoBSeller.isEmpty()) return;

    	//MN-17092021-US-0010407 - Delete the related "Actions" tied to the Cohort Seller
		delete [SELECT Id FROM Action__c WHERE LTTM_Seller__c IN:lstLTTMBoBSeller];

		resetSellerFields(lstLTTMBoBSeller, setRemovedBsId, true); // 10.01.2022 / Sophal Noch / US-0011008 move some code to this method so the method can be reused in BoBTriggerHandler.
		 
    }

	/*****************************************************************************************************************************
    @ Method:   resetSellerFields
    @ Version:  1.0
    @ Author:   Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:  US-0011008 - Clear the seller Managed fields for removed Cohort [P2] Bug - Seller and when entire Cohort is moved to status "Cohort Inactive"
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<BoB_Seller__c> list of BoB Seller
    ------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 10.01.2022 / Sophal Noch / Create the Method
    ------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 03.02.2022 / Sophal Noch / US-0011081 - [Bug]Clear the BoB_Subsegment__c in Account and Cohort Seller once the Cohort is Inactivated or when Cohort Seller is removed
	@ Change history: 11.02.2022 / Sophal Noch / US-0011283 - [P1] Managed Cohorts are not set to inactive automatically when cloned cohort is Activated
						15.03.2022 / Acmatac SEING / US-0011473 - [P1] Managed Cohorts are not set to inactive automatically when cloned cohort is Activated
    *****************************************************************************************************************************/
	public static void resetSellerFields(List<BoB_Seller__c> lstLTTMBoBSeller, Set<Id> setAccId, Boolean allOrNone)
    {
		// this method is called from BoBSellerTriggerHandler and BoBTriggerHandler
		
		if (lstLTTMBoBSeller.isEmpty()) return;

		//MN-17092021-US-0010407 - Reset Seller fields
		// List<Account> lstAcc = new List<Account>();
		
		// 11.02.2022 / Sophal Noch / US-0011283 get all bob seller that is active regardless of record type, verticle, site
		Set<Id> setActiveBsAccId = new Set<Id>();
		for (BoB_Seller__c bs : [Select Seller__c From BoB_Seller__c Where Seller__c IN: setAccId And Active__c = true And Id NOT IN :lstLTTMBoBSeller]) {
			setActiveBsAccId.add(bs.Seller__c);
		}

		Map<Id,Account> mapAcc = new Map<Id,Account>();  // 03.02.2022 / Sophal Noch / US-0011081

		// for (BoB_Seller__c bs : [SELECT Seller__c FROM BoB_Seller__c WHERE Id IN:lstLTTMBoBSeller]) {
		for (BoB_Seller__c bs : lstLTTMBoBSeller) { // 11.01.2022 / Sophal Noch / US-0011008 use exist bobseller list, no need to requery
			if(setActiveBsAccId.contains(bs.Seller__c)) continue;
			// lstAcc.add(new Account(Id = bs.Seller__c, OwnerId = ApexUtil.INTEGRATION_USER_ID, Managed_Type__c = '', EBH_BOBManaged__c = false, EBH_BOBSegment__c = '', EBH_BOBVertical__c = '', EBH_BOBCNTRY__c='')); // 10.01.2022 / Sophal Noch / US-0011008 empty EBH_BOBVertical__c,EBH_BOBCNTRY__c
			mapAcc.put(bs.Seller__c, new Account(Id = bs.Seller__c, OwnerId = ApexUtil.INTEGRATION_USER_ID, Managed_Type__c = '', EBH_BOBManaged__c = false, EBH_BOBSegment__c = '', EBH_BOBVertical__c = '', EBH_BOBCNTRY__c='', BoB_Subsegment__c = '', EBH_AccountManageName__c = '')); // 03.02.2022 / Sophal Noch / US-0011081
		}

		if(!mapAcc.isEmpty()){
			// update lstAcc;
			// update mapAcc.values(); // 03.02.2022 / Sophal Noch / US-0011081
			//----MN-17092021-US-0010407 - Reset Seller fields

			// Acmatac SEING / US-0011473 / Update Account as partial
			Database.SaveResult[] bobSellerSR = Database.update(mapAcc.values(), allOrNone);
			List<Database.Error> listException = new List<Database.Error>();  
			for (Database.SaveResult sr : bobSellerSR) {
				// 15.07.2022 / Sophal Noch / US-0011996 : fix insert log in loop issue.
				// if (!sr.isSuccess()) {
				// 	// Operation failed, so get all errors                
				// 	EBH_ApexLogger.logError(sr.getErrors(), 'BoBSellerTriggerHandler','resetSellerFields');
				// }
				if (!sr.isSuccess()) listException.addAll(sr.getErrors());
			}
			if(!listException.isEmpty()) EBH_ApexLogger.logError(listException, 'BoBSellerTriggerHandler','resetSellerFields');
		}

	}


	/*****************************************************************************************************************************
    @ Method:   validateBoBSeller
    @ Version:  1.0
    @ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:  EPH-6416 BOB MGMT. - Duplicate Seller Rules
	@		    AC1) Duplicate Validation Rules
	@				a) As a categroy manager (BOB OWNER) when I want to add a seller to a BOB that is in status DRAFT I shouldn't be able to select the same seller
	@				again (screenshot attached) (excluding the previous version of current BOB).
	@				b) As a category manager after cloning a BOB (i.e. the BoB is in Draft mode) I shouldn't be able to add a seller that is part of another BOB with status "ACTIVE".
    @			Trigger: Before insert,before update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<BoB_Seller__c> list of BoB Seller
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 03.09.2018 / Vadhanak Voun / Created the  Method.
	@				: 03.10.2018/ Vadhanak Voun	/ EPH-6449: AC2) Seller Record Owner changes after the Account Manager field is updated  on the BoB
	@ Change history: 19.07.2022 / Chetra Sarom / US-0012010 - Add New Button "Deactivate Sellers" Button next to "Remove Sellers"
    *****************************************************************************************************************************/
    public static void validateBoBSeller(List<BoB_Seller__c> listBoBSellers,Map<Id,BoB_Seller__c> mapOld)
    {
    	//1, check duplicate seller
    	Boolean isNew = (mapOld==null);
    	Map<String,BoB_Seller__c> mapBoBSeller = new Map<String,BoB_Seller__c>();
    	Map<String,BoB_Seller__c> mapSellerBS = new Map<String,BoB_Seller__c>();
    	Set<String> setBoBSellers = new Set<String>();
    	Set<String> setBoBIds = new Set<String>();
    	Set<String> setSellers = new Set<String>();
    	Map<String,String> mapSeller_AccMgmt = new Map<String,String>();
    	List<BoB_Seller__c> listSellerAccMgrChagned = new List<BoB_Seller__c>();
    	Set<String> setCountry = new Set<String>();
    	Set<String> setUser_AM_Ids = new Set<String>(); //both old and new for query to email merge fields
    	Map<String,String> mapBoBSellerIdsChanged = new Map<String,String>();
    	for(BoB_Seller__c bs: listBoBSellers)
    	{
    		if(!isNew && bs.Account_Manager__c <> mapOld.get(bs.Id).Account_Manager__c && bs.Account_Manager__c <> null)
    		{
    			mapSeller_AccMgmt.put(bs.Seller__c,bs.Account_Manager__c);
    			mapBoBSellerIdsChanged.put(bs.Id,bs.Account_Manager__c);
    			setCountry.add(bs.BoB_Country__c);
    			setUser_AM_Ids.add(bs.Account_Manager__c);
    			setUser_AM_Ids.add(mapOld.get(bs.Id).Account_Manager__c);
    			//setUser_AM_Ids.add(bs.OwnerId);
    		}
    		if(	(!isNew && !isSellerChanged(bs,mapOld.get(bs.Id))) //update but no seller changed
    			|| (isNew && bs.Cloned__c)	//bypass clone BS: EPH-6460:CR
    		)
    		{
    			continue;
    		}
    		//created with seller, or change seller (e.g. from null) 
    		//check current working BS   		
    		if(setBoBSellers.contains(bs.Id+''+bs.Seller__c))
    		{
    			 bs.addError(System.Label.ErrorSellerDuplicate);
    		}
    		setBoBSellers.add(bs.Id+''+bs.Seller__c);
    		setBoBIds.add(bs.BoB__c);
    		setSellers.add(bs.Seller__c);
    		mapBoBSeller.put(bs.BoB__c,bs); // just keep any current object to addError for friendly msg 
    		mapSellerBS.put(bs.Seller__c,bs); //same same
    	}
    	String excludeStatus = EBH_ConstantsUtility.BOB_SELLER_STATUS_REMOVED;
    	String addionalExcusion = ' AND Status__c <> :excludeStatus ';
		//check the existing in system, ignore removed seller    	
    	for(BoB_Seller__c bs: Database.query(EBH_ConstantsUtility.SOQL_BOBSELLER_BY_BOB_AND_SELLER +addionalExcusion))
    	{
    		//TH:24/04/2020: comment out because running from batch get error : Too many retries of batch save in the presence of Apex triggers with failures: when triggers are present partial save requires that some subset of rows save without any errors in order to avoid inconsistent side effects from those triggers.
    		//mapBoBSeller.get(bs.BoB__c).addError(System.Label.ErrorSellerDuplicate+'\n'+bs.Seller__r.Name);
    		mapSellerBS.get(bs.Seller__c).addError(System.Label.ErrorSellerDuplicate+'\n'+bs.Seller__r.Name);
    	}
    	//2, check occupied seller by another Active BoB
    	//NK:12/09/2018 EPH-6467 CR: showing multiple BOB Owner
    	Set<String> setAffectBoBOwner = new Set<String>();
    	Set<String> setAffectSeller = new Set<String>();
    	Set<String> setStatus = new Set<String>{BOB_SELLER_STATUS_SUBMITTED,BOB_SELLER_STATUS_DRAFT,BOBSELLER_INACTIVE_STATUS};
		String addtionalWhere = '  AND  (Active__c = true OR BoB__r.Status__c IN :setStatus)';
    	List<BoB_Seller__c> listAffectSeller = Database.query(SOQL_BOBSELLER_CHECK_BOB_ACTIVE + addtionalWhere+addionalExcusion);
    	for(BoB_Seller__c bs: listAffectSeller)
    	{    		
    		setAffectBoBOwner.add(bs.BoB__r.Owner.Name);
    		setAffectSeller.add(bs.Seller__r.Name);
    	}
    	List<String> listOwnerTmp = new List<String>(setAffectBoBOwner);
    	List<String> listSellerTmp = new List<String>(setAffectSeller);

		//@ Change history: 19.07.2022 / Chetra Sarom / US-0012010 

    	for(BoB_Seller__c bs: listAffectSeller)
    	{
			if (!(bs.BoB__r.RecordType.DeveloperName == BOB_LTTM_RECORDTYPE && bs.BoB__r.Status__c == BOB_ACTIVE_STATUS && bs.Status__c == BOBSELLER_INACTIVE_STATUS)) { // if Seller Management record type = 'Light Touch category Cohort' and status = 'Cohort Active' and BoB_Seller__c.Status__c = 'Inactive' = system allow to created Cohort Seller
				mapSellerBS.get(bs.Seller__c).addError(System.Label.ErrorSellerPartOfActiveBoB.replace('BOB_OWNER_NAME',String.join(listOwnerTmp,','))
				+'\nAffect Seller: '+String.join(listSellerTmp,','));	
			}
    	}
		// end 19.07.2022 / Chetra Sarom / US-0012010 

    	if(!mapSeller_AccMgmt.isEmpty())
    	{
    		//assignAccountManagerToSellerOwner(mapSeller_AccMgmt);
    		sendEmailToGCXOpp(mapBoBSellerIdsChanged,setCountry,mapOld,setUser_AM_Ids);
    	}
    }
	/*****************************************************************************************************************************
    @ Method:   assignAccountManagerToSellerOwner
    @ Version:  1.0
    @ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:  EPH-6449 BOB MGMT. - Make Account manager field editable all time
	@		    AC2) Seller Record Owner changes after the Account Manager field is updated  on the BoB
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<BoB_Seller__c> list of BoB Seller
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 03.10.2018 / Vadhanak Voun / Created the  Method.
    @				: 11.02.2020/ Vadhanak Voun / Disabled U:S-0007164: handle by batch from button, or nightly job
    *****************************************************************************************************************************/
	/*
	private static void assignAccountManagerToSellerOwner(Map<String,String> mapSeller_AccMgmt)
	{
		List<Account> listSellerToUpdate = new List<Account>();
		Set<String> setUserId = new Set<String>(mapSeller_AccMgmt.values());
		//prevent EBH_AccountManagerUpdateBatch update back from text field
		 Map<Id,SObject> mapActiveUser = new Map<Id,SObject>(Database.query(EBH_ConstantsUtility.SOQL_BOB_USER_BY_ID )) ;
		for(String sellerId: mapSeller_AccMgmt.keySet())
		{
			String userId = mapSeller_AccMgmt.get(sellerId);
			if(!mapActiveUser.containsKey(userId))continue; //user maybe InActive
			listSellerToUpdate.add(new Account(Id=sellerId,OwnerId=userId,EBH_AccountManageName__c=mapActiveUser.get(userId).get('Name')+'',From_BoB__c  = true)); //NK:22/10/2018: EPH-6623
		}
		//NK:16/12/2019:US-0006885: prevent account trigger to useless fire
    	EBH_AccountTriggerHandler.NO_TRIGGER_RUN  = true;  
		update listSellerToUpdate;
	}
	*/
	private static void sendEmailToGCXOpp(Map<String,String> mapBoBSellerIdsChanged,Set<String> setCountry,Map<Id,BoB_Seller__c> mapOld,Set<String> setUserId)
	{ 
		Set<String> setBoBSellerIdsChanged = mapBoBSellerIdsChanged.keySet();
   		String templateName = 'BoB_Account_Manager_Change';
   		List<EmailTemplate>  emailTemplates = Database.query(EBH_ConstantsUtility.SOQL_BOB_EMAIL_TEMPLATE);
   		if(!emailTemplates.isEmpty())
   		{
   			List<BoB_Seller__c> listSellerAccMgrChagned = Database.query(EBH_ConstantsUtility.SOQL_BOBSELLER +' Where Id IN:setBoBSellerIdsChanged');
   			//system.debug('>>>setCountry: '+setCountry); 
   			String bobCountry = '(\''+String.join(new List<String>(setCountry),'\',\'')+'\')';
			Set<String> setGoups = new Set<String>{EBH_ConstantsUtility.BOB_GROUP_BOB_GCX_OPERATIONS};
   			List<User> listUserGCXOperation = BoBSellerViewController.getRespectiveUsers(bobCountry,setGoups);
   			//system.debug('>>>setCountry bobCountry: '+bobCountry);
   			List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>(); 
   			//Account Manager (old and new) , owner
		    Map<Id,SObject> mapUsers = new Map<Id,SObject>(Database.query(EBH_ConstantsUtility.SOQL_BOB_USER_BY_ID));
		        //system.debug('>>>listUserGCXOperation: '+listUserGCXOperation);
		        //system.debug('>>>mapUsers: '+mapUsers);
		      for(BoB_Seller__c bs: listSellerAccMgrChagned) //supports mass operation
		      {
		      	for(User u: listUserGCXOperation)
		      	{
		      		Set<String> setCountryOfUser = new Set<String>(u.BoB_Country__c.split(';'));
		      		if(setCountryOfUser.contains(bs.BoB__r.EBH_BOBCNTRY__c))
		      		{
		      			String bodHtml = emailTemplates[0].HtmlValue;
				       	 bodHtml = bodHtml.replace('{!GCX_OPP_NAME}',u.Name)
				       	 .replace('{!BOB_OWNER_NAME}',bs.BoB__r.Owner.Name)
				       	 .replace('{!SELLER_NAME}',bs.Seller__r.Name)
				       	 .replace('{!ORACLE_ID}',(bs.Seller__r.EBH_OracleID__c==null?'':bs.Seller__r.EBH_OracleID__c))
				         .replace('{!ACCOUNT_MGR_FROM}',mapOld.get(bs.Id).Account_Manager__c == null ? '' : mapUsers.get(mapOld.get(bs.Id).Account_Manager__c).get('Name')+'' )
				         .replace('{!ACCOUNT_MGR_TO}', mapUsers.get(mapBoBSellerIdsChanged.get(bs.Id)).get('Name')+'' );	
				       	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				        mail.setToAddresses(new String[]{u.Email});
				        mail.setSenderDisplayName('Hive Support');
				        mail.setSubject(emailTemplates[0].subject);
				        mail.setBccSender(false);
				        mail.setUseSignature(false); 
				        mail.setHtmlBody(bodHtml); 
				        listEmail.add(mail); 
		      		}
		      	}
		      }
		      if(!test.isRunningTest()) BoBSellerViewController.doSend(listEmail);
	   	} 
	}
	private static Boolean isSellerChanged(BoB_Seller__c bsNew, BoB_Seller__c bsOld)
	{
		return bsNew.Seller__c <> bsOld.Seller__c;
	}
	/*****************************************************************************************************************************
    @ Method:   populateBobSeller
    @ Version:  1.0
    @ Author:   Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:  US-0007354 - LTTM - Manual addition of LTTM BoB Sellers
	@ 1) On Creation /update of "BoB_Seller__c"(Managed Sellers) via Manual or Bulk upload
	@ if "Parent Seller" Field in "BoB_Seller__c" = ""
	@ Autopopulate the "BoB_Seller__c"."Parent Seller" = BoB_Seller__c"."Seller"
	@ 2) 1.1 System to auto populate
	@	BoB_Seller__c. Account_Manager__c = BOB__c. Account_Manager__c
	@	BoB_Seller__c. EBH_BOBSegment__c = "LTTM"
	@ 
    @			Trigger: Before insert,before update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<BoB_Seller__c> listBoBSellers, Map<Id,BoB_Seller__c> mapOld
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 24.03.2020 / Sovantheany Dim / Created the  Method.
    *****************************************************************************************************************************/
    public static void populateBobSeller(List<BoB_Seller__c> listBoBSellers,Map<Id,BoB_Seller__c> mapOld)
    {
    	RecordType bobRecordTypeLTTM = ApexUtil.getRecordTypeByName('BOB__c',EBH_ConstantsUtility.BOB_LTTM_RECORDTYPE);
    	RecordType bobSellerRecordTypeLTTM = ApexUtil.getRecordTypeByName('BoB_Seller__c',BOBSELLER_LTTM_RECORDTYPE);
    	Boolean isNew = (mapOld==null);
    	set<String> sBob = new Set<String>();
    	for(BoB_Seller__c bobSeller : listBoBSellers){
    		if(bobSeller.BoB__c != null && bobSeller.RecordTypeId == bobSellerRecordTypeLTTM.Id){//TH: 14/05/2020 : US-0007576 : add Condition for Record type LTTM
			 	sBob.add(bobSeller.BoB__c);
			 }
    	}
    	if(sBob.isEmpty()) return;
    	String lttmRecordTypeid = bobRecordTypeLTTM.Id;
    	String whereCl = ' where id IN: sBob and RecordTypeId =: lttmRecordTypeid';
    	Map<Id,BOB__c> mapBob = new Map<Id,BOB__c>((List<BOB__c>) Database.query(EBH_ConstantsUtility.SOQL_BOB_1 + whereCl));
    	//auto populate bobSeller.Account Manager = bob.Account Manager
    	for(BoB_Seller__c bobSeller : listBoBSellers){
    		if(!mapBob.containsKey(bobSeller.BoB__c)) continue;
    		BOB__c bob = mapBob.get(bobSeller.BoB__c);
    		if(isNew && (!Batch_BobSellerBulkCSV.isBatchBobSeller || (Batch_BobSellerBulkCSV.isBatchBobSeller && bobSeller.Account_Manager__c == null))){
    			//set default Segment//TH: Comment out 19/06/2020: US-0007674 - Add new field "Managed Type" in Account and sync values with BoB_Seller__c
    			//bobSeller.EBH_BOBSegment__c = EBH_ConstantsUtility.BOB_SELLER_SEGMENT_LTTM;
    			//auto populate bobSeller.Account Manager = bob.Account Manager
    			bobSeller.Account_Manager__c = bob.Account_Manager__c;
    		}
    		//set "Parent Seller" = seller if Parent Seller is empty
    		if(bobSeller.Parent_Seller__c == null && bobSeller.Seller__c <> null && (isNew || (!isNew && bobSeller.Seller__c <> mapOld.get(bobSeller.Id).Seller__c)) ){
    			bobSeller.Parent_Seller__c = bobSeller.Seller__c;
    		}
    	}
    }


	/*****************************************************************************************************************************
    @ Method:   populateSchduleSlotsWithBS
    @ Version:  1.0
    @ Author:   Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:  US-0011996 - Call booking for Ads
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:     listNewBs = list of New Bob Seller, mapOldBs =  map of Old Bob Seller 
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.07.2022 / Sophal Noch / Created the  Method.
    *****************************************************************************************************************************/
	public static void populateSchduleSlotsWithBS(List<BoB_Seller__c> listNewBs,Map<Id,BoB_Seller__c> mapOldBs)
    {

		RecordType bobRecordTypeLTTM = ApexUtil.getRecordTypeByName('BoB_Seller__c',BOBSELLER_LTTM_RECORDTYPE);

		Boolean isNewOrDelete = mapOldBs == null ? true : false;
		Set<String> setUniqueId = new Set<String>();
		for(BoB_Seller__c newBs : listNewBs){

			BoB_Seller__c oldBs = !isNewOrDelete ? mapOldBs.get(newBs.Id) : null;

			// when there are changes in bob_seller__c like bob_seller__c.Account_Manager__c, User_Availability__c of Old bob_seller__c.Account_Manager__c need to be re-calculated.
			if(!isNewOrDelete && validateSchduleSlotsWithBS(bobRecordTypeLTTM, true, oldBs, newBs)){
				setUniqueId.add(UserAvailabilityTriggerHandler.createUniqueId(oldBs.Account_Manager__c, oldBs.Next_Call_Schedule_Date__c));
			}

			// when there are changes in bob_seller__c like bob_seller__c.Account_Manager__c, User_Availability__c of New bob_seller__c.Account_Manager__c need to be re-calculated.
			if((!isNewOrDelete && validateSchduleSlotsWithBS(bobRecordTypeLTTM, true, newBs, oldBs)) || (isNewOrDelete && validateSchduleSlotsWithBS(bobRecordTypeLTTM, false, newBs, null))){
				setUniqueId.add(UserAvailabilityTriggerHandler.createUniqueId(newBs.Account_Manager__c, newBs.Next_Call_Schedule_Date__c));
			}

		}

		if(!setUniqueId.isEmpty()) UserAvailabilityTriggerHandler.calculateSlotsFromRelatedObj(setUniqueId, false, true);

	}

	private static Boolean validateSchduleSlotsWithBS(RecordType recType, Boolean isCompareField, BoB_Seller__c targetBs, BoB_Seller__c comparedBs){
		return ((targetBs.RecordTypeId == recType.Id && targetBs.Account_Manager__c != null && targetBs.Next_Call_Schedule_Date__c != null && targetBs.Time_Slot__c != null)
				&& (!isCompareField || (isCompareField && (targetBs.RecordTypeId != comparedBs.RecordTypeId || targetBs.Account_Manager__c != comparedBs.Account_Manager__c || targetBs.Next_Call_Schedule_Date__c != comparedBs.Next_Call_Schedule_Date__c || targetBs.Time_Slot__c != comparedBs.Time_Slot__c))));
	}


}