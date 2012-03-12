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


"Input text": (params, respond) ->
    [locator, text] = params

    inputText = (locator, text) ->
        for element in queryAll document, locator
            element.value = text
            return true
        return false

    if result = @page.eval inputText, locator, text
        respond status: "PASS"
    else
        respond status: "FAIL", error: "Input '#{locator}' was not found."


"Select from list": (params, respond) ->
    [list, value] = params

    selectFromList = (list, value) ->
        for element in queryAll document, list
            # try select by values
            for i in [0...element?.options.length or 0]
                if element.options[i].value == value
                    element.selectedIndex = i
                    return true
            # and only then by labels
            trim = (s) -> s.replace /^\s+|\s+$/g, ""
            if element?.value != value
                for i in [0...element?.options.length or 0]
                    if trim(element.options[i].text) == value
                        element.selectedIndex = i
                        return true
            return false
        return null

    if result = @page.eval selectFromList, list, value
        respond status: "PASS"
    else if result == null
        respond status: "FAIL", error: "List '#{list}' was not found."
    else
        respond status: "FAIL", error: "List '#{list}' did not " +
                                       "contain '#{value}'."


"Select radio button": (params, respond) ->
    [name, value] = params

    getRadioButtonCoords = (name, value) ->
        visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
        for result in queryAll document, "xpath=//input[@name='#{name}']"
            if result.value == value and visible result
                rect = result.getBoundingClientRect()
                return x: rect.left + rect.width / 2,\
                       y: rect.top + rect.height / 2
        return null

    if coords = @page.eval getRadioButtonCoords, name, value
        @page.sendEvent "click", coords.x, coords.y
        respond status: "PASS"
    else
        respond status: "FAIL", error: "Radio button '#{value}' " +
                                       "for '#{name}' was not found."

"Click button": (params, respond) ->
    [locator] = params

    clickButton = (locator) ->
        if not /^[a-z]+=(.*)/.test locator
            xpath = "xpath=//input[@type='submit']"
            for result in queryAll document, xpath when result?.click
                trim = (s) -> s.replace /^\s+|\s+$/g, ""
                if trim(result?.value) == locator
                    do result.click
                    return true
        for result in queryAll document, locator when result?.click
            do result.click
            return true
        return null

    if result = @page.eval clickButton, locator
        respond status: "PASS"
    else
        respond status: "FAIL", error: "Button '#{locator}' was not found."


"Submit form": (params, respond) ->
    [locator] = params

    submitForm = (locator) ->
        if not /^[a-z]+=(.*)/.test locator
            xpath = "xpath=//form[@action='#{locator}']"
            for result in queryAll document, xpath when result?.submit
                do result.submit
                return true
        for result in queryAll document, locator when result?.submit
            do result.submit
            return true
        return null

    if result = @page.eval submitForm, locator
        respond status: "PASS"
    else
        respond status: "FAIL", error: "Form '#{locator}' was not found."
