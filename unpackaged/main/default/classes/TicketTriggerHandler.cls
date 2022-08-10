/*********************************************************************************************************************************
@ Class:          TicketTriggerHandler
@ Version:        1.0
@ Author:         Vadhanak Voun (vadhanak.voun@gaea-sys.com)
@ Purpose:        Handler Class for Ticket Trigger
                  EPH-3309: User Creation
----------------------------------------------------------------------------------------------------------------------------------
@ Change history:  14.09.2017 / Vadhanak Voun /Created the class. 
@                  11.10.2017 / Samnang MUONG /Created the class and move logic from trigger
@                   20/07/2020/ vadhanak voun/ added PSL_WAVE_COMM, PSL_EA_MEMB 
*********************************************************************************************************************************/
public without sharing class TicketTriggerHandler {

    static Set<String> SET_ADMIN_PROFILES  = new Set<String>();
    static Map<String,String> MAP_GROUP_IDS = new Map<String,String>();
    static Map<String,String> MAP_PROFILES = new Map<String,String>();


    public final static String PSL_WAVE_COMM = 'WaveCommunitiesPsl'; //Analytics Cloud - Wave Community Users
    public final static String PSL_EA_MEMB = 'EinsteinAnalyticsForCommunityMembersPsl';//Einstein Analytics For Community Members

    /*****************************************************************************************************************************
    @ Method:         checkCreateUsers
    @ Version:        1.0
    @ Author:         Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:        EPH-3309: Automatic User creation on custom object "Ticket".
    @                  If the business / sys admin changes the status to "In progress", 
    @                  a user should be automatically created in Salesforce.    
    @ Event: 		before update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      list oldTrigger:  
    @                  list newTrigger: 
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        void
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  14.09.2017 / Vadhanak Voun /Created the Method. 
    @				   07/03/2019 / Vadhanak Voun /NK:EPH-7025: create contact for gcx partner profile
    @				   23/09/2019/ Vadhanak Voun/US-0015717 Survey ID - Read Only Field
    @			AC3: 
	@			Given that I am Admin 
	@			When I change status of Validate survey ticket to "Validated" ,the trigger updates the survey Id in Campaign.
	@			Then Validated survey.Survey ID is copied to the related Campaign. Survey ID.
	@			and the trigger updates the Ticket status is "Closed"
    @*****************************************************************************************************************************/
    public static void checkCreateUsers(List<Ticket__c> oldTickets,List<Ticket__c> newTickets) {
         
        List <PermissionSetAssignment> psa = [select id from PermissionSetAssignment where assigneeId=:Userinfo.getUserId() AND permissionset.name='Create_Users'];
        for(Profile p: Database.query(EBH_ConstantsUtility.SOQL_ADMIN_PROFILES)) {
            SET_ADMIN_PROFILES.add(p.Id);
        }
         
        if(!SET_ADMIN_PROFILES.contains(UserInfo.getProfileId()) && psa.isEmpty()) {
            return;
        }
        //profile mapping
        for(Profile p: Database.query(EBH_ConstantsUtility.SOQL_PROFILE)) {
            MAP_PROFILES.put(p.Name,p.Id);
        }
        //NK:30/05/2018: EPH-5957 Auto-User creation should only work for ticket type "User_Request_Form"
        //Map<Id,RecordType> mapRecordType = new Map<Id,RecordType>((List<RecordType>)Database.query(EBH_ConstantsUtility.SOQL_RECTYPE_USERFORM)); 
        RecordType recTypeUserForm = ApexUtil.getRecordTypeByName('Ticket__c','User_Request_Form');
        RecordType recTypeValidateSurvey = ApexUtil.getRecordTypeByName('Ticket__c','Validate_survey');
        RecordType recTypeUserReactivate = ApexUtil.getRecordTypeByName('Ticket__c','User_Reactivation');
        
        integer i=0;
        List<User> userToCreate = new List<User>();
        List<User> userToGroupSalesPlaner = new List<User>();
        Map<String,Contact> mapContacts = new Map<String,Contact>();
        Map<String,Campaign> mapCampaignSurveyId = new Map<String,Campaign>();
        
        Map<String,String> permissionSetUserMap = new Map<String,String>();
        Set<String> setReactivateUsers = new Set<String>();
        for(Ticket__c ticketOld: oldTickets) {
            //if(mapRecordType.containsKey(newTickets[i].recordTypeId) && ticketOld.Status__c != newTickets[i].Status__c && newTickets[i].Status__c ==EBH_ConstantsUtility.STATUS_INPROGRESS) {
            if((recTypeUserForm.Id == newTickets[i].recordTypeId || recTypeUserReactivate.Id == newTickets[i].recordTypeId)  //request or reactivate
            	&& ticketOld.Status__c != newTickets[i].Status__c 
            	&& newTickets[i].Status__c ==EBH_ConstantsUtility.STATUS_INPROGRESS) 
            {
            	//system.debug('>>>>:'+JSON.serialize(newTickets[i]));
                if(!newTickets[i].Approved__c)
                {
                	newTickets[i].addError(System.Label.Ticket_Error_NotApproved); continue; 
                	
                }else if(recTypeUserForm.Id == newTickets[i].recordTypeId)
                {
                	try 
                	{
	                    User u = createUser(newTickets[i]);
	                    //system.debug('>>>>U:'+JSON.serialize(u));
	                    userToCreate.add(u);
	                     
	                    //NK:EPH-7025: 07/03/2019
	                    if(newTickets[i].Picklist__c== EBH_ConstantsUtility.PROFILE_GCX_PARTNER) //Profile
	                    {
	                    	if(getGCXAccount()==null)
	                    	{
	                    		newTickets[i].addError('No GCX Partner for Partner User!');return;
	                    	}
	                    	mapContacts.put(u.UserName,createContactFromTicket(newTickets[i]));
	                    	 
	                    }
	                }catch(Exception e) {
	                    system.debug(e);EBH_ApexLogger.logError(new List<Exception> { e }, EBH_ConstantsUtility.CLASS_TICKETHANDLER, 
	                                                    EBH_ConstantsUtility.CLASS_TICKETHANDLER_METH_CHECKCREATEUSERS);
	                }
	                //newTickets[i].Status__c = EBH_ConstantsUtility.STATUS_DONE; //must before update-trigger
	                newTickets[i].Status__c = EBH_ConstantsUtility.STATUS_CLOSED; //must before update-trigger 
                	
                }else if(recTypeUserReactivate.Id == newTickets[i].recordTypeId && newTickets[i].Inactive_User__c <> null) //reactivate by future
                {
                	setReactivateUsers.add(newTickets[i].Inactive_User__c);
                }
                
            }else if(recTypeValidateSurvey.Id == newTickets[i].recordTypeId 
            		&& ticketOld.Status__c != newTickets[i].Status__c 
            		&& newTickets[i].Status__c ==EBH_ConstantsUtility.TICKET_STATUS_VALIDATED 
            		&& newTickets[i].Related_Campaign__c <> null && newTickets[i].Survey_ID__c <> null)
            {
            	//Then Validated survey.Survey ID is copied to the related Campaign. Survey ID.
            	mapCampaignSurveyId.put(newTickets[i].Related_Campaign__c,new Campaign(Id=newTickets[i].Related_Campaign__c,Survey_ID__c=newTickets[i].Survey_ID__c));
            	newTickets[i].Status__c = EBH_ConstantsUtility.STATUS_CLOSED; 
            }
            i++;
        }
        
        if(!setReactivateUsers.isEmpty())
        {
        	reactivateUsers(setReactivateUsers);
        }
        
        if(!mapCampaignSurveyId.isEmpty())
        {
        	update mapCampaignSurveyId.values();
        }  
        
        if(!userToCreate.isEmpty()) {
               try {
					 
					if(!mapContacts.isEmpty())
					{
						//1, Insert Contact first to get Id for GCX Partner Users
						Database.insert(mapContacts.values());
						//portal user need ContactId
						//insert contact first, then assign the id of newly contact to portal User (GCX Community partner profile)
						for(User u: userToCreate)
						{
							if(mapContacts.containsKey(u.UserName))
							{
								u.ContactId = mapContacts.get(u.UserName).Id;
								u.UserRoleId = null; // Community do not need RoleId or INVALID Role Assignment! //NK:17/03/2019
							}
						}
					}
					//2, insert User here
					Database.insert(userToCreate);  
				
               }catch(System.DmlException e) {
	                 system.debug(e);EBH_ApexLogger.logError(new List<Exception> { e }, EBH_ConstantsUtility.CLASS_TICKETHANDLER, 
	                                                    EBH_ConstantsUtility.CLASS_TICKETHANDLER_METH_CHECKCREATEUSERS);
	                if(e.getMessage().contains('DUPLICATE')){
	                    for(Ticket__c tNew : newTickets){
	                        tNew.addError(Label.TicketDuplicateErrorMessage);
	                    }
	                }else //NK:17/03/2019: removed other, keep only duplicate and 'else'
	                {
	                	for(Ticket__c tNew : newTickets){
	                        tNew.addError(e.getMessage());
	                    }
	                }     
            }
            
            //In the new requirement user should not be added to public groups, 
            //they must be assigned with "wave analytics user" permission set. 
            Set<Id> setUser = new Set<Id>();
            Set<Id> setUserGCX = new Set<Id>();
            Set<String> setUserExcTeam = new Set<String>(); 
             
            for(User u: userToCreate) {
                setUser.add(u.id);
                if(u.Permission_Sets__c <> null && u.Permission_Sets__c.contains(EBH_ConstantsUtility.TICKET_PERMISSIONSET_MARKETING_EXC_TEAM))
            	{
            		setUserExcTeam.add(u.Id);
                }
                 
            	if(u.ProfileId == EBH_ConstantsUtility.PROFILE_GCX_PARTNER_ID)
            	{
            		setUserGCX.add(u.Id);
            	}
            }
            addMemberAsyn(setUser,setUserGCX);
             
            if(!setUserExcTeam.isEmpty())
            {
            	autoCreateDaysAsyn(setUserExcTeam);
            }
        }
    }
 
    
  	@future
  	private static void reactivateUsers(Set<String> setUserToReactivate)
  	{
  		List<User> listUser = new List<User>();
  		for(String uId : setUserToReactivate)
  		{
  			listUser.add(new User(Id=uId,isActive = true));
  		}
  		update listUser;
  	}
  	
  	 /*****************************************************************************************************************************
    @ Method:         createContactFromTicket
    @ Version:        1.0
    @ Author:         Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:        EPH-7025 User Ticket Automation Flow - Create GCX User
                      AC2: a) Create new Contact
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      list oldTrigger:  
                      list newTrigger: 
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        new Contact in memory
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  07.03.2019 / Vadhanak Voun /Created the Method. 
	@				:  26.06.2019 / Vadhanak Voun /EPH-7674
    *****************************************************************************************************************************/
  	 private static Contact createContactFromTicket(Ticket__c ticket)
  	 {
  	 	Contact c = new Contact(
                        LastName = ticket.Last_Name__c,
                        FirstName = ticket.First_Name__c,
                        Email = ticket.Email_address__c,
                        AccountId = getGCXAccount()==null?null:getGCXAccount().Id,
						RecordTypeId=ApexUtil.getRecordTypeByName('Contact','EBH_MANUAL').Id, //NK:26/06/2019:EPH-7674,
                        EBH_Status__c = EBH_ConstantsUtility.CONTACT_STATUS_ACTIVE
  	 					);
  	 	return c;
  	 } 
  	 private static Account gcxPartnerAccount;
  	 
  	 private static Account getGCXAccount()
  	 {
  	 	if(gcxPartnerAccount == null)
  	 	{
  	 		List<Account> listAcc = Database.query(EBH_ConstantsUtility.SOQL_GCX_ACCOUNT); 
  	 		gcxPartnerAccount = listAcc.isEmpty()?null:listAcc[0];
  	 	}
  	 	return gcxPartnerAccount;
  	 }
  	 
    @future
	public static void autoCreateDaysAsyn(Set<String> setUserId)
	{
		BatchAutoCreateDay.doInsertDaysForUsersFromToday(setUserId);
	}
	
    /*****************************************************************************************************************************
    @ Method:         addMemberAsyn (private)
    @ Version:        1.0
    @ Author:         Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:        EPH-3309:  As the dml in mixed objects. Asynchronous method need to separate the transaction.
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      list String: list of userId and group id (userId_groupId) to be created  from method checkCreateUsers.
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        void
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  14.09.2017 / Vadhanak Voun /Created the Method. 
    @                  08.11.2017 / Vadhanak Voun/ updated method to: #13032
    @                  This time a new requirement has came to map right public group when a user selects permission sets in User request form In tickets. 
    @                  Public groups has to be assigned according to the locale: 
    @                   *Locale                     *Public Group
    @                   German (Germany) -          DE Campaign Request Approvers
    @                   Czech (Czech Republic) -    EEC Campaign Request Approvers
    @                   English (Ireland) -         EEC Campaign Request Approvers
    @                   German (Switzerland) -      EEC Campaign Request Approvers
    @                   Spanish (Spain) -           ES Campaign Request Approvers
    @                   French (France) -           FR Campaign Request Approvers
    @                   Italian (Italy) -           IT Campaign Request Approvers
    @                   English (UK) -              UK Campaign Request Approvers
    @                   
    @                   15.12.2017 / Vadhanak Voun / Fixed nullpointer of  u.Permission_Sets__c line 148
    @					09.07.2018 / David Herrero / commented the creation of group members . EPH-6253
    @                   20.07.2020/ vadhanak voun / US-0007854 - User creation flow for GCX profile not adding Analytics PS
    @                                           
    *****************************************************************************************************************************/
    @future
    private static void addMemberAsyn(Set<Id> setUser,Set<Id> setUserGCX) {
        
        List<PermissionSet> permisss =  Database.query(EBH_ConstantsUtility.SOQL_PERMISSIONSET);
        List<Group> grp =  Database.query(EBH_ConstantsUtility.SOQL_GRP);
        List<PermissionSet> permissWave =  Database.query(EBH_ConstantsUtility.SOQL_PERMISSIONSET_WAVE_A_USER);
        
        Map<String, String> PerSetMap = new Map<String, String>();
        
        List<PermissionSetAssignment> listPSA = new List<PermissionSetAssignment>();
        List<PermissionSetLicenseAssign> listPSALSC = new List<PermissionSetLicenseAssign>(); //for gcx user
        List<GroupMember> listgrpMem = new List<GroupMember>(); 
        
        List<User> usrList = new List<User>();
        usrList = Database.query(EBH_ConstantsUtility.SOQL_User);
        
        for(PermissionSet psRec: permisss){
            PerSetMap.put(psRec.Name+'PS', psRec.Id);
        }
        
        for(Group grpRec: grp){
            PerSetMap.put(grpRec.DeveloperName+'PG', grpRec.Id);
        }
        
        Map<String, String> matchGrpPermSet = new Map<String, String>();
        matchGrpPermSet.put('Campaign Approval', 'Sales planner / marketer');
        matchGrpPermSet.put('Report exports', 'EBH_exportReportsPermissionSet');
        matchGrpPermSet.put('Ticket Manager', 'Ticket Manager');
         
		matchGrpPermSet.put('Marketing Execution Team', 'Marketing_Execution_Team');//21/01/2019: EPH-6940
		 
        for(User u : usrList) {
            
            List<String> strSplit = u.Permission_Sets__c==null?new List<String>():u.Permission_Sets__c.split(';');
            
            for(String str : strSplit){
                String str1 = matchGrpPermSet.get(str);
                PermissionSetAssignment psa = new PermissionSetAssignment();
               // GroupMember grpMem = new GroupMember();
                if(PerSetMap.containskey(str1+'PS')){
                    psa = new PermissionSetAssignment(PermissionSetId=PerSetMap.get(str1+'PS'), AssigneeId=u.id);
                    listPSA.add(psa);
                }
            }
            
            Locale_PublicGroup_Mapping__c gMapping = Locale_PublicGroup_Mapping__c.getInstance(u.LocaleSidKey);
            if(gMapping==null)
            {
                 throw new TicketException(EBH_ConstantsUtility.ERROR_LOCALE_GROUP_MAPPING+u.LocaleSidKey);
            }
             
            //NK:16/01/2019: EPH-6940
            if(u.Permission_Sets__c <> null && u.Permission_Sets__c.contains(EBH_ConstantsUtility.TICKET_PERMISSIONSET_MARKETING_EXC_TEAM))
            {
            	listgrpMem.add(new GroupMember(GroupId = PerSetMap.get(EBH_ConstantsUtility.GROUP_MARKETING_EXC+'PG'), UserOrGroupId=u.Id)); 
            }
            //GCX Profile:
            //1, assign permission license
            //2, assing permssion set (differ from normal user)
            if(setUserGCX.contains(u.Id))
            {
                //NK:20/07/2020: US-0007854
                //replaced hardcoded id with ApexUtil.getPermissionSetL()
                //listPSALSC.add(new PermissionSetLicenseAssign(PermissionSetLicenseId=ApexUtil.getPermissionSetL(PSL_WAVE_COMM).Id,AssigneeId=u.Id)); //NO LONGER USED
                listPSALSC.add(new PermissionSetLicenseAssign(PermissionSetLicenseId=ApexUtil.getPermissionSetL(PSL_EA_MEMB).Id,AssigneeId=u.Id));

            	listPSA.add(new PermissionSetAssignment(PermissionSetId=EBH_ConstantsUtility.PERMISSION_SET_COMMUNITY_ANALYTICS_ID,AssigneeId=u.id));	
            }else //normal user
            {
            	 listPSA.add(new PermissionSetAssignment(PermissionSetId=permissWave[0].Id,AssigneeId=u.id));
            }
        }
        try
        {
            //System.debug('>>>listPSALSC: '+listPSALSC.size());
        	if(!listPSALSC.isEmpty() && !Test.isRunningTest())
	        {
	        	Database.insert(listPSALSC); 
	        }
	         
	        if( !listPSA.isEmpty() && !Test.isRunningTest())
	            Database.insert(listPSA); 
	          
	        if(!listgrpMem.isEmpty())
	            Database.insert(listgrpMem);   
            
        }catch(Exception ex)
        {
            //NK:20/07/2020: disabled to avoid MIXED_DML_OPERATION
        	//EBH_ApexLogger.logError(new List<Exception> { ex }, 'TicketTriggerHandler','addMemberAsyn');
        	ApexUtil.doSend('Error: PermissionSet/PSL/Group Assingment',UserInfo.getUserEmail(),ex.getMessage());
        }
        
 
    }
    
    /*****************************************************************************************************************************
    @ Method:         createUser (private)
    @ Version:        1.0
    @ Author:         Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:        EPH-3309: private method to construct a User object from a reference Ticket.
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      object Ticket: ticket reference to create User
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        new object User.
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  14.09.2017 / Vadhanak Voun /Created the Method. 
                       20.10.2017 / Vadhanak Voun / added UserPermissionsMarketingUser = true to createUser
    *****************************************************************************************************************************/
    private static User createUser(Ticket__c ticket) {
        
        //cs_CZ___Europe/Prague___en_US
        CountryMapping3__c cMapping = CountryMapping3__c.getInstance(ticket.Locale__c);
        String localeKey = '';
        String timeZoneKey = ''; //oneTicket.Timezone__c = 
        String langKey = '';
        if(cMapping!=null) {
            String[] keys = (cMapping.value__c+'').split('___');
            localeKey = keys[0];
            timeZoneKey = keys[1];
            langKey = keys[2];
        }else {
            throw new TicketException(EBH_ConstantsUtility.ERROR_NO_COUNTRY_MAPPING+ticket.Locale__c);
        } 
		//NK:26/06/2019:EPH-7674
        String u_suffix = ticket.Picklist__c== EBH_ConstantsUtility.PROFILE_GCX_PARTNER? EBH_ConstantsUtility.AT_GCX_SUFFIX: EBH_ConstantsUtility.AT_HIVE_SUFFIX;		
        User u = new User(
                        //Username = ticket.Email_address__c.split('@')[0] + EBH_ConstantsUtility.AT_HIVE_SUFFIX,
                        Username = ticket.Ebay_Corp_ID__c + u_suffix,
                        TimeZoneSidKey = timeZoneKey,
                        ProfileId = MAP_PROFILES.get(ticket.Picklist__c),
                        LocaleSidKey = localeKey,
                        LanguageLocaleKey = langKey,
                        EmailEncodingKey = EBH_ConstantsUtility.ENCODE_UTF8,
                        LastName = ticket.Last_Name__c,
                        FirstName = ticket.First_Name__c,
                        FederationIdentifier = ticket.Ebay_Corp_ID__c,
                        Email = ticket.Email_address__c,
                        Division = ticket.Division__c, 
                        Alias = ticket.First_Name__c.left(1)+ticket.Last_Name__c.left(7),
                        CommunityNickname = ticket.First_Name__c+ticket.Last_Name__c+EBH_ConstantsUtility.HIVE_SUFFIX,
                        Permission_Sets__c = ticket.Permission_Sets__c,
                        UserPermissionsMarketingUser = true,
             			Cost_Center__c = ticket.Cost_Center__c,
             			Department = ticket.Department__c
        );
        return u;
    }

    /*****************************************************************************************************************************
    @ Method:         createTicketShare
    @ Version:        1.0
    @ Author:         Samnang MUONG (samnang.muong@gaea-sys.com)
    @ Purpose:        //EPH-2950 - Trigger on ticket object for manual sharing with record creator. 
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      list newTrigger:  
                      Map oldTrigger:
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        void
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  10.10.2017 / Samnang MUONG /Created the Method. 
    *****************************************************************************************************************************/
    public static void createTicketShare(List<Ticket__c> newTickets, Map<Id, Ticket__c> oldMapTicket) {
			 
        map<Id,Id> mapTicketCreatorID = new map<Id,Id>();         
          for ( Ticket__c ticket : newTickets) {

                if (oldMapTicket != null && (ticket.OwnerId == oldMapTicket.get(ticket.id).OwnerId)) continue;
                   
               mapTicketCreatorID.put(ticket.id, ticket.CreatedById);          
          }
          
          if ( mapTicketCreatorID.isEmpty() ) return;
          
          list<Ticket__Share> lstTicketShr  = new list<Ticket__Share>();
          for(Id ticketId : mapTicketCreatorID.keySet()){
             Ticket__Share ticketShr  = new Ticket__Share();
             ticketShr.ParentId = ticketId;
             ticketShr.UserOrGroupId = mapTicketCreatorID.get(ticketId);
             ticketShr.AccessLevel = 'Edit';
             ticketShr.RowCause = Schema.Ticket__Share.RowCause.Manual;
             lstTicketShr.add(ticketShr);
          }
          
          if (!lstTicketShr.isEmpty()) list<Database.SaveResult> lstResult = Database.insert(lstTicketShr,false);

    }
    
    /*****************************************************************************************************************************
    @ Method:         autoPopulateProfile
    @ Version:        1.0
    @ Author:         Sreymeas NAO (sreymeas.nao@gaea-sys.com)
    @ Purpose:        US-0009431 User creation ticket process enhancement
    @				Based on "User Type" and "Country" selected in the "Ticket" Object,
	@				auto populate "Profile" as "AU Standard User Profile" if Country = AU and User Type = Full License User
	@				auto populate "Profile" as "Standard User Profile" if Country is not AU and User Type is Full License User
	@				auto populate "Profile" as "GCX Partner Profile" if Country is not AU and User Type is GCX Portal User
	@				If user select Country = AU and User Type is GCX Portal User, throw the below error message
	@				"GCX Community is currently not enabled for AU. Please select "Full License user" as User Type."
    @ Event : 		  Before Insert / Before Update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      lstTicket:  
    ------------------------------------------------------------------------------------------------------------------------------
    @ Returns:        void
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  20.09.2019 / Sreymeas NAO /Created the Method. 
    *****************************************************************************************************************************/
    public static void autoPopulateProfile(List<Ticket__c> lstTicket,Map<Id,Ticket__c> mapOld){
    	
    	RecordType recTypeUserForm = ApexUtil.getRecordTypeByName('Ticket__c','User_Request_Form');
    	
        for(Ticket__c oneTicket: lstTicket){
        	if(recTypeUserForm.Id <> oneTicket.recordTypeId)continue; //rule for only user request
        	if(mapOld==null || ticketChanged(mapOld.get(oneTicket.Id),oneTicket)) //new or updated with eligible fields
        	{
        		//1, auto populate "Profile" as "AU Standard User Profile" if Country = AU and User Type = Full License User
        		if(oneTicket.Country__c==EBH_ConstantsUtility.TICKET_COUNTRY_AU && oneTicket.User_Type__c==EBH_ConstantsUtility.TICKET_USER_TYPE_LICENSE){
                	oneTicket.Picklist__c = EBH_ConstantsUtility.TICKET_AU_PROFILE;
	            }
	            //2, auto populate "Profile" as "Standard User Profile" if Country is not AU and User Type is Full License User
	            else if(oneTicket.Country__c!=EBH_ConstantsUtility.TICKET_COUNTRY_AU && oneTicket.User_Type__c==EBH_ConstantsUtility.TICKET_USER_TYPE_LICENSE){
	                oneTicket.Picklist__c = EBH_ConstantsUtility.TICKET_STANDARD_PROFILE;
	            }
	            //3, auto populate "Profile" as "GCX Partner Profile" if Country is not AU and User Type is GCX Portal User
	            else if(oneTicket.Country__c!= EBH_ConstantsUtility.TICKET_COUNTRY_AU && oneTicket.User_Type__c==EBH_ConstantsUtility.TICKET_USER_TYPE_PORTAL){
	                oneTicket.Picklist__c = EBH_ConstantsUtility.TICKET_GCX_PROFILE;
	            }else
	            {
	            	oneTicket.addError(System.Label.Error_Ticket_AU_GCX);
	            }
	            
	            if (oneTicket.CurrencyIsoCode==null) {
	                oneTicket.CurrencyIsoCode.addError(System.Label.Error_Currency_Required);
	            }
        	}
            
            
        }
    }
    
    private static Boolean ticketChanged(Ticket__c tOld,Ticket__c tNew)
    {
    	return 		tOld.Country__c <> tNew.Country__c
    			||  tOld.Timezone__c  <> tNew.Timezone__c
    			||  tOld.Cost_Center__c  <> tNew.Cost_Center__c
    			||  tOld.Department__c <> tNew.Department__c
    			||  tOld.User_Type__c <> tNew.User_Type__c
    			||  tOld.CurrencyIsoCode <> tNew.CurrencyIsoCode;
    			
    }
    
    class TicketException extends Exception{}

}