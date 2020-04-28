/*
    Created By: Kandisa Technologies Pvt. Ltd
    Description: Test Class for UnitBookingController Apex class.
*/
@isTest
private class UnitBookingControllerTest {
  @TestSetup
  static void createTestData() {
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
    objBarsalaSetting.Booking_Wizard_Phone_Call_Threshold__c = 1;
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
      Display_Name__c = 'b1'
    );
    insert b;

    Building__c b2 = new Building__c(
      Name = 'test 2',
      Neighborhood__c = nb.Id,
      City__c = 'Seattle',
      Same_Day_Reservation_End_Time__c = '06:00 AM',
      Display_Name__c = 'b2'
    );
    insert b2;

    Building__c b3 = new Building__c(
      Name = 'test 3',
      Neighborhood__c = nb1.Id,
      City__c = 'San Diego',
      Same_Day_Reservation_End_Time__c = '06:00 AM',
      Display_Name__c = 'b3'
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

    list<unit_pricing__c> unitPriceList = new List<unit_pricing__c>();
    date d = date.today();
    system.debug(d);
    for (integer i = 0; i < 70; i++) {
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
      system.debug('u :: ' + unitPriceList[i]);
      d += 1;
    }

    d = date.today();
    for (integer i = 0; i < 70; i++) {
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
      system.debug('u :: ' + unitPriceList[i]);
      d += 1;
    }

    insert unitPriceList;

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
    objBooking.Discount__c = 10;
    objBooking.Sub_Total__c = 50;
    objBooking.Total_taxed__c = 2;
    //objBooking.Status__c = 'Inactive';
    insert objbooking;
  }

  @isTest
  static void TestBookingWizard() {
    List<String> dateStr = new List<String>();
    for (Integer i = 0; i < 65; i++) {
      dateStr.add(String.valueOf(Date.Today().addDays(i)));
    }
    Unit__c u = [
      SELECT
        id,
        Tax_Rate__c,
        Base_price__c,
        Cleaning_Fee__c,
        (
          SELECT id, Barsala_Price_Modeled_Final__c
          FROM Unit_Prices__r
          WHERE Name = :dateStr
        )
      FROM Unit__c
      WHERE Name = 'test 1' AND Unit__c = '1'
      LIMIT 1
    ];

    Decimal grandTotal = 0;
    for (unit_pricing__c up : u.Unit_Prices__r) {
      grandTotal += up.Barsala_Price_Modeled_Final__c;
    }
    if (u.Cleaning_Fee__c != null)
      grandTotal += u.Cleaning_Fee__c;

    grandTotal += (grandTotal * u.Tax_Rate__c);

    UnitBookingController.allCities();
    UnitBookingController.allUnits(
      'Seattle',
      system.now().format('MM/dd/yyyy'),
      system.now().addDays(3).format('MM/dd/yyyy'),
      '2',
      null,
      false,
      null,
      true
    );

    String fakeBody = '{ "paid": true, "status": "succeeded", "id": "cus_CxsJgOxi7kpYIE", "object": "customer", "account_balance": 0, "created": 1527795322, "currency": null, "default_source": "card_1CXwYQKasHLvOShlYU0kNJvt", "delinquent": false, "description": "Created w/Booking Extension program", "discount": null, "email": "testnew@test.com", "invoice_prefix": "EBB1D37", "livemode": false, "metadata": {}, "shipping": null, "sources": { "object": "list", "data": [{ "id": "card_1CXwYQKasHLvOShlYU0kNJvt", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": "3333", "address_zip_check": "pass", "brand": "Visa", "country": "US", "customer": "cus_CxsJgOxi7kpYIE", "cvc_check": "pass", "dynamic_last4": null, "exp_month": 1, "exp_year": 2019, "fingerprint": "R0oPB77Gc1J1A88o", "funding": "unknown", "last4": "1111", "metadata": {}, "name": "Tarun", "tokenization_method": null }, { "id": "card_1CYB7JKasHLvOShluTNrQZDG", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": "eee3", "address_zip_check": "pass", "brand": "Visa", "country": "US", "customer": "cus_CxsJgOxi7kpYIE", "cvc_check": "pass", "dynamic_last4": null, "exp_month": 2, "exp_year": 2019, "fingerprint": "b9QkZhVd8NwlE5pp", "funding": "credit", "last4": "4242", "metadata": {}, "name": "Tarun Jain", "tokenization_method": null }], "has_more": false, "total_count": 2, "url": "/v1/customers/cus_CxsJgOxi7kpYIE/sources" }, "subscriptions": { "object": "list", "data": [], "has_more": false, "total_count": 0, "url": "/v1/customers/cus_CxsJgOxi7kpYIE/subscriptions" }, "card": { "id": "card_1AePv8KasHLvOShlwqDoNOOd", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": null, "address_zip_check": null, "brand": "Visa", "country": "US", "cvc_check": null, "dynamic_last4": null, "exp_month": 8, "exp_year": 2018, "fingerprint": "b9QkZhVd8NwlE5pp", "funding": "credit", "last4": "4242", "metadata": {}, "name": null, "tokenization_method": null }, "client_ip": null, "type": "card", "used": false }';
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator(
        200,
        'ok',
        fakeBody,
        new Map<String, String>()
      )
    );

    Xotelia_Booking__c book1 = new Xotelia_Booking__c(
      Firstname__c = 'FName',
      Lastname__c = 'LName',
      Email__c = 'test1@gmail.com',
      //Billing_Contact__c= (conModel != null ? conModel.contact.Id : null),
      Credit_Card_Full_Name__c = 'test',
      Credit_Card_CVV__c = 'test',
      Credit_Card_Number__c = '1112223334445443',
      Credit_Card_Expiration_Date__c = '12/' + Date.today().Year(),
      Credit_Card_Type__c = 'VISA',
      Zip_Code__c = 'test',
      Total_taxed__c = grandTotal,
      Product__c = u.id,
      External_code__c = 'manual',
      Start_date__c = date.today(),
      End_date__c = date.today().addDays(65),
      Status__c = 'Active',
      Travelers__c = 1,
      Sales_channel__c = 'expedia'
    );
    UnitBookingController.ResponseModel rm = UnitBookingController.BookUnitWrapper(
      book1,
      system.now().format('MM/dd/yyyy'),
      system.now().addDays(65).format('MM/dd/yyyy'),
      'test unit',
      'newCard',
      '',
      true,
      ''
    );
    System.debug('#########rm@@@@@@@ ' + rm);
    test.startTest();
    UnitBookingController.chargePayment(rm, '', false);
    test.stopTest();
  }

  @isTest
  static void TestBookingWizardPaidfail() {
    List<String> dateStr = new List<String>();
    for (Integer i = 0; i < 65; i++) {
      dateStr.add(String.valueOf(Date.Today().addDays(i)));
    }
    Unit__c u = [
      SELECT
        id,
        Tax_Rate__c,
        Base_price__c,
        Cleaning_Fee__c,
        (
          SELECT id, Barsala_Price_Modeled_Final__c
          FROM Unit_Prices__r
          WHERE Name = :dateStr
        )
      FROM Unit__c
      WHERE Name = 'test 1' AND Unit__c = '1'
      LIMIT 1
    ];

    Decimal grandTotal = 0;
    for (unit_pricing__c up : u.Unit_Prices__r) {
      grandTotal += up.Barsala_Price_Modeled_Final__c;
    }
    if (u.Cleaning_Fee__c != null)
      grandTotal += u.Cleaning_Fee__c;

    grandTotal += (grandTotal * u.Tax_Rate__c);

    UnitBookingController.allCities();
    UnitBookingController.allUnits(
      'Seattle',
      system.now().format('MM/dd/yyyy'),
      system.now().addDays(3).format('MM/dd/yyyy'),
      '2',
      null,
      false,
      null,
      true
    );

    String fakeBody = '{ "paid": false, "status": "succeeded", "id": "cus_CxsJgOxi7kpYIE", "object": "customer", "account_balance": 0, "created": 1527795322, "currency": null, "default_source": "card_1CXwYQKasHLvOShlYU0kNJvt", "delinquent": false, "description": "Created w/Booking Extension program", "discount": null, "email": "testnew@test.com", "invoice_prefix": "EBB1D37", "livemode": false, "metadata": {}, "shipping": null, "sources": { "object": "list", "data": [{ "id": "card_1CXwYQKasHLvOShlYU0kNJvt", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": "3333", "address_zip_check": "pass", "brand": "Visa", "country": "US", "customer": "cus_CxsJgOxi7kpYIE", "cvc_check": "pass", "dynamic_last4": null, "exp_month": 1, "exp_year": 2019, "fingerprint": "R0oPB77Gc1J1A88o", "funding": "unknown", "last4": "1111", "metadata": {}, "name": "Tarun", "tokenization_method": null }, { "id": "card_1CYB7JKasHLvOShluTNrQZDG", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": "eee3", "address_zip_check": "pass", "brand": "Visa", "country": "US", "customer": "cus_CxsJgOxi7kpYIE", "cvc_check": "pass", "dynamic_last4": null, "exp_month": 2, "exp_year": 2019, "fingerprint": "b9QkZhVd8NwlE5pp", "funding": "credit", "last4": "4242", "metadata": {}, "name": "Tarun Jain", "tokenization_method": null }], "has_more": false, "total_count": 2, "url": "/v1/customers/cus_CxsJgOxi7kpYIE/sources" }, "subscriptions": { "object": "list", "data": [], "has_more": false, "total_count": 0, "url": "/v1/customers/cus_CxsJgOxi7kpYIE/subscriptions" }, "card": { "id": "card_1AePv8KasHLvOShlwqDoNOOd", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": null, "address_zip_check": null, "brand": "Visa", "country": "US", "cvc_check": null, "dynamic_last4": null, "exp_month": 8, "exp_year": 2018, "fingerprint": "b9QkZhVd8NwlE5pp", "funding": "credit", "last4": "4242", "metadata": {}, "name": null, "tokenization_method": null }, "client_ip": null, "type": "card", "used": false }';
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator(
        200,
        'ok',
        fakeBody,
        new Map<String, String>()
      )
    );

    Xotelia_Booking__c book1 = new Xotelia_Booking__c(
      Firstname__c = 'FName',
      Lastname__c = 'LName',
      Email__c = 'test1@gmail.com',
      //Billing_Contact__c= (conModel != null ? conModel.contact.Id : null),
      Credit_Card_Full_Name__c = 'test',
      Credit_Card_CVV__c = 'test',
      Credit_Card_Number__c = '1112223334445443',
      Credit_Card_Expiration_Date__c = '12/' + Date.today().Year(),
      Credit_Card_Type__c = 'VISA',
      Zip_Code__c = 'test',
      Total_taxed__c = grandTotal,
      Product__c = u.id,
      External_code__c = 'manual',
      Start_date__c = date.today(),
      End_date__c = date.today().addDays(65),
      Status__c = 'Active',
      Travelers__c = 1,
      Sales_channel__c = 'expedia'
    );
    UnitBookingController.ResponseModel rm = UnitBookingController.BookUnitWrapper(
      book1,
      system.now().format('MM/dd/yyyy'),
      system.now().addDays(65).format('MM/dd/yyyy'),
      'test unit',
      'newCard',
      '',
      true,
      ''
    );

    test.startTest();
    UnitBookingController.chargePayment(rm, '', false);
    UnitBookingController.codecoverage();
    test.stopTest();
  }

  @isTest
  static void validateMergePersonAccount() {
    Id recodeType = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();

    Account masterTest = new Account();
    masterTest.RecordTypeId = recodeType;
    masterTest.LastName = 'Master Test';
    insert masterTest;

    Account mastercon = [
      SELECT id, PersonContactId
      FROM Account
      WHERE id = :masterTest.id
      LIMIT 1
    ];

    Account mergeTest = new Account();
    mergeTest.RecordTypeId = recodeType;
    mergeTest.LastName = 'Merge Test';
    mergeTest.Website = 'www.test.com';
    insert mergeTest;

    Account mergecon = [
      SELECT id, PersonContactId
      FROM Account
      WHERE id = :mergeTest.Id
      LIMIT 1
    ];

    test.startTest();
    UnitBookingController.mergecontact(
      mastercon.PersonContactId,
      mergecon.PersonContactId
    );
    Test.stopTest();
  }

  @isTest
  static void TestBookingWizard2() {
    //User usr = [select id from User where Email='michael@barsala.com' limit 1];

    Account ac = new Account(name = 'Grazitti');
    insert ac;

    Contact con = new Contact(
      AccountId = ac.Id,
      FirstName = 'test',
      LastName = 'test',
      Email = 'test@gmail.com',
      phone = '123435'
    );
    insert con;

    Id p = [SELECT id FROM profile WHERE name = 'Customer Community'].id;

    User user = new User(
      alias = 'test123',
      email = 'test@noemail.com',
      emailencodingkey = 'UTF-8',
      lastname = 'Testing',
      languagelocalekey = 'en_US',
      localesidkey = 'en_US',
      profileid = p,
      country = 'United States',
      IsActive = true,
      ContactId = con.Id,
      timezonesidkey = 'America/Los_Angeles',
      username = 'tester' + DateTime.now().millisecond() + '@noemail.com'
    );

    //insert user;

    System.runAs(user) {
      UnitBookingController obj = new UnitBookingController();
      obj.validateUser();
    }
    List<String> dateStr = new List<String>();
    dateStr.add(String.valueOf(system.now()));
    for (Integer i = 1; i < 65; i++) {
      dateStr.add(String.valueOf(system.now().addDays(i).Date()));
    }
    Unit__c u = [
      SELECT
        id,
        Tax_Rate__c,
        Base_price__c,
        Cleaning_Fee__c,
        (
          SELECT id, Barsala_Price_Modeled_Final__c
          FROM Unit_Prices__r
          WHERE Name = :dateStr
        )
      FROM Unit__c
      WHERE Name = 'test 1' AND Unit__c = '1'
      LIMIT 1
    ];

    Decimal grandTotal = 0;
    for (unit_pricing__c up : u.Unit_Prices__r) {
      grandTotal += up.Barsala_Price_Modeled_Final__c;
    }
    if (u.Cleaning_Fee__c != null)
      grandTotal += u.Cleaning_Fee__c;

    grandTotal += (grandTotal * u.Tax_Rate__c);

    UnitBookingController.allCities();
    UnitBookingController.allUnits(
      'Seattle',
      system.now().format('MM/dd/yyyy'),
      system.now().addDays(3).format('MM/dd/yyyy'),
      '2',
      null,
      false,
      null,
      true
    );

    String fakeBody = '{ "paid": true, "status": "succeeded", "id": "cus_CxsJgOxi7kpYIE", "object": "customer", "account_balance": 0, "created": 1527795322, "currency": null, "default_source": "card_1CXwYQKasHLvOShlYU0kNJvt", "delinquent": false, "description": "Created w/Booking Extension program", "discount": null, "email": "testnew@test.com", "invoice_prefix": "EBB1D37", "livemode": false, "metadata": {}, "shipping": null, "sources": { "object": "list", "data": [{ "id": "card_1CXwYQKasHLvOShlYU0kNJvt", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": "3333", "address_zip_check": "pass", "brand": "Visa", "country": "US", "customer": "cus_CxsJgOxi7kpYIE", "cvc_check": "pass", "dynamic_last4": null, "exp_month": 1, "exp_year": 2019, "fingerprint": "R0oPB77Gc1J1A88o", "funding": "unknown", "last4": "1111", "metadata": {}, "name": "Tarun", "tokenization_method": null }, { "id": "card_1CYB7JKasHLvOShluTNrQZDG", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": "eee3", "address_zip_check": "pass", "brand": "Visa", "country": "US", "customer": "cus_CxsJgOxi7kpYIE", "cvc_check": "pass", "dynamic_last4": null, "exp_month": 2, "exp_year": 2019, "fingerprint": "b9QkZhVd8NwlE5pp", "funding": "credit", "last4": "4242", "metadata": {}, "name": "Tarun Jain", "tokenization_method": null }], "has_more": false, "total_count": 2, "url": "/v1/customers/cus_CxsJgOxi7kpYIE/sources" }, "subscriptions": { "object": "list", "data": [], "has_more": false, "total_count": 0, "url": "/v1/customers/cus_CxsJgOxi7kpYIE/subscriptions" }, "card": { "id": "card_1AePv8KasHLvOShlwqDoNOOd", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": null, "address_zip_check": null, "brand": "Visa", "country": "US", "cvc_check": null, "dynamic_last4": null, "exp_month": 8, "exp_year": 2018, "fingerprint": "b9QkZhVd8NwlE5pp", "funding": "credit", "last4": "4242", "metadata": {}, "name": null, "tokenization_method": null }, "client_ip": null, "type": "card", "used": false }';
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator(
        200,
        'ok',
        fakeBody,
        new Map<String, String>()
      )
    );

    test.startTest();
    UnitBookingController.ContactModel conModel = UnitBookingController.searchContact(
      'test@gmail.com',
      null
    );
    UnitBookingController.searchContactFornew('test@gmail.com', null);

    Xotelia_Booking__c book = new Xotelia_Booking__c(
      Firstname__c = 'FName',
      Lastname__c = 'LName',
      Email__c = 'test@gmail.com',
      Billing_Contact__c = (conModel != null ? conModel.contact.Id : null),
      Credit_Card_Full_Name__c = 'test',
      Credit_Card_CVV__c = 'test',
      Credit_Card_Number__c = '1112223334445443',
      Credit_Card_Expiration_Date__c = '12/' + Date.today().Year(),
      Credit_Card_Type__c = 'VISA',
      Zip_Code__c = 'test',
      Total_taxed__c = grandTotal,
      Product__c = u.id,
      External_code__c = 'test',
      Start_date__c = date.today(),
      End_date__c = date.today().addDays(3),
      Status__c = 'Active',
      Travelers__c = 1,
      Sales_channel__c = 'test'
    );

    UnitBookingController.BookUnitWrapper(
      book,
      system.now().format('MM/dd/yyyy'),
      system.now().addDays(65).format('MM/dd/yyyy'),
      'test unit',
      'newCard',
      '',
      true,
      ''
    );

    list<string> lst = UnitBookingController.allYear();
    test.stopTest();
    //}
  }
  @isTest
  static void TestExtensionBooking() {
    Unit__c u = [
      SELECT
        id,
        Tax_Rate__c,
        Base_price__c,
        (
          SELECT id, Barsala_Price_Modeled_Final__c
          FROM Unit_Prices__r
          WHERE Name = :string.valueOf(system.now().addDays(3).Date())
        )
      FROM Unit__c
      WHERE Name = 'test 1' AND Unit__c = '1'
      LIMIT 1
    ];

    Xotelia_Booking__c book1 = new Xotelia_Booking__c(
      Firstname__c = 'FName',
      Lastname__c = 'LName',
      Email__c = 'test1@gmail.com',
      Product__c = u.id,
      External_code__c = 'manual',
      Start_date__c = date.today(),
      End_date__c = date.today().addDays(65),
      Status__c = 'Active',
      Travelers__c = 1,
      Sales_channel__c = 'expedia',
      Stripe_Customer__c = '777customers/cus_test',
      Credit_Card_Full_Name__c = 'test',
      Credit_Card_CVV__c = 'test',
      Credit_Card_Number__c = '1112223334445443',
      Credit_Card_Expiration_Date__c = '12/' + Date.today().Year(),
      Credit_Card_Type__c = 'VISA',
      Zip_Code__c = 'test'
    );
    UnitBookingController.ResponseModel rm = UnitBookingController.BookUnit(
      book1,
      system.now().format('MM/dd/yyyy'),
      system.now().addDays(2).format('MM/dd/yyyy'),
      true
    );
    insert rm.bookings;

    system.debug('@@@==' + rm);
    List<Xotelia_Booking__c> booking = [
      SELECT id
      FROM Xotelia_Booking__c
      WHERE DAY_ONLY(Start_date__c) = :Date.Today() AND Product__c = :u.id
      LIMIT 1
    ];

    UnitBookingController.bookInit(booking[0].Id);

    String fakeBody = '{ "paid": true, "status": "succeeded", "id": "cus_CxsJgOxi7kpYIE", "object": "customer", "account_balance": 0, "created": 1527795322, "currency": null, "default_source": "card_1CXwYQKasHLvOShlYU0kNJvt", "delinquent": false, "description": "Created w/Booking Extension program", "discount": null, "email": "testnew@test.com", "invoice_prefix": "EBB1D37", "livemode": false, "metadata": {}, "shipping": null, "sources": { "object": "list", "data": [{ "id": "card_1CXwYQKasHLvOShlYU0kNJvt", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": "3333", "address_zip_check": "pass", "brand": "Visa", "country": "US", "customer": "cus_CxsJgOxi7kpYIE", "cvc_check": "pass", "dynamic_last4": null, "exp_month": 1, "exp_year": 2019, "fingerprint": "R0oPB77Gc1J1A88o", "funding": "unknown", "last4": "1111", "metadata": {}, "name": "Tarun", "tokenization_method": null }, { "id": "card_1CYB7JKasHLvOShluTNrQZDG", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": "eee3", "address_zip_check": "pass", "brand": "Visa", "country": "US", "customer": "cus_CxsJgOxi7kpYIE", "cvc_check": "pass", "dynamic_last4": null, "exp_month": 2, "exp_year": 2019, "fingerprint": "b9QkZhVd8NwlE5pp", "funding": "credit", "last4": "4242", "metadata": {}, "name": "Tarun Jain", "tokenization_method": null }], "has_more": false, "total_count": 2, "url": "/v1/customers/cus_CxsJgOxi7kpYIE/sources" }, "subscriptions": { "object": "list", "data": [], "has_more": false, "total_count": 0, "url": "/v1/customers/cus_CxsJgOxi7kpYIE/subscriptions" }, "card": { "id": "card_1AePv8KasHLvOShlwqDoNOOd", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": null, "address_zip_check": null, "brand": "Visa", "country": "US", "cvc_check": null, "dynamic_last4": null, "exp_month": 8, "exp_year": 2018, "fingerprint": "b9QkZhVd8NwlE5pp", "funding": "credit", "last4": "4242", "metadata": {}, "name": null, "tokenization_method": null }, "client_ip": null, "type": "card", "used": false }';
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator(
        200,
        'ok',
        fakeBody,
        new Map<String, String>()
      )
    );

    Test.startTest();
    UnitBookingController.searchUnitAvailability(
      Date.Today().addDays(3) + '',
      booking[0].Id
    );
    Test.stopTest();
    Decimal grandTotal = (u.Unit_Prices__r[0].Barsala_Price_Modeled_Final__c -
    ((u.Unit_Prices__r[0].Barsala_Price_Modeled_Final__c * 10) / 100));
    grandTotal += (grandTotal * u.Tax_Rate__c);
    String jsonData =
      '{"bookingComments":"test","toDate":"' +
      system.now().addDays(3).format('yyyy-MM-dd') +
      '","grandTotal":"' +
      grandTotal +
      '","SubTotal":"100"}';
    //result =
    String ccModelJson =
      '{"zipCode":"222","cardName":"Tarun Jain","cvv":"333","expYear":"' +
      Date.Today().year() +
      '","expMonth":"12","cardNumber":"2222222222222222"}';
    rm = UnitBookingController.bookExtension(
      booking[0].Id,
      '10',
      jsonData,
      true,
      ccModelJson,
      'newCard'
    );

    system.debug('@@@ response model' + rm);
    //system.assertEquals([select id from Xotelia_Booking__c where id =:rm.recordId].size(),0);
  }

  @isTest
  static void TestExtensionBooking2() {
    Unit__c u = [
      SELECT
        id,
        Tax_Rate__c,
        Base_price__c,
        (
          SELECT id, Barsala_Price_Modeled_Final__c
          FROM Unit_Prices__r
          WHERE Name = :string.valueOf(system.now().addDays(3).Date())
        )
      FROM Unit__c
      WHERE Name = 'test 1' AND Unit__c = '1'
      LIMIT 1
    ];

    Xotelia_Booking__c book1 = new Xotelia_Booking__c(
      Firstname__c = 'FName',
      Lastname__c = 'LName',
      Email__c = 'test1@gmail.com',
      Product__c = u.id,
      External_code__c = 'manual',
      Start_date__c = date.today(),
      End_date__c = date.today().addDays(65),
      Status__c = 'Active',
      Travelers__c = 1,
      Sales_channel__c = 'expedia',
      //Stripe_Customer__c='777customers/cus_test',
      Credit_Card_Full_Name__c = 'test',
      Credit_Card_CVV__c = 'test',
      Credit_Card_Number__c = '1112223334445443',
      Credit_Card_Expiration_Date__c = '12/' + Date.today().Year(),
      Credit_Card_Type__c = 'VISA',
      Zip_Code__c = 'test'
    );
    UnitBookingController.ResponseModel rm = UnitBookingController.BookUnit(
      book1,
      system.now().format('MM/dd/yyyy'),
      system.now().addDays(2).format('MM/dd/yyyy'),
      true
    );
    insert rm.bookings;
    system.debug('@@@==' + rm);
    List<Xotelia_Booking__c> booking = [
      SELECT id
      FROM Xotelia_Booking__c
      WHERE DAY_ONLY(Start_date__c) = :Date.Today() AND Product__c = :u.id
      LIMIT 1
    ];

    UnitBookingController.bookInit(booking[0].Id);

    String fakeBody = '{"paid": true,"status": "succeeded","id": "cus_CxsJgOxi7kpYIE", "object": "customer", "account_balance": 0, "created": 1527795322, "currency": null, "default_source": "card_1CXwYQKasHLvOShlYU0kNJvt", "delinquent": false, "description": "Created w/Booking Extension program", "discount": null, "email": "testnew@test.com", "invoice_prefix": "EBB1D37", "livemode": false, "metadata": {}, "shipping": null, "sources": { "object": "list", "data": [ { "id": "card_1CXwYQKasHLvOShlYU0kNJvt", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": "3333", "address_zip_check": "pass", "brand": "Visa", "country": "US", "customer": "cus_CxsJgOxi7kpYIE", "cvc_check": "pass", "dynamic_last4": null, "exp_month": 1, "exp_year": 2019, "fingerprint": "R0oPB77Gc1J1A88o", "funding": "unknown", "last4": "1111", "metadata": {}, "name": "Tarun", "tokenization_method": null }, { "id": "card_1CYB7JKasHLvOShluTNrQZDG", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": "eee3", "address_zip_check": "pass", "brand": "Visa", "country": "US", "customer": "cus_CxsJgOxi7kpYIE", "cvc_check": "pass", "dynamic_last4": null, "exp_month": 2, "exp_year": 2019, "fingerprint": "b9QkZhVd8NwlE5pp", "funding": "credit", "last4": "4242", "metadata": {}, "name": "Tarun Jain", "tokenization_method": null } ], "has_more": false, "total_count": 2, "url": "/v1/customers/cus_CxsJgOxi7kpYIE/sources" }, "subscriptions": { "object": "list", "data": [], "has_more": false, "total_count": 0, "url": "/v1/customers/cus_CxsJgOxi7kpYIE/subscriptions" } }';
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator(
        200,
        'ok',
        fakeBody,
        new Map<String, String>()
      )
    );

    Test.startTest();
    UnitBookingController.searchUnitAvailability(
      Date.Today().addDays(3) + '',
      booking[0].Id
    );

    Test.stopTest();
    Decimal grandTotal = (u.Unit_Prices__r[0].Barsala_Price_Modeled_Final__c -
    ((u.Unit_Prices__r[0].Barsala_Price_Modeled_Final__c * 10) / 100));
    grandTotal += (grandTotal * u.Tax_Rate__c);
    String jsonData =
      '{"defaultCard":"test","bookingComments":"test","toDate":"' +
      system.now().addDays(3).format('yyyy-MM-dd') +
      '","grandTotal":"' +
      grandTotal +
      '","SubTotal":"100"}';
    //result =
    rm = UnitBookingController.bookExtension(
      booking[0].Id,
      '10',
      jsonData,
      true,
      '',
      'lastCard'
    );
    system.debug('@@@ response model' + rm);
    //system.assertEquals([select id from Xotelia_Booking__c where id =:rm.recordId].size(),0);

    UnitBookingController.searchContactFornew('test@gmail.com', '9898989898');
    Contact c = [SELECT id FROM contact LIMIT 1];
    Task t = new Task();
    t.OwnerId = UserInfo.getUserId();
    t.Subject = 'Donni';
    t.Status = 'Not Started';
    t.Priority = 'Normal';
    insert t;

    t = new Task();
    t.OwnerId = UserInfo.getUserId();
    t.Subject = 'Donni';
    t.Status = 'Not Started';
    t.Priority = 'Normal';
    t.whoid = c.Id;
    insert t;

    UnitBookingController.findTaskByContactId(c.Id);
    UnitBookingController.findAllLeadSource();
  }
}
