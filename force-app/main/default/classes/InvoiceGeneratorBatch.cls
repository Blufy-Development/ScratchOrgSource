/**
*   Name        :   InvoiceGeneratorBatch
*   Date        :   03/23/2020
*   Author      :   Arpit vijayvergiya
*   Description :   This Batch is used to create Invoice & InvoiceLineItems with the help of Subscription and SubscriptionLineItem records.
*
**/
global with sharing class InvoiceGeneratorBatch implements Database.Batchable<sObject>{
    
    private Date nextBillDate;
    private String type;
    private String monthCycle;
    Set<String> invoicefieldsName;
    Set<String> subscriptionLineItemfieldsName;
    Set<String> invoiceLineItemfieldsName;
    private String year;
    private String month;
    // use this constructor if we want to execute on a date base and Term base,
    global InvoiceGeneratorBatch(String year, String month){
        this.year = year;
        this.month = month;
        system.debug('year'+year);
        system.debug('month'+month);
        //nextBillDate = executionDate;
        //this.type = type;
       /* if(type == 'Month'){
            List<Blufy_Config__mdt> systemConfig = BlufyConfigService.getByDeveloperName('Default');
            if(systemConfig.size() > 0){
                    this.monthCycle = systemConfig[0].Monthly_Invoice_Cycle__c;
            }
        }  */      
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id, Name, Location__c, Customer__c, Status__c, Amount__c, GST_Tax_Amount__c, Total_Amount__c, Next_Bill_Date__c,';
        query += 'Payment_Frequency__c,(SELECT Id, Fee__c, Amount__c, Enrollment__c, Enrollment__r.class__c, Enrollment__r.Class_Session__c, Next_Bill_Date__c,'; 
        query += ' Status__c, Class_Term__r.End_Date__c, Class_Term__r.Sessions__c, Class_Term__r.Start_Date__c, Class_Term__r.Sequence__c';
        query += ',Fee__r.Unit_Price__c,Fee__r.GST_Applicable__c,Fee__r.Units__c, Fee__r.Fixed_Billing__c, Fee__r.Prorate__c, Fee__r.Amount__c,  Subscription_Start_Date__c, Subscription_Expiry_Date__c, Enrollment__r.Last_Session_Date__c, Enrollment__r.Start_Date__c FROM Subscription_Line_Items__r ';
        query += ' WHERE Status__c = \'Active\' AND Enrollment__c != null AND Fee__c != null ';
        // if(this.type == 'Term'){
        //     query += ' AND next_bill_date__c = :nextBillDate';    
        // }else if(this.type == 'Month' && String.isNotBlank(this.monthCycle)){
        //     query += ' AND next_bill_date__c = '+this.monthCycle;     
        // }
        query += ') FROM Subscription__c where ';
     // 	query += ' ID = \'a0l110000086doPAAQ\'  AND ';
        query += 'Status__c = \'Active\' AND Payment_Frequency__c != null AND Customer__c != null WITH SECURITY_ENFORCED';              
        
        System.debug('query '+query);
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,list<Subscription__c> lstSubscriptions){
        
        List<InvoiceFactory> listOfInvoiceFactory = new List<InvoiceFactory>();
        Set<String> setOfClassIds = new Set<String>();
        Map<String, Invoice__c> mapOfSubInv  = new Map<String,Invoice__c>();
        List<Invoice_Line_Item__c> listofInvItems = new List<Invoice_Line_Item__c>();
        LineItemCalculateWrapper objWrap = new LineItemCalculateWrapper();
        List<Subscription_Line_Item__c> subsciptionLineItemsList = new List<Subscription_Line_Item__c>();
        Set<String> customerIds =  new Set<String>();
        Set<String> setOfUtilizedCreditNotes = new Set<String>();
        Map<Id,List<Credit_Note__c>> mapOfCreditNote = new Map<Id,List<Credit_Note__c>>();
        List<payment__c> paymentList = new List<payment__c>();
        
        for(Subscription__c objSub : lstSubscriptions){
            InvoiceFactory objFactory = new InvoiceFactory(objSub,nextBillDate, year,month); //,nextTerm,currentMonthEndDate.addDays(1)
            customerIds.add(objSub.customer__c);
            listOfInvoiceFactory.add(objFactory);
            setOfClassIds.addAll(objFactory.setOFClassSessionIds);
            mapOfSubInv.put(objSub.Id,objFactory.getInvoice());    
        }
        
       // if(this.type == 'Term'){
           // objWrap.mapOfClassTerm = InvoiceFactory.getClassTermMap(setOfClassIDs);
        //}else if(this.type == 'Month' && String.isNotBlank(this.monthCycle)){
        system.debug('setOfClassIds'+setOfClassIds);
        system.debug('Year and Month ' + year +' ' +  month);
        if(setOfClassIds.size() > 0){
            objWrap.mapOfClassSession  = InvoiceFactory.getClassSessions(setOfClassIds, year, month);
            //Filling map of account id with credit note list
            //for now we commented code on 29-12-20
            /*for(Credit_Note__c cnObj : CreditNoteService.getByParentIds(setOfClassIds)){
                if(mapOfCreditNote.containsKey(cnObj.Account__c)){
                    list<Credit_Note__c>cnList = mapOfCreditNote.get(cnObj.Account__c);
                    cnList.add(cnObj);
                    mapOfCreditNote.put(cnObj.Account__c,cnList);
                }else{
                    mapOfCreditNote.put(cnObj.Account__c,new List<Credit_Note__c>{cnObj});
                }
            }*/
        }
       
        //}
        //Database.SaveResult[] result = Database.insert(mapOfSubInv.values(),false);
        //commented by asif on 09-10-2020 right now we commented services class function
        //TODO: Need to fill Invoice Id in mapOfSubInv
        //InvoiceService.insertInvoiceRecords(mapOfSubInv.values());
        system.debug('mapOfSubInv.values();'+mapOfSubInv.values());
        INSERT mapOfSubInv.values();
        system.debug('mapOfSubInv'+mapOfSubInv);
        /*if(mapOfCreditNote.size() > 0){
            for(Invoice__c invObj : mapOfSubInv.values()){
                if(invObj.Customer__c != null && mapOfCreditNote.containsKey(invObj.Customer__c)){
                    for(Credit_Note__c cnObj : mapOfCreditNote.get(invObj.Customer__c)){
                        payment__c payObj = new payment__c();
                        payObj.Parent__c = invObj.Customer__c;
                        payObj.Invoice__c = invObj.Id;
                        payObj.Credit_Note__c = cnObj.Id;
                        payObj.Status__c = 'Success';
                        paymentList.add(payObj);
                    }
                }
            }*/
            //if(paymentList.size() > 0){
                //for now we commented code on 15-12-20
               // PaymentService.insertPaymentRecords(paymentList);
           // }
        //}
        for(InvoiceFactory objFactory : listOfInvoiceFactory){
            for(iBlufyInvoiceEngine invoiceEngine : objFactory.listOfInvoiceHandler){
                if(invoiceEngine != null){
                    listofInvItems.addAll(invoiceEngine.createInvoiceLineItems(mapOfSubInv.get(objFactory.objSub.id),objWrap,year, month));
                    system.debug('btach-> '+invoiceEngine.objLineItem);
                    subsciptionLineItemsList.add(invoiceEngine.objLineItem);
                }
               
            }
        }
        
        InvoiceLineItemService.insertInvoiceLineItemRecords(listOfInvItems);
        system.debug('subsciptionLineItemsList'+subsciptionLineItemsList);
        SubscriptionLineItemService.updateSubsLineItemRecords(subsciptionLineItemsList);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}