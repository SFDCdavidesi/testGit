/*********************************************************************************************************************************
@ Class:          SEP_Helper
@ Version:        1.0
@ Author:         Mony Nou (mony.nou@gaea-sys.com)
@ Purpose:        Controller class for general using in SEP Community
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 19.5.2022 / Mony Nou / Created the class.
*********************************************************************************************************************************/

public with sharing class SEP_Helper {

    /*****************************************************************************************************************************
    @ Method:         initRecordInfo
    @ Version:        1.0
    @ Author:         Mony Nou
    @ Purpose:        US-0011689 - Deployment window alert
    @                   + Init method for lwcRecordInfor
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 17.06.2022 / Mony Nou / Created the  Method.
    *****************************************************************************************************************************/
    
    private static String COUPONSELLER_API = 'Coupon_Seller__c';
    private static String COUPONSELLER_STAGE_TARGETED = 'Targeted';
    private static String COUPONSELLER_STAGE_REACHED = 'Reached';
    private static String COUPONSELLER_STAGE_COMMITED = 'Commited';
    private static String COUPONSELLER_STAGE_NEGOTIATION = 'Contract Negotiation';
    private static String COUPONSELLER_COUPONTYPE_ITEM = 'Item Based';
    private static String COUPONSELLER_COUPONTYPE_CATE = 'Category Based';

    private static Map<String, String> mSObjSOQL = new Map<String, String>{
        COUPONSELLER_API => 'Select Coupon_Seller_Stage__c, Coupon_Type__c From Coupon_Seller__c WHERE Id=:recId'
    };

    @AuraEnabled
    public static Map<String,Object> initRecordInfo(String recId, String metaName, String overrideMetaName) {

        Map<String,Object> mapResult = new Map<String,Object>();
        
        //Get sObject API by RecordId 
        if (String.isNotBlank(recId)) {
            String sobj_api = getSObjectAPI(Id.valueOf(recId));
            SObject rec;
            if (mSObjSOQL.containsKey(sobj_api)) {
                 rec = Database.query(mSObjSOQL.get(sobj_api));
                
            }

            if (sobj_api.equalsIgnoreCase(COUPONSELLER_API)) {
                
                Set<String> sNotConfirmedStage = new Set<String> {COUPONSELLER_STAGE_TARGETED, COUPONSELLER_STAGE_REACHED, COUPONSELLER_STAGE_COMMITED};

                Coupon_Seller__c cs = (Coupon_Seller__c) rec;

                if ((sNotConfirmedStage.contains(cs.Coupon_Seller_Stage__c) && (cs.Coupon_Type__c == COUPONSELLER_COUPONTYPE_ITEM || cs.Coupon_Type__c == COUPONSELLER_COUPONTYPE_CATE)) 
                        || (cs.Coupon_Seller_Stage__c == COUPONSELLER_STAGE_NEGOTIATION && cs.Coupon_Type__c == COUPONSELLER_COUPONTYPE_CATE)) {
                    
                    metaName = 'SEP_Coupon_Seller_Record_Info';
                    mapResult.put('metadataName', metaName);
                    
                }
                
                
            }

        }

        if (String.isNotBlank(overrideMetaName)) metaName = overrideMetaName;

        //Get Metadata
        if (String.isNotBlank(metaName)) {
            for (Seller_Portal_Global_Variables__mdt spgv : [SELECT Value__c, Value_Big__c, Value_in_German__c FROM Seller_Portal_Global_Variables__mdt WHERE DeveloperName =: metaName]) {
                mapResult.put('meta', spgv);
            }
        }


        String userLang = UserInfo.getLanguage();
        SEPWindowAlert__c sepwa = SEPWindowAlert__c.getOrgDefaults();
        
        mapResult.put('userLang',userLang);
        mapResult.put('isDeploying', sepwa.Deploying__c);
        
       
        return mapResult;
    }


    private static String getSObjectAPI (Id recordId) {
        Schema.SObjectType sobjectType = recordId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        return sobjectName;
    }

}