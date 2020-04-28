@isTest
public class TaskTriggerTest {
    
    @TestSetup static void createTestData(){
        
        Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
        objBarsalaSetting.Enable_Unit_Price_Availabilty_Update__c = true;
        objBarsalaSetting.Enable_Booking_Unit_Price_Update__c = true;
        objBarsalaSetting.TurnOff_QA_Cleaning_Create_On_UnitChange__c = false;
        objBarsalaSetting.Enable_Product_Change_Validation__c = True;
        objBarsalaSetting.Latest_Checkout_Time__c = '2.00 PM';
        objBarsalaSetting.Late_Checkout_Upcharge__c = 99.00;
        objBarsalaSetting.Late_Checkout_Cutoff__c = '11.00 AM';
        objBarsalaSetting.Earliest_Checkin_Time__c = '2.00 PM';
        objBarsalaSetting.Early_Checkin_Cutoff__c = '5.00 PM';
        objBarsalaSetting.Early_Checkin_Upcharge__c = 99.00;
        objBarsalaSetting.Wifi_Default_Network_Name__c ='Mikey_Man(Variable)';
        objBarsalaSetting.Wifi_Default_Password__c = '4013388959';
        objBarsalaSetting.Charge_per_cleaning_tier_1__c = 79;
        objBarsalaSetting.Charge_per_cleaning_tier_2__c = 75;
        objBarsalaSetting.Charge_per_cleaning_tier_3__c = 71;
        objBarsalaSetting.Charge_per_cleaning_lowest_rate__c = 71;
        objBarsalaSetting.Barsala_Support_Email__c = 'support@barsala.com';
        objBarsalaSetting.Barsala_Support_Phone__c = '+1 206 800 7277';
        objBarsalaSetting.Enable_to_Generate_Confirmation_Code__c = true;
        objBarsalaSetting.Enable_to_Clear_Unit_SyncImg_Fields__c = true;    
        objBarsalaSetting.Enable_to_set_Booking_on_Task__c = true;
        upsert objBarsalaSetting;
        
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
        
        Account objacc = [Select PersonContactId From Account Where Id = :acc.Id limit 1];
        
        
        
        Xotelia_Booking__c objbooking = new Xotelia_Booking__c();
        objbooking.Sales_channel__c = 'manual';
        objbooking.External_code__c = 'BASF80403399';
        objbooking.External_code__c = 'BASF804033';
        objbooking.Total_taxed__c = 183.33;
        objbooking.Travelers__c = 1;
        objbooking.Firstname__c = 'Test';
        objbooking.Lastname__c = 'RP100';
        objbooking.Email__c = 'testrp@barsala.com';
        objbooking.Phone_number__c = '9898989898';
        objbooking.Start_date__c = system.now().addDays(-5);
        objbooking.End_date__c = system.now().addDays(5);
        objbooking.Product__c = u.id;
        objbooking.Billing_Contact__c = objacc.PersonContactId;
        objbooking.Guest_Contact__c = objacc.PersonContactId;
        objBooking.Discount__c = 10;
        objBooking.Sub_Total__c =  50;
        objBooking.Total_taxed__c =  2;
        insert objbooking;
        
        Account acc1 = new Account(name='test acc1');
        Insert acc1;
        
        Contact con1 = new Contact(lastName='lastName1', AccountId=acc1.Id);
        Insert con1; 
        
        Xotelia_Booking__c objbooking1 = new Xotelia_Booking__c();
        objbooking1.Sales_channel__c = 'manual';
        objbooking1.External_code__c = 'BASF80403398';
        objbooking1.External_code__c = 'BASF804034';
        objbooking1.Total_taxed__c = 183.33;
        objbooking1.Travelers__c = 1;
        objbooking1.Firstname__c = 'Test';
        objbooking1.Lastname__c = 'RP100';
        objbooking1.Email__c = 'testrp1@barsala.com';
        objbooking1.Phone_number__c = '9898989899';
        objbooking1.Start_date__c = system.now().addDays(-5);
        objbooking1.End_date__c = system.now().addDays(5);
        objbooking1.Product__c = u.id;
        objbooking1.Billing_Contact__c = con1.Id;
        //objbooking1.Guest_Contact__c = objacc.PersonContactId;
        objbooking1.Discount__c = 10;
        objbooking1.Sub_Total__c =  50;
        objbooking1.Total_taxed__c =  2;
        insert objbooking1;
        
        
        Account acc2 = new Account(name='test acc2');
        Insert acc2;
        
        Contact con2 = new Contact(lastName='lastName2', AccountId=acc2.Id);
        Insert con2; 
        
        Xotelia_Booking__c objbooking2 = new Xotelia_Booking__c();
        objbooking2.Sales_channel__c = 'manual';
        objbooking2.External_code__c = 'BASF80403399';
        objbooking2.External_code__c = 'BASF804035';
        objbooking2.Total_taxed__c = 183.33;
        objbooking2.Travelers__c = 1;
        objbooking2.Firstname__c = 'Test';
        objbooking2.Lastname__c = 'RP100';
        objbooking2.Email__c = 'testrp2@barsala.com';
        objbooking2.Phone_number__c = '9898989897';
        objbooking2.Start_date__c = system.now().addDays(5);
        objbooking2.End_date__c = system.now().addDays(10);
        objbooking2.Product__c = u.id;
        objbooking2.Billing_Contact__c = con2.Id;
        //objbooking2.Guest_Contact__c = objacc.PersonContactId;
        objbooking2.Discount__c = 10;
        objbooking2.Sub_Total__c =  50;
        objbooking2.Total_taxed__c =  2;
        insert objbooking2;
        
    }
    
    @isTest
    public static void createTaskForPersonalAccount(){
        Account acc = [SELECT Id FROM Account WHERE FirstName = 'Test FName' AND PersonEmail = 'test@yahoo.com' AND ispersonaccount = true LIMIT 1];
        
        Task ts = new Task();
        ts.WhatId = acc.Id;
        ts.OwnerId = Userinfo.getUserId();
        ts.Subject = 'Test Task';
        ts.Priority = 'Normal';
        ts.Status = 'Completed';
        
        Test.startTest();
        
        Insert ts;
        
        Test.stopTest();
        
        
    }
    
     @isTest
    public static void createTaskForContact(){
  
      Contact con = [SELECT Id from Contact WHERE Lastname='lastName1' LIMIT 1];
        
        Task ts = new Task();
        ts.WhoId = con.id;
        ts.OwnerId = Userinfo.getUserId();
        ts.Subject = 'Test Task';
        ts.Priority = 'Normal';
        ts.Status = 'Completed';
        
        Test.startTest();
        
        Insert ts;
        
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void createTaskForFutureBookings(){
        
       
        Contact con = [SELECT Id FROM Contact WHERE LastName ='lastName2' LIMIT 1];
        Task ts = new Task();
        ts.WhoId = con.id;
        ts.OwnerId = Userinfo.getUserId();
        ts.Subject = 'Test Task';
        ts.Priority = 'Normal';
        ts.Status = 'Completed';
        
        Test.startTest();
        
        Insert ts;
        
        Test.stopTest();
        
        
    }
    
}