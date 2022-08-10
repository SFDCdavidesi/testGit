/*********************************************************************************************************************************
@ Class:          SprintCapacityUserTriggerHandler
@ Version:        1.0
@ Author:         Sovantheany.Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        Handler Class for SprintCapacityUserTrigger (Sprint_Capacity_Users__c)
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 17.1.2019 / Sovantheany.Dim / Created the class.
@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
*********************************************************************************************************************************/
public without sharing class SprintCapacityUserTriggerHandler {
	
	/*********************************************************************************************************************************
	@ Purpose:        to complete Test Class
	@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
	*********************************************************************************************************************************/
	public static void completeTestClass(){
		System.debug('complete test class');
	}	
    
    /*****************************************************************************************************************************
    @ Method:         createdUpdatedSprintCapacityUser
    @ Version:        1.0
    @ Author:         Sovantheany.Dim
    @ Purpose:        EPH-6974 Trigger for new object: "Sprint Capacity (User)"
    @				  Trigger: Whenever a "Sprint Capacity (User)" record gets created or updated
    Action: update records in "Sprint Capacity (User)" object.
    
    Available capacity: Copy = SUM (Day.Available capacity (hours per day)) WHERE Day.Competency = "Copy" AND From <= Day.Day <= To AND User=Day.Owner
    Available capacity: Creative = SUM (Day.Available capacity (hours per day)) WHERE Day.Competency = "Creative" AND From <= Day.Day <= To AND User=Day.Owner
    Available capacity: Targeting = SUM (Day.Available capacity (hours per day)) WHERE Day.Competency = "Targeting" AND From <= Day.Day <= To AND User=Day.Owner
    Available capacity: Journey = SUM (Day.Available capacity (hours per day)) WHERE Day.Competency = "Journey" AND From <= Day.Day <= To AND User=Day.Owner
	Available capacity: Scripting = SUM (Day.Available capacity (hours per day)) WHERE Day.Competency = "Scripting" AND From <= Day.Day <= To AND User=Day.Owner
	@ Event:		before Insert,update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<Sprint_Capacity_Users__c> newSprintsUser, Map<ID,Sprint_Capacity_Users__c> oldSprintUserMap
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 18.12.2018 / Sovantheany.Dim / Created the  Method.
	@ Change history: 04.07.2022 /Chetra Sarlom/  US-0007031 - Deactivate triggers
    *****************************************************************************************************************************/
    
	/*
	public static void updatedSprintCapacityUser(List<Sprint_Capacity_Users__c> newSprintsUser, Map<ID,Sprint_Capacity_Users__c> oldSprintUserMap){
    	Set<String> sUserId = new Set<String>();
    	for(Sprint_Capacity_Users__c sprintUser : newSprintsUser){
    		if(trigger.isUpdate) {
    			Sprint_Capacity_Users__c oldSprintUser = oldSprintUserMap.get(sprintUser.Id);
    			if(sprintUser.User__c == oldSprintUser.User__c && sprintUser.From__c == oldSprintUser.From__c && sprintUser.To__c == oldSprintUser.To__c) continue;
    		}
    		sUserId.add(sprintUser.User__c);
    		
    		sprintUser.Available_capacity_Copy__c = 0;
    		sprintUser.Available_capacity_Creative__c = 0;
    		sprintUser.Available_capacity_Targeting__c = 0;
    		sprintUser.Available_capacity_Journey__c = 0;
    		sprintUser.Available_capacity_Scripting__c = 0;
			sprintUser.Available_capacity_Other__c = 0;
    	}
    	Map<String,List<Day__c>> mapDaybyOwner = new Map<String,List<Day__c>>();
    	for(Day__c d : [Select d.OwnerId, d.Day__c, d.Competency_pkl__c, d.Available_capacity_hours_per_day__c From Day__c d where OwnerId IN: sUserId and Competency_pkl__c != null and Day__c != null]){
    		List<Day__c> days = new List<Day__c>();
    		if(mapDaybyOwner.containsKey(d.OwnerId)) days = mapDaybyOwner.get(d.OwnerId);
    		days.add(d);
    		mapDaybyOwner.put(d.OwnerId,days);
    	}
    	for(Sprint_Capacity_Users__c sprintUser : newSprintsUser){
    		if(!mapDaybyOwner.containsKey(sprintUser.User__c)) continue;
    		List<Day__c> days = mapDaybyOwner.get(sprintUser.User__c);
    		for(Day__c d : days){
    			if(d.Available_capacity_hours_per_day__c == null) continue;
    			if(sprintUser.From__c <= d.Day__c && d.Day__c <= sprintUser.To__c){
    				if(d.Competency_pkl__c == EBH_ConstantsUtility.COMPETENCY_COPY) sprintUser.Available_capacity_Copy__c += d.Available_capacity_hours_per_day__c;
    				else if(d.Competency_pkl__c == EBH_ConstantsUtility.COMPETENCY_CREATIVE) sprintUser.Available_capacity_Creative__c += d.Available_capacity_hours_per_day__c;
    				else if(d.Competency_pkl__c == EBH_ConstantsUtility.COPETENCY_TARGETING) sprintUser.Available_capacity_Targeting__c += d.Available_capacity_hours_per_day__c;
    				else if(d.Competency_pkl__c == EBH_ConstantsUtility.COMPETENCY_JOURNEY) sprintUser.Available_capacity_Journey__c += d.Available_capacity_hours_per_day__c;
    				else if(d.Competency_pkl__c == EBH_ConstantsUtility.COPETENCY_SCRIPTING) sprintUser.Available_capacity_Scripting__c += d.Available_capacity_hours_per_day__c;
					else if(d.Competency_pkl__c == EBH_ConstantsUtility.COPETENCY_OTHER) sprintUser.Available_capacity_Other__c += d.Available_capacity_hours_per_day__c;
    			}
    		}
    	}
    	
    } */
	// end US-0007031 wtih old US-0001226 and US-0001238 
    
}