/*********************************************************************************************************************************
@ Class:          CouponSellerRedirector
@ Version:        1.0
@ Author:         LoumAng SENG (loumang.seng@gaea-sys.com)
@ Purpose:        US-0007360 - wrong coupon seller record when click on NEW
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 02.04.2020 / LoumAng SENG / Created the class.
				  
*********************************************************************************************************************************/
public class CouponSellerRedirector {
    private static Map<String, String> mCouponSeller_Coupon = new Map<String, String>{
        'Coupon__c' => 'Id'
   	};
    private static Map<String, String> mRT_Coupon_CouponSeller = new Map<String, String>{
        'Item_Based' => 'Manhattan_Coupon',
        'Category_Based' => 'Manhattan_Coupon',
        'Pop_Coupon' => 'Pop_Coupon'
    };
        
    @AuraEnabled
    public static Map<String, Object> doGetCoupon(String recordId) {
        Map<String, Object> mResult = new Map<String, Object>();

        try{
            String queryStr = 'SELECT RecordType.DeveloperName,'+ String.join((Iterable<String>)mCouponSeller_Coupon.values(), ',') +' FROM Coupon__c WHERE Id =: recordId';
            Coupon__c oCoupon = Database.query(queryStr);
            Map<String, Object> mField = new Map<String, Object>();
            for(String cSellerField : mCouponSeller_Coupon.keySet()){
                Object val = oCoupon.get(mCouponSeller_Coupon.get(cSellerField));
                if(val == null) continue;
                mField.put(cSellerField, val);
            }
            // Set default couponSeller recordtype by coupon
            String cSellerRT = mRT_Coupon_CouponSeller.get(''+oCoupon.getSObject('RecordType').get('DeveloperName'));
            mResult.put('recordTypeId', ApexUtil.getRecordTypeByName('Coupon_Seller__c', cSellerRT).Id);
            mResult.put('params', mField);

            mResult.put('isSuccess', true);
        } catch (Exception ex) {
            mResult.put('isSuccess', false);
            mResult.put('msg', ex.getMessage());
        }

        return mResult;
    }
        

}