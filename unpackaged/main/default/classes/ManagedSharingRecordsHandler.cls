/*********************************************************************************************************************************
@ Class:          ManagedSharingRecordsHandler
@ Version:        1.0
@ Author:         SOCHETTRA SAING (sochettra.saing@skyvva.com)
@ Purpose:        Handler Class for ManagedSharingRecords from Trigger
@ Change history: 14.October.2021 / SOCHETTRA SAING / Created the class.
@               :21-12-2021/ Loumang SENG /US-0010824: Deprecated. moved to Flow "UserFlow - Profile Mapping"
*********************************************************************************************************************************/
public with sharing class ManagedSharingRecordsHandler {
    public ManagedSharingRecordsHandler(){
        
    }
    //LA-17-12-2021:US-0010824 - [SP - EU Deals] Adjust Sharing for Deal Retail Campaign Object
    /*public static Boolean isInsert = false;
    public static Boolean isUpdate = false;
    public static Boolean isDelete = false;
    public static Boolean isUndelete = false;
    private static final Map<String, String> mapSitesPf = new Map<String, String>{
                                                                                    '0' => 'NA - Seller Portal',
                                                                                    '77' =>'DE - Seller Portal'
                                                                                };
    //private static final List<String> lstSite = new List<String>{'0', '77'};
    public static Integer MAX_APEX_JOBS_Flex_Queue_Enable = 100;
    public static Integer MAX_APEX_JOBS = 5;
    public static final String BATCHAPEX_JOBTYPE = 'BatchApex';
    public static Set<String> NON_PENDING_JOB_STATUS = new Set<String> {
        'Completed', 'Aborted', 'Failed'
    };
    
    // query free job
    public static Map<Id,AsyncApexJob> getRunningBatchJobs() {
        return new Map<Id, AsyncApexJob>(
                        [Select Id, Status, JobType, ApexClass.Name From AsyncApexJob 
                        where JobType=:BATCHAPEX_JOBTYPE 
                        and Status NOT IN : NON_PENDING_JOB_STATUS]);
    }
    // check Status picklist value of AsyncApexJob to know org enable queue
    public static Boolean isOrgEnableFlexQueue() {
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectField statusField = schemaMap.get('AsyncApexJob').getDescribe().fields.getMap().get('Status');
        for( Schema.PicklistEntry pe : statusField.getDescribe().getPicklistValues()) {
             
         if('Holding'.equalsIgnoreCase(pe.getValue())) {
                return true;
            }
        }
        return false;
    }
    // check free job
    public static Boolean isApexFreeJob(){
        Integer freeApexJob= isOrgEnableFlexQueue() ? (MAX_APEX_JOBS_Flex_Queue_Enable - ManagedSharingRecordsHandler.getRunningBatchJobs().size()) 
                                                                            : (MAX_APEX_JOBS - ManagedSharingRecordsHandler.getRunningBatchJobs().size());
        return freeApexJob>0;
    }

    public static void shareDealRetailCampaignsBasedOnSite(Map<Id,EBH_DealRetailCampaign__c> mNewDRC,Map<Id,EBH_DealRetailCampaign__c> mOldDRC) {
        // SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM EBH_DealRetailCampaign__Share
        
        ///Id profileId=userinfo.getProfileId();
        ///String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        //Id userId = UserInfo.getUserId();
        ///if(mapPfAllSite.get(profileName) != null) {
            ///List<String> lstSite = new List<String>();
            ///lstSite = mapPfAllSite.get(profileName);

            Set<Id> allRecIds = new Set<Id>();
            Map<String, Set<Id>> mPfNameListParent = new Map<String, Set<Id>>();

            for(EBH_DealRetailCampaign__c drc : mNewDRC.values()){
                // check if update site
                if(isUpdate && drc.EBH_Country__c == mOldDRC.get(drc.Id).EBH_Country__c) continue;

                /*if(lstSite.contains(drc.EBH_Country__c)){
                    allRecIds.add(drc.Id);
                }*/
                /*if(mapSitesPf.get(drc.EBH_Country__c) != null) {
                    String pfName = mapSitesPf.get(drc.EBH_Country__c);
                    if(mPfNameListParent.get(pfName) == null) mPfNameListParent.put(pfName, new Set<Id>());
                    mPfNameListParent.get(pfName).add(drc.Id);
                    allRecIds.add(drc.Id);
                }
            }

            if(!mPfNameListParent.isEmpty()) {
                String rowCause = Schema.EBH_DealRetailCampaign__Share.RowCause.Prevent_Deletion_on_Owner_Change__c;
                //BatchManagedSharingRecords(Set<Id> allParentIds, Set<String> lstPfNames, String accessLevel, String rowCause)
                if( ManagedSharingRecordsHandler.isApexFreeJob() ) ID batchprocessid = Database.executeBatch(new BatchManagedSharingRecords(allRecIds, mPfNameListParent, mPfNameListParent.keySet(), 'Read', rowCause), 25);

            }
        ///}
        
    }*/ /*--END US-0010824-- */
}