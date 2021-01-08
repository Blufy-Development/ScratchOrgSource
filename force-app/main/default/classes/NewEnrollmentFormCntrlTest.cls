@isTest
public class NewEnrollmentFormCntrlTest {
    
    public static testmethod void validateNewEnrollmentFormCntrl(){
        Account locationObj = BlufyTestUtil.createLocationRec('New Harbor');
        insert locationObj;
        
        Account teacherObj = BlufyTestUtil.createTeacherRec('Jonas', locationObj.Id);
        insert teacherObj;
        
        Account studentObj = BlufyTestUtil.createStudentRec('Gates','test1@gmail.com');
        insert studentObj;
        
        Course__c courseObj = BlufyTestUtil.createCourseRec('French', 'Active','XYZ-01');
        insert courseObj;
        
        Class__c classObj = BlufyTestUtil.createClassRec('Name', courseObj.Id, 'Classroom', 'Open', teacherObj.Id, 20,
                                                         'Fixed', 24, Date.today().addDays(1), Time.newInstance(10, 00, 00, 00),
                                                         'One-time',null);
        classObj.Days_of_Week__c 	  = 'Fri;Mon;Tue;Wed;Sat;Thu;Sun';
        classObj.Location__c          = locationObj.Id;
        classObj.End_Date__c = Date.today().addMonths(6);
        insert classObj;
        
        Class_Session__c clsSess = BlufyTestUtil.createClassSessionRec(classObj.Id,Time.newInstance(10,30,00,00),'120');
        insert clsSess;
        
        Term__c termObj = BlufyTestUtil.createTermRec('Term 1',String.valueOf(Date.today().year()), 'Open',Date.today().addDays(1),Date.today().addMonths(6),12,1 );
        insert termObj;
        
        Class_Term__c classTermObj = BlufyTestUtil.createClassTerms('Term 1',classObj.id,14,Date.today().addDays(1),Date.today().addMonths(6),1, ConstantClass.ScheduledStatus ,termObj.id);
        insert classTermObj;
        
        Room__c roomObj = BlufyTestUtil.createRoom(locationObj.Id, 'Room1', 'Group', 35);
        insert roomObj;
        
        Session__c sessionObj = BlufyTestUtil.createSessionRec(locationObj.Id,teacherObj.Id, classObj.Id, Date.today().addDays(7), Time.newInstance(10, 00, 00, 00), 'Scheduled', '', '60','Standard', roomObj.Id);
        insert sessionObj;
        
        Account customerObj = new Account(LastName = 'lie',personEmail = 'Test1@gmail.com',RecordTypeId =ConstantClass.customerRecTypeId);
        insert customerObj;
        
        Account customerObjUpdate = new Account(Id = customerObj.id, Phone = '1234567890', Block__c= 'Test', Unit__c ='Test', 
                                                BillingStreet = 'Test', BillingPostalCode = '201301', BillingCountry = 'India',
                                                Gender__c = 'Male', PersonBirthDate = Date.today(),
                                                Relationship_with_contact__c = 'Self');
        update customerObjUpdate;
        
        Enrollment__c enrollObj = BlufyTestUtil.createEnrollment(classObj.Id, Date.newInstance(2020,03,24), locationObj.Id, studentObj.Id,ConstantClass.enrolledStatus, true,  Date.newInstance(2020,03,24),customerObj.id);
        insert enrollObj;
        
        Enrollment__c enrollObjUpdate = new Enrollment__c(Id = enrollObj.Id, Parent_Email__c = 'Test@gmail.com'); 
        
        Student_Session__c studentSessionObj = BlufyTestUtil.createStudentSession(sessionObj.Id, 'Scheduled', studentObj.Id, enrollObjUpdate.id);
        insert studentSessionObj;
        
        Fee__c feeObj = BlufyTestUtil.createFeeRecords('Math Monthly Fee','Tuition Fee',200,true,true,'Ongoing','Monthly',2,90);
        feeObj.Invoice_Label__c = 'test';
        feeObj.Prorate__c = true;
        insert feeObj;
        
        Fee__c secondaryFeeObj = BlufyTestUtil.createFeeRecords('Math Secondary Fee','Other Fee',120,true,true,'Fixed','One-Time',2,90);
        secondaryFeeObj.RecordTypeId = ConstantClass.secondaryFeeRecordTypeId;
        secondaryFeeObj.Prorate__c = true;
        secondaryFeeObj.Invoice_Label__c = 'test';
        secondaryFeeObj.Parent__c = feeObj.Id;
        insert secondaryFeeObj;
        
        Course_Fee__c courseFee = BlufyTestUtil.createCourseFee(courseObj.Id,feeObj.Id);
        insert courseFee;
        
        Discount__c discount = BlufyTestUtil.createDiscount('testing',ConstantClass.discountType,Date.today().addDays(1),Date.today().addMonths(1),'Active','Amount',500,true);
        insert discount;
        
        Course_Discount__c courseDiscount =  BlufyTestUtil.createCourseDiscunt(courseObj.Id,discount.Id);
        insert courseDiscount;
        
        NewEnrollmentFormCntrl.ClassWrapper clsWrp = new NewEnrollmentFormCntrl.ClassWrapper();
        clsWrp.recNo = 1;
        clsWrp.clsId = classObj.Id;
        clsWrp.clsType = classObj.Type__c;
        clsWrp.clsFrequency = classObj.Frequency__c;
        clsWrp.locationId = locationObj.Id;
        clsWrp.location = locationObj.Name;
        clsWrp.clsDays = classObj.Days_of_Week__c;
        clsWrp.teacherName = classObj.Teacher__r.Name;
        clsWrp.slctClsTermId = classTermObj.Id;
        clsWrp.slctclsTermName = classTermObj.Name;
        clsWrp.fees = 400;
        
        Test.startTest();
        NewEnrollmentFormCntrl.fetchClassDetails(courseObj.id);
        NewEnrollmentFormCntrl.fetchFessDetail(clsSess.Id);
        NewEnrollmentFormCntrl.getClassSessionData(clsSess.Id);
        NewEnrollmentFormCntrl.getBlufyConfigDetails();
        NewEnrollmentFormCntrl.getchSlcdAccDetails(customerObj.Id, true);
        
        discount.Global__c = true;
        discount.Start_Date__c = system.today().addDays(-2);
        update discount;
        NewEnrollmentFormCntrl.fetchOtherDiscount();
        
        
        NewEnrollmentFormCntrl.fetchOtherDiscount();
        
        discount.Type__c = 'Discount';
        update discount;
        NewEnrollmentFormCntrl.fetchOtherDiscount();
        
        NewEnrollmentFormCntrl.getPicklistValues(ConstantClass.nameSpace + 'Discount__c',ConstantClass.nameSpace + 'Type__c');
        
        discount.Days_Before_Class__c = 1;
        update discount;
        
        feeObj.Schedule__c = 'Fixed';
        feeObj.Frequency__c = 'One-Time';
        update feeObj;
        CourseDiscountService.getCourseDiscountByCourseId(null);
        Test.stopTest();
    }
    
    public static testmethod void validateNewEnrollmentFormCntrl1(){
        Account locationObj = BlufyTestUtil.createLocationRec('New Harbor');
        insert locationObj;
        
        Account teacherObj = BlufyTestUtil.createTeacherRec('Jonas', locationObj.Id);
        insert teacherObj;
        
        Account studentObj = BlufyTestUtil.createStudentRec('Gates','test1@gmail.com');
        studentObj.FirstName = 'Bill';
        insert studentObj;
        
        Course__c courseObj = BlufyTestUtil.createCourseRec('French', 'Active','XYZ-01');
        insert courseObj;
        
        Class__c classObj = BlufyTestUtil.createClassRec('Name', courseObj.Id, 'Classroom', 'Open', teacherObj.Id, 20,
                                                         'Ongoing', 24, Date.today().addDays(1), Time.newInstance(10, 00, 00, 00),
                                                         'Term',null);
        classObj.Days_of_Week__c 	  = 'Fri;Mon;Tue;Wed;Sat;Thu;Sun';
        classObj.Location__c          = locationObj.Id;
        classObj.End_Date__c = Date.today().addMonths(6);
        insert classObj;
        
        Class_Session__c clsSess = BlufyTestUtil.createClassSessionRec(classObj.Id,Time.newInstance(10,30,00,00),'120');
        clsSess.Teacher__c = teacherObj.Id;
        clsSess.Start_Time__c = Time.newInstance(10, 00, 00, 00);
        insert clsSess;
        
        Term__c termObj = BlufyTestUtil.createTermRec('Term 1',String.valueOf(Date.today().year()), 'Open',Date.today().addDays(1),Date.today().addMonths(6),12,1 );
        insert termObj;
        
        Class_Term__c classTermObj = BlufyTestUtil.createClassTerms('Term 1',classObj.id,14,Date.today().addDays(1),Date.today().addMonths(6),1, ConstantClass.ScheduledStatus ,termObj.id);
        insert classTermObj;
        
        Room__c roomObj = BlufyTestUtil.createRoom(locationObj.Id, 'Room1', 'Group', 35);
        insert roomObj;
        
        Session__c sessionObj = BlufyTestUtil.createSessionRec(locationObj.Id,teacherObj.Id, classObj.Id, Date.today().addDays(7), Time.newInstance(10, 00, 00, 00), 'Scheduled', '', '60','Standard', roomObj.Id);
        sessionObj.Class_Session__c = clsSess.Id;
        insert sessionObj;
        
        sessionObj.Class_Term__c = classTermObj.Id;
        update sessionObj;
        
        Account customerObj = new Account(LastName = 'lie',personEmail = 'Test1@gmail.com',RecordTypeId =ConstantClass.customerRecTypeId);
        insert customerObj;
        
        Account customerObjUpdate = new Account(Id = customerObj.id, Phone = '1234567890', Block__c= 'Test', Unit__c ='Test', 
                                                BillingStreet = 'Test', BillingPostalCode = '201301', BillingCountry = 'India',
                                                Gender__c = 'Male', PersonBirthDate = Date.today(),
                                                Relationship_with_contact__c = 'Self');
        Account customerObjUpdate1 = new Account(RecordTypeId = ConstantClass.customerRecTypeId,FirstName='Nick',LastName='Thomas',Phone = '1234567890', 
                                               personEmail = 'Test17@gmail.com',
                                                Gender__c = 'Male', PersonBirthDate = Date.today(),
                                                Relationship_with_contact__c = 'Self');
        update customerObjUpdate;
        
        Fee__c feeObj = BlufyTestUtil.createFeeRecords('Math Monthly Fee',ConstantClass.tutionFeeType,250,true,true,'Ongoing','Monthly',2,90);
        feeObj.Prorate__c = true;
        feeObj.Invoice_Label__c = 'test';
        insert feeObj;
        
        Fee__c feeObj1 = BlufyTestUtil.createFeeRecords('Deposit Fee',ConstantClass.depositFeeType,200,true,true,'Fixed','One-Time',2,90);
        feeObj1.Prorate__c = true;
        feeObj1.Invoice_Label__c = 'test';
        insert feeObj1;
        
        Course_Fee__c courseFee = BlufyTestUtil.createCourseFee(courseObj.Id,feeObj.Id);
        insert courseFee;
        
        Discount__c discount = BlufyTestUtil.createDiscount('testing',ConstantClass.discountType,Date.today().addDays(1),Date.today().addMonths(1),'Active','Amount',500,true);
        insert discount;
        
        Course_Discount__c courseDiscount =  BlufyTestUtil.createCourseDiscunt(courseObj.Id,discount.Id);
        insert courseDiscount;
        
        NewEnrollmentFormCntrl.ClassWrapper clsWrp = new NewEnrollmentFormCntrl.ClassWrapper();
        clsWrp.recNo = 1;
        clsWrp.clsId = classObj.Id;
        clsWrp.clsType = classObj.Type__c;
        clsWrp.clsFrequency = classObj.Frequency__c;
        clsWrp.locationId = locationObj.Id;
        clsWrp.location = locationObj.Name;
        clsWrp.clsDays = classObj.Days_of_Week__c;
        clsWrp.teacherName = classObj.Teacher__r.Name;
        clsWrp.slctClsTermId = classTermObj.Id;
        clsWrp.slctclsTermName = classTermObj.Name;
        clsWrp.fees = 400;
        String parentWapper = '[{';
        parentWapper += '"childFeeWrapper": [],';
        parentWapper += '"frequency": "Ongoing",';
        parentWapper += '"gstApplicable": true,';
        parentWapper += '"parentAmount": 140,';
        parentWapper += '"parentFeeId": "'+feeObj.Id+'",';
        parentWapper += '"parentFeeName": "Discounted Monthly Fee",';
        parentWapper += '"parentFeeType": "Tuition Fee",';
        parentWapper += '"parentProratedAmount": 120,';
        parentWapper += '"parentTutionFeeUnitPrice": 35,';
        parentWapper += '"payFrequency": "Monthly",';
        parentWapper += '"prorate": true,';
        parentWapper += '"required": true';
        parentWapper += '}]';
        
        String depositWrapper = '[{';
        depositWrapper += '"childFeeWrapper": [],';
        depositWrapper += '"frequency": "Ongoing",';
        depositWrapper += '"gstApplicable": true,';
        depositWrapper += '"parentAmount": 200,';
        depositWrapper += '"parentFeeId": "'+feeObj1.Id+'",';
        depositWrapper += '"parentFeeName": "Deposit Monthly Fee",';
        depositWrapper += '"parentFeeType": "Deposit Fee",';
        depositWrapper += '"parentProratedAmount": 0,';
        depositWrapper += '"parentTutionFeeUnitPrice": 35,';
        depositWrapper += '"payFrequency": "Monthly",';
        depositWrapper += '"prorate": true,';
        depositWrapper += '"required": true';
        depositWrapper += '}]';
        
        List<NewEnrollmentFormCntrl.ParentFeeWrapper> tuitionFee = (List<NewEnrollmentFormCntrl.ParentFeeWrapper>)JSON.deserialize(parentWapper, List<NewEnrollmentFormCntrl.ParentFeeWrapper>.class);
        List<NewEnrollmentFormCntrl.ParentFeeWrapper> depositFee = (List<NewEnrollmentFormCntrl.ParentFeeWrapper>)JSON.deserialize(depositWrapper, List<NewEnrollmentFormCntrl.ParentFeeWrapper>.class);
        NewEnrollmentFormCntrl.ClassDetailWrapper clsDetailWrap = new NewEnrollmentFormCntrl.ClassDetailWrapper();
        clsDetailWrap.classId = clsWrp.clsId;
        clsDetailWrap.locationId = clsWrp.locationId;
        clsDetailWrap.teacherId = teacherObj.Id;
        clsDetailWrap.teacherName = classObj.Teacher__r.Name;
        clsDetailWrap.className = classObj.Name;
        clsDetailWrap.courseName = classObj.Course__r.Name;
        clsDetailWrap.dayOfWeek = clsWrp.clsDays;
        clsDetailWrap.startTime = DateTime.newInstance(Date.today(),Time.newInstance(10, 00, 00, 00));
        clsDetailWrap.endTime = DateTime.newInstance(Date.today(),Time.newInstance(12, 00, 00, 00));
        clsDetailWrap.location = locationObj.Name;
        clsDetailWrap.classSessionId = clsSess.Id;
        clsDetailWrap.clsType = clsWrp.clsType;
        clsDetailWrap.clsFrequency = clsWrp.clsFrequency;
        clsDetailWrap.mode = 'Full-Time';
        clsDetailWrap.classFee = 600;
        clsDetailWrap.gstAmount = 20;
        clsDetailWrap.totalAmount = 500;
        clsDetailWrap.showName = true;
        clsDetailWrap.tuitionFeeList = tuitionFee;
        clsDetailWrap.depositfeelist = depositFee;
        
        NewEnrollmentFormCntrl.ClassDetailsListWrapper clsDetailWrapList = new NewEnrollmentFormCntrl.ClassDetailsListWrapper();
        clsDetailWrapList.classDetail = clsDetailWrap;
        clsDetailWrapList.enrollmentStartDate = Date.today();
        
        NewEnrollmentFormCntrl.StudentDetailsWrapper stuDetail = new NewEnrollmentFormCntrl.StudentDetailsWrapper();
        stuDetail.FirstName = studentObj.FirstName;
        stuDetail.Gender = 'Male';
        stuDetail.LastName = 'Gates';
        stuDetail.PersonBirthdate = Date.today().addYears(-22);
        stuDetail.key = 0007788;
        stuDetail.classDetails = new list<NewEnrollmentFormCntrl.ClassDetailsListWrapper>{clsDetailWrapList};
            
            NewEnrollmentFormCntrl.StudentDetails stuDetailsList = new NewEnrollmentFormCntrl.StudentDetails();
        stuDetailsList.studentDetail = new List<NewEnrollmentFormCntrl.StudentDetailsWrapper>{stuDetail};
       /*     NewEnrollmentFormCntrl.ACHDetailsWrapper achDetails = new NewEnrollmentFormCntrl.ACHDetailsWrapper();
        achDetails.HolderType = 'test';
        achDetails.HolderName = 'Testimg';
        achDetails.RoutingNo = 'tyy890';
        achDetails.AccountNumber = 'ACHt677';
        List<NewEnrollmentFormCntrl.ACHDetailsWrapper> listACH = new List<NewEnrollmentFormCntrl.ACHDetailsWrapper>{achDetails};*/
        Test.startTest();
        NewEnrollmentFormCntrl.getchSlcdAccDetails(customerObj.Id, true);
        NewEnrollmentFormCntrl.calculateProratedAmount(clsSess.Id, parentWapper, system.today());
        NewEnrollmentFormCntrl.CustomerWrapper custWrp = new NewEnrollmentFormCntrl.CustomerWrapper();
        custWrp.studentDetails = studentObj;
        custWrp.stuRecNo = 1;
        List<NewEnrollmentFormCntrl.CustomerWrapper> listTest = new List<NewEnrollmentFormCntrl.CustomerWrapper>{custWrp};   
        NewEnrollmentFormCntrl.doSaveEnrollmentApex(JSON.serialize(stuDetailsList), JSON.serialize(customerObjUpdate),JSON.serialize(customerObjUpdate), 'Confirm', 800,'5590', 'Test', 'Cash','');
        NewEnrollmentFormCntrl.doSaveEnrollmentApex(JSON.serialize(stuDetailsList), JSON.serialize(customerObjUpdate1),JSON.serialize(customerObjUpdate1), 'Save As Draft', 800,'678', 'testing', 'Cash','');
        Test.stopTest();
        List<Enrollment__c> enrList = [SELECT Id,(SELECT Id FROM Student_Sessions__r) FROM Enrollment__c LIMIT 1];
        if(enrList.size() > 0){
            Enrollment__c enrol = enrList.get(0);
            system.assertEquals(1,enrol.Student_Sessions__r.size());
        }
    }
}