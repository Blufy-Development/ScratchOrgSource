/* Name         : StripeCustomerPaymentBatchHelper
 * Date         : 10th Dec 2020
 * Author       : 
 * Description  : This is a helper class for StripeCustomerPaymentBatch batch class
**/
public class StripeCustomerPaymentBatchHelper {
    public static void getCustomerChargeDetails(List<Invoice__c> lstInvoices){
        Set<Id> setIds = new Set<Id>();
        for(Invoice__c obj : lstInvoices){
            setIds.add(obj.Customer__c);
        }
        System.debug('setIds size : '+setIds.size());
        SYstem.debug('setIds : '+setIds);
        Map<Id, Payment_Account__c> mapAccountWithPaymentAccount = new Map<Id, Payment_Account__c>();
        for(Payment_Account__c obj : [Select Id,Account__c,Account__r.Customer_key__c 
                                        FROM Payment_Account__c 
                                        WHERE Account__c in : setIds AND Type__c = 'ACH' AND Active__c = TRUE]){
                                            if(!mapAccountWithPaymentAccount.containsKey(obj.Account__c))
                                                mapAccountWithPaymentAccount.put(obj.Account__c, obj);
                                        }
        setIds.clear();
        System.debug('mapAccountWithPaymentAccount size : '+mapAccountWithPaymentAccount.size());
        System.debug('mapAccountWithPaymentAccount : '+mapAccountWithPaymentAccount.keySet());
        //List<CustomClass> lstCustomClassObjs = new List<CustomClass>();
        List<Payment_Log__c> lstPaymentLogs = new List<Payment_Log__c>();
        List<Payment__c> lstPayments = new List<Payment__c>();
        for(Invoice__c obj : lstInvoices){
            if(mapAccountWithPaymentAccount.containsKey(obj.Customer__c)){
                HttpResponse resp  = StripeUtility.getStripeCharge(Integer.valueOf(obj.Total_Amount__c*100),'usd',mapAccountWithPaymentAccount.get(obj.Customer__c).Account__r.Customer_key__c,'Dummy description');
                System.debug(resp.getBody());
                String status ='none';

                if(resp.getStatusCode()==200){
                    status = (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('status');

                    Payment_Log__c paymentLogObj = new Payment_Log__c(Charge_Id__c = (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('id'),
                                                                        Invoice__c = obj.Id, 
                                                                        Status__c = status.compareTo('succeeded')==0 || status.compareTo('pending')==0?'Success':'Failure', 
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
                                                                        Status__c= 'Failure', 
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
                    Payment_Mode__c = 'ACH',
                    Status__c=status.compareTo('pending')==0?'Pending':status.compareTo('succeeded')==0?'Success':'Failure',
                    Payment_Date__c=System.today(),
                    Comments__c = status.compareTo('pending')==0?'Payment is Pending.': status.compareTo('failed')==0 ? (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('failure_code') : status.compareTo('succeeded')==0 ? 'Payment Successful.' : '',
                    Payment_Reference__c = resp.getStatusCode()==200 ? (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('id') : 'NULL'
                    ));
            }
            else {
                System.debug('mapAccountWithPaymentAccount value not found : '+obj.Customer__c);
            }
        }
        if(lstPaymentLogs.size()>0){
            insert lstPaymentLogs;
        }
        
        if(lstPayments.size()>0){
            insert lstPayments;
        }
    }
}