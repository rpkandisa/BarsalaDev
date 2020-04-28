global class ScheduleUpdateUnitCountBatch implements Schedulable {
	
   global void execute(SchedulableContext SC) {

      UpdateUnitCountBatch up = new UpdateUnitCountBatch();
        database.executeBatch(up);

   }


}