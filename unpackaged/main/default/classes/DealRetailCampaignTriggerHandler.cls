/*********************************************************************************************************************************
@ Class:          DealRetailCampaignTriggerHandler
@ Version:        1.0
@ Author:         SRONG TIN (srong.tin@gaea-sys.com)
@ Purpose:        Handler Class for DealRetailCampaign Trigger
@ Change history: 01.July.2021 / SRONG TIN / Created the class.
@                 20.July.2021 / MONY NOU  / US-0009853 - [SEP] Email notification to Seller when Deal Window is Scheduled
@                 07.September.2021 / SOCHETTRA SAING / EBAY-345 - Automatically relate records for Deal Window <> Campaign
@                 25.November.2021 / MONY NOU / US-0010732 - [SP - Na Deals][Bug]Deal Window Campaign is not showing the updated version under the Deal Window in Portal.
*********************************************************************************************************************************/
public without sharing class DealRetailCampaignTriggerHandler {
    public static final String SOQL_DEAL= 'SELECT Id, EBH_Status__c,EBH_DealRetailCampaign__c FROM EBH_Deal__c ';
    public static final String DRC_Deal_WINDOW = 'Deal_Campaign_V2';
    public static final String NA_Unsub_Deal = 'Deal_V3';
    public static final String OPS_REVIEW = 'Ops Review';
    public static final String CM_REVIEW = 'CM Review';
    public static final String SCHEDULED = 'Scheduled';
    public static final String RUNNING = 'Running';
    public static final String COMPLETED = 'Completed'; 
    
    private static final String EMAILTEMPLATE_DEALWINDOWSCH = 'Deal_Window_Scheduled'; //MN-20072021-US-0009853
    private static Id RT_DEALWINDOW = ApexUtil.getRecordTypeByName('EBH_DealRetailCampaign__c', DRC_Deal_WINDOW).Id; //MN-20072021-US-0009853

    public static Boolean isFDRCHandler = false;
    //private static final String DRC_Deal_WINDOW = 'Deal_Campaign_V2';
    public static final String DRC_Deal_WINDOW_CAMPAIGN = 'Deal_Campaign_V3';
    public static final String clone_deal_windowrecordtypeName = 'Cloned_Deal_Campaign';
    //private static Id RT_DEALWINDOW = ApexUtil.getRecordTypeByName('EBH_DealRetailCampaign__c', DRC_Deal_WINDOW).Id;
    private static Id recordtypeidDeal_WINDOW_CAMPAIGN = ApexUtil.getRecordTypeByName('EBH_DealRetailCampaign__c', DRC_Deal_WINDOW_CAMPAIGN).Id;
    //private static Id clone_deal_windowrecordtypeId = ApexUtil.getRecordTypeByName('EBH_DealRetailCampaign__c', clone_deal_windowrecordtypeName).Id;
	private static final String DE_COUNTRY = '77'; //Sambath Seng 25/4/2022 US-0011625 - Bugs/issues and user feedback
    
    /*****************************************************************************************************************************
    @ Method:   updateDealStatusByTimeBaseChange
    @ Version:  1.0
    @ Author:   SRONG TIN (srong.tin@gaea-sys.com)
    @ Purpose:  US-0009685 - [SEP] US - NA Unsub Deal - Time Based Status Changes and it related to US-0009684
    ------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 01.July.2021 / SRONG TIN / Created the  Method.
    *****************************************************************************************************************************/
    public static void updateDealStatusByTimeBaseChange(Map<Id,EBH_DealRetailCampaign__c> mNewDRC,Map<Id,EBH_DealRetailCampaign__c> mOldDRC){
        Id dealRetailCampaignRecordTypeId =  ApexUtil.getRecordTypeByName('EBH_DealRetailCampaign__c', DRC_Deal_WINDOW).Id;
        Id dealRecordTypeId =  ApexUtil.getRecordTypeByName('EBH_Deal__c', NA_Unsub_Deal).Id;
        Set<Id> dealRetailCampaignIds = new Set<Id>();
        Set<String> statusList = new Set<String>{CM_REVIEW,SCHEDULED,RUNNING,COMPLETED};
        // Get all dealRetailCampaignIds 
        for(EBH_DealRetailCampaign__c newDRC : mNewDRC.values()){
            EBH_DealRetailCampaign__c newDealRetailCampaign = mNewDRC.get(newDRC.Id);
            EBH_DealRetailCampaign__c oldDealRetailCampaign = mOldDRC.get(newDRC.Id);
            if( newDealRetailCampaign.RecordTypeId == dealRetailCampaignRecordTypeId && 
                String.isNotBlank(newDealRetailCampaign.Status__c) && 
                newDealRetailCampaign.Status__c != oldDealRetailCampaign.Status__c &&
                statusList.Contains(newDealRetailCampaign.Status__c)
              ){
                dealRetailCampaignIds.add(newDealRetailCampaign.Id);
            }
        }
        // if dealRetailCampaignIds not empty
        if(!dealRetailCampaignIds.isEmpty()){
            Batch_DRC_DealUpdate drc = new Batch_DRC_DealUpdate(dealRetailCampaignIds);
            Database.executeBatch(drc,20); 
        }
    }

    /*****************************************************************************************************************************
    @ Method:        sendEmailToDealSellerContact
    @ Version:       1.0
    @ Author:        Mony Nou (mony.nou@gaea-sys.com)  
    @ Purpose:       US-0009853 - [SEP] Email notification to Seller when Deal Window is Scheduled
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:  Map<Id,EBH_DealRetailCampaign__c> newMap,Map<Id,EBH_DealRetailCampaign__c> oldMap     
    @ event    :  After Update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 20/07/2021 / Mony Nou  / Created the  Method.
    *****************************************************************************************************************************/
    public static void sendEmailToDealSellerContact (Map<Id,EBH_DealRetailCampaign__c> newMap,Map<Id,EBH_DealRetailCampaign__c> oldMap) {

        Map<Id, List<Id>> mDealWindowSellerContact = new Map<Id, List<Id>>();
        Map<Id, String> mDealWindowSRW = new Map<Id, String>();

        for (EBH_DealRetailCampaign__c drc : newMap.values()) {

            //Filtering: for Deal Window that is updated to 'Scheduled' only
            if (drc.RecordTypeId == RT_DEALWINDOW && drc.Status__c == SCHEDULED && oldMap.get(drc.Id).Status__c != drc.Status__c) {
                mDealWindowSellerContact.put(drc.Id, new List<Id>());
                mDealWindowSRW.put(drc.Id, newMap.get(drc.Id).Start_Retail_Week__c);
            }
            
        }

        if (mDealWindowSellerContact.isEmpty()) return; //Skip is no record to process

        //Find all Seller Contact that submitted Deals against each Deal Window
        for (AggregateResult agg : [SELECT EBH_DealRetailCampaign__c dw, Seller_Contact__c sc 
                                        FROM EBH_Deal__c 
                                        WHERE EBH_DealRetailCampaign__c IN:mDealWindowSellerContact.keySet() GROUP BY EBH_DealRetailCampaign__c,Seller_Contact__c]) {
            Id dwId = Id.valueOf(String.valueOf(agg.get('dw')));
            Id scId;
            if (agg.get('sc') != null) scId = Id.valueOf(String.valueOf(agg.get('sc')));
            if (mDealWindowSellerContact.containsKey(dwId) && scId!=null) mDealWindowSellerContact.get(dwId).add(scId);
        }

        acsyn_sendEmailToDealSellerContact(JSON.serialize(mDealWindowSellerContact), JSON.serialize(mDealWindowSRW));
        
    }

    /*****************************************************************************************************************************
    @ Method:        acsyn_sendEmailToDealSellerContact
    @ Version:       1.0
    @ Author:        Mony Nou (mony.nou@gaea-sys.com)  
    @ Purpose:       US-0009853 - Create future method to send an email with attachment (Excel File from VF Page) because we cannot
    @                                do that inside Trigger Context
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 21/07/2021 / Mony Nou  / Created the  Method.
    *****************************************************************************************************************************/
    @Future(callout=true)
    private static void acsyn_sendEmailToDealSellerContact(String jsonDWSC, String jsonDWSRW) {
        
        Map<Id, List<Id>> mDWSC = (Map<Id, List<Id>>) JSON.deserialize(jsonDWSC, Map<Id, List<Id>>.class);
        Map<Id, String> mDWSRW = (Map<Id, String>) JSON.deserialize(jsonDWSRW, Map<Id, String>.class);
        
        List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>(); 
        OrgWideEmailAddress orgWide = ApexUtil.getOWDbyAddress(System.label.OWD_Unsub_Deal_Daily_Deals_Team);
        Id orgWideId = orgWide != null ? orgWide.Id : null;

        List<EmailTemplate> templates = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:EMAILTEMPLATE_DEALWINDOWSCH];
        if (templates.isEmpty()) return; //Skip is there is no email template 

        for (Id dwId : mDWSC.keySet()) {
            String dwrw = mDWSRW.get(dwId);
            for(Id scId : mDWSC.get(dwId)) {
                
                List<String> tmp = new List<String>();
                tmp.add('dwid='+dwId);
                tmp.add('scid='+scId);
                tmp.add('dwrw='+dwrw);
            
                PageReference xls_file = new PageReference('/apex/DD_RetailWeekSpreadsheet?' + String.join(tmp, '&'));
                Blob xlsContent = (!Test.isRunningTest())?xls_file.getContent():Blob.valueOf('test');

                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName('eBay Daily Deals Retail Week ' + dwrw + '.xls');
                efa.setBody(xlsContent);
                efa.setContentType('application/vnd.ms-excel');
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId(orgWideId);
                email.setTargetObjectId(scId);
                email.setWhatId(dwId);
                email.setTemplateId(templates.get(0).Id);
                email.setFileAttachments(new List<Messaging.EmailFileAttachment>{efa});

                listEmail.add(email);
            }
            
        }

        if (!listEmail.isEmpty() && !Test.isRunningTest()) ApexUtil.sendEmail(listEmail);

    }

    /*****************************************************************************************************************************
    @ Method:   insertDealRetailCampaign
    @ Version:  2.0
    @ Author:   Rishi K
    @ Purpose:  EBAY-345 - Automatically relate records for Deal Window <> Campaign
    ------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 08/10/2021 / Rishi K / updated the  Method.
    *****************************************************************************************************************************/

    public static void insertDealRetailCampaign(Map<Id,EBH_DealRetailCampaign__c> mNewDRC){

        Set<Id> allDRCIds = new Set<Id>();
        Set<String> sites = new Set<String>();
        Date startmaxdate;
        Date startmindate;
        for(EBH_DealRetailCampaign__c newsingDRC : mNewDRC.values()){
            
            if(newsingDRC.recordTypeId == recordtypeidDeal_WINDOW_CAMPAIGN){
                
                allDRCIds.add(newsingDRC.id);
                sites.add(newsingDRC.EBH_Country__c);
                if(startmindate!=null && newsingDRC.EBH_Date__c < startmindate) startmindate = newsingDRC.EBH_Date__c;
                else if(startmindate==null) startmindate = newsingDRC.EBH_Date__c;

                if(startmaxdate!=null && newsingDRC.EPH_EndDate__c >startmaxdate) startmaxdate = newsingDRC.EPH_EndDate__c;
                else if(startmaxdate==null) startmaxdate = newsingDRC.EPH_EndDate__c;
                
            }
        }
        if(allDRCIds.size()>0){              
            List<EBH_DealRetailCampaign__c> allDealWindows = new List<EBH_DealRetailCampaign__c>([Select Id, EBH_Date__c, EPH_EndDate__c from EBH_DealRetailCampaign__c WHERE RecordTypeId=:RT_DEALWINDOW AND EBH_Country__c in :sites
                                                                                                AND ((EBH_Date__c <=: startmindate AND EPH_EndDate__c >=: startmindate) OR ( EBH_Date__c >=: startmindate AND EBH_Date__c <=: startmaxdate)) limit 5000]);

            Map<Id,EBH_DealRetailCampaign__c> allDealWindowCampaigns = new  Map<Id,EBH_DealRetailCampaign__c>([Select  EBH_DealTitle__c, EPH_EndDate__c ,EBH_Date__c,id,Related_Deal_Retail_Campaign__c, EBH_Description__c from EBH_DealRetailCampaign__c WHERE id in :allDRCIds]); 
           
            List<NA_Deal_Window_Retail_Campaign_Junction__c> createJuctionrecord = new List<NA_Deal_Window_Retail_Campaign_Junction__c>();
            for(EBH_DealRetailCampaign__c newDRC : allDealWindowCampaigns.values()){                                        
                for(EBH_DealRetailCampaign__c rec: allDealWindows){
                    if((rec.EBH_Date__c <= newDRC.EBH_Date__c && rec.EPH_EndDate__c >= newDRC.EBH_Date__c) || (rec.EBH_Date__c >= newDRC.EBH_Date__c && rec.EBH_Date__c <= newDRC.EPH_EndDate__c)){
                        NA_Deal_Window_Retail_Campaign_Junction__c  newDRCjunction = new NA_Deal_Window_Retail_Campaign_Junction__c(); 
                        newDRCjunction.Deal_Retail_Campaign__c = newDRC.id;
                        newDRCjunction.Deal_Window__c=  rec.id;  
                        newDRCjunction.NA_Retail_Campaign_Description__c = newDRC.EBH_Description__c;  
                        newDRCjunction.NA_Retail_Campaign_Title__c =  newDRC.EBH_DealTitle__c;               
                        newDRCjunction.NA_Retail_Campaign_Start_Date__c =  newDRC.EBH_Date__c;                      
                        newDRCjunction.NA_Retail_Campaign_End_Date__c =  newDRC.EPH_EndDate__c;                      
                        createJuctionrecord.add(newDRCjunction);                     
                    }
                }
                                        
            }
    
            if(createJuctionrecord.size()>0){
                DealRetailCampaignTriggerHandler.isFDRCHandler = true; 
                upsert createJuctionrecord;
            }         
           

        }
        
    }

    // logic for update SCH-08092021-ebay-345
    // MN-25112021-US-0010732 - Need to make junction update whenever DealRetailCampaign is update Title/Description
    public static void updateDealRetailCampaign(Map<Id,EBH_DealRetailCampaign__c> mNewDRC, Map<Id,EBH_DealRetailCampaign__c> mOldDRC){
        Map<Id,EBH_DealRetailCampaign__c> mDRCforClone = new Map<Id,EBH_DealRetailCampaign__c>(); 
        Set<Id> rootRecIds = new Set<Id>(); // store the id of record for delete clone       
        for(EBH_DealRetailCampaign__c drc:mNewDRC.values()){
                if(drc.recordTypeId == recordtypeidDeal_WINDOW_CAMPAIGN && (drc.EBH_Date__c != mOldDRC.get(drc.id).EBH_Date__c || drc.EPH_EndDate__c != mOldDRC.get(drc.id).EPH_EndDate__c || drc.EBH_Description__c != mOldDRC.get(drc.Id).EBH_Description__c || drc.EBH_DealTitle__c != mOldDRC.get(drc.Id).EBH_DealTitle__c)){ //MN-25112021-US-0010732 
                    mDRCforClone.put(drc.id,drc);
                    rootRecIds.add(drc.Id); // delete all clone                    
                }
        }
        List<NA_Deal_Window_Retail_Campaign_Junction__c> listrecfordel = new List<NA_Deal_Window_Retail_Campaign_Junction__c>([Select id from NA_Deal_Window_Retail_Campaign_Junction__c where  Deal_Retail_Campaign__c IN: rootRecIds ]);
        DealRetailCampaignTriggerHandler.isFDRCHandler = true;
        if(!listrecfordel.isEmpty()) delete listrecfordel;
        if(!mDRCforClone.isEmpty()) insertDealRetailCampaign(mDRCforClone);
    }
    //SCH-09092021-ebay-345
    public static void deleteDealRetailCampaign(Map<Id,EBH_DealRetailCampaign__c> mOldDRC){
        SYstem.debug('mOldDRC: '+mOldDRC);
        SYstem.debug('keyset: '+mOldDRC.keyset());
        List<String> drcIds = new List<String>();
        for(Id drcId:mOldDRC.keyset()){
            drcIds.add(drcId);
        }
        SYstem.debug('drcIds: '+drcIds);

        List<EBH_DealRetailCampaign__c> dealRetailCampaigns = [SELECT Id, (SELECT Id FROM Deal_Retail_Campaign_Items__r), (SELECT Id FROM Deal_Window_Items__r) FROM EBH_DealRetailCampaign__c WHERE Id IN :drcIds];
        SYstem.debug('dealRetailCampaigns: '+dealRetailCampaigns);
        List<NA_Deal_Window_Retail_Campaign_Junction__c> listOfJunctionRecordsToDelete = new List<NA_Deal_Window_Retail_Campaign_Junction__c>();
        for(EBH_DealRetailCampaign__c drc:dealRetailCampaigns){
            listOfJunctionRecordsToDelete.addAll(drc.Deal_Retail_Campaign_Items__r);
            listOfJunctionRecordsToDelete.addAll(drc.Deal_Window_Items__r);
        }
        SYstem.debug('listOfJunctionRecordsToDelete: '+listOfJunctionRecordsToDelete);

        delete listOfJunctionRecordsToDelete;
        // List<NA_Deal_Window_Retail_Campaign_Junction__c> recs1 = new List<NA_Deal_Window_Retail_Campaign_Junction__c>([Select Deal_Window__c from NA_Deal_Window_Retail_Campaign_Junction__c LIMIT 10]);
        // SYstem.debug('recs1: '+recs1);

        // List<NA_Deal_Window_Retail_Campaign_Junction__c> recs = new List<NA_Deal_Window_Retail_Campaign_Junction__c>([Select id from NA_Deal_Window_Retail_Campaign_Junction__c where Deal_Window__c IN: mOldDRC.keyset()]);
        // SYstem.debug('recs: '+recs);

        // List<NA_Deal_Window_Retail_Campaign_Junction__c> listrecfordel = new List<NA_Deal_Window_Retail_Campaign_Junction__c>([Select id from NA_Deal_Window_Retail_Campaign_Junction__c where Deal_Window__c IN: mOldDRC.keyset() OR Deal_Retail_Campaign__c IN: mOldDRC.keyset() ]);
        // SYstem.debug('listrecfordel: '+listrecfordel);

        // DealRetailCampaignTriggerHandler.isFDRCHandler = true;

        // delete listrecfordel;
    }
    
    /*****************************************************************************************************************************
    @ Method:   setStartAndEndTimeDE
    @ Author:   Sambath Seng (Sambath.seng@gaea-sys.com)
    @ Purpose:  US-0011625 - Bugs/issues and user feedback
	@ Event:    before insert
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 25/4/2022 / Sambath Seng / Create the  Method.
    *****************************************************************************************************************************/
    public static void setStartAndEndTimeDE(List<EBH_DealRetailCampaign__c> lstNewDRC){
        Time defaultStartTime = Time.newInstance(5, 0, 0, 0);
        Time defaultEndTime = Time.newInstance(4, 59, 0, 0);
        for(EBH_DealRetailCampaign__c oDRC : lstNewDRC){
            if(oDRC.EBH_Country__c == DE_COUNTRY){
                if(oDRC.Start_Time__c == defaultStartTime){
                    oDRC.Start_Time__c = Time.newInstance(9, 0, 0, 0);
                }
                if(oDRC.End_Time__c == defaultEndTime){
                    oDRC.End_Time__c = Time.newInstance(8, 59, 0, 0);
                }
            }
        }
    }
}