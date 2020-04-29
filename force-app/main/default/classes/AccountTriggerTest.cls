@isTest
public class AccountTriggerTest {
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
    objBarsalaSetting.Check_duplicate_Contact_Via_Trigger__c = true;
    upsert objBarsalaSetting;

    Id recodeType = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();
    Account testAccount = new Account();
    testAccount.LastName = 'Test Account';
    testAccount.RecordTypeId = recodeType;
    testAccount.Phone = '1987652345,18787234590';
    insert testAccount;

    Contact c = new Contact();
    c.LastName = 'contactlastname';
    c.Email = 'test123@bc.com';
    c.Phone = '18989076543';
    insert c;
  }
  static testMethod void testMethod1() {
    Test.StartTest();

    Id recodeType = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();
    Account testAccount = new Account();
    testAccount.LastName = 'Test Account';
    testAccount.RecordTypeId = recodeType;
    testAccount.Phone = '1987652322,18787234590';
    insert testAccount;

    Test.StopTest();
  }

  static testMethod void testMethod2() {
    Test.StartTest();

    Id recodeType = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();
    Account testAccount = new Account();
    testAccount.LastName = 'Test Account';
    testAccount.RecordTypeId = recodeType;
    testAccount.Phone = '18989076543';
    testAccount.PersonEmail = 'test123@bc.com';
    try {
      insert testAccount;
    } catch (Exception e) {
    }

    Test.StopTest();
  }

  static testMethod void testMethod3() {
    Test.StartTest();

    Id recodeType = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();

    Account testAccount = new Account();
    testAccount.LastName = 'Last Account1x9x';
    testAccount.RecordTypeId = recodeType;
    testAccount.Phone = '18989073232';
    testAccount.PersonEmail = 'lastaccount1x9x@abc.com';
    insert testAccount;

    try {
      AccountTriggerDuplicateContact.isrecursion = false;
      Account objacc = new Account();
      objacc = testAccount.clone(false);
      insert objacc;
    } catch (Exception e) {
    }

    try {
      AccountTriggerDuplicateContact.isrecursion = false;
      Account objacc = new Account();
      objacc = [
        SELECT Id, PersonEmail, Phone, LastName
        FROM Account
        WHERE id != :testAccount.Id
        LIMIT 1
      ];
      update objacc;
    } catch (Exception e) {
    }

    Test.StopTest();
  }
}