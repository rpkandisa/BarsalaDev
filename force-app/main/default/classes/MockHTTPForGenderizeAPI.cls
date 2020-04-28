global class MockHTTPForGenderizeAPI implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req){
        HTTPResponse res = new HTTPResponse();
       
            if(req.getEndpoint() == 'https://api.genderize.io/?name=Sam'){
                res.setBody('{"name": "Sam","gender": "male","probability": 0.81,"count": 96261}');
            }else if(req.getEndpoint() == 'https://api.genderize.io/?name=Samantha'){
                res.setBody('{"name": "Samantha ","gender": "female","probability": 0.98,"count": 96261}');
            }else if(req.getEndpoint() == 'https://api.genderize.io/?name=Sam&name=Samantha'){
                res.setBody('[{"name": "Sam","gender": "male","probability": 0.81,"count": 96261},{"name": "Samantha","gender": "female","probability": 0.98,"count": 31152}]');
            }
            
            res.setStatus('OK');
            res.setStatusCode(200);
            
       
        return res;
    }
}