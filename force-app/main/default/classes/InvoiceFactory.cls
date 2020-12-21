/*
Name            :   InvoiceFactory
Date            :   03/23/2020
Author          :   Arpit vijayvergiya
Description     :   This class acts as midileware which takes will decide right invoice handler.
*/
public class InvoiceFactory {
    /*
As per blufy model , a subscription can have multiple subscription line item so, each line item can fall down into different
Invoice handler.
*/
    public List<iBlufyInvoiceEngine> listOfInvoiceHandler;
    public Set<String> setOFClassSessionIds;
    public Invoice__c objInv;
    public Subscription__c objSub;
    private Date executionDate;
    
    public InvoiceFactory (Subscription__c sub , Date executionDate/*, Term__c nextTerm, Date nextMonthStartDate*/){
        this.objSub = sub;
        this.executionDate = executionDate;
        listOfInvoiceHandler = new List<iBlufyInvoiceEngine>();
        setOFClassSessionIds = new Set<String>();
        setInvoice(sub);    
        
        for(Subscription_Line_Item__c objLineItem : sub.Subscription_Line_Items__r){
            if(objLineItem.Enrollment__r.Class_Session__c != null){
             	setOFClassSessionIds.add(objLineItem.Enrollment__r.Class_Session__c);   
            }           
            listOfInvoiceHandler.add(getHandler(sub.Payment_Frequency__c,objLineItem));
        } 
    }
    
    private IBlufyInvoiceEngine getHandler(String frequency, Subscription_Line_Item__c objLineItem){
        System.debug('frequency '+frequency);
        IBlufyInvoiceEngine handler;
        if(frequency == 'Term'){
            handler = new TermFullInvoiceHandler(objLineItem);
        }else if(frequency == 'Monthly'){
            handler = new MonthlyFullInvoiceHandler(objLineItem);
        }
        return handler;
    }
    
    public Invoice__c getInvoice(){
        return this.objInv;
    }
    
    /*
     * return sessions related to class and time limit
    *  timeLimit e.g. Next_Month, THIS_Month
    */
    public static Map<String,List<Session__c>> getClassSessions(Set<String> classIds){
        Map<String,List<Session__c>> classSessionsMap = new Map<String,List<Session__c>>();
        if(classIds.size() > 0){
            String ids = '';
             for(String cId : classIds){                
                ids += '\''+string.escapeSingleQuotes(cId)+ '\',';
            }
            ids = ids.removeEnd(',');            
            String query = 'SELECT Id, Session_Date__c, Class__c, Class_Session__c FROM Session__c WHERE Session_Date__c = THIS_MONTH AND Class_Session__c IN('+ids+')  WITH SECURITY_ENFORCED';
            for(SObject sObj : InvoiceService.getExecutedQueryRecords(query)){
                Session__c objSession = (Session__c)sObj;
                List<Session__c> sessionsList = classSessionsMap.containsKey(objSession.Class_Session__c) ? classSessionsMap.get(objSession.Class_Session__c) : 
                new List<Session__c>();
                sessionsList.add(objSession);
                classSessionsMap.put(objSession.Class_Session__c,sessionsList);            
            }
            return classSessionsMap;
        }
        return null;
    }
    
    
    /*
     * return class term map
    */
    
    public static Map<String,List<Class_Term__c>> getClassTermMap(Set<String> setOfClassIDs){
        System.debug('@@@setOfClassIDs'+setOfClassIDs);
        Map<String,List<Class_Term__c>> mapOfclassTerm = new Map<String,List<Class_Term__c>>();
        for(Class_Term__c objTerm : ClassTermService.getByClassIds(setOfClassIDs)){
            List<Class_Term__c> listOfTerm = mapOfClassTerm.containsKey(objTerm.Class__c) ? mapOfClassTerm.get(objTerm.Class__c) :
            new List<Class_Term__c>();
            listOfTerm.add(objTerm);
            mapOfClassTerm.put(objTerm.Class__c,listOfTerm);
        }
        return mapOfClassTerm;
    }
    
    //Util common methods
    public void setInvoice(Subscription__c sub){
        Blufy_Config__mdt blufyConfig = NewEnrollmentFormCntrl.getBlufyConfigDetails();  
        this.objInv = UtilityClass.fillInvoice(sub.Customer__c, sub.Location__c,sub.Id,'Recurring','Due');
        this.objInv.Invoice_Date__c = executionDate;//System.today();
        //this.objInv.Due_Date__c = executionDate;//System.today();
        if(blufyConfig.Invoice_Due_Days__c > 0){
             this.objInv.Due_Date__c = System.today().addDays(Integer.valueOf(blufyConfig.Invoice_Due_Days__c));
        }else{
            this.objInv.Due_Date__c = executionDate;
        }
    }
    
    public static Invoice_Line_Item__c createInvLineItem(Subscription_Line_Item__c objLineItem,String type,Decimal amount,String invId){
        Blufy_Config__mdt blufyConfig = NewEnrollmentFormCntrl.getBlufyConfigDetails();                              
        Invoice_Line_Item__c objInvoiceItem = UtilityClass.fillInvLineItem(invId, objLineItem.Enrollment__c, objLineItem.id, 
                                                                          objLineItem.Fee__c, null,type, amount, blufyConfig.GST_VAT_Applicable__c, blufyConfig.GST_VAT_Rate__c);
        return objInvoiceItem;
    }
    
    public static Subscription_Line_Item__c resetClassTermAndBillDate(Subscription_Line_Item__c objLineItem){
        objLineItem.put('Class_Term__c',NULL);
        objLineItem.put('Next_Bill_Date__c',NULL);
        return objLineItem;
    }
}