public class PayCommissionController {
  @AuraEnabled
  public static List<wrpPayCommission> getPastBookings(Id AccountId) {
    Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();

    List<Account> lstAccount = [
      SELECT id, Name, PersonContactId
      FROM Account
      WHERE Id = :AccountId AND RecordTypeId = :personAccountRecordTypeId
    ];
    List<wrpPayCommission> wrapList = new List<wrpPayCommission>();

    if (lstAccount.size() > 0) {
      Account objacc = lstAccount.get(0);

      for (Xotelia_Booking__c obj : [
        SELECT
          Id,
          Name,
          Commission_paid__c,
          Commission_Rejected_Comment__c,
          Product__c,
          Product__r.Name,
          Calculated_Total_Taxed__c,
          Status__c,
          Start_Date__c,
          End_Date__c,
          Guest_Contact__c,
          Guest_Contact__r.Name,
          Commission_Amount__c,
          Commission_Belongs_To__c,
          Commission_Belongs_To__r.Name
        FROM Xotelia_Booking__c
        WHERE
          Commission_Belongs_To__c = :objacc.PersonContactId
          AND End_date__c <= :System.today()
          AND Commission_paid__c != true
        ORDER BY Unit__c ASC
      ]) {
        wrpPayCommission o = new wrpPayCommission();
        o.bookingid = obj.Id;
        o.bookingname = obj.Name;
        o.guestid = obj.Guest_Contact__c;
        o.guestname = obj.Guest_Contact__r.Name;
        o.billingcontactid = obj.Commission_Belongs_To__c;
        o.billingcontactname = obj.Commission_Belongs_To__r.Name;
        if (obj.Start_date__c != null) {
          o.startdate = obj.Start_date__c.format('yyyy/MM/dd');
        }
        if (obj.End_date__c != null) {
          o.enddate = obj.End_date__c.format('yyyy/MM/dd');
        }
        o.commissionamount = obj.Commission_Amount__c;
        o.reason = obj.Commission_Rejected_Comment__c;
        o.totaltax = obj.Calculated_Total_Taxed__c;
        o.status = obj.Status__c;
        o.unitid = obj.Product__c;
        o.unitname = obj.Product__r.Name;
        o.approverejectstatus = '';
        if (String.isNotBlank(o.reason)) {
          o.approverejectstatus = 'rejected';
        }
        wrapList.add(o);
      }
    }
    system.debug('wrapList::' + wrapList);
    return wrapList;
  }

  @AuraEnabled
  public static void SaveRejectPay(List<wrpPayCommission> lstwrp) {
    List<Xotelia_Booking__c> lstbookings = new List<Xotelia_Booking__c>();
    for (wrpPayCommission o : lstwrp) {
      lstbookings.add(
        new Xotelia_Booking__c(
          Id = o.bookingid,
          Commission_Rejected_Comment__c = o.reason
        )
      );
    }
    if (lstbookings.size() > 0) {
      update lstbookings;
    }
  }

  @AuraEnabled
  public static void SaveApprovedData(List<wrpPayCommission> lstwrp) {
    List<Xotelia_Booking__c> lstbookings = new List<Xotelia_Booking__c>();
    for (wrpPayCommission o : lstwrp) {
      lstbookings.add(
        new Xotelia_Booking__c(Id = o.bookingid, Commission_paid__c = true)
      );
    }
    if (lstbookings.size() > 0) {
      update lstbookings;
    }
  }

  @AuraEnabled
  public static void sendEmailToAccount(Id AccountId) {
    Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();

    List<Account> lstAccount = [
      SELECT id, Name, PersonContactId, PersonEmail
      FROM Account
      WHERE Id = :AccountId AND RecordTypeId = :personAccountRecordTypeId
    ];

    Account acc = lstAccount.get(0);

    List<String> emailList = new List<String>();
    emailList.add(acc.PersonEmail);
    EmailTemplate templateId = [
      SELECT id
      FROM EmailTemplate
      WHERE name = 'Pay Commission Email Template'
    ];
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setTemplateID(templateId.Id);

    mail.setSaveAsActivity(false);
    mail.setToAddresses(emailList);
    mail.setWhatId(acc.Id);
    mail.setTargetObjectId(acc.PersonContactId);
    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
      mail
    };
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
  }

  public class wrpPayCommission {
    @AuraEnabled
    public Id bookingid { get; set; }
    @AuraEnabled
    public String bookingname { get; set; }
    @AuraEnabled
    public Id unitid { get; set; }
    @AuraEnabled
    public String unitname { get; set; }
    @AuraEnabled
    public String startdate { get; set; }
    @AuraEnabled
    public String enddate { get; set; }
    @AuraEnabled
    public Id guestid { get; set; }
    @AuraEnabled
    public String guestname { get; set; }
    @AuraEnabled
    public Id billingcontactid { get; set; }
    @AuraEnabled
    public String billingcontactname { get; set; }
    @AuraEnabled
    public String status { get; set; }
    @AuraEnabled
    public Decimal totaltax { get; set; }
    @AuraEnabled
    public Decimal commissionamount { get; set; }
    @AuraEnabled
    public String approverejectstatus { get; set; }
    @AuraEnabled
    public boolean isokay { get; set; }
    @AuraEnabled
    public boolean isrecordchange { get; set; }

    @AuraEnabled
    public boolean IsEnable { get; set; }
    @AuraEnabled
    public boolean IsDisable { get; set; }
    @AuraEnabled
    public boolean paymentSend { get; set; }
    @AuraEnabled
    public String reason { get; set; }
  }
}