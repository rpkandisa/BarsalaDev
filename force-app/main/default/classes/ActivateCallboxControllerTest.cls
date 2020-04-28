@isTest
public with sharing class ActivateCallboxControllerTest {
    @TestSetup static void createTestData(){
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
        Same_Day_Reservation_End_Time__c = '06:00 AM'
        );
        insert b;


    }

    static testMethod void validatebuildingsendsms() {

        Building__c b = [select id,name from Building__c limit 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(b);
        ActivateCallboxController objAC = new ActivateCallboxController(sc);

        PageReference pageRef = Page.ActivateCallbox;
        pageRef.getParameters().put('id', String.valueOf(b.Id));
        Test.setCurrentPage(pageRef);

        objAC.sendtextmessage();

    }
}