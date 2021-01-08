global with sharing class CreditNoteAdjustmentBatchSchedular implements Schedulable {
   global void execute(SchedulableContext SC) {
     Database.executeBatch(new CreditNoteAdjustmentBatch());
   }
}