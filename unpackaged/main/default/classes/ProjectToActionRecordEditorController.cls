/*********************************************************************************************************************************
@ Class:          ProjectToActionRecordEditorController
@ Version:        1.0
@ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:        US-0007535 Controller for Lightning: ProjectToActionsRelatedList
@ 				  AC2:
@ 				  Given that I am any User (incl. Community Users)
@ 				  When I go to Project record, eBay AU Enterprise, eBay AU SMB, EU Onboarding record types
@ 				  and on details I see new button "Update Action Status"
@ 				  and press on it and see similar flow as in LTTM Actions
@ 				  where I can mass update status of Actions
@ 				  screenshots of the proposed flow below
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 03.06.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / Created the class.
*********************************************************************************************************************************/

public without sharing class ProjectToActionRecordEditorController {
    // public ProjectToActionRecordEditorController() {

	// }

	//Loumang:31.07.2020
	private final static String PROJECT_SCALING_RECORD_TYPE = 'Scaling';
	private final static String ACTION_FIELD_SCALING_STAGE = 'Scaling_Stage__c';
	/*****************************************************************************************************************************
    @ Method:   apexInit
    @ Version:  1.0
    @ Author:   Sophal Noch (sophal.noch@gaea-sys.com)
	@ Purpose: 	get action records which are child of project record, then pass it to lightning component.
	@			use project id to query action records.
    @------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String project id
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 03.06.2020 / Sophal Noch / Created the  Method.
    *****************************************************************************************************************************/

    @AuraEnabled
	public static Map<String,Object> apexInit(String recordId) {
		Map<String,Object> mapResult = new Map<String,Object>();
		//EBH_Project__c
        List<EBH_Project__c> projects = [Select Id, Name,RecordType.DeveloperName,(Select Id From Actions__r limit 1) from EBH_Project__c where Id =:recordId];
        // System.debug('>>recordId: '+ recordId +' >>:projects:  '+projects);
        if(projects[0].Actions__r.isEmpty())
        {
        	mapResult.put('status','ko');
        	mapResult.put('error','No related actions.');
        }else
        {

	        Map<String,String> mapFixLabel = new Map<String,String>{'RecordType.Name'=>'Record Type','Owner.Name'=>'Owner'};
	        
	    
	        List<ColName> listColNameAction = new List<ColName>();
	        Set<String> setFieldNameAction = new Set<String>{'id'};
	        for(Schema.FieldSetMember f: SObjectType.Action__c.FieldSets.UpdateActionStatus.getFields())
	        {

				if(projects[0].RecordType.DeveloperName != PROJECT_SCALING_RECORD_TYPE && f.getFieldPath() == ACTION_FIELD_SCALING_STAGE){
					continue;
				}

				setFieldNameAction.add(f.getFieldPath());
				if(f.getFieldPath().contains('.') && f.getFieldPath().endsWith('Name'))
				{
					String fId = ApexUtil.getFieldIdRef(f.getFieldPath());
					setFieldNameAction.add(fId);
				}
				
				String filedLabel = mapFixLabel.containsKey(f.getFieldPath())?mapFixLabel.get(f.getFieldPath()):f.getLabel();

				listColNameAction.add(
					new ColName(filedLabel,
					f.getFieldPath(),
					f.getType()+'')
				);
				

	        }
	        
	        String soql_action = ' Select '+String.join(new List<String>(setFieldNameAction),',')+' From Action__c Where Project__c=:recordId';
	        
        	Action__c[] listActions = Database.query(soql_action);
        	
			// mapResult.put('setFieldNameAction',setFieldNameAction);
        	mapResult.put('listColNameAction',listColNameAction);
			mapResult.put('listActions',listActions);
			mapResult.put('project',projects[0]);
        	
        	mapResult.put('status','ok');
        }
        
        
        return mapResult;
	}

	/*****************************************************************************************************************************
    @ Method:   apexSave
    @ Version:  1.0
    @ Author:   Sophal Noch (sophal.noch@gaea-sys.com)
	@ Purpose: 	update action records which are modified from lightning component
    @------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      list record of actions
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 03.06.2020 / Sophal Noch / Created the  Method.
    *****************************************************************************************************************************/
	
	@AuraEnabled
	public static Map<String,Object> apexSave(List<Action__c> listActions) {
		
		Map<String,Object> mapResult = new Map<String,Object>();
		try {
			update listActions;
			mapResult.put('status','ok');
		}catch(DMLException dex)
    	{	mapResult.put('status','ko');mapResult.put('error',dex.getDmlMessage(0));mapResult.put('errorDetail',dex.getStackTraceString());
    	}catch(Exception ex)
    	{   mapResult.put('status','ko');mapResult.put('error',ex.getMessage());mapResult.put('errorDetail',ex.getStackTraceString());	}
        
		return mapResult;
	}

    static Map<String,String> mapLinkField = new Map<String,String>{'Name'=>'Name','Account.Name'=>'AccountId','RecordType.Name'=>'RecordTypeId','Owner.Name'=>'OwnerId'};

    class ColName{
    	@AuraEnabled
    	public String label;
    	
    	@AuraEnabled
    	public String fieldName;
      
        @AuraEnabled
    	public String type;
    	
        @AuraEnabled
    	public Boolean sortable = true;
    	
    	
    	@AuraEnabled
    	public Map<String,Object> typeAttributes;
    	
    	public ColName(String label,String fieldName,String type)
    	{
    		this.label = label;
    		this.fieldName = fieldName;
    		this.type = type.toLowerCase();
    		//this.editable = setEditableFields.contains(fieldName);
    		
    		if(fieldName=='RecordType.Name')
    		{
    			this.fieldName = mapLinkField.get(fieldName);
    		}else if(mapLinkField.containsKey(fieldName))
    		{
    			typeAttributes = new Map<String,Object>{
    				'label' => new Map<String,Object>{'fieldName'=>mapLinkField.get(fieldName)},
    				'target'=>'_blank',
    				'tooltip'=>''
    			};
    			this.fieldName = 'link_'+mapLinkField.get(fieldName);
    			this.type = 'url';
    		} 
    	}
    }

}