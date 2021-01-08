/*
Name        :       StripeUtility
Date        :       25/11/2020
Description :       StripeUtilty is used to have all the Stripe API related Methods
Developer   :       TMC
*/

public without sharing class StripeUtility {
    public static final Stripe_Custom_Settings__c stripeAuthDetails;
    static{
        stripeAuthDetails = [SELECT Id, Secret_Key__c, Publish_Key__c 
                             FROM Stripe_Custom_Settings__c 
                             LIMIT 1];
    }
    
    // Create Card Token For Stripe ACH 
    
    public static HttpResponse createCardToken(Long cardNumber, Integer expMonth, Integer expYear, Integer cvc){
        
        System.debug('createCardToken Method Called...');
        if((cardNumber > Long.valueOf('999999999999999') && cardNumber <= Long.valueOf('9999999999999999')) && 
           (expMonth >= 1 && expMonth <= 12) && 
           (expYear > Integer.valueOf(String.valueOf(System.today().year()).substring(2))) && (cvc > 99 && cvc <= 999)) {
               
               String cardTokenBody = 'card[number]='+cardNumber+'&card[exp_month]='+expMonth+'&card[exp_year]='+expYear+'&card[cvc]='+cvc;
               
               Http http = new Http();
               HttpRequest request = new HttpRequest();
               
               String authorizationKey = 'Bearer '+stripeAuthDetails.Secret_Key__c;
               system.debug('authorizationKey '+authorizationKey);
               
               request.setMethod('POST');
               request.setEndpoint(System.label.Stripe_Base_URL+'/v1/tokens');
               request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
               request.setHeader('Authorization', authorizationKey);
               request.setBody(cardTokenBody);
               
               HttpResponse response = http.send(request);
               system.debug('respose card --->'+response.getBody());
               return response;
               // System.debug(response.getBody());
               // if(response.getStatusCode() == 200){
               //     Card obj = (Card)JSON.deserialize(JSON.serialize(((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('card')), Card.class);
               //     obj.token_id = String.valueOf(((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('id'));
               //     System.debug(obj);
               //     return obj;
               
               // }else{
               //     System.debug('Response Status Code :'+response.getStatusCode());
               //     return null;
               // }
           }else {
               System.debug('Error : Please pass the valid values.');
               return null;
           }     
        
    }
    
    //Create Bank Account Token for Stripe ACH for new Customers
    public static StripeBankDetails createBankToken(string country, String currencyCode, String holderName, String accountHolderType, String  routingNumber, String accountNumber){
        System.debug('JM :: createBankToken method called');
        StripeBankDetails customerDetails = new StripeBankDetails();
        if(string.isNotBlank(country) && string.isNotBlank(currencyCode) && string.isNotBlank(holderName) &&
           string.isNotBlank(accountHolderType) && string.isNotBlank(routingNumber) && string.isNotBlank(accountNumber)){
               
               String createTokenBody = 'bank_account[country]='+country+'&bank_account[currency]='+currencyCode+'&bank_account[account_holder_name]='+holderName+
                   '&bank_account[account_holder_type]='+accountHolderType+'&bank_account[routing_number]='+routingNumber+'&bank_account[account_number]='+accountNumber;
               
               Http http = new Http();
               HttpRequest request = new HttpRequest();
               
               system.debug('stripeAuthDetails.Secret_Key__c====>'+stripeAuthDetails.Secret_Key__c);
               String autorizationKey = 'Bearer '+stripeAuthDetails.Secret_Key__c;
               
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
                   // Storing BTok Id
                   customerDetails.tokenId = results.containsKey('id') ?  String.valueOf(results.get('id')) : NULL;
                   if(results.containsKey('bank_account')){
                       Map<String,Object> map1= (Map<String,Object>)results.get('bank_account');
                       System.debug('JM :: KEY Set :'+map1.get('id'));
                       // Storing Ba Id 
                       customerDetails.banktokenId = (String)map1.get('id');
                   }
                   if(results.containsKey('bank_account') && String.isNotBlank(customerDetails.tokenId)){
                       system.debug(results.get('bank_account'));
                       Map<string,Object> bank_Account = (Map<string,Object>)results.get('bank_account');
                       customerDetails.accountHolderName = bank_Account.containsKey('account_holder_name') ? String.valueOf(bank_Account.get('account_holder_name')) : NULL;
                       customerDetails.accountType = bank_Account.containsKey('account_holder_type') ? String.valueOf(bank_Account.get('account_holder_type')) : NULL;
                       customerDetails.accountRountingNo = bank_Account.containsKey('routing_number') ? String.valueOf(bank_Account.get('routing_number')) : NULL;
                       customerDetails.accountNo = bank_Account.containsKey('last4') ? String.valueOf(bank_Account.get('last4')) : NULL;
                       customerDetails.status = bank_Account.containsKey('status') ? String.valueOf(bank_Account.get('status')) : NULL;
                       System.debug('JM :: customerDetails.accountNo : '+customerDetails.accountNo);
                   }
               } else {
                   System.debug(response.getBody());
                   Map<String,Object> resp = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                   throw new AuraHandledException('Error : '+ (String)((Map<String,Object>)(JSON.deserializeUntyped(JSON.serialize(resp.get('error'))))).get('message') );
               }
               
           }
        System.debug('@@@customerDetails'+customerDetails);
        return customerDetails;
    }
    
    //Create Stripe Customer
    public static CustomerDetails createStripeCustomer(String customerName, String email, String source){
        System.debug('JM :: createStripeCustomer method is called');
        System.debug('JM :: customerName : '+customerName+': Email :'+email + ': source :'+source);
        CustomerDetails  CustomerDetailsObj = new CustomerDetails();
        if(string.isNotBlank(customerName) && (string.isNotBlank(email) || string.isNotBlank(source))){
            String createTokenBody = 'name='+customerName+'&description='+customerName;
            createTokenBody += string.isNotBlank(email) ? '&email='+email : '';
            createTokenBody += string.isNotBlank(source) ? '&source='+source : '';
            
            System.debug('@@@@createTokenBody'+createTokenBody);
            String autorizationKey = 'Bearer '+stripeAuthDetails.Secret_Key__c;
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
                CustomerDetailsObj.customerId = results.containsKey('id') ? String.valueOf(results.get('id'))  : NULL;
                CustomerDetailsObj.bankSourceId = results.containsKey('default_source') ? String.valueOf(results.get('default_source'))  : NULL;
                CustomerDetailsObj.customerName = results.containsKey('name') ? String.valueOf(results.get('name')) : NULL;
            } else {
                System.debug(response.getStatusCode()+ ' - ' +response.getBody());
            }
            
        }
        return CustomerDetailsObj;
    }
    
    public static CustomerDetails createStripeCustomer(String customerName, String email){
        
        System.debug('JM :: createStripeCustomer new method is called without source');
        
        CustomerDetails  CustomerDetailsObj = new CustomerDetails();
        if(string.isNotBlank(customerName) && (string.isNotBlank(email))){
            String createTokenBody = 'name='+customerName+'&description='+customerName+'&email='+email;                
            
            System.debug('@@@@createTokenBody'+createTokenBody);
            String authorizationKey = 'Bearer '+stripeAuthDetails.Secret_Key__c;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(System.label.Stripe_Base_URL+'/v1/customers');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization',authorizationKey );
            // Set the body as a JSON object
            request.setBody(createTokenBody);
            HttpResponse response = http.send(request);
            System.debug(response);
            // Parse the JSON response
            if (response.getStatusCode() == 200) {
                System.debug(response.getBody());
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 
                CustomerDetailsObj.customerId = results.containsKey('id') ? String.valueOf(results.get('id')) : NULL;
                CustomerDetailsObj.customerName = results.containsKey('name') ? String.valueOf(results.get('name')) : NULL;
                return CustomerDetailsObj;
                
            } else {
                System.debug(response.getStatusCode()+ ' - ' +response.getBody());
                return null;
            }
        }else{
            return null;
        } 
    }
    
    
    public static  String getVerfiyStripeBank(String customerId, String bankTokenId){
        if(String.isNotBlank(customerId) && String.isNotBlank(bankTokenId)){
            String createStripeBankVerifyBody = 'amounts[]='+32+'&amounts[]='+45;
            //String createStripeBankVerifyBody = 'amounts[]='+30+'&amounts[]='+40;
            
            System.debug('@@@@createStripeBankVerifyBody'+createStripeBankVerifyBody);
            String autorizationKey = 'Bearer '+stripeAuthDetails.Secret_Key__c;
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
                Map<String,Object> mapRes = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                if(mapRes.containsKey('status')){
                    return mapRes.get('status').toString();
                }
                else{
                    System.debug('Error : Response dose not contain \'status\' key.');
                    return null;
                }
            } 
            else {
                System.debug(response.getStatusCode()+ ' - ' +response.getBody());
                Map<String, Object> mapRes = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object> mapResDetails = (Map<String,Object>)mapRes.get('error');
                System.debug('JM :: KEYSET : '+mapResDetails.keySet());
                if(((String)(mapResDetails.get('message'))).containsIgnoreCase('already been verified')){
                    //if(((String)((Map<String,Object>)((Map<String,Object>)JSON.deserializeUntyped(response.getBody())).get('error')).get('error')).containsIgnoreCase('already been verified')){
                    //if(((String)((Map<String,Object>)((Map<String,Object>)JSON.deserializeUntyped(response.getBody())).get('error'))).containsIgnoreCase('already been verified')){
                    return 'verified';
                }
                else{
                    System.debug('Error');
                    return null;
                }       
            } 
        }
        else{
            System.debug('Error : Can not pass blank arguments.');
            return null;
        }
    }
    
    //public static StripeCustomerCharge getStripeCharge(Integer amount , String curcy, String source, String description){
    public static HttpResponse getStripeCharge(Integer amount , String curcy, String customerId, String source){
        //if(amount != null && String.isNotBlank(curcy) && String.isNotBlank(source) && String.isNotBlank(description)){
        if(amount != null && String.isNotBlank(curcy) && String.isNotBlank(customerId) && String.isNotBlank(source)){
            //String createStripeChargeBody = 'amount='+amount+'&currency='+curcy+'&source='+source+'&description='+description;
            String createStripeChargeBody = 'amount='+amount+'&currency='+curcy+'&customer='+customerId + '&source='+source;
            System.debug('@@@@createStripeChargeBody'+createStripeChargeBody);
            String autorizationKey = 'Bearer '+stripeAuthDetails.Secret_Key__c;
            
            System.debug('@@@@System.label.Stripe_Base_URL'+System.label.Stripe_Base_URL);
            Http http = new Http();
            string endUrl = System.label.Stripe_Base_URL + '/v1/charges';
            system.debug('endUrl-->'+endUrl);
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endUrl);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization',autorizationKey);
            // Set the body as a JSON object
            request.setBody(createStripeChargeBody);
            HttpResponse response = http.send(request);
            System.debug(response);
            return response;
        }
        else {
            if(amount == null){
                System.debug('Error : Amount is Null');
            }
            else if(String.isBlank(curcy)){
                System.debug('Error : Curreny is Blank');
            }
            else if(String.isBlank(customerId)){
                System.debug('Error : Customer Id is Blank');
            }
            else if(String.isBlank(source)){
                System.debug('Error : Source is Blank');
            }
            return null;
        }
    }
    
    private static String stripeCustomerUpdateForSource(String customerId, String tokenId, String objId){
        if(String.isNotBlank(customerId) && String.isNotBlank(tokenId) && String.isNotBlank(objId)){
            String createStripeBankVerifyBody = 'source='+tokenId;
            //String createStripeBankVerifyBody = 'amounts[]='+30+'&amounts[]='+40;
            
            System.debug('@@@@createStripeBankVerifyBody'+createStripeBankVerifyBody);
            String autorizationKey = 'Bearer '+stripeAuthDetails.Secret_Key__c;
            Http http = new Http();
            
            string endUrl = System.label.Stripe_Base_URL + '/v1/customers/' + customerId + '/sources';
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
            System.debug('get body '+response.getBody());
            // Parse the JSON response
            if (response.getStatusCode() == 200){
                System.debug(response.getBody());
                Map<String, Object> mapRes = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                if(mapRes.size()>0 && mapRes.containsKey('object')){
                    if(((String)mapRes.get('object')).compareTo('bank_account')==0){
                        if(mapRes.containsKey('id')){
                            return ((String)mapRes.get('id')).compareTo(objId) == 0 ? 'true' : 'false';
                        }
                        else{
                            System.debug('Error : Id not found');
                            return 'false';
                        }
                    }
                    else if(((String)mapRes.get('object')).compareTo('card')==0){
                        if(mapRes.containsKey('id')){
                            if(((String)mapRes.get('id')).compareTo(objId) == 0){
                                if(mapRes.containsKey('cvc_check')){
                                    //return mapRes.get('cvc_check').toString().compareTo('pass')==0? true: false;
                                    return mapRes.get('cvc_check').toString();
                                } 
                                else{
                                    System.debug('Error : Card cvc_check result is : ' +  mapRes.get('cvc_check').toString());
                                    return 'false';
                                }
                            }
                            else{
                                System.debug('Error : Card ID is not matched');
                                return 'false';
                            }
                        }
                        else{
                            System.debug('Error : Id not found');
                            return 'false';
                        }
                    }
                    else{
                        System.debug('Error : Could not find the \'Object\' Property.');
                        return 'false';
                    }
                }
                else{
                    System.debug('Error : There is no response return from Server.');
                    return 'false';
                }
            } 
            else {
                System.debug(response.getStatusCode()+ ' - ' +response.getBody());
                Map<String,Object> resp = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                throw new AuraHandledException('Error : '+ (String)((Map<String,Object>)(JSON.deserializeUntyped(JSON.serialize(resp.get('error'))))).get('message') );
                // return false;
            } 
        }
        System.debug('Error : Some parameters are passed null.');
        return 'false';
    }
    
    //For ACH
    @AuraEnabled
    public static void createStripeCustomerAndPaymentModeACH(String accountSFId, string country, String currencyCode, String holderName, String accountHolderType, String  routingNumber, String accountNumber){
        System.debug('JM :: createStripeCustomerUsingACH Aura method called');
        System.debug('accountSFId :: '+accountSFId);
        System.debug('country :: '+country);
        System.debug('currencyCode :: '+currencyCode);
        SYstem.debug('holderName :: '+holderName);
        System.debug('accountHolderType :: '+accountHolderType);
        System.debug('routingNumber :: '+routingNumber);
        SYstem.debug('accountNumber :: '+accountNumber);
        Payment_Account__c paymentAccountObj = new Payment_Account__c();
        StripeBankDetails customerDetails = new StripeBankDetails();
        Account parentAccount = new Account();
        List<Payment_Account__c> lstOldPaymentAccounts = new List<Payment_Account__c>();
        Account objAccount = [SELECT PersonEmail 
                              FROM Account
                              WHERE Id =:accountSFId
                             ];
        String email = objAccount.PersonEmail;
        if(String.isNotBlank(accountSFId)){
            lstOldPaymentAccounts = [SELECT Id, Holder_Name__c, Account_Number__c, Type__c, Routing_Number__c, Stripe_Token__c, Active__c, Account_Type__c, Account__r.Customer_key__c
                                     FROM Payment_Account__c
                                     WHERE Account__c =: accountSFId];
            if(lstOldPaymentAccounts.size()<=0){
                System.debug('JM :: lstOldPaymentAccounts.size is less then 0');
                customerDetails = createBankToken(country, currencyCode, holderName, accountHolderType, routingNumber, accountNumber);
                if(String.isNotBlank(customerDetails.tokenId) && String.isNotBlank(customerDetails.accountHolderName) && String.isNotBlank(customerDetails.accountRountingNo)
                   && String.isNotBlank(customerDetails.accountNo) && String.isNotBlank(customerDetails.accountType)){
                       System.debug('JM :: Going to createdStipe constumer');
                       CustomerDetails customDetailsObj  = createStripeCustomer(customerDetails.accountHolderName, email, customerDetails.tokenId);
                       if(customDetailsObj != null)
                           customerDetails.stripeCustomerId = customDetailsObj.customerId;
                       else 
                           customerDetails.stripeCustomerId = null;
                   }
                
                if(String.isNotBlank(customerDetails.stripeCustomerId) && String.isNotBlank(customerDetails.accountHolderName) 
                   && String.isNotBlank(customerDetails.accountNo) && String.isNotBlank(customerDetails.accountRountingNo) && 
                   String.isNotBlank(customerDetails.accountType) && String.isNotBlank(customerDetails.tokenId) && 
                   String.isNotBlank(accountSFId) && String.isNotBlank(customerDetails.banktokenId)){
                       System.debug('JM :: first if ');
                       paymentAccountObj.Account__c = accountSFId;
                       //paymentAccountObj.Stripe_Customer_key__c = customerDetails.stripeCustomerId;
                       paymentAccountObj.Holder_Name__c = customerDetails.accountHolderName;
                       System.debug('JM :: Account_Number__c : '+customerDetails.accountNo);
                       paymentAccountObj.Account_Number__c = '********'+customerDetails.accountNo;
                       paymentAccountObj.Type__c = 'ACH';
                       paymentAccountObj.Routing_Number__c = customerDetails.accountRountingNo;
                       paymentAccountObj.Stripe_Token__c = customerDetails.tokenId;
                       paymentAccountObj.Stripe_ID__c = customerDetails.banktokenId;
                       paymentAccountObj.Verification_Status__c = customerDetails.status;
                       //paymentAccountObj.Active__c = TRUE;
                       parentAccount.Id = accountSFId;
                       paymentAccountObj.Account_Type__c = customerDetails.accountType;
                       parentAccount.Customer_key__c =  customerDetails.stripeCustomerId;
                   }
                if(String.isNotBlank(paymentAccountObj.Account__c)){
                    System.debug('Going to insert');
                    INSERT paymentAccountObj;
                }
                if(String.isNotBlank(parentAccount.Id) && String.isNotBlank(parentAccount.Customer_key__c)){
                    System.debug('Going to update');
                    UPDATE parentAccount;
                }
            }
            else {
                System.debug('JM :: first else');
                Boolean noOldPaymentAccountIsActive = TRUE;
                String customerKey;
                Boolean isCustomerUpdated = false;
                for(Payment_Account__c obj : lstOldPaymentAccounts){
                    if(obj.Active__c){
                        noOldPaymentAccountIsActive = FALSE;
                        //obj.Active__c = false;
                    }
                    customerKey = obj.Account__r.Customer_key__c;
                    System.debug('customerKey---->'+customerKey);
                }
                
                customerDetails = createBankToken(country, currencyCode, holderName, accountHolderType, routingNumber, accountNumber);
                if(String.isNotBlank(customerDetails.tokenId) && String.isNotBlank(customerDetails.accountHolderName) && String.isNotBlank(customerDetails.accountRountingNo)
                   && String.isNotBlank(customerDetails.accountNo) && String.isNotBlank(customerDetails.accountType)){
                       if(String.isNotBlank(customerKey)){
                           if(!getStripeCustomerDetails(customerKey)){
                               CustomerDetails customDetailsObj  = createStripeCustomer(customerDetails.accountHolderName, email, customerDetails.tokenId);
                               if(customDetailsObj != null)
                                   customerDetails.stripeCustomerId = customDetailsObj.customerId;
                               else 
                                   customerDetails.stripeCustomerId = null;
                           }
                           else
                           {
                               isCustomerUpdated = Boolean.valueOf(stripeCustomerUpdateForSource(customerKey, customerDetails.tokenId,customerDetails.banktokenId));
                               customerDetails.stripeCustomerId = customerKey;
                           }       
                       }
                   }
                
                if(String.isNotBlank(customerDetails.stripeCustomerId) && String.isNotBlank(customerDetails.accountHolderName)
                   //if(String.isNotBlank(customerDetails.accountHolderName) 
                   && String.isNotBlank(customerDetails.accountNo) && String.isNotBlank(customerDetails.accountRountingNo) && 
                   String.isNotBlank(customerDetails.accountType) && String.isNotBlank(customerDetails.tokenId) && 
                   String.isNotBlank(accountSFId) && isCustomerUpdated == true){
                       paymentAccountObj.Account__c = accountSFId;
                       //paymentAccountObj.Stripe_Customer_key__c = customerDetails.stripeCustomerId;
                       paymentAccountObj.Holder_Name__c = customerDetails.accountHolderName;
                       System.debug('JM :: customerDetails.accountNo : '+customerDetails.accountNo);
                       paymentAccountObj.Account_Number__c = '********'+customerDetails.accountNo;
                       paymentAccountObj.Type__c = 'ACH';
                       paymentAccountObj.Routing_Number__c = customerDetails.accountRountingNo;
                       paymentAccountObj.Stripe_Token__c = customerDetails.tokenId;
                       paymentAccountObj.Stripe_ID__c = customerDetails.banktokenId;
                       paymentAccountObj.Verification_Status__c = customerDetails.status;
                       //paymentAccountObj.Active__c = TRUE;
                       parentAccount.Id = accountSFId;
                       paymentAccountObj.Account_Type__c = customerDetails.accountType;
                       parentAccount.Customer_key__c =  customerDetails.stripeCustomerId;
                       
                   }
                if(String.isNotBlank(paymentAccountObj.Account__c)){
                    System.debug('JM : going to insert');
                    INSERT paymentAccountObj;
                }
                if(String.isNotBlank(parentAccount.Id) && String.isNotBlank(parentAccount.Customer_key__c)){
                    System.debug('JM : going to update');
                    UPDATE parentAccount;
                }
                //UPDATE lstOldPaymentAccounts;
            }
        }
    }
    
    
    //For Card
    @AuraEnabled
    public static void createStripeCustomerAndPaymentModeCard(String AccountSFId, String cardNumber, Integer exp_month, Integer exp_year, Integer cvc){
        System.debug('JM :: createStripeCustomerUsingACH Aura method called for Card');
        System.debug('AccountSFId :: '+AccountSFId);
        System.debug('cardNumber :: '+cardNumber);
        SYstem.debug('exp_month :: '+exp_month);
        System.debug('exp_year :: '+exp_year);
        System.debug('cvc :: '+cvc);
        Payment_Account__c paymentAccountObj = new Payment_Account__c();
        StripeBankDetails customerDetails = new StripeBankDetails();
        Account parentAccount = new Account();
        Card cardObj;
        List<Payment_Account__c> lstOldPaymentAccounts = new List<Payment_Account__c>();
        Account objAccount = [SELECT Name, PersonEmail
                              FROM Account
                              WHERE Id =:AccountSFId];
        String holderName = objAccount.Name;
        String email = objAccount.PersonEmail;
        
        if(String.isNotBlank(accountSFId) && String.isNotBlank(holderName) && String.isNotBlank(email) ){
            lstOldPaymentAccounts = [SELECT Id, Holder_Name__c, Account_Number__c, Type__c, Stripe_Token__c, Active__c, Account_Type__c, Account__r.Customer_key__c
                                     FROM Payment_Account__c
                                     WHERE Account__c =: accountSFId];
            if(lstOldPaymentAccounts.size()<=0){
                System.debug('JM :: lstOldPaymentAccounts.size is less then 0');
                HttpResponse response = createCardToken(Long.valueOf(cardNumber), exp_month, exp_year, cvc);
                if(response != null){
                    if(response.getStatusCode()==200){
                        cardObj = (Card)JSON.deserialize(JSON.serialize(((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('card')), Card.class);
                        cardObj.token_id = String.valueOf(((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('id'));
                        if(String.isNotBlank(cardObj.token_id) && String.isNotBlank(cardObj.token_id) ){
                            System.debug('JM :: Going to createdStipe constumer');
                            CustomerDetails customDetailsObj  = createStripeCustomer(holderName, email, cardObj.token_id);
                            if(customDetailsObj != null){
                                SYstem.debug('inside if::::::%%%%');
                                System.debug('Values : '+customDetailsObj);
                                customerDetails.stripeCustomerId = customDetailsObj.customerId;
                                customerDetails.accountHolderName = customDetailsObj.customerName;
                                //String cvcCheckValue = getVerfiyCardCVCNumber(cardObj.id,customDetailsObj.customerId);
                                //cardObj.cvc_check =  cvcCheckValue == 'true' || cvcCheckValue == 'false' ? '' : cvcCheckValue;
                            }
                            else {
                                customerDetails.stripeCustomerId = null;
                                System.debug('inside else :::::::::: %%%%%%');
                            }         
                        }
                        if(String.isNotBlank(customerDetails.stripeCustomerId) && String.isNotBlank(customerDetails.accountHolderName) 
                           && String.isNotBlank(cardObj.last4) && String.isNotBlank(cardObj.token_id) && 
                           String.isNotBlank(accountSFId) && String.isNotBlank(cardObj.id)){
                               System.debug('JM :: first if ');
                               paymentAccountObj.Account__c = accountSFId;
                               //paymentAccountObj.Stripe_Customer_key__c = customerDetails.stripeCustomerId;
                               paymentAccountObj.Holder_Name__c = customerDetails.accountHolderName;
                               System.debug('JM :: Account_Number__c : '+cardObj.last4);
                               paymentAccountObj.Account_Number__c = '************' + cardObj.last4;
                               paymentAccountObj.Type__c = 'Card';
                               paymentAccountObj.Stripe_Token__c = cardObj.token_id;
                               paymentAccountObj.Stripe_ID__c = cardObj.id;
                               //paymentAccountObj.Verification_Status__c = cardObj.cvc_check;
                               paymentAccountObj.Active__c = TRUE;//cardObj.cvc_check.compareTo('pass') == 0 ? TRUE : FALSE;
                               parentAccount.Id = accountSFId;
                               parentAccount.Customer_key__c =  customerDetails.stripeCustomerId;
                               
                           }
                        else {
                            throw new AuraHandledException('Error : Can not pass null values.');
                            // System.debug('Error : Something is null');
                        }
                    }
                    else{
                        Map<String,Object> resp = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                        throw new AuraHandledException('Error : '+ (String)((Map<String,Object>)(JSON.deserializeUntyped(JSON.serialize(resp.get('error'))))).get('message') );
                    }
                }
                else{
                    System.debug('Error : Card Object is null');
                    throw new AuraHandledException('Error : Could not register the details');
                }
                if(String.isNotBlank(paymentAccountObj.Account__c)){
                    System.debug('Going to insert');
                    INSERT paymentAccountObj;
                }
                if(String.isNotBlank(parentAccount.Id) && String.isNotBlank(parentAccount.Customer_key__c)){
                    System.debug('Going to update');
                    UPDATE parentAccount;
                }
            }
            else {
                System.debug('JM :: first else');
                Boolean noOldPaymentAccountIsActive = TRUE;
                String customerKey;
                for(Payment_Account__c obj : lstOldPaymentAccounts){
                    if(obj.Active__c){
                        noOldPaymentAccountIsActive = FALSE;
                        //obj.Active__c = false;
                    }
                    customerKey = obj.Account__r.Customer_key__c;
                    system.debug('customerKey---->'+customerKey);
                }
                
                HttpResponse response = createCardToken(Long.valueOf(cardNumber), exp_month, exp_year, cvc);
                
                if(response != null){
                    if(response.getStatusCode()==200){
                        cardObj = (Card)JSON.deserialize(JSON.serialize(((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('card')), Card.class);
                        cardObj.token_id = String.valueOf(((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('id'));
                        
                        if(String.isNotBlank(cardObj.token_id) && String.isNotBlank(holderName) ){
                            if(String.isNotBlank(customerKey)){
                                if(!getStripeCustomerDetails(customerKey)){
                                    CustomerDetails customDetailsObj  = createStripeCustomer(holderName, email, cardObj.token_id);
                                    if(customDetailsObj != null)
                                        customerDetails.stripeCustomerId = customDetailsObj.customerId;
                                    else 
                                        customerDetails.stripeCustomerId = null;
                                }
                                else{
                                    customerDetails.stripeCustomerId = customerKey;
                                    //paymentAccountObj.Is_Verified__c = getUpdatedStripeCustomerToCard(cardObj.token_id, customerKey);
                                    String cvcCheckValue = stripeCustomerUpdateForSource(customerKey, cardObj.token_id, cardObj.Id); 
                                    cardObj.cvc_check = cvcCheckValue == 'true' || cvcCheckValue == 'false' ? '' : cvcCheckValue;
                                }       
                            }else{
                                CustomerDetails customDetailsObj  = createStripeCustomer(holderName, email, cardObj.token_id);
                                if(customDetailsObj != null){
                                    customerDetails.stripeCustomerId = customDetailsObj.customerId;
                                    // String cvcCheckValue = getVerfiyCardCVCNumber(cardObj.id, customDetailsObj.customerId);
                                    // cardObj.cvc_check =  cvcCheckValue == 'true' || cvcCheckValue == 'false' ? '' : cvcCheckValue;
                                }                                         
                            }
                        }
                        if(String.isNotBlank(customerDetails.stripeCustomerId) && String.isNotBlank(holderName)
                           && String.isNotBlank(cardObj.last4) && String.isNotBlank(cardObj.token_id) 
                           && String.isNotBlank(accountSFId) && String.isNotBlank(cardObj.id)){
                               paymentAccountObj.Account__c = accountSFId;
                               //paymentAccountObj.Stripe_Customer_key__c = customerDetails.stripeCustomerId;
                               paymentAccountObj.Holder_Name__c = holderName;
                               System.debug('JM :: customerDetails.accountNo : '+cardObj.last4);
                               paymentAccountObj.Account_Number__c = '************'+cardObj.last4;
                               paymentAccountObj.Type__c = 'Card';
                               paymentAccountObj.Stripe_Token__c = cardObj.token_id;
                               paymentAccountObj.Stripe_ID__c  = cardObj.id;
                               //paymentAccountObj.Verification_Status__c = cardObj.cvc_check;
                               paymentAccountObj.Active__c = TRUE;//cardObj.cvc_check.compareTo('pass') == 0 ? TRUE : FALSE;
                               parentAccount.Id = accountSFId;
                               parentAccount.Customer_key__c =  customerDetails.stripeCustomerId;
                           }else {
                               throw new AuraHandledException('Error : Can not pass null values.');
                               // System.debug('Error : Something is null');
                           }
                    }
                    else{
                        Map<String,Object> resp = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                        throw new AuraHandledException('Error : '+ (String)((Map<String,Object>)(JSON.deserializeUntyped(JSON.serialize(resp.get('error'))))).get('message') );
                    }
                }
                else{
                    System.debug('Error : Card Object is Null');
                    throw new AuraHandledException('Error : Could not register the details');
                }
                if(String.isNotBlank(paymentAccountObj.Account__c)){
                    System.debug('JM : going to insert');
                    INSERT paymentAccountObj;
                }
                if(String.isNotBlank(parentAccount.Id) && String.isNotBlank(parentAccount.Customer_key__c)){
                    System.debug('JM : going to update');
                    UPDATE parentAccount;
                }
                //UPDATE lstOldPaymentAccounts;
            }
        }
    }
    @TestVisible
    //getStripeCustomerDetails() to verify the CustomerId 
    private static Boolean getStripeCustomerDetails(String customerKey){
        if(String.isNotBlank(customerKey)==true){
            String autorizationKey = 'Bearer '+stripeAuthDetails.Secret_Key__c;
            
            Http http = new Http();
            
            string endUrl = System.label.Stripe_Base_URL + '/v1/customers/' + customerKey;
            system.debug('endUrl-->'+endUrl);
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endUrl);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization',autorizationKey);
            
            HttpResponse response = http.send(request);
            System.debug(response);
            System.debug('get customer details--->'+response.getBody());
            
            if(response.getStatusCode() == 200){
                Map<String,Object> mapRes = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                System.debug('mapRes keySet : '+mapRes.keySet());
                if(!mapRes.containsKey('id')){
                    return false;
                }
                else {
                    return mapRes.get('id').toString().compareTo(customerKey)==0;    
                }                
            }
            else{
                System.debug(response.getStatusCode()+ ' - ' +response.getBody());
                return false;
            }
        }
        else {
            return false;    
        }
    }
    //getUpdatedCharges will return the HTTPResponse of the ChargeId passed to Id in which it will contain the Charge Object details
    public static HttpResponse getUpdatedCharges(String chargeId){
        if(String.isNotBlank(chargeId)){
            String autorizationKey = 'Bearer '+stripeAuthDetails.Secret_Key__c;
            
            Http http = new Http();
            
            string endUrl = System.label.Stripe_Base_URL + '/v1/charges/' + chargeId;
            system.debug('endUrl-->'+endUrl);
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endUrl);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization',autorizationKey);
            
            HttpResponse response = http.send(request);
            System.debug(response);
            System.debug('test charge---->'+response.getBody());
            
            return response;                
        }else{
            return null;
        }
    }
    
    /*
public static String getVerfiyCardCVCNumber(String cardId, String customerId){
if(String.isNotBlank(cardId)==true && String.isNotBlank(customerId)==true){
String autorizationKey = 'Bearer '+stripeAuthDetails.Secret_Key__c;

Http http = new Http();

string endUrl = System.label.Stripe_Base_URL + '/v1/customers/' + customerId + '/sources/'+cardId;
system.debug('endUrl-->'+endUrl);

HttpRequest request = new HttpRequest();
request.setEndpoint(endUrl);
request.setMethod('GET');
request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
request.setHeader('Authorization',autorizationKey);

HttpResponse response = http.send(request);
System.debug(response);
System.debug(response.getBody());

if(response.getStatusCode() == 200){
Map<String,Object> mapRes = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
System.debug('mapRes keySet :: '+mapRes.keySet());
if(!mapRes.containsKey('cvc_check')){
return 'false';
}
else {
return mapRes.get('cvc_check').toString();    
}                
}
else{
System.debug(response.getStatusCode()+ ' - ' +response.getBody());
return 'false';
}
}
else {
return 'false';    
}
}
*/
    
    public Class CustomerDetails{
        public String customerId;
        public String bankSourceId;
        public String customerName;
    }
    
    
    public Class StripeBankDetails{
        public String accountHolderName;
        public String accountRountingNo;
        public String accountNo;
        public String stripeCustomerId;
        public String tokenId;
        public String banktokenId;
        public String accountType;
        public String status;
    }
    
    
    public class StripeCustomerCharge{
        public String chargeid {get;set;}
        public Integer amount {get;set;} 
        public Integer amount_captured {get;set;}
        public String balance_transaction {get;set;}
        public StripeCustomerCharge(){
            chargeid = '';
            amount = 0;
            amount_captured = 0;
            balance_transaction = '';
        }
    }
    public class Card {
        public String token_id{get;set;}
        public String id {get;set;} 
        public String object_Z {get;set;} // in json: object
        public Object address_city {get;set;} 
        public Object address_country {get;set;} 
        public Object address_line1 {get;set;} 
        public Object address_line1_check {get;set;} 
        public Object address_line2 {get;set;} 
        public Object address_state {get;set;} 
        public Object address_zip {get;set;} 
        public Object address_zip_check {get;set;} 
        public String brand {get;set;} 
        public String country {get;set;} 
        public String cvc_check {get;set;} 
        public Object dynamic_last4 {get;set;} 
        public Integer exp_month {get;set;} 
        public Integer exp_year {get;set;} 
        public String fingerprint {get;set;} 
        public String funding {get;set;} 
        public String last4 {get;set;} 
        public Object name {get;set;} 
        public Object tokenization_method {get;set;} 
        
        public Card(){
            token_id = '';
            id = '';  
            object_Z  ='';
            address_city  = null;
            address_country  = null;
            address_line1  = null;
            address_line1_check  = null;
            address_line2  = null;
            address_state  = null;
            address_zip  = null;
            address_zip_check  = null;
            brand  = '';
            country  = '';
            cvc_check  = '';
            dynamic_last4  = null;
            exp_month  =0;
            exp_year  =0;
            fingerprint = ''; 
            funding  = '';
            last4  = '';
            name  = null;
            tokenization_method = null;  
            
        }
        public Card(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'object') {
                            object_Z = parser.getText();
                        } else if (text == 'address_city') {
                            address_city = parser.readValueAs(Object.class);
                        } else if (text == 'address_country') {
                            address_country = parser.readValueAs(Object.class);
                        } else if (text == 'address_line1') {
                            address_line1 = parser.readValueAs(Object.class);
                        } else if (text == 'address_line1_check') {
                            address_line1_check = parser.readValueAs(Object.class);
                        } else if (text == 'address_line2') {
                            address_line2 = parser.readValueAs(Object.class);
                        } else if (text == 'address_state') {
                            address_state = parser.readValueAs(Object.class);
                        } else if (text == 'address_zip') {
                            address_zip = parser.readValueAs(Object.class);
                        } else if (text == 'address_zip_check') {
                            address_zip_check = parser.readValueAs(Object.class);
                        } else if (text == 'brand') {
                            brand = parser.getText();
                        } else if (text == 'country') {
                            country = parser.getText();
                        } else if (text == 'cvc_check') {
                            cvc_check = parser.getText();
                        } else if (text == 'dynamic_last4') {
                            dynamic_last4 = parser.readValueAs(Object.class);
                        } else if (text == 'exp_month') {
                            exp_month = parser.getIntegerValue();
                        } else if (text == 'exp_year') {
                            exp_year = parser.getIntegerValue();
                        } else if (text == 'fingerprint') {
                            fingerprint = parser.getText();
                        } else if (text == 'funding') {
                            funding = parser.getText();
                        } else if (text == 'last4') {
                            last4 = parser.getText();
                        } else if (text == 'name') {
                            name = parser.readValueAs(Object.class);
                        } else if (text == 'tokenization_method') {
                            tokenization_method = parser.readValueAs(Object.class);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Card consuming unrecognized property: '+text);
                        }
                    }
                }
            }
        }
    }
}