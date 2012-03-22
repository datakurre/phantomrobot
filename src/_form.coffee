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



keyword "Input text",
"""
Types the given text into text field identified by locator.
""",
(locator, text) ->
    for element in queryAll document, locator
        element.value = text
        return status: "PASS"
    status: "FAIL",\
    error: "Input '#{locator}' was not found."


keyword "Select from list",
"""
""",
(list, value) ->
    results = queryAll document, list
    for element in results
        # try select by values
        for i in [0...element?.options.length or 0]
            if element.options[i].value == value
                element.selectedIndex = i
                return status: "PASS"

        # and only then by labels
        trim = (s) -> s.replace /^\s+|\s+$/g, ""
        if element?.value != value
            for i in [0...element?.options.length or 0]
                if trim(element.options[i].text) == value
                    element.selectedIndex = i
                    return status: "PASS"

    if not results.length
        status: "FAIL",\
        error: "List '#{list}' was not found."
    else
        status: "FAIL",\
        error: "List '#{list}' did not contain '#{value}'."


keyword "Select radio button",
"""
""",
(name, value) ->
    visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
    for result in queryAll document, "xpath=//input[@name='#{name}']"
        if result.value == value and visible result
            rect = result.getBoundingClientRect()
            return [name, value, x: rect.left + rect.width / 2,\
                                 y: rect.top + rect.height / 2]
    return null
,
(name, value, coords) ->
    if coords
        @page.sendEvent "click", coords.x, coords.y
        status: "PASS"
    else
        status: "FAIL",\
        error: "Radio button '#{value}' for '#{name}' was not found."


keyword "Click button",
"""
""",
(locator) ->
    if not /^[a-z]+=(.*)/.test locator
        xpath = "xpath=//input[@type='submit']"
        for result in queryAll document, xpath when result?.click
            trim = (s) -> s.replace /^\s+|\s+$/g, ""
            if trim(result?.value) == locator
                do result.click
                return status: "PASS"

    for result in queryAll document, locator when result?.click
        do result.click
        return status: "PASS"

    status: "FAIL",\
    error: "Button '#{locator}' was not found."


keyword "Submit form",
"""
""",
(locator) ->
    if not /^[a-z]+=(.*)/.test locator
        xpath = "xpath=//form[@action='#{locator}']"
        for result in queryAll document, xpath when result?.submit
            do result.submit
            return status: "PASS"

    for result in queryAll document, locator when result?.submit
        do result.submit
        return status: "PASS"

    status: "FAIL",\
    error: "Form '#{locator}' was not found."
