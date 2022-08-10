/*********************************************************************************************************************************
@ Class:         ActionCreationController
@ Version:       1.0
@ Author:        vadhanak.voun (vadhanak.voun@gaea-sys.com)
@ Purpose:       US-0007443 - [EU & AU] Create Actions
@				Controller for aura: ActionCreation
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 20.04.2020 / vadhanak.voun (vadhanak.voun@gaea-sys.com) / Created the class.
*********************************************************************************************************************************/
public without sharing class ActionCreationController{	
	public static final String RECTYPE_ACTION_TEMPLATE_SCALING = 'Scaling';
	public final static String BATCH_LEAD_SQL = 'SELECT RecordTypeId,RecordType.DeveloperName,LeadSegment__c,Site__c,OwnerId,Lead__r.Site__c,Lead__r.LeadSegment__c,EBH_Seller__c, EBH_Seller__r.Primary_Contact__r.Email, Lead__c, Lead__r.FirstName, Lead__r.LastName, Lead__r.Title, Lead__r.Email, Lead__r.Phone, Lead__r.MobilePhone, Lead__r.Street, Lead__r.City, Lead__r.Country, Lead__r.PostalCode, Lead__r.State, Lead__r.EBH_PreferredContactTime__c FROM EBH_Project__c';
	public static final String SOQL_ACTION = 'Select Id,Name,Action_Outcome__c,Action_Template__c,Completed_Date__c,Description__c,Due_Date__c,Project__c,RecordTypeId,Required__c,Status__c, Detailed_Description__c From Action__c ';
	public static final String SOQL_ACTION_TEMPLATE  = 'Select Id,Name,Active__c,Country__c,Description__c,Group__c,Lead_Segment__c,RecordTypeId,RecordType.Name,Required__c, Detailed_Description__c From Action_Template__c ';
	public static final String RECTYPE_ACTION_TEMPLATE_ACQ='Acquisition';
	/*****************************************************************************************************************************
    @ Method:   apexInitActionTemplateList
    @ Version:  1.0
    @ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:  US-0007443 - [EU & AU] Create Actions
	@		    Init list for component
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String projectId: current project id
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 17.04.2020 / Vadhanak Voun / Created the  Method.
	@ Change history: 04.04.2022 / Chetra Sarom  / US-0011551 - "Detail Description" field to be updated on Action Creation	
    *****************************************************************************************************************************/

	 @AuraEnabled
	 public static Map<String,Object> apexInitActionTemplateList(String projectId, String recTypeName)
	 {
	 	Map<String,Object> mapResult = new Map<String,Object>();
	 	
	 	String sWhereProject = ' Where Id=:projectId';
	 	EBH_Project__c project = (EBH_Project__c)Database.query(BATCH_LEAD_SQL+sWhereProject)[0];
	 	String leadCountry = project.Site__c;
	 	String leadSeg = project.LeadSegment__c;
		String recAcqa = RECTYPE_ACTION_TEMPLATE_ACQ;
		String proCountry = project.Site__c;
	 	
	 	//  = 'Select Id,Name,Active__c,Country__c,Description__c,Group__c,Lead_Segment__c,RecordTypeId,RecordType.Name,Required__c From Action_Template__c ';
	 	// = 'Select Id,Name,Action_Outcome__c,Action_Template__c,Completed_Date__c,Description__c,Due_Date__c,Project__c,RecordTypeId,Required__c,Status__c From Action__c ';
	 	String sWhereTemplate  = ' Where Active__c=true And RecordType.DeveloperName=:recAcqa AND Country__c =:leadCountry AND Lead_Segment__c=:leadSeg Order by Name';
		String sWhereTemplateScaling = ' Where Active__c=true And RecordType.DeveloperName=:recTypeName AND Country__c =:proCountry Order by Name'; 
		String sWhereAction  = ' Where Project__c=:projectId';
	 	
	 	List<Template> listPossibleActions = new List<Template>();
	 	List<Template> listSelectedAction = new List<Template>();
	 	Set<String> setExisting = new Set<String>();
	 	for(Action__c ac: Database.query(SOQL_ACTION+sWhereAction))
	 	{
	 		setExisting.add(ac.Action_Template__c);
	 	}
	 	
	 	List<Action_Template__c> listTemplate = (recTypeName == RECTYPE_ACTION_TEMPLATE_SCALING) ? Database.query(SOQL_ACTION_TEMPLATE+sWhereTemplateScaling) : Database.query(SOQL_ACTION_TEMPLATE+sWhereTemplate);
	 	
	 	for(Action_Template__c acTempl: listTemplate)
	 	{
	 		Template tmp = new Template(acTempl);
	 		tmp.isRequired = acTempl.Required__c;
	 		tmp.isExisting = setExisting.contains(acTempl.Id);
	 		tmp.template = acTempl;
	 		if(tmp.isRequired || tmp.isExisting)
	 		{
	 			listSelectedAction.add(tmp);
	 		}else
	 		{
	 			listPossibleActions.add(tmp);
	 		}
	 	}
	 	
	 	mapResult.put('status','ok');
	 	mapResult.put('listPossibleActions',listPossibleActions);
	 	mapResult.put('listSelectedAction',listSelectedAction);
	 	
	 	return mapResult;
	 }
	 
	 
	/*****************************************************************************************************************************
    @ Method:   apexSaveActions
    @ Version:  1.0
    @ Author:   Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:  US-0007443 - [EU & AU] Create Actions
	@		    Save selected new action templates
	@			Action. Name = Action Template. Name
	@		·   Action. Project = Lookup (project) – project from which process was triggered
	@		·   Action.Owner = Project. Owner
	@		·   Action. Due Date = Today + Action template. Number of dates required
	@		·   Action.Seller Name = Project. seller
	@		·   Action (Lookup) = Action Template
	@		·   Action. Description = Action Template. Description
    @------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String projectId: current project id, list of selected template to be assigned
    @------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 21.04.2020 / Vadhanak Voun / Created the  Method.
	@ Change history: 04.04.2022 / Chetra Sarom  / US-0011551 - "Detail Description" field to be updated on Action Creation
	@					22.04.2022 / Acmatac SEING / US-0011630 - Pro-Trader/aSelleration/Scaling/Acquisition: Tie Actions Record to Customer Record
    *****************************************************************************************************************************/
	 @AuraEnabled
	 public static Map<String,Object> apexSaveActions(String projectId,List<String> selectedNewTemplates)
	 {
	 	Map<String,Object> mapResult = new Map<String,Object>();
	 	String sWhereProject = ' Where Id=:projectId';

		//@ Change history: 04.04.2022 / Chetra Sarom  / US-0011551
		Set<String> validProjectRecordType = new Set<String>{
			'Scaling',
			'EUOnboarding',
			'eBayAUSMB',
			'eBayAUEnterprise'
		};
		// US-0011551 end

		// 22.04.2022 / Acmatac SEING / US-0011630
		Set<String> validProjectRecordType_4PopulateManagedSeller = new Set<String>{
			'eBayAUSMB',
			'EUOnboarding',
			'Scaling'
		};

	 	EBH_Project__c project = (EBH_Project__c)Database.query(BATCH_LEAD_SQL+sWhereProject)[0];
	 	String sWhereTemplate = ' Where Id IN:selectedNewTemplates';
	 	Map<Id,Action_Template__c> mapTemplate = new Map<Id,Action_Template__c>((List<Action_Template__c>)Database.query(SOQL_ACTION_TEMPLATE+sWhereTemplate));
	 	
	 	List<Action__c> listActionToCreate = new List<Action__c>();
	 	for(String templateId : selectedNewTemplates)
	 	{
	 		listActionToCreate.add(
	 			new Action__c(Name = mapTemplate.get(templateId).Name,
	 				Project__c = projectId,
	 				OwnerId = project.OwnerId,
					//@ Change history: 04.04.2022 / Chetra Sarom  / US-0011551
					Detailed_Description__c = (validProjectRecordType.contains(project.RecordType.DeveloperName) && mapTemplate.get(templateId).Detailed_Description__c != null)? mapTemplate.get(templateId).Detailed_Description__c: '',
					// US-0011551 end

					//US-0011630
					Managed_Seller__c = validProjectRecordType_4PopulateManagedSeller.contains(project.RecordType.DeveloperName) ? project.EBH_Seller__c : null,

	 				//Due_Date__c,
	 				Action_Template__c = templateId,
	 				RecordTypeId = (project.RecordType.DeveloperName==RECTYPE_ACTION_TEMPLATE_SCALING) ? ApexUtil.getRecordTypeByName('Action__c',RECTYPE_ACTION_TEMPLATE_SCALING).Id : ApexUtil.getRecordTypeByName('Action__c',RECTYPE_ACTION_TEMPLATE_ACQ).Id,
	 				TemplateUniqueId__c = projectId+'_'+templateId
	 			)
	 		);
	 	}
	 	
	 	try
	 	{
	 		upsert listActionToCreate TemplateUniqueId__c;
	 		mapResult.put('status','ok');
	 		
	 	}catch(DMLException dex)
    	{mapResult.put('status','ko');mapResult.put('error',dex.getDmlMessage(0));mapResult.put('errorDetail',dex.getStackTraceString());
    	}catch(Exception ex){
    		mapResult.put('status','ko');mapResult.put('error',ex.getMessage());mapResult.put('errorDetail',ex.getStackTraceString());
    	}
    	
	 	return mapResult;
	 }
	
	 /*****************************************************************************************************************************
    @ Method:   getPro
    @ Version:  1.0
    @ Author:   Sreymeas Nao (sreymeas.nao@gaea-sys.com)
    @ Purpose:  US-0007649 - [ AU] Create Actions for Scaling Project Record
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      Id proId
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 23.06.2020 / Sreymeas Nao / Created the  Method.
    *****************************************************************************************************************************/
	@AuraEnabled
	public static EBH_Project__c getPro(Id proId) {
		return [SELECT Id, Name, RecordTypeId, RecordType.Developername FROM EBH_Project__c WHERE Id = :proId];
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