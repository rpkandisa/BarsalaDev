//Added By Kandisatech on 11/12/2018 
//It is used to send email to contact on case object
@isTest
public with sharing class SendEmailToContactWithTeamMemberTest {
    static testMethod void validateSendEmailToContactWithTeamMemberTest() {
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sales - Monthlies').getRecordTypeId();
        Account acc = new Account();
        acc.Name='NewAcc';
        acc.RecordTypeId = accRTId;
        insert acc;

        Contact c = new Contact(AccountId = acc.Id);
        c.LastName = 'contactlastname';
        c.Email = 'test123@bc.com';
        insert c;

        Profile pf= [Select Id from profile where Name='System Administrator' limit 1]; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        );         
        insert uu;

        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        Test.starttest();

        system.runas(uu){

            GroupMember gm = new GroupMember(
                GroupId = testGroup.Id,
                UserOrGroupId = uu.Id
            );
            insert gm;

            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;

            Case cas = new Case(Status ='Pending', Priority = 'Medium', Origin = 'Email', ContactId = c.Id,  Accountid = acc.Id, Subject = 'TestSubject', Description = 'TestDescription'); 
            insert cas;

            cas.ownerId =  testGroup.Id;
            update cas;

            List<SendEmailToContactWithTeamMember.SendEmailToContactInner> lstETC = new List<SendEmailToContactWithTeamMember.SendEmailToContactInner>();
            SendEmailToContactWithTeamMember.SendEmailToContactInner objsetoc = new SendEmailToContactWithTeamMember.SendEmailToContactInner();
            objsetoc.caseId = cas.Id;
            objsetoc.contactId = c.Id;
            objsetoc.emailTemplateName = 'SUPPORT: Escalation Reminder to Owner';
            lstETC.add(objsetoc);

            SendEmailToContactWithTeamMember.SendEmailToContact(lstETC);

        }

        Test.stoptest();
    }
}