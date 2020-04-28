@isTest 
public class ContactTriggerTest 
{
    static testMethod void testMethod1() 
    {
        Test.StartTest(); 

        Id recodeType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.LastName='Test Account';
        testAccount.RecordTypeId = recodeType;
        testAccount.Phone = '1987652345,18787234590';
        insert testAccount;

        Contact c = new Contact();
        c.LastName = 'contactlastname';
        c.Email = 'test123@bc.com';
        c.Phone = '18989076543,12626234590';
        insert c;
        
        Test.StopTest();
    }
    
    static testMethod void testMethod2(){
        List<Contact> contactList = new List<Contact>();
        Id recodeType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.LastName='Test Account';
        testAccount.RecordTypeId = recodeType;
        testAccount.Phone = '1987652345,18787234590';
        insert testAccount;

        Contact c = new Contact();
        c.LastName = 'contactlastname';
        c.Email = 'test123@bc.com';
        c.Phone = '18989076543';
        insert c;
        contactList.add(c);
        
        
        
        Test.startTest();
         Contact con = new Contact();
        con.LastName = 'lastname';
        con.Email = 'test123@bc.com';
        con.Phone = '18989076543';
        insert con;
        ContactTriggerHandler.checkDuplicatContact(contactList,true);
        Test.stopTest();
    }
    
    static testMethod void testMethod3(){
        List<Contact> contactList = new List<Contact>();
        Id recodeType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.LastName='Test Account';
        testAccount.RecordTypeId = recodeType;
        testAccount.Phone = '1987652345,18787234590';
        insert testAccount;

        Contact c = new Contact();
        c.LastName = 'contactlastname';
        c.Email = 'test123@bc.com';
        c.Phone = '18989076543';
        insert c;
        contactList.add(c);
        
        
        
        Test.startTest();
         Contact con = new Contact();
        con.LastName = 'lastname';
        con.Email = 'test123@bc.com';
        con.Phone = '18989076543';
        insert con;
        ContactTriggerHandler.checkDuplicatContact(contactList,false);
        Test.stopTest();
    }
}