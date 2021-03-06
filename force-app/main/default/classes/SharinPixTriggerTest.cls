@isTest
private class SharinPixTriggerTest
{
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
        upsert objBarsalaSetting;

        City__c c = new City__c();
        c.Name = 'Seattle';
        c.State__c = 'SD';
        c.Rebooking_Price_Threshold_Below__c=5;
        c.Rebooking_Price_Threshold_Above__c=10;
        c.Checkin_Time_Cutoff__c = DateTime.now().time();
        insert c;
        
        City__c c1 = new City__c();
        c1.Name = 'San Diego';
        c1.State__c = 'SD';
        c1.Rebooking_Price_Threshold_Below__c=5;
        c1.Rebooking_Price_Threshold_Above__c=10;
        c1.Checkin_Time_Cutoff__c= DateTime.now().time();
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
                Airbnb_ID__c='test1', Beyond_Pricing_ID__c='test1', RU_ID__c='test1'
            );
        insert u;

        Unit__c u2 = new Unit__c(Building__c=b2.id,Name='test 2',Unit__c='2',Base_price__c=100,Beds__c='2',Unit_set__c = us.Id,
                Airbnb_listing_name__c='test2', Bedrooms__c='2', Bathroom__c='2',
                Airbnb_ID__c='test2', Beyond_Pricing_ID__c='test2', RU_ID__c='test2'
            );
        insert u2;

        Unit__c u3 = new Unit__c(Building__c=b3.id,Name='test 3',Unit__c='3',Base_price__c=110,Beds__c='3',Unit_set__c = us.Id,
                Airbnb_listing_name__c='test3', Bedrooms__c='2', Bathroom__c='2',
                Airbnb_ID__c='test3', Beyond_Pricing_ID__c='test3', RU_ID__c='test3'
            );
        insert u3;

        list<unit_pricing__c> unitPriceList = new list<unit_pricing__c>();
        date d = date.today();
        system.debug(d);
        for(integer i =0;i<70;i++){
            unitPriceList.add(new unit_pricing__c(Unit__c = u.id, Availability_Status__c = 'Available',BP_Price_Modeled__c=120,name=string.valueOf(d)));
            system.debug('u :: '+unitPriceList[i]);
            d += 1;
        }

        d = date.today();
        for(integer i =0;i<70;i++){
            unitPriceList.add(new unit_pricing__c(Unit__c = u2.id, Availability_Status__c = 'Available',BP_Price_Modeled__c=120,name=string.valueOf(d)));
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


        Housekeeping_Setting__c hkSetting = new Housekeeping_Setting__c(
          Deep_Cleaning_Validation__c = true,
          Deep_Cleaning_Minimum_Images__c = 5
      );
      insert hkSetting;

        
    }

	@isTest
	static void itShould()
	{

        

		  Unit__c u = [select id, Base_price__c from Unit__c where Name='test 1' AND Unit__c='1' limit 1];

        
        Xotelia_Booking__c book1 = new Xotelia_Booking__c(Firstname__c= 'FName',Lastname__c='LName',Email__c = 'test1@gmail.com',
                Product__c=u.id,External_code__c='manual',Start_date__c=date.today(),End_date__c=date.today().addDays(65),Status__c='Active',Travelers__c=1,Sales_channel__c='expedia',
                Stripe_Customer__c='777customers/cus_test',
                Credit_Card_Full_Name__c = 'test',
                Credit_Card_CVV__c='test',
                Credit_Card_Number__c='1112223334445443',
                Credit_Card_Expiration_Date__c='12/'+Date.today().Year(),
                Credit_Card_Type__c='VISA',
                Zip_Code__c='test');
        UnitBookingController.ResponseModel rm = UnitBookingController.BookUnit(book1,system.now().format('MM/dd/yyyy'),system.now().addDays(2).format('MM/dd/yyyy'), true);
        insert rm.bookings;

        //Create account
        Account portalAccount1 = new Account(
        Name = 'TestAccount'
        );
        insert portalAccount1;

        //Create contact
        Contact contact1 = new Contact(
        FirstName = 'Test',
        Lastname = 'McTesty',
        AccountId = portalAccount1.Id,
        Email = System.now().millisecond() + 'test@test.com'
        );
        insert contact1;

        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community - Housekeeping'];
            //UserRole ur = [select Id from UserRole where Name='Internal User' limit 1];        
            User u2 = new User(
                Alias = 'newUser', 
                //UserRoleId = ur.Id,
                Email='newuser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', 
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                ContactId = contact1.Id,
                TimeZoneSidKey='America/Los_Angeles', 
                UserName=System.now().millisecond() + 'test12345@test.com'
            );
            insert u2;

            Cleaning_Assignment__c ca = new Cleaning_Assignment__c(
                Booking__c = rm.bookings[0].Id,
                Cleaning_Type__c = 'Check-out',
                OwnerId=u2.Id
            );
            insert ca;

             System.runAs(u2) {
                sharinpix__SharinPixImage__c spImage = new sharinpix__SharinPixImage__c(
                    Cleaning_Assignment__c = ca.Id
                );
                insert spImage;
                
                delete spImage;
             }

             sharinpix__SharinPixImage__c spImageforunit = new sharinpix__SharinPixImage__c(
                    Unit__c = u.Id
                );
                insert spImageforunit;

                spImageforunit.sharinpix__Description__c = 'test';
                update spImageforunit;

        }


        Test.stopTest();
	}
}