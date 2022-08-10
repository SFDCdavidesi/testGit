public with sharing class InfluencerService {
    private static final String INSTAGRAM_CHANNEL = 'instagram';
    private static final String OTHER_CHANNEL = 'other';
    private static final Integer INSTAGRAM_ERROR_CODE = 110;


    private static final Map<String, String> mSocialChannel = new Map<String, String>{
        'twitter' => 'Twitter',
        'instagram' => 'Instagram',
        'tiktok' => 'TikTok',
        'youtube' => 'YouTube',
        'facebook' => 'Facebook',
        'snapchat' => 'Snapchat',
        'twitch' => 'Twitch',
        'blog' => 'Blog',
        'other' => 'Other'
    };

    private static final string IG_MOCK_BODY= '{ "business_discovery": { "username": "justinbieber", "followers_count": 247265482, "follows_count": 715, "media_count": 7313, "id": "17841400365670107" }, "id": "17841454032970258" }';
    private static final string DEFAULT_MOCK_BODY= '{ "business_discovery": { "username": "justinbieber", "followers_count": 247265482, "follows_count": 715, "media_count": 7313, "id": "17841400365670107" }, "id": "17841454032970258" }';

    /*********************************************************************************************************************************
    @ Method:         getUserInformation
    @ Author:         Acmatac SEING (acmatac.seing@gaea-sys.com)
    @ Purpose:        US-0011821 - 1.2.2 Influencer (API for channel record)
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:    List<String> inputLink
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  04.07.2022 / Acmatac SEING / Created the method.
    *********************************************************************************************************************************/
    @InvocableMethod(label='getUserInformation' description='Retrieve User Information')
    public static List<ResultWrapper> getUserInformation(List<CustomParameter> parameter) {
        ResultWrapper rw = new ResultWrapper();
        try {
            CallMulesoft cml = new CallMulesoft();
            CustomParameter myParmeter = parameter[0];

            String strDomain = getDomain_FromURL(myParmeter.url);
            String strUsername = get_IG_Username_FromURL(myParmeter.url);

            if(!mSocialChannel.keySet().contains(strDomain)){
                strDomain = OTHER_CHANNEL;
            }

            if(strDomain == INSTAGRAM_CHANNEL){
                Influencer_Service_Provider__mdt ispMDT = [SELECT DeveloperName
                                                        , Access_Token__c
                                                        , Base_URL__c
                                                        , Mulesoft_Client_Id__c
                                                        , Mulesoft_Client_Secret__c
                                                        , Target__c
                                                        , Instagram_Id__c
                                                        , Fields__c
                                                    FROM Influencer_Service_Provider__mdt WHERE DeveloperName =: 'instagram_user_discovery'];

                String access_token = ispMDT.Access_Token__c;
                String base_url = ispMDT.Base_URL__c;
                String instagram_id = ispMDT.Instagram_Id__c;
                String fields = ispMDT.Fields__c;
                String iGUserDiscoveryService = myParmeter.target;
                // String url='https://graph.facebook.com/17841454032970258?fields=business_discovery.username('+strUsername+'){username,followers_count,follows_count,media_count,profile_picture_url}&access_token='+access_token;
                String url = base_url + '?username='+strUsername+'&target='+iGUserDiscoveryService+'&access_token='+access_token+'&instagram_id='+instagram_id+'&fields='+fields;
                
                Map<String,String> mapHeader = new Map<String,String>{'Content-Type'=>'application/x-www-form-urlencoded'};             
                String pHeader = EncodingUtil.base64Encode(Blob.valueOf(ispMDT.Mulesoft_Client_Id__c+':'+ispMDT.Mulesoft_Client_Secret__c));            
                mapHeader.put('Authorization','Basic '+pHeader);   

                rw = cml.doCallOut(url, strDomain, mapHeader);

                rw.channelRecord.Social_Media_Channel_Type__c = mSocialChannel.get(INSTAGRAM_CHANNEL);
                // return rw;
            }else{
                
                rw.channelRecord = new Channel__c(Social_Media_Channel_Type__c = mSocialChannel.get(strDomain));
                // return rw;
            }
            return new List<ResultWrapper>{rw};
        } catch (Exception ex) {
            ResultWrapper rwE = new ResultWrapper('Error: '+ex.getMessage()+', \nTrace: '+ex.getStackTraceString());
            return new List<ResultWrapper>{rwE};
        }
    }

    public class CustomParameter{
        @InvocableVariable
        public String target;

        @InvocableVariable
        public String url;
    }

    public class ResultWrapper{
        @InvocableVariable
        public Channel__c channelRecord = new Channel__c();

        @InvocableVariable
        public Boolean hasError;
        @InvocableVariable
        public String errorMessage;
        public ResultWrapper(){
            
        }
        public ResultWrapper(String errorMessage){
            
            if(String.isBlank(errorMessage)){
                this.hasError = false;
            }else{
                this.hasError = true;
            }
            this.errorMessage = errorMessage;
        }
    }

    public interface IParser{
        void parse();
        Object getData();
    }

    public class InstagramParser implements IParser{
        private Channel__c instaObj = new Channel__c();
        private String jsonInstagram;

        public InstagramParser(String jsonInsta){
            jsonInstagram = jsonInsta;
        }

        public void parse(){
            Map<String,Object> mObjRaw = (Map<String,Object>) JSON.deserializeUntyped(jsonInstagram);
            Map<String,Object> mObjBD = (Map<String,Object>) mObjRaw.get('business_discovery');
            instaObj = new Channel__c(
               Name = String.valueOf(mObjBD.get('username')),
               Followers_Subscribers__c = Integer.valueOf(mObjBD.get('followers_count')),
               Following__c = Integer.valueOf(mObjBD.get('follows_count')),
               Posts_total__c = Integer.valueOf(mObjBD.get('media_count')),
               Profile_Picture_URL__c = String.valueOf(mObjBD.get('profile_picture_url'))
            );
            
        }

        public Object getData(){
            return instaObj;
        }
    }

    private static String getDomain_FromURL(String url){
        // Example: www.instagram.com/username => ['www', 'instagram', 'com/username'];
        List<String> splitedLinks = url.contains('.') ? url.split('\\.') : new List<String>();
        String strDomain = splitedLinks.size()>1 ? splitedLinks.get(1).toLowerCase() : '';
        return strDomain;
    }

    private static String get_IG_Username_FromURL(String url){
        // Example: www.instagram.com/username => ['www', 'instagram', 'com/username'];
        List<String> splitedLinks = url.contains('.') ? url.split('\\.') : new List<String>();
        String strUsername = splitedLinks.size()>2 && splitedLinks.get(2).contains('/') ? splitedLinks.get(2).split('/')[1] : '';
        return strUsername;
    }

    class CallMulesoft{
        public ResultWrapper doCallOut(String url, String strDomain, Map<String,String> mapHeader) {
            HTTPWrapper.IRequest request = new HTTPWrapper.SimpleRequest(url,'GET','', mapHeader);
            HTTPWrapper.SimpleResponse responseResult = new HTTPWrapper.SimpleResponse(request); 
            if(strDomain == INSTAGRAM_CHANNEL){
                responseResult.mockBody = IG_MOCK_BODY;
            }else{
                // Default Mock Body
                responseResult.mockBody = DEFAULT_MOCK_BODY;
            }
            
            system.debug('--responseResult: '+responseResult);
            system.debug('--responseResult.getResBody(): '+responseResult.getResBody());

            ResultWrapper rw = new ResultWrapper();
            if (responseResult.statusCode==200){ 
                if(strDomain == INSTAGRAM_CHANNEL){
                    IParser pss = new InstagramParser(responseResult.getResBody());
                    pss.parse();
                    rw.channelRecord = (Channel__c) pss.getData();
                }
                // Future can be FacebookParser, TikTokParser...
                else{
                    
                }
                System.debug('pss ::: '+rw.channelRecord);
            }else{
                return new ResultWrapper('failed: bad request');
            }
            
            // else if (responseResult.statusCode==400){
            //     Map<String,Object> mapResponse = (Map<String,Object>) JSON.deserializeUntyped(responseResult.getResBody());
            //     if(mapResponse.containsKey('error')){
            //         Map<String, Object> mObj = (Map<String, Object>) mapResponse.get('error');
            //         // The user with username: xxxx cannot be found.
            //         if(Integer.valueOf(mObj.get('code')) == 110){
            //             throw new InfluencerException('code:'+INSTAGRAM_ERROR_CODE+',error:'+String.valueOf(mObj.get('error_user_msg')));
            //         }
            //     }
            // }
            return rw;
        }
    }

    class InfluencerException extends Exception{

    }

}