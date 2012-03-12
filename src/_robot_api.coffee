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


"Capture page screenshot": (params, respond) ->
    if @page?.render
        # take a screenshot and embed it into the log
        fs = require "fs"
        filename = "#{new Date().getTime()}.png"
        output = "*HTML* <img src='#{filename}'/>"
        @page.render filename
        respond status: "PASS", output: output
    else
        respond status: "FAIL", error: "There's no page."


"Set Phantom timeout": (params, respond) ->
    timeout = params[1][0]
    seconds = /(\d+)s?/
    if seconds.test(timeout)
        robot.timeout = parseInt timeout.match(seconds)[1], 10
        respond status: "PASS", return: timeout
    else
        respond status: "FAIL", error: "Unsupported timeout '#{timeout}'."


"Register keyword to run on failure": (params, respond) ->
    keyword = params[1][0]
    names = (name.replace(/\_/g, " ").toLowerCase() for name, _ of this\
        when name[0].toUpperCase() == name[0])
    if keyword.toLowerCase() in names
        previous = robot.on_failure
        robot.on_failure = keyword
        respond status: "PASS", return: previous
    else
        respond status: "FAIL", error: "There's no keyword '#{keyword}'."
