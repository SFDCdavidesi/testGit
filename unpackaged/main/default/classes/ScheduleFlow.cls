/**
 * ScheduleFlow Description
 * US-0008939 
 * purpose : This class will be scheduled from Apex Scheduler using the user who schedules the class
 * Will execute a flow
 * 
 * author: David Herrero / david@herrero.us
 * 
 * Change
 * 2021-01-08        David Herrero        Created the class
 *
 */
global class ScheduleFlow implements Schedulable {
   global void execute(SchedulableContext SC) {
	launchFlow();
   }
    
    public static void launchFlow(){
        
        Map<String, Object> myMap = new Map<String, Object>();
        String flowName =  Label.Scheduled_Flow_Name;

  	  Flow.Interview myFlow = Flow.Interview.createInterview(FlowName, myMap);
      myFlow.start();
        }
}