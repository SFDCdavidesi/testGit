/*********************************************************************************************************************************
@ Class:        CustomSEPUserProfileMenuController
@ Version:       1.0
@ Author:        Mony Nou (mony.nou@gaea-sys.com)
@ Purpose:       US-0010903 - [Add User] Allow DE Deals Users to add others Contacts to the Seller Portal
@----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 07.02.2022 / Mony Nou / US-0010903 - Create class
*********************************************************************************************************************************/
public with sharing class CustomSEPUserProfileMenuController {
    
    /***********************************************************************************************************************************
    @ Method:       initUserProfileMenuItems
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Returns map of object
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 07.02.2022 / Mony Nou / US-0010903 - [Add User] Allow DE Deals Users to add others Contacts to the Seller Portal
    ***********************************************************************************************************************************/
    private static String SEPGLOBVAR_PREFIX = 'UserProfile_MenuItem_';
    private static Map<String, String> mapLanguageProfile = new Map<String, String>{'DE - Seller Portal'=>'de'};
    private static String DEF_LANG = 'en';

    @AuraEnabled
    public static Map<String, Object> initUserProfileMenuItems (){
        
        Map<String, Object> result = new Map<String, Object>();

        List<MenuItemObj> lstMenuItems = new List<MenuItemObj>();
        
        //Add First Default Menu Item - Home
        lstMenuItems.add(new MenuItemObj(Label.UsrProf_MenuItem_Home, '/s/')); //Home will always be the first Menu Item

        Set<String> curUserPMS = new Set<String>();
        for(PermissionSetAssignment psa: [Select PermissionSet.Name, PermissionSetId, AssigneeId from PermissionSetAssignment Where AssigneeId=:UserInfo.getUserId()]) { curUserPMS.add(psa.PermissionSet.Name); }

        
        // //Check User's local
        // String curLang = DEF_LANG;
        // for (Profile prof : [SELECT Name FROM Profile WHERE Id=:UserInfo.getProfileId()]) {
        //     if (mapLanguageProfile.containsKey(prof.Name)) curLang = mapLanguageProfile.get(prof.Name);
        // }

        //Check User's local and Federated Login field
        String curLang = DEF_LANG;
        Boolean isFederatedLogin = true;

        for (User usr : [SELECT Profile.Name, Federated_Login__c FROM User WHERE Id=:UserInfo.getUserId()]) {
            if (mapLanguageProfile.containsKey(usr.Profile.Name)) curLang = mapLanguageProfile.get(usr.Profile.Name);
            isFederatedLogin = usr.Federated_Login__c;
        }

        Set<String> sMenuItemWithoutFederatedLogin = new Set<String>{'UserProfile_MenuItem_ManagerUsers','UserProfile_MenuItem_LinkedAccounts'};

        Map<Integer, MenuItemObj> mMenuItem = new Map<Integer, MenuItemObj>();
        String tmp = SEPGLOBVAR_PREFIX + '%';
        for (Seller_Portal_Global_Variables__mdt spgv : [SELECT Id, Label, Value__c, Value_Big__c, Value_in_German__c, DeveloperName FROM Seller_Portal_Global_Variables__mdt WHERE DeveloperName like:tmp Order By Label]){
        
            //We store 3 information that separate by #, inside Value_Big__c as following 
            //Format to split from Value_Big__c <1> # <2> # <3> 
            //<1> - The order of Menu Item that it need to display between Home & Logout Menu Items
            //<2> - The valid Permission Set(s) that able to see this Menu Item, using API Name of Permission Set and separate with multiples Permission Sets by semicolon (;)
            //<3> - The URL that the Menu Item will navigate to
            if (String.isNotBlank(spgv.Value_Big__c)) { 
                List<String> lstTmp = spgv.Value_Big__c.split('#');
                if (lstTmp.isEmpty() || lstTmp.size() != 3) continue; //We are expected to have 3 informations extracted from Value_Big__c
                
                //Check if current user has valid permission set to display the Menu Item
                Set<String> sValidPMS = new Set<String>(lstTmp[1].split(';'));
                Boolean isValid = false;
                for (String pms : curUserPMS) {
                    isValid = sValidPMS.contains(pms);
                    if (isValid) break;
                }

                if (!isValid) continue;
                
                if (sMenuItemWithoutFederatedLogin.contains(spgv.DeveloperName) && isFederatedLogin) continue; //MN-24022022-Menu Item only visible for user is not Federated Login (Federated_Login__c = FALSE)
                
                String labelInLang = (curLang.equals('de'))?spgv.Value_in_German__c:spgv.Value__c;

                MenuItemObj mio = new MenuItemObj(labelInLang, lstTmp[2]);
                mio.order_no = Integer.valueOf(lstTmp[0]);
                mMenuItem.put(mio.order_no, mio);
            }

        }

        //Sort those Menu Item then return back to page
        if (!mMenuItem.isEmpty()) {
            List<Integer> lstMenuItemOrder = new List<Integer>(mMenuItem.keySet());
            lstMenuItemOrder.sort();
            for (Integer order : lstMenuItemOrder){
                lstMenuItems.add(mMenuItem.get(order));
            }
        }
        
        //Add Last Default Menu Item - Logout
        lstMenuItems.add(new MenuItemObj(Label.UsrProf_MenuItem_Logout, 'Logout')); //Logout will always be the last Menu Item

        result.put('menuItems', lstMenuItems);
        
        return result;

    }

    public class MenuItemObj {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }

        private Integer order_no;
        

        
        public MenuItemObj(String label, String val) {
            this.label = label;
            this.value = val;
        }
    }


}