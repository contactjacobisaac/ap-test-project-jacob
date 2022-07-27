/**
* @File Name          : NFAPICallout
* @Description        : API Class for sending Closure info to Workforce API
* @Author             : jacob.isaac
* @Modification Log   :
* Ver       Date            Author      		    Modification
* 1.0    	 22/07/2022     jacob.isaac      Initial Version
**/
public with sharing class NFAPICallout {

    public static WorkforceAPIResponseWrapper calloutMethod(Case caseRecordForUpdate){
        //String caseId = [SELECT Id from Case LIMIT 1].Id;
        
    	String userId = caseRecordForUpdate.OwnerId;
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
    	String bodyText = '{"id":"'+caseRecordForUpdate.Id+'","agentid":"'+userId+'"}';
        req.setBody(bodyText);
        req.setEndpoint('callout:NFAPI');
        req.setMethod('POST');
        Http http = new Http();
        try{
            HTTPResponse res = http.send(req);
            system.debug(res);
            system.debug('status code::::'+res.getStatusCode());
            system.debug(res.getBody());
            WorkforceAPIResponseWrapper response = (WorkforceAPIResponseWrapper)System.JSON.deserialize(res.getBody(),WorkforceAPIResponseWrapper.class);
	        return response;
        }
        catch(CalloutException err){
            system.debug(err.getMessage());
            return null;
        }
        
    }
        
        
}