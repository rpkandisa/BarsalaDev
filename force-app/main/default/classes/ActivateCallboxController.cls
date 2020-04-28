public with sharing class ActivateCallboxController {
    public Building__c objBuilding {get;set;}
    public ActivateCallboxController(ApexPages.StandardController stdController) {
        this.objBuilding = (Building__c)stdController.getRecord();
    }

    public PageReference sendtextmessage(){
        try{
        
            Building__c obj = new Building__c();
            for(Building__c b : [select id,Name from Building__c where id=: objBuilding.Id]){
                obj = b;
            }
        
            List<smagicinteract__smsMagic__c>  smsObjectList = new List<smagicinteract__smsMagic__c> ();
            String senderId = '12068007277'; // Please replace the 'smsMagic' with your relevant sender ID.
            String templateText = obj.Name; // you can fetch the template text by querying the record on smagicinteract__SMS_Template__c object
            smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
            smsObject.smagicinteract__SenderId__c = senderId;
            smsObject.smagicinteract__PhoneNumber__c = '12068232515';
            //smsObject.smagicinteract__Name__c = contact.Name; // records name
            //smsObject.smagicinteract__ObjectType__c = 'Contact'; // record type
            smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
            smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
            smsObject.smagicinteract__SMSText__c = templateText;
            smsObjectList.add(smsObject);
            Database.insert(smsObjectList, false);

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Message Sent Successfully!'));

            // PageReference pageRef = new PageReference('/'+objBuilding.Id );
            // pageRef.setRedirect(true);
            // return pageRef;

        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
        return null;
    }
}