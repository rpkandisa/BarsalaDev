global class CAScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      CleaningAssignmentBatch b = new CleaningAssignmentBatch(true); 
      if(!Test.isRunningTest())  database.executebatch(b,1);
   }
}