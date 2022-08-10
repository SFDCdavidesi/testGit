/*********************************************************************************************************************************
@ Class:          DD_RetailWeekSpreadsheetController
@ Version:        1.0
@ Author:         Mony Nou (mony.nou@gaea-sys.com)
@ Purpose:        US-0009853 - [SEP] Email notification to Seller when Deal Window is Scheduled
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 20.07.2021 / Mony Nou / Created the class.
*********************************************************************************************************************************/
public without sharing class DD_RetailWeekSpreadsheetController {

    public string xmlheader         {get;set;}
    public string contentType       {get;set;}
    public List<DealWrapper> deals  {get;set;}

    private EBH_SpotlightCategory__c default_spotlight_cate;
    
    private final static string DEAL_STATUS_SCHEDULED = 'Scheduled';
    private final static string DEAL_STATUS_CMREVIEW  = 'CM Review';
    
    
    

    public DD_RetailWeekSpreadsheetController() {

        //VF page gives some issues directly using the below code there, so wrap up in variable    
        xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';

        String param_dwid = ''; //Deal Window Id
        String param_scid = ''; //Seller Contact Id
        String param_dwrw = ''; //Deal Window Retail Week

        if (Apexpages.currentPage().getParameters().containsKey('dwid'))  param_dwid = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('dwid')); 
        if (Apexpages.currentPage().getParameters().containsKey('scid'))  param_scid = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('scid')); 
        if (Apexpages.currentPage().getParameters().containsKey('dwrw')) param_dwrw = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('dwrw')); 

        contentType = 'application/vnd.ms-excel#eBay Daily Deals Retail Week ' + param_dwrw + '.xls;charset=UTF-8'; 

        //MN-22072021-US-0009685-get defualt Spotlight Category if field Spotlight Category == null
        default_spotlight_cate = new EBH_SpotlightCategory__c();
        for(EBH_SpotlightCategory__c spl: [SELECT Name FROM EBH_SpotlightCategory__c WHERE Name = :Label.US_UnSubDeal_Default_Spotlight limit 1]){ default_spotlight_cate = spl; }

        deals = new List<DealWrapper>();
        if (String.isNotBlank(param_dwid) && String.isNotBlank(param_scid)) {
            for (EBH_Deal__c d : [SELECT toLabel(EBH_DealSiteId__c) ds, EBH_DealSiteId__c, EBH_SpotlightCategory__c, EBH_SpotlightCategory__r.Name, EBH_BusinessName__c, eBay_Seller_Name__c, EBH_eBayItemID__c, EBH_DealPrice__c
                                        , EBH_RRPWASPrice__c, EBH_Quantity__c, EBH_MaximumPurchases__c, EBH_ProductTitle__c, EBH_Vertical__c, EBH_Category__c, Sub_Category__c
                                        , EBH_DealStartDate__c, EBH_DealStartTime__c, EBH_DealEndDate__c, EBH_DealEndTime__c, EBH_Status__c, Cancellation_Reason__c, EBH_ReasonforRejection__c, EBH_ReasonforRejectionextd__c
                                    FROM EBH_Deal__c WHERE EBH_DealRetailCampaign__c=:param_dwid AND Seller_Contact__c=:param_scid]) {

                DealWrapper dw = new DealWrapper(d);
                if (String.isNotBlank(d.EBH_DealSiteId__c)) d.EBH_DealSiteId__c = String.valueOf(d.get('ds'));
                if (d.EBH_Status__c == DEAL_STATUS_CMREVIEW && d.EBH_SpotlightCategory__c == null && String.isNotBlank(default_spotlight_cate.Name)) dw.spotlight_cate = default_spotlight_cate.Name;
                if (d.EBH_Status__c == DEAL_STATUS_CMREVIEW) d.EBH_Status__c = DEAL_STATUS_SCHEDULED;
                deals.add(dw);

            }
        }

    }

    public String currencyFormat{
        get{
            return '_("$"* #,##0.00_);_("$"* \\(#,##0.00\\);_("$"* "-"??_);_(@_)';
        }
    }

    public class DealWrapper {

        public EBH_Deal__c deal{get;set;}
        public String startDate {get;set;}
        public String endDate {get;set;}
        public DateTime startTime{get;set;}
        public DateTime endTime{get;set;}
        public String spotlight_cate {get;set;}

        public DealWrapper (EBH_Deal__c deal) {
            this.deal = deal;
            if(deal.EBH_DealStartDate__c!=null){
                this.startTime = DateTime.newInstance(deal.EBH_DealStartDate__c, deal.EBH_DealStartTime__c);
                this.startDate = this.startTime.format('MM/dd/yyyy');
            }
            if(deal.EBH_DealEndDate__c!=null){
                this.endTime = DateTime.newInstance(deal.EBH_DealEndDate__c, deal.EBH_DealEndTime__c);
                this.endDate = this.endTime.format('MM/dd/yyyy');
            }

            this.spotlight_cate = (deal.EBH_SpotlightCategory__c != null)?deal.EBH_SpotlightCategory__r.Name:'';
        }   
    }
}