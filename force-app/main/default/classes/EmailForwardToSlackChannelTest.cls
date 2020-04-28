@isTest
public class EmailForwardToSlackChannelTest {
  @testsetup
  static void setupTestData() {
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
    objBarsalaSetting.Forward_Email_on_Slack_Channel__c = true;
    objBarsalaSetting.Slack_Channel_Email_Address__c = 'testfl88888@airbnb.com';
    objBarsalaSetting.Slack_User_Id__c = String.valueOf(UserInfo.getUserId());
    insert objBarsalaSetting;

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
      PersonEmail = 'testfl88888@airbnb.com',
      PersonHomePhone = '1234567',
      PersonMobilePhone = '12345678'
    );
    insert acc;

    Account objacc = [
      SELECT id, PersonContactId
      FROM account
      WHERE id = :acc.Id
    ];

    List<Case> cases = new List<Case>();
    cases.add(
      new Case(
        Status = 'New',
        Priority = 'Medium',
        Origin = 'Email',
        ContactId = objacc.PersonContactId,
        Accountid = acc.Id,
        Subject = 'TestSubject',
        Description = 'TestDescription'
      )
    );
    insert cases;

    EmailMessage email = new EmailMessage();
    email.FromAddress = 'test@abc.org';
    email.Incoming = true;
    email.ToAddress = 'test@xyz.org';
    email.Subject = 'Test email';
    email.HtmlBody = 'Test email body';
    email.ParentId = cases.get(0).Id;
    insert email;
  }

  @isTest
  static void ValidateSendEmailonSlackChannel() {
    Test.startTest();
    List<Case> cases = new List<Case>([SELECT id FROM case]);
    update cases;
    Test.stopTest();
  }
}