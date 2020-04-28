//added by kandisa tech on 21/10/2019

@isTest 
public class AirbnbMergeContactDuplicateBatchTest {
    
    static testMethod void validateBatch() {
        List<Account> lstAccount= new List<Account>();

        Id PersonAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = PersonAccountRT;
        acc.LastName ='testdata';
        acc.Airbnb_ID__pc = '9898989898';
        acc.PersonEmail = 'acc@gmail.com';
        acc.Booking_Exists__pc = true;
        acc.Is_Airbnb_Id_duplicate__pc = true;
        lstAccount.add(acc);

        acc = new Account();
        acc.RecordTypeId = PersonAccountRT;
        acc.LastName ='testdata111';
        acc.Airbnb_ID__pc = '9898989898';
        acc.PersonEmail = 'aaaa@gmail.com';
        acc.Booking_Exists__pc = true;
        acc.Is_Airbnb_Id_duplicate__pc = true;
        lstAccount.add(acc);

        acc = new Account();
        acc.RecordTypeId = PersonAccountRT;
        acc.LastName ='testdata111';
        acc.Airbnb_ID__pc = '9898989898';
        acc.PersonEmail = 'aaaa@gmail.com';
        acc.Booking_Exists__pc = true;
        acc.Is_Airbnb_Id_duplicate__pc = true;
        lstAccount.add(acc);

        acc = new Account();
        acc.RecordTypeId = PersonAccountRT;
        acc.LastName ='testdata111';
        acc.Airbnb_ID__pc = '9898989898';
        acc.PersonEmail = 'bbb@gmail.com';
        acc.Booking_Exists__pc = true;
        acc.Is_Airbnb_Id_duplicate__pc = true;
        lstAccount.add(acc);

        insert lstAccount;

        Test.startTest();

        AirbnbMergeContactDuplicateBatch obj = new AirbnbMergeContactDuplicateBatch();
        DataBase.executeBatch(obj); 

        Test.stopTest();
        
    }
}