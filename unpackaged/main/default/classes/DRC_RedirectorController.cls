/*********************************************************************************************************************************
@ Class:          DRC_RedirectorController
@ Version:        1.0
@ Author:         Loumang SENG (loumang.seng@gaea-sys.com)
@ Purpose:        Controller Class for Deal list view buttons pages in related list Deal Retail Campaign
@                  
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 23-07-2021 / Loumang SENG / Created the class.			  
*********************************************************************************************************************************/
public without sharing class DRC_RedirectorController {
    public List<EBH_Deal__c> selectedDeal{get;set;}
    public String pageId{get;set;}
    public String selectedIds{get;set;}
    //public String pageName{get;set;}

    public DRC_RedirectorController(ApexPages.StandardSetController controller) {
        //pageName = Apexpages.currentPage().getParameters().get('pageName');
        selectedDeal = controller.getSelected();
        pageId = Apexpages.currentPage().getParameters().get('id');
        selectedIds = '';
        for(EBH_Deal__c deal : selectedDeal){
            selectedIds += deal.Id + ',';
        }

        selectedIds = selectedIds != '' ? selectedIds.removeEnd(',') : selectedIds;
        

    
    }
    
}