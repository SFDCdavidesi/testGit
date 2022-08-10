/*********************************************************************************************************************************
@ Class:          CouponTriggerHandler
@ Version:        1.0
@ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
@ Purpose:        Handler Class for trigger Coupon
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 08.04.2019 /  Sovantheany Dim / Created the class.
@				: 31.08.2021 / Mony Nou / US-0009948 - remove field Email_Adress__c from query string line 16
@				: 20.05.2022 / Loumang SENG / US-0011328 - Deprecate the function to Send BCD file via email to Finance DL after Coupon ended
@				: 23.05.2022 / SRONG TIN / US-0011375: - Add related category list to item based coupon records
@				: 27.06.2022 / Mony Nou / US-0010785 - Refactor Coupon Seller object to support standard search (AC3)
@				: 30.06.2022 / Sambath Seng / US-0011998 - Business Feedback Focus 75 AC3
*********************************************************************************************************************************/
public without sharing class CouponTriggerHandler {
	/****************************************************************************************************************************
	* CONSTANTS DEFINITION
	*****************************************************************************************************************************/
	public final static String CAP_ROWHTML = ' <td style="text-align:left;vertical-align:top;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:black;">{!fieldValue}</td> ';
	private final static String SOQL_COUPON_SELLER_2 = 'Select Coupon__r.Couponsite_s__c,Seller__r.Strategic_Seller_Share_w__c,Coupon__r.Seller_Co_funding_share_forecast__c,Coupon__r.Contract_Language__c, Date_4days_Sent__c, Date_34_days_Sent__c, TriggerEmailManhattan__c, Id,Seller__c,Seller__r.EBH_OracleID__c,Coupon__c,Coupon_Seller_Stage__c,Coupon__r.RecordTypeID,Coupon__r.RecordType.DeveloperName,Coupon__r.Stage__c,SellerShareHolder__c From Coupon_Seller__c' ;
	private final static String SOQL_COUPON_SELLER = 'Select Coupon__r.Coupon_Subtitle_Copy__c,RecordType.DeveloperName, Allow_reaccept_contract__c,Advertising_Promotion__c, Day_1_Alert__c, Coupon_Contract_Due_Date__c, Day34AfterCouponEnd_Trigger_DE__c,Day4AfterCouponEnd_Trigger_DE__c,CurrencyIsoCode, Additional_Terms_Override_of_Agreement__c, Ad_Spend_Date__c, Advertising_Amount__c, Contract_Accept_Date__c,Coupon_Seller_Stage__c,Contract_Language__c,GMV_LC__c,Contra_LC__c,Cost_Share_Seller_LC__c,Coupon__r.Seller_Co_funding_share_forecast__c,Coupon__r.Contract_Due_Date__c,Free_Subtitles__c,Coupon__r.Max_Redemptions__c,Coupon__r.Owner.Name,EBH_CouponSellerOwner__r.Name,EBH_CouponSellerOwner__c,EBH_CouponSellerOwner__r.Email,Coupon__r.Contract_Language__c,Coupon__r.Coupon_Cap__c,Coupon_ID__c ,Coupon__r.Marketing_Coupon_Name__c,Coupon__r.OwnerId,Coupon__r.Owner.Email,Coupon__r.RecordType.DeveloperName,Coupon__r.CurrencyIsoCode,Additional_Terms__c,Coupon__r.Minimum_Transaction_Value__c,Coupon__r.Name,Legal_Entity_Name_w__c,Legal_Entity_Street_w__c,Legal_Entity_Zip_w__c,Seller__r.Parent.EBH_BillingCountry__c,Seller__r.Parent.EBH_BillingCity__c,Seller__r.EBH_VATNumber__c,Seller__r.Name,Coupon__r.Couponsite_s__c,PayPal_adress_N__c,Coupon__r.Coupon_Start_Time__c,Coupon__r.Coupon_Start_Date__c,Coupon__r.Coupon_end_Time__c,Coupon__r.Coupon_End_Date__c,Coupon__r.Coupon_Discount__c,Coupon__r.Coupon_Discount_Amount__c,Coupon__r.T_Cs_URL__c,Id,Name,Seller__c,Coupon__c,Oracle_ID__c,PayPal_adress__c From Coupon_Seller__c ' ;
	public final static String COUPON_SELLER_NEGOTIATION_STAGE = 'Seller Negotiation';
	public final static String COUPON_RUNNING_STAGE = 'Coupon Running';
	private final static String COUPON_OBJNAME = 'Coupon__c';
	private final static String COUPON_CATEGORYBASE = 'Category_Based'; //MN-27062022-US-0010785
    private final static String COUPON_ITEMBASE = 'Item_Based'; //MN-27062022-US-0010785
	private final static String CS_STAGE_TARGETED = 'Targeted'; //MN-27062022-US-0010785
	private final static String CS_STAGE_REACHED = 'Reached'; //MN-27062022-US-0010785
	private final static String CS_STAGE_COMMITED = 'Commited'; //MN-27062022-US-0010785
	private final static String CS_STAGE_NEGOTIATION= 'Contract Negotiation'; //MN-27062022-US-0010785
	private final static String CS_STAGE_APPROVED = 'Approved'; //MN-27062022-US-0010785
	private final static String CS_STAGE_REVIEW = 'Review'; //MN-27062022-US-0010785
	private final static String CS_STAGE_CONTRACTSEND = 'Contract Send'; //MN-27062022-US-0010785
	private final static String CS_STAGE_CONTRACTSIGNED = 'Contract Signed'; //MN-27062022-US-0010785
	private final static String COUPON_ITEMBASE_STAGE = 'Item_Based';
	private final static String COUPON_SITE_DE = 'ebay.de'; //SB 01.06.2022 US-0011998 - Business Feedback Focus 75 AC3
	
	//Loumang:US-0010777: removed field Sellers_Targeted__c from SOQL_COUPON
	//public final static String SOQL_COUPON = 'select MC_Whitelisted__c, Trigger34DayAfterEndDate__c,Trigger4DayAfterEndDate__c,OwnerId,Contract_Language__c, Coupon_ID__c, Days_since_coupon_End_Date__c, Coupon_Source__c, Couponsite_s__c, Coupon_Start_Date__c, Coupon_End_Date__c, Sellers_Targeted__c, Owner.Name, Owner.Email, RecordTypeId, id,Seller_Co_funding_share_forecast__c from Coupon__c';
	public final static String SOQL_COUPON = 'select MC_Whitelisted__c, Trigger34DayAfterEndDate__c,Trigger4DayAfterEndDate__c,OwnerId,Contract_Language__c, Coupon_ID__c, Days_since_coupon_End_Date__c, Coupon_Source__c, Couponsite_s__c, Coupon_Start_Date__c, Coupon_End_Date__c, Sellers_Targeted2__c, Owner.Name, Owner.Email, RecordTypeId, id,Seller_Co_funding_share_forecast__c from Coupon__c';
	private final static Set<Id> SET_ADMIN_PROFILE_ID = new Set<Id>{ApexUtil.ADMIN_PROFILE_ID,ApexUtil.ADMIN_LT_PRIV_PROFILE_ID};
	/************************************END CONSTANTS DEFINITION*************************************************************/
    /*****************************************************************************************************************************
    @ Method:   createCoInvest
    @ Version:  1.0
    @ Author: 	Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:	EPH-7262 Adjustment to Coupon Object
    @			AC3) As any user with permission set promotions user when I create a new coupon record the stage will be set to value = DRAFT by default (can only be edited once coupon has been saved)
    @ Event:	Before Insert
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:     List<Coupon__c> listNew
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 08.04.2019 / Vadhanak Voun / Created the  Method.
    *****************************************************************************************************************************/
    public static void setDefaultStage(List<Coupon__c> listNew)
    {
    		for(Coupon__c coupon : listNew){
    			coupon.Stage__c = EBH_ConstantsUtility.COUPON_STAGE_DRAFT;
    		}
    }
    
	/*****************************************************************************************************************************
    @ Method:   createCoInvestWithRecordType
    @ Version:  1.0
    @ Author: 	Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:	EPH-7253 Object: Coupon Co-Invest
    			i)Pagelayout Coupon Co-Invest Seller (Record Type)

				Automatically create Coupon co-invest record type = Coupon Co-Invest Seller if:
				Coupon type = Seller / Category Based (From Object Coupon__C)
				Coupon Category is added with category level = 0 (From Object Coupon_Category_c) 
				Coupon Seller is created and linked to Coupon
				User update Coupon stage to = Seller Negotiation (From Object Coupon__C)
				Once user changed the status, Co-invest type Coupon Co-Invest Seller will be created automatically with all fields populated and read only except field Co-Invest % which is editable
				
				ii)Pagelayout Coupon Co-Invest Category (Record type)
				
				Automatically create Coupon co-invest record type = Coupon Co-Invest Category if:
				
				Coupon type = Seller / Category Based  (From Object Coupon__C)
				Coupon Category is added with category level > 0  (From Object Coupon_Category_c) 
				Coupon Seller is created and linked to Coupon
				User update Coupon stage to = Seller Negotiation (From Object Coupon__C)
				Once user changed the status, Co-invest type Coupon Co-Invest Category will be created automatically with all fields populated and read only except field Co-Invest % which is editable
    @ Event:	after Update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:     List<Coupon__c> listNew,Map<Id,Coupon__c> mapOld
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 10.04.2019 / Sovantheany Dim / Created the  Method.
	@				10/02.2020 / Sovantheany Dim / updated method : US-0007175 [AU] Coupon CoInvest Record creation to happen when Coupon Seller is in stage "Targeted" for Item Based Coupons
	@				15/05/2020/ Vadhanak Voun/ US-0007195 - Coupon Co-Invest records creation is causing System.LimitException: Too many SOQL queries: 101 error
	@ 						move to @future: processCoInvestAsyn
	@				9/7/2020/ Sovantheany Dim/ updated method: US-0007761 - [AU] Update Coupon Co-Invest Records for AU Coupons
    *****************************************************************************************************************************/
    public static void createCoInvestWithRecordType(List<Coupon__c> listNew,Map<Id,Coupon__c> mapOld)
    {		
    	RecordType coponRecordTypeCategory = ApexUtil.getRecordTypeByName('Coupon__c',EBH_ConstantsUtility.COUPON_CATEGORYBASE);
		RecordType coponRecordTypeItemBase = ApexUtil.getRecordTypeByName('Coupon__c',EBH_ConstantsUtility.COUPON_ITEMBASE);
		Set<String> condtStage = new Set<String>{
			COUPON_SELLER_NEGOTIATION_STAGE
		};
    	//Map<String,RecordType> coponRecordType = ApexUtil.getRecordTypeBySobjectName('Coupon__c');
    	Set<ID> sCoupon = new Set<ID>();	
		for(Coupon__c coupon : listNew){
			Coupon__c oldCoupon = mapOld.get(coupon.Id);
			if(coupon.Stage__c != oldCoupon.Stage__c && condtStage.contains(coupon.Stage__c)
				&& (coupon.RecordTypeID == coponRecordTypeCategory.Id || coupon.RecordTypeID == coponRecordTypeItemBase.Id)){
				sCoupon.add(coupon.Id);
			}
		}
		if(sCoupon.isEmpty()) return;

		Integer totalCSCount = [Select count() From Coupon_Seller__c where Coupon__c IN: sCoupon];

		//create coninvest directly from the trigger if CS <=1000
		if(totalCSCount<=1000)
		{
			processCoInvest((Coupon_Seller__c[])Database.query(SOQL_COUPON_SELLER_2 + ' where Coupon__c IN: sCoupon'));
		}else // call batch for support for >1000
		{
			Batch_CreateCoInvest bCoInvest = new Batch_CreateCoInvest(sCoupon);
			Database.executeBatch(bCoInvest);
		}

	}

	/*********************************************************************************************************************************
	@ Method:         processCoInvest
	@ Version:       1.0
	@ Author:        Vadhanak Voun (vadhanak.voun@gaea-sys.com)
	@ Purpose:       US-0007195 - Coupon Co-Invest records creation is causing System.LimitException: Too many SOQL queries: 101 error
	@               shared with CouponTriggerHandler.createCoInvestWithRecordType AND Batch_CreateCoInvest
	----------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 15.05.2020/ Vadhanak Voun (vadhanak.voun@gaea-sys.com) / Created the Method.
	*********************************************************************************************************************************/	 
	public static void processCoInvest(Coupon_Seller__c[] listCS)
	{
		Map<Id, List<Coupon_Seller__c>> mapCoseller = new Map<Id,List<Coupon_Seller__c>>();
		Map<Id, Coupon_Seller__c> mapCouponSellerForItem = new Map<Id, Coupon_Seller__c>();
		Set<ID> sCoupon = new Set<ID>();
		//query all coupon seller related to Coupon		
		for(Coupon_Seller__c cs : listCS){
			mapCouponSellerForItem.put(cs.Id,cs);
			sCoupon.add(cs.Coupon__c);
			List<Coupon_Seller__c> lstCouponSeller = new List<Coupon_Seller__c>();
			if(mapCoseller.containsKey(cs.Coupon__c)){
				lstCouponSeller = mapCoseller.get(cs.Coupon__c);
			}
			lstCouponSeller.add(cs);
			mapCoseller.put(cs.Coupon__c,lstCouponSeller);
		}
		List<Coupon_Co_Invest__c> lstCoInvest = newListCoInvestToCreated(mapCoseller,sCoupon);
		//Th: 11/02/2020 : US-0007175 [AU] Coupon CoInvest Record creation to happen when Coupon Seller is in stage "Targeted" for Item Based Coupons
		lstCoInvest.addAll(newListCoInvestToCreatedForItemBase(mapCouponSellerForItem));
		List<Coupon_Co_Invest__c> lstCoInvestToCreated = checkDuplicatedCoInvest(lstCoInvest,sCoupon);
		if(!lstCoInvestToCreated.isEmpty()){
			insert lstCoInvestToCreated;
		}
	}

    //check if match criteria , create new co invest
    public static List<Coupon_Co_Invest__c> newListCoInvestToCreated(Map<Id, List<Coupon_Seller__c>> mapCoseller, Set<ID> sCoupon){
    	List<Coupon_Co_Invest__c> lstCoInvestToCreated = new List<Coupon_Co_Invest__c>();
		RecordType coponRecordTypeItemBase = ApexUtil.getRecordTypeByName('Coupon__c',EBH_ConstantsUtility.COUPON_ITEMBASE);
		Map<String,RecordType> coInvestRecordType = ApexUtil.getRecordTypeBySobjectName('Coupon_Co_Invest__c');
		String whereCS = ' where Coupon__c IN: sCoupon and Exception_Category__c = false';
		Integer i=2;
		//query all Coupon Category related to Coupon
		for(Coupon_Category__c cc : Database.query(EBH_ConstantsUtility.SOQL_COUPONCATEGORY + whereCS)){
			//SRONGTIN:23.05.2022:US-0011375: - Add related category list to item based coupon records
			if(!mapCoseller.containsKey(cc.Coupon__c) || cc.Coupon__r.RecordTypeID == coponRecordTypeItemBase.Id) continue;
			if(cc.Category_Level__c == 0){
				for(Coupon_Seller__c cs : mapCoseller.get(cc.Coupon__c)){
					lstCoInvestToCreated.add(newCoInvestWithCategory(cs,cc,coInvestRecordType.get(EBH_ConstantsUtility.CO_INVEST_SELLER).id));
				}
			}else if(cc.Category_Level__c > 0){
				for(Coupon_Seller__c cs : mapCoseller.get(cc.Coupon__c)){
					lstCoInvestToCreated.add(newCoInvestWithCategory(cs,cc,coInvestRecordType.get(EBH_ConstantsUtility.CO_INVEST_CATEGORY).id));
				}
			}
			
			i++;
		}
		return lstCoInvestToCreated;
    }
    
    public static List<Coupon_Co_Invest__c> newListCoInvestToCreatedForItemBase(Map<Id, Coupon_Seller__c> mapCouponSeller){
    	List<Coupon_Co_Invest__c> lstCoInvest = new List<Coupon_Co_Invest__c>();
    	Set<ID> sCouponSellerId = mapCouponSeller.keySet();
    	RecordType coInvestItemRecordType = ApexUtil.getRecordTypeByName('Coupon_Co_Invest__c',EBH_ConstantsUtility.CO_INVEST_ITEM);
    	String wherecls = ' where Coupon_Seller_ID__c IN: sCouponSellerId and Coupon_Seller_ID__r.Coupon__r.RecordType.DeveloperName = \'Item_Based\'';
    	for(Coupon_Item__c item : Database.query(EBH_ConstantsUtility.SOQL_COUPONITEM + wherecls)){
    		Coupon_Seller__c couponSeller = mapCouponSeller.get(item.Coupon_Seller_ID__c);
    		Coupon_Co_Invest__c coInvest = newCoInvest(couponSeller,item,coInvestItemRecordType.Id);
    		lstCoInvest.add(coInvest);
    	}
    	return lstCoInvest;
    }
	//Check to avoid duplicate co invest created, if already exist, no more create
	//NK:17/05/2020:US-0007195: use Unique_Key__c query filter instead of query all
    public static List<Coupon_Co_Invest__c> checkDuplicatedCoInvest(List<Coupon_Co_Invest__c> allCoInvest,Set<ID> sCoupon){
    	Map<String,Coupon_Co_Invest__c> mapCoInvest = new Map<String,Coupon_Co_Invest__c>();		
		Set<String> setKeyFilter = new Set<String>(); //  unique key: Coupon_Seller__c +'-'+ Coupon_Category__c +'-'+ Item_ID__c
		for(Coupon_Co_Invest__c coInvest : allCoInvest){
    		setKeyFilter.add(
				(coInvest.Coupon_Seller__c+'').subString(0,15) + (coInvest.Coupon_Category__c==null?'':'-'+(coInvest.Coupon_Category__c+'').subString(0,15)) + (coInvest.Item_ID__c==null?'':'-'+coInvest.Item_ID__c)
			);    	 
		}
		String whereCl = ' where Coupon_Name__c IN: sCoupon AND Unique_Key__c IN :setKeyFilter ';
    	//query all eixsint (+unique key) co invest realted to coupon
    	for(Coupon_Co_Invest__c coInvest : Database.query(EBH_ConstantsUtility.SOQL_COUPONCOINVEST + whereCl)){
    		String key =coInvest.Coupon_Seller__c + (coInvest.Coupon_Category__c==null?'':'-'+coInvest.Coupon_Category__c) + (coInvest.Item_ID__c==null?'':'-'+coInvest.Item_ID__c);    		 
    		mapCoInvest.put(key,coInvest);
    	}
    	//if co invest already have then remove from list to created
    	List<Coupon_Co_Invest__c> lstCoInvestToCreated = new List<Coupon_Co_Invest__c>();
    	for(Coupon_Co_Invest__c coInvest : allCoInvest){
    		String key = coInvest.Coupon_Seller__c + (coInvest.Coupon_Category__c==null?'':'-'+coInvest.Coupon_Category__c) + (coInvest.Item_ID__c==null?'':'-'+coInvest.Item_ID__c);
    		 
    		if(mapCoInvest.containsKey(key)) continue;
    		lstCoInvestToCreated.add(coInvest);
    	}
    	return lstCoInvestToCreated;
    }
    
    public static Coupon_Co_Invest__c newCoInvestWithCategory(Coupon_Seller__c cs,Coupon_Category__c cc,ID coInvestRecordTypeID){
    	Coupon_Co_Invest__c csNew = new Coupon_Co_Invest__c(
			Seller_Name__c = cs.Seller__c,
			Coupon_Name__c = cs.Coupon__c,
			Coupon_Seller__c = cs.ID,
			Coupon_Category__c = cc.Id,
			RecordTypeId = coInvestRecordTypeID,
			isNotManualCreated__c = true,
			//Th: US-0007761 - [AU] Update Coupon Co-Invest Records for AU Coupons 10/07/2020
			Co_Invest__c = (cs.Coupon__r.Couponsite_s__c != null && cs.Coupon__r.Couponsite_s__c.contains('ebay.com.au'))?(cs.Seller__r.Strategic_Seller_Share_w__c != null?Decimal.valueOf(cs.Seller__r.Strategic_Seller_Share_w__c):cs.Coupon__r.Seller_Co_funding_share_forecast__c):cs.SellerShareHolder__c);
		return csNew;
    }
	
	public static Coupon_Co_Invest__c newCoInvest(Coupon_Seller__c cs,Coupon_Item__c item,Id recordTypeid)
    {
    	//Th: US-0007761 - [AU] Update Coupon Co-Invest Records for AU Coupons 10/07/2020
		return new Coupon_Co_Invest__c(Coupon_Seller__c=cs.Id,Seller_Name__c=cs.Seller__c,Coupon_Name__c=cs.Coupon__c,isNotManualCreated__c = true,Item_ID__c=item.Item_ID__c,RecordTypeID=recordTypeid,Co_Invest__c=(cs.Coupon__r.Couponsite_s__c != null && cs.Coupon__r.Couponsite_s__c.contains('ebay.com.au'))?(cs.Seller__r.Strategic_Seller_Share_w__c != null?Decimal.valueOf(cs.Seller__r.Strategic_Seller_Share_w__c):cs.Coupon__r.Seller_Co_funding_share_forecast__c):item.Seller_Share__c);
    }
    
    /*****************************************************************************************************************************
    @ Method:   populateDateTimeAuto
    @ Version:  1.0
    @ Author: 	vadhanak voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:	EPH-7209 Coupon Record Type: Category Based and Item Based set Stage rules
    @			AC1)) When a Coupon (both record types) reach Coupon Start Date and Coupon Start Time then automatically set Coupon to status "Coupon Running"
	@			AC2) When a Coupon (both record types) reach Coupon End Date and Coupon End Time then automatically set Coupon to status "Coupon Executed"
	@			** use Timebase Workflow in combination with this Trigger
    @ Event:	before insert, before update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:     List<Coupon__c> listNew,Map<Id,Coupon__c> mapOld
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 09.04.2019 / Vadhanak Voun / Created the  Method.
	@				: 12.08.2021/ vadhanak voun / US-0009100 - Hypercare bug: Coupon Seller Stage Not Updating
	@											/ moved to flow
    *****************************************************************************************************************************/
    public static void populateDateTimeAuto(List<Coupon__c> listNew,Map<Id,Coupon__c> mapOld)
    {
    	Boolean isNew = (mapOld==null);
    	for(Coupon__c c: listNew)
    	{
    		if(isNew  )
    		{
    			if(c.Coupon_Start_Date__c <> null && c.Coupon_Start_Time__c <> null)
    			{
    				c.Start_Date_Time__c = DateTime.newInstanceGmt(c.Coupon_Start_Date__c, c.Coupon_Start_Time__c).addHours(1); //minus 1h because WF 1h before new DateTime
    				c.Start_Date_Time__c = recalUserTime(c.Start_Date_Time__c);
    				
    				//c.Check_Start_Date_Time__c = true;
    			}
    			if(c.Coupon_End_Date__c <> null && c.Coupon_end_Time__c <> null)
    			{
    				c.End_Date_Time__c = DateTime.newInstanceGmt(c.Coupon_End_Date__c, c.Coupon_end_Time__c).addHours(1);
    				c.End_Date_Time__c = recalUserTime(c.End_Date_Time__c);
    				
    				//c.Check_End_Date_Time__c = true;
    			}
    			
    		}else if(!isNew)
    		{
    			Set<String> setCouponId_fields = new Set<String>();
    			if(c.Coupon_Start_Date__c <> mapOld.get(c.Id).Coupon_Start_Date__c || c.Coupon_Start_Time__c <> mapOld.get(c.Id).Coupon_Start_Time__c && c.Coupon_Start_Date__c <> null && c.Coupon_Start_Time__c <> null)
    			{
    				c.Start_Date_Time__c = DateTime.newInstanceGmt(c.Coupon_Start_Date__c, c.Coupon_Start_Time__c).addHours(1);
    				c.Start_Date_Time__c = recalUserTime(c.Start_Date_Time__c);
    				
    				//c.Check_Start_Date_Time__c = false;
    				//setCouponId_fields.add(c.Id+'@_@Check_Start_Date_Time__c'); //reactivate by future
    			}
    			if(c.Coupon_End_Date__c <> mapOld.get(c.Id).Coupon_End_Date__c || c.Coupon_end_Time__c <> mapOld.get(c.Id).Coupon_end_Time__c && c.Coupon_End_Date__c <> null && c.Coupon_end_Time__c <> null)
    			{
    				c.End_Date_Time__c = DateTime.newInstanceGmt(c.Coupon_End_Date__c, c.Coupon_end_Time__c).addHours(1);
    				c.End_Date_Time__c = recalUserTime(c.End_Date_Time__c);
    				
    				//c.Check_End_Date_Time__c = false;
    				//setCouponId_fields.add(c.Id+'@_@Check_End_Date_Time__c');//reactivate by future
    			}
    			// if(!setCouponId_fields.isEmpty())
    			// {
    			// 	actviateCheckFields(setCouponId_fields);
    			// }
    		}
    		
    	}
    }
    
    private static DateTime recalUserTime(DateTime dt)
    {
    	TimeZone tz = UserInfo.getTimeZone();
    	Integer o = tz.getOffset(dt);
		Integer hOffset =( (o/1000) /60)/60; //set hour to current user time as he/she doing 
		return dt.addHours(-hOffset);
    }
    
    // @future private static void actviateCheckFields(Set<String> setCouponId_fields)
    // {
    // 	Map<String,Coupon__c> mapUpdate = new Map<String,Coupon__c>();
    // 	for(String cId_f: setCouponId_fields)
    // 	{
    // 		String cId = cId_f.split('@_@')[0];
    // 		String fName = cId_f.split('@_@')[1];
    // 		Coupon__c c = mapUpdate.containsKey(cId)?mapUpdate.get(cId): new Coupon__c(Id=cId);
    // 		c.put(fName,true);
    		
    // 		mapUpdate.put(cId,c);
    // 	}
    // 	update mapUpdate.values();
    // }
	
	/*****************************************************************************************************************************
    @ Method:   setEmailManhattan
    @ Version:  1.0
    @ Author: 	Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:	EPH-7565 Coupon - Manhattan Invoice Statment send to coupon seller
				
    @ Event:	Before Update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:     List<Coupon__c> listNewCoupon,Map<ID,Coupon__c> mapoldCoupon
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 29.07.2019 / Sovantheany Dim / Created the Method
   	@				: 07.10.2019 / Vadhanak Vouun / disable the method - use new logic
    *****************************************************************************************************************************/
    /*
    public static void setEmailManhattan(List<Coupon__c> listNewCoupon, Map<ID,Coupon__c> mapoldCoupon)
    {
    	Set<String> sCouponId = new Set<String>();
    	for(Coupon__c coupon : listNewCoupon){
    		if(coupon.Coupon_End_Date__c != null && coupon.Coupon_End_Date__c != mapoldCoupon.get(coupon.Id).Coupon_End_Date__c){
				sCouponId.add(coupon.Id);
    		}
    	}
    	
    	if(sCouponId.isEmpty()) return;
    	
    	set<String> setField = new set<String>();
    	List<Coupon_Seller__c> lstCouponSeller = new List<Coupon_Seller__c>();
    	string whereSellerCl = ' where Coupon__c IN: sCouponId';
    	for(Coupon_Seller__c couponSeller : Database.query(SOQL_COUPON_SELLER_2 + whereSellerCl)){
			couponSeller.TriggerEmailManhattan__c = false;
			lstCouponSeller.add(couponSeller);
			setField.add(couponSeller.Id+'@_@TriggerEmailManhattan__c');
    	}
    	
    	if(!lstCouponSeller.isEmpty()) update lstCouponSeller;
    	if(!setField.isEmpty()) setFutureEmailManhattan(setField);
    }
    
    @future private static void setFutureEmailManhattan(set<String> setCouponSellerId_fields){
    	Map<String,Coupon_Seller__c> mapUpdate = new Map<String,Coupon_Seller__c>();
    	for(String csId_f : setCouponSellerId_fields){
    		String csId = csId_f.split('@_@')[0];
    		String fName = csId_f.split('@_@')[1];
    		Coupon_Seller__c cs = mapUpdate.containsKey(csId)?mapUpdate.get(csId): new Coupon_Seller__c(Id=csId);
    		cs.put(fName,true);
    		
    		mapUpdate.put(csId,cs);
    	}
    	update mapUpdate.values();
    }*/
	
	/*****************************************************************************************************************************
    @ Method:   setEmailManhattanForCoupon
    @ Version:  1.0
    @ Author: 	Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:	EPH-7725 Send BCD file via email to Finance DL after Coupon ended
				
    @ Event:	Before Insert, Before Update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:     List<Coupon__c> listNewCoupon, Map<ID,Coupon__c> mapoldCoupon
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 30.07.2019 / Sovantheany Dim / Created the Method
   	@				: 15/11/2019/ Vadhanak Voun/ disabled moved all to scheduler 
    *****************************************************************************************************************************/
    /*public static void setEmailManhattanForCoupon(List<Coupon__c> listNewCoupon, Map<ID,Coupon__c> mapoldCoupon)
    {
    	set<String> setFieldCoupon = new set<String>();
    	for(Coupon__c coupon : listNewCoupon){
    		if(trigger.isInsert){
    			coupon.TriggerEmailManhattan__c = true;
    		}else if(trigger.isUpdate){
    			if(coupon.Coupon_End_Date__c != null && coupon.Coupon_End_Date__c != mapoldCoupon.get(coupon.Id).Coupon_End_Date__c){
    				coupon.TriggerEmailManhattan__c = false;
    				setFieldCoupon.add(coupon.Id+'@_@TriggerEmailManhattan__c');
    			}
    		}
    	}
    	if(!setFieldCoupon.isEmpty()) setFutureEmailManhattanForCoupon(setFieldCoupon);
    }
    
    @future private static void setFutureEmailManhattanForCoupon(set<String> setCouponId_fields){
    	Map<String,Coupon__c> mapUpdate = new Map<String,Coupon__c>();
    	for(String cId_f : setCouponId_fields){
    		String cId = cId_f.split('@_@')[0];
    		String fName = cId_f.split('@_@')[1];
    		Coupon__c c = mapUpdate.containsKey(cId)?mapUpdate.get(cId): new Coupon__c(Id=cId);
    		c.put(fName,true);
    		
    		mapUpdate.put(cId,c);
    	}
    	update mapUpdate.values();
    }
    */
     /*****************************************************************************************************************************
    @ Method:   sendBCDFileEmail
    @ Version:  1.0
    @ Author: 	Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:	EPH-7725 Send BCD file via email to Finance DL after Coupon ended
				
    @ Event:	after Update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:     List<Coupon__c> listNewCoupon, Map<ID,Coupon__c> mapoldCoupon
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 30.07.2019 / Sovantheany Dim / Created the Method
   	@ 				: 07.10.2019/ Vadhanak Voun / Trigger4DayAfterEndDate__c, Trigger34DayAfterEndDate__c
	@   			: 10.03.2020/  Vadhanak Voun / US-0007219 US-0007219 - Coupon & Coupon Seller - attach T4 and T40 statement & custom flag
   	@							added flag to custom setting and to allow send email or not
	@				: 30.08.2021 / Acmatac SEING / US-0010176 - MC: Coupon email notifications to external users
	@				: 20.05.2022 / Loumang SENG / US-0011328 - Deprecate the function to Send BCD file via email to Finance DL after Coupon ended
    *****************************************************************************************************************************/
    /*public static void sendBCDFileEmail(List<Coupon__c> listNewCoupon, Map<ID,Coupon__c> mapoldCoupon)
    {
    	if(!EBH_ActiveTriggers__c.getInstance(EBH_ConstantsUtility.TRIGGERCONTROLLER).Coupon_Send_BCD_File_To_DL__c)
    	{
    		return;
    	}
    	Set<String> sCouponId = new Set<String>();
    	for(Coupon__c coupon : listNewCoupon){
    		Coupon__c oldCoupon = mapoldCoupon.get(coupon.Id);
    		 
    		// US-0010176 - Acmatac SEING, Send email only MC_Whitelisted__c = False
			if(coupon.MC_Whitelisted__c){
				continue;
			}
			
    		//if(coupon.BCD_EmailTrigger__c != null && coupon.BCD_EmailTrigger__c != oldCoupon.BCD_EmailTrigger__c){
    		if((coupon.Trigger4DayAfterEndDate__c <> oldCoupon.Trigger4DayAfterEndDate__c && coupon.Trigger4DayAfterEndDate__c <> null )
    			|| coupon.Trigger34DayAfterEndDate__c <> oldCoupon.Trigger34DayAfterEndDate__c && coupon.Trigger34DayAfterEndDate__c <> null)
    		{
    			sCouponId.add(coupon.Id);
    		}
    	}
    	
    	if(sCouponId.isEmpty()) return;
    	
    	//NK:15/11/2019: moved to CS own trigger. scheduler will update cs status first then coupon to trigger bcd properly order
    	//Set<String> csStages = new Set<String>{EBH_ConstantsUtility.COUPON_SELLER_STAGE_EXEC,EBH_ConstantsUtility.COUPON_SELLER_STAGE_T4};
    	//String sWhere = ' Where Coupon__c IN:sCouponId AND Coupon_Seller_Stage__c IN:csStages ';
    	//List<Coupon_Seller__c> listCSSellect = Database.query(SOQL_COUPON_SELLER+sWhere);
    	
    	//update stage and send email
    	//CouponSellerTriggerHandler.isUpdatedSellerStage = true; //allow system update
    	//CouponSellerTriggerHandler.sendT4_T34Email(listCSSellect);
    	
    	//after stag updated, send bcd file
    	doSendBCDFileEmail(sCouponId);
    	
    }*/
    
	/*****************************************************************************************************************************
	@ Change history: 	30.08.2021 / Acmatac SEING / US-0010176 - MC: Coupon email notifications to external users
	@				: 20.05.2022 / Loumang SENG / US-0011328 - Deprecate the function to Send BCD file via email to Finance DL after Coupon ended
    *****************************************************************************************************************************/
    /*private static void doSendBCDFileEmail(Set<String> sCouponId)
    {
    	Map<String,String> mapCsv = buildCSVData(sCouponId);
    	String emailTemplateName = EBH_ConstantsUtility.BCD_EMAIL_TEMPLATED_NAME;
    	String whereCl = ' Where DeveloperName =: emailTemplateName'; 
    	List<EmailTemplate> empt = Database.query(EBH_ConstantsUtility.SOQLEMAIL_TEMPLATES + whereCl);
    	if(!empt.isEmpty())
   		{
   			Map<String,String> mapCountry = new Map<String,String>{
		'DE'=>Label.DL_EBAY_DL_BCDFILE_DE,
		'UK'=>Label.DL_EBAY_DL_BCDFILE_UK,
		'FR'=>Label.DL_eBay_DL_BCDFILE_FRITES,
		'IT'=>Label.DL_eBay_DL_BCDFILE_IT,
		'ES'=>Label.DL_eBay_DL_BCDFILE_ES
		}; 
   			List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
   			List<Attachment> lstAtt = new List<Attachment>();
   			
   			String wherecls = ' where id IN: sCouponId';
   			for(Coupon__c c : Database.query(SOQL_COUPON + wherecls)){
   				List<String> listToAddr = new List<String>{c.Owner.Email};
   				 
   				if(mapCountry.containsKey(c.Contract_Language__c)){
   					listToAddr.add(mapCountry.get(c.Contract_Language__c));
   				}
   				String subject = mergSubjectBCD(empt[0].Subject,c);
	    		String htmlBody = mergeEmailTemplateBody(empt[0].HtmlValue,c);
	    		
	    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		        mail.setToAddresses(listToAddr);
		        //mail.setSenderDisplayName('Hive Support');
		        mail.setSubject(subject);
		        mail.setBccSender(false);
		        mail.setUseSignature(false); 
		        mail.setHtmlBody(htmlBody);
		        //TH: 20/10/2020: US-0008543 - Set OrgWideDefault Address
				String replyto = c.Owner.Email;
				CouponSellerTriggerHandler.setOrgWideAddress(mail,replyto,System.label.OWD_MKT_REP);
				//End US-0008543
			
		        String csvContent = mapCsv.get(c.Id).trim();
		        List<Messaging.EmailFileAttachment> listAtt = new List<Messaging.EmailFileAttachment>();
			    Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
	        	fileAttachment.setBody(Blob.valueOf(csvContent));
	       	 	fileAttachment.setFileName('BCD_File.csv');  
	        	listAtt.add(fileAttachment);  
	        	
			    mail.setFileAttachments(listAtt);
		    	listEmail.add(mail);
		    	
		    	Attachment attachment = new Attachment(ParentId=c.Id,Name='BCD_File.csv',Body=Blob.valueOf(csvContent));
   				lstAtt.add(attachment);
   			}
	    		
		    if(!listEmail.isEmpty() && !Test.isRunningTest()) Messaging.sendEmail(listEmail);
   			if(!lstAtt.isEmpty()) insert lstAtt;
   		}
    }*/
    
    /*****************************************************************************************************************************
    @ Method:   synCurrencyValueTo_CpnSelrAndCpnCoInv
    @ Version:  1.0
    @ Author: 	Acmatac Seing (acmatac.seing@gaea-sys.com)
    @ Purpose:	EPH-7896 Coupon Seller and Coupon Co-Invest - Take the Currency value from related Coupon Object
				
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 21.08.2019 / Acmatac Seing / Method Creation
    *****************************************************************************************************************************/
    public static void synCurrencyValueTo_CpnSelrAndCpnCoInv(Map<Id, Coupon__c> mOldCpn, Map<Id, Coupon__c> mNewCpn){
    	Set<Id> sCpnId = new Set<Id>();
    	
    	// Filter only updated Coupon.CurrencyIsoCode
	    for(Id oCpnId : mOldCpn.keySet()){
	    	Coupon__c oldCpn = mOldCpn.get(oCpnId);
	    	Coupon__c newCpn = mNewCpn.get(oCpnId);
	    	if(oldCpn.CurrencyIsoCode != newCpn.CurrencyIsoCode){
	    		sCpnId.add(oCpnId);
	    	}
	    }
    	
    	List<Coupon_Co_Invest__c> lstCpnCoInv = new List<Coupon_Co_Invest__c>();
    	List<Coupon_Seller__c> lstCpnSelr = new List<Coupon_Seller__c>();
    	String cpnConInvSQL = EBH_ConstantsUtility.COUPON_COINVEST_SQL.Replace('[EXTRA_CLAUSE]','Coupon_Name__c') + ' WHERE Coupon_Name__c IN: sCpnId';
    	String cpnSellerSQL = EBH_ConstantsUtility.COUPON_SELLER_SQL.Replace('[EXTRA_CLAUSE]','Coupon__c') + ' WHERE Coupon__c IN: sCpnId';
        
    	// Select all related Coupon Co-Invest and Coupon Seller
    	for(Coupon_Co_Invest__c aCpnCoInv : Database.Query(cpnConInvSQL)){
    		aCpnCoInv.CurrencyIsoCode = mNewCpn.get(aCpnCoInv.Coupon_Name__c).CurrencyIsoCode;
    		lstCpnCoInv.add(aCpnCoInv);
    	}
    	
    	for(Coupon_Seller__c aCpnSelr : Database.Query(cpnSellerSQL)){
    		aCpnSelr.CurrencyIsoCode = mNewCpn.get(aCpnSelr.Coupon__c).CurrencyIsoCode;
    		lstCpnSelr.add(aCpnSelr);
    	}
    	
    	// Update Coupon Co-Invest
    	if(!lstCpnCoInv.isEmpty()){
    		update lstCpnCoInv;
    	}
    	// Update Coupon Seller
    	if(!lstCpnSelr.isEmpty()){
    		update lstCpnSelr;
    	}
    }
     
    public static Map<String,String> buildCSVData(Set<String> sCouponId){
        Map<String,String> mapCsv = new Map<String,String>();
        List<String> sColumn = new List<String>{'id_type','external_id','invoice','transaction_type','credit_type','reason','provider_id','currency','input amount','memo'};
        String columnHeader = String.join(sColumn,',');
        String csvData = columnHeader + '\n';
        for(String couponId : sCouponId){
        	mapCsv.put(couponId,csvData);
        }
        Set<String> sStage = EBH_ConstantsUtility.COUPON_SELLER_STAGE;
        //System.debug('<<<<<sStage='+sStage);
        String wherecl = ' where Coupon__c IN: sCouponId and Coupon_Seller_Stage__c IN: sStage and Contract_Accept_Date__c != null';
        for(Coupon_Seller__c cs : Database.query(EBH_ConstantsUtility.SOQL_COUPONSELLER_FOR_BCD + wherecl)) {
        	csvData = mapCsv.get(cs.Coupon__c);
        	
            List<String> rowData = new List<String>();
            rowData.add(getObjectValue(cs.Coupon__r.ID_Type__c));
            rowData.add(getObjectValue(cs.External_ID__c));
            rowData.add(getObjectValue(cs.Coupon__r.Invoice__c));
            rowData.add(getObjectValue(cs.Coupon__r.Transaction_Type__c));
            rowData.add(getObjectValue(cs.Coupon__r.Credit_type__c));
            rowData.add(getObjectValue(cs.Coupon__r.Reason__c));
            rowData.add(getObjectValue(cs.Provider_ID__c));
            rowData.add(getObjectValue(cs.Currency__c));
            rowData.add(cs.CurrencyIsoCode +' '+ getObjectValue(cs.Cost_Share_Seller_LC__c)); //NK:15/11/2019: US-0018904: Cost_Share_Seller__c -> Cost_Share_Seller_LC__c
            rowData.add(getObjectValue(cs.Coupon__r.Memo__c));
            csvData += String.join(rowData, ',') + '\n';
            
            mapCsv.put(cs.Coupon__c,csvData);
        }
        //System.debug('<<<<<mapCsv='+mapCsv);
        return mapCsv;
    } 
    
    private static String getObjectValue(Object obj){
        if(obj==null)return '';
        return obj + '';
    }
    
    private static String mergSubjectBCD(String s, Coupon__c c)
    {
    	return s==null?'':s.replace('{!Coupon__c.Coupon_ID__c}',getObjectValue(c.Coupon_ID__c))
    			.replace('{!Coupon__c.Days_since_coupon_End_Date__c}',getObjectValue(c.Days_since_coupon_End_Date__c));
    		
    }
    
    private static String mergeEmailTemplateBody(String s, Coupon__c c)
 	{
 		return s==null?'':s
 		.replace('{!Coupon__c.Coupon_ID__c}',getObjectValue(c.Coupon_ID__c))
 		.replace('{!Coupon__c.Days_since_coupon_End_Date__c}',getObjectValue(c.Days_since_coupon_End_Date__c))
 		.replace('{!Coupon__c.OwnerFullName}',getObjectValue(c.Owner.Name))
 		.replace('{!Coupon__c.Coupon_Source__c}',getObjectValue(c.Coupon_Source__c))
 		.replace('{!Coupon__c.Couponsite_s__c}',getObjectValue(c.Couponsite_s__c)) 
 		.replace('{!Coupon__c.Coupon_Start_Date__c}',(c.Coupon_Start_Date__c == null ? '':c.Coupon_Start_Date__c.format()))
 		.replace('{!Coupon__c.Coupon_End_Date__c}',(c.Coupon_End_Date__c == null ? '':c.Coupon_End_Date__c.format()))
 		//.replace('{!Coupon__c.Sellers_Targeted__c}',getObjectValue(c.Sellers_Targeted__c)) //Loumang:US-0010777: cmt this line
		.replace('{!Coupon__c.Sellers_Targeted__c}',getObjectValue(c.Sellers_Targeted2__c))
		.replace('{!Coupon__c.Link}',URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/r/Coupon__c/'+c.Id+'/view');
 	}

	private static set<String> sCouponStage = new Set<String>{'Coupon Running','Coupon Executed','T4 Statement Send','T34 Statement Send'};
	/*****************************************************************************************************************************
    @ Method:   blockManualSetStage
    @ Version:  1.0
    @ Author: 	Sovantheany.dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:	EPH-7880 Coupon Seller - Block any user to set stages running, executed, staements send (i.e. fields that are updated by Trigger)
    @ Trigger : before insert , before updated
	@ Param : List<Coupon__c> newCoupon,Map<Id, Coupon__c> mOldnCoupon			
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 22.08.2019 / Sovantheany Dim / Method Creation
	@					22.08.2019 / Acmatac SEING / US-0011025 - Update existing validation error message
	@					31.03.2022 / Sophal Noch / US-0011453 - Allow System Administrator Limited Priviledges to change coupon stage manually 
    *****************************************************************************************************************************/
    public static void blockManualSetStage(List<Coupon__c> newCoupons,Map<Id, Coupon__c> mOldnCoupon){
    	// Boolean isAdmin = (Userinfo.getprofileId()==EBH_ConstantsUtility.ADMIN_PROFILE_ID);
		Boolean isAdmin = (SET_ADMIN_PROFILE_ID.contains(Userinfo.getprofileId())); // 31.03.2022 / Sophal Noch / US-0011453
    	for(Coupon__c newCoupon : newCoupons){
			//to avoid error on workflow Coupon Executed and Coupon Running
    		if(newCoupon.TriggerStageUpdatedDate__c != null && newCoupon.TriggerStageUpdatedDate__c != mOldnCoupon.get(newCoupon.Id).TriggerStageUpdatedDate__c) continue;
    		if(!isAdmin && newCoupon.Stage__c != null && sCouponStage.contains(newCoupon.Stage__c) && (trigger.isInsert || (trigger.isUpdate && newCoupon.Stage__c != mOldnCoupon.get(newCoupon.Id).Stage__c))){
    			newCoupon.Stage__c.adderror(Label.COUPON_STAGE_CHANGE_RULE_ERROR_MSG);
    		}
    	}
    }
    
    /*****************************************************************************************************************************
    @ Method:   setCouponCoinvestStaticOwner
    @ Version:  1.0
    @ Author: 	Sovantheany.dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:	US-0015718 Coupon - Allow Coupon Owner to add Category Exceptions
    @ set static Owner = Coupon owner so that Coupon Owner can deleted Coupon co invest
    @ Trigger : before updated
	@ Param : List<Coupon__c> newCoupon,Map<Id, Coupon__c> mOldnCoupon			
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 04.10.2019 / Sovantheany Dim / Method Creation
    *****************************************************************************************************************************/
    public static void setCouponCoinvestStaticOwner(List<Coupon__c> newCoupon,Map<Id, Coupon__c> mOldnCoupon){
    	Map<String,String> mapCouponOwner = new Map<String,String>();
    	for(Coupon__c c : newCoupon){
    		if(c.OwnerId != mOldnCoupon.get(c.Id).OwnerId){
    			mapCouponOwner.put(c.Id,c.OwnerId);
    		}
    	}
    	if(mapCouponOwner.isEmpty()) return;
    	Set<String> sCouponId = mapCouponOwner.keySet();
    	List<Coupon_Co_Invest__c> lstCoInvestUpdated = new List<Coupon_Co_Invest__c>();
    	for(Coupon_Co_Invest__c coInvest : Database.query(EBH_ConstantsUtility.SOQL_COUPONCOINVEST + ' where Coupon_Name__c IN: sCouponId')){
    		if(!mapCouponOwner.containsKey(coInvest.Coupon_Name__c)) continue;// || CouponCoInvestTriggerHandler.stage.get(coInvest.Coupon_Seller__r.Coupon_Seller_Stage__c) > 4
    		if(coInvest.OwnerId != mapCouponOwner.get(coInvest.Coupon_Name__c)){
	    		coInvest.OwnerId = mapCouponOwner.get(coInvest.Coupon_Name__c);
	    		lstCoInvestUpdated.add(coInvest);
    		}
    	}
		if(!lstCoInvestUpdated.isEmpty()) update lstCoInvestUpdated;
    }

	/*****************************************************************************************************************************
    @ Method	:   couponNegotitaionEndDateReachSendEmail
    @ Version	:   1.0
    @ Author	: 	Acmatac SEING (acmatac.seing@gaea-sys.com)
    @ Purpose	:	US-0005984 [AU] AU Coupon Approval Email Notification to Category Growth Manager
    @ Trigger 	: 	after updated
	@ Param 	: 	Map<Id, Coupon__c> mOldnCoupon, Map<Id, Coupon__c> mNewCoupon	
    ------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 12.10.2019 / Acmatac SEING / Method Creation
					  17.02.2020 / Acmatac SEING / [US-0007104] UK Coupon Approval Process - Trading Mgr Approval
					  30.08.2021 / Acmatac SEING / US-0010176 - MC: Coupon email notifications to external users
    *****************************************************************************************************************************/
    public static void couponNegotitaionEndDateReachSendEmail(Map<Id, Coupon__c> mOldnCoupon, Map<Id, Coupon__c> mNewCoupon){
		
		Set<String> sContractLang = new Set<String>{'AU', 'UK'};
		Set<Id> sCpnId = new Set<Id>();
		for(Id cpnId : mOldnCoupon.keySet()){
			Coupon__c oldCpn = mOldnCoupon.get(cpnId);
			Coupon__c newCpn = mNewCoupon.get(cpnId);
			if(newCpn.Trigger1DayAfterNegotiationEndDate__c != null && oldCpn.Trigger1DayAfterNegotiationEndDate__c != newCpn.Trigger1DayAfterNegotiationEndDate__c && sContractLang.contains(newCpn.Contract_Language__c)
				&& !newCpn.MC_Whitelisted__c){ // Acmatac SEING, US-0010176 - MC: Coupon email notifications to external users
				sCpnId.add(oldCpn.Id);
			}
		}
		if(!sCpnId.isEmpty()){
			String couponStageNego = EBH_ConstantsUtility.COUPON_SELLER_STAGE_NEGO;
			
			List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
			Map<String, EmailTemplate> mEmailTempl = new Map<String, EmailTemplate>();

			String emailTemplateName = '%' + EBH_ConstantsUtility.CPN_APPR_EMAILNOTIFI_TO_CAT_GROW_MANGR_EMAILTEMPLATE;
			String whereCl = ' Where DeveloperName LIKE: emailTemplateName'; 
			for(EmailTemplate emTm : Database.query(EBH_ConstantsUtility.SOQLEMAIL_TEMPLATES + whereCl)){
				mEmailTempl.put(emTm.DeveloperName, emTm);
			}
			
			Map<String, EmailByCountryWrap> mEmailAddr = new Map<String, EmailByCountryWrap>();
			List<String> lstUserEmail = new List<String>();
			List<String> lstCCEmail = new List<String>();

			// AU
			String role_HeadOfHardverticals = EBH_ConstantsUtility.HEADOFHARDVERTICALS_ROLE;
			String whereRole = ' WHERE UserRole.Name =: role_HeadOfHardverticals';
			for(User oneUser : Database.query(EBH_ConstantsUtility.SELECTUSER_BYROLE + whereRole)){
				lstUserEmail.add(oneUser.Email);
			}
			lstCCEmail.add(Label.Label_Dimanno_Isabella_Email);
			mEmailAddr.put('AU', new EmailByCountryWrap(lstUserEmail, lstCCEmail));

			// UK
			lstUserEmail = new List<String>();
			lstCCEmail = new List<String>();
			for(User oneUser : ApexUtil.getUsersMemberByGroup(new Set<String>{EBH_ConstantsUtility.GROUP_UKCOUPONAPPROVER}).values()){
				lstUserEmail.add(oneUser.Email);
			}
			mEmailAddr.put('UK', new EmailByCountryWrap(lstUserEmail, lstCCEmail));
		
			String couponSQL = EBH_ConstantsUtility.CPNSELLER_CPNCOINVSOQL + ' WHERE Id IN: sCpnId';
			List<Coupon__c> lstCoupon = Database.query(couponSQL);
			for(Coupon__c oneCpn : lstCoupon){
				EmailTemplate emailTempl = mEmailTempl.get(oneCpn.Contract_Language__c + EBH_ConstantsUtility.CPN_APPR_EMAILNOTIFI_TO_CAT_GROW_MANGR_EMAILTEMPLATE);
				if(emailTempl == null) continue;

				String subject = emailTempl.Subject.replace('{!Coupon__c.Coupon_ID__c}', oneCpn.Coupon_ID__c).replace('{!Coupon__c.Marketing_Coupon_Name__c}', oneCpn.Marketing_Coupon_Name__c);
				
				// Prepare Email
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				String tblRows = '';
				String htmlBody = '';
				EmailByCountryWrap emWr = mEmailAddr.get(oneCpn.Contract_Language__c);
				
				if(oneCpn.Contract_Language__c == 'AU'){
					// add CC Coupon Owner to CC emaillist
					emWr.lstCCEmail.add(oneCpn.Owner.Email);
				}

				// set table row
				for(Coupon_Co_Invest__c oneCpnCoInv : oneCpn.Coupon_Co_Invests__r){
					tblRows += mergeCouponCoInvRows(oneCpnCoInv, oneCpn.Contract_Language__c);
				}
				// set email body
				htmlBody = mergeCpnNegoEmailTemplateBody(emailTempl.HtmlValue, oneCpn).replace('{!RecordRows}', tblRows);
				
				mail.setToAddresses(emWr.lstUserEmail);
				if(!emWr.lstCCEmail.isEmpty()){
					mail.setCCAddresses(emWr.lstCCEmail);
				}
				//mail.setSenderDisplayName('Hive Support');
				mail.setSubject(subject);
				mail.setBccSender(false);
				mail.setUseSignature(false); 
				mail.setHtmlBody(htmlBody);
				//TH: 20/10/2020: US-0008543 - Set OrgWideDefault Address
				String replyto = oneCpn.Owner.Email;
				CouponSellerTriggerHandler.setOrgWideAddress(mail,replyto,System.label.OWD_MKT_REP);
				//End US-0008543
				listEmail.add(mail);
			}
			
			if(!listEmail.isEmpty() && !Test.isRunningTest()) Messaging.sendEmail(listEmail);
		}
    }

	/*****************************************************************************************************************************
    @ Method	:   checkNegotiationEndDateIsChange
    @ Version	:   1.0
    @ Author	: 	Acmatac SEING (acmatac.seing@gaea-sys.com)
    @ Purpose	:	To retrigger the workflow : AU Coupon Approval Email Notification
    @ Trigger 	: 	after updated
	@ Param 	: 	Map<Id, Coupon__c> mOldnCoupon, Map<Id, Coupon__c> mNewCoupon	
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 12.10.2019 / Acmatac SEING / Method Creation
    *****************************************************************************************************************************/
    public static void checkNegotiationEndDateIsChange(Map<Id, Coupon__c> mOldnCoupon, Map<Id, Coupon__c> mNewCoupon){
		List<Coupon__c> lstCpn = new List<Coupon__c>();
		Set<Id> sCpnId = new Set<Id>();
		for(Id cpnId : mOldnCoupon.keySet()){
			Coupon__c oldCpn = mOldnCoupon.get(cpnId);
			Coupon__c newCpn = mNewCoupon.get(cpnId);
			if(newCpn.Negotiation_End_Date__c != null && oldCpn.Negotiation_End_Date__c != newCpn.Negotiation_End_Date__c){
				lstCpn.add(new Coupon__c(Id=oldCpn.Id, CheckNegotiationEndDate__c=false));
				sCpnId.add(oldCpn.Id);
			}
		}
		if(!lstCpn.isEmpty()){
			update lstCpn;
			updateCoupon_CheckNegotiationEndDate_Asyn(sCpnId);
		}
	}

	private static String mergeCpnNegoEmailTemplateBody(String str, Coupon__c c)
 	{
		String cpnDisc = getObjectValue(c.Coupon_Discount__c) != '' ? getObjectValue(c.Coupon_Discount__c) : '0';
		String gmvTarg = getObjectValue(c.Coupon_GMV_Target__c) != '' ? getObjectValue(c.Coupon_GMV_Target__c) : '0';
		String cpnCap = getObjectValue(c.Coupon_Cap__c) != '' ? getObjectValue(c.Coupon_Cap__c) : '0';
		String cpnMaxRedeem = getObjectValue(c.Max_Redemptions__c) != '' ? getObjectValue(c.Max_Redemptions__c) : '0';
 		return str==null?'':str
			.replace('{!Coupon__c.Coupon_ID__c}',getObjectValue(c.Coupon_ID__c))
			.replace('{!Coupon__c.Marketing_Coupon_Name__c}',getObjectValue(c.Marketing_Coupon_Name__c))
			.replace('{!Coupon__c.Coupon_Start_Date__c}',(c.Coupon_Start_Date__c == null ? '':c.Coupon_Start_Date__c.format()))
			.replace('{!Coupon__c.Coupon_End_Date__c}',(c.Coupon_End_Date__c == null ? '':c.Coupon_End_Date__c.format()))
			.replace('{!Coupon__c.Contract_Due_Date__c}',(c.Contract_Due_Date__c == null ? '':c.Contract_Due_Date__c.format()))
			.replace('{!Coupon__c.Coupon_Discount__c}',cpnDisc)
			.replace('{!Coupon__c.Coupon_GMV_Target__c}',gmvTarg)
			.replace('{!Coupon__c.Coupon_Cap__c}',cpnCap)
			.replace('{!Coupon__c.Max_Redemptions__c}',cpnMaxRedeem)
 			.replace('{!Coupon__c.Link}','<a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/r/Coupon__c/'+c.Id+'/view" target="_blank">'+ c.Coupon_ID__c +'</a>');
	}

	private static String mergeCouponCoInvRows(Coupon_Co_Invest__c oneCpnCoInv, String countryLang)
	{
		List<String> lstFields = new List<String>();

		String oracleId = getObjectValue(oneCpnCoInv.Coupon_Seller__r.Oracle_ID__c);
		String sellerName = getObjectValue(oneCpnCoInv.Coupon_Seller__r.Seller__r.Name);
		String categoryName = getObjectValue(oneCpnCoInv.Coupon_Category__r.Category__r.Name);
		String sellerFunding = String.isNotBlank(getObjectValue(oneCpnCoInv.Seller_Funding__c)) ? getObjectValue(oneCpnCoInv.Seller_Funding__c) : '0';
		String couponSellerRec = '<a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/r/Coupon_Seller__c/'+oneCpnCoInv.Coupon_Seller__c+'/view" target="_blank">'+ oneCpnCoInv.Coupon_Seller__r.Name +'</a>';
		String couponSellerOwner = getObjectValue(oneCpnCoInv.Coupon_Seller__r.EBH_CouponSellerOwner__r.Name);
		String status = getObjectValue(oneCpnCoInv.Coupon_Seller__r.Coupon_Seller_Stage__c);
		String sellerShare = String.isNotBlank(getObjectValue(oneCpnCoInv.Co_Invest__c)) ? getObjectValue(oneCpnCoInv.Co_Invest__c) : '0';
		String ebayFunding = getObjectValue(oneCpnCoInv.eBayFunding__c);
		if(String.isBlank(ebayFunding)){
			ebayFunding = '0';
		}else{
			// to show as percentage
			ebayFunding = '' + Decimal.valueOf(ebayFunding) * 100;
		}
	
		if(countryLang == 'AU'){
			lstFields.add(oracleId);
			lstFields.add(sellerName);
			lstFields.add(categoryName);
			lstFields.add(sellerFunding);
			lstFields.add(ebayFunding);
			lstFields.add(sellerShare+'%');

		}else if(countryLang == 'UK'){
			lstFields.add(oracleId);
			lstFields.add(sellerName);
			lstFields.add(couponSellerRec);
			lstFields.add(couponSellerOwner);
			lstFields.add(status);
			lstFields.add(categoryName);
			lstFields.add(sellerShare+'%');
		}
		
		String result = '';
		for(String oneF : lstFields){
			result += CAP_ROWHTML.replace('{!fieldValue}', oneF);
		}

		return '<tr>'+ result +'</tr>\n';
	}

	// // UK
	// private static String mergeCouponCoInvRowsUK(Coupon_Co_Invest__c oneCpnCoInv)
	// {
	// 	String oracleId = getObjectValue(oneCpnCoInv.Coupon_Seller__r.Oracle_ID__c);
	// 	String sellerName = getObjectValue(oneCpnCoInv.Coupon_Seller__r.Seller__r.Name);
	// 	String categoryName = getObjectValue(oneCpnCoInv.Coupon_Category__r.Category__r.Name);
	// 	String couponSellerRec = '<a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/r/Coupon_Seller__c/'+oneCpnCoInv.Coupon_Seller__c+'/view" target="_blank">'+ oneCpnCoInv.Coupon_Seller__r.Name +'</a>';
	// 	String couponSellerOwner = getObjectValue(oneCpnCoInv.Coupon_Seller__r.EBH_CouponSellerOwner__r.Name);
	// 	String status = getObjectValue(oneCpnCoInv.Coupon_Seller__r.Coupon_Seller_Stage__c);
	// 	String sellerShare = String.isNotBlank(getObjectValue(oneCpnCoInv.Co_Invest__c)) ? getObjectValue(oneCpnCoInv.Co_Invest__c) : '0';
	// 	String rowHtm = ' <td style="text-align:#TextAlignPosition;vertical-align:top;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:black;">';
	// 	return  '<tr>' +
	// 		rowHtm.replace('#TextAlignPosition', 'left') + oracleId +'</td> ' +
	// 		rowHtm.replace('#TextAlignPosition', 'left') + sellerName +'</td> ' +
	// 		rowHtm.replace('#TextAlignPosition', 'left') + couponSellerRec +'</td> ' +
	// 		rowHtm.replace('#TextAlignPosition', 'left') + couponSellerOwner +'</td> ' +
	// 		rowHtm.replace('#TextAlignPosition', 'left') + status +'</td> ' +
	// 		rowHtm.replace('#TextAlignPosition', 'left') + categoryName +'</td> ' +
	// 		rowHtm.replace('#TextAlignPosition', 'right') + sellerShare +'%</td> ' +
	// 		'</tr>'+'\n';
	// 	// .replace('{!Coupon__c.Link}',URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/r/Coupon__c/'+c.Id+'/view');
	// }

	// To retrigger the workflow timebased : AU Coupon Approval Email Notification
	@future
    private static void updateCoupon_CheckNegotiationEndDate_Asyn(Set<Id> sCpnId)
    {   
        List<Coupon__c> lstCpn = new List<Coupon__c>();
		for(Id cpnId : sCpnId){
			lstCpn.add(new Coupon__c(Id=cpnId, CheckNegotiationEndDate__c=true));
		}
		if(!lstCpn.isEmpty()){
			update lstCpn;
		}
	}
	
	private class EmailByCountryWrap{
		List<String> lstUserEmail;
		List<String> lstCCEmail;
		public EmailByCountryWrap(List<String> lstUserEmail, List<String> lstCCEmail){
			this.lstUserEmail = lstUserEmail;
			this.lstCCEmail = lstCCEmail;
		}
	}

	/*****************************************************************************************************************************
    @ Method	:   changeStage
    @ Version	:   1.0
    @ Author	: 	Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose	:	US-0011385 - External Sharing for Coupon Category/ Category Tree, And for any other stage change.
    @ Trigger 	: 	after update
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 11.03.2022 / Sophal Noch / Create Method
	                  30.6.2022 / Sambath Seng / US-0011998 - Business Feedback Focus 75 AC3
    *****************************************************************************************************************************/
	public static void changeStage(List<Coupon__c> newCoupon, Map<Id, Coupon__c> mOldnCoupon){

		RecordType cpnRTypeItemBase = ApexUtil.getRecordTypeByName(COUPON_OBJNAME,COUPON_ITEMBASE_STAGE);
		Set<Id> setSellerNegoCpnItemId= new Set<Id>();
		Set<Id> setSellerNegoDECpnId= new Set<Id>();
		for(Coupon__c cpn : newCoupon){
			if(cpn.Stage__c == COUPON_SELLER_NEGOTIATION_STAGE && cpn.Stage__c != mOldnCoupon.get(cpn.Id).Stage__c){
				if(cpn.RecordTypeId == cpnRTypeItemBase.Id) setSellerNegoCpnItemId.add(cpn.Id);
				if(cpn.Main_Coupon_Site__c == COUPON_SITE_DE) setSellerNegoDECpnId.add(cpn.Id);//Start SB 30.6.2022 US-0011998 - Business Feedback Focus 75 AC3
			}
		}

		if(!setSellerNegoCpnItemId.isEmpty()){
			List<Coupon_Category__c> listCpnCate = [Select Id From Coupon_Category__c Where Coupon__c In: setSellerNegoCpnItemId And Is_Visible_in_Seller_Portal__c = false];
			if(!listCpnCate.isEmpty()){
				for(Coupon_Category__c cpnCate : listCpnCate){
					cpnCate.Is_Visible_in_Seller_Portal__c = true; // Coupon_Category__c criteria-sharing rule will share the record to public group "DE - Seller Portal".
				}
				update listCpnCate;
			}
		}
		//Start SB 30.6.2022 US-0011998 - Business Feedback Focus 75 AC3
		if(!setSellerNegoDECpnId.isEmpty()){
			List<Coupon_Seller__c> lstCS = [Select Id From Coupon_Seller__c Where Coupon__c In:setSellerNegoDECpnId];
			if(!lstCS.isEmpty()){
				for(Coupon_Seller__c ocs : lstCS){
					ocs.Coupon_Seller_Stage__c = CS_STAGE_REACHED;
				}
				update lstCS;
			}
		}
		//End SB 30.6.2022 US-0011998 - Business Feedback Focus 75 AC3

	}

	/*****************************************************************************************************************************
    @ Method	:   syncCouponInfo2CouponSellers
    @ Version	:   1.0
    @ Author	: 	Mony Nou (mony.nou@gaea-sys.com)
    @ Purpose	:	US-0010785 - Refactor Coupon Seller object to support standard search (AC3)
	@					- Sync value from Coupon's fields to all it associated Coupon Seller's fields 
    @ Trigger 	: 	after update
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 27.06.2022 / Mony Nou/ Create Method
    *****************************************************************************************************************************/
	public static void syncCouponInfo2CouponSellers(Map<Id, Coupon__c> newMap, Map<Id, Coupon__c> oldMap) {

		Set<Id> sCouponId2Sync = new Set<Id>();

		for (Coupon__c cp : newMap.values()) {

			if (cp.Marketing_Coupon_Name__c != oldMap.get(cp.Id).Marketing_Coupon_Name__c || cp.Coupon_ID__c != oldMap.get(cp.Id).Coupon_ID__c) {
				sCouponId2Sync.add(cp.Id);
			}

			
		}

		if (sCouponId2Sync.isEmpty()) return;

		List<Coupon_Seller__c> lstCS2Update = new List<Coupon_Seller__c>();

		RecordType cpnRTypeCateBase = ApexUtil.getRecordTypeByName(COUPON_OBJNAME,COUPON_CATEGORYBASE);
		RecordType cpnRTypeItemBase = ApexUtil.getRecordTypeByName(COUPON_OBJNAME,COUPON_ITEMBASE);

		Set<Id> sValidRT = new Set<Id> {cpnRTypeCateBase.Id, cpnRTypeItemBase.Id}; 
		Set<String> sValidStage = new Set<String>{ CS_STAGE_TARGETED, CS_STAGE_REACHED, CS_STAGE_COMMITED, CS_STAGE_NEGOTIATION, CS_STAGE_APPROVED, CS_STAGE_REVIEW, CS_STAGE_CONTRACTSEND, CS_STAGE_CONTRACTSIGNED };

		for (Coupon_Seller__c cs : [SELECT Coupon__c FROM Coupon_Seller__c WHERE Coupon__c IN:sCouponId2Sync AND Coupon__r.RecordTypeId IN:sValidRT 
										AND Coupon_Seller_Stage__c IN:sValidStage 
										AND Seller__c IN (SELECT AccountId FROM Contact WHERE Community_User__c != NULL AND Active_Community_User__c = TRUE)]) {
			
			Coupon__c cp = newMap.get(cs.Coupon__c);

			cs.Coupon_Marketing_Name__c = cp.Marketing_Coupon_Name__c;
			cs.Coupon_Code__c = cp.Coupon_ID__c;

			lstCS2Update.add(cs);
		}

		if (!lstCS2Update.isEmpty()) Database.update(lstCS2Update, false);
		
	}

}