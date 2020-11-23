({
    doInit : function(component, event, helper) {
        var pageRef = component.get("v.pageReference");
        
        if(!$A.util.isEmpty(pageRef.state.educato__sessId) && pageRef.state.educato__sessId != 'Undefined')
            component.set("v.sessionId",pageRef.state.educato__sessId);
        //  var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var action = component.get("c.doInitApex");
        action.setCallback(this,function(response){
            if(response.getState() == 'SUCCESS'){
                alert('response==>'+JSON.stringify(response.getReturnValue()))
                if(response.getReturnValue().message.includes('SUCCESS')){
                    component.set("v.listGenderPicklistValues",response.getReturnValue().listGenderPicklistValues);
                    component.set("v.listPaymentModePicklistValues",response.getReturnValue().listPaymentModePicklistValues);
                    component.set("v.maxBirthDate",response.getReturnValue().maxBirthdate);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    handleCorporateIndividualChange :  function(component,event,helper){
        document.getElementById("contactId").value = null;
        component.set("v.isSameAsParent",false);
        component.set("v.contactDetail",component.get("v.resetContactDetail"));
    },
    
    handleMyApplicationEvent : function(component, event, helper) {
        var valueId = event.getParam("selectedOption");  
        var value = event.getParam("inputValue");
        var type = event.getParam("type");
        console.log('@@@@@ check type '+type);
        
        if(type == 'Course'){
            
        }else if(type == 'Contact' || type == 'Corporate' || type == 'SecondaryContact'){
            var action = component.get("c.getSelectedAccount");
            action.setParams({
                "accId" : valueId,
                "isCorporateAccount" : component.get("v.isCorporateAccount")
            });
            action.setCallback(this,function(response){
                if(response.getState() == "SUCCESS"){
                    console.log('hh='+response.getReturnValue())
                    if(response.getReturnValue().length > 0){
                        if(type == 'SecondaryContact'){
                            component.set("v.secondaryContactDetail",response.getReturnValue());
                        }else{
                            console.log(JSON.stringify(response.getReturnValue()))
                            component.set("v.contactDetail",response.getReturnValue());
                            component.set("v.parentValue",response.getReturnValue().BillingCountry);
                        }
                    }
                }
            });            
            $A.enqueueAction(action);
        }else if(type == 'Student'){
            var indx = event.getParam("slctIndex");
            var action = component.get("c.getSelectedAccount");
            action.setParams({
                "accId" : valueId,
                "isCorporateAccount" : false
            });
            action.setCallback(this,function(response){
                if(response.getState() == "SUCCESS"){
                    if(response.getReturnValue().length > 0){
                            
                    }
                }
            });            
            $A.enqueueAction(action);
        }
    },
})