/**
* @File Name          : BatchUpdateCaseOnWorkforceAPI
* @Description        : Batch Apex for sending Case Closure info to Workforce API
* @Author             : jacob.isaac
* @Modification Log   :
* Ver       Date            Author      		    Modification
* 1.0    	 22/07/2022     jacob.isaac      Initial Version
**/
public with sharing class BatchUpdateCaseOnWorkforceAPI implements Database.Batchable<sObject>,Schedulable, Database.AllowsCallouts{
     
     static Boolean recursive = false;
     List<Case> failedCaseList = new List<Case>();
    
     public class apiResponseWrapper{
        public Boolean success;
        public String error;
        public String secretKey;
    }
    //WorkforceAPIResponseWrapper
    public Database.QueryLocator start(Database.BatchableContext bc){
        String queryString;
        queryString = 'SELECT Id,Status,OwnerId FROM Case where Status = '+'\'Closed\''+' AND NFAPISecretKey__c=null WITH SECURITY_ENFORCED';
        return Database.GetQueryLocator(queryString);
    }
    public void execute(Database.BatchableContext bc,List<Case> scope){
        ProcessCaseClosureRecords processData = new ProcessCaseClosureRecords(scope);
        //ProcessCaseClosureRecords.processRecords(scope);
        processRecords(scope); 
    }
    public void finish(Database.BatchableContext bc){
        recursive=true;
        if(!recursive){
            if(failedCaseList.size()>0){
            queueExcessRecords(failedCaseList);
        	}
        }
    }
    public void execute(SchedulableContext sc) {
		BatchUpdateCaseOnWorkforceAPI job = new BatchUpdateCaseOnWorkforceAPI();
		Database.executebatch(job,100);
	}
    
    public void processRecords(List<Case> caseRecords){
        system.debug('checking if invoking from batch');
        List<Case> updateCaseList = new List<Case>();
        
        
        for(Case caseRec : caseRecords){
            //{"success":true,"secretKey":"22ca3d23ebe053c600091223e61dba2a"}
            //{"success":false,"error":"agent id is invalid. Check Content-Type header.... ;) ;)"}
            
            WorkforceAPIResponseWrapper apiResonse = NFAPICallout.calloutMethod(caseRec);
            
            if(apiResonse.success == true){
                if(Schema.sObjectType.Case.isUpdateable() && Schema.sObjectType.Case.fields.NFAPISecretKey__c.isUpdateable()){
                	Case updateRec = new Case(Id=caseRec.Id,NFAPISecretKey__c=apiResonse.secretKey);
                    updateCaseList.add(updateRec);
                }
            }
            else{
                 Case failureCase = new Case(Id=caseRec.Id,OwnerId=CaseRec.OwnerId);
                 failedCaseList.add(failureCase);
            }
        }
        update updateCaseList;
        
    }
     public void queueExcessRecords(List<Case> failedCaseRecords){
		System.enqueueJob(new ProcessCaseClosureRecords(failedCaseRecords));
	}
}