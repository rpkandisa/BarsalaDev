@isTest
public class BookingConfirmationCodeTest {
   
   @TestSetup static void createTestData(){
        City__c c = new City__c();
        c.Name = 'Seattle';
        c.State__c = 'SD';
        c.Rebooking_Price_Threshold_Below__c=5;
        c.Rebooking_Price_Threshold_Above__c=10;
        c.Checkin_Time_Cutoff__c = DateTime.now().time();
        c.Tax__c = 0.21;
        insert c;
        
        City__c c1 = new City__c();
        c1.Name = 'San Diego';
        c1.State__c = 'SD';
        c1.Rebooking_Price_Threshold_Below__c=5;
        c1.Rebooking_Price_Threshold_Above__c=10;
        c1.Checkin_Time_Cutoff__c= DateTime.now().time();
        c1.Tax__c = 0.15;
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
        
        Unit_set__c us = new Unit_set__c(Name = 'Test US 1');
        insert us;

        Unit__c u = new Unit__c(Building__c=b.id,Name='test 1',Unit__c='1',Base_price__c=120,Beds__c='1',Unit_set__c = us.Id,
                Airbnb_listing_name__c='test', Bedrooms__c='1', Bathroom__c='1', 
                Airbnb_ID__c='test1', Beyond_Pricing_ID__c='test1', RU_ID__c='test1', Website_Listing_Name__c='test'
            );
        insert u;

        Unit__c u2 = new Unit__c(Building__c=b2.id,Name='test 2',Unit__c='2',Base_price__c=100,Beds__c='2',Unit_set__c = us.Id,
                Airbnb_listing_name__c='test2', Bedrooms__c='2', Bathroom__c='2',
                Airbnb_ID__c='test2', Beyond_Pricing_ID__c='test2', RU_ID__c='test2', Website_Listing_Name__c='test'
            );
        insert u2;

        Unit__c u3 = new Unit__c(Building__c=b3.id,Name='test 3',Unit__c='3',Base_price__c=110,Beds__c='3',Unit_set__c = us.Id,
                Airbnb_listing_name__c='test3', Bedrooms__c='2', Bathroom__c='2',
                Airbnb_ID__c='test3', Beyond_Pricing_ID__c='test3', RU_ID__c='test3', Website_Listing_Name__c='test'
            );
        insert u3;

        list<unit_pricing__c> unitPriceList = new list<unit_pricing__c>();
        date d = date.today();
        system.debug(d);
        for(integer i =0;i<70;i++){
            unitPriceList.add(new unit_pricing__c(Unit__c = u.id, Availability_Status__c = 'Available',BP_Price_Modeled__c=120,name=string.valueOf(d), UNITPRICE_DATE__c=d));
            system.debug('u :: '+unitPriceList[i]);
            d += 1;
        }

        d = date.today();
        for(integer i =0;i<70;i++){
            unitPriceList.add(new unit_pricing__c(Unit__c = u2.id, Availability_Status__c = 'Available',BP_Price_Modeled__c=120,name=string.valueOf(d), UNITPRICE_DATE__c=d));
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

        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc= new Account(
          RecordTypeID=recordTypeId ,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='test@yahoo.com',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonHomePhone='1234567',
          PersonMobilePhone='12345678' 
        ); 
        insert acc;

        Account objacc = [Select PersonContactId From Account Where Id = :acc.Id limit 1];

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
        objbooking.End_date__c = system.now().addDays(5);
        objbooking.Product__c = u.id;
        objbooking.Billing_Contact__c = objacc.PersonContactId;
        objBooking.Discount__c = 10;
        objBooking.Sub_Total__c =  50;
        objBooking.Total_taxed__c =  2;
        objBooking.Confirmation_Code__c = '';
        insert objbooking;
    }

    @isTest static void TestBookingConfirmationCode() {
        List<String> dateStr = new List<String>();
        for(Integer i=0;i<65;i++){
            dateStr.add(String.valueOf(Date.Today().addDays(i)));
        }
        Unit__c u = [select id,Tax_Rate__c, Base_price__c, Cleaning_Fee__c,
                (Select id,Barsala_Price_Modeled_Final__c from Unit_Prices__r where Name=:dateStr )
                 from Unit__c where Name='test 1' AND Unit__c='1' limit 1];
        
        Decimal grandTotal = 0;
        for(unit_pricing__c up:u.Unit_Prices__r){
            grandTotal += up.Barsala_Price_Modeled_Final__c;
        }
        if(u.Cleaning_Fee__c != null)
            grandTotal += u.Cleaning_Fee__c;

        grandTotal += (grandTotal*u.Tax_Rate__c);

        UnitBookingController.allCities();
        UnitBookingController.allUnits('Seattle',system.now().format('MM/dd/yyyy'),system.now().addDays(3).format('MM/dd/yyyy'),'2', null, false, null);
        
        test.startTest();
        String fakeBody = '{ "paid": true, "status": "succeeded", "id": "cus_CxsJgOxi7kpYIE", "object": "customer", "account_balance": 0, "created": 1527795322, "currency": null, "default_source": "card_1CXwYQKasHLvOShlYU0kNJvt", "delinquent": false, "description": "Created w/Booking Extension program", "discount": null, "email": "testnew@test.com", "invoice_prefix": "EBB1D37", "livemode": false, "metadata": {}, "shipping": null, "sources": { "object": "list", "data": [{ "id": "card_1CXwYQKasHLvOShlYU0kNJvt", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": "3333", "address_zip_check": "pass", "brand": "Visa", "country": "US", "customer": "cus_CxsJgOxi7kpYIE", "cvc_check": "pass", "dynamic_last4": null, "exp_month": 1, "exp_year": 2019, "fingerprint": "R0oPB77Gc1J1A88o", "funding": "unknown", "last4": "1111", "metadata": {}, "name": "Tarun", "tokenization_method": null }, { "id": "card_1CYB7JKasHLvOShluTNrQZDG", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": "eee3", "address_zip_check": "pass", "brand": "Visa", "country": "US", "customer": "cus_CxsJgOxi7kpYIE", "cvc_check": "pass", "dynamic_last4": null, "exp_month": 2, "exp_year": 2019, "fingerprint": "b9QkZhVd8NwlE5pp", "funding": "credit", "last4": "4242", "metadata": {}, "name": "Tarun Jain", "tokenization_method": null }], "has_more": false, "total_count": 2, "url": "/v1/customers/cus_CxsJgOxi7kpYIE/sources" }, "subscriptions": { "object": "list", "data": [], "has_more": false, "total_count": 0, "url": "/v1/customers/cus_CxsJgOxi7kpYIE/subscriptions" }, "card": { "id": "card_1AePv8KasHLvOShlwqDoNOOd", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": null, "address_zip_check": null, "brand": "Visa", "country": "US", "cvc_check": null, "dynamic_last4": null, "exp_month": 8, "exp_year": 2018, "fingerprint": "b9QkZhVd8NwlE5pp", "funding": "credit", "last4": "4242", "metadata": {}, "name": null, "tokenization_method": null }, "client_ip": null, "type": "card", "used": false }';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'ok', fakeBody, new Map<String,String>()));
        
        Xotelia_Booking__c book1 = new Xotelia_Booking__c(Firstname__c= 'FName',Lastname__c='LName',Email__c = 'test1@gmail.com',
                //Billing_Contact__c= (conModel != null ? conModel.contact.Id : null),
                Credit_Card_Full_Name__c = 'test',
                Credit_Card_CVV__c='test',
                Credit_Card_Number__c='1112223334445443',
                Credit_Card_Expiration_Date__c='12/'+Date.today().Year(),
                Credit_Card_Type__c='VISA',
                Zip_Code__c='test',
                Total_taxed__c=grandTotal,
                Product__c=u.id,External_code__c='manual',Start_date__c=date.today(),End_date__c=date.today().addDays(65),Status__c='Active',Travelers__c=1,Sales_channel__c='expedia');
        UnitBookingController.BookUnitWrapper(book1,system.now().format('MM/dd/yyyy'),system.now().addDays(65).format('MM/dd/yyyy'), 'test unit', 'newCard', '', true,'');

        List<Xotelia_Booking__c> lstBookings = new List<Xotelia_Booking__c>([select id,Confirmation_Code__c from Xotelia_Booking__c limit 1 ]);

        System.debug('@@@lstBookings@@@@ ' + lstBookings);
        BookingConfirmationCode.findUniqueConfirmationCode(lstBookings.get(0).Confirmation_Code__c);

        test.stopTest();
    }

    @isTest static void TestBookingConfirmationBatch() {
        
        
        test.startTest();
        

        List<Xotelia_Booking__c> lstBookings = new List<Xotelia_Booking__c>([select id,Confirmation_Code__c from Xotelia_Booking__c where Confirmation_Code__c != null limit 1 ]);
        Xotelia_Booking__c b = lstBookings.get(0);
        b.Confirmation_Code__c = null;
        update b;

       
        BatchToUpdateBookingConfirmation obj = new BatchToUpdateBookingConfirmation();
        DataBase.executeBatch(obj); 

        test.stopTest();
    }
}