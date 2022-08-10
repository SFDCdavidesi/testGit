/*********************************************************************************************************************************
@ Class:          MarketingTicketTriggerHandler
@ Version:        1.0
@ Author:         Vadhanak.Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:        Handler Class for Marketing Ticket (Marketing_Ticket__c)
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 18.12.2018 / Vadhanak.Voun / Created the class.
*********************************************************************************************************************************/
public without sharing class MarketingTicketTriggerHandler {

	/*********************************************************************************************************************************
	@ Purpose:        to complete Test Class
	@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
	*********************************************************************************************************************************/
	public static void completeTestClass(){
		System.debug('complete test class');
	}	

    /*****************************************************************************************************************************
    @ Method:         setCounter
    @ Version:        1.0
    @ Author:         Vadhanak Voun
    @ Purpose:        EPH-6853 Due Dates and Ticket ID Automation for Marketing Ticket
    @				  "Count" is generated automatically and is a numerical value.
	@					If it is a first ticket created with this record type for this Campaign that the value equals to 1 (e.g. UK_2018-10-01_Promoted Listings_Targeting_1)
	@					It the Ticket for this Campaign with this record type was already created than value is 2, etc. (e.g UK_2018-10-01_Promoted Listings_Targeting_2)
	@ Event:		Before Insert
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<Marketing_Ticket__c> :       
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 18.12.2018 / Vadhanak Voun / Created the  Method.
	@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
    *****************************************************************************************************************************/
    
	/* public static void setCounter(List<Marketing_Ticket__c> listMarketTicket)
    {
    	Set<String> setRecordtypeId =  new Set<String>();
    	Set<String> setCampaignId =  new Set<String>();
    	Map<String,Integer> mapCounter = new Map<String,Integer>();
    	for(Marketing_Ticket__c mt : listMarketTicket)
    	{
    		setRecordtypeId.add(mt.RecordTypeId);
    		setCampaignId.add(mt.Campaign__c);
    	}
    	
    	String where_Marketing = ' Where Campaign__c IN :setCampaignId AND RecordTypeId IN :setRecordtypeId';
    	String SOQL_MARKETING_TICKET = 'Select Id,Name,Campaign__c,RecordTypeId From Marketing_Ticket__c ';
    	for(Marketing_Ticket__c mt : Database.query(SOQL_MARKETING_TICKET + where_Marketing))
    	{
    		if(mapCounter.containsKey(mt.Campaign__c+''+mt.RecordTypeId))
    		{
    			Integer c = mapCounter.get(mt.Campaign__c+''+mt.RecordTypeId);
    			mapCounter.put(mt.Campaign__c+''+mt.RecordTypeId, c+ 1);
    		}else
    		{
    			mapCounter.put(mt.Campaign__c+''+mt.RecordTypeId,1);
    		}
    	}
    	//start assign the counter....
    	for(Marketing_Ticket__c mt : listMarketTicket)
    	{
    		if(mapCounter.containsKey(mt.Campaign__c+''+mt.RecordTypeId))
    		{
    			Integer c = mapCounter.get(mt.Campaign__c+''+mt.RecordTypeId);
    			mt.Count__c = c+ 1 ;
    			mapCounter.put(mt.Campaign__c+''+mt.RecordTypeId, c+ 1);
    		}else
    		{
    			mapCounter.put(mt.Campaign__c+''+mt.RecordTypeId,1);
    			mt.Count__c = 1;
    		}
    	}
    	
    }*/
	// end US-0007031 with old US-0001616

	
	/*****************************************************************************************************************************
    @ Method:         setDueDate
    @ Version:        1.0
    @ Author:         sovantheany dim
    @ Purpose:        EPH-6853 Due Dates,This value will be automatically populated based on Campaign Start Date		  
    Record Type "Targeting": Campaign.StartDate - 3 Working Day
    Record Type "Copy/Creative": Campaign.StartDate - 2 Working Day
    Record Type "Journey": Campaign.StartDate - 1 Working Day
	@ Event:			before Insert
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<Marketing_Ticket__c> :       
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 27.12.2018 / Sovantheany Dim / Created the  Method.
	@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
    *****************************************************************************************************************************/
    /*
	public static void setDueDate(List<Marketing_Ticket__c> listMarketTicket)
    {
    	Map<String,Integer> mapSubstractDay = new Map<String, Integer>();
    	Set<String> setCampaign= new Set<String>();
    	Integer substractDay = 0;
		
		RecordType rCopyCreative = ApexUtil.getRecordTypeByName('Marketing_Ticket__c','Copy_Creative');
        RecordType rTargeting = ApexUtil.getRecordTypeByName('Marketing_Ticket__c','Targeting');
        RecordType rJourney = ApexUtil.getRecordTypeByName('Marketing_Ticket__c','Journey');
    	Map<String,Integer> mapSubDay = new Map<String,Integer>{rTargeting.ID=>3, rCopyCreative.ID=>2,rJourney.ID=>1};
		
		for(Marketing_Ticket__c marketingTicket : listMarketTicket){
    		substractDay = mapSubDay.get(marketingTicket.RecordTypeId);
    		marketingTicket.Due_Date__c = marketingTicket.Campaign_Start_Date__c != null ? subtractDays(marketingTicket.Campaign_Start_Date__c,substractDay): null;
    	}
    }*/
	// end US-0007031 with old US-0001616
    
    /*****************************************************************************************************************************
    @ Method:         getPreviousWorkingDay
    @ Version:        1.0
    @ Author:         sovantheany dim
    @ Purpose:        Check if new date is within working days
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      Date      
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 28.12.2018 / Sovantheany Dim / Created the  Method.
	@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
    *****************************************************************************************************************************/	
	
	/*public static Date getPreviousWorkingDay(Date d){
        
         //Check if new date is within working days
        if (d.daysBetween(d.toStartofWeek()) == 0 ||
                     d.daysBetween(d.toStartofWeek()) == -6)
        {
            //New date is not within working days, recursively call same function to get previous date by subtracting 1 day
            d = d.addDays(-1);
            return getPreviousWorkingDay(d);
        } else{
            //New date is within working days, return this date
            return d;
        }
    }
	*/
    
    /*****************************************************************************************************************************
    @ Method:         subtractDays
    @ Version:        1.0
    @ Author:         sovantheany dim
    @ Purpose:        substract start date by day number
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      Date startDate ,Integer days
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 28.12.2018 / Sovantheany Dim / Created the  Method.
	@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
    *****************************************************************************************************************************/	
    /* public static Date subtractDays(Date startDate, Integer days)
    {
    	boolean isStartDateworkingDay = true;
        //If startdate is not within working days, take previous working day
        if (startDate.daysBetween(startDate.toStartofWeek()) == 0 ||
                     startDate.daysBetween(startDate.toStartofWeek()) == -6){
        	isStartDateworkingDay = false;
        }
        startDate = getPreviousWorkingDay(startDate);
        for (Integer i = 0; i < days; i++)
        {
            //Subtract 1 day
            startDate = startDate.addDays(-1);
            //If new date is not within working days, get previous working day
        	startDate = getPreviousWorkingDay(startDate);
        }
        startDate = isStartDateworkingDay ? startDate.addDays(-1) : startDate;
        startDate = getPreviousWorkingDay(startDate);
        return startDate;
    }*/
	
	/*****************************************************************************************************************************
    @ Method:         sumEstimatedEffortOnSprint
    @ Version:        1.0
    @ Author:         sovantheany dim
    @ Purpose: EPH-6975 Trigger for object: "Marketing Ticket"
    In the Sprint detail, we should show the sum of Estimated Effort for all the Marketing tickets for all Users that were allocated to the SPRINT.
           
    Estimated_Effort: Copy ( SUM (Marketing_Ticket.Estimated_Effort) from Marketing Ticket where Sprint=Sprint.ID and
    Marketing_Ticket.Competency='Creative'
    
    Estimated_Effort: Creative ( SUM (Marketing_Ticket.Estimated_Effort) from Marketing Ticket where Sprint=Sprint.ID and
    Marketing_Ticket.Competency='Creative'
    
    Estimated_Effort: Targeting( SUM (Marketing_Ticket.Estimated_Effort) from Marketing Ticket where Sprint=Sprint.ID and
    Marketing_Ticket.Competency='Targeting'
    
    Estimated_Effort: Journey ( SUM (Marketing_Ticket.Estimated_Effort) from Marketing Ticket where Sprint=Sprint.ID and
    Marketing_Ticket.Competency='Journey'
    
    Estimated_Effort: Scriptig ( SUM (Marketing_Ticket.Estimated_Effort) from Marketing Ticket where Sprint=Sprint.ID and
    Marketing_Ticket.Competency='Scripting'
    
    Estimated_Effort: Other ( SUM (Marketing_Ticket.Estimated_Effort) from Marketing Ticket where Sprint=Sprint.ID and
    Marketing_Ticket.Competency='Other'
    
    EPH-7002 : Missing Fields in Related list "Marketing Execution Team"
    In the "Marketing Execution Team" part we show Estimated effort per each User that was allocated to the SPRINT.
           
    Estimated_Effort: Copy ( SUM (Marketing_Ticket.Estimated_Effort) from Marketing Ticket where Sprint=Sprint.ID and Marketing_Ticket.Competency='Creative' AND Marketing Ticket.Specialist = "Sprint Capacity (Users).User."
    Estimated_Effort: Creative ( SUM (Marketing_Ticket.Estimated_Effort) from Marketing Ticket where Sprint=Sprint.ID and Marketing_Ticket.Competency='Creative' AND Marketing Ticket.Specialist = "Sprint Capacity (Users).User."
    Estimated_Effort: Targeting( SUM (Marketing_Ticket.Estimated_Effort) from Marketing Ticket where Sprint=Sprint.ID and Marketing_Ticket.Competency='Targeting' AND Marketing Ticket.Specialist = "Sprint Capacity (Users).User."
    Estimated_Effort: Journey ( SUM (Marketing_Ticket.Estimated_Effort) from Marketing Ticket where Sprint=Sprint.ID and Marketing_Ticket.Competency='Journey' AND Marketing Ticket.Specialist = "Sprint Capacity (Users).User."
    Estimated_Effort: Scriptig ( SUM (Marketing_Ticket.Estimated_Effort) from Marketing Ticket where Sprint=Sprint.ID and Marketing_Ticket.Competency='Scripting' AND Marketing Ticket.Specialist = "Sprint Capacity (Users).User."
    Estimated_Effort: Scriptig ( SUM (Marketing_Ticket.Estimated_Effort) from Marketing Ticket where Sprint=Sprint.ID and Marketing_Ticket.Competency='Other' AND Marketing Ticket.Specialist = "Sprint Capacity (Users).User."
    @ Event:			after Insert,updated,deleted
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      List<Marketing_Ticket__c> newMarketTickets, Map<ID,Marketing_Ticket__c> oldMarketTickets
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.01.2019 / Sovantheany Dim / Created the  Method.
    24.01.2019 / Sovantheany Dim / Updated the  Method.
	@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
    *****************************************************************************************************************************/	
    /* US-0007031 - Deactivate triggers
	public static void sumEstimatedEffortOnSprintAndSprintCapacityUser(List<Marketing_Ticket__c> newMarketTickets, Map<ID,Marketing_Ticket__c> oldMarketTickets){
    	List<Marketing_Ticket__c> lstmarketingTickets = newMarketTickets == null ? oldMarketTickets.values() : newMarketTickets;
    	Set<String> setSprintId = new Set<String>();
    	Map<String,SPRINT__c> mapSprint = new Map<String,SPRINT__c>();
    	for(Marketing_Ticket__c ticket : lstmarketingTickets){
    		if(ticket.Sprint_Name__c == null || ticket.Competency_s__c == null) continue;
    		
			if(trigger.isUpdate){
				Marketing_Ticket__c oldticket = oldMarketTickets.get(ticket.ID);

				if(ticket.Sprint_Name__c == oldticket.Sprint_Name__c && ticket.Estimated_Effort__c == oldticket.Estimated_Effort__c && 
				ticket.Competency_s__c == oldticket.Competency_s__c && ticket.Specialist__c == oldticket.specialist__c) continue;
				//if Sprint_Name__c is update , update Estimated Effort on both new sprint record and old sprint record
				else if(ticket.Sprint_Name__c != oldticket.Sprint_Name__c) setSprintId.add(oldticket.Sprint_Name__c);
				
				//map old sprint to update
				//NK:23/03/2019: fixed no id for update when ticket updated from null to new sprint
				if(oldticket.Sprint_Name__c <> null && !mapSprint.containsKey(oldticket.Sprint_Name__c)){
    			SPRINT__c sp = generateSprint(oldticket.Sprint_Name__c);
    			mapSprint.put(oldticket.Sprint_Name__c,sp);
    			}
			}
    		
    		setSprintId.add(ticket.Sprint_Name__c);
    		//map new sprint to update
    		if(!mapSprint.containsKey(ticket.Sprint_Name__c)){
    			SPRINT__c sp = generateSprint(ticket.Sprint_Name__c);
    			mapSprint.put(ticket.Sprint_Name__c,sp);
    		}
    	}
    	
    	//comment out because : new version no Marketing Ticket.Specialist = “Sprint Capacity (Users).User.”
    	Map<String,Sprint_Capacity_Users__c> mapSprintCapacityUser = new Map<String,Sprint_Capacity_Users__c>();
    	//Map<String,Set<String>> mapSprintUser = new Map<String,Set<String>>();
    	for(Sprint_Capacity_Users__c scu : [Select User__c,Sprint__c,Estimated_Effort_Copy__c,Estimated_Effort_Creative__c,
    	Estimated_Effort_Targeting__c,Estimated_Effort_Journey__c,Estimated_Effort_Scripting__c,Estimated_Effort_Other__c 
    	From Sprint_Capacity_Users__c where Sprint__c IN: setSprintId and User__c != null]){
    		
    		
    		
    		String sprintUser = scu.Sprint__c+'/'+scu.User__c;
    		scu.Estimated_Effort_Copy__c = 0;
    		scu.Estimated_Effort_Creative__c = 0;
    		scu.Estimated_Effort_Targeting__c = 0;
    		scu.Estimated_Effort_Journey__c = 0;
    		scu.Estimated_Effort_Scripting__c = 0;
    		scu.Estimated_Effort_Other__c = 0;
    		mapSprintCapacityUser.put(sprintUser,scu);
    	}
    	
    	for(Marketing_Ticket__c ticket : [select Estimated_Effort__c, Competency_s__c, Specialist__c, Sprint_Name__c from Marketing_Ticket__c where Sprint_Name__c IN: setSprintId and Competency_s__c != null]){
    		
    		///Set<String> sUser = mapSprintUser.containsKey(ticket.Sprint_Name__c) ? mapSprintUser.get(ticket.Sprint_Name__c) : new Set<String>();
    		//if(!sUser.contains(ticket.Specialist__c)) continue;
    		
    		ticket.Estimated_Effort__c = ticket.Estimated_Effort__c != null ? ticket.Estimated_Effort__c : 0;
    		//sum estimate effort on Sprint detail page
    		if(mapSprint.containsKey(ticket.Sprint_Name__c)){
    			SPRINT__c sp = mapSprint.get(ticket.Sprint_Name__c);
    			if(ticket.Competency_s__c == EBH_ConstantsUtility.COMPETENCY_COPY) sp.Estimated_Effort_Copy__c += ticket.Estimated_Effort__c;
    			else if(ticket.Competency_s__c == EBH_ConstantsUtility.COMPETENCY_CREATIVE) sp.Estimated_Effort_Creative__c += ticket.Estimated_Effort__c;
    			else if(ticket.Competency_s__c == EBH_ConstantsUtility.COPETENCY_TARGETING) sp.Estimated_Effort_Targeting__c += ticket.Estimated_Effort__c;
    			else if(ticket.Competency_s__c == EBH_ConstantsUtility.COMPETENCY_JOURNEY) sp.Estimated_Effort_Journey__c += ticket.Estimated_Effort__c;
    			else if(ticket.Competency_s__c == EBH_ConstantsUtility.COPETENCY_SCRIPTING) sp.Estimated_Effort_Scripting__c += ticket.Estimated_Effort__c;
    			else if(ticket.Competency_s__c == EBH_ConstantsUtility.COPETENCY_OTHER) sp.Estimated_Effort_Other__c += ticket.Estimated_Effort__c;
    			
    			mapSprint.put(ticket.Sprint_Name__c,sp);
    		}
    		
    		if(ticket.Specialist__c != null){
    			//sum estimate effort on Sprint capacity User related list
	    		String sprintUser = ticket.Sprint_Name__c+'/'+ticket.Specialist__c;
	    		if(mapSprintCapacityUser.containsKey(sprintUser)){
	    			Sprint_Capacity_Users__c scu = mapSprintCapacityUser.get(sprintUser);
	    			if(ticket.Competency_s__c == EBH_ConstantsUtility.COMPETENCY_COPY) scu.Estimated_Effort_Copy__c += ticket.Estimated_Effort__c;
	    			else if(ticket.Competency_s__c == EBH_ConstantsUtility.COMPETENCY_CREATIVE) scu.Estimated_Effort_Creative__c += ticket.Estimated_Effort__c;
	    			else if(ticket.Competency_s__c == EBH_ConstantsUtility.COPETENCY_TARGETING) scu.Estimated_Effort_Targeting__c += ticket.Estimated_Effort__c;
	    			else if(ticket.Competency_s__c == EBH_ConstantsUtility.COMPETENCY_JOURNEY) scu.Estimated_Effort_Journey__c += ticket.Estimated_Effort__c;
	    			else if(ticket.Competency_s__c == EBH_ConstantsUtility.COPETENCY_SCRIPTING) scu.Estimated_Effort_Scripting__c += ticket.Estimated_Effort__c;
	    			else if(ticket.Competency_s__c == EBH_ConstantsUtility.COPETENCY_OTHER) scu.Estimated_Effort_Other__c += ticket.Estimated_Effort__c;
	    			
	    			mapSprintCapacityUser.put(sprintUser,scu);
	    		
	    		}
    		}
    		
    	}
    	System.debug('<<<<<mapSprintCapacityUser.values()='+mapSprintCapacityUser.values());
    	if (!mapSprint.isEmpty()) update mapSprint.values();
    	if(!mapSprintCapacityUser.isEmpty()) update mapSprintCapacityUser.values();
    }
	*/ 
	// end US-0007031 with old US-0001225
     /*****************************************************************************************************************************
    @ Method:         generateSprint
    @ Version:        1.0
    @ Author:         sovantheany dim
    @ Purpose:        create default new sprint
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      String SprintID  ,    Map<String,SPRINT__c> mapSprint 
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 16.1.2019 / Sovantheany Dim / Created the  Method.
	@ Change history: 04.07.2022 /Chetra Sarlom/ US-0007031 - Deactivate triggers
    *****************************************************************************************************************************/	
    /*
	private static SPRINT__c generateSprint(String sprintID){
    	SPRINT__c sp = new SPRINT__c(ID = sprintID, Estimated_Effort_Copy__c = 0, Estimated_Effort_Creative__c = 0,Estimated_Effort_Targeting__c = 0,Estimated_Effort_Journey__c = 0,Estimated_Effort_Scripting__c = 0,Estimated_Effort_Other__c = 0);
		return sp;
    }*/
}