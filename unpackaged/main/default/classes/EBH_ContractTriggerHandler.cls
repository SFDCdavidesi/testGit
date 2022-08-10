/*********************************************************************************************************************************
@ Class:          EBH_ContractTriggerHandler
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        Handler Class for Contract Trigger
EPH-6, EPH-14 : Contract Management and Contract Approval
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 12.05.2017 / NEHA LUND / Created the class.
@ Change history: 24.05.2018 / David Herrero / Commented unused methods
*********************************************************************************************************************************/
public without sharing class EBH_ContractTriggerHandler {
    /************************************* CONSTANT DEFINITION *************************************************/
    static final String ContrFinancePostCheck = 'Sent for Finance Post-check';
    static final String CONTRACT_SEND_STATUS = 'Contract Send';
    static final String CONTRACT_LISTINGRECORDTYPE       = 'EBH_ListingAgreement';
    static final String CONTRACT_ACPRECORDTYPE           = 'EBH_ACP';
    static final String CONTRACT_RSRECORDTYPE            = 'EBH_RevenueShare'; 
    
    public static final String CONTRACT_STATUS_DRAFT = 'Draft';
    public static final String CONTRACT_LISTING_AGREEMENT_RECORDTYPEID = '0126A000000M9xVQAS';
    public static final String CONTRACT_ACP_RECORDTYPEID = '0126A000000M9x9QAC';
    // PRIVATE PART
    
    /************************************ END OF CONSTANT DEFINITION*******************************************/

    //To get the Pre-Approved Template rules
    static Map<String, EBH_ContractPreApprovedRules__c> rulesMap = new Map<String, EBH_ContractPreApprovedRules__c>();
    static Map<Id, String> recordTypeMap = new Map<Id, String>();
    //to store the developer name for the record types
    static Map<Id, String> recordTypeDeveloperMap = new Map<Id, String>();
    static Set<Id> contractPricingRTIds = new Set<Id>();
    
    static String RT_REFURB_NAME = 'Refurbished';
    static Id RT_REFURB_ID = ApexUtil.getRecordTypeByName('Contract',RT_REFURB_NAME).Id;
    static Set<Id> SET_RT_ID_NO_PRICING = new Set<Id>{RT_REFURB_ID};

    static String PRO_CANCELLED_STATUS = 'Program Cancelled';
    static String EBAY_DECLINED_STATUS = 'eBay Declined';
    static String DE_COUNTRY = 'DE';
    static String UK_COUNTRY = 'UK'; //SB 29/10/2021 US-0010606

    // Sophal:03/02/2022:US-0011123
    static String IT_COUNTRY = 'IT';
    static String FR_COUNTRY = 'FR';

    static Map<String,String> MAP_COUNTRY_TO_OWD_EMAIL = new Map<String,String>{ 
        DE_COUNTRY => Label.Refurb_DE_OWD_Email,
        IT_COUNTRY => Label.Refurb_IT_OWD_Email // Sophal:04/02/2022:US-0011141
    };
    static Map<String,String> MAP_COUNTRY_STATUS_TO_EMAILTEMPLATE = new Map<String,String>{ 
        DE_COUNTRY+'_'+PRO_CANCELLED_STATUS => 'DE_Refurb_Program_Cancelled_Notification',
        DE_COUNTRY+'_'+EBAY_DECLINED_STATUS => 'DE_Refurb_eBay_Declined_Notification',
        IT_COUNTRY+'_'+EBAY_DECLINED_STATUS => 'IT_Refurb_eBay_Declined_Notification' // Sophal:04/02/2022:US-0011141
    };
    //Start - SB 29/10/2021 US-0010606 Create new map to store Seller refurb contract email template
    static Map<String,String> MAP_COUNTRY_STATUS_TO_CSELLER_EMAILTEMPLATE = new Map<String,String>{ 
        DE_COUNTRY+'_'+CONTRACT_SEND_STATUS => 'Seller_Refurb_Contract_DE',
        UK_COUNTRY+'_'+CONTRACT_SEND_STATUS => 'Seller_Refurb_Contract_UK',
        // Sophal:03/02/2022:US-0011123
        IT_COUNTRY+'_'+CONTRACT_SEND_STATUS => 'Seller_Refurb_Contract_IT',
        FR_COUNTRY+'_'+CONTRACT_SEND_STATUS => 'Seller_Refurb_Contract_FR'
    };
    //End - SB 29/10/2021 US-0010606 Create new map to store Seller refurb contract email template
    static String EMT_TCS_URL = '{!TCs_URL__c}';
    static String EMT_STARTDATE = '{!StartDate}';
    static String EMT_ENDDATE = '{!EndDate}';
    static String EMT_ACCOUNT_NAME = '{!Account.Name}';
    static String EMT_BC_MAILING_ADRESS = '{!Business_Contact__r.EBH_MailingAddress__c}';
    static String EMT_BC_MAILING_STREET = '{!Business_Contact__r.EBH_MailingStreet__c}';
    static String EMT_BC_MAILING_POSTAL_CODE = '{!Business_Contact__r.EBH_MailingPostalCode__c}';
    static String EMT_BC_MAILING_CITY = '{!Business_Contact__r.EBH_MailingCity__c}';
    static String EMT_CS_BUSINESS_NAME = '{!EBH_ContractsForSeller__r.EBH_BusinessName__c}';
    //Start - SB 29/10/2021 US-0010606 Add more field from Email Template
	static String EMT_CONTRACT_ACCOUNT = '{!Contract.Account}';
    static String EMT_BUSINESS_CONTACT_STREET = '{!Contract.BusinessContactStreet__c}';
    static String EMT_BUSINESS_CONTACT_POSTAL_CODE = '{!Contract.BusinessContactPostalCode__c}';
    static String EMT_BUSINESS_CONTACT_CITY = '{!Contract.BusinessContactCity__c}';
    static String EMT_BUSINESS_NAME = '{!EBH_ContractSeller__c.EBH_BusinessName__c}';
    static String EMT_START_DATE ='{!Contract.StartDate}';
    static String EMT_CONTRACT_SEND_DATE = '{!Contract.Contract_Send_Date__c}'; // Sophal:03/02/2022:US-0011123
    //End - SB 29/10/2021 US-0010606 Add more field from Email Template

    /*****************************************************************************************************************************
@ Method:         validatePreApprovedTemplate
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        Validates Pre-Approved Template checkbox on Contract based on the following field combination
- Site
- Language &
- Contract Record Type  
Custom Settings will store the combination of Site, Language & Contract Record Type and 
if Contract's details are matched, then Pre-Approved Template checkbox should be checked.
Otherwise Pre-Approved Template checkbox will be unchecked.
If the value is not as PAT matrix then throw an error to the user
------------------------------------------------------------------------------------------------------------------------------
@ Parameter:      Contracts:      Contracts from the trigger scope
ContractOldMap: Contracts old map from the trigger scope
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 12.05.2017 / NEHA LUND / Created the  Method.
*****************************************************************************************************************************/
    public static void validatePreApprovedTemplate(List<Contract> contracts, Map<Id, Contract> contractOldMap) {
        
        //To only initialize once, so that custom settings and record types are not queried again
        if(rulesMap.isEmpty()) {
            
            //To get the custom settings data and store in the map
            for(EBH_ContractPreApprovedRules__c rule: EBH_ContractPreApprovedRules__c.getAll().values()) {
                
                rulesMap.put(rule.EBH_RecordType__c + EBH_ConstantsUtility.HYPHEN_KEY + rule.EBH_Site__c 
                             + EBH_ConstantsUtility.HYPHEN_KEY + rule.EBH_Language__c, rule);
            }
            
            //To get record type name from the record type ID
            for(RecordType rt: Database.query(EBH_ConstantsUtility.CTH_CONTRECTYPEQUERY)) {
                
                recordTypeMap.put(rt.id, rt.Name);
                
                recordTypeDeveloperMap.put(rt.id, rt.DeveloperName);
                
                if( rt.DeveloperName == CONTRACT_LISTINGRECORDTYPE || 
                   rt.DeveloperName == CONTRACT_ACPRECORDTYPE     ||
                   rt.DeveloperName == CONTRACT_RSRECORDTYPE ) {
                       
                       contractPricingRTIds.add(rt.Id);
                   }
                
            }
        }
        
        //parse through contracts of the trigger scope
        for(Contract cont : contracts) {
            
            if(hasPreApprovedParametersChanged(cont, contractOldMap)) {
                if(cont.EBH_PreApprovedTemplate__c != rulesMap.containsKey(RecordTypeMap.get(cont.RecordTypeId) 
                                                                           + EBH_ConstantsUtility.HYPHEN_KEY + cont.EBH_Site__c 
                                                                           + EBH_ConstantsUtility.HYPHEN_KEY + cont.EBH_Language__c)){
                                                                               
                                                                               cont.addError(Label.EBH_PreapprovedTemplateError);
                                                                           }             
            }
        }
    }
    
    /*****************************************************************************************************************************
@ Method:         setBUApprover
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        EBH-4032: To update Legal Approver and Finance Pre-Check approvers based on the Contract Matrix approval 
rules defined.
For every Site - we have Legal Approver and Finance Pre-Check approvers defined in 
Contract Matrix Approval rules 
- Every Contract Matrix Approval object will have related Contract Approval Hierarchy records
- Finance Approver
- Controlling Approver
------------------------------------------------------------------------------------------------------------------------------
@ Parameter:      Contracts:      Contracts from the trigger scope
ContractOldMap: Contracts old map from the trigger scope
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 11.01.2017 / NEHA LUND / Created the  Method.
*****************************************************************************************************************************/
    /*  public static void setBUApprover(List<Contract> contracts, Map<Id, Contract> contractOldMap) {

Set<String> buApprovers = new Set<String>();
List<Contract> contractsToBeApproved = new List<Contract>();
Map<String,Id> groupIds = new Map<String, Id>();

for(Contract con: contracts) {

if(con.EBH_ControllingApproved__c != contractOldMap.get(con.Id).EBH_ControllingApproved__c &&
con.EBH_ControllingApproved__c && !String.isBlank(con.EBH_BUApproverGroup__c)){

buApprovers.add(con.EBH_BUApproverGroup__c);
contractsToBeApproved.add(con);
}

if(con.EBH_FinancePostCheckDone__c != contractOldMap.get(con.Id).EBH_FinancePostCheckDone__c && 
con.EBH_FinancePostCheckDone__c){

contractsToBeApproved.add(con);

}
}

if(!buApprovers.isEmpty()) {            

for(Group pg: [SELECT id, Name from Group where Name in :buApprovers]) {
groupIds.put(pg.Name,pg.Id);
}            
}

if(!contractsToBeApproved.isEmpty()){

for(Contract con: contractsToBeApproved){

//  if(!string.isBlank(con.EBH_BUApproverGroup__c) && groupIds.containsKey(con.EBH_BUApproverGroup__c)){
Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
req1.setObjectId(con.Id);
//Set the approver as public group ID
if(groupIds.containsKey(con.EBH_BUApproverGroup__c))
req1.setNextApproverIds(new Id[] {groupIds.get(con.EBH_BUApproverGroup__c)});
Approval.ProcessResult result = Approval.process(req1);
//  }                
}
}
}
*/
    /*****************************************************************************************************************************
@ Method:         updateApprovers
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        To update Legal Approver and Finance Pre-Check approvers based on the Contract Matrix approval rules defined 
For every Site - we have Legal Approver and Finance Pre-Check approvers defined in 
Contract Matrix Approval rules 
- Every Contract Matrix Approval object will have related Contract Approval Hierarchy records
- Finance Approver
- Controlling Approver
------------------------------------------------------------------------------------------------------------------------------
@ Parameter:      Contracts:      Contracts from the trigger scope
ContractOldMap: Contracts old map from the trigger scope
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 12.05.2017 / NEHA LUND / Created the  Method.
*****************************************************************************************************************************/
    public static void updateApprovers(List<Contract> contracts, Map<Id, Contract> contractOldMap) {
        
        //dynamic approvers on the Contract
        Map<String, EBH_ContractApprovalMatrix__c> approvalMatrices = new Map<String, EBH_ContractApprovalMatrix__c>();
        EBH_CurrencyConverter cConverter = new EBH_CurrencyConverter();
        
        //get the Contract Approval Matrix rules by Site
        for(EBH_ContractApprovalMatrix__c rule : Database.query(EBH_ConstantsUtility.CTH_APPMTRXQUERY)) {
            approvalMatrices.put(rule.EBH_Site__c, rule);
        }
        Set<ID> accountIds = new Set<ID>();
        for(Contract cont : contracts) {
            accountIds.add(cont.AccountId);
        }
        Map<ID, account> accountMap = new Map<ID, Account>(
            [SELECT ID, EBH_BillingCountry__c from Account where ID IN :accountIds]);
        
        String country ='';
        String accountCountry ='';
        
        //parse through contracts of the trigger scope
        for(Contract cont : contracts) {
            country = cont.EBH_Country__c;
            accountCountry = accountMap.get(cont.accountID).EBH_BillingCountry__c;
            
            if( accountCountry == 'Germany' || accountCountry == 'DE'){
                country = 'DE';
            } else if( accountCountry == 'Spain' || accountCountry == 'ES'){
                country = 'ES';
            } else if( accountCountry == 'France' || accountCountry == 'FR'){
                country = 'FR';
            } else if( accountCountry == 'Italy' || accountCountry == 'IT'){
                country = 'IT';
            } else if( accountCountry == 'United Kingdom' || accountCountry == 'UK' || accountCountry == 'GB'){
                country = 'UK';
            } else{
                country = 'Rest of Europe';
            }
            
            //if site or value has changed or the record is new
            if( approvalMatrices.containsKey(country)) {
                
                cont.EBH_LegalApprover__c = null;
                cont.EBH_LegalApprover__c = approvalMatrices.get(country).EBH_LegalApprover__c;
                
            }
            //if site or value has changed or the record is new
            if( approvalMatrices.containsKey(country)) {
                
                cont.EBH_BUApproverGroup__c = cont.EBH_FinancePreCheckApprover__c = cont.EBH_ControllingApprover__c =
                    cont.EBH_FinanceApprover__c = null;
                cont.EBH_FinancePreCheckApprover__c = approvalMatrices.get(country).EBH_FinancePreCheckApprover__c;
                
                //loop through the approval matrix of the current contract site and find the approver to populate
                for(EBH_ContractApprovalHierarchy__c ah : 
                    
                    approvalMatrices.get(country).EBH_ContractApprovalHierarchies__r) {
                        
                        Decimal contractValue = cConverter.convert(cont.EBH_ContractValue__c, cont.CurrencyISOCode,ah.CurrencyISOcode);
                        Decimal exposureValue = cConverter.convert(cont.EBH_ContractExposure__c,cont.CurrencYISOcode ,ah.CurrencyISOcode) ;
                        
                        if(recordTypeDeveloperMap.get(ah.RecordTypeId) == EBH_ConstantsUtility.HIERARCHY_CONTROLLING) {
                            if(contractValue >= ah.EBH_Threshold__c && cont.EBH_ControllingApprover__c == null ) {
                                cont.EBH_ControllingApprover__c = ah.EBH_Approver__c;
                            }
                        } else if(recordTypeDeveloperMap.get(ah.RecordTypeId) == EBH_ConstantsUtility.HIERARCHY_FINANCE) {
                            if(exposureValue >= ah.EBH_Threshold__c && cont.EBH_FinanceApprover__c == null) {
                                cont.EBH_FinanceApprover__c = ah.EBH_Approver__c;
                            }
                        }else if(recordTypeDeveloperMap.get(ah.RecordTypeId) == EBH_ConstantsUtility.HIERARCHY_BUAPPROVER) {
                            if(contractValue >= ah.EBH_Threshold__c && cont.EBH_BUApproverGroup__c == null) {
                                cont.EBH_BUApproverGroup__c = ah.EBH_BUApproverGroup__c;
                            }
                        }
                        
                        
                    }
            } else {                
                //To Do: what should be the default approver
            }
        } 
    } 
    
    /*****************************************************************************************************************************
@ Method:         updateContractValueExposure
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        To update Contract Value & Exposure when the below Contract parameters are changed = 
US:0017
- Value & Exposure for Listing is summation of Value of Listing Record Type 
Pricing records plus Store subscription Fees based on the Store Subscription value
driven by contract

- Value & Exposure for ACP is summation of Value of ACP Record Type
Pricing records plus Average Take rate & Rebate Tier Rate is being
controlled by Contract

- Value & Exposure for Revenue Share is summation of Value of Revenue Share 
Record Type Pricing records plus Average Take rate & Rebate Tier 
Rate is being controlled by Contract
------------------------------------------------------------------------------------------------------------------------------
@ Parameter:      Contracts:      Contracts from the trigger scope
ContractOldMap: Contracts old map from the trigger scope
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 12.05.2017 / NEHA LUND / Created the  Method.
*****************************************************************************************************************************/
public static void updateContractValueExposure(List<Contract> contracts, Map<Id, Contract> contractOldMap) {
        
    // Sophal: 19/08/2021: US-0010203 get RecordType refurbished 
    // setRtIdNoPricing = setRtIdNoPricing != null ? setRtIdNoPricing : new Set<Id>{ApexUtil.getRecordTypeByName('Contract',RT_REFURB_NAME).Id};

    List<Contract> contractsToBeUpdated = new List<Contract>();
    
    //parse through contracts of the trigger scope
    for(Contract cont : contracts) {
        //if controlling parameters on Contract are changed, then value & 
        //exposure needs to be updated along with approvers information
        /* if(hasPricingParametersChanged(cont, contractOldMap) 
|| hasSiteChanged(cont, contractOldMap)  
|| hasSiteOrValueChanged(cont, contractOldMap)) {*/
        //if( cont.status != EBH_ConstantsUtility.CONTRACT_READYFOREBAYSIGNATURE &&
        //   cont.status != 'Sent for eBay Signature')
        if(!EBH_ConstantsUtility.SET_EXCLUDE_CONTRACT.contains(cont.status) //NK:12/06/2018: EPH-5605: exclude: Executed / Voided/Signature
            && !SET_RT_ID_NO_PRICING.contains(cont.RecordTypeId)  // Sophal: 19/08/2021: US-0010203 reburb contract has no pricing, it can skipped
        )
            
            contractsToBeUpdated.add(cont);   
        //}
    }
    
    if( ! contractsToBeUpdated.isEmpty() ){
        //update Approvers if Value/Exposure is updated
        updateApprovers( EBH_PricingTriggerHandler.updateContractValueExposure(contractsToBeUpdated, false), contractOldMap);
    }
}
    
    /*****************************************************************************************************************************
@ Method:         updateTakeRate
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        EPH-89 : To update the average take rate on Contract based on the combination of -
- Site
- Main Vertical
- Record Type 
Combinations are stored in Contract Take Rate Mapping
------------------------------------------------------------------------------------------------------------------------------
@ Parameter:      Contracts:      Contracts from the trigger scope
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 09.10.2017 / NEHA LUND / Created the  Method.
*****************************************************************************************************************************/
    public static void updateTakeRate(List<Contract> contractRecords, Map<Id, Contract> contractOldMap ) {
        
        //To only initialize once, so that custom settings and record types are not queried again
        
        Map<String, Decimal> takeRateRules = new Map<String, Decimal>();
        
        //To get the custom settings data and store in the map
        for(EBH_ContractTakeRateMapping__c rule: EBH_ContractTakeRateMapping__c.getAll().values()) {
            
            if( rule.EBH_RecordType__c == null) 
                rule.EBH_RecordType__c = EBH_ConstantsUtility.CONTRACT_NULL;
            
            takeRateRules.put(rule.EBH_Site__c + rule.EBH_MainVertical__c + rule.EBH_RecordType__c, rule.EBH_TakeRate__c);
        }
        
        //To get record type name from the record type ID
        for(RecordType rt: Database.query(EBH_ConstantsUtility.CTH_CONTRECTYPEQUERY)) {
            
            recordTypeMap.put(rt.id, rt.Name);              
        }
        
        String key, defaultKey, defaultVertical, defaultRecordType;
        
        //parse through contracts of the trigger scope
        for(Contract cont : contractRecords) {
            
            key = cont.EBH_Site__c + EBH_ConstantsUtility.CTH_DEFAULTVALUE ;
            defaultkey = cont.EBH_Site__c + cont.EBH_MainVertical__c ;
            defaultRecordType = cont.EBH_Site__c + EBH_ConstantsUtility.CTH_DEFAULTVALUE + recordTypeMap.get(cont.recordTypeId);
            
            //System.debug('#####'+key+'Default'+defaultKey+'###'+defaultREcordType);
            
            if(hasTakeRateParametersChanged(cont, contractOldMap)) {
                cont.EBH_AverageTakeRate__c = takeRateRules.containsKey(defaultRecordType) ? takeRateRules.get(defaultRecordType) :
                takeRateRules.containsKey(defaultKey) ? takeRateRules.get(defaultKey) :
                takeRateRules.get(key);
            }                                                
        }       
    }
    
    /*****************************************************************************************************************************
@ Method:         updateContractDates
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        To update the date fields when the Contract passes through a specific status changes 
------------------------------------------------------------------------------------------------------------------------------
@ Parameter:      Contracts:      Contracts from the trigger scope
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 29.05.2017 / NEHA LUND / Created the  Method.
@ Change history: 10.07.2018 / David Herrero / Added clause when contract is clonned
@ Change history: 09.08.2021 / Sovantheany Dim / US-0009871 - [Refurb] Send Click Agreements to Contract Sellers

*****************************************************************************************************************************/
    public static void updateContractDates(List<Contract> contractRecords, Map<Id, Contract> contractOldMap ) {
        
        List<Contract> contracts = new List<Contract>();
        for( Contract con : contractRecords ){
            if((contractOldMap != null && con.Status != contractOldMap.get(con.id).Status) 
               || !String.isBlank(con.Status) && contractOldMap == null ){
                   if( con.Status.equalsIgnoreCase(EBH_ConstantsUtility.CONTRACT_SentFinancePreChecked ) ){
                       con.EBH_DateSentforFinancePrecheck__c = Date.Today();
                   } else if( con.Status.equalsIgnoreCase(EBH_ConstantsUtility.CONTRACT_InNegotiation)  && 
                             contractOldMap.get(con.id).Status == EBH_ConstantsUtility.CONTRACT_SentFinancePreChecked){
                                 con.EBH_DateFinancePrechecked__c = Date.Today();
                             } else if ( con.Status.equalsIgnoreCase(EBH_ConstantsUtility.CONTRACT_InNegotiation) ) {
                                 con.EBH_DateSentforNegotiation__c = Date.Today();
                             } else  if ( con.Status.equalsIgnoreCase(EBH_ConstantsUtility.CONTRACT_PendingApproval) ) {
                                 con.EBH_DateSentforFirstApproval__c = Date.Today();
                             } else if ( con.Status.equalsIgnoreCase(EBH_ConstantsUtility.CONTRACT_Approved) ) {
                                 con.EBH_DateApproved__c = Date.Today(); 
                             } 
                             //TH:09/08/2021:US-0009871 : autopopulate Contract Send Date when Contract is sent for Seller acceptance
                             else if ( con.Status.equalsIgnoreCase(CONTRACT_SEND_STATUS) ) {
                             	con.Contract_Send_Date__c = Date.Today();
               				 }else if ( con.Status.equalsIgnoreCase(EBH_ConstantsUtility.CONTRACT_SellerSignature ) ) {
                                 con.EBH_DateSentforCustomerSignature__c = Date.Today();
                             } else if ( con.Status.equalsIgnoreCase(EBH_ConstantsUtility.CONTRACT_SellerSignatureProvided ) ) {
                                 con.EBH_DateCustomerSignatureReturned__c = Date.Today();
                             } else if( con.status.equalsIgnoreCase(EBH_ConstantsUtility.CONTRACT_eBaySignatureSent) ){
                                 con.CustomerSignedDate = Date.Today();
                             }else if( con.status.equalsIgnoreCase('Executed') ){
                                 con.CompanySignedDate = Date.Today();
                             }
                   
                   contracts.add( con);
               }
        }
    }
    
    /*****************************************************************************************************************************
@ Method:         updateApprovalComments
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        To update Cancellation Reason, when the request is rejected
------------------------------------------------------------------------------------------------------------------------------
@ Parameter:      Contracts:      Contracts from the trigger scope
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 29.05.2017 / NEHA LUND / Created the  Method.
*****************************************************************************************************************************/
    @future
    public static void updateApprovalComments(Set <ID> contracts) {
        
        Map<Id,Contract> contractMap  =  new Map<Id,Contract>((List<Contract>)
                                                              Database.query(EBH_ConstantsUtility.CTH_CONTRACTMAPQUERY));
        List<Contract> updateContracts = new List<Contract>();
        
        for(Contract contractRecord : contractMap.values()) {
            //if it matches any of the approval criteria and rejected then populate the comments
            if (!contractMap.get(contractRecord.id).ProcessSteps.isEmpty()  
                && (contractRecord.Status.equalsIgnoreCase(EBH_ConstantsUtility.CONTRACT_DRAFTSTATUS) 
                    || contractRecord.Status.equalsIgnoreCase(EBH_ConstantsUtility.CONTRACT_NEGOTIATIONSTATUS))) {
                        if( contractMap.get(contractRecord.id).ProcessSteps[0].StepStatus =='Rejected'){
                            contractRecord.EBH_CancellationReason__c = contractMap.get(contractRecord.id).ProcessSteps[0].Comments;
                            updateContracts.add(contractRecord);
                            break;
                        }
                    }
        }
        
        if(!updateContracts.isEmpty()){
            try{
                update updateContracts;
            } catch(Exception ex) {
                EBH_ApexLogger.logError(new List<Exception> { ex }, EBH_ConstantsUtility.CTH_CONTRACTCLASS, EBH_ConstantsUtility.CTH_METHOD);
            }
        }
    }
    
    /*****************************************************************************************************************************
@ Method:         hasTakeRateParametersChanged
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        EPH-89 : To check if the Contract's any of the deciding take rate parameters have changed, or when contract 
is created
@ Parameter:      contract:           contract to check field(s) change for Site, Language & Record Type
contractOldMap:     contract old map from trigger scope to compare
------------------------------------------------------------------------------------------------------------------------------
@ Returns:        Boolean: True if any of the field changed
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 12.05.2017 / NEHA LUND / Created the  Method.
*****************************************************************************************************************************/
    public static Boolean hasTakeRateParametersChanged( Contract contract, Map<Id, Contract> contractOldMap) {
        
        Contract oldCon = contractOldMap != Null ? contractOldMap.get(contract.Id) : contract;
        
        return contract.EBH_Site__c != oldCon.EBH_Site__c ||
            contract.EBH_MainVertical__c != oldCon.EBH_MainVertical__c ||
            contract.RecordTypeId != oldCon.RecordTypeId ||
            contractOldMap == null;
    }
    
    /*****************************************************************************************************************************
@ Method:         hasPreApprovedParametersChanged
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        To check if the Contract's any of the deciding pre-approved parameters have changed, or when contract 
is created
@ Parameter:      contract:           contract to check field(s) change for Site, Language & Record Type
contractOldMap:     contract old map from trigger scope to compare
------------------------------------------------------------------------------------------------------------------------------
@ Returns:        Boolean: True if any of the field changed
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 12.05.2017 / NEHA LUND / Created the  Method.
*****************************************************************************************************************************/
    public static Boolean hasPreApprovedParametersChanged( Contract contract, Map<Id, Contract> contractOldMap) {
        
        Contract oldCon = contractOldMap != Null ? contractOldMap.get(contract.Id) : contract;
        
        return (contract.EBH_Site__c != oldCon.EBH_Site__c ||
                contract.EBH_Language__c != oldCon.EBH_Language__c ||
                contract.RecordTypeId != oldCon.RecordTypeId ||
                contract.EBH_PreApprovedTemplate__c != oldCon.EBH_PreApprovedTemplate__c ||
                contractOldMap == null) && 
            contract.EBH_PreApprovedTemplate__c;
    }
    
    /*****************************************************************************************************************************
@ Method:         hasSiteChanged
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        To check if the Contract's Site is changed, then Approvers will be changed, Legal Approver 
If Contract Value is changed, then following fields will change
- Legal Approver
@ Parameter:      contract:           contract to check field(s) change for Site, Language & Record Type
contractOldMap:     contract old map from trigger scope to compare
------------------------------------------------------------------------------------------------------------------------------
@ Returns:        Boolean: True if any of the field changed
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 12.05.2017 / NEHA LUND / Created the  Method.
*****************************************************************************************************************************/
    /*   public static Boolean hasSiteChanged(Contract contract, Map<Id, Contract> contractOldMap) {

Contract oldCon = contractOldMap != Null ? contractOldMap.get(contract.Id) : contract;

return contract.EBH_Site__c != oldCon.EBH_Site__c || contractOldMap == null;               
}
*/ 
    /*****************************************************************************************************************************
@ Method:         hasPricingParametersChanged
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        To check if the Contract's controlling fields are changed
@ Parameter:      contract:           contract to check field(s) 
contractOldMap:     contract old map from trigger scope to compare
- Store Subscription
- Average Take Rate
- Rebate Tier Rebate
- Revenue Share Rate
------------------------------------------------------------------------------------------------------------------------------
@ Returns:        Boolean: True if any of the field changed
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 31.05.2017 / NEHA LUND / Created the  Method.
*****************************************************************************************************************************/
    /*   public static Boolean hasPricingParametersChanged(Contract contract, Map<Id, Contract> contractOldMap) {

Contract oldCon = contractOldMap != Null ? contractOldMap.get(contract.Id) : contract;

return contract.EBH_StoreSubscription__c != oldCon.EBH_StoreSubscription__c ||
contract.EBH_AverageTakeRate__c != oldCon.EBH_AverageTakeRate__c ||
contract.EBH_RebateTierrebate__c != oldCon.EBH_RebateTierrebate__c ||
contract.EBH_RevenueShareRate__c != oldCon.EBH_RevenueShareRate__c;

}
*/
    /*****************************************************************************************************************************
@ Method:         hasSiteOrValueChanged
@ Version:        1.0
@ Author:         NEHA LUND
@ Purpose:        To check if the Contract's Site is changed, then Approvers will be changed, Legal Approver and Finance 
Pre-check approver
If Contract Value is changed, then following fields will change
- Controlling Approver
- Finance Pre-check Approver
@ Parameter:      contract:           contract to check field(s) change for Site, Language & Record Type
contractOldMap:     contract old map from trigger scope to compare
------------------------------------------------------------------------------------------------------------------------------
@ Returns:        Boolean: True if any of the field changed
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 12.05.2017 / NEHA LUND / Created the  Method.
*****************************************************************************************************************************/
    /*  public static Boolean hasSiteOrValueChanged(Contract contract, Map<Id, Contract> contractOldMap) {

Contract oldCon = contractOldMap != Null ? contractOldMap.get(contract.Id) : contract;

return contract.EBH_Site__c != oldCon.EBH_Site__c ||
contract.EBH_ContractValue__c != oldCon.EBH_ContractValue__c ||
contract.EBH_ContractExposure__c != oldCon.EBH_ContractExposure__c ||
contract.RecordTypeId != oldCon.RecordTypeId ||
(contractOldMap == null && 
contractPricingRTIds.contains(contract.RecordTypeId));
}  
*/
    /*****************************************************************************************************************************
@ Method:         lockContractUpdate
@ Version:        1.0
@ Author:         ASHISH BARANWAL
@ Purpose:        [EBH] (EPH-4159) - To lock the update of Contract when status id Ready for eBay Signature
------------------------------------------------------------------------------------------------------------------------------
@ Parameter:      Contracts:      Contracts from the trigger scope
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 22.11.2017 / ASHISH BARANWAL / Created the  Method.
05.02.2018 / David Herrero / Added list of exclusions to be able to edit Some fields
06/02/2018 / Vadhanak Voun / EPH-5367: Added "isBUPending" check to ensure that record under BU Approval must be locked
17/04/2018 / David Herrero / Add exclusions to lockContractUpdate
28/03/2022 / Acmatac SEING / US-0011334 - "Reset to Draft" Capabilities for Contract owners and validations
*****************************************************************************************************************************/
    public static void lockContractUpdate (List<Contract> contracts, Map<Id, Contract> contractOldMap) {
        
        Map<String, Schema.SObjectField> contractFields 
            = Schema.getGlobalDescribe().get(EBH_ConstantsUtility.CONTRACT_CONTAPINAME).getDescribe().fields.getMap();
        List<PermissionSetAssignment> ps = [SELECT id  from PermissionSetAssignment where AssigneeId = :USerInfo.getUserId() 
                                            and PermissionSet.Name = 'EBH_ContractAdmin'];        //DHE 2018/04/17
        set<String> allowedProfiles = new set<String>{'System Administrator','Business Admin'}; //DHE 2018/04/17
            
            String profileName=[select Name from profile where id=:UserInfo.getProfileId()].Name;//DHE 2018/04/17
        List<String> fieldExceptions = new List<String>{'Actual_approver__c',
            'CompanySignedDate',
            'CustomerSignedDate',
            'EBH_ApprovalProcessControl__c',
            'EBH_Approved__c',
            'EBH_AttachmentCheck__c',
            'EBH_BUApproverGroup__c',
            'EBH_CancellationReason__c',
            'EBH_ContractExposure__c',
            'EBH_ContractValue__c',
            'EBH_DateApproved__c',
            'EBH_ApprovalProcessControl',
            'EBH_DateCustomerSignatureReturned__c',
            'EBH_DateSentforCustomerSignature__c',
            'EBH_DateSentforFirstApproval__c',
            'EBH_DateSentforNegotiation__c',
            'EBH_EUSignNotes__c',
            'EBH_FinanceApprover__c',
            'EBH_FinancePostCheckDone__c',
            'EBH_FinancePreCheckApprover__c',
            'EBH_LegalApprover__c',
            'EBH_LegalApprover__c',
            'EndDate',
            'LastModifiedById',
            'LastModifiedDate',
            'List_Control_Values__c',            
            'StatusCode',
            'SystemModstamp',
            'Contract_Signed_by__c',
            'Contract_Accept_Date__c',
            'Contract_Send_Date__c'};
                
                for(Contract con : contracts) {            
                    if(
                        //         	isBUPending(contracts, con) || //vadhanak:06/02/2018
                        (con.Status != 'Draft' &&	con.Status != 'In Negotiation' && contractOldMap.get(con.id).Status != 'Draft') || //DHE 2018/04/17
                        
                        (contractOldMap.get(con.id).Status == 'Approved'||
                        contractOldMap.get(con.id).Status == 'Sent for Seller Signature'   ||
                        
                        contractOldMap.get(con.id).Status == EBH_ConstantsUtility.CONTRACT_READYFOREBAYSIGNATURE ||
                        contractOldMap.get(con.id).Status == EBH_ConstantsUtility.CONTRACT_VOIDEDSTATUS ) && con.Status != 'Draft' && con.OwnerId != UserInfo.getUserId()) { //US-0011334 - Acmatac SEING - "Reset to Draft" Capabilities for Contract owners and validations
                            
                            for(Schema.SObjectField fld : contractFields.values()) {
                                
                                String fldName = fld.getDescribe().getName();
                                System.debug('#####' + fldName);
                                if(fldName != EBH_ConstantsUtility.CONTRACT_CONTSTATUSAPINAME &&
                                   
                                   /*  fldName != 'CustomerSignedDate' &&
fldName != 'CompanySignedDate' &&
fldName != 'EBH_DateSentforCustomerSignature__c'  &&
fldName != 'EBH_DateCustomerSignatureReturned__c' && */
                                   !fieldExceptions.contains(fldName) &&
                                   //need to move into constant utility call 
                                   con.get(fldName) != contractOldMap.get(con.id).get(fldName)
                                   && !allowedProfiles.contains(profileName)//DHE 2018/04/17
                                   && ps.isEmpty() //DHE 2018/04/17
                                  ) {
                                      
                                      System.debug('fldName 2>> ' + fldName);
                                      con.addError(  EBH_ConstantsUtility.CONTRACT_LOCKERROR);
                                  }
                            }
                        }
                }
    }
    
    /*****************************************************************************************************************************
@ Method:         isBUPending
@ Version:        1.0
@ Author:         Vadhanak Voun	
@ Purpose:        EPH-5367 - For unknown reason, Contract is not locked by standard Approval process. 
@							 This trigger to support (lockContractUpdate) when approval stage is under BU Approval pending, then lock the record.
------------------------------------------------------------------------------------------------------------------------------
@ Parameter:      Contracts:      List of Contracts from the trigger scope
@				  Contract		  Single contract to check the approval stage
------------------------------------------------------------------------------------------------------------------------------
@ Change history: 06.02.2018 / Vadhanak Voun / Created the  Method.

*****************************************************************************************************************************/
    /*private static Set<String> setBUPending;
private static Boolean isBUPending(List<Contract> listContract,Contract con){
if(setBUPending==null){
setBUPending = new Set<String>();
Set<String> contractIds = new Set<String>();

for(Contract c: listContract){
contractIds.add(c.Id);		
}

for(ProcessInstanceNode pNode : Database.query(EBH_ConstantsUtility.SOQL_PROCESSINTANCE_NODE_BY_CONTRACT)){
setBUPending.add(pNode.ProcessInstance.TargetObjectId);		
}
}

return setBUPending.contains(con.Id);	
}
*/
    
    /*****************************************************************************************************************************
@ Method:         validateNotSubmittingWithZeroPricing
@ Version:        1.0
@ Author:         David Herrero	
@ Purpose:        Not Allow any user to submit a Contract into the approval process if it has not at lest 1 pricing attached to the contract
------------------------------------------------------------------------------------------------------------------------------
@ Parameter:      Contracts:      List of Contracts from the trigger scope

------------------------------------------------------------------------------------------------------------------------------
@ Change history: 24.05.2018 / David Herrero / Created the  Method.
*****************************************************************************************************************************
@ Change history: 19.06.2020 / Sophal Noch / Update the  Method.
@ Purpose:         US-0007662 To throw the below existing error message when contract is submitted for Approval 
@                   for reaching the stage "Finance Post Check" and Contract.Number_of_Pricing_records__c==0 .
@                   Not to be thrown for the stages "Draft","In Negotiation" or "Finance Pre check" or "Voided".
@                   Basically, Adding In Negotiation and Sent for Finance Pre-check Status to Condition
@*****************************************************************************************************************************
@ Change history: 06.08.2021 / Sophal Noch / US-0009896 Update the  Method.              
*****************************************************************************************************************************/    
    public static void validateNotSubmittingWithZeroPricing(List<Contract>listContracts)   {

        // Sophal: 06/08/2021: US-0009896 get RecordType refurbished 
        // setRtIdNoPricing = setRtIdNoPricing != null ? setRtIdNoPricing : new Set<Id>{ApexUtil.getRecordTypeByName('Contract',RT_REFURB_NAME).Id};

        for (Contract c:listContracts){
            if(c.Status!=EBH_ConstantsUtility.CONTRACT_DRAFTSTATUS 
                && c.Status!=EBH_ConstantsUtility.CONTRACT_VOIDEDSTATUS 
                && c.Status!= EBH_ConstantsUtility.CONTRACT_InNegotiation
                && c.Status!= EBH_ConstantsUtility.CONTRACT_SentFinancePreChecked
                && c.Number_of_Pricing_records__c==0 
                && !SET_RT_ID_NO_PRICING.contains(c.RecordTypeId) // Sophal: 06/08/2021: US-0009896 skip if recordtype is refurbished
                && !test.isRunningTest()
            ){
                c.addError(Label.Not_Submit_Without_Pricing);
            }
        }
        
    }

 /*****************************************************************************************************************************
@ Method:         resetFieldsOnInsert
@ Version:        1.0
@ Author:         David Herrero	
@ Purpose:        Not Allow any user to submit a Contract into the approval process if it has not at lest 1 pricing attached to the contract
------------------------------------------------------------------------------------------------------------------------------
@ Parameter:      Contracts:      List of Contracts from the trigger scope

------------------------------------------------------------------------------------------------------------------------------
@ Change history: 24.05.2018 / David Herrero / Created the  Method.

*****************************************************************************************************************************/    
    public static void resetFieldsOnInsert(List<Contract> listContracts ){ 
        
        for (Contract con : listContracts){
            
        
            con.status=ebh_constantsUtility.CONTRACT_DRAFTSTATUS;        
            con.CompanySignedDate = null;
            con.CustomerSignedDate = null;        
            con.EBH_DateSentforCustomerSignature__c=null;
            con.EBH_DateSentforFinancePrecheck__c=null;
            con.EBH_DateSentforNegotiation__c=null;
            con.EBH_DateApproved__c=null;
            con.EBH_DateCustomerSignatureReturned__c=null;
            con.EBH_DateFinancePrechecked__c=null;
            con.EBH_DateSentforFirstApproval__c=null;
            con.EBH_eBaySignedBy__c=null;
        }
    }
    
    /*****************************************************************************************************************************
    @ Method:         validatePricingDate
    @ Version:        1.0
    @ Author:         Dim sovantheany(sovantheany.dim@gaea-sys.com)	
    @ Purpose:        US-0007005 [Contracts] Pricing Fields to be exposed in Contracts
    @ Validation 1 – Object “Contract”
    @ Note - This rule alone should exclude System Admin and Integration users profiles
    @ Throw error message if Any other standard user profile user other than contract owner without "Contract Admin" permission set tries to edit the pricing dates in Contract record
    @ “Only Contract Owner or users with "Contract Admin" permission can edit the Pricing Start/End dates”
    @
    @ Validation 2 – Pricing Start Date must be >= Contract Start Date and <=Contract End Date
    @ When the Contract owner or ant user with "Contract Admin" permission edits the Pricing Start date field in Contract and if the date value does not meet the above criteria throw an error message
    @ “Pricing Start Date must be >= Contract Start Date AND <=Contract End Date”
    @
    @ Validation 3 - Pricing End Date must be > Contract Start Date and <= Contract End Date
    @ When the Contract owner or ant user with "Contract Admin" permission edits the Pricing End date field in Contract and if the date value does not meet the above criteria throw an error message
    @ “Pricing End Date must be >= Contract Start Date AND <=Contract End Date”
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:    newContracts : List<Contract>
    				oldMapContracts : Map<Id,Contract>
    ------------------------------------------------------------------------------------------------------------------------------				
   	@ Event		: Before Update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 20.01.2020 / Dim sovantheany / Created the Method.
    *****************************************************************************************************************************/    
    public static void validatePricingDate(List<Contract> newContracts, Map<Id, Contract> oldMapContracts){ 
        Boolean isAdmin = (Userinfo.getprofileId()==EBH_ConstantsUtility.ADMIN_PROFILE_ID);
        Boolean isStandard = (Userinfo.getprofileId()==EBH_ConstantsUtility.PROFILE_ID_STANDARD);
        Boolean isContractAdmin = ApexUtil.checkPermissionSet(new Set<String>{EBH_ConstantsUtility.PERMISSION_SET_CONTRACT_ADMIN});
    	String currentUser = UserInfo.getUserId();
    	
        for (Contract con : newContracts){
        	Contract oldCon = oldMapContracts.get(con.Id);
        	if(con.EBH_PricingStartDate__c != oldCon.EBH_PricingStartDate__c || con.EBH_PricingEndDate__c != oldCon.EBH_PricingEndDate__c){
        		if(!isAdmin && !isStandard || (isStandard && currentUser != con.OwnerId && !isContractAdmin)){
        			con.addError(Label.Err_Contract_Pricing_Date);
        		}else if(con.EBH_PricingStartDate__c > con.EndDate || con.EBH_PricingStartDate__c < con.StartDate){
        			con.addError(Label.Err_Contract_Pricing_Start_Date);
        		}else if(con.EBH_PricingEndDate__c > con.EndDate || con.EBH_PricingEndDate__c < con.StartDate){
        			con.addError(Label.Err_Contract_Pricing_End_Date);
        		}
        	}
        }
    }
    
    /*****************************************************************************************************************************
    @ Method:         setDefaultPricingDate
    @ Version:        1.0
    @ Author:         Dim sovantheany(sovantheany.dim@gaea-sys.com)	
    @ Purpose:        US-0007167
    @ Description:
    @ Expected - On Creation of ACP, Listing Agreement or Revenue share contracts
    @ The Pricing Start Date and Pricing End Date in Contract should default to "Contract Start Date" and "Contract End Date"
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:    newContracts : List<Contract>
    ------------------------------------------------------------------------------------------------------------------------------				
   	@ Event		: Before Insert
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 04.02.2020 / Dim sovantheany / Created the Method.
    *****************************************************************************************************************************/
    public static void setDefaultPricingDate(List<Contract> newContracts){ 
    	set<String> sContractRecordType = new Set<String>{ApexUtil.getRecordTypeByName('Contract',CONTRACT_ACPRECORDTYPE).Id, ApexUtil.getRecordTypeByName('Contract',CONTRACT_LISTINGRECORDTYPE).Id,ApexUtil.getRecordTypeByName('Contract',CONTRACT_RSRECORDTYPE).Id};
    	for(Contract contr : newContracts){
    		if(!sContractRecordType.Contains(contr.RecordTypeId)) continue;
    		contr.EBH_PricingStartDate__c = contr.StartDate;
    		contr.EBH_PricingEndDate__c = contr.EndDate;
    	}
    }

    /*****************************************************************************************************************************
    @ Method:         validateBeforeSubmittingForPostCheck
    @ Version:        1.0
    @ Author:         Sreymeas Nao(sreymeas.nao@gaea-sys.com)	
    @ Purpose:        US-0007544 - [Contracts] Contract Sellers to be made mandatory at stage "Finance Post check"
    @ Description:
    @ Contract.record type = "ACP" or "Listing Agreement" Or "Revenue Share"
    @ When Contract Owner submits for Finance post check Approval ( Contract.Status = "Sent for Finance Post-check" )
    @ Query if there are related EBH_ContractSeller__c records associated with the Contract >0
    @ then allow the submission for Approval to proceed else throw the below error message
    @ ---------------------------------------------------------------------------------------------------------------------------
    @ US-0010190 - [Docusign] Validations to ensure Contract Document is attached before submitting for post check approval
    @ Given that I am any user
    @ when I select a Contract (record type = ACP or Listing Agreement or Revenue share) and click "Submit for Approval" for Post check approval
    @ CHECK if ".pdf" document is attached , if no document attached
    @ throw an error message
    @ "Please attach the right contract document before submitting for approval"
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:    List<Contract> newContracts, Map<Id,Contract> oldContracts
    ------------------------------------------------------------------------------------------------------------------------------				
   	@ Event		: Before Insert, Before Update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 26.05.2020 / Sreymeas Nao / Created the Method.
    @ Change history: 30.08.2021 / Sovantheany Dim / Update the Method.	US-0010190
    
    *****************************************************************************************************************************/
    
    public static void validateBeforeSubmittingForPostCheck(List<Contract> newContracts, Map<Id,Contract> oldContracts){
        set<String> sContractRecordType = new Set<String>{ApexUtil.getRecordTypeByName('Contract',CONTRACT_ACPRECORDTYPE).Id, ApexUtil.getRecordTypeByName('Contract',CONTRACT_LISTINGRECORDTYPE).Id,ApexUtil.getRecordTypeByName('Contract',CONTRACT_RSRECORDTYPE).Id};
        for (Contract contr : newContracts) {
            if (oldContracts<>null && contr.Status <> oldContracts.get(contr.Id).Status && contr.Status==contrFinancePostCheck && sContractRecordType.contains(contr.RecordTypeId)) {
                if(contr.Number_of_sellers__c == 0) contr.addError(Label.Not_Submit_Contract_Without_Contract_Seller);
                //TH: US-0010190: Validations to ensure Contract Document is attached before submitting for post check approval
                if(!contr.EBH_AttachmentCheck__c) contr.addError(Label.Not_Submit_Contract_Without_PDF_Att);
            }
        }
    }
    
    /*****************************************************************************************************************************
	 @ Method:         assignUniqueKey
	 @ Version:        1.0
	 @ Author:         Sovantheany Dim
	 @ Purpose:        US-0009871 - [Refurb] Send Click Agreements to Contract Sellers
     @ Event:          before insert,before update
	 ------------------------------------------------------------------------------------------------------------------------------
	 @ Returns:        void
	 ------------------------------------------------------------------------------------------------------------------------------
	 @ Change history:  16.08.2021 / Sovantheany Dim /Created the Method.
	 *****************************************************************************************************************************/	
	 public static void assignUniqueKey(List<Contract> listNew)
    {
        for(Contract c: listNew)
        {
            if(c.Unique_Id__c == null)
            {                 
                c.Unique_Id__c = ApexUtil.doEncrypt(System.now().formatLong()+'',ApexUtil.encryptionkey).left(30).replace('+','');//url decode + to space. 
            }
        }
    }


    /*********************************************************************************************************************************
    @ Method:         sendRefurbEmail
    @ Version:        1.0
    @ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
    @ Event:		  after update
    @ Purpose:        US-0010204 - [Refurb] Email Notification when Contract Status is set to "Program Cancelled"
    @                 US-0010205 - [Refurb] Email Notification when Contract Status is set  to "eBay Declined"
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  07.09.2021 / Sophal Noch / US-0010204, 0010205 create the method
					31.10.2021 / Sambath Seng / US-0010606, Add more condition to check status
                    15.11.2021 / Sophal Noch / US-0010851, use EBH_Site__c instead of EBH_Country__c
                    04.02.2022 / Sophal Noch / US-0011141, send email for EBH_Site__c = 'IT' and Status = 'eBay Declined'
    *********************************************************************************************************************************/
    public static void sendRefurbEmail(List<Contract> newContracts, Map<Id,Contract> oldContracts){

        Set<Id> contrToSendEmail = new Set<Id>();

        for(Contract contr : newContracts){

            // Sophal / 07.09.2021 / US-0010204, 0010205 : only status in ('Program Cancelled', 'eBay Declined') and Contract.EBH_Country__c == 'DE'. 
            if(contr.RecordTypeId == RT_REFURB_ID
               //&& MAP_COUNTRY_STATUS_TO_EMAILTEMPLATE.containsKey(contr.EBH_Country__c + '_' + contr.Status)
               && MAP_COUNTRY_STATUS_TO_EMAILTEMPLATE.containsKey(contr.EBH_Site__c + '_' + contr.Status) // Sophal Noch / 15.11.2021 / US-0010851 : get Template name by EBH_Site__c
               && contr.Status != oldContracts.get(contr.Id).Status)
            {
                contrToSendEmail.add(contr.Id);
            }

        }

        if(!contrToSendEmail.isEmpty()){

            Map<String, EmailTemplate> mapApiNameToEmailTemplate = new Map<String, EmailTemplate>();
            for(EmailTemplate emt : [Select Id,Subject,Body, HtmlValue, DeveloperName from EmailTemplate Where DeveloperName IN: MAP_COUNTRY_STATUS_TO_EMAILTEMPLATE.values()]){
                mapApiNameToEmailTemplate.put(emt.DeveloperName, emt);
            }

            List<Messaging.SingleEmailMessage> listMailToSend = new List<Messaging.SingleEmailMessage>();
            List<Task> listTask = new List<Task>();

            for(Contract contr : [Select Id, Status, EBH_Site__c, EBH_Country__c, TCs_URL__c, StartDate, EndDate, Account.Name, Owner.Email, 
                                Business_Contact__r.Email, Business_Contact__r.EBH_MailingAddress__c, Business_Contact__r.EBH_MailingStreet__c, Business_Contact__r.EBH_MailingPostalCode__c, Business_Contact__r.EBH_MailingCity__c,
                                (Select Id, EBH_BusinessName__r.Name From EBH_ContractsForSeller__r Order By Id ASC Limit 1)
                                From Contract Where Id IN: contrToSendEmail]){
                
                // Sophal / 07.09.2021 / US-0010204, 0010205 : MAP_COUNTRY_STATUS_TO_EMAILTEMPLATE return the EmailTemplate DeveloperName text and then use it to find EmailTemplate in mapApiNameToEmailTemplate.
                // EmailTemplate emt = mapApiNameToEmailTemplate.get(MAP_COUNTRY_STATUS_TO_EMAILTEMPLATE.get(contr.EBH_Country__c + '_' + contr.Status));
                EmailTemplate emt = mapApiNameToEmailTemplate.get(MAP_COUNTRY_STATUS_TO_EMAILTEMPLATE.get(contr.EBH_Site__c + '_' + contr.Status)); // Sophal Noch / 15.11.2021 / US-0010851 : get Template record by EBH_Site__c

                if(emt != null){

                    String subject = emt.Subject;
                    String htmlBody = emt.HtmlValue;
                    String plainTxtBody = emt.Body;

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    // Sophal / 07.09.2021 / US-0010204, 0010205 : need only the first contract seller of contract
                    String firstCsellerBusiName = (contr.EBH_ContractsForSeller__r.isEmpty() ? '' : contr.EBH_ContractsForSeller__r[0].EBH_BusinessName__r.Name);
                    
                    subject = subject.replace(EMT_CS_BUSINESS_NAME, firstCsellerBusiName);

                    // if(contr.EBH_Country__c == DE_COUNTRY && contr.Status == PRO_CANCELLED_STATUS){
                    if(contr.EBH_Site__c == DE_COUNTRY && contr.Status == PRO_CANCELLED_STATUS){ // Sophal Noch / 15.11.2021 / US-0010851

                        // Sophal / 07.09.2021 / US-0010204 : status = 'Program Cancelled'

                        // subject = subject.replace(EMT_CS_BUSINESS_NAME, firstCsellerBusiName);
                        subject = subject.replace(EMT_ENDDATE, contr.EndDate == null ? '' : contr.EndDate.format());//SB 1.11.2021 Add Condition to check if EndDate is null
                        
                        htmlBody = mergeBodyDEProCancelled(htmlBody, contr, firstCsellerBusiName);
                        plainTxtBody = mergeBodyDEProCancelled(plainTxtBody, contr, firstCsellerBusiName);

                    // }else if(contr.EBH_Country__c == DE_COUNTRY && contr.Status == EBAY_DECLINED_STATUS){
                    }else if(contr.EBH_Site__c == DE_COUNTRY && contr.Status == EBAY_DECLINED_STATUS){ // Sophal Noch / 15.11.2021 / US-0010851

                        // Sophal / 07.09.2021 / US-0010205 : status = 'eBay Declined'

                        // subject = subject.replace(EMT_CS_BUSINESS_NAME, firstCsellerBusiName);
                        subject = subject.replace(EMT_STARTDATE, contr.StartDate.format());

                        htmlBody = htmlBody.replace(EMT_TCS_URL, contr.TCs_URL__c);
                        plainTxtBody = plainTxtBody.replace(EMT_TCS_URL, contr.TCs_URL__c);

                    }else if(contr.EBH_Site__c == IT_COUNTRY && contr.Status == EBAY_DECLINED_STATUS){ // Sophal:04/02/2022:US-0011141
                        subject = subject.replace(EMT_ENDDATE, contr.EndDate == null ? '' : contr.EndDate.format());
                        htmlBody = htmlBody.replace(EMT_TCS_URL, contr.TCs_URL__c);
                        plainTxtBody = plainTxtBody.replace(EMT_TCS_URL, contr.TCs_URL__c);
                    }

                    mail.setSubject(subject);
                    mail.setHtmlBody(htmlBody);
                    mail.setToAddresses(new String[]{contr.Business_Contact__r.Email}); 
                    mail.setccAddresses(new String[]{contr.Owner.Email});
                    // Sophal / 07.09.2021 / US-0010204, US-0010205: set OrgWideEmail depending on Country
                    // String owdEmail = MAP_COUNTRY_TO_OWD_EMAIL.get(contr.EBH_Country__c);
                    String owdEmail = MAP_COUNTRY_TO_OWD_EMAIL.get(contr.EBH_Site__c); // Sophal Noch / 15.11.2021 / US-0010851 get Org-Wide Email by EBH_Site__c
                    OrgWideEmailAddress orgWide = ApexUtil.getOWDbyAddress(owdEmail);
                    if(orgWide != null) mail.setOrgWideEmailAddressId(orgWide.Id);
                    listMailToSend.add(mail);

                    String description = 'To: ' + contr.Business_Contact__r.Email + '\n' + //
                    'CC: '+contr.Owner.Email+'\n'+
                    'Subject: '+subject+'\n'+
                    'Body: \n'+plainTxtBody;
                    Task t = createTask(subject,contr,description); // Sophal / 07.09.2021 / US-0010204, US-0010205 create task with description = email content
                    listTask.add(t);

                }


            }

            if(!listMailToSend.isEmpty()){
                if(!Test.isRunningTest()) ApexUtil.sendEmail(listMailToSend);
                insert listTask;
            }
                
        }

    }

    private static Task createTask(String subject,Contract contr,String description){
    	Task t = new Task();
    	t.Subject = 'Email: '+subject;
    	t.WhatId = contr.Id;
        t.ActivityDate = System.today();
        t.Status = 'Completed';
        t.TaskSubtype = 'Email';
        t.IsVisibleInSelfService = false;
    	t.Description = description;
    	t.RecordTypeId = ApexUtil.getRecordTypeByName('Task','Standard_Task').Id;
    	t.Log_Task__c = true;
    	
    	return t;
    }


    private static String mergeBodyDEProCancelled(String body, Contract contr, String firstCsellerBusiName){

        body = body.replace(EMT_TCS_URL, contr.TCs_URL__c);
        body = body.replace(EMT_ENDDATE, contr.EndDate == null ? '' : contr.EndDate.format());//SB 1.11.2021 Add condition to check if it null
        body = body.replace(EMT_ACCOUNT_NAME, contr.Account.Name);
        body = body.replace(EMT_BC_MAILING_ADRESS, contr.Business_Contact__r.EBH_MailingAddress__c);
        body = body.replace(EMT_BC_MAILING_STREET, contr.Business_Contact__r.EBH_MailingStreet__c);
        body = body.replace(EMT_BC_MAILING_POSTAL_CODE, contr.Business_Contact__r.EBH_MailingPostalCode__c);
        body = body.replace(EMT_BC_MAILING_CITY, contr.Business_Contact__r.EBH_MailingCity__c);
        body = body.replace(EMT_CS_BUSINESS_NAME, firstCsellerBusiName);
        
        return body;
    }

    /*****************************************************************************************************************************
    @ Method:   createTaskContractSend
    @ Version:  1.0
    @ Author: 	Sambath Seng (sambath.seng@gaea-sys.com)
    @ Purpose:	US-0010606 - [Refurb]Click Contract Emails to be tracked as Activities in Activity Related List
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:     List<Contract> lstContract
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 29.10.2021 / Sambath Seng / Created the method
    *****************************************************************************************************************************/
    @InvocableMethod
    public static void createTaskContractSend(List<Contract> lstContract) {
        Set<Id> contIds = new Set<Id>();
        for(Contract oCont : lstContract){
            if(MAP_COUNTRY_STATUS_TO_CSELLER_EMAILTEMPLATE.containsKey(oCont.EBH_Site__c + '_' + oCont.Status))
            {
                contIds.add(oCont.Id);
            }
        }
        if(!contIds.isEmpty()){
            Map<String, EmailTemplate> mapApiNameToEmailTemplate = new Map<String, EmailTemplate>();
            for(EmailTemplate emt : [Select Id,Subject,Body, HtmlValue, DeveloperName from EmailTemplate Where DeveloperName IN: MAP_COUNTRY_STATUS_TO_CSELLER_EMAILTEMPLATE.values()]){
                mapApiNameToEmailTemplate.put(emt.DeveloperName, emt);
            }
            List<Task> listTask = new List<Task>();
            for(Contract oCont : [Select Id, Status, EBH_Site__c, StartDate, Account.Name, Owner.Email, Contract_Send_Date__c,
                                Business_Contact__r.Email, BusinessContactStreet__c, BusinessContactPostalCode__c, BusinessContactCity__c,
                                (Select Id, EBH_BusinessName__r.Name From EBH_ContractsForSeller__r Order By Id ASC Limit 1)
                                From Contract Where Id IN: contIds]){
                
                EmailTemplate emt = mapApiNameToEmailTemplate.get(MAP_COUNTRY_STATUS_TO_CSELLER_EMAILTEMPLATE.get(oCont.EBH_Site__c + '_' + oCont.Status));
                if(emt != null){
                    String subject = emt.Subject;
                    String htmlBody = emt.Body;
                    String csBusinessName = (oCont.EBH_ContractsForSeller__r.isEmpty() ? '' : oCont.EBH_ContractsForSeller__r[0].EBH_BusinessName__r.Name);
                    subject = mergeBodyContractSend(subject, oCont, csBusinessName);
                    htmlBody = mergeBodyContractSend(htmlBody, oCont, csBusinessName);
                    String description = 'To: ' + oCont.Business_Contact__r.Email + '\n' + //
                    'CC: '+oCont.Owner.Email+'\n'+
                    'Subject: '+subject+'\n'+
                    'Body: \n'+htmlBody;
                    Task t = createTask(subject,oCont,description);
                    listTask.add(t);
                }
            }
            if(!listTask.isEmpty()){
                insert listTask;
            }   
        }
    }

    /*****************************************************************************************************************************
    @ Method:   resetContractStatus
    @ Version:  1.0
    @ Author: 	Acmatac SEING (acmatac.seing@gaea-sys.com)
    @ Purpose:	US-0011334 - "Reset to Draft" Capabilities for Contract owners and validations
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 22.03.2022 / Acmatac SEING / Created the method
    *****************************************************************************************************************************/
    public static void resetContractStatus(Map<Id,Contract> oldContract, Map<Id,Contract> newContract) {
        // Exclude Admin
        if(Userinfo.getprofileId() == EBH_DealTriggerHandler.ADMIN_PROFILE_ID || Userinfo.getprofileId() == EBH_DealTriggerHandler.ADMIN_PRIVILEGE_PROFILE_ID){
            return;
        }
        
        Set<String> oldStatusesAllow = new Set<String>{'In Negotiation', 'Sent for Finance Pre-check', 'Sent for Finance Post-check', 'Approved', 'Pending Approval', 'Ready for eBay Signature'};
        Set<String> oldStatusesFilter = new Set<String>{'Sent for eBay Signature', 'Executed', 'Voided'};

        Set<Id> contIds = new Set<Id>();
        List<Contract> lstContr = new List<Contract>();
        for(Contract oldContr : oldContract.values()) {
            Contract newContr = newContract.get(oldContr.Id);

            if(oldContr.Status != newContr.Status
                && (newContr.RecordTypeId == CONTRACT_LISTING_AGREEMENT_RECORDTYPEID || newContr.RecordTypeId == CONTRACT_ACP_RECORDTYPEID
                && newContr.Status == CONTRACT_STATUS_DRAFT)
            ){
                if(UserInfo.getUserId() == newContr.OwnerId && oldStatusesAllow.contains(oldContr.Status)){
                    // Reset all flags so records can resubmit for approval
                    newContr.EBH_FinancePostCheckDone__c = false;
                    newContr.EBH_FinanceApproved__c = false;
                    newContr.EBH_Approved__c = false;
                }
                
                if(oldStatusesFilter.contains(oldContr.Status)){
                    newContr.addError(Label.CONTRACT_SET_TO_DRAFT_ERROR_MSG);
                }
            }
        }
    }
    /*****************************************************************************************************************************
    @ Method:   mergeBodyContractSend
    @ Version:  1.0
    @ Author: 	Sambath Seng (sambath.seng@gaea-sys.com)
    @ Purpose:	US-0010606 - [Refurb]Click Contract Emails to be tracked as Activities in Activity Related List
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:     String body, Contract contr, String csBusinessName
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 31.10.2021 / Sambath Seng / Created the method
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 03.02.2022 / Sophal Noch / US-0011123 - IT/FR Refurb Click Contracts Emails
    *****************************************************************************************************************************/
    private static String mergeBodyContractSend(String body, Contract contr, String csBusinessName){
        body = body.replace(EMT_CONTRACT_ACCOUNT, contr.Account.Name == null ? '' : contr.Account.Name);
        body = body.replace(EMT_BUSINESS_CONTACT_STREET, contr.BusinessContactStreet__c == null ? '' : contr.BusinessContactStreet__c);
        body = body.replace(EMT_BUSINESS_CONTACT_POSTAL_CODE, contr.BusinessContactPostalCode__c == null ? '' : contr.BusinessContactPostalCode__c);
        body = body.replace(EMT_BUSINESS_CONTACT_CITY, contr.BusinessContactCity__c == null ? '' : contr.BusinessContactCity__c);
        body = body.replace(EMT_BUSINESS_NAME, csBusinessName == null ? '' : csBusinessName);
        body = body.replace(EMT_START_DATE, contr.StartDate == null ? '' : contr.StartDate.format());
        body = body.replace(EMT_CONTRACT_SEND_DATE, contr.Contract_Send_Date__c == null ? '' : contr.Contract_Send_Date__c.format()); // Sophal:03/02/2022:US-0011123
        return body;
    }

}