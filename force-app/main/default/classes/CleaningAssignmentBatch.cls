//Created by KandisaTech on 16-05-2019
//It is a batch class which is used to update next/previous lookup of Cleaning assignment each records
global class CleaningAssignmentBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public String query;
    global List<String> lstException;
    
    global CleaningAssignmentBatch(boolean blnInitial) {
        lstException = new List<String>();
        this.query = 'select id,Next_Cleaning_Assignment__c,Previous_Cleaning_Assignment__c,Unit_ID__c,Booking__c from Cleaning_Assignment__c where  Cleaning_Required_On__c >= LAST_N_MONTHS:1 and Unit_ID__c!=null order by Unit_ID__c, Cleaning_Required_On__c  '; //Cleaning_Type__c=\'Check-out\' and
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Cleaning_Assignment__c> lst) {
           
        Set<Id> unitIds = new Set<Id>();
        for(Cleaning_Assignment__c ca : lst){
            unitIds.add(ca.Unit_ID__c);
        }

        Map<Id,Cleaning_Assignment__c> mapCARecords = new Map<Id,Cleaning_Assignment__c>();
        Date chkoutdate = System.Today().addYears(-2);
        Map<Id,Cleaning_Assignment__c> mapCleaning = new Map<Id,Cleaning_Assignment__c>([select id,Next_Cleaning_Assignment__c,Previous_Cleaning_Assignment__c,Unit_ID__c,Booking__c from Cleaning_Assignment__c where Unit_ID__c in: unitIds  and Cleaning_Required_On__c >=: chkoutdate  order by Unit_ID__c, Cleaning_Required_On__c]); // and Cleaning_Type__c='Check-out'

		Map<Id,Cleaning_Assignment__c> mapCleaningCheckOnly = new Map<Id,Cleaning_Assignment__c>([select id,Next_Cleaning_Assignment__c,Previous_Cleaning_Assignment__c,Unit_ID__c,Booking__c from Cleaning_Assignment__c where Unit_ID__c in: unitIds  and Cleaning_Required_On__c >=: chkoutdate  order by Unit_ID__c, Cleaning_Required_On__c]); //and Cleaning_Type__c='Check-out'

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
        
        if(mapCARecords.size()>0){
            CleaningAssignmentHandler.isCleaningRecursion = true;

            List<Cleaning_Assignment__c> lstCARecords = new List<Cleaning_Assignment__c>();
            for(Cleaning_Assignment__c ca  : mapCARecords.values()){
                Cleaning_Assignment__c tmpca = new Cleaning_Assignment__c();
                if(mapCleaningCheckOnly.containsKey(ca.Id)){
                    tmpca = mapCleaningCheckOnly.get(ca.Id);
                    if(tmpca.Next_Cleaning_Assignment__c == ca.Next_Cleaning_Assignment__c && tmpca.Previous_Cleaning_Assignment__c == ca.Previous_Cleaning_Assignment__c){
                        continue;
                    }
                }
                lstCARecords.add(ca);
            }


            //List<String> lstException = new List<String>();
            Database.SaveResult[] srList = Database.update(lstCARecords, false);
            Integer intexception = 0;
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                }
                else {
                    // Operation failed, so get all errors                                    
                    for(Database.Error err : sr.getErrors()) {       
                        lstException.add('Method batch: ' + err.getStatusCode() + ': ' + err.getMessage() + ' field affected:' + err.getFields() + ' Id: ' + lstCARecords.get(intexception).Id);
                    }
                }
                 intexception++;
            }
            

            CleaningAssignmentHandler.isCleaningRecursion = false;
        }

    }
    
    global void finish(Database.BatchableContext BC) {
        if(lstException.size()>0 || Test.isRunningTest()) {
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