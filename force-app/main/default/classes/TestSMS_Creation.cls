@isTest
public class TestSMS_Creation {

    
    
    @isTest
    public static void TestSMS_CreationAndCaseLookupWithContact(){
        
        smagicinteract__smsMagic__c CurrentSMS = new smagicinteract__smsMagic__c(smagicinteract__PhoneNumber__c='1234667890',smagicinteract__SMSText__c ='Hello',smagicinteract__SenderId__c = '15612645662');
        Insert CurrentSMS;
        Contact con = new Contact(FirstName='test',LastName= 'July',Phone=CurrentSMS.smagicinteract__PhoneNumber__c);
        insert con;
        Case CurrCase = new case(Status = 'Open',ContactId= con.id);
        insert CurrCase;
        SMS_Creation.WrapperClass wrap = new SMS_Creation.WrapperClass();
        wrap.ContPhone = CurrentSMS.smagicinteract__PhoneNumber__c;
        wrap.SMSText = CurrentSMS.smagicinteract__SMSText__c; 
        wrap.SMSHistoryId = CurrentSMS.Id;
        wrap.OwnerId = UserInfo.getUserId();
        List<SMS_Creation.WrapperClass> wrapList = new List<SMS_Creation.WrapperClass>();
        wrapList.add(wrap);
        //insert wrapList;
        
        Test.startTest();
        SMS_Creation.SMS_CreationAndCaseLookup(wrapList);
        Test.stopTest();
    }
    
   @isTest
    public static void TestSMS_CreationAndCaseLookupWithoutCase(){
        
        smagicinteract__smsMagic__c CurrentSMS = new smagicinteract__smsMagic__c(smagicinteract__PhoneNumber__c='41234667890',smagicinteract__SMSText__c ='Hello',smagicinteract__SenderId__c = '15612645662');
        Insert CurrentSMS;
        Contact con = new Contact(FirstName='test',LastName= 'July',Phone=CurrentSMS.smagicinteract__PhoneNumber__c);
        insert con;
        
        SMS_Creation.WrapperClass wrap = new SMS_Creation.WrapperClass();
        wrap.SMSText = CurrentSMS.smagicinteract__SMSText__c; 
        wrap.SMSHistoryId = CurrentSMS.Id;
        wrap.OwnerId = UserInfo.getUserId();
        List<SMS_Creation.WrapperClass> wrapList = new List<SMS_Creation.WrapperClass>();
        wrapList.add(wrap);
        //insert wrapList;
        
        Test.startTest();
              
            SMS_Creation.SMS_CreationAndCaseLookup(wrapList);
           
        
        Test.stopTest();
    }
    
     @isTest
    public static void TestSMS_CreationAndCaseLookupWithoutContact(){
        
        smagicinteract__smsMagic__c CurrentSMS = new smagicinteract__smsMagic__c(smagicinteract__PhoneNumber__c='1234667890',smagicinteract__SMSText__c ='Hello',smagicinteract__SenderId__c = '15612645662');
        Insert CurrentSMS;
        
        SMS_Creation.WrapperClass wrap = new SMS_Creation.WrapperClass();
        wrap.SMSText = CurrentSMS.smagicinteract__SMSText__c; 
        wrap.SMSHistoryId = CurrentSMS.Id;
        wrap.OwnerId = UserInfo.getUserId();
        List<SMS_Creation.WrapperClass> wrapList = new List<SMS_Creation.WrapperClass>();
        wrapList.add(wrap);
        
        Test.startTest();
              
            SMS_Creation.SMS_CreationAndCaseLookup(wrapList);
           
        
        Test.stopTest();
    }

    @isTest
    public static void TestSMS_CreationAndCaseLookupWithoutContact1(){
        
        smagicinteract__smsMagic__c CurrentSMS = new smagicinteract__smsMagic__c(smagicinteract__PhoneNumber__c='1234665560',smagicinteract__SMSText__c ='this is test data. Text forwarded from: 1234667890 this is rnd to find number',smagicinteract__SenderId__c = '15612645662');
        Insert CurrentSMS;
        
        SMS_Creation.WrapperClass wrap = new SMS_Creation.WrapperClass();
        wrap.SMSText = CurrentSMS.smagicinteract__SMSText__c; 
        wrap.SMSHistoryId = CurrentSMS.Id;
        wrap.OwnerId = UserInfo.getUserId();
        List<SMS_Creation.WrapperClass> wrapList = new List<SMS_Creation.WrapperClass>();
        wrapList.add(wrap);
        
        Test.startTest();
              
            SMS_Creation.SMS_CreationAndCaseLookup(wrapList);
           
        
        Test.stopTest();
    }
    
    public Class WrapperClass {
        
        public String CaseSubject;
        
        public String ContPhone;
        
        public Id SMSHistoryId;
        
        public Id OwnerId;
        
        public String SMSText;
        
        public String FirstName;
        
        public String LastName;
        
    }
    
}