# Amplosion ⚡️

Amplosion is an iOS 15 and greater app that automagically redirects AMP links to their normal counterpart. AMP links can be super annoying, so this helps make your web browsing experience a bunch more delightful.

### Why Open Source 🔒

Safari extensions require your permission to run, so in the interest of transparency I wanted to make the app completely open source. Amplosion's Privacy Policy already states that it's completely private (everything is handled locally, on-device) but why trust my words when you can go through the code itself? My intention is for this to serve as an extra layer of validation that Amplosion is a privacy-first app, and seeks simply to make your web browsing experience more pleasant. 

### How it Works 🛠

Amplosion is a Safari extension. Once enabled, when the page loads, Amplosion checks if the current page is an AMP page, and if so, reads the page headers to find the "canonical" (AKA normal) link, and redirects the browser to that page instead. Amplosion prefers the "All Websites" permission so that it can, well, fix AMP pages on any website!

The AMP redirection is all done in JavaScript. To see this AMP redirection code, it's located in Amplosion Extension > Resources. The `content.js` file does the majority of the heavy-lifting in terms of redirecting away from AMP. The `background.js` file and the `SafariWebExtensionHandler.swift` file act as communication layers with the main app (enabling you to add items to your Allowlist, if you so choose, for instance). Lastly the `popover*` files are the "UI" for the extension when you select them in Safari, showing you the current page's stats and the ability to add it to the Allowlist.

### Other 🐶

While the JavaScript is the "brains" of the app, there's also an actual app component, that mostly just exists for fun. It has a pet digital dog style mini-game, plus all your stats for Amplosion, and the ability to change the app's home screen icon. There's also code for the home screen widgets in there if you're interested!

### Questions? 🙋

If you have any questions or suggestions, feel free to open an issue on GitHub, or hit me up on Twitter [@ChristianSelig](https://twitter.com/christianselig).
