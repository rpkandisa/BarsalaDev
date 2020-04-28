@isTest
public class TestCaseTrigger {
  @testsetup
  static void setupTestData() {
    Barsala_Round_Robin__c objSetting = new Barsala_Round_Robin__c();
    List<Barsala_Round_Robin__c> lstBRR = new List<Barsala_Round_Robin__c>();
    for (Integer i = 0; i < 7; i++) {
      objSetting = new Barsala_Round_Robin__c();
      Datetime dttime = Datetime.now().addDays(i);
      objSetting.Name = dttime.format('EEEE');
      objSetting.Auto_Assign_Number__c = 0;
      lstBRR.add(objSetting);
    }
    insert lstBRR;

    

    Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
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

    objBarsalaSetting.Enable_Escalation_Level__c = true;
    objBarsalaSetting.Do_you_want_to_stop_to_run_Case_trigger__c = false;
    objBarsalaSetting.Enable_Round_Robin_Trigger__c = true;
    objBarsalaSetting.Monthly_Discount__c = 25; // need to remove
    upsert objBarsalaSetting;

    City__c c1 = new City__c();
    c1.Name = 'San Diego';
    c1.State__c = 'SD';
    c1.Rebooking_Price_Threshold_Below__c = 5;
    c1.Rebooking_Price_Threshold_Above__c = 10;
    c1.Checkin_Time_Cutoff__c = DateTime.now().time();
    insert c1;

    Neighborhood__c nb = new Neighborhood__c(
      Name = 'Test NB 1',
      City__c = c1.Id
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
      Same_Day_Reservation_End_Time__c = '06:00 AM'
    );
    insert b;

    Building__c b2 = new Building__c(
      Name = 'test 2',
      Neighborhood__c = nb.Id,
      Same_Day_Reservation_End_Time__c = '06:00 AM'
    );
    insert b2;

    Building__c b3 = new Building__c(
      Name = 'test 3',
      Neighborhood__c = nb1.Id,
      Same_Day_Reservation_End_Time__c = '06:00 AM'
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
      Airbnb_listing_name__c = 'test 1',
      Bedrooms__c = '1',
      Bathroom__c = '1',
      Website_Listing_Name__c = 'true',
      Building_Unit_Set__c = bus.Id,
      Start_Date__c = system.today(),
      End_Date__c = system.today().addYears(10)
    );
    insert u;

    Unit__c u2 = new Unit__c(
      Building__c = b2.id,
      Name = 'test 2',
      Unit__c = '2',
      Base_price__c = 120,
      Beds__c = '1',
      Unit_set__c = us.Id,
      Airbnb_listing_name__c = 'test 2',
      Bedrooms__c = '1',
      Bathroom__c = '1',
      Website_Listing_Name__c = 'true',
      Building_Unit_Set__c = bus1.Id,
      Start_Date__c = system.today(),
      End_Date__c = system.today().addYears(10)
    );
    insert u2;

    Unit__c u3 = new Unit__c(
      Building__c = b3.id,
      Name = 'test 3',
      Unit__c = '3',
      Base_price__c = 120,
      Beds__c = '1',
      Unit_set__c = us.Id,
      Airbnb_listing_name__c = 'test 3',
      Bedrooms__c = '1',
      Bathroom__c = '1',
      Website_Listing_Name__c = 'true',
      Building_Unit_Set__c = bus2.Id,
      Start_Date__c = system.today(),
      End_Date__c = system.today().addYears(10)
    );
    insert u3;

    list<unit_pricing__c> unitPriceList = new List<unit_pricing__c>();
    date d = date.today().addMonths(-1);

    for (integer i = 0; i < 30; i++) {
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
      unitPriceList.add(
        new unit_pricing__c(
          Unit__c = u3.id,
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
                    Building_Unit_Set_Pricing_Day__c = busp1.Id
        )
      );
      system.debug('u :: ' + unitPriceList[i]);
      d += 1;
    }
    insert unitPriceList;

    DateTime dt = System.today();
    Time STTime = Time.newInstance(0, 0, dt.second(), dt.millisecond());
    Time ETTime = Time.newInstance(23, 59, dt.second(), dt.millisecond());

    Team_Schedule__c ts = new Team_Schedule__c();
    ts.User__c = UserInfo.getUserId();
    ts.Mon_Start__c = STTime;
    ts.Mon_End__c = ETTime;
    ts.Tue_Start__c = STTime;
    ts.Tue_End__c = ETTime;
    ts.Wed_Start__c = STTime;
    ts.Wed_End__c = ETTime;
    ts.Thu_Start__c = STTime;
    ts.Thu_End__c = ETTime;
    ts.Fri_Start__c = STTime;
    ts.Fri_End__c = ETTime;
    ts.Sat_Start__c = STTime;
    ts.Sat_End__c = ETTime;
    ts.Sun_Start__c = STTime;
    ts.Sun_End__c = ETTime;
    insert ts;
  }
  @isTest
  static void TestPopulateBookingOnCase() {
    List<Unit__c> units = [SELECT id FROM Unit__c];
    Account acc = new Account(Name = 'test');
    insert acc;

    Contact con = new Contact(
      LastName = 'test',
      AccountID = acc.Id,
      Email = 'test@test.com'
    );
    insert con;

    Contact con2 = new Contact(
      LastName = 'test',
      AccountID = acc.Id,
      Email = 'test2@test.com'
    );
    insert con2;

    Contact con3 = new Contact(
      LastName = 'test',
      AccountID = acc.Id,
      Email = 'test3@test.com'
    );
    insert con3;

    test.startTest();

    List<Xotelia_Booking__c> bookings = new List<Xotelia_Booking__c>();
    bookings.add(
      new Xotelia_Booking__c(
        Sales_Channel__c = 'manual',
        Product__c = units[0].id,
        External_code__c = '12345',
        Start_date__c = date.today(),
        End_date__c = date.today().addDays(2),
        Status__c = 'Active',
        Updated_Email__c = 'test@test.com'
      )
    );
    bookings.add(
      new Xotelia_Booking__c(
        Sales_Channel__c = 'manual',
        Product__c = units[1].id,
        External_code__c = '123456',
        Start_date__c = date.today(),
        End_date__c = date.today().addDays(2),
        Status__c = 'Active',
        Guest_Contact__c = con2.Id
      )
    );
    bookings.add(
      new Xotelia_Booking__c(
        Sales_Channel__c = 'manual',
        Product__c = units[2].id,
        External_code__c = '123457',
        Start_date__c = date.today(),
        End_date__c = date.today().addDays(2),
        Status__c = 'Active',
        Billing_Contact__c = con3.Id
      )
    );
    insert bookings;

    List<Case> cases = new List<Case>();
    cases.add(
      new Case(
        Status = 'New',
        Priority = 'Medium',
        Origin = 'Email',
        ContactId = con.Id,
        Accountid = acc.Id,
        Subject = 'TestSubject',
        Description = 'TestDescription'
      )
    );
    cases.add(
      new Case(
        Status = 'New',
        Priority = 'Medium',
        Origin = 'Email',
        ContactId = con2.Id,
        Accountid = acc.Id,
        Subject = 'TestSubject',
        Description = 'TestDescription'
      )
    );
    cases.add(
      new Case(
        Status = 'New',
        Priority = 'Medium',
        Origin = 'Email',
        ContactId = con3.Id,
        Accountid = acc.Id,
        Subject = 'TestSubject',
        Description = 'TestDescription'
      )
    );
    insert cases;

    system.assertEquals(
      [SELECT id, Booking__c FROM Case WHERE id = :cases[0].Id]
      .Booking__c,
      bookings[0].Id
    );
    system.assertEquals(
      [SELECT id, Booking__c FROM Case WHERE id = :cases[1].Id]
      .Booking__c,
      bookings[1].Id
    );
    system.assertEquals(
      [SELECT id, Booking__c FROM Case WHERE id = :cases[2].Id]
      .Booking__c,
      bookings[2].Id
    );
    test.stopTest();
  }

  @isTest
  static void TestPopulateBookingOnCase2() {
    List<Unit__c> units = [SELECT id FROM Unit__c];
    Account acc = new Account(Name = 'test');
    insert acc;

    Contact con = new Contact(
      LastName = 'test',
      AccountID = acc.Id,
      Email = 'test@test.com'
    );
    insert con;

    Contact con2 = new Contact(
      LastName = 'test',
      AccountID = acc.Id,
      Email = 'test2@test.com'
    );
    insert con2;

    Contact con3 = new Contact(
      LastName = 'test',
      AccountID = acc.Id,
      Email = 'test3@test.com'
    );
    insert con3;

    test.startTest();

    List<Xotelia_Booking__c> bookings = new List<Xotelia_Booking__c>();
    bookings.add(
      new Xotelia_Booking__c(
        Sales_Channel__c = 'manual',
        Product__c = units[0].id,
        External_code__c = '1234511',
        Start_date__c = date.today().addDays(5),
        End_date__c = date.today().addDays(10),
        Status__c = 'Active',
        Updated_Email__c = 'test@test.com'
      )
    );
    bookings.add(
      new Xotelia_Booking__c(
        Sales_Channel__c = 'manual',
        Product__c = units[1].id,
        External_code__c = '1234512',
        Start_date__c = date.today().addDays(5),
        End_date__c = date.today().addDays(10),
        Status__c = 'Active',
        Guest_Contact__c = con2.Id
      )
    );
    bookings.add(
      new Xotelia_Booking__c(
        Sales_Channel__c = 'manual',
        Product__c = units[2].id,
        External_code__c = '1234513',
        Start_date__c = date.today().addDays(5),
        End_date__c = date.today().addDays(10),
        Status__c = 'Active',
        Billing_Contact__c = con3.Id
      )
    );
    insert bookings;

    List<Case> cases = new List<Case>();
    cases.add(
      new Case(
        Status = 'New',
        Priority = 'Medium',
        Origin = 'Email',
        ContactId = con.Id,
        Accountid = acc.Id,
        Subject = 'TestSubject',
        Description = 'TestDescription'
      )
    );
    cases.add(
      new Case(
        Status = 'New',
        Priority = 'Medium',
        Origin = 'Email',
        ContactId = con2.Id,
        Accountid = acc.Id,
        Subject = 'TestSubject',
        Description = 'TestDescription'
      )
    );
    cases.add(
      new Case(
        Status = 'New',
        Priority = 'Medium',
        Origin = 'Email',
        ContactId = con3.Id,
        Accountid = acc.Id,
        Subject = 'TestSubject',
        Description = 'TestDescription'
      )
    );
    insert cases;

    system.assertEquals(
      [SELECT id, Booking__c FROM Case WHERE id = :cases[0].Id]
      .Booking__c,
      bookings[0].Id
    );
    system.assertEquals(
      [SELECT id, Booking__c FROM Case WHERE id = :cases[1].Id]
      .Booking__c,
      bookings[1].Id
    );
    system.assertEquals(
      [SELECT id, Booking__c FROM Case WHERE id = :cases[2].Id]
      .Booking__c,
      bookings[2].Id
    );

    test.stopTest();
  }

  @isTest
  static void TestPopulateBookingOnCase3() {
    List<Unit__c> units = [SELECT id FROM Unit__c];
    Account acc = new Account(Name = 'test');
    insert acc;

    Contact con = new Contact(
      LastName = 'test',
      AccountID = acc.Id,
      Email = 'test@test.com'
    );
    insert con;

    Contact con2 = new Contact(
      LastName = 'test',
      AccountID = acc.Id,
      Email = 'test2@test.com'
    );
    insert con2;

    Contact con3 = new Contact(
      LastName = 'test',
      AccountID = acc.Id,
      Email = 'test3@test.com'
    );
    insert con3;

    test.startTest();

    List<Xotelia_Booking__c> bookings = new List<Xotelia_Booking__c>();
    bookings.add(
      new Xotelia_Booking__c(
        Sales_Channel__c = 'manual',
        Product__c = units[0].id,
        External_code__c = '123458',
        Start_date__c = date.today().addDays(-10),
        End_date__c = date.today().addDays(-5),
        Status__c = 'Active',
        Updated_Email__c = 'test@test.com'
      )
    );
    bookings.add(
      new Xotelia_Booking__c(
        Sales_Channel__c = 'manual',
        Product__c = units[1].id,
        External_code__c = '123459',
        Start_date__c = date.today().addDays(-10),
        End_date__c = date.today().addDays(-5),
        Status__c = 'Active',
        Guest_Contact__c = con2.Id
      )
    );
    bookings.add(
      new Xotelia_Booking__c(
        Sales_Channel__c = 'manual',
        Product__c = units[2].id,
        External_code__c = '1234510',
        Start_date__c = date.today().addDays(-10),
        End_date__c = date.today().addDays(-5),
        Status__c = 'Active',
        Billing_Contact__c = con3.Id
      )
    );
    insert bookings;

    List<Case> cases = new List<Case>();
    cases.add(
      new Case(
        Status = 'New',
        Priority = 'Medium',
        Origin = 'Email',
        ContactId = con.Id,
        Accountid = acc.Id,
        Subject = 'TestSubject',
        Description = 'TestDescription'
      )
    );
    cases.add(
      new Case(
        Status = 'New',
        Priority = 'Medium',
        Origin = 'Email',
        ContactId = con2.Id,
        Accountid = acc.Id,
        Subject = 'TestSubject',
        Description = 'TestDescription'
      )
    );
    cases.add(
      new Case(
        Status = 'New',
        Priority = 'Medium',
        Origin = 'Email',
        ContactId = con3.Id,
        Accountid = acc.Id,
        Subject = 'TestSubject',
        Description = 'TestDescription'
      )
    );
    insert cases;

    system.assertEquals(
      [SELECT id, Booking__c FROM Case WHERE id = :cases[0].Id]
      .Booking__c,
      bookings[0].Id
    );
    system.assertEquals(
      [SELECT id, Booking__c FROM Case WHERE id = :cases[1].Id]
      .Booking__c,
      bookings[1].Id
    );
    system.assertEquals(
      [SELECT id, Booking__c FROM Case WHERE id = :cases[2].Id]
      .Booking__c,
      bookings[2].Id
    );

    Map<String, Barsala_Round_Robin__c> mapWeekDaySettings = Barsala_Round_Robin__c.getAll();
    for (Integer i = 0; i < 7; i++) {
      Datetime dttime = Datetime.now().addDays(i);
      CaseRoundRobin.fnfindwherequery(dttime, false);
      CaseRoundRobin.findLastAssignee(dttime, mapWeekDaySettings);
    }

    for (Case objCase : cases) {
      objCase.Escalate__c = '1';
      objCase.Priority = 'Urgent';
      objCase.Status = 'Escalated';
      break;
    }
    CaseRoundRobin.isRecursion = false;
    update cases;

    Map<string, Id> mapEmailvsCaseId = new Map<string, Id>();
    mapEmailvsCaseId.put('test3@test.com', cases[0].Id);
    CaseRoundRobin.SetContact(mapEmailvsCaseId);

    test.stopTest();
  }
}