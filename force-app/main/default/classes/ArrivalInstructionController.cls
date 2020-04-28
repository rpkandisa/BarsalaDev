public class ArrivalInstructionController {
  @AuraEnabled
  public static ArrivalInstructionsDetails getUnitArrivalInstruction(
    String UnitId
  ) {
    System.debug('unitId --> ' + UnitId);
    ArrivalInstructionsDetails arrInstructionsDetails = new ArrivalInstructionsDetails();
    List<sharinpix__SharinPixImage__c> lst_sharinPixImage = new List<sharinpix__SharinPixImage__c>();

    if (UnitId != null) {
      Unit__c unit = [
        SELECT
          Id,
          Arrival_Instructions_Template__c,
          Unit_Number__c,
          Floor__c,
          Parking__c,
          Arrival_Instructions_Template__r.Building__r.Neighborhood__r.City__r.Barsala_Primary__r.Name,
          Arrival_Instructions_Template__r.Building__r.Neighborhood__r.City__r.Barsala_Primary__r.Phone_Standardized__c
        FROM Unit__c
        WHERE Id = :UnitId
        LIMIT 1
      ];
      arrInstructionsDetails.unitId = unit.Id;
      arrInstructionsDetails.unitNumber = unit.Unit_Number__c;
      arrInstructionsDetails.floorNumber = unit.Floor__c;
      arrInstructionsDetails.parking = unit.Parking__c;
      arrInstructionsDetails.cityManagerName = unit.Arrival_Instructions_Template__r.Building__r.Neighborhood__r.City__r.Barsala_Primary__r.Name;
      arrInstructionsDetails.cityManagerPhone = unit.Arrival_Instructions_Template__r.Building__r.Neighborhood__r.City__r.Barsala_Primary__r.Phone_Standardized__c;

      if (unit.Arrival_Instructions_Template__c != null) {
        lst_sharinPixImage = [
          SELECT
            id,
            Checkin_Instruction_Step_Number__c,
            Checkin_Instruction_Description__c,
            Arrival_Instructions_Template__c,
            sharinpix__ImageURLFull__c,
            sharinpix__ImageOriginal__c,
            Checkin_Supply_Unit_Number__c,
            Checkin_Supply_Floor_Number__c,
            Checkin_Supply_Parking_Spot__c,
            Checkin_Supply_City_Manager_Phone__c
          FROM sharinpix__SharinPixImage__c
          WHERE
            Arrival_Instructions_Template__c = :unit.Arrival_Instructions_Template__c
          ORDER BY Checkin_Instruction_Step_Number__c
        ];
      }
    }
    arrInstructionsDetails.sharinPixImagesList = lst_sharinPixImage;
    System.debug('lst_sharinPixImage: ' + lst_sharinPixImage.size());
    System.debug('arrInstructionsDetails: ' + arrInstructionsDetails);

    return arrInstructionsDetails;
  }

  @AuraEnabled
  public static ArrivalInstructionsDetails getBookingArrivalInstruction(
    String BookingId
  ) {
    System.debug('bookingId --> ' + BookingId);
    ArrivalInstructionsDetails arrInstructionsDetails = new ArrivalInstructionsDetails();
    List<sharinpix__SharinPixImage__c> lst_sharinPixImage = new List<sharinpix__SharinPixImage__c>();

    if (BookingId != null) {
      Xotelia_Booking__c booking = [
        SELECT
          Id,
          Product__c,
          Product__r.Access_Code__c,
          Guest_KeyCafe_Code__c,
          Guest_Access_Code__c,
          Product__r.Arrival_Instructions_Template__c
        FROM Xotelia_Booking__c
        WHERE Id = :BookingId
        LIMIT 1
      ];

      arrInstructionsDetails.bookingId = booking.Id;
      arrInstructionsDetails.guestKeyCafeCode = booking.Guest_KeyCafe_Code__c;
      arrInstructionsDetails.guestAccessCode = booking.Guest_Access_Code__c;

      if (
        booking.Product__c != null &&
        booking.Product__r.Access_Code__c != null
      ) {
        arrInstructionsDetails.productAccessCode = booking.Product__r.Access_Code__c;
      }

      if (booking.Product__c != null) {
        Unit__c unit = [
          SELECT
            Id,
            Arrival_Instructions_Template__c,
            Unit_Number__c,
            Floor__c,
            Parking__c,
            Arrival_Instructions_Template__r.Building__r.Neighborhood__r.City__r.Barsala_Primary__r.Name,
            Arrival_Instructions_Template__r.Building__r.Neighborhood__r.City__r.Barsala_Primary__r.Phone_Standardized__c
          FROM Unit__c
          WHERE Id = :booking.Product__c
          LIMIT 1
        ];

        arrInstructionsDetails.unitId = unit.Id;
        arrInstructionsDetails.unitNumber = unit.Unit_Number__c;
        arrInstructionsDetails.floorNumber = unit.Floor__c;
        arrInstructionsDetails.parking = unit.Parking__c;
        arrInstructionsDetails.cityManagerName = unit.Arrival_Instructions_Template__r.Building__r.Neighborhood__r.City__r.Barsala_Primary__r.Name;
        arrInstructionsDetails.cityManagerPhone = unit.Arrival_Instructions_Template__r.Building__r.Neighborhood__r.City__r.Barsala_Primary__r.Phone_Standardized__c;
      }

      if (
        booking.Product__c != null &&
        booking.Product__r.Arrival_Instructions_Template__c != null
      ) {
        lst_sharinPixImage = [
          SELECT
            id,
            Checkin_Instruction_Step_Number__c,
            Checkin_Instruction_Description__c,
            sharinpix__ImageURLFull__c,
            sharinpix__ImageOriginal__c,
            Checkin_Supply_Unit_Number__c,
            Checkin_Supply_Floor_Number__c,
            Checkin_Supply_Parking_Spot__c,
            Checkin_Supply_City_Manager_Phone__c,
            Checkin_Supply_Keycafe_Code__c,
            Checkin_Supply_VirtualKey_Code__c,
            Checkin_Supply_Unit_Access_Code__c
          FROM sharinpix__SharinPixImage__c
          WHERE
            Arrival_Instructions_Template__c = :booking.Product__r.Arrival_Instructions_Template__c
          ORDER BY Checkin_Instruction_Step_Number__c
        ];
      }
      arrInstructionsDetails.sharinPixImagesList = lst_sharinPixImage;
    }

    System.debug('lst_sharinPixImage: ' + lst_sharinPixImage.size());
    return arrInstructionsDetails;
  }

  public class ArrivalInstructionsDetails {
    @AuraEnabled
    public String unitId { get; set; }
    @AuraEnabled
    public String unitNumber { get; set; }
    @AuraEnabled
    public String floorNumber { get; set; }
    @AuraEnabled
    public string parking { get; set; }
    @AuraEnabled
    public String bookingId { get; set; }
    @AuraEnabled
    public string guestKeyCafeCode { get; set; }
    @AuraEnabled
    public string guestAccessCode { get; set; }
    @AuraEnabled
    public string cityManagerName { get; set; }
    @AuraEnabled
    public string cityManagerPhone { get; set; }
    @AuraEnabled
    public list<sharinpix__SharinPixImage__c> sharinPixImagesList { get; set; }
    @AuraEnabled
    public string productAccessCode { get; set; }
  }
}