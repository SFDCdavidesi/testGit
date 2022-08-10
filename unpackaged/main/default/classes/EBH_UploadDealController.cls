/**
  -changed log:
   + NK:31/10/2017: https://gaeasys.plan.io/issues/11788?pn=1#note-59
     The format for the date is causing quite a few issues for the csv file formatting. 
     We therefore require the date format to be changed to allow only the date in the format - dd/mm/yyyy
   + Fixed empty row that causes to fail upload.
   
   + 08/11/2017(11788?pn=1#note-64):
     1) Ensure that all fields that are mandatory for creating a new deal are also mandatory in the csv import - i.e. - Product Title, Category, Quantity, Seller Price, Seller Email - please can you check the logic in the CSV importer especially -> at the moment if the Quantity and Seller Price are blank in the CSV import it adds a zero to the deal record.
    2) For deals uploaded via the CSV importer can we set 'deal price' field in the deal object = 'seller price' first when uploading proposals? Deal price can be edited afterwards, but in many cases it stays equal to 'seller price'. The 'seller price' field needs also to be populated as it is now.

	+ 13/06/2019: NK: EPH-7247 Deals Object - Make field "Product title" mandatory in bulk upload
	+ 14/06/2019: NK: EPH-7502 Deal Bulk Upload - add addtional fields to bulk upload file (compartible with existing csv)
	+ 08/02/2021 : TH :US-0008668 : [US] Bulk Upload field mapping CSV verification
  + 28.March.2022 / Acmatac SEING / US-0011204 - Fix new line break problem when upload
*/
public class EBH_UploadDealController {
    private final static String DATA_TYPE_STRING ='String',DATA_TYPE_DECIMAL = 'Decimal',DATA_TYPE_NUMBER='Number',DATA_TYPE_DATE = 'Date',DATA_TYPE_TIME='Time',
													DATA_TYPE_PICKLIST='Picklist',DATA_TYPE_URL='URL',DATA_TYPE_REF='Reference',DATA_TYPE_EMAIL='Email';
													
    //NK:13/06/2019:EPH-7247  additional required field
    private static Set<String> setRequiredFields = new Set<String>
    {
    	'EBH_ProductTitle__c','EBH_DealStartDate__c','EBH_DealStartTime__c','EBH_DealEndDate__c','EBH_DealEndTime__c'
    };
    
    private static Map<Integer, MappedField>mappedIndexColName = new Map<Integer, MappedField>{
        0 => new MappedField('EBH_eBayItemID__c', DATA_TYPE_STRING),
        1 => new MappedField('', ''),
        2 => new MappedField('EBH_ProductTitle__c', DATA_TYPE_STRING),
        3 => new MappedField('EBH_EAN__c', DATA_TYPE_STRING),
        4 => new MappedField('EBH_SellerPrice__c', DATA_TYPE_DECIMAL),
        5 => new MappedField('EBH_RecommendedRetailPriceWAS__c', DATA_TYPE_PICKLIST),
        6 => new MappedField('EBH_RRPWASPrice__c', DATA_TYPE_DECIMAL),
        7 => new MappedField('EBH_Quantity__c', DATA_TYPE_NUMBER),
        8 => new MappedField('EBH_Dealdateearliestpossible__c', DATA_TYPE_DATE),
        9 => new MappedField('EBH_DealFormat__c', DATA_TYPE_PICKLIST),
        10 => new MappedField('EBH_IdealoLink__c', DATA_TYPE_URL),
        11 => new MappedField('EBH_AmazonLink__c', DATA_TYPE_URL),
        //12 => new MappedField('EBH_ebayLink__c', DATA_TYPE_URL), //field changed to formula
        12 => new MappedField('', ''), 
        13 => new MappedField('EBH_PictureLink__c', DATA_TYPE_URL),
        14 => new MappedField('EBH_CommentfromeBaySourcer__c', DATA_TYPE_STRING),
        15 => new MappedField('EBH_CommentfromSeller__c', DATA_TYPE_STRING),
        16 => new MappedField('EBH_Category__c', DATA_TYPE_STRING),
        17 => new MappedField('', ''),
        18 => new MappedField('EBH_SellerEmail__c', DATA_TYPE_EMAIL),
        
        19 => new MappedField('EBH_DealSiteId__c', DATA_TYPE_PICKLIST), //EPH-5771 
        
        //NK:13/06/2019:EPH-7247 
        20 => new MappedField('EBH_DealStartTime__c', DATA_TYPE_TIME),  
        21 => new MappedField('EBH_DealEndTime__c', DATA_TYPE_TIME)  
        
    };
    
    private static Map<Integer, MappedField>mappedIndexColName_v2 = new Map<Integer, MappedField>{
        0 => new MappedField('EBH_eBayItemID__c', DATA_TYPE_STRING),
        1 => new MappedField('', ''), //seller name to look for id
        2 => new MappedField('EBH_ProductTitle__c', DATA_TYPE_STRING),
        3 => new MappedField('EBH_EAN__c', DATA_TYPE_STRING),
        4 => new MappedField('EBH_SellerPrice__c', DATA_TYPE_DECIMAL),
        5 => new MappedField('EBH_DealPrice__c', DATA_TYPE_DECIMAL),
        6 => new MappedField('EBH_DealStartDate__c',DATA_TYPE_DATE),
        7 => new MappedField('EBH_DealStartTime__c', DATA_TYPE_TIME),  
        8 => new MappedField('EBH_DealEndDate__c',DATA_TYPE_DATE),
        9 => new MappedField('EBH_DealEndTime__c', DATA_TYPE_TIME),  
        10 => new MappedField('EBH_RecommendedRetailPriceWAS__c', DATA_TYPE_PICKLIST),
        11 => new MappedField('EBH_RRPWASPrice__c', DATA_TYPE_DECIMAL),
        12 => new MappedField('EBH_Quantity__c', DATA_TYPE_NUMBER),
        13 => new MappedField('EBH_Dealdateearliestpossible__c', DATA_TYPE_DATE),
        14 => new MappedField('EBH_DealFormat__c', DATA_TYPE_PICKLIST),
        15 => new MappedField('EBH_SpotlightCategory__c',DATA_TYPE_STRING),//DATA_TYPE_REF),        
        16 => new MappedField('EBH_IdealoLink__c', DATA_TYPE_URL),
        17 => new MappedField('EBH_AmazonLink__c', DATA_TYPE_URL),
        18 => new MappedField('', ''),  //ebay url
        19 => new MappedField('EBH_PictureLink__c', DATA_TYPE_URL),
        20 => new MappedField('EBH_CommentfromeBaySourcer__c', DATA_TYPE_STRING),
        21 => new MappedField('EBH_CommentfromSeller__c', DATA_TYPE_STRING),
        22 => new MappedField('EBH_Category__c', DATA_TYPE_STRING),
        23 => new MappedField('EBH_DealRetailCampaign__c',DATA_TYPE_STRING),//DATA_TYPE_REF),
        24 => new MappedField('EBH_SellerEmail__c', DATA_TYPE_EMAIL),
        25 => new MappedField('EBH_DealSiteId__c', DATA_TYPE_PICKLIST), //EPH-5771 
        26 => new MappedField('OwnerId',DATA_TYPE_STRING)//DATA_TYPE_REF)
        
    };
    
    private static Integer minColumnNumber = 20;
    //NK:06/10/2017:added 4 DE months: Mär Mai Okt Dez, the rest are the same
    private static Map<String, Integer>mMonth = new Map<String, Integer>{
        'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Mär' => 3,  'Apr' => 4,
        'May' => 5, 'Mai' => 5, 'Jun' => 6, 'Jul' => 7,  'Aug' => 8,
        'Sep' => 9, 'Oct' => 10, 'Okt' => 10,'Nov' => 11,'Dec' => 12,
        'Dez' => 12
    };
   
    
    private static Map<String, String>mDealFormat = new Map<String, String>{
        'Value Hero' => 'Featured', 'Basket Item' => 'Core'
    };
    private static String locale;
    public String referrer{get{return ApexPages.currentPage().getHeaders().get('Referer');} set;}

    /*********************************************************************************************************************************
    @ Change history: 28.March.2022 / Acmatac SEING / US-0011204 - Fix new line break problem when upload
    @ Change history: 03.June.2022 / Sophal Noch / US-0011721 - AU Standard Deal - Bulk Upload is not mapping to AU site
    *********************************************************************************************************************************/
    @AuraEnabled
    public static Map<String, Object> createDealFromCSV(String parentId, String filename, String contentfile,String separator,String numFormat, Boolean isPreview){
      locale = numFormat;
      
        Map<String, Object>mResult = new Map<String, Object>{
            'isSuccess' => true,
            'successRecord' => new List<EBH_Deal__c>()  
        };
        
        try{
            //windows: \n\r, unix: \r
            // US-0011204 START
            // contentfile = contentfile.replace('\n',''); STOP USING IT
            String newLineToUse =  Batch_BobSellerBulkCSV.NEWLINE_LF;
            if(contentfile.contains(Batch_BobSellerBulkCSV.NEWLINE_CR)){
              newLineToUse = Batch_BobSellerBulkCSV.NEWLINE_CR;
              contentfile =  contentfile.replace('\n','');
            }
            // US-0011204 END

            OpenCSVParser parser = new OpenCSVParser(separator,OpenCSVParser.DEFAULT_QUOTE_CHARACTER, OpenCSVParser.DEFAULT_ESCAPE_CHARACTER,OpenCSVParser.DEFAULT_STRICT_QUOTES, OpenCSVParser.DEFAULT_IGNORE_LEADING_WHITESPACE);
            
            //NK:27/09/2019:US-0009342: set to "fasle" to solve in-string comma: "TV, audio e video" 
            OpenCSVReader reader = new OpenCSVReader(parser,contentfile,newLineToUse,false);//unix user only \r
            List<List<String>>lstDataRow = reader.readAll();
            
            //TH:06/09/2021:US-0010030:Check column number
            Integer columnNumber = lstDataRow[0].size();
            if(columnNumber < minColumnNumber){
            	mResult = new Map<String, Object>{'isSuccess' => false,'errMsg' => System.label.Error_upload_Deal_Format};
            	return mResult;
            }
            //END US-0010030
            
            //TH: 08/02/2021 : US-0008668
            List<String> listCsvColumnNames = lstDataRow[0];
            listCsvColumnNames.add('Status');
            //END TH: 08/02/2021 : US-0008668
            
            lstDataRow.remove(0); //remove header
            //TH: 08/02/2021 : US-0008668
            if(isPreview){
            	List<List<String>> lstDataRowToProceed = new List<List<String>>();
		    	Integer counter = 0;
		    	while(counter<MassUploadObjectController.RECORD_LIMIT_FOR_PReVIEW && counter<lstDataRow.size()) {
		    		lstDataRowToProceed.add(lstDataRow[counter]);
		    		counter++;
		    	}
		    	
		    	createRecordsFromCSVFile(parentId, lstDataRowToProceed);
		    	
		    	List<MassUploadObjectController.ObjDTO> listSObjectDTO = new List<MassUploadObjectController.ObjDTO>();
		    
		    	integer rowNum = 0;
		    	for(List<String> dataRow : lstDataRowToProceed){
		    		rowNum++;
		    		MassUploadObjectController.ObjDTO sObjectDTO = new MassUploadObjectController.ObjDTO();
					sObjectDTO.lstCell = dataRow;
					if(mapError.containsKey(rowNum)){
						sObjectDTO.status = toFormatString(mapError.get(rowNum)).replace('<br/>',' ; ');
					}else{
						sObjectDTO.status = 'OK';
					}
					listSObjectDTO.add(sObjectDTO);
		    	}
		    	mResult.put('data', listSObjectDTO); 
            }//END TH: 08/02/2021 : US-0008668
            else{
            	List<EBH_Deal__c>lst2Insert = createRecordsFromCSVFile(parentId, lstDataRow);
	        	 if(!lst2Insert.isEmpty()){
	           		insert lst2Insert;
	        	}
	        	
	        	mResult.put('successRecord', lst2Insert.size());             
	            mResult.put('lstRecord', lst2Insert);
	            mResult.put('listError', toFormatString(listError));
	            mResult.put('errorSome', !listError.isEmpty());
            
            }
            mResult.put('columns', listCsvColumnNames);
        }catch(Exception ex){mResult = new Map<String, Object>{'isSuccess' => false,'errMsg' => ex.getMessage()  +' '+ ex.getStackTraceString()};
        }
        return mResult;
            
    }
    
    private static String toFormatString(String[] listStr)
    {  
      String str = '';
      for(String s : listStr)
      {
        str+=s+'<br/>';
      }
      
      return str;
      
    }
    static List<String> listError;
    static Map<Integer, List<String>> mapError;
    private static List<EBH_Deal__c> createRecordsFromCSVFile(String parentId, List<List<String>>lstDataRow){
        List<EBH_Deal__c>lstRecord = new List<EBH_Deal__c>();
        Map<String,String> mapSeller = new Map<String,String>();
        Set<String> setSeller = new Set<String>();
        Set<String> setSpotLightEXT = new Set<String>();
        
        //check which template to use, old or new
        Integer templateVersion = lstDataRow[0].size() <= (mappedIndexColName.size()+1)? 1: 2;
        Map<Integer, MappedField> mapRealFieldColumn = (templateVersion == 1 ?mappedIndexColName : mappedIndexColName_v2);
        
        for(List<String>dataRow : lstDataRow){
          setSeller.add(dataRow[1]);
          
          if(templateVersion==2 && String.isNotBlank(dataRow[15]))
          {
          	setSpotLightEXT.add(dataRow[15].trim());
          }
        }
        
        Map<String,String> mapSpotLight =  findSpotLight(setSpotLightEXT);
        
        for(Account es:[Select Id,Name from Account where Name IN:setSeller])
        {
          mapSeller.put(es.Name,es.Id);
        }
        listError = new List<String> ();
        mapError = new Map<Integer, List<String>>();
        integer rowNum = 0;
        
        
        for(List<String> dataRow : lstDataRow){
        	
          rowNum++;
          
          if(isEmptyRow(dataRow))
          {
            continue;
          }
            //Deal__c deal = new Deal__c(Account= parentId);
            String realSellerId = mapSeller.get(dataRow[1]);
             if(realSellerId==null)
             {
             	String errorMss = 'Seller Not Found:"'+dataRow[1]+'" At Row:'+rowNum;
               listError.add(errorMss);
               mapMessageError(rowNum, errorMss);//TH: 08/02/2021 : US-0008668
               continue;
             }
            EBH_Deal__c deal = new EBH_Deal__c(EBH_BusinessName__c = realSellerId);
            Boolean hasError = false;
            for(Integer i=0;i<dataRow.size();i++){
                String strValue = dataRow[i];
                MappedField mapField = mapRealFieldColumn.get(i);//mappedIndexColName.get(i);
                if(mapField == null || String.isBlank(mapField.fieldName)) continue;
                
                //NK:08/11/2017
                if(String.isBlank(strValue) && isRequired(mapField.fieldName))
                {
                  hasError = true;
                  String errorMss = 'Required field missing value('+mapField.fieldName+'). At row: '+rowNum+', col: '+(i+1);
                  listError.add(errorMss);
                  mapMessageError(rowNum, errorMss);//TH: 08/02/2021 : US-0008668 
                  continue;
                }
                Object dataValue;
                try 
                {
                  dataValue = getValueByType(mapField.fieldType, strValue);
                }catch(Exception ex)
                {
                  hasError = true;
                  String errorMss = ex.getMessage()+'" At Row:'+rowNum+', col: '+(i+1);
                  listError.add(errorMss);
                  mapMessageError(rowNum,errorMss);//TH: 08/02/2021 : US-0008668 
                  //break; //go to next row
                }
                
                if(mapField.fieldName == 'EBH_SpotlightCategory__c')
                {
                	//spotlight cat ext id provided but not found in the system
                	if(String.isNotBlank(strValue) && !mapSpotLight.containsKey(strValue.trim()))
                	{
                		hasError = true;
                		String errorMss = 'Spotlight Category is not found: ('+strValue+'). At row: '+rowNum+', col: '+(i+1);
	                  	listError.add(errorMss);
	                  	mapMessageError(rowNum,errorMss);//TH: 08/02/2021 : US-0008668 
	                  	continue;
                	}
                	dataValue = mapSpotLight.get(strValue.trim());
                }
                
                if(mapField.fieldName == 'EBH_DealFormat__c') dataValue = mDealFormat.containsKey(strValue) ? mDealFormat.get(strValue) : strValue;
                deal.put(mapField.fieldName, dataValue);
            }
            //if(String.isEmpty(deal.EBH_eBayItemID__c)) continue;
           
            if(!hasError)
            {
              deal.EBH_DealPrice__c = (templateVersion==1? deal.EBH_SellerPrice__c:deal.EBH_DealPrice__c);//NK:19/06/2019: EPH-7502: keep the old logic for old template
              //NK:25/05/2018: //EPH-5771
              // deal.EBH_DealSiteId__c =  EBH_ConstantsUtility.MAP_SITE_CODE_ID.containsKey((deal.EBH_DealSiteId__c+'').toUpperCase()) ? 
	            //   EBH_ConstantsUtility.MAP_SITE_CODE_ID.get((deal.EBH_DealSiteId__c+'').toUpperCase())
	            //   :EBH_ConstantsUtility.MAP_SITE_CODE_ID.get('DE'); //default DE

              // 03.06.2022 / Sophal Noch / US-0011721 :
              deal.EBH_DealSiteId__c =  String.isNotBlank(deal.EBH_DealSiteId__c) && deal.EBH_DealSiteId__c.isNumeric() ? deal.EBH_DealSiteId__c 
                : (ApexUtil.MAP_COUNTRY_CODE.containsKey((deal.EBH_DealSiteId__c+'').toUpperCase()) ? ApexUtil.MAP_COUNTRY_CODE.get((deal.EBH_DealSiteId__c+'').toUpperCase()) : ApexUtil.MAP_COUNTRY_CODE.get('DE')); //default DE
              
              lstRecord.add(deal);
              
            }
        }
        return lstRecord;
    }
    
    private static Object getValueByType(String fieldType, String fieldValue){
        Boolean isEmpty = String.isEmpty(fieldValue);
        if(fieldType == DATA_TYPE_DECIMAL) {
            fieldValue = fieldValue.replaceAll('[^0-9.,]', '');
            fieldValue = locale=='en'?fieldValue.replace(',',''):fieldValue.replace('.','').replace(',','.'); //convert number with format to system number
            return isEmpty ? null : Decimal.valueOf(fieldValue);//NK :08/11/2017:changed from zero to null
        //16. Feb 17
        }else if(fieldType == DATA_TYPE_DATE){
            if(isEmpty) return null; //NK:changed from Date.today() to null
            
            List<String>dateSplit = new List<String>();
            //if(fieldValue.contains('.')) dateSplit = fieldValue.replace('.', '').split(' ');
            //else if(fieldValue.contains('-')) dateSplit = fieldValue.split('-');
            //else if(fieldValue.contains('/')) dateSplit = fieldValue.split('/');
            
            if(!isValidDate(fieldValue))
            {
              throw new FieldFormatException('Invalid Date Format: "'+fieldValue+'". Expected: dd/mm/yyyy.');
            }
            dateSplit = fieldValue.split('/');
            String yearString = dateSplit[2].length() == 2 ? '20' + dateSplit[2] : dateSplit[2];
            Integer year = Integer.valueOf(yearString.trim());
            //Integer month = mMonth.get(dateSplit[1].trim());
            Integer month = Integer.valueOf(dateSplit[1].trim());  //no mapping need since restricted format
            Integer day = Integer.valueOf(dateSplit[0].trim());
            
            return Date.newInstance(year, month, day);
            
        }else if(fieldType == DATA_TYPE_TIME)//NK:13/06/2019:EPH-7247
        {
        	 if(isEmpty) return null;
        	 Time t = isValidTime(fieldValue);
        	 if(t==null)
        	 {
        	 	throw new FieldFormatException('Invalid Time Format: "'+fieldValue+'". Expected: HH:MM.');
        	 }
        	 return t;
        }        
        else if(fieldType == DATA_TYPE_NUMBER){
            fieldValue = fieldValue.replaceAll('[^0-9]', '');
            return isEmpty ? null : Integer.valueOf(fieldValue); //NK :08/11/2017:changed from zero to null
        }
        return fieldValue;
    }
    // dd/mm/yyyy
    private static Boolean isValidDate(String strDate)
    {
      String[] dateStrArr = strDate.split('/');
       
        return dateStrArr.size()==3;
      
    }
    //valid time: 10:00, 20:00,... HH:MM
    private static Time isValidTime(String strTime)
    {
    	strTime = strTime.trim();
    	if(strTime.contains(' ') || !strTime.contains(':')) //10:00 AM? 
    	{
    		return null;
    	}
    	String[] strTimes = strTime.split(':');
    	Time myTime = null;
    	
    	try
    	{
    		myTime = Time.newInstance(ApexUtil.toInteger(strTimes[0]),ApexUtil.toInteger(strTimes[1]),0,0);
    	}catch(Exception ex)
    	{
	   		System.debug(ex);
    	}
    	
    	return myTime;
    	 
    }
    //check row is empty
    private static Boolean isEmptyRow(String[] rowData)
    {
      String s = String.join(rowData,'').trim();
       
    return String.isEmpty(s) ;
    }
    public class MappedField{
        public String fieldName;
        public String fieldType;
        public MappedField(String fieldName, String fieldType){
            this.fieldName = fieldName;
            this.fieldType = fieldType;
        }       
    }
  
  //NK:08/11/2017
  static Map<String, Schema.SObjectField> allFieldDes = Schema.getGlobalDescribe().get('EBH_Deal__c').getDescribe().fields.getMap();
  public static Boolean isRequired(String fName)
  {
    return !allFieldDes.get(fName).getDescribe().isNillable() || setRequiredFields.contains(fName);
       
  }
  
  //NK:08/07/2019: EPH-7761
  public static Map<String,String> findSpotLight(Set<String> setExtId)
  {
  	 Map<String,String> mapResult = new Map<String,String>();
  	 for(EBH_SpotlightCategory__c sc: Database.query(EBH_ConstantsUtility.SOQL_SPOTLIGHT_CAT + ' Where EBH_SpotlightCategoryID__c IN:setExtId'))
  	 {
  	 	mapResult.put(sc.EBH_SpotlightCategoryID__c,sc.Id);
  	 }
  	 
  	 return mapResult;
  }
  
  //TH : 08/02/2021: US-0008668 
  private static void mapMessageError(Integer rowNum, String mssg){
  	 List<String> lstError = (mapError.containsKey(rowNum)) ? mapError.get(rowNum) : new List<String>();
  	 lstError.add(mssg);
  	 mapError.put(rowNum,lstError);      
  }
  
  class FieldFormatException extends Exception{}    
   
}