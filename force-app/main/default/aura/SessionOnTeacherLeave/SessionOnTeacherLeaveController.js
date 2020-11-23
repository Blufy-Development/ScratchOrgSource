({
	  doInit : function(component,event,helper){
      /*  var recordId = component.get("v.recordId");
        // alert(recordId);
        var action = component.get("c.generateSession");
        action.setParams({
            "clsTermId": recordId
        });
        action.setCallback(this,function(result){
            var res = result.getReturnValue();
            //alert(JSON.stringify(res));
            if(res.length > 0){
                component.set("v.sessionList",res);
            }else{                
                helper.showToast(component,event,"Error","Only draft class term can be schedule.");
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        
        $A.enqueueAction(action);*/
    },
})