//added by Kandisa Tech on 03/01/2019
//It is used to create person account record if newly created case does not haveing Account/Contact

@isTest	
public with sharing class EmailMessageTriggerTest {
    static testMethod void ValidteEmailMessageTriggerTest() {
        Test.startTest();
        Case c = new Case();
        c.Subject = 'Om Test';
        c.Status ='New';
        c.Priority = 'Medium';
        c.Origin = 'Email';
        insert c;

        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = c.Id; 
        insert email;
        Test.stopTest();
    }

    static testMethod void ValidteEmailMessageTriggerTest1() {
        Test.startTest();
        Case c = new Case();
        c.Subject = 'Om Test';
        c.Status ='New';
        c.Priority = 'Medium';
        c.Origin = 'Email';
        insert c;

        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@m.expediapartnercentral.com';
        email.Incoming = True;
        email.ToAddress= 'test@m.expediapartnercentral.com';
        email.Subject = 'guest response from Test';
        email.HtmlBody = 'Test email body';
        email.ParentId = c.Id; 
        insert email;
        Test.stopTest();
    }

    static testMethod void ValidteEmailMessageTrigger2Test() {
        Test.startTest();
        Case c = new Case();
        c.Subject = 'Om2 Test';
        c.Status ='New';
        c.Priority = 'Medium';
        c.Origin = 'Email';
        insert c;

        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test2@abc.org';
        email.FromName = 'Test Case';
        email.Incoming = True;
        email.ToAddress= 'test2@xyz.org';
        email.Subject = 'Test email2';
        email.HtmlBody = 'Test email2 body';
        email.ParentId = c.Id; 
        insert email;
        Test.stopTest();
    }

     static testMethod void ValidteEmailMessageTrigger3Test() {
        Test.startTest();
        Case c = new Case();
        c.Subject = 'Om2 Test';
        c.Status ='New';
        c.Priority = 'Medium';
        c.Origin = 'Email';
        insert c;

        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'aaaaaa@mchat.booking.com';
        email.FromName = 'Test Case';
        email.Incoming = True;
        email.ToAddress= 'test2@xyz.org';
        email.Subject = 'Test email2';
        email.HtmlBody = 'Test email2 body';
        email.ParentId = c.Id; 
        insert email;
        Test.stopTest();
    }

    static testMethod void ValidteEmailMessageTrigger4Test() {
        Test.startTest();
        Case c = new Case();
        c.Subject = 'Om2 Test';
        c.Status ='New';
        c.Priority = 'Medium';
        c.Origin = 'Email';
        insert c;

        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'aaaaaa@mchat.booking.com';
        email.FromName = 'Test Case';
        email.Incoming = True;
        email.ToAddress= 'test2@xyz.org';
        email.Subject = 'Test email2';
        email.HtmlBody = 'Confirmation number: BASF28223236 test';
        email.ParentId = c.Id; 
        insert email;
        Test.stopTest();
    }
}