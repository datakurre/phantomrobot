###
Copyright (C) 2011-2012  Asko Soukka <asko.soukka@iki.fi>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
###


advanced_keyword "Open browser",
"""
Opens a new browser instance to given URL.

Returns the index of this browser instance which can be used later to switch
back to it. Index starts from 1 and is reset back to it when Close All Browsers
keyword is used. See Switch Browser for example.

``url`` is an optional url to open.

``browser`` is an optional parameter that exists to support SeleniumLibarary
and is just ignored.

``alias`` is an optional alias for the browser instance and it can be used for
switching between browsers similarly as the index. See Switch Browser for more
details about that.
""",
([url, browser, alias], callback) ->
    browser = do require("webpage").create
    browser.viewportSize = width: 1024, height: 768

    #
    # Init browser (page) intance with a lot of magic.
    #
    initBrowser = (browser) ->

        #
        # Store and log an alert message.
        #
        browser.onAlert = (msg) ->
            browser._lastAlertMessage = msg
            robot.debug "alert: #{msg}"

        #
        # Store and log a console message.
        #
        browser.onConsoleMessage = (msg) ->
            browser._lastConsoleMessage = msg
            robot.debug "console.log: #{msg}"

        #
        # Prevent new actions before the current page has been loaded;
        # the magic here is to store the last resource request before
        # onLoadStarted and follow that request to be completed.
        #
        browser.robotIsLoading = false
        browser.robotIsLoadingURL = null
        browser.onLoadStarted = -> browser.robotIsLoading = true
        browser.onResourceRequested = (request) ->
            if not browser.robotIsLoading
                browser.robotIsLoadingURL = request.url
        browser.onResourceReceived = (request) ->
            if browser.robotIsLoading\
                and request.url == browser.robotIsLoadingURL
                    browser.robotIsLoading = false

        #
        # Define generic query-method to be available in eval.
        #
        queryAll = (element, locator, assign_to_id=null) ->
            results = []
            if locator of (document._robotIds or {})
                results.push document._robotIds[locator]
            else if /^css=(.*)/.test locator
                css = locator.match(/^css=(.*)/)[1]
                for result in element.querySelectorAll(css)
                    results.push result
            else if /^xpath=(.*)/.test locator
                xpath = locator.match(/xpath=(.*)/)[1]
                # Evaluate an XPath expression aExpression against a given DOM
                # node or Document object (aNode), returning the results as an
                # array thanks wanderingstan at morethanwarm dot mail dot com
                # for the initial work.
                # https://developer.mozilla.org/en/Using_XPath
                xpe = do new XPathEvaluator
                nsResolver = xpe.createNSResolver document
                iterator = xpe.evaluate xpath, document, nsResolver, 0, null
                loop
                    result = do iterator.iterateNext
                    if result then results.push result else break
            else if /^link=(.*)/.test locator
                href_or_text = locator.match(/^link=(.*)/)[1]
                for link in queryAll document, "xpath=//a"
                    if href_or_text in [link.href, link.text]
                        results.push link
            else if /^dom=(.*)/.test locator
                path = locator.match(/^dom=(.*)/)[1]
                try result = eval(path)
                catch error then result = null
                if result then results.push result
            else
                if result = document.getElementById locator
                    results.push result
                else
                    for result in document.getElementsByName locator
                        results.push result
            if results.length and assign_to_id
                document._robotIds ?= {}
                document._robotIds[assign_to_id] = results[0]
            results

        #
        # Define custom browser.evaluate with support for params.
        # http://code.google.com/p/phantomjs/issues/detail?id=132#c44
        #
        browser.eval = (func) ->  # 'evaluate with parameters'
            # Prevent "onbeforeunload" (not supported by phantomjs).
            browser.evaluate -> window.onbeforeunload = ->  # I do nothing

            # Exit quicly when the browser is still loading the html.
            if browser.robotIsLoading
                throw "Browser was busy (loading in progress)."

            # Evaluate with parameters.
            str = "function() { queryAll = #{do queryAll.toString};"
            str += "return (#{do func.toString})("
            for arg in [].slice.call arguments, 1
                str += (/object|string/.test typeof arg)\
                    and "JSON.parse(#{JSON.stringify(JSON.stringify(arg))}),"\
                    or arg + ","
            if /,$/.test str
                str = str.replace /,$/, "); }"
            else
                str += "); }"
            browser.evaluate str

    # Perform init.
    initBrowser browser

    if alias then browser._robotAlias = alias

    # Save onto open browsers-list and set active.
    @browsers ?= []
    @browsers.push browser
    @browser = browser

    if url then @["Go to"] [url], callback

    callback status: "PASS", return: @browsers.length


advanced_keyword "Maximize browser window",
"""
Maximizes current browser window.

.. note:: Just resizes to larger, not maximizes, the browser on phantomrobot.
""",
([], callback) ->
    @browser.viewportSize = width: 1280, height: 1024
    callback status: "PASS"


advanced_keyword "Close browser",
"""
Closes the current browser.
""",
([], callback) ->
    @browsers ?= []

    closed = false
    for browser in @browsers
        if browser == @browser
            do browser.release
            closed = true
            break

    if closed
        callback status: "PASS"
    else
        callback status: "FAIL", error: "Open browser was not found."


advanced_keyword "Close all browsers",
"""
Closes all open browsers and empties the connection cache.

After this keyword new indexes get from Open Browser keyword are reset to 1.

This keyword should be used in test or suite teardown to make sure all browsers
are closed.
""",
([], callback) ->
    @browsers ?= []
    loop
        if browser = do @browsers.pop
            do browser.release
        else break
    callback status: "PASS"


advanced_keyword "Go to",
"""
Navigates the active browser instance to the provided URL.
""",
([url], callback) ->
    has_been_completed = false

    if not @browser.robotIsLoading
        @browser.open url, (status) =>
            if not has_been_completed
                has_been_completed = true
                callback status: "PASS"
    else
        callback status: "FAIL",\
                 error: "Browser was busy (loading in progress)."


keyword "Reload page",
"""
Simulates user reloading page.
""",
() ->
    do document.location.reload
    status: "PASS"
