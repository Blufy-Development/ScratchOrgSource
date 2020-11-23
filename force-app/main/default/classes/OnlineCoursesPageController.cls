public class OnlineCoursesPageController {
 /*   public string location {get;set;}
    public string category {get;set;}
    public string level {get;set;}
    public string type {get;set;}
    public List<SelectOption> listLocation {get;set;}
    public List<SelectOption> listCategory {get;set;}
    public List<SelectOption> listLevel {get;set;}
    public List<SelectOption> listType {get;set;}
    public Integer countFilter {get;set;}
    
    public OnlineCoursesPageController(){
        location = '';
        category = '';
        level = '';
        type = '';
        countFilter = 0;
        listLocation = new List<SelectOption>();
        listCategory = new List<SelectOption>();
        listLevel = new List<SelectOption>();
        listType = new List<SelectOption>();
        getFiltersData();
    }
    
    private void getFiltersData(){
        List<String> listFilterVisibility = new List<String>();
        for(educato__Online_Process_Config__mdt metaData : [SELECT educato__Field_Api_Name__c FROM educato__Online_Process_Config__mdt
                                                            WHERE educato__Active__c = true AND educato__Type__c = 'Filter'
                                                            AND educato__Section__c = 'Course Filter']){
                                                                listFilterVisibility.add(metaData.educato__Field_Api_Name__c);                                            
                                                            }
        system.debug('listFilterVisibility-->'+listFilterVisibility);
        if(listFilterVisibility.size() > 0){
             countFilter = listFilterVisibility.size();
            if(listFilterVisibility.contains('Location')){
                for(Account acc : [SELECT Id,Name FROM Account WHERE RecordType.Name = 'Location']){
                    listLocation.add(new SelectOption(acc.Id,acc.Name));
                }
            }
            
            if(listFilterVisibility.contains('educato__Category__c')){
                for(String catValue : UtilityClass.getPickValues('educato__Course__c','educato__Category__c')){
                    listCategory.add(new SelectOption(catValue,catValue));
                }
            }
            
            if(listFilterVisibility.contains('educato__Level__c')){
                for(String levValue : UtilityClass.getPickValues('educato__Course__c','educato__Level__c')){
                    listLevel.add(new SelectOption(levValue,levValue));
                }
            }
            
            if(listFilterVisibility.contains('educato__Type__c')){
                for(String typValue : UtilityClass.getPickValues('educato__Course__c','educato__Type__c')){
                    listType.add(new SelectOption(typValue,typValue));   
                }
            }
        }
    }   */
}