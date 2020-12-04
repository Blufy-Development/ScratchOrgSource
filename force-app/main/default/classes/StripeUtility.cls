/*
Name        :       StripeUtility
Date        :       25/11/2020
Description :       StripeUtilty is used to have all the Stripe API related Methods
Developer   :       TMC
*/



public class StripeUtility {
    
    public static final educato__Stripe_Metadata__mdt stripeMeta;
    static{
        educato__Stripe_Metadata__mdt stripeMetaData = [select id,publishKey__c, secretKey__c from Stripe_Metadata__mdt LIMIT 1];
        stripeMeta = stripeMetaData;
    }

    //Create Bank Account Token for Stripe ACH for new Customers
    public static StripeCustomerDetails createBankToken(string country, String currencyCode, String holderName, String accountHolderType, String  routingNumber, String accountNumber){
        StripeCustomerDetails customerDetails = new StripeCustomerDetails();
        if(string.isNotBlank(country) && string.isNotBlank(currencyCode) && string.isNotBlank(holderName) &&
           string.isNotBlank(accountHolderType) && string.isNotBlank(routingNumber) && string.isNotBlank(accountNumber)){

            String createTokenBody = 'bank_account[country]='+country+'&bank_account[currency]='+currencyCode+'&bank_account[account_holder_name]='+holderName+
                                    '&bank_account[account_holder_type]='+accountHolderType+'&bank_account[routing_number]='+routingNumber+'&bank_account[account_number]='+accountNumber;
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String autorizationKey = 'Bearer '+stripeMeta.secretKey__c;
               
            system.debug('autorizationKey '+autorizationKey);
            request.setEndpoint(System.label.Stripe_Base_URL+'/v1/tokens');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization', autorizationKey);
            // Set the body as a JSON object
            request.setBody(createTokenBody);
            HttpResponse response = http.send(request);
            System.debug(response.getBody());
            // Parse the JSON response
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 
                customerDetails.tokenId = results.containsKey('id') ?  String.valueOf(results.get('id')) : NULL;
                if(results.containsKey('bank_account') && String.isNotBlank(customerDetails.tokenId)){
                    system.debug(results.get('bank_account'));
                    Map<string,Object> bank_Account = (Map<string,Object>)results.get('bank_account');
                    customerDetails.accountHolderName = bank_Account.containsKey('account_holder_name') ? String.valueOf(bank_Account.get('account_holder_name')) : NULL;
                    customerDetails.accountType = bank_Account.containsKey('account_holder_type') ? String.valueOf(bank_Account.get('account_holder_type')) : NULL;
                    customerDetails.accountRountingNo = bank_Account.containsKey('routing_number') ? String.valueOf(bank_Account.get('routing_number')) : NULL;
                    customerDetails.accountNo = bank_Account.containsKey('last4') ? String.valueOf(bank_Account.get('last4')) : NULL;
                }
            } else {
                System.debug(response.getBody());
            }

        }
        System.debug('@@@customerDetails'+customerDetails);
        return customerDetails;
    }

    //Create Stripe Customer
    public static string createStripeCustomer(String customerName, String email, String source){
        String customerId;
        if(string.isNotBlank(customerName) && (string.isNotBlank(email) || string.isNotBlank(source))){
            String createTokenBody = 'name='+customerName+'&description='+customerName;
            createTokenBody += string.isNotBlank(email) ? '&email='+email : '';
            createTokenBody += string.isNotBlank(source) ? '&source='+source : '';

            System.debug('@@@@createTokenBody'+createTokenBody);
            String autorizationKey = 'Bearer '+stripeMeta.educato__secretKey__c;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(System.label.Stripe_Base_URL+'/v1/customers');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization',autorizationKey );
            // Set the body as a JSON object
            request.setBody(createTokenBody);
            HttpResponse response = http.send(request);
            System.debug(response);
            // Parse the JSON response
            if (response.getStatusCode() == 200) {
                System.debug(response.getBody());
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 
                customerId = results.containsKey('id') ? String.valueOf(results.get('id'))  : NULL;
            } else {
                System.debug(response.getStatusCode()+ ' - ' +response.getBody());
            }

        }
        return customerId;
    }


  public static string createStripeBankVerify(Integer ammt1 , Integer ammt2, String customerId, String bankTokenId){
        String verifiedStatus = '';
        if(ammt1 != null && ammt2 != null  && customerId != null && bankTokenId != null){
            String createStripeBankVerifyBody = 'amounts[]='+ammt1+'&amounts[]='+ammt2;
            System.debug('@@@@createStripeBankVerifyBody'+createStripeBankVerifyBody);
            String autorizationKey = 'Bearer '+stripeMeta.secretKey__c;
            Http http = new Http();
        
            string endUrl = System.label.Stripe_Base_URL + '/v1/customers/' + customerId + '/sources/' + bankTokenId + '/verify';
            system.debug('endUrl-->'+endUrl);
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endUrl);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization',autorizationKey);
            // Set the body as a JSON object
            request.setBody(createStripeBankVerifyBody);
            HttpResponse response = http.send(request);
            System.debug(response);
            // Parse the JSON response
            if (response.getStatusCode() == 200) {
                System.debug(response.getBody());
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 
                verifiedStatus = results.containsKey('status') ? String.valueOf(results.get('status'))  : NULL;
            } else {
                System.debug(response.getStatusCode()+ ' - ' +response.getBody());
            }
        
       }

       return verifiedStatus;
    }

    
    @future(callout=true)
    public static void createStripeCustomerUsingACH(String accountSFId, string country, String currencyCode, String holderName, String accountHolderType, String  routingNumber, String accountNumber, String email){
        educato__Payment_Account__c paymentAccountObj = new educato__Payment_Account__c();
        StripeCustomerDetails customerDetails = new StripeCustomerDetails();
        customerDetails = createBankToken(country, currencyCode, holderName, accountHolderType, routingNumber, accountNumber);
        if(String.isNotBlank(customerDetails.tokenId) && String.isNotBlank(customerDetails.accountHolderName) && String.isNotBlank(customerDetails.accountRountingNo)
             && String.isNotBlank(customerDetails.accountNo) && String.isNotBlank(customerDetails.accountType)){
                customerDetails.stripeCustomerId =  createStripeCustomer(customerDetails.accountHolderName, email, customerDetails.tokenId);
        }

        if(String.isNotBlank(customerDetails.stripeCustomerId) && String.isNotBlank(customerDetails.accountHolderName) 
            && String.isNotBlank(customerDetails.accountNo) && String.isNotBlank(customerDetails.accountRountingNo) && 
            String.isNotBlank(customerDetails.accountType) && String.isNotBlank(customerDetails.tokenId) && 
            String.isNotBlank(accountSFId)){
                paymentAccountObj.educato__Account__c = accountSFId;
                paymentAccountObj.Stripe_Customer_key__c = customerDetails.stripeCustomerId;
                paymentAccountObj.educato__Holder_Name__c = customerDetails.accountHolderName;
                paymentAccountObj.educato__Account_Number__c = customerDetails.accountNo;
                paymentAccountObj.educato__Type__c = customerDetails.accountType;
                paymentAccountObj.educato__Routing_Number__c = customerDetails.accountRountingNo;
                paymentAccountObj.Stripe_Token__c = customerDetails.tokenId;
        }
        if(String.isNotBlank(paymentAccountObj.educato__Account__c)){
            UPDATE paymentAccountObj;
        }
    }





    Public Class StripeCustomerDetails{
        Public String accountHolderName;
        Public String accountRountingNo;
        Public String accountNo;
        Public String stripeCustomerId;
        Public String tokenId;
        Public String accountType;
    }
}