//Added By Kandisatech on 10/12/2018 
//It is used to create case team member
@isTest
public with sharing class autoCreateCaseTeamMemberTest {
    static testMethod void validateautoCreateCaseTeamMembers() {
        Test.starttest();
        
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sales - Monthlies').getRecordTypeId();
        Account acc = new Account();
        acc.Name='NewAcc';
        acc.RecordTypeId = accRTId;
        insert acc;

        Contact c = new Contact(AccountId = acc.Id);
        c.LastName = 'contactlastname';
        c.Email = 'test123@bc.com';
        insert c;

        /*CaseTeamRole ctr = new CaseTeamRole();
        ctr.Name = 'CC';
        ctr.AccessLevel = 'Edit';
        insert ctr;*/

        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', ContactId = c.Id,  Accountid = acc.Id, Subject = 'TestSubject', Description = 'TestDescription'); 
        insert cas;

        CaseTeamRole ctr = new CaseTeamRole();
        ctr=[select Id, AccessLevel from CaseTeamRole limit 1];
       

        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
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

       
        CaseTeamMember ctm = new CaseTeamMember();
        ctm.TeamRoleId = ctr.Id;
        ctm.ParentId = cas.Id;
        ctm.MemberId = uu.Id;
        insert ctm;

        autoCreateCaseTeamMembers.CreateCaseTeamMemberInner obj = new autoCreateCaseTeamMembers.CreateCaseTeamMemberInner();
        obj.caseId = cas.Id;
        obj.userNames = uu.Username;
        obj.teamRoleName = 'CC';
        autoCreateCaseTeamMembers.CreateCaseTeamMemberRecords(new List<autoCreateCaseTeamMembers.CreateCaseTeamMemberInner> { obj });

        Test.stoptest();
    }
}