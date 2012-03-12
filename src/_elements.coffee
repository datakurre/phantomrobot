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


"Assign id to element": (params, respond) ->
    [keyword, [locator, id]] = params

    assignIdToElement = (locator, id) ->
        for result in queryAll document, locator, id
            return true
        return false

    if @page.eval assignIdToElement, locator, id
        respond status: "PASS"
    else
        respond status: "FAIL", error: "Page did not contain '#{locator}'."


"Page should contain": (params, respond) ->
    [keyword, [locator]] = params

    pageContains = (locator) ->
        for result in queryAll document, locator
            return true
        if not /^[a-z]+=(.*)/.test locator
            xpath = "xpath=//*[contains(text(), '#{locator}')]"
            for result in queryAll document, xpath
                return true
        return false

    if result = @page.eval pageContains, locator
        respond status: "PASS"
    else
        respond status: "FAIL", error: "Page did not contain '#{locator}'."


"Page should contain visible": (params, respond) ->
    [keyword, [locator]] = params

    pageContainsVisible = (locator) ->
        visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
        for result in queryAll document, locator when visible result
            return true
        if not /^[a-z]+=(.*)/.test locator
            xpath = "xpath=//*[contains(text(), '#{locator}')]"
            for result in queryAll document, xpath when visible result
                return true
        return false

    if result = @page.eval pageContainsVisible, locator
        respond status: "PASS"
    else
        respond status: "FAIL", error: "Page did not contain '#{locator}'."


"Wait until page contains": (params, respond) ->
    @["Page should contain"] params, respond


"Wait until page contains visible": (params, respond) ->
    @["Page should contain visible"] params, respond


"Page should contain element": (params, respond) ->
    @["Page should contain"] params, respond


"Wait until page contains element": (params, respond) ->
    @["Page should contain"] params, respond


"Page should not contain element": (params, respond) ->
    [keyword, [locator]] = params

    @["Page should contain"] params, (response) ->
        if response?.status == "PASS"
            respond status: "FAIL", error: "Page did contain '#{locator}'.",
        else
            respond status: "PASS"


"Element should be visible": (params, respond) ->
    @["Page should contain visible"] params, respond


"Element should not be visible": (params, respond) ->
    [keyword, [locator]] = params

    @["Page should contain visible"] params, (response) ->
        if response?.status == "PASS"
            respond status: "FAIL", error: "Page did contain visible " +
                                           "'#{locator}'.",
        else
            respond status: "PASS"


"Element should contain": (params, respond) ->
    [keyword, [element, locator]] = params

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
    [keyword, [locator, text]] = params

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
    [keyword, [locator]] = params
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
    [keyword, [xpath]] = params

    locator = "xpath=" + xpath

    getXPathMatchTimes = (locator) ->
        do queryAll(document, locator).length.toString

    respond status: "PASS", return: @page.eval getXPathMatchTimes, locator


"XPath should match X times": (params, respond) ->
    [keyword, [xpath, times]] = params

    locator = "xpath=" + xpath
    times = parseInt times, 10

    getXPathMatchTimes = (locator) -> queryAll(document, locator).length

    if (result = @page.eval getXPathMatchTimes, locator) == times
        respond status: "PASS"
    else
        respond status: "FAIL", error: "XPath '#{locator}' matched only " +
                                       "'#{result}' times."


"Get horizontal position": (params, respond) ->
    [keyword, [locator]] = params

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
    [keyword, [locator]] = params

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

