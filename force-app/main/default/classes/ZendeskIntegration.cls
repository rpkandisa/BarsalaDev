//added by Kandisa Technologies on 20-12-2018
//It is used to find attachement from zendesk and store that attachement into salesforce

public without sharing class ZendeskIntegration {

    public static string findSOQLZendesk(){
        return 'SELECT Id,Name from Zendesk__Zendesk_Ticket__c where Name != null and Is_Attachment_Process__c=false ';
    }

    public static void callBatch(){
        ZendeskAttachmentBatch b = new ZendeskAttachmentBatch(findSOQLZendesk());
        Database.executeBatch(b,1); // keep size equal to 1
    }
    
    public static void findAttachementByticketId(string ticketId, string ticketSFId){

        List<case> lstCase = new List<case> ();                
        lstCase=  [select id from case where Zendesk_External_ID__c =: ticketId];
        Case objcase = new Case();
        if(lstCase.size()>0){
            objcase = lstCase.get(0);
        }


        string commentURL = Zendesk__c.getValues('commentJSONUrl').value__c.replace('{0}',ticketId); 
        HTTPResponse res = doCallout('GET', commentURL);

        //system.debug('res.getBody()!!!' + res.getBody());

        // List<CaseComment> lstComment = new List<CaseComment>();
        List<Zendesk_Comment__c> lstComment = new List<Zendesk_Comment__c>();


        if(res.getStatusCode() == 200){
            List<Attachment> lstAttachment = new List<Attachment>();

            ZendeskcommentJSON zc = ZendeskcommentJSON.parse(res.getBody());
            for(ZendeskcommentJSON.Comments c : zc.comments){
                
                Zendesk_Comment__c objzc = new Zendesk_Comment__c();
                objzc.Case__c =  objcase.Id;
                objzc.Comment__c = c.html_body;
                lstComment.add(objzc);

                // CaseComment cc = new CaseComment();
                // cc.IsPublished = c.public_Z;
                // cc.ParentId = objcase.Id;
                // cc.CommentBody =  c.body;
                // //System.debug('@@@@@@casecomment !!! ' + cc);
                // lstComment.add(cc);

                // if(objcase.Id != null){
                //     objcase.Test_Fields__c += c.html_body;
                // }

                if(label.StopZendeskAttachment == 'false' || Test.isRunningTest()){
                    for(ZendeskcommentJSON.Attachments a : c.attachments){
                        Attachment att = new Attachment();
                        att = fnProcessOnImage(a, objcase.Id);
                        if(att.ParentId != null){
                            lstAttachment.add(att);
                        }
                    }
                }
                
            }
            if(lstAttachment.size()>0 && !Test.isRunningTest()){
                insert lstAttachment;                
            }

            //update objcase;

            if(lstComment.size()>0 && !Test.isRunningTest()){
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.allowFieldTruncation = true;
                Database.insert(lstComment, dmo);
                //insert lstComment;
            }

            Zendesk__Zendesk_Ticket__c z = new Zendesk__Zendesk_Ticket__c(Id = ticketSFId, Is_Attachment_Process__c = true);
            update z;
        }
    }

    public static Attachment fnProcessOnImage(ZendeskcommentJSON.Attachments a, Id parentId){
        Attachment att = new Attachment();
        HTTPResponse res = doCallout('GET', a.content_url);
        if(res.getStatusCode() == 302 || Test.isRunningTest() ) {            
            HTTPRequest r = new HTTPRequest();            
            if(!Test.isRunningTest()){
                r.setEndpoint(res.getHeader('Location'));
            }      
            r.setHeader('Content-Type', a.content_type);      
            r.setCompressed(true);
            r.setMethod('GET');
            res = null;           
            
            // List<case> lstCase = new List<case> ();                
            // lstCase=  [select id from case where Zendesk_External_ID__c =: parentId];
                
            if(parentId != null)
            {
                Id CaseId = parentId;                
                res = new HTTP().send(r);    
                if(res.getstatuscode() == 200){
                    Blob body = null;
                    if(!Test.isRunningTest()){
                        body = res.getBodyAsBlob();
                    }
                    att.contentType = a.content_type;
                    att.Name = a.file_name;
                    att.Body = body;                   
                    
                    att.ParentId = CaseId;
                }
            }
        }
        return att;
    }

    public static HTTPResponse doCallout(string methodname, string endpoint){
        List<Zendesk__C> zensettings = Zendesk__c.getall().values();
        string username = Zendesk__c.getValues('username').value__c;
        string password = Zendesk__c.getValues('password').value__c;

        HTTP h = new HTTP();
        HTTPRequest r = new HTTPRequest();
        r.setEndpoint(endpoint);
        Blob headerValue = Blob.valueOf( username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        r.setHeader('Authorization', authorizationHeader);
        r.setMethod(methodname);
        HTTPResponse resp = h.send(r);
        return resp;
    }


}