({
	doInitJquery : function(component, event, helper) {
        jQuery("document").ready(function(){
              var action = component.get("c.getCheckinInfo");
       
              action.setParams({ recordId : component.get('v.recordId')});
              action.setCallback(this, function(a) {
                  var state = a.getState();
                  if (state === "SUCCESS") {
                      var result = a.getReturnValue();
                      var containerId = (result.uiContext != 'Theme4t') 
                                      ? 'desktopContainer' 
                                      : 'mobileContainer';

                      //setting user current theme value
                      component.set("v.context",result.uiContext);
                      
                      //when the component is sued on desktop
                      //hidning mobile container, since it has some padding for scrollong,
                      if(result.uiContext != 'Theme4t'){
                          var toggleContainer = component.find("outerScroller");
                          $A.util.toggleClass(toggleContainer, "toggle");
                      }
                      
                      if(result.isError == true){
                          helper.showMessage(component, event, result.messages, containerId);
                      }else{
                          //setting component html based on user context i.e desktop or mobile
                          document.getElementById(containerId).innerHTML=result.htmlBody;
                      }
                  }
                  else if (state === "ERROR") {
                      console.log(a.getError());
                      $A.log("Errors", a.getError());
                  }
              });
              $A.enqueueAction(action);
              
              //binding jquery on click event for links
              jQuery(document).on('click','a',function(e){
                  //alert(jQuery(this).attr("href"));
                  //alert(jQuery(this).attr("href"));
                  //window.open(jQuery(this).attr("href"),"_new"); 
                  
                  //sforce.one.navigateToURL(jQuery(this).attr("href"));
                  var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": jQuery(this).attr("href"),
                      isredirect :true
                    });
                    urlEvent.fire();
                  
                  return false;
              });
          });
     }
})