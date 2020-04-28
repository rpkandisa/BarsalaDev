@isTest
private class Batch_populate_SharinPixImages_Unit_Test {

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
        
        Building__c  b = new Building__c(Name='test 1',Neighborhood__c = nb.Id,City__c = 'Seattle',Same_Day_Reservation_End_Time__c = '06:00 AM',Display_Name__c='b1');
        insert b;

        Building__c  b2 = new Building__c(Name='test 2',Neighborhood__c = nb.Id,City__c = 'Seattle',Same_Day_Reservation_End_Time__c = '06:00 AM',Display_Name__c='b2');
        insert b2;

        Building__c  b3 = new Building__c(Name='test 3',Neighborhood__c = nb1.Id,City__c = 'San Diego',Same_Day_Reservation_End_Time__c = '06:00 AM',Display_Name__c='b3');
        insert b3;

        Building_Unit_Set__c bus = new Building_Unit_Set__c(
        Name = 'BUS1',
        Building__c = b.Id
        );
        insert bus;
        
        Unit_set__c us = new Unit_set__c(Name = 'Test US 1');
        insert us;

        // Unit__c u = new Unit__c(Building__c=b.id,Name='test 1',Unit__c='1',Base_price__c=120,Beds__c='1',Unit_set__c = us.Id,
        //         Airbnb_listing_name__c='test', Bedrooms__c='1', Bathroom__c='1', 
        //         Airbnb_ID__c='test1', Beyond_Pricing_ID__c='test1', RU_ID__c='test1', Website_Listing_Name__c='test'
        //     );
        // insert u;

        Unit__c u = new Unit__c(
            Building__c = b.id,
            Name = 'test 1',
            Unit__c = '1',
            Base_price__c = 120,
            Beds__c = '1',
            Unit_set__c = us.Id,
            Airbnb_listing_name__c = 'test',
            Bedrooms__c = '1',
            Bathroom__c = '1',
            Airbnb_ID__c = 'test1',
            Beyond_Pricing_ID__c = 'test1',
            RU_ID__c = 'test1',
            Website_Listing_Name__c = 'test',
            Building_Unit_Set__c = bus.Id,
            Start_Date__c = system.today(),
            End_Date__c = system.today().addDays(70)
        );
        insert u;
        
        Batch_populate_SharinPixImages_ForUnit batchTest = new Batch_populate_SharinPixImages_ForUnit();               
        ID batchprocessid = Database.executeBatch(batchTest, 15);
        
        }
        }