public class NewEnrollmentFormApexController {
    
    @auraEnabled
    public static InitWrapperClass doInitApex(){
        InitWrapperClass initWrpCls = new InitWrapperClass();
        try{
            initWrpCls.listGenderPicklistValues       = UtilityClass.getPickValues('Account','educato__Gender__c');
            initWrpCls.listPaymentModePicklistValues  = UtilityClass.getPickValues('educato__Payment__c', 'educato__Cash_Mode__c');
            initWrpCls.maxBirthdate = Date.today();          
            initWrpCls.message = 'SUCCESS';
            return initWrpCls;
        }catch(exception e){
            System.debug('Do Init Method Error Message-->'+e.getMessage());
            System.debug('Do Init Method Line Number-->'+e.getLineNumber());
            initWrpCls.message = e.getMessage(); 
            return initWrpCls;
        }
    }
    
    @auraEnabled
    public static Account getSelectedAccount(String accId,Boolean isCorporateAccount){
        Account acc = new Account();
        List<Account> accList = new List<Account>();
        accList = AccountService.getCorporateOrCustomerById(accId, isCorporateAccount);
        if(accList.size() > 0){
            acc= accList.get(0);
        }
        System.debug('acc-->'+acc); 
        return acc;
    }
    
    public Class InitWrapperClass{
        @AuraEnabled
        public List<String> listGenderPicklistValues;
        @AuraEnabled
        public List<String> listPaymentModePicklistValues;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Date maxBirthdate;
        
        public InitWrapperClass(){
            listGenderPicklistValues      = new List<String>();
            listPaymentModePicklistValues = new List<String>();       
            message = '';
        }
    }
}