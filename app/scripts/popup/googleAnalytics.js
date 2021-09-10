(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
    
//Using localStorage to store the Client ID. In order to track users accross sessions...
//...@see: https://developers.google.com/analytics/devguides/collection/analyticsjs/cookies-user-id#using_localstorage_to_store_the_client_id
var GA_LOCAL_STORAGE_KEY = 'ga:clientId';
var szTrackingID = 'UA-133691543-6';

if (window.localStorage) {
    ga('create', szTrackingID, {
    'storage': 'none',
    'clientId': localStorage.getItem(GA_LOCAL_STORAGE_KEY)
    });
    ga(function(tracker) {
    localStorage.setItem(GA_LOCAL_STORAGE_KEY, tracker.get('clientId'));
    });
}
else {
    ga('create', szTrackingID, 'auto');
}

ga('set', 'checkProtocolTask', null); //Removes necesary check against HTTP or HTTPS since the protocol is extension:

ga('require', 'displayfeatures');

ga('send', 'event', 'OpenExtension', 'OpenExtension', 'OpenExtension', {nonInteraction: true});

//Function to track PageViews as users navigate tabs.
function trackPageViews(element){

    let pageName = element.innerText.replace(/\s+/g, '').toLowerCase();
    let pagePath = '/' + pageName + '.html';
    ga('send', 'pageview', pagePath, {title: pageName});
    console.log(`PageViewExecuted for Pagetitle: ${pageName} PAGEPATH: ${pagePath}`);
}

//Tracks Simple Click Buttons. Reviews the element clicked, and determines proper tracking based on its context. 
function trackEvent(element, con){

    let context = con;
    let parent = element[0].parentElement.id;
    let category;
    let label;
    let action;

    //When no context is implictly passed; determine tracking context from Parent element
    if(context === null || context === "undefined" || context === ""){
        
        if(parent === "cmds_container"){
            context = "commands";
            
        }
        if (parent === "mdm-tab"){
            context = "mdm";
        }
        console.log("CONTEXT: ", context)

    }
    
    //Trigger Tracking based on context of the event.
    switch(context){
        case "commands": 
            category = "commands_Interactions";
            action= "commandType_" + element.parent()[0].ariaLabel;
            label = element[0].innerText.trim().split("\n");
            ga('send', 'event', category, action, label[0]);
            console.log(`GA EVENT TRIGGERED: Category: ${category}, Action: ${action}, Label: ${label}`);
            break;

        case "mdm": 
            category = "MDM_Interactions"
            action= "ButtonClicked_" + element[0].innerText.trim().split("!")[0];
            label = element[0].innerText.trim().split("\n")[0];
            ga('send', 'event', category, action, label);
            console.log(`Category: ${category}, Action: ${action}, Label: ${label}`);
    }

    
}