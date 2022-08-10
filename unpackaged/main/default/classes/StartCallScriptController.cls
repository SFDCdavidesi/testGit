/*********************************************************************************************************************************
@ Class:          StartCallScriptController
@ Version:        1.0
@ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:        controller for lightning component Start_Call_Script.cmp
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:  15.06.2021 / Sophal Noch / Created the class.
*********************************************************************************************************************************/
public without sharing class StartCallScriptController {

    /*****************************************************************************************************************************
    @ Method:       getSessionId
    @ Author:       Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:      US-0009379 - Refresh Task page when survey flow is finished
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  15.06.2021 / Sophal Noch / Created the method.
    @*****************************************************************************************************************************/
    @AuraEnabled
    public static String getSessionId(){
        return UserInfo.getSessionId();
    }

    /*****************************************************************************************************************************
    @ Method:       saveContacts
    @ Author:       sovantheany.dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:      US-0011439 - Duplicate Management Contacts
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  11.07.2022 / sovantheany.dim / Created the method.
    @*****************************************************************************************************************************/
    @InvocableMethod(label='Save Contacts' description='Save the Contact specified' category= 'Contact')
    public static List<ID> saveContacts(List<Contact> contacts) {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Database.SaveResult[] results = Database.insert(contacts,dml);
        List<ID> contactIds = new List<ID>();
        for (Database.SaveResult result : results) {
            if (result.isSuccess()) {
                contactIds.add(result.getId());
            }
        }
        return contactIds;
    }
}