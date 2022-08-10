/*********************************************************************************************************************************
@ Class:          BatchManagedSharingRecords
@ Version:        1.0
@ Author:         SOCHETTRA SAING (sochettra.saing@skyvva.com)
@ Purpose:        Handler Class for BatchManagedSharingRecords from ManagedSharingRecordsHandler
@ Change history: 14.October.2021 / SOCHETTRA SAING / Created the class.
@               :21-12-2021/ Loumang SENG /US-0010824: Deprecated. moved to Flow "UserFlow - Profile Mapping"
@
*********************************************************************************************************************************/
public with sharing class BatchManagedSharingRecords{
    public BatchManagedSharingRecords(){
        
    }
/*public with sharing class BatchManagedSharingRecords implements Database.Batchable<sObject>{
    
    private String query;
    private Set<Id> allParentIds;
    Map<String, Set<Id>> mPfNameListParent;
    private Set<String> lstPfNames;
    private String accessLevel;
    private String rowCause;
    public BatchManagedSharingRecords(Set<Id> allParentIds, Map<String, Set<Id>> mPfNameListParent, Set<String> lstPfNames, String accessLevel, String rowCause) {
        this.query = 'SELECT Id, Profile.Name FROM User WHERE Profile.Name IN: lstPfNames AND isActive = true ' + (Test.isRunningTest()? ' LIMIT 2' : '');
        this.allParentIds = allParentIds;
        this.mPfNameListParent = mPfNameListParent;
        this.lstPfNames = lstPfNames;
        this.accessLevel = accessLevel;
        this.rowCause = rowCause;
        
        delete [SELECT Id FROM EBH_DealRetailCampaign__Share WHERE ParentId IN: allParentIds AND RowCause =: rowCause];
        
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(this.query);
        
    }
  
    public void execute(Database.BatchableContext BC, List<User> scope){
        List<EBH_DealRetailCampaign__Share> lstDRCShare = new List<EBH_DealRetailCampaign__Share>();
        System.debug('user size '+scope.size());
        for(User u : scope){

            if(this.mPfNameListParent.get(u.Profile.Name) == null) continue;

            Set<Id> allParents = this.mPfNameListParent.get(u.Profile.Name);
            for(Id pId : allParents){
                EBH_DealRetailCampaign__Share drcShare  = new EBH_DealRetailCampaign__Share();
                // Set the ID of record being shared.
                drcShare.ParentId = pId;
                // Set the ID of user or group being granted access.
                drcShare.UserOrGroupId = u.Id;
                // Set the access level.
                drcShare.AccessLevel = this.accessLevel;
                // Set rowCause to 'manual' for manual sharing.
                // This line can be omitted as 'manual' is the default value for sharing objects.
                drcShare.RowCause = this.rowCause;

                lstDRCShare.add(drcShare);
            }
        }
        System.debug('lstDRCShare '+lstDRCShare.size());
        insert lstDRCShare;
        //Database.SaveResult sr = Database.insert(lstDRCShare,false);

    }
  
    public void finish(Database.BatchableContext BC){
    
    }*/
}