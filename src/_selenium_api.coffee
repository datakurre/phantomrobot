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


advanced_keyword "Start Selenium server",
"""
Starts the Selenium Server provided with SeleniumLibrary.

.. note:: Does nothing on phantomrobot.
""",
([], callback) -> callback status: "PASS"


advanced_keyword "Stop Selenium server",
"""
Stops the selenium server (and closes all browsers).
""",
([], callback) -> @["Close all browsers"] [], callback


advanced_keyword "Set Selenium timeout",
"""
Sets the timeout used by various keywords.

Keywords that expect a page load to happen will fail if the page is not loaded
within the timeout specified with seconds.

The previous timeout value is returned by this keyword and can be used to set
the old value back later. The default timeout is 5 seconds, but it can be
altered in importing.
""",
([seconds], callback) -> @["Set Phantom timeout"] [seconds], callback


advanced_keyword "Set Selenium speed",
"""
Sets the delay that is waited after each Selenium command.

This is useful mainly in slowing down the test execution to be able to view the
execution. seconds may be given in Robot Framework time format. Returns the
previous speed value.

.. note:: Sets the sleep between retries until timeout on phantomrobot.
""",
([seconds], callback) -> @["Set Phantom sleep"] [seconds], callback
