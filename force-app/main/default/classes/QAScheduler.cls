global class QAScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      QAAssignmentBatch b = new QAAssignmentBatch(); 
      if(!Test.isRunningTest()) database.executebatch(b,1);
   }
}