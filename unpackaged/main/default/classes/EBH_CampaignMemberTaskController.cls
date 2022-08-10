/*********************************************************************************************************************************
@ Class:          EBH_CampaignMemberTaskController
@ Version:        1.0
@ Author:         NEHA LUND 
@ Purpose:        Controller Class for EBH_CampaignMemberTaskCreation refresh
                  EPH-3519 : Campaign Review and Measurement
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 05.10.2017 / NEHA LUND / Created the class.
*********************************************************************************************************************************/
public with sharing class EBH_CampaignMemberTaskController {
    
    public Boolean  noMembers      { set; get; }
    public Boolean  newTaskCreated { set; get; }
    public Account  AMUser         { set; get; }
    public Account  SMBUser        { set; get; }
    public Boolean  IsAMManual     { set; get; }
    public Boolean  IsSMBManual    { set; get; }
    public Campaign cRecord        { set; get; }
    
    Id campaignId;
    List<CampaignMember> cMembers;
    
    public Integer AMMembers {
        get {
            return Database.countQuery('SELECT COUNT() FROM CampaignMember WHERE CampaignId = :campaignId AND Contact.Account.Owner.Name != \'Integration User\'');
        }
    }
    
    public Integer SMBMembers {
        get {
            return Database.countQuery('SELECT COUNT() FROM CampaignMember WHERE CampaignId = :campaignId AND Contact.Account.Owner.Name = \'Integration User\'');
        }
    }
    
    /*****************************************************************************************************************************
    @ Method:         EBH_CampaignMemberTaskController
    @ Version:        1.0
    @ Author:         NEHA LUND 
    @ Purpose:        initialization of parameters
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      ApexPages.StandardController controller
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 05.10.2017 / NEHA LUND  / Created the  Method.
    *****************************************************************************************************************************/
    public EBH_CampaignMemberTaskController(ApexPages.StandardController controller) {
        
        campaignId = controller.getId();
        cRecord = [SELECT EBH_TaskCreated__c,EBH_SellerList__c from Campaign where Id = :campaignID];
        
        //fetch related Campaign Members
        cMembers = Database.query(EBH_ConstantsUtility.AOC_CAMPQUERY);
        
        noMembers = cMembers.isEmpty();
        newTaskCreated = cRecord.EBH_TaskCreated__c;
        
        AMUser = new Account(OwnerId = UserInfo.getUserId());
        SMBUser = new Account(OwnerId = UserInfo.getUserId());
    }
    
    /*****************************************************************************************************************************
    @ Method:         createTasks
    @ Version:        1.0
    @ Author:         NEHA LUND 
    @ Purpose:        initialization of parameters
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      ApexPages.StandardController controller
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 05.10.2017 / NEHA LUND  / Created the  Method.
    @				: 25.12.2018/ Vadhanak Voun/ EPH-6850 Targeting Engine with Priority
    *****************************************************************************************************************************/
    public PageReference createTasks() {
        
        List<Task> tasks = new List<Task>();
        System.debug('@@@@@'+IsAMManual+'@@@@@'+IsSMBManual);
        
        String filterId = cRecord.EBH_SellerList__c;
        Map<String,EBH_TargetedSeller__c> mapTargetSeller = new Map<String,EBH_TargetedSeller__c>();
        for(EBH_TargetedSeller__c ts: Database.query(EBH_ConstantsUtility.RCG_TARGETEDSELLERQUERY))
        {
        	mapTargetSeller.put(ts.EBH_Seller__c,ts);
        }
         
        for(CampaignMember cm : (List<CampaignMember>)cMembers) {
                 
            tasks.add(new Task(
                Subject                 = cm.Campaign.Name + EBH_ConstantsUtility.AOC_TASKNAME,
                ActivityDate            = Date.today() + EBH_ConstantsUtility.AOC_TASKDUE,
                WhoId                   = cm.ContactId,
                WhatId                  = cm.CampaignId,
                EBH_CampaignMemberId__c = cm.Id,
                Status                  = EBH_ConstantsUtility.AOC_TASKSTATUS,
                Type                    = EBH_ConstantsUtility.AOC_OUTREACH,
                EBH_Response__c         = EBH_ConstantsUtility.AOC_TASKCALL,
                
                ownerId                 = (cm.contact.account.Owner.Name.equalsIgnoreCase(Label.EBH_IntegrationUser) == false ?
                                              (IsAMManual == false ? cm.Contact.Account.OwnerId : AMUser.OwnerId) : 
                                              (IsSMBManual == false ? cm.Campaign.OwnerId : SMBUser.OwnerId)),
               Order_Priority__c = (mapTargetSeller.containsKey(cm.Contact.AccountId)?mapTargetSeller.get(cm.Contact.AccountId).Priority__c:null)
            ));
        }
                                 
        try {
            Database.insert(tasks);
                
            newTaskCreated = true;
            
            cRecord.EBH_TaskCreated__c = true;
            cRecord.Status = EBH_ConstantsUtility.CMRC_EXECUTION;
            
            Database.update(cRecord);
        } catch(Exception ex) {
            EBH_ApexLogger.logError(new List<Exception> { ex }, EBH_ConstantsUtility.AOC_CLASS, EBH_ConstantsUtility.AOC_METHOD);
        }
        
        return null;
    }
}