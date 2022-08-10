/*********************************************************************************************************************************
@ Class:          DayTriggerHandler
@ Version:        1.0
@ Author:         Sovantheany.Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        Handler Class for DayTrigger (Day__c)
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 22.1.2019 / Sovantheany.Dim / Created the class.
@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
*********************************************************************************************************************************/
public without sharing class DayTriggerHandler {
	
    /*********************************************************************************************************************************
	@ Purpose:        to complete Test Class
	@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
	*********************************************************************************************************************************/
	public static void completeTestClass(){
		System.debug('complete test class');
	}	

    /*****************************************************************************************************************************
    @ Method:         updatedCompetency
    @ Version:        1.0
    @ Author:         Sovantheany.Dim
    @ Purpose:        look up relationship (User.Competency)
    @ Event:		before Insert
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<Day__c> newDays
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 22.1.2019 / Sovantheany.Dim / Created the  Method.
    @ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
    *****************************************************************************************************************************/
    /* public static void updatedCompetency(List<Day__c> newDays){
    	Set<String> sUser = new Set<String>();
    	for(Day__c d : newDays){
    		if(d.User__c == null) continue;
    		sUser.add(d.User__c);
    	}
    	Map<ID,User> mapUser = new Map<ID,User>([select Competency__c from User where id IN: sUser]);
    	for(Day__c d : newDays){
    		if(!mapUser.containsKey(d.User__c)) continue;
    		User u = mapUser.get(d.User__c);
    		d.Competency_pkl__c = u.Competency__c;
    	}
    }*/
    
    /*****************************************************************************************************************************
    @ Method:         updateSprintCapacityUser
    @ Version:        1.0
    @ Author:         Sovantheany.Dim
    @ Purpose:        EPH-7013 : Trigger for Sprint Capacity (User)
    Trigger: Whenever a "Day" record get updated
    Action: update records in "Sprint Capacity (User)" object.
    @ Event:		after Update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<Day__c> newDays
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 25.01.2019 / Sovantheany.Dim / Created the  Method.
    @ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
    *****************************************************************************************************************************/
    /*
    public static void updateSprintCapacityUser(List<Day__c> newDays,Map<ID,Day__c> oldDays){
    	String userType = Schema.SObjectType.User.getKeyPrefix();
    	Set<String> sUserId = new Set<String>();
    	for(Day__c d : newDays){
    		Day__c oldDay = oldDays.get(d.ID);
    		if(oldDay.OwnerId != d.OwnerId && String.valueOf(oldDay.OwnerId).startsWith(userType)) sUserId.add(oldDay.OwnerId);
    		sUserId.add(d.OwnerId);
    	}
    	//get all day
    	Map<String,List<Day__c>> mapDaybyOwner = new Map<String,List<Day__c>>();
        for(Day__c d : [Select d.OwnerId, d.Day__c, d.Competency_pkl__c, d.Available_capacity_hours_per_day__c From Day__c d where OwnerId IN: sUserId and Competency_pkl__c != null and Day__c != null]){
            List<Day__c> days = new List<Day__c>();
            if(mapDaybyOwner.containsKey(d.OwnerId)) days = mapDaybyOwner.get(d.OwnerId);
            days.add(d);
            mapDaybyOwner.put(d.OwnerId,days);
        }
        //get all sprint capacity user where user = day.owner
        List<Sprint_Capacity_Users__c> lstSprintCapacityUser = new List<Sprint_Capacity_Users__c>();
    	for(Sprint_Capacity_Users__c sprintUser : [Select s.User__c, s.To__c, s.From__c, s.Available_capacity_Scripting__c, s.Available_capacity_Other__c, 
    	s.Available_capacity_Journey__c, s.Available_capacity_Creative__c, s.Available_capacity_Copy__c From Sprint_Capacity_Users__c s where User__c IN: sUserId]){
    		if(!mapDaybyOwner.containsKey(sprintUser.User__c)) continue;
            List<Day__c> days = mapDaybyOwner.get(sprintUser.User__c);
            sprintUser.Available_capacity_Copy__c = 0;
            sprintUser.Available_capacity_Creative__c = 0;
            sprintUser.Available_capacity_Targeting__c = 0;
            sprintUser.Available_capacity_Journey__c = 0;
            sprintUser.Available_capacity_Scripting__c = 0;
            sprintUser.Available_capacity_Other__c = 0;
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
            lstSprintCapacityUser.add(sprintUser);
    	}
    	if(!lstSprintCapacityUser.isEmpty()) update lstSprintCapacityUser;
    } */
    // end US-0007031 with old US-0001460 US-0001236
}