/*********************************************************************************************************************************
@ Class:          OpportunityRedirectorController
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        US-0008557 - [NA] Opportunity Layout "Details" and "Related" sections
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 06.11.2020 / Sovantheany Dim / Created the class.
@ Change history: 16.06.2021 / Mony Nou / US-0009693 - Modify Clone Quote Functionality.                 
*********************************************************************************************************************************/
public class OpportunityRedirectorController {
    private static set<String> sPermissionSet = new Set<String>{'US_CA_Standard_user','NA_Sales_Ops_Admin'};
    private static String NAPROFILE = 'NA Standard User Base';
    
    @AuraEnabled
    public static Map<String, Object> validatedOpportunity() {
        Map<String, Object> mResult = new Map<String, Object>();
        try{
            Boolean isNAUser = UserInfo.getProfileId() == ApexUtil.getProfileByName(NAPROFILE).Id;
            // if NA profile : Check if user has permission  "US & CA standard user", "NA Data Loader & Sales Ops Admin" 
            Boolean is_US_NA_userPermission = checkPermissionSet(sPermissionSet);
            
            if(isNAUser && is_US_NA_userPermission || !isNAUser) mResult.put('isSuccess', true);
            else if(isNAUser && !is_US_NA_userPermission){
                mResult.put('isSuccess', false);
                mResult.put('msg', System.label.Validated_NAUserPermission_on_Opportunity);
            }
        }catch (Exception ex) { mResult.put('isSuccess', false);mResult.put('msg', ex.getMessage());}
        return mResult;
    }
    
    private static Boolean checkPermissionSet(Set<String> setPName)
    {
        String currentUserId = UserInfo.getUserId();
        String sWhere = ' WHERE AssigneeId =:currentUserId AND PermissionSet.Name IN :setPName';     
        List<PermissionSetAssignment> listPSA = Database.query(EBH_ConstantsUtility.SOQL_PERMISSIONSET_ASSIGNMENT + sWhere); 
        return listPSA.size() == setPName.Size();
    }
    

    //MN-16062021-US-0009693 - Modify Clone Quote Functionality.
    @AuraEnabled
    public static Map<String, Object> validateCloneQuoteButton() {
        Map<String, Object> mResult = new Map<String, Object>();
        try{
            
            Boolean isValid = CloneQuoteController.isValid();
            mResult.put('isSuccess', isValid);
            if (!isValid) mResult.put('msg', Label.Error_No_Permission_To_CloneQuote);
            
        }catch (Exception ex) { mResult.put('isSuccess', false);mResult.put('msg', ex.getMessage());}
        return mResult;
    }
}