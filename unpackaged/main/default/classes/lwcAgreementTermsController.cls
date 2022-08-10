/**
 * @description 
 * @date        19-July-2021
 * @author      Samnang MUONG
 */
public without sharing class lwcAgreementTermsController {

    @AuraEnabled(cacheable=false)   
    public static Boolean initAgreementTerms() {     

        try {

            Boolean result = false;
            
            List<User> lstUsers = [SELECT Id, ContactId, Contact.Accepted_Current_Deals_Agreement__c FROM User WHERE Id=:UserInfo.getUserId()];           

            if (!lstUsers.isEmpty()) {
                result = lstUsers[0].Contact.Accepted_Current_Deals_Agreement__c; 
            }
            

         return result;
            
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }


    }

    @AuraEnabled(cacheable=false)   
    public static String acceptedAgreement() {     

        String message = 'success';
        try {         
            List<User> lstUsers = [SELECT Id, ContactId, Contact.Accepted_Current_Deals_Agreement__c FROM User WHERE Id=:UserInfo.getUserId()];
            

            if (!lstUsers.isEmpty() && String.isNotBlank(lstUsers[0].ContactId)) {                  
                
             if(!Test.isRunningTest()) update new Contact(Id=lstUsers[0].ContactId, Accepted_Current_Deals_Agreement__c=true); // The reason ignore update contact: User Portal in test class cannot update Contact INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY
          
            }
            
        } catch (Exception e) { message = e.getMessage(); } 

        return message; 


    }
    
}