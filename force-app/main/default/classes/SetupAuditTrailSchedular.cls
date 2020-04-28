/* 
* Class: SetupAuditTrailSchedular
* Date: 03 Feb 2020
* Purpose: Send Email when the validation Rule 'Underbooking' on Booking object get modifies.
* 
*/
global class SetupAuditTrailSchedular implements Schedulable {

    global void execute(SchedulableContext ctx){
        
        AuditTrailForValidationRule__c   csBatch = AuditTrailForValidationRule__c.getOrgDefaults();
        System.debug('Last Record Created date: ' + csBatch.AuditCreatedDate__c);
        System.debug('Last Record CSBatch : ' + csBatch);
        System.debug('Current Time : ' + System.now());
        
        List<SetupAuditTrail> lstAuditTrail =  [ SELECT Id, Action, Display, CreatedDate, Section, CreatedBy.Name  FROM SetupAuditTrail  
                                                WHERE (Action = 'changedValidationFormula' OR Action = 'changedValidationActive'  ) AND
                                                (Id != :csBatch.SetupAuditTrailID__c AND CreatedDate > : csBatch.AuditCreatedDate__c )
                                                ORDER BY CreatedDate DESC];
        
        /*(Id != :csBatch.SetupAuditTrailID__c AND CreatedDate > : csBatch.AuditCreatedDate__c )*/
        
        System.debug('lstAuditTrail :: ' + lstAuditTrail.size());
        if(lstAuditTrail != null && lstAuditTrail.size() > 0 ){
            
            
            Boolean VLRHasMidified = false;
            String LatestAuditTrailId;
            DateTime LatestedAuditTrailCreateddate;
            String ModifiedByUser;
            
            for(SetupAuditTrail trail : lstAuditTrail){
                String disaplay = trail.Display;
                if(disaplay.contains('\"Underbooking\"') && !disaplay.contains('Underbooking_')){
                    VLRHasMidified = true;
                    LatestAuditTrailId = trail.Id;
                    LatestedAuditTrailCreateddate = trail.CreatedDate;
                    ModifiedByUser = trail.CreatedBy.name;
                    break;
                }
            }
            
            
            if(VLRHasMidified){
                csBatch.SetupAuditTrailID__c = LatestAuditTrailId;
                csBatch.AuditCreatedDate__c = LatestedAuditTrailCreateddate;
                Update csBatch;
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                string[] to = System.Label.BookingValidationEmails.split(','); 
                    email.setToAddresses(to);
                email.setSubject('Validation Rule "Underbooking" has been modified!');
                
                String emailBody = 	'Hi Salesforce Admin,<br/><br/>' +
                    ' <b>' + ModifiedByUser + '</b>  has modified <a href="https://barsala.my.salesforce.com/03d1Q000001UQPY?setupid=CustomObjects" target="_blank "> this </a> validation rule,' + 
                    ' request you to please review this change.' +
                    ' <br/><br/>Thanks!';
                
                
                System.debug('Email Body : ' + emailBody);
                
                email.setHtmlBody(emailBody);
                try{
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                }catch(exception e){
                    System.debug('Exception:: ' + e.getLineNumber() + ' : ' + e.getMessage());
                }
            }
        }
    }
}