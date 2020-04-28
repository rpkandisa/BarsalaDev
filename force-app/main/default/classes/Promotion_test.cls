@isTest
public class Promotion_test {
    @TestSetup static void createTestData(){
        Id PersonAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    	Account acc = new Account();
    	acc.RecordTypeId = PersonAccountRT;
    	acc.FirstName = 'Rajesh';
    	acc.LastName = 'Lastname';
    	acc.Phone = '8787292929';
    	acc.PersonEmail = 'testdata@gmail.com';
    	acc.Booking_Exists__pc = true;
    	acc.Is_Duplicate__pc = true;
        insert acc;        
    }
    
    @isTest
    static void PromotionTesting()
    {	
        Id PersonAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    	Account acc = new Account();
    	acc.RecordTypeId = PersonAccountRT;
    	acc.FirstName = 'Rajesh';
    	acc.LastName = 'testdata';
    	acc.Phone = '9898989898';
    	acc.PersonEmail = 'acc@gmail.com';
    	acc.Booking_Exists__pc = true;
    	acc.Is_Duplicate__pc = true;
        insert acc;
        
        Promotion__c promo = new Promotion__c();
        promo.name = 'Test';
        promo.Basis__c = 'percentage'; 
        promo.Discount_Percentage_Override__c = 10.00;
        promo.Usage_Type__c = 'fixed_use';
        insert promo;     
        
        
        Promotion.wrpPromotion Wrapvar = new Promotion.wrpPromotion();
        Wrapvar.usagetype = promo.Usage_Type__c;
        Wrapvar.basis = promo.Basis__c;
        Wrapvar.timecontrained = 'Yes';
        Wrapvar.prefertype = 'dayfromnow';
        Promotion.saveData(Wrapvar);
        Promotion.findbyaccountid(acc.id);
        
        test.startTest();
        promo.Basis__c = 'percentage'; 
        promo.Applies_To__c ='booking';
        Promotion.createname(promo,'test');
        update promo;
        test.stopTest();
    }

    @isTest
    static void PromotionaddonTesting()
    {	
        Id PersonAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    	Account acc = new Account();
    	acc.RecordTypeId = PersonAccountRT;
    	acc.FirstName = 'Rajesh';
    	acc.LastName = 'addon';
    	acc.Phone = '9898989898';
    	acc.PersonEmail = 'addon@gmail.com';
    	acc.Booking_Exists__pc = true;
    	acc.Is_Duplicate__pc = true;
        insert acc;
        
        Promotion__c promo = new Promotion__c();
        promo.name = 'Test';
        promo.Basis__c = 'percentage';
        promo.Applies_To__c = 'cleaning';
        insert promo;     
        
        
        Promotion.wrpPromotion Wrapvar = new Promotion.wrpPromotion();
        Wrapvar.usagetype = promo.Usage_Type__c;
        Wrapvar.basis = promo.Basis__c;
        Wrapvar.timecontrained = 'Yes';
        Wrapvar.prefertype = 'dayfromnow';
        Promotion.saveData(Wrapvar);
        Promotion.findbyaccountid(acc.id);
        
        test.startTest();
        promo = new Promotion__c();
        promo.name = 'Test';
        promo.Basis__c = 'percentage';
        insert promo; 

        Wrapvar = new Promotion.wrpPromotion();
        Wrapvar.usagetype = promo.Usage_Type__c;
        Wrapvar.basis = promo.Basis__c;
        Promotion.saveData(Wrapvar);
        Promotion.findbyaccountid(acc.id); 
        test.stopTest();
    }


    @isTest
    static void PromotionTesting2()
    {	
        Id PersonAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    	Account acc = new Account();
    	acc.RecordTypeId = PersonAccountRT;
    	acc.FirstName = 'Rajesh';
    	acc.LastName = 'testdata';
    	acc.Phone = '9898989898';
    	acc.PersonEmail = 'acc@gmail.com';
    	acc.Booking_Exists__pc = true;
    	acc.Is_Duplicate__pc = true;
        insert acc;
            
        Promotion__c promo = new Promotion__c();
        promo.name = 'Test';
        promo.Basis__c = 'percentage';
        promo.Credit__c = 100;
        promo.Usage_Type__c = 'fixed_use';
        insert promo;
        
        Promotion.wrpPromotion Wrapvar = new Promotion.wrpPromotion();
        Wrapvar.usagetype = promo.Usage_Type__c;
        Wrapvar.basis = promo.Basis__c;
        Wrapvar.timecontrained = 'Yes';
        Promotion.saveData(Wrapvar);
        Promotion.findbyaccountid(acc.id);
        promotion.findAppliesTo();
        promotion.findAllMarketingOption();
        
        
    }
    
    @isTest
    static void validatingLookupController()
    {
        LookupController.search('Account','Lastname',new List<String>{'PersonEmail=\'testdata@gmail.com\''},new List<String>{'Phone'});
        LookupController.getRecentlyViewed('Account',new List<String>{'PersonEmail=\'testdata@gmail.com\''},new List<String>{'Phone'});
    }
    
    @isTest
    static void validatingPicklistController()
    {
        PicklistSelectController.getFieldLabel('Promotion__c','Basis__c');
        PicklistSelectController.getPicklistOptions('Promotion__c','Basis__c');
    }
    
}