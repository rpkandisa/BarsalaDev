@isTest
public class BatchToUpdateSharinpixForBUSTest {
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

    sharinpix__SharinPixImage__c spImage = new sharinpix__SharinPixImage__c();
    spImage.Checkin_Instruction_Step_Number__c = 1;
    spImage.Checkin_Instruction_Description__c = 'Test';
    spImage.sharinpix__FileName__c = 'copy-of-02_5152_mls';
    spImage.sharinpix__Format__c = 'jpg';
    spImage.sharinpix__ImageURLOriginal__c = 'https://p.sharinpix.com/1/b74d25f/app.sharinpix.com%2Fimages%2F0447bdcf-6a0f-481b-a413-9915bf0d56d0%2Fthumbnails%2Foriginal-27520d72327.jpg/copy-of-02_5152_mls.jpg';
    spImage.Unit__c = u.Id;
    insert spImage;

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

    spImage = new sharinpix__SharinPixImage__c();
    spImage.Checkin_Instruction_Step_Number__c = 1;
    spImage.Checkin_Instruction_Description__c = 'Test1';
    spImage.sharinpix__FileName__c = 'copy-of-02_5152_mls1';
    spImage.sharinpix__Format__c = 'jpg';
    spImage.sharinpix__ImageURLOriginal__c = 'https://p.sharinpix.com/1/b74d25f/app.sharinpix.com%2Fimages%2F0447bdcf-6a0f-481b-a413-9915bf0d56d0%2Fthumbnails%2Foriginal-27520d72327.jpg/copy-of-02_5152_mls.jpg';
    spImage.Unit__c = u.Id;
    insert spImage;

    spImage = new sharinpix__SharinPixImage__c();
    spImage.Checkin_Instruction_Step_Number__c = 1;
    spImage.Checkin_Instruction_Description__c = 'Test2';
    spImage.sharinpix__FileName__c = 'copy-of-02_5152_mls2';
    spImage.sharinpix__Format__c = 'jpg';
    spImage.sharinpix__ImageURLOriginal__c = 'https://p.sharinpix.com/1/b74d25f/app.sharinpix.com%2Fimages%2F0447bdcf-6a0f-481b-a413-9915bf0d56d0%2Fthumbnails%2Foriginal-27520d72327.jpg/copy-of-02_5152_mls.jpg';
    spImage.Unit__c = u.Id;
    insert spImage;

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
  }

  @isTest
  public static void testMethod1() {
    Test.startTest();
    try {
      BatchToUpdateSharinpixForBUS obj = new BatchToUpdateSharinpixForBUS(true);
      DataBase.executebatch(obj);
    } catch (Exception e) {
    }

    Test.stopTest();
  }

  @isTest
  public static void testMethod2() {
    Test.startTest();
    try {
      BatchToUpdateSharinpixForBUS obj = new BatchToUpdateSharinpixForBUS(false);
      DataBase.executebatch(obj);
    } catch (Exception e) {
    }

    Test.stopTest();
  }
}