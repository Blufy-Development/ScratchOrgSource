public class MonthlyFullInvoiceHandler extends iBlufyInvoiceEngine {
    
    // public Subscription_Line_Item__c objLineItem;
    public MonthlyFullInvoiceHandler(Subscription_Line_Item__c objLineItem){
        this.objLineItem = objLineItem;
    }
    
    public override List<Invoice_Line_Item__c> createInvoiceLineItems(Invoice__c objInv,LineItemCalculateWrapper objWrap,String year, String month){
        List<Invoice_Line_Item__c> listOfLineItems = new List<Invoice_Line_Item__c>();
        Integer noOfSession = 0;
        List<Session__c> sessions = objWrap.mapOfClassSession.containsKey(objLineItem.Enrollment__r.Class_Session__c) ?  
        objWrap.mapOfClassSession.get(objLineItem.Enrollment__r.Class_Session__c) : new List<Session__c>();
        Decimal amount = 0;
        date dateObj = date.today();
        if(Integer.valueOf(month) != dateObj.month() && String.isNotBlank(year) && String.isNotBlank(month)){
             dateObj = date.newinstance(Integer.valueOf(year), Integer.valueOf(month), 1);
        }
        system.debug('dateObj'+dateObj);
        system.debug('objLineItem.Fee__r.Fixed_Billing__c  '+objLineItem.Fee__r.Fixed_Billing__c);
        system.debug('objLineItem.Fee__r.Prorate__c  '+ objLineItem.Fee__r.Prorate__c);
        system.debug('objLineItemId-'+objLineItem.Id);
        system.debug('sessions-size '+sessions.size());
        if(objLineItem.Fee__r.Fixed_Billing__c != false && objLineItem.Fee__r.Prorate__c == false){
            amount = objLineItem.Fee__r.amount__c;
        }else {
            if(objLineItem.Enrollment__r.Start_Date__c != null && objLineItem.Enrollment__r.Last_Session_Date__c != null
              && objLineItem.Enrollment__r.Start_Date__c.month() == dateObj.month() && objLineItem.Enrollment__r.Last_Session_Date__c.month() == dateObj.month()){
                for(Session__c session : sessions){
                    if(session.session_Date__c.month() == dateObj.month() && session.session_Date__c >= objLineItem.Enrollment__r.Start_Date__c && session.session_Date__c <= objLineItem.Enrollment__r.Last_Session_Date__c){
                        noOfSession+=1;
                    }
                }
            }else if(objLineItem.Enrollment__r.Start_Date__c != null && objLineItem.Enrollment__r.Start_Date__c.month() == dateObj.month()){
                for(Session__c session : sessions){
                    if(session.session_Date__c.month() == dateObj.month() && session.session_Date__c >= objLineItem.Enrollment__r.Start_Date__c ){
                        noOfSession+=1;
                    }
                }
            }else if(objLineItem.Enrollment__r.Last_Session_Date__c != null &&  objLineItem.Enrollment__r.Last_Session_Date__c.month() == dateObj.month()){
                for(Session__c session : sessions){
                    if(session.session_Date__c.month() == dateObj.month() && session.session_Date__c <= objLineItem.Enrollment__r.Last_Session_Date__c ){
                        noOfSession+=1;
                    }
                }
            }else{
                for(Session__c session : sessions){
                    system.debug('session month ' + session.session_Date__c.month());
                    if(session.session_Date__c.month() == dateObj.month()){
                        noOfSession+=1;
                    }
                }
            } 
            system.debug('noOfSession'+noOfSession);           
            if(objLineItem.Fee__r.Unit_Price__c != null){
                amount = noOfSession * objLineItem.Fee__r.Unit_Price__c;
            }           
            system.debug('amount'+amount);
        }
        // if(objLineItem.Subscription_Start_Date__c != NULL && objLineItem.Subscription_Start_Date__c.month() == objLineItem.Next_Bill_Date__c.month() 
        //    && objLineItem.Subscription_Start_Date__c.year() == objLineItem.Next_Bill_Date__c.year()){
        //        System.debug('inside subscription is starting late in month');
        //        for(Session__c session : sessions){
        //            if(session.session_Date__c >= objLineItem.Subscription_Start_Date__c ){
        //                noOfSession+=1;
        //            }
        //        }
        //    }else if(objLineItem.Enrollment__r.Last_Session_Date__c != NULL && objLineItem.Enrollment__r.Last_Session_Date__c.month() == objLineItem.Next_Bill_Date__c.month() 
        //             && objLineItem.Enrollment__r.Last_Session_Date__c.year() == objLineItem.Next_Bill_Date__c.year()){
        //                 System.debug('inside subscription is ending in month');
        //                 for(Session__c session : sessions){
        //                     if(session.session_Date__c <= objLineItem.Enrollment__r.Last_Session_Date__c ){
        //                         noOfSession+=1;
        //                     }
        //                 } 
        //                 objLineItem.put('Status__c','InActive');
        //                 //objLineItem.Status__c = 'InActive';
        //             }else{
        //                 noOfSession = sessions.size();
        //             }
        //Added by Asif on 09-10-20 if number of session is greater than number of units, put number of units in the noOfSession
        if(objLineItem.Fee__r.Units__c != null && objLineItem.Fee__r.Units__c > 0 && noOfSession > objLineItem.Fee__r.Units__c){
            noOfSession = Integer.valueOf(objLineItem.Fee__r.Units__c);
        }
       
        /*if(objLineItem.Fee__r.Fixed_Billing__c != false){
            amount = objLineItem.Fee__r.amount__c;
        }else {
            amount = noOfSession * objLineItem.Fee__r.Unit_Price__c;
        }*/
        //Decimal amount = noOfSession * objLineItem.Fee__r.Unit_Price__c;
        system.debug('objLineItem'+objLineItem.Fee__r.GST_Applicable__c);
        Invoice_Line_Item__c objInvoiceItem = InvoiceFactory.createInvLineItem(objLineItem,'Fee',amount,objInv.id,year,month);  //new Invoice_Line_Item__c();
        listOfLineItems.add(objInvoiceItem);
        
        // set next bill date
      //  objLineItem.put('Next_Bill_Date__c',date.valueOf(objLineItem.Next_Bill_Date__c.addMonths(1))); 
        system.debug('MONTHLY'+objLineItem);
        //objLineItem.Next_Bill_Date__c = objLineItem.Next_Bill_Date__c.addMonths(1);
        return listOfLineItems;
    }
}