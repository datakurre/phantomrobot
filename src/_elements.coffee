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


keyword "Assign id to element",
"""
Assigns a temporary identifier to element specified by locator.

This is mainly useful if the locator is complicated/slow XPath expression.
Identifier expires when the page is reloaded.
""",
(locator, id) ->
    for result in queryAll document, locator, id
        return status: "PASS"
    status: "FAIL", error: "Page did not contain '#{locator}'."


keyword "Page should contain",
"""
Verifies that current page contains text.

If this keyword fails, it automatically logs the page source using the log
level specified with the optional loglevel argument. Giving NONE as level
disables logging.

.. note:: ``loglevel`` has no effect on phantomrobot.
""",
(text, loglevel="INFO") ->
    xpath = "xpath=//*[contains(text(), '#{text}')]"
    for result in queryAll document, xpath
        return status: "PASS"
    status: "FAIL", error: "Page did not contain '#{text}'."


keyword "Page should not contain",
"""
Verifies the current page does not contain text.

If this keyword fails, it automatically logs the page source using the log
level specified with the optional loglevel argument. Giving NONE as level
disables logging.

.. note:: ``loglevel`` has no effect on phantomrobot.
""",
(text, loglevel="INFO") ->
    if (results = @["Page should contain"] text).status == "FAIL"
        status: "PASS"
    else
        status: "FAIL", error: "Page did contain #{text}."


keyword "Wait until page contains",
"""
Waits until text appears on current page.

Fails if timeout expires before the text appears. See introduction for more
information about timeout and its default value. error can be used to override
the default error message.

.. note:: ``timeout`` has no effect on phantomrobot.
""",
(text, timeout, error) ->
    if (results = @["Page should contain"] text).status == "FAIL"
        status: "FAIL", error: error or status.error
    else
        results


keyword "Page should contain visible",
"""
Verifies that current page contains visible text.

If this keyword fails, it automatically logs the page source using the log
level specified with the optional loglevel argument. Giving NONE as level
disables logging.

.. note:: ``loglevel`` has no effect on phantomrobot.
""", (text, loglevel="INFO") ->
    visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
    xpath = "xpath=//*[contains(text(), '#{text}')]"
    for result in queryAll document, xpath when visible result
        return status: "PASS"
    status: "FAIL", error: "Page did not contain visible '#{text}'."


keyword "Page should not contain visible",
"""
Verifies the current page does not contain visible text.

If this keyword fails, it automatically logs the page source using the log
level specified with the optional loglevel argument. Giving NONE as level
disables logging.

.. note:: ``loglevel`` has no effect on phantomrobot.
""",
(text, loglevel="INFO") ->
    if (results = @["Page should contain visible"] text).status == "FAIL"
        status: "PASS"
    else
        status: "FAIL", error: "Page did contain visible #{text}."




keyword "Wait until page contains visible",
"""
Waits until visible text appears on current page.

Fails if timeout expires before the text appears. See introduction for more
information about timeout and its default value. error can be used to override
the default error message.

.. note:: ``timeout`` has no effect on phantomrobot.
""",
(text, timeout, error) ->
    if (results = @["Page should contain visible"] text).status == "FAIL"
        status: "FAIL", error: error or status.error
    else
        results




keyword "Page should contain element",
"""
Verifies element identified by locator is found from current page.

``message`` can be used to override default error message.

If this keyword fails, it automatically logs the page source using the log
level specified with the optional loglevel argument. Giving NONE as level
disables logging.

.. note:: ``loglevel`` has no effect on phantomrobot.
""",
(locator, message, loglevel="INFO") ->
    for result in queryAll document, locator
        return status: "PASS"
    status: "FAIL", error: message or "Page did not contain '#{locator}'."


keyword "Wait until page contains element",
"""
Waits until element specified with locator appears on current page.

Fails if timeout expires before the element appears. See introduction for more
information about timeout and its default value.

``error`` can be used to override the default error message.

.. note:: ``timeout`` has no effect on phantomrobot.
""",
(locator, timeout, error) ->
    if (results = @["Page should contain element"] locator).status == "FAIL"
        status: "FAIL", error: error or status.error
    else
        results


keyword "Page should not contain element",
"""
""",
(params, respond) ->
    [locator] = params

    @["Page should contain"] params, (response) ->
        if response?.status == "PASS"
            respond status: "FAIL", error: "Page did contain '#{locator}'.",
        else
            respond status: "PASS"


"Element should be visible": (params, respond) ->
    @["Page should contain visible"] params, respond


"Element should not be visible": (params, respond) ->
    [locator] = params

    @["Page should contain visible"] params, (response) ->
        if response?.status == "PASS"
            respond status: "FAIL", error: "Page did contain visible " +
                                           "'#{locator}'.",
        else
            respond status: "PASS"


"Element should contain": (params, respond) ->
    [element, locator] = params

    elementContains = (element, locator) ->
        if (results = queryAll document, element).length
            for result in results
                if queryAll(document, locator).length > 0
                    return true
                xpath = "xpath=//*[contains(text(), '#{locator}')]"
                for subres in queryAll document, xpath
                    return true
            return false
        return null

    if result = @page.eval elementContains, element, locator
        respond status: "PASS"
    else if result == null
        respond status: "FAIL", error: "Element '#{element}' " +
                                       "was not found."
    else
        respond status: "FAIL", error: "Element '#{element}' did not " +
                                       "contain '#{locator}'."


"Element text should be": (params, respond) ->
    [locator, text] = params

    getlocatorText = (locator) ->
        for result in queryAll document, locator
            return result.innerText.replace /^\s+|\s+$/g, ""
        return null

    if (result = @page.eval getElementText, locator) == text
        respond status: "PASS"
    else if result == null
        respond status: "FAIL", error: "Element '#{locator}' text " +
                                       "was not found."
    else
        respond status: "FAIL", error: "Element '#{locator}' text " +
                                       "'#{result}' != #{text}."


"Get element attribute": (params, respond) ->
    [locator] = params
    [locator, attribute] = locator.split "@"

    getElementAttribute = (locator, attribute) ->
        for result in queryAll document, locator
            return result.getAttribute attribute
        return null

    if result = @page.eval getElementAttribute, locator, attribute
        respond status: "PASS", return: result
    else
        respond status: "FAIL", error: "Element '#{locator}' " +
                                       "was not found."


"Get matching XPath count": (params, respond) ->
    [xpath] = params

    locator = "xpath=" + xpath

    getXPathMatchTimes = (locator) ->
        do queryAll(document, locator).length.toString

    respond status: "PASS", return: @page.eval getXPathMatchTimes, locator


"XPath should match X times": (params, respond) ->
    [xpath, times] = params

    locator = "xpath=" + xpath
    times = parseInt times, 10

    getXPathMatchTimes = (locator) -> queryAll(document, locator).length

    if (result = @page.eval getXPathMatchTimes, locator) == times
        respond status: "PASS"
    else
        respond status: "FAIL", error: "XPath '#{locator}' matched only " +
                                       "'#{result}' times."


"Get horizontal position": (params, respond) ->
    [locator] = params

    getElementCoords = (locator) ->
        visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
        for result in queryAll document, locator when visible result
            rect = result.getBoundingClientRect()
            return x: rect.left, y: rect.top
        return null

    if coords = @page.eval getElementCoords, locator
        respond status: "PASS", return: coords.x
    else
        respond status: "FAIL", error: "Could not determine position for " +
                                       "'#{locator}'"


"Get vertical position": (params, respond) ->
    [locator] = params

    getElementCoords = (locator) ->
        visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
        for result in queryAll document, locator when visible result
            rect = result.getBoundingClientRect()
            return x: rect.left, y: rect.top
        return null

    if coords = @page.eval getElementCoords, locator
        respond status: "PASS", return: coords.y
    else
        respond status: "FAIL", error: "Element '#{locator}' was not found."

