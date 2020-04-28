@isTest
public class BatchToTransferAttachmentToShrinpixTest {
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

    Account objacc = [
      SELECT PersonContactId, Name
      FROM Account
      WHERE Id = :testAccount.Id
      LIMIT 1
    ];

    Attachment att = new Attachment();
    att.Name = 'Government-Issued-ID-' + objacc.Name.replace(' ', '-');
    att.ParentId = testAccount.Id;
    Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
    att.Body = bodyBlob;
    insert att;

    Test.StartTest();
    BatchToTransferAttachmentToShrinpix b = new BatchToTransferAttachmentToShrinpix();
    Database.executeBatch(b);
    Test.StopTest();
  }
}