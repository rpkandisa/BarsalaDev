//Developed by Kandisatech
//It is used to calculate # review on unit when rating given in booking record

public without sharing class UnitReviewCount {
  @InvocableMethod(
    label='Unit Review Count'
    description='It is used to calculate Unit Review.'
  )
  public static void UpdateUnitReviewByBookingRating(List<ID> ids) {
    List<Unit__c> lst = new List<Unit__c>(
      [
        SELECT id, (SELECT Id FROM Xotelia_Bookings__r WHERE Rating__c > 0)
        FROM Unit__c
        WHERE Id IN :ids
      ]
    );

    Map<Id, Unit__c> mapUnits = new Map<Id, Unit__c>();
    for (Unit__c u : lst) {
      Unit__c objunit = new Unit__c(Id = u.Id, of_Reviews__c = 0);
      Integer intcount = 0;
      for (Xotelia_Booking__c b : u.Xotelia_Bookings__r) {
        intcount++;
      }
      if (intcount > 0) {
        objunit.of_Reviews__c = intcount;
        mapUnits.put(u.Id, u);
      }
    }

    if (mapUnits.size() > 0) {
      update mapUnits.values();
    }
  }
}