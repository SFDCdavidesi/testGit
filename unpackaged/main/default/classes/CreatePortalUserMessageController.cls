/*********************************************************************************************************************************
@ Class:         CreatePortalUserMessageController
@ Version:       1.0
@ Author:        Broseth.KATOR (broseth.kator@skyvva.con)
@ Purpose:       Create Message for Portal User Message 
@				 Controller for lwc: lwcCreatePortalUserMessage and lwcViewPortalUserMessage
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 06/Sep/2021 / Broseth.KATOR (broseth.kator@skyvva.con) / Created the class.
*********************************************************************************************************************************/

public with sharing class CreatePortalUserMessageController {

    @AuraEnabled 
    public static user fetchUserInfo(){
     // query current user information  
      User currUser = [SELECT Id, Username, ContactId, Contact.FirstName, FirstName, LastName, UserType
                    FROM User WHERE Id =: userInfo.getUserId()];
        return currUser;
    }

    @AuraEnabled
    public static Object doPosting(Portal_User_Message__c postMessage) {
        Map<String, Object> mResult = new Map<String, object>();
        mResult.put('status','error');
        try {
            insert postMessage; 
            mResult.put('postMessage',postMessage);
            mResult.put('message', 'The message post successfully.');
            mResult.put('status','success');
        } catch (Exception e) {
            mResult.put('message', 'Error:'+ e.getMessage());
        }
        return mResult;
    }

    // @AuraEnabled
    // public static List<Portal_User_Message__c> getPortalUserMessage(Integer limitRec, String profileSetting) {
    //     List<Portal_User_Message__c> lstPortal_User_Message=[SELECT Id, Name, Type__c, Start_time__c, End_time__c, Content__c, Status__c, Applies_to_User_Region__c, Message_Type__c FROM Portal_User_Message__c WHERE Message_Type__c = 'Global banner' AND DAY_ONLY(Start_time__c )<=:Date.today() AND DAY_ONLY(End_time__c )>=:Date.today() AND Applies_to_User_Region__c LIKE:profileSetting AND Status__c = 'Active' ORDER BY CreatedDate DESC LIMIT: limitRec];
    //     return lstPortal_User_Message;
    // }

    @AuraEnabled
    public static List<Portal_User_Message_Item__c> getPortalUserMessage(Integer limitRec, String profileSetting) {
        List<Portal_User_Message_Item__c> lstPortal_User_Message=[SELECT Id, Name, Type__c, Start_time__c, End_time__c, Content__c, Status__c, Portal_User_Message__c, Portal_User_Message__r.Applies_to_User_Region__c, Message_Type__c FROM Portal_User_Message_Item__c WHERE Message_Type__c = 'Global banner' AND DAY_ONLY(Start_time__c )<=:Date.today() AND DAY_ONLY(End_time__c )>=:Date.today() AND Portal_User_Message__r.Applies_to_User_Region__c LIKE:profileSetting AND Status__c = 'Active' ORDER BY CreatedDate DESC LIMIT: limitRec];
        return lstPortal_User_Message;
    }

    @AuraEnabled
    public static List<Portal_User_Message__c> getPortalUserMessageInBox(String statusValue) {
        List<Portal_User_Message__c> lstPortal_User_Message=[SELECT Id, Name, Type__c, Start_time__c, End_time__c, Content__c, Status__c, Applies_to_User_Region__c, Message_Type__c FROM Portal_User_Message__c WHERE Message_Type__c = 'Inbox Only' AND Status__c LIKE:statusValue ORDER BY CreatedDate DESC LIMIT 500];
        return lstPortal_User_Message;
    }

    @AuraEnabled
    public static List<Portal_User_Message_Item__c> getPortalUserMessageModal() {
        Id contactId = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId; 
        List<Portal_User_Message_Item__c> lstPortal_User_Message=[SELECT Id, Name, Read__c, Message_Type__c, Content__c FROM Portal_User_Message_Item__c WHERE Read__c = FALSE AND Message_Type__c = 'Modal' AND DAY_ONLY(Start_time__c )<=:Date.today() AND DAY_ONLY(End_time__c )>=:Date.today() AND Status__c = 'Active' AND Contact__c = :contactId ORDER BY CreatedDate DESC LIMIT 1];
        return lstPortal_User_Message;
    }


    @AuraEnabled(cacheable=false)   
    public static Boolean initAgreementTerms() {     

        try {

            Boolean result = false;
            List<Portal_User_Message_Item__c> lstPortal_User_Message=[SELECT Id, Read__c, Message_Type__c FROM Portal_User_Message_Item__c WHERE Message_Type__c = 'Modal' ORDER BY CreatedDate DESC LIMIT 1];
            if (!lstPortal_User_Message.isEmpty()) {
                result = lstPortal_User_Message[0].Read__c; 
            }

         return result;
            
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }

    @AuraEnabled(cacheable=false)   
    public static void updateModalRead(String portalUserMessageId) {
        System.debug('portalUserMessageId: '+portalUserMessageId);
        Portal_User_Message_Item__c portalUserMessage = [SELECT Id FROM Portal_User_Message_Item__c WHERE Id =:portalUserMessageId LIMIT 1];
        portalUserMessage.Read__c = true;
        update portalUserMessage;
    }

    @AuraEnabled(cacheable=false)   
    public static String acceptedAgreement() {     

        String message = 'success';
        try {         
            List<Portal_User_Message_Item__c> lstPortal_User_Message=[SELECT Id, Read__c, Message_Type__c FROM Portal_User_Message_Item__c WHERE Message_Type__c = 'Modal' ORDER BY CreatedDate DESC LIMIT 1];

            if (!lstPortal_User_Message.isEmpty() && String.isNotBlank(lstPortal_User_Message[0].Id)) {                  
                
             if(!Test.isRunningTest()) update new Portal_User_Message_Item__c(Id=lstPortal_User_Message[0].Id, Read__c=true);
          
            }
            
        } catch (Exception e) { message = e.getMessage(); } 

        return message; 


    }

    @InvocableMethod(label='Another Active Modal message record is live, please deactivate before creating a new one' description='')
    public static void showErrorMessage(List< Portal_User_Message__c> potalmessage) {
        
        //parse inputs and variables

        System.debug('>>>potalmessage'+potalmessage);
        for(Portal_User_Message__c poc: potalmessage){
            poc.addError(Label.object_user_validation_message,'',true);
        }
        
    }
}