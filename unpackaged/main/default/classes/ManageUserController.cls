/*********************************************************************************************************************************
@ Class:        ManageUserController
@ Version:      1.0
@ Author:       vadhanak voun (vadhanak.voun@gaea-sys.com)
@ Purpose:      Controller for lwcManageUser  
@               US-0010903 - [Add User] Allow DE Deals Users to add others Contacts to the Seller Portal
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 07.02.2022 / vadhanak voun / Created the class.
@                   29.03.2022 / Sovantheany.dim / Update : US-0011571 - Welcome email has been enabled which will send same email template to every Sellers irrespective of region and type of Seller
@                  15.07.2022 / vadhanak voun / US-0012070 - Amend Manage Users to support Linked Accounts
*********************************************************************************************************************************/
public with sharing class ManageUserController {
     
    private static final String RT_ACC_GROUP='Seller_Portal_Group'; //account group

    private final static String PF_PORTAL_DE = 'DE - Seller Portal';
    //private final String PORTAL_NA = 'NA - Seller Portal';
    private final static String PORTAL_SUFFIX = '.ebay.portal';

    private final static String PS_BASELINE = 'Seller_Portal_Baseline_Account_Contact_Access';
    private final static String PS_DE_DEALS ='DE_Seller_Portal_Deals';

    private final static String WELCOME_EMAIL_TEMPLATE='Add_User_Welcome_Email_Template'; //for immediate reset pwd for Manage User from portal. SSO user not to receive welcome email

    /*********************************************************************************************************************************
    @ method:        getContacts
    @ Version:      1.0
    @ Author:       vadhanak voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:      US-0010903 - [Add User] Allow DE Deals Users to add others Contacts to the Seller Portal    
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 07.02.2022 / vadhanak voun / Created the method.
    @               : 06.06.2022/ vadhanak voun / US-0011892 - Testing Issue - Link Multiple Account
    *********************************************************************************************************************************/
    @AuraEnabled//(cacheable=true)
    public static Map<String,Object> getContacts()
    {
        RecordType recSP = ApexUtil.getRecordTypeByName('Contact', 'Seller_Portal');
        User currentUser = [Select Id,UserName,Email,ContactId,Contact.RecordType.DeveloperName,Contact.AccountId,Contact.Account.OwnerId,Federated_Login__c From User Where Id=:UserInfo.getUserId()];
        //List<Contact> listCon = [Select Id,Name,Email From Contact Where AccountId =:currentUser.Contact.AccountId AND RecordTypeId=:recSP.Id AND CreatedById=:currentUser.Id Order By Name];

        List<User> listUser = [Select Id,Email,ContactId,Contact.Name,Contact.Email,Contact.AccountId From User Where Contact.RecordTypeId=:recSP.Id AND Contact.AccountId=:currentUser.Contact.AccountId And IsActive=TRUE AND Federated_Login__c=TRUE Order By CreatedDate ASC];

        Map<String,AccountContactRelation> mapRelation = new Map<String,AccountContactRelation>();
        for(AccountContactRelation acr : [Select Id,AccountId,Account.Name,Contact.Name,Contact.Email,ContactId,IsActive From AccountContactRelation Where AccountId=:currentUser.Contact.AccountId ])
        {
            mapRelation.put(acr.AccountId,acr);
        }
                 
        return new Map<String,Object> {'curentUser'=>currentUser,'listUser'=>listUser,'contRelation'=>mapRelation.values()};
    }
    /*********************************************************************************************************************************
    @ method:        apexSubmitContact
    @ Version:      1.0
    @ Author:       vadhanak voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:      US-0010903 - [Add User] Allow DE Deals Users to add others Contacts to the Seller Portal    
    @ param:        contact (json)
    @               accId: id of selected account if more than 1
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 07.02.2022 / vadhanak voun / Created the method.
    @               : 31.03.2022/ vadhanak voun / US-0011582 - [Add User] Query only Customer Portal enabled contacts while stopping the contact addition by Manage User
    *********************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> apexSubmitContact(Map<String,String> cont,String[] listAccIds)
    {
        Map<String,Object> mapResult = new Map<String,Object>{'status'=>'ok'};
        RecordType recSP = ApexUtil.getRecordTypeByName('Contact', 'Seller_Portal');
        User currentUser = [Select Id,UserName,Email,ContactId,Contact.AccountId,Contact.Account.OwnerId From User Where Id=:UserInfo.getUserId()];
        Contact newCont = new Contact(
            FirstName=cont.get('firstName'),
            LastName=cont.get('lastName'),
            Email=cont.get('email'),
            RecordTypeId=recSP.Id,
            AccountId = currentUser.Contact.AccountId,
            OwnerId= Test.isRunningTest()?UserInfo.getUserId():currentUser.Contact.Account.OwnerId
        );
        String contEmail = newCont.Email;
        String soqlsContact = 'Select Id From User '; //NK:31/03/2022/US-0011582
        String sWhereUser = ' WHERE Email=\''+newCont.Email +'\' AND UserType=\'PowerCustomerSuccess\'';
        if(!WithoutSharing.doQuery(soqlsContact,sWhereUser,'').isEmpty())
        {
            mapResult.put('status','ko');mapResult.put('error','duplicate');
            return mapResult;
        }
        try
        {
            WithoutSharing.doInsert(new List<SObject>{newCont}); 

            List<AccountContactRelation> listAccCont = new List<AccountContactRelation>();
            for(String accId: listAccIds)
            {
                listAccCont.add(
                    new AccountContactRelation(ContactId=newCont.Id,AccountId=accId,IsActive=True)
                );                
            }

            if(!listAccCont.isEmpty())
            {                
                WithoutSharing.doInsert(listAccCont); 
            }

            mapResult.put('conId',newCont.Id);
            mapResult.put('listAccCont',listAccCont);

        }catch(DMLException dex)
        {
            mapResult.put('status','ko');mapResult.put('error',dex.getDmlMessage(0));mapResult.put('errorDetail',dex.getStackTraceString());
        }catch(Exception ex){ mapResult.put('status','ko');mapResult.put('error',ex.getMessage());mapResult.put('errorDetail',ex.getStackTraceString()); }
     
        return mapResult;
    }
    /*********************************************************************************************************************************
    @ method:        apexSubmitUser
    @ Version:      1.0
    @ Author:       vadhanak voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:      US-0010903 - [Add User] Allow DE Deals Users to add others Contacts to the Seller Portal   
    @               avoid mixed dml. separete insert contact and user in different transaction 
    @ param:        jsonUser,contId,listAccContId created earlier by apexSubmitContact      
    @----------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 07.02.2022 / vadhanak voun / Created the method.
    *********************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> apexSubmitUser(Map<String,String> contMap,String[] listAccContId)
    {
        Map<String,Object> mapResult = new Map<String,Object>{'status'=>'ok'};  

        try
        {
            Profile prof = [Select Id From Profile Where Name=:PF_PORTAL_DE];
            Profile_Mapping__mdt pmapping = [Select Id,User_Currency__c,User_Language__c,User_Locale__c,timeZoneSidKey__c From Profile_Mapping__mdt Where MasterLabel=:PF_PORTAL_DE];
    
           // Contact cont = [Select Id,Name,FirstName,LastName,Email From Contact Where Id=:contId];
    
            User userNew = new User(        
                username = contMap.get('email') + PORTAL_SUFFIX,
                email = contMap.get('email'),
                lastName = contMap.get('lastName'),
                firstName = contMap.get('firstName'),            
                alias = (contMap.get('email') + PORTAL_SUFFIX ).left(8),
                languagelocalekey = pmapping.User_Language__c,
                localesidkey = pmapping.User_Locale__c,
                emailEncodingKey = 'UTF-8',
                timeZoneSidKey = pmapping.timeZoneSidKey__c,
                profileId = prof.Id,
                ContactId = contMap.get('Id'),
                Permission_Sets__c = EbayRegistrationHandler.PSGROUP_DE,
                Federated_Login__c = true
            );

            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail= true;        
            userNew.setOptions(dlo);               
            WithoutSharing.doInsert(new User[]{userNew});
            
            //NK:18/07/2022:US-0012070
            //assign the account-contact relationship to the new contact/user (incase in Group)
            manageAccountContactRelationships(null);

            //29.03.2022:US-0011571 
            //void mixed dml
            doResetPwd(userNew.Id);            

            mapResult.put('user_id',userNew.Id);          

        }catch(DMLException dex)
        {
            mapResult.put('status','ko');mapResult.put('error',dex.getDmlMessage(0));mapResult.put('errorDetail',dex.getStackTraceString());
        }catch(Exception ex){ mapResult.put('status','ko');mapResult.put('error',ex.getMessage());mapResult.put('errorDetail',ex.getStackTraceString()); }
        finally {
            //insert User failed. delete the just-inserted-contact
            if(mapResult.get('status')=='ko')
            {
                clearContactData(contMap.get('Id'),listAccContId);
            }
        }
     
        return mapResult;
    }

    /*********************************************************************************************************************************
    @ method:        doResetPwd
    @ Version:      1.0
    @ Author:       sovantheany dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:      US-0011571 - Welcome email has been enabled which will send same email template to every Sellers irrespective of region and type of Seller    
    @----------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.03.2022 / sovantheany dim / Created the method.
    *********************************************************************************************************************************/
    @future
    private static void doResetPwd(String usrId)
    {
        //System.resetPassword(usrId,true);
        System.resetPasswordWithEmailTemplate(usrId,true,WELCOME_EMAIL_TEMPLATE);
         
    }
    @future
    private static void clearContactData(String contId,String[] listAccContId)
    {        
        Contact cont = new Contact(Id=contId,FirstName='delete-err',LastName='delete-err',Email='delete-err@example.com');
        
        try{
            WithoutSharing.doUpdate(new Contact[]{cont});
        }catch(Exception ex){System.debug(ex); }
        if(!listAccContId.isEmpty())
        {
            List<AccountContactRelation> listToDelete = WithoutSharing.doQuery('Select Id From AccountContactRelation ', ' WHERE ID IN'+('(\''+String.join(listAccContId,'\',\'')+'\')'), '');  
            WithoutSharing.doDelete(listToDelete);
        }
        
        WithoutSharing.doDelete(new Contact[]{cont});
    }

     /*********************************************************************************************************************************
    @ method:        apexRemoveContact
    @ Version:      1.0
    @ Author:       vadhanak voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:      US-0011278 - Deactivate/Delete Users by the Seller Admin
    @ param:        targetId: userId and contact id to be removed
    @               requires 2 steps to complete removal. to avoid mixed-dml
    @               1, remove contact, 2, remove user.
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 21.02.2022 / vadhanak voun / Created the method.
    *********************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> apexRemoveContact(String targetObject,String contId,String usrId)
    {
        Map<String,Object> mapResult = new Map<String,Object>{'status'=>'ok'};  
        SObject sobj = null;
        
        if(targetObject=='contact')
        {
            Contact contRemove = [Select Id,FirstName,LastName From Contact Where Id=:contId];
            sobj = new Contact(Id=contId);
            sobj.put('FirstName', 'Deactivated '+contRemove.FirstName);
            sobj.put('LastName','Deactivated '+contRemove.LastName);
            
        }else if(targetObject=='user')
        {
            User usrRemove = [Select Id,FirstName,LastName From User Where Id=:usrId];
            sobj = new User(Id=usrId);
            sobj.put('UserName',(usrId+'@deactivated.com'));
            sobj.put('IsActive',false);
            sobj.put('FirstName', 'Deactivated '+usrRemove.FirstName); //contact already Deactivated first.
            sobj.put('LastName', 'Deactivated '+usrRemove.LastName);

            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail = false;
            sobj.setOptions(dlo);
        }
                
        sobj.put('Email',(usrId+'@deactivated.com'));

        try {

            WithoutSharing.doUpdate(new List<SObject>{sobj});
            
            //NK:18/07/2022:US-0012070
            manageAccountContactRelationships(contId);
        }catch(DMLException dex)
        {
            mapResult.put('status','ko');mapResult.put('error',dex.getDmlMessage(0));mapResult.put('errorDetail',dex.getStackTraceString());
        }catch(Exception ex){ mapResult.put('status','ko');mapResult.put('error',ex.getMessage());mapResult.put('errorDetail',ex.getStackTraceString()); }
        
        return mapResult;
    }

    /*********************************************************************************************************************************
    @ method:        addAccountContactRelationships
    @ Version:      1.0
    @ Author:       vadhanak voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:      US-0012070 - Amend Manage Users to support Linked Accounts
    @ param:        removeContId. contact id being removed from ManageUser         
    ----------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 15.07.2022 / vadhanak voun / Created the method.
    @                            /then also remove the account-contact relationship if if in the group
    *********************************************************************************************************************************/
    @future
    private static void manageAccountContactRelationships(String removeContId)
    {
        //remove relationship
        if(String.isNotBlank(removeContId))
        {
            WithoutSharing.doDelete([Select Id From AccountContactRelation WHERE ContactId =:removeContId],false);
        }else   // or add new relationship
        {
            User[] usrs = [Select Id,ContactId,Contact.AccountId,Contact.Account.RecordType.DeveloperName FROM User WHERE Id=:UserInfo.getUserId() AND Contact.Account.RecordType.DeveloperName = :RT_ACC_GROUP];
            //current account is already in group
            if(!usrs.isEmpty())
            {
                LinkedAccountsController.manageContactsRelationship(usrs[0].Contact.AccountId);
            }
        }
       
    }

}