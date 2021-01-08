trigger PaymentAccountTrigger on Payment_Account__c (After Insert, After Update) {
    if(Trigger.isAfter){
        System.debug('JM :: PaymentAccountTrigger :: isAfter');
        if(Trigger.isInsert){
            System.debug('JM :: PaymentAccountTrigger :: isInsert');
            PaymentAccountTriggerHelper.afterInsert();
        }
        if(Trigger.isUpdate){
            System.debug('JM :: PaymentAccountTrigger :: isUpdate');
            PaymentAccountTriggerHelper.afterInsert();
        }
    }
}