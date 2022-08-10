/*********************************************************************************************************************************
@ Class:        BatchAutoCreateDay
@ Version:      1.0
@ Author:       Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:      EPH-6940 Triggers for new object: "Day"
@                AC 1) Automatic creation of records in the "Day" table
@				Rule: Every week create automatically new records for all users in Public Group: Marketing Execution Team ( EPH-6941) in the object "Days".
@				Create "Day" records for working days within a time frame:  (Today + 90; Today + 97)
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 06.01.2019 / Vadhanak Voun (vadhanak.voun@gaea-sys.com) / Created the class.
*********************************************************************************************************************************/
global without sharing class BatchAutoCreateDay implements Database.Batchable<SObject>,Schedulable{
    
    public BatchAutoCreateDay()
    {
    }
    
    global Database.querylocator start(Database.BatchableContext bc)
    {
    	Set<String> setGoups = new Set<String>{EBH_ConstantsUtility.GROUP_MARKETING_EXC};
    	return Database.getQueryLocator(EBH_ConstantsUtility.SOQL_GROUP_MEMBER);
    }
    
    global void execute(Database.BatchableContext bc,List<GroupMember> scope)
    {
    	Set<String> setUserId = new Set<String>();
    	for(GroupMember gm : scope)
    	{
    		setUserId.add(gm.UserOrGroupId);
    	}
    	
    	doInsertDaysForUsers(setUserId,getNext90Days());
    }
    
    public static void doInsertDaysForUsersFromToday(Set<String> setUserId)
    {
    	doInsertDaysForUsers(setUserId,getTodayTo97Days());
    }
    private static void doInsertDaysForUsers(Set<String> setUserId,List<Date> listDates)
    {
    	List<Day__c> listDayRecords = new List<Day__c>();
    	for(String  userId : setUserId)
    	{
    		listDayRecords.addAll(
    			createDaysForUser(listDates,userId)
    		);
    	}
    	
    	Database.insert( listDayRecords,false); //partial. Skip records that fail because of "not unique" on the unique ID field.
    }
    //EPH-7010
    
    private static List<Day__c> createDaysForUser(List<Date> listDates,String userId)
    {
    	List<Day__c> listDayRecords = new List<Day__c>();
    	for(Date d: listDates)
		{
			listDayRecords.add(
				new Day__c(
				 	Day__c = d,
				 	OwnerId = userId,
				 	User__c = userId,
				 	Available_capacity_of_your_work_time__c = 100
				)
			);
		}
    		
    	return listDayRecords;
    }
    /* EPH-7010
     when new user is created we will create records for (today -> today+97) exclude sat,sun
     Today -> Today+97
    */	
    private static List<Date> getTodayTo97Days()
    {
    	List<Date> listDates = new List<Date>();
    	DateTime d_Run = System.now();
    	for(Integer i=0;i<97;i++)
    	{
    		if(Integer.valueOf(d_Run.format('u')) <=5) //exclude sat/sun
    		{
    			listDates.add(d_Run.date());
    		}
    		d_Run = d_Run.addDays(1);
    	}
    	
    	return listDates;
    }
    
    private static List<Date> getNext90Days()
    {
    	List<Date> listDates = new List<Date>();
    	
    	DateTime next90 = System.now().addDays(90);
    	DateTime dateRun = next90;
    	//get 5 working days
    	while(listDates.size()<5)
    	{
    		if(Integer.valueOf(dateRun.format('u')) <=5) //weekday:1-5, Weekend: 6:Sat,7:Sun
    		{
    			listDates.add(dateRun.date());
    			dateRun = dateRun.addDays(1);
    		}else
    		{
    			dateRun = dateRun.addDays(1);
    		}
    	}
    	
    	return listDates;
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
    //for scheduler
    global void execute(SchedulableContext ctx)
    {
    	BatchAutoCreateDay bAuto = new BatchAutoCreateDay();
    	Database.executeBatch(bAuto);
    }
}