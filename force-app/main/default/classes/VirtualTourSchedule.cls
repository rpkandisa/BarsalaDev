global class VirtualTourSchedule implements Schedulable {
   global void execute(SchedulableContext SC) {
      VirtualTourBatch batchTest = new VirtualTourBatch();               
      Database.executeBatch(batchTest, 1);
   }
}