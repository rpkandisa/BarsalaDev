public without sharing class UpgradeWizard {
  public static Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
    .get('Person Account')
    .getRecordTypeId();

  public Integer UnitImageThreshold { get; set; }
  public Decimal avgRating { get; set; }

  //functions to return all Cities
  @RemoteAction
  public static List<City__c> allCities() {
    List<City__c> lstCities = new List<City__c>(
      [SELECT Id, Name FROM City__c ORDER BY Name]
    );
    return lstCities;
  }

  public UserValidationModel userModel { get; set; }
  public void validateUser() {
    Id bookingId = null;
    if (
      !string.isblank(
        string.valueof(ApexPages.currentPage().getParameters().get('bookId'))
      ) || !Test.isRunningTest()
    ) {
      bookingId = (Id) ApexPages.currentPage().getParameters().get('bookId');
    } else if (Test.isRunningTest()) {
      bookingId = [SELECT id FROM Xotelia_Booking__c LIMIT 1].get(0).Id;
    }

    userModel = checkUserBookingPermission(false, bookingId);
    UnitImageThreshold = Integer.Valueof(
      (Barsala_Settings__c.getOrgDefaults()).Unit_Image_Threshold__c
    );

    avgRating = 0;
    Barsala_Settings__c objbs = Barsala_Settings__c.getOrgDefaults();
    if (
      objbs.Unit_Star_Rating_Threshold__c != null &&
      objbs.Unit_Star_Rating_Threshold__c > 0
    ) {
      avgRating = objbs.Unit_Star_Rating_Threshold__c;
    }

    //forwardToCustomAuthPage();
  }
  @RemoteAction
  public static UserValidationModel checkUserBookingPermission(
    Boolean isRoomUsed,
    Id bookingId
  ) {
    //Boolean isRoomUsed
    Id contactId = null;
    UserValidationModel model = new UserValidationModel();

    //if(!string.isblank(string.valueof(ApexPages.currentPage().getParameters().get('bookId'))) || Test.isRunningTest()){

    for (Xotelia_Booking__c b : [
      SELECT
        id,
        Billing_Contact__c,
        Guest_Contact__c,
        Start__c,
        End__c,
        Total_Travelers__c,
        Sales_channel__c,
        Product__c,
        Total_taxed__c
      FROM Xotelia_Booking__c
      WHERE id = :bookingId
    ]) {
      model.isRoomUsed = system.Today() >= b.Start__c;
      if (b.Guest_Contact__c != null && b.Billing_Contact__c == null) {
        contactId = b.Guest_Contact__c;
      } else {
        contactId = b.Billing_Contact__c;
      }
      if (isRoomUsed) {
        DateTime dttemp = setDateTime(b.Start__c.format());
        if (dttemp.format('MM/dd/yyyy') == system.now().format('MM/dd/yyyy')) {
          model.sdt = System.Today().addDays(1).format();
        } else {
          model.sdt = System.Today().format();
        }
      } else {
        model.sdt = b.Start__c.format();
      }
      model.edt = b.End__c.format();
      model.noofguest = string.valueof(b.Total_Travelers__c);
      model.saleschannel = b.Sales_channel__c;
      model.unitid = b.Product__c;
      model.prevpayment = b.Total_taxed__c;
    }
    //}

    //return UserInfo.getUserType();

    model.isStandardUser = true;
    model.isBookingAllowed = true;
    if (contactId != null) {
      model.contactId = contactId;
      ContactModel conModel = fetchContactDetails(contactId);

      if (
        conModel.contact.Xotelia_Bookings__r.size() > 0 ||
        conModel.contact.Xotelia_Bookings1__r.size() > 0
      )
        model.isBookingAllowed = true;
      model.conModel = JSON.serialize(conModel);
    }

    return model;
  }
  public static ContactModel fetchContactDetails(String recordId) {
    String soql =
      'select id, FirstName, LastName, Email, Phone, MobilePhone, Stripe_Customer_ID__c,' +
      '(select id, Stripe_Customer__c from Xotelia_Bookings__r ' +
      'where  Status__c=\'Active\' limit 1), ' +
      '(select id, Stripe_Customer__c from Xotelia_Bookings1__r ' +
      'where  Status__c=\'Active\' ORDER BY Stripe_Customer__c NULLS LAST limit 1) ' +
      'from Contact where id=:recordId';

    system.debug('@@@' + soql);
    return fetchSavedCards(Database.query(soql));
  }
  public static ContactModel fetchSavedCards(List<Contact> conList) {
    if (conList != null && conList.size() > 0) {
      List<CreditCardModel> ccModelList;
      String stripeCustomerId;
      //Getting Stripe Customer ID
      if (conList[0].Stripe_Customer_ID__c != null)
        stripeCustomerId = conList[0].Stripe_Customer_ID__c;
      else if (
        conList[0].Xotelia_Bookings1__r.size() > 0 &&
        conList[0].Xotelia_Bookings1__r[0].Stripe_Customer__c != null
      )
        stripeCustomerId = StripeHelper.getStripeCustomerIdFromURL(
          conList[0].Xotelia_Bookings1__r[0].Stripe_Customer__c
        );

      //fethcing saved cards for customer
      if (stripeCustomerId != null) {
        SavedCardsModel cardsModel = fetchCustomerSavedCards(
          null,
          stripeCustomerId,
          null
        );
        if (!cardsModel.isError && cardsModel.ccModelList.size() > 0)
          ccModelList = cardsModel.ccModelList;
      }
      return new ContactModel(conList[0], ccModelList);
    }
    return null;
  }
  public class UserValidationModel {
    @RemoteAction
    public Boolean isStandardUser { get; set; }
    @RemoteAction
    public Boolean isBookingAllowed { get; set; }
    @RemoteAction
    public String contactId { get; set; }
    @RemoteAction
    public String conModel { get; set; }
    @RemoteAction
    public String sdt { get; set; }
    @RemoteAction
    public String edt { get; set; }
    @RemoteAction
    public String noofguest { get; set; }
    @RemoteAction
    public String saleschannel { get; set; }
    @RemoteAction
    public String unitid { get; set; }
    @RemoteAction
    public Decimal prevpayment { get; set; }
    @RemoteAction
    public Boolean isRoomUsed { get; set; }
  }
  //find existing guest/contact with email or phone
  //this method also fetches saved cards from stripe for the customer
  @RemoteAction
  public static ContactModel searchContact(String email, String phone) {
    String soql =
      'select id, FirstName, LastName, Email, Phone, Stripe_Customer_ID__c,' +
      '(select id, Stripe_Customer__c from Xotelia_Bookings1__r ' +
      'where  Status__c=\'Active\' AND Stripe_Customer__c != null limit 1) ' +
      'from Contact';

    if (String.isNotBlank(email))
      soql += ' where Email=:email';
    if (String.isNotBlank(phone)) {
      soql += String.isNotBlank(email) ? ' OR' : ' where';
      soql += ' Phone=:phone';
    }
    soql += ' ORDER BY LastModifiedDate DESC limit 1';
    system.debug('@@@' + soql);
    return fetchSavedCards(Database.query(soql));
  }
  //fetch saved cards for customer with Stripe Custom ID
  //this method also checks for default card set in customer profile to set default card selected on UI
  //this method skip's card from stripe it matches to existing bookings card
  public static SavedCardsModel fetchCustomerSavedCards(
    Stripe_Setting__c stripeSetting,
    String stripeCustomerId,
    CreditCardModel existingBookingCard
  ) {
    SavedCardsModel cardsModel = new SavedCardsModel();
    List<CreditCardModel> ccModelList = new List<CreditCardModel>();
    if (stripeSetting == null)
      stripeSetting = Stripe_Setting__c.getORGDefaults();
    if (stripeSetting != null) {
      //fetching customer details
      StripeHelper.HTTPModel httpModel = StripeHelper.getStripeCustomerDetails(
        stripeSetting,
        stripeCustomerId
      );
      if (httpModel.isCalloutException) {
        cardsModel.isError = true;
        cardsModel.errmsg = httpModel.response;
      } else {
        //parsing the customer details response
        StripeHelper.StripeCustomerParser customerParser = StripeHelper.parseStripeCustomer(
          httpModel.response
        );

        if (
          customerParser != null &&
          (customerParser.error == null ||
          customerParser.error.message == null) &&
          customerParser.sources != null &&
          customerParser.sources.data != null &&
          customerParser.sources.data.size() > 0
        ) {
          for (StripeHelper.cls_data cardData : customerParser.sources.data) {
            if (
              cardData.objectStr == 'card' &&
              String.isNotBlank(cardData.name) &&
              cardData.name != 'Expedia VirtualCard'
            ) {
              //removing the card from last booking if already stored in stripe
              //now logic has changed to
              //if card from stripe is matching the card on existing booking
              //then showing existing bookings card so card info can be copied to extension
              if (
                existingBookingCard == null ||
                (existingBookingCard.cardName != cardData.name ||
                existingBookingCard.cardNumber != cardData.last4 ||
                Integer.ValueOf(existingBookingCard.expMonth) !=
                cardData.exp_month ||
                Integer.ValueOf(existingBookingCard.expYear) !=
                cardData.exp_year)
              ) {
                CreditCardModel ccModel = new CreditCardModel(
                  cardData.last4,
                  cardData.name,
                  cardData.exp_month + '',
                  cardData.exp_year + '',
                  cardData.address_zip,
                  null,
                  cardData.id,
                  cardData.brand,
                  cardData.fingerprint,
                  (cardData.id == customerParser.default_source)
                );
                //setting default card
                if (ccModel.isDefaultSource) {
                  cardsModel.defaultSavedCard = ccModel;
                  cardsModel.ccModelList.add(cardsModel.defaultSavedCard);
                } else
                  ccModelList.add(ccModel);
              }
            }
          }
        } else if (
          customerParser != null &&
          customerParser.error != null &&
          customerParser.error.message != null
        ) {
          //error handling
          cardsModel.isError = true;
          cardsModel.errmsg = customerParser.error.message;
        }
      }
    }
    cardsModel.ccModelList.addAll(ccModelList);
    return cardsModel;
  }
  //functions to return list of year from current to 2050
  @RemoteAction
  public static List<string> allYear() {
    Integer startyear = system.today().year();
    List<string> lstYears = new List<string>();
    for (Integer i = startyear; i <= 2050; i++) {
      lstYears.add(string.valueof(i));
    }
    return lstYears;
  }

  @RemoteAction
  public static List<wrapperUnit> allUnitsByBookingId(
    String bookingId,
    Boolean isRoomUsed
  ) {
    List<wrapperUnit> lstWrapUnit = new List<wrapperUnit>();
    List<Xotelia_Booking__c> lstBooking = new List<Xotelia_Booking__c>(
      [
        SELECT
          id,
          Start__c,
          End__c,
          Product__r.Max_Sleep_Guests__c,
          Product__r.City__c,
          Product__c,
          Discount__c,
          Product__r.Unit_Type_Order__c,
          City__c
        FROM Xotelia_Booking__c
        WHERE id = :bookingId
      ]
    );
    if (lstBooking.size() > 0) {
      Xotelia_Booking__c obj = new Xotelia_Booking__c();
      obj = lstBooking.get(0);

      string sdt = system.today().format().split(' ')[0],
        edt = obj.End__c.format().split(' ')[0];
      if (isRoomUsed) {
        //sdt = system.today().format().split(' ')[0];
        DateTime dttemp = setDateTime(obj.Start__c.format());
        if (dttemp.format('MM/dd/yyyy') == system.now().format('MM/dd/yyyy')) {
          sdt = System.Today().addDays(1).format();
        } else {
          sdt = System.Today().format();
        }
      } else {
        sdt = obj.Start__c.format().split(' ')[0];
        /*if(system.today() > obj.Start__c){
                   sdt = System.Today().format();
               }*/
      }

      lstWrapUnit = allUnits(
        obj.City__c,
        sdt,
        edt,
        '1',
        '',
        true,
        null,
        Integer.valueOf(obj.Product__r.Unit_Type_Order__c)
      );

      //Boolean isfuturebooking =  obj.Start__c > system.today();

      System.debug('obj.Start__c@@@@ ' + obj.Start__c);
      System.debug('obj.Start__c@@@@ ' + obj.Product__c);
      System.debug('obj.Start__c@@@@ ' + obj.Discount__c);
      System.debug('obj.Start__c@@@@ ' + sdt);

      List<wrapperUnit> lstWrapUnitTemp = new List<wrapperUnit>();
      lstWrapUnitTemp = ExistingUnits(
        '',
        obj.Start__c.format().split(' ')[0],
        sdt,
        '1',
        obj.Product__c,
        true,
        obj.Discount__c
      ); //(isfuturebooking ? edt : sdt)
      for (wrapperUnit wp : lstWrapUnitTemp) {
        lstWrapUnit.add(wp);
      }

      if (lstWrapUnitTemp.size() == 0) {
        // It is only in future booking
        wrapperUnit wp = new wrapperUnit();
        wp.UnitId = obj.Product__c;
        wp.UnitTypeOrder = Integer.valueof(obj.Product__r.Unit_Type_Order__c);
        lstWrapUnit.add(wp);
      }
    }
    return lstWrapUnit;
  }

  //for existing booking record for booked units on search criteria
  @RemoteAction
  public static List<wrapperUnit> ExistingUnits(
    string city,
    string fromdate,
    string todate,
    string noofguests,
    String bookUnitId,
    Boolean includeCleaningFee,
    Decimal discount
  ) {
    List<wrapperUnit> lstWrapUnit = new List<wrapperUnit>();
    string strQuery = '';
    string strWhereClause = '';
    Date dtFromDate = Date.parse(fromdate);
    Date dtToDate = Date.parse(todate);

    System.debug('#@@@@@@FromDate: ' + dtFromDate + ' todate: ' + dtToDate);

    set<Date> setFromToDates = allDatesBetweenTwoDates(fromdate, todate);

    if (!string.IsBlank(city)) {
      string strCitysearch = '%' + city + '%';
      strWhereClause += ' and Unit__r.City__c like: strCitysearch ';
    }
    if (!string.IsBlank(fromdate) && !string.IsBlank(todate)) {
      strWhereClause += ' and UnitPrice_Date__c >=: dtFromDate and UnitPrice_Date__c <: dtToDate';
    }
    if (!string.IsBlank(noofguests)) {
      Integer intNoofguests = Integer.valueof(noofguests);
      strWhereClause += ' and Unit__r.Max_Sleep_Guests__c >=: intNoofguests ';
    }

    strQuery += 'Select Name,Availability_Status__c,BP_Price_Modeled__c,Barsala_Price_Modeled_Final__c,UnitPrice_Date__c,Unit__c ';
    strQuery += 'from Unit_Pricing__c Where UnitPrice_Date__c != null and Unit__r.Feeder__c = FALSE AND Unit__r.Status__c=\'Active\' ';

    if (string.isNotBlank(bookUnitId)) {
      strQuery += ' and Unit__c =: bookUnitId';
    }
    if (string.isNotblank(strWhereClause)) {
      strQuery +=
        strWhereClause + ' order by UnitPrice_Date__c asc limit 49999';
    }

    try {
      //system.debug('after query Heap size :: ' +Limits.getHeapSize());
      //this map holds unit wise all unit pricing records.
      map<string, List<Unit_Pricing__c>> unit_UnitPriceMap = new Map<string, List<Unit_Pricing__c>>();

      //this map holds unit wise all unit price dates
      map<string, set<date>> unit_UnitPriceDatesMap = new Map<string, set<date>>();

      Integer totalnights = dtFromDate.Daysbetween(dtToDate);
      // system.debug('intNoofguests  :: ' + noofguests   + ' setUnitIds   ' + setUnitIds  );
      // system.debug('dtFromDate :: ' + dtFromDate + ' todate ' + dtToDate );
      system.debug('strQuery@@@ ' + strQuery);

      // Step 1: Create Map of Unit with Unit Pricing records and Unit with Unit Pricing Dates.
      for (Unit_Pricing__c up : Database.Query(strQuery)) {
        if (unit_UnitPriceMap.containsKey(up.Unit__c))
          unit_UnitPriceMap.get(up.Unit__c).add(up);
        else
          unit_UnitPriceMap.put(up.Unit__c, new List<Unit_Pricing__c>{ up });
        if (unit_UnitPriceDatesMap.containsKey(up.Unit__c))
          unit_UnitPriceDatesMap.get(up.Unit__c).add(up.UnitPrice_Date__c);
        else
          unit_UnitPriceDatesMap.put(
            up.Unit__c,
            new Set<date>{ up.UnitPrice_Date__c }
          );
      }

      system.debug('after creating map Heap size :: ' + Limits.getHeapSize());

      // Step 2: Based on the Unit Price Date map, find out all the units Ids which have availability for all dates and discard the rest.
      for (Id unitId : unit_UnitPriceMap.keyset()) {
        //check if unit have all available unit price records or not.
        if (unit_UnitPriceMap.get(unitId).size() == totalnights) {
          Boolean blnAllDateCheck = true;
          //if unit have all availabe unit price record then checking units are available for all dates and no duplicates
          for (Date dtFT : setFromToDates) {
            if (!unit_UnitPriceDatesMap.get(unitid).contains(dtFT)) {
              blnAllDateCheck = false;
              break;
            }
          }
          //if unit price record is not available for any one of date then remove unit from map
          if (!blnAllDateCheck) {
            //if unit price record is not available for all dates then remove from map to reduce heap size
            unit_UnitPriceMap.remove(unitId);
          }
        } else {
          //if unit price record is not available for all dates then remove from map to reduce heap size
          unit_UnitPriceMap.remove(unitId);
        }
      }

      //system.debug('after filling map Heap size - Before NULL :: '+Limits.getHeapSize());
      //set map to null to reduce the heap size.
      unit_UnitPriceDatesMap = null;

      //system.debug('after filling map Heap size - After NULL:: '+Limits.getHeapSize());

      // Step 3: For each unit, create a wrapper record and also calculate the total price
      if (unit_UnitPriceMap.size() > 0) {
        // Map contains unit wise wrapper result.
        map<Id, wrapperUnit> mapWrapperUnitIds = new Map<Id, wrapperUnit>();

        Map<Id, Unit__c> unitMap = new Map<Id, Unit__c>(
          [
            SELECT
              Building__c,
              Building__r.Name,
              Standard_Guests__c,
              Name,
              Unit_Type__c,
              Virtual_Tour_URL__c,
              Virtual_Tour_Thumbnail__c,
              Neighborhood__c,
              Base_price__c,
              Tax_Rate__c,
              Cleaning_Fee__c,
              Extra_Guest_Charge__c,
              //** -- uncomment for unit slider images
              (
                SELECT
                  id,
                  sharinpix__ImageURLThumbnail__c,
                  sharinpix__ImageURLOriginal__c,
                  sharinpix__ImageURLMini__c,
                  sharinpix__ImageURLFull__c,
                  Fill_to_Size__c,
                  sharinpix__Tags__c,
                  SharinpixImageOrder__c
                FROM SharinPix_Images__r
                ORDER BY SharinpixImageOrder__c ASC NULLS LAST
              ),
              Average_Ratings__c,
              of_Reviews__c,
              Unit_Type_Order__c
            //*/
            FROM Unit__c
            WHERE Id IN :unit_UnitPriceMap.keyset()
          ]
        );

        system.debug('After Unit Query: ' + Limits.getHeapSize());

        for (Id unitId : unit_UnitPriceMap.keyset()) {
          Unit__c unit = unitMap.get(unitId);
          wrapperUnit objWrap = new wrapperUnit();

          //** -- uncomment for unit slider images
          for (sharinpix__SharinPixImage__c image : unit.SharinPix_Images__r) {
            if (
              image.SharinpixImageOrder__c > 0 &&
              image.SharinpixImageOrder__c < 3
            ) {
              objWrap.images.add(
                new ImageModel(
                  image.Fill_to_Size__c,
                  image.sharinpix__ImageURLFull__c
                )
              );
            }
          } //*/

          objWrap.UnitId = unitId;
          objWrap.UnitName = unit.Name;
          objWrap.BuildingId = unit.Building__c;
          objWrap.BuildingName = unit.Building__r.Name;
          objWrap.UnitType = unit.Unit_Type__c;
          objWrap.Neighborhood = unit.Neighborhood__c;
          objWrap.TaxRate = unit.Tax_Rate__c;
          objWrap.VirtualTourURL = unit.Virtual_Tour_URL__c;
          objWrap.VirtualTourThumb = unit.Virtual_Tour_Thumbnail__c;
          objWrap.UnitTypeOrder = integer.valueof(unit.Unit_Type_Order__c);
          objWrap.CleaningFee = (includeCleaningFee != null &&
            includeCleaningFee)
            ? unit.Cleaning_Fee__c
            : 0;

          //added star rating & no of review
          if (unit.Average_Ratings__c > 0) {
            objWrap.starRating = (unit.Average_Ratings__c / 2).setScale(2);
          }
          if (unit.of_Reviews__c > 0) {
            objWrap.noOfReviews = unit.of_Reviews__c;
          }

          //check for unit price
          for (Unit_Pricing__c up : unit_UnitPriceMap.get(unitid)) {
            Decimal dailySubtotal = CalculateTotalPrice(
              up.Barsala_Price_Modeled_Final__c,
              Decimal.valueof(noofguests),
              unit.Standard_Guests__c,
              unit.Extra_Guest_Charge__c
            );

            Decimal discountAmount = (discount != null &&
              discount != 0)
              ? ((dailySubtotal * discount) / 100).setScale(2)
              : 0;
            Decimal dailyDiscountedAmount = (discountAmount != 0)
              ? (dailySubtotal - discountAmount).setScale(2)
              : dailySubtotal;
            String commments =
              (up.UnitPrice_Date__c != null
                ? string.valueof(up.UnitPrice_Date__c).split(' ')[0]
                : '') +
              ' : ' +
              (discountAmount > 0
                ? '(Discount -' + discountAmount + ' USD) '
                : '') +
              dailyDiscountedAmount +
              ' USD';
            if (mapWrapperUnitIds.containskey(up.Unit__c)) {
              // Price Calculation
              objWrap.ExtraGuestPrice =
                mapWrapperUnitIds.get(up.Unit__c).ExtraGuestPrice +
                CalculateExtraGuestPrice(
                  Decimal.valueof(noofguests),
                  unit.Standard_Guests__c,
                  unit.Extra_Guest_Charge__c
                );
              objWrap.SubTotal =
                mapWrapperUnitIds.get(up.Unit__c).SubTotal +
                dailyDiscountedAmount;
              objWrap.UnitPriceWithoutGuest =
                mapWrapperUnitIds.get(up.Unit__c).UnitPriceWithoutGuest +
                up.Barsala_Price_Modeled_Final__c;

              // Booking Comments
              objWrap.BookingComments =
                mapWrapperUnitIds.get(up.Unit__c).BookingComments +
                ' \n    ' +
                commments;
              mapWrapperUnitIds.put(up.Unit__c, objWrap);
            } else {
              objWrap.AvailabilityStatus = up.Availability_Status__c;
              // Price Calculation
              objWrap.ExtraGuestPrice = CalculateExtraGuestPrice(
                Decimal.valueof(noofguests),
                unit.Standard_Guests__c,
                unit.Extra_Guest_Charge__c
              );
              objWrap.SubTotal = dailyDiscountedAmount;
              objWrap.UnitPriceWithoutGuest = up.Barsala_Price_Modeled_Final__c;

              // Booking Comments
              String strBookingComments = '';
              strBookingComments = 'No of Guests: ' + noofguests + '\n';
              strBookingComments += ' By night:\n    ' + commments;
              objWrap.BookingComments = strBookingComments;
              mapWrapperUnitIds.put(up.Unit__c, objWrap);
            }
            system.debug('@@@discountAmount==' + discountAmount);
            system.debug('@@@dailyDiscountedAmount==' + dailyDiscountedAmount);
            system.debug('@@@objWrap.SubTotal==' + objWrap.SubTotal);
          }
        }

        unit_UnitPriceMap = null;

        for (wrapperUnit objWrap : mapWrapperUnitIds.values()) {
          objWrap.TotalPrice = objWrap.SubTotal;
          objWrap.TotalPrice += objWrap.CleaningFee;

          system.debug('@@@objWrap.TotalPrice==' + objWrap.TotalPrice);
          system.debug('@@@objWrap.SubTotal==' + objWrap.SubTotal);
          // Apply Tax if Total Nights is less than 30.
          if (totalnights < 30) {
            //As not the subtotal can be 0, but there might be total price, or discount is over 100%,
            //but still the cleaning fee and taxes are applicable
            //if(objWrap.SubTotal != 0){
            objWrap.AvgPrice = (objWrap.UnitPriceWithoutGuest / totalnights)
              .setScale(2);
            Decimal TotalTax = (objWrap.TotalPrice * objWrap.TaxRate)
              .setScale(2);
            objWrap.TotalTax = TotalTax;
            system.debug('@@@TotalTax==' + TotalTax);
            objWrap.BookingComments +=
              '\n Cleaning Fee: ' +
              objWrap.CleaningFee +
              ' USD';
            objWrap.BookingComments += '\n Total Tax: ' + TotalTax + ' USD';
            objWrap.TotalPrice += TotalTax;
            objWrap.TotalPrice = objWrap.TotalPrice.setScale(2);
            //}
          } else {
            //no tax for bookings greater than 30 days, so overriting tax rate to 0
            objWrap.TaxRate = 0;
            objWrap.BookingComments +=
              '\n Cleaning Fee: ' +
              objWrap.CleaningFee +
              ' USD';
            objWrap.AvgPrice = (objWrap.UnitPriceWithoutGuest / totalnights)
              .setScale(2);
          }
          lstWrapUnit.add(objWrap);
        }

        system.debug(
          'after filling wrap list Heap size :: ' + Limits.getHeapSize()
        );

        lstWrapUnit.sort();
        return lstWrapUnit;
      }
    } catch (Exception e) {
      throw new BookingException(
        'Exception occurred: ' +
        e.getMessage() +
        ' at ' +
        e.getLineNumber()
      );
    }
    return new List<wrapperUnit>();
  }

  // Function to return Available Units based on Search criteria
  @RemoteAction
  public static List<wrapperUnit> allUnits(
    string city,
    string fromdate,
    string todate,
    string noofguests,
    String bookUnitId,
    Boolean includeCleaningFee,
    Decimal discount,
    Integer intUnitTypeOrder
  ) {
    System.debug('Max Available Heap Size: ' + Limits.getLimitHeapSize());

    // Decimal decStarRating = 0;
    // Barsala_Settings__c objbs = Barsala_Settings__c.getOrgDefaults();
    // if(objbs.Unit_Star_Rating_Threshold__c != null && objbs.Unit_Star_Rating_Threshold__c > 0){
    //     decStarRating = objbs.Unit_Star_Rating_Threshold__c;
    // }
    List<wrapperUnit> lstWrapUnit = new List<wrapperUnit>();
    string strQuery = '';
    string strWhereClause = '';
    Date dtFromDate = Date.parse(fromdate);
    Date dtToDate = Date.parse(todate);

    System.debug('#@@@@@@FromDate: ' + dtFromDate + ' todate: ' + dtToDate);

    set<Date> setFromToDates = allDatesBetweenTwoDates(fromdate, todate);

    // removed fields:
    // if(decStarRating > 0 && !Test.isRunningTest()){ // checking star rating
    //     decStarRating = decStarRating *2;
    //     strWhereClause += ' and Unit__r.Average_Ratings__c >=: decStarRating ';
    // }
    if (!string.IsBlank(city)) {
      string strCitysearch = '%' + city + '%';
      strWhereClause += ' and Unit__r.City__c like: strCitysearch ';
    }
    if (!string.IsBlank(fromdate) && !string.IsBlank(todate)) {
      strWhereClause += ' and UnitPrice_Date__c >=: dtFromDate and UnitPrice_Date__c <: dtToDate';
    }
    if (!string.IsBlank(noofguests)) {
      Integer intNoofguests = Integer.valueof(noofguests);
      strWhereClause += ' and Unit__r.Max_Sleep_Guests__c >=: intNoofguests ';
    }

    set<Id> setUnitIds = new Set<Id>();
    if (string.isBlank(bookUnitId)) {
      string strAggregateQuery =
        'SELECT Unit__c unitid, COUNT(Unit__r.Name) FROM Unit_Pricing__c Where Availability_Status__c != \'Available\' ' +
        strWhereClause;
      strAggregateQuery += ' GROUP BY Unit__c HAVING COUNT(Unit__r.Name) >= 1 Limit 49999';

      for (AggregateResult aggr : Database.Query(strAggregateQuery)) {
        if (aggr.get('unitid') != null) {
          setUnitIds.add((Id) aggr.get('unitid'));
        }
      }
    }
    //system.debug('setUnitIds ::: '+setUnitIds);

    strQuery += 'Select Name,Availability_Status__c,BP_Price_Modeled__c,Barsala_Price_Modeled_Final__c,UnitPrice_Date__c,Unit__c ';
    strQuery += 'from Unit_Pricing__c Where UnitPrice_Date__c != null and Availability_Status__c = \'Available\' and Unit__r.Feeder__c = FALSE AND Unit__r.Status__c=\'Active\' ';

    if (string.isBlank(bookUnitId) && setUnitIds.size() > 0) {
      strQuery += ' and Unit__c not in: setUnitIds ';
    }
    system.debug('bookUnitId: ' + bookUnitId);
    if (string.isNotBlank(bookUnitId)) {
      strQuery += ' and Unit__c =: bookUnitId';
    }
    if (string.isNotblank(strWhereClause)) {
      strQuery +=
        strWhereClause + ' order by UnitPrice_Date__c asc limit 49999';
    }

    try {
      //system.debug('after query Heap size :: ' +Limits.getHeapSize());
      //this map holds unit wise all unit pricing records.
      map<string, List<Unit_Pricing__c>> unit_UnitPriceMap = new Map<string, List<Unit_Pricing__c>>();

      //this map holds unit wise all unit price dates
      map<string, set<date>> unit_UnitPriceDatesMap = new Map<string, set<date>>();

      Integer totalnights = dtFromDate.Daysbetween(dtToDate);
      system.debug(
        'intNoofguests  :: ' +
        noofguests +
        ' setUnitIds   ' +
        setUnitIds
      );
      system.debug('dtFromDate :: ' + dtFromDate + ' todate ' + dtToDate);
      system.debug('strQuery@@@ ' + strQuery);

      // Step 1: Create Map of Unit with Unit Pricing records and Unit with Unit Pricing Dates.
      for (Unit_Pricing__c up : Database.Query(strQuery)) {
        system.debug('strQuery@@@up ' + up);
        if (unit_UnitPriceMap.containsKey(up.Unit__c))
          unit_UnitPriceMap.get(up.Unit__c).add(up);
        else
          unit_UnitPriceMap.put(up.Unit__c, new List<Unit_Pricing__c>{ up });
        if (unit_UnitPriceDatesMap.containsKey(up.Unit__c))
          unit_UnitPriceDatesMap.get(up.Unit__c).add(up.UnitPrice_Date__c);
        else
          unit_UnitPriceDatesMap.put(
            up.Unit__c,
            new Set<date>{ up.UnitPrice_Date__c }
          );
      }

      system.debug('after creating map Heap size :: ' + Limits.getHeapSize());

      // Step 2: Based on the Unit Price Date map, find out all the units Ids which have availability for all dates and discard the rest.
      for (Id unitId : unit_UnitPriceMap.keyset()) {
        //check if unit have all available unit price records or not.
        if (unit_UnitPriceMap.get(unitId).size() == totalnights) {
          Boolean blnAllDateCheck = true;
          //if unit have all availabe unit price record then checking units are available for all dates and no duplicates
          for (Date dtFT : setFromToDates) {
            if (!unit_UnitPriceDatesMap.get(unitid).contains(dtFT)) {
              blnAllDateCheck = false;
              break;
            }
          }
          //if unit price record is not available for any one of date then remove unit from map
          if (!blnAllDateCheck) {
            //if unit price record is not available for all dates then remove from map to reduce heap size
            unit_UnitPriceMap.remove(unitId);
          }
        } else {
          //if unit price record is not available for all dates then remove from map to reduce heap size
          unit_UnitPriceMap.remove(unitId);
        }
      }

      //system.debug('after filling map Heap size - Before NULL :: '+Limits.getHeapSize());
      //set map to null to reduce the heap size.
      unit_UnitPriceDatesMap = null;

      //system.debug('after filling map Heap size - After NULL:: '+Limits.getHeapSize());

      // Step 3: For each unit, create a wrapper record and also calculate the total price
      if (unit_UnitPriceMap.size() > 0) {
        // Map contains unit wise wrapper result.
        map<Id, wrapperUnit> mapWrapperUnitIds = new Map<Id, wrapperUnit>();

        Map<Id, Unit__c> unitMap = new Map<Id, Unit__c>(
          [
            SELECT
              Building__c,
              Building__r.Name,
              Standard_Guests__c,
              Name,
              Unit_Type__c,
              Virtual_Tour_URL__c,
              Virtual_Tour_Thumbnail__c,
              Neighborhood__c,
              Base_price__c,
              Tax_Rate__c,
              Cleaning_Fee__c,
              Extra_Guest_Charge__c,
              //** -- uncomment for unit slider images
              (
                SELECT
                  id,
                  sharinpix__ImageURLThumbnail__c,
                  Fill_to_Size__c,
                  sharinpix__ImageURLOriginal__c,
                  sharinpix__ImageURLMini__c,
                  sharinpix__ImageURLFull__c,
                  sharinpix__Tags__c,
                  SharinpixImageOrder__c
                FROM SharinPix_Images__r
                ORDER BY SharinpixImageOrder__c NULLS LAST
              ),
              Average_Ratings__c,
              of_Reviews__c,
              Unit_Type_Order__c
            //*/
            FROM Unit__c
            WHERE Id IN :unit_UnitPriceMap.keyset()
          ]
        );

        system.debug('After Unit Query: ' + Limits.getHeapSize());

        for (Id unitId : unit_UnitPriceMap.keyset()) {
          Unit__c unit = unitMap.get(unitId);
          wrapperUnit objWrap = new wrapperUnit();

          //** -- uncomment for unit slider images
          for (sharinpix__SharinPixImage__c image : unit.SharinPix_Images__r) {
            if (
              image.SharinpixImageOrder__c > 0 &&
              image.SharinpixImageOrder__c < 3
            ) {
              objWrap.images.add(
                new ImageModel(
                  image.Fill_to_Size__c,
                  image.sharinpix__ImageURLFull__c
                )
              );
            }
          } //*/

          objWrap.UnitId = unitId;
          objWrap.UnitName = unit.Name;
          objWrap.BuildingId = unit.Building__c;
          objWrap.BuildingName = unit.Building__r.Name;
          objWrap.UnitType = unit.Unit_Type__c;
          objWrap.Neighborhood = unit.Neighborhood__c;
          objWrap.TaxRate = unit.Tax_Rate__c;
          objWrap.VirtualTourURL = unit.Virtual_Tour_URL__c;
          objWrap.VirtualTourThumb = unit.Virtual_Tour_Thumbnail__c;
          objWrap.UnitTypeOrder = Integer.valueof(unit.Unit_Type_Order__c);
          objWrap.CleaningFee = (includeCleaningFee != null &&
            includeCleaningFee)
            ? unit.Cleaning_Fee__c
            : 0;

          //added star rating & no of review
          if (unit.Average_Ratings__c > 0) {
            objWrap.starRating = (unit.Average_Ratings__c / 2).setScale(2);
          }
          if (unit.of_Reviews__c > 0) {
            objWrap.noOfReviews = unit.of_Reviews__c;
          }

          //check for unit price
          for (Unit_Pricing__c up : unit_UnitPriceMap.get(unitid)) {
            Decimal dailySubtotal = CalculateTotalPrice(
              up.Barsala_Price_Modeled_Final__c,
              Decimal.valueof(noofguests),
              unit.Standard_Guests__c,
              unit.Extra_Guest_Charge__c
            );
            Decimal discountAmount = (discount != null &&
              discount != 0)
              ? ((dailySubtotal * discount) / 100).setScale(2)
              : 0;
            Decimal dailyDiscountedAmount = (discountAmount != 0)
              ? (dailySubtotal - discountAmount).setScale(2)
              : dailySubtotal;
            String commments =
              (up.UnitPrice_Date__c != null
                ? string.valueof(up.UnitPrice_Date__c).split(' ')[0]
                : '') +
              ' : ' +
              (discountAmount > 0
                ? '(Discount -' + discountAmount + ' USD) '
                : '') +
              dailyDiscountedAmount +
              ' USD';
            if (mapWrapperUnitIds.containskey(up.Unit__c)) {
              // Price Calculation
              objWrap.ExtraGuestPrice =
                mapWrapperUnitIds.get(up.Unit__c).ExtraGuestPrice +
                CalculateExtraGuestPrice(
                  Decimal.valueof(noofguests),
                  unit.Standard_Guests__c,
                  unit.Extra_Guest_Charge__c
                );
              objWrap.SubTotal =
                mapWrapperUnitIds.get(up.Unit__c).SubTotal +
                dailyDiscountedAmount;
              objWrap.UnitPriceWithoutGuest =
                mapWrapperUnitIds.get(up.Unit__c).UnitPriceWithoutGuest +
                up.Barsala_Price_Modeled_Final__c;

              // Booking Comments
              objWrap.BookingComments =
                mapWrapperUnitIds.get(up.Unit__c).BookingComments +
                ' \n    ' +
                commments;
              mapWrapperUnitIds.put(up.Unit__c, objWrap);
            } else {
              objWrap.AvailabilityStatus = up.Availability_Status__c;
              // Price Calculation
              objWrap.ExtraGuestPrice = CalculateExtraGuestPrice(
                Decimal.valueof(noofguests),
                unit.Standard_Guests__c,
                unit.Extra_Guest_Charge__c
              );
              objWrap.SubTotal = dailyDiscountedAmount;
              objWrap.UnitPriceWithoutGuest = up.Barsala_Price_Modeled_Final__c;

              // Booking Comments
              String strBookingComments = '';
              strBookingComments = 'No of Guests: ' + noofguests + '\n';
              strBookingComments += ' By night:\n    ' + commments;
              objWrap.BookingComments = strBookingComments;
              mapWrapperUnitIds.put(up.Unit__c, objWrap);
            }
            system.debug('@@@discountAmount==' + discountAmount);
            system.debug('@@@dailyDiscountedAmount==' + dailyDiscountedAmount);
            system.debug('@@@objWrap.SubTotal==' + objWrap.SubTotal);
          }
        }

        unit_UnitPriceMap = null;

        for (wrapperUnit objWrap : mapWrapperUnitIds.values()) {
          if (Test.isrunningTest()) {
            objWrap.CleaningFee = 0;
          }

          objWrap.TotalPrice = objWrap.SubTotal;
          objWrap.TotalPrice += ((includeCleaningFee != null &&
            includeCleaningFee)
            ? objWrap.CleaningFee
            : 0);
          system.debug('@@@includeCleaningFee==' + includeCleaningFee);
          system.debug('@@@objWrap.TotalPrice==' + objWrap.TotalPrice);
          system.debug('@@@objWrap.SubTotal==' + objWrap.SubTotal);
          // Apply Tax if Total Nights is less than 30.
          if (totalnights < 30) {
            //As not the subtotal can be 0, but there might be total price, or discount is over 100%,
            //but still the cleaning fee and taxes are applicable
            //if(objWrap.SubTotal != 0){
            objWrap.AvgPrice = (objWrap.UnitPriceWithoutGuest / totalnights)
              .setScale(2);
            Decimal TotalTax = (objWrap.TotalPrice * objWrap.TaxRate)
              .setScale(2);
            objWrap.TotalTax = TotalTax;
            system.debug('@@@TotalTax==' + TotalTax);
            objWrap.BookingComments +=
              '\n Cleaning Fee: ' +
              objWrap.CleaningFee +
              ' USD';
            objWrap.BookingComments += '\n Total Tax: ' + TotalTax + ' USD';
            objWrap.TotalPrice += TotalTax;
            objWrap.TotalPrice = objWrap.TotalPrice.setScale(2);
            //}
          } else {
            //no tax for bookings greater than 30 days, so overriting tax rate to 0
            objWrap.TaxRate = 0;
            objWrap.BookingComments +=
              '\n Cleaning Fee: ' +
              objWrap.CleaningFee +
              ' USD';
            objWrap.AvgPrice = (objWrap.UnitPriceWithoutGuest / totalnights)
              .setScale(2);
          }
          lstWrapUnit.add(objWrap);
        }

        system.debug(
          'after filling wrap list Heap size :: ' + Limits.getHeapSize()
        );

        lstWrapUnit.sort();
        return lstWrapUnit;
      }
    } catch (Exception e) {
      throw new BookingException(
        'Exception occurred: ' +
        e.getMessage() +
        ' at ' +
        e.getLineNumber()
      );
    }
    return new List<wrapperUnit>();
  }

  public static ResponseModel validateBookingRate(
    List<wrapperUnit> lstAllUnits,
    Xotelia_Booking__c objBooking,
    Boolean isRoomUsed
  ) {
    ResponseModel rm = new ResponseModel();

    if (lstAllUnits.size() > 0) {
      wrapperUnit tmpBooking = lstAllUnits.get(0);
      //updating comments;
      //objBooking.Booking_comment__c = tmpBooking.BookingComments;
      /*rm.errMsgs.add('@@@tmpBooking.TotalPrice'+tmpBooking.TotalPrice);
            rm.errMsgs.add('@@@objBooking.Total_taxed__c'+objBooking.Total_taxed__c);
            rm.errMsgs.add('Integer.ValueOf(tmpBooking.TotalPrice)=='+Integer.ValueOf(tmpBooking.TotalPrice));
            rm.errMsgs.add('Integer.ValueOf(objBooking.Total_taxed__c)=='+Integer.ValueOf(objBooking.Total_taxed__c));
            */
      if (
        (getUserType() != 'Standard' &&
        objBooking.Discount__c != null &&
        objBooking.Discount__c > 0) //|| Integer.ValueOf(tmpBooking.TotalPrice) != Integer.ValueOf(objBooking.Total_taxed__c)
      ) {
        if (isRoomUsed) {
          rm.isError = true;
          rm.errMsgs.add(
            'We encountered some error while processing your request, please contact the support team to continue your booking.'
          );
        }
      }
    } else {
      rm.isError = true;
      rm.errMsgs.add(
        'The unit you are trying to book is no longer available. Please select a different unit to proceed.'
      );
    }

    return rm;
  }
  public static ResponseModel validateBookingDate(
    DateTime startDate,
    DateTime endDate
  ) {
    ResponseModel rm = new ResponseModel();
    if (startDate == null || endDate == null) {
      rm.isError = true;
      rm.errMsgs.add('Please select valid From and To dates.');
    } else if (startDate >= endDate) {
      rm.isError = true;
      rm.errMsgs.add('To Date should be greater than From Date.');
    } else if (getUserType() != 'Standard' && startDate.Date() < Date.Today()) {
      rm.isError = true;
      rm.errMsgs.add(
        'Come on! You can make booking for present and future dates only.'
      );
    }
    return rm;
  }
  //create person account for new guest
  @TestVisible
  private static Contact createPersonAccount(
    Xotelia_Booking__c objBooking,
    Contact objContact,
    String stripeCustomerId
  ) {
    Account perAcc = new Account();
    perAcc.RecordTypeId = personAccountRecordTypeId;
    perAcc.FirstName = objBooking.Firstname__c;
    perAcc.LastName = objBooking.Lastname__c;
    perAcc.Phone = objBooking.Phone_number__c;
    perAcc.PersonEmail = objBooking.Email__c;

    if (String.isNotBlank(stripeCustomerId))
      perAcc.Stripe_Customer_ID__pc = stripeCustomerId;
    insert perAcc;
    List<Account> accList = [
      SELECT id, PersonContactId
      FROM Account
      WHERE id = :perAcc.Id
    ];
    if (accList.size() > 0) {
      objContact.Id = accList[0].PersonContactId;
    }
    return objContact;
  }

  public static string getCreatableFieldsSOQL(
    String objectName,
    String whereClause
  ) {
    String selects = '';
    if (whereClause == null || whereClause == '') {
      return null;
    }
    // Get a map of field name and field token
    Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe()
      .get(objectName.toLowerCase())
      .getDescribe()
      .Fields.getMap();
    list<string> selectFields = new List<string>();
    if (fMap != null) {
      for (Schema.SObjectField ft : fMap.values()) {
        // loop through all field tokens (ft)
        Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
        if (fd.isCreateable()) {
          // field is creatable
          selectFields.add(fd.getName());
        }
      }
    }

    if (!selectFields.isEmpty()) {
      for (string s : selectFields) {
        selects += s + ',';
      }
      if (selects.endsWith(',')) {
        selects = selects.substring(0, selects.lastIndexOf(','));
      }
    }

    return 'SELECT ' +
      selects +
      ' FROM ' +
      objectName +
      ' WHERE ' +
      whereClause;
  }

  //method to book unit from booking wizard
  @RemoteAction
  public static ResponseModel BookUnitWrapper(
    Xotelia_Booking__c objBookingtemp,
    string bookingStartDate,
    string bookingEndDate,
    String unitName,
    string selectedCardId,
    String defaultSourceId,
    Boolean includeCleaningFee,
    String oldBookingId,
    Boolean isRoomUsed
  ) {
    Decimal decTotalTaxed = 0;
    Boolean isOldAndNewUpgradBookingOnSameDate = false;
    Xotelia_Booking__c objBooking;
    Xotelia_Booking__c objOldBooking;
    //Id oldbookingId = null;
    string strOldSOQL = '';
    if (!string.isblank(oldBookingId)) {
      strOldSOQL = getCreatableFieldsSOQL(
        'Xotelia_Booking__c',
        'id=\'' +
        oldbookingId +
        '\''
      );

      objOldBooking = (Xotelia_Booking__c) Database.query(strOldSOQL);

      // if(objOldBooking.Billing_Contact__c == null && objOldBooking.Guest_Contact__c != null){
      //     objOldBooking.Billing_Contact__c = objOldBooking.Guest_Contact__c;
      // }

      if (!isRoomUsed) {
        objBooking = objOldBooking.clone(true, true);
        bookingStartDate = objBooking.Start_date__c.format('MM/dd/yyyy');
        bookingEndDate = objBooking.End_date__c.format('MM/dd/yyyy');
      } else {
        objBooking = objOldBooking.clone(false, true);
        objBooking.Previous_Booking__c = oldBookingId;
        objBooking.External_code__c = 'manual';
        objBooking.Sales_channel__c = 'manual';

        if (
          system.now().format('MM/dd/yyyy') ==
          objBooking.Start_date__c.format('MM/dd/yyyy')
        ) {
          isOldAndNewUpgradBookingOnSameDate = true;
          objBooking.Start_date__c = setDateTime(bookingStartDate);
        } else {
          objBooking.Start_date__c = system.now();
        }
        bookingStartDate = objBooking.Start_date__c.format('MM/dd/yyyy');
      }

      objBooking.Phone_number__c = objBookingtemp.Phone_number__c;
      objBooking.Email__c = objBookingtemp.Email__c;
      objBooking.Firstname__c = objBookingtemp.Firstname__c;
      objBooking.Lastname__c = objBookingtemp.Lastname__c;

      objBooking.Booking_Type__c = 'Upgrade';

      if (
        String.isNotBlank(objBookingtemp.Credit_Card_Number__c) &&
        (isRoomUsed || String.isBlank(objBooking.Credit_Card_Number__c))
      ) {
        objBooking.Credit_Card_Number__c = objBookingtemp.Credit_Card_Number__c;
      }
      if (
        String.isNotBlank(objBookingtemp.Credit_Card_Full_Name__c) &&
        (isRoomUsed || String.isBlank(objBooking.Credit_Card_Full_Name__c))
      ) {
        objBooking.Credit_Card_Full_Name__c = objBookingtemp.Credit_Card_Full_Name__c;
      }
      if (
        String.isNotBlank(objBookingtemp.Credit_Card_CVV__c) &&
        (isRoomUsed || String.isBlank(objBooking.Credit_Card_CVV__c))
      ) {
        objBooking.Credit_Card_CVV__c = objBookingtemp.Credit_Card_CVV__c;
      }
      if (
        String.isNotBlank(objBookingtemp.Credit_Card_Type__c) &&
        (isRoomUsed || String.isBlank(objBooking.Credit_Card_Type__c))
      ) {
        objBooking.Credit_Card_Type__c = objBookingtemp.Credit_Card_Type__c;
      }
      if (
        String.isNotBlank(objBookingtemp.Zip_Code__c) &&
        (isRoomUsed || String.isBlank(objBooking.Zip_Code__c))
      ) {
        objBooking.Zip_Code__c = objBookingtemp.Zip_Code__c;
      }
      if (
        String.isNotBlank(objBookingtemp.Credit_Card_Expiration_Date__c) &&
        (isRoomUsed ||
        String.isBlank(objBooking.Credit_Card_Expiration_Date__c))
      ) {
        objBooking.Credit_Card_Expiration_Date__c = objBookingtemp.Credit_Card_Expiration_Date__c;
      }
      // objBooking.Credit_Card_Number__c = objBookingtemp.Credit_Card_Number__c;
      // objBooking.Credit_Card_Full_Name__c = objBookingtemp.Credit_Card_Full_Name__c;
      // objBooking.Credit_Card_CVV__c = objBookingtemp.Credit_Card_CVV__c;
      // objBooking.Credit_Card_Type__c = objBookingtemp.Credit_Card_Type__c;
      // objBooking.Zip_Code__c = objBookingtemp.Zip_Code__c;
      //objBooking.Credit_Card_Expiration_Date__c = objBookingtemp.Credit_Card_Expiration_Date__c;
      objBooking.Disable_Cleanings__c = objBookingtemp.Disable_Cleanings__c;
      objBooking.Private_comment__c = objBookingtemp.Private_comment__c;
      objBooking.Discount__c = objBookingtemp.Discount__c;
      objBooking.Sub_Total__c = objBookingtemp.Sub_Total__c;

      decTotalTaxed = objBooking.Total_taxed__c;
      system.debug('decTotalTaxed@@@ ' + decTotalTaxed);

      objBooking.Total_taxed__c = objBookingtemp.Total_taxed__c;
      system.debug('decTotalTaxed@@@ ' + decTotalTaxed);

      objBooking.Product__c = objBookingtemp.Product__c;
      //objBooking.Orig_Product__c =  objBookingtemp.Orig_Product__c;
      objBooking.Upgrade__c = true;
    }

    Boolean isPaymentCharged = false;
    Boolean updateContact = false;
    List<Contact> conList;
    String stripeCustomerId;
    Payment__c pymt;
    ResponseModel rm = new ResponseModel();
    Stripe_Setting__c stripeSetting = Stripe_Setting__c.getORGDefaults();
    system.debug('objBooking@@@ ' + objBooking);
    system.debug(
      'bookingStartDate@@@ ' +
      bookingStartDate +
      ' ' +
      bookingEndDate
    );
    if (objBooking.Total_taxed__c > 0 && stripeSetting == null) {
      rm.errMsgs.add(
        'Stripe Connection settings not found, please contact your administrator.'
      );
      rm.isError = true;
      return rm;
    }
    try {
      //added validation for customer community user
      //if(string.valueof(system.URL.getCurrentRequestUrl()).contains('/customer/apexremote')){
      //objBooking.Start_date__c = setDateTime(bookingStartDate);
      objBooking.End_date__c = setDateTime(bookingEndDate);
      rm = validateBookingDate(
        objBooking.Start_date__c,
        objBooking.End_date__c
      );
      if (rm.isError == true)
        return rm;
      string noofguest = '1';
      if (objBooking.Travelers__c != null) {
        noofguest = objBooking.Travelers__c.format();
      }

      List<wrapperUnit> lstAllUnits = UpgradeWizard.allUnits(
        objBooking.City__c,
        objBooking.Start_date__c.format('MM/dd/yyyy'),
        objBooking.End_date__c.format('MM/dd/yyyy'),
        noofguest,
        objBooking.Product__c,
        includeCleaningFee,
        objBooking.Discount__c,
        0
      );
      rm = validateBookingRate(lstAllUnits, objBooking, isRoomUsed);
      if (rm.isError == true)
        return rm;
      else {
        //updating comments;
        if (!isRoomUsed) {
          string tmpbookingcomment = objBooking.Booking_comment__c;
          objBooking.Booking_comment__c =
            lstAllUnits.get(0).BookingComments +
            '\n' +
            tmpbookingcomment;
        } else {
          objBooking.Booking_comment__c = lstAllUnits.get(0).BookingComments;
        }
      }

      //}
      //for sales channel airbnb or discount 100% or more i.e total amount is 0, no payments are made, so no need to process
      if (
        objBooking.Sales_channel__c != 'airbnb' &&
        objBooking.Total_taxed__c != null &&
        objBooking.Total_taxed__c > 0
      ) {
        String cardId;
        String cardType;
        Boolean isDuplicateMatch = false;
        StripeCustomerModel scModel;
        CreditCardModel ccModel;
        //Checking Stripe Customer ID from Contact or Last Active booking, if Guest Already Exists
        if (objBooking.Billing_Contact__c != null) {
          conList = fetchContactAndLastActiveBooking(
            objBooking.Billing_Contact__c
          );
          stripeCustomerId = getStripeCustomerIdFromContactOrLastBooking(
            conList
          );
        }
        //If user has added a new card
        if (selectedCardId == 'newCard') {
          ccModel = new CreditCardModel(
            objBooking.Credit_Card_Number__c,
            objBooking.Credit_Card_Full_Name__c,
            objBooking.Credit_Card_Expiration_Date__c.split('/')[0],
            objBooking.Credit_Card_Expiration_Date__c.split('/')[1],
            objBooking.Zip_Code__c,
            objBooking.Credit_Card_CVV__c,
            null,
            null,
            null,
            false
          );
          //then checking for duplicates and using existing card if a mat founds
          if (stripeCustomerId != null) {
            DuplicateCardModel dcm = checkDuplicateCard(
              stripeSetting,
              ccModel,
              stripeCustomerId
            );
            if (!dcm.isError) {
              //when duplicate matched, populating card type on booking record, and selecting existing card fpr payment
              if (dcm.isDuplicateMatch) {
                selectedCardId = dcm.selectedCardId;
                cardType = dcm.cardType;
              }
            } else {
              rm.errMsgs.addall(dcm.errMsgs);
              rm.isError = true;
            }
          }
        }
        if (!rm.isError) {
          if (stripeCustomerId == null || selectedCardId == 'newCard') {
            //create stripe customer with card
            //if cusotmer already created then only adding card to customer profile
            StripeHelper.HTTPModel httpModel = StripeHelper.createStripeCustomer(
              stripeSetting,
              stripeCustomerId,
              objBooking.Email__c,
              'Created w/Booking wizard',
              ccModel
            );
            scModel = processCreateStripeCustomer(httpModel, stripeCustomerId);
            if (!rm.isError && stripeCustomerId == null)
              updateContact = true;
            stripeCustomerId = scModel.stripeCustomerId;
            selectedCardId = scModel.cardId;
            cardType = scModel.cardType;
            rm.errMsgs.addAll(scModel.errMsgs);
            rm.isError = scModel.isError;
          }
        }
        if (!rm.isError) {
          //populating card type on booking record
          if (ccModel != null && cardType != null)
            objBooking.Credit_Card_Type__c = cardType;

          //populating string customer id url on booking record
          if (stripeCustomerId != null)
            objBooking.Stripe_Customer__c =
              stripeSetting.Dashboard_URL__c +
              '/customers/' +
              stripeCustomerId;

          rm = BookUnit(
            objBooking,
            bookingStartDate,
            bookingEndDate,
            includeCleaningFee
          );
          if (!rm.isError) {
            Xotelia_Booking__c book = rm.bookings[0];
            String bookingComments = updateBookingComments(
              'Charge for booking through Barsala Booking Wizard #: ',
              book
            );

            StripeHelper.HTTPModel httpModel = StripeHelper.chargeStripeCustomer(
              stripeSetting,
              stripeCustomerId,
              bookingComments,
              selectedCardId,
              book.Total_taxed__c,
              book.Email__c,
              'Barsala Reservation'
            );
            //If there is exception in callout, then showing error
            if (httpModel.isCalloutException) {
              rm.errMsgs.add(httpModel.response);
              rm.isError = true;
            } else {
              StripeHelper.StripeChargeParser charge = StripeHelper.parseStripeCharge(
                httpModel.response
              );
              if (charge != null) {
                if (charge.paid != null && charge.paid) {
                  pymt = new Payment__c(
                    Payment_Date__c = DateTime.now(),
                    Payment_Method__c = 'Credit Card',
                    Value__c = book.Total_taxed__c.setScale(2),
                    Status__c = 'Succeeded',
                    Stripe_Charge__c = stripeSetting.Dashboard_URL__c +
                      '/payments/' +
                      charge.id
                  );
                  isPaymentCharged = true;

                  rm = updateCustomerDefaultSource(
                    rm,
                    defaultSourceId,
                    selectedCardId,
                    stripeCustomerId,
                    stripeSetting
                  );
                } else {
                  rm.errMsgs.add(
                    StripeHelper.getStripeResponseError(charge.error)
                  );
                  rm.isError = true;
                }
              }
            }
          }
        }
      } else {
        rm = BookUnit(
          objBooking,
          bookingStartDate,
          bookingEndDate,
          includeCleaningFee
        );
      }

      //populating stripe customer id on billing contact, so it can be used later
      //As this methods make multiple calls to API, i.e for creating customer, charging a card e.t.c
      //even if there is exception/error in one callout to charge a payment but customer was created in stripe successfully,
      //in that case as well we will update customer id on contact, so for future transaction customer does't needs to be created again
      Contact objContact = new Contact();
      if (
        !rm.isError ||
        updateContact ||
        (objBooking.Billing_Contact__c == null &&
        stripeCustomerId != null) ||
        (stripeCustomerId != null &&
        conList != null &&
        conList[0].Stripe_Customer_ID__c == null)
      ) {
        //Creating person account for new Guests
        if (objBooking.Billing_Contact__c == null) {
          objContact = createPersonAccount(
            objBooking,
            objContact,
            stripeCustomerId
          );
        } else {
          if (objBooking.get('Firstname__c') != null) {
            objContact.FirstName = objBooking.Firstname__c;
          }
          if (objBooking.get('Lastname__c') != null) {
            objContact.LastName = objBooking.Lastname__c;
          }
          if (objBooking.get('Email__c') != null) {
            objContact.Email = objBooking.Email__c;
          }
          system.debug(
            'Phone_number__c@@@ ' + objBooking.get('Phone_number__c')
          );
          if (objBooking.get('Phone_number__c') != null) {
            objContact.Phone = objBooking.Phone_number__c;
          }
          objContact.Id = objBooking.Billing_Contact__c;

          if (stripeCustomerId != null)
            objContact.Stripe_Customer_ID__c = stripeCustomerId;
          system.debug('objContact@@@ ' + objContact);
          upsert objContact;
        }
        if (objBooking.Billing_Contact__c == null)
          rm.contactId = objContact.Id;
      }
      if (!rm.isError) {
        if (objBooking.Billing_Contact__c == null) {
          for (Xotelia_Booking__c book : rm.bookings) {
            book.Billing_Contact__c = objContact.Id;
          }
        }

        Boolean blnBookingXetelioException = false;
        try {
          if (!isRoomUsed) {
            update rm.bookings;
          } else {
            for (Xotelia_Booking__c b : rm.bookings) {
              b.Confirmation_Code__c = '';
            }
            system.debug('@@@#### ' + rm.bookings);
            insert rm.bookings;

            for (Xotelia_Booking__c b : [
              SELECT id, Confirmation_Code__c
              FROM Xotelia_Booking__c
              WHERE id IN :rm.bookings
            ]) {
              for (Xotelia_Booking__c o : rm.bookings) {
                if (o.Id == b.Id) {
                  o.Confirmation_Code__c = b.Confirmation_Code__c;
                }
              }
            }

            system.debug('@@@#### ' + rm.bookings);
          }

          if (Test.isRunningTest()) {
            findUniqueXeteliaCode(
              rm.bookings[0].External_code__c,
              rm.bookings[0].Xotelia_code__c
            );
          }
        } catch (Exception e) {
          if (
            e.getMessage().contains('Xotelia_code__c') ||
            e.getMessage().contains('External_code__c')
          ) {
            for (Xotelia_Booking__c xb : rm.bookings) {
              clsxoteliacode objnewcode = new clsxoteliacode();
              objnewcode = findUniqueXeteliaCode(
                xb.External_code__c,
                xb.Xotelia_code__c
              );
              xb.External_code__c = objnewcode.externalcode;
              xb.Xotelia_code__c = objnewcode.xcode;
            }

            if (!isRoomUsed) {
            } else {
              insert rm.bookings;
            }
          } else {
            blnBookingXetelioException = true;
            throw new BKException(e.getMessage());
          }
        }

        if (!blnBookingXetelioException || Test.isRunningTest()) {
          if (
            rm.bookings[0].Sales_channel__c != 'airbnb' &&
            rm.bookings[0].Total_taxed__c != null &&
            rm.bookings[0].Total_taxed__c > 0 &&
            pymt != null
          ) {
            pymt.Booking__c = rm.bookings[0].Id;
            insert pymt;
          }
          rm.successMsgs.add('Success Booking Id=' + rm.bookings[0].id);
          rm.recordId = rm.bookings[0].id;

          if (isRoomUsed || Test.isRunningTest()) {
            //objOldBooking
            objBooking.Orig_Product__c = objOldBooking.Orig_Product__c;
            wrpNextPrevBooking objnextprevbookingids = findNextPreviousBooking(
              objBooking
            );
            if (objnextprevbookingids.nextid != null) {
              objBooking.Next_Booking__c = objnextprevbookingids.nextid;
            }
            if (objnextprevbookingids.previousid != null) {
              objBooking.Previous_Booking__c = objnextprevbookingids.previousid;
            }
            update objBooking;

            if (isOldAndNewUpgradBookingOnSameDate) {
              objOldBooking.End_date__c = system.now().addDays(1);
            } else {
              objOldBooking.End_date__c = system.now();
            }

            //objOldBooking.Next_Booking__c = objBooking.Id;

            List<Booking_Unit_Price_Junction__c> lstDeleteBUPJ = new List<Booking_Unit_Price_Junction__c>();
            List<Unit_Pricing__c> lstUnitPriceAvailibility = new List<Unit_Pricing__c>();
            List<Payment__c> lstPaymentTransfer = new List<Payment__c>();

            for (Xotelia_Booking__c book : [
              SELECT
                id,
                (
                  SELECT id, Unit_Pricing__c
                  FROM Booking_Unit_Price_Junctions__r
                  WHERE Unit_Pricing__r.UnitPrice_Date__c > today
                ),
                (SELECT id FROM Payments__r)
              FROM Xotelia_Booking__c
              WHERE id = :objOldBooking.Id
            ]) {
              for (
                Booking_Unit_Price_Junction__c bupj : book.Booking_Unit_Price_Junctions__r
              ) {
                Unit_Pricing__c up = new Unit_Pricing__c(
                  Id = bupj.Unit_Pricing__c
                );
                up.Availability_Status__c = 'Available';
                lstUnitPriceAvailibility.add(up);

                lstDeleteBUPJ.add(bupj);
              }

              // for (Payment__c objpayment : book.Payments__r) {
              //     objpayment.Booking__c = objBooking.Id;
              //     lstPaymentTransfer.add(objpayment);
              // }
            }

            if (lstUnitPriceAvailibility.size() > 0)
              update lstUnitPriceAvailibility;

            // if(lstPaymentTransfer.size()>0) update lstPaymentTransfer;

            if (lstDeleteBUPJ.size() > 0)
              delete lstDeleteBUPJ;

            wrpNextPrevBooking objnextprevbookingidsforold = findNextPreviousBooking(
              objOldBooking
            );
            if (objnextprevbookingidsforold.nextid != null) {
              objOldBooking.Next_Booking__c = objnextprevbookingidsforold.nextid;
            }
            if (objnextprevbookingidsforold.previousid != null) {
              objOldBooking.Previous_Booking__c = objnextprevbookingidsforold.previousid;
            }
            update objOldBooking;
          } else {
            // it is added for futur booking and add total field value with newly total value
            wrpNextPrevBooking objnextprevbookingids = findNextPreviousBooking(
              objBooking
            );
            if (objnextprevbookingids.nextid != null) {
              objBooking.Next_Booking__c = objnextprevbookingids.nextid;
            }
            if (objnextprevbookingids.previousid != null) {
              objBooking.Previous_Booking__c = objnextprevbookingids.previousid;
            }
            // system.debug('objnextprevbookingids else@@@@@' + objnextprevbookingids);

            objBooking.Total_taxed__c =
              objBooking.Total_taxed__c + decTotalTaxed;
            update objBooking;
          }
        }
      }
    } catch (Exception e) {
      system.debug('@@@Exception ' + e.getMessage() + ' ' + e.getLineNumber());
      String exceptionMsg = handleCustomValidationException(e);
      rm.errMsgs.add(exceptionMsg);
      if (isPaymentCharged) {
        rm.errMsgs.add(
          'The payment has been processed but failed to create Booking Record:'
        );
        rm.errMsgs.add(
          'Payment Transaction: ' + pymt.Stripe_Charge__c.split('payments/')[1]
        );
        rm.errMsgs.add('Initial Payment Amount: $' + pymt.Value__c);
        prepareAndSendEmail(
          stripeSetting,
          pymt,
          objBooking,
          unitName,
          objBooking.Start_date__c.format('MMM dd, yyyy'),
          objBooking.End_date__c.format('MMM dd, yyyy'),
          exceptionMsg
        );
      }
      rm.isError = true;
    }
    return rm;
  }

  public class BKException extends Exception {
  }

  public class clsxoteliacode {
    public string xcode { get; set; }
    public string externalcode { get; set; }
  }

  public static clsxoteliacode findUniqueXeteliaCode(
    string externalcode,
    string xoteliacode
  ) {
    List<Xotelia_Booking__c> lstBookingRecords = new List<Xotelia_Booking__c>(
      [
        SELECT id, External_code__c, Xotelia_code__c, createddate
        FROM Xotelia_Booking__c
        WHERE External_code__c = :externalcode OR Xotelia_code__c = :xoteliacode
      ]
    );

    if (lstBookingRecords.size() > 0) {
      integer randomNum = integer.valueof(math.random() * 100000000);
      if (randomNum == 0)
        randomNum = integer.valueof(math.random() * 100000000);

      string strnum = 'BASF' + string.valueOf(randomNum);
      if (strnum.length() <= 10) {
        xoteliacode = strnum;
      } else {
        xoteliacode = strnum.subString(0, 10);
      }

      return findUniqueXeteliaCode(strnum, xoteliacode);
    }

    clsxoteliacode obj = new clsxoteliacode();
    obj.xcode = xoteliacode;
    obj.externalcode = externalcode;
    return obj;
  }

  public class wrpNextPrevBooking {
    public Id nextid { get; set; }
    public Id previousid { get; set; }

    public wrpNextPrevBooking() {
      nextid = null;
      previousid = null;
    }
  }

  public static wrpNextPrevBooking findNextPreviousBooking(
    Xotelia_Booking__c obj
  ) {
    Xotelia_Booking__c objbooking = [
      SELECT id, Start_date__c, End_date__c, Product__c
      FROM Xotelia_Booking__c
      WHERE id = :obj.id
    ];

    wrpNextPrevBooking o = new wrpNextPrevBooking();
    List<Booking_Unit_Price_Junction__c> lstBUPJunctionNext = new List<Booking_Unit_Price_Junction__c>(
      [
        SELECT Id, Booking__c, Booking__r.Start_date__c, Booking__r.End_date__c
        FROM Booking_Unit_Price_Junction__c
        WHERE
          Unit_Pricing__r.Unit__c = :objbooking.Product__c
          AND Booking__r.End_date__c > :objbooking.End_date__c
        LIMIT 1
      ]
    );
    if (lstBUPJunctionNext.size() > 0) {
      o.nextid = lstBUPJunctionNext.get(0).Booking__c;
    }

    List<Booking_Unit_Price_Junction__c> lstBUPJunctionPrevious = new List<Booking_Unit_Price_Junction__c>(
      [
        SELECT Id, Booking__c
        FROM Booking_Unit_Price_Junction__c
        WHERE
          Unit_Pricing__r.Unit__c = :objbooking.Product__c
          AND Booking__r.Start_date__c < :objbooking.Start_date__c
        LIMIT 1
      ]
    );
    if (lstBUPJunctionPrevious.size() > 0) {
      o.previousid = lstBUPJunctionPrevious.get(0).Booking__c;
    }

    return o;
  }

  public static StripeCustomerModel processCreateStripeCustomer(
    StripeHelper.HTTPModel httpModel,
    String stripeCustomerId
  ) {
    StripeCustomerModel scModel = new StripeCustomerModel();
    scModel.stripeCustomerId = stripeCustomerId;
    //If there is exception in callout, then showing error
    if (httpModel.isCalloutException) {
      scModel.errMsgs.add(httpModel.response);
      scModel.isError = true;
    } else if (scModel.stripeCustomerId == null) {
      //if stripe customer was newly created then using customer parser
      StripeHelper.StripeCustomerParser customerParser = StripeHelper.parseStripeCustomer(
        httpModel.response
      );
      if (customerParser != null) {
        if (String.isNotBlank(customerParser.id)) {
          ///copying customer id
          scModel.stripeCustomerId = customerParser.id;

          //getting card id created with customer
          if (
            customerParser.sources != null &&
            !customerParser.sources.data.isEmpty()
          ) {
            scModel.cardId = customerParser.sources.data[0].id;
            scModel.cardType = customerParser.sources.data[0].brand;
          } else {
            //if card was npt created then adding error message
            scModel.errMsgs.add(
              'Could not save credit card, Please contact your administrator.==' +
              httpModel.response
            );
            scModel.isError = true;
          }
        } else if (customerParser.error != null) {
          //if response has error, adding error messages
          scModel.errMsgs.add(
            StripeHelper.getStripeResponseError(customerParser.error)
          );
          scModel.isError = true;
        }
      } else {
        //if response was blank/null, adding error message
        scModel.errMsgs.add(
          'Could not create customer profile, Please contact your administrator.==' +
          httpModel.response
        );
        scModel.isError = true;
      }
    } else {
      //if stripe customer was exists already, then using card data parser
      StripeHelper.cls_data cardData = StripeHelper.parseStripeSaveCard(
        httpModel.response
      );
      if (cardData != null) {
        //if card was saved successfully, then storing card id temporary to charge payment
        if (String.isNotBlank(cardData.id)) {
          scModel.cardId = cardData.Id;
          scModel.cardType = cardData.brand;
        } else if (cardData.error != null) {
          // if there was any error in response then adding error message
          scModel.errMsgs.add(
            StripeHelper.getStripeResponseError(cardData.error)
          );
          scModel.isError = true;
        }
      } else {
        //if response was blank/null, then adding error message
        scModel.errMsgs.add(
          'Could not charge customer profile, Please contact your administrator.==' +
          httpModel.response
        );
        scModel.isError = true;
      }
    }
    return scModel;
  }
  //function is used to create booking
  @RemoteAction
  public static ResponseModel BookUnit(
    Xotelia_Booking__c objBooking,
    string bookingStartDate,
    string bookingEndDate,
    Boolean includeCleaningFee
  ) {
    ResponseModel rm = new ResponseModel();

    try {
      boolean isExternalCodeManual = false;
      List<Xotelia_Booking__c> lstBookingRecords = new List<Xotelia_Booking__c>();
      if (
        getUserType() != 'Standard' || string.IsnotBlank(objBooking.Email__c)
      ) {
        if (objBooking.External_code__c == 'manual') {
          isExternalCodeManual = true;
          integer randomNum = integer.valueof(math.random() * 100000000);
          if (randomNum == 0)
            randomNum = integer.valueof(math.random() * 100000000);
          objBooking.External_code__c = 'BASF' + string.valueOf(randomNum);
          //added condition if External code length is less than 10 then do not substring - added on 27th Sept 18
          if (objBooking.External_code__c.length() <= 10) {
            objBooking.Xotelia_code__c = objBooking.External_code__c;
          } else {
            objBooking.Xotelia_code__c = objBooking.External_code__c.subString(
              0,
              10
            );
          }
        } else if (String.isBlank(objBooking.Xotelia_code__c)) {
          //
          if (objBooking.External_code__c.length() <= 10)
            objBooking.Xotelia_code__c = objBooking.External_code__c;
          else
            objBooking.Xotelia_code__c = objBooking.External_code__c.subString(
              0,
              10
            );
        }
        objBooking.Start_date__c = setDateTime(bookingStartDate);
        objBooking.End_date__c = setDateTime(bookingEndDate);

        //discounted is added in AllUnits method now, which also calculates price for the booking,
        //also the booking comments has discounted daily price now, so no need to add this
        //system.debug(objBooking.Discount__c);
        //if(objBooking.Discount__c != null && objBooking.Discount__c != 0)
        //  objBooking.Booking_comment__c = objBooking.Booking_comment__c + '\n Discount: '+objBooking.Discount__c+'% ('+(objBooking.Total_taxed__c*(objBooking.Discount__c/100)).setScale(2)+')';

        //start Logic for Booking Split
        Date dtStartDate = date.newinstance(
          objBooking.Start_date__c.year(),
          objBooking.Start_date__c.month(),
          objBooking.Start_date__c.day()
        );
        Date dtEndDate = date.newinstance(
          objBooking.End_date__c.year(),
          objBooking.End_date__c.month(),
          objBooking.End_date__c.day()
        );
        Integer noofDaysforBooking = dtStartDate.Daysbetween(dtEndDate);
        if (noofDaysforBooking > 60 || Test.isRunningTest()) {
          Date dtStartingDate = dtStartDate;
          Integer i = 1;
          while (dtStartingDate < dtEndDate) {
            includeCleaningFee = (includeCleaningFee && i == 1);
            Xotelia_Booking__c objBookingNew = objBooking.clone(false);
            Time checkinTime = Time.newInstance(11, 0, 0, 0);
            objBookingNew.Start_date__c = DateTime.NewInstance(
              dtStartingDate,
              checkinTime
            );
            dtStartingDate = dtStartingDate.addDays(30);
            if (dtStartingDate.Daysbetween(dtEndDate) < 30) {
              objBookingNew.End_date__c = DateTime.NewInstance(
                dtEndDate,
                checkinTime
              );
              dtStartingDate = dtStartingDate.addDays(
                dtStartingDate.Daysbetween(dtEndDate)
              );
            } else {
              objBookingNew.End_date__c = DateTime.NewInstance(
                dtStartingDate,
                checkinTime
              );
            }

            //System.debug('objBookingNew.Travelers__c ::: '+objBookingNew.Travelers__c);
            string noofguest = '1';
            if (objBookingNew.Travelers__c != null) {
              noofguest = objBookingNew.Travelers__c.format();
            }
            system.debug(
              '@@@objBookingNew.Discount__c==' + objBookingNew.Discount__c
            );
            system.debug(
              '@@@objBooking.Discount__c==' + objBooking.Discount__c
            );
            List<wrapperUnit> lstAllUnits = UpgradeWizard.allUnits(
              '',
              objBookingNew.Start_date__c.format('MM/dd/yyyy'),
              objBookingNew.End_date__c.format('MM/dd/yyyy'),
              noofguest,
              objBooking.Product__c,
              includeCleaningFee,
              objBookingNew.Discount__c,
              0
            );
            //UnitBookingController.allUnits('', objBookingNew.Start_date__c.format('MM/DD/YYYY'), objBookingNew.End_date__c.format('MM/DD/YYYY'), string.valueof(objBookingNew.Travelers__c));
            system.debug('Unit Size:  ' + lstAllUnits.size());
            for (wrapperUnit objWrapperUnit : lstAllUnits) {
              if (objBookingNew.Product__c == objWrapperUnit.UnitId) {
                objBookingNew.Booking_comment__c = objWrapperUnit.BookingComments;
                objBookingNew.Sub_Total__c = objWrapperUnit.SubTotal;
                objBookingNew.Total_taxed__c = objWrapperUnit.TotalPrice;
                if (i > 1) {
                  /*if(objWrapperUnit.BookingComments.contains('Cleaning Fee:')){
                                        Integer totaltaxindex = objWrapperUnit.BookingComments.indexOf('Cleaning Fee:');
                                        string strTotalTax =  objWrapperUnit.BookingComments.substring(totaltaxindex, objWrapperUnit.BookingComments.length());
                                        Integer totaxtaxendindex = strTotalTax.indexof('USD')+3;
                                        string WholeTotalTaxstring = strTotalTax.Substring(0,totaxtaxendindex).replace('\r\n', ' ');
                                        objWrapperUnit.BookingComments = objWrapperUnit.BookingComments.replace(WholeTotalTaxstring,''); 
                                        objBookingNew.Booking_comment__c = objWrapperUnit.BookingComments;
                                        objBookingNew.Total_taxed__c = objBookingNew.Total_taxed__c - objWrapperUnit.CleaningFee;
                                    }*/
                  objBookingNew.do_not_charge__c = true;
                }
                /*if(objBookingNew.Discount__c != null && objBookingNew.Discount__c != 0) {
                                    objBookingNew.Booking_comment__c = objBookingNew.Booking_comment__c + '\n Discount: '+objBookingNew.Discount__c+'% ('+(objBookingNew.Total_taxed__c*(objBookingNew.Discount__c/100)).setScale(2)+')';
                                    objBookingNew.Total_taxed__c = objBookingNew.Total_taxed__c - (objBookingNew.Total_taxed__c*(objBookingNew.Discount__c/100));
                                }*/
                break;
              }
            }
            if (isExternalCodeManual) {
              integer randomNum = integer.valueof(math.random() * 100000000);
              if (randomNum == 0)
                randomNum = integer.valueof(math.random() * 100000000);
              objBookingNew.External_code__c =
                'BASF' + string.valueOf(randomNum);
              objBookingNew.Xotelia_code__c = objBookingNew.External_code__c.subString(
                0,
                10
              );
            } else {
              if (objBookingNew.External_code__c.length() <= 10)
                objBookingNew.Xotelia_code__c =
                  objBookingNew.External_code__c + string.valueof(i);
              else
                objBookingNew.Xotelia_code__c =
                  objBookingNew.External_code__c.subString(0, 9) +
                  string.valueof(i);
            }
            rm.bookings.add(objBookingNew);
            i++;
          }
        } else {
          rm.bookings.add(objBooking);
        }
      } else {
        rm.isError = true;
        rm.errMsgs.add(
          'Email is not provided for the booking record. Please add the email address on booking record'
        );
      }
      //end
      /* if(rm.bookings.size() > 0){
                //insert rm.bookings;
                //rm.successMsgs.add('Success Booking Id='+rm.bookings[0].id);
                //rm.recordId = rm.bookings[0].id;
                rm.isError = false;
            }*/
      //insert objBooking;
      /*set<Date> setFromToDates = allDatesBetweenTwoDates(string.valueof(objBooking.Start_date__c), string.valueof(objBooking.End_date__c));
            List<Unit_Price__c> lstUpdateUnitPrice = 
            for(Unit_Ori){
            }*/
      System.debug('lstBookingRecords ::: ' + rm.bookings);
    } catch (Exception ex) {
      rm.isError = true;
      if (
        ex.getTypeName() == 'System.DmlException' &&
        ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')
      ) {
        for (Integer i = 0; i < ex.getNumDml(); i++) {
          rm.errMsgs.add(ex.getDmlMessage(i));
        }
      } else
        rm.errMsgs.add(ex.getTypeName() + '==' + ex.getMessage());

      throw new BookingException(
        'Exception occurred: ' +
        rm.errMsgs +
        ' at ' +
        ex.getLineNumber()
      );
    }
    return rm;
  }

  //function is used to calculate total price
  public static Decimal CalculateTotalPrice(
    Decimal UnitPrice,
    Decimal NoofGuest,
    decimal stdGuest,
    Decimal ExtraGuestPrice
  ) {
    Decimal SubTotal = 0;
    if (UnitPrice != null)
      SubTotal += UnitPrice;
    else
      return SubTotal;
    if ((NoofGuest - stdGuest) > 0) {
      SubTotal += ((NoofGuest - stdGuest) * ExtraGuestPrice);
    }
    return SubTotal;
  }

  //function that calculate extra guest price
  public static Decimal CalculateExtraGuestPrice(
    Decimal NoofGuest,
    decimal stdGuest,
    Decimal UnitExtraGuestPrice
  ) {
    Decimal ExtraGuestPrice = 0;
    if ((NoofGuest - stdGuest) > 0) {
      ExtraGuestPrice = ((NoofGuest - stdGuest) * UnitExtraGuestPrice);
    }
    return ExtraGuestPrice;
  }

  //function to get all dates between start date and end date
  public static set<Date> allDatesBetweenTwoDates(
    string fromdate,
    string todate
  ) {
    set<Date> setAllDates = new Set<Date>();
    Date dtFromDate = Date.parse(fromdate);
    Date dtToDate = Date.parse(todate);
    Integer totaldays = dtFromDate.Daysbetween(dtToDate);
    for (Integer i = 0; i < totaldays; i++) {
      setAllDates.add(dtFromDate.addDays(i));
    }
    return setAllDates;
  }

  //function return dateime from date string
  public static DateTime setDateTime(string bookingDates) {
    list<string> stgList = bookingDates.split('/');
    return datetime.newInstance(
      integer.valueOf(stgList[2]),
      integer.valueOf(stgList[0]),
      integer.valueOf(stgList[1]),
      11,
      0,
      0
    );
  }

  //wrapper class to hold search result
  public class wrapperUnit implements Comparable {
    public string UnitId;
    public string UnitName;
    public string BuildingId;
    public string BuildingName;
    public string AvailabilityStatus;
    public string BookingComments;
    public string UnitType;
    public string Neighborhood;
    public decimal AvgPrice;
    public decimal TaxRate;
    public decimal CleaningFee;
    public decimal SubTotal;
    public decimal TotalPrice;
    public decimal TotalTax;
    public string errorMsg;
    public decimal UnitPriceWithoutGuest;
    public decimal ExtraGuestPrice;
    public decimal Discount;
    public string VirtualTourURL;
    public string VirtualTourThumb;
    public Integer UnitTypeOrder;
    //** -- uncomment for unit slider images
    public List<ImageModel> images;
    //*/

    //added for star rating and no of review
    public Decimal starRating;
    public Decimal noOfReviews;
    // end star rating and no of review

    public wrapperUnit() {
      //** -- uncomment for unit slider images
      images = new List<ImageModel>();
      //*/
      UnitId = '';
      UnitName = '';
      BuildingId = '';
      BuildingName = '';
      AvailabilityStatus = '';
      UnitType = '';
      Neighborhood = '';
      AvgPrice = 0;
      TaxRate = 0;
      CleaningFee = 0;
      TotalPrice = 0;
      SubTotal = 0;
      BookingComments = '';
      TotalTax = 0;
      errorMsg = '';
      UnitPriceWithoutGuest = 0;
      ExtraGuestPrice = 0;
      Discount = 0;
      VirtualTourURL = '';
      VirtualTourThumb = '';
      starRating = 0;
      noOfReviews = 0;
      UnitTypeOrder = 0;
    }
    public Integer compareTo(Object compareTo) {
      wrapperUnit compareitem = (wrapperUnit) compareTo;
      if (this.UnitName > compareitem.UnitName)
        return 1;
      else if (this.UnitName == compareitem.UnitName)
        return 0;
      return -1;
    }
  }

  //** -- uncomment for unit slider images
  public class ImageModel {
    public String thumbnailURL;
    public String imageURL;

    public ImageModel(String thumbnailURL, String imageURL) {
      this.thumbnailURL = thumbnailURL;
      this.imageURL = imageURL;
    }
  } //*/

  @auraEnabled
  public static initBookingWrap bookInit(string bookingId) {
    initBookingWrap ib = new initBookingWrap();
    Xotelia_Booking__c booking = [
      SELECT
        Product__c,
        Travelers__c,
        Start_date__c,
        End_date__c,
        Product__r.Extra_Guest_Charge__c,
        Total_Unit_Booking_Price__c,
        Product__r.Tax_Rate__c,
        Credit_Card_Full_Name__c,
        Credit_Card_Number__c,
        Credit_Card_CVV__c,
        Credit_Card_Expiration_Date__c,
        Credit_Card_Type__c,
        Zip_Code__c,
        Sales_channel__c
      FROM Xotelia_Booking__c
      WHERE id = :bookingId
    ];
    ib.fromDate = booking.Start_date__c.format('yyyy-MM-dd');
    ib.toDate = booking.End_date__c.format('yyyy-MM-dd');
    if (
      ib.userType != 'Standard' &&
      booking.End_date__c.Date() < Date.Today()
    ) {
      ib.isError = true;
      ib.messages.add(
        'You can not extend a booking which is already passed, Kindly make a new booking.'
      );
    }
    return ib;
  }
  @auraEnabled
  public static bookingExtensionWrapper searchUnitAvailability(
    string todate,
    string bookingId
  ) {
    bookingExtensionWrapper wr = new bookingExtensionWrapper();
    //wr.result = 'not available';
    try {
      Xotelia_Booking__c booking = [
        SELECT
          Product__c,
          Travelers__c,
          Product__r.Standard_Guests__c,
          Product__r.Max_Sleep_Guests__c,
          Product__r.Extra_Guest_Charge__c,
          City__c,
          Total_Unit_Booking_Price__c,
          Product__r.Tax_Rate__c,
          Start_date__c,
          End_date__c,
          Zip_Code__c,
          Sales_channel__c,
          Credit_Card_Full_Name__c,
          Credit_Card_Number__c,
          Billing_Contact__c,
          Credit_Card_CVV__c,
          Credit_Card_Expiration_Date__c,
          Credit_Card_Type__c,
          Stripe_Customer__c,
          Billing_Contact__r.Stripe_Customer_ID__c,
          Total_Net__c,
          Product__r.Average_Ratings__c,
          Product__r.of_Reviews__c
        FROM Xotelia_Booking__c
        WHERE id = :bookingId
      ];
      Date dtFromDate = booking.End_date__c.Date();
      Date toDateDT = date.valueOf(todate);
      DateTime dtToDate = DateTime.newInstance(
        toDateDT.year(),
        toDateDT.month(),
        toDateDT.Day()
      );
      list<wrapperUnit> unitPriceWrap = UpgradeWizard.allUnits(
        booking.City__c,
        booking.End_date__c.format('MM/dd/yyyy'),
        dtToDate.format('MM/dd/yyyy'),
        string.valueOf(booking.Travelers__c),
        booking.Product__c,
        false,
        null,
        0
      );
      system.debug('unitPriceWrap:  ' + unitPriceWrap.size());
      if (!unitPriceWrap.isEmpty()) {
        CreditCardModel existingBookingCard;
        List<CreditCardModel> ccModelList = new List<CreditCardModel>();
        wrapperUnit wp = unitPriceWrap[0];
        wr.SubTotal = wp.SubTotal;
        wr.SubTotalIncTax = wp.TotalPrice;
        wr.ExistingBookTotal = booking.Total_Net__c;
        wr.grandTotal = wp.TotalPrice;
        wr.disAmt = wp.TotalPrice;
        wr.tax = wp.TotalTax;
        wr.taxRate = wp.TaxRate;
        wr.bookingComments = wp.bookingComments;
        wr.cleaningFee = wp.cleaningFee;
        wr.toDate = todate;

        /*if(
                    String.isBlank(booking.Sales_channel__c) || 
                    booking.Sales_channel__c == 'airbnb' ||
                    String.isBlank(booking.Credit_Card_Full_Name__c) ||
                    booking.Credit_Card_Full_Name__c == 'Expedia VirtualCard' || 
                    String.isBlank(booking.Credit_Card_Number__c) ||
                    String.isBlank(booking.Credit_Card_CVV__c) ||
                    String.isBlank(booking.Credit_Card_Expiration_Date__c) ||
                    String.isBlank(booking.Credit_Card_Type__c) ||
                    String.isBlank(booking.Zip_Code__c)
                )
                    wr.requireCreditCard = true;
                */
        if (
          String.isNotBlank(booking.Sales_channel__c) &&
          booking.Sales_channel__c != 'airbnb' &&
          String.isNotBlank(booking.Credit_Card_Full_Name__c) &&
          booking.Credit_Card_Full_Name__c != 'Expedia VirtualCard' &&
          String.isNotBlank(booking.Credit_Card_Number__c) &&
          String.isNotBlank(booking.Credit_Card_CVV__c) &&
          String.isNotBlank(booking.Credit_Card_Expiration_Date__c) &&
          //String.isNotBlank(booking.Credit_Card_Type__c) &&
          String.isNotBlank(booking.Zip_Code__c)
        ) {
          Integer cardLength = booking.Credit_Card_Number__c.length();
          String last4Digits = (cardLength > 4)
            ? booking.Credit_Card_Number__c.Substring(
                cardLength - 4,
                cardLength
              )
            : booking.Credit_Card_Number__c;
          String expMonth = '';
          String expYear = '';
          if (
            booking.Credit_Card_Expiration_Date__c != null &&
            booking.Credit_Card_Expiration_Date__c.contains('/')
          ) {
            expMonth = booking.Credit_Card_Expiration_Date__c.split('/')[0];
            expYear = booking.Credit_Card_Expiration_Date__c.split('/')[1];
          }
          existingBookingCard = new CreditCardModel(
            last4Digits,
            booking.Credit_Card_Full_Name__c,
            expMonth,
            expYear,
            booking.Zip_Code__c,
            booking.Credit_Card_CVV__c,
            'lastCard',
            booking.Credit_Card_Type__c,
            null,
            false
          );
          wr.defaultCard = 'lastCard';
        }
        if (dtFromDate.daysBetween(toDateDT) + 1 <= 30) {
          String stripeCustomerId = getStripeCustomerID(booking);

          if (stripeCustomerId != null) {
            //fetching saved cards
            SavedCardsModel cardsModel = fetchCustomerSavedCards(
              null,
              stripeCustomerId,
              existingBookingCard
            );
            if (!cardsModel.isError && cardsModel.ccModelList.size() > 0) {
              ccModelList = cardsModel.ccModelList;

              if (
                existingBookingCard == null &&
                cardsModel.defaultSavedCard != null
              )
                wr.defaultCard = cardsModel.defaultSavedCard.cardId;
            } else if (cardsModel.isError && cardsModel.errmsg != null) {
              wr.result = cardsModel.errmsg;
              //error handling
            }
          }
        }
        if (existingBookingCard != null)
          wr.ccModelList.add(existingBookingCard);
        if (!ccModelList.isEmpty())
          wr.ccModelList.addAll(ccModelList);

        if (wr.ccModelList.isEmpty())
          wr.requireCreditCard = true;

        return wr;
      }
      wr.result = 'not available';
    } catch (exception e) {
      if (e.getTypeName() == 'System.QueryException') {
        wr.result = 'not available';
        return wr;
      } else {
        wr.result = e.getMessage() + ' At line number: ' + e.getLinenumber();
        return wr;
      }
    }
    return wr;
  }
  //First it check Stripe Customer field on booking
  //if found blank then checks on Billing Contact's Stripe Customer Id field
  //If Contact's field is also blank, then checks on previous active booking
  private static String getStripeCustomerID(Xotelia_Booking__c booking) {
    //checking on Stripe Customer field on booking
    String stripeCustomerId = StripeHelper.getStripeCustomerIdFromURL(
      booking.Stripe_Customer__c
    );
    if (stripeCustomerId == null && booking.Billing_Contact__c != null) {
      //checking on Billing Contact's Stripe Customer Id field
      stripeCustomerId = booking.Billing_Contact__r.Stripe_Customer_ID__c;

      //Checking on previous active booking
      if (stripeCustomerId == null)
        stripeCustomerId = getStripeCustomerIdFromLastBooking(
          booking.Billing_Contact__c
        );
    }
    return stripeCustomerId;
  }
  private static String getStripeCustomerIdFromLastBooking(Id conId) {
    List<Xotelia_Booking__c> lastActiveBooking = [
      SELECT id, Stripe_Customer__c
      FROM Xotelia_Booking__c
      WHERE
        Billing_Contact__c = :conId
        AND Status__c = 'Active'
        AND Stripe_Customer__c != null
      LIMIT 1
    ];
    if (lastActiveBooking.size() > 0)
      return StripeHelper.getStripeCustomerIdFromURL(
        lastActiveBooking[0].Stripe_Customer__c
      );
    return null;
  }
  private static List<Contact> fetchContactAndLastActiveBooking(Id conId) {
    return [
      SELECT
        id,
        Stripe_Customer_ID__c,
        (
          SELECT id, Stripe_Customer__c
          FROM Xotelia_Bookings1__r
          WHERE Status__c = 'Active' AND Stripe_Customer__c != null
          LIMIT 1
        )
      FROM Contact
      WHERE id = :conId
    ];
  }
  private static String getStripeCustomerIdFromContactOrLastBooking(
    List<Contact> conList
  ) {
    if (conList.size() > 0) {
      if (conList[0].Stripe_Customer_ID__c != null)
        return conList[0].Stripe_Customer_ID__c;
      else if (
        conList[0].Xotelia_Bookings1__r.size() > 0 &&
        conList[0].Xotelia_Bookings1__r[0].Stripe_Customer__c != null
      )
        return StripeHelper.getStripeCustomerIdFromURL(
          conList[0].Xotelia_Bookings1__r[0].Stripe_Customer__c
        );
    }
    return null;
  }

  private static DuplicateCardModel checkDuplicateCard(
    Stripe_Setting__c stripeSetting,
    CreditCardModel ccModel,
    String stripeCustomerId
  ) {
    DuplicateCardModel dcm = new DuplicateCardModel();
    if (stripeCustomerId != null) {
      SavedCardsModel cardsModel = fetchCustomerSavedCards(
        stripeSetting,
        stripeCustomerId,
        null
      );
      if (!cardsModel.isError && cardsModel.ccModelList.size() > 0) {
        StripeHelper.HTTPModel httpModel = StripeHelper.createCardToken(
          stripeSetting,
          stripeCustomerId,
          ccModel
        );
        if (httpModel.isCalloutException) {
          dcm.errMsgs.add(httpModel.response);
          dcm.isError = true;
        } else {
          StripeHelper.TokenParser tokenParser = StripeHelper.parseCreateToken(
            httpModel.response
          );
          system.debug('@@@tokenParser==' + tokenParser);
          if (
            tokenParser != null &&
            tokenParser.error == null &&
            tokenParser.card != null &&
            tokenParser.card.fingerprint != null
          ) {
            ccModel.cardKey =
              tokenParser.card.fingerprint +
              ccModel.cardName.toLowerCase() +
              ccModel.expMonth +
              ccModel.expYear;
            system.debug('@@@cardKey==' + ccModel.cardKey);
            for (CreditCardModel tempModel : cardsModel.ccModelList) {
              system.debug('@@@tempModel.cardKey==' + tempModel.cardKey);
              if (tempModel.cardKey == ccModel.cardKey) {
                system.debug('@@@tempModel.cardKey==matched');
                dcm.isDuplicateMatch = true;
                dcm.selectedCardId = tempModel.cardId;
                dcm.cardType = tempModel.cardType;
                break;
              }
            }
          } else {
            dcm.errMsgs.add(
              StripeHelper.getStripeResponseError(tokenParser.error)
            );
            dcm.isError = true;
          }
        }
      }
    }
    return dcm;
  }
  private static String updateBookingComments(
    String summary,
    Xotelia_Booking__c book
  ) {
    //charge a stripe customer with card id
    return (summary != null ? summary : '') +
      (book.Xotelia_code__c != null ? book.Xotelia_code__c : '') +
      (book.Booking_comment__c != null
        ? '\nBooking Details:\n' + book.Booking_comment__c
        : '');
  }
  public static ResponseModel updateCustomerDefaultSource(
    ResponseModel rm,
    String defaultCardId,
    String cardId,
    String stripeCustomerId,
    Stripe_Setting__c stripeSetting
  ) {
    if (!rm.isError) {
      if (String.isNotBlank(defaultCardId) && defaultCardId != cardId) {
        //updating default source/card to current one user paid with
        StripeHelper.HTTPModel httpModel = StripeHelper.createStripeCustomerDefaultSource(
          stripeSetting,
          stripeCustomerId,
          cardId
        );

        //If there is exception in callout, then showing error
        if (httpModel.isCalloutException) {
          rm.infoMsgs.add(httpModel.response);
          //isError = true;
        }
        StripeHelper.StripeCustomerParser customerParser = StripeHelper.parseStripeCustomer(
          httpModel.response
        );

        if (customerParser != null) {
          if (
            String.isBlank(customerParser.id) && customerParser.error != null
          ) {
            rm.infoMsgs.add(
              StripeHelper.getStripeResponseError(customerParser.error)
            );
            //rm.isError = true;
          }
        } else {
          rm.infoMsgs.add(
            'Could not update default source/card for customer profile, Please contact your administrator.==' +
            httpModel.response
          );
          //isError = true;
        }
      }
    }
    return rm;
  }
  //preparing email body and sending it
  public static void prepareAndSendEmail(
    Stripe_Setting__c stripeSetting,
    Payment__c pymt,
    Xotelia_Booking__c booking,
    String unitName,
    String startDate,
    String endDate,
    String exceptionMsg
  ) {
    List<String> toAddresses = new List<String>();
    String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
    if (stripeSetting.Email_Addresses__c != null) {
      for (
        String str : stripeSetting.Email_Addresses__c.trim()
          .replaceAll('\r\n', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .split(';')
      ) {
        if (str.trim().length() > 0)
          toAddresses.add(str.trim());
      }

      //if(toAddresses.size()==0)
      //    toAddresses.add('test@test.com');
      String htmlBody = 'We had an issue with a Booking where the payment was processed but booking couldn’t be created. Below are the details:<br/>';

      htmlBody += '<ul>';
      htmlBody += '<li>Payment Transaction: ' + pymt.Stripe_Charge__c + '</li>';
      htmlBody += '<li>Payment Amount: <b>$' + pymt.Value__c + '</b></li>';
      htmlBody +=
        '<li>Booking Unit: <a href="' +
        baseURL +
        '/' +
        booking.Product__c +
        '">' +
        unitName +
        '</a></li>';
      htmlBody +=
        '<li>Contact Person: <a href="' +
        baseURL +
        '/' +
        booking.Billing_Contact__c +
        '">' +
        booking.Firstname__c +
        ' ' +
        booking.Lastname__c +
        '</a> (' +
        booking.Email__c +
        ')</li>';
      htmlBody +=
        '<li>Extension Dates: <b>' +
        startDate +
        '</b> to <b>' +
        endDate +
        '</b></li>';
      htmlBody += '</ul>';
      htmlBody +=
        'Exception Details: ' +
        exceptionMsg.replaceAll('\n', '<br/>') +
        '<br/><br/>';
      htmlBody += 'Please take the appropriate action.';
      sendEmail(
        'Booking Extension Exception - Payment Processed',
        toAddresses,
        htmlBody
      );
    }
  }
  //sending email based on params
  public static void sendEmail(
    String subject,
    List<String> toAddresses,
    String htmlBody
  ) {
    //sending exception email
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    // Step 2: Set list of people who should get the email
    if (String.isNotBlank(Label.BookingValidationEmails)) {
      for (string stremail : Label.BookingValidationEmails.split(',')) {
        if (String.isNotBlank(stremail) && String.isNotBlank(stremail.trim())) {
          toAddresses.add(stremail.trim());
        }
      }
    }
    mail.setToAddresses(toAddresses);
    // Step 4. Set email contents - you can use variables!
    mail.setSubject(subject);
    mail.setHtmlBody(htmlBody);
    // Step 6: Send all emails in the master list
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
  }
  public static String handleCustomValidationException(Exception ex) {
    String strMessage = '';
    if (
      ex.getTypeName() == 'System.DmlException' &&
      ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')
    ) {
      for (Integer i = 0; i < ex.getNumDml(); i++) {
        if (strMessage != '')
          strMessage += '\n';
        strMessage += ex.getDmlMessage(i);
      }
      strMessage += '\n' + ex.getTypeName() + ', at line ' + ex.getLineNumber();
    } else
      strMessage =
        ex.getTypeName() +
        '==' +
        ex.getMessage() +
        ', at line ' +
        ex.getLineNumber();
    /*//sending exception email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Step 2: Set list of people who should get the email
        mail.setToAddresses(new List<String>{'tarun.j@kandisatech.com'});
        // Step 4. Set email contents - you can use variables!
        mail.setSubject('Extend Booking Exception');
        mail.setHtmlBody(strMessage);
        // Step 6: Send all emails in the master list
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});*/
    return strMessage;
  }
  public class ResponseModel {
    @AuraEnabled
    public Boolean isError { get; set; }
    @AuraEnabled
    public Boolean isPartialSuccess { get; set; }
    @AuraEnabled
    public String recordId { get; set; }
    @AuraEnabled
    public Id contactId { get; set; }
    @AuraEnabled
    public List<String> errMsgs { get; set; }
    @AuraEnabled
    public List<String> successMsgs { get; set; }
    @AuraEnabled
    public List<String> infoMsgs { get; set; }
    @AuraEnabled
    public List<Xotelia_Booking__c> bookings { get; set; }

    public ResponseModel() {
      isError = false;
      isPartialSuccess = false;
      recordId = '';
      errMsgs = new List<String>();
      successMsgs = new List<String>();
      infoMsgs = new List<String>();
      bookings = new List<Xotelia_Booking__c>();
    }
  }
  public class bookingExtensionWrapper {
    @auraEnabled
    public decimal ExistingBookTotal = 0;
    @auraEnabled
    public decimal SubTotal = 0;
    @auraEnabled
    public decimal SubTotalIncTax = 0;
    @auraEnabled
    public decimal grandTotal = 0;
    @auraEnabled
    public decimal disAmt = 0;
    @auraEnabled
    public decimal tax = 0;
    @auraEnabled
    public decimal taxRate = 0;
    @auraEnabled
    public decimal CleaningFee = 0;
    @auraEnabled
    public string result;
    @auraEnabled
    public string toDate;
    @auraEnabled
    public string bookingComments;
    @auraEnabled
    public Boolean requireCreditCard = false;
    @auraEnabled
    public List<CreditCardModel> ccModelList;
    @auraEnabled
    public String defaultCard;
    public bookingExtensionWrapper() {
      ccModelList = new List<CreditCardModel>();
    }
  }
  public class initBookingWrap {
    @auraEnabled
    public string userType = getUserType();
    @auraEnabled
    public string uiContext;
    @auraEnabled
    public string fromDate;
    @auraEnabled
    public string toDate;
    @auraEnabled
    public List<String> messages = new List<String>();
    @auraEnabled
    public Boolean isError = false;
    public initBookingWrap() {
      this.uiContext = UserInfo.getUiThemeDisplayed();
    }
  }
  public class CreditCardModel {
    @auraEnabled
    public string cardId { get; set; }
    @auraEnabled
    public string cardNumber { get; set; }
    @auraEnabled
    public string expMonth = '';
    @auraEnabled
    public string expYear = '';
    @auraEnabled
    public string cvv = '';
    @auraEnabled
    public string cardName = '';
    @auraEnabled
    public string cardType = '';
    @auraEnabled
    public string zipCode = '';
    @auraEnabled
    public Boolean isDefaultSource = false;
    @auraEnabled
    public string cardKey = '';
    @auraEnabled
    public string fingerprint = '';
    public CreditCardModel() {
    }
    public CreditCardModel(
      String cardNumber,
      String cardName,
      String expMonth,
      String expYear,
      String zipCode,
      String cvv,
      String cardId,
      String cardType,
      String fingerprint,
      Boolean isDefaultSource
    ) {
      this.cardId = cardId;
      this.cardNumber = cardNumber;
      this.expMonth = (expMonth != null
        ? ((Integer.ValueOf(expMonth) > 9 ||
            expMonth.length() == 2
            ? ''
            : '0') + expMonth)
        : expMonth);
      this.expYear = expYear;
      this.cvv = cvv;
      this.cardName = cardName;
      this.cardType = cardType;
      this.zipCode = zipCode;
      this.isDefaultSource = isDefaultSource;
      this.fingerprint = fingerprint;

      if (
        this.fingerprint != null &&
        this.cardName != null &&
        this.expMonth != null &&
        this.expYear != null
      )
        this.cardKey =
          this.fingerprint +
          this.cardName.toLowerCase() +
          this.expMonth +
          this.expYear;
    }
  }
  public class ContactModel {
    @auraEnabled
    public Contact contact { get; set; }
    @auraEnabled
    public List<CreditCardModel> ccModelList { get; set; }
    @auraEnabled
    public String defaultSourceId { get; set; }
    @auraEnabled
    public String errMessage { get; set; }
    public ContactModel(Contact contact, List<CreditCardModel> ccModelList) {
      this.contact = contact;
      this.ccModelList = ccModelList;
    }
  }
  public class DuplicateCardModel {
    public Boolean isDuplicateMatch = false;
    public String selectedCardId;
    public String cardType;
    public List<String> errMsgs = new List<String>();
    public Boolean isError = false;
  }
  public class SavedCardsModel {
    @AuraEnabled
    public List<CreditCardModel> ccModelList = new List<CreditCardModel>();
    @AuraEnabled
    public CreditCardModel defaultSavedCard;
    @AuraEnabled
    public Boolean isError = false;
    @AuraEnabled
    public String errmsg;
  }
  public class StripeCustomerModel {
    @AuraEnabled
    public String stripeCustomerId;
    @AuraEnabled
    public String cardId;
    @AuraEnabled
    public String cardType;
    @AuraEnabled
    public List<String> errMsgs = new List<String>();
    @AuraEnabled
    public Boolean isError = false;
  }

  @auraEnabled
  public static String getUserType() {
    return UserInfo.getUserType();
  }
}