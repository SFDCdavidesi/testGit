@isTest
//NK:10/02/2012: depreciated CheckDelivery. moved to batch
public class TST_LC_CheckDelivery {

  static testMethod void test_method(){
      LC_CheckDelivery obj = new LC_CheckDelivery();

      LC_CreateMediaPlanController obj1 = new LC_CreateMediaPlanController();
  }
	
	//static TestDataGenerator testDATA = new TestDataGenerator();

    // public static Quote quote;
    // public static QuoteLineItem qli;
    // public static AdServer_Login__c login;
    // public static IO__c io;
    // public static IO_LineItem__c IOline;
    
    // public static AdServer_Login__c[] listLogin;
    // public static Account[] lstAcc;
    // public static Targeting__c[] targetting;
    // public static Content__c[] contents;
    // public static Advertiser__c[] lstAdvertiser;
    
    // public static Ad_Campaign__c adc;
    // //public Region__c[] regions;

    // //public AreaCode__c[] areaCodes;
    // //public City__c[] cities;
    // public static Site__c[] sites;
    // public static Country__c[] countries;
    // public static GAM_Key_Value__c[] keyvalues;
    // private static Placement__c[] lstPlacements;
    // public static Devices__c[] lstDevices;
    // public static Connection__c[] lstConns;
    // public static Geography__c[] lstGeographies;
    // public static User userAdmin;
    // private static User currentUser = [ select Id, Name from User where Id = :UserInfo.getUserId() ]; 
    // public static final String TESTINGCURRENCY = 'USD';
    

    // @TestSetup static void setup(){
    // 	TST_DataGenerator.setupSimpleData(new Set<String>{'Account', 'Opportunity', 'Quote', 'QuoteLineItem','IO__c','IO_LineItem__c'});
    //     sites = QueryUtil.queryRecords(Util.NS + 'Site__c');
    //     TestDARTCodeCoverage.createTestUser();//createTestUser();
    //     TestDARTCodeCoverage.createCredential();//createCredential();
    //     TestDARTCodeCoverage.createTargetingHierarchy();
    //     TestDARTCodeCoverage.createAccount();
    //     TestDARTCodeCoverage.createAdvertiser();
        
    //     //testDATA.createOpp(testDATA.lstAcc.get(0));
    //     //testDATA.createOppTeamMember(testDATA.opp.id);
    //     //testDATA.createNewOppItemsDart(testDATA.opp.id,2,DARTUtil.DART6,testDATA.targetting[0].Id);
    //     //createTargetingKVHierarchy();
    //     keyvalues = TestDARTCodeCoverage.createTargetingKVHierarchy();
    // 	login = TST_DataGenerator.generateAdServerLogin();

    // 	insert login;
    	
    // }

      //@vitou 13-05-2015
      //NK:10/02/2021:US-0008913:depreciated use batch instead
    // static void getTestData(){
    //     logIn = [select id, Refresh_Token__c, Client_Id__c, Client_Secret__c,ExternalLineDescriptionId__c, Network_ID__c from AdServer_Login__c where Name='Test' limit 1];
	// 	quote = (Quote) QueryUtil.queryRecords('Quote','ID<>null limit 1').get(0);  
    // 	qli = (QuoteLineItem ) QueryUtil.queryRecords('QuoteLineItem', 'Id<> null AND QuoteId=\'' + quote.Id + '\' limit 1 ',DFPController.DFP_QUOTE_ADDITIONAL_FIELD, new Map<String,Object>()).get(0);

    //     qli.Targeting__c =  QueryUtil.queryRecords(Util.NS +'Targeting__c','ID<>null limit 1').get(0).Id;
    //     update  qli;    
    // 	io = (IO__c) QueryUtil.queryRecords(Util.NS + 'IO__c','ID<>null limit 1', new Set<String>{'Owner.Name', Util.NS + 'Advertiser__r.Name'}, new Set<String>()).get(0);
    	
    // 	IOline = (IO_LineItem__c ) QueryUtil.queryRecords(Util.NS + 'IO_LineItem__c', 'Id<> null limit 1', DFPController.DFP_IO_ADDITIONAL_FIELD, new Map<String,Object>()).get(0);
    	
    // 	IOline.Ad_Id__c = '9347894237';
    // 	IOline.from_Date__c = System.today();
    // 	update IOline;
    	
    // 		sites = QueryUtil.queryRecords(Util.NS + 'Site__c');
    // 		lstAcc = QueryUtil.queryRecords('Account');
    // 		lstAdvertiser = QueryUtil.queryRecords(Util.NS + 'Advertiser__c');
    //         targetting = QueryUtil.queryRecords(Util.NS + 'Targeting__c');
        
    //     insert new Ad_Campaign__c(Name = 'Test Campaign 001', IO__c = io.Id, Start_Date__c = System.Today());
    // }
    
    // @isTest static void test_createDFPReportJob(){
    // 	getTestData();
    	
    // 	Test.startTest();
    //         RemoteResponse response =  LC_CheckDelivery.createDFPReportJob(io.Id);
    //         System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_OK);

    //     Test.stopTest();
    // }
    
    // @isTest static void test_checkDFPReportJobStatus(){
    // 	getTestData();
    	
    // 	Test.startTest();
    //         RemoteResponse response =  LC_CheckDelivery.checkDFPReportJobStatus(io.Id, '');
    //         System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_ERROR);

    //     Test.stopTest();
    // }
    
    // @isTest static void test_downloadDFPReportAndUpdateSF(){
    // 	getTestData();
    	
    // 	Test.startTest();
    //         RemoteResponse response =  LC_CheckDelivery.downloadDFPReportAndUpdateSF(io.Id, '');
    //         System.assertEquals(response.statusCode, RemoteResponse.STATUSCODE_ERROR);

    //     Test.stopTest();
    // }
    
    
       /**
     * create advetiser test records
     */
    // public static void createAdvertiser()
    // {
    //     System.runAs(currentUser){
    //         lstAdvertiser = new List<Advertiser__c>();
    //         Advertiser__c advertiser1 = new Advertiser__c(Account__c=lstAcc.get(0).id, Agency__c=lstAcc.get(0).id);
    //         lstAdvertiser.add(advertiser1);
    //         Advertiser__c advertiser2 = new Advertiser__c(Account__c=lstAcc.get(1).id, Agency__c=lstAcc.get(1).id, DART5_Advertiser_Id__c='111111', DART6_Advertiser_Id__c='222222');
    //         lstAdvertiser.add(advertiser2);
            
    //         insert lstAdvertiser;
    //     }
    // }
    

    /**
     * create AdserverLogin records
     */
    // public static void createCredential(){
    //     TestDARTCodeCoverage.createCredential('DE');
    // }
    /**
     * create AdserverLogin records
     */
    // public static void createCredential(String country)
    // {
    //     System.runAs(userAdmin){
            
    //         AdServer_Login__c login6 = new AdServer_Login__c(RecordTypeId=[Select id, name From RecordType Where  Name=: DARTUtil.DART6 AND SobjectType =:Util.NS+'AdServer_Login__c' limit 1].id,
    //             Name = country,
    //             Login_URL__c='http://test.com',
    //             User_Name__c='dart6testuser@gmail.com',
    //             Password__c ='testpwddart6123456',
    //             Active__c = true,
    //             Network_ID__c='123456',
    //             Client_ID__c = 'xxxxxxxxxxxxxxxxxxxxx',
    //             Client_Secret__c = 'xxxxxxxxxxxxxxx',
    //             Refresh_Token__c = 'xxxxxxxxxxx'
    //             );
                
    //             listLogin = new List<AdServer_Login__c>{login6};
    //             insert listLogin;
    //     }     
    // }
 
    /**
     * Type:
     * Dart - Site
     * Dart - Zone
     * Dart - ContentCategory
     * @param number of record to be created
     * @param list type of content
     */
    // public static void createContents(Integer numToCreate,List<String> ctype)
    // {
    //     System.runAs(currentUser){
    //         contents = new List<Content__c>();
    //         for(Integer i=0;i<numToCreate;i++)
    //         {
    //             Content__c c = new Content__c(Name='4000'+i,DartName__c='DartName'+i,Type__c=ctype[i]);
    //             contents.add(c);
    //         }
    //         insert contents;
    //     }
    // }

    /**
     * create DartKeyvalue2 test records
     * @param number of records to be created
     */
    // public static void createKV(Integer numToCreate)
    // {
    //     System.runAs(currentUser){
    //         keyvalues = new List<GAM_Key_Value__c>();
    //         for(Integer i=0;i<numToCreate;i++)
    //         {
    //             GAM_Key_Value__c kv = (GAM_Key_Value__c)TestDARTCodeCoverage.createKeyOrValueOrAS('as','red','DE','999999');//new GAM_Key_Value__c(Name='DE RTM Targeting'+i,Key__c='seg'+i,Key_Value__c='seg'+i,Key_Value_Name__c='DE RTM Targeting',Active__c=true);
    //             keyvalues.add(kv);
    //         }
    //         insert keyvalues;
    //     }
    // }
    
    /**
     * create targeting test records
     * @param number of records to be created
     */
    // public static void createTargetings(Integer numToCreate)
    // {
    //     System.runAs(currentUser){
    //         targetting = new List<Targeting__c>();
    //         for(Integer i=0;i<numToCreate;i++)
    //         {
    //             Targeting__c t = new Targeting__c(Description__c='test');
    //             targetting.add(t);
    //         }
    //         insert targetting;
    //     }
    // }
    
    //13/01/2015 - to create Devices for testing
    // public static void createDevices() {
    //     System.runAs(currentUser){
    //         lstDevices = new List<Devices__c>();
    //         Devices__c dev1 = new Devices__c(Name = 'Test1', Dart_ID__c=123456, DFP_API_Name__c='DeviceManufacturer');
    //         insert dev1;
    //         Devices__c dev2 = new Devices__c(Name = 'Test2', Dart_ID__c=555555, Node_ID__c= dev1.Id, DFP_API_Name__c='DeviceCategory');
    //         insert dev2;
    //         Devices__c dev3 = new Devices__c(Name = 'Test3', Dart_ID__c=333333, Node_ID__c= dev1.Id, DFP_API_Name__c='DeviceCategory');
    //         insert dev3;
    //         lstDevices.add(dev1);
    //         lstDevices.add(dev2);
    //         lstDevices.add(dev3);
    //         //Dev Browser
    //         Devices__c devDv = new Devices__c(Name = 'Test', Dart_ID__c=09089, Node_ID__c= dev1.Id, DFP_API_Name__c='Browser');
    //         insert devDv;
    //         Devices__c devDv1 = new Devices__c(Name = 'Test', Dart_ID__c=12678, Node_ID__c= devDv.Id);
    //         insert devDv1;
    //         lstDevices.add(devDv);
    //         lstDevices.add(devDv1);
    //         // BrowserLanguage
    //         Devices__c devBl = new Devices__c(Name = 'Test', Dart_ID__c=555550, Node_ID__c= dev1.Id, DFP_API_Name__c='BrowserLanguage');
    //         insert devBl;
    //         Devices__c devBl1 = new Devices__c(Name = 'Test3', Dart_ID__c=555551, Node_ID__c= devBl.Id);
    //         insert devBl1;
    //         lstDevices.add(devBl);
    //         lstDevices.add(devBl1);
    //         //DeviceCapability
    //         Devices__c devDc = new Devices__c(Name = 'Test', Dart_ID__c=444440, Node_ID__c= dev1.Id, DFP_API_Name__c='DeviceCapability');
    //         insert devDc;
    //         Devices__c devDc1 = new Devices__c(Name = 'Test3', Dart_ID__c=444441, Node_ID__c= devDc.Id);
    //         insert devDc1;
    //         lstDevices.add(devDc);
    //         lstDevices.add(devDc1);
    //         //OperatingSystem
    //         Devices__c devOs = new Devices__c(Name = 'Test', Dart_ID__c=333330, Node_ID__c= dev1.Id, DFP_API_Name__c='OperatingSystem');
    //         insert devOs;
    //         Devices__c devOs1 = new Devices__c(Name = 'Test3', Dart_ID__c=333331, Node_ID__c= devOs.Id);
    //         insert devOs1;
    //         lstDevices.add(devOs);
    //         lstDevices.add(devOs1);
    //         //OperatingSystemVersion
    //         Devices__c devOsv = new Devices__c(Name = 'Test', Dart_ID__c=222220, Node_ID__c= dev1.Id, DFP_API_Name__c='OperatingSystemVersion');
    //         insert devOsv;
    //         Devices__c devOsv1 = new Devices__c(Name = 'Test3', Dart_ID__c=222221, Node_ID__c= devOsv.Id);
    //         insert devOsv1;
    //         lstDevices.add(devOsv);
    //         lstDevices.add(devOsv1);
    //         //MobileDevice
    //         Devices__c devMd = new Devices__c(Name = 'Test', Dart_ID__c=111110, Node_ID__c= dev1.Id, DFP_API_Name__c='MobileDevice');
    //         insert devMd;
    //         Devices__c devMd1 = new Devices__c(Name = 'Test3', Dart_ID__c=111100, Node_ID__c= devMd.Id);
    //         insert devMd1;
    //         lstDevices.add(devMd);
    //         lstDevices.add(devMd1);
    //         //MobileDeviceSubmodel
    //         Devices__c devMds = new Devices__c(Name = 'Test', Dart_ID__c=404040, Node_ID__c= dev1.Id, DFP_API_Name__c='MobileDeviceSubmodel');
    //         insert devMds;
    //         Devices__c devMds1 = new Devices__c(Name = 'Test3', Dart_ID__c=404041, Node_ID__c= devMds.Id);
    //         insert devMds1;
    //         lstDevices.add(devMds);
    //         lstDevices.add(devMds1);
    //     }
    //  }
    
    //13/01/2015 - to create Connection for testing 
    //  public static void createConnections() {
    //     System.runAs(currentUser){
    //         lstConns = new List<Connection__c>();
    //         Connection__c conn1 = new Connection__c(Name = 'Test1', Dart_ID__c=123456, DFP_API_Name__c='BandwidthGroup');
    //         insert conn1;
    //         Connection__c conn2 = new Connection__c(Name = 'Test3', Dart_ID__c=111111, DFP_API_Name__c='MobileCarrier');
    //         insert conn2;
    //         Connection__c conn3 = new Connection__c(Name = 'Test1', Dart_ID__c=666666, Node_ID__c = conn1.Id);
    //         insert conn3;
            
    //         Connection__c conn4 = new Connection__c(Name = 'Test1', Dart_ID__c=121213, Node_ID__c = conn2.Id);
    //         insert conn4;
    //         Connection__c conn5 = new Connection__c(Name = 'Test3', Dart_ID__c=131414, Node_ID__c = conn2.Id);
    //         insert conn5;
    
    //         lstConns.add(conn1);
    //         lstConns.add(conn2);
    //         lstConns.add(conn3);
    //         lstConns.add(conn4);
    //         lstConns.add(conn5);
    //     }
    // }
    
    
    //13/01/2015 - to create Geography for testing
    // public static void createGeographies() {
    //     System.runAs(currentUser){
    //         lstGeographies = new List<Geography__c>();
    //         Geography__c geo1 = new Geography__c(Name = 'Test1', Dart_ID__c=123456, Type__c = 'COUNTRY');
    //         insert geo1;
    //         Geography__c geo2 = new Geography__c(Name = 'Test2', Dart_ID__c=888888, Type__c = 'CITY', Node_ID__c=geo1.Id);
    //         insert geo2;
    //         Geography__c geo3 = new Geography__c(Name = 'Test3', Dart_ID__c=999999, Type__c = 'CITY', Node_ID__c=geo2.Id);
    //         insert geo3;
    //         lstGeographies.add(geo1);
    //         lstGeographies.add(geo2);
    //         lstGeographies.add(geo3);
    //     } 
    // }
    
    /**
     * create targeting Association
     */ 
    // public static void createTargetingHierarchy()
    // {
    //     System.runAs(currentUser){
    //         List<Sobject> listObj = new List<SObject>();
    //         TestDARTCodeCoverage.createTargetings(1);
            
    //         ////country + assoc
    //         //createCountries(1);
    //         //TargetingCountryAssociation__c countryAssoc = new TargetingCountryAssociation__c(TargetCountry__c='TestCountry', Targeting__c=targetting[0].Id, Country__c=countries[0].Id);
    //         //listObj.add(countryAssoc);
            
    //         ////city +  assoc
    //         //createCities(1,countries[0].Id);
    //         //TargetingCityAssociation__c cityAsso =new TargetingCityAssociation__c(targetcity__c='TestCity',Targeting__c=targetting[0].Id,City__c=cities[0].Id);
    //         //listObj.add(cityAsso);
            
    //         //// Regions
    //         //createRegions(1);
    //         //TargetingRegionAssociation__c regionAss =new    TargetingRegionAssociation__c(  TargetRegion__c='TestRegion',Targeting__c=targetting[0].Id, Region__c=regions[0].Id);
    //         //listObj.add(regionAss);
            
    //         ////area +  assoc
    //         //createAreaCodes(1);
    //         //TargetingAreaCodeAssociation__c tgArea = new TargetingAreaCodeAssociation__c(AreaCode__c=areaCodes[0].Id,Targeting__c=targetting[0].Id);
    //         //listObj.add(tgArea);
            
    //         ////kv +  assoc
    //         //createKV(1);
    //         GAM_Key_Value__c k1 = (GAM_Key_Value__c)TestDARTCodeCoverage.createKeyOrValueOrAS('k','car','DE','999999');
    //         insert k1;

    //         TargetingKeyValueAssociation__c kvAssoc = new TargetingKeyValueAssociation__c(GAM_Key_Value__c=keyvalues[0].Id,Targeting__c=targetting[0].Id);
    //         listObj.add(kvAssoc);
            
    //         //content +  assoc
    //         contents= TestDARTCodeCoverage.createContents(3,new List<String>{'Dart - Site','Dart - Zone','Dart - Zone'});
    //         TargetingContentAssociation__c contAssoc = new TargetingContentAssociation__c(Target_Content_Key__c='key',Targeting__c=targetting[0].Id,TargetingContent__c=contents[0].Id);
    //         TargetingContentAssociation__c contAssoc2 = new TargetingContentAssociation__c(Target_Content_Key__c='key-111',Targeting__c=targetting[0].Id,TargetingContent__c=contents[1].Id);
    //         listObj.add(contAssoc);
    //         listObj.add(contAssoc2);
    
    //         //Placement +  assoc
    //         //Chr: @updated 05-09-2014: Comment out this block of code in order to avoid dependency when deploy to UAT
    //         lstPlacements =  TestDARTCodeCoverage.createPlacement();
    //         PlacementTargetingAssociation__c placementAssoc = new PlacementTargetingAssociation__c(Targeting__c=targetting[0].Id, Placement__c=lstPlacements[0].id);
    //         listObj.add(placementAssoc);
            
    //         // 13/01/2015 device + asso
    //         lstDevices = TestDARTCodeCoverage.createDevices();
    //         TargetingDeviceAssociation__c devAssoc = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev', Targeting__c=targetting[0].Id, Device__c = lstDevices[0].id);
    //         listObj.add(devAssoc);
    //         TargetingDeviceAssociation__c devAssoc2 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev2', Targeting__c=targetting[0].Id, Device__c = lstDevices[1].id);
    //         listObj.add(devAssoc2);
    //         TargetingDeviceAssociation__c devAssoc3 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev3', Targeting__c=targetting[0].Id, Device__c = lstDevices[2].id);
    //         listObj.add(devAssoc3);
    //         TargetingDeviceAssociation__c devAssoc4 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev2', Targeting__c=targetting[0].Id, Device__c = lstDevices[3].id);
    //         listObj.add(devAssoc4);
    //         TargetingDeviceAssociation__c devAssoc5 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev3', Targeting__c=targetting[0].Id, Device__c = lstDevices[4].id);
    //         listObj.add(devAssoc5);
    //         TargetingDeviceAssociation__c devAssoc6 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev2', Targeting__c=targetting[0].Id, Device__c = lstDevices[5].id);
    //         listObj.add(devAssoc6);
    //         TargetingDeviceAssociation__c devAssoc7 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev3', Targeting__c=targetting[0].Id, Device__c = lstDevices[6].id);
    //         listObj.add(devAssoc7);
    //         TargetingDeviceAssociation__c devAssoc8 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev2', Targeting__c=targetting[0].Id, Device__c = lstDevices[7].id);
    //         listObj.add(devAssoc8);
    //         TargetingDeviceAssociation__c devAssoc9 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev3', Targeting__c=targetting[0].Id, Device__c = lstDevices[8].id);
    //         listObj.add(devAssoc9);
    //         TargetingDeviceAssociation__c devAssoc10 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev2', Targeting__c=targetting[0].Id, Device__c = lstDevices[9].id);
    //         listObj.add(devAssoc10);
    //         TargetingDeviceAssociation__c devAssoc11 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev3', Targeting__c=targetting[0].Id, Device__c = lstDevices[10].id);
    //         listObj.add(devAssoc11);
    //         TargetingDeviceAssociation__c devAssoc12 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev2', Targeting__c=targetting[0].Id, Device__c = lstDevices[11].id);
    //         listObj.add(devAssoc12);
    //         TargetingDeviceAssociation__c devAssoc13 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev3', Targeting__c=targetting[0].Id, Device__c = lstDevices[12].id);
    //         listObj.add(devAssoc13);
    //         TargetingDeviceAssociation__c devAssoc114 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev2', Targeting__c=targetting[0].Id, Device__c = lstDevices[13].id);
    //         listObj.add(devAssoc114);
    //         TargetingDeviceAssociation__c devAssoc15 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev3', Targeting__c=targetting[0].Id, Device__c = lstDevices[14].id);
    //         listObj.add(devAssoc15);
    //         TargetingDeviceAssociation__c devAssoc16 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev2', Targeting__c=targetting[0].Id, Device__c = lstDevices[15].id);
    //         listObj.add(devAssoc16);
    //         TargetingDeviceAssociation__c devAssoc17 = new TargetingDeviceAssociation__c(TargetDevice__c='TestDev3', Targeting__c=targetting[0].Id, Device__c = lstDevices[16].id);
    //         listObj.add(devAssoc17);
            
    //          //Connection + asso
    //         lstConns= TestDARTCodeCoverage.createConnections();
    //         TargetingConnectionAssociation__c connAssoc = new TargetingConnectionAssociation__c(TargetConnection__c='TestConn', Targeting__c=targetting[0].Id, Connection__c = lstConns[0].id);
    //         listObj.add(connAssoc);
    //         TargetingConnectionAssociation__c connAssoc2 = new TargetingConnectionAssociation__c(TargetConnection__c='TestConn2', Targeting__c=targetting[0].Id, Connection__c = lstConns[1].id);
    //         listObj.add(connAssoc2);
    //         TargetingConnectionAssociation__c connAssoc3 = new TargetingConnectionAssociation__c(TargetConnection__c='TestConn3', Targeting__c=targetting[0].Id, Connection__c = lstConns[2].id);
    //         listObj.add(connAssoc3);
    //         TargetingConnectionAssociation__c connAssoc4 = new TargetingConnectionAssociation__c(TargetConnection__c='TestConn2', Targeting__c=targetting[0].Id, Connection__c = lstConns[3].id);
    //         listObj.add(connAssoc4);
    //         TargetingConnectionAssociation__c connAssoc5 = new TargetingConnectionAssociation__c(TargetConnection__c='TestConn3', Targeting__c=targetting[0].Id, Connection__c = lstConns[4].id);
    //         listObj.add(connAssoc5);
            
    //         //geography + assoc
    //         lstGeographies = TestDARTCodeCoverage.createGeographies();
    //         TargetingGeographyAssociation__c geoAssoc = new TargetingGeographyAssociation__c(TargetGeography__c='TestGeo', Targeting__c=targetting[0].Id, Geography__c = lstGeographies[0].id);
    //         listObj.add(geoAssoc);
    //         TargetingGeographyAssociation__c geoAssoc2 = new TargetingGeographyAssociation__c(TargetGeography__c='TestGeo2', Targeting__c=targetting[0].Id, Geography__c = lstGeographies[1].id);
    //         listObj.add(geoAssoc2);
    //         TargetingGeographyAssociation__c geoAssoc3 = new TargetingGeographyAssociation__c(TargetGeography__c='TestGeo3', Targeting__c=targetting[0].Id, Geography__c = lstGeographies[2].id);
    //         listObj.add(geoAssoc3);
            
    //         insert listObj;
    //     }
    // }
    
    /**
     * create GAM_Key_Value__c test records
     */
    // public static void createTargetingKVHierarchy()
    // {
    //     System.runAs(currentUser){
    //         //createSite(new Set<String>{'DE'});
            
    //         keyvalues = new List<GAM_Key_Value__c>(); 
            
    //         // Key Free-form 
    //         GAM_Key_Value__c k1 = new GAM_Key_Value__c(Dart6_KeyId__c=11111,Name='car test',Key__c='car',Key_Value__c='car',Key_Value_Name__c='car',Active__c=true, Site__c=sites.get(0).id, Key_ValueType_FreeForm__c=true);
    //         insert k1;
            
    
    //         GAM_Key_Value__c val1 = new GAM_Key_Value__c(Node_ID__c=k1.Id,Dart6_ValueId__c=22222,Name='bmw',Key_Value__c='bmw',Key_Value_Name__c='bmw',Active__c=true);
    //         GAM_Key_Value__c val2 = new GAM_Key_Value__c(Node_ID__c=k1.Id,Dart6_ValueId__c=null,Name='hummer',Key_Value__c='hummer',Key_Value_Name__c='hummer',Active__c=true);
    //         insert new GAM_Key_Value__c[]{val1,val2};
            
    //         // Key not Free-form
    //         GAM_Key_Value__c k2 = new GAM_Key_Value__c(Dart6_KeyId__c=123123,Name='color test',Key__c='color',Key_Value__c='color',Key_Value_Name__c='color',Active__c=true, Site__c=sites.get(0).id);
    //         insert k2;
            
    //         GAM_Key_Value__c val21 = new GAM_Key_Value__c(Node_ID__c=k2.Id,Dart6_ValueId__c=66666,Name='red',Key_Value__c='red',Key_Value_Name__c='red',Active__c=true);
    //         GAM_Key_Value__c val22 = new GAM_Key_Value__c(Node_ID__c=k2.Id,Dart6_ValueId__c=555555,Name='white',Key_Value__c='white',Key_Value_Name__c='white',Active__c=true);
    //         insert new GAM_Key_Value__c[]{val21,val22};
            
            
    //         keyvalues.add(k1);
    //         keyvalues.add(val1); 
    //         keyvalues.add(val2); 
    //         keyvalues.add(k2);
    //         keyvalues.add(val21); 
    //         keyvalues.add(val22);
            
    //         // Create Keyvalue Audience Segment
            
    //         List<GAM_Key_Value__c> lstKeyAs = [Select id, name, Key_Value__c, Key_Value_Name__c From GAM_Key_Value__c Where Key_Value__c='Audience Segment'];
    //         if(lstKeyAs.size()>0)
    //         {
                
    //             GAM_Key_Value__c asVal11 = new GAM_Key_Value__c(Node_ID__c=lstKeyAs.get(0).Id,Dart6_ValueId__c=999999,Name='Aud1',Key_Value__c='Aud1',Key_Value_Name__c='Aud1',Active__c=true);
    //             GAM_Key_Value__c asVal12 = new GAM_Key_Value__c(Node_ID__c=lstKeyAs.get(0).Id,Dart6_ValueId__c=888888,Name='Aud2',Key_Value__c='Aud2',Key_Value_Name__c='Aud2',Active__c=true);
    //             insert new GAM_Key_Value__c[]{asVal11,asVal12};
                
    //             keyvalues.addAll(lstKeyAs);
    //             keyvalues.add(asVal11);
    //             keyvalues.add(asVal12);
                
    //         }
    //         else
    //         {
    //             GAM_Key_Value__c kvAs = new GAM_Key_Value__c(Dart6_KeyId__c=123123,Name='Audience Segment',Key__c='Audience Segment',Key_Value__c='Audience Segment',Key_Value_Name__c='Audience Segment',Active__c=true);
    //             insert kvAs;
                
    //             GAM_Key_Value__c asVal1 = new GAM_Key_Value__c(Node_ID__c=kvAs.Id,Dart6_ValueId__c=999999,Name='Aud1',Key_Value__c='Aud1',Key_Value_Name__c='Aud1',Active__c=true);
    //             GAM_Key_Value__c asVal2 = new GAM_Key_Value__c(Node_ID__c=kvAs.Id,Dart6_ValueId__c=888888,Name='Aud2',Key_Value__c='Aud2',Key_Value_Name__c='Aud2',Active__c=true);
    //             insert new GAM_Key_Value__c[]{asVal1,asVal2};
                
    //             keyvalues.add(kvAs);
    //             keyvalues.add(asVal1);
    //             keyvalues.add(asVal2);
                
    //         }
            
            
    //           //TargetingKeyValueAssociation__c kvAssoc1 = new TargetingKeyValueAssociation__c(Name='kvAssocTest1',DARTKeyValue__c=val1.Id,Targeting__c=targetting[0].Id);
    //           //TargetingKeyValueAssociation__c kvAssoc2 = new TargetingKeyValueAssociation__c(Name='kvAssocTest2',DARTKeyValue__c=val2.Id,Targeting__c=targetting[0].Id);
    //           //insert new TargetingKeyValueAssociation__c[]{kvAssoc1,kvAssoc2};
    //     }   
            
        
        
    // }

    // private static void createPlacement()
    //  {
    //     System.runAs(currentUser){
    //         lstPlacements=new List<Placement__c>();
    //         Placement__c plc = new Placement__c(Name='test placement', Dart_ID__c=11111);
    //         lstPlacements.add(plc);
    //         insert lstPlacements;
    //     }
    //  }

    // public static void createAccount()
    // {
    //     System.runAs(currentUser){
    //         if(userAdmin==null) createTestUser();
    //         lstAcc = new List<Account>();
    //         for(Integer i=0; i<3; i++)
    //         {
    //             Account acc = new Account(
    //                         Name='Test Acc'+i,
    //                         //Country_Code__c='DE',
    //                         BillingStreet='Street', 
    //                         BillingPostalCode='1Nl1', 
    //                         BillingCity='City',
    //                         ownerId= userAdmin.Id
    //                       );
    //             lstAcc.add(acc);
    //         }
    //         insert lstAcc;  
    //     }
    // }

    // public static void createTestUser()
    // {
    //     System.runAs ( currentUser ) {
    //         Profile p=[Select Id, Name From Profile Where Name='System Administrator'  or Name='Systemadministrator' Limit 1];
    //         userAdmin = new User();
    //         userAdmin.Username='testUser1@boco.com';
    //         userAdmin.LastName='testLastName1';
    //         userAdmin.Email='testEmail1@boco.com';
    //         userAdmin.Alias='test1';
    //         userAdmin.TimeZoneSidKey='Pacific/kiritimati';
    //         userAdmin.LocaleSidKey='ar';
    //         userAdmin.EmailEncodingKey='UTF-8';
    //         userAdmin.ProfileId=p.Id;
    //         userAdmin.LanguageLocaleKey='en_US';   
    //         insert userAdmin;
    //     }                       
    // }
}