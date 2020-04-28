@isTest
public class UpdateUnitCountBatchTest {

    @isTest
    public static void TestExecute(){
        City__c c = new City__c();
        c.Name = 'Seattle';
        c.State__c = 'SD';
        c.Rebooking_Price_Threshold_Below__c=5;
        c.Rebooking_Price_Threshold_Above__c=10;
        c.Checkin_Time_Cutoff__c = DateTime.now().time();
        c.Tax__c = 0.21;
        insert c;
        
        
        Neighborhood__c nb = new Neighborhood__c(Name='Test NB 1', City__c = c.Id);
        insert nb;
        
       
        
        Building__c  b = new Building__c(Name='test 1',Neighborhood__c = nb.Id,City__c = 'Seattle',Same_Day_Reservation_End_Time__c = '06:00 AM');
        insert b; 
        
        Unit_set__c us = new Unit_set__c(Name = 'Test US 1');
        insert us;

        List<Unit__c> unitList = new List<Unit__c>();
        for(integer i =0;i<10;i++){
           Unit__c u = new Unit__c(Building__c=b.id,Name='test 1'+i ,Unit__c='1'+i,Base_price__c=120,Beds__c='1',Unit_set__c = us.Id,
                Airbnb_listing_name__c='test'+i, Bedrooms__c='1', Bathroom__c='1', 
                Airbnb_ID__c='test1'+i, Beyond_Pricing_ID__c='test1'+i, RU_ID__c='test1'+i, Website_Listing_Name__c='test'+i ,End_Date__c=system.today().addDays(5), Start_Date__c=system.today().addDays(-5)); 
            unitList.add(u);
        }
        insert unitList;
        
        
        Test.StartTest();

   UpdateUnitCountBatch UnitCount = new UpdateUnitCountBatch();
    Database.executeBatch(UnitCount);

   Test.StopTest();

    }
}