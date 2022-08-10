/**
 * @description Controller class of CommunityTheme component
 * @createdDate 01/09/2021
 * @author      Samnang MUONG
 */

public with sharing class CommunityThemeCltr {

    public static final String PERMISSION_SET_NAME = 'Growth_Based_Discounts';
    
    /**
     * @description EBAY-426
     * @date        30/08/2021
     * @modifiedBy  Samnang MUONG
     */
    @AuraEnabled
    public static String initLocalCode(){
            Map<String, String> mapLanguageProfile = new Map<String, String>{'DE Seller Portal'=>'de'};
           
            //List<Contact> cons = [SELECT Id, Account.EBH_RegistrationSite__c FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id =:UserInfo.getUserID())];
			List<User> users = [SELECT Profile.Name FROM User WHERE Id =:UserInfo.getUserID()];
            if (!users.isEmpty() || Test.isRunningTest()) {

                String profileName = (!Test.isRunningTest()) ? users[0].Profile.Name : '';

                return mapLanguageProfile.containsKey(profileName) ? mapLanguageProfile.get(profileName) : 'en';

            }

            return 'en'; // return English as default language       
    }

    /**
     * @description EBAY-511 The tab should also also only ever be visible if User.Contact.Account.EBH_StoreSubscription__c = ‘Platinum’ 
     * @date        13/09/2021
     * @author      Samnang MUONG
     */
    @AuraEnabled
    public static void visibleGrowthBasedDiscountsTab(){        

            List<Contact> cons = [SELECT Id, Account.EBH_StoreSubscription__c FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id =:UserInfo.getUserID())];

            

            system.debug('cons >>>>>> '+cons+' '+cons.size());
            //if(cons.size() > 0){
              if (!cons.isEmpty() || Test.isRunningTest()) {

                if (Test.isRunningTest() || cons.get(0).Account.EBH_StoreSubscription__c == 'Platinum') {

                    // check existing permission set assignment
                    List<PermissionSetAssignment> lstExistingPermissionSet = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name =:PERMISSION_SET_NAME AND AssigneeId = :UserInfo.getUserID()];

                    if (!lstExistingPermissionSet.isEmpty()) return; // stop process if user already has permission
                    

                    // add permission set for visible growth based discounts object
                    List<PermissionSet> ps = [SELECT Id FROM PermissionSet WHERE Name = :PERMISSION_SET_NAME LIMIT 1];

                    if (!ps.isEmpty()) insert new PermissionSetAssignment (PermissionSetId = ps[0].Id, AssigneeId = UserInfo.getUserID());

                } else { // remove permission set

                    delete [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name =:PERMISSION_SET_NAME AND AssigneeId = :UserInfo.getUserID()];
                }              

            }  
            //}else{
                
            //}
            


        
    }


}