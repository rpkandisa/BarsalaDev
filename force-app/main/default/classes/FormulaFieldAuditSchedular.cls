/* 
* Class: FormulaFieldAuditSchedular
* Date: 04 Feb 2020
* Purpose: Send Email when the Custom Formula Field Barsala_Price_Modeled_Final__c	(Unit Pricing Object) and 
*          Price__c (Building Unit Set Pricing Object) modifies.
* 
*/
global class FormulaFieldAuditSchedular implements Schedulable {
	
     global void execute(SchedulableContext ctx){
        
        AuditTrailForValidationRule__c   csBatch = AuditTrailForValidationRule__c.getOrgDefaults();
        System.debug('Last Record Id: ' + csBatch.CFFSetupAuditTrailID__c);
        System.debug('Last Record CreatedDate : ' + csBatch.CFFAuditCreatedDate__c);
        System.debug('Current Time : ' + System.now());
        
        List<SetupAuditTrail> lstAuditTrail =  [ SELECT Id, Action, Display, CreatedDate, Section, CreatedBy.Name  FROM SetupAuditTrail  
                                                WHERE (Action = 'changedCFFormulaCustom') AND
                                                (Id != :csBatch.CFFSetupAuditTrailID__c  AND CreatedDate > : csBatch.CFFAuditCreatedDate__c  )
                                                ORDER BY CreatedDate DESC];
        
        
        System.debug('lstAuditTrail :: ' + lstAuditTrail);
        if(lstAuditTrail != null && lstAuditTrail.size() > 0 ){
            
            List<SetUpAuditTrailWrapper> AuditWrapList = new List<SetUpAuditTrailWrapper>();
            Set<String> AuditWrapSet = new Set<String>();
            
            for(SetupAuditTrail trail : lstAuditTrail){
                String disaplay = trail.Display;
                if(!AuditWrapSet.contains ('Barsala Price Modeled (Final)') && 
                   disaplay.contains('Barsala Price Modeled (Final)') ){
                       
                       SetUpAuditTrailWrapper wrap = new SetUpAuditTrailWrapper();
                       wrap.CFFAuditTrailId = trail.Id;
                       wrap.CFFAuditTrailCreatedDate  = trail.CreatedDate;
                       wrap.AuditTrailCreatedBy = trail.CreatedBy.name; 
                       wrap.CFFName = 'Barsala Price Modeled (Final)';
                       wrap.CFFObject = 'Unit Pricing';
                       wrap.CFFLink = 'https://barsala.my.salesforce.com/00N3600000RA4O8?setupid=CustomObjects';
                       AuditWrapList.add(wrap);
                       AuditWrapSet.add('Barsala Price Modeled (Final)');
                       
                   }else if(!AuditWrapSet.contains ('Price custom field on Building Unit Set Pricing') &&
                            disaplay.contains('Price custom field on Building Unit Set Pricing')){
                                
                                SetUpAuditTrailWrapper wrap = new SetUpAuditTrailWrapper();
                                wrap.CFFAuditTrailId = trail.Id;
                                wrap.CFFAuditTrailCreatedDate = trail.CreatedDate;
                                wrap.AuditTrailCreatedBy = trail.CreatedBy.name; 
                                wrap.CFFName = 'Price';
                                wrap.CFFObject = 'Building Unit Set Pricing';
                                wrap.CFFLink = 'https://barsala.my.salesforce.com/00N1Q00000ToXxP?setupid=CustomObjects';
                                wrap.AuditTrailCreatedBy = trail.CreatedBy.name; 
                                AuditWrapList.add(wrap);
                                AuditWrapSet.add('Price custom field on Building Unit Set Pricing');
                            }
                if(AuditWrapSet.size() == 2)
                    break;
            }
            
			System.debug('AuditWrapSet :: ' + AuditWrapSet);   
            System.debug('AuditWrapList :: ' + AuditWrapList);
            
            if(AuditWrapList.size() > 0){
                csBatch.CFFSetupAuditTrailID__c = AuditWrapList[0].CFFAuditTrailId;
                csBatch.CFFAuditCreatedDate__c = AuditWrapList[0].CFFAuditTrailCreatedDate;
                Update csBatch;
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                string[] to = System.Label.BookingValidationEmails.split(','); 
                    email.setToAddresses(to);
                
                String emailSubject;
                String emailBody;
                
                if(AuditWrapList.size() == 1){
                    
                    emailSubject = 'Formula Field "' + AuditWrapList[0].CFFName + '" on ' + AuditWrapList[0].CFFObject + ' has been modified!';
                    emailBody = 	'Hi Salesforce Admin,<br/><br/>' +
                    ' <b>' + AuditWrapList[0].AuditTrailCreatedBy + '</b>  has modified <a href="' + AuditWrapList[0].CFFLink + '" target="_blank "> this </a> Formula Field,' + 
                    ' request you to please review this change.' +
                    ' <br/><br/>Thanks!';
                    
                }else if(AuditWrapList.size() == 2){
                    
                    emailSubject = 'Formula Fields have been modified!';
                    emailBody = 	'Hi Salesforce Admin,<br/><br/>' +
                    ' Following formula fields have been modified,' + 
                    '<ol> <li> <a href="' + AuditWrapList[0].CFFLink + '" target="_blank "> '+ AuditWrapList[0].CFFName + '</a> on ' + AuditWrapList[0].CFFObject + ' have been modified by <b>' + AuditWrapList[0].AuditTrailCreatedBy + '</b> </li>' +
                    '<li> <a href="' + AuditWrapList[1].CFFLink + '" target="_blank "> '+ AuditWrapList[1].CFFName + '</a> on ' + AuditWrapList[1].CFFObject + ' have been modified by <b>' + AuditWrapList[1].AuditTrailCreatedBy + '</b> </li> </ol>' +
                    ' <br/>Request you to please review these changes.' +
                    ' <br/><br/>Thanks!';
                    
                }
                email.setSubject(emailSubject);
                email.setHtmlBody(emailBody);
                
                System.debug('Email Subject : ' + emailSubject);
                System.debug('Email Body : ' + emailBody);
                
                try{
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                }catch(exception e){
                    System.debug('Exception:: ' + e.getLineNumber() + ' : ' + e.getMessage());
                }
            }
        }
    }
    
    public class SetUpAuditTrailWrapper{
        public string CFFAuditTrailId {get;set;}
        public DateTime CFFAuditTrailCreatedDate {get;set;}
        public string CFFName {get;set;}
        public String CFFObject {get;set;}
        public String CFFLink {get;set;}
        Public String AuditTrailCreatedBy {get;set;}
    }
}