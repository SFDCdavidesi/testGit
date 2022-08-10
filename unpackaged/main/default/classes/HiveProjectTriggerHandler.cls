/*********************************************************************************************************************************
 @ Class:          HiveProjectTriggerHandler
 @ Version:        1.0
 @ Author:         David Herrero
 @ Purpose:        handler for trigger/ object Hive_Project
 ----------------------------------------------------------------------------------------------------------------------------------
 @ Change history: 2.08.2021 / David Herrero / Created the class.
 *********************************************************************************************************************************/
public without sharing class HiveProjectTriggerHandler{
	public static final String COMPLETED_STATUS = 'Completed';
	public static final String QUERY_USER_STORIES = 'select id,hive_project__c from copado__user_story__c where Hive_Project__c in :completedProjectsToValidate and copado__status__c not in :EXCLUDED_US_STATUS';
	public static final String QUERY_REQUIREMENT_REQUESTS = 'select id,hive_project__c from Requirement_Request__c where Hive_Project__c in :completedProjectsToValidate and Status__c not in :EXCLUDED_FR_STATUS';
	public static final String ERROR_MESSAGE = 'You can not close a project with open feature requests or user stories. Please, progress before closing project.';

    public static final String[] EXCLUDED_US_STATUS= new String[] {'Closed - Complete','Rejected' ,'Deployed in PROD','Duplicated' };
    public static final String[] EXCLUDED_FR_STATUS= new String[] {'Delivered','Completed' ,'Rejected' ,'On-hold' };

	public static void validateCompletedStatus(Hive_Project__c[] newList, Map<Id, Hive_Project__c> newMap){
        
		List<copado__User_Story__c> lus;
		List<Requirement_Request__c> lfr;
		set<id> addedError = new set<id>();

		set<id> completedProjectsToValidate = new set<id>();
		for (Hive_Project__c p : newList){
			if (p.Status__c == COMPLETED_STATUS){
				completedProjectsToValidate.add(p.ID);

			}
		}
		System.debug('completedProjectsToValidate:::'+completedProjectsToValidate);
		if (!completedProjectsToValidate.isEmpty()){
			lus = Database.query(QUERY_USER_STORIES);
            lfr = Database.query(QUERY_REQUIREMENT_REQUESTS);

			System.debug('lus:::'+lus);
			if (lus != null && lus.size()>0){
                System.debug('size of lus = ' + lus);

				for (copado__User_Story__c cus : lus){
					newMap.get(cus.hive_project__c).addError(ERROR_MESSAGE);
					addedError.ADD(cus.hive_project__c);
				}
			} 
				
                System.debug('size of lfr = ' + lfr);

				if (lfr != null){
                    System.debug('lfr not null ' + lfr);

					for (Requirement_Request__c rr : lfr){
                        System.debug('Requirement_Request__c ' + rr);
                        System.debug('addedError ' + addedError);

						if (!addedError.contains(rr.Hive_Project__c)){
                            System.debug('addedError ' + addedError);

							newMap.get(rr.Hive_Project__c).addError(ERROR_MESSAGE);
							addedError.ADD(rr.hive_project__c);


				
				}
			}
		}
        System.debug('addedError ' + addedError);

        }
    }
}