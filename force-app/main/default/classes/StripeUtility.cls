public class StripeUtility {
	public static string userName ='pk_test_51HpTW9FP8lsxT1YHGc6Y6gOOAR3oW1tjqVvLmydtVo7dRgdhzBY7I13mrd9osX2YPHYkh0av1IkhK4dmNjqrEXt400vfzOPCWU';
	public static string password ='pk_test_51HpTW9FP8lsxT1YHGc6Y6gOOAR3oW1tjqVvLmydtVo7dRgdhzBY7I13mrd9osX2YPHYkh0av1IkhK4dmNjqrEXt400vfzOPCWU';
    public static string bankAccount = 'US';
    public static string bankCurrency ='USD';
    public static string holder_Name ='Jenny Rosen';
    public static string account_Holder_Type ='individual';
    public static string routing_Number ='110000000';
    public static string account_Number ='000123456789';
    
 //https://api.stripe.com/v1/tokens?bank_account[country]=us&bank_account[currency]=USD&bank_account[account_holder_name]=Jenny Rosen&bank_account[account_holder_type]=individual&bank_account[routing_number]=110000000&bank_account[account_number]=000123456789 
    public static void tokenBankAccount(){
        system.debug('Inserted');
        if(string.isNotBlank(bankAccount) && string.isNotBlank(bankCurrency) && string.isNotBlank(holder_Name) &&
           string.isNotBlank(account_Holder_Type) && string.isNotBlank(routing_Number) && string.isNotBlank(account_Number)){
               try{
                   string endPoint ='https://api.stripe.com/v1/tokens?bank_account[country]='+bankAccount+'&bank_account[currency]=';
                   endPoint+=bankCurrency+'&bank_account[account_holder_name]='+holder_Name+'&bank_account[account_holder_type]=';
               	   endPoint+=account_Holder_Type+'&bank_account[routing_number]='+routing_Number+'&bank_account[account_number]='+account_Number;
                   	system.debug('@@@endPoint@@@'+endPoint);
                  	HttpResponse response;
                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
					Blob headerValue = Blob.valueOf(userName + '' + password);
					String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
					req.setHeader('Authorization', authorizationHeader);
                   system.debug('@@@Authorization@@@@'+ authorizationHeader);
					req.setEndpoint(endPoint);
					req.setMethod('POST');
                    response = http.send(req);
                	system.debug('@@@response@@@@'+ response.getBody());
                    system.debug('@@@Code@@@@'+response.getStatusCode());
                    If(response.getStatusCode() == 200 ){  
						system.debug('@@@responseInternal@@@@'+ response.getBody());
                        
                    }else{
                        //system.debug('responseInternalERROR'+response.get);
                    }
                   
                   
               }catch(Exception e){
                   system.debug('error '+e);
               }
           }
        
        
    }
    

}