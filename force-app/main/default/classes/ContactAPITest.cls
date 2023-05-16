@isTest global class ContactAPITest {
    
    @isTest global static void testGet(){
        RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/ContactAPI/10_0';
        List<Contact> contacts = ContactAPI.getContacts();
        if(contacts.size() > 0){
            String idStr = Id.valueOf(contacts.get(0).Id);
            System.assertEquals(idStr.indexOf('003'), 0, 'ID prefix incorrect.');
        }
    }
    
    @isTest global static void testPost(){
        Contact contact = new Contact(FirstName='fName', LastName='lName', Phone='123456789');
        Id retId = ContactAPI.createContact(contact.FirstName, contact.LastName, contact.Phone);
        Contact retContact = [SELECT Id, FirstName, LastName, Phone FROM Contact WHERE Id = :retId];
        System.assert(retContact != null, 'Record is null.');
        System.assertEquals(contact.FirstName, retContact.FirstName, 'First Name mismatch.');
        System.assertEquals(contact.LastName, retContact.LastName, 'Last Name mismatch.');
        System.assertEquals(contact.Phone, retContact.Phone, 'Phone mismatch.');
    }
    
    @isTest global static void testPostFail(){
        Contact contact = new Contact(FirstName='fName', LastName=null, Phone='123456789');
        Id retId = ContactAPI.createContact(contact.FirstName, contact.LastName, contact.Phone);
        System.assert(retId == null, 'Record is not null.');
    }
    
    @isTest global static void testDelete(){
        Contact contact = new Contact(FirstName='fName', LastName='lName', Phone='123456789');
        insert contact;
        String checkId = contact.Id;
        RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/ContactAPI/' + checkId;
        boolean result = ContactAPI.deleteContactByID();
        System.assert(result, 'Returned False.');
        Map<Id, Contact> retContacts = new Map<Id, Contact>([SELECT Id, FirstName, LastName, Phone FROM Contact]);
        System.assert(retContacts.get(checkId) == null, 'No return ID');
    }
    
    @isTest global static void testDeleteFail(){
        Contact contact = new Contact(FirstName='fName', LastName='lName', Phone='123456789');
        insert contact;
        String checkId = contact.Id;
        RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/ContactAPI/' + checkId;
        boolean result = ContactAPI.deleteContactByID();
        result = ContactAPI.deleteContactByID();
        System.assert(!result, 'Returned True.');
    }
    
    @isTest global static void testPut(){
        Contact contact = new Contact(FirstName='fName', LastName='lName', Phone='123456789');
        insert contact;
        contact.FirstName = 'fName2';
        
        boolean result = ContactAPI.upsertContact(contact.Id, contact.FirstName, contact.LastName, contact.Phone);
        Contact retContact = [SELECT Id, FirstName, LastName, Phone FROM Contact WHERE Id = :contact.Id];
        System.assert(result, 'Returned False.');
        System.assert(retContact != null, 'Record is null.');
        System.assertEquals(contact.FirstName, retContact.FirstName, 'First Name mismatch.');
        System.assertEquals(contact.LastName, retContact.LastName, 'Last Name mismatch.');
        System.assertEquals(contact.Phone, retContact.Phone, 'Phone mismatch.');
    }
    
    @isTest global static void testPutFail(){
        Contact contact = new Contact(FirstName='fName', LastName='lName', Phone='123456789');
        insert contact;
        contact.FirstName = 'fName2';
        contact.Phone = 'TESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTEST';
        
        boolean result = ContactAPI.upsertContact(contact.Id, contact.FirstName, contact.LastName, contact.Phone);
        Contact retContact = [SELECT Id, FirstName, LastName, Phone FROM Contact WHERE Id = :contact.Id];
        System.assert(!result, 'Returned True.');
    }
    
    @isTest global static void testPatch(){
        Contact contact = new Contact(FirstName='fName', LastName='lName', Phone='123456789');
        insert contact;
        String checkId = contact.Id;
        contact.FirstName = 'fName2';
        RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/ContactAPI/' + checkId;
        String body =
              '{ ' +
              '"FirstName": "' + contact.FirstName + '"' +
              '}';
        RestContext.request.requestBody = Blob.valueOf(body);
        boolean result = ContactAPI.updateContactFieldsByID();
        Contact retContact = [SELECT Id, FirstName, LastName, Phone FROM Contact WHERE Id = :checkId];
        System.assert(retContact != null, 'Record is null.');
        System.assert(result, 'Returned False.');
        System.assertEquals(contact.FirstName, retContact.FirstName, 'First Name mismatch.');
        System.assertEquals(contact.LastName, retContact.LastName, 'Last Name mismatch.');
        System.assertEquals(contact.Phone, retContact.Phone, 'Phone mismatch.');
    }
    
    @isTest global static void testPatchFail(){
        Contact contact = new Contact(FirstName='fName', LastName='lName', Phone='123456789');
        insert contact;
        String checkId = contact.Id;
        contact.FirstName = 'fName2';
        contact.Phone = 'TESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTEST';
        RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/ContactAPI/' + checkId;
        String body =
              '{ ' +
              '"FirstName": "' + contact.FirstName + '",' +
              '"Phone": "' + contact.Phone + '"' +
              '}';
        RestContext.request.requestBody = Blob.valueOf(body);
        boolean result = ContactAPI.updateContactFieldsByID();
        System.assert(!result, 'Returned True.');
    }
    
}