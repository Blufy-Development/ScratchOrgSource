public class ScheduleHandler implements ScheduleDispatchedInterface {
    public static String className; 
   	public void execute(SchedulableContext sc, String className){
        System.debug('ScheduleHandler\'s execute method is called :: '+className);
        Type targettype = Type.forName(className);
        if(targettype.getName() == 'educato.StripeAccountVerifyBatch'){
            Database.executeBatch((StripeAccountVerifyBatch)targettype.NewInstance());  
        }
        else if(targettype.getName() == 'educato.StripePaymentBatch'){
            Database.executeBatch((StripePaymentBatch)targettype.NewInstance());  
        }
        else if(targettype.getName() == 'educato.StripeChargeVerifyBatch'){
            Database.executeBatch((StripeChargeVerifyBatch)targettype.NewInstance());  
        }
    }   
}