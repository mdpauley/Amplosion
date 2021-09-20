// ======================
// = POPUP COMMUNICATOR =
// ======================

//console.log("New extension invocation");

browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    function handleResponse(message) {
        sendResponse({ response: message });
    }

    function handleError(error) {
        console.log(`Error: ${error}`);
    }
    
    if (request.type == "fetchWebsiteInfo") {
        var hostname = window.location.hostname;
        
        var sending = browser.runtime.sendMessage({ type: "bgFetchWebsiteInfo", item: hostname });
        sending.then(handleResponse, handleError);
        return true;
    }
});


function handleAllowlistResponse(message) {
    var allowlistItems = message.response;
    
    // ===============
    // = IDENTIFIERS =
    // ===============

    // Activate both immediately, and on DOMNodeInserted. Immediately will cover the case if the user activates the extension after the page has already loaded and isn't doing anything more interesting, and DOMNodeInserted will cover the other cases where the page is potentially changing and it will grab the first occurrence of AMP. DOMNodeInserted is used because Google does all sorts of crazy stuff with replacing the page contents with JavaScript and rewriting the URL so normal page reloads and whatnot are hard to go off of.
    activateAMPSniffingDog();
    document.addEventListener("DOMNodeInserted", onDOMNodeInserted);

    function onDOMNodeInserted(event) {
        activateAMPSniffingDog()
    }

    function activateAMPSniffingDog() {
        if (allowlistItems.includes(window.location.hostname)) {
            return;
        }
        
        if (isAMPPage()) {
            handleAMPPage();
        } else if (isGoogleSearchResultsPage()) {
            handleGoogleSearchResultsPage();
        } else if (isGoogleNewsPage()) {
            handleGoogleNewsPage();
        }
    }

    function isGoogleSearchResultsPage() {
        if (window.location.hostname.includes("google.")) {
            if (document.querySelector("html[itemtype=\"http://schema.org/SearchResultsPage\"]")) {
                // Google uses this to denote a search page
                return true;
            }
        }

        return false;
    }

    function isGoogleNewsPage() {
        if (document.location.hostname.includes("news.google.")) {
            return true;
        } else {
            return false;
        }
    }

    function isAMPPage() {
        // Through inspection and contrary to their docs https://amp.dev/documentation/guides-and-tutorials/learn/spec/amphtml/, Google doesn't seem to use the lightning bolt character to denote AMP pages anymore, rather just an AMP attribute in the HTML. But check both just in case it changes back?
        if (document.querySelector("html[amp]") || document.querySelector("html[⚡]")) {
            return true;
        } else {
            // A second case is when the user activates Amplosion after loading an AMP page in the Google AMP viewer (e.g.: https://www.google.ca/amp/s/www.cnbc.com/amp/2021/09/13/example.html). These cached pages won't have an AMP selector in the HTML, but you can figure things out by looking at the URL scheme and then reading the canonical URL from the head all the same. If they activate Amplosion before loading this page, Amplosion should catch it and fix it in the search results so this shouldn't occur very often.
            // Docs on Google Viewer: https://developers.google.com/search/docs/advanced/experience/about-amp#about-google-amp-viewer
            // Valid URLs are [google domains if they contain /amp/], [ampproject.org], [ampproject.net], and [amp.dev]
            // (Note: Google has a second kind called Signed Exchanges which seeks to fix the Google-y URL problem (see https://developers.google.com/search/docs/advanced/experience/signed-exchange) but Apple doesn't like this and thus doesn't support it in Safari so we don't have to worry about implementing it
            var isGoogleViewer = window.location.hostname.includes("google.") && window.location.pathname.includes("/amp/");
            var isAMPDomain = window.location.hostname.includes("ampproject.org") || window.location.hostname.includes("ampproject.net") || window.location.hostname.includes("amp.dev")
            
            if (isGoogleViewer || isAMPDomain) {
                return true;
            } else {
                return false;
            }
        }
    }

    function findCanonicalURLInPageSource() {
        return document.head.querySelector("link[rel=\"canonical\"]").href;
    }

    // ============
    // = HANDLERS =
    // ============

    function handleGoogleSearchResultsPage() {
        // Go through all the anchors in the Google Search Results page, and prevent Google's JavaScript from triggering, and instead use our own click handler to either:
        //     - If amp-cur dataset attribute available, that's the non-AMP URL, direct them to that immediately (note: not normally available on carousel articles)
        //     - If unavailable, just use the 'normal' href value and we'll redirect once we load that enough to get the canonical URL
        // From there we can actually see the link[rel=canonical] title and use that to redirect the user to the non-AMP version.
        const anchors = document.querySelectorAll("a[data-amp]");

        for (let anchor of anchors) {
            anchor.addEventListener("click", function(event) {
                const canonicalURL = anchor.dataset.ampCur;

                if (canonicalURL) {
                    browser.runtime.sendMessage({ type: "incrementHostname", item: window.location.hostname });
                    window.location.href = canonicalURL;
                } else {
                    handledAmpURL = anchor.href;
                    window.location.href = anchor.href;
                }

                event.preventDefault();
                event.stopImmediatePropagation();
                return false;
            });
        }
    }

    function handleGoogleNewsPage() {
        // Two possible outcomes. The first is if they navigate directly to the Google News hosted URL without the articles list first (or they load Amplosion after navigating to a Google News story). The second is we're on the Google News page that lists a bunch of articles, in which point we can intercept there. Get ready, because both of these solutions suck (but hey they work).
        if (window.location.pathname.includes("/articles/")) {
            // We will rarely hit this situation. Only if the user opens a Google News direct article URL into their browser, or if they activate Amplosion while already in one. Either way we need to handle that. The easy way is just to refresh the page, it confuses Google since it doesn't have the cached AMP content fed into the page with JS anymore, so it just loads the normal article. The issue is getting in a refresh loop, while Google slowly navigates away from news.google.com, so we need to set a variable that indicates we've handled it already. But if we just set it globally in this file, the content script is restarted each time the page reloads, and since we're asking it to refresh, we'll lose any status of having handled it (so it would just keep trying infinitely over and over again). So set it on the actual browser storage so it'll persist. Clunky, but I can't think of anything better!
            browser.storage.local.get((item) => {
                var currentURL = window.location.href;

                // Do it with strings, the way from the WWDC vid (21-10027 @ 7:34) causes a crash seemingly if it's not present
                if (typeof(item["handledGoogleNewsObj"]) !== "undefined") {
                    // It exists!
                    var handledNewsURL = item["handledGoogleNewsObj"]["newsURL"];

                    if (handledNewsURL === currentURL) {
                        // Do nothing, already handled
                        return;
                    } else {
                        // New URL!
                        let handledGoogleNewsObj = {
                            newsURL: currentURL
                        };

                        browser.storage.local.set({handledGoogleNewsObj}, function() {
                            // Setting has completely. Now just reload, it will confuse Google and cause the correct page to load. It hurts itself in its confusion!
                            window.location.reload();
                        });
                    }
                } else {
                    // Has never been set, so we'll set it now and then reload page
                    let handledGoogleNewsObj = {
                        newsURL: currentURL
                    };

                    browser.storage.local.set({handledGoogleNewsObj}, function() {
                        // Setting has completely. Now just reload, it will confuse Google and cause the correct page to load. It hurts itself in its confusion!
                        window.location.reload();
                    });
                }
            });
        } else {
            // This solution is beyond dumb, but long story short since Google just injects the contents of the cached AMP page into the page rather than loading everything, for every anchor on the page just prevent that JavaScript from firing on-click, and instead just make it follow the actual href (shock! horror!), which will Google to get confused (the URL doesn't actually have any content, it's just a cache) and load the actual URL, which we can then intercept and de-AMPify
            const anchors = document.querySelectorAll("a");

            for (let anchor of anchors) {
                anchor.addEventListener("click", function(event) {
                    browser.runtime.sendMessage({ type: "incrementHostname", item: window.location.hostname });
                    window.location.href = anchor.href;
                    
                    // Do all the things!
                    event.preventDefault();
                    event.stopImmediatePropagation();
                    return false;
                });
            }
        }
    }

    var handledAMPURL = "";

    function handleAMPPage() {
        const canonicalURL = findCanonicalURLInPageSource();

        // Sometimes the page's canonical URL can be an AMP URL, so prevent infinite loading loops
        const isDifferentURL = canonicalURL != window.location.href;
        
        // Also prevent it from continually activaitng while we load the change
        const isAlreadyHandled = handledAMPURL == window.location.href;
        
        if (canonicalURL && isDifferentURL && !isAlreadyHandled) {
            handledAMPURL = window.location.href;
            browser.runtime.sendMessage({ type: "incrementHostname", item: window.location.hostname });
            window.location.replace(canonicalURL);
            
            // Prevent further execution of current loading items
            return false;
        }
    }
}

function handleAllowlistError(error) {
    console.log(`Error with allowlist: ${error}`);
}

// Everything starts with getting the Allowlist from UserDefaults, then we can know what to allow through if necessary
var sending = browser.runtime.sendMessage({ type: "getAllowlist" });
sending.then(handleAllowlistResponse, handleAllowlistError);
