//Created by KandisaTech on 16-05-2019
public class CleaningAssignmentHandler 
{
    public static boolean isCleaningRecursion = false;
    public static boolean isBookingCleaningRecursion = true;

    //It is static method which is used to populate next/previous lookup of Cleaning assignment records
    public static void UpdateNextPreviousCleaning(List<Cleaning_Assignment__c> lstnew){
        Set<Id> unitIds = new Set<Id>();
        for(Cleaning_Assignment__c ca : lstnew){
            //if(ca.Cleaning_Type__c=='Check-out'){
                unitIds.add(ca.Unit_ID__c);
            //}            
        }

        Map<Id,Cleaning_Assignment__c> mapCARecords = new Map<Id,Cleaning_Assignment__c>();
        mapCARecords = fnPrintNextPrevLookUp(unitIds,lstnew,mapCARecords);
        
        if(mapCARecords.size()>0){
            CleaningAssignmentHandler.isCleaningRecursion = true;
            //update mapCARecords.values();
            List<String> lstException = new List<String>();
            Database.SaveResult[] srList = Database.update(mapCARecords.values(), false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                }
                else {
                    // Operation failed, so get all errors                                    
                    for(Database.Error err : sr.getErrors()) {       
                        lstException.add('Method Insert: ' + err.getStatusCode() + ': ' + err.getMessage() + ' field affected:' + err.getFields())  ;
                    }
                }
            }
            if(lstException.size()>0) sendEmailIfNextPrevHavingException(String.join(lstException,';'));

            CleaningAssignmentHandler.isCleaningRecursion = true;
        }



        // List<Cleaning_Assignment__c> lstCleaningNew = new List<Cleaning_Assignment__c>([select id,Unit_ID__c,Booking__c,CreatedDate,Cleaning_Type__c from Cleaning_Assignment__c where id in: lst and Cleaning_Type__c='Check-out' order by Unit_ID__c, Checkout_Date__c]);        
        // for(Cleaning_Assignment__c qa : lstCleaningNew){
        //     unitIds.add(qa.Unit_ID__c);
        // }

        // Map<Id,Id> mapUnitVsPreviousCleaning = new Map<Id,Id>();
        // for(Unit__c unit : [select id,(select Id from Cleaning_Assignments__r where Unit_ID__c != null and id not in: lst  order by createddate desc limit 1) from Unit__c where id in: unitIds]){
        //     for (Cleaning_Assignment__c qa : unit.Cleaning_Assignments__r) {
        //         mapUnitVsPreviousCleaning.put(unit.Id, qa.id);
        //     }
        // }

        // Map<Id,Cleaning_Assignment__c> mapCleaning = new Map<Id,Cleaning_Assignment__c>();
        
        // for(Cleaning_Assignment__c ca : lstCleaningNew){
        //     if(mapUnitVsPreviousCleaning.containsKey(ca.Unit_ID__c)){
        //         Cleaning_Assignment__c objCleaningPrevious = new Cleaning_Assignment__c(Id = mapUnitVsPreviousCleaning.get(ca.Unit_ID__c));

        //         if(mapCleaning.containsKey(objCleaningPrevious.Id)){
        //             objCleaningPrevious = mapCleaning.get(objCleaningPrevious.Id);
        //         }

        //         objCleaningPrevious.Next_Cleaning_Assignment__c = ca.Id;
        //         mapCleaning.put(objCleaningPrevious.Id, objCleaningPrevious);
        //         ca.Previous_Cleaning_Assignment__c = objCleaningPrevious.Id;
        //         mapCleaning.put(ca.Id,ca);

        //         mapUnitVsPreviousCleaning.put(ca.Unit_ID__c,ca.Id);
        //     }
        // }

        // if(mapCleaning.size()>0){
        //     CleaningAssignmentHandler.isCleaningRecursion = true;
        //     system.debug('@@@@@CleaningAssignmet@@@@' + mapCleaning.values());
        //     update mapCleaning.values();
        //     CleaningAssignmentHandler.isCleaningRecursion = true;
        // }

    }


    public static void updateCleaningOnDelete(List<Cleaning_Assignment__c> lstold){        
        
        Map<Id,Id> mapBookingIdvsCAId = new  Map<Id,Id>();
        List<Cleaning_Assignment__c> lstCA = new List<Cleaning_Assignment__c>();
        for(Cleaning_Assignment__c qa : lstold){
            if(qa.Next_Cleaning_Assignment__c != null){
                Cleaning_Assignment__c objqanext = new Cleaning_Assignment__c(Id = qa.Next_Cleaning_Assignment__c);
                objqanext.Previous_Cleaning_Assignment__c = qa.Previous_Cleaning_Assignment__c;
                lstCA.add(objqanext);
            }

            if(qa.Previous_Cleaning_Assignment__c != null){
                Cleaning_Assignment__c objqanext = new Cleaning_Assignment__c(Id = qa.Previous_Cleaning_Assignment__c);
                objqanext.Next_Cleaning_Assignment__c = qa.Next_Cleaning_Assignment__c;
                lstCA.add(objqanext);
            }

            mapBookingIdvsCAId.put(qa.Booking__c, qa.Id);
        }

        if(lstCA.size()>0){
            CleaningAssignmentHandler.isCleaningRecursion = true;
            //update lstCA;
            List<String> lstException = new List<String>();
            Database.SaveResult[] srList = Database.update(lstCA, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                }
                else {
                    // Operation failed, so get all errors                                    
                    for(Database.Error err : sr.getErrors()) {       
                        lstException.add('Method Delete: ' + err.getStatusCode() + ': ' + err.getMessage() + ' field affected:' + err.getFields())  ;
                    }
                }
            }
            if(lstException.size()>0)  sendEmailIfNextPrevHavingException(String.join(lstException,';'));


            //BookingTriggerHelper.IsRecursive
            List<Xotelia_Booking__c> lstBooking = new List<Xotelia_Booking__c>();
            for(Xotelia_Booking__c b : [select id,Cleaning_Assignment_Id__c from Xotelia_Booking__c where Id in: mapBookingIdvsCAId.keyset()]){
                if(mapBookingIdvsCAId.containsKey(b.Id) && String.isblank(b.Cleaning_Assignment_Id__c) == false && (Id)b.Cleaning_Assignment_Id__c == mapBookingIdvsCAId.get(b.Id)){
                    Xotelia_Booking__c objb = new Xotelia_Booking__c(Id = b.Id, Cleaning_Assignment_Id__c = null );
                    lstBooking.add(objb);
                }
            }

            if(lstBooking.size()>0){
                BookingTriggerHelper.IsRecursive = true;
                update lstBooking;
                BookingTriggerHelper.IsRecursive = false;
            }

            CleaningAssignmentHandler.isCleaningRecursion = false;
        }
    }

    public static void CleaningNextPrevChangeOnUpdate(List<Cleaning_Assignment__c> lst, Map<Id,Cleaning_Assignment__c> oldmap){  

        Map<Id,Id> mapNextCA = new Map<Id,Id>();
        Map<Id,Id> mapPrevCA = new Map<Id,Id>(); 
        Set<Id> setOldCleaningIds = new Set<Id>();        
        Set<Id> unitIds = new Set<Id>();
        for (Cleaning_Assignment__c ca : lst) {

            mapNextCA.put(ca.Next_Cleaning_Assignment__c,ca.Previous_Cleaning_Assignment__c);
            mapPrevCA.put(ca.Previous_Cleaning_Assignment__c,ca.Next_Cleaning_Assignment__c);

            setOldCleaningIds.add(ca.Next_Cleaning_Assignment__c);
            setOldCleaningIds.add(ca.Previous_Cleaning_Assignment__c);

            unitIds.add(ca.Unit_ID__c);
        }

        Map<Id,Cleaning_Assignment__c> mapCARecords = new Map<Id,Cleaning_Assignment__c>(); // it is used to populate next/prev for booking of older unit
        for(Cleaning_Assignment__c ca : [select id,Next_Cleaning_Assignment__c,Previous_Cleaning_Assignment__c,Unit_ID__c from Cleaning_Assignment__c where Id in: setOldCleaningIds]){
           if(mapPrevCA.containsKey(ca.Id)){
               ca.Next_Cleaning_Assignment__c = mapPrevCA.get(ca.Id);
               mapCARecords.put(ca.Id, ca);
           }
           if(mapNextCA.containsKey(ca.Id)){
               ca.Previous_Cleaning_Assignment__c = mapNextCA.get(ca.Id);
               mapCARecords.put(ca.Id, ca);
           }
        }

        mapCARecords = fnPrintNextPrevLookUp(unitIds,lst,mapCARecords);
        
        if(mapCARecords.size()>0){
            CleaningAssignmentHandler.isBookingCleaningRecursion = true;
            //update mapCARecords.values();
            List<String> lstException = new List<String>();
            Database.SaveResult[] srList = Database.update(mapCARecords.values(), false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                }
                else {
                    // Operation failed, so get all errors                                    
                    for(Database.Error err : sr.getErrors()) {       
                        lstException.add('Method Update: ' + err.getStatusCode() + ': ' + err.getMessage() + ' field affected:' + err.getFields())  ;
                    }
                }
            }

            if(lstException.size()>0) sendEmailIfNextPrevHavingException(String.join(lstException,';'));
        }
    }


    private static Map<Id,Cleaning_Assignment__c> fnPrintNextPrevLookUp(Set<Id> unitIds, List<Cleaning_Assignment__c> lst, Map<Id,Cleaning_Assignment__c> mapCARecords){
        Date chkoutdate = System.Today().addYears(-2);
        Map<Id,Cleaning_Assignment__c> mapCleaning = new Map<Id,Cleaning_Assignment__c>([select id,Next_Cleaning_Assignment__c,Previous_Cleaning_Assignment__c,Unit_ID__c,Booking__c from Cleaning_Assignment__c where Unit_ID__c in: unitIds and Cleaning_Type__c='Check-out' and Checkout_Date__c >=: chkoutdate  order by Unit_ID__c, Checkout_Date__c]);

        Map<Id,List<Cleaning_Assignment__c>> mapUnitVsCleaning = new Map<Id,List<Cleaning_Assignment__c>>();
        Map<Id,Map<Id,Integer>> mapCAIdVsIdx = new Map<Id,Map<Id,Integer>>();
        Map<Id,Map<Integer,Id>> mapIdxVsCAId = new Map<Id,Map<Integer,Id>>();
        Integer intCAIdx = 0;
        Id unitIdCompare = null;
        for(Cleaning_Assignment__c ca  : mapCleaning.values()){

            if(unitIdCompare != ca.Unit_ID__c){
                intCAIdx = 0;
                unitIdCompare = ca.Unit_ID__c;
            }

            if(!mapUnitVsCleaning.containsKey(ca.Unit_ID__c)){
                mapUnitVsCleaning.put(ca.Unit_ID__c, new List<Cleaning_Assignment__c>{ ca  });
            }else{
                mapUnitVsCleaning.get(ca.Unit_ID__c).add(ca);
            }

                        
            if(!mapCAIdVsIdx.containsKey(ca.Unit_ID__c)){
                Map<Id,Integer> tmpCAIdVsInt = new Map<Id,Integer>();
                tmpCAIdVsInt.put(ca.Id,intCAIdx);
                mapCAIdVsIdx.put(ca.Unit_ID__c, tmpCAIdVsInt);
            }else{
                mapCAIdVsIdx.get(ca.Unit_ID__c).put(ca.Id, intCAIdx);
            }

            if(!mapIdxVsCAId.containsKey(ca.Unit_ID__c)){
                Map<Integer,Id> tmpCAIdVsInt = new Map<Integer,Id>();
                tmpCAIdVsInt.put(intCAIdx, ca.Id);
                mapIdxVsCAId.put(ca.Unit_ID__c, tmpCAIdVsInt);
            }else{
                mapIdxVsCAId.get(ca.Unit_ID__c).put(intCAIdx, ca.Id);
            }

            intCAIdx++;
        }

        for (Cleaning_Assignment__c ca : lst) {
            if(mapUnitVsCleaning.containsKey(ca.Unit_ID__c)){
                List<Cleaning_Assignment__c> lstCA = mapUnitVsCleaning.get(ca.Unit_ID__c);
                Map<Id,Integer> tmpCaIdsVsInx = mapCAIdVsIdx.get(ca.Unit_ID__c);
                Map<Integer,Id> tmpIdxVsCAId = mapIdxVsCAId.get(ca.Unit_ID__c);

                Cleaning_Assignment__c caCurrRecord = new Cleaning_Assignment__c();
                Cleaning_Assignment__c caPrevRecord = new Cleaning_Assignment__c();
                Cleaning_Assignment__c caNextRecord = new Cleaning_Assignment__c();

                Integer currentCAIndex = tmpCaIdsVsInx.get(ca.Id); // current CA records

                if(!tmpIdxVsCAId.containsKey(currentCAIndex)) continue;

                caCurrRecord = lstCA.get(currentCAIndex);
                caCurrRecord.Previous_Cleaning_Assignment__c = null;
                caCurrRecord.Next_Cleaning_Assignment__c = null;

                if(tmpIdxVsCAId.containsKey(currentCAIndex-1)){ // previous CA record
                    caPrevRecord = lstCA.get(currentCAIndex-1);
                    caCurrRecord.Previous_Cleaning_Assignment__c = caPrevRecord.Id;
                    caPrevRecord.Next_Cleaning_Assignment__c = caCurrRecord.Id;
                }                

                if(tmpIdxVsCAId.containsKey(currentCAIndex+1)){ // next CA record
                    caNextRecord = lstCA.get(currentCAIndex+1);
                    caCurrRecord.Next_Cleaning_Assignment__c = caNextRecord.Id;
                    caNextRecord.Previous_Cleaning_Assignment__c = caCurrRecord.Id;
                }

                mapCARecords.put(ca.Id, caCurrRecord);
                if(caPrevRecord.id != null) mapCARecords.put(caPrevRecord.Id, caPrevRecord);
                if(caNextRecord.id != null) mapCARecords.put(caNextRecord.Id, caNextRecord);
            }
        } 

        return mapCARecords;
    }

    public static void sendEmailIfNextPrevHavingException(string strmsg){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        List<String> lstToAddress = new List<String>();
        for(String str : label.Next_Prev_CA_QA_Exception_Email.split(',')){
            if(!string.isblank(str)){
                lstToAddress.add(str.trim());
            }
        }
        message.setToAddresses(lstToAddress);
        message.setReplyTo('noreply@barsala.com');
        message.setSenderDisplayName('Barsala Support');
        message.setSubject('Barsala CA Assignment Exception');
        message.setHtmlBody(strmsg);
        mails.add(message);

        Messaging.sendEmail(mails);
        
    }
}