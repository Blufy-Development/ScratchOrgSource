public class StripeACHChargesVerificationBatchHelper {
    public StripeACHChargesVerificationBatchHelper() {

    }
    public static void getUpdateChargesStatus(List<Payment__c> lstPayments){
        List<Payment_Log__c> lstNewPaymentLogs = new List<Payment_Log__c>(); 
        List<Payment__c> lstUpdatePayments = new List<Payment__c>();
        List<Invoice__c> lstUpdatedInvoices = new List<Invoice__c>();
        for(Payment__c obj : lstPayments){
            HttpResponse resp = StripeUtility.getUpdatedCharges(obj.Payment_Reference__c);
            if(resp != null){
                String status = null;
                if(resp.getStatusCode() == 200){
                    status = (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('status');
                    lstNewPaymentLogs.add(new Payment_Log__c(Charge_Id__c = (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('id'),
                                                                        Invoice__c = obj.Invoice__c, 
                                                                        Status__c = status.compareTo('succeeded')==0 || status.compareTo('pending')==0 ? 'Success':'Failure', 
                                                                        Message__c = status.compareTo('succeeded')==0 ? 'Payment Successful.' : status.compareTo('pending')==0 ? 'Payment is Pending.' : (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('failure_message') ,
                                                                        //Code__c = status.compareTo('succeeded')==0 || status.compareTo('pending')==0 ? '200': (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('failure_code'),
                                                                        //Code__c will be containing the details only incase of failed
                                                                        Code__c = status.compareTo('failed')==0 ? (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('failure_code') : '',
                                                                        Type__c= status.compareTo('succeeded')==0 || status.compareTo('pending')==0 ? 'OK' : 'Failed' 
                                                                ));
                    if(status.compareTo('succeeded')==0)
                        lstUpdatedInvoices.add(new Invoice__c(Id = obj.Invoice__c, Status__c = 'Paid'));
                }
                else{
                    lstNewPaymentLogs.add(new Payment_Log__c(
                                                                Invoice__c = obj.Id, 
                                                                Status__c= 'Failure', 
                                                                Message__c = (String)((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('error')))).get('message'), 
                                                                Code__c = String.valueOf(resp.getStatusCode()), 
                                                                Type__c= (String)((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('error')))).get('type')
                                                            ));

                }
                lstUpdatePayments.add(new Payment__c(
                                                        Id = obj.Id, 
                                                        Status__c = status.compareTo('succeeded') == 0 ? 'Success' : status.compareTo('pending') == 0 ? 'Pending' : 'Failed',
                                                        Comments__c = status.compareTo('succeeded') == 0 ? 'Payment Successful.' : status.compareTo('failed') == 0 ? (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('failure_message') : status.compareTo('pending') == 0 ? 'Status is Pending.' : ''
                                                    ));
                // lstUpdatePayments.add(new Payment__c(Id = obj.Id, Status__c = status.compareTo('succeeded')==0? 'Success' : status.compareTo('pending')==0 ? 'Pending' : 'Failed', 
                //                                         //Comments__c = status.compareTo('succeeded')==0? 'Payment Successful.' : status.compareTo('failed') == 0 ? (String) ((Map<String,Object>)JSON.deserializeUntyped(resp.getBody())).get('failure_message') : status.compareTo('pending') == 0 ? 'Status is Pending.' : null,
                                                    
                //     ));
            }
        }
        if(lstNewPaymentLogs.size()>0){
            System.debug('JM :: Going to insert Payment Logs');
            insert lstNewPaymentLogs;
        }
        if(lstUpdatePayments.size()>0){
            System.debug('JM :: Going to update Payment Records');
            update lstUpdatePayments;
        }
        if(lstUpdatedInvoices.size()>0){
            System.debug('JM :: Going to update Invoice records');
            update lstUpdatedInvoices;
        }
    }
}