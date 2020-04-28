@isTest
private class customsettingcontrollerTest
{
    private static testMethod void validateCustomSetting() {

        test.startTest();

            customsettingcontroller cs = new customsettingcontroller();
            cs.fnPageRedirect();
        
        test.stopTest();
    }

}