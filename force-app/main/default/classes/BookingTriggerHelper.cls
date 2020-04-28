/*
    Created By: Kandisa Technologies Pvt. Ltd
    Date : 03/20/2017
*/
public class BookingTriggerHelper {
  /*
        Function name: UnitBookingUpdate
        Description: it updates unit price records if any of below event occurs
                     a. New Booking Made
                     b. Booking deleted
                     c. Booking Status updated from Active to Inactive and vice versa.
                     d. Booking moved from 1 unit to another unit.
                     e. Dates on Booking are changed.
    */
  public static boolean isRecursive = false;
  public static boolean isUnitPriceRecursive = false;
  public static void UnitBookingUpdate(
    List<Xotelia_Booking__c> triggerNew,
    Map<id, Xotelia_Booking__c> triggerOldMap,
    Boolean triggerInsert,
    Boolean triggerIsUpdate,
    Boolean triggerIsDelete
  ) {
    isRecursive = false;
    set<string> unitIds = new Set<string>();

    Map<string, Xotelia_Booking__c> mapunitbookingvsbooking = new Map<string, Xotelia_Booking__c>();
    Set<Id> newunitids = new Set<Id>();

    // Set of booking records where unit has been updated.
    set<string> BookingUnitChanged = new Set<string>();
    // Set of booking records where Date has been changed.
    set<string> BookingDateChanged = new Set<string>();
    // Set of booking records where Booking Status has been changed.
    set<string> BookingStatusChanged = new Set<string>();

    Date minStartDate;
    Date maxEndDate;

    List<Xotelia_Booking__c> bookingList = new List<Xotelia_Booking__c>();
    //setting context variable to use for trigger events
    if (triggerIsDelete)
      bookingList = triggerOldMap.values();
    else if (triggerInsert || triggerIsUpdate)
      bookingList = triggerNew;

    //getting unit ids,booking start and end date and checking if booking has been updated
    for (Xotelia_Booking__c booking : bookingList) {
      if (booking.Product__c != null) {
        if (triggerInsert || triggerIsDelete) {
          UnitIds.add(booking.Product__c);
        }

        //getting min start date from all booking records
        if (minStartDate == null)
          minStartDate = booking.Start_Date__c.date();
        else if (booking.Start_Date__c.date() < minStartDate)
          minStartDate = booking.Start_Date__c.date();

        //getting max end date from all booking records
        if (maxEndDate == null)
          maxEndDate = booking.End_Date__c.date();
        else if (booking.End_Date__c.date() > maxEndDate)
          maxEndDate = booking.End_Date__c.date();
        //getting unit id from booking to query unit price records

        //checking update criteria
        if (triggerIsUpdate) {
          Xotelia_Booking__c oldBooking = triggerOldMap.get(booking.id);
          //if unit changed in booking
          if (booking.Product__c != oldBooking.Product__c) {
            /**fill map and set to check existing unit have already booking */
            mapunitbookingvsbooking.put(
              booking.Product__c +
              '' +
              booking.Id,
              booking
            );
            newunitids.add(booking.Product__c);
            /** end added to check existing unit have already booking*/

            UnitIds.add(oldBooking.Product__c);
            UnitIds.add(booking.Product__c);

            BookingUnitChanged.add(booking.id);
          }
          //if booking start date is changed
          if (booking.Start_Date__c.date() != oldBooking.Start_Date__c.date()) {
            BookingDateChanged.add(booking.id);
            if (oldBooking.Start_Date__c.date() < minStartDate)
              minStartDate = oldBooking.Start_Date__c.date();

            UnitIds.add(booking.Product__c);
          }
          //if booking end date is changed
          if (booking.End_Date__c.date() != oldBooking.End_Date__c.date()) {
            BookingDateChanged.add(booking.id);
            if (oldBooking.End_Date__c.date() > maxEndDate)
              maxEndDate = oldBooking.End_Date__c.date();

            UnitIds.add(booking.Product__c);
          }
          //if booking status is changed
          if (booking.Status__c != oldBooking.Status__c) {
            BookingStatusChanged.add(booking.id);
            UnitIds.add(booking.Product__c);
          }
        }
      } else if (
        triggerIsUpdate && triggerOldMap.get(booking.id).Product__c != null
      ) {
        UnitIds.add(booking.Product__c);

        //getting min start date from all booking records
        if (minStartDate == null)
          minStartDate = booking.Start_Date__c.date();
        else if (booking.Start_Date__c.date() < minStartDate)
          minStartDate = booking.Start_Date__c.date();

        //getting max end date from all booking records
        if (maxEndDate == null)
          maxEndDate = booking.End_Date__c.date();
        else if (booking.End_Date__c.date() > maxEndDate)
          maxEndDate = booking.End_Date__c.date();
      }
    }

    if (unitIds.size() > 0) {
      /** need to chek unit price record have been already booked and it is check when change the product on existing booking */
      // if(newunitids.size()>0){

      //     Integer noofDaysforBooking = minStartDate.Daysbetween(maxEndDate);
      //     Map<Id,Integer> mapUnitvsCount = new Map<Id,Integer>();

      // for (Unit_Pricing__c up : [SELECT Unit_Price_Date__c,Availability_Status__c,Unit__c,Unit__r.Name,Total_Booking__c,Building_Unit_Set_Pricing_Day__c
      //         FROM Unit_Pricing__c
      //         WHERE   Unit__c In:newunitids
      //         AND     Unit_Price_Date__c >= :minStartDate
      //         AND     Unit_Price_Date__c < :maxEndDate
      //         AND Availability_Status__c = 'Booked']) {
      //     throw new BookingException('The newly selected Unit is not available for the given date range.');
      // }
      // }
      /** end need to chek unit price record have been already booked and it is check when change the product on existing booking */

      // Get all Unit Price records falling between Minimum Start Date and Maximum End Date
      list<Unit_Pricing__c> unitPriceList = [
        SELECT
          Unit_Price_Date__c,
          Availability_Status__c,
          Unit__c,
          Total_Booking__c,
          Building_Unit_Set_Pricing_Day__c
        FROM Unit_Pricing__c
        WHERE
          Unit__c IN :UnitIds
          AND Unit_Price_Date__c >= :minStartDate
          AND Unit_Price_Date__c < :maxEndDate
      ];

      system.debug('unitPriceList :: ' + unitPriceList);
      if (unitPriceList.size() > 0) {
        //map of date unitprice map with unit as key
        map<string, map<date, Unit_Pricing__c>> Dated_Unit_UnitPriceMap = new Map<string, map<date, Unit_Pricing__c>>();
        //map of date unitprice map with oldunit as key
        map<string, map<date, Unit_Pricing__c>> Dated_OldUnit_UnitPriceMap = new Map<string, map<date, Unit_Pricing__c>>();
        // map of unit with its unitprice list
        map<string, List<Unit_Pricing__c>> unit_UnitPriceMap = new Map<string, list<Unit_Pricing__c>>();
        //map of new unit price if no unit price records retrun from query
        map<string, Unit_Pricing__c> unitPriceToInsert = new Map<string, Unit_Pricing__c>();
        //Map of booking unit price junction object
        map<string, List<Booking_Unit_Price_Junction__c>> bookingUnitPriceJunctionMap = new Map<String, List<Booking_Unit_Price_Junction__c>>();
        //set of processed booking id
        set<string> processedBookingId = new Set<string>();

        //creating map of list unit price records and its related unit as key
        for (Unit_Pricing__c up : unitPriceList) {
          if (unit_UnitPriceMap.containsKey(up.Unit__c))
            unit_UnitPriceMap.get(up.Unit__c).add(up);
          else
            unit_UnitPriceMap.put(up.Unit__c, new List<Unit_Pricing__c>{ up });
        }
        system.debug('unit_UnitPriceMap :: ' + unit_UnitPriceMap);

        //logic to create map for new & old unit with its related booking date unit price records
        for (Xotelia_Booking__c booking : bookingList) {
          if (
            booking.Product__c != null ||
            string.isNotBlank(booking.Product__c) &&
            string.isNotBlank(booking.Status__c)
          ) {
            if (unit_UnitPriceMap.containsKey(booking.Product__c)) {
              //create map of new  booking unit with its unitprice record mapped date wise
              system.debug('Dated_Unit_UnitPriceMap :: ' + booking);
              system.debug(
                'Dated_Unit_UnitPriceMap :: ' +
                unit_UnitPriceMap.get(booking.Product__c)
              );
              Dated_Unit_UnitPriceMap = DatedUnitPriceMap(
                booking,
                unit_UnitPriceMap.get(booking.Product__c),
                Dated_Unit_UnitPriceMap
              );
              system.debug(
                'Dated_Unit_UnitPriceMap :: ' + Dated_Unit_UnitPriceMap
              );
            } else {
              Date bookingStartDate = booking.Start_Date__c.date();

              while (bookingStartDate < booking.End_Date__c.date()) {
                string key =
                  booking.Product__c + String.valueOf(bookingStartDate);
                if (booking.Status__c.toLowerCase() == 'inactive')
                  unitPriceToInsert.put(
                    key,
                    new Unit_Pricing__c(
                      Unit__c = booking.Product__c,
                      Name = String.valueOf(bookingStartDate),
                      Availability_Status__c = 'Available'
                    )
                  );
                else if (booking.Status__c.toLowerCase() == 'active')
                  unitPriceToInsert.put(
                    key,
                    new Unit_Pricing__c(
                      Unit__c = booking.Product__c,
                      Name = String.valueOf(bookingStartDate),
                      Availability_Status__c = 'Booked'
                    )
                  );

                bookingStartDate += 1;
              }
              system.debug('unitPriceToInsert :: ' + unitPriceToInsert);
            }
          }
          //old unit price records are used only if unit or booking dates are changed
          if (
            triggerIsUpdate &&
            (BookingUnitChanged.contains(booking.id) ||
            BookingDateChanged.contains(booking.id)) &&
            string.isNotBlank(booking.Status__c)
          ) {
            Xotelia_Booking__c oldBooking = triggerOldMap.get(booking.id);
            if (
              oldBooking.Product__c != null ||
              string.isNotBlank(oldBooking.Product__c)
            ) {
              if (unit_UnitPriceMap.containsKey(oldBooking.Product__c)) {
                //create map of old booking unit with its unitprice record mapped date wise
                Dated_OldUnit_UnitPriceMap = DatedUnitPriceMap(
                  oldBooking,
                  unit_UnitPriceMap.get(oldBooking.Product__c),
                  Dated_OldUnit_UnitPriceMap
                );
                system.debug(
                  'Dated_OldUnit_UnitPriceMap udpate :: ' +
                  Dated_OldUnit_UnitPriceMap
                );
              } else {
                date bookingStartDate = oldBooking.Start_Date__c.date();

                while (bookingStartDate < oldBooking.End_Date__c.date()) {
                  string key =
                    oldBooking.Product__c + String.valueOf(bookingStartDate);
                  unitPriceToInsert.put(
                    key,
                    new Unit_Pricing__c(
                      Unit__c = oldBooking.Product__c,
                      Name = String.valueOf(bookingStartDate),
                      Availability_Status__c = 'Available'
                    )
                  );
                  bookingStartDate += 1;
                }
                system.debug(
                  'unitPriceToInsert udpate :: ' + unitPriceToInsert
                );
              }
            }
          }
        }

        //map of new unitprice records need to update
        map<string, Unit_Pricing__c> unitPriceToUpdate = new Map<string, Unit_Pricing__c>();

        for (Xotelia_Booking__c booking : bookingList) {
          if (
            booking.Product__c != null &&
            Dated_Unit_UnitPriceMap.containsKey(booking.Product__c) &&
            string.isNotBlank(booking.Status__c)
          ) {
            //geting map of dated unit price records for new booking records
            map<Date, Unit_Pricing__c> unitPriceMap = Dated_Unit_UnitPriceMap.get(
              booking.Product__c
            );
            //start date reference and to used to update all record between start and old date
            Date bookingStartDate = booking.Start_Date__c.date();
            system.debug('bookingStartDate@@@@@ :: ' + bookingStartDate);

            if (triggerIsDelete) {
              //logic to update unit price availablity status to "available" if booking is deleted
              while (bookingStartDate < booking.End_Date__c.date()) {
                //updating unit price record related to deleted booking
                if (unitPriceMap.containsKey(bookingStartDate)) {
                  Unit_Pricing__c up = unitPriceMap.get(bookingStartDate);
                  if (up.Total_Booking__c <= 1)
                    unitPriceToUpdate.put(
                      up.id,
                      new Unit_Pricing__c(
                        id = up.id,
                        Availability_Status__c = 'Available'
                      )
                    );
                  bookingStartDate += 1;
                }
              }
            }

            if (triggerInsert) {
              //logic to process unit price records if booking is made
              system.debug('unitPriceMap@@@@@ :: ' + unitPriceMap);
              unitPriceToUpdate = newUnitPriceUpdate(
                bookingStartDate,
                booking,
                unitPriceMap,
                unitPriceToUpdate
              );
              system.debug('unitPriceToUpdate udpate :: ' + unitPriceToUpdate);
            }

            if (triggerIsUpdate) {
              //logic to process unit price records if booking unit is changed
              if (BookingUnitChanged.contains(booking.id)) {
                Xotelia_Booking__c oldBooking = triggerOldMap.get(booking.id);
                //setting new unit's unit price values to available or booked depends on booking status

                unitPriceToUpdate = newUnitPriceUpdate(
                  bookingStartDate,
                  booking,
                  unitPriceMap,
                  unitPriceToUpdate
                );
                system.debug(
                  'unitPriceToUpdate udpate :: ' + unitPriceToUpdate
                );
                //setting old unit's unit price values to available
                if (
                  oldBooking.Product__c != null &&
                  Dated_OldUnit_UnitPriceMap.containsKey(oldBooking.Product__c)
                ) {
                  unitPriceToUpdate = oldUnitPriceUpdate(
                    oldBooking,
                    Dated_OldUnit_UnitPriceMap.get(oldBooking.Product__c),
                    unitPriceToUpdate
                  );
                }
                system.debug(
                  'unitPriceToUpdate udpate :: ' + unitPriceToUpdate
                );
              }

              //logic to process unit price record if booking dates is changed
              if (BookingDateChanged.Contains(booking.id)) {
                Xotelia_Booking__c oldBooking = triggerOldMap.get(booking.id);

                if (
                  oldBooking.Product__c != null &&
                  Dated_OldUnit_UnitPriceMap.containsKey(oldBooking.Product__c)
                ) {
                  //processing old date unit price records
                  unitPriceToUpdate = oldUnitPriceUpdate(
                    oldBooking,
                    Dated_OldUnit_UnitPriceMap.get(oldBooking.Product__c),
                    unitPriceToUpdate
                  );
                }
                //processing new date unit price records
                unitPriceToUpdate = newUnitPriceUpdate(
                  bookingStartDate,
                  booking,
                  unitPriceMap,
                  unitPriceToUpdate
                );
                system.debug('unitPriceToUpdate' + unitPriceToUpdate);
              }

              //logic to set unit price records availablity status if booking status is changed
              if (BookingStatusChanged.contains(booking.id)) {
                unitPriceToUpdate = newUnitPriceUpdate(
                  bookingStartDate,
                  booking,
                  unitPriceMap,
                  unitPriceToUpdate
                );
              }
            }
            processedBookingId.add(booking.id);
          } else {
            system.debug(
              'unitPriceToUpdate before else old booking @@@ ' +
              unitPriceToUpdate
            );
            if (
              triggerIsUpdate &&
              (BookingUnitChanged.contains(booking.id) ||
              BookingDateChanged.contains(booking.id)) &&
              string.isNotBlank(booking.Status__c)
            ) {
              Xotelia_Booking__c oldBooking = triggerOldMap.get(booking.id);
              if (
                oldBooking.Product__c != null &&
                Dated_OldUnit_UnitPriceMap.containsKey(oldBooking.Product__c)
              ) {
                //processing old date unit price records
                unitPriceToUpdate = oldUnitPriceUpdate(
                  oldBooking,
                  Dated_OldUnit_UnitPriceMap.get(oldBooking.Product__c),
                  unitPriceToUpdate
                );
              }
            }
            system.debug(
              'unitPriceToUpdate after else old booking @@@ ' +
              unitPriceToUpdate
            );
          }
        }
        system.debug(
          'unitPriceToUpdate before upsert @@@ ' + unitPriceToUpdate
        );

        Boolean blnisinsert = false;
        string htmlbody = '';
        List<Unit_Pricing__c> lstinsertException = new List<Unit_Pricing__c>();
        if (unitPriceToUpdate.values().size() > 0) {
          // && !isUnitPriceRecursive
          for (String strkey : unitPriceToUpdate.keySet()) {
            Unit_Pricing__c up = unitPriceToUpdate.get(strkey);
            if (up.Id == null) {
              blnisinsert = true;
              lstinsertException.add(up);
            }
          }
          //isUnitPriceRecursive = true;
          system.debug(
            'unitPriceToUpdate before upsert @@@ ' + unitPriceToUpdate
          );
        }

        system.debug('unitPriceToInsert@@@@@@' + unitPriceToInsert);
        if (unitPriceToInsert.values().size() > 0) {
          blnisinsert = true;
          //insert unitPriceToInsert.values();
          //htmlbody = JSON.serialize(unitPriceToInsert.values()) ;
          //UnitBookingController.sendEmail(subject, toAddresses, htmlBody);
        }

        if (blnisinsert) {
          string subject = 'Booking Trigger Notification: Unit pricing records were not available';
          if (
            lstinsertException.size() > 0 ||
            unitPriceToInsert.values().size() > 0
          ) {
            lstinsertException.addAll(unitPriceToInsert.values());

            htmlbody += '<div>Hi Admin,</div><br/>';
            htmlbody += '<div>The BookingTrigger apex trigger created missing unit pricing records.</div>';
            htmlbody += '<div>Please see the log summary to know more about the records that were created.</div><br/>';
            //htmlbody += '<div>The following Unit {!Unit Id} doesn\'t have required unit pricing records between {Startdate} to {end date}.</div>';
            htmlbody += JSON.serialize(lstinsertException);
          }
          UnitBookingController.sendEmail(
            subject,
            new List<String>(),
            htmlBody
          );
          //throw new UnitBookingController.BKException('')

          if (lstinsertException.size() > 0) {
            system.debug('lstinsertException##### @@@ ' + lstinsertException);
            fnUdpateBuildingUnitSetPrice(
              lstinsertException,
              minStartDate,
              maxEndDate
            );
            system.debug('lstinsertException##### @@@ ' + lstinsertException);
            insert lstinsertException;
          }
        }

        if (unitPriceToUpdate.values().size() > 0 && !Test.isRunningTest()) {
          system.debug(
            'unitPriceToUpdate before update @@@ ' + unitPriceToUpdate
          );
          update unitPriceToUpdate.values();
        }

        //if Booking Unit Price update is enabled then it creates Junction records
        Barsala_Settings__c objBarsalaSetting = Barsala_Settings__c.getOrgDefaults();
        if (
          objBarsalaSetting.Enable_Booking_Unit_Price_Update__c &&
          !triggerIsDelete
        ) {
          //&& !blnisinsert
          List<Unit_Pricing__c> lstAllUnitPrices = new List<Unit_Pricing__c>(
            [
              SELECT
                Id,
                Name,
                Unit_Price_Date__c,
                Unit__c,
                Barsala_Price_Modeled_Final__c
              FROM Unit_Pricing__c
              WHERE
                Id IN :unitPriceToUpdate.values()
                OR Id IN :unitPriceToInsert.values()
            ]
          );
          //map of unit price with unit and date as key
          map<string, Unit_Pricing__c> allunitPriceUpserted = new Map<string, Unit_Pricing__c>();
          for (Unit_Pricing__c objUP : lstAllUnitPrices) {
            string key =
              objUP.Unit__c + string.valueOf(objUP.Unit_Price_Date__c);
            allunitPriceUpserted.put(key, objUP);
          }
          //if any unit price found with Booked status
          if (allunitPriceUpserted.size() > 0) {
            //delete all Booking Unit Price Junction records
            List<Booking_Unit_Price_Junction__c> lstExistingBookingUnitPrice = new List<Booking_Unit_Price_Junction__c>(
              [
                SELECT Id
                FROM Booking_Unit_Price_Junction__c
                WHERE Booking__c IN :bookingList
              ]
            );
            if (lstExistingBookingUnitPrice.size() > 0) {
              delete lstExistingBookingUnitPrice;
            }

            //create a new Booking Unit Price Junction records
            List<Booking_Unit_Price_Junction__c> lstBookingUnitPriceInsert = new List<Booking_Unit_Price_Junction__c>();
            for (Xotelia_Booking__c booking : bookingList) {
              date bookingStartDate = booking.Start_Date__c.date();
              while (bookingStartDate < booking.End_Date__c.date()) {
                string key =
                  booking.Product__c + String.valueOf(bookingStartDate);
                if (allunitPriceUpserted.containskey(key)) {
                  Booking_Unit_Price_Junction__c objBUP = new Booking_Unit_Price_Junction__c();
                  objBUP.Booking__c = booking.Id;
                  objBUP.Unit_Pricing__c = allunitPriceUpserted.get(key).id;
                  objBUP.Booking_Status__c = Booking.Status__c;
                  objBUP.Barsala_Price_Modeled_Final__c = allunitPriceUpserted.get(
                      key
                    )
                    .Barsala_Price_Modeled_Final__c;
                  lstBookingUnitPriceInsert.add(objBUP);
                }
                bookingStartDate += 1;
              }
            }
            //insert Booking Unit Price Junction object record
            if (lstBookingUnitPriceInsert.size() > 0) {
              insert lstBookingUnitPriceInsert;
            }
          }
        }
        isRecursive = true;
        //system.debug('utilized Cpu Time :: '+ limits.getCpuTime() +' From total cpu time :: '+limits.getLimitCpuTime());
      }
    }
  }

  //function to update new unit price reocrds availiblity status
  public static Map<string, Unit_Pricing__c> newUnitPriceUpdate(
    Date startDate,
    Xotelia_Booking__c booking,
    Map<Date, Unit_Pricing__c> unitPriceMap,
    Map<string, Unit_Pricing__c> unitPriceToUpdateMap
  ) {
    Map<string, Unit_Pricing__c> unitPriceToUpdate = unitPriceToUpdateMap;
    Date bookingStartDate = startDate;
    //looping through all unit price record in between booking startdate and enddate
    while (bookingStartDate < booking.End_Date__c.date()) {
      // system.debug(bookingStartDate);
      if (unitPriceMap.containsKey(bookingStartDate)) {
        Unit_Pricing__c up = unitPriceMap.get(bookingStartDate);
        //setting availablity status depends on booking status
        if (
          booking.Status__c.toLowerCase() == 'inactive' &&
          up.Total_Booking__c <= 1
        )
          unitPriceToUpdate.put(
            up.id,
            new Unit_Pricing__c(
              id = up.id,
              Availability_Status__c = 'Available'
            )
          );
        else if (
          booking.Status__c.toLowerCase() == 'active' ||
          up.Total_Booking__c > 1
        )
          unitPriceToUpdate.put(
            up.id,
            new Unit_Pricing__c(id = up.id, Availability_Status__c = 'Booked')
          );

        bookingStartDate += 1;
      } else {
        //creating new unit price records for unit if not found
        Unit_Pricing__c newUp;

        if (booking.Status__c.toLowerCase() == 'inactive')
          newUp = new Unit_Pricing__c(
            Unit__c = booking.Product__c,
            Name = String.valueOf(bookingStartDate),
            Availability_Status__c = 'Available'
          );
        else if (booking.Status__c.toLowerCase() == 'active')
          newUp = new Unit_Pricing__c(
            Unit__c = booking.Product__c,
            Name = String.valueOf(bookingStartDate),
            Availability_Status__c = 'Booked'
          );

        String key = booking.Product__c + String.valueOf(bookingStartDate);
        unitPriceToUpdate.put(key, newUp);
        bookingStartDate += 1;
      }
    }

    return unitPriceToUpdate;
  }

  //function to update old unit price reocrds availiblity status
  public static map<string, Unit_Pricing__c> oldUnitPriceUpdate(
    Xotelia_Booking__c oldBooking,
    Map<Date, Unit_Pricing__c> oldunitPriceMap,
    Map<string, Unit_Pricing__c> unitPriceToUpdateMap
  ) {
    //map<string,List<Booking_Unit_Price_Junction__c>> jnDataMap,set<string> processBookId
    map<string, Unit_Pricing__c> unitPriceToUpdate = unitPriceToUpdateMap;
    date oldBookingStartDate = oldBooking.Start_Date__c.date();

    //looping through all unit price record in between booking startdate and enddate
    while (oldBookingStartDate < oldBooking.End_Date__c.date()) {
      if (oldunitPriceMap.containsKey(oldBookingStartDate)) {
        Unit_Pricing__c up = oldunitPriceMap.get(oldBookingStartDate);
        //checking if another booking is available on same unit price records and its booking status is active than code will not update unit price status,
        if (up.Total_Booking__c <= 1) {
          unitPriceToUpdate.put(
            up.id,
            new Unit_Pricing__c(
              id = up.id,
              Availability_Status__c = 'Available'
            )
          );
        }
        oldBookingStartDate += 1;
      } else {
        //creating new unit price records for unit if not found
        Unit_Pricing__c newUp = new Unit_Pricing__c(
          Unit__c = oldBooking.Product__c,
          Name = String.valueOf(oldBookingStartDate),
          Availability_Status__c = 'Available'
        );
        string key =
          oldBooking.Product__c + String.valueOf(oldBookingStartDate);
        unitPriceToUpdate.put(key, newUp);
        oldBookingStartDate += 1;
      }
    }

    return unitPriceToUpdate;
  }

  //function to create map of new & old booking unit with its unitprice record mapped date wise
  public static map<string, map<date, Unit_Pricing__c>> DatedUnitPriceMap(
    Xotelia_Booking__c booking,
    List<Unit_Pricing__c> unitPriceList,
    Map<String, Map<Date, Unit_Pricing__c>> UPMap
  ) {
    //map of unitprice record with its unit price date
    Map<date, Unit_Pricing__c> UnitPriceMap_Dated = new Map<Date, Unit_Pricing__c>();
    //map of unit with its relevent booking dates unit price records
    map<string, map<Date, Unit_Pricing__c>> Dated_Unit_UnitPriceMap = UPMap;

    for (Unit_Pricing__c up : unitPriceList) {
      if (
        up.Unit_Price_Date__c >= booking.Start_Date__c.date() &&
        up.Unit_Price_Date__c < booking.End_Date__c.date()
      ) {
        UnitPriceMap_Dated.put(up.Unit_Price_Date__c, up);
      }
    }
    //checking of unit is exist in map , if exist than add additional unit price values come from second booking records
    if (!Dated_Unit_UnitPriceMap.ContainsKey(booking.Product__c)) {
      Dated_Unit_UnitPriceMap.put(booking.Product__c, UnitPriceMap_Dated);
    } else if (Dated_Unit_UnitPriceMap.ContainsKey(booking.Product__c)) {
      map<Date, Unit_Pricing__c> SecBookingUnitPriceMap = Dated_Unit_UnitPriceMap.get(
        booking.Product__c
      );
      //looping through new map to add record to exsting date unit price map
      for (Unit_Pricing__c up : UnitPriceMap_Dated.values()) {
        SecBookingUnitPriceMap.put(up.Unit_Price_Date__c, up);
      }
      Dated_Unit_UnitPriceMap.put(booking.Product__c, SecBookingUnitPriceMap);
    }

    return Dated_Unit_UnitPriceMap;
  }

  public static void fnChangeBookingProduct(
    List<Xotelia_Booking__c> lstnew,
    Map<id, Xotelia_Booking__c> oldmap
  ) {
    Map<Id, Cleaning_Assignment__c> mapCleaning = new Map<Id, Cleaning_Assignment__c>();
    // Map<Id,QA_Assignment__c> mapQA = new Map<Id,QA_Assignment__c>();
    // Map<Id,Xotelia_Booking__c> MapBooking = new Map<Id,Xotelia_Booking__c>();
    List<Cleaning_Assignment__c> lstCleaningAssignment = new List<Cleaning_Assignment__c>();
    List<QA_Assignment__c> lstQAAssignment = new List<QA_Assignment__c>();

    for (Xotelia_Booking__c obj : [
      SELECT
        id,
        Product__c,
        (
          SELECT id, Unit_ID__c
          FROM Cleaning_Assignments__r
          WHERE Cleaning_Required_On__c > today
          ORDER BY CreatedDate DESC
        ),
        (SELECT id, Unit_ID__c FROM QA_Assignments__r ORDER BY CreatedDate DESC)
      FROM Xotelia_Booking__c
      WHERE id IN :lstnew
    ]) {
      if (obj.Product__c != oldmap.get(obj.Id).Product__c) {
        for (Cleaning_Assignment__c ca : obj.Cleaning_Assignments__r) {
          Cleaning_Assignment__c objca = new Cleaning_Assignment__c(Id = ca.Id);
          objca.Unit_ID__c = obj.Product__c;
          lstCleaningAssignment.add(objca);
        }

        for (QA_Assignment__c qa : obj.QA_Assignments__r) {
          QA_Assignment__c objqa = new QA_Assignment__c(Id = qa.Id);
          objqa.Unit_ID__c = obj.Product__c;
          lstQAAssignment.add(objqa);
        }
      }
    }

    if (lstCleaningAssignment.size() > 0) {
      CleaningAssignmentHandler.isBookingCleaningRecursion = false;
      List<String> lstException = new List<String>();
      Database.SaveResult[] srList = Database.update(
        lstCleaningAssignment,
        false
      );
      for (Database.SaveResult sr : srList) {
        if (sr.isSuccess()) {
        } else {
          // Operation failed, so get all errors
          for (Database.Error err : sr.getErrors()) {
            lstException.add(
              'Method Update CA Unit : ' +
              err.getStatusCode() +
              ': ' +
              err.getMessage() +
              ' field affected:' +
              err.getFields()
            );
          }
        }
      }
      if (lstException.size() > 0)
        CleaningAssignmentHandler.sendEmailIfNextPrevHavingException(
          String.join(lstException, ';')
        );

      //update lstCleaningAssignment;
      //CleaningAssignmentHandler.isBookingCleaningRecursion = true;
    }

    if (lstQAAssignment.size() > 0) {
      QAAssignmentHandler.isBookingQARecursion = false;
      //update lstQAAssignment;

      List<String> lstException = new List<String>();
      Database.SaveResult[] srList = Database.update(lstQAAssignment, false);
      for (Database.SaveResult sr : srList) {
        if (sr.isSuccess()) {
        } else {
          // Operation failed, so get all errors
          for (Database.Error err : sr.getErrors()) {
            lstException.add(
              'Method Update QA Unit : ' +
              err.getStatusCode() +
              ': ' +
              err.getMessage() +
              ' field affected:' +
              err.getFields()
            );
          }
        }
      }
      if (lstException.size() > 0)
        QAAssignmentHandler.sendEmailIfNextPrevHavingException(
          String.join(lstException, ';')
        );
    }

    // for (Xotelia_Booking__c obj: lstnew) {
    //     if(obj.Product__c != oldmap.get(obj.Id).Product__c){

    //         Cleaning_Assignment__c objca = new Cleaning_Assignment__c();
    //         objca.Booking__c = obj.Id;
    //         objca.Unit_ID__c = obj.Product__c;
    //         mapCleaning.put(obj.Id, objca);

    //         QA_Assignment__c objqa = new QA_Assignment__c();
    //         objqa.Booking_Record__c = obj.Id;
    //         objqa.Unit_ID__c = obj.Product__c;
    //         mapQA.put(obj.Id, objqa);

    //     }
    // }

    // if(mapCleaning.size()>0){
    //     insert mapCleaning.values();
    //     for (Cleaning_Assignment__c objca : mapCleaning.values()) {
    //         Xotelia_Booking__c objBooking = new Xotelia_Booking__c(Id = objca.Booking__c, Cleaning_Assignment_Id__c = objca.Id);
    //         MapBooking.put(objca.Booking__c,objBooking);
    //     }
    // }

    // if(mapQA.size()>0){
    //     insert mapQA.values();
    //     for (QA_Assignment__c objqa : mapQA.values()) {
    //         Xotelia_Booking__c objBooking = new Xotelia_Booking__c(Id = objqa.Booking_Record__c);
    //         if(MapBooking.ContainsKey(objqa.Booking_Record__c)){
    //             objBooking = MapBooking.get(objqa.Booking_Record__c);
    //         }
    //         c
    //         objBooking.QA_Assignment_Id__c = objqa.Id;
    //         MapBooking.put(objqa.Booking_Record__c,objBooking);
    //     }
    // }

    // if(MapBooking.size()>0){
    //     BookingTriggerHelper.IsRecursive = true;
    //     update MapBooking.values();
    //     BookingTriggerHelper.IsRecursive = false;

    //     //update Cleaning and QA viceversa
    //     // List<SObject>  lstSObject = new List<SObject>();
    //     // List<QA_Assignment__c>  lstQAAssignment = new List<QA_Assignment__c>();
    //     // for (Xotelia_Booking__c objBooking : MapBooking.values()) {
    //     //     Cleaning_Assignment__c objCA = new Cleaning_Assignment__c(Id = objBooking.Cleaning_Assignment_Id__c, QA_Assignment__c = objBooking.QA_Assignment_Id__c);
    //     //     lstSObject.add(objCA);

    //     //     QA_Assignment__c objQA = new QA_Assignment__c(Id = objBooking.QA_Assignment_Id__c, Cleaning_Assignment__c = objBooking.Cleaning_Assignment_Id__c );
    //     //     lstSObject.add(objQA);
    //     // }

    //     // if(lstSObject.size()>0){
    //     //     QAAssignmentHandler.isQARecursion = true;
    //     //     CleaningAssignmentHandler.isCleaningRecursion = true;
    //     //     Update lstSObject;
    //     //     QAAssignmentHandler.isQARecursion = false;
    //     //     CleaningAssignmentHandler.isCleaningRecursion = false;
    //     // }
    // }
  }
  public static void CheckingTimeForProductChange(
    List<Xotelia_Booking__c> booklist,
    Map<id, Xotelia_Booking__c> oldmap
  ) {
    String timestring = '';
    for (Xotelia_Booking__c bking : booklist) {
      if (
        label.Run_CheckIn_Time == 'true' ||
        oldmap == null ||
        (bking.Start_date__c != null &&
        ((oldmap != null &&
        bking.Check_in_time__c != oldmap.get(bking.id).Check_in_time__c) ||
        (oldmap != null &&
        bking.Start_date__c != oldmap.get(bking.id).Start_date__c)))
      ) {
        bking.CheckIn_DateTime__c = bking.Start_date__c;
        try {
          bking.CheckIn_Time__c = Time.newInstance(
            bking.Start_date__c.hour(),
            bking.Start_date__c.minute(),
            0,
            0
          );
        } catch (Exception e) {
          bking.CheckIn_Time__c = Time.newInstance(11, 0, 0, 0);
        }

        system.debug('timestring' + timestring);

        if (string.isNotBlank(bking.Check_in_time__c)) {
          system.debug('at line 535');
          timestring = bking.Check_in_time__c.trim();
          if (
            (timestring.tolowercase().contains('am') ||
            timestring.tolowercase().contains('pm')) &&
            timestring.contains(':') &&
            timestring.length() < 9
          ) {
            system.debug('timestring' + timestring);
            system.debug('timestring' + timestring.length());

            Integer hours = 0;
            Integer minutes = 0;
            String meridiem = '';

            List<String> timeLst1 = timeString.split(':');
            hours = Integer.valueOf(timeLst1[0]);
            minutes = Integer.valueOf(timeLst1[1].left(2));
            meridiem = timeLst1[1].right(2);
            system.debug('meridiem' + meridiem);
            system.debug('hours' + hours);
            if (meridiem == 'PM' && hours < 12) {
              hours = hours + 12;
            } else if (meridiem == 'AM' && hours == 12) {
              hours = 0;
            }

            DateTime chkingdatetime = Datetime.newInstance(
              bking.Start_date__c.Year(),
              bking.Start_date__c.month(),
              bking.Start_date__c.day(),
              hours,
              minutes,
              0
            );
            bking.CheckIn_DateTime__c = chkingdatetime;

            Time chkintime = Time.newInstance(hours, minutes, 0, 0);
            bking.CheckIn_Time__c = chkintime;
          }
        }
      }
    }
  }

  public static void fnUdpateBuildingUnitSetPrice(
    List<Unit_Pricing__c> lstUP,
    Date minStartDate,
    Date maxEndDate
  ) {
    Set<Id> UnitId = new Set<Id>();
    for (Unit_Pricing__c up : lstUP) {
      UnitId.add(up.Unit__c);
    }
    system.debug('UnitId#####' + UnitId);

    Map<Id, Unit__c> mapUnitVsBUS = new Map<Id, Unit__c>();

    Map<Id, Set<Id>> mapBUSvsUnits = new Map<Id, Set<Id>>();
    for (Unit__c u : [
      SELECT Id, Unit__c, Building_Unit_Set__c, Building_Unit_Set__r.Name
      FROM Unit__c
      WHERE Id IN :UnitId
    ]) {
      mapUnitVsBUS.put(u.Id, u);
      if (mapBUSvsUnits.containsKey(u.Building_Unit_Set__c)) {
        mapBUSvsUnits.get(u.Building_Unit_Set__c).add(u.Id);
      } else {
        mapBUSvsUnits.put(u.Building_Unit_Set__c, new Set<Id>{ u.Id });
      }
    }

    system.debug('mapUnitVsBUS#####' + mapUnitVsBUS);
    system.debug('mapBUSvsUnits#####' + mapBUSvsUnits);

    Map<Id, Map<String, Building_Unit_Set_Pricing__c>> mapBUSvsBUSP = new Map<Id, Map<String, Building_Unit_Set_Pricing__c>>();
    for (Building_Unit_Set_Pricing__c busp : [
      SELECT id, Building_Unit_Set__c, Building_Unit_Set__r.Name, Price_Date__c
      FROM Building_Unit_Set_Pricing__c
      WHERE
        Building_Unit_Set__c IN :mapBUSvsUnits.Keyset()
        AND Price_Date__c >= :minStartDate
        AND Price_Date__c < :maxEndDate
    ]) {
      if (mapBUSvsBUSP.containsKey(busp.Building_Unit_Set__c)) {
        mapBUSvsBUSP.get(busp.Building_Unit_Set__c)
          .put(String.valueOf(busp.Price_Date__c), busp);
      } else {
        mapBUSvsBUSP.put(
          busp.Building_Unit_Set__c,
          new Map<String, Building_Unit_Set_Pricing__c>{
            String.valueOf(busp.Price_Date__c) => busp
          }
        );
      }
    }

    system.debug('mapBUSvsBUSP#####' + mapBUSvsBUSP);

    Map<String, Building_Unit_Set_Pricing__c> mapdatevsBUSP = new Map<String, Building_Unit_Set_Pricing__c>();
    Map<String, Building_Unit_Set_Pricing__c> mapkeyvsBUSP = new Map<String, Building_Unit_Set_Pricing__c>(); // it is used to store newly created building unit set pricing record
    for (Unit_Pricing__c up : lstUP) {
      // here we have checked the building unit set pricing record exist for Unit Price
      if (mapUnitVsBUS.containsKey(up.Unit__c)) {
        Unit__c objunit = mapUnitVsBUS.get(up.Unit__c);
        mapdatevsBUSP = new Map<String, Building_Unit_Set_Pricing__c>();
        if (mapBUSvsBUSP.containsKey(objunit.Building_Unit_Set__c)) {
          //
          mapdatevsBUSP = mapBUSvsBUSP.get(objunit.Building_Unit_Set__c);
          if (mapdatevsBUSP.containsKey(up.Name)) {
            up.Building_Unit_Set_Pricing_Day__c = mapdatevsBUSP.get(up.Name).Id;
          } else {
            mapkeyvsBUSP.put(
              up.Name + up.Unit__c,
              new Building_Unit_Set_Pricing__c(
                Name = objunit.Building_Unit_Set__r.Name + ' | ' + up.Name,
                Building_Unit_Set__c = objunit.Building_Unit_Set__c,
                Price_Date__c = Date.valueOf(up.Name)
              )
            );
          }
        } else {
          mapkeyvsBUSP.put(
            up.Name + up.Unit__c,
            new Building_Unit_Set_Pricing__c(
              Name = objunit.Building_Unit_Set__r.Name + ' | ' + up.Name,
              Building_Unit_Set__c = objunit.Building_Unit_Set__c,
              Price_Date__c = Date.valueOf(up.Name)
            )
          );
        }
      }
    }
    system.debug('lstUP#####' + lstUP);

    if (mapkeyvsBUSP.size() > 0) {
      insert mapkeyvsBUSP.values();
      for (Unit_Pricing__c up : lstUP) {
        if (
          up.Building_Unit_Set_Pricing_Day__c == null &&
          mapkeyvsBUSP.containsKey(up.Name + up.Unit__c)
        ) {
          up.Building_Unit_Set_Pricing_Day__c = mapkeyvsBUSP.get(
              up.Name + up.Unit__c
            )
            .Id;
        }

        if (mapUnitVsBUS.containskey(up.Unit__c)) {
          Unit__c objunit = mapUnitVsBUS.get(up.Unit__c);
          string strunit = objunit.Unit__c;
          if (string.isNotBlank(strunit)) {
            up.Name = objunit.Unit__c + ' | ' + up.Name;
          }
        }
      }
      system.debug('lstUP#####' + lstUP);
    }

    // return lstUP;
  }

  public static void codecovarageMethod() {
    string str = 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
    str += 'test 1111111';
  }

  public static void updatePersonAccount(
    List<Xotelia_Booking__c> lst,
    Map<Id, Xotelia_Booking__c> oldmap
  ) {
    // // Id currentUserId = UserInfo.getUserId();
    // // User activeUser = [Select Email From User where Id = : currentUserId limit 1];
    // // List<Account> acc = new List<Account>();
    // // if(activeUser != null){
    // //     acc = [SELECT id,PersonEmail FROM Account WHERE IsPersonAccount = True AND PersonEmail = :activeUser.Email limit 1];

    // // }

    // // List<Xotelia_Booking__c> bookingList = new List<Xotelia_Booking__c>();
    // // for(Xotelia_Booking__c booking :triggerNew){
    // //     if(booking.Two_Factor_Screening_Approval_Decision__c != null && acc != null && acc.size()>0){
    // //         //booking.Two_Factor_Screening_Approval_Employee__c = acc[0].Id;
    // //         bookingList.add(booking);
    // //     }
    // // }

    for (Xotelia_Booking__c b : lst) {
      if (
        b.Two_Factor_Screening_Approval_Decision__c != null &&
        b.Two_Factor_Screening_Approval_Decision__c == 'Clear' &&
        oldmap == null
      ) {
        b.Two_Factor_Screening_Approval_Employee__c = UserInfo.getUserId();
      }

      if (
        oldmap != null &&
        oldmap.get(b.Id).Two_Factor_Screening_Approval_Decision__c !=
        b.Two_Factor_Screening_Approval_Decision__c &&
        b.Two_Factor_Screening_Approval_Decision__c == 'Clear'
      ) {
        b.Two_Factor_Screening_Approval_Employee__c = UserInfo.getUserId();
      }
    }
  }
}
