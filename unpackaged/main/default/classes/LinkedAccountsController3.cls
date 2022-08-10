public with sharing class LinkedAccountsController3 {

    /*****************************************************************************************************************************
    @ Method:         removeLinkedAccount
    @ Version:        1.0
    @ Author:         Sophal Noch
    @ Purpose:        US-0010902 - Allow Sellers to unlink Accounts
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 09.05.2022 /Sophal Noch/ Created the  Method.
    *****************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> removeLinkedAccount(String accId)
    {
        Savepoint sp = Database.setSavepoint();
        Map<String,Object> mapResult = new Map<String,Object>{'status'=>'ok'};
        try {
            RecordType recSeller = ApexUtil.getRecordTypeByName('Account', 'EBH_Seller');
            RecordType recGroup = ApexUtil.getRecordTypeByName('Account', 'Seller_Portal_Group');
            User cUser = [Select Id,ContactId,Contact.AccountId, Contact.Account.RecordTypeId From User Where Id=:UserInfo.getUserId()];
            if(cUser.Contact.Account.RecordTypeId == recSeller.Id){ // remove AccountContactRelation record when login User.Contact.Account.RecordType is EBH_Seller
                WithoutSharing.doDelete([Select Id From AccountContactRelation Where AccountId =: accId and ContactId =: cUser.ContactId]);
            }else if(cUser.Contact.Account.RecordTypeId == recGroup.Id){ // remove AccountContactRelation records when login User.Contact.Account.RecordType is Seller_Portal_Group
                Map<Id, AccountContactRelation> mapAccIdToAcr = new Map<Id, AccountContactRelation>();
                for(AccountContactRelation acr : [Select Id, AccountId From AccountContactRelation Where Account.RecordTypeId =:recSeller.Id And ContactId =: cUser.ContactId AND IsDirect = false]){
                    mapAccIdToAcr.put(acr.AccountId, acr);
                }
                if(!mapAccIdToAcr.containsKey(accId)) return mapResult; 
                AccountContactRelation selectedAcr = mapAccIdToAcr.remove(accId);
                if(mapAccIdToAcr.isEmpty()) return mapResult;  // do not remove when there is no EBH_Seller AccountContactRelation records left
                List<AccountContactRelation> listAcrToDelete = [Select Id, AccountId From AccountContactRelation Where Account.RecordTypeId =:recSeller.Id AND AccountId =: selectedAcr.AccountId AND Account.Seller_Portal_Group__c =: cUser.Contact.AccountId AND Account.Seller_Portal_Group__c != null AND IsDirect = false];
                Map<Id, Account> mapAccToUpdate = new Map<Id, Account>();
                for(AccountContactRelation acr : listAcrToDelete){
                    if(!mapAccToUpdate.containsKey(acr.AccountId)) mapAccToUpdate.put(acr.AccountId, new Account(Id = acr.AccountId, Seller_Portal_Group__c = null));
                }
                WithoutSharing.doDelete(listAcrToDelete);  // remove AccountContactRelation records from login user and ferderate users
                WithoutSharing.doUpdate(mapAccToUpdate.values()); // update unlinked Account from Group by set Seller_Portal_Group__c = null.
            }
        }catch(Exception e){Database.rollback(sp);mapResult.put('status','ko');mapResult.put('error',e.getMessage());}
        return mapResult;
    }
}