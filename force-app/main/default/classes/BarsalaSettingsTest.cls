@isTest
private class BarsalaSettingsTest
{
	@isTest
	static void validateSettings()
	{
		Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
        objBarsalaSetting.Enable_Escalation_Level__c = true;
        objBarsalaSetting.Enable_Round_Robin_Trigger__c = true;
        upsert objBarsalaSetting;

		BarsalaSettings bs = new BarsalaSettings();

		bs.save();
	}
}