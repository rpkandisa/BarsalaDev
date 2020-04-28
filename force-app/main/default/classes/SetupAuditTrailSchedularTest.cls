@isTest
public class SetupAuditTrailSchedularTest {

     @isTest(SeeAllData=false)
    public static void ModifyValidationRule(){
        
        AuditTrailForValidationRule__c   csBatch = new AuditTrailForValidationRule__c();
        csBatch.SetupAuditTrailID__c = '0Ym5C00000V8ZMWBBB';
        csBatch.AuditCreatedDate__c = DateTime.newInstance(2019, 02, 02, 12, 19, 23);
        Insert csBatch;
        
        Test.startTest();
        DateTime now = system.now();
        String cron = '0 0 * * 1-12 ? *';
        System.debug(cron);
        String jobId = System.schedule('Scheduled SetupAuditTrailSchedular', cron,  new SetupAuditTrailSchedular());     
        Test.stopTest();
        
    }
}