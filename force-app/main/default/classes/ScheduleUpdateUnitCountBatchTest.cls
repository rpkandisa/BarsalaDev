@isTest
public  class ScheduleUpdateUnitCountBatchTest {
    
    static testMethod void validateScheduleUpdateUnitCountBatchTest() {
        Test.starttest();
        ScheduleUpdateUnitCountBatch sh1 = new ScheduleUpdateUnitCountBatch();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test ScheduleUpdateUnitCountBatch Check', sch, sh1); 
        Test.stoptest();
    }
    
}