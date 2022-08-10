/*********************************************************************************************************************************
@ Class:          CouponItemTriggerHandler
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        Handler Class for trigger Coupon Item
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 18.04.2019 / Sovantheany Dim / Created the class.
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 06.08.202 / Mony Nou  / US-0009746 - Coupon - enable deletion of coupon related records
*********************************************************************************************************************************/
public without sharing class CouponItemTriggerHandler {
	/****************************************************************************************************************************
	* CONSTANTS DEFINITION
	*****************************************************************************************************************************/
	private final static String SOQL_COUPON_SELLER_2 = 'Select Coupon__r.Couponsite_s__c,Seller__r.Strategic_Seller_Share_w__c,Coupon__r.Seller_Co_funding_share_forecast__c,Coupon__r.Contract_Language__c, Date_4days_Sent__c, Date_34_days_Sent__c, TriggerEmailManhattan__c, Id,Seller__c,Seller__r.EBH_OracleID__c,Coupon__c,Coupon_Seller_Stage__c,Coupon__r.RecordTypeID,Coupon__r.RecordType.DeveloperName,Coupon__r.Stage__c,SellerShareHolder__c From Coupon_Seller__c' ;
	private final static String SOQL_COUPON_ITEM = 'select Item_ID__c, Coupon_ID__c,Unique_Item__c from Coupon_Item__c';

	private static String COUPON_SELLER_STAGE_CONTRACT_TARGETED 	= 'Targeted'; //MN-06082021-US-0009746
	private static String COUPON_SELLER_STAGE_CONTRACT_REACHED 		= 'Reached'; //MN-06082021-US-0009746
	private static String COUPON_SELLER_STAGE_CONTRACT_COMMITED	 	= 'Commited'; //MN-06082021-US-0009746
	private static String COUPON_SELLER_STAGE_CONTRACT_NEGOTIATION 	= 'Contract Negotiation'; //MN-06082021-US-0009746
	
	private static String COUPON_STAGE_DRAFT 				= 'Draft'; //MN-06082021-US-0009746
	private static String COUPON_STAGE_SELLERNEGOTIATION 	= 'Seller Negotiation'; //MN-06082021-US-0009746

	
	/************************************END CONSTANTS DEFINITION*************************************************************/


	/*****************************************************************************************************************************
    @ Method:   preventRecordDeletion
    @ Version:  1.0
    @ Author: 	Mony Nou (mony.nou@gaea-sys.com)
    @ Purpose:	US-0009746 - Coupon - enable deletion of coupon related records
	@ Event:	Before Delete
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter: Map<Id, Coupon_Item__c> oldMap  
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 06.08.2021 / Mony / Created the  Method
	*****************************************************************************************************************************/
	public static void preventRecordDeletion(Map<Id, Coupon_Item__c> oldMap) {

		Set<String> validDeleteCouponSellerStage = new Set<String>{
			COUPON_SELLER_STAGE_CONTRACT_TARGETED,
			COUPON_SELLER_STAGE_CONTRACT_REACHED,
			COUPON_SELLER_STAGE_CONTRACT_COMMITED,
			COUPON_SELLER_STAGE_CONTRACT_NEGOTIATION
		};

		Set<String> validDeleteCouponStage = new Set<String>{
			COUPON_STAGE_DRAFT,
			COUPON_STAGE_SELLERNEGOTIATION
		};

		Boolean isAdmin = (Userinfo.getprofileId() == ApexUtil.ADMIN_PROFILE_ID);

		for (Coupon_Item__c ci : [SELECT Coupon_Seller_ID__r.EBH_CouponSellerOwner__c, Coupon_Seller_ID__r.Coupon_Seller_Stage__c, 
									Coupon_ID__r.Stage__c FROM Coupon_Item__c WHERE Id IN:oldMap.keySet()]) {
			if ( (!isAdmin && Userinfo.getUserId() != ci.Coupon_Seller_ID__r.EBH_CouponSellerOwner__c) 
					|| !validDeleteCouponSellerStage.contains(ci.Coupon_Seller_ID__r.Coupon_Seller_Stage__c)
					|| !validDeleteCouponStage.contains(ci.Coupon_ID__r.Stage__c)) {
				oldMap.get(ci.Id).addError(System.Label.Prevent_Deletion_of_Coupon_Seller_Item_Category);
			}
		}
	}


	/*****************************************************************************************************************************
    @ Method:   createCoInvestOnceCouponItemCreated
    @ Version:  1.0
    @ Author: 	Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:	
    			[#EPH-7253] Object_ Coupon Co-Invest
    			
    			iii)Pagelayout Coupon Co-Invest Item (Record Type)

				Automatically create Coupon co-invest record type = Coupon Co-Invest Item if:
				Coupon type = Item Based
				Create Coupon Seller linked to coupon
				min 1 Item has been uploaded to Coupon Sellers
				User update Coupon Seller stage to = Contract Negotiation
				Once user changed the linked coupon seller status, Co-invest type Coupon Co-Invest Item will be created automatically
				
    @ Event:	After Insert
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:     List<Coupon_Category__c> listNewCategory
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 18.04.2019 / Sovantheany Dim / Created the  Method
   	@				: 19.12.2019/ Vadhanak Voun/ US-0006480 Ability to bulk upload seller share with items
	@				: related: CouponSellerTriggerHandler.createCoInvest2
	   					22/10/2020/ Acmatac SEING / US-0007666 include 1 more status into the trigger (Coupon Running).    
    *****************************************************************************************************************************/
	public static void createCoInvestOnceCouponItemCreated(List<Coupon_Item__c> listNew){
		Map<ID,List<Coupon_Item__c>> mapItem = new Map<ID,List<Coupon_Item__c>>();
		String whereCl = ' where ID IN: listNew';
		for(Coupon_Item__c coItem : Database.query(EBH_ConstantsUtility.SOQL_COUPONITEM + whereCl)){
			if(coItem.Coupon_Seller_ID__c != null && (coItem.Coupon_Seller_ID__r.Coupon_Seller_Stage__c == EBH_ConstantsUtility.COUPON_SELLER_STAGE_NEGO || coItem.Coupon_Seller_ID__r.Coupon__r.Stage__c == CouponTriggerHandler.COUPON_SELLER_NEGOTIATION_STAGE || coItem.Coupon_Seller_ID__r.Coupon__r.Stage__c == CouponTriggerHandler.COUPON_RUNNING_STAGE) && coItem.Coupon_Seller_ID__r.Coupon__r.RecordType.DeveloperName == EBH_ConstantsUtility.COUPON_ITEMBASE){
				List<Coupon_Item__c> lstItem = new List<Coupon_Item__c>();
				if(mapItem.containskey(coItem.Coupon_Seller_ID__c)) lstItem = mapItem.get(coItem.Coupon_Seller_ID__c);
				lstItem.add(coItem);
				mapItem.put(coItem.Coupon_Seller_ID__c,lstItem);
			}
		}
		
		if(mapItem.isEmpty()) return;
		Set<ID> sSeller = mapItem.keySet();
		RecordType coInvestItemRecordType = ApexUtil.getRecordTypeByName('Coupon_Co_Invest__c',EBH_ConstantsUtility.CO_INVEST_ITEM);
		List<Coupon_Co_Invest__c> lstCoInvestToCreated = new List<Coupon_Co_Invest__c>();
		String whereSeller = ' where ID IN: sSeller';
		for(Coupon_Seller__c coSeller : Database.query(SOQL_COUPON_SELLER_2 + whereSeller)){
			if(!mapItem.containsKey(coSeller.ID)) continue;
			List<Coupon_Item__c> lstItem = mapItem.get(coSeller.ID);
			for(Coupon_Item__c item : lstItem){
				Coupon_Co_Invest__c coInvest = CouponTriggerHandler.newCoInvest(coSeller,item,coInvestItemRecordType.Id);
	    		//Th:10/02/2020:comment out bellow code: move all to method newCoInvest
	    		//coInvest.Item_ID__c = item.Item_ID__c;
	    		//coInvest.RecordTypeID = coInvestItemRecordType.Id;
	    		
	    		//NK:16/12/2019: US-0006480 
	    		//Th: US-0007761 - [AU] Update Coupon Co-Invest Records for AU Coupons 10/07/2020
	    		coInvest.Co_Invest__c =  coInvest.Co_Invest__c == null ?(item.Seller_Share__c==null)?coSeller.Coupon__r.Seller_Co_funding_share_forecast__c:item.Seller_Share__c:coInvest.Co_Invest__c;
	    		
	    		lstCoInvestToCreated.add(coInvest);
				}
		}
		
		if(!lstCoInvestToCreated.isEmpty())
    	{
    		insert lstCoInvestToCreated;
    	}
	}
	
	/*****************************************************************************************************************************
    @ Method:   deleteUpdateCouponItem
    @ Version:  1.0
    @ Author: 	Sreymeas Nao (sreymeas.nao@gaea-sys.com)
    @ Purpose:  EPH-7937 AC1,AC2) As any user with permission set = promotions user I want to delete OR update a coupon Item record. I can only delete a coupon item (validation rule )if the following criteria apply:
    @           I am the owner of of the related coupon seller record 
    @           when Coupon seller stage <= Contract send (i.e. all stages after contract send I am not able to delete or update)
    @ Event:	Before Delete and Update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:     List<Coupon_Item__c> listRec
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 08.23.2019 / Sreymeas Nao / Created the  Method.
					12.25.2019 / Acmatac SEING / US-0006997: [AU] Existing Coupon Validations to include AU - Coupon Item and Coupon Co-Invest .- Validation Rule (Delete and edit)
    *****************************************************************************************************************************/
	public static void deleteUpdateCouponItem(List<Coupon_Item__c> listRec){
		CouponCoInvestTriggerHandler.deleteUpdateCpnCoInvAndCpnItem(listRec);
	}
	
	/*****************************************************************************************************************************
    @ Method:   validateCouponItem
    @ Version:  1.0
    @ Author: 	Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:  US-0007117 - Coupon Seller - Validation Rule to stop user uploading same item id to the coupon twice
    @ Description : when I go to Coupon Object record type Item based and upload (manual or bulk) item ids 
	@ System should look through all items relate to all coupon seller records for this specific coupon
	@ If the item ids already exist, system must block the upload of the item ids and display error message below
    @ Event:	Before Insert and Update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:     List<Coupon_Item__c> listNewRec
    				Map<ID,Coupon_Item__c> mapOldRec
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 26.10.2020 / Sovantheany Dim / Created the  Method.
    @ Change history: 21/09/2021 / sovantheany dim/ update :US-0010449 - [BUG] Coupon item creation (bulk and manually) not working
    *****************************************************************************************************************************/
public static void validateCouponItem(List<Coupon_Item__c> listNewRec, Map<ID,Coupon_Item__c> mapOldRec){
		Boolean isNew = (mapOldRec==null);
		set<String> sDuplicateInfile = new set<String>();
		Map<String,Coupon_Item__c> mapCouponItem = new Map<String,Coupon_Item__c>();
		set<String> sItem = new Set<String>();
		for(Coupon_Item__c newItem : listNewRec){
			if(isNew || !isNew && (newItem.Coupon_ID__c != mapOldRec.get(newItem.Id).Coupon_ID__c || newItem.Item_ID__c != mapOldRec.get(newItem.Id).Item_ID__c)){
				String key = newItem.Coupon_ID__c +'_'+newItem.Item_ID__c;
				if(mapCouponItem.containsKey(key)) {
					sDuplicateInfile.add(key);
					continue;
				}
				mapCouponItem.put(key,newItem);
				sItem.add(newItem.Item_ID__c);
			}
		}
		if(mapCouponItem.isEmpty()) return;
		//remove record that duplciate in file
		for(String key : sDuplicateInfile){
			Coupon_Item__c newItem = mapCouponItem.get(key);
			newItem.addError(System.label.Error_Duplicate_Coupon_Item_In_File+newItem.Item_ID__c);
			mapCouponItem.remove(key);
		}
		set<String> uniqueCouponItems = mapCouponItem.keySet();
		String wherecl = ' where Unique_Item__c IN: uniqueCouponItems and Item_ID__c IN: sItem';//TH:21/09/2021:US-0010449 - [BUG] Coupon item creation (bulk and manually) not working
		Map<String,String> mapDupItemInSystem = new Map<String,String>();
		for(Coupon_Item__c existingItem : Database.query(SOQL_COUPON_ITEM + wherecl)){
			mapDupItemInSystem.put(existingItem.Unique_Item__c,existingItem.Item_ID__c);
			if(mapCouponItem.containsKey(existingItem.Unique_Item__c)){
				Coupon_Item__c item = mapCouponItem.get(existingItem.Unique_Item__c);
				item.addError(System.label.Error_Duplicate_Coupon_Item+item.Item_ID__c);
			}
		}
	}
}