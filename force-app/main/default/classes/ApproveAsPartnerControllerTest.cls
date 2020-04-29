@isTest
public class ApproveAsPartnerControllerTest {
    
	
    static testMethod void validateAccount() {

        String recordTypeId = Schema.getGlobalDescribe()
        .get('Account')
        .getDescribe()
        .getRecordTypeInfosByName()
        .get('Person Account')
        .getRecordTypeId();
        Account acc = new Account(
            RecordTypeID = recordTypeId,
            FirstName = 'Test FName',
            LastName = 'Test LName',
            PersonMailingStreet = 'test@yahoo.com',
            PersonMailingPostalCode = '12345',
            PersonMailingCity = 'SFO',
            PersonEmail = 'test@yahoo.com',
            PersonHomePhone = '1234567',
            PersonMobilePhone = '12345678',
            Commission_Status__pc='Requested'
        );
        insert acc;


        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        ApproveAsPartnerController objAC = new ApproveAsPartnerController(sc);

        PageReference pageRef = Page.ApproveAsPartner;
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);

        objAC.updateAccountRecord();

    }        
}