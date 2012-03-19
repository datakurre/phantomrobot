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


advanced_keyword "Capture page screenshot",
"""
Takes a screenshot of the current page and embeds it into the log.

``filename`` argument specifies the name of the file to write the screenshot into.
It works the same was as with Capture Screenshot.

``css`` can be used to modify how the screenshot is taken. By default the bakground
color is changed to avoid possible problems with background leaking when the
page layout is somehow broken.

.. note:: ``css`` has no effect on phantomrobot.
""",
([filename, css], callback) ->
    if @browser?.render
        # take a screenshot and embed it into the log
        fs = require "fs"
        filename = filename or "#{new Date().getTime()}.png"
        output = "*HTML* <img src='#{filename}'/>"
        @browser.render filename

        callback status: "PASS", output: output
    else
        callback status: "FAIL", error: "Open browser was not found."


advanced_keyword "Set Phantom timeout",
"""
Sets the timeout for PhantomRobot implicit retries.

Returns the previous value.
""",
([seconds], callback) ->
    regexp = /(\d+)s?/
    if regexp.test(seconds)
        previous = "#{robot.timeout} seconds"
        robot.timeout = parseInt seconds.match(seconds)[1], 10

        callback status: "PASS", return: previous
    else
        callback status: "FAIL", error: "Unsupported timeout '#{seconds}'."


advanced_keyword "Set Phantom sleep",
"""
Sets the sleep between PhantomRobot's implicit retries.

Returns the previous value.
""",
([seconds], callback) ->
    regexp = /(\d+)s?/
    if regexp.test(seconds)
        # set sleep, but it must be above zero; this seems silly, but we
        # try to mimic selenium speed here...
        previous = "#{Math.floor robot.sleep} seconds"
        robot.sleep = Math.max 0.1, parseFloat(seconds.match(seconds)[1], 10)

        callback status: "PASS", return: previous
    else
        callback status: "FAIL", error: "Unsupported sleep '#{seconds}'."


advanced_keyword "Register keyword to run on failure",
"""
Sets the keyword to execute when a SeleniumLibrary keyword fails.

``keyword_name`` is the name of a SeleniumLibrary keyword that will be executed if
another SeleniumLibrary keyword fails. It is not possible to use a keyword that
requires arguments. The name is case but not space sensitive. If the name does
not match any keyword, this functionality is disabled and nothing extra will be
done in case of a failure.

The initial keyword to use is set in importing, and the keyword that is used by
default is Capture Screenshot. Taking a screenshot when something failed is a
very useful feature, but notice that it can slow down the execution.

This keyword returns the name of the previously registered failure keyword. It
can be used to restore the original value later.
""",
([keyword_name], callback) ->
    names = (name.replace(/\_/g, " ").toLowerCase() for name, _ of this\
        when name[0].toUpperCase() == name[0])
    if keyword_name.toLowerCase() in names  # be case-insensitive
        previous = robot.on_failure
        robot.on_failure = keyword_name

        callback status: "PASS", return: previous
    else
        callback status: "FAIL", error: "There's no keyword '#{keyword_name}'."
