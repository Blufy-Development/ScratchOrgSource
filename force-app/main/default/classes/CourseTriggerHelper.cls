public class CourseTriggerHelper {

    public static void checkEnrollmentBeforeCourseDeletion(List<Course__c> listCourse){
        Set<String> setCourseId = new Set<String>();
        Set<String> setCourseIdContainingEnrollment = new Set<String>();
        
        for(Course__c course : listCourse){
            setCourseId.add(course.Id);
        }
        
        if(setCourseId.size() > 0){
            List<Class__c> listClassWithEnrollment = ClassService.getClassAlongContainEnrollmentByCourseId(setCourseId);
            if(listClassWithEnrollment != NULL && listClassWithEnrollment.size() > 0){
                for(Class__c cls : listClassWithEnrollment){
                    if(cls.Enrollments__r.size() > 0)
                        setCourseIdContainingEnrollment.add(cls.Course__c);
                }
            }
        }
        
        if(setCourseIdContainingEnrollment.size() > 0){
            for(Course__c course : listCourse){
                if(setCourseIdContainingEnrollment.contains(course.Id))
                    course.addError('You can not delete a course having associated enrollment(s)');
            }
        }
    }
}