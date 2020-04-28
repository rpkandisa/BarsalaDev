@isTest
public with sharing class ProcessBuildingUnitPricingTest {
  @TestSetup
  static void createTestData() {
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
      Same_Day_Reservation_End_Time__c = '06:00 AM'
    );
    insert b;

    Building__c b2 = new Building__c(
      Name = 'test 2',
      Neighborhood__c = nb.Id,
      City__c = 'Seattle',
      Same_Day_Reservation_End_Time__c = '06:00 AM'
    );
    insert b2;

    Building__c b3 = new Building__c(
      Name = 'test 3',
      Neighborhood__c = nb1.Id,
      City__c = 'San Diego',
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

    Date tmpdt = date.today();
    List<Building_Unit_Set_Pricing__c> lstBUSP = new List<Building_Unit_Set_Pricing__c>();
    for (integer i = 0; i < 70; i++) {
      Date dtstart = tmpdt.addDays(i);
      Building_Unit_Set_Pricing__c busp = new Building_Unit_Set_Pricing__c();
      busp.Price_Date__c = dtstart;
      busp.Building_Unit_Set__c = bus1.Id;
      busp.Name =
        bus1.Name +
        ' | ' +
        DateTime.newInstance(dtstart.year(), dtstart.month(), dtstart.day())
          .format('yyyy-MM-dd');
      lstBUSP.add(busp);
    }
    insert lstBUSP;

    Unit_set__c us = new Unit_set__c(Name = 'Test US 1');
    insert us;

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
      Building_Unit_Set__c = bus1.Id
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
      Building_Unit_Set__c = bus2.Id
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
          name = string.valueOf(d),
          UNITPRICE_DATE__c = d
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
          name = string.valueOf(d),
          UNITPRICE_DATE__c = d
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
  }

  @isTest
  static void runBatchToCreateBuildingUnitSetPriceRecord() {
    Test.startTest();
    BatchToCreateBuildingUnitSetPriceRecord b = new BatchToCreateBuildingUnitSetPriceRecord();
    b.query = 'select id,Name,Building__c,IsRecordProcess__c from Building_Unit_Set__c where IsRecordProcess__c=false  and Name = \'BUS1\' ';
    Database.executeBatch(b);
    Test.stopTest();
  }

  @isTest
  static void runBatchForBuildingUnitPriceOnUnitPrice() {
    Test.startTest();
    BatchForBuildingUnitPriceOnUnitPrice b = new BatchForBuildingUnitPriceOnUnitPrice();
    b.query = 'SELECT Id, Building_Unit_Set__c, Price_Date__c FROM Building_Unit_Set_Pricing__c where  Building_Unit_Set__r.Name = \'BUS2\' ';
    Database.executeBatch(b);
    Test.stopTest();
  }
}