/*********************************************************************************************************************************
@ Class:          EBH_ProjectTriggerHandler
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        Handler Class for Project Trigger
                  US-0006886 [AU] Approval Process for eBay AU SMB Project with lead Source "Self Gen"
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:  26.12.2019 / Sovantheany Dim /Created the class.
*********************************************************************************************************************************/
public without sharing class EBH_ProjectTriggerHandler {
	private static RecordType recTypeManagedPayProj = ApexUtil.getRecordTypeByName('EBH_Project__c','ManagedPayment');
	private static RecordType recTypeSRMProj = ApexUtil.getRecordTypeByName('EBH_Project__c','Seller_Risk_Management');
	private static final String LEAD_SOQL= 'SELECT Site__c, Company FROM Lead ';
	private static final String ADMIN_PROFILE_ID = '00e6A000000HNzwQAG';
	//23.12.2021 - SRONG TIN : US-0010604
	public static Boolean isHistoryCreate = false;

	// *** PUBLIC ***
	public static final String PROJECT_STAGE_LIVETOSITE = 'Live to Site';
	public static final String PROJECT_STAGE_COMPLETED = 'Completed';
	public static final String PROJECT_STAGE_SUBMITTED = 'Submitted';

	/*****************************************************************************************************************************
    @ Method:         validatedAuSMBProject
    @ Version:        1.0
    @ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:        US-0006886 [AU] Approval Process for eBay AU SMB Project with lead Source "Self Gen"
    @ Rule 1 ->When Lead: Record Type EQUALS eBay AU SMB AND Lead Source = "Self Gen" and isapproved = "False"
    @ When creating "New” Button in Project Related List for SMB Leads is clicked, throw the below error
    @ "Please submit the Lead for Approval."
    @ Note - This is applicable only for SMB Leads and not for Enterprise Leads.  
    @ -----
    @ Rule 3 -> Validation (Negative scenario)
    @ When attempting to create "Project" of record type "eBay AU SMB" from the "Project" tab and Project. Lead lookup field value is "Empty" throw an error on save
    @ "Projects cannot be created without Lead"
    @ When attempting to create "Project" of record type "eBay AU SMB" from the "Project" tab and "Lead" value <> "Empty" and Lead.Lead Source = "Self Gen" and Lead.isapproved = "False" throw an error on save
    @ "Please submit the Lead for Approval."
    @ Event: 		before insert
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter: List<EBH_Project__c> newProjects
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        void
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  26.12.2019 / Sovantheany Dim /Created the methode.
    					25.03.2020 / Sovantheany Dim /Updated the methode : US-0007330 - [EU & AU] Approval Process.
    					Rule 1 ->When Lead: Record Type EQUALS the record type "New Seller Registration Process" (previously EBH_eBayAUSMB record type) and Lead Source = "Self Gen" and isapproved = "False" and LeadSegment__c = SMB (small medium business) and Site__c = AU
    					When creating "New” Button in Project Related List for SMB Leads is clicked, throw the below error
						"Please submit the Lead for Approval."
						Rule 3 -> Validation (Negative scenario)
						When attempting to create "Project" of record type "eBay AU SMB" from the "Project" tab and Project. Lead lookup field value is "Empty" throw an error on save
						"Projects cannot be created without Lead"
						When attempting to create "Project" of record type "New Seller Registration Process" (previously EBH_eBayAUSMB record type) from the "Project" tab and "Lead" value Lead Source = "Self Gen" and Lead.isapproved = "False" and LeadSegment__c = SMB (small medium business) 
						and Site__c = AU throw an error on save "Please submit the Lead for Approval."
    @*****************************************************************************************************************************/
    public static void validatedAuSMBProject(List<EBH_Project__c> newProjects) {
    	RecordType recTypeAuSMBProject = ApexUtil.getRecordTypeByName('EBH_Project__c','eBayAUSMB');
    	Set<String> sLeadId = new Set<String>{};
    	List<EBH_Project__c> lstProject = new List<EBH_Project__c>();
    	for(EBH_Project__c project : newProjects){
    		if(project.recordTypeId != recTypeAuSMBProject.Id) continue;
    		if(project.Lead__c == null){
    			project.addError(System.label.eBayAuSBM_Err_1);
    		}else{
    			sLeadId.add(project.Lead__c);
    			lstProject.add(project);
    		}
    	}
    	if(sLeadId.isEmpty()) return;
    	RecordType recTypeAuSMBLead = ApexUtil.getRecordTypeByName('Lead','EBH_eBayAUSMB');
    	Set<String> sErrorLead = new Set<String>();
    	String wherecl = ' where id IN: sLeadId';
    	for(Lead lead : Database.query(EBH_ConstantsUtility.SOQL_LEAD2 + wherecl)){
    		if(lead.RecordTypeId == recTypeAuSMBLead.Id && lead.LeadSource != null && lead.LeadSource == EBH_ConstantsUtility.LEAD_SOURCE_SELF_GEN && lead.isapproved__c == false && lead.Site__c == EBH_ConstantsUtility.LEAD_COUNTRY_AU && lead.LeadSegment__c == EBH_ConstantsUtility.LEAD_SEGMENT_SMB){
    			sErrorLead.add(lead.Id);
    		}
    	}
    	for(EBH_Project__c project : lstProject){
    		if(sErrorLead.Contains(project.Lead__c)){
    			project.addError(System.label.eBayAuSBM_Err_2);
    		}
    	}
	}
	/*****************************************************************************************************************************
    @ Method:       validateManagedPaymentProj
    @ Author:       Acmatac SEING (acmatac.seing@gaea-sys.com)
	@ Purpose:      US-0007514 Project New Record Type: Managed Payment
					Throw error when user want to insert or delete Project Managed Payment
					Only user with permission set ManagedPayment can edit
    @ Event:		before insert, before update, before delete
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:	List<EBH_Project__c> lstNewProj
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  08.May.2020 / Acmatac SEING /Created the methode.
	@*****************************************************************************************************************************
	@ Change history:  US-0007521 Change history: 18.06.2020 / Sophal Noch / Add Allow Standard Profile User and GCX 
	@					with permisssion set Create_Managed_Payment to insert
	@					EBH_Project records in batch class BatchUploadManagedPayment
    @*****************************************************************************************************************************/
    public static void validateManagedPaymentProj(List<EBH_Project__c> lstProj) {
		Boolean hasPermiss = ApexUtil.checkPermissionSet(new Set<String>{'Managed_Payment'});
		Boolean isAdmin = Userinfo.getprofileId() == EBH_ConstantsUtility.ADMIN_PROFILE_ID;

		Boolean hasCreatedPermiss = ApexUtil.checkPermissionSet(new Set<String>{'Create_Managed_Payment'});

		// Except admin
		// If it's the Update event, user with Managed_Payment permission can Update
		if(isAdmin 

			|| (Trigger.isUpdate && hasPermiss)

			|| (Trigger.isInsert && hasCreatedPermiss) // enable to insert with permissionSet Create_Managed_Payment
			
			|| (Trigger.isUpdate && hasCreatedPermiss && BatchUploadManagedPayment.isBatchManagedPaymentUploading) // need to let update trigger run in ordr to insert with permissionSet Create_Managed_Payment
			
			
		){
			return;
		}
		for(EBH_Project__c oProj : lstProj){
			// If User try to Create or Delete it will throw error
			if(oProj.RecordTypeId == recTypeManagedPayProj.Id){
				oProj.addError(Label.Validate_Managed_Payment);
			}
		}
	}


	/*****************************************************************************************************************************
    @ Method:       validateSRMProj
    @ Author:       Acmatac SEING (acmatac.seing@gaea-sys.com)
	@ Purpose:      US-0009646 AC3: (Validation for displaying "Delete" buttton on the Seller Risk Mangement record)
	@				Given that I am any user with UK Seller Risk Management BU" permission set
	@				When I go to Projects (record type- Seller Risk Management) and click on any record
	@				When Stage != "Submitted", I must not be able to delete the record 
	@ Event: 		before delete
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:	List<EBH_Project__c> lstProj => List of Project before delete
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  28.June.2021 / Acmatac SEING / Created the methode.
	@*****************************************************************************************************************************/
    public static void validateSRMProj(List<EBH_Project__c> lstProj) {
		// Except admin
		if(Userinfo.getprofileId() == ADMIN_PROFILE_ID){
			return;
		}else{
			Boolean hasPermiss = ApexUtil.checkPermissionSet(new Set<String>{'UK_Seller_Risk_Management_BU'});
			for(EBH_Project__c oProj : lstProj){
				// If User try to Delete it will throw error and only Has permission And Stage = Submitted.
				if(oProj.RecordTypeId == recTypeSRMProj.Id && (oProj.EBH_Stage__c != PROJECT_STAGE_SUBMITTED || 
						(oProj.EBH_Stage__c == PROJECT_STAGE_SUBMITTED && !hasPermiss))){
					oProj.addError(Label.PROJECT_SRM_ERROR_ON_DELETE);
				}
			}
		}
	}
	
    /*****************************************************************************************************************************
    @ Method:       validatedRequiredField
    @ Author:       Sovantheany Dim (sovantheany.dim@gaea-sys.com)
	@ Purpose:      US-0009942 - [UK Risk] Pending items- High Priority
	@				AC 5:
	@ 				Given that I am any user with UK Seller Risk Management CUD/GCX" permission set
	@				When I go to Projects (Seller Risk Management) record and select Stage [EBH_Stage__c] = "Completed"
	@				There should be an automation to check if the following fields are poulated, before marking stage as Complete 
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:	List<EBH_Project__c> lstProj => List of Project before update
    ------------------------------------------------------------------------------------------------------------------------------
	@ Change history:  30.Jully.2021 / Sovantheany Dim / Created the methode.
	@					06.June.2022 / Sovantheany Dim / Update the methode.US-0011884 - Move From Validation Rule due to Rollup Summary issue.
	@*****************************************************************************************************************************/
    public static void validatedRequiredField(List<EBH_Project__c> lstProj, Map<Id,EBH_Project__c> mapolds) {
        Map<String,String> mapFields = new Map<String,String>();
        for(Schema.FieldSetMember f : SObjectType.EBH_Project__c.FieldSets.UKSRM_RequiredField.getFields()) {
            mapFields.put(f.getFieldPath(),f.getLabel());
        }
		Boolean hasCUDPermiss = ApexUtil.checkPermissionSet(new Set<String>{'UK_Seller_Risk_Management_CUD_GCX'});
		Boolean hasBUPermiss = ApexUtil.checkPermissionSet(new Set<String>{'UK_Seller_Risk_Management_BU'});
		Set<String> setCompletedStatus = new Set<String>{PROJECT_STAGE_COMPLETED,PROJECT_STAGE_SUBMITTED};
        for(EBH_Project__c oProj : lstProj){
            if(hasCUDPermiss && oProj.RecordTypeId == recTypeSRMProj.Id && mapolds.get(oProj.Id).EBH_Stage__c != oProj.EBH_Stage__c && oProj.EBH_Stage__c == PROJECT_STAGE_COMPLETED){
                Set<String> setEmptyFields = new Set<String>();
                for(String fieldName : mapFields.keySet()){
                    if(oProj.get(fieldName) == null){
                        setEmptyFields.add(mapFields.get(fieldName));
                    } 
                }
                if(!setEmptyFields.isEmpty()) oProj.addError(Label.UKSRM_Required_Field_error+String.join(new List<String>(setEmptyFields),' , ') );
			}
			//TH: US-0011884 : Insufficient Privileges to modify the record when stage is not Submitted
			else if(hasBUPermiss && !setCompletedStatus.contains(oProj.EBH_Stage__c) && oProj.RecordTypeId == recTypeSRMProj.Id
			&& oProj.EBH_Stage__c == mapolds.get(oProj.Id).EBH_Stage__c){
				oProj.addError(Label.Validation_UKSRM_BU_Edit_Record_Error_msg);
			}
            
        }

	}

	/*****************************************************************************************************************************
    @ Method:       createAndUpdateProjectStageHistory
    @ Author:       SRONG TIN (srong.tin@gaea-sys.com)
	@ Purpose:      US-0010604 - Project Stage duration
	------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:	List<EBH_Project__c> lstProj, Map<Id,EBH_Project__c> mapolds
	@ Event: 		Trigger.isAfter insert, update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  21.Dec.2021 / SRONG TIN / Created the methode.
	@*****************************************************************************************************************************/
	public static void createAndUpdateProjectStageHistory(List<EBH_Project__c> lstProj, Map<Id,EBH_Project__c> oldMap) {
		
		Boolean isNew = Trigger.isInsert;
		Map<Id,EBH_Project__c> projectMap = new Map<Id,EBH_Project__c>();
		for(EBH_Project__c onePro : lstProj){
           if(isNew || (!isNew && onePro.EBH_Stage__c != oldMap.get(onePro.Id).EBH_Stage__c)){
			projectMap.put(onePro.Id,onePro);
		   } 
        }
		//check projectMap empty
		if(projectMap.isEmpty())return;
		//get Project Stage History
		Map<Id,Project_Stage_History__c> pshMap = new Map<Id,Project_Stage_History__c>();
		for(Project_Stage_History__c onePSH: [Select Id,End_Stage_Date_Time__c,Project__c,Duration_in_days_int__c,Duration_in_days__c From Project_Stage_History__c Where Project__c in :projectMap.keySet() AND End_Stage_Date_Time__c = null]){
			pshMap.put(onePSH.Project__c,onePSH);
		}
		// create or update project stage history
		List<Project_Stage_History__c> pshToUpSert = new List<Project_Stage_History__c>();
		for(String id: projectMap.keySet()){
			//
			EBH_Project__c project = projectMap.get(id);
			if(!pshMap.isEmpty() && pshMap.containsKey(id)){
				// update current stage and create new stage history 
				Project_Stage_History__c psh = pshMap.get(id);
				psh.End_Stage_Date_Time__c = Datetime.now();
				psh.Duration_in_days_int__c = psh.Duration_in_days__c;
				pshToUpSert.add(psh);
			}
			// create new project stage history
			Project_Stage_History__c newPSH = new Project_Stage_History__c();
			newPSH.Start_Stage_DateTime__c = Datetime.now();
			newPSH.Stage__c = project.EBH_Stage__c;
			newPSH.Project__c = project.Id;
			newPSH.Duration_in_days_int__c = 0;
			pshToUpSert.add(newPSH);
		}
		// upsert Project Stage History
		if(!pshToUpSert.isEmpty()){
			isHistoryCreate = true;
			upsert pshToUpSert;
		}

	}
    
}