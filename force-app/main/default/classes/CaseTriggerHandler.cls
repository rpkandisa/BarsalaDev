//created by Kandisa Tech on 03/01/2018
public class CaseTriggerHandler {
    public static boolean isRecursion = false;
    
    public static void populateBookingOnCase(List<Case> lstCase, Boolean isAfter){
        Set<Id> conIds = new Set<Id>(); //map to store Case Contact Ids
        Set<String> conEmails = new Set<String>(); //Map to store Contact Email Ids
        Map<Id,Contact> contactMap = new Map<Id, Contact>(); //Map store Contact with Ids
        
        //List contains items which not matched in first processing and 
        //have to checked in #2 process/criteria
        List<Case> casesRemainingToMatch = new List<Case>();
        List<Case> casesToUpdate = new List<Case>();

        //if trigger is running on after context, need to query data and update them
        if(isAfter){
            lstCase = [select id, ContactId, Booking__c from Case where id in:lstCase AND ContactId != null AND Booking__c = null];
        }

        //Collecting case contact ids
        for(Case cs:lstCase){
            if(cs.ContactId != null && cs.Booking__c == null)
                conIds.add(cs.ContactId);
        }

        if(conIds.size()==0)
            return;

        //fetching contacts, and creating map wit Id, also storing unique emails in a set
        for(Contact con:[select id,Email from Contact where id in:conIds AND Email != null]){
            contactMap.put(con.Id, con);
            conEmails.add(con.Email);
        }
        
        system.debug('@@@ isAfter=='+isAfter);
        system.debug('@@@ conEmails=='+conEmails);
        system.debug('@@@ contactMap=='+contactMap);
        

        //map contains booking for Updated_Email field, which lies between today date
        Map<String, Xotelia_Booking__c> emailBookingMap = new Map<String,Xotelia_Booking__c>();
        //map contains booking with Guest_ContactID, which lies between today date
        Map<Id, Xotelia_Booking__c> guestBookingMap = new Map<Id,Xotelia_Booking__c>();
        //map contains booking with Billing_ContactID, which lies between today date
        Map<Id, Xotelia_Booking__c> billingBookingMap = new Map<Id,Xotelia_Booking__c>();
        //Set contains emails which are matched with Booking's Updated_Email field in #1 Criteria
        //So we remove these emails from main list, so in process #2, 
        //so these records can be filtered to do not fetch in query in #2 process
        Set<String> matchedEmails = new Set<String>();

        // Matching Process #1
        //Here we check bookings which start and end lies between today's date
        //with matching email, Guest_Contact, or Billing Contact
        //Store these bookings in map declared above
        for(Xotelia_Booking__c booking:[select id, Updated_Email__c, Guest_Contact__c, 
                            Guest_Contact__r.Email, Billing_Contact__c, Billing_Contact__r.Email, 
                            Start_Date__c, End_Date__c from Xotelia_Booking__c 
                            where Start_Date__c<=TODAY AND End_Date__c>=TODAY 
                            And 
                            (
                                Updated_Email__c in:conEmails
                                OR Guest_Contact__c in:conIds
                                OR Billing_Contact__c in:conIds
                            ) Order By Start_Date__c DESC, CreatedDate DESC])
        {
            system.debug('@@@ isAfter=='+isAfter);
            system.debug('@@@ conEmails2=='+conEmails);

            if(booking.Updated_Email__c != null)// && !emailBookingMap.containsKey(booking.Updated_Email__c))
                emailBookingMap.put(booking.Updated_Email__c, booking);
            
            if(booking.Guest_Contact__c != null)// && !guestBookingMap.containsKey(booking.Guest_Contact__c))
                guestBookingMap.put(booking.Guest_Contact__c, booking);

            if(booking.Billing_Contact__c != null)// && !billingBookingMap.containsKey(booking.Billing_Contact__c))
                billingBookingMap.put(booking.Billing_Contact__c, booking);
        }

        system.debug('@@@ isAfter=='+isAfter);
        system.debug('@@@ emailBookingMap=='+emailBookingMap);
        system.debug('@@@ guestBookingMap=='+guestBookingMap);
        system.debug('@@@ billingBookingMap=='+billingBookingMap);

        //Matching the Contact email, or id in map created above
        //if any map does finds the matcing email or contact id,
        //we associate their booking with case
        //Priority1 : First try to match with Case.Contact.Email on Booking.Updated_Email, if not matched
        //Priority2 : Second try to match with Case.ContactId on Booking.Guest_Contact__c, if not matched
        //Priority3 : Third try to match with Case.ContactId on Booking.Billing_Contact__c
        for(Case cs:lstCase){
            Boolean bookingMatched = true;
            if(contactMap.containsKey(cs.ContactId) 
                && contactMap.get(cs.ContactId).Email != null
                && emailBookingMap.containsKey(contactMap.get(cs.ContactId).Email)
            ){
                cs.Booking__c = emailBookingMap.get(contactMap.get(cs.ContactId).Email).Id;
                //collecing matched emails for contacts, so no need to filter then in #2 process
                matchedEmails.add(contactMap.get(cs.ContactId).Email);
            }else if(guestBookingMap.containsKey(cs.ContactId)){
                cs.Booking__c = guestBookingMap.get(cs.ContactId).Id;
                //removing contact ids which are matched, so no need to process them in #2 process
                conIds.remove(cs.ContactId);
            }else if(billingBookingMap.containsKey(cs.ContactId)){
                cs.Booking__c = billingBookingMap.get(cs.ContactId).Id;
                //removing contact ids which are matched, so no need to process them in #2 process
                conIds.remove(cs.ContactId);
            }else
                bookingMatched = false;
            
            //collecting cases which are not matched, to process them only in #2 process
            if(!bookingMatched)
                casesRemainingToMatch.add(cs);
            else if(isAfter){
                casesToUpdate.add(cs);
            }
        }

        system.debug('@@@ isAfter=='+isAfter);
        system.debug('@@@ casesToUpdate=='+casesToUpdate);
        
        //If all cases are matched with bookings, then return method from here,
        //Since there are no cases remaining to match in #2 process criteria
        if(casesRemainingToMatch.size()==0){
            if(casesToUpdate.size()>0){
                CaseTriggerHandler.isRecursion = true;
                update casesToUpdate;
                CaseTriggerHandler.isRecursion = false;
            }
            return;
        }


        // Matching Process #2
        //Here we check bookings which start date is max amond other bookings
        //with matching email, Guest_Contact, or Billing Contact
        //Store these bookings in map declared before #1 process

        //#removing emails which are already matched
        for(String emailstr:matchedEmails){
            //emailBookingMap.remove(emailstr);
            conEmails.remove(emailstr);
        }

        //fetching bookings with start date in descending order, where email, guest contact or billing contact is matched
        for(Xotelia_Booking__c booking:[select id, Updated_Email__c, Guest_Contact__c, 
                            Guest_Contact__r.Email, Billing_Contact__c, Billing_Contact__r.Email, 
                            Start_Date__c, End_Date__c from Xotelia_Booking__c where 
                            (
                                Updated_Email__c in:conEmails
                                OR Guest_Contact__c in:conIds
                                OR Billing_Contact__c in:conIds
                            ) Order By Start_Date__c DESC, CreatedDate DESC])
        {
            if(booking.Updated_Email__c != null){
                if(!emailBookingMap.containsKey(booking.Updated_Email__c))
                    emailBookingMap.put(booking.Updated_Email__c, booking);
                else if(booking.Start_Date__c>Date.Today()
                        && booking.Start_Date__c<= emailBookingMap.get(booking.Updated_Email__c).Start_Date__c)
                    emailBookingMap.put(booking.Updated_Email__c, booking);
            }

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


        //Matching the Contact email, or id in map created above
        //if any map does finds the matcing email or contact id,
        //we associate their booking with case
        //Priority1 : First try to match with Case.Contact.Email on Booking.Updated_Email, if not matched
        //Priority2 : Second try to match with Case.ContactId on Booking.Guest_Contact__c, if not matched
        //Priority3 : Third try to match with Case.ContactId on Booking.Billing_Contact__c
        for(Case cs:casesRemainingToMatch){
            Boolean bookingMatched = true;

            if(contactMap.containsKey(cs.ContactId) 
                && contactMap.get(cs.ContactId).Email != null
                && emailBookingMap.containsKey(contactMap.get(cs.ContactId).Email)
            )
                cs.Booking__c = emailBookingMap.get(contactMap.get(cs.ContactId).Email).Id;
            else if(guestBookingMap.containsKey(cs.ContactId))
                cs.Booking__c = guestBookingMap.get(cs.ContactId).Id;
            else if(billingBookingMap.containsKey(cs.ContactId))
                cs.Booking__c = billingBookingMap.get(cs.ContactId).Id;
            else
                bookingMatched = false;

            //collecting cases which are not matched, to process them only in #2 process
            if(bookingMatched && isAfter)
                casesToUpdate.add(cs);
        }

        system.debug('@@@ isAfter=='+isAfter);
        system.debug('@@@ casesToUpdate=='+casesToUpdate);

        if(casesToUpdate.size()>0){
            CaseTriggerHandler.isRecursion = true;
            update casesToUpdate;
            CaseTriggerHandler.isRecursion = false;
        }
    }
}