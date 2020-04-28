@isTest
public with sharing class BatchToSyncSharinPixForAccountTest {
  static testMethod void testMethod1() {
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

    BatchToSyncSharinPixForAccount b = new BatchToSyncSharinPixForAccount();
    ID batchprocessid = Database.executeBatch(b);

    Test.StopTest();
  }
}