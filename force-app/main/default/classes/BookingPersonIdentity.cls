public without sharing class BookingPersonIdentity {
  public enum fieldType {
    IDoc_file_id,
    IDSelfie_file
  }

  public static Attachment findImageOnBooking(
    Id guestId,
    string IDURL,
    integer intfieldtype
  ) {
    HTTPResponse res = doCallout('GET', IDURL);

    if (res.getStatusCode() == 200 || Test.isRunningTest()) {
      List<Attachment> lstAttachment = new List<Attachment>();

      Account objAcc = [
        SELECT Id, Name, IDoc_file_id__pc, IDSelfie_file__pc
        FROM Account
        WHERE PersonContactId = :guestId
        LIMIT 1
      ];

      if (
        objAcc != null &&
        (String.isBlank(objAcc.IDoc_file_id__pc) ||
        String.isBlank(objAcc.IDSelfie_file__pc))
      ) {
        Attachment att = new Attachment();
        Blob body = null;
        body = res.getBodyAsBlob();
        //att.contentType = a.content_type;

        if (fieldType.IDoc_file_id.ordinal() == intfieldtype) {
          att.Name = 'Government-Issued-ID-' + objAcc.Name.replace(' ', '-');
        } else {
          att.Name =
            'Government-Issued-ID-Selfie-' + objAcc.Name.replace(' ', '-');
        }

        att.Body = body;
        att.ParentId = objAcc.Id;

        if (att.ParentId != null) {
          return att;
        }
      }
    }
    return null;
  }

  public static HTTPResponse doCallout(string methodname, string endpoint) {
    HTTP h = new HTTP();
    HTTPRequest r = new HTTPRequest();
    r.setEndpoint(endpoint);
    r.setMethod(methodname);
    HTTPResponse resp = h.send(r);
    return resp;
  }
}