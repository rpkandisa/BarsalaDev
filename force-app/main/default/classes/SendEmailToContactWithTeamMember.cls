//Added By Kandisatech on 07/12/2018 
//It is used to send email to Contact for generic way
public with sharing class SendEmailToContactWithTeamMember {
    
    @InvocableMethod(label='Send Email To Contact With TeamMember')
    public static void SendEmailToContact(List<SendEmailToContactInner> lstwrp){
        Set<string> emailTemplateName = new Set<string>();
        Set<Id> caseIds = new Set<Id>();
        for(SendEmailToContactInner s : lstwrp){
            caseIds.add(s.caseId);
            emailTemplateName.add(s.emailTemplateName);
        }

        //List<EmailServicesAddress> lstEmailServicesAddress = new List<EmailServicesAddress>([select EmailDomainName from  EmailServicesAddress where IsActive=true and Function.FunctionName = 'EmailToCase' ]);
        // string emailtosalesforce = '';
        // if(lstEmailServicesAddress.size() > 0){
        //     emailtosalesforce = lstEmailServicesAddress.get(0).EmailDomainName;
        // }

        Map<Id,Case> mapCase = new Map<Id,Case>([select id,casenumber,contactId,OwnerId,(SELECT Id, ParentId, MemberId, Member.Email FROM TeamMembers) from Case where Id in: caseIds]);

        System.debug('templateid ' + emailTemplateName);
        Map<string,EmailTemplate> mapEmailTemplate = new Map<string,EmailTemplate>();
        for(EmailTemplate et : [Select id,name,subject from EmailTemplate where name =:emailTemplateName]){
            System.debug('et@@@@@ ' + et);
            mapEmailTemplate.put(et.name.tolowercase(),et);
        }

        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        Id toEmailId = null, emailTemplateId = null;
        List<Id> contactIds = new List<Id>();
        
        for(SendEmailToContactInner s : lstwrp){
            contactIds = new List<Id>();
            toEmailId = null;
            emailTemplateId = null;
            Case c = mapCase.get(s.caseId);
            
            toEmailId = s.contactId;
            if(mapEmailTemplate.containsKey(s.emailTemplateName.toLowerCase())){
                emailTemplateId = mapEmailTemplate.get(s.emailTemplateName.toLowerCase()).Id;
            }else{
                continue;
            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(toEmailId);            
            mail.setTemplateId(emailTemplateId);
            mail.setReplyTo('noreply@barsala.com');
            mail.setSenderDisplayName('Barsala Support');  

            // string strSubject = '';
            // if(mapEmailTemplate.containsKey(s.emailTemplateName.toLowerCase())){
            //     if(!String.isBlank(mapEmailTemplate.get(s.emailTemplateName.toLowerCase()).Subject)){
            //         strSubject = mapEmailTemplate.get(s.emailTemplateName.toLowerCase()).Subject + ' ' + getThreadId(s.caseId);
            //     }else{
            //         strSubject = getThreadId(s.caseId);
            //     }                
            // }
            // mail.setSubject(strSubject);
            // mail.setTreatBodiesAsTemplate(true);

            List<string> lstMemberEmails = new List<string>();
            for(CaseTeamMember ctm : c.TeamMembers){
                lstMemberEmails.add(ctm.Member.Email);
            }

            //lstMemberEmails.add(Label.CaseThreadIdEmail);

            //system.debug('@@@@@lstMemberEmails ' + lstMemberEmails);            
            mail.setWhatId(s.caseId);            
            //system.debug('@@@@@lstMemberEmails ' + lstMemberEmails);

            if(lstMemberEmails.size()>0) mail.setCcAddresses(lstMemberEmails);
            
            mails.add(mail);
        }

        if(mails.size()>0){
            Messaging.sendEmail(mails);
        }
    }
    
    public class SendEmailToContactInner {
        @InvocableVariable(required=true)
        public ID caseId;

        @InvocableVariable(required=true)
        public ID contactId;

        @InvocableVariable(required=true)
        public String emailTemplateName;
    }

}