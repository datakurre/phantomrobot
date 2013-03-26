#
# Copyright (C) 2011-2012  Asko Soukka <asko.soukka@iki.fi>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

advanced_keyword "Frame Should Contain",
"""
Verifies frame identified by locator contains text.

See Page Should Contain for explanation about loglevel argument.

Key attributes for frames are id and name. See introduction for details about
locating elements.
""",
([locator, text], callback) ->
    @browser.switchToMainFrame()
    @browser.switchToFrame(locator)
    @["Page should contain"] [text], callback


advanced_keyword "Select Frame",
"""
Sets frame identified by locator as current frame.

Key attributes for frames are id and name. See introduction for details about locating elements.
""",
([locator], callback) ->
    @browser.switchToMainFrame()
    @browser.switchToFrame(locator)
    callback status: "PASS"


advanced_keyword "Unselect Frame",
"""
Sets the top frame as the current frame.
""",
([], callback) ->
    @browser.switchToMainFrame()
    callback status: "PASS"


advanced_keyword "Current Frame Contains",
"""
Verifies that current frame contains text.

See Page Should Contain for explanation about loglevel argument.
""",
([text], callback) ->
    @["Page should contain"] [text], callback
