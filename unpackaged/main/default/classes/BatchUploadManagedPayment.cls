/*********************************************************************************************************************************
@ Class:          BatchUploadManagedPayment
@ Version:        1.0
@ Author:         Sophal Noch (sophal.noch@gaea-sys.com)
@ Purpose:        US-0007521 Controller for Lightning: ProjectToActionsRelatedList
@ 				  Summary: New Permission Set, New Button, Bulk Upload to create new records, email notification
@                 AC 1:
@                 As a GCX Partner Profile or Standard Profile user with the 'Create Managed Payment' permission set
@                 When I go to the Project object (EBH_Project__c) and Select any Managed Payment List View.
@                 From the drop down box I can see a new button called 'Upload Managed Payment'
@                 Similar to Deals
@                 Note: on EBH_Deals the button appears on all list views except Recently Viewed - unable to find references to that story in Copado.
@                 Managed Payment Upload Button.png
@                 AC 2: Create a new permission set 'Create Managed Payment' that allows users assigned the permission set to 'create' and 'edit' records for the 'EBH_Project__c' Object with record type name = 'Managed Payment'
@                 AC 3:
@                 As a Standard User with the 'Create Managed Payment' permission set
@                 When I go to the Project- Managed Payment List View and Click the button 'Upload Managed Payment' and am able to upload a CSV file.
@                 I see a similar screen with title 'Bulk Upload Managed Payment (instead of Bulk Upload Nominated Item displayed below)
@                 The Attention message should read "Use this .csv template to upload and create Managed Payment records and include a link the following file.
@                 Screen Shot 2020-06-04 at 15.58.52.png
@                 TC 1: The upload must be able to accept .csv in both comma separated and semi-colon separated formats. If the file is not of these formats the upload process should fail and no records should be created. 
@                 TC 2: The CSV file will contain two Data Points:
@                 Oracle Id --> Used for External Id and Matching to seller record
@                 Outreach_dt --> mapped to 'EBHProject.PaymentsInvitationDate__c' (Date Format is DD/MM/YYYY)
@                 AC 4: Given I have performed AC 3, for every unique Oracle Id a new record is created within Hive for the EBH_Project Object with the Managed Payment record type unless an existing Managed Payment record already exists for the seller the oracle Id is associated within Hive
@                 AC 4.1: Records created with an External Id based on Oracle ID to match seller. External ID to follow the same format as [US--0015695]
@                 External ID field will be generated as a Surrogate key (Static Prefix + Oracle ID), sample: PRJ_MP-123456789
@                 TC ONLY: The naming of each Managed Payment record should follow the convention of US-0007610
@                 Project record name = "Payments" <space> Project.Country<space> Project.Seller
@                 Where Project.Country is based on the 'EBH_SellerAccount.RegistrationCountry' value
@                 AC 4.3: Records should be created in Hive using INSERT functionality, where a Managed Payment Record already exists for a given Seller the upload line should be skipped in order to preserve the original record
@                 AC 4.4: The owner of the newly created records in Hive should be the User uploaded the file.
@                 AC 4.5: If the Oracle Id from the upload file does not match an existing Seller within Hive, a Managed Payment record will not be created, the line should be skipped and the next record should be processed.
@                 AC 5: Given that I have peformed AC 3 and AC 4 has been completed, as the uploading user I (and Jonathan Burgess) are informed by email of the success, error. number of processed records. If no seller is found for a corresponding Oracle Id, the email should contain a list of failed Oracle Id records. If an Oracle Id is already associated with a seller that has a Managed Payment record, the failed Oracle Id's should be included in the email.
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 18.06.2020 / Sophal Noch (sophal.noch@gaea-sys.com) / Created the class.
*********************************************************************************************************************************/
global without sharing class BatchUploadManagedPayment implements Database.batchable<String>, Database.Stateful{

    private String m_csvFile;
    private String parentId;

    private String numFormat = 'en'; //de or en
    private String csv_separator = ','; 
    private String docUniqueName;
    private List<String> validSeparators = new List<String>{',',';'};

    public static final String NEWLINE_LF = '\n';
    public static final String NEWLINE_CR = '\r';
    public static final String NEWLINE_CRLF = '\r\n';

    private Integer totalCsvRows = 0;

    private Integer errorRowLimit = 1000;
    private Boolean isMoreThanErrorRowLimit = false;

    private List<String> listError = new List<String>();

    Map<String,String> mapLastError = new Map<String,String>();

    public final static String SELLER_MANAGED_PAYMENT_RECORD_TYPE = 'ManagedPayment';

    Integer successInsertCount = 0;
    Integer failInsertCount = 0;

    Id managedPaymentRecordTypeId;

    private final static String DATA_TYPE_STRING ='String',
    // DATA_TYPE_DECIMAL = 'Decimal',
    // DATA_TYPE_NUMBER='Number',
    // DATA_TYPE_EMAIL='Email',
    // DATA_TYPE_TIME='Time',
    // DATA_TYPE_PICKLIST='Picklist',
    // DATA_TYPE_URL='URL',
    // DATA_TYPE_REF='Reference',
    DATA_TYPE_DATE = 'Date';

    User uploader;
    DateTime uploadTime;


    public static Boolean isBatchManagedPaymentUploading = false;

    public final static String  BATCH_UPLOAD_MANAGED_PAYMENT_EMAIL_TEMPLATE = 'Batch_Upload_Managed_Payment_Email_Template';

    public final static String ROW_ERROR_MSG_TEMPLATE = '- Oracle Id: {!oraId}. Error: {!err}. At CSV Row: {!row}.';


    /*****************************************************************************************************************************
    @ Method/Construtor:   BatchUploadManagedPayment
    @ Version:  1.0
    @ Author:   Sophal Noch (sophal.noch@gaea-sys.com)
	@ Purpose: 	initialize batch instance
    @------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      Sting ParentId parent id of project record, in this case it is null
    @                 String docUniqueName document Name that csv is saved to
    @                 String numFormat format of number for column number value
    @                 String seperator sign to split each column of each row.
    ------------------------------------------------------------------------------------------------------------------------------
    @ Event:          initialize batch
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 18.06.2020 / Sophal Noch / Created the  Method.
    *****************************************************************************************************************************/
    public BatchUploadManagedPayment(String parentId, String docUniqueName, String numFormat,String separator) {
        
        isBatchManagedPaymentUploading = false;

        this.parentId = parentId;
        this.docUniqueName = docUniqueName;
		this.csv_separator = separator;
        this.numFormat = numFormat;

        uploader = [Select Id,Name,Email from User where Id=: UserInfo.getuserid()];
        uploadTime = datetime.now();


        managedPaymentRecordTypeId = ApexUtil.getRecordTypeByName('EBH_Project__c',SELLER_MANAGED_PAYMENT_RECORD_TYPE).Id;
        
        Document d = [Select Name,Body From Document where Name =:docUniqueName];
		m_csvFile =  d.Body.toString().replace('\n',''); //unix user only \r
        
    }

    /*****************************************************************************************************************************
    @ Method:   start
    @ Version:  1.0
    @ Author:   Sophal Noch (sophal.noch@gaea-sys.com)
	@ Purpose: 	init batch data
    @------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      Database.batchableContext batch context
    ------------------------------------------------------------------------------------------------------------------------------
    @ Event:          run before every batch process start
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 18.06.2020 / Sophal Noch / Created the  Method.
    *****************************************************************************************************************************/

    global Iterable<String> start(Database.batchableContext batchableContext)
    { 

        Iterable<String> citer;

        try
        {
            citer=(Iterable<String>)new List<String>(); 
            Boolean isValid = validateSepratorFormat(m_csvFile.split(NEWLINE_CR));
            if(isValid){
                citer = new CSVIterator(m_csvFile,NEWLINE_CR,true); //skip header
            }
            
        }catch(Exception ex)
        {
            citer=(Iterable<String>)new List<String>(); 
            // System.debug('>>>Start Error: '+ex.getMessage());
            
            String rowErrorMsg = createRowErrorMsg('',ex.getMessage(),0);
            addErrorToList(rowErrorMsg);
            mapLastError.put('batchManagedPayment',ex.getMessage());
        }



        return citer;
    }

    /*****************************************************************************************************************************
    @ Method:   execute
    @ Version:  1.0
    @ Author:   Sophal Noch (sophal.noch@gaea-sys.com)
	@ Purpose: 	doing batch precess
    @------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      Database.batchableContext batch context, List<String> scope list of csv rows per batch
    ------------------------------------------------------------------------------------------------------------------------------
    @ Event:          every batch process execute
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 18.06.2020 / Sophal Noch / Created the  Method.
    *****************************************************************************************************************************/
    global void execute(Database.BatchableContext batchableContext, List<String> scope)  
    {

        String csvFile = ''; //construct small piece of csv from the scope 
        for(String row : scope)
        {
            csvFile += row + NEWLINE_CR;
        }

        OpenCSVParser parser = new OpenCSVParser(csv_separator,OpenCSVParser.DEFAULT_QUOTE_CHARACTER, OpenCSVParser.DEFAULT_ESCAPE_CHARACTER,OpenCSVParser.DEFAULT_STRICT_QUOTES, OpenCSVParser.DEFAULT_IGNORE_LEADING_WHITESPACE);
    	OpenCSVReader reader = new OpenCSVReader(parser,csvFile,NEWLINE_CR,false);//unix user only \r //to false to allow double quote with comma: 123,"1,23"
        List<List<String>>listAllRows = reader.readAll();

        // System.debug('nsp: listAllRows '+JSON.serialize(listAllRows));

        Map<String,Account> sellerOracleIdMap = new Map<String,Account>();
        Set<String> oracleIds = new Set<String>();

        for(List<String> row : listAllRows)
    	{

            try
    		{

                String eachOracleId = row[0].trim();
                oracleIds.add(eachOracleId);
            }catch(Exception ex)
    		{

                mapLastError.put('batchManagedPayment',ex.getMessage());
    		}
        }

        sellerOracleIdMap = getSellerOracleIdMap(oracleIds);


        List<CSVData> listData = new List<CSVData>();  
        
        List<EBH_Project__c> listProjectToInsert = new List<EBH_Project__c>();

        Integer eachScopeCsvRows = 0;

        for(List<String> row : listAllRows)
    	{
            eachScopeCsvRows ++;
            Integer rowNumber = totalCsvRows + eachScopeCsvRows;

            String tempOracleId = '';
            try
    		{
                tempOracleId = row[0];
            }catch(Exception ex){}

    		try
    		{
                CSVData cData = new CSVData(row,rowNumber);

	    		//dont know what to do with missing Oracle Id or Listing Id
	    		if(String.isBlank(cData.oracleId)){

                    String rowErrorMsg = createRowErrorMsg('','OracleId is empty',rowNumber);
                    addErrorToList(rowErrorMsg);

                    mapLastError.put('batchManagedPayment','OracleId is empty');
                    failInsertCount ++;
                    continue;
                }

                if(!sellerOracleIdMap.containsKey(cData.oracleId)){

                    String rowErrorMsg = createRowErrorMsg(cData.oracleId,'Seller is not found',rowNumber);
                    addErrorToList(rowErrorMsg);

                    mapLastError.put('batchManagedPayment','Seller is not found');
                    failInsertCount ++;
                    continue;
                }else if(sellerOracleIdMap.containsKey(cData.oracleId) && sellerOracleIdMap.get(cData.oracleId).Projects__r.size() > 0){

                    String rowErrorMsg = createRowErrorMsg(cData.oracleId,'Seller with Managed Payment already exists',rowNumber);
                    addErrorToList(rowErrorMsg);

                    mapLastError.put('batchManagedPayment','Seller is not found.');
                    failInsertCount ++;
                    continue;
                }

                cData.sellerId = sellerOracleIdMap.get(cData.oracleId).Id;

	    		listData.add(cData);
                

    		}catch(Exception ex)
    		{
                failInsertCount ++;

                String errorMsg = ex.getMessage();
                if(errorMsg.contains('List index out of bounds')){
                    errorMsg = 'Incorrect use of separator';
                }

                String rowErrorMsg = createRowErrorMsg(tempOracleId,errorMsg,rowNumber);
                addErrorToList(rowErrorMsg);

                
                mapLastError.put('batchManagedPayment',ex.getMessage());
    		}
        }

        for(CSVData eachCData : listData)
    	{
            EBH_Project__c eachProject = new EBH_Project__c (
                EBH_Seller__c = eachCData.sellerId,
                PaymentsInvitationDate__c = eachCData.paymentsInvitationDate,
                RecordTypeId = managedPaymentRecordTypeId
            );
            listProjectToInsert.add(eachProject);
        }



        try{

            if(!listProjectToInsert.isEmpty()){
                isBatchManagedPaymentUploading = true;
                insert listProjectToInsert;
                isBatchManagedPaymentUploading = false;
                successInsertCount += listProjectToInsert.size();

            }

        }catch(Exception ex){
            isBatchManagedPaymentUploading = false;

            mapLastError.put('batchManagedPayment',ex.getMessage());
            for(CSVData eachCData : listData)
            {   
                failInsertCount ++;
                String oracleId = eachCData.oracleId != null ? eachCData.oracleId : '';
                String rowErrorMsg = createRowErrorMsg(oracleId,ex.getMessage(),eachCData.rowNum);
                addErrorToList(rowErrorMsg);
            }

        }

        totalCsvRows = totalCsvRows + eachScopeCsvRows;
        
        // system.debug('nsp: listError : '+listError);


    }

    /*****************************************************************************************************************************
    @ Method/Construtor:   finish
    @ Version:  1.0
    @ Author:   Sophal Noch (sophal.noch@gaea-sys.com)
	@ Purpose: 	delete temporary document that store csv and send email
    @------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      Database.batchableContext batch context
    ------------------------------------------------------------------------------------------------------------------------------
    @ Event:          when batch process is finished.
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 18.06.2020 / Sophal Noch / Created the  Method.
    *****************************************************************************************************************************/
    global void finish(Database.BatchableContext batchableContext)
	{
        isBatchManagedPaymentUploading = false;
		//clear the tmp Doc
		Delete [Select Id from Document where Name = :docUniqueName];	
    	sendResult();
    }
    
    private void sendResult()
	{
		String emailTemplateName = BATCH_UPLOAD_MANAGED_PAYMENT_EMAIL_TEMPLATE;
		String whereCl = ' Where DeveloperName =: emailTemplateName'; 
    	List<EmailTemplate> empt = Database.query(EBH_ConstantsUtility.SOQLEMAIL_TEMPLATES + whereCl);
    	//System.debug('>>>fvfCampaignId: '+fvfCampaignId);
    	
    	String htmlBody = contructBody(empt[0].HtmlValue);
    	
        if(!Test.isRunningTest()) ApexUtil.doSend(empt[0].subject,uploader.email,htmlBody);
        // if(!Test.isRunningTest()) ApexUtil.doSend(empt[0].subject,'sophal.noch@gaea-sys.com',htmlBody);
			    
    }
    
    private String contructBody(String hbody)
	{
		//system.debug('>>>mapLastError: '+mapLastError);
		return hbody
		.replace('{!Owner}',Test.isRunningTest()?'Test':uploader.Name)
		.replace('{!createdDate}',String.ValueofGmt(uploadTime))
		.replace('{!countItem}',ApexUtil.formatNumber(Decimal.ValueOf(successInsertCount),0,numFormat.toUpperCase())+'')
		.replace('{!failedRecords}',listError.size() > 0 ? toFormatString(listError):'');
	}

    private Boolean validateSepratorFormat(String[] allCsvrow){

        Boolean isValid = true;
        for(Integer i = 1; i < allCsvrow.size(); i++ ){ //skip header so start from 1

            String eachCsvRow = allCsvrow[i];

            if(
                !eachCsvRow.contains(validSeparators[0]) && !eachCsvRow.contains(validSeparators[1])
            ){
                isValid = false;
                String rowErrorMsg = createRowErrorMsg(eachCsvRow, 'Invalid Seprator format' ,i);
                addErrorToList(rowErrorMsg);
            }

            
        }

        return isValid;
    

    }

    private void addErrorToList(String rowErrorMsg){

        if(listError.size() < errorRowLimit){
            listError.add(rowErrorMsg);
            return;
        }
        isMoreThanErrorRowLimit = true;
        
    }


    private Map<String,Account> getSellerOracleIdMap(Set<String> sellerOracleIds){


            Map<String,Account> sellerOracleIdMap = new Map<String,Account>();

            List<Account> sellerList = [
                SELECT Id, 
                Name,
                EBH_OracleID__c,
                EBH_RegistrationCountry__c,
                (SELECT Id, Name, RecordType.Id FROM Projects__r WHERE RecordType.DeveloperName =: SELLER_MANAGED_PAYMENT_RECORD_TYPE) 
                FROM Account 
                WHERE EBH_OracleID__c IN: sellerOracleIds
            ];

            
            for(Account eachSeller : sellerList){

                sellerOracleIdMap.put(eachSeller.EBH_OracleID__c,eachSeller);

            }

            return sellerOracleIdMap;

    }

    private String toFormatString(String[] listStr)
    {
        
      String str = '';
      for(String s : listStr)
      {
        str+=s+'<br/>';
      }

      str = isMoreThanErrorRowLimit ? (str+'+more.... ') : str;
      
      return str;
      
    }

    private String createRowErrorMsg(String oracleId, String errorMsg, Integer rowNumber){

       // '- Oracle Id: {!oraId}. Error: {!err}. At CSV Row: {!row}.';

        String result = ROW_ERROR_MSG_TEMPLATE.replace('{!oraId}', oracleId).replace('{!err}',errorMsg).replace('{!row}',rowNumber+'');
        return result;
    }


    class CSVData{

        Integer rowNum;

        Id sellerId;
        String oracleId;
		Date paymentsInvitationDate;


        public CSVData(String[] csvRow, Integer rowNum){

            this.rowNum = rowNum;

            String idString = csvRow[0].trim();

            this.oracleId = (String)(getValueByType(DATA_TYPE_STRING,idString));
            
            String dateAsString = csvRow[1].trim();
            this.paymentsInvitationDate = (Date)(getValueByType(DATA_TYPE_DATE,dateAsString));
            
            

        }

        private Object getValueByType(String fieldType, String fieldValue){

            Boolean isEmpty = String.isEmpty(fieldValue);
            
            if(fieldType == DATA_TYPE_DATE){
                if(isEmpty) return null;
    
                List<String>dateSplit = new List<String>();
                
                if(!isValidDate(fieldValue))
                {
                  throw new FieldFormatException('Invalid Date Format: "'+fieldValue+'". Expected: dd/mm/yyyy');
                }
                dateSplit = fieldValue.split('/');
                String yearString = dateSplit[2].length() == 2 ? '20' + dateSplit[2] : dateSplit[2];
                Integer year = Integer.valueOf(yearString.trim());
                Integer month = Integer.valueOf(dateSplit[1].trim());  //no mapping need since restricted format
                Integer day = Integer.valueOf(dateSplit[0].trim());
                
                return Date.newInstance(year, month, day);
                
            }
    
            return fieldValue;
        }

        private Boolean isValidDate(String strDate)
        {
          String[] dateStrArr = strDate.split('/');
           
            return dateStrArr.size()==3;
          
        }

        		
    }

    class FieldFormatException extends Exception{}

    

}