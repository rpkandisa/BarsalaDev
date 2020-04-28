@isTest
public class FormulaFieldAuditSchedularTest {

    @isTest(SeeAllData=false)
    public static void ModifyFormulaField(){
        
        AuditTrailForValidationRule__c   csBatch = new AuditTrailForValidationRule__c();
        csBatch.CFFSetupAuditTrailID__c = '0Ym5C00000V8ZMWBBB';
        csBatch.CFFAuditCreatedDate__c = DateTime.newInstance(2019, 02, 02, 12, 19, 23);
        Insert csBatch;
        
        Test.startTest();
        DateTime now = system.now();
        String cron = '0 0 * ? * * *';
        System.debug(cron);
        String jobId = System.schedule('Scheduled FormulaFieldAuditSchedular', cron,  new FormulaFieldAuditSchedular());     
        Test.stopTest();
        
    }
}