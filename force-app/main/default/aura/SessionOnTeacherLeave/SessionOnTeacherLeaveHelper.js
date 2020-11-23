({
	showToast : function(component, event, type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": type+"!",
            "type" : type,
            "message": msg
        });
        toastEvent.fire();
    }
})