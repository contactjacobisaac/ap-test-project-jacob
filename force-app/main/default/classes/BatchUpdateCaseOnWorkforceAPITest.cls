/**
* @File Name          : BatchUpdateCaseOnWorkforceAPITest
* @Description        : TestClass for batch job of updating Case Closure to Workforce API
* @Author             : jacob.isaac
* @Modification Log   :
* Ver       Date            Author      		    Modification
* 1.0    	 22/07/2022     jacob.isaac      Initial Version
**/
@isTest
public with sharing class BatchUpdateCaseOnWorkforceAPITest {
@testSetup
    static void testData(){
        List<Account> listOfAccounts = new List<Account>();
        List<Case> listOfCases = new List<Case>();
        Account accRec = new Account(Name='Test Account');
        insert accRec;
        for(integer i=0;i<100;i++){
        	Case caseRec = new Case (AccountId=accRec.Id,Status='Closed');
			listOfCases.add(caseRec);            
        }
        insert listOfCases;
        
        
    }
    
     private class RestMockSuccess implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req) {
            String response = '{"success":true,"secretKey":"22ca3d23ebe053c600091223e61dba2a"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(response);
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class RestMockFail implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req) {
            String response = '{"success":false,"error":"agent id is invalid. Check Content-Type header.... ;) ;)"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(response);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testNFAPIBatchApex(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockSuccess());
		BatchUpdateCaseOnWorkforceAPI batchInstance = new BatchUpdateCaseOnWorkforceAPI();  
        Id jobId = Database.executeBatch(batchInstance,100);
        Test.stopTest();
        List<Case> listOfCases = [SELECT Id,Status,NFAPISecretKey__c from Case WHERE NFAPISecretKey__c != null];
        system.assertEquals(100, listOfCases.size());
        
    }
     @isTest
    static void testNFAPIBatchApexFailureScenario(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockFail());
		BatchUpdateCaseOnWorkforceAPI batchInstance = new BatchUpdateCaseOnWorkforceAPI();  
        Id jobId = Database.executeBatch(batchInstance,100);
        Test.stopTest();
        List<Case> listOfCases = [SELECT Id,Status,NFAPISecretKey__c from Case WHERE NFAPISecretKey__c != null];
        system.assertEquals(0, listOfCases.size());
        
    }
}