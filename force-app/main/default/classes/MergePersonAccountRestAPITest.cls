@isTest
public class MergePersonAccountRestAPITest {
    
    @isTest
    public static void teste(){
        
        Id recodeType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account masterTest = new Account();
        masterTest.RecordTypeId = recodeType;
        masterTest.LastName ='Master Test';
        insert masterTest;
        
        Account mergeTest = new Account();
        mergeTest.RecordTypeId = recodeType;
        mergeTest.LastName ='Merge Test';
        mergeTest.Website = 'www.test.com';
        insert mergeTest;
        
        string strBody = '{"masterId":"'+masterTest.Id+'","mergeId":"'+mergeTest.Id+'"}';
        String myJSON = JSON.serialize(strBody);
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://barsala--staging.cs1.my.salesforce.com/services/apexrest/upsertaccount';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        
        RestContext.request = request;
        MergePersonAccountRestAPI.mergeRecords(masterTest.Id, mergeTest.Id);
    }
    
}