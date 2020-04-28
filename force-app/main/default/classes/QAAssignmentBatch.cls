//Created by KandisaTech on 16-05-2019
//It is a batch class which is used to populate next/previous lookup of QA assignment records
global class QAAssignmentBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public String query; 
    global List<String> lstException;
    
    global QAAssignmentBatch() {
        this.query = 'select id,Next_QA_Assignment__c,Previous_QA_Assignment__c,Unit_ID__c,Booking_Record__c from QA_Assignment__c  where Checkin_Date__c >= LAST_N_MONTHS:1 and Unit_ID__c!=null ORDER BY Unit_ID__c,Checkin_Date__c ';
        lstException = new List<String>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<QA_Assignment__c> lst) {
        Set<Id> unitIds = new Set<Id>();
        for(QA_Assignment__c qa : lst){
            unitIds.add(qa.Unit_ID__c);
        }

        //List<String> lstException = new List<String>();
        Map<Id,QA_Assignment__c> mapCARecords = new Map<Id,QA_Assignment__c>();
        Date chkoutdate = System.Today().addYears(-2);
        Map<Id,QA_Assignment__c> mapCleaning = new Map<Id,QA_Assignment__c>([select id,Next_QA_Assignment__c,Previous_QA_Assignment__c,Unit_ID__c,Booking_Record__c from QA_Assignment__c where Unit_ID__c in: unitIds and Checkin_Date__c >=: chkoutdate  order by Unit_ID__c, Checkin_Date__c]);
        
        Map<Id,QA_Assignment__c> mapCleaningCheckOnly = new Map<Id,QA_Assignment__c>([select id,Next_QA_Assignment__c,Previous_QA_Assignment__c,Unit_ID__c,Booking_Record__c from QA_Assignment__c where Unit_ID__c in: unitIds and Checkin_Date__c >=: chkoutdate  order by Unit_ID__c, Checkin_Date__c]);

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
        
        if(mapCARecords.size()>0){
            QAAssignmentHandler.isQARecursion = true;
            List<QA_Assignment__c> lstQARecords = new List<QA_Assignment__c>();
            for(QA_Assignment__c ca  : mapCARecords.values()){
                QA_Assignment__c tmpca = new QA_Assignment__c();
                if(mapCleaningCheckOnly.containsKey(ca.Id)){
                    tmpca = mapCleaningCheckOnly.get(ca.Id);
                    if(tmpca.Next_QA_Assignment__c == ca.Next_QA_Assignment__c && tmpca.Previous_QA_Assignment__c == ca.Previous_QA_Assignment__c){
                        continue;
                    }
                }
                lstQARecords.add(ca);
            }

            Database.SaveResult[] srList = Database.update(lstQARecords, false);
            Integer intexception = 0;
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {  }
                else {
                    // Operation failed, so get all errors                                    
                    for(Database.Error err : sr.getErrors()) {    
                        lstException.add('Method batch: ' + err.getStatusCode() + ': ' + err.getMessage() + ' field affected:' + err.getFields() + ' Id: ' + lstQARecords.get(intexception).Id)  ;
                    }
                }
                intexception++;
            }
            
            QAAssignmentHandler.isQARecursion = false;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if(lstException.size()>0 || Test.IsrunningTest()) {
            string strexception = String.join(lstException,';');

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
            message.setHtmlBody(strexception);
            mails.add(message);

            Messaging.sendEmail(mails);
        }
    }
    
}