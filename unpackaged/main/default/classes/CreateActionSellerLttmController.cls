/*********************************************************************************************************************************
@ Class:         CreateActionSellerLttmController
@ Version:       1.0
@ Author:        Sreymeas Nao (sreymeas.nao@gaea-sys.com)
@ Purpose:       US-0007429 - [LTTM] - Create Actions for LTTM Sellers in Light touch category cohort
@				 Controller for aura: CreateActionSellerLttm
@				 US-0008799 Modified method apexInitActionTemplateList
@				 Controller for VF Page: CreateActionForCohortSeller
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:  	20.04.2020 / Sreymeas Nao (sreymeas.nao@gaea-sys.com) / Created the class.
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:	06.07.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / US-0007809 Modified method apexInitActionTemplateList
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:	23.10.2020 / Sim Ratha (ratha.sim@gaea-sys.com) / US-0008439 - [US] Seller Management US & CA Added to Country for Action Template
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:	13.01.2021 / Mony Nou (mony.nou@gaea-sys.com)/ US-0008799 Modified method apexInitActionTemplateList
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:	16.07.2021 / Mony Nou (mony.nou@gaea-sys.com)/ US-0009960 Modified method apexSaveActions
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:	05.08.2021 / Mony Nou (mony.nou@gaea-sys.com)/ US-0010084 
				:   05.05.2022 / Loumang SENG /US-0011260 - TECHDEBT: Reflected XSS
				:   06.07.2022 / Sophal Noch / US-0012056 - Error Message thrown when attemption to Create 96 Actions to Cohort Sellers
*********************************************************************************************************************************/

public without sharing class CreateActionSellerLttmController {

	//Start-Sambath Seng 09.09.2021 US-0010209 add Detailed Description to query
	private static String SOQL_ACTION_TEMPLATE  = 'Select (Select Id,Action_Template__c,LTTM_Seller__c From Actions__r Where LTTM_Seller__c IN:bobSellerId limit 1),Id,Name,Active__c,Country__c,Description__c,Detailed_Description__c,Group__c,Lead_Segment__c,RecordTypeId,RecordType.Name,Required__c From Action_Template__c ';
	//End-Sambath Seng 09.09.2021 US-0010209 add Detailed Description to query
	/******************* CONTROLLER FOR VF PAGE *****************************/
	public String   bobId           {get;set;}
    public String   bobSellerIds    {get;set;}
    public Integer  numSelected     {get;set;}
    public String   msg             {get;set;}
    public Boolean  isError         {get;set;} //warning or error 
    public String   severity        {get;set;} // warning,info,error,confirm

    private final String RECTYPE_BOBSELLER_LTTM = System.Label.BoBSellerRecordType_LTTM;
	
	private final static Integer INSERT_ACTION_RECORD_LIMIT = Integer.valueOf(System.Label.InsertActionRecordLimit);

    public CreateActionSellerLttmController(ApexPages.StandardSetController controller) {

        List<BoB_Seller__c> bobSellers = controller.getSelected();
		//bobId = (ApexPages.currentPage().getParameters().get('id')!=null)?String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id')):'';
		bobId = String.escapeSingleQuotes(String.isBlank(System.currentPageReference().getParameters().get('id')) ? '' : ApexPages.currentPage().getParameters().get('id'));//LA-04-05-2022:US-0011260
		numSelected = (bobSellers!=null)?bobSellers.size():0;

        if (numSelected < 1) {
            isError = true; 
            msg = System.Label.BoBCreateActionError_1;
            severity = ApexPages.severity.WARNING.name();
        } else {

            Id recTypeLTTMId = ApexUtil.getRecordTypeByName('BoB_Seller__c',RECTYPE_BOBSELLER_LTTM).Id;
            
            List<Id> tmpIds = new List<Id>();
            for (BoB_Seller__c bobSeller: bobSellers) {
                if (bobSeller.RecordTypeId == recTypeLTTMId) tmpIds.add(bobSeller.Id);
            }

            bobSellerIds = (tmpIds.isEmpty())?'':String.join(tmpIds, ',');
        }
    }

    public PageReference backToListView(){

        PageReference pageRef = new PageReference('/lightning/r/'+bobId+'/related/BoB_Sellers__r/view');
        pageRef.setRedirect(true);
        return pageRef;
    }
	/******************* END OF CONTROLLER FOR VF PAGE **********************/


	/******************* CONSTANTS DEFINITION*****************************/
     public final static String SOQL_BOB_SELLER_1 = 'select Oracle_Id__c, Seller__r.Name from BoB_Seller__c';
	 public final static String SOQL_BOB_1 = 'Select Status__c, Name, RecordTypeId,Account_Manager__c,Owner.Name,owner.Email,EBH_BOBCNTRY__c From BOB__c';
	 public static final Map<String,String> mapCountry = new Map<String,String>{'3'=>'UK','77'=>'DE', '71'=>'FR','101'=>'IT','186'=>'ES','163'=>'PL',
            '99'=>'IE','193'=>'CH','146'=>'NL','23'=>'BE','15'=>'AU','168'=>'EEC-Unsited','0'=>'US','2'=>'CA'};
     /* ***************  END OF CONSTANTS DEFINITION********************/
    
	
	/***************************************************************************************************************************************
	@ Method:        apexInitActionTemplateList
	@ Version:       2.0
	@ Author:        Sophal Noch (sophal.noch@gaea-sys.com)
	@ Purpose:       US-0007809 be able to have "Select All" feature while Selecting Action Templates
	@				 to be able to view only the Child Action Templates(type LTTM) that has Parent Action IS NOT BLANK
	-----------------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 06.07.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / Modified the method. Adding Parent_Action__c != NULL when
	@																		Selecting Action Templates
	@				  13.01.2020 / Mony Nou (mony.nou@gaea-sys.com)/ US-0008799 - [LTTM Plus]Create Actions for selected Subset of Light touch cohort Sellers
	@				: 02.04.2021/ Vadhanak Voun/ US-0009354 - [Pro-Trader Hyper Care] "Create Actions" resulting in error when attempting to create 26 Actions in PROD
	@				: 26.11.2021 / SRONG TIN / US-0010820 - [PT/aSell] Pro-Trader/aSelleration: Apply missing actions across cohort sellers
	-----------------------------------------------------------------------------------------------------------------------------------------*/	 
    @AuraEnabled
	 public static Map<String,Object> apexInitActionTemplateList(String bobId, String bobSellerIds)
	 {	
	 	Map<String,Object> result = new Map<String,Object>();
	 	String sWhereBob = ' Where Id=:bobId';
		String sWhereBobSeller = ' Where BoB__c=:bobId';
		if (String.isNotBlank(bobSellerIds)) {
			List<String> lBoBSellerIds = bobSellerIds.split(',');
			sWhereBobSeller+=' And Id IN:lBoBSellerIds';
		}
		
		String recLttm = EBH_ConstantsUtility.RECTYPE_ACTION_TEMPLATE_LTTM;
	 	BOB__c bob = (BOB__c)Database.query(SOQL_BOB_1+sWhereBob)[0];
		//List<BOB_Seller__c> bobSeller = Database.query(SOQL_BOB_SELLER_1+sWhereBobSeller);
		Map<Id,BOB_Seller__c> mapBobSeller = new Map<Id,BOB_Seller__c>( (BOB_Seller__c[])Database.query(SOQL_BOB_SELLER_1+sWhereBobSeller) );
		String bobCountry = bob.EBH_BOBCNTRY__c;
        Set<Id> bobSellerId = mapBobSeller.keySet();
        String mapBobCountry = mapCountry.get(bobCountry);
	 	String sWhereTemplate  = ' Where Active__c=true And RecordType.DeveloperName=:recLttm AND Country__c =:mapBobCountry AND Parent_Action__c != NULL Order by Name';
	 	String sWhereAction  = ' Where LTTM_Seller__c IN :bobSellerId';
	 	
	 	List<Template> listPossibleActions = new List<Template>();
	 	List<Template> listSelectedAction = new List<Template>();
	 	// Set<String> setExisting = new Set<String>();
	 	// for(Action__c ac: Database.query(EBH_ConstantsUtility.SOQL_ACTION+sWhereAction))
	 	// {
	 	// 	setExisting.add(ac.Action_Template__c);
	 	// }
	 	
	 	// List<Action_Template__c> listTemplate = Database.query(SOQL_ACTION_TEMPLATE+sWhereTemplate);
	 	
	 	for(Action_Template__c acTempl: Database.query(SOQL_ACTION_TEMPLATE+sWhereTemplate))
	 	{
	 		Template tmp = new Template(acTempl);
	 		tmp.isRequired = acTempl.Required__c;
	 		//tmp.isExisting = setExisting.contains(acTempl.Id);
			
			tmp.isExisting = (acTempl.Actions__r <> null && !acTempl.Actions__r.isEmpty());
			// SRONG TIN / 26.11.2021 / US-0010820
			if (bobSellerId.size() == 1 && tmp.isExisting) continue; //MN-05082021-US-0010084 - No longer keep the existed one
			
			tmp.template = acTempl;
			//if(tmp.isRequired || tmp.isExisting) //MN-05082021-US-0010084 - No longer keep the existed one
			if (tmp.isRequired) //MN-05082021-US-0010084 - Keep the auto select required action template as is
	 		{
	 			listSelectedAction.add(tmp); 
	 		}else
	 		{
				
	 			listPossibleActions.add(tmp);
	 		}
	 	}
	 	
	 	result.put('status','ok');
	 	result.put('listPossibleActions',listPossibleActions);
	 	result.put('listSelectedAction',listSelectedAction);
        //result.put('bobSeller',bobSeller);
		result.put('bobSellerId',bobSellerId);
		result.put('bobSellerChunkResult',ApexUtil.chunkList(new List<Id>(bobSellerId), 25));  //limit Bob Seller per save
	 	
	 	return result;
	 }
	 
     /*****************************************************************************************************************************
    @ Method:   apexSaveActions
    @ Version:  1.0
    @ Author:   Sreymeas Nao (sreymeas.nao@gaea-sys.com)
    @ Purpose:  US-0007429 - [LTTM] - Create Actions for LTTM Sellers in Light touch category cohort
	@		    Save selected new action templates
	@			Action. Name = Action Template. Name
	@		·   Action. LTTM Seller = Lookup (BoB_Seller__c) 
	@		·   Action.Owner = BoB_Seller__c. Account_Manager__c
	@		·   Action. Due Date = Today + Action template. Number of dates required
	@		·   Action.Seller = BoB_Seller__c. Seller__c
	@		·   Action (Lookup) = Action Template
	@		·   Action. Description = Action Template. Description
	@			Action. Group = Action Template. Group
    @------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String bobId: current bob id, list of selected template to be assigned
	@				  String bobSellerIds: selected BoB Sellers from Related List "Cohort Sellers" button called "Create Actions for Selected Sellers"
    @------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 21.04.2020 / Sreymeas Nao / Created the  Method.
	@				  19.01.2021 / Mony Nou (mony.nou@gaea-sys.com)/ US-0008799 - [LTTM Plus]Create Actions for selected Subset of Light touch cohort Sellers
	@				  16.07.2021 / Mony Nou (mony.nou@gaea-sys.com)/ US-0009960 - [Pro-Trader] P1 "Create Actions" button creates Duplicated Actions for Transferred sellers
	@							+ Just changed the unique key in TemplateUniqueId__c to use with Action Template Id + BoBSeller Id to avoid any duplicate creation when BoBSeller changed to new BoB
    @				  08.09.2021 / Sambath Seng (sambath.seng@gaea-sys.com)/ US-0010209 - [Pro-Trader] Action Template Description length to be increased to 32000
	@				  06.07.2022 / Sophal Noch / US-0012056 - Error Message thrown when attemption to Create 96 Actions to Cohort Sellers
	*****************************************************************************************************************************/
	 @AuraEnabled
	 public static Map<String,Object> apexSaveActions(String bobId, String bobSellerIds, List<String> selectedNewTemplates)
	 {
	 	Map<String,Object> mapResult = new Map<String,Object>();
	 	String sWhereBob = ' Where Id=:bobId';
        String sWhereBobSeller = ' Where BoB__c=:bobId';
		if (String.isNotBlank(bobSellerIds)) {
			List<String> lBoBSellerIds = bobSellerIds.split(',');
			sWhereBobSeller+=' And Id IN:lBoBSellerIds';
		}
        Set<String> bobSellerId = new Set<String>();
	 	BOB__c bob = (BOB__c)Database.query(SOQL_BOB_1+sWhereBob)[0];
	 	List<BOB_Seller__c> bobSeller = Database.query(SOQL_BOB_SELLER_1+sWhereBobSeller);
        //System.debug('bobSeller>>>'+);
        String sWhereTemplate = ' Where Id IN:selectedNewTemplates';
		//Start-Sambath Seng 09.09.2021 US-0010209 change from EBH_ConstantUtility.SOQL_ACTION_TEMPLATE to SOQL_ACTION_TEMPLATE
	 	Map<Id,Action_Template__c> mapTemplate = new Map<Id,Action_Template__c>((List<Action_Template__c>)Database.query(SOQL_ACTION_TEMPLATE+sWhereTemplate));
		//End-Sambath Seng 09.09.2021 US-0010209 change from EBH_ConstantUtility.SOQL_ACTION_TEMPLATE to SOQL_ACTION_TEMPLATE
		 List<Action__c> listActionToCreate = new List<Action__c>();
	 	for(String templateId : selectedNewTemplates)
	 	{
            for(BOB_Seller__c oneBobSeller : bobSeller){
                listActionToCreate.add(
	 			new Action__c(Name = mapTemplate.get(templateId).Name,
	 				LTTM_Seller__c = oneBobSeller.Id,
	 				OwnerId = bob.OwnerId,
                    Managed_Seller__c = oneBobSeller.Seller__c,
	 				//Due_Date__c,
	 				Action_Template__c = templateId,
	 				RecordTypeId = ApexUtil.getRecordTypeByName('Action__c',EBH_ConstantsUtility.RECTYPE_ACTION_TEMPLATE_LTTM).Id,
	 				// TemplateUniqueId__c = bobId+'_'+templateId+'_'+oneBobSeller.Id
					 TemplateUniqueId__c = templateId+'_'+oneBobSeller.Id, //MN-16072021-US-0009960
					Detailed_Description__c = mapTemplate.get(templateId).Detailed_Description__c //Sambath Seng-08/09/2021-US-0010209
                 )
               );
            }
	 	}
	 	try
	 	{
			if(listActionToCreate.size() > INSERT_ACTION_RECORD_LIMIT ){mapResult.put('status','ko');mapResult.put('error',System.Label.ErrorInsertActionsAboveLimitation);return mapResult;} // Sophal Noch / 06.07.2022 / US-0012056 : record insert limit is 10000.
	 		upsert listActionToCreate TemplateUniqueId__c;
	 		mapResult.put('status','ok');
	 		
	 	}catch(DMLException dex)
    	{mapResult.put('status','ko');mapResult.put('error',dex.getDmlMessage(0));mapResult.put('errorDetail',dex.getStackTraceString());
        }catch(Exception ex){
    		mapResult.put('status','ko');mapResult.put('error',ex.getMessage());mapResult.put('errorDetail',ex.getStackTraceString());
        }
    	
	 	return mapResult;
	 }
    
	 class Template{
	 	
	 	@AuraEnabled
	 	public Action_Template__c template;
	 	
	 	@AuraEnabled
	 	public Boolean isRequired;
	 	
	 	@AuraEnabled
	 	public Boolean isExisting;
	 	
	 	@AuraEnabled
	 	public Boolean leftCheck = false; //checked but not yet moved to selection panel
	 	
	 	@AuraEnabled
	 	public Boolean rightCheck = false; //check and on the right panel
	 	
	 	@AuraEnabled
	 	public Boolean selected = false; // on the right panel could be check on uncheck
	 	
	 	@AuraEnabled
	 	public String id;
	 	
	 	public Template(Action_Template__c template)
	 	{
	 		this.id = template.Id;
	 	}
	 }
}