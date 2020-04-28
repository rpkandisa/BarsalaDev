@isTest
public class ArrivalInstructionController_Test {
    
    @isTest
    public static void method1(){
        
        Account ac = new Account(name ='Test Account') ;
        insert ac;
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName ='TestLName';
        con.Phone = '9874563210';
        con.Email = 'test@test.com';
        con.AccountId = ac.Id;
        con.Stripe_Customer_ID__c = 'cus_FxYpDRG0ewPEBh';
        insert con;  
        
        City__c city = new City__c();
        city.name = 'Hollywood';
        city.state__c = 'CA';
        city.Feeder_Block_Threshold__c= 0;
        city.Building_Switch_Allowed__c = 'NO';
        city.Neighborhood_Switch_Allowed__c = 'NO';
        city.Unit_Set_Switch_Allowed__c = 'NO';
        city.Checkin_Time_Cutoff__c = time.newInstance(0, 1, 1, 1);
        city.Max_Double_Booking_Switches__c = 5;
        city.Rebooking_Price_Threshold_Above__c = 0.8;
        city.Rebooking_Price_Threshold_Below__c = 1.2;
        Insert city;
        
        Neighborhood__c nb = new Neighborhood__c();
        nb.Name = 'Hollywood - Hollywood';
        nb.City__c = city.id;
        Insert nb;
        
        Building__c building = new Building__c();
        building.Name= 'New Building';
        building.Same_Day_Reservation_End_Time__c = '06:00 AM';
        building.Neighborhood__c = nb.Id;
        building.Days_Before_Booking_Available__c = 0;
        Insert building;
        
        
        Unit_set__c unitSet = new Unit_set__c();
        unitset.Name = 'Test UnitSet';
        Insert unitset;
        
        Arrival_Instructions_Template__c inst = new Arrival_Instructions_Template__c();
        inst.Name = '8665Burton Penthouse';
        inst.Building__c = building.Id;
        Insert inst;
        
        sharinpix__SharinPixImage__c spImage = new sharinpix__SharinPixImage__c();
        spImage.Checkin_Instruction_Step_Number__c = 1;
        spImage.Checkin_Instruction_Description__c = 'Test';
        spImage.Arrival_Instructions_Template__c = inst.Id;
        Insert spImage;
        
        Unit__c unit = new Unit__c();
        unit.Building__c = building.Id;
        unit.Bedrooms__c = '1';
        unit.Bed_Size__c = '2';
        unit.Bathroom__c = '2';
        unit.Beds__c = '2';
        unit.Long_Description__c = 'test';
        unit.Start_Date__c = system.today();
        unit.End_Date__c = system.today().addDays(10);
        unit.Lease_Start_Date__c = system.today();
        unit.Lease_End_Date__c = system.today().addDays(10);
        unit.Base_price__c = 500;
        unit.Min_price__c = 200;
        unit.Airbnb_listing_name__c = 'West Hollywood Condos Penthouse';
        unit.Airbnb_ID__c='test1';
        unit.Beyond_Pricing_ID__c='test1';
        unit.RU_ID__c='test1';
        unit.Website_Listing_Name__c='test';
        unit.Unit_set__c = unitset.Id;
        unit.Unit__c = 'test unit';
        unit.Arrival_Instructions_Template__c = inst.Id;
       Insert unit;
        
        Xotelia_Booking__c objbooking = new Xotelia_Booking__c();
        objbooking.Sales_channel__c = 'booking';
        objbooking.External_code__c = 'BASF80403999';
        objbooking.External_code__c = 'BASF8040999';
        objbooking.Total_taxed__c = 18.9;
        objbooking.Travelers__c = 2;
        objbooking.Firstname__c = 'Test9 ';
        objbooking.Lastname__c = 'RP109';
        objbooking.Email__c = 'rp12345@barsala.com';
        objbooking.Phone_number__c = '8989898123';
        objbooking.Start_date__c = system.now();
        objbooking.End_date__c = system.now().addDays(5);
        objbooking.Product__c = unit.id;
        objbooking.Billing_Contact__c = con.Id;
        objbooking.Discount__c = 10;
        objbooking.Sub_Total__c =  50;
        objbooking.Total_taxed__c =  2;
        objbooking.Status__c ='Active';
        objbooking.Screening_Decision__c ='Consider';
        objbooking.Elevated_Fraud_Risk__c='';
        objbooking.Private_comment__c='';
        insert objbooking;
        

        Test.startTest();
        ArrivalInstructionController.getUnitArrivalInstruction(unit.Id);
        ArrivalInstructionController.getBookingArrivalInstruction(objbooking.Id);
        Test.stopTest();
    }

}