###
Copyright (C) 2011  Asko Soukka <asko.soukka@iki.fi>

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

class Page

    "Page should contain": (params, respond) ->
        needle = params[1][0]

        pageContains = (needle) ->
            for result in queryAll document, needle
                return true
            if not /^[a-z]+=(.*)/.test needle
                xpath = "xpath=//*[contains(text(), '#{needle}')]"
                for result in queryAll document, xpath
                    return true
            return false

        if result = @page.eval pageContains, needle
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Page did not contain '#{needle}'."

    "Page should contain visible": (params, respond) ->
        needle = params[1][0]

        pageContainsVisible = (needle) ->
            visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
            for result in queryAll document, needle when visible result
                return true
            if not /^[a-z]+=(.*)/.test needle
                xpath = "xpath=//*[contains(text(), '#{needle}')]"
                for result in queryAll document, xpath when visible result
                    return true
            return false

        if result = @page.eval pageContainsVisible, needle
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Page did not contain '#{needle}'."

    "Wait until page contains": (params, respond) ->
        @["Page should contain"] params, respond

    "Wait until page contains visible": (params, respond) ->
        @["Page should contain visible"] params, respond

    "Page should contain element": (params, respond) ->
        @["Page should contain"] params, respond

    "Wait until page contains element": (params, respond) ->
        @["Page should contain"] params, respond

    "Page should not contain element": (params, respond) ->
        needle = params[1][0]
        @["Page should contain"] params, (response) ->
            if response?.status == "PASS"
                respond status: "FAIL", error: "Page did contain '#{needle}'.",
            else
                respond status: "PASS"

    "Element should be visible": (params, respond) ->
        @["Page should contain visible"] params, respond

    "Element should not be visible": (params, respond) ->
        needle = params[1][0]
        @["Page should contain visible"] params, (response) ->
            if response?.status == "PASS"
                respond status: "FAIL", error: "Page did contain visible " +
                                               "'#{needle}'.",
            else
                respond status: "PASS"

    "Element should contain": (params, respond) ->
        element = params[1][0]
        needle = params[1][1]

        elementContains = (element, needle) ->
            if (results = queryAll document, element).length
                for result in results
                    if queryAll(document, needle).length > 0
                        return true
                    xpath = "xpath=//*[contains(text(), '#{needle}')]"
                    for subres in queryAll document, xpath
                        return true
                return false
            return null

        if result = @page.eval elementContains, element, needle
            respond status: "PASS"
        else if result == null
            respond status: "FAIL", error: "Element '#{element}' " +
                                           "was not found."
        else
            respond status: "FAIL", error: "Element '#{element}' did not " +
                                           "contain '#{needle}'."

    "Element text should be": (params, respond) ->
        element = params[1][0]
        text = params[1][1]

        getElementText = (element) ->
            for result in queryAll document, element
                return result.innerText.replace /^\s+|\s+$/g, ""
            return null

        if (result = @page.eval getElementText, element) == text
            respond status: "PASS"
        else if result == null
            respond status: "FAIL", error: "Element '#{element}' text " +
                                           "was not found."
        else
            respond status: "FAIL", error: "Element '#{element}' text " +
                                           "'#{result}' != #{text}."

    "XPath should match X times": (params, respond) ->
        xpath = "xpath=" + params[1][0]
        times = parseInt params[1][1], 10

        getXPathMatchTimes = (xpath) -> queryAll(document, xpath).length

        if (result = @page.eval getXPathMatchTimes, xpath) == times
            respond status: "PASS"
        else
            respond status: "FAIL", error: "XPath '#{xpath}' matched only " +
                                           "'#{result}' times."
