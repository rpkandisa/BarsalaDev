/**
 * It's used to cover processtoConvertBusinessToPersonAccount code coverage
 */
@isTest
public with sharing class ConvertBusinessToPersonAccountTest {
  
    @IsTest
    static void validatePersonAccount(){
        
        Test.startTest();
        
        String GBRTId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Growth - Buildings and Units').getRecordTypeId();
        Account acc1 = new Account();
        acc1.RecordTypeId = GBRTId;
        acc1.Name='Aircall New Account';
        acc1.BillingCity ='Chennai' ;
        acc1.BillingCountry='india';
        acc1.BillingPostalCode='600075';
        acc1.BillingState='tamil nadu';
        acc1.BillingStreet='water well street'; 
        acc1.Phone = '19898767654';
        insert acc1;

        Contact objcon = new Contact();
        objcon.LastName = 'testlast';
        objcon.Phone = '19898767654';
        objcon.AccountId = acc1.Id;
        insert objcon;

        Task t = new Task();
        t.CallDisposition = 'aircall';
        t.CallDurationInSeconds = 25;
        t.WhatId = acc1.Id;
        insert t;

        List<ProcessToConvertBusinessToPersonAccount.wrpbusinesstoperson> lstwrp = new List<ProcessToConvertBusinessToPersonAccount.wrpbusinesstoperson>();
        ProcessToConvertBusinessToPersonAccount.wrpbusinesstoperson o = new ProcessToConvertBusinessToPersonAccount.wrpbusinesstoperson();
        o.taskid = t.id;
        o.businessaccountid = acc1.id;
        o.phone = acc1.Phone;
        lstwrp.add(o);

        ProcessToConvertBusinessToPersonAccount.convertAccountToPersonAccount(lstwrp);

        Test.stopTest();
        
    }
    
}