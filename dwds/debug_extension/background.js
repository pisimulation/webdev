chrome.browserAction.onClicked.addListener(function () {
    var query = { active: true, currentWindow: true };
    var currentTab;
    var paused = false;
    function debug() {
        if (!paused) {
            chrome.debugger.sendCommand({ "tabId": currentTab.id }, "Debugger.pause");
            paused = true;
        } else {
            chrome.debugger.sendCommand({ "tabId": currentTab.id }, "Debugger.resume");
            paused = false;
        }
    }
    function callback(tabs) {
        //console.log(window);
        currentTab = tabs[0]; // there will be only one in this array
        chrome.debugger.attach({ "tabId": currentTab.id }, "1.3");
        chrome.debugger.sendCommand({ "tabId": currentTab.id }, "Debugger.enable", {}, function(result) {
            console.log(result);
        });
        console.log("PIIIIIIIIIIIIIIII from background.js");
        chrome.debugger.sendCommand({"tabId": currentTab.id}, "Runtime.evaluate", {"expression": "\$dwdsPort"}, function(result) {
            console.log(result.result.value);
        });
        
        //debug();
        //setInterval(debug, 1000);
    };
    chrome.tabs.query(query, callback);
    //console.log(piVar);
    //PI: look for injected "DART" and extension server
    //PI: get extension endpoint address
    //PI: get DevTools URL
    //PI: launch DevTools URL in new tab
    
});


