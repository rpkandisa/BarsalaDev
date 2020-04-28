@isTest
public class AccountTriggerHandlerTest {
  static testMethod void validateBatch() {
    List<Account> lstAccount = new List<Account>();

    Id PersonAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();
    Account acc = new Account();
    acc.RecordTypeId = PersonAccountRT;
    acc.FirstName = 'Rajesh';
    acc.LastName = 'testdata';
    acc.Phone = '9898989898';
    acc.PersonEmail = 'acc@gmail.com';
    acc.Booking_Exists__pc = true;
    acc.Is_Duplicate__pc = true;
    lstAccount.add(acc);

    insert lstAccount;

    Test.startTest();

    BatchToUpdatePersonGender obj = new BatchToUpdatePersonGender();
    DataBase.executeBatch(obj);

    Test.stopTest();
  }

  @isTest
  public static void methodForSingleRecord() {
    String recordTypeId = Schema.getGlobalDescribe()
      .get('Account')
      .getDescribe()
      .getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();
    Account acc = new Account(
      RecordTypeID = recordTypeId,
      FirstName = 'Sam',
      LastName = 'LName',
      PersonMailingStreet = 'test@yahoo.com',
      PersonMailingPostalCode = '12345',
      PersonMailingCity = 'SFO',
      PersonEmail = 'test@yahoo.com',
      PersonHomePhone = '1234567',
      PersonMobilePhone = '12345678',
      Phone = '9876543210,9632587412'
    );

    Test.setMock(HttpCalloutMock.class, new MockHTTPForGenderizeAPI());

    Test.startTest();
    insert acc;

    acc.firstName = 'Samantha';
    update acc;
    Test.stopTest();
  }

  @isTest
  public static void methodForMultipleRecord() {
    List<Account> lstAccounts = new List<Account>();
    String recordTypeId = Schema.getGlobalDescribe()
      .get('Account')
      .getDescribe()
      .getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();
    Account acc = new Account(
      RecordTypeID = recordTypeId,
      FirstName = 'Sam',
      LastName = 'LName',
      PersonMailingStreet = 'test@yahoo.com',
      PersonMailingPostalCode = '12345',
      PersonMailingCity = 'SFO',
      PersonEmail = 'test@yahoo.com',
      PersonHomePhone = '1234567',
      PersonMobilePhone = '12345678',
      Phone = '9876543210,9632587412'
    );
    lstAccounts.add(acc);

    Account acc1 = new Account(
      RecordTypeID = recordTypeId,
      FirstName = 'Samantha',
      LastName = 'LName',
      PersonMailingStreet = 'test@yahoo.com',
      PersonMailingPostalCode = '12345',
      PersonMailingCity = 'SFO',
      PersonEmail = 'test@yahoo.com',
      PersonHomePhone = '1234567',
      PersonMobilePhone = '12345678',
      Phone = '9876543210,9632587412'
    );
    lstAccounts.add(acc1);

    Test.setMock(HttpCalloutMock.class, new MockHTTPForGenderizeAPI());

    Test.startTest();
    insert lstAccounts;
    Test.stopTest();
  }
}