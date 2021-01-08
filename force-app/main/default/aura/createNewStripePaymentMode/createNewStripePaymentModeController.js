({
    handleChange : function(component, event, helper) {
        var changeValue = event.getParam("value");
        console.log('value : ',changeValue);
        console.log('recordId : ',component.get("v.recordId"));
        $A.util.addClass(component.find("radioGroup"), "slds-hide");
    },
    doInit: function(component,event,helper) {
        console.log('doinit called');
        component.get("v.hasRendered");
        component.set("v.isLoading", false);
        $A.util.removeClass(component.find("radioGroup"), "slds-hide");
        //cmp.set("v.options", "[{'label': 'ACH', 'value': 'ACH'},{'label': 'Card(Credit/Debit)', 'value': 'Card'}]");
        let arr = [];
        console.log('calling init');
        arr.push({'label': 'ACH', 'value': 'ACH'});
        arr.push({'label': 'Credit/Debit Card', 'value': 'Credit/Debit Card'});
        component.set("v.options", arr);
        component.set("v.value", '');
        var pageRef = component.get("v.pageReference");	        
        console.log(JSON.stringify(pageRef));	        
        var state = pageRef.state; // state holds any query params	        
        console.log('state = '+JSON.stringify(state));	        
        var base64Context = state.inContextOfRef;	        
        console.log('base64Context = '+base64Context);	        
        if (base64Context.startsWith("1\.")) {	            
            base64Context = base64Context.substring(2);	            
            console.log('base64Context = '+base64Context);	        
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        console.log('addressableContext = '+JSON.stringify(addressableContext));	        
        component.set("v.recordId", addressableContext.attributes.recordId);
        
    },
    submitACHDetails : function(component,event,helper){
        console.log('submit ACHDetails');
        let achDetails = component.find("achVerficationComponenet").sendDetails();
        console.log('achDetails : ',achDetails);
        console.log('achDetails : ',achDetails[0].HolderName);
        if(achDetails!=null && achDetails.length > 0){
            helper.callApexMethodACH(component,event,helper);
        }
        
    },
    submitCardDetails : function(component, event, helper){
        console.log('submit Card details');
        let cardDetails = component.find("cardComponenet").sendDetails();
        console.log('card Details : ',cardDetails);
        if(cardDetails != null && cardDetails.length>0){
            helper.callApexMethodCard(component,event,helper);
        }
    },
    goBack : function(component, event, helper){
        console.log('back called');
        $A.get('e.force:refreshView').fire();
    },
    backtoMain : function(component, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/r/educato__Payment_Account__c/"+component.get("v.recordId")+"/related/educato__Payment_Accounts__r/view"
        });
        urlEvent.fire();
    },
    showSpinner : function(component, event, helper){
        component.set("v.isLoading", true);
    },
    hideSpinner  : function(component, event, helper){
        component.set("v.isLoading", false);
    },
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
     },
})