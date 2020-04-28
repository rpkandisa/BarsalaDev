public with sharing class TaskTriggerHandler {
    
    public static Boolean isRecursion = false;
    public static void populateBookingId(){
        List<Task> lstTask = new List<Task>();
        Set<Id> setContactIds = new Set<Id>();
        Map<Id,Task> mapAccountIds = new Map<Id,Task>();
        for (Task t : (List<Task>)trigger.new) {
            if(t.WhoId != null && String.valueof(t.WhoId).startsWith('003') && t.Booking__c == null){
                setContactIds.add(t.WhoId);
                lstTask.add(new Task(Id = t.Id, WhoId = t.WhoId));
            }
            else if(t.WhatId != null && String.valueof(t.WhatId).startsWith('001') && t.Booking__c == null){
                mapAccountIds.put(t.WhatId, new Task(Id = t.Id, WhatId = t.WhatId));
            }
        }

        if(mapAccountIds.size()>0){ // it is check when whoId is null and what is belongs to person account
            for(Account a : [select id,PersonContactId from account where id in: mapAccountIds.keySet() and ispersonaccount = true]){
                Task t = mapAccountIds.get(a.Id);
                t.WhoId = a.PersonContactId;
                setContactIds.add(t.WhoId);
                lstTask.add(new Task(Id = t.Id, WhoId = t.WhoId));
            }
        }

        if(setContactIds.size()>0){
             
            //map contains booking with Guest_ContactID, which lies between today date
            Map<Id, Xotelia_Booking__c> guestBookingMap = new Map<Id,Xotelia_Booking__c>();
            //map contains booking with Billing_ContactID, which lies between today date
            Map<Id, Xotelia_Booking__c> billingBookingMap = new Map<Id,Xotelia_Booking__c>();

            for(Xotelia_Booking__c booking:[select id, Updated_Email__c, Guest_Contact__c, 
                        Guest_Contact__r.Email, Billing_Contact__c, Billing_Contact__r.Email, 
                        Start_Date__c, End_Date__c from Xotelia_Booking__c 
                        where Start_Date__c<=TODAY AND End_Date__c>=TODAY 
                        And 
                        (
                            Guest_Contact__c in:setContactIds
                            OR Billing_Contact__c in:setContactIds
                        ) Order By Start_Date__c DESC, CreatedDate DESC])
            {

            if(booking.Guest_Contact__c != null)
                guestBookingMap.put(booking.Guest_Contact__c, booking);

            if(booking.Billing_Contact__c != null)
                billingBookingMap.put(booking.Billing_Contact__c, booking);
            }

            // if any map does finds the matcing contact id, we associate their booking with Task
            for (Task t : lstTask) {
                                 
                if(guestBookingMap.containsKey(t.WhoId)){
                    t.Booking__c = guestBookingMap.get(t.WhoId).Id;
                    //removing contact ids which are matched, so no need to process them in #2 process
                    setContactIds.remove(t.WhoId);
                }else if(billingBookingMap.containsKey(t.WhoId)){
                    t.Booking__c = billingBookingMap.get(t.WhoId).Id;
                    //removing contact ids which are matched, so no need to process them in #2 process
                    setContactIds.remove(t.WhoId);
                }
            }

            if(setContactIds.size() > 0){

                 for(Xotelia_Booking__c booking:[select id, Updated_Email__c, Guest_Contact__c, 
                            Guest_Contact__r.Email, Billing_Contact__c, Billing_Contact__r.Email, 
                            Start_Date__c, End_Date__c from Xotelia_Booking__c where 
                            (
                                Guest_Contact__c in:setContactIds
                                OR Billing_Contact__c in:setContactIds
                            ) Order By Start_Date__c DESC, CreatedDate DESC])
                {
                    if(booking.Guest_Contact__c != null){
                        if(!guestBookingMap.containsKey(booking.Guest_Contact__c))
                            guestBookingMap.put(booking.Guest_Contact__c, booking); 
                        else if(booking.Start_Date__c>Date.Today()
                                && booking.Start_Date__c<= guestBookingMap.get(booking.Guest_Contact__c).Start_Date__c)
                            guestBookingMap.put(booking.Guest_Contact__c, booking);
                    } 

                    if(booking.Billing_Contact__c != null){
                        if(!billingBookingMap.containsKey(booking.Billing_Contact__c))
                            billingBookingMap.put(booking.Billing_Contact__c, booking);
                        else if(booking.Start_Date__c>Date.Today()
                                && booking.Start_Date__c<= billingBookingMap.get(booking.Billing_Contact__c).Start_Date__c)
                            billingBookingMap.put(booking.Billing_Contact__c, booking);   
                    }
                }

                for (Task t : lstTask) {
                                 
                    if(guestBookingMap.containsKey(t.WhoId)){
                        t.Booking__c = guestBookingMap.get(t.WhoId).Id;
                        //removing contact ids which are matched, so no need to process them in #2 process
                        setContactIds.remove(t.WhoId);
                    }else if(billingBookingMap.containsKey(t.WhoId)){
                        t.Booking__c = billingBookingMap.get(t.WhoId).Id;
                        //removing contact ids which are matched, so no need to process them in #2 process
                        setContactIds.remove(t.WhoId);
                    }
                }

            }

            if(lstTask.size() > 0){
                TaskTriggerHandler.isRecursion = true;
                Update lstTask;
                TaskTriggerHandler.isRecursion = false;
            }

        }
    }

}