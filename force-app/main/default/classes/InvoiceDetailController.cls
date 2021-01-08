Public with sharing class InvoiceDetailController{
    public Invoice__c invoice{get;set;}
    public List<Payment__c> listPayment{get;set;}
    public String logo{get;set;}
	    
    public InvoiceDetailController(){
        invoice = new Invoice__c();
        listPayment = new List<Payment__c>();
        string invId = Apexpages.currentPage().getParameters().get('Id');
        
        List<Invoice__c> invList = InvoiceService.getInvoiceById(invId);  
        if(invList.size()>0){
            if(invList[0].Total_Paid_Amount__c == NULL)
                invList[0].Total_Paid_Amount__c = 0;
            
            if(invList[0].Invoice_Line_Items__r.size() > 0){
                for(Invoice_Line_Item__c invItm : invList[0].Invoice_Line_Items__r){
                    if(invItm.GST_Amount__c == NULL)
                        invItm.GST_Amount__c = 0;
                }
            }
            invoice = invList[0];
            if(invoice.Payments__r.size() > 0){
                listPayment = invoice.Payments__r;
            }
            
            List<Blufy_Config__mdt> listBlufyConfig = BlufyConfigService.getByDeveloperName('Default');
            if(listBlufyConfig.size() > 0){
                logo = listBlufyConfig[0].Logo__c;
            }
        }       
    }
}