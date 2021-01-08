global with sharing class CreditNoteAdjustmentBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = ' SELECT Id,Status__c,Issue_Date__c,Account__c,Amount__c FROM Credit_Note__c ';
        query += ' WHERE Status__c = \'Issued\' AND Account__c != NULL AND Amount__c != NULL ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Credit_Note__c> listCreditNote){
        Set<String> setCustomerId = new Set<String>();
        Map<String,Invoice__c> mapAccountIdToInvoice = new Map<String,Invoice__c>();
        List<Credit_Note__c> listCreditNoteToUpdate = new List<Credit_Note__c>();
        List<Payment__c> listPayment = new List<Payment__c>();
        
        for(Credit_Note__c creditNote : listCreditNote){
            setCustomerId.add(creditNote.Account__c);
        }
        
        if(setCustomerId.size() > 0){
            List<Account> listAccount = AccountService.getAccountOfLatestDueInvoice(setCustomerId);
            if(listAccount != NULL && listAccount.size() > 0){
                for(Account acc : listAccount){
                    if(acc.Invoice_Customer__r.size() > 0){
                        mapAccountIdToInvoice.put(acc.Id,acc.Invoice_Customer__r[0]);   
                    }   
                }
            }   
        }
        
        if(mapAccountIdToInvoice.keySet().size() > 0){
            for(Credit_Note__c creditNote : listCreditNote){
                if(mapAccountIdToInvoice.containsKey(creditNote.Account__c) && 
                   creditNote.Amount__c < mapAccountIdToInvoice.get(creditNote.Account__c).Outstanding_Amount__c){
                       Payment__c payment      = new Payment__c();
                       payment.Amount__c       = creditNote.Amount__c;
                       payment.Payment_Date__c = Date.today();
                       payment.Credit_Note__c  = creditNote.Id;
                       payment.Invoice__c      = mapAccountIdToInvoice.get(creditNote.Account__c).Id;
                       payment.Parent__c       = creditNote.Account__c;
                       payment.Type__c         = ConstantClass.creditNoteCashMode;
                       payment.Status__c       = ConstantClass.successStatus;
                       //payment.Payment_Mode__c = ConstantClass.creditNoteCashMode;
                       payment.Payment_Reference__c = 'Credit Note Applied';
                       listPayment.add(payment);
                       creditNote.educato__Status__c = ConstantClass.appliedStatus;
                       listCreditNoteToUpdate.add(creditNote);
                   }
            }
        }
        
        if(listPayment.size() > 0)
            PaymentService.insertPaymentRecords(listPayment);
        
        if(listCreditNoteToUpdate.size() > 0)
            CreditNoteService.updateCreditNoteRecords(listCreditNote);
    }
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}