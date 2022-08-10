/*
@       Deprecated by       Mony Nou
@       Deprecated Date     14.07.2021
@       Reason: US-0009770 - These class is no longer used 
*/
public with sharing class LC_CheckDelivery {
    /*
    @AuraEnabled  // LPC_CampaignDeliveriesController.getReportJobId
    public static RemoteResponse createDFPReportJob(Id recordId){
    	RemoteResponse rr = new RemoteResponse();
    	
        try {
            
            if(!Util.hasPermission('Check_DFP_Delivery')){
                rr.statusCode = RemoteResponse.STATUSCODE_ERROR;
                rr.message = 'You don\'t have permission to check DFP delivery!';
                return rr;
            }
            
            Ad_Campaign__c adCamp ;
            if(recordId.getSobjectType() == Schema.Ad_Campaign__c.SObjectType ){
                adCamp = (Ad_Campaign__c) QueryUtil.queryRecord(recordId, new Set<String>{Util.NS+'IO__r.'+Util.NS+'Order_Id__c'});
            }else if (recordId.getSobjectType() == Schema.IO__c.SObjectType){
                adCamp = (Ad_Campaign__c) QueryUtil.queryRecords(Util.NS+'Ad_Campaign__c', Util.NS+'IO__c=:value1',new Set<String>{Util.NS+'IO__r.'+Util.NS+'Order_Id__c'},new Map<String, Object>{'value1'=>recordId}).get(0);
            }
            if(adCamp.Start_Date__c > system.today()) new RemoteResponse('Campaign have not started yet', RemoteResponse.STATUSCODE_ERROR);
            AdServer_Login__c login = LC_CheckDelivery.getAdServerLogin(adCamp.IO__c);
            DART6_REPORTSERVICE.ReportJob reportJob = LC_CheckDelivery.getReptJob(adCamp);
            DART6_REPORTSERVICE.REPORTServiceInterfacePort rptService = DART6_Delivery.buildQueryService(login.Name, login.Network_ID__c);
            Long jobId  = DART6_Delivery.runReportRequest(rptService, reportJob);
            rr.content = new Map<String, String>{'jobId'=>String.valueOf(jobId)};
            rr.statusCode = RemoteResponse.STATUSCODE_OK;
        } catch(Exception ex) {
            return new RemoteResponse(ex.getMessage(), RemoteResponse.STATUSCODE_ERROR);
        }
	    return rr;
    }
    
    @AuraEnabled // LPC_CampaignDeliveriesController.getJobStatus
    public static RemoteResponse checkDFPReportJobStatus(Id recordId, String jobId){
    	RemoteResponse rr = new RemoteResponse();
        try {
            AdServer_Login__c login;
            if( recordId.getSObjectType() == Schema.IO__c.SObjectType ) 
               login = LC_CheckDelivery.getAdServerLogin(recordId);
            else if (recordId.getSObjectType() == Schema.Ad_Campaign__c.SObjectType ){
                Ad_Campaign__c adCamp = (Ad_Campaign__c) QueryUtil.queryRecord(recordId);
                login = LC_CheckDelivery.getAdServerLogin(adCamp.IO__c);
            }else{
                return new RemoteResponse('Invalid record ID', RemoteResponse.STATUSCODE_ERROR);
            }

            DART6_REPORTSERVICE.REPORTServiceInterfacePort rptService = DART6_Delivery.buildQueryService(login.Name, login.Network_ID__c);
            String jobStatus =  rptService.getReportJobStatus(long.valueOf(jobId));
            //rr.content = new Map<String, String>{'jobStatus'=>'COMPLETED'};
            //rr.content = new Map<String, String>{'jobStatus'=>'IN_PROGRESS'};
            rr.content = new Map<String, String>{'jobStatus'=>jobStatus};
            rr.statusCode = RemoteResponse.STATUSCODE_OK;
        } catch(Exception ex) {
            return new RemoteResponse('error: checkDFPReportJobStatus', RemoteResponse.STATUSCODE_ERROR);
        }
    	
	    return rr;
    }
    @AuraEnabled // LPC_CampaignDeliveriesController.doDownloadDelivery
    public static RemoteResponse downloadDFPReportAndUpdateSF(Id recordId, String jobId){
    	RemoteResponse rr = new RemoteResponse();
    	try {
            Ad_Campaign__c adCamp ;
            if(recordId.getSobjectType() == Schema.Ad_Campaign__c.SObjectType ){
                adCamp = (Ad_Campaign__c) QueryUtil.queryRecord(recordId);
            }else if (recordId.getSobjectType() == Schema.IO__c.SObjectType){
                adCamp = (Ad_Campaign__c) QueryUtil.queryRecords('Ad_Campaign__c','IO__c=:value1',new Map<String, Object>{'value1'=>recordId}).get(0);
            }
            AdServer_Login__c login = LC_CheckDelivery.getAdServerLogin(adCamp.IO__c);
            
            //get reportservice
            DART6_REPORTSERVICE.REPORTServiceInterfacePort rptService = DART6_Delivery.buildQueryService(login.Name, login.Network_ID__c);
            HTTPWrapper.IGenericRequest deliveryRequest = FactoryDARTRequest.getInstance().createDartDeliveryRequest(login,'','', long.valueOf(jobId), rptService);
            DART6Parser.IDartParser deliveryParser = FactoryParser.getInstance().createDeliveryParser(login.RecordType.Name, DART6_Delivery.SOBJECT_DAILY);
            DARTObject.IDARTConnector deliveryCon = FactoryConnector.getInstance().createConnector(login.RecordType.Name,deliveryRequest, deliveryParser);
            deliveryCon.connect();  
            List<DARTObject.DARTDelivery> listDartObjects = (List<DARTObject.DARTDelivery>) deliveryCon.getDartObjects();


            Map<String, RS_Daily__c> mapRSDaily = new Map<String, RS_Daily__c>();
            for(RS_Daily__c RSDaily: (List<RS_Daily__c>) QueryUtil.queryRecords(Util.NS+'RS_Daily__c', 
                                Util.NS+'Ad_Campaign__c=:value1', 
                                new Set<String>{Util.NS+'Revenue_Schedule_Monthly__r.'+Util.NS+'IO_LineItem__r.'+Util.NS+'IO__r.'+Util.NS+'Order_Id__c', Util.NS+'Revenue_Schedule_Monthly__r.'+Util.NS+'IO_LineItem__r.'+Util.NS+'Ad_Id__c'}, 
                                new Map<String, Object>{'value1'=>adCamp.Id})){
                
                if( RSDaily.Date__c != null && String.isNotBlank(RSDaily.Revenue_Schedule_Monthly__r.IO_LineItem__r.Ad_Id__c)){
                    Datetime dtRSDate =  RSDaily.Date__c;
                    String uniqueKey =dtRSDate.formatGmt('M/d/yy')+ '_' + RSDaily.Revenue_Schedule_Monthly__r.IO_LineItem__r.Ad_Id__c;
                    mapRSDaily.put(uniqueKey, RSDaily);
                }

            }

            
            List<RS_Daily__c> lstRSDailyToUpdate = new List<RS_Daily__c>();
            for(DARTObject.DARTDelivery delivery : listDartObjects){
                String uniqueKey = delivery.getDateString() + '_' + delivery.getAdId();
                RS_Daily__c rDaily = mapRSDaily.get(uniqueKey);
                if(rDaily==null) continue;


                for(String combineTypeField: BatchDeliveryProcess.mFieldsDartToSObj.keySet()){
                    
                    if(combineTypeField.startsWithIgnoreCase(DART6_Delivery.DAILY_API_NAME)){
                        String fieldName = combineTypeField.split('\\.')[1];
                        String dartFieldName = BatchDeliveryProcess.mFieldsDartToSObj.get(combineTypeField);
                        String dartVal = String.valueOf(delivery.getValue(dartFieldName));
                        dartVal = dartVal.replace('%', '').replace(',', '');
                        if(!DARTUtil.isNumber(dartVal)) continue;
                        rDaily.put(fieldName, Decimal.valueOf(dartVal));                        
                    }
                }
                lstRSDailyToUpdate.add(rDaily);
            }
            WithoutSharing.doUpdate(lstRSDailyToUpdate);
            rr.content = new Map<String, String>{'result'=>'COMPLETED'};
            rr.statusCode = RemoteResponse.STATUSCODE_OK;
        } catch(Exception ex) {
            return new RemoteResponse(ex.getMessage(), RemoteResponse.STATUSCODE_ERROR);
        }
	    return rr;
    }
    
    public static DART6_REPORTSERVICE.ReportJob getReptJob(Ad_Campaign__c adCamp){

    	if(adCamp.IO__c == null) throw new ExceptionGroup.CustomException('Ad Campaign not linked to any IO');
    	
    	DART6_REPORTSERVICE.Statement statement = new DART6_REPORTSERVICE.Statement();
        statement.query = 'WHERE ORDER_ID = ' + adCamp.IO__r.Order_Id__c;
        
    	//DateTime dToday = System.now();
    	
        DART6_REPORTSERVICE.ReportQuery reportQuery = new DART6_REPORTSERVICE.ReportQuery();
        reportQuery.statement = statement;
        reportQuery.dateRangeType = 'CUSTOM_DATE';
        reportQuery.columns = DART6_Delivery.queryFieldsDART6.get(DART6_Delivery.SOBJECT_DAILY);
        reportQuery.dimensions = DART6_Delivery.dimensionFieldsDART6.get(DART6_Delivery.SOBJECT_DAILY);
        
        Date startDate = adCamp.Start_Date__c;
        Date endDate = System.today();
        reportQuery.startDate = new DART6_REPORTSERVICE.Date_x();
        reportQuery.startDate.year = startDate.year();
        reportQuery.startDate.month = startDate.month();
        reportQuery.startDate.day = startDate.day();
        system.debug('Anydatatype_msg'+reportQuery);
        reportQuery.endDate = new DART6_REPORTSERVICE.Date_x();
        reportQuery.endDate.year = endDate.year();
        reportQuery.endDate.month = endDate.month();
        reportQuery.endDate.day = endDate.day();
        reportQuery.dimensionAttributes = DART6_Delivery.dimensionAttributesDART6.get(DART6_Delivery.SOBJECT_DAILY);   

        DART6_REPORTSERVICE.ReportJob reportJob = new DART6_REPORTSERVICE.ReportJob();
        reportJob.reportQuery = reportQuery;
        return reportJob;
    }
    
    public static DART6_REPORTSERVICE.ReportJob getReptJob(IO_LineItem__c ioLine){

    	if(ioLine == null && ioLine.Ad_Id__c == null) throw new ExceptionGroup.CustomException('IO Line not yet booking to DFP');
    	
    	DART6_REPORTSERVICE.Statement statement = new DART6_REPORTSERVICE.Statement();
        statement.query = 'WHERE LINE_ITEM_ID = ' + ioLine.Ad_Id__c;
        
    	//DateTime dToday = System.now();
    	
        DART6_REPORTSERVICE.ReportQuery reportQuery = new DART6_REPORTSERVICE.ReportQuery();
        reportQuery.statement = statement;
        reportQuery.dateRangeType = 'CUSTOM_DATE';
        reportQuery.columns = DART6_Delivery.queryFieldsDART6.get(DART6_Delivery.SOBJECT_LINEITEM);
        reportQuery.dimensions = DART6_Delivery.dimensionFieldsDART6.get(DART6_Delivery.SOBJECT_LINEITEM);
        
        Date startDate = ioLine.from_Date__c;
        Date endDate = System.today();
        reportQuery.startDate = new DART6_REPORTSERVICE.Date_x();
        reportQuery.startDate.year = startDate.year();
        reportQuery.startDate.month = startDate.month();
        reportQuery.startDate.day = startDate.day();
        system.debug('Anydatatype_msg'+reportQuery);
        reportQuery.endDate = new DART6_REPORTSERVICE.Date_x();
        reportQuery.endDate.year = endDate.year();
        reportQuery.endDate.month = endDate.month();
        reportQuery.endDate.day = endDate.day();
        reportQuery.dimensionAttributes = DART6_Delivery.dimensionAttributesDART6.get(DART6_Delivery.SOBJECT_LINEITEM);   

        DART6_REPORTSERVICE.ReportJob reportJob = new DART6_REPORTSERVICE.ReportJob();
        reportJob.reportQuery = reportQuery;
        return reportJob;
    }

    public static AdServer_Login__c getAdServerLogin(Id ioId){

        List<IO_LineItem__c> ioItems = [Select Product__r.Site__r.Country__c, IO__r.Order_Id__c , IO__r.Campaign_Start__c, IO__r.Campaign_End__c From IO_LineItem__c
                                        Where   IO__c = :ioId AND
                                                Ad_Id__c != NULL AND
                                                from_Date__c <= TODAY
                                                limit 1];
        if(ioItems.isEmpty()) throw new ExceptionGroup.CustomException('There is active or completed item found.');
        
        IO_LineItem__c item = ioItems.get(0);
        String adServName = item.Product__r.Site__r.Country__c;
        return DARTUtil.getCredential(DARTUtil.DART6, adServName);
    }
    */
}