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

class Form

    "Input text": (params, respond) ->
        input = params[1][0]
        text = params[1][1]

        inputText = (input, text) ->
            for element in queryAll document, input
                element.value = text
                return true
            return false

        if result = @page.eval inputText, input, text
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Input '#{input}' was not found."

    "Select from list": (params, respond) ->
        list = params[1][0]
        value = params[1][1]

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
        name = params[1][0]
        value = params[1][1]

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
        needle = params[1][0]

        clickButton = (needle) ->
            if not /^[a-z]+=(.*)/.test needle
                xpath = "xpath=//input[@type='submit']"
                for result in queryAll document, xpath when result?.click
                    trim = (s) -> s.replace /^\s+|\s+$/g, ""
                    if trim(result?.value) == needle
                        do result.click
                        return true
            for result in queryAll document, needle when result?.click
                do result.click
                return true
            return null

        if result = @page.eval clickButton, needle
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Button '#{needle}' was not found."

    "Submit form": (params, respond) ->
        needle = params[1][0]

        submitForm = (needle) ->
            if not /^[a-z]+=(.*)/.test needle
                xpath = "xpath=//form[@action='#{needle}']"
                for result in queryAll document, xpath when result?.submit
                    do result.submit
                    return true
            for result in queryAll document, needle when result?.submit
                do result.submit
                return true
            return null

        if result = @page.eval submitForm, needle
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Form '#{needle}' was not found."
