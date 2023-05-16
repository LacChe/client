@RestResource(urlMapping='/ContactAPI/*')
global with sharing class ContactAPI {
	
    @HttpGet
    global static List<Contact> getContacts(){
        RestRequest request = RestContext.request;
        String params = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);
        Integer seperatorIndex = params.lastIndexOf('_');
        Integer limitAmt = Integer.valueOf(params.substring(0, seperatorIndex));
        Integer offset = Integer.valueOf(params.substring(seperatorIndex + 1));
        System.debug('Get Contacts');
        return [SELECT FirstName, LastName, Phone, Id FROM Contact 
                ORDER BY LastName ASC 
                LIMIT :limitAmt 
                OFFSET :offset];
    }
    
    @HttpPost
    global static Id createContact(String firstName, String lastName, String phone){
        Contact thisContact = new Contact(
            FirstName=firstName,
            LastName=lastName,
            Phone=phone);
        try {
            insert thisContact;
        } catch(Exception e) {
        	System.debug('Excpetion: ' + e);
            return null;
        }
        System.debug('Post Contact: ' + thisContact.Id);
        return thisContact.Id;
    }
    
    @HttpDelete
    global static boolean deleteContactByID(){
        RestRequest request = RestContext.request;
        String contactId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);
        try {
            Contact thisContact = [SELECT Id FROM Contact WHERE Id = :contactId];
            System.debug('Delete Contact: ' + thisContact.Id);
            delete thisContact;
        } catch(Exception e) {
        	System.debug('Excpetion: ' + e);
        	return false;
        }
        return true;
    }
    
    @HttpPut
    global static boolean upsertContact(String Id, String firstName, String lastName, String phone){
        Contact thisContact = new Contact(
            ID=Id,
            FirstName=firstName,
            LastName=lastName,
            Phone=phone
        );
        try {
            upsert thisContact;  
        } catch(Exception e) {
        	System.debug('Excpetion: ' + e);
        	return false;
        }
        System.debug('Put Contact: ' + thisContact.Id);
        return true;
    }
    
    @HttpPatch
    global static boolean updateContactFieldsByID(){
        RestRequest request = RestContext.request;
        String contactId = request.requestURI.substring(
        request.requestURI.lastIndexOf('/')+1);
        Contact thisContact = [SELECT Id FROM Contact WHERE Id = :contactId];
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        for(String fieldName : params.keySet()){
            thisContact.put(fieldName, params.get(fieldName));
        }
        try {
            update thisContact;
        } catch(Exception e) {
        	System.debug('Excpetion: ' + e);
        	return false;
        }
        System.debug('Patched Contact: ' + thisContact.Id);
        return true;
    }
    
}