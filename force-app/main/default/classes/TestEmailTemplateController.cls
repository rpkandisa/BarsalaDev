@isTest
private class TestEmailTemplateController {
	@TestSetup static void createTestData(){
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
                Airbnb_listing_name__c='test', Bedrooms__c='1', Bathroom__c='1', 
                Airbnb_ID__c='test1', Beyond_Pricing_ID__c='test1', RU_ID__c='test1', Website_Listing_Name__c='test'
            );
        insert u;


        list<unit_pricing__c> unitPriceList = new list<unit_pricing__c>();
        date d = date.today();
        system.debug(d);
        for(integer i =0;i<70;i++){
            unitPriceList.add(new unit_pricing__c(Unit__c = u.id, Availability_Status__c = 'Available',BP_Price_Modeled__c=120,name=string.valueOf(d)));
            system.debug('u :: '+unitPriceList[i]);
            d += 1;
        }

        insert unitPriceList;

        insert new Stripe_Setting__c(
            End_Point__c = 'www.test.com',
            Secret_Key__c = 'test',
            Dashboard_URL__c = 'www.test.com',
            Email_Addresses__c = 'test@test.com'
        );
    }

    @isTest static void TestExtensionBooking2() {
        Unit__c u = [select id,Tax_Rate__c, Base_price__c,
            (Select id,Barsala_Price_Modeled_Final__c from Unit_Prices__r where Name=:string.valueOf(system.now().addDays(3).Date()) )
             from Unit__c where Name='test 1' AND Unit__c='1' limit 1];
        
        
        Xotelia_Booking__c book1 = new Xotelia_Booking__c(Firstname__c= 'FName',Lastname__c='LName',Email__c = 'test1@gmail.com',
                Product__c=u.id,External_code__c='manual',Start_date__c=date.today(),End_date__c=date.today().addDays(65),Status__c='Active',Travelers__c=1,Sales_channel__c='expedia',
                //Stripe_Customer__c='777customers/cus_test',
                Credit_Card_Full_Name__c = 'test',
                Credit_Card_CVV__c='test',
                Credit_Card_Number__c='1112223334445443',
                Credit_Card_Expiration_Date__c='12/'+Date.today().Year(),
                Credit_Card_Type__c='VISA',
                Email_Template_Name__c = 'Barsala_Checkin_206Bell',
                Zip_Code__c='test');
        UnitBookingController.ResponseModel rm = UnitBookingController.BookUnit(book1,system.now().format('MM/dd/yyyy'),system.now().addDays(2).format('MM/dd/yyyy'), true);
        insert rm.bookings;

        EmailTemplateController.ResponseModel rm2 = EmailTemplateController.getCheckinInfo(rm.bookings[0].Id);
        system.assertEquals(rm2.isError,false);
    }
}