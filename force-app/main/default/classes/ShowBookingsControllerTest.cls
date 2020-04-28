@isTest
public class ShowBookingsControllerTest {
  @isTest
  public static void getContactTest() {
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
      Display_Name__c = 'b1'
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
    objbooking.End_date__c = system.now().addDays(-3);
    objbooking.Product__c = u.id;
    objbooking.Billing_Contact__c = objacc.PersonContactId;
    objbooking.Commission_Belongs_To__c = objacc.PersonContactId;
    objBooking.Discount__c = 10;
    objBooking.Sub_Total__c = 50;
    objBooking.Total_taxed__c = 2;
    objBooking.Commission_paid__c = false;
    objBooking.Commission_Rejected_Comment__c = 'TEST';
    insert objbooking;

    Xotelia_Booking__c objbooking1 = new Xotelia_Booking__c();
    objbooking1.Sales_channel__c = 'manual';
    objbooking1.External_code__c = 'BASF80403300';
    objbooking1.External_code__c = 'BASF804000';
    objbooking1.Total_taxed__c = 183.30;
    objbooking1.Travelers__c = 1;
    objbooking1.Firstname__c = 'Test123';
    objbooking1.Lastname__c = 'RP100123';
    objbooking1.Email__c = 'test@barsala.com';
    objbooking1.Phone_number__c = '9876543210';
    objbooking1.Start_date__c = system.now().addDays(-10);
    objbooking1.End_date__c = system.now().addDays(-8);
    objbooking1.Product__c = u.id;
    objbooking1.Billing_Contact__c = objacc.PersonContactId;
    objbooking1.Commission_Belongs_To__c = objacc.PersonContactId;
    objBooking1.Discount__c = 10;
    objBooking1.Sub_Total__c = 50;
    objBooking1.Total_taxed__c = 2;
    objBooking1.Commission_paid__c = true;

    insert objbooking1;

    Test.startTest();
    ShowBookingsController con = new ShowBookingsController();
    con.AccId = acc.Id;
    con.getContact();
    con.getBookingDetails();
    con.getTotalAmount();
    test.stopTest();
  }
}