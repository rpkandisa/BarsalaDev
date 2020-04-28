public with sharing class Promotion {
  
    @AuraEnabled
    public static List<PicklistSelectController.PicklistOption> findAppliesTo() {
        List<PicklistSelectController.PicklistOption> lstnew = new List<PicklistSelectController.PicklistOption>();
        List<PicklistSelectController.PicklistOption> lst = new List<PicklistSelectController.PicklistOption>();

        lst = PicklistSelectController.getPicklistOptions('Promotion__c', 'Applies_To__c');
        // for (PicklistSelectController.PicklistOption o : lst) {
        //     if(o.label != 'Booking'){
        //         lstnew.add(o);
        //     }
        // }
       return lst;
    }

    @AuraEnabled
    public static List<PicklistSelectController.PicklistOption> findAllMarketingOption() {
        List<PicklistSelectController.PicklistOption> lst = new List<PicklistSelectController.PicklistOption>();
        lst.add(new PicklistSelectController.PicklistOption( '--None--', '' ));
        
        PicklistSelectController.fnbasismarketingoption(lst);
        lst.add(new PicklistSelectController.PicklistOption( 'Custom', 'custom' ));
        //return PicklistSelectController.fnbasismarketingoption(new List<PicklistSelectController.PicklistOption>());
        return lst;
    }


    @AuraEnabled
    public static wrpPromotion findbyaccountid(Id recordid) {
        wrpPromotion w = new wrpPromotion();
        for (Account a : [Select Id,Name from Account where id=: recordid]) {            
            w.recordid = a.Id;
            w.personname = a.Name;
            w.promocode = '';
            w.basis = '';
            w.discountamountoverride = 0;
            w.usagetype = '';
            w.timesofredeem = 0;
            w.addon = '';
            w.timecontrained = '';
            w.prefertype = '';
            w.daystouse = 0;
            w.startdate = System.today();
            w.enddate = null;
            w.appliesto = '';
            w.promotionfor = '';
            w.nameofcampaign = '';
        }
        System.debug('obj@@@@@ ' + w);
        return w;
    }

    @AuraEnabled
    public static Promotion__c saveData(wrpPromotion obj) {
        System.debug('obj@@@@@ ' + obj);

        Promotion__c objpromotion = new Promotion__c();
        // for (Promotion__c p : [select id,Name,Add_On__c,Basis__c,Booking__c,Building_Resident_Discount__c,Credit__c,Credit_Remaining__c,Credit_Spent__c,Days_To_Use__c,Description__c,Discount_Amount_Override__c,Discount_Percentage_Override__c,End_Date__c,Expired__c,Global_Discount_Template__c,Marketing_Promotion_Template__c,Maximum_Days_To_Apply__c,Max_Redemptions__c,Minimum_Days_To_Apply__c,Monthly_Discount__c,Num_Redemptions__c,Person_Account__c,Promo_Code__c,Redemption_Date__c,Repeat_Guest_Discount__c,Start_Date__c,Template__c,Terms_And_Conditions_Override__c,Usage_Type__c,VIP_Discount__c from Promotion__c
        // where Basis__c =: obj.basis and Template__c = null and Usage_Type__c =: obj.usagetype]) {
        //     //objpromotion = p.clone(false,false,false,false);
        //     //objpromotion.Template__c = p.Id;
        //     //objpromotion.Name = p.Name + ' ' + obj.personname;
        // }

         
        
        

        //objpromotion.Promo_Code__c = obj.promocode; // promo code
        if(String.isNotBlank(obj.basis)){
            objpromotion.Basis__c = obj.basis; // type of discount are you giving
        }
        
        if(obj.basis == 'flat' || obj.basis == 'percentage'){
            objpromotion.Applies_To__c = 'Booking';
        }
        // else if(obj.basis == 'percentage'){
        //     objpromotion.Applies_To__c = 'Booking';
        // }

        if(String.isNotBlank(obj.promocode)){
            objpromotion.Promo_Code__c = obj.promocode;
            objpromotion.Marketing_Promotion_Template__c = true;
        }
        
        objpromotion.Person_Account__c = obj.recordid;

        if(obj.basis == 'add-on'){ // if addon then change basis to percent and percent 100%
            obj.basis = 'percentage';
            obj.discountamountoverride = 100;
        }

        if(obj.basis == 'percentage'){
            objpromotion.Discount_Percentage_Override__c = obj.discountamountoverride;  //How much of flat dollar amount discount are you looking to give
            objpromotion.Discount_Amount_Override__c = null;
            objpromotion.Credit__c = null;
        }else if( obj.basis == 'credit'){
            objpromotion.Discount_Amount_Override__c = null;
            objpromotion.Discount_Percentage_Override__c = null;
            objpromotion.Credit__c = obj.discountamountoverride;
        }
        else{
            objpromotion.Discount_Percentage_Override__c = null;
            objpromotion.Credit__c = null;
            objpromotion.Discount_Amount_Override__c = obj.discountamountoverride;  //How much of flat dollar amount discount are you looking to give
        }

        if(String.isnotblank(obj.addon)){
            objpromotion.Applies_To__c = obj.addon;
        }
        

        if( obj.basis == 'credit'){
            objpromotion.Usage_Type__c = 'fixed_use'; //Is it fixed use or recurring
        }else{
            objpromotion.Usage_Type__c = obj.usagetype; //Is it fixed use or recurring
        }
        
        
        objpromotion.Max_Redemptions__c = null;
        if(obj.usagetype == 'fixed_use'){ // if fixed then How many times can the guest redeem it
            objpromotion.Max_Redemptions__c = obj.timesofredeem;
        }

        objpromotion.Days_To_Use__c = null;
        objpromotion.Start_Date__c = null;
        objpromotion.End_Date__c = null;

        if(obj.timecontrained == 'Yes'){ //Is it time constrained = Yes
            if(obj.prefertype == 'dayfromnow'){ //Do you perfer to specify a number of days from today
                objpromotion.Days_To_Use__c = obj.daystouse;
            }
            objpromotion.Start_Date__c = obj.startdate;
            objpromotion.End_Date__c = obj.enddate;
        } 

        //populate name field
        
        objpromotion.Name = createname(objpromotion, obj.personname);
        if(String.isNotBlank(obj.basis)){
            objpromotion.Basis__c = obj.basis; // type of discount are you giving
        }
        // if(obj.basis == 'vip-discount' || obj.basis == 'repeat-guest-discount' || obj.basis == 'building-resident-discount'){
        //     //objpromotion.Usage_Type__c = 'fixed_use'; // need to confirm
        //     if(obj.basis == 'vip-discount'){
        //         objpromotion.VIP_Discount__c = true;
        //     }else if(obj.basis == 'repeat-guest-discount'){
        //         objpromotion.Repeat_Guest_Discount__c = true;
        //     }else if(obj.basis == 'building-resident-discount'){
        //         objpromotion.Building_Resident_Discount__c = true;
        //     }
        // }

        if((obj.basis != 'flat' && obj.basis != 'percentage' && String.isNotBlank(obj.promotionapply)) || Test.isRunningTest() ){
            System.debug('@@@@id ' + obj.basis);

            string strpromoid = obj.promotionapply;

            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Promotion__c').getDescribe().fields.getMap();
            List<String> strList = new List<String>(objectFields.keySet());
            string allfields = string.join(strList,',');

            for (Promotion__c objp : Database.query('select ' + allfields + ' from Promotion__c where id =: strpromoid ')) {
                objpromotion = objp.clone(false,false,false,false);
                system.debug('objp@@@@@ ' + objp);
            } 
            system.debug('objpromotion@@@@@ ' + objpromotion);
            objpromotion.Marketing_Promotion_Template__c = false;
            objpromotion.Person_Account__c = obj.recordid;

            if(obj.promotionfor == 'Marketing Campaign'){
                objpromotion.Name = objpromotion.Display_Name__c;
            }else{
                objpromotion.Name = objpromotion.Display_Name__c +  ' (' + obj.personname + ')';
            }

           
            system.debug('objp@@@@@ ' + objpromotion);

        }

        if(string.isnotblank(obj.appliesto)){
            objpromotion.Applies_To__c = obj.appliesto;
        }

        if(obj.promotionfor == 'Marketing Campaign'){
            objpromotion.Name = objpromotion.Name.replace('(null)','');
            if(String.IsNotBlank(obj.nameofcampaign)){
                objpromotion.Name = obj.nameofcampaign;
                objpromotion.Display_Name_Override__c = obj.nameofcampaign;
            }
        }

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.allowFieldTruncation = true;
        objpromotion.setOptions(dml);
        insert objpromotion;

        return objpromotion;
    }  
    
    public static string createname(Promotion__c o, string pnm){
        string strname = '';

        if(o.Basis__c == 'add-on' && string.isNotBlank(o.Applies_To__c)){
            for ( PicklistEntry entry : Schema.getGlobalDescribe().get('Promotion__c').getDescribe().fields.getMap().get('Applies_To__c').getDescribe().getPicklistValues() ) {
                if(o.Applies_To__c.contains(entry.getValue())){
                    if(String.isNotBlank(strname)){
                        strname += ' | ' + entry.getLabel();
                    }else{
                        strname = entry.getLabel();
                    }                    
                }
                //options.add( new PicklistOption( entry.getLabel(), entry.getValue() ) );
            }
            
        }else if(o.Basis__c == 'credit' && o.Credit__c > 0){
            strname += '$' + o.Credit__c + ' Credit ';
        }else if(o.Basis__c == 'flat' && o.Discount_Amount_Override__c > 0){
            strname += '$' + o.Discount_Amount_Override__c + ' off ';
        }else if(o.Basis__c == 'percentage' && o.Discount_Percentage_Override__c > 0){
            strname += o.Discount_Percentage_Override__c +'% Discount ';
        }else if(o.Basis__c == 'vip-discount'){
            strname += 'VIP Discount';
        }else if(o.Basis__c == 'repeat-guest-discount'){
            strname += 'Repeat Guest Discount';
        }else if(o.Basis__c == 'building-resident-discount'){
            strname += 'Building Resident Discount';
        }

        if(o.Usage_Type__c == 'fixed_use' && o.Basis__c != 'credit'){ // if fixed then How many times can the guest redeem it            
            if(o.Max_Redemptions__c > 1){
                strname += ' - ' + o.Max_Redemptions__c + ' Uses (' + pnm + ')';
            }else {
                strname += ' - ' + o.Max_Redemptions__c + ' Use (' + pnm + ')';
            }            
        }else if(o.Basis__c == 'credit'){
            strname += ' - (' + pnm + ')';
        }else if(o.Basis__c == 'vip-discount' || o.Basis__c == 'repeat-guest-discount' || o.Basis__c == 'building-resident-discount'){
            strname += ' (' + pnm + ')';
        }
        else{
            strname += ' Recurring (' + pnm + ')';
        }

        return strname;
    }

    public class BKException extends Exception {}

    public class wrpPromotion {
        @AuraEnabled
        public String recordid { get; set; }
        @AuraEnabled        
        public String nameofcampaign { get; set; }
        @AuraEnabled        
        public String personname { get; set; }
        @AuraEnabled
        public String promocode { get; set; }
        @AuraEnabled
        public string promotionapply { get; set; }
        @AuraEnabled
        public string promotionfor { get; set; }
        @AuraEnabled
        public string basis { get; set; }
        @AuraEnabled
        public string usagetype { get; set; }
        @AuraEnabled
        public Decimal discountamountoverride { get; set; }
        @AuraEnabled
        public Decimal timesofredeem { get; set; }
        @AuraEnabled
        public String addon { get; set; }
        @AuraEnabled
        public String appliesto { get; set; }
        @AuraEnabled
        public String timecontrained { get; set; }
        @AuraEnabled
        public String prefertype { get; set; }
        @AuraEnabled
        public Decimal daystouse { get; set; }
        @AuraEnabled
        public Date startdate { get; set; }
        @AuraEnabled
        public Date enddate { get; set; }
        
    }


    
}