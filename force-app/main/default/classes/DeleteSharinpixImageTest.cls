@isTest
public class DeleteSharinpixImageTest {
  static testMethod void testMethod1() {
    Id recodeType = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();
    Account testAccount = new Account();
    testAccount.LastName = 'Test Account';
    testAccount.RecordTypeId = recodeType;
    testAccount.Phone = '1987652345';
    testAccount.Is_Sync_Image_Process__c = true;
    insert testAccount;

    Test.StartTest();
    DeleteSharinpixImage.deleteImage(testAccount.Id);
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
    testAccount.Phone = '1987652345';
    testAccount.Is_Sync_Image_Process__c = true;
    insert testAccount;

    BatchtoDeleteShrinpixImages b = new BatchtoDeleteShrinpixImages();
    ID batchprocessid = Database.executeBatch(b);

    Test.StopTest();
  }
}