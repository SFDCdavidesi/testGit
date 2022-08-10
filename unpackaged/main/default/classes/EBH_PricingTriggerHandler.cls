/*********************************************************************************************************************************
@ Class:          EBH_PricingTriggerHandler
@ Version:        1.0
@ Author:         NEHA LUND 
@ Purpose:        Handler Class for Pricing Trigger
                  EPH-6 : Contract Management
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 18.05.2017 / NEHA LUND / Created the class.
@ Change history: 24.05.2018 / David Herrero / Update method hasPricingMatrixChanged for taking in consideration when category changes
                  24.05.2018 / Neha Lund / Default FVF Cap to null before calculating it for metacategories
*********************************************************************************************************************************/

public without sharing class EBH_PricingTriggerHandler {
    
    public final static String PRICING_REC_P2 = 'Listing_Pricing_P2_0'; //NK:28/07/2020: US-0007883
    public static final String CONTRACT_LISTINGRECORDTYPE       = 'EBH_ListingAgreement';
    public static final String CONTRACT_ACPRECORDTYPE           = 'EBH_ACP';
    public static final String CONTRACT_RSRECORDTYPE            = 'EBH_RevenueShare';   
    
    public static final String CONTRACT_PRICINGCONTRACTQUERY 
    = ' SELECT StartDate,EndDate,id, EBH_ContractExposure__c,CurrencyISOCode,EBH_Site__c, EBH_AverageTakeRate__c, EBH_StoreSubscription__c, '
    + ' EBH_ContractValue__c, RecordType.DeveloperName, EBH_RebateTierrebate__c, EBH_RevenueShareRate__c, '
    + '(SELECT Id, EBH_GMVTarget__c ,CurrencyISOCode, EBH_ListingExposure__c, EBH_ListingValue__c, EBH_ACPValue__c, EBH_ACPExposure__c, '
    + ' EBH_RevenueExposure__c, EBH_PriorYearGMV__c, EBH_RevenueValue__c, EBH_StoreSubscription__c, '
    + ' EBH_Site__c, RecordType.DeveloperName '
    + ' FROM EBH_Pricing__r) from Contract where id IN :parents ';   

    public static final String CONTRACT_PARENTCHILDQUERY 
        = 'SELECT StartDate,EndDate,Id,EBH_RebateTierrebate__c, EBH_ContractExposure__c,CurrencyISOCODE,EBH_Site__c,EBH_IncrementalGMVonly__c, EBH_AverageTakeRate__c, '
        + 'EBH_StoreSubscription__c, EBH_ContractValue__c, RecordType.DeveloperName, EBH_OnBoardingFees__c, '
        + '(SELECT Id, CurrencyISOCode,EBH_GMVTarget__c , EBH_ListingExposure__c,  EBH_ListingValue__c, EBH_ACPValue__c, EBH_ACPExposure__c, '
        + ' EBH_RevenueExposure__c, EBH_RevenueValue__c, EBH_PriorYearGMV__c,  '
        + ' EBH_StoreSubscription__c, EBH_Site__c, RecordType.DeveloperName FROM EBH_Pricing__r'
        + ' ) '
        + 'FROM Contract WHERE Id IN: parentIds AND '
        + ' RecordTypeId IN (SELECT Id FROM RecordType WHERE DeveloperName=\''+CONTRACT_LISTINGRECORDTYPE+'\''
        + ' OR DeveloperName = \'' + CONTRACT_RSRECORDTYPE + '\''
        + ' OR DeveloperName = \'' + CONTRACT_ACPRECORDTYPE + '\')';  

    //To get the store subscription fees for each Site
   // static Map<String, EBH_SiteStoreSubscriptionFees__c> SubscriptionFees = new Map<String, EBH_SiteStoreSubscriptionFees__c>();
    static Map<String,EBH_ListingPricingExposure__c> exposureMap = new Map<String, EBH_ListingPricingExposure__c>();
    static EBH_CurrencyConverter  cConverter = new EBH_CurrencyConverter ();
    /*****************************************************************************************************************************
    @ Method:         updateCustomRollUp
    @ Version:        1.0
    @ Author:         NEHA LUND 
    @ Purpose:        Updates custom roll ups on Contract (record type: Listing Agreement) from all child Pricings of record Type 
                      Listing Agreement
                       - Contract Listing Value - Value + Store Subscription Fees (if subscription type is Free)
                       - Contract Exposure Value - Exposure + Store Subscription Fees (if subscription type is Non Free) 
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      Pricings:      Pricings from the trigger scope
                      PricingOldMap: Pricings old map from the trigger scope
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 08.12.2017 / NEHA LUND / Created the  Method.
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 06.09.2021 / Sophal Noch / Modified the  Method.
    *****************************************************************************************************************************/
    public static void updateCustomRollUp(List<EBH_Pricing__c> Pricings, Map<Id, EBH_Pricing__c> PricingOldMap) {        
        
        Set<Id> parentIds = new Set<Id>();    //distinct parent ids of the Pricings in trigger scope
        List<Contract> parents;               //list of distinct parents from parentIds
        
        for(EBH_Pricing__c con : Pricings) { 
            
            //get distinct parent ids from trigger scope Pricings and populate parentIds if any aggregate fields has changed
            if(hasRollupChanged(con, PricingOldMap)) {              
                
                Id pId = con.EBH_ContractId__c;
                
                if(!String.isBlank(pId)) {
                    parentIds.add(pId); 
                }
            }
            
            //if Contract is changed, then both old and new parents need to be updated
            if(hasParentChanged(con, PricingOldMap)){
                
                Id pId = PricingOldMap.get(con.id).EBH_ContractId__c;
                
                if(!String.isBlank(pId)) {
                    parentIds.add(pId); 
                }
            }
        }        
        
        
        //fetch the Contract & child Pricing records
        parents = Database.query(CONTRACT_PARENTCHILDQUERY);
        
        if( !parents.isEmpty() ){
            try {
                updateContractValueExposure(parents, true);
            } catch (DmlException ex) {
                // Sophal / 02.09.2021 / US-0010295 show cleaner error message by getting error message from exception and add to each pricing record.
                //DmlException dmlEx = new DmlException(ex.getDmlMessage(0));
                Map<Id,String> mapContIdToError = new Map<Id,String>();
                for(Integer i = 0; i < ex.getNumDml(); i++) {
                    mapContIdToError.put(ex.getDmlId(i), ex.getDmlMessage(i));
                }
                String defaultErr = ex.getMessage();
                for(EBH_Pricing__c pricing : Pricings){
                    String errToDisplay = mapContIdToError.get(pricing.EBH_ContractId__c);
                    errToDisplay = (errToDisplay != null && errToDisplay.contains(Label.ErrorInvalidSellerSignatoryContact)) ? errToDisplay : defaultErr;
                    pricing.addError(errToDisplay);
                }
            }
            

            
        }
        
     }
     
     /*****************************************************************************************************************************
    @ Method:         updatePricingCapDiscount
    @ Version:        1.0
    @ Author:         NEHA LUND 
    @ Purpose:        EPH-5008 : Reusable method for both Pricing & Contract two way synchronization
                      Updates custom roll ups on Contract (record type: Listing Agreement) from all child Pricings of record Type 
                      Listing Agreement
                       - Contract Listing Value - Value + Store Subscription Fees (if subscription type is Free)
                       - Contract Exposure Value - Exposure + Store Subscription Fees (if subscription type is Non Free) 
                       
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      Pricings:      Pricings from the trigger scope
                      PricingOldMap: Pricings old map from the trigger scope
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 09.11.2017 / NEHA LUND / Created the  Method.
    *****************************************************************************************************************************/
   
    public static void updateFFExposure( List<EBH_Pricing__c> pricings, Map<ID, EBH_Pricing__c> pricingMap ){
        
        EBH_ListingPricingExposure__c exposure = new EBH_ListingPricingExposure__c();
        Decimal exposureValue = 0;
        for(EBH_ListingPricingExposure__c lp: [SELECT Name, Id, CurrencyISOCODE,EBH_GalleryPlus__c , EBH_Store__c,
                                                EBH_InsertionFees__c , EBH_InternationalSiteVisibility__c ,
                                                EBH_PicturePack__c , EBH_Subtitle__c from 
                                                EBH_ListingPricingExposure__c]){
            exposureMap.put(lp.Name, lp);
        }
        
        for(EBH_Pricing__c con : pricings) { 
            
            
            exposureValue = 0;
            if( exposureMap.containsKey(con.EBH_Site__c)){
                exposure = exposureMap.get(con.EBH_Site__c);
               
                if( con.EBH_InsertionFees__c != null && con.EBH_InsertionFees__c == EBH_constantsUtility.PRICING_FREESUBSCRIPTION){
                    exposureValue += cconverter.convert(exposure.EBH_InsertionFees__C, exposure.CurrencyISOCOde, con.CurrencyISOCode);
                }
                
                if( con.EBH_InternationalSiteVisibility__c != null && con.EBH_InternationalSiteVisibility__c == EBH_constantsUtility.PRICING_FREESUBSCRIPTION){
                    exposureValue += cconverter.convert(exposure.EBH_InternationalSiteVisibility__c,  exposure.CurrencyISOCOde, con.CurrencyISOCode);
                }
                if( con.EBH_subTitle__c != null && con.EBH_Subtitle__c == EBH_constantsUtility.PRICING_FREESUBSCRIPTION){
                    exposureValue += cconverter.convert(exposure.EBH_Subtitle__C, exposure.CurrencyISOCOde, con.CurrencyISOCode);
                }
                if( con.EBH_GalleryPlus__c != null && con.EBH_GalleryPlus__c == EBH_constantsUtility.PRICING_FREESUBSCRIPTION){
                    exposureValue += cconverter.convert(exposure.EBH_GalleryPlus__C,exposure.CurrencyISOCOde, con.CurrencyISOCode);
                }
               
               con.EBH_FFExposure__c = exposureValue;
                
            }
        }    
        
    }
    
     /*****************************************************************************************************************************
    @ Method:         updatePricingCapDiscount
    @ Version:        1.0
    @ Author:         NEHA LUND 
    @ Purpose:        EPH-4178: Reusable method for both Pricing & Contract two way synchronization
                      Updates custom roll ups on Contract (record type: Listing Agreement) from all child Pricings of record Type 
                      Listing Agreement
                       - Contract Listing Value - Value + Store Subscription Fees (if subscription type is Free)
                       - Contract Exposure Value - Exposure + Store Subscription Fees (if subscription type is Non Free) 
                       
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      Pricings:      Pricings from the trigger scope
                      PricingOldMap: Pricings old map from the trigger scope
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 09.11.2017 / NEHA LUND / Created the  Method.
    *****************************************************************************************************************************/
   
    public static void updatePricingCapDiscount( List<EBH_Pricing__c> pricings, Map<ID, EBH_Pricing__c> pricingMap ){
        
            
            Set<ID> pricingIds = new Set<ID> ();
            
            for(EBH_Pricing__c con : Pricings) { 
            
                //get distinct parent ids from trigger scope Pricings and populate parentIds if any aggregate fields has changed
                if(hasPricingMatrixChanged(con, pricingMap)) {              
                     
                        pricingIds.add(con.EBH_ContractPricingMatrix__c);
                }
            }
            
            Map<ID, EBH_ContractPricingMatrix__c> pMatrixMap = new Map<ID, EBH_ContractPricingMatrix__c>
                    ([SELECT EBH_BusinessVerticalName__c, EBH_CAP__c,
                    EBH_Currency__c,currencyISOCode, EBH_FVF__c, EBH_ListingFormat__c, EBH_MetaCategoryL2__c, EBH_SiteCountry__c,
                    EBH_SiteID__c from EBH_ContractPricingMatrix__c where ID IN :pricingIds]);
                    
            
            EBH_ContractPricingMatrix__c pm = new EBH_ContractPricingMatrix__c();
            
            for(EBH_Pricing__c con : Pricings) { 
               
                //get distinct parent ids from trigger scope Pricings and populate parentIds if any aggregate fields has changed
                if(hasPricingMatrixChanged(con, pricingMap)) {              
                
                        //EPH-5858 : to default FVF cap to blank when related product category doesn't have any FVF cap
                        con.EBH_DefaultFVFCap__c = null;
                        
                        if(pMatrixMap.containsKey(con.EBH_ContractPricingMatrix__c)){
                            pm = pMatrixMap.get(con.EBH_ContractPricingMatrix__c);
                            if(pm.EBH_Cap__c != null)
                            con.EBH_DefaultFVFCap__c = cconverter.convert(pm.EBH_Cap__c,pMatrixMap.get(con.EBH_ContractPricingMatrix__c).CurrencyISOCode,con.CurrencyISOCode  );
                           
                            con.EBH_DefaultFVFDiscount__c = pm.EBH_FVF__c;
                        }
                }
            }
                    
        
    }
    
    /*****************************************************************************************************************************
    @ Method:         updateContractValueExposure
    @ Version:        1.0
    @ Author:         NEHA LUND 
    @ Purpose:        US-0017: Reusable method for both Pricing & Contract two way synchronization
                      Updates custom roll ups on Contract (record type: Listing Agreement) from all child Pricings of record Type 
                      Listing Agreement
                       - Contract Listing Value - Value + Store Subscription Fees (if subscription type is Free)
                       - Contract Exposure Value - Exposure + Store Subscription Fees (if subscription type is Non Free) 
                       
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      Pricings:      Pricings from the trigger scope
                      PricingOldMap: Pricings old map from the trigger scope
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 18.05.2017 / NEHA LUND / Created the  Method.
    @               : 26/04/2018/ Vadhanak Voun/ EPH-5479 Additional bolt-ons for Listing and ACP
    @                updated acp and listing to get new calculation
    @               : 28.07.2020/ Vadhanak Voun / US-0007883 - Contract P2.0 Value and Contract Exposure calculation for Listing Agreement contracts
    @               :10.11.2020/ Vadhanak Voun /US-0007957 - ST-002994 - Contract 2460: Exposure (Store Subscription and AM Bolt-ons) needs to be adjusted to 3 months period
    *****************************************************************************************************************************/   
    public static List<Contract> updateContractValueExposure( List<Contract> parents, boolean updateContracts ){
       
        List<EBH_Pricing__c> pricingList = new List<EBH_Pricing__c>();
       /* if(SubscriptionFees.isEmpty()) {
               
            //To keep Site as a key and Store Subscription Fee
            for( EBH_SiteStoreSubscriptionFees__c siteSubscription : EBH_SiteStoreSubscriptionFees__c.getAll().values()){
                   
                SubscriptionFees.put( siteSubscription.EBH_Site__c, siteSubscription );
            }
            
        }   */   
         for(EBH_ListingPricingExposure__c lp: [SELECT Name, CurrencyISOCode, Id,EBH_GalleryPlus__c  , 
                                                EBH_Store__c,
                                                EBH_InsertionFees__c, 
                                               EBH_InternationalSiteVisibility__c,
                                                 EBH_PicturePack__c , 
                                                EBH_Subtitle__c from 
                                                EBH_ListingPricingExposure__c]){
                                                    
            exposureMap.put(lp.Name, lp);
        } 
        //query Contract to get child Pricing records
        Map<ID, Contract> contractMap = new Map<ID, Contract>((List<Contract>)Database.query(CONTRACT_PRICINGCONTRACTQUERY));
        //EPH-4145
        Decimal boardingFees = 0;
        Decimal conversionRate = 1;
        
        //NK:26/04/2018
        Map<String,Contract_Fee__c> mapAllFee =  getMapContractFee();
        //parse through Parents        
        for(Contract contractRecord : parents) {
            Decimal valPeriod = calDatePeriod(contractRecord.StartDate,contractRecord.EndDate);
            //NK:26/04/2018 custom setting record exist and price <> null -> convert currency
            //EPH-5479 Additional bolt-ons for Listing and ACP
            Decimal ampBoltOnFee = (mapAllFee.get('AM_Bolt_on__c'+contractRecord.EBH_Site__c) <> null && mapAllFee.get('AM_Bolt_on__c'+contractRecord.EBH_Site__c).Price__c <> null)
                                ? cconverter.convert( mapAllFee.get('AM_Bolt_on__c'+contractRecord.EBH_Site__c).Price__c ,mapAllFee.get('AM_Bolt_on__c'+contractRecord.EBH_Site__c).CurrencyCode__c,  contractRecord.CurrencyISOCode):0;
            ampBoltOnFee    = ampBoltOnFee * valPeriod; //NK:10/11/2020:US-0007957

            Decimal subcriptionFeeNew = (mapAllFee.get('EBH_StoreSubscription__c'+contractRecord.EBH_Site__c+contractRecord.EBH_StoreSubscription__c) <> null && mapAllFee.get('EBH_StoreSubscription__c'+contractRecord.EBH_Site__c+contractRecord.EBH_StoreSubscription__c).Price__c <> null)
                                        ? cconverter.convert( mapAllFee.get('EBH_StoreSubscription__c'+contractRecord.EBH_Site__c+contractRecord.EBH_StoreSubscription__c).Price__c ,mapAllFee.get('EBH_StoreSubscription__c'+contractRecord.EBH_Site__c+contractRecord.EBH_StoreSubscription__c).CurrencyCode__c,  contractRecord.CurrencyISOCode):0;
            subcriptionFeeNew   = subcriptionFeeNew * valPeriod; //NK:10/11/2020:US-0007957
            //System.debug('>>>>>valPeriod: '+valPeriod+'   >ampBoltOnFee: '+ampBoltOnFee+'  subcriptionFeeNew>: '+subcriptionFeeNew);
            boardingFees = 0;
            if( contractRecord.EBH_OnBoardingFees__c != null ){
                boardingFees = contractRecord.EBH_OnBoardingFees__c;
            }
           
            Decimal storeFreeFees    
                    = contractRecord.EBH_StoreSubscription__c != null && contractRecord.EBH_StoreSubscription__c.equalsIgnoreCase(EBH_ConstantsUtility.PRICING_FREESUBSCRIPTION) && 
                      exposureMap.containsKey(contractRecord.EBH_Site__c) ? 
                      cconverter.convert(exposureMap.get(contractRecord.EBH_Site__c).EBH_Store__c, exposureMap.get(contractRecord.EBH_Site__c).CurrencyISOCode, contractRecord.CurrencyISOCode ): EBH_ConstantsUtility.STORE_FEES;
                
            Decimal storeNonFreeFees 
                    = contractRecord.EBH_StoreSubscription__c!= null && contractRecord.EBH_StoreSubscription__c.equalsIgnoreCase(EBH_ConstantsUtility.PRICING_NONFREESUBSCRIPTION) && 
                      exposureMap.containsKey(contractRecord.EBH_Site__c)? 
                      cconverter.convert(exposureMap.get(contractRecord.EBH_Site__c).EBH_Store__c,exposureMap.get(contractRecord.EBH_Site__c).CurrencyISOCode,  contractRecord.CurrencyISOCode): EBH_ConstantsUtility.STORE_FEES;
                
            
            contractRecord.EBH_ContractValue__c = contractRecord.EBH_ContractExposure__c = EBH_ConstantsUtility.STORE_FEES;
            //NK:26/04/2018: acp and listing
            if( contractMap.get(contractRecord.id).RecordType.DeveloperName.equalsIgnoreCase(EBH_ConstantsUtility.CONTRACT_LISTINGRECORDTYPE)
            || contractMap.get(contractRecord.id).RecordType.DeveloperName.equalsIgnoreCase(EBH_ConstantsUtility.CONTRACT_ACPRECORDTYPE) 
            ){        
                //reset the roll ups
                contractRecord.EBH_ContractValue__c    = (contractRecord.AM_Bolt_on__c == EBH_ConstantsUtility.CONTRACT_AMBOLT_STANDARD ? ampBoltOnFee : 0);
                contractRecord.EBH_ContractExposure__c = (contractRecord.EBH_StoreSubscription__c <>EBH_ConstantsUtility.CONTRACT_AMBOLT_STANDARD? 
                                                        subcriptionFeeNew:0) + (contractRecord.AM_Bolt_on__c==EBH_ConstantsUtility.CONTRACT_AMBOLT_FREE? ampBoltOnFee:0);
            }
            else if(contractMap.get(contractRecord.id).RecordType.DeveloperName.equalsIgnoreCase(EBH_ConstantsUtility.CONTRACT_RSRECORDTYPE) ){
                contractRecord.EBH_ContractValue__c = contractRecord.EBH_ContractExposure__c = boardingFees;
             
            }else{
                contractRecord.EBH_ContractExposure__c = storeFreeFees;
            }
            
            //System.debug('#####'+storeNonFreeFees);
            //aggregate from child Pricings, if context is Contract Trigger then use the Contract Map
            //if Context of execution is Pricing Trigger then use the contractRecord
            pricingList = updateContracts ? contractRecord.EBH_Pricing__r: contractMap.get(contractRecord.id).EBH_Pricing__r;
             
            //parse through Pricing Records
            for(EBH_Pricing__c pricing : pricingList) {
                
                //Pricing RecordType Listing
                if(pricing.RecordType.DeveloperName == EBH_ConstantsUtility.PRICING_LISTINGRECORDTYPE || pricing.RecordType.DeveloperName == PRICING_REC_P2) { //NK:28/07/2020: US-0007883
                    
                  
                    //aggregate and populate roll ups at parent
                    contractRecord.EBH_ContractValue__c    
                        += pricing.EBH_ListingValue__c != Null ?
                           cconverter.convert(pricing.EBH_ListingValue__c, pricing.currencyISOCode,contractRecord.currencyISOCode )
                           : EBH_ConstantsUtility.STORE_FEES;
                   
                    contractRecord.EBH_ContractExposure__c 
                        += pricing.EBH_ListingExposure__c != Null ? 
                           cconverter.convert(pricing.EBH_ListingExposure__c , pricing.currencyISOCode,contractRecord.currencyISOCode): EBH_ConstantsUtility.STORE_FEES;
                }
                //Pricing RecordType ACP Target
                else
                if(pricing.RecordType.DeveloperName == EBH_ConstantsUtility.PRICING_ACPTARGETRECORDTYPE ){
                  
                    //aggregate and populate roll ups at parent
                    contractRecord.EBH_ContractValue__c    
                        += pricing.EBH_GMVTarget__c != null && contractRecord.EBH_AverageTakeRate__c != Null ?
                          cconverter.convert( (pricing.EBH_GMVTarget__c * contractRecord.EBH_AverageTakeRate__c)/100 , pricing.currencyISOCode,contractRecord.currencyISOCode) 
                          : 0;
                    
                    
                   /*contractRecord.EBH_ContractExposure__c 
                        += pricing.EBH_GMVTarget__c!= null && contractRecord.EBH_AverageTakeRate__c!= null && contractRecord.EBH_RebateTierrebate__c != null? 
                       cconverter.convert(  (pricing.EBH_GMVTarget__c * contractRecord.EBH_AverageTakeRate__c * contractRecord.EBH_RebateTierrebate__c)/10000, pricing.currencyISOCode,contractRecord.currencyISOCode) : 0;
                    */
                    
                    //Updated: LA/07-04-2021/US-0009303
                    
                    Decimal contractExposure = 0;

                    if(pricing.EBH_GMVTarget__c!= null && contractRecord.EBH_AverageTakeRate__c!= null && contractRecord.EBH_RebateTierrebate__c != null){

                        Decimal contrPrice;
                        if(contractRecord.VolumeBasedDiscount__c){
                            contrPrice = ( pricing.EBH_GMVTarget__c * contractRecord.EBH_AverageTakeRate__c * contractRecord.EBH_RebateTierrebate__c * (1-(contractRecord.VolumeDiscounts__c==null?0:contractRecord.VolumeDiscounts__c/100)));
                        }else{
                            contrPrice = pricing.EBH_GMVTarget__c * contractRecord.EBH_AverageTakeRate__c * contractRecord.EBH_RebateTierrebate__c;
                        }
                        contractExposure = cconverter.convert( contrPrice/10000, pricing.currencyISOCode, contractRecord.currencyISOCode);

                    }
                    contractRecord.EBH_ContractExposure__c += contractExposure;
                    //System.debug('contractRecord.EBH_ContractExposure__c::::'+contractRecord.EBH_ContractExposure__c); 
                 }
                //Pricing RecordType Revenue Share Target
                else
                if(pricing.RecordType.DeveloperName == EBH_ConstantsUtility.PRICING_REVENUESHARETARGETRECORDTYPE) {
                    decimal gmv = pricing.EBH_GMVTarget__c;
                    //EPH-5058 
                    if( contractRecord.EBH_IncrementalGMVonly__c && pricing.EBH_PriorYearGMV__c != null){
                        gmv = gmv*0.15;
                           
                   }
                    //aggregate and populate roll ups at parent
                    contractRecord.EBH_ContractValue__c    
                        +=  (pricing.EBH_GMVTarget__c != null &&  contractRecord.EBH_AverageTakeRate__c != null && 
                           contractRecord.EBH_RebateTierrebate__c != null ?
                         cconverter.convert(  (pricing.EBH_GMVTarget__c * contractRecord.EBH_AverageTakeRate__c * 
                           contractRecord.EBH_RebateTierrebate__c)/10000, 
                            pricing.currencyISOCode,contractRecord.currencyISOCode)
                           : 0);
                  
                   
                   
                    contractRecord.EBH_ContractExposure__c 
                        += (pricing.EBH_GMVTarget__c != null &&  contractRecord.EBH_AverageTakeRate__c != null && 
                           contractRecord.EBH_RebateTierrebate__c != null ? 
                        cconverter.convert(   (gmv * contractRecord.EBH_AverageTakeRate__c * 
                           contractRecord.EBH_RebateTierrebate__c)/10000,pricing.currencyISOCode,contractRecord.currencyISOCode) : 0);
                }
                
            }
        }
        
        //if context of execution is Pricing trigger, then we should have an explicit update of Contracts
        if( updateContracts ){
           
           List<Database.saveResult> sr = new List<Database.SaveResult>();
          // try {
                sr= Database.update(parents);
          /*  }catch(DMLException ex) {
                EBH_ApexLogger.logError(new List<Exception> { ex }, EBH_ConstantsUtility.PRICE_CLASSHANDLER, 
                                        EBH_ConstantsUtility.PRICE_CLASSMETHOD);
                                 
            }*/
        }
     
     //return contracts modified in this method, so that they get updated in Contract trigger context
     return parents;

    }
    /*****************************************************************************************************************************
    @ Method:         calDatePeriod
    @ Version:        1.0
    @ Author:         NEHA LUND 
    @ Purpose:       US-0007957 - ST-002994 - Contract 2460: Exposure (Store Subscription and AM Bolt-ons) needs to be adjusted to 3 months period                    
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      startDate,Enddate
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 10.11.2020/ Vadhanak Voun /US-0007957 - ST-002994 - Contract 2460: Exposure (Store Subscription and AM Bolt-ons) needs to be adjusted to 3 months period
    @               : Days360(Contract.Contract Start Date, Contract.Contract End Date)/360*
    *****************************************************************************************************************************/   
    private static Decimal calDatePeriod(Date dStart,Date dEnd)
    {
        return Decimal.valueOf(dStart.daysBetween(dEnd))/Decimal.valueOf(360);
    }

    /*****************************************************************************************************************************
    @ Method:         hasRollupChanged
    @ Version:        1.0
    @ Author:         NEHA LUND 
    @ Purpose:        Check and returns true if any of the following fields has changed in Pricing passed in param:
                       - Listing Value
                       - Listing Exposure 
                       - Store Subscription
                       - Contract
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      con:           Pricing to check field(s) change for
                      PricingOldMap: Pricing old map from trigger scope to compare
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        Boolean: True if any of the field changed
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 18.05.2017 / NEHA LUND / Created the  Method.
    *****************************************************************************************************************************/
    public static Boolean hasRollupChanged(EBH_Pricing__c con, Map<Id, EBH_Pricing__c> PricingOldMap) {
        
        EBH_Pricing__c oldCon = PricingOldMap != Null ? PricingOldMap.get(con.Id) : con;
        
        return con.EBH_ListingValue__c != oldCon.EBH_ListingValue__c ||
               con.EBH_ListingExposure__c != oldCon.EBH_ListingExposure__c ||
               con.EBH_ACPValue__c != oldCon.EBH_ACPValue__c ||
               con.EBH_ACPExposure__c != oldCon.EBH_ACPExposure__c ||
               con.EBH_RevenueValue__c != oldCon.EBH_RevenueValue__c ||
               con.EBH_RevenueExposure__c != oldCon.EBH_RevenueExposure__c ||
               con.EBH_ContractId__c != oldCon.EBH_ContractId__c || PricingOldMap == null ; 
    } 
     /*****************************************************************************************************************************
    @ Method:         hasPricingMatrixChanged
    @ Version:        1.0
    @ Author:         Neha Lund
    @ Purpose:        EPH-4178: Check and returns true if Pricing Matrix has changed
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      con:           Pricing to check field(s) change for
                      PricingOldMap: Pricing old map from trigger scope to compare
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        Boolean: True if any of the field changed
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 09.11.2017 / NEHA LUND / Created the  Method.
    *****************************************************************************************************************************/
    public static Boolean hasPricingMatrixChanged(EBH_Pricing__c con, Map<Id, EBH_Pricing__c> PricingOldMap) {
        
        EBH_Pricing__c oldCon = PricingOldMap != Null ? PricingOldMap.get(con.Id) : con;
        
        return (con.EBH_ContractPricingMatrix__c  != oldCon.EBH_ContractPricingMatrix__c  ||  
                con.CurrencyISOCODe != oldCon.CurrencyISOCode ||  
                con.EBH_Category__c!=oldCon.EBH_Category__c || // Added by DHE 2018/05/24 EPH-5858
                pricingOldMap == null ) &&
                con.EBH_ContractPricingMatrix__c != null;
    }    
    /*****************************************************************************************************************************
    @ Method:         hasParentChanged
    @ Version:        1.0
    @ Author:         Neha Lund
    @ Purpose:        Check and returns true if parent has changed in old Pricing passed in param
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      con:           Pricing to check field(s) change for
                      PricingOldMap: Pricing old map from trigger scope to compare
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        Boolean: True if any of the field changed
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 18.05.2017 / NEHA LUND / Created the  Method.
    *****************************************************************************************************************************/
    public static Boolean hasParentChanged(EBH_Pricing__c con, Map<Id, EBH_Pricing__c> PricingOldMap) {
        
        EBH_Pricing__c oldCon = PricingOldMap != Null ? PricingOldMap.get(con.Id) : con;
        
        return con.EBH_ContractId__c != oldCon.EBH_ContractId__c;
    }    
    
    /*****************************************************************************************************************************
    @ Method:         getMapContractFee
    @ Version:        1.0
    @ Author:         Vadhanak Voun
    @ Purpose:        poppulate custom setting (Contract_Fee__c) records into map for easy usage
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        Boolean: map of custom setting: Contract_Fee__c
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 26.04.2018 / Vadhanak Voun / Created the  Method.
    *****************************************************************************************************************************/
    private static Map<String,Contract_Fee__c> getMapContractFee()
    {
        Map<String,Contract_Fee__c> mapAllFee = new Map<String,Contract_Fee__c>();
        Map<String,Contract_Fee__c> custFee = Contract_Fee__c.getAll();
        for(Contract_Fee__c c: custFee.values())
        {
            mapAllFee.put(c.Field__c+c.Site__c+(String.isBlank(c.Type__c)?'':c.Type__c),c);
        }
        return mapAllFee;
    }
    
}