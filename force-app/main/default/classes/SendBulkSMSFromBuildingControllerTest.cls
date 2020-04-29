@isTest
public class SendBulkSMSFromBuildingControllerTest {
    
    @isTest
    public static void testSendSMS(){
        City__c c = new City__c();
        c.Name = 'Seattle';
        c.State__c = 'SD';
        c.Rebooking_Price_Threshold_Below__c = 5;
        c.Rebooking_Price_Threshold_Above__c = 10;
        c.Checkin_Time_Cutoff__c = DateTime.now().time();
        c.Tax__c = 0.21;
        insert c;
        
        Neighborhood__c nb = new Neighborhood__c(
            Name = 'Test NB 1',
            City__c = c.Id
        );
        insert nb;
        
        Building__c b = new Building__c(
            Name = 'test 1',
            Neighborhood__c = nb.Id,
            City__c = 'Seattle',
            Same_Day_Reservation_End_Time__c = '06:00 AM',
            Display_Name__c = 'b1'
        );
        insert b;
        
        Building_Unit_Set__c bus = new Building_Unit_Set__c(
            Name = 'BUS1',
            Building__c = b.Id
        );
        insert bus;
        
        Unit_set__c us = new Unit_set__c(Name = 'Test US 1');
        insert us;
        
        Building_Unit_Set_Pricing__c busp = new Building_Unit_Set_Pricing__c();
        busp.Building_Unit_Set__c = bus.id;
        busp.Price_Date__c = system.today();
        insert busp;
        
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
        
        
        String recordTypeId = Schema.getGlobalDescribe()
            .get('Account')
            .getDescribe()
            .getRecordTypeInfosByName()
            .get('Person Account')
            .getRecordTypeId();
        Account acc = new Account(
            RecordTypeID = recordTypeId,
            FirstName = 'Test FName',
            LastName = 'Test LName',
            PersonMailingStreet = 'test@yahoo.com',
            PersonMailingPostalCode = '12345',
            PersonMailingCity = 'SFO',
            PersonEmail = 'test@yahoo.com',
            PersonHomePhone = '1234567',
            PersonMobilePhone = '12345678'
        );
        insert acc;
        
        Account objacc = [
            SELECT PersonContactId
            FROM Account
            WHERE Id = :acc.Id
            LIMIT 1
        ];
        Contact objcon = [
            SELECT Id
            FROM Contact
            WHERE AccountId = :acc.Id
            LIMIT 1
        ];
        
        Xotelia_Booking__c objbooking = new Xotelia_Booking__c();
        objbooking.Sales_channel__c = 'manual';
        objbooking.External_code__c = 'BASF80403399';
        objbooking.External_code__c = 'BASF804033';
        objbooking.Total_taxed__c = 183.33;
        objbooking.Travelers__c = 1;
        objbooking.Firstname__c = 'Test';
        objbooking.Lastname__c = 'RP100';
        objbooking.Email__c = 'testrp@barsala.com';
        objbooking.Phone_number__c = '9898989898';
        objbooking.Start_date__c = system.now().addDays(-5);
        objbooking.End_date__c = system.now().addDays(10);
        objbooking.Product__c = u.id;
        objbooking.Billing_Contact__c = objacc.PersonContactId;
        objBooking.Discount__c = 10;
        objBooking.Sub_Total__c = 50;
        objBooking.Total_taxed__c = 2; 
        objBooking.Guest_Contact__c = objcon.id;
        objBooking.Billing_Contact__c = objcon.id;
        objBooking.Status__c = 'Active';
        insert objbooking;
        
        system.debug('b.Id :'+b.Id);
         PageReference pageRef = Page.SendBulkSMSFromBuilding;
        pageRef.getParameters().put('Id', b.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(b);
        SendBulkSMSFromBuildingController sendSMS = new SendBulkSMSFromBuildingController(sc);
        
        sendSMS.selectedContacts();
       
        
    }
}