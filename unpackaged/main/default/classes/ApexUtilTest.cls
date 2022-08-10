@Istest
private class ApexUtilTest {
	static testMethod void testUtil()
	{
		Test.startTest();
			ApexUtil.formatNumber(10000,',','.',2);
			ApexUtil.formatNumber(10000,2,'DE');
			ApexUtil.checkNull(10);
			ApexUtil.formatTime(null);
			ApexUtil.mapCurrencySign.get('USD');
			ApexUtil.toDecimal('1000',2);
			ApexUtil.toDecimal0('1000',2);
			ApexUtil.toInteger('10');
			ApexUtil.toDouble('10');
			ApexUtil.getUserRoleByName('Global');
			ApexUtil.getRecordTypeByName('Account','EBH_Seller');
			ApexUtil.getRecordTypeBySobjectName('Account');
			ApexUtil.doSend('subject','test@test.com','html body here');
			ApexUtil.checkPermissionSet(new Set<String>{'no_permission_name'});
			ApexUtil.getValue('Parent.Name',new Account(Name='Test'));
			ApexUtil.runningInASandbox();
			ApexUtil.getSiteUrl('Deal_Acceptance');
			ApexUtil.getUsersMemberByGroup(new  Set<String>{'group1'});
			ApexUtil.constructQuoteString(new Set<String>{'x','y'});
			ApexUtil.generateSQOLFields('Account');
			ApexUtil.doCompare('=',4,4);
			ApexUtil.doCompare('<',4,4);
			ApexUtil.doCompare('<=',4,4);
			ApexUtil.doCompare('>',4,4);
			ApexUtil.doCompare('>=',4,4);
			ApexUtil.genUniqueString(10);
			ApexUtil.countRunningBatch(new Set<String>{'Batch1'});
			ApexUtil.nullStr('');
			ApexUtil.findCronJob(new Set<String>{'BatchCouponSellerStatus'});
			Map<String, List<ApexUtil.PicklistEntryWrapper>> objResults  = ApexUtil.getDependentMap(EBH_Deal__c.getSObjectType(),'EBH_DealSiteId__c','EBH_Vertical__c');
			ApexUtil.getPicklistValues(EBH_Deal__c.EBH_DealFormat__c);
        ApexUtil.getFieldIdRef('EBH_BusinessName__r.Name');
        ApexUtil.fixNumber('15.5','EN');
        ApexUtil.permissionSetMembers('test');
		ApexUtil.getCurrentUser();

		Map<String,String> binding = new Map<String,String>();
		List<EmailTemplate>  template = [select Id, Name, Body, Subject, HtmlValue, DeveloperName from EmailTemplate where DeveloperName = 'NA_Deals_Notify_Approvals' LIMIT 1];
		if(template.isEmpty()){
			binding.put('{!User.Phone}', 'xxxxxxxxxxxx');
		}else{
			binding.put('{!EBH_Deal__c.Merchant_Approver__c}', 'Test Name');
			binding.put('{!EBH_Deal__c.Link}', URL.getOrgDomainUrl().toExternalForm());
		}

		Messaging.SingleEmailMessage preparedEmail = ApexUtil.prepareEmail(null, new String[] {'sophal.noch@gaea-sys.com.invalid'}, null, 'NA_Deals_Notify_Approvals', 'Sample_GreatMeetingYou', binding, null, null);
		//ApexUtil.sendEmail(new List<Messaging.SingleEmailMessage>{preparedEmail});

		Test.stopTest(); 

		ApexUtil.getProfileByName('Administrator');
		ApexUtil.getPermissionSetL('test');
		ApexUtil.getOWDbyAddress('');
		ApexUtil.getFieldSet('Account', 'test') ;
		ApexUtil.validSFId(UserInfo.getUserId());
		ApexUtil.MAP_LOCALE_DATEFORMAT();

		ApexUtil.chunkList(new List<Object>{'a','b'},1);

		ApexUtil.isProduction();
		ApexUtil.gmtDateToDTZone(system.today(),Time.newInstance(1, 2, 3, 4),'PST');
        ApexUtil.generateUniqueString(new List<ID>{UserInfo.getUserId()});

		ApexUtil.revokeUserAccess3PLink(UserInfo.getUserId(),'xyzabc');
	}
}