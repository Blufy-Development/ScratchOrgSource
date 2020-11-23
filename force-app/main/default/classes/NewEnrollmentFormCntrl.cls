/*
Name: NewEnrollmentFormCntrl
Date: 30th Jan 2020
Author: 
Description: This controller is used create new enrollments 
*/
public class NewEnrollmentFormCntrl {
   
    //Its used for fetch active course records
    @auraEnabled
    public static List<Course__c> fetchCourses(){   
        return CourseService.getAllCourseWithActiveStatus();
    }
    
    //This function is used to get dynmically picklist values of the object
    @auraEnabled
    public static Map<String,String> fetchTermAndCondition(){ 
        Map<String,String> configMap = new Map<String,String>();      
        List<Blufy_Config__mdt> systemConfig = BlufyConfigService.getByDeveloperName('Default') ;
        system.debug('systemConfig-->'+systemConfig);
        if(systemConfig.size() > 0){
            configMap.put('TermsTitle',systemConfig[0].Terms_and_Conditions_Title__c);
            configMap.put('TermsDesription',systemConfig[0].Terms_and_Conditions_Description__c);
        }
        return configMap;
    }
    
    
    //This function is used to get selected contact details when user select existing customer
    @auraEnabled
    public static Account getchSlcdAccDetails(String accId,Boolean isCorporateAccount){
        Account acc = new Account();
        List<Account> accList = new List<Account>();
        accList = AccountService.getCorporateOrCustomerById(accId, isCorporateAccount);
        if(accList.size() > 0){
            acc= accList.get(0);
         /*   if(String.isNotBlank(acc.PersonContactId)){
                List<AccountContactRelation> listAccountContactRelation = AccountContactRelationService.getByPrimaryAccountContactId(acc.PersonContactId);
                if(listAccountContactRelation != NULL && listAccountContactRelation.size() > 0)
                    acc.educato__Relationship_with_contact__c = listAccountContactRelation[0].Roles;
            }*/
        }
        System.debug('acc-->'+acc); 
        return acc;
    }
    
    @AuraEnabled
    public static CourseFeeWrapper fetchCourseBySessId(String sessionId){
        CourseFeeWrapper crsFeeWrap = new CourseFeeWrapper();
        if(String.isNotBlank(sessionId)){
            List<Session__c> listSession = SessionService.getById(new Set<Id>{sessionId});
            if(listSession != Null && listSession.size() > 0){
                crsFeeWrap = fetchCrsClsDetails(listSession[0].Class__r.Course__c);
                if(crsFeeWrap != NULL && crsFeeWrap.classWrapperList.size() > 0){
                    for(ClassWrapper clsWrap : crsFeeWrap.classWrapperList){
                        if(clsWrap.clsId.equalsIgnoreCase(listSession[0].Class__c)){
                            clsWrap.isSelected = true;
                            clsWrap.courseId = listSession[0].Class__r.Course__c;
                            clsWrap.courseName = listSession[0].Class__r.Course__r.Name;
                        }
                    }
                }
            }
        }
        return crsFeeWrap;
    }
    
    //This function is used to fetch course classes when user select specific course
    @auraEnabled
    public static CourseFeeWrapper fetchCrsClsDetails(String crId){
        CourseFeeWrapper crsFeeWrap = new CourseFeeWrapper();
        List<ClassWrapper> cwList   = new List<ClassWrapper>();
        List<DisWrapper>   disList  = new List<DisWrapper>();
        
        List<Course_Fee__c> listCourseFee = CourseFeeService.getByCourseId(crId);
        if(listCourseFee != null && listCourseFee.size() > 0){
            for(Course_Fee__c crFee: listCourseFee){
                FeeWrapper fw = new FeeWrapper();
                fw.feeId      = crFee.Fee__c;
                fw.feeName    = crFee.Fee__r.Name;
                fw.feeType    = crFee.Fee__r.Type__c;
                fw.payFrequency = crFee.Fee__r.Frequency__c;  
                fw.feeAmount   = crFee.Fee__r.Amount__c;
                fw.feeSchType  = crFee.Fee__r.Schedule__c;  
                fw.noOfUnit    = crFee.Fee__r.Units__c != null ? Integer.valueOf(crFee.Fee__r.Units__c):0;
                fw.isGSTApplicable = crFee.Fee__r.GST_Applicable__c;
                
                if(crFee.Fee__r.Type__c == ConstantClass.depositFeeType){
                    fw.isSelected = crFee.Fee__r.Required__c;
                    crsFeeWrap.depositWrapperList.add(fw);
                    if(fw.isSelected){
                        fw.isOverride = true;
                        crsFeeWrap.totFee += fw.feeAmount; 
                        crsFeeWrap.totWithProratedFee += fw.feeAmount;
                    }
                }else if(crFee.Fee__r.Type__c != ConstantClass.tutionFeeType){
                    fw.isSelected = crFee.Fee__r.Required__c;
                    crsFeeWrap.feeWrapperList.add(fw);
                    if(fw.isSelected){
                        fw.isOverride = true;
                        crsFeeWrap.totFee += fw.feeAmount; 
                        crsFeeWrap.totWithProratedFee += fw.feeAmount;
                    }
                } 
            }
        }
        
        Integer counter = 0;
        for(Class__c cls: ClassService.getByCourseIdAlongWithClassTerms(crId)){   
            system.debug('cls'+cls); 
            ClassWrapper cw = new ClassWrapper();
            cw.clsId        = cls.Id;                  
            cw.clsName      = cls.Name;
            cw.clsDays      = cls.Days_of_Week__c;     
            cw.clsType      = cls.Type__c;    
            cw.clsFrequency	= cls.Frequency__c;
            cw.locationId   = cls.Location__c;
            cw.location     = cls.Location__r.Name;
            cw.teacherName  = cls.Teacher__r.Name;
            cw.clsEndDate   = (cls.End_Date__c != NULL ? cls.End_Date__c : null);
            cw.seatsAlv     = cls.Seats_Available__c != null ? Integer.valueOf(cls.Seats_Available__c) : 0;
            
            if(cls.Start_Time__c != null)
                cw.stEndTime= Datetime.newInstance(System.today(), cls.Start_Time__c).format('hh:mm a');
            if(cls.End_Time__c != null)
                cw.stEndTime += ' - '+ Datetime.newInstance(System.today(), cls.End_Time__c).format('hh:mm a');    
            
            //For Monthly classes        
            if(cls.Frequency__c.equalsIgnoreCase(ConstantClass.monthlyFrequency)){        
                counter  = counter + 1;     
                cw.recNo = counter;               
                cwList.add(cw);     
            }else{//For fixed Term and fixed classes                 
                for(Class_Term__c clsTerm : cls.Class_Terms__r){
                    if(clsTerm.End_Date__c >= System.today()){
                        TermWrapper tm = new TermWrapper();
                        tm.clsTermId = clsTerm.Id;
                        tm.clsTermName = clsTerm.Name;
                        if(clsTerm.Start_Date__c != null)
                            tm.stEndDate    = Datetime.newInstance(clsTerm.Start_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM');  
                        if(clsTerm.End_Date__c != null)
                            tm.stEndDate    += ' - '+Datetime.newInstance(clsTerm.End_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM yyyy');
                        
                        cw.termList.add(tm);
                    }
                }
                if(cw.termList.size() > 0){
                    counter = counter + 1; 
                    cw.recNo = counter;  
                    cwList.add(cw); 
                }            
            }
            system.debug('cls.Class_Sessions__r'+cls.Class_Sessions__r);
            //system.debug('cls.Class_Sessions__r.size()'+cls.Class_Sessions__r.size());
            if(cls.Class_Sessions__r.size() > 0){
                Map<String,List<ClassSessionWrapper>> dayOfWeekMap = new Map<String,List<ClassSessionWrapper>>();
                for(Class_Session__c csObj : cls.Class_Sessions__r){
                    ClassSessionWrapper clsSessObjWrap = new ClassSessionWrapper();
                    clsSessObjWrap.enrollments = csObj.Enrollments__c;
                    clsSessObjWrap.type = csObj.Type__c;
                    clsSessObjWrap.teacherName = csObj.Teacher__r.name;
                    clsSessObjWrap.startTime = csObj.Start_Time__c;
                    clsSessObjWrap.endTime = csObj.End_Time__c;
                    clsSessObjWrap.seatsLeft = csObj.Seats_Left__c;
                    clsSessObjWrap.dayOfWeek= csObj.Day_of_Week__c;   
                    if(dayOfWeekMap.containsKey(csObj.Day_of_Week__c)){
                        List<ClassSessionWrapper> clsSessionList = dayOfWeekMap.get(csObj.Day_of_Week__c);
                        clsSessionList.add(clsSessObjWrap);
                        dayOfWeekMap.put(csObj.Day_of_Week__c,clsSessionList);
                    }else{
                        dayOfWeekMap.put(csObj.Day_of_Week__c,new List<ClassSessionWrapper>{clsSessObjWrap});
                    }
                   
                    // cw.classSessionWrapperList.add(clsSessObjWrap);                 
                }
                if(dayOfWeekMap.size() > 0){
                    for(String mapObj : dayOfWeekMap.keySet()){
                        DayOfWeekWrapper dayObj = new DayOfWeekWrapper();
                        dayObj.nameOfDay = mapObj;
                        dayObj.classSessionWrapperList.addAll(dayOfWeekMap.get(mapObj));
                        cw.dayOfWeekClsList.add(dayObj);
                    }
                }

            }
        }
        crsFeeWrap.classWrapperList.addAll(cwList);
        return crsFeeWrap;
    }
    
    @AuraEnabled
    public static CourseFeeWrapper fetchClassDetails(String crId){
        CourseFeeWrapper crsFeeWrap = new CourseFeeWrapper();
        List<ClassWrapper> cwList   = new List<ClassWrapper>();
        Integer counter = 0;
        for(Class__c cls: ClassService.getByCourseIdAlongWithClassTerms(crId)){   
            system.debug('cls'+cls); 
            ClassWrapper cw = new ClassWrapper();
            cw.clsId        = cls.Id;                  
            cw.clsName      = cls.Name;
            cw.clsDays      = cls.Days_of_Week__c;     
            cw.clsType      = cls.Type__c;    
            cw.clsFrequency	= cls.Frequency__c;
            cw.course       = cls.Course__r.Name;
            cw.locationId   = cls.Location__c;
            cw.location     = cls.Location__r.Name;
            cw.teacherName  = cls.Teacher__r.Name;
            cw.totalEnrollment = cls.Enrollments__c;
            cw.clsEndDate   = (cls.End_Date__c != NULL ? cls.End_Date__c : null);
            cw.seatsAlv     = cls.Seats_Available__c != null ? Integer.valueOf(cls.Seats_Available__c) : 0;
            
            if(cls.Start_Time__c != null)
                cw.stEndTime= Datetime.newInstance(System.today(), cls.Start_Time__c).format('hh:mm a');
            if(cls.End_Time__c != null)
                cw.stEndTime += ' - '+ Datetime.newInstance(System.today(), cls.End_Time__c).format('hh:mm a');    
            
            //For Monthly classes        
            if(cls.Frequency__c.equalsIgnoreCase(ConstantClass.monthlyFrequency)){        
                counter  = counter + 1;     
                cw.recNo = counter;               
                cwList.add(cw);     
            }else{//For fixed Term and fixed classes                 
                for(Class_Term__c clsTerm : cls.Class_Terms__r){
                    if(clsTerm.End_Date__c >= System.today()){
                        TermWrapper tm = new TermWrapper();
                        tm.clsTermId = clsTerm.Id;
                        tm.clsTermName = clsTerm.Name;
                        if(clsTerm.Start_Date__c != null)
                            tm.stEndDate    = Datetime.newInstance(clsTerm.Start_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM');  
                        if(clsTerm.End_Date__c != null)
                            tm.stEndDate    += ' - '+Datetime.newInstance(clsTerm.End_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM yyyy');
                        
                        cw.termList.add(tm);
                    }
                }
                if(cw.termList.size() > 0){
                    counter = counter + 1; 
                    cw.recNo = counter;  
                    cwList.add(cw); 
                }            
            }
            system.debug('cls.Class_Sessions__r'+cls.Class_Sessions__r);
            //system.debug('cls.Class_Sessions__r.size()'+cls.Class_Sessions__r.size());
            if(cls.Class_Sessions__r.size() > 0){
                Map<String,List<ClassSessionWrapper>> dayOfWeekMap = new Map<String,List<ClassSessionWrapper>>();
                for(Class_Session__c csObj : cls.Class_Sessions__r){
                    ClassSessionWrapper clsSessObjWrap = new ClassSessionWrapper();
                    clsSessObjWrap.id = csObj.Id;
                    clsSessObjWrap.enrollments = csObj.Enrollments__c;
                    clsSessObjWrap.type = csObj.Type__c;
                    clsSessObjWrap.teacherName = csObj.Teacher__r.name;
                    clsSessObjWrap.startTime = csObj.Start_Time__c;
                    clsSessObjWrap.endTime = csObj.End_Time__c;
                    clsSessObjWrap.seatsLeft = csObj.Seats_Left__c;
                    clsSessObjWrap.dayOfWeek= csObj.Day_of_Week__c;   
                    if(dayOfWeekMap.containsKey(csObj.Day_of_Week__c)){
                        List<ClassSessionWrapper> clsSessionList = dayOfWeekMap.get(csObj.Day_of_Week__c);
                        clsSessionList.add(clsSessObjWrap);
                        dayOfWeekMap.put(csObj.Day_of_Week__c,clsSessionList);
                    }else{
                        dayOfWeekMap.put(csObj.Day_of_Week__c,new List<ClassSessionWrapper>{clsSessObjWrap});
                    }
                   
                    // cw.classSessionWrapperList.add(clsSessObjWrap);                 
                }
                if(dayOfWeekMap.size() > 0){
                    for(String mapObj : dayOfWeekMap.keySet()){
                        DayOfWeekWrapper dayObj = new DayOfWeekWrapper();
                        dayObj.nameOfDay = mapObj;
                        dayObj.classSessionWrapperList.addAll(dayOfWeekMap.get(mapObj));
                        Decimal numberOfEnrollments = 0;
                        for(ClassSessionWrapper csWObj: dayOfWeekMap.get(mapObj)){
                            if(csWObj.enrollments != null){
                                numberOfEnrollments += csWObj.enrollments;
                            }
                        }
                        dayObj.csTotEnrollment = numberOfEnrollments;
                        cw.dayOfWeekClsList.add(dayObj);
                    }
                }

            }
        }
        crsFeeWrap.classWrapperList.addAll(cwList);
        return crsFeeWrap;
    }
	
    @AuraEnabled
    public static List<ParentFeeWrapper> fetchFessDetail(String classSessionId){
        if(String.isNotBlank(classSessionId)){
            List<Class_Session__c> clsList = [SELECT Id, Class__r.Course__c FROM Class_Session__c WHERE Id=: classSessionId];
            if(clsList.size() > 0){
              	Map<String, ParentFeeWrapper> mapOfFee = new Map<String, ParentFeeWrapper>();         
                for(Course_Fee__c courseObj : [SELECT Id, Fee__c, Fee__r.Type__c, Fee__r.Amount__c, Fee__r.Unit_Price__c, Fee__r.Name,
                                               Fee__r.RecordType.Name 
                                               FROM Course_Fee__c 
                                               WHERE Course__c =: clsList[0].Class__r.Course__c]){
                                                   ParentFeeWrapper parentFeeObj = new ParentFeeWrapper();                                                        
                                                   parentFeeObj.parentFeeId = courseObj.Fee__c;
                                                   parentFeeObj.parentFeeName = courseObj.Fee__r.Name;
                                                   parentFeeObj.parentFeeType = courseObj.Fee__r.Type__c;
                                                   parentFeeObj.parenTtutionFeeUnitPrice = courseObj.Fee__r.Unit_Price__c;
                                                   parentFeeObj.parentAmount = courseObj.Fee__r.Amount__c;
                                                   mapOfFee.put(courseObj.Fee__c, parentFeeObj);
                }                
                For(Fee__c feeObj : [SELECT Id, Name,Type__c, Amount__c, Frequency__c, Unit_Price__c, Parent__c, RecordType.Name, Units__c, GST_Applicable__c
                                     FROM Fee__c WHERE Parent__c =: mapOfFee.keySet()]){                                        
                                         if(mapOfFee.containsKey(feeObj.Parent__c)){
                                             FeeWrapper fw = new FeeWrapper();
                                             fw.feeId      = feeObj.Id;
                                             fw.feeName    = feeObj.Name;
                                             fw.feeType    = feeObj.Type__c;
                                             fw.payFrequency = feeObj.Frequency__c;  
                                             fw.feeAmount   = feeObj.Amount__c;                       
                                             fw.noOfUnit    = feeObj.Unit_Price__c != null ? Integer.valueOf(feeObj.Unit_Price__c) : 0;
                                             fw.isGSTApplicable = feeObj.GST_Applicable__c;
                                             ParentFeeWrapper parentFeeObj = new ParentFeeWrapper(); 
                                             parentFeeObj = mapOfFee.get(feeObj.Parent__c);
                                             parentFeeObj.childFeeWrapper.add(fw);
                                             mapOfFee.put(feeObj.Parent__c,parentFeeObj);
                                         }                     
                }                       
            return mapOfFee.values();
            }
        }   
        return null;
    }

    
    @AuraEnabled
    public static List<DisWrapper> fetchCourseDiscount(String courseId){
        List<DisWrapper> listDiscount  = new List<DisWrapper>();
        try{
            if(String.isNotBlank(courseId)){
                List<Course_Discount__c> listCourseDiscount = CourseDiscountService.getCourseDiscountByCourseId(courseId);
                if(listCourseDiscount.size() > 0){
                    for(Course_Discount__c crsDis: listCourseDiscount){                                
                        Decimal amtVal = 0;
                        if(crsDis.Discount__r.Format__c.equalsIgnoreCase(ConstantClass.amountFormat)){
                            amtVal = crsDis.Discount__r.Value__c;
                        }else if(crsDis.Discount__r.Format__c.equalsIgnoreCase(ConstantClass.percentFormat)){
                            amtVal = crsDis.Discount__r.Value__c;
                        }
                        DisWrapper dw = new DisWrapper();
                        dw.disId      = crsDis.Discount__c;
                        dw.isOverride = crsDis.Discount__r.Override__c;
                        dw.format = crsDis.Discount__r.Format__c;
                        dw.name       = crsDis.Discount__r.Name;
                        dw.amount     = amtVal;
                        dw.type       = crsDis.Discount__r.Type__c;
                        listDiscount.add(dw);
                    }
                }
            }
            return listDiscount;
        }catch(Exception e){
            system.debug('Error-->'+e.getMessage());
        }
        return null;
    }
    
    //This function is used to get class term amount on the bases of class term session and selected course unit price
    @auraEnabled
    public static List<FeeWrapper> fetchClsTermSessionAmount(String clsStr, String tutionFeeWrapperListStr){
        ClassWrapper cls = (ClassWrapper) System.JSON.deserialize(clsStr, ClassWrapper.class);
        List<FeeWrapper> tutionFeeWrapperList = String.isNotBlank(tutionFeeWrapperListStr) ? (List<FeeWrapper>) JSON.deserialize(tutionFeeWrapperListStr,List<FeeWrapper>.class) : new List<FeeWrapper>(); 
        
        tutionFeeWrapperList = new List<FeeWrapper>();
        List<Class__c> clsList = ClassService.getById(new Set<Id>{cls.clsId});
        if(clsList.size() > 0){
            List<Course_Fee__c> listCourseFee = CourseFeeService.getByCourseIdOrType(clsList.get(0).Course__c, ConstantClass.tutionFeeType, clsList.get(0).Frequency__c);
            if(listCourseFee != NULL && listCourseFee.size() > 0){
                for(Course_Fee__c crFee: listCourseFee){
                    FeeWrapper fw = new FeeWrapper();
                    fw.feeId      = crFee.Fee__c;
                    fw.feeName    = crFee.Fee__r.Name;
                    fw.feeType    = crFee.Fee__r.Type__c;
                    fw.payFrequency = crFee.Fee__r.Frequency__c;  
                    fw.feeAmount = crFee.Fee__r.Amount__c;
                    fw.tutionFeeUnitPrice = crFee.Fee__r.Units__c;
                    fw.isOverride = crFee.Fee__r.Override__c;                                                   
                    fw.feeSchType  = crFee.Fee__r.Schedule__c;  
                    fw.noOfUnit    = crFee.Fee__r.Units__c != null ? Integer.valueOf(crFee.Fee__r.Units__c):0;  
                    fw.isGSTApplicable = crFee.Fee__r.GST_Applicable__c;
                    tutionFeeWrapperList.add(fw);  
                }
            }
        }                            
        
        return tutionFeeWrapperList;
    }
    
    //This function is used to Edis selected courses, So in this we were fetching all course and class details
    @auraEnabled
    public static CourseFeeWrapper editCrsClsDetails(String cfStr){
        CourseFeeWrapper cf = (CourseFeeWrapper) System.JSON.deserialize(cfStr, CourseFeeWrapper.class);
        
        CourseFeeWrapper crsFeeWrap = cf;
        
        
        String clsId = cf.slcdClsWrapObj.clsId;
        crsFeeWrap.classWrapperList     = new List<ClassWrapper>();
        
        List<ClassWrapper> cwList = new List<ClassWrapper>();
        if(String.isNotBlank(clsId)){
            Set<String> slcdFee = new Set<String>();
            
            for(FeeWrapper fw : crsFeeWrap.tutionFeeWrapperList){
                slcdFee.add(fw.feeId);
            }
            for(FeeWrapper fw : crsFeeWrap.depositWrapperList){
                slcdFee.add(fw.feeId);
            }
            for(FeeWrapper fw : crsFeeWrap.feeWrapperList){
                slcdFee.add(fw.feeId); 
            }
            
            List<Class__c> clsList = ClassService.getById(new Set<Id>{clsId});
            if(clsList.size() > 0){
                String   crId= clsList.get(0).Course__c;
                List<Course_Fee__c> listCourseFee = CourseFeeService.getByCourseId(crId);
                
                if(listCourseFee != NULL && listCourseFee.size() > 0){
                    for(Course_Fee__c crFee: listCourseFee){
                        FeeWrapper fw = new FeeWrapper();
                        fw.feeId      = crFee.Fee__c;                         
                        fw.feeName    = crFee.Fee__r.Name;
                        fw.feeType    = crFee.Fee__r.Type__c;
                        fw.payFrequency = crFee.Fee__r.Frequency__c;  
                        fw.feeAmount  = crFee.Fee__r.Amount__c;
                        fw.isSelected = crFee.Fee__r.Required__c;
                        fw.isGSTApplicable = crFee.Fee__r.GST_Applicable__c;
                        fw.feeSchType = crFee.Fee__r.Schedule__c;  
                        fw.noOfUnit   = crFee.Fee__r.Units__c != null ? Integer.valueOf(crFee.Fee__r.Units__c):0;   
                        
                        if(crFee.Fee__r.Type__c == ConstantClass.tutionFeeType){
                            fw.isSelected = false;
                            if(!slcdFee.contains(crFee.Fee__c) &&  crFee.Fee__r.Frequency__c ==clsList.get(0).Frequency__c)
                                crsFeeWrap.tutionFeeWrapperList.add(fw);
                        }else if(crFee.Fee__r.Type__c == ConstantClass.depositFeeType){       
                            if(fw.isSelected)
                                fw.isOverride = true;                
                            if(!slcdFee.contains(crFee.Fee__c))
                                crsFeeWrap.depositWrapperList.add(fw);
                        }else{
                            if(fw.isSelected)
                                fw.isOverride = true;
                            if(!slcdFee.contains(crFee.Fee__c))
                                crsFeeWrap.feeWrapperList.add(fw);
                        }   
                    }
                }
                
                Integer counter = 0;      
                for(Class__c cls: ClassService.getByCourseIdAlongWithClassTerms(crId)){  
                    ClassWrapper cw = new ClassWrapper();
                    cw.clsId        = cls.Id;                  
                    cw.clsName      = cls.Name;
                    cw.clsDays      = cls.Days_of_Week__c;     
                    cw.clsType      = cls.Type__c;   
                    cw.clsFrequency	= cls.Frequency__c;
                    cw.locationId   = cls.Location__c;
                    cw.location     = cls.Location__r.Name;
                    cw.teacherName  = cls.Teacher__r.Name;
                    cw.seatsAlv     = cls.Seats_Available__c != null ? Integer.valueOf(cls.Seats_Available__c) : 0;
                    if(cls.Id == clsId)                  
                        cw.isSelected = true;                
                    if(cls.Start_Time__c != null)
                        cw.stEndTime= Datetime.newInstance(System.today(), cls.Start_Time__c).format('hh:mm a');
                    if(cls.End_Time__c != null)
                        cw.stEndTime += ' - '+ Datetime.newInstance(System.today(), cls.End_Time__c).format('hh:mm a');    
                    
                    
                    //For Monthly classes        
                    if(cls.Frequency__c.equalsIgnoreCase(ConstantClass.monthlyFrequency)){        
                        counter  = counter + 1;     
                        cw.recNo = counter;               
                        cwList.add(cw);     
                    }else{//For fixed Term and fixed classes                 
                        for(Class_Term__c clsTerm : cls.Class_Terms__r){
                            if(clsTerm.End_Date__c >= System.today()){
                                TermWrapper tm = new TermWrapper();
                                tm.clsTermId = clsTerm.Id;
                                tm.clsTermName = clsTerm.Name;
                                if(clsTerm.Start_Date__c != null)
                                    tm.stEndDate    = Datetime.newInstance(clsTerm.Start_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM');  
                                if(clsTerm.End_Date__c != null)
                                    tm.stEndDate    += ' - '+Datetime.newInstance(clsTerm.End_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM yyyy');
                                
                                cw.termList.add(tm);
                            }
                        }
                        if(cw.termList.size() > 0){
                            counter = counter + 1; 
                            cw.recNo = counter;  
                            cwList.add(cw); 
                        }
                    }
                }
            }
        }
        crsFeeWrap.classWrapperList.addAll(cwList);
        
        return crsFeeWrap;
    }
    
    //This function is used to get Early bird discount, If any avaialble on selected course
    @auraEnabled
    public static List<DisWrapper> checkEarlyBirdDiscount(String clsWrapStr){ 
        ClassWrapper clsWrap = (ClassWrapper) System.JSON.deserialize(clsWrapStr, ClassWrapper.class);
        List<DisWrapper> disWrapList = new List<DisWrapper>();
        /* if(isCourseFeeAccessible && isClassAccessible && isDiscountAccessible && isCourseDiscAccessible){
if(String.isNotBlank(clsWrap.clsId)){
List<Class__c> clsList = [SELECT Id, Name, Start_Date__c, Course__c FROM Class__c WHERE Id =:clsWrap.clsId AND Start_Date__c != null];

if(clsList.size() > 0){
Class__c cls = clsList.get(0);

Integer diffInDays = System.today().daysBetween(cls.Start_Date__c);
for(Course_Discount__c crsDis: [SELECT Id, Name, Discount__c, Discount__r.Name, Discount__r.Days_Before_Class__c, Discount__r.Value__c, Discount__r.Override__c, Discount__r.Required__c,
Discount__r.Type__c, Discount__r.Format__c, Discount__r.Start_Date__c, Discount__r.End_Date__c 
FROM Course_Discount__c 
WHERE Course__c =:cls.Course__c AND Discount__r.Days_Before_Class__c != null AND Discount__r.Format__c != null AND
Discount__r.Active__c = True AND Discount__r.Value__c != null AND Discount__r.Type__c =:ConstantClass.earlyBirdDiscount]){

if(diffInDays >= crsDis.Discount__r.Days_Before_Class__c){ 
Decimal amtVal = 0;
if(crsDis.Discount__r.Format__c.equalsIgnoreCase(ConstantClass.amountFormat)){
amtVal = crsDis.Discount__r.Value__c;
}else if(crsDis.Discount__r.Format__c.equalsIgnoreCase(ConstantClass.percentFormat)){
//  amtVal = crsDis.Discount__r.Value__c;
}

DisWrapper dw = new DisWrapper();
dw.disId      = crsDis.Discount__c;
dw.isSelected = crsDis.Discount__r.Required__c;
dw.isOverride = crsDis.Discount__r.Override__c;
dw.name       = crsDis.Discount__r.Name;
dw.amount     = amtVal;
dw.type       = crsDis.Discount__r.Type__c;
disWrapList.add(dw);
}
}
}
}
}*/
        return disWrapList;
    }
    
    //This function is used to fetch other discount which configured globally
    @auraEnabled
    public static List<DisWrapper> fetchOtherDiscount(){ 
        List<DisWrapper> disWrapList = new List<DisWrapper>();
        List<DisWrapper> refDisWrapList  = new List<DisWrapper>();
        List<DisWrapper> proDisWrapList  = new List<DisWrapper>();
        List<DisWrapper> othrDisWrapList = new List<DisWrapper>();
        
        
        for(Discount__c dis: DiscountService.getAllGlobalDiscounts()){
            DisWrapper dw = new DisWrapper();
            if(dis.Format__c.equalsIgnoreCase(ConstantClass.amountFormat)){
                dw.amount = dis.Value__c;
            }else if(dis.Format__c.equalsIgnoreCase(ConstantClass.percentFormat)){
                //  dw.amount = dis.Value__c;
            }  
            dw.disId   = dis.Id;                
            dw.name    = dis.Name;
            dw.format  = dis.Format__c;
            dw.isOverride = dis.Override__c;
            dw.type    = dis.Type__c;
            if(dw.type.equalsIgnoreCase(ConstantClass.referralType)){
                refDisWrapList.add(dw);
            }else if(dw.type.equalsIgnoreCase(ConstantClass.promoType)){
                dw.promoCode = dis.Code__c;
                proDisWrapList.add(dw);
            }else if(dw.type.equalsIgnoreCase(ConstantClass.discountType)){
                othrDisWrapList.add(dw);   
            }
        }
        
        if(refDisWrapList.size() > 0)
            disWrapList.addAll(refDisWrapList); 
        if(proDisWrapList.size() > 0)
            disWrapList.addAll(proDisWrapList); 
        if(othrDisWrapList.size() > 0)
            disWrapList.addAll(othrDisWrapList); 
        
        return disWrapList;
    }
    
    //This function is used to calculate prorated amount on the bases of enrollment date when user click on save button on class model
    @auraEnabled
    public static CourseFeeWrapper calculateProratedAmount(String slcdCrsObjStr){ 
        CourseFeeWrapper slcdCrsObj = (CourseFeeWrapper) System.JSON.deserialize(slcdCrsObjStr, CourseFeeWrapper.class);
        
        if(slcdCrsObj != null && slcdCrsObj.enrolDate != null
           && slcdCrsObj.slcdClsWrapObj != null && slcdCrsObj.slcdClsWrapObj.fees > 0){
               
               FeeWrapper fwT = new FeeWrapper();
               System.debug('fee-->>'+ slcdCrsObj.tutionFeeWrapperList);
               for(FeeWrapper twTemp: slcdCrsObj.tutionFeeWrapperList){
                   if(twTemp.isSelected)
                       fwT = twTemp;
               }  
               
               slcdCrsObj.tutionFeeWrapperList = new List<FeeWrapper>();
               slcdCrsObj.tutionFeeWrapperList.add(fwT);
               
               
               FeeWrapper fw = slcdCrsObj.tutionFeeWrapperList[0];
               slcdCrsObj.slcdClsWrapObj.slctClsTermId = '';
               slcdCrsObj.slcdClsWrapObj.slctclsTermName = '';
               
               Date tempDt = slcdCrsObj.enrolDate;   
               
               //Fetch selected class
               List<Class__c> clsList = ClassService.getByIdAlongWithEnrolDate(slcdCrsObj.slcdClsWrapObj.clsId,tempDt);
               
               Class_Term__c clsTerm = new Class_Term__c();
               if(clsList[0].Class_Terms__r.size() > 0){
                   //get specifi class term according to the selected enrolment date
                   for(Class_Term__c clsTermTemp: clsList[0].Class_Terms__r){
                       if(clsTermTemp.Start_Date__c <= tempDt && tempDt < clsTermTemp.End_Date__c){
                           clsTerm = clsTermTemp;
                           slcdCrsObj.slcdClsWrapObj.slctClsTermId   = clsTermTemp.Id;
                           slcdCrsObj.slcdClsWrapObj.slctclsTermName = clsTermTemp.Name;
                           break;
                       }
                   }    
                   //Check if no class term avaialble according to the enrolment date, Then check next term
                   if(clsTerm.Id == null){
                       for(Class_Term__c clsTermTemp: clsList[0].Class_Terms__r){
                           if(clsTermTemp.End_Date__c > tempDt){
                               clsTerm = clsTermTemp;
                               slcdCrsObj.slcdClsWrapObj.slctClsTermId   = clsTermTemp.Id;
                               slcdCrsObj.slcdClsWrapObj.slctclsTermName = clsTermTemp.Name;
                               break;
                           }
                       } 
                   }    
               }
               
               //Fetch selected tution fee for prorated amount
               List<Fee__c> feeList   = FeeService.getFeeById(fw.feeId);
               system.debug('feeList-->'+feeList);
               system.debug('clsList-->'+clsList);
               if(clsList.size() > 0 && feeList.size() > 0){
                   Class__c cls          = clsList.get(0);                 
                   Fee__c   fee          = feeList.get(0);
                   Integer noOfLessInCurrMonth = 0;
                   
                   //Calculate prorated number of lesson for month type class on the bases of selected date
                   //Fetch number of remaining session on the bases of term selected
                   if(clsTerm.Id != null){
                       List<Session__c> sessList  = SessionService.getByClassTermIdAlongWithEnrolDate(clsTerm.Id,tempDt);  
                       noOfLessInCurrMonth = sessList.size();
                       System.debug('@@--->'+clsTerm.Id );
                       System.debug('@@--->'+sessList.size());
                   }
                   System.debug('@@--->'+noOfLessInCurrMonth);
                   Decimal packFee = fee.Unit_Price__c * noOfLessInCurrMonth;
                   System.debug('condition-->'+cls.Frequency__c + ' '+fee.Units__c +' '+ noOfLessInCurrMonth+' ' + fee.Units__c);
                   
                   
                   if(cls.Frequency__c == ConstantClass.monthlyFrequency && fee.Units__c != Null && noOfLessInCurrMonth > fee.Units__c)
                       packFee = fee.Unit_Price__c * Integer.valueOf(fee.Units__c);
                   fw.feeProratedAmount = packFee;
               }                           
               slcdCrsObj.tutionFeeWrapperList[0] = fw; 
           }
        
        return slcdCrsObj;
    }
    
    @auraEnabled
    public static List<FeeWrapper> getRelatedFeeApex(String feeId){
        List<FeeWrapper> listFeeWrapper = new List<FeeWrapper>();
        if(String.isNotBlank(feeId)){
            List<Fee__c> listRelatedFee = FeeService.getRelatedFeeById(feeId);
            if(listRelatedFee != NULL && listRelatedFee.size() > 0){
                for(Fee__c rFee : listRelatedFee){
                    FeeWrapper fw = new FeeWrapper();
                    fw.feeId      = rFee.Id;
                    fw.feeName    = rFee.Name;
                    fw.feeType    = rFee.Type__c;
                    fw.payFrequency = rFee.Frequency__c;  
                    fw.feeAmount   = rFee.Amount__c;
                    fw.feeSchType  = rFee.Schedule__c;  
                    fw.noOfUnit    = rFee.Units__c != null ? Integer.valueOf(rFee.Units__c):0;
                    fw.feeParent   = rFee.Parent__c;
                    fw.isSelected  = rFee.Required__c;
                    if(fw.isSelected)
                        fw.isOverride  = true;
                    fw.isGSTApplicable = rFee.GST_Applicable__c;
                    listFeeWrapper.add(fw);
                }
            }
        }
        system.debug('listFeeWrapper-->'+listFeeWrapper);
        return listFeeWrapper;
    }
    
    //This function is used to get dynmically picklist values of the object
    
    @auraEnabled (cacheable =true)
    public static List<String> getPicklistValues(String ObjectApi_name, String Field_name){ 
        return UtilityClass.getPickValues(ObjectApi_name, Field_name);
    }
    
    //This function is used to save and complete the whole enrolment process.
    @auraEnabled
    public static String doSaveApex(String parAccStr,String secondaryContactDetail, String slctdEnrolmentsStr, String globalDisListStr, Decimal totPayAmt, String refNo, String payMode,String btnLabel,String paymentComments){
        System.debug('secondaryContactDetail-->'+secondaryContactDetail);
        System.debug('payMode-->'+payMode);
        Account parAcc = (Account) System.JSON.deserialize(parAccStr, Account.class);
        Account secondaryAcc = (Account) JSON.deserialize(secondaryContactDetail, Account.class);
        System.debug('parAcc-->'+parAcc);
        List<CustomerWrapper> slctdEnrolments = String.isNotBlank(slctdEnrolmentsStr) ? (List<CustomerWrapper>) JSON.deserialize(slctdEnrolmentsStr,List<CustomerWrapper>.class) : new List<CustomerWrapper>(); 
        List<DisWrapper> globalDisList = String.isNotBlank(globalDisListStr) ? (List<DisWrapper>) JSON.deserialize(globalDisListStr,List<DisWrapper>.class) : new List<DisWrapper>();
        
        Boolean isAccountCreatableAccessible = FieldPremissionCrudUtility.checkReadPermission('Account',new Set<String>{
            'RecordTypeId', 'FirstName', 'LastName', 'PersonEmail','Phone','Block__c','Unit__c','BillingStreet',
                'BillingPostalCode', 'BillingCountry', 'Gender__c', 'PersonBirthdate','Relationship_with_contact__c'},
                                                                                              true,false);
        Boolean isEnrollmentAccessible = FieldPremissionCrudUtility.checkReadPermission('Enrollment__c',  
                                                                                        new Set<String>{'Location__c', 'Start_Date__c','Parent__c','Student__c','Stage__c','Status__c','Enrollment_Date__c',
                                                                                            'Parent_Email__c','Comments__c','Terms_and_Conditions__c','Referred_By__c'},true,false);
        Boolean isStudentSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Student_Session__c',  
                                                                                            new Set<String>{'Account__c', 'Session__c', 'Enrollment__c','Status__c','Billable__c'},true,false);
        Boolean isInvLnItmAccessible = FieldPremissionCrudUtility.checkReadPermission('Invoice_Line_Item__c',  
                                                                                      new Set<String>{'Enrollment__c', 'Subscription_Line_Item__c','Fee__c','Discount__c','Type__c','Amount__c'},true,false);
        String strMsg = 'Success';
        Savepoint sp;
        try{  /*
            sp = Database.setSavepoint();
            Account cstmrAlreadyAvl = new Account();
            Account familyAccount = new Account();
            List<AccountContactRelation> listAccountContactRelation = new List<AccountContactRelation>(); 
            Set<String> setAccountId = new Set<String>();            
            String recTypeId = ConstantClass.customerRecTypeId;
            String primaryRelationShip = '';
            String secondaryRelationship = '';
            Map<String,String> mapBillingCoutryLabelToBillingCountryValue = new Map<String,String>();
            Schema.sObjectType objType = Schema.getGlobalDescribe().get('Account').newSObject().getSObjectType();
            Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
            
            for(Schema.PicklistEntry ple : objFieldMap.get('BillingCountryCode').getDescribe().getPicklistValues()){
                mapBillingCoutryLabelToBillingCountryValue.put(ple.getLabel(),ple.getValue());
            }
            
            system.debug('mapBillingCoutryLabelToBillingCountryValue-->'+mapBillingCoutryLabelToBillingCountryValue);
            if(String.isBlank(parAcc.Id) && String.isNotBlank(parAcc.PersonEmail)){
                parAcc.RecordTypeId = recTypeId;
                List<Account> accList = AccountService.getAccountByEmailId(parAcc.PersonEmail);
                if(accList.size() > 0){
                    cstmrAlreadyAvl = accList.get(0);
                    parAcc.Id = cstmrAlreadyAvl.Id;
                }
            }else if(String.isBlank(parAcc.Id) && String.isBlank(parAcc.PersonEmail)){
                parAcc.RecordTypeId = ConstantClass.corporateRecTypeId;
            }
            if(String.isNotBlank(parAcc.educato__Relationship_With_Student__c))
                primaryRelationShip = parAcc.educato__Relationship_With_Student__c;
            if(String.isNotBlank(parAcc.BillingCountryCode) && mapBillingCoutryLabelToBillingCountryValue.keySet().size() > 0 && 
              mapBillingCoutryLabelToBillingCountryValue.containsKey(parAcc.BillingCountryCode))
                parAcc.BillingCountryCode = mapBillingCoutryLabelToBillingCountryValue.get(parAcc.BillingCountryCode);
            parAcc = AccountService.upsertAccountRecords(new List<Account>{parAcc})[0];
            setAccountId.add(parAcc.Id);
            
            if(String.isNotBlank(secondaryAcc.LastName)){            
                if(String.isBlank(secondaryAcc.Id) && String.isNotBlank(secondaryAcc.PersonEmail)){
                    secondaryAcc.RecordTypeId = recTypeId;
                    //secondaryAcc.Primary_Account__c = parAcc.Id;
                    List<Account> accList = AccountService.getAccountByEmailId(secondaryAcc.PersonEmail);
                    if(accList.size() > 0){
                        cstmrAlreadyAvl = accList.get(0);
                        secondaryAcc.Id = cstmrAlreadyAvl.Id;
                    }
                }
                if(String.isNotBlank(secondaryAcc.educato__Relationship_With_Student__c))
                    secondaryRelationship = secondaryAcc.educato__Relationship_With_Student__c;
                secondaryAcc = AccountService.upsertAccountRecords(new List<Account>{secondaryAcc})[0];
                setAccountId.add(secondaryAcc.Id);
            }
            
            Map<String, List<Session__c>> clsSessonMap  = new Map<String, List<Session__c>>();
            Map<String, Class_Term__c> slcdClsTermMap   = new Map<String, Class_Term__c>();
            String locationId = '';
            for(CustomerWrapper cw: slctdEnrolments){
                for(CourseFeeWrapper crsWrap : cw.slctdClsDetails){
                    ClassWrapper slcdClsWrap = crsWrap.slcdClsWrapObj;
                    system.debug('slcdClsWrap.slctClsTermId-->'+slcdClsWrap.slctClsTermId);
                    system.debug('slcdClsWrap.clsId-->'+slcdClsWrap.clsId);
                    clsSessonMap.put(slcdClsWrap.slctClsTermId, null);
                    clsSessonMap.put(slcdClsWrap.clsId, null);
                    
                    if(String.isNotBlank(slcdClsWrap.slctClsTermId))
                        slcdClsTermMap.put(slcdClsWrap.clsId, null);
                    if(String.isBlank(locationId))
                        locationId = slcdClsWrap.locationId;
                }
            }
            
            //Fill invoice
            Invoice__c inv = UtilityClass.fillInvoice(parAcc.Id,locationId, null, ConstantClass.newEnrollmentInvType,
                                                      (String.isNotBlank(btnLabel) && btnLabel.equalsIgnoreCase('Confirm') ? 
                                                       ConstantClass.paidStatus : ConstantClass.dueStatus));
            inv = InvoiceService.insertInvoiceRecords(new List<Invoice__c>{inv})[0];
            
            if(clsSessonMap.keySet().size() > 0){
                for(Session__c sess: SessionService.getByClassTermIdAlongWithClassId(clsSessonMap.keySet())){
                    //For term or fixed based sessions                        
                    if(sess.Class_Term__c != null){
                        if(clsSessonMap.containsKey(sess.Class_Term__c)){
                            List<Session__c> sessList = clsSessonMap.get(sess.Class_Term__c);
                            sessList = sessList != null ? sessList : new List<Session__c>();
                            sessList.add(sess);
                            clsSessonMap.put(sess.Class_Term__c, sessList);
                            
                            if(slcdClsTermMap.get(sess.Class__c) == null){
                                slcdClsTermMap.put(sess.Class__c, new Class_Term__c(Id = sess.Class_Term__c,Name = sess.Class_Term__r.Name,
                                                                                    Sequence__c = sess.Class_Term__r.Sequence__c, 
                                                                                    Start_Date__c = sess.Class_Term__r.Start_Date__c, 
                                                                                    End_Date__c = sess.Class_Term__r.End_Date__c));
                            }
                        }
                    }else{//For monthly sessions
                        List<Session__c> sessList = clsSessonMap.get(sess.Class__c);
                        sessList = sessList != null ? sessList : new List<Session__c>();
                        sessList.add(sess);
                        
                        clsSessonMap.put(sess.Class__c, sessList);
                    }
                }                                                  
            }
            
            System.debug('@@@@clsSessonMap   '+clsSessonMap);
            //find next class term
            Map<String, Class_Term__c> nextClassTermMap = new Map<String, Class_Term__c>();
            if(slcdClsTermMap.keySet().size() > 0){
                for(Class__c cls: ClassService.getByIdAlongWithStartDate(slcdClsTermMap.keySet())){
                    if(slcdClsTermMap.get(cls.Id) != null){
                        Class_Term__c slcdClsTerm = slcdClsTermMap.get(cls.Id);
                        for(Class_Term__c clsTerm : cls.Class_Terms__r){
                            if(clsTerm.Start_Date__c > slcdClsTerm.Start_Date__c){
                                nextClassTermMap.put(cls.Id, clsTerm);
                                break;
                            }       
                        }
                    }
                }
            }
            
            List<Account>                   stuList   = new List<Account>();
            List<Enrollment__c>             enrList   = new List<Enrollment__c>();
            List<Class__c> listClass = new List<Class__c>();
            List<Student_Session__c> stuSessList = new List<Student_Session__c>();
            List<Invoice_Line_Item__c> invLnItms = new List<Invoice_Line_Item__c>();
            for(CustomerWrapper cw: slctdEnrolments){
                Account stuDet = cw.studentDetails;
                stuDet.RecordTypeId = recTypeId;
                if(String.isNotBlank(stuDet.Relationship_with_contact__c) && stuDet.Relationship_with_contact__c.equalsIgnoreCase('Self')){
                    stuDet.Id = parAcc.Id;              
                }else{
                    stuDet.Parent__c = parAcc.Id;
                }
                
                if(String.isBlank(stuDet.Id)){
                    String tempName = stuDet.FirstName+' '+stuDet.LastName+' '+stuDet.PersonBirthDate;
                    for(Account exisStu: cstmrAlreadyAvl.Students__r){
                        String existingStu = exisStu.FirstName+' '+exisStu.LastName+' '+exisStu.PersonBirthDate;
                        if(tempName.equalsIgnoreCase(existingStu)){
                            stuDet.Id = exisStu.Id;
                            break;
                        }
                    }
                }
                
                stuList.add(stuDet);
                for(CourseFeeWrapper crsWrap : cw.slctdClsDetails){
                    ClassWrapper slcdClsWrap = crsWrap.slcdClsWrapObj;
                    
                    FeeWrapper slcdTutionFee = new FeeWrapper();
                    if(crsWrap.tutionFeeWrapperList.size() > 0)
                        slcdTutionFee = crsWrap.tutionFeeWrapperList.get(0);
                    
                    Enrollment__c enr  = UtilityClass.fillEnrollment(parAcc.Id, slcdClsWrap.locationId, slcdClsWrap.clsId, crsWrap.enrolDate,ConstantClass.enrollmentStage,
                                                                     ConstantClass.draftStatus);
                    enr.Parent_Email__c= parAcc.PersonEmail;
                    enr.Student__r     = stuDet;
                    enr.Comments__c    = crsWrap.comments;
                    enr.Terms_and_Conditions__c = true;
                    enr.Type__c = slcdTutionFee.feeSchType;
                    system.debug('crsWrap.enrolEndDate-->'+crsWrap.enrolEndDate);
                    enr.Enrollment_End_Date__c = (crsWrap.enrolEndDate != NULL ? crsWrap.enrolEndDate : null);
                    enrList.add(enr);
                    
                    //System.debug('@@@@nextSchDt  '+slcdClsWrap.clsType);
                    //Insert subscription line items
                    if(slcdClsWrap.clsType.equalsIgnoreCase(ConstantClass.ongoingClsType) && 
                       crsWrap.tutionFeeWrapperList.size() > 0 && 
                       !(slcdTutionFee.payFrequency.equalsIgnoreCase(ConstantClass.oneTimeFrequency))){
                           //Added on 27th May 2020
                           Boolean isNeedToCheckStuSess = False;
                           Integer noOfSess = 0;
                           if(String.isNotBlank(slcdTutionFee.feeSchType) && slcdTutionFee.feeSchType.equalsIgnoreCase(ConstantClass.fixedType))
                               isNeedToCheckStuSess = true;
                           
                           //Filling student session records for term frequency 
                           if(clsSessonMap.containskey(slcdClsWrap.slctClsTermId) && clsSessonMap.get(slcdClsWrap.slctClsTermId) != NULL){
                               for(Session__c sess : clsSessonMap.get(slcdClsWrap.slctClsTermId)){
                                   if(sess.Session_Date__c >= crsWrap.enrolDate){
                                       Student_Session__c stuSess = new Student_Session__c();
                                       stuSess.Account__r   = stuDet;
                                       stuSess.Session__c   = sess.Id;
                                       stuSess.Enrollment__r= enr;
                                       stuSess.Status__c= (String.isNotBlank(btnLabel) && btnLabel.equalsIgnoreCase('Confirm') ? ConstantClass.ScheduledStatus : ConstantClass.draftStatus);
                                       stuSess.Billable__c= true;
                                       stuSessList.add(stuSess); 
                                       noOfSess = noOfSess+1;
                                       if(isNeedToCheckStuSess && slcdTutionFee.noOfUnit < noOfSess)
                                           break;
                                   }
                               }
                           }else{
                               system.debug('Class Terms or Sessions not found for the selected class');
                               return 'Class Terms or Sessions not found for the selected class';
                           }
                       }else if(slcdClsWrap.clsType.equalsIgnoreCase(ConstantClass.fixedType) || slcdTutionFee.payFrequency.equalsIgnoreCase(ConstantClass.oneTimeFrequency)){
                           //Filling student session records for fixed course
                           system.debug('slcdClsWrap.slctClsTermId==>'+slcdClsWrap.slctClsTermId);
                           system.debug('clsSessonMap-->'+clsSessonMap);
                           if(clsSessonMap.get(slcdClsWrap.slctClsTermId) != null){
                               for(Session__c sess : clsSessonMap.get(slcdClsWrap.slctClsTermId)){
                                   if(sess.Session_Date__c >= crsWrap.enrolDate){
                                       Student_Session__c stuSess = new Student_Session__c();
                                       stuSess.Account__r   = stuDet;
                                       stuSess.Session__c   = sess.Id;
                                       stuSess.Enrollment__r= enr;
                                       stuSess.Status__c= (String.isNotBlank(btnLabel) && btnLabel.equalsIgnoreCase('Confirm') ? ConstantClass.ScheduledStatus : ConstantClass.draftStatus);
                                       stuSess.Billable__c= True;
                                       stuSessList.add(stuSess);   
                                   }
                               }
                           }
                       }
                    
                    //Class End date updation with Last Session's Date 
                    if(slcdClsWrap.clsType.equalsIgnoreCase(ConstantClass.fixedType)){
                        if(String.isNotBlank(slcdClsWrap.slctClsTermId)){
                            if(clsSessonMap.get(slcdClsWrap.slctClsTermId) != null){
                                List<Session__c> sessList = clsSessonMap.get(slcdClsWrap.slctClsTermId);
                                Class__c cls = new Class__c();
                                cls.Id = slcdClsWrap.clsId;
                                cls.End_Date__c = sessList[sessList.size() - 1].Session_Date__c; 
                                listClass.add(cls);
                            }  
                        }
                    }                         
                    
                    //Invoice line items for tution fee
                    for(FeeWrapper fw: crsWrap.tutionFeeWrapperList){
                        Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(inv.Id, null, null, fw.feeId, null, ConstantClass.feeType,
                                                                                     (fw.feeProratedAmount > 0 ? fw.feeProratedAmount : fw.feeAmount) ,
                                                                                     fw.isGSTApplicable);
                        if(slcdClsWrap.clsFrequency.equalsIgnoreCase(ConstantClass.monthlyFrequency)){
                            invLnItm.educato__Name__c = 'Tuition Fee-('+(DateTime.now()).format('MMM')+'-'+Date.today().year()+')';
                        }
                        else if(slcdClsTermMap.keySet().size() > 0){
                            Class_Term__c clsTerm = slcdClsTermMap.get(slcdClsWrap.clsId);
                            Date startDate = clsTerm.educato__Start_Date__c;
                            Date endDate = clsTerm.educato__End_Date__c; 
                            System.debug('startDate-->'+startDate);
                            System.debug('endDate-->'+endDate);
                            invLnItm.educato__Name__c = 'Tuition Fee-('+ clsTerm.Name +'-'+startDate.format()+' To '+endDate.format()+')';
                        }
                        invLnItm.Enrollment__r = enr;
                        invLnItms.add(invLnItm);
                    }
                    
                    //Invoice line items for Other fee
                    for(FeeWrapper fw: crsWrap.feeWrapperList){
                        Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(inv.Id, null, null, fw.feeId, null, ConstantClass.feeType, fw.feeAmount, fw.isGSTApplicable);
                        invLnItm.Enrollment__r = enr;
                        invLnItms.add(invLnItm);
                    }
                    
                    //Invoice line items for Deposit fee
                    for(FeeWrapper fw: crsWrap.depositWrapperList){
                        Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(inv.Id, null, null, fw.feeId, null, ConstantClass.depositFeeType, fw.feeAmount, fw.isGSTApplicable);
                        invLnItm.Enrollment__r = enr;
                        invLnItms.add(invLnItm);
                    }
                    
                    //Invoice line items for other course discount Amount
                    for(DisWrapper dis: crsWrap.disWrapperList){
                        Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(inv.Id, null, null, null, dis.disId, ConstantClass.discountType, dis.amount, true);
                        invLnItm.Enrollment__r = enr;
                        invLnItms.add(invLnItm);
                    }
                    
                    //Invoice line items for earlybird Discount Amount
                    for(DisWrapper dis: crsWrap.earlybirdDisWrapperList){
                        Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(inv.Id, null, null, null, dis.disId, ConstantClass.discountType, dis.amount, true);
                        invLnItm.Enrollment__r = enr;
                        invLnItms.add(invLnItm);
                    }
                    
                }
            }
            //Invoice line items for global Discount Amount
            DisWrapper referralDis;
            system.debug('globalDisList-->'+globalDisList);
            for(DisWrapper dis: globalDisList){
                Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(inv.Id, null, null, null, dis.disId, ConstantClass.discountType, dis.amount, true);
                invLnItms.add(invLnItm);
                
                if(String.isNotBlank(dis.type) && dis.type.equalsIgnoreCase(ConstantClass.referralType)){
                    referralDis = dis;
                }
            }
            system.debug('invLnItms-->'+invLnItms.size());
            //update class
            if(listClass.size() > 0)
                ClassService.updateClassRecords(listClass);
            
            //Upserting Students
            if(isAccountCreatableAccessible){
                if(stuList.size() > 0){
                    upsert stuList;
                    for(Account acc: stuList){
                        setAccountId.add(acc.Id);
                    }
                }
            }else{
                System.debug('Permission issue on Account');
            }  
            System.debug('stuList-->'+stuList);
            
            //Inserting enrollments
            if(isEnrollmentAccessible){
                if(enrList.size() > 0){
                    for(Enrollment__c enr: enrList){
                        enr.Student__c = enr.Student__r.Id;
                        if(referralDis != null)
                            enr.Referred_By__c = referralDis.referralById;
                    }
                    system.debug('enrList-->'+enrList);
                    insert enrList;
                }
            }else{
                System.debug('Permission issue on Enrollment');
            }
            
            //Inserting student session bases of the session term
            if(isStudentSessionAccessible){
                if(stuSessList.size() > 0){
                    for(Student_Session__c stuSess: stuSessList){
                        stuSess.Account__c   = stuSess.Account__r.Id;
                        stuSess.Enrollment__c= stuSess.Enrollment__r.Id;
                    }
                    insert stuSessList;
                } 
            }else{
                System.debug('Permission issue on Student Service');
            }
            
            //Inserting Invoice line items
            if(isInvLnItmAccessible){
                if(invLnItms.size() > 0){
                    for(Invoice_Line_Item__c invItm: invLnItms)
                        invItm.Enrollment__c = invItm.Enrollment__r.Id;
                    insert invLnItms;
                }
            }else{
                System.debug('Permission issue on Invoice Line Item');
            }
            
            //Insert Payment record
            Payment__c payment = UtilityClass.fillPayment(parAcc.Id, inv.Id, (String.isNotBlank(btnLabel) && btnLabel.equalsIgnoreCase('Confirm') ? ConstantClass.paidStatus : ConstantClass.dueStatus),totPayAmt);
            payment.Transaction_Id__c = refNo;
            payment.Cash_Mode__c = payMode;
            payment.Comments__c = paymentComments;
            PaymentService.insertPaymentRecords(new List<Payment__c>{payment});
            
            //Payment credit for referral discount
            if(referralDis != null){
                Payment__c paymentAsCredit = UtilityClass.fillPayment(referralDis.referralById, null, 'Pending' , referralDis.amount);
                paymentAsCredit.Type__c = 'Credit';
                PaymentService.insertPaymentRecords(new List<Payment__c>{paymentAsCredit}); 
            }
            
            if(String.isNotBlank(btnLabel) && btnLabel.equalsIgnoreCase('Confirm') && enrList.size() > 0){
                for(Enrollment__c enrol : enrList){
                    enrol.Status__c = ConstantClass.enrolledStatus;
                }
                EnrollmentService.updateByList(enrList);
                system.debug('enrList-->'+enrList);
            }
            
            if(setAccountId.size() > 0){
                Map<String,String> mapAccIdToPersonAccId = new Map<String,String>();
                for(Account acc : [SELECT Id,PersonContactId FROM Account Where Id IN : setAccountId]) {
                    mapAccIdToPersonAccId.put(acc.Id,acc.PersonContactId);                    
                }
                String parAccPersonContactId = (mapAccIdToPersonAccId.keySet().size() > 0 && mapAccIdToPersonAccId.containsKey(parAcc.Id) 
                                                ? mapAccIdToPersonAccId.get(parAcc.Id) : '');
                String secAccPersonContactId = '';
                if(String.isNotBlank(secondaryAcc.Id)){
                    secAccPersonContactId =   (mapAccIdToPersonAccId.keySet().size() > 0 && mapAccIdToPersonAccId.containsKey(secondaryAcc.Id) 
                                               ? mapAccIdToPersonAccId.get(secondaryAcc.Id) : '');
                }
                System.debug('secAccPersonContactId-->'+secAccPersonContactId);
                if(String.isNotBlank(parAccPersonContactId)){
                    List<AccountContactRelation> listAccountContactRelationToCheck = AccountContactRelationService.getByPrimaryAccountContactId(parAccPersonContactId);
                    System.debug('listAccountContactRelationToCheck-->'+listAccountContactRelationToCheck);
                    if(listAccountContactRelationToCheck == NULL || listAccountContactRelationToCheck.size() == 0){
                        familyAccount.RecordTypeId = ConstantClass.familyAccRecTypeId;
                        familyAccount.Name = parAcc.LastName;
                        familyAccount = AccountService.upsertAccountRecords(new List<Account>{familyAccount})[0];
                        if(mapAccIdToPersonAccId.keySet().size() > 0){
                            for(String perConId : mapAccIdToPersonAccId.values()){
                                AccountContactRelation accConRelation = new AccountContactRelation();
                                accConRelation.AccountId = familyAccount.Id;
                                accConRelation.ContactId = perConId;
                                if(String.isNotBlank(parAccPersonContactId) && parAccPersonContactId == perConId)
                                    accConRelation.Roles = primaryRelationShip;
                                if(String.isNotBlank(secAccPersonContactId) && secAccPersonContactId == perConId)
                                    accConRelation.Roles = secondaryRelationShip;
                                listAccountContactRelation.add(accConRelation);
                            }
                        }
                    }
                    
                    if(listAccountContactRelationToCheck != NULL && listAccountContactRelationToCheck.size() > 0){
                        String familyAccId = listAccountContactRelationToCheck[0].AccountId;
                        List<AccountContactRelation> listFamilyAccountContactRelation = AccountContactRelationService.getByFamilyAccountId(familyAccId);
                        if(listFamilyAccountContactRelation != NULL && listFamilyAccountContactRelation.size() > 0){
                            List<String> listExistingAccConRelation = new List<String>();
                            for(AccountContactRelation accConRel : listFamilyAccountContactRelation){
                                listExistingAccConRelation.add(accConRel.ContactId);    
                            }
                            if(listExistingAccConRelation.size() > 0 && mapAccIdToPersonAccId.keySet().size() > 0){
                                for(String perConId : mapAccIdToPersonAccId.values()){
                                    if(!listExistingAccConRelation.contains(perConId)){
                                        AccountContactRelation accConRelation = new AccountContactRelation();
                                        accConRelation.AccountId = familyAccId;
                                        accConRelation.ContactId = perConId;
                                        if(String.isNotBlank(parAccPersonContactId) && parAccPersonContactId == perConId)
                                            accConRelation.Roles = primaryRelationShip;
                                        if(String.isNotBlank(secAccPersonContactId) && secAccPersonContactId == perConId)
                                            accConRelation.Roles = secondaryRelationShip;
                                        listAccountContactRelation.add(accConRelation);
                                    }
                                }
                            }
                        }
                    }                
                }
                system.debug('listAccountContactRelation-->'+listAccountContactRelation);
                if(listAccountContactRelation.size() > 0)
                    AccountContactRelationService.insertAccountContactRelationRecords(listAccountContactRelation);
            }
            strMsg += '#' + enrList[enrList.size() - 1].Id;*/
        }catch(Exception e){
            Database.rollback(sp);
            System.debug('@@@@ Error:   '+e.getMessage() + e.getLineNumber());
            strMsg = 'Error: '+e.getMessage();
        }
        return strMsg;
    }

    //Its used to find next class term
    public static Map<String, Class_Term__c> getNextClassTerm(List<Subscription_Line_Item__c> subLnItmList){
        Map<String, Class_Term__c> nextClsTermMap = new Map<String, Class_Term__c>();
        
        return nextClsTermMap;
    }
    
    //Its used to initialize blank customer wrapper
    @auraEnabled
    public static CustomerWrapper blankInitializeCstmrWrpr(){
        return new CustomerWrapper();
    }
    
    //This function is used to add blank student on Enrollment page
    @auraEnabled
    public static List<CustomerWrapper> addStudents(List<CustomerWrapper> stuClsWrapperList){
        if(stuClsWrapperList == null)
            stuClsWrapperList = new List<CustomerWrapper>();
        
        stuClsWrapperList.add(new CustomerWrapper());
        return stuClsWrapperList;
    }
    
    public class CustomerWrapper{
        @AuraEnabled public Integer stuRecNo{get;set;}
        @AuraEnabled public Account studentDetails{get;set;}
        @AuraEnabled public List<CourseFeeWrapper> slctdClsDetails{get;set;}
        
        public CustomerWrapper(){
            this.stuRecNo   = stuRecNo;
            studentDetails  = new Account();
            slctdClsDetails = new List<CourseFeeWrapper>();
        }
    }
    
    public class CourseFeeWrapper{
        @AuraEnabled public List<ClassWrapper> classWrapperList{get;set;}
        @AuraEnabled public List<FeeWrapper>   tutionFeeWrapperList{get;set;}
        @AuraEnabled public List<FeeWrapper>   depositWrapperList{get;set;}
        @AuraEnabled public List<FeeWrapper>   feeWrapperList{get;set;}
        @AuraEnabled public List<DisWrapper>   disWrapperList{get;set;}
        @AuraEnabled public List<DisWrapper>   earlybirdDisWrapperList{get;set;}
       
        @AuraEnabled public ClassWrapper slcdClsWrapObj{get;set;}  
        @AuraEnabled public Date         enrolDate{get;set;}
        @AuraEnabled public Date 		 enrolEndDate{get;set;}
        @AuraEnabled public String       comments{get;set;}
        @AuraEnabled public Decimal      totFee{get;set;}
        @AuraEnabled public Decimal      totWithProratedFee{get;set;}
        @AuraEnabled public String       typeAddEdit{get;set;}
        @AuraEnabled public Integer      recNo{get;set;} 
        
        public CourseFeeWrapper(){
            this.classWrapperList = new List<ClassWrapper>();
            this.tutionFeeWrapperList = new List<FeeWrapper>();
            this.depositWrapperList   = new List<FeeWrapper>();
            this.feeWrapperList       = new List<FeeWrapper>();
            this.disWrapperList       = new List<DisWrapper>();
            this.earlybirdDisWrapperList= new List<DisWrapper>();
            this.totFee               = 0 ;
            this.totWithProratedFee   = 0;
            this.enrolDate            = System.today();
            this.enrolEndDate 		  = null;
            this.slcdClsWrapObj       = new ClassWrapper();
            this.typeAddEdit          = 'Add';
           
        }
    }
    
    public class ClassWrapper{
        @AuraEnabled public Integer recNo{get;set;}
        @AuraEnabled public String  clsId{get;set;}
        @AuraEnabled public String  clsName{get;set;}
        @AuraEnabled public String  clsType{get;set;}
        @AuraEnabled public String  clsFrequency{get;set;}
        @AuraEnabled public String  clsDays{get;set;}
        @AuraEnabled public Date    clsEndDate{get;set;}
        @AuraEnabled public String  locationId{get;set;}
        @AuraEnabled public String  location{get;set;}
        @AuraEnabled public String  course;
        @AuraEnabled public Decimal totalEnrollment;
        @AuraEnabled public String  stEndDate{get;set;}
        @AuraEnabled public String  stEndTime{get;set;}
        @AuraEnabled public String  teacherName{get;set;}
        @AuraEnabled public Integer seatsAlv{get;set;}
        @AuraEnabled public Decimal fees{get;set;}
        @AuraEnabled public Boolean isSelected{get;set;}
        
        @AuraEnabled public String  courseId{get;set;}
        @AuraEnabled public String  courseName{get;set;}
        
        @AuraEnabled public String slctClsTermId{get;set;} 
        @AuraEnabled public String slctclsTermName{get;set;}
        
        @AuraEnabled public List<TermWrapper> termList{get;set;}
        @AuraEnabled public List<DayOfWeekWrapper> dayOfWeekClsList;
        public ClassWrapper(){
            this.fees = this.seatsAlv = 0;
            this.isSelected = false;
            this.termList = new  List<TermWrapper>();
            this.dayOfWeekClsList = new List<DayOfWeekWrapper>();
        }
    }
    
    public class TermWrapper{ 
        @AuraEnabled public String clsTermId{get;set;} 
        @AuraEnabled public String clsTermName{get;set;}
        @AuraEnabled public String stEndDate{get;set;}
        
        public TermWrapper(){}
    }
    
    Public class ParentFeeWrapper{
        @AuraEnabled public String  parentFeeId;
        @AuraEnabled public String  parentFeeName;
        @AuraEnabled public String  parentFeeType;
        @AuraEnabled public Decimal parentTutionFeeUnitPrice;
        @AuraEnabled public Decimal parentAmount;
        @AuraEnabled public List<FeeWrapper> childFeeWrapper;
        ParentFeeWrapper(){
            childFeeWrapper = new List<FeeWrapper>();
        }
    }
    
    public class FeeWrapper{ 
        @AuraEnabled public String  feeId{get;set;}
        @AuraEnabled public String  feeName{get;set;}
        @AuraEnabled public String  feeType{get;set;}
        @AuraEnabled public String  payFrequency{get;set;}
        @AuraEnabled public String  feeSchType{get;set;}
        @AuraEnabled public String  feeParent{get;set;}
        @AuraEnabled public Integer noOfUnit{get;set;}
        @AuraEnabled public Decimal tutionFeeUnitPrice{get;set;}
        @AuraEnabled public Decimal feeAmount{get;set;}
        @AuraEnabled public Decimal feeProratedAmount{get;set;}
        @AuraEnabled public Boolean isSelected{get;set;}
        @AuraEnabled public Boolean isOverride{get;set;}
        @AuraEnabled public Boolean isGSTApplicable{get;set;}
        
        public FeeWrapper(){
            this.feeAmount  = 0;
            this.feeProratedAmount  = 0;
            this.tutionFeeUnitPrice = 0;
            this.noOfUnit   = 0;
            this.isSelected = False;
            this.isOverride = False;
            this.isGSTApplicable = False;
        }
    }
    
    public class DisWrapper{ 
        @AuraEnabled public String  disId{get;set;}
        @AuraEnabled public String  name{get;set;}
        @AuraEnabled public String  type{get;set;}
        @AuraEnabled public Decimal amount{get;set;}
        @AuraEnabled public String  format{get;set;}
        @AuraEnabled public String  referralBy{get;set;}
        @AuraEnabled public String  referralById{get;set;}
        @AuraEnabled public String  enterCode{get;set;}
        @AuraEnabled public String  promoCode{get;set;}
        @AuraEnabled public Boolean isSelected{get;set;}
        @AuraEnabled public Boolean isOverride{get;set;}
        
        public DisWrapper(){
            this.amount   = 0;
            this.isSelected = False;
            this.isOverride = False;
        }
    }
    
    public class DayOfWeekWrapper{
        @AuraEnabled public String nameOfDay;
        @AuraEnabled public decimal csTotEnrollment;
        @AuraEnabled public List<ClassSessionWrapper> classSessionWrapperList = new List<ClassSessionWrapper>();
    }
    
    public class ClassSessionWrapper{
        @AuraEnabled public String id;
        @AuraEnabled public decimal enrollments;
        @AuraEnabled public String type;
        @AuraEnabled public String teacherName;
        @AuraEnabled public time startTime;
        @AuraEnabled public time endTime;
        @AuraEnabled public decimal seatsLeft;
        @AuraEnabled public String dayOfWeek;        
    }
    
}