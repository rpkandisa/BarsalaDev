@isTest
public class clearGuestControllerTest {
    @TestSetup static void createTestData(){
        City__c c = new City__c();
        c.Name = 'Seattle';
        c.State__c = 'SD';
        c.Rebooking_Price_Threshold_Below__c=5;
        c.Rebooking_Price_Threshold_Above__c=10;
        c.Checkin_Time_Cutoff__c = DateTime.now().time();
        c.Tax__c = 0.21;
        insert c;
        
        City__c c1 = new City__c();
        c1.Name = 'San Diego';
        c1.State__c = 'SD';
        c1.Rebooking_Price_Threshold_Below__c=5;
        c1.Rebooking_Price_Threshold_Above__c=10;
        c1.Checkin_Time_Cutoff__c= DateTime.now().time();
        c1.Tax__c = 0.15;
        insert c1;
        
        Neighborhood__c nb = new Neighborhood__c(Name='Test NB 1', City__c = c.Id);
        insert nb;
        
        Neighborhood__c nb1 = new Neighborhood__c(Name='Test NB 2', City__c = c1.Id);
        insert nb1;
        
        Building__c  b = new Building__c(Name='test 1',Neighborhood__c = nb.Id,City__c = 'Seattle',Same_Day_Reservation_End_Time__c = '06:00 AM');
        insert b;
        
        Building__c  b2 = new Building__c(Name='test 2',Neighborhood__c = nb.Id,City__c = 'Seattle',Same_Day_Reservation_End_Time__c = '06:00 AM');
        insert b2;
        
        Building__c  b3 = new Building__c(Name='test 3',Neighborhood__c = nb1.Id,City__c = 'San Diego',Same_Day_Reservation_End_Time__c = '06:00 AM');
        insert b3;
        
        Unit_set__c us = new Unit_set__c(Name = 'Test US 1');
        insert us;
        
        Unit__c u = new Unit__c(Building__c=b.id,Name='test 1',Unit__c='1',Base_price__c=120,Beds__c='1',Unit_set__c = us.Id,
                                Airbnb_listing_name__c='test', Bedrooms__c='1', Bathroom__c='1', 
                                Airbnb_ID__c='test1', Beyond_Pricing_ID__c='test1', RU_ID__c='test1', Website_Listing_Name__c='test'
                               );
        insert u;
        
        Unit__c u2 = new Unit__c(Building__c=b2.id,Name='test 2',Unit__c='2',Base_price__c=100,Beds__c='2',Unit_set__c = us.Id,
                                 Airbnb_listing_name__c='test2', Bedrooms__c='2', Bathroom__c='2',
                                 Airbnb_ID__c='test2', Beyond_Pricing_ID__c='test2', RU_ID__c='test2', Website_Listing_Name__c='test'
                                );
        insert u2;
        
        Unit__c u3 = new Unit__c(Building__c=b3.id,Name='test 3',Unit__c='3',Base_price__c=110,Beds__c='3',Unit_set__c = us.Id,
                                 Airbnb_listing_name__c='test3', Bedrooms__c='2', Bathroom__c='2',
                                 Airbnb_ID__c='test3', Beyond_Pricing_ID__c='test3', RU_ID__c='test3', Website_Listing_Name__c='test'
                                );
        insert u3;
        
        list<unit_pricing__c> unitPriceList = new list<unit_pricing__c>();
        date d = date.today();
        system.debug(d);
        for(integer i =0;i<70;i++){
            unitPriceList.add(new unit_pricing__c(Unit__c = u.id, Availability_Status__c = 'Available',BP_Price_Modeled__c=120,name=string.valueOf(d), UNITPRICE_DATE__c=d));
            system.debug('u :: '+unitPriceList[i]);
            d += 1;
        }
        
        d = date.today();
        for(integer i =0;i<70;i++){
            unitPriceList.add(new unit_pricing__c(Unit__c = u2.id, Availability_Status__c = 'Available',BP_Price_Modeled__c=120,name=string.valueOf(d), UNITPRICE_DATE__c=d));
            system.debug('u :: '+unitPriceList[i]);
            d += 1;
        }
        
        insert unitPriceList;
        
        insert new Stripe_Setting__c(
            End_Point__c = 'www.test.com',
            Secret_Key__c = 'test',
            Dashboard_URL__c = 'www.test.com',
            Email_Addresses__c = 'test@test.com'
        );
        
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonEmail='test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678' 
        ); 
        insert acc;
        Account ac = new Account(name ='Test Account') ;
        insert ac;
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName ='TestLName';
        con.Phone = '9874563210';
        con.Email = 'test@test.com';
        con.AccountId = ac.Id;
        con.Stripe_Customer_ID__c = 'cus_FxYpDRG0ewPEBh';
        insert con;  
        System.debug('con Id :: ' + con.Id);
        
        Account objacc = [Select PersonContactId From Account Where Id = :acc.Id limit 1];
        
        
        
        Xotelia_Booking__c objbooking1 = new Xotelia_Booking__c();
        objbooking1.Sales_channel__c = 'manual';
        objbooking1.External_code__c = 'BASF80403390';
        objbooking1.External_code__c = 'BASF8040330';
        objbooking1.Total_taxed__c = 183.33;
        objbooking1.Travelers__c = 1;
        objbooking1.Firstname__c = 'Test1 ';
        objbooking1.Lastname__c = 'RP101';
        objbooking1.Email__c = 'testrpTest@barsala.com';
        objbooking1.Phone_number__c = '8989898980';
        objbooking1.Start_date__c = system.now().addDays(-5);
        objbooking1.End_date__c = system.now().addDays(5);
        objbooking1.Product__c = u.id;
        objbooking1.Billing_Contact__c = con.Id;
        objbooking1.Discount__c = 10;
        objbooking1.Sub_Total__c =  50;
        objbooking1.Total_taxed__c =  2;
        objbooking1.Status__c ='Active';
        objbooking1.Screening_Decision__c ='Consider';
        objbooking1.Elevated_Fraud_Risk__c='On Hold - Fraud Possible';
        objbooking1.Private_comment__c='';
        insert objbooking1;
        
        Xotelia_Booking__c objbooking = new Xotelia_Booking__c();
        objbooking.Sales_channel__c = 'booking';
        objbooking.External_code__c = 'BASF80403999';
        objbooking.External_code__c = 'BASF8040999';
        objbooking.Total_taxed__c = 18.9;
        objbooking.Travelers__c = 2;
        objbooking.Firstname__c = 'Test9 ';
        objbooking.Lastname__c = 'RP109';
        objbooking.Email__c = 'rp12345@barsala.com';
        objbooking.Phone_number__c = '8989898123';
        objbooking.Start_date__c = system.now().addDays(-5);
        objbooking.End_date__c = system.now().addDays(5);
        objbooking.Product__c = u.id;
        objbooking.Billing_Contact__c = con.Id;
        objbooking.Discount__c = 10;
        objbooking.Sub_Total__c =  50;
        objbooking.Total_taxed__c =  2;
        objbooking.Status__c ='Active';
        objbooking.Screening_Decision__c ='Consider';
        objbooking.Elevated_Fraud_Risk__c='';
        objbooking.Private_comment__c='';
        insert objbooking;
        
        Xotelia_Booking__c objbooking2 = new Xotelia_Booking__c();
        objbooking2.Sales_channel__c = 'booking';
        objbooking2.External_code__c = 'BASF80403111';
        objbooking2.External_code__c = 'BASF8040111';
        objbooking2.Total_taxed__c = 18.9;
        objbooking2.Travelers__c = 2;
        objbooking2.Firstname__c = 'Test56 ';
        objbooking2.Lastname__c = 'Temp123';
        objbooking2.Email__c = 'rpTemp12345@barsala.com';
        objbooking2.Phone_number__c = '8981118123';
        objbooking2.Start_date__c = system.now().addDays(-5);
        objbooking2.End_date__c = system.now().addDays(5);
        objbooking2.Product__c = u.id;
        objbooking2.Billing_Contact__c = con.Id;
        objbooking2.Discount__c = 10;
        objbooking2.Sub_Total__c =  50;
        objbooking2.Total_taxed__c =  2;
        objbooking2.Status__c ='Active';
        objbooking2.Screening_Decision__c ='Consider';
        objbooking2.Elevated_Fraud_Risk__c='';
        objbooking2.Private_comment__c='Manually Cleared by Kandisa Team';
        insert objbooking2;
        
        Xotelia_Booking__c objbooking3 = new Xotelia_Booking__c();
        objbooking3.Sales_channel__c = 'booking';
        objbooking3.External_code__c = 'BASF80403222';
        objbooking3.External_code__c = 'BASF8040222';
        objbooking3.Total_taxed__c = 18.9;
        objbooking3.Travelers__c = 2;
        objbooking3.Firstname__c = 'Test ';
        objbooking3.Lastname__c = 'Temp';
        objbooking3.Email__c = 'rp00000@barsala.com';
        objbooking3.Phone_number__c = '8981119123';
        objbooking3.Start_date__c = system.now().addDays(-5);
        objbooking3.End_date__c = system.now().addDays(5);
        objbooking3.Product__c = u.id;
        objbooking3.Billing_Contact__c = con.Id;
        objbooking3.Discount__c = 10;
        objbooking3.Sub_Total__c =  50;
        objbooking3.Total_taxed__c =  2;
        objbooking3.Status__c ='Active';
        objbooking3.Screening_Decision__c ='Consider';
        objbooking3.Elevated_Fraud_Risk__c='On Hold - Fraud Possible';
        objbooking3.Private_comment__c='Manually Cleared by Kandisa Team';
        insert objbooking3;
    }
    
    @isTest
    public static void TestControllerOne(){
        Xotelia_Booking__c booking = [SELECT id,Email__c FROM Xotelia_Booking__c WHERE Email__c='testrpTest@barsala.com'];
        System.debug('booking::'+booking);
        Test.StartTest(); 
        
        
        PageReference pageRef = Page.ResendreviewForm;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(booking.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(booking);
        clearGuestController testcon = new clearGuestController(sc);
        
        
        testcon.currentRecordId = booking.Id;
        
        
        testcon.redirect();
        testcon.Save();
        
        
        Test.StopTest();
    }
    
    @isTest
    public static void TestControllerTwo(){
        Xotelia_Booking__c booking1 = [SELECT id,Email__c FROM Xotelia_Booking__c WHERE Email__c='rp12345@barsala.com'];
        System.debug('booking::'+booking1);
        Test.StartTest(); 
        
        
        PageReference pageRef = Page.ResendreviewForm;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(booking1.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(booking1);
        clearGuestController testcon = new clearGuestController(sc);
        
        
        testcon.currentRecordId = booking1.Id;
        
        
        testcon.redirect();
        testcon.Save();
        
        
        Test.StopTest();
    }
    
    
    @isTest
    public static void TestControllerThree(){
        Xotelia_Booking__c booking2 = [SELECT id,Email__c FROM Xotelia_Booking__c WHERE Email__c='rpTemp12345@barsala.com'];
        System.debug('booking::'+booking2);
        Test.StartTest(); 
        
        
        PageReference pageRef = Page.ResendreviewForm;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(booking2.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(booking2);
        clearGuestController testcon = new clearGuestController(sc);
        
        
        testcon.currentRecordId = booking2.Id;
        
        
        testcon.redirect();
        testcon.Save();
        
        
        Test.StopTest();
    }
    
    
    @isTest
    public static void TestControllerFour(){
        Xotelia_Booking__c booking2 = [SELECT id,Email__c FROM Xotelia_Booking__c WHERE Email__c='rp00000@barsala.com'];
        System.debug('booking::'+booking2);
        Test.StartTest(); 
        
        
        PageReference pageRef = Page.ResendreviewForm;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(booking2.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(booking2);
        clearGuestController testcon = new clearGuestController(sc);
        
        
        testcon.currentRecordId = booking2.Id;
        
        
        testcon.redirect();
        testcon.Save();
        
        
        Test.StopTest();
    }

     @isTest
    public static void TestControllerFive(){
        Xotelia_Booking__c booking2 = [SELECT id,Email__c FROM Xotelia_Booking__c WHERE Email__c='rp00000@barsala.com'];
        System.debug('booking::'+booking2);
        Test.StartTest(); 
        
        
        PageReference pageRef = Page.ResendreviewForm;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(booking2.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(booking2);
        clearGuestController testcon = new clearGuestController(sc);
        
        
        testcon.currentRecordId = booking2.Id;
        
        
        testcon.getElevatedFraudRisk();
        clearGuestController.findExistingContacts('rp00000@barsala.com','');
        
        
        Test.StopTest();
    }
    
}