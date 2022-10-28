@isTest
public class ContactAPITest {
    
    @isTest static void testGet(){
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    	mock.setStaticResource('ContactAPITestResource');
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        Test.setMock(HttpCalloutMock.class, mock);
        List<Contact> contacts = ContactAPI.getContacts(10, 0);
        System.assert(contacts != null, 'No Contacts');
        System.assertEquals(contacts.get(0).FirstName, 'Rose', 'Name Incorrect');
    }
    
    @isTest static void testPost(){
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    	mock.setStaticResource('ContactAPITestIDResource');
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        Test.setMock(HttpCalloutMock.class, mock);
        Id retId = ContactAPI.createContact('Rose', 'Gonzalez', '(123) 456 798');
        Id checkId = ID.valueOf('0038c00002vIJjkAAG');
        System.assert(retId == checkId, 'ID Incorrect');
    }
    
    @isTest static void testDelete(){
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockRetTrue());
        
        boolean result = ContactAPI.deleteContactByID(ID.valueOf('0038c00002vIJjkAAG'));
        System.assert(result, 'Returned False.');
    }
    
    @isTest static void testPut(){
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockRetTrue());
        boolean result = ContactAPI.upsertContact('Rose', 'Gonzalez', '(512) 757-6000', ID.valueOf('0038c00002vIJjkAAG'));
        System.assert(result, 'Returned False.');
    }
    
    @isTest static void testPatch(){
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockRetTrue());
        String body =
              '{ ' +
              '"FirstName": "testFirstname"' +
              '}';
        boolean result = ContactAPI.updateContactFieldsByID(ID.valueOf('0038c00002vIJjkAAG'), body);
        System.assert(result, 'Returned False.');
    }
    
}