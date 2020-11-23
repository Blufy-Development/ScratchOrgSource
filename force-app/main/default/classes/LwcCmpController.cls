public with sharing class LwcCmpController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountList() {
        return [
            SELECT Id, Name, PersonMobilePhone, PersonEmail
            FROM Account
            WHERE Recordtype.Name = 'Parent'
            WITH SECURITY_ENFORCED
            LIMIT 10
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> findAccounts(String searchKey) {
        String key = '%' + searchKey + '%';
        return [
            SELECT Id, Name, PersonMobilePhone, PersonEmail
            FROM Account
            WHERE Name LIKE :key
            WITH SECURITY_ENFORCED
            LIMIT 10
        ];
    }
}