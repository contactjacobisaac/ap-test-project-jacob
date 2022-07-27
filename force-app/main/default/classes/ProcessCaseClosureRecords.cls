public class ProcessCaseClosureRecords implements System.Queueable, Database.AllowsCallouts {
    List<Case> caseRecords = new List<Case>();
    public ProcessCaseClosureRecords(List<Case> caseRecords){
        this.caseRecords = caseRecords;
    }
    public void execute(System.QueueableContext ctx){
        BatchUpdateCaseOnWorkforceAPI job = new BatchUpdateCaseOnWorkforceAPI();
		Database.executebatch(job,100);
    }
}