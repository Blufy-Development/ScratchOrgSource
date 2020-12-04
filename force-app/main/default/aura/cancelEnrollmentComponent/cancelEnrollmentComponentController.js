({
    doInit : function(component, event, helper){
        component.set("v.enrolmentId", component.get("v.recordId")); 
        console.log('test',component.get("v.enrolmentId"));
    },
    handleupdateEnrollment: function(component, event, helper){
        var state = event.getParam("state");
        var succesMessage = event.getParam("succesMessage");
        if(state =='Success'){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": succesMessage,
                "type" : "success"
            });
            toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
        }else if(state =='Cancel'){
            $A.get("e.force:closeQuickAction").fire();
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": succesMessage,
                "type" : "error"
            });
            toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
        }
    }
})