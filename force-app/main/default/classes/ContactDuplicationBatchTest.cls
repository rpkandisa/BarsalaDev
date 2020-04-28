@isTest 
public class ContactDuplicationBatchTest {
    
    static testMethod void validateBatch() {
        List<Contact> lstContact= new List<Contact>();

        
        Contact con = new Contact();
        con.LastName ='testdata';
        con.Phone = '9898989898';
        con.Email = 'con@gmail.com';
        lstContact.add(con);

        con = new Contact();
        con.LastName ='testdata111';
        con.Phone = '9898989898';
        con.Email = 'aaaa@gmail.com';
        lstContact.add(con);

        con = new Contact();
        con.LastName ='testdata111';
        con.Phone = '9898989898';
        con.Email = 'aaaa@gmail.com';
        lstContact.add(con);

        con = new Contact();
        con.LastName ='testdata111';
        con.MobilePhone = '9898989898';
        con.Email = 'bbb@gmail.com';
        lstContact.add(con);

        insert lstContact;

        City__c c1 = new City__c();
        c1.Name = 'San Diego';
        c1.State__c = 'SD';
        c1.Rebooking_Price_Threshold_Below__c=5;
        c1.Rebooking_Price_Threshold_Above__c=10;
        c1.Checkin_Time_Cutoff__c= DateTime.now().time();
        insert c1;

        Neighborhood__c nb = new Neighborhood__c(Name='Test NB 1', City__c = c1.Id);
        insert nb;

        Unit_set__c us = new Unit_set__c(Name = 'Test US 1');
        insert us;

        Building__c  b = new Building__c(Name='test 1', Neighborhood__c = nb.Id, Same_Day_Reservation_End_Time__c = '06:00 AM');
        insert b;

        Unit__c u = new Unit__c(Building__c=b.id,Name='test 1',Unit__c='1',Base_price__c=120,Beds__c='1',Unit_set__c = us.Id,
                Airbnb_listing_name__c='test 1', Bedrooms__c='1', Bathroom__c='1'
            );
        insert u;

        Xotelia_Booking__c book = new Xotelia_Booking__c(Sales_Channel__c='manual',Product__c=u.id,External_code__c='12345',Start_date__c=date.today(),End_date__c=date.today().addDays(3),Status__c='Inactive', Billing_Contact__c= lstContact.get(0).Id);
        insert book;

        book = new Xotelia_Booking__c(Sales_Channel__c='manual',Product__c=u.id,External_code__c='123456',Start_date__c=date.today(),End_date__c=date.today().addDays(3),Status__c='Inactive', Guest_Contact__c= lstContact.get(1).Id);
        insert book;


        Test.startTest();

        ContactDuplicationBatch obj = new ContactDuplicationBatch();
        DataBase.executeBatch(obj); 

        Test.stopTest();
        
    }
}