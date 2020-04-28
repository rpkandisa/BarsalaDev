global class BatchToUpdateSharinpixForBUS implements Database.Batchable<sObject>, Database.AllowsCallouts {
  public String soql;
  public boolean blnIsImageToSharinpixRecords = false;
  global BatchToUpdateSharinpixForBUS(Boolean IsImageToSharinpixRecords) {
    soql = 'select id from Building_Unit_Set__c ';
    this.blnIsImageToSharinpixRecords = IsImageToSharinpixRecords;
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(soql);
  }

  global void execute(
    Database.BatchableContext BC,
    List<Building_Unit_Set__c> lst
  ) {
    List<Building_Unit_Set__c> lstBUSUpdate = new List<Building_Unit_Set__c>();
    Map<Id, Id> mapBuidvsUnitId = new Map<Id, Id>();

    if (!blnIsImageToSharinpixRecords) {
      Integer prevwesiteCount = 0;
      Map<Id, List<sharinpix__SharinPixImage__c>> mapBUSvsUnitSharinPix = new Map<Id, List<sharinpix__SharinPixImage__c>>();
      for (Unit__c u : [
        SELECT
          Id,
          Building_Unit_Set__c,
          (
            SELECT
              Id,
              sharinpix__ImageURLOriginal__c,
              sharinpix__FileName__c,
              sharinpix__Format__c,
              sharinpix__Tags__c
            FROM SharinPix_Images__r
          )
        FROM Unit__c
        WHERE Building_Unit_Set__c IN :lst
      ]) {
        if (u.SharinPix_Images__r.size() > 0) {
          Integer wesiteCount = 0;
          for (sharinpix__SharinPixImage__c objsi : u.SharinPix_Images__r) {
            if (
              String.isNotBlank(objsi.sharinpix__Tags__c) &&
              objsi.sharinpix__Tags__c.tolowercase().contains('website')
            ) {
              wesiteCount++;
            }
          }

          system.debug('imgcount##### ' + u.Building_Unit_Set__c);
          system.debug('imgcount##### ' + u.SharinPix_Images__r.size());

          if (
            !mapBUSvsUnitSharinPix.containsKey(u.Building_Unit_Set__c) ||
            (mapBUSvsUnitSharinPix.containsKey(u.Building_Unit_Set__c) &&
            wesiteCount > prevwesiteCount)
          ) {
            prevwesiteCount = wesiteCount;
            system.debug('imgcount##### updated ');
            List<sharinpix__SharinPixImage__c> lstsharinpix = new List<sharinpix__SharinPixImage__c>();
            lstsharinpix = u.SharinPix_Images__r;
            mapBUSvsUnitSharinPix.put(u.Building_Unit_Set__c, lstsharinpix);
            mapBuidvsUnitId.put(u.Building_Unit_Set__c, u.Id);
          }
        }
      }

      for (Id busid : mapBUSvsUnitSharinPix.keySet()) {
        if (mapBuidvsUnitId.containsKey(busid)) {
          lstBUSUpdate.add(
            new Building_Unit_Set__c(
              Id = busid,
              UnitId__c = mapBuidvsUnitId.get(busid)
            )
          );
        }

        for (
          sharinpix__SharinPixImage__c spimg : mapBUSvsUnitSharinPix.get(busid)
        ) {
          String albumId = busid;
          String url = spimg.sharinpix__ImageURLOriginal__c;
          String filename = '';
          if (String.isNotBlank(spimg.sharinpix__FileName__c)) {
            filename = spimg.sharinpix__FileName__c;
          }
          if (String.isNotBlank(spimg.sharinpix__Format__c)) {
            filename += ('.' + spimg.sharinpix__Format__c);
          }
          System.debug('pass param 1111');
          sharinpix.Utils utl = new sharinpix.Utils();
          if (!Test.isRunningTest()) {
            utl.uploadFromUrl(url, albumId, filename);
          }
        }
      }
    } else {
      for (Building_Unit_Set__c b : lst) {
        try {
          if (!Test.isRunningTest()) {
            sharinpix.imageSyncMigration.resyncAlbum(b.Id);
          }
        } catch (Exception e) {
          system.debug('Building_Unit_Set__c Exception@@@@@' + b);
          system.debug('Building_Unit_Set__c Exception@@@@@' + e.getMessage());
        }
      }
    }

    if (lstBUSUpdate.size() > 0)
      update lstBUSUpdate;
  }

  global void finish(Database.BatchableContext BC) {
  }
}