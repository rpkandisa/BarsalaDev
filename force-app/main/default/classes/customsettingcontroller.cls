public with sharing class customsettingcontroller {
    
    public PageReference fnPageRedirect(){
        PageReference myVFPage = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/setup/ui/listCustomSettings.apexp');
        myVFPage.setRedirect(true);
        String retURL = EncodingUtil.urlEncode('/ui/setup/Setup?setupid=DevToolsIntegrate', 'UTF-8');
        myVFPage.getParameters().put('retURL', retURL);
        myVFPage.getParameters().put('setupid', 'CustomSettings');
        return myVFPage;        
    }

}