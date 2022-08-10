/*********************************************************************************************************************************
@ Class:          ClsListViewController
@ Version:        1.0
@ Author:         Sochettra Saing
@ Purpose:        Ability to display Deal List View(EBAY-260)
@ ClsFullCalendarController for LWC lwcDealsFullCalendar
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 28.06.2021 / Sochettra Saing / Created the class.
@ Change history: 24.11.2021 / Sovantheany Dim / US-0010793 - [SEP] Seller views their Deals in Deal Windows
@ Change history: 11/01/2022 : sovantheany dim : US-0010969 -  BUG -[SP EU-Deals] All Deal List Columns " Zustand des Artikels " and " Aktionsformat " not display value in DE
@ Change history: 13-05-2022 / Loumang SENG / US-0011707 -  Ability to view Coupons in list views on Coupon list page (upcoming, future, past, declined, etc) - Part 2
*********************************************************************************************************************************/
public with sharing class ClsListViewController {

    /*@AuraEnabled
    public static Map<String, Object> getAllRecords(String mdtName){
        return new Map<String,Object>();
    }*/

    /*@AuraEnabled
    public static String initLocalCode(){
        String userSite = 'en';
        Map<String, String> mapLanguageLocalCode = new Map<String, String>{'Germany'=>'de'};
       
        List<Contact> cons = [SELECT Id, Account.EBH_RegistrationSite__c FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id =:UserInfo.getUserID())];

        if (!cons.isEmpty() || Test.isRunningTest()) {

            String regSite = (!Test.isRunningTest()) ? cons[0].Account.EBH_RegistrationSite__c : '';

            userSite = mapLanguageLocalCode.containsKey(regSite) ? mapLanguageLocalCode.get(regSite) : 'en';

        }

        return userSite;    
    }*/

    @AuraEnabled
    public static Map<String, Object> getAllSetting(String mdtName){
        //System.debug('@@@@ metadata name'+mdtName);
        Map<String, Object> mResult = new Map<String,Object>();
        mResult.put('status', 'error');
        try{
            String message = '';
            mdtName = mdtName.trim();
            Seller_Portal_Setting__mdt spsMdt = readMtdObject(mdtName);
            if(checkIsInValid(spsMdt)){
                //System.debug('@@@@ invalid metadada'+spsMdt);
                mResult.put('message', 'Missing FiledSet or Object Name!');
            } else {
                //System.debug('@@@@ valid metadada'+spsMdt);
                Map<String, Object> mHighlightFields = readFieldSet(spsMdt.Field_Set_Name__c, spsMdt.Object_API_Name__c);
                Map<String, Object> mDetailFields = readFieldSet(spsMdt.Field_Set_Detail_Name__c, spsMdt.Object_API_Name__c);
                
                Set<String> allFieldsAPI = new Set<String>();
                allFieldsAPI.addAll((Set<String>) mHighlightFields.get('allFields'));
                allFieldsAPI.addAll((Set<String>) mDetailFields.get('allFields'));
                //String query = buildQuery(spsMdt, allFieldsAPI);
                
                mResult.put('highlightFields', mHighlightFields.get('allFieldsObj'));
                mResult.put('detailFields', mDetailFields.get('allFieldsObj'));
                mResult.put('numberOfRecordsPerPage', spsMdt.Number_Of_Records_To_Display__c);
                
                //mResult.put('userDisplayMode', getPortalDisplayDensity()); //MN-02122021-US-0010808

                
                mResult.put('sObjectName', spsMdt.Object_API_Name__c); // Samnang MUONG : return sobject name
                
                mResult.put('status', 'success');
            }
            
        } catch( Exception ex){mResult.put('message', 'Error:'+ex.getLineNumber()+ ex.getMessage());}
        
        return mResult;
    }

    @AuraEnabled
    public static Map<String, Object> doUpdateContact(Contact con){
        Map<String, Object> mResult = new Map<String,Object>();
        mResult.put('status', 'error');
        try{
            update con;
            mResult.put('status', 'success');
            mResult.put('message', 'The contact is updated successfully!');
        } catch( Exception ex){mResult.put('message', 'Error:'+ex.getLineNumber()+ ex.getMessage());}
        return mResult;
    }

    
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getSearchResult(String searchKey, String settingName,string filter){
        //try {

            settingName = settingName.trim();
            //String query = 'SELECT EBH_eBayItemID__c, EBH_ProductTitle__c, Status_Seller_Portal__c, EBH_DealPrice__c, EBH_RRPWASPrice__c, EBH_Quantity__c, EBH_Category__c, EBH_DealStartDate__c, EBH_DealEndDate__c, eBay_Seller_Name__c FROM EBH_Deal__c WHERE EBH_DealStartDate__c > TODAY AND OwnerId=\'0051F00000o9wFdQAI\'';
            
            Seller_Portal_Setting__mdt spsMdt = [SELECT DeveloperName, Field_Set_Name__c, Field_Set_Detail_Name__c, Object_API_Name__c, Filter_Values__c, Number_Of_Records_To_Display__c, Order_Fields__c, Maximum_Records__c, Specific_Search_Field__c FROM Seller_Portal_Setting__mdt WHERE DeveloperName =: settingName];
            String selectedFields = '';
            String filters = '';
            String newFilter='';

             //system.debug('filter>>> '+ spsMdt);
             //sObject filterData=(sObject)JSON.deserialize(filter,sObject.class);
             if(string.isNotBlank(filter))
             {
                newFilter= filter;
            //  Filter filterData=(Filter)(JSON.deserialize(filter,Filter.class));
            //  system.debug('filterData>>> '+ filterData);
            
             

            //     if(String.isNotBlank(filterData.status))
            //     {
            //         newFilter+=' AND Seller_Portal_Status__c='+'\''+filterData.status +'\'';
            //     }
           
            //     if(String.isNotBlank(filterData.rejectionReason))
            //     {
            //         newFilter+=' AND EBH_ReasonforRejection__c='+'\''+filterData.rejectionReason +'\'';
            //     }

            //     if(String.isNotBlank(filterData.dealFormat))
            //     {
            //         newFilter+=' AND EBH_DealFormat__c='+'\''+filterData.dealFormat +'\'';
            //     }
            //     if(String.isNotBlank(filterData.startDate)||String.isNotBlank(filterData.endDate))
            //     {
            //         newFilter+=' AND EBH_DealStartDate__c>='+''+filterData.startDate +'';
            //         newFilter+=' AND EBH_DealEndDate__c <='+''+filterData.endDate +'';
            //     }
            }
            
            if(checkIsInValid(spsMdt)){
                //mResult.put('message', 'Missing FiledSet or Object Name!');
            } else {
                Map<String, Object> mHighlightFields = readFieldSet(spsMdt.Field_Set_Name__c, spsMdt.Object_API_Name__c);
                Map<String, Object> mDetailFields = readFieldSet(spsMdt.Field_Set_Detail_Name__c, spsMdt.Object_API_Name__c);
                
                Set<String> allFieldsAPI = new Set<String>();
                allFieldsAPI.addAll((Set<String>) mHighlightFields.get('allFields'));
                allFieldsAPI.addAll((Set<String>) mDetailFields.get('allFields'));

                if (spsMdt.Object_API_Name__c == 'EBH_Deal__c') allFieldsAPI.add('EBH_BusinessName__r.Name'); //MN-27042021-US-0010950 - To get EBH_BusinessName__r.Name

                selectedFields = String.join(new List<String>(allFieldsAPI), ', ');
                filters = (String.isNotBlank(spsMdt.Filter_Values__c) ? spsMdt.Filter_Values__c : '');
            }
            
            String key = '';
            String id = '';
            Id userId = UserInfo.getUserID();
            //Boolean hasOwnerIdField = doesFieldExist(spsMdt.Object_API_Name__c, 'OwnerId');

            // filters = (filters.containsIgnoreCase('{$User.Id}') ?filters.replace('{$User.Id}', '\''+userId +'\'') : 
            //                                                     (String.isNotBlank(filters)? filters +newFilter+ ' AND OwnerId='+'\''+userId +'\'' : ' OwnerId='+'\''+userId +'\''));

           // Updated 26/10/2021 Samnang MUONG : for ignore ownerId for list view of Deal_Search_Result and Deal_Retail_Campaign_Search_Result
            //Set<String> ignoreOwnerIdFieldSetName = new Set<String>{'Deal_Search_Result', 'Deal_Retail_Campaign_Search_Result'};

            //MN-09122021-US-0010932-For some reason some org return this value as Decimal => cause an issue with Query that expected such value as integer
            Integer max_records = (spsMdt.Maximum_Records__c == null || spsMdt.Maximum_Records__c == 0)?0:Integer.valueOf(spsMdt.Maximum_Records__c); 

            //TH:comment out code filter by OwnerId :US-0010889:14/12/2021
           /*if (!ignoreOwnerIdFieldSetName.contains(settingName)) {
               filters = (filters.containsIgnoreCase('{$User.Id}') ?filters.replace('{$User.Id}', '\''+userId +'\'') : 
                                                                   (String.isNotBlank(filters)? filters +newFilter+ (hasOwnerIdField ? ' AND OwnerId='+'\''+userId +'\'' : '') : (hasOwnerIdField ? ' OwnerId='+'\''+userId +'\'' : '')));
           }*/
           filters = (String.isNotBlank(filters)? filters +newFilter : '');
             //END US-0010889 

            if ( String.isNotBlank(searchKey)) {
                key = '%' + searchKey + '%';

                //TH:US-0010793 :24/11/2021: id is using in Meta Data Seller Portal Setting.My_Deal_Related_List
                id = searchKey;
                // SRONG TIN:US-0010435 : 2.05.2022: Ability to view Coupons in list views on Coupon list page (upcoming, future, past, declined, etc) - Part 1
                if (String.isNotBlank(filters) && String.isNotBlank(spsMdt.Specific_Search_Field__c)) filters += ' AND ';

                if(String.isNotBlank(spsMdt.Specific_Search_Field__c) )filters += ' (' + spsMdt.Specific_Search_Field__c +') ';
            }
            // update 01/10/2021 : Samnang MUONG : purpose : Translate picklist value
            // update 11/01/2022 : TH : US-0010969 -  add translation for picklist value "Item_Condition__c" and "EBH_DealFormat__c"\
            // update 13-05-2022 : LA : US-0011707 : Add translation for picklist value "Coupon_Type__c" and "Coupon_Seller_Stage_Portal__c"
            String newSelectedFields = selectedFields.replace('Seller_Portal_Status__c', 'toLabel(Seller_Portal_Status__c)').replace('Item_Condition__c', 'toLabel(Item_Condition__c)').replace('EBH_DealFormat__c', 'toLabel(EBH_DealFormat__c)').replace('Coupon_Type__c', 'toLabel(Coupon_Type__c)').replace('Coupon_Seller_Stage_Portal__c', 'toLabel(Coupon_Seller_Stage_Portal__c)');




            //MN-09122021-US-0010932 - Replace field spsMdt.Maximum_Records__c with Integer variable max_records so that it will make sure to have Integer Value for LIMIT 
            //String query = 'SELECT '+ newSelectedFields + ' FROM '+ spsMdt.Object_API_Name__c +(String.isNotBlank(filters)? ' WHERE '+filters : '') + (String.isNotBlank(spsMdt.Order_Fields__c)? ' ORDER BY '+spsMdt.Order_Fields__c : '' ) + (spsMdt.Maximum_Records__c > 0 ? ' LIMIT '+spsMdt.Maximum_Records__c:'');
            String query = 'SELECT '+ newSelectedFields + ' FROM '+ spsMdt.Object_API_Name__c +(String.isNotBlank(filters)? ' WHERE '+filters : '') + (String.isNotBlank(spsMdt.Order_Fields__c)? ' ORDER BY '+spsMdt.Order_Fields__c : '' ) + (max_records > 0 ? ' LIMIT '+ max_records:'');

            Map<String,Object> mResult = new Map<String,Object>();
            //('query---'+query);
            system.debug('query---:'+query);
            mResult.put('query', query);
            mResult.put('settingName', settingName);
            mResult.put('listRecord', Database.query(query));
            return mResult;    
            
         //} catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }

    /* MN-02122021-US-0010808
    private static User getPortalDisplayDensity(){
        return [SELECT Id, ContactId, Contact.Portal_Display_Density__c FROM User WHERE Id=: UserInfo.getUserID() Limit 1];
    }
    */

    private static Boolean checkIsInValid(Seller_Portal_Setting__mdt spsMdt) {
        Boolean isInValid = false;
        if(String.isBlank(spsMdt.Field_Set_Name__c) || String.isBlank(spsMdt.Object_API_Name__c)) isInValid = true;
        return isInValid;
    }

    public static boolean doesFieldExist(String objName, string fieldName){
        try {
            SObject so = Schema.getGlobalDescribe().get(objName).newSObject();
            return so.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);
        }
        catch(Exception ex) {return false;}
         
        
    }

    /*private static String buildQuery(Seller_Portal_Setting__mdt spsMdt, Set<String> allFieldsAPI) {
        String query = ''; 
        String selectedField = String.join(new List<String>(allFieldsAPI), ', ');
        String filters = (String.isNotBlank(spsMdt.Filter_Values__c) ? spsMdt.Filter_Values__c : '');

        Id userId = UserInfo.getUserID();

        filters = (filters.containsIgnoreCase('{$User.Id}') ?filters.replace('{$User.Id}', '\''+userId +'\'') : 
                                                                filters + ' AND OwnerId='+'\''+userId +'\'');
        
        String orderFields = (String.isNotBlank(spsMdt.Order_Fields__c)? spsMdt.Order_Fields__c : '');

        query = 'SELECT '+selectedField+' FROM '+spsMdt.Object_API_Name__c+(String.isNotBlank(filters)? ' WHERE '+filters : '')+(String.isNotBlank(orderFields)? ' ORDER BY '+orderFields : '' ) + (spsMdt.Maximum_Records__c > 0? ' LIMIT '+spsMdt.Maximum_Records__c:'');
        
        return query;
    }*/

    private static Map<String, Object> readFieldSet(String fieldSetName, String ObjectName) {
        Map<String, Object> mFieldSet = new Map<String,Object>();

        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        //system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));

        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        //system.debug('==== fieldSetName>' + fieldSetName);
        //system.debug('==== ObjectName>' + ObjectName);
        //List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
        //system.debug('fieldSetMemberList ====>' + fieldSetMemberList); 
        List<Map<String,String>> allFieldsObj = new List<Map<String,String>>();
        Set<String> allFields = new Set<String>();
        for(Schema.FieldSetMember fsm : fieldSetObj.getFields()) {
            //system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
            //system.debug('Label ====>' + fieldSetMemberObj.getLabel());
            //system.debug('Required ====>' + fieldSetMemberObj.getRequired());
            //system.debug('DbRequired ====>' + fieldSetMemberObj.getDbRequired());
            //system.debug('Type ====>' + fieldSetMemberObj.getType());   //type - STRING,PICKLIST
            //lstFields.add(fieldSetMemberObj.getFieldPath());
            Map<String,String> mObj = new Map<String,String>();
            mObj.put('fieldName',fsm.getFieldPath());
            mObj.put('label',fsm.getLabel());
            mObj.put('type',String.valueOf(fsm.getType()));
            allFieldsObj.add(mObj);

            allFields.add(fsm.getFieldPath());
            
        }
        mFieldSet.put('allFields', allFields);
        mFieldSet.put('allFieldsObj', allFieldsObj);

        return mFieldSet; 
    }  
    @AuraEnabled
    public static Seller_Portal_Setting__mdt readMtdObject(String mdtName) {
        return [SELECT DeveloperName, Field_Set_Name__c, Field_Set_Detail_Name__c, Object_API_Name__c, Filter_Values__c, Number_Of_Records_To_Display__c, Order_Fields__c, Maximum_Records__c, Specific_Search_Field__c FROM Seller_Portal_Setting__mdt WHERE DeveloperName =: mdtName];
    }

    @AuraEnabled
    public static String getMtdObjectName(String mdtName) {
        //System.debug('@@@@ mdtName'+mdtName);
        Seller_Portal_Setting__mdt spsMdt = new Seller_Portal_Setting__mdt();
        for(Seller_Portal_Setting__mdt mdt : [SELECT DeveloperName, Object_API_Name__c FROM Seller_Portal_Setting__mdt WHERE DeveloperName =: mdtName]){
            spsMdt = mdt;
        }

        return spsMdt.Object_API_Name__c;
    }

    public class Filter {
        public String status;
        public String rejectionReason;
        public String dealFormat;
        public String startDate;
        public String endDate;
    }


    @AuraEnabled
    public static Map<String, Object> updateInterest(List<Id> coup){
        Map<String, Object> mResult = new Map<String,Object>();
        mResult.put('status', 'error');
        try{
            // update coup;
            // Map<String, String> session = Auth.SessionManagement.getCurrentSession();
            List<Coupon_Seller__c> lstCoupon_Seller=[SELECT Id, Coupon__c, Coupon_Seller_Stage__c, Contract_Accept_Date__c, Contract_Accepted_From__c FROM Coupon_Seller__c WHERE Coupon__c IN: coup];
            if (!lstCoupon_Seller.isEmpty()) {   
                for(Integer i=0; i<lstCoupon_Seller.size(); i++){
                    if(String.isNotBlank(lstCoupon_Seller[i].Id)){
                        update new Coupon_Seller__c(
                            Id=lstCoupon_Seller[i].Id, 
                            Coupon_Seller_Stage__c='Commited'
                            // ,
                            // Contract_Accept_Date__c=system.now(),
                            // Contract_Accepted_From__c=session.get('SourceIp')
                        );   
                    }
                }
            }
            mResult.put('status', 'success');
            mResult.put('message', 'The Coupon is updated successfully!');
        } catch( Exception ex){mResult.put('message', 'Error:'+ex.getLineNumber()+ ex.getMessage());}
        return mResult;
    }

    @AuraEnabled
    public static Map<String, Object> updateNotInterest(List<Id> coup){
        Map<String, Object> mResult = new Map<String,Object>();
        mResult.put('status', 'error');
        try{
            // update coup;
            List<Coupon_Seller__c> lstCoupon_Seller=[SELECT Id, Coupon__c, Coupon_Seller_Stage__c, Contract_Accept_Date__c, Contract_Accepted_From__c FROM Coupon_Seller__c WHERE Coupon__c IN: coup];
            if (!lstCoupon_Seller.isEmpty()) {   
                for(Integer i=0; i<lstCoupon_Seller.size(); i++){
                    if(String.isNotBlank(lstCoupon_Seller[i].Id)){
                        update new Coupon_Seller__c(
                            Id=lstCoupon_Seller[i].Id, 
                            Coupon_Seller_Stage__c='Seller Declined',
                            Seller_Declined_Reasons__c='Other'
                        );   
                    }
                }
            }
            mResult.put('status', 'success');
            mResult.put('message', 'The Coupon is updated successfully!');
        } catch( Exception ex){mResult.put('message', 'Error:'+ex.getLineNumber()+ ex.getMessage());}
        return mResult;
    }

}