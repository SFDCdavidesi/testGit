/*********************************************************************************************************************************
@ Interface:     HIVE_Intellum
@ Version:       1.0
@ Author:        Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:       US-0010064 - [Intellum] API integration with Intellum
@                Authentication for Intellum 
@ usage:        HIVE_Intellum.ListEnrollmentService listEnrol = new HIVE_Intellum.ListEnrollmentService(null);
@               listEnrol.sendRequest();
@               Map<String,Object> result = listEnrol.getResult();
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 02.08.2021 / Vadhanak Voun (vadhanak.voun@gaea-sys.com) / request_token
*********************************************************************************************************************************/
public without sharing class HIVE_Intellum {

    private static Access intel_access;
    public static Access getAccess()
    {   
        if(intel_access==null)
        {
            intel_access = new Access();
        }
        return intel_access;
    }

    class IntellumException extends Exception{

    }
     
    public class Access{
         
        Map<String,Intellum_Credendtial__mdt> mapCred;

        public String accesToken {get;private set;}        
        private Map<String,Object> mapResult;

        

        public String request_token()
        {
            if(accesToken !=null)
            {
                return accesToken;
            }

            Intellum_Credendtial__mdt cred =  getCredential();
            if(cred == null)
            {
                throw new IntellumException('No Credential defined in Intellum_Credendtial__mdt for this org.');
            }

            String endPoint = cred.API_Server__c +'/oauth2/token.json';
            Map<String,String> mapHeader = new Map<String,String>{'Content-Type'=>'application/json'};
             
            Long secondNow =  DateTime.now().getTime()/1000;
            Long secondExp = secondNow + 60; //max 60 seconds
            
            Map<String,Object> mapClaimSet = new Map<String,Object>
            {
                'iss'=>cred.UID__c,
                'aud'=>cred.API_Server__c,
                'scope'=>cred.Scope__c,
                'exp'=>secondExp, 
                'iat'=>secondNow
            };
            
            String claimSetString = JSON.serialize(mapClaimSet);
            //system.debug('--secondNow: '+secondNow + ' --secondExp: '+secondExp+'\n--claimSetString: '+claimSetString);

            String pHeader = EncodingUtil.base64Encode(Blob.valueOf('{"alg":"RS256"}'));
            String pClaimSet = EncodingUtil.base64Encode(Blob.valueOf(claimSetString));
            String privateKey = cred.Private_Key__c;
            
            //system.debug(privateKey);
            String pSignature = EncodingUtil.base64Encode(Crypto.sign('RSA-SHA256', Blob.valueOf(pHeader+'.'+pClaimSet), EncodingUtil.base64Decode(privateKey))) ;            
            
            String assertion3_parts = pHeader+'.'+pClaimSet+'.'+pSignature;

            Map<String,String> mapBody = new Map<String,String>
            {
                'grant_type'=>'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion'=>assertion3_parts

            };
            String payload = JSON.serialize(mapBody);
            
            //system.debug('--payload: '+payload);

            HTTPWrapper.IRequest reqToken = new HTTPWrapper.SimpleRequest(endPoint,'POST',payload,mapHeader);
            HTTPWrapper.SimpleResponse resToken = new HTTPWrapper.SimpleResponse(reqToken); 

            //{"error":"invalid_jwt_iat","error_description":"The JWT issue time is invalid"}
            resToken.mockBody = MOCK_TOKEN_RES;

            //7200: 2 hours
            mapResult = (Map<String,Object>)JSON.deserializeUntyped(resToken.getResBody());

            //System.debug('----res body-----: '+resToken.getResBody());
            if(mapResult.containsKey('error'))
            {
                throw new IntellumException('Authentication: '+resToken.status+': '+mapResult.get('error_description')+'');
            }

            accesToken = mapResult.get('access_token')+'';

            return accesToken;
        }

        public Intellum_Credendtial__mdt getCredential()
        {  
            if(mapCred==null)
            {
                mapCred= new Map<String,Intellum_Credendtial__mdt>();            
                for(Intellum_Credendtial__mdt cred: [Select Id,DeveloperName,Scope__c,UID__c,API_Server__c,Private_Key__c,Version_Path__c From Intellum_Credendtial__mdt])
                {
                    mapCred.put(cred.DeveloperName,cred);
                }   
            }       

            return ApexUtil.isProduction()? mapCred.get('production') : mapCred.get('sandbox');
        }

    }

    interface IService{
        void sendRequest();
        Map<String,Object> getResult();
        List<SObject> getListObject();   //In case we need a ready-sf-object

        Boolean isSuccess();
        
    }

    abstract class BaseService implements IService{
        
        protected String endPoint;
        protected String serviceName;
        Map<String,String> mapHeader;
        protected String method;
        
        protected String resMessage = '';
        protected Boolean isSuccess;

        protected Map<String,Object> mapResponse;

        protected Map<String,Object> mapParam; //body of the request

        public BaseService(String serviceName,String method)
        {
            this.serviceName = serviceName;
            this.method = method;
            
            mapHeader = new Map<String,String>{'Content-Type'=>'application/json'};
        }
        
        public void sendRequest()
        {
            isSuccess = true;
            try
            {
                String accToken = getAccess().request_token();
                mapHeader.put('Authorization','Bearer '+accToken);
    
                Intellum_Credendtial__mdt cred =  getAccess().getCredential();            
                endPoint = cred.API_Server__c +cred.Version_Path__c+'/'+serviceName;
    
                String payload = mapParam==null?'':JSON.serialize(mapParam);
                //system.debug(payload);
                HTTPWrapper.IRequest request = new HTTPWrapper.SimpleRequest(endPoint,method,payload,mapHeader);
                HTTPWrapper.SimpleResponse response = new HTTPWrapper.SimpleResponse(request); 
                response.mockBody = MOCK_CREATE_ENROL_RES;


                mapResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getResBody());
                
                isSuccess = response.statusCode != 200;

                if(mapResponse.containsKey('error'))
                {
                    isSuccess = false;throw new IntellumException(mapResponse.get('error_description')+'');
                }else if(mapResponse.containsKey('errors'))
                {
                    isSuccess = false;throw new IntellumException(mapResponse.get('errors')+'');
                }
                
                

            }catch (Exception ex)
            {                
                isSuccess = false;System.debug(ex);throw new IntellumException(ex.getMessage());
            }
           
        }

        public Map<String,Object> getResult()
        {
            return mapResponse;
        }

        public virtual List<SObject> getListObject(){
            return null;
        }

        public Boolean isSuccess()
        {
            return isSuccess;
        }
         
    }

    
    public class createEnrollmentService extends BaseService{

        public createEnrollmentService(Map<String,Object> mapParamEnrol)
        {
            super('enrollments','POST');
            this.mapParam = mapParamEnrol;
        }

        //in case we need list of ready object
        public override List<SObject> getListObject()
        {
            String sobjName = 'intellumapp__IntellumEnrollment__c';
            Map<String,String> map_sf_json = new Map<String,String>();
            sObject sObj_enrol = Schema.getGlobalDescribe().get(sobjName).newSObject();

            for(Intellum_Mapping__mdt mapping: [Select Id,DeveloperName,SF_To_JSON_Fields__c From Intellum_Mapping__mdt where DeveloperName='IntellumEnrollment'])
            {                
                for(String allFields : mapping.SF_To_JSON_Fields__c.split(','))
                {
                    List<String> bothFields = allFields.split(':');                   
                    map_sf_json.put(bothFields[0],bothFields[1]);
                }                
            }  
            //System.debug('---------:map_sf_json: '+map_sf_json.size());
            
            Map<String,Object> mapEnrolRespone = (Map<String,Object>)mapResponse.get('enrollment');

            Map<String,Schema.SObjectField> fieldMapDesc = sObj_enrol.getSObjectType().getDescribe().fields.getMap();

            for(String fName: map_sf_json.keySet())
            {
                String jsonField = map_sf_json.get(fName);

                Object val = ApexUtil.getJSONValue(mapEnrolRespone,jsonField);
                if(val == null)continue;

                Schema.DescribeFieldResult current_field = fieldMapDesc.get(fName).getDescribe();
                 //System.debug('---------:bothFields: '+bothFields);                         
                if(current_field.getType() == DisplayType.Date) 
                {
                    //Date myDate = DateTime.newInstanceGMT(2013, 11, 12).dateGMT(); //2019-10-14
                    String[] valDate = (val+'').split('-');   
                    sObj_enrol.put(fName,DateTime.newInstanceGMT(Integer.valueOf(valDate[0]), Integer.valueOf(valDate[1]), Integer.valueOf(valDate[2])).dateGMT());
                    
                } else if (current_field.getType() == DisplayType.Datetime) 
                {
                    String[] valDate = (val+'').split('T')[0].split('-'); 
                    String[] valTime = (val+'').split('T')[1].split('\\+')[0].split(':'); 
                    //DateTime expected = DateTime.newInstanceGMT(2013, 11, 12, 3, 3, 3);   //2019-05-14T10:13:39+00:00
                    //newInstanceGmt(Integer year, Integer month, Integer date, Integer hour, Integer minute, Integer second)
                    sObj_enrol.put(fName,DateTime.newInstanceGMT(Integer.valueOf(valDate[0]), Integer.valueOf(valDate[1]), Integer.valueOf(valDate[2]),Integer.valueOf(valTime[0]),Integer.valueOf(valTime[1]),Integer.valueOf(valTime[2])));
                    
                }else
                {
                    sObj_enrol.put(fName,val);
                } 

                //System.debug('---------:fName: '+fName+'  jsonField: '+jsonField+'  val: '+val);
                
            }
            intellumapp__IntellumActivity__c i_act = new intellumapp__IntellumActivity__c(intellumapp__id__c=Decimal.valueOf(sObj_enrol.get('intellumapp__course_id__c')+''));
            intellumapp__IntellumUser__c i_user = new intellumapp__IntellumUser__c(intellumapp__id__c=Decimal.valueOf(sObj_enrol.get('intellumapp__user_id__c')+''));
            sObj_enrol.putSObject('intellumapp__IntellumActivity__r',i_act);
            sObj_enrol.putSObject('intellumapp__IntellumUser__r',i_user);

            return new List<SObject>{sObj_enrol};
        }

    }
    
    public class ListEnrollmentService extends BaseService{

        public ListEnrollmentService(Map<String,Object> mapParam)
        {
            super('enrollments','GET');
            this.mapParam = mapParam;

        }

    }
     

    static final String MOCK_CREATE_ENROL_RES = '{"enrollment":{"id":1222,"auto_enrollment_id":null,"enrolled_on":"2019-05-14T10:13:39+00:00","due_on":"2019-10-14","started_on":null,"completed_on":null,"verified_at":null,"expires_on":"2020-10-14T09:00:00+00:00","status":"in-progress","progress":0,"score":null,"time":0,"code":"abc123","completed_activities_count":null,"accepted_invite":false,"grader_id":null,"last_opened_on":null,"relationship_type":"required","position":null,"plan_quarter":null,"viewed_in_plan":null,"is_visible_instructor":null,"course":{"id":91673733,"code":null},"course_session":null,"relationship_reason":"Annual requirement for completion","user":{"id":582732833,"code":null},"course_version_number":1,"created_on":"2018-10-14T13:57:06+00:00","updated_on":"2018-10-14T13:57:06+00:00","flagged_by_proctoring":null},"status_messages":{"created":{"enrollment":[1222]},"changed":{},"deleted":{}},"api_version":"3.0.0"}';
    static final String MOCK_TOKEN_RES = '{"access_token":"2111fafcf0e4b52b60f9e57919bdd0c695294402df57b99c3b732d28a3ec8924","token_type":"bearer","expires_in":7200,"scope":"admin_read admin_write","created_at":1627979647}';
}