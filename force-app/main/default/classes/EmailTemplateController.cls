public class EmailTemplateController {
    public ResponseModel model{get;set;}

    /*public EmailTemplateController(){
        ID recordId = ApexPages.CurrentPage().getParameters().get('id');
        model = getCheckinInfo(recordId);
    }

    public EmailTemplateController(ApexPAges.StandardController sc){
        ID recordId = sc.getId();
        model = getCheckinInfo(recordId);
    }*/

	@AuraEnabled
    public static ResponseModel getCheckinInfo(ID recordId){
        ResponseModel rm = new ResponseModel();
        rm.uiContext = UserInfo.getUiThemeDisplayed();
        
        try{
            List<Xotelia_Booking__c> bookings = [select id, Email_Template_Name__c from Xotelia_Booking__c where id=:recordId];
            if(bookings.size()>0){
                if(bookings[0].Email_Template_Name__c != null){
                    List<EmailTemplate> emailTemplates = [select id from EmailTemplate where DeveloperName=:bookings[0].Email_Template_Name__c];
                    if(emailTemplates.size()>0){
                        Messaging.SingleEmailMessage mail = 
                            Messaging.renderStoredEmailTemplate(emailTemplates[0].Id, null, recordId);
                        
                        rm.htmlBody = mail.getHTMLBody();
                        rm.isError = false;
                    }else
                        rm.messages.add('Invalid Template, Please contact customer support');
                }else
                    rm.messages.add('Checkin/Checkout information is not avaialble at this moment.');
            }else{
                rm.messages.add('Invalid booking record!');
            }
        }catch(Exception e){
            rm.messages.add((e.getTypeName()+', '+e.getMessage()+', at line '+e.getLineNumber()));
        }
        return rm;
    }
        
    public class ResponseModel{
        @AuraEnabled public List<String> messages;
        @AuraEnabled public String htmlBody;
        @AuraEnabled public Boolean isError;
		@AuraEnabled public String uiContext;
        
        public ResponseModel(){
            messages = new List<String>();
            isError=true;
        }
    }
}