window.addEventListener("DOMContentLoaded", (event) => {
    var hostname = "";
    var addButton = document.getElementById("add-to-allowlist");
    var removeButton = document.getElementById("remove-from-allowlist");
    
    // Response handlers
    
    function handleResponse(message) {
        console.log(message.response, message.response.response);
        
        hostname = message.response.response.hostname;
        
        document.getElementById("total-amplosions").innerHTML = message.response.response.amplosions;
        document.getElementById("site-title").innerHTML = hostname;
        
        var isOnAllowlist = message.response.response.isOnAllowlist;
        
        if (isOnAllowlist) {
            removeButton.style.display = "inline";
        } else {
            addButton.style.display = "inline";
        }
    }

    function handleError(error) {
        console.log(`Error: ${error}`);
    }
    
    // The potatoes
        
    // Hide them to begin, and then unhide them when we know which to show
    addButton.style.display = "none";
    removeButton.style.display = "none";
    
    addButton.addEventListener("click", (event) => {
        browser.runtime.sendMessage({ type: "addToAllowlist", item: hostname });
        addButton.style.display = "none";
        removeButton.style.display = "inline";
    });
    
    removeButton.addEventListener("click", (event) => {
        browser.runtime.sendMessage({ type: "removeFromAllowlist", item: hostname });
        addButton.style.display = "inline";
        removeButton.style.display = "none";
    });

    browser.tabs.query({active: true, currentWindow: true}, function (tabs) {
        // Sends a message to the content script which finds the current page, which then talks to the background script to talk to the native extension, which then returns to this popup script the the site's name, total amplosions for this site, and whether it's on the allowlist
        var sending = browser.tabs.sendMessage(tabs[0].id, { type: "fetchWebsiteInfo" });
        sending.then(handleResponse, handleError);
    });
});
