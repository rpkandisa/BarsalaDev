global class SharinpixDeleleteRecordScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    BatchtoDeleteShrinpixImgRecord b = new BatchtoDeleteShrinpixImgRecord();
    database.executebatch(b, 10);
  }
}