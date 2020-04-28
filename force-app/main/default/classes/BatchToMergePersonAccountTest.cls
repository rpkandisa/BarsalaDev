@isTest 
public class BatchToMergePersonAccountTest {
    
    static testMethod void validateBatch() {
        List<Account> lstAccount= new List<Account>();

        Id PersonAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = PersonAccountRT;
        acc.LastName ='testdata';
        acc.Phone = '9898989898';
        acc.PersonEmail = 'acc@gmail.com';
        acc.Booking_Exists__pc = true;
        acc.Is_Duplicate__pc = true;
        lstAccount.add(acc);

        acc = new Account();
        acc.RecordTypeId = PersonAccountRT;
        acc.LastName ='testdata111';
        acc.Phone = '9898989898';
        acc.PersonEmail = 'aaaa@gmail.com';
        acc.Booking_Exists__pc = true;
        acc.Is_Duplicate__pc = true;
        lstAccount.add(acc);

        acc = new Account();
        acc.RecordTypeId = PersonAccountRT;
        acc.LastName ='testdata111';
        acc.Phone = '9898989898';
        acc.PersonEmail = 'aaaa@gmail.com';
        acc.Booking_Exists__pc = true;
        acc.Is_Duplicate__pc = true;
        lstAccount.add(acc);

        acc = new Account();
        acc.RecordTypeId = PersonAccountRT;
        acc.LastName ='testdata111';
        acc.Phone = '9898989898';
        acc.PersonEmail = 'bbb@gmail.com';
        acc.Booking_Exists__pc = true;
        acc.Is_Duplicate__pc = true;
        lstAccount.add(acc);

        insert lstAccount;

        Test.startTest();

        BatchToMergePersonAccount obj = new BatchToMergePersonAccount();
        DataBase.executeBatch(obj); 

        Test.stopTest();
        
    }
}