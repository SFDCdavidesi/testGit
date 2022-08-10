global with sharing class InfluencerIntegration {
    private static final String INSTAGRAM_CHANNEL = 'instagram';
    private static final String OTHER_CHANNEL = 'other';
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
    public static List<Channel_Wrapper> getUserInformation(List<String> inputLink) {
        if(inputLink.isEmpty()) return null;
        // try {
            List<Channel_Wrapper> listChannelWrapp = new List<Channel_Wrapper>();
            Channel_Wrapper channelWrapp = new Channel_Wrapper();
            String strLink = inputLink.get(0);

            // Example: www.instagram.com/username => ['www', 'instagram', 'com/username'];
            List<String> splitedLinks = strLink.contains('.') ? strLink.split('\\.') : new List<String>();
            String strDomain = splitedLinks.get(1).toLowerCase();
            String strUsername = splitedLinks.get(2).contains('/') ? splitedLinks.get(2).split('/')[1] : '';

            if(!mSocialChannel.keySet().contains(strDomain)){
                strDomain = OTHER_CHANNEL;
            }

            if(strDomain == INSTAGRAM_CHANNEL){
                String access_token = 'EAAIkpv7LujwBAKshCFfVy5ZABx7KAAvtR2o84AgBZCh9vQfJmm2wtvvckysZAnCaiNpwVzS4rnB857iPyZC9sZAqn0575X4PnOCuU3gQ7Fwn0ZB0RktWIZAr4EJOcYs2kT9SEDY16LqYFtyA2kKDNXWIfOKUGr7TlSTaGScMW9bV1mIBiCZC9xZC4';
                String url='https://graph.facebook.com/17841454032970258?fields=business_discovery.username('+strUsername+'){username,followers_count,follows_count,media_count,profile_picture_url}&access_token='+access_token;
                CustomHttpResponse responseResult = doHTTP_GET(url);
                Map<String, Object> mResult = (Map<String, Object>) JSON.deserializeUntyped(responseResult.getResBody());
                
                channelWrapp.channel_type = INSTAGRAM_CHANNEL;
                if (responseResult.statusCode==200 && mResult.containsKey('business_discovery')){ 
                    Map<String, Object> mObj = (Map<String, Object>) mResult.get('business_discovery');
        
                    channelWrapp.username = String.valueOf(mObj.get('username'));
                    channelWrapp.followers_count = Integer.valueOf(mObj.get('followers_count'));
                    channelWrapp.follows_count = Integer.valueOf(mObj.get('follows_count'));
                    channelWrapp.media_count = Integer.valueOf(mObj.get('media_count'));
                    channelWrapp.profile_picture_url = String.valueOf(mObj.get('profile_picture_url'));
                    
                }else if (responseResult.statusCode==400 && mResult.containsKey('error')){
                    
                    Map<String, Object> mObj = (Map<String, Object>) mResult.get('error');
                    // The user with username: xxxx cannot be found.
                    if(Integer.valueOf(mObj.get('code')) == 110){
                        channelWrapp.ig_user_not_found = true;
                    }
                }
            }else{
                channelWrapp.channel_type = mSocialChannel.get(strDomain);
            }

            listChannelWrapp.add(channelWrapp);
            return listChannelWrapp;
        // } catch (Exception ex) {
        //     List<Channel_Wrapper> listChannelWrapp = new List<Channel_Wrapper>();
        //     Channel_Wrapper channelWrapp = new Channel_Wrapper();
        //     channelWrapp.unexpected_error = true;
        //     channelWrapp.unexpected_error_message = ex.getMessage();
        //     listChannelWrapp.add(channelWrapp);

        //     EBH_ApexLogger.logError(new List<Exception> { ex }, 'InfluencerIntegration', 'getUserInformation');

        //     return listChannelWrapp;
        // }
        
        
    }

    private static CustomHttpResponse doHTTP_GET(String url){
        HTTPWrapper.IRequest reqItem = new HTTPWrapper.SimpleRequest(url,'GET','');
        return new CustomHttpResponse(reqItem);
    }

    class CustomHttpResponse extends HTTPWrapper.AbstractResponse{
        
        public CustomHttpResponse(HTTPWrapper.IRequest req)
        {
            super(req); 
            excecute();
        }
        public override String getMockedBody()
        {
            return 
			'{ "business_discovery": { "username": "justinbieber", "followers_count": 247265482, "follows_count": 715, "media_count": 7313, "id": "17841400365670107" }, "id": "17841454032970258" }';
        }
		
    }

    public class Channel_Wrapper {

        // Instagram Field //
        @InvocableVariable
        public String username; 

        @InvocableVariable
        public Integer followers_count;

        @InvocableVariable
        public Integer follows_count;

        @InvocableVariable
        public Integer media_count;

        @InvocableVariable
        public Boolean ig_user_not_found;

        @InvocableVariable
        public String profile_picture_url; 
        // Instagram Field END //

        // General Field //
        @InvocableVariable
        public String channel_type;

        @InvocableVariable
        public Boolean not_supported_channel;
        // General Field END //

        // Error handler //
        // @InvocableVariable
        // public Boolean unexpected_error;
        // public String unexpected_error_message;
        // Error handler END //

        public Channel_Wrapper(){
            this.ig_user_not_found = false;
            // this.not_supported_channel = false;
            // this.unexpected_error = false;
        }
    }

    // global enum ChannelType {INSTAGRAM, YOUTUBE, TIKTOK}
}