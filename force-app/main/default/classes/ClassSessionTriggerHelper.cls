public class ClassSessionTriggerHelper {
    public static void createSessions(List<Class_Session__c> clsSessList){
        Map<String,Class_Session__c> clsSessMap = new Map<String,Class_Session__c>(ClassSessionService.getClassSessionsByIds(clsSessList));
        List<Session__c> listSession = new List<Session__c>();
        for(Class_Session__c clsSess: clsSessList){
            if(clsSessMap.get(clsSess.Id) != null){
                Date sDate = System.today();
                DateTime strtDateTm = DateTime.newInstance(sDate.year(),sDate.month(),sDate.day(),00,00,00);
                
                Date sessTillDate = clsSessMap.get(clsSess.Id).Class__r.Scheduled_Till__c;
                DateTime endDateTm = DateTime.newInstance(sessTillDate.year(),sessTillDate.month(),sessTillDate.day(),00,00,00);
                
                Integer seq = 0;
                Class__c cls = new Class__c(Id = clsSess.Class__c, Location__c = clsSessMap.get(clsSess.Id).Class__r.Location__c);
                listSession.addAll(UtilityClass.createSessions(cls,strtDateTm,endDateTm,seq,null,
                                                                           new List<Class_Session__c>{clsSess},
                                                                           null));
            }
        }  
        if(listSession.size() > 0)
            SessionService.insertSessionRecords(listSession);
    }
    
    public static void updateClsSessRelatedSessionRecords(Map <String, Class_Session__c> mapClsSess){
        List<Session__c> updateSessList = new List<Session__c>();
        List<Session__c> sessionList    = SessionService.getSessionsFromTodayByClassSessionId(mapClsSess.keySet());
        if(sessionList.size() > 0){
            for(Session__c sessObj : sessionList){
                Session__c sess = new Session__c(Id = sessObj.Id);
                sess.Teacher__c = mapClsSess.get(sessObj.Class_Session__c).Teacher__c;
                sess.Room__c    = mapClsSess.get(sessObj.Class_Session__c).Room__c;
                updateSessList.add(sess);
            }
        }
        
        if(updateSessList.size() > 0){
            SessionService.updateSessionRecords(updateSessList);
        }
    }
    
}