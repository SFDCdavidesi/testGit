@istest
global class ScheduleFlowTest {
    
    public static testMethod void testScheduler() {
        
        Test.StartTest();
  
        ScheduleFlow sh1 = new ScheduleFlow();
        
        String sch = '0 0 23 * * ?';
        system.schedule('Test ScheduleFlow', sch, sh1); 
        Test.stopTest(); }
    
}