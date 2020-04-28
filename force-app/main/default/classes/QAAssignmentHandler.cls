//Created by KandisaTech on 16-05-2019
public class QAAssignmentHandler {

	public static boolean isQARecursion = false;
    public static boolean isBookingQARecursion = true;

    //It is a static method which is used to populate next/previous lookup of QA assignment records
    public static void UpdateNextPreviousQA(List<QA_Assignment__c> lst){
        Set<Id> unitIds = new Set<Id>();
        // List<QA_Assignment__c> lstQANew = new List<QA_Assignment__c>([select id,Unit_ID__c,Booking_Record__c,CreatedDate,Checkin_Date__c from QA_Assignment__c where id in: lst order by Unit_ID__c, Checkin_Date__c]);
        for(QA_Assignment__c qa : lst){
            unitIds.add(qa.Unit_ID__c);
        }

        List<String> lstException = new List<String>();
        Map<Id,QA_Assignment__c> mapCARecords = new Map<Id,QA_Assignment__c>();
        mapCARecords = fnPrintNextPrevLookUp(unitIds,lst,mapCARecords); 
        
        if(mapCARecords.size()>0){
            QAAssignmentHandler.isQARecursion = true;
            //update mapCARecords.values();

            Database.SaveResult[] srList = Database.update(mapCARecords.values(), false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {}
                else {
                    // Operation failed, so get all errors                                    
                    for(Database.Error err : sr.getErrors()) {       
                        lstException.add('Method Insert: ' + err.getStatusCode() + ': ' + err.getMessage() + ' field affected:' + err.getFields())  ;
                    }
                }
            }
            if(lstException.size()>0) sendEmailIfNextPrevHavingException(String.join(lstException,';'));

            QAAssignmentHandler.isQARecursion = false;
        }

        // Map<Id,Id> mapUnitVsPreviousQA = new Map<Id,Id>();
        // for(Unit__c unit : [select id,(select Id from QA_Assignments__r where Unit_ID__c!=null and id not in: lst order by createddate desc limit 1) from Unit__c where id in: unitIds ]){
        //     for (QA_Assignment__c qa : unit.QA_Assignments__r) {
        //         mapUnitVsPreviousQA.put(unit.Id, qa.id);
        //     }
        // }

        // Map<Id,QA_Assignment__c> mapQA = new Map<Id,QA_Assignment__c>();
        // for(QA_Assignment__c qa : lstQANew){
        //     if(mapUnitVsPreviousQA.containsKey(qa.Unit_ID__c)){
        //         QA_Assignment__c objQAPrevious = new QA_Assignment__c();
        //         objQAPrevious.Id = mapUnitVsPreviousQA.get(qa.Unit_ID__c);
        //         if(mapQA.containsKey(objQAPrevious.Id)){
        //             objQAPrevious = mapQA.get(objQAPrevious.Id);
        //         }

        //         objQAPrevious.Next_QA_Assignment__c = qa.Id;
        //         mapQA.put(qa.Id,objQAPrevious);

        //         qa.Previous_QA_Assignment__c = objQAPrevious.Id;
        //         mapQA.put(qa.Id,qa);
        //     }
        // }

        // if(mapQA.size()>0){
        //     QAAssignmentHandler.isQARecursion = true;
        //     update mapQA.values();
        //     QAAssignmentHandler.isQARecursion = false;
        // }

    }

    public static void updateQAOnDelete(List<QA_Assignment__c> lstold){        
        Map<Id,Id> mapBookingIdvsQAId = new  Map<Id,Id>();
        List<QA_Assignment__c> lstQA = new List<QA_Assignment__c>();
        for(QA_Assignment__c qa : lstold){
            if(qa.Next_QA_Assignment__c != null){
                QA_Assignment__c objqanext = new QA_Assignment__c(Id = qa.Next_QA_Assignment__c);
                objqanext.Previous_QA_Assignment__c = qa.Previous_QA_Assignment__c;
                lstQA.add(objqanext);
            }

            if(qa.Previous_QA_Assignment__c != null){
                QA_Assignment__c objqanext = new QA_Assignment__c(Id = qa.Previous_QA_Assignment__c);
                objqanext.Next_QA_Assignment__c = qa.Next_QA_Assignment__c;
                lstQA.add(objqanext);
            }

            mapBookingIdvsQAId.put(qa.Booking_Record__c, qa.Id);
        }

        if(lstQA.size()>0){
            QAAssignmentHandler.isQARecursion = true;
            List<String> lstException = new List<String>();
            Database.SaveResult[] srList = Database.update(lstQA, false);
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
            if(lstException.size()>0) sendEmailIfNextPrevHavingException(String.join(lstException,';'));
            //update lstQA;
            
            List<Xotelia_Booking__c> lstBooking = new List<Xotelia_Booking__c>();
            for(Xotelia_Booking__c b : [select id,QA_Assignment_Id__c from Xotelia_Booking__c where Id in: mapBookingIdvsQAId.keyset()]){
                if(mapBookingIdvsQAId.containsKey(b.Id) && String.isblank(b.QA_Assignment_Id__c) == false && (Id)b.QA_Assignment_Id__c == mapBookingIdvsQAId.get(b.Id)){
                    Xotelia_Booking__c objb = new Xotelia_Booking__c(Id = b.Id, QA_Assignment_Id__c = null );
                    lstBooking.add(objb);
                }
            }

            if(lstBooking.size()>0){
                BookingTriggerHelper.IsRecursive = true;
                update lstBooking;
                BookingTriggerHelper.IsRecursive = false;
            }

            QAAssignmentHandler.isQARecursion = false;
        }
    }

    public static void QANextPrevChangeOnUpdate(List<QA_Assignment__c> lst, Map<Id,QA_Assignment__c> oldmap){  
        Map<Id,Id> mapNextCA = new Map<Id,Id>();
        Map<Id,Id> mapPrevCA = new Map<Id,Id>(); 
        Set<Id> setOldCleaningIds = new Set<Id>();        
        Set<Id> unitIds = new Set<Id>();
        for (QA_Assignment__c ca : lst) {

            mapNextCA.put(ca.Next_QA_Assignment__c,ca.Previous_QA_Assignment__c);
            mapPrevCA.put(ca.Previous_QA_Assignment__c,ca.Next_QA_Assignment__c);

            setOldCleaningIds.add(ca.Next_QA_Assignment__c);
            setOldCleaningIds.add(ca.Previous_QA_Assignment__c);

            unitIds.add(ca.Unit_ID__c);
        }

        Map<Id,QA_Assignment__c> mapCARecords = new Map<Id,QA_Assignment__c>(); // it is used to populate next/prev for booking of older unit
        for(QA_Assignment__c ca : [select id,Next_QA_Assignment__c,Previous_QA_Assignment__c,Unit_ID__c from QA_Assignment__c where Id in: setOldCleaningIds]){
           if(mapPrevCA.containsKey(ca.Id)){
               ca.Next_QA_Assignment__c = mapPrevCA.get(ca.Id);
               mapCARecords.put(ca.Id, ca);
           }
           if(mapNextCA.containsKey(ca.Id)){
               ca.Previous_QA_Assignment__c = mapNextCA.get(ca.Id);
               mapCARecords.put(ca.Id, ca);
           }
        }

                
        mapCARecords = fnPrintNextPrevLookUp(unitIds,lst,mapCARecords);

        if(mapCARecords.size()>0){
            QAAssignmentHandler.isBookingQARecursion = true;
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

    private static Map<Id,QA_Assignment__c> fnPrintNextPrevLookUp(Set<Id> unitIds, List<QA_Assignment__c> lst, Map<Id,QA_Assignment__c> mapCARecords){

        Date chkoutdate = System.Today().addYears(-2);
        Map<Id,QA_Assignment__c> mapCleaning = new Map<Id,QA_Assignment__c>([select id,Next_QA_Assignment__c,Previous_QA_Assignment__c,Unit_ID__c,Booking_Record__c from QA_Assignment__c where Unit_ID__c in: unitIds and Checkin_Date__c >=: chkoutdate  order by Unit_ID__c, Checkin_Date__c]);

        Map<Id,List<QA_Assignment__c>> mapUnitVsCleaning = new Map<Id,List<QA_Assignment__c>>();
        Map<Id,Map<Id,Integer>> mapCAIdVsIdx = new Map<Id,Map<Id,Integer>>();
        Map<Id,Map<Integer,Id>> mapIdxVsCAId = new Map<Id,Map<Integer,Id>>();
        Integer intCAIdx = 0;
        Id unitIdCompare = null;
        for(QA_Assignment__c ca  : mapCleaning.values()){

            if(unitIdCompare != ca.Unit_ID__c){
                intCAIdx = 0;
                unitIdCompare = ca.Unit_ID__c;
            }

            if(!mapUnitVsCleaning.containsKey(ca.Unit_ID__c)){
                mapUnitVsCleaning.put(ca.Unit_ID__c, new List<QA_Assignment__c>{ ca  });
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

        for (QA_Assignment__c ca : lst) {
            if(mapUnitVsCleaning.containsKey(ca.Unit_ID__c)){
                List<QA_Assignment__c> lstCA = mapUnitVsCleaning.get(ca.Unit_ID__c);
                Map<Id,Integer> tmpCaIdsVsInx = mapCAIdVsIdx.get(ca.Unit_ID__c);
                Map<Integer,Id> tmpIdxVsCAId = mapIdxVsCAId.get(ca.Unit_ID__c);

                QA_Assignment__c caCurrRecord = new QA_Assignment__c();
                QA_Assignment__c caPrevRecord = new QA_Assignment__c();
                QA_Assignment__c caNextRecord = new QA_Assignment__c();

                Integer currentCAIndex = tmpCaIdsVsInx.get(ca.Id); // current CA records
                caCurrRecord = lstCA.get(currentCAIndex);
                caCurrRecord.Previous_QA_Assignment__c = null;
                caCurrRecord.Next_QA_Assignment__c = null;

                if(tmpIdxVsCAId.containsKey(currentCAIndex-1)){ // previous CA record
                    caPrevRecord = lstCA.get(currentCAIndex-1);
                    caCurrRecord.Previous_QA_Assignment__c = caPrevRecord.Id;
                    caPrevRecord.Next_QA_Assignment__c = caCurrRecord.Id;
                }                

                if(tmpIdxVsCAId.containsKey(currentCAIndex+1)){ // next CA record
                    caNextRecord = lstCA.get(currentCAIndex+1);
                    caCurrRecord.Next_QA_Assignment__c = caNextRecord.Id;
                    caNextRecord.Previous_QA_Assignment__c = caCurrRecord.Id;
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
        message.setSubject('Barsala QA Assignment Exception');
        message.setHtmlBody(strmsg);
        mails.add(message);

        Messaging.sendEmail(mails);
        
    }
}