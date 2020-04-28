//Added By Kandisatech on 11/12/2018 
//It is used to send email to user or queue on case object
@isTest
public with sharing class SendEmailToUserWithTeamMemberTest {
    static testMethod void validateSendEmailToUserWithTeamMemberTest() {
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

            List<SendEmailToUserWithTeamMember.SendEmailToUserInner> lstwrp = new List<SendEmailToUserWithTeamMember.SendEmailToUserInner>();
            SendEmailToUserWithTeamMember.SendEmailToUserInner objSendEmailToUserInner = new SendEmailToUserWithTeamMember.SendEmailToUserInner();
            objSendEmailToUserInner.caseId = cas.Id;
            objSendEmailToUserInner.OwnerId = uu.Id;
            objSendEmailToUserInner.emailTemplateName = 'Notify assignee of assignment';
            lstwrp.add(objSendEmailToUserInner);

            SendEmailToUserWithTeamMember.SendEmailToUser(lstwrp);


            //cas.ownerId =  testGroup.Id;
            //update cas;
        }

        Test.stoptest();
    }
}