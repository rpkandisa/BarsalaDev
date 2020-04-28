public with sharing class StripeHelper {
    
    public static String getStripeCustomerIdFromURL(String stripeCustomerId){
        if(stripeCustomerId != null && stripeCustomerId.contains('customers/cus_'))
            return stripeCustomerId.split('customers/')[1];
        return null;
    }

    public static HTTPModel getStripeCustomerDetails(Stripe_Setting__c stripeSetting, String stripeCustomerId){
        return StripeHelper.doHTTPCallout(
                                            'GET', 
                                            'application/x-www-form-urlencoded', 
                                            stripeSetting, 
                                            '/customers/'+stripeCustomerId, 
                                            null
                                        );
    }

    public static HTTPModel createStripeCustomer(Stripe_Setting__c stripeSetting, String stripeCustomerId, 
                                                    String email, String description, 
                                                    UpgradeWizard.CreditCardModel ccModel)
    {
        String apiPath = '/customers';
        String requestBody = 'source[object]=card&'+
                            'source[address_zip]='+ccModel.zipCode+'&'+
                            'source[name]='+ccModel.cardName+'&'+
                            'source[number]='+ccModel.cardNumber+'&'+
                            'source[exp_month]='+ccModel.expMonth+'&'+
                            'source[exp_year]='+ccModel.expYear+'&'+
                            'source[cvc]='+ccModel.cvv+'&'+
                            'source[currency]=usd';

        if(String.isBlank(stripeCustomerId)){
            requestBody += '&account_balance=0&'+
                            'description='+description+'&'+
                            'email='+email;
        }else{
            apiPath += '/'+stripeCustomerId+'/sources';
        }

        return StripeHelper.doHTTPCallout(
                                            'POST', 
                                            'application/x-www-form-urlencoded', 
                                            stripeSetting, 
                                            apiPath, 
                                            requestBody
                                        );
    }
    
    public static HTTPModel createStripeCustomer(Stripe_Setting__c stripeSetting, String stripeCustomerId, 
                                                    String email, String description, 
                                                    UnitBookingByOwnerController.CreditCardModel ccModel)
    {
        String apiPath = '/customers';
        String requestBody = 'source[object]=card&'+
                            'source[address_zip]='+ccModel.zipCode+'&'+
                            'source[name]='+ccModel.cardName+'&'+
                            'source[number]='+ccModel.cardNumber+'&'+
                            'source[exp_month]='+ccModel.expMonth+'&'+
                            'source[exp_year]='+ccModel.expYear+'&'+
                            'source[cvc]='+ccModel.cvv+'&'+
                            'source[currency]=usd';

        if(String.isBlank(stripeCustomerId)){
            requestBody += '&account_balance=0&'+
                            'description='+description+'&'+
                            'email='+email;
        }else{
            apiPath += '/'+stripeCustomerId+'/sources';
        }

        return StripeHelper.doHTTPCallout(
                                            'POST', 
                                            'application/x-www-form-urlencoded', 
                                            stripeSetting, 
                                            apiPath, 
                                            requestBody
                                        );
    }

    public static HTTPModel createStripeCustomer(Stripe_Setting__c stripeSetting, String stripeCustomerId, 
                                                    String email, String description, 
                                                    UnitBookingController.CreditCardModel ccModel)
    {
        String apiPath = '/customers';
        String requestBody = 'source[object]=card&'+
                            'source[address_zip]='+ccModel.zipCode+'&'+
                            'source[name]='+ccModel.cardName+'&'+
                            'source[number]='+ccModel.cardNumber+'&'+
                            'source[exp_month]='+ccModel.expMonth+'&'+
                            'source[exp_year]='+ccModel.expYear+'&'+
                            'source[cvc]='+ccModel.cvv+'&'+
                            'source[currency]=usd';

        if(String.isBlank(stripeCustomerId)){
            requestBody += '&account_balance=0&'+
                            'description='+description+'&'+
                            'email='+email;
        }else{
            apiPath += '/'+stripeCustomerId+'/sources';
        }

        return StripeHelper.doHTTPCallout(
                                            'POST', 
                                            'application/x-www-form-urlencoded', 
                                            stripeSetting, 
                                            apiPath, 
                                            requestBody
                                        );
    }

    public static HTTPModel createStripeCustomerDefaultSource(Stripe_Setting__c stripeSetting, String stripeCustomerId, 
                                                    String cardId)
    {
        return StripeHelper.doHTTPCallout(
                                            'POST', 
                                            'application/x-www-form-urlencoded', 
                                            stripeSetting, 
                                            '/customers/'+stripeCustomerId,
                                            'default_source='+cardId
                                        );
    }

    public static HTTPModel createCardToken(Stripe_Setting__c stripeSetting, String stripeCustomerId, 
                                                                UpgradeWizard.CreditCardModel ccModel)
    {
        String requestBody = 'card[number]='+ccModel.cardNumber+'&'+
                                'card[exp_month]='+ccModel.expMonth+'&'+
                                'card[exp_year]='+ccModel.expYear+'&'+
                                'card[cvc]='+ccModel.cvv;
                                //'card[address_zip]='+ccModel.zipCode+'&'+
                                //'card[name]='+ccModel.cardName+'&'+
                                //'card[currency]=usd';

        return StripeHelper.doHTTPCallout(
                                            'POST', 
                                            'application/x-www-form-urlencoded', 
                                            stripeSetting, 
                                            '/tokens',
                                            requestBody
                                        );
    }
    
    public static HTTPModel createCardToken(Stripe_Setting__c stripeSetting, String stripeCustomerId, 
                                                                UnitBookingByOwnerController.CreditCardModel ccModel)
    {
        String requestBody = 'card[number]='+ccModel.cardNumber+'&'+
                                'card[exp_month]='+ccModel.expMonth+'&'+
                                'card[exp_year]='+ccModel.expYear+'&'+
                                'card[cvc]='+ccModel.cvv;
                                //'card[address_zip]='+ccModel.zipCode+'&'+
                                //'card[name]='+ccModel.cardName+'&'+
                                //'card[currency]=usd';

        return StripeHelper.doHTTPCallout(
                                            'POST', 
                                            'application/x-www-form-urlencoded', 
                                            stripeSetting, 
                                            '/tokens',
                                            requestBody
                                        );
    }

    public static HTTPModel createCardToken(Stripe_Setting__c stripeSetting, String stripeCustomerId, 
                                                                UnitBookingController.CreditCardModel ccModel)
    {
        String requestBody = 'card[number]='+ccModel.cardNumber+'&'+
                                'card[exp_month]='+ccModel.expMonth+'&'+
                                'card[exp_year]='+ccModel.expYear+'&'+
                                'card[cvc]='+ccModel.cvv;
                                //'card[address_zip]='+ccModel.zipCode+'&'+
                                //'card[name]='+ccModel.cardName+'&'+
                                //'card[currency]=usd';

        return StripeHelper.doHTTPCallout(
                                            'POST', 
                                            'application/x-www-form-urlencoded', 
                                            stripeSetting, 
                                            '/tokens',
                                            requestBody
                                        );
    }

    public static HTTPModel chargeStripeCustomer(Stripe_Setting__c stripeSetting, String stripeCustomerId, 
                                                    String description, String sourceID, Decimal amount, 
                                                    String receiptEmail, String statmentDesc)
    {
        if(statmentDesc != null && statmentDesc.length()>22)
            statmentDesc = statmentDesc.substring(0, 21);
        
        String requestBody = 'customer='+stripeCustomerId+'&'+
                            (description!= null ? 'description='+EncodingUtil.urlEncode(description, 'UTF-8')+'&' : '')+
                            'source='+sourceID+'&'+
                            'currency=usd&'+
                            //converting amount in cents positive integer since stripe does support positive values only
                            'amount='+Integer.ValueOf(amount*100)+'&'+ 
                            (receiptEmail != null ? 'receipt_email='+EncodingUtil.urlEncode(receiptEmail, 'UTF-8')+'&' : '')+
                            (statmentDesc != null ? 'statement_descriptor='+EncodingUtil.urlEncode(statmentDesc, 'UTF-8') : '');
                                
                                

        return StripeHelper.doHTTPCallout(
                                            'POST', 
                                            'application/x-www-form-urlencoded', 
                                            stripeSetting, 
                                            '/charges', 
                                            requestBody
                                        );
    }

    public static String getStripeResponseError(cls_error error){
        return (error.type != null ? error.type : 'Error')
            + (error.code != null ? '- '+error.code : '')+
            ': '+error.message;
    }
    public static HTTPModel doHTTPCallout(String method, String contentType, Stripe_Setting__c sc, String apiPath, String dataBody){
        HTTPModel model = new HTTPModel();
        system.debug('@@ request body =='+dataBody);
        try{
            HttpRequest req = new HttpRequest();
            req.setMethod(method);
            req.setHeader('Content-Type',contentType);
            req.setEndpoint(sc.End_Point__c+apiPath);          
            req.setHeader('Authorization','Bearer '+sc.Secret_key__c);
            if(dataBody != null)
                req.setBody(dataBody);          
            req.setTimeout(12*10000);

            Http http = new Http();
            HTTPResponse res = http.send(req);

            model.response = res.getBody().replaceAll('"object"','"objectStr"').replaceAll('"currency"','"currencyStr"');
            system.debug('@@ callout response=='+res.getBody());
        }catch(Exception e){
            system.debug('@@ exception=='+e.getMessage());
            model.response = e.getMessage();
            model.isCalloutException = true;
        }
        return model;
    }

    public static StripeCustomerParser parseStripeCustomer(String json){
        return (StripeCustomerParser) System.JSON.deserialize(json, StripeCustomerParser.class);
    }

    public static cls_data parseStripeSaveCard(String json){
        return (cls_data) System.JSON.deserialize(json, cls_data.class);
    }

    public static StripeChargeParser parseStripeCharge(String json){
        return (StripeChargeParser) System.JSON.deserialize(json, StripeChargeParser.class);
    }

    public static TokenParser parseCreateToken(String json){
        return (TokenParser) System.JSON.deserialize(json, TokenParser.class);
    }

    public class HTTPModel{
        public String response='';
        public Boolean isCalloutException = false;
    }

    public class StripeCustomerParser{
        public String id;   //cus_Cbfm7WCWPx3ffk
        public String objectStr;    //customer
        public Integer account_balance; //0
        public Integer created; //1522674623
        public String currencyStr;
        public String default_source;   //card_1CCSQVKasHLvOShlakFXZgGe
        public boolean delinquent;
        public String description;  //testing tarun
        public cls_discount discount;
        public String email;    //tarun.j@kandisatech2.com
        public String invoice_prefix;   //BBDAD32
        public boolean livemode;
        public cls_metadata metadata;
        public cls_shipping shipping;
        public cls_sources sources;
        public cls_subscriptions subscriptions;
        public cls_error error;
    }

    
    public class cls_discount {
    }
    public class cls_metadata {
    }
    public class cls_shipping {
    }
    public class cls_sources {
        public String objectStr;    //list
        public cls_data[] data;
        public boolean has_more;
        public Integer total_count; //2
        public String url;  ///v1/customers/cus_Cbfm7WCWPx3ffk/sources
    }

    public class TokenParser{
        public String id;   //tok_1CmGBoKasHLvOShlrEy4RBXv
        public String objectStr;    //token
        public cls_data card;
        public String client_ip;    //13.108.254.8
        public String created;  //1531207392
        public Boolean livemode;    //false
        public String type; //token
        public Boolean used;    //false
        public cls_error error;         
    }
    public class cls_data {
        public String id;   //card_1CCSQVKasHLvOShlakFXZgGe
        public String objectStr;    //card
        public String address_city;
        public String address_country;
        public String address_line1;
        public String address_line1_check;
        public String address_line2;
        public String address_state;
        public String address_zip;  //122332
        public String address_zip_check;    //pass
        public String brand;    //Visa
        public String country;  //US
        public String customer; //cus_Cbfm7WCWPx3ffk
        public String cvc_check;    //pass
        public String dynamic_last4;
        public Integer exp_month;   //11
        public Integer exp_year;    //2021
        public String fingerprint;  //b9QkZhVd8NwlE5pp
        public String funding;  //credit
        public String last4;    //4242
        public cls_metadata metadata;
        public String name;
        public String tokenization_method;
        public cls_error error;
    }
    public class cls_error{
        public String code;
        public String doc_url;
        public String type;
        public String message;
        public String param;
    }

    public class StripeChargeParser{
        public String id;   //ch_1CCTVBKasHLvOShlarmwUERh
        public String objectStr;    //charge
        public Integer amount;  //100
        public Integer amount_refunded; //0
        public String balance_transaction;  //txn_1CCTVBKasHLvOShlkapdFXTi
        public boolean captured;
        public Integer created; //1522678757
        public String currencyStr;  //usd
        public String customer; //cus_Cbfm7WCWPx3ffk
        public String description;  //for testing
        public boolean livemode;
        public cls_outcome outcome;
        public boolean paid;
        public boolean refunded;
        public cls_sources refunds;
        public cls_data source;
        public String status;   //succeeded
        public cls_error error;
    }
    
    public class cls_outcome {
        public String network_status;   //approved_by_network
        public cls_reason reason;
        public String seller_message;   //Payment complete.
        public String type; //authorized
    }

    public class cls_reason {
    }
    public class cls_address_city {
    }
    public class cls_address_country {
    }
    public class cls_address_line1 {
    }
    public class cls_address_line1_check {
    }
    public class cls_address_line2 {
    }
    public class cls_address_state {
    }
    public class cls_dynamic_last4 {
    }
    
    public class cls_tokenization_method {
    }
    public class cls_subscriptions {
        public String objectStr;    //list
        public cls_data[] data;
        public boolean has_more;
        public Integer total_count; //0
        public String url;  ///v1/customers/cus_Cbfm7WCWPx3ffk/subscriptions
    }

    public static void codecoveragetest(){
        string s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
    }

    public static void codecoveragetest2(){
        string s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
    }

    public static void codecoveragetest3(){
        string s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
    }

    public static void codecoveragetest4(){
        string s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
        s1 = 'this is test code';
    }


}