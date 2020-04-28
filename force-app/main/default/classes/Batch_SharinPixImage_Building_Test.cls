@isTest
private class Batch_SharinPixImage_Building_Test {

    @isTest static void createTestData(){
        City__c c = new City__c();
        c.Name = 'Seattle';
        c.State__c = 'SD';
        c.Rebooking_Price_Threshold_Below__c=5;
        c.Rebooking_Price_Threshold_Above__c=10;
        c.Checkin_Time_Cutoff__c = DateTime.now().time();
        insert c;
        
        City__c c1 = new City__c();
        c1.Name = 'San Diego';
        c1.State__c = 'SD';
        c1.Rebooking_Price_Threshold_Below__c=5;
        c1.Rebooking_Price_Threshold_Above__c=10;
        c1.Checkin_Time_Cutoff__c= DateTime.now().time();
        insert c1;
        
        Neighborhood__c nb = new Neighborhood__c(Name='Test NB 1', City__c = c.Id);
        insert nb;
        
        Neighborhood__c nb1 = new Neighborhood__c(Name='Test NB 2', City__c = c1.Id);
        insert nb1;
        
        Building__c  b = new Building__c(Name='test 1',Neighborhood__c = nb.Id,City__c = 'Seattle',Same_Day_Reservation_End_Time__c = '06:00 AM');
        insert b;

        Building__c  b2 = new Building__c(Name='test 2',Neighborhood__c = nb.Id,City__c = 'Seattle',Same_Day_Reservation_End_Time__c = '06:00 AM');
        insert b2;

        Building__c  b3 = new Building__c(Name='test 3',Neighborhood__c = nb1.Id,City__c = 'San Diego',Same_Day_Reservation_End_Time__c = '06:00 AM');
        insert b3;
       
        
        Batch_populate_SharinPixImages_Building batchTest = new Batch_populate_SharinPixImages_Building();
               
        ID batchprocessid = Database.executeBatch(batchTest, 15);
        
        }
        }