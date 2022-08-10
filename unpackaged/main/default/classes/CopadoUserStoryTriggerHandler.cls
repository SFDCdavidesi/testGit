public class CopadoUserStoryTriggerHandler {
    private static final String COPADO_USER_STORY_EXCLUDE_FIELDS='Fields_to_Exclude';

    private static Integer recurRunCount = 1;

    private static final String STATUS_BINDED = 'Binded';	
    private static final String USERSTORY_SOQL = 'select count(Id) totalStory,Hive_Project__c from copado__User_Story__c';
    private static final String PROJECT_SOQL = 'select id,Status__c,(select id from User_Stories__r where copado__Status__c NOT IN: completedStatus limit 1) from Hive_Project__c';
    private static final String COMPLETED_STATUS = 'Completed';
    private static final String DEVELOPMENT_STATUS = 'Development';

    private static final String CURRENT_USER_ID {get{if(CURRENT_USER_ID == null){CURRENT_USER_ID = String.valueOf(UserInfo.getUserId());}return CURRENT_USER_ID;}set;}
    private static final String STATUS_APPROVED = 'Approved';	
    private static final String SPRINT_STATUS_INPROGRESS = 'In progress';
    private static final Id RECORDTYPEID_USER_STORY = ApexUtil.getRecordTypeByName('copado__User_Story__c','User_Story').Id;
    private static final Id RECORDTYPEID_BUG = ApexUtil.getRecordTypeByName('copado__User_Story__c','Bug').Id;
    private static final Set<String> SET_CHANGING_PRIORITY_USERID{
        get{
            if(SET_CHANGING_PRIORITY_USERID == null){
                Set<String> setUserId = new Set<String>();
                setUserId.addAll(Label.ChangingPriorityUserId.split(','));
                SET_CHANGING_PRIORITY_USERID = setUserId;
            }
            return SET_CHANGING_PRIORITY_USERID;
        }
        set;
    }
    private static final List<String> LIST_SALAMI_NAMES{
        get{
            if(LIST_SALAMI_NAMES == null){
                List<String> listSalamiName = new List<String>();
                for(String spName : Label.SprintSalamiNames.split(';')){
                    listSalamiName.add(spName.trim().toLowerCase());
                }
                LIST_SALAMI_NAMES = listSalamiName;
            }
            return LIST_SALAMI_NAMES;
        }
        set;
    }


    public static void decodeDescription(copado__User_Story__c[] newList, Map<id,copado__User_Story__c> oldMap , boolean isUpdate){
        /*
        Not needed anymore
        for (copado__User_Story__c cus:newlist){
            if(cus.Description__c != null &&  isUpdate && cus.Description__c!= oldmap.get(cus.id).Description__c || !isUpdate && cus.copado__Functional_Specifications__c!=null){
                cus.Description__c=cus.Description__c.unescapeHtml4();
                
                
            }
        }
        */
    }
    /*
Updated 2019-12-16 by DHE
it also calculate Technical Design length*/
    /*
    public static void calculateTechnicalSpecifications(List<copado__User_Story__c>newList){
        for (copado__User_Story__c us : newList){
            if(!String.isBlank(us.copado__Technical_Specifications__c)){
                us.Technical_Specifications_length__c=us.copado__Technical_Specifications__c.length();
                
            }else{
                us.Technical_Specifications_length__c=0;
                
            }
            
            
            if (!String.isBlank(us.Technical_Design__c)){
                System.debug('Technical design ' + us.Technical_Design__c);
                System.debug('Technical design ' + us.Technical_Design__c.length());
                us.Technical_Design_Length__c=us.Technical_Design__c.length();
                
            }else{
                us.Technical_Design_Length__c=0;
            }
        }
        
    }
    */
    /*
This method will prevent to copy certain fields when cloning a user story
*/
    public static void emptySelectedFieldsWhenCloning(List<copado__User_Story__c>newList){
        //System.debug('Is clone=' + newList);
        List<copado__User_Story__c> usCloned = new List<copado__User_Story__c>();
        for (copado__User_Story__c cus:newList){
            // System.debug('Is clone=' + cus.isClone());
            if (cus.isClone()){
              cus=  excludeSomeFields(cus);
            }
        }
        
        
        
        
        
    }
    /*
acan we make changes in copado: when user is cloning the record, story points should be set to zero,
developer should be set to null and status =draft, sprint should be removed
*/
    
    private static copado__User_Story__c excludeSomeFields(copado__User_Story__c cus){
    /*    List<String> fieldsToExclude = new list<string>{'copado__Story_Points_Other__c',
            'copado__Story_Points_SFDC__c', 'Story_Points_Dev__c', 'Story_Points_Test__c' ,'copado__developer__c','copado__status__c','copado__Acceptance_Criteria_Status__c',
            'PO_reviewed__c','copado__Org_Credential__c','copado__Environment__c','copado__Apex_Tests_Passed__c','copado__Manual_Tests_Passed__c',
            'SAT_Tests_passed__c','Smoke_Test_Passed__c','UAT_Test_Passed__c','copado__Documentation_Complete__c','Code_has_been_reviewed__c'};
*/
                //updated by DHE 2020-07-01 to use a field set
        Schema.FieldSet fs1 = Schema.SObjectType.Copado__User_Story__c.fieldSets.getMap().get(COPADO_USER_STORY_EXCLUDE_FIELDS);
          Map<String, Schema.SObjectField> userstoryfieldsmap = Schema.getGlobalDescribe().get( 'Copado__user_story__c' ).getDescribe().fields.getMap();
        String f='';
        for (Schema.FieldSetMember fsm : fs1.getFields()){
            f=fsm.getFieldPath(); 
            
            Schema.DescribeFieldResult field = userstoryfieldsmap.get( f.trim() ).getDescribe();
            String fieldType = ( '' + field.getType() ).replace( 'Schema.DisplayType.', '' );
            
            System.debug(f + ' ' + fieldType);
            if (!field.isUpdateable()){
                continue;
            }else if (fieldType =='DOUBLE'){
                cus.put(f,0);
                
            }else if (fieldType=='BOOLEAN'){
                cus.put(f,false);
            }
            else{
                cus.put(f,null);
            }               
        }
        return cus;
    }   

    /*****************************************************************************************************************************
    @ Method	:   checkDependency
    @ Version	:   1.0
    @ Author	: 	Loumang SENG (loumang.seng@gaea-sys.com)
    @ Purpose	:	US-0009262 - Synchronize related user stories status
    @ Trigger 	: 	after updated
	@ Param 	: 	Map<Id,copado__User_Story__c> mapOld, List<copado__User_Story__c> listNew	
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 24.03.2021 / Loumang SENG / Method Creation
    *****************************************************************************************************************************/
    public static void checkDependency(List<copado__User_Story__c> listNew,Map<Id,copado__User_Story__c> mapOld)
    {	
        if(recurRunCount >2) return;
        Map<Id,String> mapUSId = new Map<Id,String>();
        for(copado__User_Story__c cus : listNew){
            copado__User_Story__c oldcus = mapOld.get(cus.Id);
			if(cus.copado__Status__c != oldcus.copado__Status__c){
                mapUSId.put(cus.Id,cus.copado__Status__c);

            }
        }

        if(!mapUSId.isEmpty()){
            
            Map<Id, copado__User_Story__c> mapUsChildToUpdate = new Map<Id, copado__User_Story__c>();

            for(copado__Team_Dependency__c usd : [Select Id,copado__Dependent_User_Story__c, copado__Provider_User_Story__c from copado__Team_Dependency__c where copado__Provider_User_Story__c IN:mapUSId.keySet() AND Relationship__c=:STATUS_BINDED]){

                if(!mapUsChildToUpdate.containsKey(usd.copado__Dependent_User_Story__c)){

                    String status = mapUSId.get(usd.copado__Provider_User_Story__c);
                    copado__User_Story__c childUs = new copado__User_Story__c(Id=usd.copado__Dependent_User_Story__c,copado__Status__c=status);
                    mapUsChildToUpdate.put(usd.copado__Dependent_User_Story__c,childUs);

               }

            }
            
            if(!mapUsChildToUpdate.isEmpty()){
                recurRunCount ++;
                update mapUsChildToUpdate.values();
            }

        }

    	
    }

    /*****************************************************************************************************************************
    @ Method	:   updateProjectStatus
    @ Version	:   1.0
    @ Author	: 	Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose	:	US-0010666 - New Validations for Feature Request creation
    @ AC 2 
    @ Please create an automation for the following rules:
    @ 1) If there are User stories Linked to any {Hive_Project__c} record with Status equal to 'New/'Under Review' , and {copado__User_Story__c.copado__Sprint__c} is populated 
    @ Then, there should be an automation to change the linked project status {Hive_Project__c.Status__c} to "Development"
    @ 2) If the linked User stories with active status is equal to 'Deployed in PROD' Linked to any {Hive_Project__c} record,
    @ {Hive_Project__c.Status__c} to "Completed"
    @ Trigger 	: 	after insert, updated
	@ Param 	: 	Map<Id,copado__User_Story__c> mapOld, List<copado__User_Story__c> listNew	
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 25.05.2022 /Sovantheany Dim / Method Creation
    *****************************************************************************************************************************/
    public static void updateProjectStatus(List<copado__User_Story__c> listNew,Map<Id,copado__User_Story__c> mapOld)
    {
        try{
            Boolean isNew = (mapOld==null);
            Set<String> sProjectIds = new Set<String>();
            Set<String> completedStatus = new Set<String>(System.label.Complete_User_Story_Status.Split(';'));
            for(copado__User_Story__c userStory : listNew){
                if(userStory.Hive_Project__c == null || userStory.copado__Sprint__c == null) continue;

                //If copado__Sprint__c is populated
                if(isNew || (!isNew && (userStory.copado__Sprint__c != mapOld.get(userStory.Id).copado__Sprint__c || userStory.Hive_Project__c != mapOld.get(userStory.Id).Hive_Project__c))){
                    sProjectIds.add(userStory.Hive_Project__c);
                }
                //If User stories status is equal to 'Deployed in PROD' or Complete
                else if((isNew || (!isNew && (userStory.copado__Status__c != mapOld.get(userStory.Id).copado__Status__c || userStory.Hive_Project__c != mapOld.get(userStory.Id).Hive_Project__c))) 
                    && completedStatus.contains(userStory.copado__Status__c)){
                    sProjectIds.add(userStory.Hive_Project__c);
                }
            }
            if(sProjectIds.isEmpty()) return;
            List<Hive_Project__c> lstProjectToUpdate = new List<Hive_Project__c>();
            Set<String> newProjectStatus = new Set<String>(System.label.New_Project_Status.Split(';'));
            for(Hive_Project__c project : Database.query(PROJECT_SOQL+' where id IN: sProjectIds')){
                //if All related User Story have  Complete status, update Project to Complete
                if(project.User_Stories__r.isEmpty() && project.Status__c != COMPLETED_STATUS) lstProjectToUpdate.add(new Hive_Project__c(id = project.Id, Status__c = COMPLETED_STATUS));
                //if Project Status equal to 'New/'Under Review' and copado__Sprint__c is populated, update Project to Development
                else if(newProjectStatus.contains(project.Status__c)) lstProjectToUpdate.add(new Hive_Project__c(id = project.Id, Status__c = DEVELOPMENT_STATUS));
            }
            if(!lstProjectToUpdate.isEmpty()) update lstProjectToUpdate;
        }catch(System.DmlException e) {
            Trigger.new[0].addError(e.getDmlMessage(0));
        }

    }


    /*****************************************************************************************************************************
    @ Method	:   validatePriorityChanged
    @ Version	:   1.0
    @ Author	: 	Sophal Noch (sophal.noch@gaea-sys.com
    @ Purpose	:	US-0011960 - Managing prioritization of Product Backlog Items (PBIs)
    @ Trigger 	: 	before update
	@ Param 	: 	List<copado__User_Story__c> listNew, Map<Id,copado__User_Story__c> mapOld
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 08.07.2022 / Sophal Noch / Create Method
    *****************************************************************************************************************************/
    public static void validatePriorityChanged(List<copado__User_Story__c> listNew,Map<Id,copado__User_Story__c> mapOld){
        
        // 08.07.2022 / Sophal Noch / US-0011960 : AC4, Use trigger to validiaion record instead. We can not use validation rule because of maximum number of 20 unique object reference on User Story. 

        Set<Id> setSprintId = new Set<Id>();
        List<copado__User_Story__c> listPriorityChanged = new  List<copado__User_Story__c>();
    
        for(copado__User_Story__c newUs : listNew){
            copado__User_Story__c oldUs = mapOld.get(newUs.Id);
            if( newUs.copado__Status__c == STATUS_APPROVED && newUs.copado__Sprint__c != null && !SET_CHANGING_PRIORITY_USERID.contains(CURRENT_USER_ID)
                && ((newUs.RecordTypeId == RECORDTYPEID_USER_STORY && newUs.BA_Priority__c != oldUs.BA_Priority__c) || (newUs.RecordTypeId == RECORDTYPEID_BUG && newUs.Bug_Priority__c != oldUs.Bug_Priority__c))
            ){
                setSprintId.add(newUs.copado__Sprint__c);
                listPriorityChanged.add(newUs);
            }
    
        }
        if(!setSprintId.isEmpty()){
            Map<Id,copado__Sprint__c> mapSprint = new  Map<Id,copado__Sprint__c>([Select Id, Name from copado__Sprint__c Where Id IN: setSprintId AND copado__Status__c =: SPRINT_STATUS_INPROGRESS]);
            if(mapSprint.isEmpty()) return;
            for(copado__User_Story__c newUs : listPriorityChanged){
                copado__Sprint__c sprint = mapSprint.get(newUs.copado__Sprint__c);
                if(sprint != null){
                    Boolean isSalami = false;
                    for(String spName : LIST_SALAMI_NAMES){ // 08.07.2022 / Sophal Noch / US-0011960 salami sprint has no record type, so use name to identify it. ex: Salami Stream, 'Salami Iteration
                        if(sprint.Name.toLowerCase().contains(spName)) { isSalami = true; break;}
                    }
                    if(isSalami && newUs.RecordTypeId == RECORDTYPEID_USER_STORY) newUs.BA_Priority__c.addError(Label.ErrorChangeBAPriorityWhenApproved);
                    if(isSalami && newUs.RecordTypeId == RECORDTYPEID_BUG) newUs.Bug_Priority__c.addError(Label.ErrorChangeBugPriorityWhenApproved);
                }
    
            }
    
        }
    }
    
}