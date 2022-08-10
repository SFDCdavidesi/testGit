/*********************************************************************************************************************************
@ Class:          BulkSendCouponContractController
@ Version:        1.0
@ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:        Controller Class for BulkSendCouponContract.cmp
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:  27.08.2020 / Sophal Noch / Created the class.
*********************************************************************************************************************************/
public without sharing class BulkSendCouponContractController {

    private final static String COUPON_SPECIAL_PERMISSION = 'Coupon_Special_Permission';

    /*****************************************************************************************************************************
    @ Method:       apexInit
    @ Author:       Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:      US-0000792
    @               Summary
    @               ADMIN
    @               AC1 :
    @               Create New Permision Set "Coupon Special Permission"
    @               Create New Button in the "Coupon Seller" Related List -> "Send Bulk Contract" in the Coupon Seller Detail page (Refer the attached PPT Slide 1 for the mock layout where the button needs to be placed)
    @               Create a new Coupon Seller Stage "Approved" in between Stage "Negotiation" and "Contract Send" for Coupon Seller Record.
    @               
    @               AC2: "Send Bulk Contract"(Button Logic)
    @               Prerequisite : Only Users with Permission "Coupon Special Permission" can click this button to send Contracts in Bulk.
    @               Button Logic : Check if user has the Permission "Coupon Special Permission" and if yes ,based on the Coupon type ->Coupon Contract Email to be sent to all Coupon Sellers in bulk whose stage is "Approved".
    @               update the stage to "Contract Send" for all the Coupon Sellers which will trigger bulk email send to all the sellers and once complete display the below success pop up message as shown in Slide 3(Refer attached PPT for UI Mock UI)
    @               
    @               Coupon Contracts successfully sent!
    @               
    @               You check the individual status under Coupon Sellers "View All" or Summary Funnel at the bottom of the Coupon record.
    @               
    @               AC3: Validations for the Button :
    @               When there are no "Coupon Seller" records in "Approved" Stage and the Coupon owner clicks "Send Bulk Contract".
    @               Error Message : There are no "Coupon Sellers" in "Approved" stage. Please move them to "Approved" stage and click "Send Bulk Contract".
    @               2. When any user without the "Coupon Special Permission" permission set clicks "Send Bulk Contract" button
    @               Error Message : You do not have Permission "Coupon Special Permission" to bulk send Coupon Contracts.Please raise a Support ticket to add this Permission.
    @               
    @               Testing AC
    @               General Note - Test the ACs with both "AU Standard user profile" and "Standard user profile" users as well
    @               AC4
    @               As Any user with the "Coupon Special Permission  Contract Bulk Send" permission set
    @               Verify coupon Contracts can be sent in bulk to all Sellers with "Coupon Seller Stage" is "Negotiation Complete  'Approved'.  Verify the "Coupon Seller Stage" is updated to "Contract Send" when the bulk eMail alerts are triggered to Sellers. 
    @               Verify if the Success message is displayed to the Coupon Owner.
    @               
    @               AC5 : Verify the Validation Error Messages are displayed as expected for users who click the "Send Bulk Contract" as mentioned in AC3
    @ Event:		after BulkSendCouponContract.cmp init
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:	coupon Id
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  27.08.2020 / Sophal Noch / Created the method.
    @*****************************************************************************************************************************/
    @AuraEnabled
	public static Map<String,Object> apexInit(String couponId) {
        

        // query coupon sellers by coupon id, to display on table

        Map<String,Object> mapResult = new Map<String,Object>();

        Boolean hasCouponSpecialPermission = ApexUtil.checkPermissionSet(new Set<String>{COUPON_SPECIAL_PERMISSION});
        Boolean isAdmin = Userinfo.getprofileId() == EBH_ConstantsUtility.ADMIN_PROFILE_ID;

        if(!hasCouponSpecialPermission && !isAdmin){
            mapResult.put('status','ko');
            mapResult.put('error',System.Label.ErrorNoCouponSpecialPermission);
            return mapResult;
        }


        Set<String> setFieldNameCoSeller = new Set<String>{'id'};

        Map<String,String> mapFixLabel = new Map<String,String>{'Seller__r.Name'=>'Seller'};

        List<ColName> listColNameCoSeller = new List<ColName>();

        for(Schema.FieldSetMember f: SObjectType.Coupon_Seller__c.FieldSets.BulkSendCouponContract.getFields())
        {
            setFieldNameCoSeller.add(f.getFieldPath());
            if(f.getFieldPath().contains('.') && f.getFieldPath().endsWith('Name'))
            {
                String fId = ApexUtil.getFieldIdRef(f.getFieldPath());
                setFieldNameCoSeller.add(fId);
            }

            String filedLabel = mapFixLabel.containsKey(f.getFieldPath())? mapFixLabel.get(f.getFieldPath()): f.getLabel();

            listColNameCoSeller.add(
                new ColName(filedLabel,
                f.getFieldPath(),
                f.getType()+'')
            );

        }

        String soqlCoSeller = ' Select '+String.join(new List<String>(setFieldNameCoSeller),',')+' From Coupon_Seller__c Where Coupon__c=:couponId';
	        
        List<Coupon_Seller__c> listCoSeller = Database.query(soqlCoSeller);

        if(listCoSeller.isEmpty()){
        	mapResult.put('status','ko');
        	mapResult.put('error',System.Label.ErrorNoRelatedCouponSeller);
        }else{
            mapResult.put('listColNameCoSeller',listColNameCoSeller);
            mapResult.put('listCoSeller',listCoSeller);
            mapResult.put('status','ok');
        }


        return mapResult;
    
    }


    /*****************************************************************************************************************************
    @ Method:       apexSave
    @ Author:       Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:      US-0000792
    @               updated selected couponSeller records from BulkSendCouponContract.cmp and update status to = 'Contract Sent'
    @ Event:		after BulkSendCouponContract.cmp load
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:	list of couponSeller 
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  27.08.2020 / Sophal Noch / Created the method.
    @*****************************************************************************************************************************/
    @AuraEnabled
	public static Map<String,Object> apexSave(List<Coupon_Seller__c> listCoSeller) {

        // change coupon sellers which have status = 'Approved' to 'Contract Sent'

        Map<String,Object> mapResult = new Map<String,Object>();

        try {

            List<Coupon_Seller__c> listCoSellerToUpdate = new List<Coupon_Seller__c>();

            if(!listCoSeller.isEmpty()){
                
                for(Coupon_Seller__c eachCoSeller : listCoSeller){
    
                    if(eachCoSeller.Coupon_Seller_Stage__c == EBH_ConstantsUtility.COUPONSELLER_STAGE_APPROVED){
    
                        eachCoSeller.Coupon_Seller_Stage__c = EBH_ConstantsUtility.COUPON_SELLER_STAGE_CONTRACT_SEND;
                        listCoSellerToUpdate.add(eachCoSeller);
    
                    }
    
                }
            }
    
            if(listCoSellerToUpdate.isEmpty()){
                mapResult.put('status','ko');
                mapResult.put('error',System.Label.ErrorNoCouponSellerInApprovedStage);
            }else{
                update listCoSellerToUpdate;
                mapResult.put('status','ok');
            }


        }catch(DMLException dex)
    	{	mapResult.put('status','ko');mapResult.put('error',dex.getDmlMessage(0));mapResult.put('errorDetail',dex.getStackTraceString());
    	}catch(Exception ex)
    	{   mapResult.put('status','ko');mapResult.put('error',ex.getMessage());mapResult.put('errorDetail',ex.getStackTraceString());	}

        return mapResult;


    }

    static Map<String,String> mapLinkField = new Map<String,String>{'Name'=>'Name','Seller__r.Name'=>'SellerId'};

    class ColName{
    	@AuraEnabled
    	public String label;
    	
    	@AuraEnabled
    	public String fieldName;
      
        @AuraEnabled
    	public String type;
    	
        @AuraEnabled
    	public Boolean sortable = true;
    	
    	
    	@AuraEnabled
    	public Map<String,Object> typeAttributes;
    	
    	public ColName(String label,String fieldName,String type)
    	{
    		this.label = label;
    		this.fieldName = fieldName;
    		this.type = type.toLowerCase();
    		//this.editable = setEditableFields.contains(fieldName);
    		
            if(mapLinkField.containsKey(fieldName)){
    			typeAttributes = new Map<String,Object>{
    				'label' => new Map<String,Object>{'fieldName'=>mapLinkField.get(fieldName)},
    				'target'=>'_blank',
    				'tooltip'=>''
    			};
    			this.fieldName = 'link_'+mapLinkField.get(fieldName);
    			this.type = 'url';
    		} 
    	}
    }

}