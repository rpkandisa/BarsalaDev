@isTest
public class BatchtoDeleteShrinpixImgRecordTest {
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

    sharinpix__SharinPixImage__c spImage = new sharinpix__SharinPixImage__c();
    spImage.Checkin_Instruction_Step_Number__c = 1;
    spImage.Checkin_Instruction_Description__c = 'Test';
    spImage.sharinpix__FileName__c = 'copy-of-02_5152_mls';
    spImage.sharinpix__Format__c = 'jpg';
    spImage.sharinpix__ImageURLOriginal__c = 'https://p.sharinpix.com/1/e5aa706/app.sharinpix.com%2Fimages%2Fb1cbdac3-a582-4f45-9d7d-d2a04d0a0a93%2Fthumbnails%2Foriginal-3f66b6b44ee.jpg/matterport-rollins-510-living-room.jpg';
    spImage.sharinpix__ImagePublicId__c = 'd7eb26dd-2989-4e06-9eb9-d73323644b34';
    spImage.Unit__c = u.Id;
    insert spImage;
  }

  @isTest
  public static void method1() {
    Test.startTest();
    try {
      Test.setMock(HttpCalloutMock.class, new AttachmentCalloutMock());

      BatchtoDeleteShrinpixImgRecord obj = new BatchtoDeleteShrinpixImgRecord();
      DataBase.executebatch(obj);
    } catch (Exception e) {
    }

    Test.stopTest();
  }

  @isTest
  public static void callscheduler() {
    Test.startTest();
    try {
      Test.setMock(HttpCalloutMock.class, new AttachmentCalloutMock());
      SharinpixDeleleteRecordScheduler sh1 = new SharinpixDeleleteRecordScheduler();
      String sch = '0 0 23 * * ?';
      system.schedule('Test scheduler to delete shrinpix', sch, sh1);
    } catch (Exception e) {
    }

    Test.stopTest();
  }
}