/*********************************************************************************************************************************
@ Class:         BatchFixBoBAccountManager
@ Version:       1.0
@ Author:        Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:       US-0007069 Create a batch job to update Managed Account records based on most recent BoB
@				 SOQL1: Update Owner, Account Manager name, Managed flag (account object) for sellers in current BoB
@				 	select Seller__c, from BoB_Seller__c where Active__c = true and Status__c in ('New','Submitted')
@				 	
@				 SOQL2: For sellers where managed flag is checked true, but they are not part of an active BoB, these sellers must be removed.
@				 	select Id from Account where EBH_BOBManaged__c = true and Id NOT IN (select Seller__c from BoB_Seller__c where Active__c = true and Status__c in ('New','Submitted') )
@----------------------------------------------------------------------------------------------------------------------------------
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 20.01.2020 / Vadhanak Voun (vadhanak.voun@gaea-sys.com) / Created the class.
@ Version:      	2.0
@ Purpose:      	US-0007676 This requirement is captured to sync below 6 fields from BoB_Seller (LTTM Seller) to the "Account"(Seller) record
@					This is required to differentiate Accounts as "LTTM" vs "Managed" and will be consumed by Analytics to display the scorecard in Customer 360 view for LTTM sellers and "Mid Group of focus Sellers" outside LTTM.
@					SOQL1: 1.Update Account(Seller) from BoB_Seller__c when LTTM Cohort(BoB__c) is of status "BoB Active" and record type = "Light_touch_Category_Cohort"
@						Query BoB_Seller__c
@						select
@							Seller__c
@						from BoB_Seller__c
@
@						where (Active__c = true and Status__c in ('New','Submitted') and 
@						Bob__r.RecordType.DeveloperName = 'Managed_Cohort')
@							OR
@						(Bob__r.Status__c = 'BoB Active' and Bob__r.RecordType.DeveloperName = 'Light_Touch_Category_Cohort')
@				 	
@					SOQL2: Update Seller record after removal of LTTM Sellers from Active BoB__c
@						For sellers where the managed flag is checked true, but they are not part of an active BoB, these sellers must be removed.
@						Updated the Query as below:
@						select Id from Account where EBH_BOBManaged__c = true and Id NOT IN
@
@ 						(select Seller__c from BoB_Seller__c where (Active__c = true and Status__c in ('New','Submitted') and Bob__r.RecordType.DeveloperName = 'Managed_Cohort') OR 
@
@						(Bob__r.Status__c = 'BoB Active' and Bob__r.RecordType.DeveloperName = 'Light_Touch_Category_Cohort'))
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history:	05.06.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / Update the class, add class property for sql string, disable old sql string, update methods
@ Change history:	11.01.2022 / Sophal Noch (sophal.noch@gaea-sys.com) / US-0011008 - Clear the seller Managed fields for removed Cohort [P2] Bug - Seller and when entire Cohort is moved to status "Cohort Inactive"
@ Change history:	06.06.2022 / Sophal Noch (sophal.noch@gaea-sys.com) / US-0011827 - Managed Country is displayed for Austria AT Cohort as UNKNOWN on Seller Record
@ Change history:   19.07.2022 / Chetra Sarom / US-0012010 - Add New Button "Deactivate Sellers" Button next to "Remove Sellers"
*********************************************************************************************************************************/

global without sharing class BatchFixBoBAccountManager implements Database.Batchable<SObject>,Schedulable{
		
	Set<String> setStatus = new Set<String>{EBH_ConstantsUtility.BOB_SELLER_STATUS_NEW,EBH_ConstantsUtility.BOB_STATUS_SUBMITTED};
	
	private final static String BOBSELLER_INACTIVE_STATUS = 'Inactive'; //@ Change history: 19.07.2022 / Chetra Sarom / US-0012010

	 String sellerSOQL = 'select Id from Account where EBH_BOBManaged__c = true '
						 +'and Id NOT IN (select Seller__c from BoB_Seller__c %sWhere1% ) ';
						 
	//String sWhere = ' where Active__c = true and Status__c in :setStatus ';
	String sWhere = ' where ((Active__c = true and Status__c in :setStatus AND Bob__r.RecordType.DeveloperName =: BOB_MANAGED_COHORT_RECORDTYPE) OR '
					+'(Bob__r.Status__c =: BOB_ACTIVE_STATUS AND Bob__r.RecordType.DeveloperName =: BOB_LIGHT_TOUCH_CATEGORY_COHORT_RECORDTYPE) OR '
					+'(Bob__r.Status__c =: BOB_INACTIVE_STATUS AND Seller__r.EBH_BOBManaged__c = false AND Bob__r.RecordType.DeveloperName IN: SET_BOB_RTYPES AND ' // 11.01.2022 / Sophal Noch / US-0011008 query inactive bob with EBH_BOBManaged__c = false but other fields are not empty.
					+'(Seller__r.OwnerId !=: INTEGRATION_USER_ID OR Seller__r.Managed_Type__c != null OR Seller__r.EBH_BOBSegment__c != null OR Seller__r.BoB_Subsegment__c != null OR Seller__r.EBH_AccountManageName__c != null OR Seller__r.EBH_BOBVertical__c != null OR Seller__r.EBH_BOBCNTRY__c != null))) ';

	// use bobSellerSOQL instead of EBH_ConstantsUtility.SOQL_BOBSELLER because EBH_ConstantsUtility.SOQL_BOBSELLER missing field Bob__r.RecordType.DeveloperName
	 String bobSellerSOQL = 'Select Managed_Type__c, EBH_BOBSegment__c,BoB_Subsegment__c,Status__c,Previous_Status__c,Id,Account_Manager__c,'
	 + 'Account_Manager__r.Name,BoB__c,BoB__r.Name,BoB__r.EBH_BOBVertical__c,BoB__r.OwnerId,BoB__r.Owner.Name,BoB__r.EBH_BOBCNTRY__c,BoB__r.Status__c,'
	 + 'Bob__r.RecordType.DeveloperName, Seller__c,Seller__r.Name,Seller__r.EBH_OracleID__c from BoB_Seller__c ';
	
	String soqlFinal = '';
	String processObject = 'bs'; //bs (bob seller) or acc	
	Set<String> processIds; //portion of ids as param to be processed for quick batch

	public final static String BOB_MANAGED_COHORT_RECORDTYPE = 'Managed_Cohort';

	public final static String BOB_LIGHT_TOUCH_CATEGORY_COHORT_RECORDTYPE = 'Light_Touch_Category_Cohort';

	public final static String BOB_ACTIVE_STATUS = 'BoB Active';

	private final static String BOB_INACTIVE_STATUS = 'BoB Inactive';

	private static final Set<String> SET_BOB_RTYPES = new Set<String>{BOB_LIGHT_TOUCH_CATEGORY_COHORT_RECORDTYPE,BOB_MANAGED_COHORT_RECORDTYPE};

	private static final String INTEGRATION_USER_ID = ApexUtil.INTEGRATION_USER_ID;

	// public final static Map<String,String> MAP_CODE_TO_COUNTRY  = new Map<String,String>{
	// 	'3'=> 'UK','77'=> 'DE','71'=> 'FR','101'=> 'IT','186'=> 'ES','163'=> 'PL','99'=> 'IE','193'=> 'CH','146'=> 'NL','23'=> 'Small Site','168'=> 'EEC-Unsited','15'=> 'AU','0'=>'US','2'=>'CA'
	// };//Update from '23'=>'BE' to '23'=>'Small Site'

	// 06.06.2022 / Sophal Noch / US-0011827 : MAP_CODE_TO_COUNTRY used here and reused in class BoBTriggerHandler. the purpose is getting value and label directly from picklist BoB__c.EBH_BOBCNTRY__c
	public static Map<String,String> MAP_CODE_TO_COUNTRY {
		get{
			if(MAP_CODE_TO_COUNTRY == null){
				MAP_CODE_TO_COUNTRY = new Map<String,String>();
				Schema.DescribeFieldResult fieldResult = BoB__c.EBH_BOBCNTRY__c.getDescribe();
				List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
				for( Schema.PicklistEntry pickListVal : ple){
					MAP_CODE_TO_COUNTRY.put(pickListVal.getValue(),pickListVal.getLabel());
				}
			}
			return MAP_CODE_TO_COUNTRY;
		}
		set{}
	}

	
	//from test
	public BatchFixBoBAccountManager()
	{		
	} 
	
	public BatchFixBoBAccountManager(String processObject)
	{
		buildSoql(processObject,null);
	}
	public BatchFixBoBAccountManager(String processObject,Set<String> processIds)
	{
		buildSoql(processObject,processIds);
	}

	/*****************************************************************************************************************************
	@ Method:   buildSoql
	@ Version:  2.0
	@ Purpose:  update soqlFinal variable depending on processObject whether it is bob seller or account.
	@			bobSellerSOQL for bob seller query and sellerSOQL for seller query.
	@			if value processIds is not empty, ad it to sql string.
	@			return soqlFinal as final sql string value.
	------------------------------------------------------------------------------------------------------------------------------
	@ Parameter:      processObject, processIds
	------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 05.06.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / update the method.
    *****************************************************************************************************************************/
	private void buildSoql(String processObject,Set<String> processIds) 
	{
		this.processObject = processObject;
		this.processIds = processIds;
		if(processObject=='bs')
		{
			// soqlFinal = EBH_ConstantsUtility.SOQL_BOBSELLER + sWhere +(processIds==null?'':' AND BoB__c IN :processIds');
			soqlFinal = bobSellerSOQL + sWhere +(processIds==null?'':' AND BoB__c IN :processIds');
			// EBH_ConstantsUtility.SOQL_BOBSELLER // missing field Bob__r.RecordType.DeveloperName, that why use sql string above instead of this
		}else if(processObject=='acc')
		{
			soqlFinal = sellerSOQL.replace('%sWhere1%',sWhere)+(processIds==null?'':' AND Id IN :processIds');
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(soqlFinal);
    }

    global void execute(Database.BatchableContext pBc, List<SObject> scope){
		Map<String,Account> mapSellerToUpdate = new Map<String,Account>();
    	if(processObject=='bs')
		{
			//Update Owner, Account Manager name, Managed flag (account object) for sellers in current BoB
			 for(Integer i=0;i<scope.size();i++)
			 {
			 	BoB_Seller__c bs = (BoB_Seller__c)scope[i];
			 	Account acc = new Account(Id=bs.Seller__c);
				//@ Change history: 19.07.2022 / Chetra Sarom / US-0012010
				if(bs.Bob__r.Status__c == BOB_INACTIVE_STATUS || (bs.Status__c == BOBSELLER_INACTIVE_STATUS && bs.BoB__r.RecordType.DeveloperName == BOB_LIGHT_TOUCH_CATEGORY_COHORT_RECORDTYPE)){ // 11.01.2022 / Sophal Noch / US-0011008 clear fields for inactive bob  // 
					mapSellerToUpdate.put(bs.Seller__c,assignValueToSeller(acc,null));
				}else{
					mapSellerToUpdate.put(bs.Seller__c,assignValueToSeller(acc,bs));
				}
				//@ end : 19.07.2022 / Chetra Sarom / US-0012010
			 	
			 }
			 
		}else if(processObject=='acc')
		{
			//For sellers where managed flag is checked true, but they are not part of an active BoB, these sellers must be removed.
			 for(Integer i=0;i<scope.size();i++)
			 {
			 	Account acc = (Account)scope[i];
			 	mapSellerToUpdate.put(acc.Id,assignValueToSeller(acc,null));
			 }
		}
		
		try
		{
			update mapSellerToUpdate.values();
		}catch(Exception ex)
		{
			EBH_ApexLogger.logError(new List<Exception> { ex }, 'BatchFixBoBAccountManager','execute');
		}
		
	}
	


    
    private Account assignValueToSeller(Account acc,BoB_Seller__c qBS)
    {
		acc.EBH_BOBManaged__c = qBS==null?false: true;
		//acc.EBH_BOBCNTRY__c  =  qBS==null?null:EBH_ConstantsUtility.MAP_CODE_TO_COUNTRY.containsKey(qBS.BoB__r.EBH_BOBCNTRY__c)?EBH_ConstantsUtility.MAP_CODE_TO_COUNTRY.get(qBS.BoB__r.EBH_BOBCNTRY__c):'Unknown';
		acc.EBH_BOBCNTRY__c  =  qBS==null?null:MAP_CODE_TO_COUNTRY.containsKey(qBS.BoB__r.EBH_BOBCNTRY__c)?MAP_CODE_TO_COUNTRY.get(qBS.BoB__r.EBH_BOBCNTRY__c):'Unknown';
		acc.EBH_BOBVertical__c = qBS==null?null: qBS.BoB__r.EBH_BOBVertical__c;
		acc.EBH_BOBSegment__c =  qBS==null?null: qBS.EBH_BOBSegment__c;
		//acc.BoB_Subsegment__c =  qBS==null?null: qBS.BoB_Subsegment__c; //TH: 19/03/2021 : US-0009127 - [BoB Clean up]Hide "Managed Sub segment" from BoB Seller and Customer 360
		acc.BoB_Subsegment__c =  qBS==null?null: qBS.BoB_Subsegment__c; // 03.02.2022 / Sophal Noch / US-0011081 - [Bug]Clear the BoB_Subsegment__c in Account and Cohort Seller once the Cohort is Inactivated or when Cohort Seller is removed
		acc.EBH_AccountManageName__c = qBS==null?null:qBS.Account_Manager__r.Name;
		acc.Managed_Type__c = qBS==null?null:qBS.Managed_Type__c;//TH: 19/06/2020 : US-0007674 - Add new field "Managed Type" in Account and sync values with BoB_Seller__c

		acc.From_BoB__c  = true; //NK:22/10/2018: EPH-6623
		if(qBS==null)
		{
			acc.OwnerId = INTEGRATION_USER_ID; 
		}else
		{
			if(String.isNotBlank(qBS.Account_manager__c))
            {
             	acc.OwnerId = qBS.Account_manager__c;
            }
		}
		return acc;
    }
    
    global void execute(SchedulableContext sc) { 
    	//when scedueler start, BS start first
        BatchFixBoBAccountManager b = new BatchFixBoBAccountManager('bs');
        Database.executeBatch(b);
    }   
    
    global void finish(Database.BatchableContext pBc){
		if(processObject=='bs' && !Test.isRunningTest()) //next step for acc (Seller that has flag checked but not particiate in any Active BoB)
		{
			BatchFixBoBAccountManager b = new BatchFixBoBAccountManager('acc');
			Database.executeBatch(b);
		}	
    }
}