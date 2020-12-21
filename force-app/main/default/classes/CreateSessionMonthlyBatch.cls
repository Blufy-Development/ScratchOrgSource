/*
* Name: CreateSessionMonthlyBatch
* Author : Rajesh Sahu
* created on : 20/11/2020
*
*
* Description : This Batch Class is used to create monthly session records for monthly Open classes
*/

global with sharing class CreateSessionMonthlyBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        //**************Retrieving Class with Open Status, Monthly Frequency,Advance Scheduling Unit is Month(s)  & Next Schedule Date is 
        //Today along with related Sessions,Class Session,Enrollment Records***************************
        String query = 'SELECT Id,Name,Start_Date__c,Advance_Scheduling_Period__c,Location__c, Scheduled_Till__c, ';
        query += ' Start_Time__c,Days_of_Week__c,Sessions__c,Exclude_Public_Holidays__c,Frequency__c, ';
        query += ' (SELECT Id,Duration_in_Minutes__c,Day_of_Week__c,Start_Time__c,Teacher__c,Room__c FROM Class_Sessions__r ORDER BY Start_Time__c), ';
        query += ' (SELECT Id,Enrollment_End_Date__c,Student__c,Type__c,Class_Session__c FROM Enrollments__r), ';
        query += ' (SELECT Id,Sequence__c FROM Sessions__r ORDER BY Sequence__c DESC LIMIT 1) ';
        query += ' FROM Class__c WHERE Status__c =\'Open\' AND Frequency__c = \'Monthly\'';
        query += ' WITH SECURITY_ENFORCED';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Class__c> clsList){
        try{
            List<Session__c> listSessionToInsert = new List<Session__c>();
            List<Student_Session__c> listStudentSession = new List<Student_Session__c>();
            List<Class__c> listClassToUpdate = new List<Class__c>();
            
            Set<String> setTeacherId   = new Set<String>();
            Set<String> setRoomId  = new Set<String>();
            
            List<Holiday__c> listOfHolidays = new List<Holiday__c>(); 
            Map<String,List<Teacher_Working_Hours__c>> mapTeacherIdToTechrWrkHour = new Map<String,List<Teacher_Working_Hours__c>>();
            Map<String,List<Teacher_Leave__c>> mapTeacherIdToTeacherLeave = new Map<String,List<Teacher_Leave__c>>();
            Map<String,List<Session__c>> mapTeacherIdToTeacherSessions = new Map<String,List<Session__c>>();
            Map<String,List<Session__c>> mapRoomIdToRoomSessions = new Map<String,List<Session__c>>();
            
            
            for(Class__c classRec : clsList){
                //*********************Retrieving Class Session related to class which specify the number of sessions per day of a Class*******************
                if(classRec.Class_Sessions__r.size() > 0){
                    for(Class_Session__c clsSess : classRec.Class_Sessions__r){
                        
                        if(String.isNotBlank(clsSess.Teacher__c))
                            setTeacherId.add(clsSess.Teacher__c);
                        if(String.isNotBlank(clsSess.Room__c))
                            setRoomId.add(clsSess.Room__c);
                    }
                }
            }
            
            //************************Retrieving Teacher Leaves,Teacher Working Hour & Holiday of specified teacher of class*******************************
            if(setTeacherId.size() > 0){
                mapTeacherIdToTeacherLeave = UtilityClass.getTeacherLeaves(setTeacherId);
                mapTeacherIdToTechrWrkHour = UtilityClass.getTeacherWorkingHour(setTeacherId);
                mapTeacherIdToTeacherSessions = UtilityClass.getTeacherRelatedSessions(setTeacherId);
                listOfHolidays = UtilityClass.getHolidays();
            }
            
            if(setRoomId.size() > 0)
                mapRoomIdToRoomSessions = UtilityClass.getRoomRelatedSessions(setRoomId);
            
            for(Class__c cls : clsList){
                Date sDate = cls.Scheduled_Till__c.addDays(1);
                DateTime strtDateTm = DateTime.newInstance(sDate.year(),sDate.month(),sDate.day(),00,00,00);
                
                Integer numberOfDays = Date.daysInMonth(sDate.year(), sDate.month());
                Date eDate = Date.newInstance(sDate.year(), sDate.month(), numberOfDays);                
                DateTime endDateTm = DateTime.newInstance(eDate.year(),eDate.month(),eDate.day(),00,00,00);
                
                Integer seq = 0;
                List<Session__c> listSession = UtilityClass.createSessions(cls,strtDateTm,endDateTm,seq,null,
                                                                           cls.Class_Sessions__r,
                                                                           null);
                if(listSession.size() > 0){
                    //*********Get Updated Sessions Based on Holiday,Teacher Leaves,Teacher Working Hour*****************
                    listSession = UtilityClass.getUpdatedSessions(seq,cls.Exclude_Public_Holidays__c,
                                                                  listSession,mapTeacherIdToTeacherLeave, mapTeacherIdToTechrWrkHour,
                                                                  listOfHolidays,mapTeacherIdToTeacherSessions,
                                                                  mapRoomIdToRoomSessions);
                }
                //mapClassIdToSessions.put(cls.Id,listSession);
                listSessionToInsert.addAll(listSession); 
                
                Class__c clsTemp = new Class__c(Id=cls.Id);
                clsTemp.put('Scheduled_Till__c',eDate);
                listClassToUpdate.add(clsTemp);
            } 
            
            if(listSessionToInsert.size() > 0){
                listSessionToInsert = SessionService.insertSessionRecords(listSessionToInsert);
                
                Map<String,List<Session__c>> mapClassIdToSessions = new Map<String,List<Session__c>>();
                for(Session__c sess : listSessionToInsert){
                    List<Session__c> listSession = new List<Session__c>();
                    String key = sess.Class__c+';'+sess.Class_Session__c;
                    if(mapClassIdToSessions.containsKey(key))
                        listSession = mapClassIdToSessions.get(key);
                    listSession.add(sess);
                    mapClassIdToSessions.put(key,listSession);
                }
                
                for(Class__c cls: clsList){
                    //*********************Retrieving Enrollments related to class*******************
                    for(Enrollment__c enrol : cls.Enrollments__r){
                        //******************Creating Student Session Records for each Enrollment based on session records*********** 
                        if(mapClassIdToSessions.get(cls.Id+';'+enrol.Class_Session__c) != null){
                            for(Session__c sess : mapClassIdToSessions.get(cls.Id+';'+enrol.Class_Session__c)){
                                Student_Session__c stuSess = UtilityClass.createStudentSessions(enrol, sess);
                                listStudentSession.add(stuSess);
                            }
                        }
                    }
                }
                System.debug('listClassToUpdate->'+listClassToUpdate);
                if(listStudentSession.size() > 0)
                    StudentSessionService.insertStudentSessionRecords(listStudentSession);
                
                ClassService.updateClassRecords(listClassToUpdate);
            }
        } catch(Exception e){
            System.debug('Line Number-->'+e.getLineNumber());
            
            Blufy_Error_Log__c blufyErrLg = new Blufy_Error_Log__c();
            blufyErrLg.put('Process_Name__c','SessionRecordsCreationBatchApex');
            blufyErrLg.put('Description__c',e.getMessage());
            blufyErrLg.put('Title__c','Session Creation Batch');
            BlufyErrorLogService.insertBlufyErrorLogRecords(new List<Blufy_Error_Log__c>{blufyErrLg});
        }
    }
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}