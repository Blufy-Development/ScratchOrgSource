public class AutoCompleteCmpController {
    @auraEnabled(cacheable=true)
    public static List<SObject> getRecords(String searchString, String objectApiName, String idFieldApiName, String valueFieldApiName, String extendedWhereClause, Integer maxRecords){
        Set<String> fieldsApiName = new Set<String>{'Id', 'Name'};
            // if(String.isNotBlank(objectApiName) && objectApiName.endsWith('__c'))
            //objectApiName = 'educato__' + objectApiName;
            //System.debug('Namespace-->'+ConstantClass.nameSpace);
            // System.debug('objectApiName@@@@@-->'+objectApiName);
            Boolean isAccessible = FieldPremissionCrudUtility.checkReadPermission(objectApiName,fieldsApiName,false);    
        if(isAccessible){
            searchString = String.escapeSingleQuotes(searchString);
            objectApiName = String.escapeSingleQuotes(objectApiName);
            idFieldApiName = String.escapeSingleQuotes(idFieldApiName);
            valueFieldApiName = String.escapeSingleQuotes(valueFieldApiName);
            
            if(extendedWhereClause == null){
                extendedWhereClause = '';
            }
            System.debug('@@@@@-->'+extendedWhereClause);
            //if(String.isNotBlank(objectApiName) && objectApiName.endsWith('__c'))
           //     objectApiName = 'educato__' + objectApiName;
            String query = 'SELECT '+idFieldApiName+', '+valueFieldApiName+' FROM '+objectApiName+' WHERE '+valueFieldApiName+' LIKE \'%'+String.escapeSingleQuotes(searchString)+'%\' '+extendedWhereClause+' WITH SECURITY_ENFORCED LIMIT '+maxRecords;
            if(objectApiName.equalsIgnoreCase('Account')){
                if(extendedWhereClause.startsWith('001'))
                    extendedWhereClause = ' AND Parent__c = \'' +extendedWhereClause+ '\' AND Recordtype.Name =\'Customer\' ';
                //query = 'SELECT '+idFieldApiName+', '+valueFieldApiName+',LastName,PersonEmail FROM '+objectApiName+' WHERE Recordtype.Name =\'Customer\' AND '+valueFieldApiName+' LIKE \'%'+searchString+'%\' '+extendedWhereClause+' LIMIT '+maxRecords;
                query = 'SELECT '+idFieldApiName+', '+valueFieldApiName+',LastName,PersonEmail FROM '+objectApiName+' WHERE '+valueFieldApiName+' LIKE \'%'+String.escapeSingleQuotes(searchString)+'%\' '+extendedWhereClause+' WITH SECURITY_ENFORCED LIMIT '+maxRecords;
            }       
            System.debug('@@@@-->'+query);
            return Database.query(query);
        }
        return null;
    }

    @AuraEnabled(cacheable = true)
    public static List<SObject> findRecords(String searchKey, String objectName, String searchField,String extendedWhereClause){
        System.debug(System.LoggingLevel.DEBUG,extendedWhereClause );
        String key = '%' + searchKey + '%';
        String QUERY = 'Select Id, '+searchField+' From '+objectName +' Where '+searchField +' LIKE :key';
        
        if(String.isNotBlank(extendedWhereClause) && (extendedWhereClause.containsIgnoreCase('Parent') || extendedWhereClause.containsIgnoreCase('Student'))){
            QUERY = 'Select Id, '+searchField+',FirstName From '+objectName +' Where '+searchField +' LIKE :key';
        }
        if(objectName.equalsIgnoreCase('Course__c')){
            QUERY = 'Select Id, '+searchField+',Location__r.Name From '+objectName +' Where '+searchField +' LIKE :key';
        }
        if(String.isNotBlank(extendedWhereClause))
            QUERY += extendedWhereClause;
        QUERY += ' WITH SECURITY_ENFORCED LIMIT 5';
        System.debug(System.LoggingLevel.DEBUG, QUERY);
        List<SObject> sObjectList = Database.query(QUERY);
        return sObjectList;
    }
}