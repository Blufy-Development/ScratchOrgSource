/*
Name        :       StripeUtility
Date        :       25/11/2020
Description :       StripeUtilty is used to have all the Stripe API related Methods
Developer   :       TMC
*/

public class StripeUtility {
    public static final educato__Stripe_Metadata__mdt stripeAuthDetails;
    static{
        educato__Stripe_Metadata__mdt stripeMetaData = [select id,publishKey__c, secretKey__c from Stripe_Metadata__mdt LIMIT 1];
        stripeAuthDetails = stripeMetaData;
    }

    // Create Card Token For Stripe ACH 

    public static Card createCardToken(Long cardNumber, Integer expMonth, Integer expYear, Integer cvc){

        System.debug('createCardToken Method Called...');
        if((cardNumber > Long.valueOf('999999999999999') && cardNumber <= Long.valueOf('9999999999999999')) && (expMonth >= 1 && expMonth <= 12) && (expYear > System.today().year()) && (cvc > 99 && cvc <= 999)) {
            
            String cardTokenBody = 'card[number]='+cardNumber+'&card[exp_month]='+expMonth+'&card[exp_year]='+expYear+'&card[cvc]='+cvc;

            Http http = new Http();
            HttpRequest request = new HttpRequest();

            String authorizationKey = 'Bearer '+stripeAuthDetails.secretKey__c;
            system.debug('authorizationKey '+authorizationKey);

            request.setMethod('POST');
            request.setEndpoint(System.label.Stripe_Base_URL+'/v1/tokens');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization', authorizationKey);
            request.setBody(cardTokenBody);
            
            HttpResponse response = http.send(request);
            System.debug(response.getBody());
            if(response.getStatusCode() == 200){
                Card obj = (Card)JSON.deserialize(JSON.serialize(((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('card')), Card.class);
                obj.token_id = String.valueOf(((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('id'));
                System.debug(obj);
                return obj;

            }else{
                System.debug('Response Status Code :'+response.getStatusCode());
                return null;
            }
        }else {
            return null;
        }     

    }

    //Create Bank Account Token for Stripe ACH for new Customers
    public static StripeCustomerDetails createBankToken(string country, String currencyCode, String holderName, String accountHolderType, String  routingNumber, String accountNumber){
        System.debug('JM :: createBankToken method called');
        StripeCustomerDetails customerDetails = new StripeCustomerDetails();
        if(string.isNotBlank(country) && string.isNotBlank(currencyCode) && string.isNotBlank(holderName) &&
        string.isNotBlank(accountHolderType) && string.isNotBlank(routingNumber) && string.isNotBlank(accountNumber)){

            String createTokenBody = 'bank_account[country]='+country+'&bank_account[currency]='+currencyCode+'&bank_account[account_holder_name]='+holderName+
                                        '&bank_account[account_holder_type]='+accountHolderType+'&bank_account[routing_number]='+routingNumber+'&bank_account[account_number]='+accountNumber;

            Http http = new Http();
            HttpRequest request = new HttpRequest();
                
            system.debug('stripeAuthDetails.secretKey__c====>'+stripeAuthDetails.secretKey__c);
            String autorizationKey = 'Bearer '+stripeAuthDetails.secretKey__c;
                
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
                    System.debug('JM :: customerDetails.accountNo : '+customerDetails.accountNo);
                }
            } else {
                System.debug(response.getBody());
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
            String autorizationKey = 'Bearer '+stripeAuthDetails.educato__secretKey__c;
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
            String authorizationKey = 'Bearer '+stripeAuthDetails.educato__secretKey__c;
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


    public static  Boolean getVerfiyStripeBank(String customerId, String bankTokenId){
        if(String.isNotBlank(customerId) && String.isNotBlank(bankTokenId)){
            String createStripeBankVerifyBody = 'amounts[]='+32+'&amounts[]='+45;
            //String createStripeBankVerifyBody = 'amounts[]='+30+'&amounts[]='+40;
            
            System.debug('@@@@createStripeBankVerifyBody'+createStripeBankVerifyBody);
            String autorizationKey = 'Bearer '+stripeAuthDetails.secretKey__c;
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
                return true;
            } else {
                System.debug(response.getStatusCode()+ ' - ' +response.getBody());
                Map<String, Object> mapRes = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object> mapResDetails = (Map<String,Object>)mapRes.get('error');
                System.debug('JM :: KEYSET : '+mapResDetails.keySet());
                if(((String)(mapResDetails.get('message'))).containsIgnoreCase('already been verified')){
                //if(((String)((Map<String,Object>)((Map<String,Object>)JSON.deserializeUntyped(response.getBody())).get('error')).get('error')).containsIgnoreCase('already been verified')){
                //if(((String)((Map<String,Object>)((Map<String,Object>)JSON.deserializeUntyped(response.getBody())).get('error'))).containsIgnoreCase('already been verified')){
                    return true;
                }
                else
                    return false;
            } 
        }
        return null;
    }

    //public static StripeCustomerCharge getStripeCharge(Integer amount , String curcy, String source, String description){
    public static HttpResponse getStripeCharge(Integer amount , String curcy, String customerId, String source){
        //if(amount != null && String.isNotBlank(curcy) && String.isNotBlank(source) && String.isNotBlank(description)){
            if(amount != null && String.isNotBlank(curcy) && String.isNotBlank(customerId) && String.isNotBlank(source)){
            //String createStripeChargeBody = 'amount='+amount+'&currency='+curcy+'&source='+source+'&description='+description;
            String createStripeChargeBody = 'amount='+amount+'&currency='+curcy+'&customer='+customerId + '&source='+source;
            System.debug('@@@@createStripeChargeBody'+createStripeChargeBody);
            String autorizationKey = 'Bearer '+stripeAuthDetails.secretKey__c;

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
							

    //For ACH
    @future(callout=true)
    public static void createStripeCustomerUsingACH(String accountSFId, string country, String currencyCode, String holderName, String accountHolderType, String  routingNumber, String accountNumber, String email, String paymentType){
        System.debug('JM :: createStripeCustomerUsingACH method called');
        Payment_Account__c paymentAccountObj = new Payment_Account__c();
        StripeCustomerDetails customerDetails = new StripeCustomerDetails();
        Account parentAccount = new Account();
        List<Payment_Account__c> lstOldPaymentAccounts = new List<Payment_Account__c>();
        
        if(String.isNotBlank(accountSFId)){
            lstOldPaymentAccounts = [SELECT Id, Holder_Name__c, Account_Number__c, Type__c, Routing_Number__c, Stripe_Token__c, Active__c, Account_Type__c, Account__r.Customer_key__c
                                      FROM Payment_Account__c
                                      WHERE Account__c =: accountSFId and Routing_Number__c =: routingNumber];
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
                    paymentAccountObj.Account_Number__c = customerDetails.accountNo;
                    paymentAccountObj.Type__c = 'ACH';
                    paymentAccountObj.Routing_Number__c = customerDetails.accountRountingNo;
                    paymentAccountObj.Stripe_Token__c = customerDetails.tokenId;
                    paymentAccountObj.Stripe_Bank_Account_Token__c = customerDetails.banktokenId;
                    paymentAccountObj.Active__c = TRUE;
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
                for(Payment_Account__c obj : lstOldPaymentAccounts){
                    if(obj.Active__c)
                        noOldPaymentAccountIsActive = FALSE;
                    
                    customerKey = obj.Account__r.Customer_key__c;
                    
                    system.debug('customerKey---->'+customerKey);
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
                                customerDetails.stripeCustomerId = customerKey;
                        }
                        
                }

                if(String.isNotBlank(customerDetails.stripeCustomerId) && String.isNotBlank(customerDetails.accountHolderName)
                //if(String.isNotBlank(customerDetails.accountHolderName) 
                && String.isNotBlank(customerDetails.accountNo) && String.isNotBlank(customerDetails.accountRountingNo) && 
                String.isNotBlank(customerDetails.accountType) && String.isNotBlank(customerDetails.tokenId) && 
                String.isNotBlank(accountSFId)){
                    paymentAccountObj.Account__c = accountSFId;
                    //paymentAccountObj.Stripe_Customer_key__c = customerDetails.stripeCustomerId;
                    paymentAccountObj.Holder_Name__c = customerDetails.accountHolderName;
                    System.debug('JM :: customerDetails.accountNo : '+customerDetails.accountNo);
                    paymentAccountObj.Account_Number__c = customerDetails.accountNo;
                    paymentAccountObj.Type__c = 'ACH';
                    paymentAccountObj.Routing_Number__c = customerDetails.accountRountingNo;
                    paymentAccountObj.Stripe_Token__c = customerDetails.tokenId;
                    paymentAccountObj.Active__c = noOldPaymentAccountIsActive;
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
            }
        }
    }

    //For Card
    @future(callout=true)
    public static void createStripeCustomerUsingACH(String accountSFId, String holderName, String email, String cardNumber, Integer cvc, Integer exp_month, Integer exp_year,  String paymentType){
        System.debug('JM :: createStripeCustomerUsingACH method called for Card');
        Payment_Account__c paymentAccountObj = new Payment_Account__c();
        StripeCustomerDetails customerDetails = new StripeCustomerDetails();
        Account parentAccount = new Account();
        Card cardObj;
        List<Payment_Account__c> lstOldPaymentAccounts = new List<Payment_Account__c>();
        
        if(String.isNotBlank(accountSFId) && String.isNotBlank(holderName) && String.isNotBlank(email) ){
            lstOldPaymentAccounts = [SELECT Id, Holder_Name__c, Account_Number__c, Type__c, Stripe_Token__c, Active__c, Account_Type__c, Account__r.Customer_key__c
                                      FROM Payment_Account__c
                                      WHERE Account__c =: accountSFId];
            if(lstOldPaymentAccounts.size()<=0){
                System.debug('JM :: lstOldPaymentAccounts.size is less then 0');
                cardObj = createCardToken(Long.valueOf(cardNumber), exp_month, exp_year, cvc);
                if(String.isNotBlank(cardObj.token_id) && String.isNotBlank(cardObj.token_id) ){
                        System.debug('JM :: Going to createdStipe constumer');
                       	CustomerDetails customDetailsObj  = createStripeCustomer(holderName, email, cardObj.token_id);
                        if(customDetailsObj != null){
                            SYstem.debug('inside if::::::%%%%');
                            System.debug('Values : '+customDetailsObj);
                            customerDetails.stripeCustomerId = customDetailsObj.customerId;
                            customerDetails.accountHolderName = customDetailsObj.customerName;
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
                    System.debug('JM :: Account_Number__c : '+customerDetails.accountNo);
                    paymentAccountObj.Account_Number__c = cardObj.last4;
                    paymentAccountObj.Type__c = 'Card';
                    paymentAccountObj.Stripe_Token__c = cardObj.token_id;
                    paymentAccountObj.Stripe_Bank_Account_Token__c = cardObj.id;
                    paymentAccountObj.Active__c = TRUE;
                    parentAccount.Id = accountSFId;
                    parentAccount.Customer_key__c =  customerDetails.stripeCustomerId;

                }
                else {
                    System.debug('Something is null');
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
                    if(obj.Active__c)
                        noOldPaymentAccountIsActive = FALSE;
                    
                    customerKey = obj.Account__r.Customer_key__c;
                    
                    system.debug('customerKey---->'+customerKey);
                }
                cardObj = createCardToken(Long.valueOf(cardNumber), exp_month, exp_year, cvc);
                if(String.isNotBlank(cardObj.token_id) && String.isNotBlank(holderName) ){
                        if(String.isNotBlank(customerKey)){
                            if(!getStripeCustomerDetails(customerKey)){
                                CustomerDetails customDetailsObj  = createStripeCustomer(holderName, email, cardObj.token_id);
                                if(customDetailsObj != null)
                                    customerDetails.stripeCustomerId = customDetailsObj.customerId;
                                else 
                                    customerDetails.stripeCustomerId = null;
                            }
                            else
                                customerDetails.stripeCustomerId = customerKey;
                        }
                        
                }

                if(String.isNotBlank(customerDetails.stripeCustomerId) && String.isNotBlank(holderName)
                && String.isNotBlank(cardObj.last4) && String.isNotBlank(cardObj.token_id) 
                && String.isNotBlank(accountSFId) && String.isNotBlank(cardObj.id)){
                    paymentAccountObj.Account__c = accountSFId;
                    //paymentAccountObj.Stripe_Customer_key__c = customerDetails.stripeCustomerId;
                    paymentAccountObj.Holder_Name__c = holderName;
                    System.debug('JM :: customerDetails.accountNo : '+cardObj.last4);
                    paymentAccountObj.Account_Number__c = cardObj.last4;
                    paymentAccountObj.Type__c = 'Card';
                    paymentAccountObj.Stripe_Token__c = cardObj.token_id;
                    paymentAccountObj.Stripe_Bank_Account_Token__c	= cardObj.id;
                    paymentAccountObj.Active__c = noOldPaymentAccountIsActive;
                    parentAccount.Id = accountSFId;
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
            }
        }
    }

    //For offline
    @future(callout=true)
	public static void createStripeCustomerUsingACH(String accountSFId, string customerName, String email){
        System.debug('JM :: createStripeCustomerUsingACH  new method called');
        		
        if(String.isNotBlank(accountSFId) && String.isNotBlank(customerName) && String.isNotBlank(email)){

            StripeCustomerDetails stripeCustomerDetails = new StripeCustomerDetails();
            CustomerDetails objCustomerDetails = new CustomerDetails();
            Account objAccount = [SELECT Customer_key__c
								  FROM Account
								  WHERE Id =: accountSFId];
						   
            if(objAccount != null){
                if(String.isNotBlank(objAccount.Customer_key__c)){
					if(!getStripeCustomerDetails(objAccount.Customer_key__c)){
                       
                        objCustomerDetails = createStripeCustomer(customerName, email);
                        
                        if(objCustomerDetails != null)
							stripeCustomerDetails.stripeCustomerId = objCustomerDetails.customerId;
                        
                       
                    }
                }
                else{
                    
                    System.debug('Customer Id is blank...');
                    objCustomerDetails = createStripeCustomer(customerName, email);
                    if(objCustomerDetails != null)
						stripeCustomerDetails.stripeCustomerId = objCustomerDetails.customerId;
					//stripeCustomerDetails.stripeCustomerId = createStripeCustomer(customerName, email).customerId;
				} 
                System.debug('createStripeCustomerUsingACH.stripeCustomerId : '+stripeCustomerDetails.stripeCustomerId);
                System.debug('CUstomer Name : '+objCustomerDetails.customerName);
               	System.debug('Customer Id : '+objCustomerDetails.customerId);
			}	          
        }
    }

    //getStripeCustomerDetails() to verify the CustomerId 
    private static Boolean getStripeCustomerDetails(String customerKey){
        if(String.isNotBlank(customerKey)==true){
            String autorizationKey = 'Bearer '+stripeAuthDetails.secretKey__c;
            
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
            System.debug(response.getBody());
            
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
            String autorizationKey = 'Bearer '+stripeAuthDetails.secretKey__c;
            
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
            System.debug(response.getBody());
            
            return response;                
        }else{
            return null;
        }
    }

    Public Class CustomerDetails{
        Public String customerId;
        Public String bankSourceId;
        public String customerName;
    }


    Public Class StripeCustomerDetails{
        Public String accountHolderName;
        Public String accountRountingNo;
        Public String accountNo;
        Public String stripeCustomerId;
        Public String tokenId;
        Public String banktokenId;
        Public String accountType;
    }


    public class StripeCustomerCharge{
        public String chargeid {get;set;}
        public Integer amount {get;set;} 
        public Integer amount_captured {get;set;}
        public String balance_transaction {get;set;}
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