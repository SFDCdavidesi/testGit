/*********************************************************************************************************************************
@ Interface:     HIVE_Intellum_EnrollmentController
@ Version:       1.0
@ Author:        Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:       US-0010064 - [Intellum] API integration with Intellum
@                cotroller for enrolment stuff  
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 13.08.2021 / Vadhanak Voun (vadhanak.voun@gaea-sys.com) / create the class
                  06.09.2021 / SRONG TIN (srong.tin@gaea-sys.com) / Updated class  / US-0010067
*********************************************************************************************************************************/
public with sharing class HIVE_Intellum_EnrollmentController {
    
    //SRONG TIN 06.09.2021 : US-0010067
    private final static String PERMISSION_INTELLUM_MANAGE_ENROLLMENTS = 'Intellum_Manage_Enrollments';
    public static Boolean isCreateEnrollments {get;set;}
    public String recordId{get;set;}
    public String intellumUserId{get;set;}
    public Decimal intellumUserAppId{get;set;}
    private static Boolean isAdmin {get;set;}
    public HIVE_Intellum_EnrollmentController(ApexPages.StandardSetController controller){
        // check permission set and admin
        isCreateEnrollments = false;
        recordId =  (ApexPages.currentPage().getParameters().get('id')!=null)?String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id')):'';
        Boolean isManageEnrollments = ApexUtil.checkPermissionSet(new Set<String>{PERMISSION_INTELLUM_MANAGE_ENROLLMENTS});
        isAdmin = (Userinfo.getprofileId() == Apexutil.ADMIN_PROFILE_ID);
        if(!isManageEnrollments && !isAdmin)return;
        for(intellumapp__IntellumUser__c intellumUser: [Select Id,intellumapp__id__c From intellumapp__IntellumUser__c Where Seller__c =:recordId]){
            intellumUserId = intellumUser.Id;
            intellumUserAppId = intellumUser.intellumapp__id__c;
        }
        isCreateEnrollments = true;
    }

    /*********************************************************************************************************************************
    @ Method:        createIntellumEnrollment
    @ Version:       1.0
    @ Author:        SRONG TIN (srong.tin@gaea-sys.com)
    @ Parameter:     intellumEnrollment, intellumActivities, intellumUserAppId
    @ Event:         Intellum_Enrollment_Create_Enrollment.cmp
    @ Change history: 06.09.2021 / SRONG TIN (srong.tin@gaea-sys.com) / create the Method
    @ Purpose:       US-0010067 - [Intellum] Add custom button "Create Enrollments" on the related Enrollments list Customer 360 page.
    *********************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> createIntellumEnrollment(  intellumapp__IntellumEnrollment__c intellumEnrollment,
                                                                List<intellumapp__IntellumActivity__c> intellumActivities,
                                                                Decimal intellumUserAppId) {
        Map<String,Object> mapResult = new Map<String,Object>();
        List<intellumapp__IntellumEnrollment__c> intellumEnrollmentlist = new List<intellumapp__IntellumEnrollment__c>();
        List<ResultWrapper> activityToAPIErrors = new List<ResultWrapper>();                                                           
        for(intellumapp__IntellumActivity__c activity:intellumActivities){
            
            intellumapp__IntellumEnrollment__c oneIntellum = new intellumapp__IntellumEnrollment__c();
            List<intellumapp__IntellumEnrollment__c> intellumList = new List<intellumapp__IntellumEnrollment__c>();
            Map<String,Object> mapCourse  = new Map<String,Object>{'id'=>activity.intellumapp__id__c};
            Map<String,Object> mapUser = new Map<String,Object>{'id'=>intellumUserAppId};
            Map<String,Object> mapEnrol  = new Map<String,Object>
                {
                'course'=>mapCourse,
                'user'=>mapUser,
                'due_on'=> intellumEnrollment.intellumapp__due_on__c,
                'status'=>intellumEnrollment.intellumapp__status__c,
                'relationship_type'=>intellumEnrollment.intellumapp__relationship_type__c,
                'relationship_reason'=>intellumEnrollment.Relationship_Reason__c
                };
            try{
                Map<String,Object> mapParam  = new Map<String,Object>{'enrollment'=>mapEnrol};                   
                HIVE_Intellum.createEnrollmentService createEnrol = new HIVE_Intellum.createEnrollmentService(mapParam);
                createEnrol.sendRequest();
               // mapResult = createEnrol.getResult();
                intellumList = ((List<intellumapp__IntellumEnrollment__c>)createEnrol.getListObject());
            } catch(Exception e) {
                // adding activtiy fail to api
                ResultWrapper oneErrorActivity = new ResultWrapper(activity,e.getMessage(),e.getStackTraceString());
                activityToAPIErrors.add(oneErrorActivity);
            }
            // maping fields for Intellum Enrollment
            if(!intellumList.isEmpty()){
                oneIntellum = createSFActivity(intellumList[0],intellumEnrollment,activity.Id);
                //add to list
                intellumEnrollmentlist.add(oneIntellum);
            }
        }
        // add activity fail to api
        mapResult.put('activitiesFailAPI',activityToAPIErrors);
        mapResult.put('allActivityCount',intellumActivities.size());
        // create intellum enrollment
        if(!intellumEnrollmentlist.isEmpty()){
            try{
                upsert intellumEnrollmentlist intellumapp__id__c;
                mapResult.put('intellumEnrollmentlist',intellumEnrollmentlist);
                mapResult.put('status','ok');
            } catch(Exception e) {
                mapResult.put('status','ko');mapResult.put('error',e.getMessage());mapResult.put('errorDetail',e.getStackTraceString());
                //AuraHandledException auraError = new AuraHandledException(e.getMessage());
                //auraError.setMessage(e.getMessage());
                //throw auraError;
            }
        }
        return mapResult;
    }  
    /*********************************************************************************************************************************
    @ Method:        createSFActivity
    @ Version:       1.0
    @ Author:        SRONG TIN (srong.tin@gaea-sys.com)
    @ Purpose:       To make better look
    @ Parameter:     intellumFromAPI,intellumEnrollment, activityId
    @ Change history: 09.09.2021 / SRONG TIN (srong.tin@gaea-sys.com) / create the Method
    *********************************************************************************************************************************/
    private static intellumapp__IntellumEnrollment__c  createSFActivity(intellumapp__IntellumEnrollment__c intellumFromAPI,
                                                                        intellumapp__IntellumEnrollment__c intellumEnrollment, 
                                                                        String activityId){
        intellumapp__IntellumEnrollment__c oneIntellum = new intellumapp__IntellumEnrollment__c();
            oneIntellum.intellumapp__IntellumActivity__c = activityId;
            oneIntellum.intellumapp__IntellumUser__c = intellumEnrollment.intellumapp__IntellumUser__c;
            oneIntellum.intellumapp__accepted_invite__c = intellumFromAPI.intellumapp__accepted_invite__c;
            oneIntellum.Seller__c = intellumEnrollment.Seller__c;
            oneIntellum.Relationship_Reason__c = intellumEnrollment.Relationship_Reason__c;
            oneIntellum.intellumapp__completed_activities_count__c = intellumFromAPI.intellumapp__completed_activities_count__c;
            oneIntellum.intellumapp__course_id__c = intellumFromAPI.intellumapp__course_id__c;
            oneIntellum.intellumapp__created_on__c = intellumFromAPI.intellumapp__created_on__c;
            oneIntellum.intellumapp__due_on__c = intellumFromAPI.intellumapp__due_on__c;
            oneIntellum.intellumapp__enrolled_on__c = intellumFromAPI.intellumapp__enrolled_on__c;
            oneIntellum.intellumapp__expires_on__c = intellumFromAPI.intellumapp__expires_on__c;
            oneIntellum.intellumapp__id__c = intellumFromAPI.intellumapp__id__c;
            oneIntellum.intellumapp__progress__c = intellumFromAPI.intellumapp__progress__c;
            oneIntellum.intellumapp__relationship_type__c = intellumFromAPI.intellumapp__relationship_type__c;
            oneIntellum.intellumapp__status__c = intellumFromAPI.intellumapp__status__c;
            oneIntellum.intellumapp__time__c = intellumFromAPI.intellumapp__time__c;
            oneIntellum.intellumapp__updated_on__c = intellumFromAPI.intellumapp__updated_on__c;
            oneIntellum.intellumapp__user_id__c = intellumFromAPI.intellumapp__user_id__c;
        return oneIntellum;
    }

    //SRONG TIN:wrapper class for response list createIntellumEnrollment
    private class ResultWrapper {
    	@auraEnabled public intellumapp__IntellumActivity__c activity {get;set;}
    	@auraEnabled public String message {get;set;}
        @auraEnabled public String messageStackTrace {get;set;}
        public ResultWrapper(intellumapp__IntellumActivity__c activity,String message,String messageStackTrace){
            this.activity = activity;
            this.message = message;
            this.messageStackTrace = messageStackTrace;
        }
    }
}