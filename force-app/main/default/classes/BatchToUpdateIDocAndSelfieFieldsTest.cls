@isTest
public class BatchToUpdateIDocAndSelfieFieldsTest {
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
      SELECT Id, PersonContactId, Name
      FROM Account
      WHERE Id = :testAccount.Id
      LIMIT 1
    ];

    sharinpix__SharinPixImage__c img = new sharinpix__SharinPixImage__c();
    img.sharinpix__Account__c = objacc.Id;
    img.sharinpix__FileName__c =
      'Government-Issued-ID-' + objacc.Name.replace(' ', '-');
    img.sharinpix__ImageURLOriginal__c = 'https://p.sharinpix.com/2/cc79d80/YXBwLnNoYXJpbnBpeC5jb20vaW1hZ2VzLzQyYzgwNjQ4LWY3MzYtNGVlZi1hNjM1LWY4ZGJmZTUzYTU1Ni90aHVtYm5haWxzL29yaWdpbmFsLTNhZmFmOGViMjk5LmpwZw==/government-issued-id-7531-ne-17th-st-apt-.jpg';
    img.sharinpix__ImagePublicId__c = 's1ds234f';
    insert img;

    img = new sharinpix__SharinPixImage__c();
    img.sharinpix__Account__c = objacc.Id;
    img.sharinpix__FileName__c =
      'Government-Issued-ID-Selfie-' + objacc.Name.replace(' ', '-');
    img.sharinpix__ImageURLOriginal__c = 'https://p.sharinpix.com/2/cc79d80/YXBwLnNoYXJpbnBpeC5jb20vaW1hZ2VzLzQyYzgwNjQ4LWY3MzYtNGVlZi1hNjM1LWY4ZGJmZTUzYTU1Ni90aHVtYm5haWxzL29yaWdpbmFsLTNhZmFmOGViMjk5LmpwZw==/government-issued-id-7531-ne-17th-st-apt-.jpg';
    img.sharinpix__ImagePublicId__c = 's1dselfies234f';
    insert img;

    Test.StartTest();
    BatchToUpdateIDocAndSelfieFields b = new BatchToUpdateIDocAndSelfieFields();
    Database.executeBatch(b);
    Test.StopTest();
  }
}