//Created by kandisatech on 11/12/2019
// It is used to create Confirmation code for booking
public without sharing class BookingConfirmationCode {

    public static Boolean isRecursionHandler = false;
    public static void updateBookingConfirmationCode(List<Xotelia_Booking__c> bookings, Boolean istrigger) {
        try{
        Map<String,Xotelia_Booking__c> mapConfirmationCode = new Map<String,Xotelia_Booking__c>();
        for (Xotelia_Booking__c b : bookings) {            
            if(String.IsBlank(b.Confirmation_Code__c)){
                b.Confirmation_Code__c = generateRandomString(6);
                mapConfirmationCode.put(b.Confirmation_Code__c, b);
            }
        }
    
       if(mapConfirmationCode.size()>0){
            List<Xotelia_Booking__c> lstBookings = new List<Xotelia_Booking__c>([select id,Confirmation_Code__c from Xotelia_Booking__c where Confirmation_Code__c in:mapConfirmationCode.keySet()]);
            if(lstBookings.size()>0){
                for (Xotelia_Booking__c b : lstBookings) {
                    String strreschar = findUniqueConfirmationCode(generateRandomString(6));
                    if(mapConfirmationCode.containsKey(b.Confirmation_Code__c)){
                        mapConfirmationCode.get(b.Confirmation_Code__c).Confirmation_Code__c = strreschar;
                    }
                }
            }

            BookingConfirmationCode.isRecursionHandler = true;
            if(!istrigger && bookings.size() > 0) {
                Update bookings;
            }
       }
        }catch(Exception e){
            Sentry.record(e);
            throw e;
        }
    }

    public static String findUniqueConfirmationCode(string rescode){
         List<Xotelia_Booking__c> lstBookings = new List<Xotelia_Booking__c>([select id,Confirmation_Code__c from Xotelia_Booking__c where Confirmation_Code__c =:rescode]);
         if(lstBookings.size()>0){
            return findUniqueConfirmationCode(generateRandomString(6));
         }
         return rescode;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

}