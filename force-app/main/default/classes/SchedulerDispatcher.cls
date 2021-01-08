global class SchedulerDispatcher Implements Schedulable{
    public String className;
    public SchedulerDispatcher(String st){
        this.className = st;
    }
    global void execute(SchedulableContext sc) 
    {
        System.debug('SchedulerDispatcher execute method called');
        Type targettype = Type.forName('ScheduleHandler');   
        if(targettype!=null) {
            ScheduleDispatchedInterface obj = (ScheduleDispatchedInterface)targettype.NewInstance();
            obj.execute(sc, className);   
        } 
    } 
 
}