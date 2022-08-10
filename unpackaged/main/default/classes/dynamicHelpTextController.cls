/*****************************************************************************************************************************
@ Method:         dynamicHelpTextController
@ Version:        1.0
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 16-12-2021 / Sambath Seng / US-0010845 - [AM] AM Useful links / Landing Page Layout
******************************************************************************************************************************/
public with sharing class dynamicHelpTextController {
   @AuraEnabled(cacheable=true) 
    public static Component_help_text_setting__mdt helpTextMetadata(String metadataName){
     
     return [SELECT Help_Text__c,DeveloperName,Heading__c,Inner_Help_Text__c,
              Id FROM Component_help_text_setting__mdt where DeveloperName=:metadataName];
    }

    @AuraEnabled(cacheable=true) 
    public static returnwaptrustedShops trustedShopsMetadata(String firstMetadataName,String secondMetadataName){
        returnwaptrustedShops obj = new returnwaptrustedShops();
        obj.trustedShopsMetadata =  [SELECT DeveloperName,Help_Text__c,Bigger_Body_Test__c,
        Id FROM Component_help_text_setting__mdt where DeveloperName=:firstMetadataName OR DeveloperName=:secondMetadataName];
        obj.retcon =[Select id,Account.Trusted_Shop_Discount_Code__c ,Email,FirstName,LastName from Contact where id =:[Select ContactId from User where id=:Userinfo.getUserid()].ContactId]; 
        if(obj.retcon.Account.Trusted_Shop_Discount_Code__c == null)
        obj.retcon.Account.Trusted_Shop_Discount_Code__c = [SELECT Code__c FROM Trusted_Shops_Discount_Code__c WHERE Has_Been_Applied__c = FALSE LIMIT 1].Code__c;
        return obj;
    }
    
    @AuraEnabled(cacheable=true) 
    public static list<Component_help_text_setting__mdt> accountManagementMetadata(String firstMetadataName, String secondMetadataName, String thirdMetadataName){
        return [SELECT DeveloperName,Help_Text__c,Bigger_Body_Test__c,Id FROM Component_help_text_setting__mdt where DeveloperName=:firstMetadataName OR DeveloperName=:secondMetadataName OR DeveloperName=:thirdMetadataName ORDER BY DeveloperName ASC];
    }

    public class returnwaptrustedShops{
        @AuraEnabled public list<Component_help_text_setting__mdt> trustedShopsMetadata{get;set;}
        @AuraEnabled public contact retcon{get;set;}
    } 

   
}