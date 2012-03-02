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

"Click link": (params, respond) ->
    needle = params[1][0]

    getLinkCoords = (needle) ->
        visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
        for result in queryAll document, needle when visible result
            rect = result.getBoundingClientRect()
            return x: rect.left + rect.width / 2,\
                   y: rect.top + rect.height / 2
        trim = (s) -> s.replace /^\s+|\s+$/g, ""
        for result in queryAll document, "xpath=//a" when visible result
            if trim(result.innerText) == needle
                rect = result.getBoundingClientRect()
                return x: rect.left + rect.width / 2,\
                       y: rect.top + rect.height / 2
        return null

    if coords = @page.eval getLinkCoords, needle
        @page.sendEvent "click", coords.x, coords.y
        respond status: "PASS"
    else
        respond status: "FAIL", error: "Link '#{needle}' was not found."

"Click element": (params, respond) ->
    needle = params[1][0]

    getElementCoords = (needle) ->
        visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
        for result in queryAll document, needle when visible result
            rect = result.getBoundingClientRect()
            return x: rect.left + rect.width / 2,\
                   y: rect.top + rect.height / 2
        return null

    if coords = @page.eval getElementCoords, needle
        @page.sendEvent "click", coords.x, coords.y
        respond status: "PASS"
    else
        respond status: "FAIL", error: "Element '#{needle}' was not found."

"Mouse down": (params, respond) ->
    needle = params[1][0]

    getCoords = (needle) ->
        for result in queryAll document, needle
            rect = result.getBoundingClientRect()
            return x: rect.left + rect.width / 2,\
                   y: rect.top + rect.height / 2
        return null

    if coords = @page.eval getCoords, needle
        @page.sendEvent "mousedown", coords.x, coords.y
        respond status: "PASS"
    else
        respond status: "FAIL", error: "Element '#{needle}' was not found."

"Mouse up": (params, respond) ->
    needle = params[1][0]

    getCoords = (needle) ->
        for result in queryAll document, needle
            rect = result.getBoundingClientRect()
            return x: rect.left + rect.width / 2,\
                   y: rect.top + rect.height / 2
        return null

    if coords = @page.eval getCoords, needle
        @page.sendEvent "mouseup", coords.x, coords.y
        respond status: "PASS"
    else
        respond status: "FAIL", error: "Element '#{needle}' was not found."
