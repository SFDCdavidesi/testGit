/*********************************************************************************************************************************
@ Class:          SprintTriggerHandler
@ Version:        1.0
@ Author:         Sovantheany.Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        Handler Class for SprintTrigger (Sprint__c)
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 16.1.2019 / Sovantheany.Dim / Created the class.
@ Change history: 04.07.2022 / Chetra Sarlom / US-0007031 - Deactivate triggers
*********************************************************************************************************************************/
public without sharing class SprintTriggerHandler {
    
	/*********************************************************************************************************************************
	@ Purpose:        to complete Test Class
	@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
	*********************************************************************************************************************************/
	public static void completeTestClass(){
		System.debug('complete test class');
	}	
	
    /*****************************************************************************************************************************
    @ Method:         createdSprintCapacityUser
    @ Version:        1.0
    @ Author:         Sovantheany.Dim
    @ Purpose:        EPH-6853 Due Dates and Ticket ID Automation for Marketing Ticket
    @				  Trigger: Whenever a "Sprint" record gets created or updated
    @				Action: create / update / delete records in Sprint Capacity (User)" object. Create records per user IN Public Group: Marketing Execution
    @				User = User.ID of Public Group: Marketing Execution member
    @				Sprint = Sprint record from trigger
    @ 				From = Sprint_r.From_c
    @ 				To = Sprint_r.To_c
	@ Event:		after Insert
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<SPRINT__c> newSprints
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 16.1.2019 / Sovantheany.Dim / Created the  Method.
	@ Change history: 04.07.2022 / Chetra Sarlom / US-0007031 - Deactivate triggers
    *****************************************************************************************************************************/	
    /*
	public static void createdSprintCapacityUser(List<SPRINT__c> newSprints){
    	List<Sprint_Capacity_Users__c> lstNewsprintCapacityUsers = new List<Sprint_Capacity_Users__c>();
    	for(SPRINT__c sp : newSprints){
    		Set<String> sActiveUserID = getUser();
    		for(String userID : sActiveUserID){
    			lstNewsprintCapacityUsers.add(newSprintCapacityUser(userID,sp));
    		}
    	}
    	
    	if(!lstNewsprintCapacityUsers.isEmpty()) insert lstNewsprintCapacityUsers;
    }
	/* 
	// end US-0007031 old US-0001227 

    
    /*****************************************************************************************************************************
    @ Method:         updatedOrDeletedSprintCapacityUser
    @ Version:        1.0
    @ Author:         Sovantheany.Dim
    @ Purpose:        EPH-6853 Due Dates and Ticket ID Automation for Marketing Ticket
    @				  Trigger: Whenever a "Sprint" record gets created or updated
    @				Action: create / update / delete records in Sprint Capacity (User)" object. Create records per user IN Public Group: Marketing Execution
    @				Sprint Capacity (User) record would get deleted is when the sprint gets updated and a user is not member of the public group anymore or was deactivated.
	@ Event:		after update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<SPRINT__c> newSprints; Map<ID,SPRINT__c> oldSprints  
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 16.1.2019 / Sovantheany.Dim / Created the  Method.
	@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
    *****************************************************************************************************************************/
    /*
	public static void updatedOrDeletedSprintCapacityUser(List<SPRINT__c> newSprints, Map<ID,SPRINT__c> oldSprints){
    	Map<String,SPRINT__c> mapSprint = new Map<String,SPRINT__c>();
    	for(SPRINT__c newSprint : newSprints){
    		SPRINT__c oldSprint = oldSprints.get(newSprint.ID);
    		if(newSprint.From__c == oldSprint.From__c && newSprint.To__c == oldSprint.To__c) continue;
    		mapSprint.put(newSprint.ID,newSprint);
    	}
    	Set<String> sActiveUserID = getUser();
    	List<Sprint_Capacity_Users__c> lstSPUserToDeleted = new List<Sprint_Capacity_Users__c>();
    	List<Sprint_Capacity_Users__c> lstSPUserToUpdated = new List<Sprint_Capacity_Users__c>();
    	set<String> setSprintAndUser = new Set<String>();
    	for(Sprint_Capacity_Users__c spUser : [select User__c,From__c,To__c,Sprint__c from Sprint_Capacity_Users__c where Sprint__c IN: mapSprint.keySet()]){
    		setSprintAndUser.add(spUser.Sprint__c+'/'+spUser.User__c);
    		if(sActiveUserID.contains(spUser.User__c)){
    			SPRINT__c sprint = mapSprint.get(spUser.Sprint__c);
    			spUser.From__c = sprint.From__c;
    			spUser.To__c = sprint.To__c;
    			lstSPUserToUpdated.add(spUser);
    		}
    		//if user is not member of public group anymore or user is deativated, delete
    		else{
    			lstSPUserToDeleted.add(spUser);
    		}
    	}
    	if(!lstSPUserToDeleted.isEmpty()) delete lstSPUserToDeleted;
    	if(!lstSPUserToUpdated.isEmpty()) update lstSPUserToUpdated;
    	
    	List<Sprint_Capacity_Users__c> lstNewsprintCapacityUsers = new List<Sprint_Capacity_Users__c>();
    	//create new Sprint_Capacity_Users__c in case there is more user in public group or user is activated
    	for(String key : mapSprint.keySet()){
    		SPRINT__c sp = mapSprint.get(key);
    		for(String userID : sActiveUserID){
    			String sprintAndUser = key + '/' + userID;
    			if(setSprintAndUser.contains(sprintAndUser)) continue;
    			lstNewsprintCapacityUsers.add(newSprintCapacityUser(userID,sp));
    		}
    	}
    	if(!lstNewsprintCapacityUsers.isEmpty()) insert lstNewsprintCapacityUsers;
    	
    }
	/*
	// end US-0007031 old US-0001238 US-0001227 

    /*****************************************************************************************************************************
    @ Method:         getUser
    @ Version:        1.0
    @ Author:         Sovantheany.Dim
    @ Purpose:        get all active user IN Public Group: Marketing Execution
    ------------------------------------------------------------------------------------------------------------------------------
    @ return :      List<User>   
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 16.1.2018 / Sovantheany.Dim / Created the  Method.
	@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
    *****************************************************************************************************************************/
    /*
	public static Set<String> getUser(){
    	String userType = Schema.SObjectType.User.getKeyPrefix();
    	Set<String> sUserId = new Set<String>();
    	for(GroupMember gm : [Select UserOrGroupId, Group.DeveloperName, Group.Id, GroupId From GroupMember where Group.DeveloperName =: EBH_ConstantsUtility.GROUP_MARKETING_EXC]){
    		if(String.valueOf(gm.UserOrGroupId).startsWith(userType))sUserId.add(gm.UserOrGroupId);
    	}
    	
    	Set<String> sActiveUserId = new Set<String>();
    	for(User u : [select id from User where id IN: sUserId and IsActive = true]){
    		sActiveUserId.add(u.Id);
    	}
    	
    	return sActiveUserId;
    } */

	// end US-0007031 old US-0001238 US-0001227 
    
    /*****************************************************************************************************************************
    @ Method:         newSprintCapacityUser
    @ Version:        1.0
    @ Author:         Sovantheany.Dim
    @ Purpose:        create new Sprint_Capacity_Users__c
    ------------------------------------------------------------------------------------------------------------------------------
    @ return :      String userID, SPRINT__c sp  
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 16.1.2018 / Sovantheany.Dim / Created the  Method.
	@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
    *****************************************************************************************************************************/
    /*
	public static Sprint_Capacity_Users__c newSprintCapacityUser(String userID, SPRINT__c sp){
    	Sprint_Capacity_Users__c spUser = new Sprint_Capacity_Users__c();
    	spUser.User__c = userID;
    	spUser.From__c = sp.From__c;
    	spUser.To__c = sp.To__c;
    	spUser.Sprint__c = sp.ID;
    	return spUser;
    } */

	// end US-0007031 old US-0001238 US-0001227 
}