/*********************************************************************************************************************************
@ Class:          EBH_RelatedSellersController
@ Version:        1.0
@ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
@ Purpose:        [EBH] (EPH-2855) - Shows the related Sellers on the Legal Entity page as inline vf
                  EPH-5 : Seller 360, Customer Management
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 27.07.2017 / JOY MONDOL (jmondol@deloitte.co.uk) / Created the page.
*********************************************************************************************************************************/
public with sharing class EBH_RelatedSellersController {
    
    Id parentId;
    
    public Integer RowCount { get; set; }   
    public Decimal PageCount { get; set; }
    public Integer PageNumber { get; set; }
    public Integer PageNumberDisplay { get; set; }
    public Integer PageSize { get { return Integer.valueOf(Label.EBH_DistinctSellerPageSize); } }
    
    public List<Account> Sellers { 
        get {
            return Database.query(SellerQuery);
        }
    }
    
    public String SellerQuery {
        get {
            String query = EBH_ConstantsUtility.RSC_SELLERQUERY;
            
            String PLACEHOLDER = EBH_ConstantsUtility.FR_BLANK;
            
            for(Schema.FieldSetMember fld : SObjectType.Account.FieldSets.EBH_RelatedSellerFields.getFields()) {
                PLACEHOLDER += EBH_ConstantsUtility.ATCH_COMMA + fld.getFieldPath();
            }
            
            return !String.isBlank(PLACEHOLDER) ? query.replace(EBH_ConstantsUtility.PLACEH, PLACEHOLDER) : 
                   query.replace(EBH_ConstantsUtility.PLACEH, EBH_ConstantsUtility.FR_BLANK);
        }
    }
    
    /*****************************************************************************************************************************
    @ Method:         Constructor - EBH_RelatedSellersController
    @ Version:        1.0
    @ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
    @ Purpose:        To get the legal entity Id, passed through inline VF page
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      ApexPages.StandardController 
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 21.06.2017 / JOY MONDOL / Created the  Method.
    *****************************************************************************************************************************/
    public EBH_RelatedSellersController(ApexPages.StandardController controller) {        
        parentId = controller.getId();
        PageNumber = PageNumberDisplay = 0; 
        RowCount = Database.countQuery(EBH_ConstantsUtility.RSC_SELLERCOUNTQUERY);
        PageCount = Math.ceil(Decimal.valueOf(RowCount).divide(PageSize, 1));
    }
    
    /*****************************************************************************************************************************
    @ Method:         first
    @ Version:        1.0
    @ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
    @ Purpose:        To get the first page of paginated records
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      No Parameters
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 21.06.2017 / JOY MONDOL / Created the  Method.
    *****************************************************************************************************************************/
    public void first() {
        PageNumber = PageNumberDisplay = 0;
    }
    
   /*****************************************************************************************************************************
    @ Method:         next
    @ Version:        1.0
    @ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
    @ Purpose:        To get the next set of paginated records
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      No Parameters
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 21.06.2017 / JOY MONDOL / Created the  Method.
    *****************************************************************************************************************************/
    public void next() {
        PageNumber += PageSize;
        PageNumberDisplay++;
    }
    
    /*****************************************************************************************************************************
    @ Method:         previous
    @ Version:        1.0
    @ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
    @ Purpose:        To get the previous set of paginated records
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      No Parameters
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 21.06.2017 / JOY MONDOL / Created the  Method.
    *****************************************************************************************************************************/
    public void previous() {
        PageNumber -= PageSize;
        PageNumberDisplay--;
    }
    
    /*****************************************************************************************************************************
    @ Method:         last
    @ Version:        1.0
    @ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
    @ Purpose:        Used for getting the last set of records
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      No Parameter
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 21.06.2017 / JOY MONDOL / Created the  Method.
    *****************************************************************************************************************************/
    public void last() {
        PageNumber = Integer.valueOf(PageCount - 1) * PageSize;
        PageNumberDisplay = Integer.valueOf(PageCount - 1);
    }
}