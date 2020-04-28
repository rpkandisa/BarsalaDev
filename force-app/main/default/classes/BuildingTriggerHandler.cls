public class BuildingTriggerHandler {

    public static boolean isRecursive = false;

    public static void BuildingOwnerChanged(List<Building__c> buidings, Map<Id, Building__c> buildingOldMap, boolean isInsert){
        Set<Id> buildingIds = new Set<Id>();
        for(Building__c bld :buidings){
            
            if(isInsert){
                if(String.isNotBlank(bld.Building_Owner__c)){
                    buildingIds.add(bld.Id);
                }
            }else{
                if(String.isNotBlank(bld.Building_Owner__c) && buildingOldMap.get(bld.Id).Building_Owner__c != bld.Building_Owner__c  ){
                       buildingIds.add(bld.Id);
               }
            }
            
        }
        
        if(buildingIds != null && buildingIds.size() > 0){
            
            Date dt = System.today();
            String soqlquery = 'Select Id, status__c, End_date__c, Product__r.Building__c, Product__r.Building__r.Building_Owner__c, ' +
                               ' Building_Owner__c from Xotelia_Booking__c where Status__c = \'Active\' AND End_date__c >=: dt ' +
                               ' AND Product__r.Building__c IN: setBuildingIds';
            
              
            PopulateBuildingOwnerOnBookingBatch batch = new PopulateBuildingOwnerOnBookingBatch(soqlquery,dt,buildingIds);            
            Id BatchId = DataBase.executeBatch(batch, 10); 

        }
    }
    
    public static void callBatchForBuildingOwner(){
        
    }
}