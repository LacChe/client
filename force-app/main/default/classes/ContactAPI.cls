public with sharing class ContactAPI {
    
    @AuraEnabled
    public static List<Contact> getContacts(Integer limitAmt, Integer offset){
        HttpRequest httpRequest = new HttpRequest();
        // server expects this format:
        // /services/apexrest/ContactAPI/<limitAmt>_<offset>
        httpRequest.setEndpoint('callout:API_Named_Credential/services/apexrest/ContactAPI/' + limitAmt + '_' + offset);
        httpRequest.setMethod('GET'); 
        Http http = new Http();
        HTTPResponse res = http.send(httpRequest);
        
        List<Contact> contacts = (List<Contact>)JSON.deserializeStrict(res.getBody(), List<Contact>.class);
        System.debug('Get Contacts');
        return contacts;
    }
    
    @AuraEnabled 
    public static Id createContact(String firstName, String lastName, String phone){
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint('callout:API_Named_Credential/services/apexrest/ContactAPI/');
        httpRequest.setMethod('POST'); 
        httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
        String body =
              '{ ' +
              '"firstName": "' + firstName + '",' +
              '"lastName": "' + lastName + '",' +
              '"phone": "' + phone + '"' +
              '}';
        httpRequest.setBody(body);
        Http http = new Http();
        HTTPResponse res = http.send(httpRequest);

        Id retId = (Id)JSON.deserializeStrict(res.getBody(), Id.class);
        System.debug('Post Contact: ' + retId);
        return retId;
    }
    
    @AuraEnabled 
    public static boolean deleteContactByID(Id id){
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint('callout:API_Named_Credential/services/apexrest/ContactAPI/' + id);
        httpRequest.setMethod('DELETE'); 
        Http http = new Http();
        HTTPResponse res = http.send(httpRequest);
        
        boolean result = (Boolean)JSON.deserializeStrict(res.getBody(), Boolean.class);

        System.debug('Delete Contact: ' + id);
        return result;
    }
    
    @AuraEnabled 
    public static boolean upsertContact(String id, String firstName, String lastName, String phone){
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint('callout:API_Named_Credential/services/apexrest/ContactAPI/');
        httpRequest.setMethod('PUT'); 
        httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
        String body =
              '{ ' +
              '"Id": "' + id + '",' +
              '"firstName": "' + firstName + '",' +
              '"lastName": "' + lastName + '",' +
              '"phone": "' + phone + '"' +
              '}';
        httpRequest.setBody(body);
        Http http = new Http();
        HTTPResponse res = http.send(httpRequest);
        
        boolean result = (boolean)JSON.deserializeStrict(res.getBody(), boolean.class);
        
        System.debug('Put Contact: ' + id);
        
        return result;
    }
    
    @AuraEnabled 
    public static boolean updateContactFieldsByID(Id id, String jsonBody){        
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint('callout:API_Named_Credential/services/apexrest/ContactAPI/' + id);
        httpRequest.setMethod('PATCH'); 
        httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
        httpRequest.setBody(jsonBody);
        Http http = new Http();
        HTTPResponse res = http.send(httpRequest);
        
        boolean result = (boolean)JSON.deserializeStrict(res.getBody(), boolean.class);
        
        System.debug('Patched Contact: ' + id);
        
        return result;
    }

}