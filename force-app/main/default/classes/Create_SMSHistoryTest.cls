@isTest
public class Create_SMSHistoryTest {
  @isTest
  public static void TestSMSHistoryData() {
    Contact con = new Contact(
      FirstName = 'test',
      LastName = 'July',
      Phone = '9999888876'
    );
    insert con;

    Create_SMSHistory.wrpsmshistory wrap = new Create_SMSHistory.wrpsmshistory();
    wrap.senderPhoneNumber = '12068007277';
    wrap.smsText = 'TEst reply.';
    wrap.recepientPhoneNumber = '19999888876';
    wrap.contactId = con.Id;
    List<Create_SMSHistory.wrpsmshistory> wrapList = new List<Create_SMSHistory.wrpsmshistory>();
    wrapList.add(wrap);

    Test.startTest();
    Create_SMSHistory.createSMSHistory(wrapList);
    Test.stopTest();
  }
}