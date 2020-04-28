@isTest
public class BatchToUpdatePersonDataByBookingTest {
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
    c.Tax__c = 0.15;
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
      Website_Listing_Name__c = 'test'
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
      Website_Listing_Name__c = 'test'
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
      Website_Listing_Name__c = 'test'
    );
    insert u3;

    list<unit_pricing__c> unitPriceList = new List<unit_pricing__c>();
    date d = date.today().AddDays(-5);
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

    d = date.today().AddDays(-5);
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

    Account objacc = [
      SELECT PersonContactId, Name
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
    objbooking.End_date__c = system.now().addDays(2);
    objbooking.Product__c = u.id;
    objbooking.Billing_Contact__c = objacc.PersonContactId;
    objBooking.Discount__c = 10;
    objBooking.Sub_Total__c = 50;
    objBooking.Total_taxed__c = 2;
    objBooking.Guest_Contact__c = objacc.PersonContactId;
    objBooking.IDSelfie_file_id__c = 'https://api.typeform.com/responses/files/b796643ddc9e7d8f37eedfdd866637489bf826eb8ca583805dc58c1a8161978f/20171026_125007.jpg';
    objBooking.IDoc_file_id__c = 'https://api.typeform.com/responses/files/558b63a6aa7d34a8708872cb080057a51069ef8cf7323a638ee2e03aeef11dc5/BW_drivers_license_front.jpg';
    insert objbooking;

    Attachment att = new Attachment();
    att.Name = 'Government-Issued-ID-' + objacc.Name.replace(' ', '-');
    att.ParentId = objacc.Id;
    Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
    att.Body = bodyBlob;
    insert att;

    Attachment att1 = new Attachment();
    att1.Name = 'Government-Issued-ID-Selfie-' + objacc.Name.replace(' ', '-');
    att1.ParentId = objacc.Id;
    Blob bodyBlob1 = Blob.valueOf('Unit Test Attachment Body');
    att1.Body = bodyBlob1;
    insert att1;
  }

  @isTest
  public static void testMethod1() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new AttachmentCalloutMock());

    BatchToUpdatePersonDataByBooking obj = new BatchToUpdatePersonDataByBooking(
      0
    );
    DataBase.executebatch(obj);
    Test.stopTest();
  }

  @isTest
  public static void testMethod2() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new AttachmentCalloutMock());

    BatchToUpdatePersonDataByBooking obj = new BatchToUpdatePersonDataByBooking(
      1
    );
    DataBase.executebatch(obj);
    Test.stopTest();
  }

  @isTest
  public static void testMethod3() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new AttachmentCalloutMock());

    BatchToUpdatePersonDataByBooking obj = new BatchToUpdatePersonDataByBooking(
      2
    );
    DataBase.executebatch(obj);
    Test.stopTest();
  }

  @isTest
  public static void testMethod4() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new AttachmentCalloutMock());

    BatchToUpdatePersonDataByBooking obj = new BatchToUpdatePersonDataByBooking(
      3
    );
    DataBase.executebatch(obj);
    Test.stopTest();
  }

  @isTest
  public static void testMethod5() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new AttachmentCalloutMock());

    BatchToUpdatePersonDataByBooking obj = new BatchToUpdatePersonDataByBooking(
      4
    );
    DataBase.executebatch(obj);
    Test.stopTest();
  }

  @isTest
  public static void testMethod6() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new AttachmentCalloutMock());

    BatchToUpdatePersonDataByBooking obj = new BatchToUpdatePersonDataByBooking(
      5
    );
    DataBase.executebatch(obj);
    Test.stopTest();
  }

  @isTest
  public static void testMethod7() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new AttachmentCalloutMock());

    BatchToUpdatePersonDataByBooking obj = new BatchToUpdatePersonDataByBooking(
      6
    );
    DataBase.executebatch(obj);
    Test.stopTest();
  }

  @isTest
  public static void testMethod8() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new AttachmentCalloutMock());

    BatchToUpdatePersonDataByBooking obj = new BatchToUpdatePersonDataByBooking(
      7
    );
    DataBase.executebatch(obj);
    Test.stopTest();
  }
}