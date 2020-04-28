public with sharing class ShowBookingsController {
  public Id AccId { get; set; }

  public ShowBookingsController() {
    system.debug('AccId ::' + AccId);
  }

  public Contact getContact() {
    contact con = [SELECT id, Name FROM Contact WHERE AccountId = :AccId];

    return con;
  }
  public List<Wrapper> getBookingDetails() {
    contact con = [SELECT id, Name FROM Contact WHERE AccountId = :AccId];
    List<Xotelia_Booking__c> AllBookingList = [
      SELECT
        id,
        name,
        Commission_Rejected_Comment__c,
        Unit__c,
        Start_date__c,
        Commission_Amount__c,
        Commission_Belongs_To__c,
        Commission_Belongs_To__r.Name,
        Commission_Belongs_To__r.phone,
        End_date__c,
        Commission_paid__c
      FROM Xotelia_Booking__c
      WHERE Commission_Belongs_To__c = :con.Id
      //AND lastModifiedDate = :System.today()
      //AND Commission_Rejected_Comment__c != null
    ];
    List<Wrapper> wrapList = new List<Wrapper>();

    for (Xotelia_Booking__c book : AllBookingList) {
      if (book.Commission_Rejected_Comment__c != null) {
        Wrapper wrap = new Wrapper();
        wrap.ContactName = book.Commission_Belongs_To__r.Name;
        wrap.ContactPhone = book.Commission_Belongs_To__r.Phone;
        Datetime sdt = book.Start_date__c;
        String formattedSDate = sdt.format('dd-MM-YYYY');

        wrap.startDate = formattedSDate;
        Datetime edt = book.End_date__c;
        String formattedEDate = edt.format('dd-MM-YYYY');
        wrap.endDate = formattedEDate;
        wrap.unitName = book.Unit__c;
        wrap.rejectionReason = book.Commission_Rejected_Comment__c;
        wrapList.add(wrap);
      }
    }

    return wrapList;
  }

  public decimal getTotalAmount() {
    contact con = [SELECT id, Name FROM Contact WHERE AccountId = :AccId];
    List<Xotelia_Booking__c> AllBookingList = [
      SELECT
        id,
        name,
        Commission_Rejected_Comment__c,
        Unit__c,
        Start_date__c,
        Commission_Amount__c,
        Commission_Belongs_To__c,
        Commission_Belongs_To__r.Name,
        Commission_Belongs_To__r.phone,
        End_date__c,
        Commission_paid__c
      FROM Xotelia_Booking__c
      WHERE Commission_Belongs_To__c = :con.Id
      //AND lastModifiedDate = :System.today()
      //AND Commission_Rejected_Comment__c != null
    ];

    decimal totalAmount = 0.00;
    for (Xotelia_Booking__c book : AllBookingList) {
      if (
        book.Commission_paid__c == true &&
        book.Commission_Amount__c != null
      ) {
        totalAmount += book.Commission_Amount__c;
      }
    }
    return totalAmount;
  }

  public class Wrapper {
    public String ContactName { get; set; }
    public String ContactPhone { get; set; }
    public String startDate { get; set; }
    public String endDate { get; set; }
    public String unitName { get; set; }
    public String rejectionReason { get; set; }
  }
}