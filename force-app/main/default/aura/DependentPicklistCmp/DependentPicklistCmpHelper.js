({
    validateFields : function(component,event) {
        if(component.get("v.requiredOrNot")){
            var parentValid = true;  
            var childValid = true;
            if($A.util.isEmpty(component.get("v.parentValue")) || component.get("v.parentValue").includes('None')){
                document.getElementById('parent').classList.add('slds-has-error');
                document.getElementById('parentError').style.display = 'block';
                parentValid = false;
            }else{
                document.getElementById('parent').classList.remove('slds-has-error');
                document.getElementById('parentError').style.display = 'none';
            }
            if(($A.util.isEmpty(component.get("v.childValue")) || component.get("v.childValue").includes('None')) && !component.get("v.disabledChildField")){
                document.getElementById('child').classList.add('slds-has-error');
                document.getElementById('childError').style.display = 'block';
                childValid = false;
            }else{
                document.getElementById('child').classList.remove('slds-has-error');
                document.getElementById('childError').style.display = 'none';
            }
            if(parentValid && childValid)
                component.set("v.requiredCheck",true);
            else
                component.set("v.requiredCheck",false);
        }
    },
})