/*
    Created By: Kandisa Technologies Pvt. Ltd
    Description: Class is created for redirected to login and unitbooking page
*/

public without sharing class BookNowSessionController {
    
    @AuraEnabled
    public static string findRedirectUrl() {
        string sUrl = '';
        String communityUrl = '';
        String customHomePage = '/customer/s/unitbooking';
        if (UserInfo.getUserType().equals('Guest')) {
            sUrl = communityUrl + '/customer/login?startURL=' + EncodingUtil.urlEncode(customHomePage, 'UTF-8');
        } else{
            sUrl = communityUrl + customHomePage;
        }
        return sUrl ;
    }
    
    
    
}