public with sharing class DART6_Delivery {
    public DART6_Delivery(){
        
    }
    // /********************
    // Deprecate by Acmatac SEING, US-0007908 [Ads 2020] Migrate DFP Batch Process to Hive
    // @   Since this is the old process, after migration it will be deprecated.
    // @   All the old functionalities and related are removed.
    // ********************/

    // public static final Integer DELIVERY_BATCH_SIZE = 200;
    // public static final Integer DAY_NUM_SPLIT = 2;

    // public static final String LINEITEM_API_NAME = Util.NS+'IO_LineItem__c'; 
    // public static final String DAILY_API_NAME = Util.NS+'RS_Daily__c';
      
    // public static final String SOBJECT_LINEITEM = 'IO LineItem';
    // public static final String SOBJECT_DAILY = 'Revenue Schedule Daily'; 
    
    // public static final String DART_STATUS_NEW = 'New';
    // public static final String DART_STATUS_AWAIT = 'Await';
    // public static final String DART_STATUS_FINISHED = 'Finished'; 
    
    // public static final String SCH_TYPE_DAILY = 'Daily'; 
    // public static final String SCH_TYPE_MONTHLY = 'Monthly';
    // public static final String SCH_TYPE_MANUALLY = 'Manually';
    // public static final String SCH_TYPE_MANUALLYPOLLING = 'Manually - Polling';
    // public static final String SCH_TYPE_ALL = 'All';
    
    // public static final String REPORT_QUERY_FAILED = 'FAILED';
    // public static final String REPORT_QUERY_INPROGRESS = 'IN_PROGRESS';
    // public static final String REPORT_QUERY_COMPLETED = 'COMPLETED';
    // public static final String REPORT_QUERY_CANCELLED = 'CANCELLED';
    
    // public static final String TYPE_MANUALLY_POLLING = 'Polling Import';
    // public static final Integer MAX_ATTAMPT_WAITING = 10;
    // public static final String REPORT_QUERY_RETRY = 'RETRY';
    // public static final Integer MAX_RETRY_IMPORT = 3;
    // public static final String QUERY_START_DATE = '%StartDate%';
    // public static final String QUERY_END_DATE = '%EndDate%';
    
    // public static final String DFP_DELIVERY = 'Dfp';
    // public static final String ADX_IMPORT = 'Adx';
    
    
    // public static void start(String scheduleType, String sobj) {
    //     start(scheduleType, sobj, '');
    // }
    
    // public static void start(String scheduleType, String sobj, Date startDate, Date endDate) {
    //     start(scheduleType, sobj, startDate, endDate, '');
    // }
    
    // public static void start(String scheduleType, String sobj, String importType) {
    //     DateTime dToday = System.now();
    //     DateTime dNextMonth = dToday.addMonths(1);
    //     DateTime dLastMonth = dToday.addMonths(-1);
    //     DateTime dYesterday = dToday.addDays(-1);
    //     DateTime dB4Yesterday = dToday.addDays(-2);
    //     DateTime dTomorrow = dToday.addDays(1); 
    //     DateTime dStartThisMonth = DateTime.newInstance(dToday.year(),dToday.month(),1);
    //     DateTime dStartNextMonth = DateTime.newInstance(dNextMonth.year(),dNextMonth.month(),1);
    //     DateTime dStartLastMonth = DateTime.newInstance(dLastMonth.year(),dLastMonth.month(),1);
    //     DateTime startDate;  
    //     DateTime endDate;
    //     if(sobj == SOBJECT_DAILY){
    //         startDate = dB4Yesterday;
    //         endDate = dYesterday;
    //     }else if(sobj == SOBJECT_LINEITEM){
    //         startDate = dStartThisMonth;
    //         endDate = dToday;
    //     }
    //     if(sobj == SOBJECT_DAILY && scheduleType  == SCH_TYPE_ALL ){
    //          endDate = dYesterday;
    //          //case current month is january 
    //          Integer m = dToday.month() == 1 ? 12 : (dToday.month()-1) ;
    //          Integer y = dToday.month() == 1 ? ( dToday.year()-1 ) : dToday.year() ;
    //          startDate = DateTime.newInstance( y , m  ,1);
    //     }
    //     start(scheduleType, sobj, Date.valueOf(startDate), Date.valueOf(endDate), importType);
    // }
    // public static void start(String scheduleType, String sobj, Date startDate, Date endDate, String importType) {
    //     start( scheduleType,  sobj,  startDate,  endDate,  importType,null);
    // }
    
    // public static void start(String scheduleType, String sobj, Date startDate, Date endDate, String importType, Id adServerId) {
    //     List<Date> lstStartDate = new List<Date>();
    //     List<Date> lstEndDate = new List<Date>();
    //     if( sobj != SOBJECT_LINEITEM && Math.abs(startDate.daysBetween(endDate)) > DAY_NUM_SPLIT ) {
    //         Date tmpDate = startDate;
    //         Date tmpDate2 = endDate;
    //         while(tmpDate < endDate){
    //             lstStartDate.add(Date.newInstance(tmpDate.year(),tmpDate.month(),tmpDate.day()));
    //             tmpDate = tmpDate.addDays(DAY_NUM_SPLIT);
    //             tmpDate2 = tmpDate.addDays(-1);
    //             lstEndDate.add(Date.newInstance(tmpDate2.year(),tmpDate2.month(),tmpDate2.day()));
    //         }
    //         if(tmpDate2 < endDate || startDate == endDate) {
    //             lstStartDate.add(Date.newInstance(endDate.year(), endDate.month(), endDate.day()));
    //             lstEndDate.add(Date.newInstance(endDate.year(), endDate.month(), endDate.day()));
    //         }
    //     } else {
    //         lstStartDate.add(startDate);
    //         lstEndDate.add(endDate);
    //     }
        
    //     DART_Delivery_Support__c[] listDDs = new List<DART_Delivery_Support__c>();
    //     for(AdServer_Login__c login : [SELECT RecordType.name,Name,Login_URL__c, User_Name__c, Password__c, Network_ID__c FROM AdServer_Login__c WHERE  Active__c = true AND isDeleted = false ]) {

    //         if(String.isNotBlank(adServerId) && login.Id != adServerId ) continue;

    //          for(Integer i = 0; i < lstStartDate.size(); i++){
    //             listDDs.add(new DART_Delivery_Support__c(
    //                 AdServer_Login__c=login.Id,Attempt__c=0,
    //                 Schedule_Type__c = scheduleType,
    //                 Sobject__c = sobj,
    //                 Status__c = DART_STATUS_NEW,
    //                 Query_Start_Date__c = lstStartDate[i],
    //                 Query_End_Date__c = lstEndDate[i],
    //                 Import_Type__c=(ADX_IMPORT.equals(importType)?'Adx Import':'Delivery Import')));
    //          }
    //     }
        
    //     if(!listDDs.isEmpty()) {
    //         insert listDDs;
    //         DART6BatchDeliverySupport batchSupport = new DART6BatchDeliverySupport(listDDs[0].Id, DART6BatchDeliverySupport.CALL_TYPE_REQUEST_REPORT, importType);
    //         ID batchprocessid = Database.executeBatch(batchSupport);
    //     }
    // } 
    
    // public static void start(Id ioId){
    //     IO_LineItem__c IOLineItem;
    //     try {
    //         IOLineItem = (IO_LineItem__c) QueryUtil.queryRecords(Util.NS+'IO_LineItem__c',Util.NS+'IO__c=:value1', new Set<String>{Util.NS+'Product__r.'+Util.NS+'site__r.'+Util.NS+'Country__c',Util.NS+'IO__r.'+Util.NS+'Campaign_Start__c',Util.NS+'IO__r.'+Util.NS+'Campaign_End__c',Util.NS+'IO__r.'+Util.NS+'Order_Id__c'},new Map<String,Object>{'value1'=>ioId}).get(0);
    //     } catch(ListException ex) {
    //         throw new ExceptionGroup.CustomException('Cannot start schedule delivery for this record');
    //     }

    //     Integer numPending = [Select count() from DART_Delivery_Support__c 
    //             WHERE Filters__c LIKE :'%' + IOLineItem.IO__r.Order_Id__c + '%'
    //             AND Sobject__c=:SOBJECT_DAILY
    //             AND Status__c <> :DART6_Delivery.DART_STATUS_FINISHED];

    //     if( IOLineItem.IO__r.Order_Id__c==null ) throw new ExceptionGroup.CustomException('This IO have not booked to DFP yet');
    //     if( numPending>0 ) throw new ExceptionGroup.CustomException('Importing Delivery of this record is already running.');
        
	// 	Date startD = IOLineItem.IO__r.Campaign_Start__c;
    // 	Date endD = IOLineItem.IO__r.Campaign_End__c;
    // 	if(startD > system.today()) return;
    // 	if(endD > system.today()) endD = system.today();
		
    //     AdServer_Login__c login = DARTUtil.getCredential(DARTUtil.DART6,IOLineItem.Product__r.Site__r.Country__c);
        
    //     DART_Delivery_Support__c dds = new DART_Delivery_Support__c(
    //                 AdServer_Login__c=login.Id,
    //                 Attempt__c=0,
    //                 Schedule_Type__c = '',
    //                 Sobject__c = SOBJECT_DAILY,
    //                 Status__c = DART_STATUS_NEW,
    //                 Filters__c = 'ORDER_ID= '+ IOLineItem.IO__r.Order_Id__c , 
    //                 Query_Start_Date__c = startD,
    //                 Query_End_Date__c = endD,
    //                 Import_Type__c='Delivery Import');
    //     insert dds;
    //     DART6BatchDeliverySupport batchSupport = new DART6BatchDeliverySupport(dds.id, DART6BatchDeliverySupport.CALL_TYPE_REQUEST_REPORT, 'Delivery Import');
    //     Database.executeBatch(batchSupport);
    // }
    
    // /** Called from 'start' of Main scheduler. and from Batch to continue to next Login */
    // public static void doStart(DART_Delivery_Support__c dds, String importType) {   
        
    //     if(DARTUtil.DART6.equals(dds.AdServer_Login__r.RecordType.name)) 
    //     {
    //         String addQuery='';
    //         if(ADX_IMPORT.equals(importType)) addQuery = 'WHERE LINE_ITEM_TYPE = \'AD_EXCHANGE\'';
    //         if(String.isNotBlank(dds.Filters__c)) addQuery = 'WHERE '+ dds.Filters__c;
    //         DART6_REPORTSERVICE.REPORTServiceInterfacePort reportService = buildQueryService(dds);
    //         Dart6_ReportService.ReportJob reportJob = buildReportQuery(dds, addQuery);
    //         createReportJob(dds, reportService, reportJob, importType);
    //     }
    // }
    
    
    
    // /** 
    //  * to build queryService
    //  * @param DART_Delivery_Support__c
    //  * @return DART6_REPORTSERVICE.REPORTServiceInterfacePort
    //  */
    // public static DART6_REPORTSERVICE.REPORTServiceInterfacePort buildQueryService(DART_Delivery_Support__c dds){       
    //     return buildQueryService(dds.AdServer_Login__r.Name, dds.AdServer_Login__r.Network_ID__c);
    // } 
    
    
    // /**
    //  * @retrun DART_Delivery_Support record by recordId
    //  * @param recordId
    //  */
    // public static DART_Delivery_Support__c getDeliverySupportRecord(String recId){
    //      return [Select Filters__c,AdServer_Login__r.Name, AdServer_Login__r.Network_ID__c, AdServer_Login__r.RecordType.name,Status__c, Sobject__c, Schedule_Type__c, Job_Id__c, DART_Status__c, Attempt__c, AdServer_Login__c, Query_Start_Date__c, Query_End_Date__c, Retry_Counter__c From DART_Delivery_Support__c where Id =: recId];
    // }
    
    // /** 
    //  * dart6: check job status 
    //  * @param DART_Delivery_Support
    //  * @updated Chr: 13-08-2015 
    //  *               Version v201505 not use methode getReportJob anymore, we replaced it with getReportJobStatus 
    //  *               and return as string
    //  */ 
    // public static void checkJobStatus(DART_Delivery_Support__c dds, String importType) {
    //     DART6_REPORTSERVICE.REPORTServiceInterfacePort reportService = DART6_Delivery.buildQueryService(dds);
    //     //request to get status here: COMPLETED, IN_PROGRESS, FAILED
    //     String repJobStatus = reportService.getReportJobStatus((long)dds.Job_Id__c);
    //     // if complete ok -> run controller batch from importDelivery()
    //     if(repJobStatus == DART6_REPORTSERVICE.REPORTJOBSTATUS_COMPLETED){
    //         Delivery_Controller controller = new Delivery_Controller(dds);
    //         controller.setReportService(reportService);
    //         controller.setJobid((long)dds.Job_Id__c);
    //         controller.importDelivery(importType);
    //         processBatchDelivery(dds, controller.getListDart());
    //         return;
    //     }
    //     // if complete FAILED -> log
    //     if(repJobStatus == DART6_REPORTSERVICE.REPORTJOBSTATUS_FAILED){
    //         dds.DART_Status__c = REPORT_QUERY_FAILED;
    //         dds.Status__c = DART_STATUS_FINISHED;
    //         update dds;
    //         throw new ExceptionGroup.DARTException('Failed to query report from server');
    //         return;
    //     }
        
    //     // If attempt more than MAX_ATTAMPT_WAITING, report job is stuck. A new job will be attempted 
    //     if(dds.Attempt__c > MAX_ATTAMPT_WAITING && dds.Status__c == DART_STATUS_AWAIT){
    //         retryImport(dds, new DARTLogger.LogMessage(
    //                             dds.Id ,'Import Process was abandoned',
    //                             'DART6_Delivery.checkJobStatus', dds.AdServer_Login__r.RecordType.name,
    //                             DARTLogger.TYPE_ERROR, dds.Status__c, 'Requesting report takes time too long with more than ' + MAX_ATTAMPT_WAITING + ' attempts' ), importType);
    //         return;
    //     }
        
    //     // if in progress -> run scheduler watcher, attempt++
    //     dds.DART_Status__c = REPORT_QUERY_INPROGRESS;
    //     dds.Status__c = DART_STATUS_AWAIT;
    //     dds.Attempt__c = dds.Attempt__c + 1;
    //     createSchedulerWatcher(dds.Id, dds.Sobject__c, importType);
    //     update dds;
     
    // }
    
    
    // /**
    //  * start to run next AdserverLogin
    //  * @param string sobject name
    //  * @param String scheduleType
    //  */
    // public static void startNextAdServer(String sobj, String scheduletype, String importType){
    //     DART_Delivery_Support__c nextdds ;
    //     List<DART_Delivery_Support__c> ldds = [Select AdServer_Login__r.Name, AdServer_Login__r.Network_ID__c, AdServer_Login__r.RecordType.name, Sobject__c, Schedule_Type__c, Job_Id__c, DART_Status__c, Status__c, Attempt__c, AdServer_Login__c, Query_Start_Date__c, Query_End_Date__c From DART_Delivery_Support__c Where 
    //         (Status__c =: DART_STATUS_NEW OR DART_Status__c =: REPORT_QUERY_INPROGRESS) And 
    //         Sobject__c =: sobj And 
    //         Schedule_Type__c =: scheduletype 
    //         order by CreatedDate];
    //     //Avoid same network progressing the same time which causes LockRow error
    //     Set<String> progressingNetworks = new Set<String>();
    //     for (DART_Delivery_Support__c dds : ldds) {
    //         if (dds.DART_Status__c == REPORT_QUERY_INPROGRESS) {
    //             progressingNetworks.add(dds.AdServer_Login__r.Name);
    //         }
    //         if (nextdds == null && dds.Status__c == DART_STATUS_NEW) {
    //             nextdds = dds;
    //         }
    //     }
    //     for (DART_Delivery_Support__c dds : ldds) {
    //         if (nextdds != null && !progressingNetworks.contains(nextdds.AdServer_Login__r.Name)) {
    //             break;
    //         }
    //         if (dds.Status__c == DART_STATUS_NEW) {
    //             nextdds = dds;
    //         }
    //     }
    //     if (nextdds == null) {
    //         return;
    //     }
    //     DART6BatchDeliverySupport batchSupport = new DART6BatchDeliverySupport(ldds[0].Id, DART6BatchDeliverySupport.CALL_TYPE_REQUEST_REPORT, importType);
    //     ID batchprocessstartNextAdServerid = Database.executeBatch(batchSupport);
    // } 
    
    
    
    // // =================Private static methods/variables==================
    
    // public static Map<String,String[]> queryFieldsDART6 = new Map<String, String[]>{
    //     // for testing with test network, KH.
    //     //SOBJECT_DAILY => new String[]{'AD_SERVER_IMPRESSIONS','AD_SERVER_CLICKS', 'AD_SERVER_CTR', 'AD_SERVER_CPM_AND_CPC_REVENUE' },
        
    //     // Not support with test network
    //     SOBJECT_DAILY => new String[]{'TOTAL_LINE_ITEM_LEVEL_IMPRESSIONS','TOTAL_LINE_ITEM_LEVEL_CLICKS', 'AD_SERVER_ACTIVE_VIEW_VIEWABLE_IMPRESSIONS', 'AD_SERVER_ACTIVE_VIEW_MEASURABLE_IMPRESSIONS', 'AD_SERVER_ACTIVE_VIEW_VIEWABLE_IMPRESSIONS_RATE','AD_SERVER_CPM_AND_CPC_REVENUE','AD_SERVER_LINE_ITEM_LEVEL_PERCENT_CLICKS','AD_SERVER_IMPRESSIONS','AD_SERVER_LINE_ITEM_LEVEL_PERCENT_IMPRESSIONS','AD_SERVER_CLICKS'},
        
    //     SOBJECT_LINEITEM => new String[]{'AD_SERVER_IMPRESSIONS', 'AD_SERVER_CTR', 'AD_SERVER_ACTIVE_VIEW_VIEWABLE_IMPRESSIONS', 'AD_SERVER_ACTIVE_VIEW_MEASURABLE_IMPRESSIONS', 'AD_SERVER_ACTIVE_VIEW_VIEWABLE_IMPRESSIONS_RATE'}
    // };
    // public static Map<String,String[]> dimensionFieldsDART6 = new Map<String, String[]>{
    //         SOBJECT_DAILY => new String[] {'ORDER_ID', 'LINE_ITEM_ID', 'DATE'},
    //         SOBJECT_LINEITEM => new String[] {'ORDER_ID', 'LINE_ITEM_ID'}
    // };
    
    // public static Map<String,String[]> dimensionAttributesDART6 = new Map<String, String[]>{
    //         SOBJECT_DAILY => new String[]{'LINE_ITEM_DELIVERY_INDICATOR'},
    //         SOBJECT_LINEITEM => new String[]{'LINE_ITEM_LIFETIME_IMPRESSIONS', 'LINE_ITEM_LIFETIME_CLICKS', 'LINE_ITEM_DELIVERY_INDICATOR'}
    // };
    
    // static Map<String, String> mGeneralQuery = new Map<String, String>{
    //     SOBJECT_DAILY => 'Select id, '+Util.NS+'Date__c, '+Util.NS+'Viewable_Clicks__c, '+Util.NS+'Viewable_Impressions__c, '+Util.NS+'Revenue_Schedule_Monthly__r.'+Util.NS+'IO_LineItem__r.'+Util.NS+'IO__r.'+Util.NS+'Order_Id__c, '+Util.NS+'Revenue_Schedule_Monthly__r.'+Util.NS+'IO_LineItem__r.'+Util.NS+'Ad_Id__c, '+Util.NS+'Product__r.'+Util.NS+'Site__r.'+Util.NS+'Country__c ' + 
    //     				'From ' + DAILY_API_NAME + ' Where %DATECRIT% '+Util.NS+'Product__r.'+Util.NS+'Site__r.'+Util.NS+'Country__c =\'%1\' AND '+Util.NS+'Product__r.RecordType.Name =\'%2\' AND '+Util.NS+'Revenue_Schedule_Monthly__r.'+Util.NS+'IO_LineItem__r.'+Util.NS+'Ad_Id__c <> null ',
    //     SOBJECT_LINEITEM => 'Select id, '+Util.NS+'Ad_Id__c, '+Util.NS+'IO__r.'+Util.NS+'Order_Id__c, '+Util.NS+'Product__r.'+Util.NS+'Site__r.'+Util.NS+'Country__c ' + Util.NS+'CTR__c ' + Util.NS+'Impressions_Delivered__c ' +
    //     				'From ' + LINEITEM_API_NAME + ' Where %DATECRIT% '+Util.NS+'Product__r.'+Util.NS+'Site__r.'+Util.NS+'Country__c =\'%1\' AND '+Util.NS+'Product__r.RecordType.Name =\'%2\' AND '+Util.NS+'Ad_Id__c <> null '
    // };
    // static Map<String, String> mQuerySObject = new Map<String, String>{
    //     SOBJECT_DAILY => mGeneralQuery.get(SOBJECT_DAILY).replace('%DATECRIT%', Util.NS+'Date__c >= ' + QUERY_START_DATE + ' AND '+Util.NS+'Date__c <= ' + QUERY_END_DATE + ' AND '),
    //     SOBJECT_LINEITEM => mGeneralQuery.get(SOBJECT_LINEITEM).replace('%DATECRIT%', Util.NS+'from_Date__c <= ' + QUERY_START_DATE + ' AND '+Util.NS+'until_Date__c >= ' + QUERY_END_DATE + ' AND ')
    // };
    
    // public static string getOrderId(sObject sobj) {
    // 	String sobjName = String.valueOf(sobj.getSObjectType());
    	
    // 	if(sobjName == DART6_Delivery.LINEITEM_API_NAME) {
    // 		return String.valueOf(sobj.getSObject(Util.NS+'IO__r').get(Util.NS+'Order_Id__c'));
    // 	} else if(sobjName == DART6_Delivery.DAILY_API_NAME) {
    // 		return String.valueOf(sobj.getSObject(Util.NS+'Revenue_Schedule_Monthly__r').getSObject(Util.NS+'IO_LineItem__r').getSObject(Util.NS+'IO__r').get(Util.NS+'Order_Id__c'));
    // 	}
    // 	return '';	
    // }
    // public static string getAdId(sObject sobj) {
    // 	String sobjName = String.valueOf(sobj.getSObjectType());
    	
    // 	if(sobjName == DART6_Delivery.LINEITEM_API_NAME) {
    // 		return String.valueOf(sobj.get(Util.NS+'Ad_Id__c'));
    // 	} else if(sobjName == DART6_Delivery.DAILY_API_NAME) {
    // 		return String.valueOf(sobj.getSObject(Util.NS+'Revenue_Schedule_Monthly__r').getSObject(Util.NS+'IO_LineItem__r').get(Util.NS+'Ad_Id__c'));
    // 	}
    // 	return '';	
    // }
    // public static string getCountry(sObject sobj) {
    // 	return String.valueOf(sobj.getSObject(Util.NS+'Product__r').getSObject(Util.NS+'Site__r').get(Util.NS+'Country__c'));	
    // }
    
    // /** 
    //  * @param AdServerLoginName
    //  * @param NetworkId
    //  * @return DART6_REPORTSERVICE.REPORTServiceInterfacePort
    //  */
    // public static DART6_REPORTSERVICE.REPORTServiceInterfacePort buildQueryService(String adServName, String netId){
    //     AdServer_Login__c login = DARTUtil.getCredential(DARTUtil.DART6, adServName);
    //     String authToken = DARTUtil.getAccessToken(login); // new version 201405
        
    //     // Build Service Request Header
    //     DART6_REPORTSERVICE.SoapRequestHeader header = new DART6_REPORTSERVICE.SoapRequestHeader();
    //     header.applicationName='ReportService';
    //     header.networkCode= netId;
        
    //     Map<String,String> inputHttpHeaders_x = new Map<String, String>();
    //     inputHttpHeaders_x.put('Authorization', 'Bearer '+authToken);
        
    //     DART6_REPORTSERVICE.REPORTServiceInterfacePort reportService = new DART6_REPORTSERVICE.ReportServiceInterfacePort();
    //     reportService.RequestHeader = header;
    //     reportService.inputHttpHeaders_x = inputHttpHeaders_x;
    //     reportService.timeout_x = 120000;//Extend timeout due to massive download size
    //     return reportService;
    // }
    
    // static Dart6_ReportService.ReportJob buildReportQuery(DART_Delivery_Support__c dds, String addQuery){
        
    //     String sobjType = dds.Sobject__c;
    //     // Create report query.
    //     Dart6_ReportService.Statement statement = new Dart6_ReportService.Statement();
    //     statement.query = addQuery;
    //     Dart6_ReportService.ReportQuery reportQuery = new Dart6_ReportService.ReportQuery();
    //     reportQuery.statement = statement;
    //     reportQuery.dateRangeType = 'CUSTOM_DATE';
    //     reportQuery.columns = DART6_Delivery.queryFieldsDART6.get(sobjType);
    //     reportQuery.dimensions = DART6_Delivery.dimensionFieldsDART6.get(sobjType);
        
    //     reportQuery.startDate = new Dart6_ReportService.Date_x();
    //     reportQuery.startDate.year = dds.Query_Start_Date__c.year();
    //     reportQuery.startDate.month = dds.Query_Start_Date__c.month();
    //     reportQuery.startDate.day = dds.Query_Start_Date__c.day();
        
    //     reportQuery.endDate = new Dart6_ReportService.Date_x();
    //     reportQuery.endDate.year = dds.Query_End_Date__c.year();
    //     reportQuery.endDate.month = dds.Query_End_Date__c.month();
    //     reportQuery.endDate.day = dds.Query_End_Date__c.day();
    //     reportQuery.dimensionAttributes = DART6_Delivery.dimensionAttributesDART6.get(sobjType);
        
    //     System.debug('Dart reportQuery :::::' + reportQuery);
    //     Dart6_ReportService.ReportJob reportJob = new Dart6_ReportService.ReportJob();
    //     reportJob.reportQuery = reportQuery;
    //     return reportJob;
    // }
    
    // /** dart6: create a report job at dart server */
    // static void createReportJob(DART_Delivery_Support__c dds, DART6_REPORTSERVICE.REPORTServiceInterfacePort reportService, Dart6_ReportService.ReportJob reportJob, String importType)
    // {
    //     dds.Job_Id__c = runReportRequest(reportService, reportJob);
    //     dds.DART_Status__c = REPORT_QUERY_INPROGRESS;
    //     dds.Status__c = DART_STATUS_AWAIT;
    //     dds.Attempt__c = dds.Attempt__c + 1;
    //     update dds;
    //     createSchedulerWatcher(dds.Id, dds.Sobject__c, importType);
    // } 
    
    // static void createSchedulerWatcher(String ddsId, String sObj, String importType){
    //     DART6SchReportRequestWatcher watcher = new DART6SchReportRequestWatcher(ddsId, importType);
    //     System.schedule('DART6 Delivery RunningReport ' + ddsId + ' at ' + Datetime.now()  , watcher.createCronExpForNextFireTime(), watcher);
    // }
    
    // /**
    //  * call to process batch delivery
    //  * @param DART_Delivery_Support__c
    //  * @param List of DartObject
    //  */
    // static void processBatchDelivery(DART_Delivery_Support__c dds, List<DARTObject.IDARTGenericObject> lstDartObject){
    //     String dsStartDate = DateTime.newInstance(dds.Query_Start_Date__c.year(),dds.Query_Start_Date__c.month(),dds.Query_Start_Date__c.day()).format(DARTUtil.DART_DATEFORMAT_QUERY) ;
    //     String dsEndDate = DateTime.newInstance(dds.Query_End_Date__c.year(),dds.Query_End_Date__c.month(),dds.Query_End_Date__c.day()).format(DARTUtil.DART_DATEFORMAT_QUERY) ;
    //     String queryStr = mQuerySObject.get(dds.Sobject__c).replace('%1', dds.AdServer_Login__r.Name).replace('%2', dds.AdServer_Login__r.RecordType.Name);
    //     queryStr = queryStr.replaceAll(QUERY_START_DATE, dsStartDate).replaceAll(QUERY_END_DATE, dsEndDate);
	// 	// changed to fix Num Batch Limit error
    //     if (Test.isRunningTest()) {
    //     	queryStr = queryStr.replace('FOR UPDATE', 'LIMIT 2');
    //     }
    //     BatchDeliveryProcess batchDelivery = new BatchDeliveryProcess(queryStr, lstDartObject, dds.Id);
    //     ID batchprocessid = Database.executeBatch(batchDelivery, DELIVERY_BATCH_SIZE);
    // }
    
    // /**
    //  * Retry another job after a time-out failure OR job has been stuck
    //  */
   	// static void retryImport(DART_Delivery_Support__c failedDds, DARTLogger.LogMessage logmsg, String importType){
    //     if(failedDds.Status__c != DART_STATUS_FINISHED && failedDds.Retry_Counter__c < MAX_RETRY_IMPORT){
    //         DART_Delivery_Support__c retriedDds = failedDds.clone(false);
    //         retriedDds.Attempt__c = 0;
    //         retriedDds.Status__c = DART_STATUS_NEW;
    //         retriedDds.DART_Status__c = null;
    //         retriedDds.Job_Id__c = null;
    //         retriedDds.Retry_Counter__c = failedDds.Retry_Counter__c + 1;
    //         insert retriedDds;
    //         failedDds.Retried_DART_Delivery_Support__c = retriedDds.Id;
    //         failedDds.DART_Status__c = REPORT_QUERY_RETRY;
    //     }
    //     failedDds.Status__c = DART_STATUS_FINISHED;
    //     if(failedDds.DART_Status__c != REPORT_QUERY_RETRY) failedDds.DART_Status__c = REPORT_QUERY_FAILED;
    //     update failedDds;
    //     if(logmsg != null) DARTLogger.getInstance().log(failedDds.Id,new List<DARTLogger.LogMessage>{logmsg});
    //     startNextAdServer(failedDds.Sobject__c, failedDds.Schedule_Type__c, importType);
    // }
    
    // public static Long runReportRequest(DART6_REPORTSERVICE.REPORTServiceInterfacePort reportService, Dart6_ReportService.ReportJob reportJob){
    //     // Run report job.
    //     reportJob = reportService.runReportJob(reportJob);
    //     return reportJob.id;
    // }


    // /*---------------------------------
    // @  Change history:  14.12.2020 / Acmatac SEING / US-0007908 Copied from old DeliveryController and make it as Inner Class
    // ---------------------------------*/
    // class Delivery_Controller  extends DARTObject.AbstractDARTController{
    
    //     AdServer_Login__c login;
    //     String breakDown, dateRange;
    //     private Long jobid;
    //     private DART6_REPORTSERVICE.REPORTServiceInterfacePort reportService;
        
    //     public DART_Delivery_Support__c dartDelStatus {get; set;}
    //     public String selectedMonth {get;set;}
    //     public List<SelectOption> lstOptMonths {get; set;}
    //     public String fromId {get; set;}
    //     public Boolean productMode {get; set;}
    //     public Boolean rSMode {get; set;}
    //     public Boolean rSDMode {get; set;}
        
    //     public Delivery_Controller() {
    //         fromId = System.currentPageReference().getParameters().get('id');
    //         dartDelStatus = new DART_Delivery_Support__c();
    //         dartDelStatus.Sobject__c = System.currentPageReference().getParameters().get('sobjType');
            
    //         //Display Tab style
    //         rSMode = dartDelStatus.Sobject__c == DART6_Delivery.SOBJECT_LINEITEM;
    //         rSDMode = dartDelStatus.Sobject__c == DART6_Delivery.SOBJECT_DAILY;
            
    //         //Previous Six months
    //         Date todayDate = System.today();
    //         lstOptMonths = new List<SelectOption>();
    //         for(Integer i = 0; i > -6 ; i--){
    //             Date optionDate = todayDate.addMonths(i);
    //             String monthStr = BatchDeliveryProcess.MINT_TO_MONTH.get(optionDate.month());
    //             lstOptMonths.add(new SelectOption(optionDate.month() + '-' + optionDate.year() , monthStr + ' - ' + optionDate.year()));
    //         }
    //         selectedMonth = lstOptMonths[0].getValue();
    //     }
        
    //     public Delivery_Controller(AdServer_Login__c login,String breakDown,String dateRange) {
    //         this.login = login;
    //         this.breakDown = breakDown;
    //         this.dateRange = dateRange;
    //         dartDelStatus = new DART_Delivery_Support__c();
    //     }
        
    //     public Delivery_Controller(DART_Delivery_Support__c dds) {
    //         dartDelStatus = dds;
    //         login = [SELECT RecordType.name,Name,Login_URL__c, User_Name__c, Password__c, Network_ID__c FROM AdServer_Login__c WHERE Id =: dds.AdServer_Login__c limit 1];
    //     }
        
        
        
    //     /**
    //      * Start import process
    //      */
    //     public PageReference proceedImport(){
    //         Date startDate = dartDelStatus.Query_Start_Date__c;
    //         Date endDate = dartDelStatus.Query_End_Date__c;
    //         List<String> ldElement = selectedMonth.split('-');
    //         if(dartDelStatus.Sobject__c == DART6_Delivery.SOBJECT_LINEITEM){
    //             Integer yearInt = Integer.valueOf(ldElement[1]);
    //             Integer monthInt = Integer.valueOf(ldElement[0]);
    //             startDate = Date.newInstance(yearInt,monthInt,1);
    //             endDate = Date.newInstance(yearInt,monthInt,Date.daysInMonth(yearInt, monthInt));
    //         }
    //         String result='';
    //         try{
    //             Integer numPending = [Select count() from DART_Delivery_Support__c 
    //                 WHERE Schedule_Type__c=:DART6_Delivery.SCH_TYPE_MANUALLY 
    //                 AND Sobject__c=:dartDelStatus.Sobject__c
    //                 AND Status__c <> :DART6_Delivery.DART_STATUS_FINISHED];
                
    //             //We expected all DDS are 'finished'; so we can run another, or wait until they all finish
    //             if(numPending>0) result = 'Importing Delivery of '+dartDelStatus.Sobject__c+' is already running.';
    //             else{
    //                 //start(SCH_TYPE_MANUALLY, dartDelStatus.Sobject__c, startDate, endDate);
    //                 result = 'SUCCESS: Importing Delivery of '+dartDelStatus.Sobject__c+' is now running in background.';
    //             }
    //         }catch(Exception ex){result+='ERROR: '+ex;}
    //         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, result));
    //         return null;
    //     }
        
    //     public void setJobid(Long jobid){
    //         this.jobid = jobid;
    //     } 
        
    //     public void setReportService (DART6_REPORTSERVICE.REPORTServiceInterfacePort reportService){
    //         this.reportService = reportService;
    //     }
        
    //     public void importDelivery(String importType) {  
            
    //         //create request
    //         HTTPWrapper.IGenericRequest deliveryRequest = FactoryDARTRequest.getInstance().createDartDeliveryRequest(login,breakDown,dateRange, jobid, reportService);
            
    //         //create parser 
    //         DART6Parser.IDartParser deliveryParser;
    //         if(DART6_Delivery.ADX_IMPORT.equals(importType)){
    //             deliveryParser =  FactoryParser.getInstance().createAdxReportParser(login.RecordType.Name, dartDelStatus.Sobject__c);
    //         }   
    //         else{
    //             deliveryParser = FactoryParser.getInstance().createDeliveryParser(login.RecordType.Name, dartDelStatus.Sobject__c);
    //         }
            
    //         //create connection
    //         DARTObject.IDARTConnector deliveryCon = FactoryConnector.getInstance().createConnector(login.RecordType.Name,deliveryRequest, deliveryParser);
    //         deliveryCon.connect();    
    //         invokedMethod = deliveryRequest.getInvokedMethod();
            
    //         //getDartObjects
    //         listDartObjects = deliveryCon.getDartObjects();
            
    //     }
    // }
    // /*---------------------------------
    // @  END OF Delivery_Controller
    // ---------------------------------*/ 
}