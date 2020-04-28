@isTest
private class VirtualTourBatchTest
{
	@isTest
	static void validateVirtualTourBatch()
	{
		City__c c = new City__c();
        c.Name = 'Seattle';
        c.State__c = 'SD';
        c.Rebooking_Price_Threshold_Below__c=5;
        c.Rebooking_Price_Threshold_Above__c=10;
        c.Checkin_Time_Cutoff__c = DateTime.now().time();
        insert c;
        
        Neighborhood__c nb = new Neighborhood__c(Name='Test NB 1', City__c = c.Id);
        insert nb;
        
        Building__c  b = new Building__c(Name='test 1',Neighborhood__c = nb.Id,City__c = 'Seattle',Same_Day_Reservation_End_Time__c = '06:00 AM');
        insert b;
        
        Unit_set__c us = new Unit_set__c(Name = 'Test US 1');
        insert us;

        Unit__c u = new Unit__c(Building__c=b.id,Name='test 1',Unit__c='1',Base_price__c=120,Beds__c='1',Unit_set__c = us.Id,
                Airbnb_listing_name__c='test', Bedrooms__c='1', Bathroom__c='1', Virtual_Tour_URL__c='https://my.matterport.com/show/?m=8ZZL2N1C6Vk',
                Airbnb_ID__c='test1', Beyond_Pricing_ID__c='test1', RU_ID__c='test1', Website_Listing_Name__c='test',Is_Virtual_Tour_URL_InCorrect__c=true
            );
        insert u;
        
		Test.setMock(HttpCalloutMock.class, new VirtualTourHTTPMockTest());

        VirtualTourBatch batchTest = new VirtualTourBatch();               
        ID batchprocessid = Database.executeBatch(batchTest);

	}

	@isTest
	static void validateVirtualTourScheduler()
	{
		City__c c = new City__c();
        c.Name = 'Seattle';
        c.State__c = 'SD';
        c.Rebooking_Price_Threshold_Below__c=5;
        c.Rebooking_Price_Threshold_Above__c=10;
        c.Checkin_Time_Cutoff__c = DateTime.now().time();
        insert c;
        
        Neighborhood__c nb = new Neighborhood__c(Name='Test NB 1', City__c = c.Id);
        insert nb;
        
        Building__c  b = new Building__c(Name='test 1',Neighborhood__c = nb.Id,City__c = 'Seattle',Same_Day_Reservation_End_Time__c = '06:00 AM');
        insert b;
        
        Unit_set__c us = new Unit_set__c(Name = 'Test US 1');
        insert us;

        Unit__c u = new Unit__c(Building__c=b.id,Name='test 1',Unit__c='1',Base_price__c=120,Beds__c='1',Unit_set__c = us.Id,
                Airbnb_listing_name__c='test', Bedrooms__c='1', Bathroom__c='1', Virtual_Tour_URL__c='https://my.matterport.com/show/?m=8ZZL2N1C6Vk',
                Airbnb_ID__c='test1', Beyond_Pricing_ID__c='test1', RU_ID__c='test1', Website_Listing_Name__c='test',Is_Virtual_Tour_URL_InCorrect__c=true
            );
        insert u;
        
		Test.setMock(HttpCalloutMock.class, new VirtualTourHTTPMockTest());

        Test.startTest();
		VirtualTourSchedule sh1 = new VirtualTourSchedule();
		String sch = '0 0 23 * * ?'; 
		system.schedule('Test Territory Check', sch, sh1); 
		Test.stopTest();

	}
}