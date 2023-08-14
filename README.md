Demdex Requests Handler is a GTM server-side client designed to capture and handle requests which Adobe Analytics VisitorAPI.js makes to the [dmp.demdex.net domain](https://experienceleague.adobe.com/docs/id-service/using/intro/id-request.html?lang=en).

The main purpose for the client is to set demdex cookie in the first party context to avoid ITP in Safari browsers.

Adobe Analytics data collection server (dmp.demdex.net) uses demdex cookie value and organization ID to generate AMCV cookie. AMVC cookie contains the Experience Cloud visitor ID or MID which is used as a visitor id in Adobe Analytics reports.

Demdex Requests Handler works in a pretty simple way:

1) captures request and redirects it to the dmp.demdex.net
2) captures response from the dmp.demdex.net with set demdex cookie header
3) changes domain attribute in the set demdex cookie header to the first party domain
4) returns the response back to browser

With such approach demdex cookie is a http cookie and set in the first party context which means that it is not rejected in Safari browsers.
