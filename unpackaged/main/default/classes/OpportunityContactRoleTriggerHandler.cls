/*********************************************************************************************************************************
@ Class:         OpportunityContactRoleTriggerHandler
@ Version:       1.0
@ Author:        Vahanak Voun (vahanak.voun@gaea-sys.com)
@ Purpose:       handler for trigger: OpportunityContactRoleTrigger
@				  
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 01.09.2021 / Vahanak Voun (vahanak.voun@gaea-sys.com) / Created the class.
*********************************************************************************************************************************/
public with sharing class OpportunityContactRoleTriggerHandler {
     
    public final static String ROLE_INVOICE_RECIPIENT = 'Invoice Receiver';//'Invoice recipient'; old EU uses Invoice recipient, story uses: Invoice Receiver

    /*****************************************************************************************************************************
    @ Method:   updatePrimaryContactAndSAP
    @ Version:  1.0
    @ Author: 	Vahanak Voun (vahanak.voun@gaea-sys.com)
    @ Purpose:	US-0010238 - Migrate class "ContactRoleOnOpportunity" into Hive				
    @ Event:	after insert, after Update
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:     List<OpportunityContactRole>listNew, Map<Id,OpportunityContactRole> mapOld
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 01.09.2021 / Vahanak Voun / Created the Method
    *****************************************************************************************************************************/
    public static void updatePrimaryContactAndSAP(List<OpportunityContactRole> listNew, Map<Id,OpportunityContactRole> mapOld)
    {
        Boolean isNew = (mapOld == null);
        //Boolean isDelete = Trigger.isDelete;

        List<OpportunityContactRole> listInvRec = new List<OpportunityContactRole>();
        List<OpportunityContactRole> listPrimary = new List<OpportunityContactRole>();
        Set<Id> setContId = new Set<Id>();
        Set<Id> setOppId = new Set<Id>();
        for(OpportunityContactRole oppCR: listNew)
        {
            if(oppCR.IsPrimary && ( isNew || (!isNew && oppCR.IsPrimary <> mapOld.get(oppCR.Id).IsPrimary)) )
            {
                listPrimary.add(oppCR);
            }
            if(ROLE_INVOICE_RECIPIENT.equalsIgnoreCase(oppCR.Role) && (isNew || (!isNew && oppCR.Role <> mapOld.get(oppCR.Id).Role)) )
            {
                listInvRec.add(oppCR);
            }
            setContId.add(oppCR.ContactId);
            setOppId.add(oppCR.OpportunityId);
        }
        if(listInvRec.isEmpty() && listPrimary.isEmpty())
        {
            return;
        }

        Map<Id,Contact> mapContact = new Map<Id,Contact>([Select Id,AccountId,Account.SAP_ID__c From Contact Where Id IN :setContId]);
        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>([Select Id,Primary_Contact__c,SAP_ID_Overwrite__c From Opportunity Where Id IN :setOppId]);
        
        //to update sap override or primary contact
        Map<Id,Opportunity> mapOppToUpdate = new Map<Id,Opportunity>();

        for(OpportunityContactRole oppCR: listPrimary)
        {
            Opportunity opp = mapOpp.get(oppCR.OpportunityId);
            if(oppCR.ContactId <> opp.Primary_Contact__c)
            {
                opp.Primary_Contact__c = oppCR.ContactId;
                mapOppToUpdate.put(opp.Id,opp);
            }
        }
        for(OpportunityContactRole oppCR: listInvRec)
        {
            Opportunity opp = mapOpp.get(oppCR.OpportunityId);
            Contact cont = mapContact.get(oppCR.ContactId);
            if(opp.SAP_ID_Overwrite__c <> cont.Account.SAP_ID__c)
            {
                opp.SAP_ID_Overwrite__c = cont.Account.SAP_ID__c;
                mapOppToUpdate.put(opp.Id,opp);
            }
        }

        if(!mapOppToUpdate.isEmpty())
        {
            update mapOppToUpdate.values();
        }

    } 
    /*****************************************************************************************************************************
    @ Method:   reassignPrimaryContact
    @ Version:  1.0
    @ Author: 	Vahanak Voun (vahanak.voun@gaea-sys.com)
    @ Purpose:	US-0010238 - Migrate class "ContactRoleOnOpportunity" into Hive				
    @ Event:	after delete
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:     List<OpportunityContactRole>listOld
    ------------------------------------------------------------------------------------------------------------------------------
   	@ Change history: 01.09.2021 / Vahanak Voun / Created the Method
    *****************************************************************************************************************************/
    public static void reassignPrimaryContact(List<OpportunityContactRole> listCR)
    {
        Set<Id> setOppIds = new Set<Id>();
        Set<Id> setCRIds = new Set<Id>();
        for(OpportunityContactRole oppCR: listCR)
        {
            setOppIds.add(oppCR.OpportunityId);
            setCRIds.add(oppCR.Id);
        }
        
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
        for(Opportunity opp: [Select Id,Primary_Contact__c,(Select Id,ContactId,OpportunityId,IsPrimary From OpportunityContactRoles Where IsPrimary=True AND Id NOT IN :setCRIds) From Opportunity Where Id IN :setOppIds])
        {            
            //in case 2+ primary contact roles and 1 is being deleted, reassign another one
            if(!opp.OpportunityContactRoles.isEmpty() && opp.OpportunityContactRoles[0].ContactId <> opp.Primary_Contact__c)
            {
                opp.Primary_Contact__c = opp.OpportunityContactRoles[0].ContactId;
                listOppToUpdate.add(opp);

            }else if(opp.OpportunityContactRoles.isEmpty()) //no more primary contact role
            {
                opp.Primary_Contact__c = null;  
                listOppToUpdate.add(opp);
            }
        }
        
        if(!listOppToUpdate.isEmpty())
        {
            update listOppToUpdate;
        }

    }
}