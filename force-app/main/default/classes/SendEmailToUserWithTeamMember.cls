//Added By Kandisatech on 10/12/2018 
//It is used to send email for generic way
public with sharing class SendEmailToUserWithTeamMember {
    
    @InvocableMethod(label='Send Email To User With TeamMember')
    public static void SendEmailToUser(List<SendEmailToUserInner> lstwrp){
        Set<string> emailTemplateName = new Set<string>();
        Set<Id> caseIds = new Set<Id>();
        for(SendEmailToUserInner s : lstwrp){
            caseIds.add(s.caseId);
            emailTemplateName.add(s.emailTemplateName);
        }

        Map<Id,Case> mapCase = new Map<Id,Case>([select id,casenumber,contactId,OwnerId,Owner.Email,Owner.isActive,(SELECT Id, ParentId, MemberId, Member.Email FROM TeamMembers) from Case where Id in: caseIds]);

        //Fill all the queue Member
        Set<Id> setQueueIds = new Set<Id>();
        for(Case c : mapCase.values()){
            if(!string.valueof(c.OwnerId).startsWith('005')){
                setQueueIds.add(c.OwnerId);
            }
        }

        Set<Id> queueUsers = new Set<Id>();
        Map<Id,Set<Id>> mapGroupIdvsUserIds = new Map<Id,Set<Id>>();
        if(setQueueIds.size()>0){              
            for(GroupMember gm: [SELECT Id, GroupId, UserOrGroupId FROM GroupMember where GroupId in: setQueueIds]){
                if(string.valueof(gm.UserOrGroupId).startswith('005')){
                    if(mapGroupIdvsUserIds.containsKey(gm.GroupId)){
                        mapGroupIdvsUserIds.get(gm.GroupId).add(gm.UserOrGroupId);
                    }else{
                        mapGroupIdvsUserIds.put(gm.GroupId, new Set<Id> { gm.UserOrGroupId });
                    }
                    queueUsers.add(gm.UserOrGroupId);
                }                
            }
        }

        Map<Id,User> mapQueueUser = new Map<Id,User>();
        if(queueUsers.size()>0){
            for(User u: [select id,email from user where id in: queueUsers and isActive=true]){
                mapQueueUser.put(u.id,u);
            }
        }

        Map<string,Id> mapEmailTemplate= new Map<string,Id>();
        for(EmailTemplate et : [Select id,name from EmailTemplate where name in:emailTemplateName]){
            mapEmailTemplate.put(et.name.tolowercase(),et.id);
        }

        Map<Integer,Messaging.SingleEmailMessage> tempmails =  new Map<Integer,Messaging.SingleEmailMessage>();
        Id tempemailTemplateId = null; Integer indexsendemail = 0;
        for(SendEmailToUserInner s : lstwrp){
            Case c = mapCase.get(s.caseId);

            if(!c.Owner.isActive) continue;

            if(mapEmailTemplate.containsKey(s.emailTemplateName.toLowerCase())){
                tempemailTemplateId = mapEmailTemplate.get(s.emailTemplateName.toLowerCase());
            }else{
                continue;
            }
                
            // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(tempemailTemplateId, s.OwnerId, s.caseId);
            String emailSubject = mail.getSubject();
            String emailTextBody = mail.getPlainTextBody();

            mail.setTargetObjectId(s.OwnerId);
            mail.setSubject(emailSubject);
            mail.setPlainTextBody(emailTextBody);
            mail.saveAsActivity = false;


            // // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // mail.setTargetObjectId(s.OwnerId);            
            // mail.setTemplateId(tempemailTemplateId);
            
            // //mail.setWhatId(s.caseId);
            // mail.setSaveAsActivity(false);
            tempmails.put(indexsendemail, mail);
            indexsendemail++;
        }

        if(tempmails.size()>0){
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(tempmails.values());
            Database.rollback(sp);
        }

        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();        
        List<string> contactOrUserIds = new List<string>();
        string toEmailId = '';        

        Integer IndexUsedForEmail = 0;
        for(SendEmailToUserInner s : lstwrp){
            toEmailId = '';
            Case c = mapCase.get(s.caseId);

            if(!c.Owner.isActive) continue;
            
            if(!string.valueof(c.OwnerId).startsWith('005')){ // if case owner is not user mean it's queue
                if(mapGroupIdvsUserIds.containsKey(c.OwnerId)){                        
                    Integer idx = 0;
                    for(Id usrid : mapGroupIdvsUserIds.get(c.OwnerId)){
                        if(idx == 0) {
                            toEmailId = mapQueueUser.get(usrid).Email;
                            idx++;
                        }else{
                            contactOrUserIds.add(mapQueueUser.get(usrid).Email);
                        }
                    }
                }else{
                    continue; // queue is not contains user
                }
            }else{
                toEmailId = c.OwnerId; // If case owner is user
            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            sendTo.add(toEmailId);
            mail.setToAddresses(sendTo);
            mail.setReplyTo('noreply@barsala.com');
            mail.setSenderDisplayName('Barsala Support');

            List<string> lstMemberEmails = new List<string>();
            for(CaseTeamMember ctm : c.TeamMembers){
                lstMemberEmails.add(ctm.Member.Email);
            }
            //system.debug('@@@@@lstMemberEmails ' + lstMemberEmails);          
            //mail.setSaveAsActivity(false);
            if(contactOrUserIds.size()>0){
                lstMemberEmails.addAll(contactOrUserIds);
            }
                       
            //system.debug('@@@@@lstMemberEmails ' + lstMemberEmails);
            if(lstMemberEmails.size()>0) mail.setCcAddresses(lstMemberEmails);

            Messaging.SingleEmailMessage tempemail = tempmails.get(IndexUsedForEmail);
            if(tempemail.getPlainTextBody() != null && !string.isBlank(tempemail.getPlainTextBody())) mail.setPlainTextBody(tempemail.getPlainTextBody());
            if(tempemail.getHTMLBody() != null &&  !string.isBlank(tempemail.getHTMLBody())) mail.setHTMLBody(tempemail.getHTMLBody());
            if(tempemail.getSubject() != null && !string.isBlank(tempemail.getSubject())) mail.setSubject(tempemail.getSubject());
            
            mails.add(mail);
            IndexUsedForEmail++;
        }

        if(mails.size()>0){
            Messaging.sendEmail(mails);
        }
    }

    public class SendEmailToUserInner {
        @InvocableVariable(required=true)
        public ID caseId;

        @InvocableVariable(required=true)
        public String OwnerId;

        @InvocableVariable(required=true)
        public String emailTemplateName;
    }

}