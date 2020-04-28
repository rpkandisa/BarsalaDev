public with sharing class BarsalaSettings {
	public Barsala_Settings__c obj{get;set;}
	public BarsalaSettings() {
		obj = Barsala_Settings__c.getOrgDefaults();
	}

	public void save(){
		update obj;
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Saved Successfully!'));
	}
}