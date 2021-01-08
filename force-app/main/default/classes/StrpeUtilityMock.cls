global class StrpeUtilityMock implements HttpCalloutMock {
// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
         HttpResponse res = new HttpResponse();  
          if (req.getEndpoint().endsWith('tokens')) {
              System.debug('HELL :: '+req.getBody());
              if(req.getBody().contains('card')){
                res.setBody('{ "id": "tok_1HzdnFBceq9TTrxiKCnTdOan", "object": "token", "card": { "id": "card_1HzdnFBceq9TTrxikyiGncMy", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": null, "address_zip_check": null, "brand": "Visa", "country": "US", "cvc_check": "unchecked", "dynamic_last4": null, "exp_month": 12, "exp_year": 2021, "fingerprint": "mFDJrOiKYpYTHTfa", "funding": "credit", "last4": "4242", "metadata": {}, "name": null, "tokenization_method": null }, "client_ip": "117.199.192.81", "created": 1608278069, "livemode": false, "type": "card", "used": false }');
                res.setStatusCode(200);
              }
              
              else{
                  res.setBody('{ "id": "btok_1HvglzBceq9TTrxi74nRHAHx", "object": "token", "bank_account": { "id": "ba_1HvglzBceq9TTrxigiRmduvk", "object": "bank_account", "account_holder_name": "Jenny Rosen", "account_holder_type": "individual", "bank_name": "STRIPE TEST BANK", "country": "US", "currency": "usd", "fingerprint": "xUKg8Q81nWKxi0eD", "last4": "6789", "routing_number": "110000000", "status": "new" }, "client_ip": "13.108.238.8", "created": 1607336211, "livemode": false, "type": "bank_account", "used": false }');
                  res.setStatusCode(200);    
              }
              system.debug('endpoint ----> '+req.getEndpoint());
                 
         }
        
         if (req.getEndpoint().endsWith('customers')) {
              system.debug('endpoint 2 ----> '+req.getEndpoint());
              res.setBody('{ "id": "cus_IWkgCLgOc0fBlw", "object": "customer", "address": null, "balance": 0, "created": 1607337743, "currency": null, "default_source": "ba_1HvglzBceq9TTrxigiRmduvk", "delinquent": false, "description": "TestName", "discount": null, "email": "test@gmail.com", "invoice_prefix": "7F262C6D", "invoice_settings": { "custom_fields": null, "default_payment_method": null, "footer": null }, "livemode": false, "metadata": { }, "name": "TestName", "next_invoice_sequence": 1, "phone": null, "preferred_locales": [ ], "shipping": null, "tax_exempt": "none" }');             
              res.setStatusCode(200);   
         }
           
        if(req.getEndpoint().endsWith('cus_IWkgCLgOc0fBlw')){
            res.setBody('{ "id": "cus_IWkgCLgOc0fBlw", "object": "customer", "address": null, "balance": 0, "created": 1608013350, "currency": "usd", "default_source": null, "delinquent": false, "description": null, "discount": null, "email": null, "invoice_prefix": "4310AD6", "invoice_settings": { "custom_fields": null, "default_payment_method": null, "footer": null }, "livemode": false, "metadata": {}, "name": null, "next_invoice_sequence": 1, "phone": null, "preferred_locales": [], "shipping": null, "tax_exempt": "none" }');             
            res.setStatusCode(200);  
        }
        
        if(req.getEndpoint().endsWith('sources')){
            res.setBody('{ "id": "card_1HzdnFBceq9TTrxikyiGncMy", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": null, "address_zip_check": null, "brand": "Visa", "country": "US", "customer": "cus_IapHt189fHeLJ9", "cvc_check": "pass", "dynamic_last4": null, "exp_month": 12, "exp_year": 2021, "fingerprint": "mFDJrOiKYpYTHTfa", "funding": "credit", "last4": "4242", "metadata": {}, "name": null, "tokenization_method": null }');             
            res.setStatusCode(200);  
        }
        
        if(req.getEndpoint().endsWith('card_1HzdnFBceq9TTrxikyiGncMy')){
            res.setBody('{ "id": "card_1HzdnFBceq9TTrxikyiGncMy", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": null, "address_zip_check": null, "brand": "Visa", "country": "US", "customer": "cus_IapHt189fHeLJ9", "cvc_check": "pass", "dynamic_last4": null, "exp_month": 12, "exp_year": 2021, "fingerprint": "mFDJrOiKYpYTHTfa", "funding": "credit", "last4": "4242", "metadata": {}, "name": null, "tokenization_method": null }');             
            res.setStatusCode(200);  
        }

         if (req.getEndpoint().endsWith('charges')) {
             system.debug('endpoint 2 ----> '+req.getEndpoint());   
             res.setBody('{ "id": "ch_1HvhleBceq9TTrxi5s5i7ihs", "object": "charge", "amount": 10000, "amount_captured": 10000, "amount_refunded": 0, "application": null, "application_fee": null, "application_fee_amount": null, "balance_transaction": "txn_1HvhleBceq9TTrxiAh3WMdB7", "billing_details": { "address": { "city": null, "country": null, "line1": null, "line2": null, "postal_code": null, "state": null }, "email": null, "name": null, "phone": null }, "calculated_statement_descriptor": "Stripe", "captured": true, "created": 1607340034, "currency": "inr", "customer": null, "description": "My First Test Charge (created for API docs)", "destination": null, "dispute": null, "disputed": false, "failure_code": null, "failure_message": null, "fraud_details": { }, "invoice": null, "livemode": false, "metadata": { }, "on_behalf_of": null, "order": null, "outcome": { "network_status": "approved_by_network", "reason": null, "risk_level": "normal", "risk_score": 58, "seller_message": "Payment complete.", "type": "authorized" }, "paid": true, "payment_intent": null, "payment_method": "card_1HvhleBceq9TTrxikQIWIOHQ", "payment_method_details": { "card": { "brand": "visa", "checks": { "address_line1_check": null, "address_postal_code_check": null, "cvc_check": null }, "country": "US", "exp_month": 12, "exp_year": 2021, "fingerprint": "mFDJrOiKYpYTHTfa", "funding": "credit", "installments": null, "last4": "4242", "network": "visa", "three_d_secure": null, "wallet": null }, "type": "card" }, "receipt_email": null, "receipt_number": null, "receipt_url": "https://pay.stripe.com/receipts/acct_1Hs5GNBceq9TTrxi/ch_1HvhleBceq9TTrxi5s5i7ihs/rcpt_IWlILXNgtIQ0eueIIxiGhj1sGXav4oV", "refunded": false, "refunds": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/charges/ch_1HvhleBceq9TTrxi5s5i7ihs/refunds" }, "review": null, "shipping": null, "source": { "id": "card_1HvhleBceq9TTrxikQIWIOHQ", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": null, "address_zip_check": null, "brand": "Visa", "country": "US", "customer": null, "cvc_check": null, "dynamic_last4": null, "exp_month": 12, "exp_year": 2021, "fingerprint": "mFDJrOiKYpYTHTfa", "funding": "credit", "last4": "4242", "metadata": { }, "name": null, "tokenization_method": null }, "source_transfer": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "status": "succeeded", "transfer_data": null, "transfer_group": null }');
             res.setStatusCode(200);   
         }
        
        
         if (req.getEndpoint().endsWith('verify')) {
             system.debug('endpoint 2 ----> '+req.getEndpoint());
             res.SetstatusCode(200);
             res.setBody('{ "id": "ba_1I1rzLBceq9TTrxi27GQtqVs", "object": "bank_account", "account_holder_name": "Jenny Rosen", "account_holder_type": "individual", "bank_name": "STRIPE TEST BANK", "country": "US", "currency": "usd", "customer": "cus_Id8HKIFlaY0TvX", "fingerprint": "xUKg8Q81nWKxi0eD", "last4": "6789", "metadata": { }, "routing_number": "110000000", "status": "verified" }');
         }
        
         return res;       
    }
}