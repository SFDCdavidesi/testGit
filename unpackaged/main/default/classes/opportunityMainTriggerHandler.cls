public with sharing class opportunityMainTriggerHandler implements ITrigger{
    //Set<String> oppIDs2MediaPlan = new Set<String>();
    List<Opportunity> termUpdatedOpp = new List<Opportunity>();
    // List<Opportunity> opps2BuildForecast = new List<Opportunity>(); // 22.12.2020 / Sophal Noch /  US-0008746 - [Ads 2020] Remove Old Daily/Monthly Forecast Revenue Generated
    Set<Id> ioIDs2BuildRS = new Set<Id>(); //RS = Revenue Schedule 

    //static final Id RECORDTYPEID_EBAY_AD;
    // static final Id ADMIN_PROFILE_ID; // 18.12.2020 / Sophal Noch / US-0008866 : because it is not used anymore
    Set<Id> validOpportunityRecordType = new Set<Id>();

    // static {
    // 	for(Profile p : [Select Id from Profile Where Name = 'System Administrator']){
    // 		ADMIN_PROFILE_ID = p.Id;
    // 	}
    // } // 18.12.2020 / Sophal Noch / US-0008866 : because it is not used anymore

    public opportunityMainTriggerHandler() {
        //for(RecordType rt : [Select Id from RecordType Where SobjectType = 'Opportunity' and (DeveloperName = :Label.OPP_RECORDTYPENAME_AD OR DeveloperName =:Label.OPP_REVISION_RECORDTYPENAME)]) {
            //RECORDTYPEID_EBAY_AD = rt.Id;

        /*
        //MN-19112019-Updated with new RT "Direct", "Programmatic, PMP, and Incremental"
        
        // 12.01.2020 / Sophal Noch / US-0008955 disble this query because it cause soql 101 from 
        // process buidler named "eBay Ads Updates for Existing Quotes"

        for(RecordType rt : [Select Id from RecordType Where SobjectType = 'Opportunity' and 
                             (DeveloperName = :Label.OPP_RECORDTYPEDEVNAME_DIRECT OR 
                              DeveloperName =:Label.OPP_RECORDTYPEDEVNAME_PROGRAMMATIC OR 
                              DeveloperName =:Label.OPP_RECORDTYPEDEVNAME_PMP OR
                              DeveloperName =:Label.OPP_RECORDTYPEDEVNAME_REVISION 
                             )]) {
            validOpportunityRecordType.add(rt.Id);
        }
        */
    }

    public void bulkBefore()
    {
        
        
    }

    public void bulkAfter()
    {
        
    }
    
    public void beforeInsert(SObject so){
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
    }
    
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so){   

    }
    
    public void afterInsert(SObject so){
    	//Opportunity opp = (Opportunity) so;
     //   if( opp.StageName == Label.OPP_STATUS_QM && opp.Media_Plan__c == null){
     //       oppIDs2MediaPlan.add(opp.Id);
     //   }
     	// Opportunity opp = (Opportunity) so;
     	// if( validFRS(opp) && opp.Amount != 0 ) opps2BuildForecast.add(opp); // 22.12.2020 / Sophal Noch /  US-0008746 - [Ads 2020] Remove Old Daily/Monthly Forecast Revenue Generated
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        Opportunity newOpp = (Opportunity) so;
        if( GW_sObject.isFieldChanged(so, oldSo, Util.NS +'IO_Paper__c') ){termUpdatedOpp.add(newOpp);}
        
		// if( 
        //     (GW_sObject.oneOrMoreFieldsChanged(so, oldSo, new Set<String>{ 'Amount', Util.NS + 'Start_Date__c', Util.NS + 'End_Date__c' }) 
        //     // || UserInfo.getProfileId() == ADMIN_PROFILE_ID // 18.12.2020 / Sophal Noch / US-0008866 : because it cause soql 101 error for admin and test method
        // ) && validFRS(newOpp) ) {
		// 	opps2BuildForecast.add(newOpp);
		// } // 22.12.2020 / Sophal Noch /  US-0008746 - [Ads 2020] Remove Old Daily/Monthly Forecast Revenue Generated

        if( GW_sObject.isFieldChanged(so, oldSo,'StageName') && newOpp.IsWon && newOpp.IO__c != null){ioIDs2BuildRS.add(newOpp.IO__c);}	
    }
    
    public void afterDelete(SObject so){
    }
    
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this 
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally(){
        //if(trigger.isafter) GW_Opportunity.createMediaPlan(oppIDs2MediaPlan);
        // GW_Opportunity.syncRec(termUpdatedOpp);
        // new GW_IO.RevenueScheduleCreator(opps2BuildForecast); // 22.12.2020 / Sophal Noch /  US-0008746 - [Ads 2020] Remove Old Daily/Monthly Forecast Revenue Generated
        // GW_IO.createRSDailyAndMonthly(ioIDs2BuildRS);
    }
 	/*
 	boolean validFRS(Opportunity opp) {
 		return String.isNotBlank(opp.RecordTypeId) && opp.RecordTypeId == RECORDTYPEID_EBAY_AD && 
 				opp.Start_Date__c != null && opp.End_Date__c != null && opp.End_Date__c >= opp.Start_Date__c;
 	}
    */
    //MN-30092019
    // boolean validFRS(Opportunity opp) {
    //     return String.isNotBlank(opp.RecordTypeId) && validOpportunityRecordType.contains(opp.RecordTypeId) && 
    //             opp.Start_Date__c != null && opp.End_Date__c != null && opp.End_Date__c >= opp.Start_Date__c;
    // } // 22.12.2020 / Sophal Noch /  US-0008746 - [Ads 2020] Remove Old Daily/Monthly Forecast Revenue Generated
 }