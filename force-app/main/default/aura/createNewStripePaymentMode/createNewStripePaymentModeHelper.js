({
    callApexMethodACH : function(component,event,helper) {
        console.log('callApexMethodACH method called');
        let action = component.get("c.createStripeCustomerAndPaymentModeACH");
        let achDetails = component.find("achVerficationComponenet").sendDetails();
        
        if(achDetails != null){
            action.setParams({
                accountSFId: component.get("v.recordId"),
                country : "US",
                currencyCode : "USD",
                holderName : achDetails[0].HolderName,
                accountHolderType : achDetails[0].HolderType,
                routingNumber : achDetails[0].RoutingNo,
                accountNumber : achDetails[0].AccountNumber,
                //"email" : null
            });
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    console.log("Data has been created");
                    $A.get("e.force:showToast").setParams({
                        title: "Success",
                        type: "success",
                        message: "Account has been created."
                    }).fire();
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get("e.force:refreshView").fire();
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/lightning/r/educato__Payment_Account__c/"+component.get("v.recordId")+"/related/educato__Payment_Accounts__r/view"
                    });
                    urlEvent.fire();
                }else if(response.getState() == "ERROR"){
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error : "+errors[0].message);
                        }
                    } else {
                        console.log("Error");
                    }
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        type: "error",
                        message: ""+errors[0].message
                    }).fire();
                }
            });
            $A.enqueueAction(action);
        }
    },
    callApexMethodCard : function(component,event,helper) {
        console.log('callApexMethodCard method called');
        var action = component.get("c.createStripeCustomerAndPaymentModeCard");
        let achDetails = component.find("cardComponenet").sendDetails();
        console.log('achDetails'+ achDetails);
        console.log('component.get("v.recordId") : ',component.get("v.recordId"));
        console.log(" achDetails[0].CardNumber :: "+ achDetails[0].CardNumber);
        console.log(" achDetails[0].ExpMonth :: "+ achDetails[0].ExpMonth);
        console.log(" achDetails[0].ExpYear :: "+ achDetails[0].ExpYear);
        console.log(" achDetails[0].CVCNumber :: "+ achDetails[0].CVCNumber);
        
        if(achDetails != null){
            action.setParams({
                AccountSFId: component.get("v.recordId"),
                cardNumber : achDetails[0].CardNumber,
                exp_month : achDetails[0].ExpMonth,
                exp_year : achDetails[0].ExpYear,
                cvc : achDetails[0].CVCNumber
            });
            console.log('getParams : ',action.getParams());
            console.log('pring params');
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    console.log("Data has been created");
                    $A.get("e.force:showToast").setParams({
                                                    title: "Success",
                                                    type: "success",
                                                    message: "Card has been created."
                                                }).fire();
                                                $A.get("e.force:closeQuickAction").fire();
                                                $A.get("e.force:refreshView").fire();
                                                var urlEvent = $A.get("e.force:navigateToURL");
                                                urlEvent.setParams({
                                                    "url": "/lightning/r/educato__Payment_Account__c/"+component.get("v.recordId")+"/related/educato__Payment_Accounts__r/view"
                                                });
                                                urlEvent.fire();
                }else if(response.getState() == "ERROR"){
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error : "+errors[0].message);
                        }
                    } else {
                        console.log("Error");
                    }
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        type: "error",
                        message: ""+errors[0].message
                    }).fire();
                }
                
            });
            
        }
        $A.enqueueAction(action);
    },
 })