/*********************************************************************************************************************************
@ Class:          SEPDownloadController
@ Version:        1.0
@ Author:         Loumang SENG (loumang.seng@gaea-sys.com)
@ Purpose:        Controller vf page: SEPDownloadPage
                  US-0010534 - Downloadable item list in .xls file from portal
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 14.06.2022 / Loumang SENG / Created the class.
                  22.06.2o22 / Sambath Seng / US-0010429 - Ability to sign Agreement in portal
                  25.07.2022 / Mony Nou / US-0012015 - NA Localization for Coupon Contract
*********************************************************************************************************************************/
public with sharing class SEPDownloadController {
    public string currentUser{get;set;}
    public string currentDate{get;set;}
    public List<Coupon_Co_Invest__c> coInvests {get;set;}
    public CouponSellerWrapper cs {get;set;}
    private final static String RT_COUPON_CO_INVEST_ITEM = 'Coupon_Co_Invest_Item';
    private final static String DF_DD_MM_YYYY = 'dd/MM/yyyy';
    private final static String SOQL_COUPONCOINVEST = 'select Item_ID__c,Item_Title__c,Category__c, Coupon_Seller__c, Co_Invest__c, Category_ID__c, Coupon_Category__r.Name from Coupon_Co_Invest__c';
    public string xmlheader{ get{return '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';}}
    private final static String SOQL_COUPONCATEGORY = 'select Id,Name from Coupon_Category__c';

    public SEPDownloadController(){
        String csId = String.escapeSingleQuotes(String.isBlank(ApexPages.currentPage().getParameters().get('id')) ? '': ApexPages.currentPage().getParameters().get('id'));
        currentUser = UserInfo.getUserName();
        currentDate = Datetime.now().format(DF_DD_MM_YYYY);
        if(String.isNotBlank(csId)){
            cs = new CouponSellerWrapper(SEPCouponController.getCS(csId));
            coInvests = getCouponCoInvestItems(csId);
        }       
    }
  
    /*********************************************************************************************************************************
    @ method:         getCouponCoInvestItems
    @ Version:        1.0
    @ Author:         Loumang SENG (loumang.seng@gaea-sys.com)
    @ Purpose:        US-0010534 - Downloadable item list in .xls file from portal
    @ Parameter:      String csId
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 14.06.2022 / Loumang SENG / Created the method.
    *********************************************************************************************************************************/
    public static List<Coupon_Co_Invest__c> getCouponCoInvestItems(String csId){
        return Database.query(SOQL_COUPONCOINVEST+' Where RecordType.DeveloperName=:RT_COUPON_CO_INVEST_ITEM AND Coupon_Seller__c =:csId');
    }

    /*********************************************************************************************************************************
    @ Class:          CouponSellerWrapper
    @ Version:        1.0
    @ Author:         Loumang SENG (loumang.seng@gaea-sys.com)
    @ Purpose:        Reduce coding to mapping coupon seller fields for SEPDownloadController and SEPCouponController
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 14.06.2022 / Loumang SENG / Created the class.
                      22.06.2o22 / Sambath Seng / US-0010429 - Ability to sign Agreement in portal
                      25.07.2022 / Mony Nou / US-0012015 - NA Localization for Coupon Contract
    *********************************************************************************************************************************/
    public class CouponSellerWrapper {
        public String maxRedmeptions{get;set;}
        public DateTime couponStartDate{get;set;}
        public DateTime couponEndDate{get;set;}
        public String legalEntity{get;set;}
        public String streetName{get;set;}
        public String zip{get;set;}
        public String city{get;set;}
        public String country{get;set;}
        public String eBaySellerID{get;set;}
        public String couponSites{get;set;}
        public String couponCode{get;set;}
        public String formatcouponStartDate{get;set;}
        public String formatcouponEndDate{get;set;}
        public String couponStartTime{get;set;}
        public String couponEndTime{get;set;}
        // public String couponDiscount{get;set;}
        public String marketingName{get;set;}
        public String minTransactionVal{get;set;}
        public String maxDisc{get;set;}
        public String additionalArrangement{get;set;}
        // public String couponDiscountAmount{get;set;}
        public String couponName{get;set;}
        public String couponDiscountAndDiscountAmount{get;set;}

        public String sellerShareHolder {get;set;} //MN-25072022-US-0012015
        public String eBayCofundMax {get;set;} //MN-25072022-US-0012015


        public CouponSellerWrapper(Coupon_Seller__c cs){
            couponName = cs.Name;
            couponCode = ApexUtil.checkNull(cs.Coupon_ID__c)+'';//LA-29-06-2022: US-0010429
            couponStartDate = Datetime.newInstance(cs.Coupon_Start_Date__c.Year(),cs.Coupon_Start_Date__c.Month(),cs.Coupon_Start_Date__c.Day());
		    couponEndDate = Datetime.newInstance(cs.Coupon_End_Date__c.Year(),cs.Coupon_End_Date__c.Month(),cs.Coupon_End_Date__c.Day());
            maxRedmeptions = cs.Max_Redemptions__c==null?'N/A':ApexUtil.formatNumber(cs.Max_Redemptions__c,0,cs.Contract_Language__c);//SB 22.6.2022 US-0010429 - Ability to sign Agreement in portal
            legalEntity = ApexUtil.checkNull(cs.Legal_Entity_Name_w__c)+'';
            streetName = ApexUtil.checkNull(cs.Legal_Entity_Street_w__c)+'';
            zip = ApexUtil.checkNull(cs.Legal_Entity_Zip_w__c)+'';
            city = ApexUtil.checkNull(cs.Legal_Entity_City__c)+'';
            eBaySellerID = cs.Seller__r.Name;
            couponSites = ApexUtil.checkNull(cs.Coupon_Site__c)+'';
            couponStartTime = ApexUtil.formatTime(cs.Coupon_Start_Time__c);
            formatcouponStartDate = couponStartDate == null ? '' : couponStartDate.format(DF_DD_MM_YYYY);
            couponEndTime = ApexUtil.formatTime(cs.Coupon_End_Time__c);
            formatcouponEndDate = couponEndDate == null ? '' : couponEndDate.format(DF_DD_MM_YYYY);
            // couponDiscount = cs.SP_Coupon_Discount_Rate__c==null?'':ApexUtil.formatNumber(cs.SP_Coupon_Discount_Rate__c,2,cs.Contract_Language__c)+'%';//SB 22.6.2022 US-0010429 - Ability to sign Agreement in portal
            // couponDiscountAmount = cs.Coupon_Discount_Amount__c==null?'':ApexUtil.mapCurrencySign.get(cs.CurrencyIsoCode)+ApexUtil.formatNumber(cs.Coupon_Discount_Amount__c,3,cs.Contract_Language__c);//SB 22.6.2022 US-0010429 - Ability to sign Agreement in portal
            //LA-05-07-2022-US-0011917: chnge formula field type number to percentage for field 'Coupon Discount (%)' and update mappingg field from(cs.SP_Coupon_Discount_Rate__c*100) to cs.SP_Coupon_Discount_Rate__c
            couponDiscountAndDiscountAmount = (cs.SP_Coupon_Discount_Rate__c==null && cs.Coupon_Discount_Amount__c==null)?'N/A':(cs.SP_Coupon_Discount_Rate__c==null?ApexUtil.mapCurrencySign.get(cs.CurrencyIsoCode)+ApexUtil.formatNumber(cs.Coupon_Discount_Amount__c,2,cs.Contract_Language__c):ApexUtil.formatNumber(cs.SP_Coupon_Discount_Rate__c,2,cs.Contract_Language__c)+'%');//SB 27.6.2022 US-0010429 - Ability to sign Agreement in portal 
            maxDisc = cs.Maximum_Discount_Value__c ==null?'N/A':ApexUtil.mapCurrencySign.get(cs.CurrencyIsoCode)+ApexUtil.formatNumber(cs.Maximum_Discount_Value__c ,2,cs.Contract_Language__c);
            additionalArrangement = cs.Additional_Terms__c==null?'':cs.Additional_Terms__c;
            marketingName = ApexUtil.checkNull(cs.Marketing_Coupon_Name__c)+'';
            minTransactionVal = cs.Min_Transaction_Value__c==null?'N/A':ApexUtil.mapCurrencySign.get(cs.CurrencyIsoCode)+ApexUtil.formatNumber(cs.Min_Transaction_Value__c,2,cs.Contract_Language__c);
            country = ApexUtil.checkNull(cs.Legal_Entity_Country__c)+'';
            
            //MN-25072022-US-0012015
            sellerShareHolder = (cs.SellerShareHolder__c==null)?'N/A':ApexUtil.formatNumber(cs.SellerShareHolder__c,2,cs.Contract_Language__c)+'%';
            eBayCofundMax = (cs.eBay_Co_fund_Max__c==null)?'N/A':ApexUtil.formatNumber(cs.eBay_Co_fund_Max__c,2,cs.Contract_Language__c);
            
        }
    }

    /*********************************************************************************************************************************
    @ method:         getDownloadExcel
    @ Version:        1.0
    @ Author:         Loumang SENG (loumang.seng@gaea-sys.com)
    @ Purpose:        US-0010534 - Downloadable item list in .xls file from portal
    @ Parameter:      String csId
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 14.06.2022 / Loumang SENG / Created the method.
    *********************************************************************************************************************************/
    @AuraEnabled
    public static String getDownloadExcel(String csId) {
        PageReference xlsGenerater = new PageReference('/apex/SEPDownloadPage');
        xlsGenerater.getParameters().put('id',csId);
        return  EncodingUtil.base64encode(!Test.isRunningTest() ? xlsGenerater.getContent() : Blob.valueOf('test'));
    }
    
}