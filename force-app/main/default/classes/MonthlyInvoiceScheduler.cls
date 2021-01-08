global with sharing class MonthlyInvoiceScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
     // mergeNumbers M = new mergeNumbers(); 
     Database.executeBatch(new InvoiceGeneratorBatch(String.valueOf(System.today().year()),String.valueOf(System.today().month())),100);
   }
}