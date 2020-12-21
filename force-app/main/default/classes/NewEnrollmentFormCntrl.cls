/*
Name: NewEnrollmentFormCntrl
Date: 30th Jan 2020
Author: 
Description: This controller is used create new enrollments 
*/
public class NewEnrollmentFormCntrl {
    
    //This function is used to get dynmically picklist values of the object
    @auraEnabled
    public static Blufy_Config__mdt getBlufyConfigDetails(){ 
        List<Blufy_Config__mdt> systemConfig = BlufyConfigService.getByDeveloperName('Default') ;
        system.debug('systemConfig-->'+systemConfig);
        if(systemConfig.size() > 0){
            return systemConfig[0];         
        }
        return null;
    }
    
    //used
    //This function is used to get selected contact details when user select existing customer
    @auraEnabled
    public static Account getchSlcdAccDetails(String accId,Boolean isCorporateAccount){
        Account acc = new Account();
        List<Account> accList = new List<Account>();
        accList = AccountService.getCorporateOrCustomerById(accId, isCorporateAccount);
        if(accList.size() > 0){
            acc= accList.get(0);
        }
        System.debug('acc-->'+acc); 
        return acc;
    }
    //used
    @AuraEnabled
    public static List<Class_Session__c> getClassSessionData(String clsSessionId){
        if(String.isNotBlank(clsSessionId)){
            return ClassSessionService.getClassSessionsById(new Set<String>{clsSessionId});
        }
        return null;
    }
    
    //used
    @AuraEnabled
    public static CourseFeeWrapper fetchClassDetails(String crId){
        system.debug('crId'+crId);
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
            cw.clsSrtDate   = (cls.Start_Date__c != NULL ? cls.Start_Date__c : null);
            cw.isFixed      = (cls.Type__c == 'Fixed' ? true : false);
            cw.seatsAlv     = cls.Seats_Available__c != null ? Integer.valueOf(cls.Seats_Available__c) : 0;
            cw.mode         = cls.Mode__c; 
            if(cls.Start_Time__c != null)
                cw.stEndTime= Datetime.newInstance(System.today(), cls.Start_Time__c).format('hh:mm a');
            if(cls.End_Time__c != null)
                cw.stEndTime += ' - '+ Datetime.newInstance(System.today(), cls.End_Time__c).format('hh:mm a');    
            
            //For Monthly classes        
            if(cls.Frequency__c.equalsIgnoreCase(ConstantClass.monthlyFrequency)){  
                system.debug('cw Inside');
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
                system.debug('cls.Class_Sessions__r'+cls.Class_Sessions__r);
                for(Class_Session__c csObj : cls.Class_Sessions__r){
                    system.debug('csObj'+csObj);
                    ClassSessionWrapper clsSessObjWrap = new ClassSessionWrapper();
                    clsSessObjWrap.id = csObj.Id;
                    clsSessObjWrap.enrollments = csObj.Enrollments__c != null ? csObj.Enrollments__c : 0;
                    clsSessObjWrap.type = csObj.Type__c;
                    clsSessObjWrap.teacherName = csObj.Teacher__r.name;
                    clsSessObjWrap.teacherId = csObj.Teacher__c;
                    clsSessObjWrap.startTime = csObj.Start_Time__c;
                    clsSessObjWrap.endTime = csObj.End_Time__c;
                    clsSessObjWrap.seatsLeft = csObj.Seats_Left__c;
                    clsSessObjWrap.dayOfWeek= csObj.Day_of_Week__c;  
                    system.debug('clsSessObjWrap'+clsSessObjWrap);
                    if(dayOfWeekMap.containsKey(csObj.Day_of_Week__c)){
                        List<ClassSessionWrapper> clsSessionList = dayOfWeekMap.get(csObj.Day_of_Week__c);
                        clsSessionList.add(clsSessObjWrap);
                        dayOfWeekMap.put(csObj.Day_of_Week__c,clsSessionList);
                    }else{
                        dayOfWeekMap.put(csObj.Day_of_Week__c,new List<ClassSessionWrapper>{clsSessObjWrap});
                    }
                    system.debug('dayOfWeekMap'+dayOfWeekMap);
                    // cw.classSessionWrapperList.add(clsSessObjWrap);                 
                }
                if(dayOfWeekMap.size() > 0){
                    for(String mapObj : dayOfWeekMap.keySet()){
                        system.debug('mapObj'+mapObj);
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
                system.debug('cw'+cw);
            }
        }
        crsFeeWrap.classWrapperList.addAll(cwList);
        return crsFeeWrap;
    }
    //used
    @AuraEnabled
    public static List<ParentFeeWrapper> fetchFessDetail(String classSessionId){
        if(String.isNotBlank(classSessionId)){
            List<Class_Session__c> clsList = [SELECT Id, Class__r.Course__c FROM Class_Session__c WHERE Id=: classSessionId];
            if(clsList.size() > 0){
                Map<String, ParentFeeWrapper> mapOfFee = new Map<String, ParentFeeWrapper>();         
                for(Course_Fee__c courseObj : [SELECT Id, Fee__c, Fee__r.Type__c, Fee__r.Amount__c, Fee__r.Unit_Price__c, Fee__r.Name,
                                               Fee__r.Prorate__c,  Fee__r.Required__c, Fee__r.GST_Applicable__c,
                                               Fee__r.Frequency__c,  Fee__r.Schedule__c
                                               FROM Course_Fee__c 
                                               WHERE Course__c =: clsList[0].Class__r.Course__c AND Fee__r.RecordType.Id =: ConstantClass.primaryFeeRecordTypeId]){
                                                   ParentFeeWrapper parentFeeObj = new ParentFeeWrapper();                                                        
                                                   parentFeeObj.parentFeeId = courseObj.Fee__c;
                                                   parentFeeObj.parentFeeName = courseObj.Fee__r.Name;
                                                   parentFeeObj.parentFeeType = courseObj.Fee__r.Type__c;
                                                   parentFeeObj.parenTtutionFeeUnitPrice = courseObj.Fee__r.Unit_Price__c != null ? courseObj.Fee__r.Unit_Price__c : 0;
                                                   parentFeeObj.parentAmount = courseObj.Fee__r.Amount__c;
                                                   parentFeeObj.prorate      = courseObj.Fee__r.Prorate__c; 
                                                   parentFeeObj.required     = courseObj.Fee__r.Required__c;
                                                   parentFeeObj.gstApplicable = courseObj.Fee__r.GST_Applicable__c;
                                                   parentFeeObj.payFrequency = courseObj.Fee__r.Frequency__c;
                                                   parentFeeObj.frequency = courseObj.Fee__r.Schedule__c;
                                                   mapOfFee.put(courseObj.Fee__c, parentFeeObj);
                                               }                
                For(Fee__c feeObj : [SELECT Id, Name,Type__c, Amount__c, Frequency__c,
                                     Unit_Price__c, Parent__c, RecordType.Name, Units__c,
                                     GST_Applicable__c, Required__c, Schedule__c
                                     FROM Fee__c WHERE Parent__c =: mapOfFee.keySet() AND RecordType.Id =: ConstantClass.secondaryFeeRecordTypeId]){                                        
                                         if(mapOfFee.containsKey(feeObj.Parent__c)){
                                             FeeWrapper fw = new FeeWrapper();
                                             fw.feeId      = feeObj.Id;
                                             fw.feeName    = feeObj.Name;
                                             fw.feeType    = feeObj.Type__c;
                                             fw.payFrequency = feeObj.Frequency__c;  
                                             fw.feeAmount   = feeObj.Amount__c;                       
                                             fw.noOfUnit    = feeObj.Unit_Price__c != null ? Integer.valueOf(feeObj.Unit_Price__c) : 0;
                                             fw.isGSTApplicable = feeObj.GST_Applicable__c;
                                             fw.required   = feeObj.Required__c;
                                             fw.frequency = feeObj.Schedule__c;
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
    
    //This function is used to fetch other discount which configured globally
    //used
    @auraEnabled (cacheable = true)
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
            dw.isGlobal = true;
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
    public static ParentFeeWrapper calculateProratedAmount(String classSessionId, String selectedFee, Date enrolDate){ 
        system.debug('selectedFee'+selectedFee);
        if(String.isNotBlank(classSessionId) && String.isNotBlank(selectedFee) && enrolDate != NULL){
            List<ParentFeeWrapper> tuitionFee = (List<ParentFeeWrapper>)System.JSON.deserialize(selectedFee, List<ParentFeeWrapper>.class);
            Integer noOfSess = 0;
            if(enrolDate.month() == System.today().month()){
                List<Session__c> listSession = SessionService.getByClassSessionIdAlongWithEnrolDate(classSessionId,enrolDate);
                noOfSess = (listSession.size() > 0 ? listSession.size() : 0);
            }
            tuitionFee[0].parentProratedAmount = tuitionFee[0].parentTutionFeeUnitPrice * noOfSess;
            return tuitionFee[0];
        }
        return null;
    }
    
    //This function is used to get dynmically picklist values of the object
    
    @auraEnabled(cacheable =true)
    public static List<String> getPicklistValues(String ObjectApi_name, String Field_name){ 
        return UtilityClass.getPickValues(ObjectApi_name, Field_name);
    }
    
    @AuraEnabled
    public static String doSaveEnrollmentApex(String studentDetails,String parentDetail,String secondaryDetail,String btnLabel,Decimal grandTotal,String paymentRefNumber,String paymentComments,String paymentMode,Boolean showAchPayment,
                                              String discountList,String achRelatedInfo){
                                                  Savepoint sp;
                                                  try{
                                                      Account parentAccount = new Account();
                                                      Account secondaryAccount = new Account();
                                                      StudentDetails objStudentDetail = new StudentDetails();
                                                      Boolean isExistingParent = false;
                                                      List<ACHDetailsWrapper> listACHDetailsWrapper = new List<ACHDetailsWrapper>();
                                                      List<Account> listStudent = new List<Account>();
                                                      List<Family__c> listFamily = new List<Family__c>();
                                                      List<Enrollment__c> listEnrollment = new List<Enrollment__c>();
                                                      List<Invoice_Line_Item__c> listInvoiceLineItem = new List<Invoice_Line_Item__c>();
                                                      List<Deposit__c> listDeposit = new List<Deposit__c>();
                                                      List<Student_Session__c> listStudentSession = new List<Student_Session__c>();
                                                      String locationId = '';
                                                      Map<String,List<Session__c>> mapCourseDetailsToClassSessions = new Map<String,List<Session__c>>();
                                                      Map<String,Account> mapAccDetailToAccount = new Map<String,Account>();
                                                      Map<String,String> mapCourseDetailsToEnrollmentId = new Map<String,String>();
                                                      Map<String,String> mapCourseDetailsToTuitionFee = new Map<String,String>();
                                                      Map<String,Subscription__c> mapPaymentFrequencyToSubscription = new Map<String,Subscription__c>();
                                                      List<Subscription_Line_Item__c> listSubscriptionLineItem = new List<Subscription_Line_Item__c>();
                                                      List<DisWrapper> listDiscountWrapper = new List<DisWrapper>();
                                                      Boolean gstApplicable = false;
                                                      Decimal gstRate = 0.0;
                                                      Decimal invoiceDueDays = 0;
                                                      
                                                      Blufy_Config__mdt blufyConfig = getBlufyConfigDetails();
                                                      if(blufyConfig != NULL){
                                                          gstApplicable = blufyConfig.GST_VAT_Applicable__c;	
                                                          gstRate = blufyConfig.GST_VAT_Rate__c;
                                                          invoiceDueDays = blufyConfig.Invoice_Due_Days__c;
                                                      }
                                                      
                                                      if(String.isNotBlank(parentDetail))
                                                          parentAccount = (Account)JSON.deserialize(parentDetail,Account.class);
                                                      
                                                      if(String.isNotBlank(secondaryDetail))
                                                          secondaryAccount = (Account)JSON.deserialize(secondaryDetail,Account.class);
                                                      
                                                      if(String.isNotBlank(studentDetails))
                                                          objStudentDetail = (StudentDetails)JSON.deserialize(studentDetails, StudentDetails.class);
                                                      
                                                      if(String.isNotBlank(discountList))
                                                          listDiscountWrapper = (List<DisWrapper>)JSON.deserialize(discountList, List<DisWrapper>.class);
                                                      
                                                      if(String.isNotBlank(achRelatedInfo))
                                                          listACHDetailsWrapper = (List<ACHDetailsWrapper>)JSON.deserialize(achRelatedInfo, List<ACHDetailsWrapper>.class);
                                                      
                                                      //**********************************************Parent Records Insertion**********************************************************
                                                      if(parentAccount != NULL){       
                                                          if(String.isBlank(parentAccount.Id) && String.isNotBlank(parentAccount.PersonEmail)){
                                                              parentAccount.RecordTypeId = ConstantClass.customerRecTypeId;
                                                              List<Account> listAccount = AccountService.getAccountByEmailId(parentAccount.PersonEmail);
                                                              if(listAccount.size() > 0){                    
                                                                  parentAccount.Id = listAccount[0].Id;
                                                              }
                                                          }
                                                          
                                                          if(String.isNotBlank(parentAccount.Id))
                                                              isExistingParent = true;
                                                          
                                                          if(String.isBlank(parentAccount.Id) && String.isBlank(parentAccount.PersonEmail)){
                                                              parentAccount.RecordTypeId = ConstantClass.corporateRecTypeId;
                                                          }
                                                          parentAccount = AccountService.upsertAccountRecords(new List<Account>{parentAccount})[0];          
                                                      }
                                                      //**********************************************Parent Records Insertion**********************************************************
                                                      
                                                      //**********************************************Secondary Account Records Insertion**********************************************************
                                                      if(secondaryAccount != NULL && String.isNotBlank(secondaryAccount.LastName)){
                                                          if(String.isBlank(secondaryAccount.Id)){
                                                              secondaryAccount.RecordTypeId = ConstantClass.customerRecTypeId;
                                                          }
                                                          secondaryAccount = AccountService.upsertAccountRecords(new List<Account>{secondaryAccount})[0];
                                                      }
                                                      //**********************************************Secondary Account Insertion**********************************************************
                                                      
                                                      //**********************************************Family Records Insertion**********************************************************
                                                      if(!isExistingParent && String.isNotBlank(parentAccount.Id) && String.isNotBlank(secondaryAccount.Id)){          
                                                          Family__c family = new Family__c();
                                                          family.Name = parentAccount.LastName;
                                                          family.Account__c = parentAccount.Id;
                                                          family.Account_2__c = secondaryAccount.Id;
                                                          family.Relationship__c = ConstantClass.spouseFmlyRelationPicklist;
                                                          listFamily.add(family);
                                                      }
                                                      //**********************************************Family Records Insertion**********************************************************
                                                      
                                                      if(objStudentDetail != NULL){
                                                          if(String.isNotBlank(parentAccount.Id)){
                                                              List<Subscription__c> listSubscription = SubscriptionService.getSubscriptionByParentId(new Set<String>{parentAccount.Id});
                                                              if(listSubscription.size() > 0){
                                                                  for(Subscription__c sub: listSubscription){
                                                                      mapPaymentFrequencyToSubscription.put(sub.Payment_Frequency__c,sub);
                                                                  }   
                                                              }
                                                          }
                                                          
                                                          //**********************************************Student Records Filling & Insertion**********************************************************
                                                          if(objStudentDetail.studentDetail.size() > 0){
                                                              for(StudentDetailsWrapper student : objStudentDetail.studentDetail){
                                                                  Account studentAcc = new Account();
                                                                  studentAcc.RecordTypeId = ConstantClass.studCustomerRecordTypeId;
                                                                  studentAcc.FirstName = student.FirstName;
                                                                  studentAcc.LastName = student.LastName;
                                                                  studentAcc.PersonBirthdate = student.PersonBirthdate;
                                                                  studentAcc.Gender__c = student.Gender;
                                                                  studentAcc.educato__Parent__c = parentAccount.Id;
                                                                  if(String.isNotBlank(student.Id))
                                                                      studentAcc.Id = student.Id;
                                                                  listStudent.add(studentAcc);
                                                              }
                                                              
                                                              if(listStudent.size() > 0){
                                                                  listStudent = AccountService.upsertAccountRecords(listStudent);
                                                                  for(Account student :listStudent){
                                                                      mapAccDetailToAccount.put(student.FirstName+'#'+student.LastName+'#'+student.PersonBirthDate+'#'+student.Gender__c,student);
                                                                  }
                                                                  //**********************************************Student Records Filling & Insertion**********************************************************
                                                                  
                                                                  //**********************************************Student Family Records Filling & Insertion**********************************************************
                                                                  if(!isExistingParent && mapAccDetailToAccount.keySet().size() > 0){
                                                                      Account frstStudent = mapAccDetailToAccount.values()[0];
                                                                      for(Account student : mapAccDetailToAccount.values()){
                                                                          Family__c parentAccountfamily = new Family__c();
                                                                          parentAccountfamily.Name = parentAccount.LastName;
                                                                          parentAccountfamily.Account__c = parentAccount.Id;
                                                                          parentAccountfamily.Account_2__c = student.Id;
                                                                          parentAccountfamily.Relationship__c = ConstantClass.childFmlyRelationPicklist;
                                                                          listFamily.add(parentAccountfamily);
                                                                          
                                                                          if(String.isNotBlank(secondaryAccount.Id)){
                                                                              Family__c secondaryAccountfamily = new Family__c();
                                                                              secondaryAccountfamily.Name = parentAccount.LastName;
                                                                              secondaryAccountfamily.Account__c = secondaryAccount.Id;
                                                                              secondaryAccountfamily.Account_2__c = student.Id;
                                                                              secondaryAccountfamily.Relationship__c = ConstantClass.childFmlyRelationPicklist;   
                                                                          	  listFamily.add(secondaryAccountfamily);
                                                                          }
                                                                          
                                                                          if(String.isNotBlank(frstStudent.Id) && !frstStudent.Id.equals(student.Id)){
                                                                              Family__c siblingAccountfamily = new Family__c();
                                                                              siblingAccountfamily.Name = parentAccount.LastName;
                                                                              siblingAccountfamily.Account__c = frstStudent.Id;
                                                                              siblingAccountfamily.Account_2__c = student.Id;
                                                                              siblingAccountfamily.Relationship__c = ConstantClass.siblingFmlyRelationPicklist;   
                                                                          	  listFamily.add(siblingAccountfamily);
                                                                          }
                                                                      }                                                          
                                                                  }                        
                                                                  
                                                                  if(listFamily.size() > 0){
                                                                      listFamily = FamilyService.insertRecords(listFamily);
                                                                  }
                                                                  //**********************************************Student Family Records Filling & Insertion**********************************************************
                                                                  
                                                                  //**********************************************Enrollment Records Filling**********************************************************
                                                                  for(StudentDetailsWrapper student : objStudentDetail.studentDetail){
                                                                      if(student.classDetails.size() > 0){
                                                                          for(ClassDetailsListWrapper classDetails : student.classDetails){
                                                                              ClassDetailWrapper classDetail = classDetails.classDetail;
                                                                              String studentId = mapAccDetailToAccount.get(student.FirstName+'#'+student.LastName+'#'+student.PersonBirthDate+'#'+student.Gender).Id;                  
                                                                              if(String.isNotBlank(btnLabel) && btnLabel.equalsIgnoreCase('Confirm'))
                                                                                  mapCourseDetailsToClassSessions.put(studentId+'#'+classDetail.classId+'#'+classDetail.classSessionId+'#'+classDetails.enrollmentStartDate,null);
                                                                              if(String.isBlank(locationId))
                                                                                  locationId = classDetail.locationId;
                                                                              Enrollment__c enrolmnt  = UtilityClass.fillEnrollment(parentAccount.Id,classDetail.locationId, classDetail.classId,
                                                                                                                                    classDetails.enrollmentStartDate,ConstantClass.enrollmentStage,
                                                                                                                                    (String.isNotBlank(btnLabel) && btnLabel.equalsIgnoreCase('Confirm') ? 
                                                                                                                                     ConstantClass.enrolledStatus : ConstantClass.draftStatus));
                                                                              enrolmnt.Student__c = mapAccDetailToAccount.get(student.FirstName+'#'+student.LastName+'#'+student.PersonBirthDate+'#'+student.Gender).Id;
                                                                              enrolmnt.Class_Session__c = classDetail.classSessionId;
                                                                              enrolmnt.Type__c = classDetail.clsType;
                                                                              enrolmnt.Parent_Email__c = parentAccount.PersonEmail;
                                                                              enrolmnt.Comments__c = classDetails.comments;
                                                                              enrolmnt.Mode__c = classDetail.mode;
                                                                              listEnrollment.add(enrolmnt);
                                                                          }
                                                                      }
                                                                  }
                                                                  //**********************************************Enrollment Records Filling**********************************************************
                                                                  
                                                                  //**********************************************Invoice Record Insertion**********************************************************
                                                                  Invoice__c invoice = UtilityClass.fillInvoice(parentAccount.Id,locationId,null,ConstantClass.newEnrollmentInvType,
                                                                                                                (!showAchPayment && String.isNotBlank(btnLabel) && btnLabel.equalsIgnoreCase('Confirm') ? 
                                                                                                                 ConstantClass.paidStatus : ConstantClass.dueStatus));
                                                                  if(invoiceDueDays > 0)
                                                                      invoice.Due_Date__c = System.today().addDays(Integer.valueOf(invoiceDueDays));
                                                                  invoice.Remarks__c = paymentComments;
                                                                  invoice = InvoiceService.insertInvoiceRecords(new List<Invoice__c>{invoice})[0];
                                                                  //**********************************************Invoice Record Insertion**********************************************************
                                                                  
                                                                  //**********************************************Enrollment Records Insertion**********************************************************
                                                                  if(listEnrollment.size() > 0){
                                                                      listEnrollment = EnrollmentService.insertEnrollmentRecords(listEnrollment);
                                                                      for(Enrollment__c enrolment : listEnrollment){
                                                                          mapCourseDetailsToEnrollmentId.put(enrolment.Student__c+'#'+enrolment.Class__c+'#'+enrolment.Class_Session__c,enrolment.Id);
                                                                      }
                                                                      //**********************************************Enrollment Records Insertion**********************************************************
                                                                      
                                                                      for(StudentDetailsWrapper student : objStudentDetail.studentDetail){
                                                                          if(student.classDetails.size() > 0){
                                                                              if(mapAccDetailToAccount.keySet().size() > 0 && mapCourseDetailsToEnrollmentId.keySet().size() > 0){
                                                                                  for(ClassDetailsListWrapper classDetails : student.classDetails){
                                                                                      ClassDetailWrapper classDetail = classDetails.classDetail;
                                                                                      //**************************Invoice Line Item Records Insertion***************************************************
                                                                                      if(classDetail.tuitionFeeList.size() > 0){
                                                                                          ParentFeeWrapper tutionFee = classDetail.tuitionFeeList[0];
                                                                                          Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(invoice.Id, null, null, tutionFee.parentFeeId, null, ConstantClass.feeType,
                                                                                                                                                       tutionFee.parentProratedAmount,gstApplicable,gstRate);
                                                                                          String studentId = mapAccDetailToAccount.get(student.FirstName+'#'+student.LastName+'#'+student.PersonBirthDate+'#'+student.Gender).Id;
                                                                                          invLnItm.Period__c = DateTime.now().format('MMM') +' '+System.today().year();
                                                                                          invLnItm.Enrollment__c = mapCourseDetailsToEnrollmentId.get(studentId+'#'+classDetail.classId+'#'+classDetail.classSessionId);
                                                                                          listInvoiceLineItem.add(invLnItm);
                                                                                          
                                                                                          if(classDetail.clsType.equalsIgnoreCase(ConstantClass.ongoingClsType) && !(tutionFee.payFrequency.equalsIgnoreCase(ConstantClass.oneTimeFrequency))){
                                                                                              mapCourseDetailsToTuitionFee.put(studentId+'#'+classDetail.classId,tutionFee.parentFeeId+'#'+tutionFee.payFrequency);
                                                                                              
                                                                                              //**************************Subscription Records Insertion***************************************************
                                                                                              Subscription__c subs = new Subscription__c();
                                                                                              if(mapPaymentFrequencyToSubscription.containsKey(tutionFee.payFrequency)){
                                                                                                  subs = mapPaymentFrequencyToSubscription.get(tutionFee.payFrequency);
                                                                                              }else{
                                                                                                  subs.Location__c = classDetail.locationId;
                                                                                                  subs.Customer__c = parentAccount.Id;
                                                                                                  subs.Status__c   = ConstantClass.activeStatus;
                                                                                                  subs.Payment_Frequency__c = tutionFee.payFrequency;
                                                                                                  if(subs.Subscription_Start_Date__c == NULL)
                                                                                                      subs.Subscription_Start_Date__c = classDetails.enrollmentStartDate;
                                                                                                  else if(subs.Subscription_Start_Date__c > classDetails.enrollmentStartDate)
                                                                                                      subs.Subscription_Start_Date__c = classDetails.enrollmentStartDate;
                                                                                                  mapPaymentFrequencyToSubscription.put(tutionFee.payFrequency, subs);
                                                                                              }
                                                                                              //**************************Subscription Records Insertion***************************************************   
                                                                                          }                                                    
                                                                                      }
                                                                                      if(classDetail.secondaryFeeList.size() > 0){
                                                                                          for(FeeWrapper secondaryFee : classDetail.secondaryFeeList){
                                                                                              Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(invoice.Id, null, null, secondaryFee.feeId, null, ConstantClass.feeType,
                                                                                                                                                           secondaryFee.feeAmount,gstApplicable,gstRate);
                                                                                              String studentId = mapAccDetailToAccount.get(student.FirstName+'#'+student.LastName+'#'+student.PersonBirthDate+'#'+student.Gender).Id;
                                                                                              invLnItm.Period__c = DateTime.now().format('MMM') +' '+System.today().year();
                                                                                              invLnItm.Enrollment__c = mapCourseDetailsToEnrollmentId.get(studentId+'#'+classDetail.classId+'#'+classDetail.classSessionId);
                                                                                              listInvoiceLineItem.add(invLnItm);
                                                                                          }
                                                                                      }
                                                                                      if(classDetail.depositfeelist.size() > 0){
                                                                                          for(ParentFeeWrapper depositFee : classDetail.depositfeelist){
                                                                                              Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(invoice.Id, null, null, depositFee.parentFeeId, null, ConstantClass.depositFeeType,
                                                                                                                                                           depositFee.parentAmount,false,0.0);
                                                                                              String studentId = mapAccDetailToAccount.get(student.FirstName+'#'+student.LastName+'#'+student.PersonBirthDate+'#'+student.Gender).Id;
                                                                                              invLnItm.Period__c = DateTime.now().format('MMM') +' '+System.today().year();
                                                                                              invLnItm.Enrollment__c = mapCourseDetailsToEnrollmentId.get(studentId+'#'+classDetail.classId+'#'+classDetail.classSessionId);
                                                                                              listInvoiceLineItem.add(invLnItm);
                                                                                          }
                                                                                      }
                                                                                      //**************************Invoice Line Item Records Insertion***************************************************
                                                                                  }
                                                                              }
                                                                          }
                                                                      }
                                                                      
                                                                      //*************************************************Student Session Record Filling*******************************
                                                                      if(mapCourseDetailsToClassSessions.keySet().size() > 0){
                                                                          Set<String> setClassSessionId = new Set<String>();
                                                                          for(String key : mapCourseDetailsToClassSessions.keySet()){
                                                                              setClassSessionId.add(key.split('#')[2]);
                                                                          }
                                                                          
                                                                          if(setClassSessionId.size() > 0){
                                                                              List<Session__c> listSession = SessionService.getSessionsByClassSessionId(setClassSessionId);
                                                                              if(listSession.size() > 0){
                                                                                  for(String key : mapCourseDetailsToClassSessions.keySet()){
                                                                                      String classSessionId = key.split('#')[2];
                                                                                      Date enrollmentDate = Date.valueOf(key.split('#')[3]);
                                                                                      for(Session__c session : listSession){
                                                                                          if(classSessionId.equals(session.Class_Session__c) && session.Session_Date__c >= enrollmentDate){
                                                                                              List<Session__c> listSessionToPut = new List<Session__c>();
                                                                                              if(mapCourseDetailsToClassSessions.get(key) != NULL)
                                                                                                  listSessionToPut = mapCourseDetailsToClassSessions.get(key);
                                                                                              listSessionToPut.add(session);
                                                                                              mapCourseDetailsToClassSessions.put(key,listSessionToPut);
                                                                                          } 
                                                                                      }
                                                                                  }
                                                                              }
                                                                          }                                                      
                                                                          System.debug('mapCourseDetailsToClassSessions-->'+mapCourseDetailsToClassSessions);
                                                                          for(String mapKey : mapCourseDetailsToClassSessions.keySet()){
                                                                              if(mapCourseDetailsToClassSessions.get(mapKey) != NULL){   
                                                                                  System.debug('mapStudent Size-->'+mapCourseDetailsToClassSessions.get(mapKey).size());
                                                                                  for(Session__c session : mapCourseDetailsToClassSessions.get(mapKey)){
                                                                                      Student_Session__c stuSess = new Student_Session__c();
                                                                                      stuSess.Account__c    = mapKey.split('#')[0];
                                                                                      stuSess.Session__c    = session.Id;
                                                                                      stuSess.Enrollment__c = mapCourseDetailsToEnrollmentId.get(mapKey.split('#')[0]+'#'+mapKey.split('#')[1]+'#'+mapKey.split('#')[2]);
                                                                                      stuSess.Status__c     = ConstantClass.ScheduledStatus;
                                                                                      stuSess.Billable__c   = True;  
                                                                                      listStudentSession.add(stuSess);
                                                                                  }                                                    
                                                                              }
                                                                          }                                                                                     
                                                                      }
                                                                      //*************************************************Student Session Record Filling*******************************
                                                                      
                                                                      
                                                                      
                                                                      //*************************************************Subscription Record Insertion*******************************************
                                                                      if(mapPaymentFrequencyToSubscription.keySet().size() > 0){
                                                                          List<Subscription__c> listSubscriptionToInsert = SubscriptionService.upsertSubscriptionRecords(mapPaymentFrequencyToSubscription.values());
                                                                          if(listSubscriptionToInsert != NULL && listSubscriptionToInsert.size() > 0 ){
                                                                              for(Subscription__c subs : listSubscriptionToInsert){
                                                                                  if(mapPaymentFrequencyToSubscription.containsKey(subs.Payment_Frequency__c))
                                                                                      mapPaymentFrequencyToSubscription.put(subs.Payment_Frequency__c,subs);
                                                                              }
                                                                          }
                                                                      }
                                                                      //*************************************************Subscription Record Insertion*******************************************
                                                                      
                                                                      //*************************************************Subscription Line Item Record Filling*******************************************
                                                                      if(mapCourseDetailsToTuitionFee.keySet().size() > 0 && mapAccDetailToAccount.keySet().size() > 0 
                                                                         && mapCourseDetailsToEnrollmentId.keySet().size() > 0 && mapPaymentFrequencyToSubscription.keySet().size() > 0){
                                                                             for(StudentDetailsWrapper student : objStudentDetail.studentDetail){
                                                                                 if(student.classDetails.size() > 0){
                                                                                     for(ClassDetailsListWrapper classDetails : student.classDetails){
                                                                                         ClassDetailWrapper classDetail = classDetails.classDetail;
                                                                                         String studentId = mapAccDetailToAccount.get(student.FirstName+'#'+student.LastName+'#'+student.PersonBirthDate+'#'+student.Gender).Id;
                                                                                         if(mapCourseDetailsToEnrollmentId.containsKey(studentId+'#'+classDetail.classId+'#'+classDetail.classSessionId) &&
                                                                                            mapCourseDetailsToTuitionFee.containsKey(studentId+'#'+classDetail.classId)){
                                                                                                Subscription_Line_Item__c subsLnItem = new Subscription_Line_Item__c();
                                                                                                subsLnItem.Subscription__c  = mapPaymentFrequencyToSubscription.get(mapCourseDetailsToTuitionFee.get(studentId+'#'+classDetail.classId).split('#')[1]).Id;
                                                                                                subsLnItem.Enrollment__c    = mapCourseDetailsToEnrollmentId.get(studentId+'#'+classDetail.classId+'#'+classDetail.classSessionId);
                                                                                                subsLnItem.Fee__c           = mapCourseDetailsToTuitionFee.get(studentId+'#'+classDetail.classId).split('#')[0];
                                                                                                subsLnItem.Status__c        = ConstantClass.activeStatus;
                                                                                                //subsLnItem.Subscription_Start_Date__c = classDetails.enrollmentStartDate;    
                                                                                                //Date oneMonthAfterSubsStartDate = classDetails.enrollmentStartDate.date().addMonths(1);
                                                                                                //subsLnItem.Next_Bill_Date__c = Date.newInstance(oneMonthAfterSubsStartDate.year(),oneMonthAfterSubsStartDate.month(),1);
                                                                                                listSubscriptionLineItem.add(subsLnItem);
                                                                                            }
                                                                                     }                                           
                                                                                 }
                                                                             }
                                                                         }                            
                                                                      
                                                                      if(listSubscriptionLineItem.size() > 0)
                                                                          listSubscriptionLineItem = SubscriptionLineItemService.insertSubsLineItemRecords(listSubscriptionLineItem);
                                                                      //*************************************************Subscription Line Item Record Filling*******************************************
                                                                      
                                                                      //*************************************************Discount Record Filling*********************************************************
                                                                      if(listDiscountWrapper.size() > 0){
                                                                          for(DisWrapper discount : listDiscountWrapper){
                                                                              Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(invoice.Id, null, null, null,discount.disId,ConstantClass.discountType,discount.amount,gstApplicable,gstRate);
                                                                              listInvoiceLineItem.add(invLnItm);
                                                                          }
                                                                      }
                                                                      //*************************************************Discount Record Filling*********************************************************
                                                                      
                                                                      //*************************************************Invoice Line Item Record Insertion**********************************************
                                                                      if(listInvoiceLineItem.size() > 0){
                                                                          listInvoiceLineItem = InvoiceLineItemService.insertInvoiceLineItemRecords(listInvoiceLineItem);
                                                                          for(Invoice_Line_Item__c invLinItem : listInvoiceLineItem){
                                                                              if(invLinItem.Type__c.equalsIgnoreCase(ConstantClass.depositFeeType)){
                                                                                  Deposit__c deposit 		= new Deposit__c();
                                                                                  deposit.Account__c	 	= parentAccount.Id;
                                                                                  deposit.Enrollment__c 	= invLinItem.Enrollment__c;
                                                                                  deposit.Invoice_Line_Item__c = invLinItem.Id;
                                                                                  listDeposit.add(deposit);
                                                                              }
                                                                          }
                                                                      }                            
                                                                      //*************************************************Invoice Line Item Record Insertion*******************************
                                                                      
                                                                      //*************************************************Deposit Record Insertion*******************************
                                                                      if(listDeposit.size() > 0)
                                                                          listDeposit = DepositService.insertDepositRecords(listDeposit);
                                                                      //*************************************************Deposit Record Insertion*******************************
                                                                      
                                                                      //*************************************************Student Session Record Insertion*******************************
                                                                      if(listStudentSession.size() > 0)
                                                                          listStudentSession = StudentSessionService.insertStudentSessionRecords(listStudentSession);
                                                                      //*************************************************Student Session Record Insertion*******************************
                                                                  }
                                                                  
                                                                  
                                                                  //**********************************************Payment Records Insertion**********************************************************
                                                                  if(!showAchPayment && String.isNotBlank(btnLabel) && btnLabel.equalsIgnoreCase('Confirm')){
                                                                      Payment__c payment = UtilityClass.fillPayment(parentAccount.Id,invoice.Id,ConstantClass.successStatus,grandTotal);
                                                                      payment.Payment_Reference__c = paymentRefNumber;
                                                                      payment.Payment_Mode__c = paymentMode;
                                                                      //payment.Credit_Note__c = 'a0l110000087Za0AAE';
                                                                      payment.Comments__c = paymentComments;
                                                                      payment = PaymentService.insertPaymentRecords(new List<Payment__c>{payment})[0];
                                                                  }
                                                                  //**********************************************Payment Records Insertion**********************************************************
                                                                  
                                                                  //**********************************************Payment Account Records Insertion**********************************************************
                                                                  if(String.isNotBlank(btnLabel) && btnLabel.equalsIgnoreCase('Confirm')){
                                                                      if(showAchPayment && listACHDetailsWrapper.size() > 0){
                                                                          ACHDetailsWrapper objACH = listACHDetailsWrapper[0];
                                                                          StripeUtility.createStripeCustomerUsingACH(parentAccount.Id,'US','USD',objACH.HolderName,objACH.HolderType,objACH.RoutingNo,objACH.AccountNumber,parentAccount.PersonEmail,ConstantClass.ACHHolderType);
                                                                      }else if(!showAchPayment){
                                                                          StripeUtility.createStripeCustomerUsingACH(parentAccount.Id, NULL, NULL,parentAccount.FirstName+' '+parentAccount.LastName, NULL, NULL, NULL,parentAccount.PersonEmail,ConstantClass.offlineHolderType);
                                                                      }
                                                                  }
                                                                  //**********************************************Payment Account Records Insertion**********************************************************
                                                              }
                                                          }
                                                      }
                                                      return 'SUCCESS#'+listEnrollment[0].Id;
                                                  }catch(Exception e){
                                                      System.debug('@@@@ Error:   '+e.getMessage() + e.getLineNumber());
                                                      Database.rollback(sp);
                                                      return e.getMessage();
                                                  }
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
        @AuraEnabled public Date clsSrtDate;
        @AuraEnabled public boolean isFixed;
        @AuraEnabled public string mode;
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
        @AuraEnabled public Boolean isGlobal;
        @AuraEnabled public Decimal daysBeforeClass;
        public DisWrapper(){
            this.amount   = 0;
            this.isSelected = False;
            this.isOverride = False;
            this.isGlobal = false;
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
        @AuraEnabled public String teacherId;
        @AuraEnabled public time startTime;
        @AuraEnabled public time endTime;
        @AuraEnabled public decimal seatsLeft;
        @AuraEnabled public String dayOfWeek;        
    }
    
    public class StudentDetails{
        @AuraEnabled public List<StudentDetailsWrapper> studentDetail{get;set;}
        public StudentDetails(){
            studentDetail = new List<StudentDetailsWrapper>();
        }
    }
    
    public class StudentDetailsWrapper{
        @AuraEnabled public String FirstName {get;set;}
        @AuraEnabled public String LastName {get;set;}
        @AuraEnabled public Decimal key {get;set;}
        @AuraEnabled public String Gender{get;set;}
        @AuraEnabled public Date PersonBirthdate {get;set;}
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public List<ClassDetailsListWrapper> classDetails {get;set;}
    }
    
    public class ClassDetailsListWrapper{
        @AuraEnabled public ClassDetailWrapper classDetail {get;set;}
        @AuraEnabled public Date enrollmentStartDate {get;set;}
        @AuraEnabled public String comments {get;set;}
        public ClassDetailsListWrapper(){
            classDetail = new ClassDetailWrapper();
            enrollmentStartDate = null;
        }
    }
    
    public class ClassDetailWrapper{
        @AuraEnabled public String classId {get;set;}
        @AuraEnabled public String locationId {get;set;}
        @AuraEnabled public String teacherId {get;set;}
        @AuraEnabled public String teacherName {get;set;}
        @AuraEnabled public String className {get;set;}
        @AuraEnabled public String courseName {get;set;}
        @AuraEnabled public String dayOfWeek {get;set;}
        @AuraEnabled public DateTime startTime {get;set;}
        @AuraEnabled public DateTime endTime {get;set;}
        @AuraEnabled public String location {get;set;}
        @AuraEnabled public String classSessionId {get;set;}
        @AuraEnabled public String  clsType{get;set;}
        @AuraEnabled public String  clsFrequency{get;set;}
        @AuraEnabled public String  mode{get;set;}
        @AuraEnabled public List<ParentFeeWrapper> tuitionFeeList {get;set;}
        @AuraEnabled public List<FeeWrapper> secondaryFeeList {get;set;}
        @AuraEnabled public List<ParentFeeWrapper> depositfeelist{get;set;}
        @AuraEnabled public Decimal classFee {get;set;}
        @AuraEnabled public Decimal gstAmount {get;set;}
        @AuraEnabled public Decimal totalAmount {get;set;}
        @AuraEnabled public Boolean showName {get;set;}
        
        public ClassDetailWrapper(){
            this.tuitionFeeList = new List<ParentFeeWrapper>();
            this.secondaryFeeList = new List<FeeWrapper>();
            this.depositfeelist = new List<ParentFeeWrapper>();
            this.classFee = 0;
            this.gstAmount = 0;
            this.totalAmount = 0;
            this.showName = false;
        }
    }
    
    Public class ParentFeeWrapper{
        @AuraEnabled public String  parentFeeId;
        @AuraEnabled public String  parentFeeName;
        @AuraEnabled public String  parentFeeType;
        @AuraEnabled public String  payFrequency;
        @AuraEnabled public String  frequency;
        @AuraEnabled public Decimal parentTutionFeeUnitPrice;
        @AuraEnabled public Decimal parentAmount;
        @AuraEnabled public Decimal parentProratedAmount;
        @AuraEnabled public Boolean prorate; 
        @AuraEnabled public Boolean required;
        @AuraEnabled public Boolean gstApplicable;                                                          
        @AuraEnabled public List<FeeWrapper> childFeeWrapper;
        public ParentFeeWrapper(){
            childFeeWrapper = new List<FeeWrapper>();
            parentProratedAmount = 0;
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
        @AuraEnabled public Boolean required;
        @AuraEnabled public String  frequency;
        
        public FeeWrapper(){
            this.feeAmount  = 0;
            this.feeProratedAmount  = 0;
            this.tutionFeeUnitPrice = 0;
            this.noOfUnit   = 0;
            this.isSelected = false;
            this.isOverride = false;
            this.isGSTApplicable = false;
        }
    }
    
    public class ACHDetailsWrapper{
        @AuraEnabled public String HolderType;
        @AuraEnabled public String HolderName;
        @AuraEnabled public String RoutingNo;
        @AuraEnabled public String AccountNumber;
        public ACHDetailsWrapper(){}
    }
}