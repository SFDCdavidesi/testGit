/**
 * Author : Gaeasys
 * CreatedDate: 31-May-2018
 * Description:
 * 22.12.2020 / Acmatac SEING: US-0007876 Deprecate not used component, Due to testclass code coverage
 */
public with sharing class GW_MediaPlan {
	public GW_MediaPlan(){
		
	}
	// public static Map<String, String> O2MMapping = new Map<String, String>{
	// 	Util.NS + 'IO_Paper__c' => Util.NS + 'IO_Paper__c'
	// };

	// 31.07.2020 / Acmatac SEING: US-0007876 Be able to create one or many quotes on an Opportunity, without needing to create a Media Plan
    // public static Quote convertMediaPlanToQuote(Id mediaPlanId){
    // 	//Get from Cache, avoid requery
	// 	Media_Plan__c mediaPlan = (Media_Plan__c) Util.getCache( mediaPlanId);
	// 	Quote quote = new Quote(Media_Plan__c = mediaPlanId, OpportunityId = mediaPlan.Opportunity__c);
	// 	for(M2Q_Mapping__mdt fieldMapper: (List<M2Q_Mapping__mdt>)QueryUtil.queryRecords(Util.NS+'M2Q_Mapping__mdt')) {

	// 		if( fieldMapper.default__c ) {
	// 			quote.put( fieldMapper.Quote_Field__c, fieldMapper.default_value__c);

	// 		}else if ( String.isNotBlank(fieldMapper.Media_Plan_Field__c) ) {

	// 			quote.put( fieldMapper.Quote_Field__c , mediaPlan.get(fieldMapper.Media_Plan_Field__c) );

	// 		} else if ( String.isNotBlank(fieldMapper.Opportunity_Field__c)){
					
	// 			Opportunity opp = (Opportunity) Util.getCache(mediaPlan.Opportunity__c );
	// 			quote.put( fieldMapper.Quote_Field__c , opp.get(fieldMapper.Opportunity_Field__c) );
	// 		}
	// 	}
	// 	return quote;
	// }    

	// public static void syncRec(List<Media_Plan__c> requiredSyncRecs){
	// 	if(requiredSyncRecs.isEmpty()) return ;
	// 	Map<String, Media_Plan__c> mapRequiredSyncRec = new Map<String, Media_Plan__c>(requiredSyncRecs);
    //     List<Opportunity> oppToSyncs = new List<Opportunity>();
    //     for( Media_Plan__c srcMP : (List<Media_Plan__c>) QueryUtil.queryRecords(Util.NS+'Media_Plan__c', new Set<String>{Util.NS+'Opportunity__r.'+Util.NS+'IO__r.'+Util.NS+'Dually_Signed_IO__c'}, mapRequiredSyncRec.keySet()) ) {
    //     	if(srcMP.Opportunity__r.IO__r.Dually_Signed_IO__c){
    //     		mapRequiredSyncRec.get(srcMP.Id).IO_Paper__c.addError(Label.ERR_UPDATE_TERMS);
    //     		continue;
    //     	} 
    //     	String ioFieldMap = O2MMapping.get(Util.NS +'IO_Paper__c');
    //     	//system.assertEquals(false,srcMP.Opportunity__r.IO__r.Dually_Signed_IO__c);
    //     	// let opp handle update IO
    //     	if(srcMP.Opportunity__c!=null ){
    //     		Opportunity opp = new Opportunity(Id = srcMP.Opportunity__c);
    //     		opp.put( ioFieldMap, srcMP.get(ioFieldMap));		
    //     		oppToSyncs.add(opp);
    //     	}
            
    //     }
    //     update oppToSyncs;
    // }
}