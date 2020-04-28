@isTest
global class AttachmentCalloutMock implements HttpCalloutMock {
     global HTTPResponse respond(HTTPRequest req) {
         
         
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        //res.setBody('{"example":"test"}');
        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);
        
         res.setBodyAsBlob(myBlob);
        res.setStatusCode(200);
        return res;
    }
}