public without sharing class ProcessBuildingUnitPricing {
  public static void processBuildingUnitSet(List<Building_Unit_Set__c> lst) {
    Set<Id> buildingIds = new Set<Id>(); // it is used to store Building Id

    //find min Date from Unit records
    for (Building_Unit_Set__c bus : lst) {
      buildingIds.add(bus.Building__c);
    }

    //to find the min and max date from units of building
    Map<Id, wrpBuilding> mapBuildingUnitDate = new Map<Id, wrpBuilding>();

    for (AggregateResult ar : [
      SELECT Building__c, Building_Unit_Set__c, Min(Start_Date__c) msdt
      FROM Unit__c
      WHERE Building__c IN :buildingIds AND Start_Date__c != null
      GROUP BY Building__c, Building_Unit_Set__c
    ]) {
      wrpBuilding wrp = new wrpBuilding();
      wrp.buildingid = (Id) ar.get('Building__c');
      wrp.buildingunitsetid = (Id) ar.get('Building_Unit_Set__c');
      if (ar.get('msdt') != null) {
        wrp.startdate = (Date) ar.get('msdt');
      } else {
        wrp.startdate = System.today();
      }
      wrp.enddate = System.today().addYears(1);
      mapBuildingUnitDate.put(wrp.buildingunitsetid, wrp);
    }

    List<Building_Unit_Set_Pricing__c> lstBUSP = new List<Building_Unit_Set_Pricing__c>();
    for (Building_Unit_Set__c bus : lst) {
      if (mapBuildingUnitDate.containsKey(bus.Id)) {
        bus.IsRecordProcess__c = true;
        wrpBuilding wrp = mapBuildingUnitDate.get(bus.Id);
        Integer numberDaysDue = wrp.startdate.daysBetween(wrp.enddate);
        for (Integer i = 0; i <= numberDaysDue; i++) {
          Date dtstart = wrp.startdate.addDays(i);
          Building_Unit_Set_Pricing__c busp = new Building_Unit_Set_Pricing__c();
          busp.Price_Date__c = dtstart;
          busp.Building_Unit_Set__c = bus.Id;
          busp.Name =
            bus.Name +
            ' | ' +
            DateTime.newInstance(dtstart.year(), dtstart.month(), dtstart.day())
              .format('yyyy-MM-dd');
          lstBUSP.add(busp);
        }
      }
    }

    if (lstBUSP.size() > 0) {
      insert lstBUSP;
    }

    if (lst.size() > 0) {
      update lst;
    }
  }

  public static void ProcessToSetUnitPriceRecord(
    List<Building_Unit_Set_Pricing__c> lst
  ) {
    Map<String, Id> mapBuildingSetDatevsBuildingSetPricingId = new Map<String, Id>();
    Set<Date> busDates = new Set<Date>();
    Set<Id> buildingUnitSetIds = new Set<Id>(); // it is used to store Building unit set Id
    for (Building_Unit_Set_Pricing__c bus : lst) {
      buildingUnitSetIds.add(bus.Building_Unit_Set__c);
      busDates.add(bus.Price_Date__c);
      mapBuildingSetDatevsBuildingSetPricingId.put(
        bus.Building_Unit_Set__c +
        '' +
        bus.Price_Date__c,
        bus.Id
      );
    }

    Map<Id, Unit_Pricing__c> mapUnitPrice = new Map<Id, Unit_Pricing__c>();

    for (Unit_Pricing__c up : [
      SELECT id, Unit__c, Unit__r.Building_Unit_Set__c, UNITPRICE_DATE__c
      FROM Unit_Pricing__c
      WHERE
        Unit__r.Building_Unit_Set__c IN :buildingUnitSetIds
        AND UNITPRICE_DATE__c IN :busDates
    ]) {
      if (
        mapBuildingSetDatevsBuildingSetPricingId.containsKey(
          up.Unit__r.Building_Unit_Set__c +
          '' +
          up.UNITPRICE_DATE__c
        )
      ) {
        Id BUSPId = mapBuildingSetDatevsBuildingSetPricingId.get(
          up.Unit__r.Building_Unit_Set__c +
          '' +
          up.UNITPRICE_DATE__c
        );
        Unit_Pricing__c objup = new Unit_Pricing__c(Id = up.Id);
        objup.Building_Unit_Set_Pricing_Day__c = BUSPId;
        mapUnitPrice.put(up.Id, objup);
      }
    }

    if (mapUnitPrice.size() > 0) {
      update mapUnitPrice.values();
    }
  }

  public class wrpBuilding {
    public Id buildingid { get; set; }
    public Id buildingunitsetid { get; set; }
    public Date startdate { get; set; }
    public Date enddate { get; set; }
  }
}