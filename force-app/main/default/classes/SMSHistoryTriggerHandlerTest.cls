@isTest
public class SMSHistoryTriggerHandlerTest {
  @isTest
  public static void method1() {
    Id APIServiceAccountProfileId = [
      SELECT Id
      FROM Profile
      WHERE Name = 'API Service Account'
      LIMIT 1
    ]
    .Id;
    User usr = new User(
      ProfileId = APIServiceAccountProfileId,
      LastName = 'last',
      Email = 'puser000@amamama.com',
      Username = 'puser000@amamama.com' + System.currentTimeMillis(),
      CompanyName = 'TEST',
      Title = 'title',
      Alias = 'alias',
      TimeZoneSidKey = 'America/Los_Angeles',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US'
    );
    insert usr;

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
    //objBarsalaSetting.Enable_SMSHistory_for_API_Service_Accout__c = true;
    //objBarsalaSetting.API_Service_Account_ProfileId__c = APIServiceAccountProfileId;
    objBarsalaSetting.Executive_Owner_Id__c = UserInfo.getUserId();
    upsert objBarsalaSetting;

    List<smagicinteract__smsMagic__c> lst_sms = new List<smagicinteract__smsMagic__c>();
    smagicinteract__smsMagic__c CurrentSMS = new smagicinteract__smsMagic__c(
      smagicinteract__PhoneNumber__c = '41234667890',
      smagicinteract__SMSText__c = 'Hello',
      smagicinteract__SenderId__c = '15612645662',
      Automated_Message_Type__c = 'Executive'
    );
    lst_sms.add(CurrentSMS);

    // smagicinteract__smsMagic__c CurrentSMS1 = new smagicinteract__smsMagic__c(
    //   smagicinteract__PhoneNumber__c = '41234667890',
    //   smagicinteract__SMSText__c = 'Hello',

    // );
    // lst_sms.add(CurrentSMS1);

    GroupMember gm = [
      SELECT GroupId, UserOrGroupId
      FROM GroupMember
      WHERE Group.Name = 'Executive SMS Users' AND Group.Type = 'Regular'
      LIMIT 1
    ];
    SMSHistoryTriggerHandler.getGroupUserIds(new Set<Id>{ gm.GroupId });

    System.runAs(usr) {
      insert lst_sms;
    }
  }
}