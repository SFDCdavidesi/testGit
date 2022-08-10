/*********************************************************************************************************************************@ Class:          ApexUtil
@ Version:        1.0
@ Author:         Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:        Utility class for everyone
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 24.12.2018 / Vadhanak Voun / Created the class.
*********************************************************************************************************************************/
public without sharing class ApexUtil {

    public final static String ADMIN_PROFILE_ID = '00e6A000000HNzwQAG'; //MN-06082021-US-0009746
    public final static String INTEGRATION_USER_ID = '0056A000000zaxM'; //MN-17092021-US-0010407
    public final static String ADMIN_LT_PRIV_PROFILE_ID = '00e3u000000S5pPAAS'; //Sophal-31032022-US-0011453
        
    //NK:08/01/2021:US-0008785
    public static String encryptionkey = '01IS0000000IZrJX';

    //NK:29/12/2020
    public final static map<String,String> MAP_COUNTRY_LANG = new Map <String,STring>{'de'=>'de','uk'=>'en','es'=>'es','fr'=>'fr','it'=>'it','us'=>'en','ca'=>'en','au'=>'en'};   
    public final static map<String,String> MAP_CODE_LANG = new Map <String,STring>{'77'=>'de','3'=>'en','186'=>'es','71'=>'fr','101'=>'it','1'=>'en','2'=>'en','15'=>'en'};
    public final static Map<String,String> MAP_COUNTRY_CODE  = new Map<String,String>{
        '3'=> 'UK','77'=> 'DE','71'=> 'FR','101'=> 'IT','186'=> 'ES','163'=> 'PL','99'=> 'IE','193'=> 'CH','146'=> 'NL','23'=> 'BE','168'=> 'EEC-Unsited','15'=> 'AU','1'=>'US','2'=>'CA',
        'UK'=>'3','DE'=>'77','FR'=>'71','IT'=>'101','ES'=>'186','PL'=>'163','IE'=>'99','CH'=>'193','NL'=>'146','BE'=>'23','EEC-Unsited'=>'168','AU'=>'15','US'=>'1','CA'=>'2'
    };

    //TH:07/06/2022:Move from EBH_ConstantsUtility
    public final static string TRIGGERCONTROLLER     = 'EBH Trigger Controller'; //custom setting name

    public static final string SOQL_ORGWIDE = 'select id,Address from OrgWideEmailAddress';
    public static Map<String,EmailTemplate> mapEmailTemplate = new Map<String,EmailTemplate>();
    private static Map<String,String> localeToDateTimeFmtMap;
    
    //NK:03/06/2019: 
    //e.g. formatNumber(123456789,',','.',3) -> 123,456,789.000
    public static String formatNumber(Decimal val, String osep, String nsep, Integer sclVal)
    {
        osep =  String.isEmpty(osep)?'!*!':osep;
        if(val == null){val = 0;}
        String s, tmp; Integer i = (sclVal==0?3: (4+sclVal)); //3: thousand char 
        s = val.setScale(sclVal).toPlainString().replace(osep, nsep);
        String negSign = s.startsWith('-')?'-':''; //preserve the minus sign
        s = s.replace('-',''); //remove it for cal then add later
        osep = osep.replace('!*!','');
        while(s.length() > i)
        {
            tmp = s.substring(0, s.length() - i) + osep + s.substring(s.length() - i);
            s = tmp;
            i += 4;
        }
        return negSign+s;
    }
    public static String formatNumber(Decimal val,Integer n_scale,String countryCode)
    {
        String osep = map_K_Separator.containsKey(countryCode)?map_K_Separator.get(countryCode):map_K_Separator.get('UK');
        String nsep = mapNumSeparator.containsKey(countryCode)?mapNumSeparator.get(countryCode):mapNumSeparator.get('UK');
        return formatNumber(val,osep,nsep,n_scale);
    }
    private static Map<String,String> mapNumSeparator = new Map<String,String>
    {
        'DE'=>',','UK'=>'.','EN'=>'.','FR'=>',','IT'=>',','ES'=>','
    };
    private static Map<String,String> map_K_Separator = new Map<String,String>
    {
        'DE'=>'.',      //4 294 967.295,000  
        'UK'=>',',      //4,294,967,295.00  
        'EN'=>',',      //4,294,967,295.00  
        'FR'=>' ',      //4 294 967 295,000  
        'IT'=>'.',      //4.294.967.295,000 
        'ES'=>'.'       //4.294.967.295,000  
    };
    //NK:03/06/2019
    public static Object checkNull(Object o)
    {
        return (o==null?'':o);
    }
    public static String nullStr(Object o)
    {
        return (o==null?'':o+'');
    }
    public static String formatTime(Time myTime)
    {
        return myTime==null?'': Datetime.newInstance(Date.today(), myTime).format('h:mm a');
    }
    public static Map<String,String> mapCurrencySign = new Map<String,String>
    {   'AUD'=>'$',
        'GBP'=>'£',
        'EUR'=>'€',
        'PLN'=>'zł',
        'CHF'=>'CHF',
        'USD'=>'$'
    };
    public static Decimal toDecimal(String s,Integer scale)
    {
        try{
            return (s==null?null:Decimal.valueOf((s+'')).setScale(scale));
        }catch(Exception ex)
        {
            return null;
        }
         
    } 

    public static Decimal toDecimal0(String s,Integer scale)
    {
        Decimal tmp = toDecimal(s,scale);
        return (tmp==null?0:tmp);
    
    } 

    public static Integer toInteger(String s)
    {
        try{
            return (s==null?0:Integer.valueOf((s+'')));
        }catch(Exception ex)
        {
            return null;
        }
         
    } 
    public static Double toDouble(String s)
    {
        try{
            return Double.valueOf((s+'').replace(',','.'));
        }catch(Exception ex)
        {
            return null;
        }
        
    } 
    public static Long toLong(String s)
    {
        try{
            return (s==null?0:Long.valueOf((s+'')));
        }catch(Exception ex)
        {
            return null;
        }
         
    }   
    private static Map<String,UserRole> mapUserRole;
    public static Userrole getUserRoleByName(String userRolename){
        if (mapUserRole==null){
            mapUserRole = new Map<String,UserRole>();
            for (UserRole ur :[select id,name from UserRole]){
                mapUserRole.put(ur.name,ur);
            }
        }
        return mapUserRole.get(userRolename);
    }
    //NK:20/11/2018: reduce soql
    private static Map<String,RecordType> mapRecordType;
    public static RecordType getRecordTypeByName(String sobjectName,String recordTypeName)
    {
        if(mapRecordType==null)
        {
            mapRecordType = new Map<String,RecordType>();
            for(RecordType rt : [SELECT id,sobjectType,DeveloperName from RecordType])
            {
                mapRecordType.put(rt.sobjectType+''+rt.DeveloperName,rt);
            }
        } 
        return mapRecordType.get(sobjectName+recordTypeName);
    } 
    //TH : 10/04/2019
    public static Map<String,RecordType> getRecordTypeBySobjectName(String sobjectName){
        Map<String,RecordType> mapRecordType = new Map<String,RecordType>();
        for(RecordType rt : [SELECT id,sobjectType,DeveloperName from RecordType where sobjectType =: sobjectName]){
            mapRecordType.put(rt.DeveloperName,rt);
        }
        return mapRecordType;
    }
    //NK:08/03/2019
    public static void doSend(String subject,String email,String bodHtml){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new String[]{email});
                        mail.setSenderDisplayName('Hive Support');
                        mail.setSubject(subject);
                        mail.setBccSender(false);
                        mail.setUseSignature(false); 
                        mail.setHtmlBody(bodHtml);
        if(!test.isRunningTest()) Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }
    //NK:05/04/2019
    public static Boolean checkPermissionSet(Set<String> setPName)
    {
        String currentUserId = UserInfo.getUserId();
        String sWhere = ' WHERE AssigneeId =:currentUserId AND PermissionSet.Name IN :setPName';     
        List<PermissionSetAssignment> listPSA = Database.query(EBH_ConstantsUtility.SOQL_PERMISSIONSET_ASSIGNMENT + sWhere); 
        return !listPSA.isEmpty();
    }
    //NK:18/04/2019
    public static Object getValue(String fieldName,Sobject sobj)
   {    
            String[] sFields = fieldName.split('[.]');
            Integer i = 1;
            Sobject tmp = sobj;
            //ParentTicket__r.Opportunity__r.Name
            //ParentTicket__r.Name
            //Name
            while(i<sFields.size() && tmp<>null) //0 < 3
            {
                tmp = tmp.getSObject(sFields[i-1]);
                i++;
            }
         return tmp==null?null:tmp.get(sFields[i-1]);
     }
    //DHE 2019-05-09
    public static Boolean runningInASandbox() {
  return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
}
    //NK:15/05/2019:  
    //e.g. 'Deal_Acceptance' -> 'https://sprintdev-hive-prod.cs14.force.com/response'
    public static String getSiteUrl(String siteName)
    {
        if(mapSiteUrl==null)
        {
            mapSiteUrl = new Map<String,String>();
            Map<String,String> siteIds = new Map<String,String>();
            for(Site site1: [SELECT Id, GuestUserId, Name, Subdomain, UrlPathPrefix FROM Site])
            {
                siteIds.put((site1.Id+'').substring(0,15),site1.Name);
            }
            for(SiteDetail sdt: [Select SecureUrl, IsRegistrationEnabled, Id, DurableId From SiteDetail where DurableId IN:siteIds.keySet()])
            {
                mapSiteUrl.put(siteIds.get(sdt.DurableId),sdt.SecureUrl); //DurableId: 15 char
            }
        }
        return mapSiteUrl.get(siteName);
    }
    private static Map<String,String> mapSiteUrl;
    public static Map<Id,User> getUsersMemberByGroup(Set<String> setGoups)
    {
        Map<Id,User> mapUser = new Map<Id,User>();
        Set<String> setUserId = new Set<String>();
        for(GroupMember gm: Database.query(EBH_ConstantsUtility.SOQL_GROUP_MEMBER))
        {
            //filter only user
            if(gm.UserOrGroupId.getSObjectType()==Schema.User.SObjectType)
            {
                setUserId.add(gm.UserOrGroupId);
            }               
        }
        if(Test.isRunningTest())
        {
            setUserId.add(UserInfo.getUserId());
        }
        if(!setUserId.isEmpty())
        {
             mapUser = new Map<Id,User>((List<User>)Database.query(EBH_ConstantsUtility.SOQL_BOB_USER_BY_ID +' AND isActive=true'));
        } 
        return mapUser;
    }
    //NK:21/06/2019: Set<String> to quoted string: 'A','B','C' 
    public static String constructQuoteString(Set<String> setString)
    {
        return ('\''+String.join(new List<String>(setString),'\',\'')+'\''); 
    }
    //NK:19/07/2019: ->f1,f2,f3...
    public static String generateSQOLFields(String sobjectName)
    {
        List<String> fieldsResult = new List<String>();
        Map<String, Schema.SObjectField> allFieldDes = Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap();
        for(Schema.SObjectField f  : allFieldDes.values())
        {
            if(f.getDescribe().isAccessible())
                fieldsResult.add(f.getDescribe().getName());
        }
        if(!fieldsResult.isEmpty())
        {
            return String.join(fieldsResult,','); 
        }
        return null;
    }
    public static Boolean doCompare(String operator,Decimal val1,Decimal val2)
    {
        val1 = val1==null?0:val1;
        val2 = val2==null?0:val2;
        if(operator=='=')
        {
            return val1 == val2;
        }else if(operator=='<=')    
        {
            return val1<= val2;
        }else if(operator=='<')
        {
            return val1<val2;
        }else if(operator=='>')
        {
            return val1>val2;
        }else if(operator=='>=')
        {
            return val1>=val2;
        }
        return false;
    }
    //NK:06/11/2020:128->256
    public static String genUniqueString(Integer len)
    {
        Blob blobKey = crypto.generateAesKey(256);
        String key = EncodingUtil.base64encode(blobKey);
        return key.substring(0, len <=key.length()?len:key.length() ); //e.g. Iwy3RWl1M+uuLZbHeZzuPDEJalO1t/cdQhOr/9lVzBo=
    }

    //TH:26/07/2022:US-0012199
    public static String genUniqueStringNoSymbol(Integer len)
    {
        String uniqueString = ApexUtil.genUniqueString(len);
        return uniqueString.replaceAll('[^a-zA-Z0-9]', '');
    }

    /*
    NK:02/10/2019
        check if batch alreay running or about to run to preven duplicate job 
    */
    public static Map<String,Integer> countRunningBatch(Set<String> batchClassNames)
    {
        Map<String,Integer> mapResult = new Map<String,Integer>();
        Set<String> runningStatus = new Set<String>{'Queued','Processing','Preparing'};
        AggregateResult[] result =  [Select ApexClass.Name className,count(Id) countx  FROM AsyncApexJob WHERE ApexClass.Name IN :batchClassNames AND Status IN: runningStatus group by ApexClass.Name];
        for(aggregateresult ar : result)
        {
         //system.debug('>>class: '+ar.get('className') + ' >>: '+ ar.get('countx'));
         mapResult.put(ar.get('className')+'',(Integer)ar.get('countx'));
        }
        for(String cname: batchClassNames)
        {
            if(mapResult.get(cname) ==null)
            {
                mapResult.put(cname,0);
            }
        }
        return mapResult;
    }
    //NK:15/11/2019
    public static CronTrigger[] findCronJob(Set<String> batchClassNames)
    {
        Set<String> setStates = new Set<String>{'WAITING','PAUSED','BLOCKED','PAUSED_BLOCKED'};//ACQUIRED,EXECUTING,PAUSED,BLOCKED,PAUSED_BLOCKED
        //7: schedule apex, 9 batch
        return [Select TimesTriggered, State, StartTime, PreviousFireTime, NextFireTime, Id, EndTime, CronJobDetailId, CronExpression From CronTrigger c where CronJobDetail.Name IN:batchClassNames AND CronJobDetail.JobType IN ('7','9') AND State in:setStates];
    } 
   //NK:17/11/2019: get dependant picklist value 
    public static Map<String, List<PicklistEntryWrapper>> getDependentMap(Schema.sObjectType objType, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        Map<String,List<PicklistEntryWrapper>> objResults = new Map<String,List<PicklistEntryWrapper>>();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        for (Schema.PicklistEntry ple : contrEntries) {
            //String label = ple.getLabel();
            //objResults.put(label, new List<String>());
            //controllingValues.add(label);
            if(ple.isActive())
            {
                String val = ple.getValue();
                objResults.put(val, new List<PicklistEntryWrapper>());
                controllingValues.add(val);
            }
        }
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    ((List<PicklistEntryWrapper>)objResults.get(controllingValues.get(i))).add(plew);
                }
            }
        }
        return objResults;
    }
    private static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    private static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        String validForBits = '';
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        return validForBits;
    }
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    public class PicklistEntryWrapper{
        @auraEnabled public String active {get;set;}
        @auraEnabled public String defaultValue {get;set;}
        @auraEnabled public String label {get;set;}
        @auraEnabled public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
    }
    public static List<Map<String,String>> getPicklistValues(Schema.SObjectField pklField)
    {
        List<Map<String,String>> listResult = new List<Map<String,String>>();
        for(Schema.PicklistEntry pkl: pklField.getDescribe().getPicklistValues())
        {
            if(pkl.isActive())
            {
                listResult.add(new Map<String,String>{'label'=>pkl.getLabel(),'value'=>pkl.getValue(),'isActive'=>pkl.isActive()+'','isDefaultValue'=>pkl.isDefaultValue()+''});    
            }
        }
        return listResult;
    }
    public static String getFieldIdRef(String fullNamePath)
    {
        if(fullNamePath.contains('.') )
        {
            String fId = fullNamePath.substring(0,fullNamePath.lastIndexOf('.'))+'.Id';
            return fId;
        }
        return fullNamePath;
    }
    // public static Profile getProfileByName(String name)
    // {
    //     return [SELECT Name FROM Profile WHERE Name =: name];
    // }
    private static Map<String,Profile> mProfile;
    public static Profile getProfileByName(String name)
    {
        if(mProfile==null)
        {
            mProfile = new Map<String, Profile>();
            for(Profile profl : Database.query('SELECT Id, Name FROM Profile'))
            {
                mProfile.put(profl.Name, profl);
            }
        } 
        return (mProfile.containsKey(name)) ? mProfile.get(name):null;
    }
    //correct number. e.g. from csv. user selected opion of format
    public static String fixNumber(String value, String locale){
        value = value.replaceAll('[^0-9.,]', '');
        value = locale == 'de' ? value.replace('.','').replace(',','.') : value.replace(',','');
        return value;
    }
    //NK: check if userid is a member of permission set
    public static Set<String> permissionSetMembers(String setPName)
    {
        Set<String> setPSA = new Set<String>();
        String sWhere = ' WHERE PermissionSet.Name =:setPName';  
         for(PermissionSetAssignment psa: Database.query(EBH_ConstantsUtility.SOQL_PERMISSIONSET_ASSIGNMENT + sWhere))
         {
            setPSA.add(psa.AssigneeId);
         }
        return setPSA;
    }
    private static User currentUser = null;
    public static User getCurrentUser()
    {
        if(currentUser==null)
        {
            Set<String> setUser = new Set<String>{UserInfo.getUserId()};
            currentUser =  Database.query(EBH_ConstantsUtility.SOQL_User);
        }
        return currentUser;
    }
    
    private static Map<String,PermissionSetLicense> mapPSL;
    //NK:20/07/2020: get PermissionSetLicense (not simiple permission set)
    public static PermissionSetLicense getPermissionSetL(String psl_DEVName)
    {
        if(mapPSL==null)
        {
            mapPSL = new Map<String,PermissionSetLicense>();
            for(PermissionSetLicense psl: [Select Id,MasterLabel,DeveloperName,TotalLicenses From PermissionSetLicense]){
                mapPSL.put(psl.DeveloperName,psl);
            }
        }
        return mapPSL.get(psl_DEVName);
    } 
    
    //TH: 02/09/2020    : get OrgWideEmailAddress by email
    private static Map<String,OrgWideEmailAddress> mapOrgWide;
    public static OrgWideEmailAddress getOWDbyAddress(String addr){
        if(mapOrgWide == null){
            mapOrgWide = new Map<String,OrgWideEmailAddress>();
            for(OrgWideEmailAddress orgWide : Database.query(SOQL_ORGWIDE)){
                mapOrgWide.put(orgWide.Address, orgWide);
            }
        }
        return mapOrgWide.get(addr);
    }
    /*********************************************************************************************************************************
    @ Method:         getFieldSet
    @ Version:        1.0
    @ Author:         Sreymeas Nao (sreymeas.nao@gaea-sys.com)
    @ Purpose:        US-0008103 - [US]* Deals Internal Bulk/Mass Approval Functionality
                      It was migrated from join instance with original name: DD_Utils.getFieldSet
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:    String strToEncrypt, String pkey
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  02/10/2020 / Sreymeas Nao / Created the method.
    *********************************************************************************************************************************/
    public static String getFieldSet(String sObjectName, String fieldSetName) {
        String result = '';
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
     
            if(FsMap.containsKey(fieldSetName))
                for(Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()) {
                    if(result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel() + '",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired()) + '",';
                    jsonPart += '"type":"' + (f.getType()) + '",';
                    jsonPart += '"name":"' + f.getFieldPath() + '"';
                    jsonPart += '}';
                    result += jsonPart;
            }
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
        }
        return '['+result+']';
    }

    

    /*********************************************************************************************************************************
    @ Method:         prepareEmail
    @ Version:        1.0
    @ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:        US-0008230 
                      It was migrated from join instance with original name: DD_Utils.prepareEmail
                      it for preparing email before sending them.
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:    targetobjectid : object id, tos: main recipients, cc : more recipients, templateName : email template, 
                    defaulttemplate: default email template, binding : field to replace in email content, 
                    sendFromName : sender display name in email, owa: Id of Organization-Wide Email Address
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  07.10.2020 / Sophal Noch / Created the method.
    *********************************************************************************************************************************/
    public static Messaging.SingleEmailMessage prepareEmail(String targetobjectid, String[] tos, String cc, String templateName, String defaulttemplate, Map<String,String> binding, String sendFromName, OrgWideEmailAddress owa) {
       
        // read from cache
        EmailTemplate template = mapEmailTemplate.get(templateName);
        
        if (template==null) {
            List<EmailTemplate> templates = [select Id, Name, Body, Subject, HtmlValue, DeveloperName from EmailTemplate where DeveloperName =:templateName];
           
            
            if (templates.isEmpty()) {
                
                template = [select Id, Name, Body, Subject, HtmlValue, DeveloperName from EmailTemplate where DeveloperName =:defaulttemplate LIMIT 1];
    
            } else {
                template = templates.get(0);
            }
            
            // put in cache
             mapEmailTemplate.put(templateName,template);
        }
        
        // build body
        String body = template.HtmlValue;
        String subject = template.Subject;
   
        if (binding!=null)
        for (String k : binding.keySet()) {
            if(binding.get(k) != null) {
                body = body.replace(k,binding.get(k));
                subject = subject.replace(k,binding.get(k));
            }
        }  
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
         
        if (targetobjectid==null) {
            email.setSubject(subject);
            email.setHtmlBody(body); 
            email.setToAddresses(tos);
            if(sendFromName != null) email.setSenderDisplayName(sendFromName);
            if(owa != null) email.setOrgWideEmailAddressId(owa.Id);
        } else {
            email.setTargetObjectId(targetobjectid);
            email.setTemplateId(template.Id);
        }
        
     
        
        return email;
        
    }
    
    /*********************************************************************************************************************************
    @ Method:         sendEmail
    @ Version:        1.0
    @ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
    @ Purpose:        US-0008230 
                      It was migrated from join instance with original name: DD_Utils.sendEmail
                      it is for sending email
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:    emails: list of email to send
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  07.10.2020 / Sophal Noch / Created the method.
    *********************************************************************************************************************************/
    public static Messaging.SendEmailResult[] sendEmail(List<Messaging.SingleEmailMessage> emails) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
            if (results[0].success) {System.debug('The email was sent successfully.');
            } else {System.debug('The email failed to send: ' + results[0].errors[0].message);}
            return results;
      
    }
    /*********************************************************************************************************************************
    @ Method:         doEncrypt
    @ Version:        1.0
    @ Author:         Sreymeas Nao (sreymeas.nao@gaea-sys.com)
    @ Purpose:        US-0008102 
                      It was migrated from join instance with original name: DD_Utils.doEncrypt
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:    String strToEncrypt, String pkey
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  23.10.2020 / Sreymeas Nao / Created the method.
    *********************************************************************************************************************************/
    public static String doEncrypt(String strToEncrypt, String pkey) {
        
        Blob key =  Blob.valueOf(pkey);
        Blob data = Blob.valueOf(strToEncrypt);
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, data);
        return EncodingUtil.base64Encode(encrypted); 
        
    }

    /*********************************************************************************************************************************
    @ Method:         generateUniqueString
    @ Version:        1.0
    @ Author:         Sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:        US-0011631 - Create invocable method to encrypt SF record Ids or generate random unique value
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:    List<ID> ids
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  16.05.2022 / Sovantheany Dim / Created the method.
    @                   26.07.2022 / Sovantheany Dim / US-0012199 - Minor Improvements required to finis work with MC team
    *********************************************************************************************************************************/
    @InvocableMethod(label='generateUniqueString' description='Generate random unique value')
    public static List<String> generateUniqueString(List<ID> ids) {
        List<String> lstUniqueString = new List<String>();
        for(ID objectId : ids){
            lstUniqueString.add(ApexUtil.genUniqueStringNoSymbol(40));
        }
        return lstUniqueString;   
    }

     /*********************************************************************************************************************************
    @ Method:         validSFId
    @ Version:        1.0
    @ Author:         vadhanak.voun(vadhanak.voun@gaea-sys.com)
    @ Purpose:        check if the string is a valid sfid. sfdc throws error is id is not valid
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:    String to validate
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  06.11.2020 / vadhanak.voun / Created the method.
    *********************************************************************************************************************************/
    public static Boolean validSFId(String sfId)
    {         
        return sfId instanceOf Id;
    }


     /*********************************************************************************************************************************
    @ Method:         getLocaleToDateTimeFmtMap
    @ Version:        1.0
    @ Author:         Ratha.Sim(ratha.sim@gaea-sys.com)
    @ Purpose:        Returns a map of user locale | datetime format for that locale
    ------------------------------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  21.12.2020 / ratha.sim / Created the method.
    *********************************************************************************************************************************/
    public static Map<String,String> MAP_LOCALE_DATEFORMAT() {
        if(localeToDateTimeFmtMap != null) {
            return localeToDateTimeFmtMap;
        }
        localeToDateTimeFmtMap = new Map<String,String> {
                'ar'            => 'dd/MM/yyyy hh:mm a',
                'ar_AE'         => 'dd/MM/yyyy hh:mm a',
                'ar_BH'         => 'dd/MM/yyyy hh:mm a',
                'ar_JO'         => 'dd/MM/yyyy hh:mm a',
                'ar_KW'         => 'dd/MM/yyyy hh:mm a',
                'ar_LB'         => 'dd/MM/yyyy hh:mm a',
                'ar_SA'         => 'dd/MM/yyyy hh:mm a',
                'bg_BG'         => 'yyyy-M-d H:mm',
                'ca'            => 'dd/MM/yyyy HH:mm',
                'ca_ES'         => 'dd/MM/yyyy HH:mm',
                'ca_ES_EURO'    => 'dd/MM/yyyy HH:mm',
                'cs'            => 'd.M.yyyy H:mm',
                'cs_CZ'         => 'd.M.yyyy H:mm',
                'da'            => 'dd-MM-yyyy HH:mm',
                'da_DK'         => 'dd-MM-yyyy HH:mm',
                'de'            => 'dd.MM.yyyy HH:mm',
                'de_AT'         => 'dd.MM.yyyy HH:mm',
                'de_AT_EURO'    => 'dd.MM.yyyy HH:mm',
                'de_CH'         => 'dd.MM.yyyy HH:mm',
                'de_DE'         => 'dd.MM.yyyy HH:mm',
                'de_DE_EURO'    => 'dd.MM.yyyy HH:mm',
                'de_LU'         => 'dd.MM.yyyy HH:mm',
                'de_LU_EURO'    => 'dd.MM.yyyy HH:mm',
                'el_GR'         => 'd/M/yyyy h:mm a',
                'en_AU'         => 'd/MM/yyyy HH:mm',
                'en_B'          => 'M/d/yyyy h:mm a',
                'en_BM'         => 'M/d/yyyy h:mm a',
                'en_CA'         => 'dd/MM/yyyy h:mm a',
                'en_GB'         => 'dd/MM/yyyy HH:mm',
                'en_GH'         => 'M/d/yyyy h:mm a',
                'en_ID'         => 'M/d/yyyy h:mm a',
                'en_IE'         => 'dd/MM/yyyy HH:mm',
                'en_IE_EURO'    => 'dd/MM/yyyy HH:mm',
                'en_NZ'         => 'd/MM/yyyy HH:mm',
                'en_SG'         => 'M/d/yyyy h:mm a',
                'en_US'         => 'M/d/yyyy h:mm a',
                'en_ZA'         => 'yyyy/MM/dd hh:mm a',
                'es'            => 'd/MM/yyyy H:mm',
                'es_AR'         => 'dd/MM/yyyy HH:mm',
                'es_BO'         => 'dd-MM-yyyy hh:mm a',
                'es_CL'         => 'dd-MM-yyyy hh:mm a',
                'es_CO'         => 'd/MM/yyyy hh:mm a',
                'es_CR'         => 'dd/MM/yyyy hh:mm a',
                'es_EC'         => 'dd/MM/yyyy hh:mm a',
                'es_ES'         => 'd/MM/yyyy H:mm',
                'es_ES_EURO'    => 'd/MM/yyyy H:mm',
                'es_GT'         => 'd/MM/yyyy hh:mm a',
                'es_HN'         => 'MM-dd-yyyy hh:mm a',
                'es_MX'         => 'd/MM/yyyy hh:mm a',
                'es_PE'         => 'dd/MM/yyyy hh:mm a',
                'es_PR'         => 'MM-dd-yyyy hh:mm a',
                'es_PY'         => 'dd/MM/yyyy hh:mm a',
                'es_SV'         => 'MM-dd-yyyy hh:mm a',
                'es_UY'         => 'dd/MM/yyyy hh:mm a',
                'es_VE'         => 'dd/MM/yyyy hh:mm a',
                'et_EE'         => 'd.MM.yyyy H:mm',
                'fi'            => 'd.M.yyyy H:mm',
                'fi_FI'         => 'd.M.yyyy H:mm',
                'fi_FI_EURO'    => 'd.M.yyyy H:mm',
                'fr'            => 'dd/MM/yyyy HH:mm',
                'fr_BE'         => 'd/MM/yyyy H:mm',
                'fr_CA'         => 'yyyy-MM-dd HH:mm',
                'fr_CH'         => 'dd.MM.yyyy HH:mm',
                'fr_FR'         => 'dd/MM/yyyy HH:mm',
                'fr_FR_EURO'    => 'dd/MM/yyyy HH:mm',
                'fr_LU'         => 'dd/MM/yyyy HH:mm',
                'fr_MC'         => 'dd/MM/yyyy HH:mm',
                'hr_HR'         => 'yyyy.MM.dd HH:mm',
                'hu'            => 'yyyy.MM.dd. H:mm',
                'hy_AM'         => 'M/d/yyyy h:mm a',
                'is_IS'         => 'd.M.yyyy HH:mm',
                'it'            => 'dd/MM/yyyy H.mm',
                'it_CH'         => 'dd.MM.yyyy HH:mm',
                'it_IT'         => 'dd/MM/yyyy H.mm',
                'iw'            => 'HH:mm dd/MM/yyyy',
                'iw_IL'         => 'HH:mm dd/MM/yyyy',
                'ja'            => 'yyyy/MM/dd H:mm',
                'ja_JP'         => 'yyyy/MM/dd H:mm',
                'kk_KZ'         => 'M/d/yyyy h:mm a',
                'km_KH'         => 'M/d/yyyy h:mm a',
                'ko'            => 'yyyy. M. d a h:mm',
                'ko_KR'         => 'yyyy. M. d a h:mm',
                'lt_LT'         => 'yyyy.M.d HH.mm',
                'lv_LV'         => 'yyyy.d.M HH:mm',
                'ms_MY'         => 'dd/MM/yyyy h:mm a',
                'nl'            => 'd-M-yyyy H:mm',
                'nl_BE'         => 'd/MM/yyyy H:mm',
                'nl_NL'         => 'd-M-yyyy H:mm',
                'nl_SR'         => 'd-M-yyyy H:mm',
                'no'            => 'dd.MM.yyyy HH:mm',
                'no_NO'         => 'dd.MM.yyyy HH:mm',
                'pl'            => 'yyyy-MM-dd HH:mm',
                'pt'            => 'dd-MM-yyyy H:mm',
                'pt_AO'         => 'dd-MM-yyyy H:mm',
                'pt_BR'         => 'dd/MM/yyyy HH:mm',
                'pt_PT'         => 'dd-MM-yyyy H:mm',
                'ro_RO'         => 'dd.MM.yyyy HH:mm',
                'ru'            => 'dd.MM.yyyy H:mm',
                'sk_SK'         => 'd.M.yyyy H:mm',
                'sl_SI'         => 'd.M.y H:mm',
                'sv'            => 'yyyy-MM-dd HH:mm',
                'sv_SE'         => 'yyyy-MM-dd HH:mm',
                'th'            => 'M/d/yyyy h:mm a',
                'th_TH'         => 'd/M/yyyy, H:mm ?.',
                'tr'            => 'dd.MM.yyyy HH:mm',
                'ur_PK'         => 'M/d/yyyy h:mm a',
                'vi_VN'         => 'HH:mm dd/MM/yyyy',
                'zh'            => 'yyyy-M-d ah:mm',
                'zh_CN'         => 'yyyy-M-d ah:mm',
                'zh_HK'         => 'yyyy-M-d ah:mm',
                'zh_TW'         => 'yyyy/M/d a h:mm'
            };
            return localeToDateTimeFmtMap;
    }

    public static Map<String,Object> chunkList(List<Object> listItem,Integer rowLimit)
    {
        Map<String,Object> mapResult  = new Map<String,Object>();
        List<List<Object>> listAllChunk = new List<List<Object>>();        
					 
					 
        Decimal d = Decimal.valueOf(listItem.size()) / Decimal.valueOf(rowLimit);
        Integer numOfChunk = d.round(System.RoundingMode.CEILING).intValue();        

        if(listItem.size()<=rowLimit)
        {
            listAllChunk.add(listItem);
            
        }else{
            for(Integer i=0;i<numOfChunk;i++)
            {
                Integer startIndex = i==0?0:i*rowLimit;
                Integer endIndex = i==0?rowLimit: (i*rowLimit)+rowLimit;
                endIndex = endIndex > listItem.size()?listItem.size():endIndex;

                List<Object> listChunk = new List<Object>();
                for(Integer j = startIndex;j<endIndex;j++)
                {
                    listChunk.add(listItem[j]);
                }
                listAllChunk.add(listChunk);
            }
        }
         
        mapResult.put('totalRow',listItem.size());
        mapResult.put('chunkSize',listAllChunk.size());
        mapResult.put('listAllChunk',listAllChunk);

        return mapResult;
    }

    public static String doDecrypt(String encryptedTxt, String pkey) {


        Blob encryptedData = EncodingUtil.base64Decode(encryptedTxt);

        Blob key =  Blob.valueOf(pkey);

        Blob decrypted = Crypto.decryptWithManagedIV('AES128', key , encryptedData);

        String decryptedString = decrypted.toString();

        return  decryptedString;
    }
    
    public static boolean isProduction()
    {
        return UserInfo.getOrganizationId() == '00D6A0000002HftUAE';
    }

     //support nested object
     //e.g. Object val = ApexUtil.getJSONValue(mapParam,'enrollment.course.id');
     public static Object getJSONValue(Map<String,Object>mapJson,String fname)
     {  
        String key1 = !fname.contains('.') ? fname : fname.substring(0,fname.indexOf('.'));         
        return !fname.contains('.') ? (mapJson==null?'':mapJson.get(fname)) : getJSONValue((Map<String,Object>)mapJson.get(key1),fname.substring(fname.indexOf('.')+1,fname.length()));
     }

     public static String closeSQoute(String str)
     {
         return '\''+str+'\'';
     }

     //Sovantheany Dim : 31/01/2022 : US-0010648 - [BUG][NA DEALS] Canada Contracts on microsite and PDF Attachment showing incorrect EST times
     public static Datetime gmtDateToDTZone(Date d, Time t, String toZone){
        if(t == null || d == null) return null;
        Datetime dt0 = Datetime.newInstanceGmt(d.year(), d.month(), d.day(), 0,0,0);
        TimeZone tzGMT = TimeZone.getTimeZone('GMT');
        TimeZone tztoZone = TimeZone.getTimeZone(toZone);

        Integer offGMT = (((tzGMT.getOffset(dt0.date())/1000)/60)/60);
        Integer offZone = (((tztoZone.getOffset(dt0.date())/1000)/60)/60);

        Integer addHour = offGMT > offZone ? Math.abs(offZone) : offZone;
        Datetime dt1 = dt0.addHours(addHour);
        Datetime dt2 = dt1.addHours(t.hour()).addMinutes(t.minute());

        return dt2;                          
    }


    /***********************************************************************************************************************************
    @ Method:       revokeUserAccess3PLink
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Returns map of result
    @ Param: map user id and identifier (e.g.Account.eBay_API_User_Id__c)
    ------------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 19.05.2022 / vadhanak voun / US-0011343
    ***********************************************************************************************************************************/
    public static Boolean revokeUserAccess3PLink(String userId,String remoteId)   
    {
        // String authProviderId = '';//Provide the Auth. Provider Id
        // String strUserId = '';//Provide the User Id
        Boolean result = false;
        String soqlTPA = 'select id,Provider, UserId, RemoteIdentifier, SsoProviderId  from ThirdPartyAccountLink ';
        String sWehere1 = ' WHERE RemoteIdentifier='+closeSQoute(remoteId);
        String sWehere2 = String.isBlank(userId)?'':' AND UserId='+closeSQoute(userId);
        for(ThirdPartyAccountLink tpl: Database.query(soqlTPA+sWehere1+sWehere2))
        { 
            //system.debug('--tpl'+tpl);
            result = Auth.AuthToken.revokeAccess( tpl.SsoProviderId, tpl.Provider, tpl.UserId, tpl.RemoteIdentifier);
            //system.debug('--result: '+result);
          
        }
                
        return result;
    }

}