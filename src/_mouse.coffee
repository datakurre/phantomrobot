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


keyword "Click link",
"""
""",
(locator) ->
    visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
    for result in queryAll document, locator when visible result
        rect = result.getBoundingClientRect()
        return x: rect.left + rect.width / 2,\
               y: rect.top + rect.height / 2
    trim = (s) -> s.replace /^\s+|\s+$/g, ""
    for result in queryAll document, "xpath=//a" when visible result
        if trim(result.innerText) == locator
            rect = result.getBoundingClientRect()
            return x: rect.left + rect.width / 2,\
                   y: rect.top + rect.height / 2
    return null
,
(locator, coords) ->
    if coords
        @browser.sendEvent "click", coords.x, coords.y
        status: "PASS"
    else
        status: "FAIL",\
        error: "Link '#{locator}' was not found."


keyword "Click element",
"""
""",
(locator) ->
    visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
    for result in queryAll document, locator when visible result
        rect = result.getBoundingClientRect()
        return x: rect.left + rect.width / 2,\
               y: rect.top + rect.height / 2
    return null
,
(locator, coords) ->
    if coords
        @browser.sendEvent "click", coords.x, coords.y
        status: "PASS"
    else
        status: "FAIL",\
        error: "Element '#{locator}' was not found."


keyword "Mouse down",
"""
""",
(locator) ->
    for result in queryAll document, locator
        rect = result.getBoundingClientRect()
        return x: rect.left + rect.width / 2,\
               y: rect.top + rect.height / 2
    return null
,
(locator, coords) ->
    if coords
        @browser.sendEvent "mousedown", coords.x, coords.y
        status: "PASS"
    else
        status: "FAIL",\
        error: "Element '#{locator}' was not found."


keyword "Mouse up",
"""
""",
(locator) ->
    for result in queryAll document, locator
        rect = result.getBoundingClientRect()
        return x: rect.left + rect.width / 2,\
               y: rect.top + rect.height / 2
    return null
,
(locator, coords) ->
    if coords
        @browser.sendEvent "mouseup", coords.x, coords.y
        status: "PASS"
    else
        status: "FAIL",\
        error: "Element '#{locator}' was not found."
