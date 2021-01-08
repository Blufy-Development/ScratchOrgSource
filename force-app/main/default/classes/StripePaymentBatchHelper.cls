/* Name         : StripePaymentBatchHelper
 * Date         : 10th Dec 2020
 * Author       : 
 * Description  : This is a helper class for StripeCustomerPaymentBatch batch class
**/
public without sharing class StripePaymentBatchHelper {
    public static void getCustomerChargeDetails(List<Invoice__c> lstInvoices){
        Set<Id> setIds = new Set<Id>();
        List<Invoice__c> lstTempInvoices = new List<Invoice__c>(); 
        for(Invoice__c obj : lstInvoices){
            setIds.add(obj.Customer__c);
            List<Payment__c> lstPayments = obj.Payments__r;
            Boolean isSuccess = false;
            for(Payment__c paymentObj : lstPayments){
                if(paymentObj.Status__c == 'Success')
                    isSuccess = true;
            }   
            if(!isSuccess)
                lstTempInvoices.add(obj);
        }
        System.debug('setIds size : '+setIds.size());
        SYstem.debug('setIds : '+setIds);
        System.debug('lstTempInvoices :: '+lstTempInvoices.size());
        System.debug('lstTempInvoices data :: '+lstTempInvoices);
        
        Map<Id, Payment_Account__c> mapAccountWithPaymentAccount = new Map<Id, Payment_Account__c>();
        for(Payment_Account__c obj : [Select Id,Account__c, Account__r.Customer_key__c, Type__c, Stripe_ID__c
                                        FROM Payment_Account__c 
                                        WHERE Account__c in : setIds AND Active__c = TRUE]){
                                            if(!mapAccountWithPaymentAccount.containsKey(obj.Account__c))
                                                mapAccountWithPaymentAccount.put(obj.Account__c, obj);
                                        }
        setIds.clear();
        System.debug('mapAccountWithPaymentAccount size : '+mapAccountWithPaymentAccount.size());
        
    
      //List<CustomClass> lstCustomClassObjs = new List<CustomClass>();
        List<Payment_Log__c> lstPaymentLogs = new List<Payment_Log__c>();
        List<Payment__c> lstPayments = new List<Payment__c>();
        Map<Id,Invoice__c> mapInvoicesUpdated = new Map<Id,Invoice__c>();
        for(Invoice__c obj : lstTempInvoices){
            if(mapAccountWithPaymentAccount.containsKey(obj.Customer__c)){
                HttpResponse resp  = StripeUtility.getStripeCharge(Integer.valueOf(obj.Total_Amount__c*100),'usd',mapAccountWithPaymentAccount.get(obj.Customer__c).Account__r.Customer_key__c,mapAccountWithPaymentAccount.get(obj.Customer__c).Stripe_ID__c);
                if(resp != null){

                    System.debug(resp.getBody());
                    String status ='none';

                    if(resp.getStatusCode()==200){
                        status = (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('status');

                        Payment_Log__c paymentLogObj = new Payment_Log__c(Charge_Id__c = (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('id'),
                                                                            Invoice__c = obj.Id, 
                                                                            API_Status__c = status.compareTo('succeeded')==0 || status.compareTo('pending')==0?'Success':'Failure', 
                                                                            Message__c = status.compareTo('pending')==0?'Payment is Pending.' : status.compareTo('failed')==0 ? (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('failure_message') : status.compareTo('succeeded')==0 ? 'Payment is Successful.' : '',
                                                                            //Code__c will be containing the details only incase of failed
                                                                            Code__c = status.compareTo('failed')==0 ? (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('failure_code') : '', 
                                                                            Type__c = status.compareTo('succeeded')==0 || status.compareTo('pending')==0 ? 'OK' : 'Failed' 
                                                                    );
                        System.debug('status code in 200');
                        lstPaymentLogs.add(paymentLogObj);
                        
                    }
                    else{
                        System.debug('status code is : '+resp.getStatusCode());
                        Payment_Log__c paymentLogObj = new Payment_Log__c(Invoice__c = obj.Id, 
                                                                            API_Status__c = 'Failure', 
                                                                            Message__c = (String)((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('error')))).get('message'), 
                                                                            Code__c = String.valueOf(resp.getStatusCode()), 
                                                                            Type__c= (String)((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('error')))).get('type')
                                                                    );
                        lstPaymentLogs.add(paymentLogObj);
                    }
                    lstPayments.add(new Payment__c(
                        Parent__c = obj.Customer__c, 
                        Invoice__c = obj.Id, 
                        Amount__c = obj.Total_Amount__c, 
                        Payment_Mode__c = mapAccountWithPaymentAccount.get(obj.Customer__c).Type__c.compareTo('Card')==0 ? 'Credit Card' : mapAccountWithPaymentAccount.get(obj.Customer__c).Type__c.compareTo('ACH') == 0 ? 'ACH' : 'Other',
                        Status__c=status.compareTo('pending')==0?'Pending':status.compareTo('succeeded')==0?'Success':'Failed',
                        Payment_Date__c=System.today(),
                        Comments__c = status.compareTo('pending')==0?'Payment is Pending.': status.compareTo('failed')==0 ? (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('failure_code') : status.compareTo('succeeded')==0 ? 'Payment Successful.' : '',
                        Payment_Reference__c = resp.getStatusCode()==200 ? (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('id') : 'NULL'
                        ));

                    if(status.compareTo('succeeded')==0 && mapAccountWithPaymentAccount.get(obj.Customer__c).Type__c.compareTo('Card')==0) {
                        if(mapInvoicesUpdated.containsKey(obj.Id))
                            mapInvoicesUpdated.get(obj.Id).Status__c = 'Paid';
                        else
                            mapInvoicesUpdated.put(obj.Id, new Invoice__c(Id = obj.Id, Status__c = 'Paid'));
                    }
                    if(mapInvoicesUpdated.containsKey(obj.Id))
                        mapInvoicesUpdated.get(obj.Id).Automation_Applied__c = true;
                    else
                        mapInvoicesUpdated.put(obj.Id, new Invoice__c(Id = obj.Id, Automation_Applied__c = true));

                    system.debug('lstPayments'+lstPayments);
                    
                }
                else {
                    System.debug('mapAccountWithPaymentAccount value not found : '+obj.Customer__c);
                }
            }
            else{
                System.debug('Error : Response is Null');
            }
        }
        if(lstPaymentLogs.size()>0){
            PaymentLogService.insertPaymentLogRecords(lstPaymentLogs);
        }
        
        if(lstPayments.size()>0){
            PaymentService.insertPaymentRecords(lstPayments);
        }
        if(mapInvoicesUpdated.values().size()>0){
            update mapInvoicesUpdated.values();
        }
    }
}