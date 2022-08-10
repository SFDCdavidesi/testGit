public with sharing class HTTPWrapperAds {
    public HTTPWrapperAds() {}
    
        public virtual Interface IGenericRequest{
            String getInvokedMethod(); //what dart method has been invoked?
               
        }
        /** For new DFP invoker - apex classes from WSDL */
        public Interface IInvoker extends IGenericRequest{
            void invoke();
            Object getResponseObject();
            
            
             
        } 
        /** for old API need raw xml body requests*/
        public Interface IRequest extends IGenericRequest{
            Map<String,String> getHeader();
            String getBody();
            String getEndPoint();
            String getMethod();
        }
         //to keep it live
        static final Http M_HTTP = new Http();
        /**
            Parent class for all responses
        */
        public with sharing abstract class AbstractResponse {
            private HttpResponse res;
            protected IRequest request;
            protected String status{get;set;}
            
            public AbstractResponse (IRequest request){
                this.request = request;
            }
            public abstract String getMockedBody();
            //void setRespone(HttpResponse res){} 
            //void setKeyElements(Set<String> keys){}
             
            HttpHandler handler;
            
            protected void excecute(){
                //if(!Test.isRunningTest()){
                    handler = new HttpHandler(request);
                    res = handler.sendRequest();
                    if(res!=null) status=res.getStatus();
                //}
                
            }
             
            public String getResBody(){
                if(!Test.isRunningTest()){
                    if(res==null) return '';
                    return res.getBody();
                } 
                status='OK';
                return getMockedBody();
            }
            
            /*
            public String getHeader(String key){
                return res.getHeader(key);
            
           }
           
           public List<String> getHeaderKeys(){
                return res.getHeaderKeys();
           }
           
           public String getCookie(){
            
                return getHeader('Set-Cookie');
           }
           */
           
        }
        
        final static Integer HTTP_RETRY = 3;
        /**
        HttpHandler 
        **/
        public with sharing  class HttpHandler {
              
            String method;
            HttpRequest req;
            public HttpHandler(IRequest request){
                req = new HttpRequest();    
                req.setTimeout(120000); //12 sec
                if(request.getBody()!=null && request.getBody()!='') {
                    req.setBody(request.getBody());
                } 
                if(request.getEndPoint()==null){
                    //System.debug('>>>>>>>>>>>>>>> HttpHandler ERROR: Error: No Endpoint Specified!!');
                    throw new ExceptionGroup.HTTPException('Error: No Endpoint Specified!!');
                }
                req.setEndpoint(request.getEndPoint());
                req.setMethod(request.getMethod());  
                  
                System.debug('>>>>>>>>>>>>>>> Request Body:'+request.getBody());
                for(String key: request.getHeader().keySet()){
                    req.setHeader(key,request.getHeader().get(key));
                }
            }
            public void setMethod(String s){
                method = s;  
            }
             
            Integer numTry = 0;
            public Httpresponse sendRequest(){      
                HttpResponse response = null;
                
                try{
                     if(!Test.isRunningTest()){
                         response = M_HTTP.send(req);
                     }
    
                }catch(CalloutException ex){
                    //System.debug('=================='+response);
                    //Logger.logError(c,Constants.CALL_OUT_ERROR);              
                    if(ex.getMessage().contains('Read timed out') && numTry < HTTP_RETRY)
                     {
                         numTry++;
                         return sendRequest();
                     }      
                    throw new ExceptionGroup.HTTPException('Can not callout: due to error: '+ex +'\nRetried '+numTry);
                    
                }
                return response;
            }
           
        }
        
        /** For simple http request - for general - no specific call */ 
        public class SimpleRequest  extends AbstractRequest {
            
            public SimpleRequest(String myEndPoint,String myMethod,String myBody)
            {
                endPoint =  myEndPoint;
                method = myMethod;
                body = myBody;
                mapHeader = new Map<String,String>();
            }
            
            /* need header?*/
            public SimpleRequest(String myEndPoint,String myMethod,String myBody,Map<String,String> myHeader)
            {
                this(myEndPoint,myMethod,myBody);
                mapHeader = myHeader;
            }
      
        }
        
        public with sharing abstract class AbstractRequest implements HTTPWrapperAds.IRequest{
             protected String body='';
             protected String endPoint;
             protected String method='GET';
             protected Map<String,String> mapHeader; 
             
             public virtual String  getInvokedMethod()
            {
                return 'SimpleRequest';
            }
            public virtual Map<String,String> getHeader()
            {
                return mapHeader;            
            }       
            public virtual String getBody()
            {
                return body;
            }
            
            public String getEndPoint()
            {
                return endPoint; 
            }        
            public String getMethod()
            {
                return method; 
            }
            
         }
         
         public class SimpleResponse extends HTTPWrapperAds.AbstractResponse{
            
            public SimpleResponse(IRequest req)
            {
                super(req); 
                excecute();
            }
            public override String getMockedBody()
            {
                return '';
            }
            
        }
        
    //******************************************** **************************************************//
        /*public class TestDARTRequest implements IRequest{
            Map<String,String> mapHeader;
            public TestDARTRequest()
            {
                mapHeader = new Map<String,String>();
                mapHeader.put('Cookie','');
                mapHeader.put('Content-type','text/xml');
                mapHeader.put('Accept-Encoding','gzip, deflate');
                mapHeader.put('User-Agent','API_VERSION_DARTAPI_13.6.9 JRE_1.6.0_25');
                
                //Blob headerValue = Blob.valueOf('nakb_angkor@yahoo.com:dart123456');
                //String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                  String authsss = Tester.composeDigestAuthorizationHeader('cambodia_DE-API','dartebaytest2012','/xmlserver/','POST');
                 //System.debug('>>>>>>>> AUTHORIZATION ' + authorizationHeader);
         
                   mapHeader.put('Authorization',authsss);
           
            }
            
            public Map<String,String> getHeader()
            {
                return mapHeader;
                
            }
            
            public String getBody()
            {
                return 
                '<dart:request-template select="xmlserver/session/UserInfo.xml" method="get" xmlns:dart="http://www.doubleclick.net">'+
                    '<dart:parameters>'+
                        '<UpdateLastLoginDate>true</UpdateLastLoginDate>'+
                    '</dart:parameters>'+
                '</dart:request-template>';
    
            }
            
            public String getEndPoint()
            {
                return 'http://dfpapitest.doubleclick.net/xmlserver/';
            }
            
            public String getMethod()
            {
                return 'POST';
            }
        }
        
        public class TestDARTResponse extends AbstractResponse{
            
            public TestDARTResponse(IRequest req)
            {
                super(req); 
                excecute();
            }
            public override String getMockedBody()
            {
                return '';
            }
        }
        /**USAGE:
            httpwrapperads.IRequest reqDart1 = new httpwrapperads.TestDARTRequest();
            httpwrapperads.TestDARTResponse resDart1 = new httpwrapperads.TestDARTResponse(reqDart1);
            System.debug('>>>>>>>>>>Resbody: '+resDart1.getResBody());
        */
    
    
}