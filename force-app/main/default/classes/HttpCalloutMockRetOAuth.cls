global class HttpCalloutMockRetOAuth implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token" : "", "instance_url" : ""}');
        return res;
    }
}