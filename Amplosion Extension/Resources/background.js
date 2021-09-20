browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    function gotNativeResponse(nativeResponse) {
        sendResponse({ response: nativeResponse });
    }

    function gotNativeError(error) {
        sendResponse({ response: `Error: ${error}` });
    }

    if (request.type == "incrementHostname") {
        browser.runtime.sendNativeMessage("com.christianselig.Amplosion", { message: request.type, item: request.item });
    } else if (request.type == "getAllowlist") {
        var sending = browser.runtime.sendNativeMessage("com.christianselig.Amplosion", { message: request.type });
        sending.then(gotNativeResponse, gotNativeError);

        // Required seemingly as the sendNativeMessage call is asynchronous
        return true;
    } else if (request.type == "addToAllowlist") {
       var sending = browser.runtime.sendNativeMessage("com.christianselig.Amplosion", { message: request.type, item: request.item });
       sending.then(gotNativeResponse, gotNativeError);
       return true;
    } else if (request.type == "bgFetchWebsiteInfo") {
        var sending = browser.runtime.sendNativeMessage("com.christianselig.Amplosion", { message: request.type, item: request.item });
        sending.then(gotNativeResponse, gotNativeError);
        return true;
    } else if (request.type == "addToAllowlist") {
        browser.runtime.sendNativeMessage("com.christianselig.Amplosion", { message: request.type, item: request.item });
    } else if (request.type == "removeFromAllowlist") {
        browser.runtime.sendNativeMessage("com.christianselig.Amplosion", { message: request.type, item: request.item });
    }
});
