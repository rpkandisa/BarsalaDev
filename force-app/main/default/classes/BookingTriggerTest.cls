/*
    Created By: Kandisa Technologies Pvt. Ltd
    Description: Test Class for Booking Trigger.
*/
@isTest
private class BookingTriggerTest {
    
    @isTest static void UnitBookingUpdate() {
        Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
        objBarsalaSetting.Max_Nightly_Rate__c = 3000;
        objBarsalaSetting.Enable_Unit_Price_Availabilty_Update__c = true;
        objBarsalaSetting.Enable_Booking_Unit_Price_Update__c = true;
        objBarsalaSetting.TurnOff_QA_Cleaning_Create_On_UnitChange__c = false;
        objBarsalaSetting.Enable_Product_Change_Validation__c = true;
        objBarsalaSetting.Latest_Checkout_Time__c = '2.00 PM';
        objBarsalaSetting.Late_Checkout_Upcharge__c = 99.00;
        objBarsalaSetting.Late_Checkout_Cutoff__c = '11.00 AM';
        objBarsalaSetting.Earliest_Checkin_Time__c = '2.00 PM';
        objBarsalaSetting.Early_Checkin_Cutoff__c = '5.00 PM';
        objBarsalaSetting.Early_Checkin_Upcharge__c = 99.00;
        objBarsalaSetting.Wifi_Default_Network_Name__c = 'Mikey_Man(Variable)';
        objBarsalaSetting.Wifi_Default_Password__c = '4013388959';
        objBarsalaSetting.Charge_per_cleaning_tier_1__c = 79;
        objBarsalaSetting.Charge_per_cleaning_tier_2__c = 75;
        objBarsalaSetting.Charge_per_cleaning_tier_3__c = 71;
        objBarsalaSetting.Charge_per_cleaning_lowest_rate__c = 71;
        objBarsalaSetting.Barsala_Support_Email__c = 'support@barsala.com';
        objBarsalaSetting.Barsala_Support_Phone__c = '+1 206 800 7277';
        objBarsalaSetting.Enable_to_Generate_Confirmation_Code__c = true;
        objBarsalaSetting.Forward_Email_on_Slack_Channel__c = true;
        objBarsalaSetting.Slack_Channel_Email_Address__c = 'testfl88888@airbnb.com';
        objBarsalaSetting.Slack_User_Id__c = String.valueOf(UserInfo.getUserId());
        objBarsalaSetting.Monthly_Discount__c = 25; // need to remove
        upsert objBarsalaSetting;

        City__c c = new City__c();
        c.Name = 'Seattle';
        c.State__c = 'SD';
        c.Rebooking_Price_Threshold_Below__c = 5;
        c.Rebooking_Price_Threshold_Above__c = 10;
        c.Checkin_Time_Cutoff__c = DateTime.now().time();
        c.Tax__c = 0.21;
        insert c;

        City__c c1 = new City__c();
        c1.Name = 'San Diego';
        c1.State__c = 'SD';
        c1.Rebooking_Price_Threshold_Below__c = 5;
        c1.Rebooking_Price_Threshold_Above__c = 10;
        c1.Checkin_Time_Cutoff__c = DateTime.now().time();
        c1.Tax__c = 0.15;
        insert c1;

        Neighborhood__c nb = new Neighborhood__c(
        Name = 'Test NB 1',
        City__c = c.Id
        );
        insert nb;

        Neighborhood__c nb1 = new Neighborhood__c(
        Name = 'Test NB 2',
        City__c = c1.Id
        );
        insert nb1;

        Building__c b = new Building__c(
        Name = 'test 1',
        Neighborhood__c = nb.Id,
        City__c = 'Seattle',
        Same_Day_Reservation_End_Time__c = '06:00 AM',
        Display_Name__c = 'test disp 1'
        );
        insert b;

        Building__c b2 = new Building__c(
        Name = 'test 2',
        Neighborhood__c = nb.Id,
        City__c = 'Seattle',
        Same_Day_Reservation_End_Time__c = '06:00 AM',
        Display_Name__c = 'test disp 2'
        );
        insert b2;

        Building__c b3 = new Building__c(
        Name = 'test 3',
        Neighborhood__c = nb1.Id,
        City__c = 'San Diego',
        Same_Day_Reservation_End_Time__c = '06:00 AM',
        Display_Name__c = 'test disp 3'
        );
        insert b3;

        Building_Unit_Set__c bus = new Building_Unit_Set__c(
        Name = 'BUS1',
        Building__c = b.Id
        );
        insert bus;

        Building_Unit_Set__c bus1 = new Building_Unit_Set__c(
        Name = 'BUS2',
        Building__c = b2.Id
        );
        insert bus1;

        Building_Unit_Set__c bus2 = new Building_Unit_Set__c(
        Name = 'BUS3',
        Building__c = b3.Id
        );
        insert bus2;

        Unit_set__c us = new Unit_set__c(Name = 'Test US 1');
        insert us;

        Building_Unit_Set_Pricing__c busp = new Building_Unit_Set_Pricing__c();
        busp.Building_Unit_Set__c = bus.id;
        busp.Price_Date__c = system.today();
        insert busp;

        Building_Unit_Set_Pricing__c busp1 = new Building_Unit_Set_Pricing__c();
        busp1.Building_Unit_Set__c = bus1.id;
        busp1.Price_Date__c = system.today();
        insert busp1;

        Building_Unit_Set_Pricing__c busp2 = new Building_Unit_Set_Pricing__c();
        busp2.Building_Unit_Set__c = bus2.id;
        busp2.Price_Date__c = system.today();
        insert busp2;

        Unit__c u = new Unit__c(
            Building__c = b.id,
            Name = 'test 1',
            Unit__c = '1',
            Base_price__c = 120,
            Beds__c = '1',
            Unit_set__c = us.Id,
            Airbnb_listing_name__c = 'test',
            Bedrooms__c = '1',
            Bathroom__c = '1',
            Airbnb_ID__c = 'test1',
            Beyond_Pricing_ID__c = 'test1',
            RU_ID__c = 'test1',
            Website_Listing_Name__c = 'test',
            Building_Unit_Set__c = bus.Id,
            Start_Date__c = system.today(),
            End_Date__c = system.today().addDays(70)
        );
        insert u;

        Unit__c u2 = new Unit__c(
            Building__c = b2.id,
            Name = 'test 2',
            Unit__c = '2',
            Base_price__c = 100,
            Beds__c = '2',
            Unit_set__c = us.Id,
            Airbnb_listing_name__c = 'test2',
            Bedrooms__c = '2',
            Bathroom__c = '2',
            Airbnb_ID__c = 'test2',
            Beyond_Pricing_ID__c = 'test2',
            RU_ID__c = 'test2',
            Website_Listing_Name__c = 'test',
            Building_Unit_Set__c = bus1.Id,
            Start_Date__c = system.today(),
            End_Date__c = system.today().addDays(70)
        );
        insert u2;

        Unit__c u3 = new Unit__c(
            Building__c = b3.id,
            Name = 'test 3',
            Unit__c = '3',
            Base_price__c = 110,
            Beds__c = '3',
            Unit_set__c = us.Id,
            Airbnb_listing_name__c = 'test3',
            Bedrooms__c = '2',
            Bathroom__c = '2',
            Airbnb_ID__c = 'test3',
            Beyond_Pricing_ID__c = 'test3',
            RU_ID__c = 'test3',
            Website_Listing_Name__c = 'test',
            Building_Unit_Set__c = bus2.Id,
            Start_Date__c = system.today(),
            End_Date__c = system.today().addDays(70)
        );
        insert u3;

        list<unit_pricing__c> unitPriceList = new list<unit_pricing__c>();
        date d = date.today();
        system.debug(d);
        for(integer i =0;i<10;i++){
            //unitPriceList.add(new unit_pricing__c(Unit__c = u.id, Availability_Status__c = 'Available',BP_Price_Modeled__c=120,name=string.valueOf(d)));

            unitPriceList.add(
                new unit_pricing__c(
                    Unit__c = u.id,
                    Availability_Status__c = 'Available',
                    BP_Price_Modeled__c = 120,
                    Base_Unit_Price__c = 60,
                    Barsala_Building_Factor__c = 2,
                    Barsala_Set_Factor__c = 3,
                    Barsala_Neighborhood_Factor__c = 4,
                    Barsala_City_Factor__c = 5,
                    Specific_Building_Adjustment__c = 6,
                    Specific_City_Adjustment__c = 7,
                    Specific_Neighborhood_Adjustment__c = 8,
                    Specific_Set_Adjustment__c = 9,
                    BP_Last_Days_Factor__c = 10,
                    BP_Price_Scraped__c = 5,
                    Min_Price__c = 1,
                    name = string.valueOf(d),
                    UNITPRICE_DATE__c = d,
                    Building_Unit_Set_Pricing_Day__c = busp.Id
                )
            );
            
            system.debug('u :: '+unitPriceList[i]);
            d += 1;
        }
        //system.debug('unitPriceList :: '+unitPriceList[0]);

        d = date.today();
        for(integer i =0;i<10;i++){
            //unitPriceList.add(new unit_pricing__c(Unit__c = u2.id, Availability_Status__c = 'Available',BP_Price_Modeled__c=120,name=string.valueOf(d)));
            unitPriceList.add(
                new unit_pricing__c(
                    Unit__c = u2.id,
                    Availability_Status__c = 'Available',
                    BP_Price_Modeled__c = 120,
                    Base_Unit_Price__c = 60,
                    Barsala_Building_Factor__c = 2,
                    Barsala_Set_Factor__c = 3,
                    Barsala_Neighborhood_Factor__c = 4,
                    Barsala_City_Factor__c = 5,
                    Specific_Building_Adjustment__c = 6,
                    Specific_City_Adjustment__c = 7,
                    Specific_Neighborhood_Adjustment__c = 8,
                    Specific_Set_Adjustment__c = 9,
                    BP_Last_Days_Factor__c = 10,
                    BP_Price_Scraped__c = 5,
                    Min_Price__c = 1,
                    name = string.valueOf(d),
                    UNITPRICE_DATE__c = d,
                    Building_Unit_Set_Pricing_Day__c = busp2.Id
                )
            );
            system.debug('u :: '+unitPriceList[i]);
            d += 1;
        }
        insert unitPriceList;
        //system.debug('unitPriceList :: '+unitPriceList[0]);


        insert new Stripe_Setting__c(
            End_Point__c = 'www.test.com',
            Secret_Key__c = 'test',
            Dashboard_URL__c = 'www.test.com',
            Email_Addresses__c = 'test@test.com'
        );

        String recordTypeId = Schema.getGlobalDescribe()
        .get('Account')
        .getDescribe()
        .getRecordTypeInfosByName()
        .get('Person Account')
        .getRecordTypeId();
        Account acc = new Account(
            RecordTypeID = recordTypeId,
            FirstName = 'Test FName',
            LastName = 'Test LName',
            PersonMailingStreet = 'test@yahoo.com',
            PersonMailingPostalCode = '12345',
            PersonMailingCity = 'SFO',
            PersonEmail = 'test@yahoo.com',
            PersonHomePhone = '1234567',
            PersonMobilePhone = '12345678'
        );
        insert acc;

        Account objacc = [
            SELECT PersonContactId
            FROM Account
            WHERE Id = :acc.Id
            LIMIT 1
        ];

        test.startTest();

        Xotelia_Booking__c book = new Xotelia_Booking__c();
        book.Sales_channel__c = 'manual';
        book.External_code__c = '12345';
        book.Total_taxed__c = 183.33;
        book.Travelers__c = 1;
        book.Firstname__c = 'Test';
        book.Lastname__c = 'RP100';
        book.Email__c = 'testrp@barsala.com';
        book.Phone_number__c = '9898989898';
        book.Start_date__c = system.now();
        book.End_date__c = system.now().addDays(3);
        book.Product__c = u.id;
        book.Billing_Contact__c = objacc.PersonContactId;
        book.Discount__c = 10;
        book.Sub_Total__c = 50;
        book.Total_taxed__c = 2;
        book.Status__c = 'Inactive';
        insert book;

        // Xotelia_Booking__c book = new Xotelia_Booking__c(Sales_Channel__c='manual',Product__c=u.id,External_code__c='12345',Start_date__c=date.today(),End_date__c=date.today().addDays(3),Status__c='Inactive');
        // insert book;

        for(unit_pricing__c up:[SELECT Unit_Price_Date__c,Availability_Status__c,Unit__c FROM Unit_Pricing__c WHERE Unit__c =: u.id AND 
                                                        Unit_Price_Date__c >= :book.Start_date__c.date() and Unit_Price_Date__c <= :book.End_date__c.date()]){
            system.assertEquals(up.Availability_Status__c,'Available');
            system.debug(up.Unit_Price_Date__c);
        }
        
        BookingTriggerHelper.IsRecursive = false;
        BookingTriggerHelper.isUnitPriceRecursive = false;
        book.Status__c = 'Active';
        update book;

        for(unit_pricing__c up:[SELECT Unit_Price_Date__c,Availability_Status__c,Unit__c FROM Unit_Pricing__c WHERE Unit__c =: u.id AND 
                                                        Unit_Price_Date__c >= :book.Start_date__c.date() and Unit_Price_Date__c < :book.End_date__c.date()]){
            system.debug(up);
            //system.assertEquals(up.Availability_Status__c,'Booked');
            //system.debug(up.Unit_Price_Date__c);
        }
        
        BookingTriggerHelper.IsRecursive = false;
        BookingTriggerHelper.isUnitPriceRecursive = false;
        book.Product__c = u2.id;
        update book;

        //set to store old unitprice id
        set<id> upId = new set<id>();
        for(unit_pricing__c up:[SELECT Unit_Price_Date__c,Availability_Status__c,Unit__c FROM Unit_Pricing__c WHERE Unit__c =: u2.id AND 
                                                        Unit_Price_Date__c >= :book.Start_date__c.date() and Unit_Price_Date__c < :book.End_date__c.date()]){
            //system.assertEquals(up.Availability_Status__c,'Booked');
            upId.add(up.id);
            //system.debug(up.Unit_Price_Date__c);
        }

        BookingTriggerHelper.IsRecursive = false;
        book.Start_date__c = system.now().addDays(-5);
        book.End_date__c = system.now().addDays(15);
        BookingTriggerHelper.isUnitPriceRecursive = true;
        update book;



        for(unit_pricing__c up:[SELECT Unit_Price_Date__c,Availability_Status__c,Unit__c FROM Unit_Pricing__c WHERE Unit__c =: u2.id AND 
                                                        Unit_Price_Date__c >= :book.Start_date__c.date() and Unit_Price_Date__c < :book.End_date__c.date()]){
            //system.assertEquals(up.Availability_Status__c,'Booked');
            //system.debug(up.Unit_Price_Date__c);
        }

        for(unit_pricing__c up:[SELECT Unit_Price_Date__c,Availability_Status__c,Unit__c FROM Unit_Pricing__c WHERE id In:upId]){
            //system.assertEquals(up.Availability_Status__c,'Booked');
            //system.debug(up.Unit_Price_Date__c);
        }

        book.Start_date__c = system.now().addDays(30);
        book.End_date__c = system.now().addDays(35);
        book.Product__c = u3.id;

        //delete [select id from unit_pricing__c where Unit__c =:u2.id and Unit_Price_Date__c >= :date.today().addDays(-6) AND Unit_Price_Date__c < :date.today().addDays(16)];
        BookingTriggerHelper.IsRecursive = false;
        //update book;
        
        

        BookingTriggerHelper.IsRecursive = false;
        BookingTriggerHelper.isUnitPriceRecursive = false;

        QAAssignmentHandler.isQARecursion = true;
        CleaningAssignmentHandler.isCleaningRecursion = true;
        delete [select id from Cleaning_Assignment__c where Booking__c=: book.Id];
        delete [select id from QA_Assignment__c where Booking_Record__c=: book.Id];
        delete book;
        QAAssignmentHandler.isQARecursion = false;
        CleaningAssignmentHandler.isCleaningRecursion = false;

        for(unit_pricing__c up:[SELECT Unit_Price_Date__c,Availability_Status__c,Unit__c FROM Unit_Pricing__c WHERE Unit__c =: u2.id AND 
                                                        Unit_Price_Date__c >= :book.Start_date__c.date() and Unit_Price_Date__c < :book.End_date__c.date()]){
            system.assertEquals(up.Availability_Status__c,'Available');
        }

        
        Xotelia_Booking__c book2 = new Xotelia_Booking__c();
        book2.Sales_channel__c = 'manual';
        book2.External_code__c = '12345';
        book2.Total_taxed__c = 183.33;
        book2.Travelers__c = 1;
        book2.Firstname__c = 'Test';
        book2.Lastname__c = 'RP100';
        book2.Email__c = 'testrp@barsala.com';
        book2.Phone_number__c = '9898989898';
        book2.Start_date__c = system.now();
        book2.End_date__c = system.now().addDays(3);
        book2.Product__c = u.id;
        book2.Billing_Contact__c = objacc.PersonContactId;
        book2.Discount__c = 10;
        book2.Sub_Total__c = 50;
        book2.Total_taxed__c = 2;
        book2.Status__c = 'Inactive';
        book2.Check_in_time__c = '4:00 PM';
        insert book2;

        // Xotelia_Booking__c book2 = new Xotelia_Booking__c(Sales_Channel__c='manual',Product__c=u.id,External_code__c='12345',Start_date__c=date.today(),End_date__c=date.today().addDays(3),Status__c='Inactive', Check_in_time__c = '4:00 PM');
        // insert book2;

        id batchid = database.executebatch(new UnitPriceStatusUpdate_Batch(),1);

        BookingTriggerHelper.IsRecursive = false;
        book2.Product__c = null;
        //update book2;
		
		BookingTriggerHelper.codecovarageMethod();

        test.stopTest();
    }
    
    
    @isTest
    public static void updatePersonAccountTest(){
        Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
		objBarsalaSetting.Populate_Two_Factor_Screening_Approval__c = true;
        
        String recordTypeId = Schema.getGlobalDescribe()
        .get('Account')
        .getDescribe()
        .getRecordTypeInfosByName()
        .get('Person Account')
        .getRecordTypeId();
        Account acc = new Account(
            RecordTypeID = recordTypeId,
            FirstName = 'Test FName',
            LastName = 'Test LName',
            PersonMailingStreet = 'test@yahoo.com',
            PersonMailingPostalCode = '12345',
            PersonMailingCity = 'SFO',
            PersonEmail = 'test@yahoo.com',
            PersonHomePhone = '1234567',
            PersonMobilePhone = '12345678'
        );
        insert acc;
        
        Account objacc = [
            SELECT PersonContactId
            FROM Account
            WHERE Id = :acc.Id
            LIMIT 1
        ];
        
        City__c c = new City__c();
        c.Name = 'Seattle';
        c.State__c = 'SD';
        c.Rebooking_Price_Threshold_Below__c = 5;
        c.Rebooking_Price_Threshold_Above__c = 10;
        c.Checkin_Time_Cutoff__c = DateTime.now().time();
        c.Tax__c = 0.21;
        insert c;
        
        Neighborhood__c nb = new Neighborhood__c(
        Name = 'Test NB 1',
        City__c = c.Id
        );
        insert nb;
        
         Building__c b = new Building__c(
        Name = 'test 1',
        Neighborhood__c = nb.Id,
        City__c = 'Seattle',
        Same_Day_Reservation_End_Time__c = '06:00 AM',
        Display_Name__c = 'test disp 1'
        );
        insert b;
        
        Unit_set__c us = new Unit_set__c(Name = 'Test US 1');
        insert us;
        
        Building_Unit_Set__c bus = new Building_Unit_Set__c(
        Name = 'BUS1',
        Building__c = b.Id
        );
        insert bus;
        
         Unit__c u = new Unit__c(
            Building__c = b.id,
            Name = 'test 1',
            Unit__c = '1',
            Base_price__c = 120,
            Beds__c = '1',
            Unit_set__c = us.Id,
            Airbnb_listing_name__c = 'test',
            Bedrooms__c = '1',
            Bathroom__c = '1',
            Airbnb_ID__c = 'test1',
            Beyond_Pricing_ID__c = 'test1',
            RU_ID__c = 'test1',
            Website_Listing_Name__c = 'test',
            Building_Unit_Set__c = bus.Id,
            Start_Date__c = system.today(),
            End_Date__c = system.today().addDays(70)
        );
        insert u;
        
        Xotelia_Booking__c book2 = new Xotelia_Booking__c();
        book2.Sales_channel__c = 'manual';
        book2.External_code__c = '12345';
        book2.Total_taxed__c = 183.33;
        book2.Travelers__c = 1;
        book2.Firstname__c = 'Test';
        book2.Lastname__c = 'RP100';
        book2.Email__c = 'testrp@barsala.com';
        book2.Phone_number__c = '9898989898';
        book2.Start_date__c = system.now();
        book2.End_date__c = system.now().addDays(3);
        book2.Product__c = u.id;
        book2.Billing_Contact__c = objacc.PersonContactId;
        book2.Discount__c = 10;
        book2.Sub_Total__c = 50;
        book2.Total_taxed__c = 2;
        book2.Status__c = 'Inactive';
        book2.Check_in_time__c = '4:00 PM';
        book2.Two_Factor_Screening_Approval_Decision__c = 'Clear';
        insert book2;
        
       
        
        
    }
}