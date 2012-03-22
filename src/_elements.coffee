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


keyword "Assign id to element",
"""
Assigns a temporary identifier to element specified by locator.

This is mainly useful if the locator is complicated/slow XPath expression.
Identifier expires when the page is reloaded.
""",
(locator, id) ->
    for result in queryAll document, locator, id
        return status: "PASS"
    status: "FAIL",\
    error: "Page did not contain '#{locator}'."


keyword "Page should contain",
"""
Verifies that current page contains text.

If this keyword fails, it automatically logs the page source using the log
level specified with the optional loglevel argument. Giving NONE as level
disables logging.

.. note:: ``loglevel`` has no effect on phantomrobot.
""",
(text, loglevel="INFO") ->
    xpath = "xpath=//*[contains(text(), '#{text}')]"
    for result in queryAll document, xpath
        return status: "PASS"
    status: "FAIL",\
    error: "Page did not contain '#{text}'."


keyword "Wait until page contains",
"""
Waits until text appears on current page.

Fails if timeout expires before the text appears. See introduction for more
information about timeout and its default value. error can be used to override
the default error message.

.. note:: ``timeout`` has no effect on phantomrobot.
""",
([text, timeout, error], callback) ->
    xpath = "xpath=//*[contains(text(), '#{text}')]"
    for result in queryAll document, xpath
        return status: "PASS"
    status: "FAIL",\
    error: error or "Page did not contain '#{text}'."


keyword "Page should not contain",
"""
Verifies the current page does not contain text.

If this keyword fails, it automatically logs the page source using the log
level specified with the optional loglevel argument. Giving NONE as level
disables logging.

.. note:: ``loglevel`` has no effect on phantomrobot.
""",
(text, loglevel="INFO") ->
    xpath = "xpath=//*[contains(text(), '#{text}')]"
    for result in queryAll document, xpath
        return status: "FAIL",\
               error: "Page did contain '#{text}'."
    status: "PASS"


keyword "Page should contain visible",
"""
Verifies that current page contains visible text.

If this keyword fails, it automatically logs the page source using the log
level specified with the optional loglevel argument. Giving NONE as level
disables logging.

.. note:: ``loglevel`` has no effect on phantomrobot.
""",
(text, loglevel="INFO") ->
    visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
    xpath = "xpath=//*[contains(text(), '#{text}')]"
    for result in queryAll document, xpath when visible result
        return status: "PASS"
    status: "FAIL",\
    error: "Page did not contain visible '#{text}'."


keyword "Wait until page contains visible",
"""
Waits until visible text appears on current page.

Fails if timeout expires before the text appears. See introduction for more
information about timeout and its default value. error can be used to override
the default error message.

.. note:: ``timeout`` has no effect on phantomrobot.
""",
(text, timeout, error) ->
    visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
    xpath = "xpath=//*[contains(text(), '#{text}')]"
    for result in queryAll document, xpath when visible result
        return status: "PASS"
    status: "FAIL",\
    error: error or "Page did not contain visible '#{text}'."


keyword "Page should not contain visible",
"""
Verifies the current page does not contain visible text.

If this keyword fails, it automatically logs the page source using the log
level specified with the optional loglevel argument. Giving NONE as level
disables logging.

.. note:: ``loglevel`` has no effect on phantomrobot.
""",
(text, loglevel="INFO") ->
    visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
    xpath = "xpath=//*[contains(text(), '#{text}')]"
    for result in queryAll document, xpath when visible result
        return status: "FAIL",\
               error: "Page did contain visible '#{text}'."
    status: "PASS"


keyword "Page should contain element",
"""
Verifies element identified by locator is found from current page.

``message`` can be used to override default error message.

If this keyword fails, it automatically logs the page source using the log
level specified with the optional loglevel argument. Giving NONE as level
disables logging.

.. note:: ``loglevel`` has no effect on phantomrobot.
""",
(locator, message, loglevel="INFO") ->
    for result in queryAll document, locator
        return status: "PASS"
    status: "FAIL",\
    error: message or "Page did not contain '#{locator}'."


keyword "Wait until page contains element",
"""
Waits until element specified with locator appears on current page.

Fails if timeout expires before the element appears. See introduction for more
information about timeout and its default value.

``error`` can be used to override the default error message.

.. note:: ``timeout`` has no effect on phantomrobot.
""",
(locator, timeout, error) ->
    for result in queryAll document, locator
        return status: "PASS"
    status: "FAIL",\
    error: error or "Page did not contain '#{locator}'."


keyword "Page should not contain element",
"""
Verifies element identified by locator is not found from current page.

``message`` can be used to override default error message.

If this keyword fails, it automatically logs the page source using the log
level specified with the optional loglevel argument. Giving NONE as level
disables logging.

.. note:: ``loglevel`` has no effect on phantomrobot.
""",
(locator, message, loglevel="INFO") ->
    for result in queryAll document, locator
        return status: "FAIL",\
               error: message or "Page did contain #{locator}."
    status: "PASS"


keyword "Get element attribute",
"""
Return value of element attribute.

``attribute_locator`` consists of element locator followed by an @ sign and
attribute name, for example "element_id@class".
""",
(attribute_locator) ->
    [locator, attribute] = attribute_locator.split "@"
    for result in queryAll document, locator
        return status: "PASS",\
               return: result.getAttribute attribute
    status: "FAIL",\
    error: "Page did contain #{locator}."


keyword "Element should be visible",
"""
Verifies that the element identified by ``locator`` is visible.

Herein, visible means that the element is logically visible, not optically
visible in the current browser viewport. For example, an element that carries
display:none is not logically visible, so using this keyword on that element
would fail.

``message`` can be used to override the default error message.

Key attributes for arbitrary elements are ``id`` and ``name``.
""",
(locator, message) ->
    visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
    for result in queryAll document, locator when visible result
        return status: "PASS"
    status: "FAIL",\
    error: message or "Page did not contain visible '#{locator}'."


keyword "Element should not be visible",
"""
Verifies that the element identified by ``locator`` is NOT visible.

This is the opposite of *Element should be visible*.

``message`` can be used to override the default error message.

Key attributes for arbitrary elements are ``id`` and ``name``.
""",
(locator, message) ->
    visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
    for result in queryAll document, locator when visible result
        return status: "FAIL",\
               error: message or "Page did contain visible '#{locator}'."
    status: "PASS"


keyword "Element should contain",
"""
Verifies element identified by ``locator`` contains text expected.

If you wish to assert an exact (not a substring) match on the text of the
element, use *Element text should be*

``message`` can be used to override the default error message.

Key attributes for arbitrary elements are ``id`` and ``name``.
""",
(locator, expected, message) ->
    if (results = queryAll document, locator).length
        for result in results
            xpath = "xpath=//*[contains(text(), '#{expected}')]"
            for subres in queryAll document, xpath
                return status: "PASS"
        return status: "FAIL",\
               error: "Element '#{locator}' did not contain '#{expected}'."
    status: "FAIL",\
    error: "Element '#{locator}' was not found."


keyword "Element text should be",
"""
Verifies element identified by ``locator`` exactly contains text expected.

In contrast to Element Should Contain, this keyword does not try a substring
match but an exact match on the element identified by locator.

``message`` can be used to override the default error message.

Key attributes for arbitrary elements are ``id`` and ``name``.
""",
(locator, expected, message) ->
    if (results = queryAll document, locator).length
        for result in results
            result = result.innerText.replace /^\s+|\s+$/g, ""
            if result == expected
                return status: "PASS"
        return status: "FAIL",\
               error: "Element '#{locator}' was not '#{expected}'."
    status: "FAIL",\
    error: "Element '#{locator}' was not found."


keyword "Get matching XPath count",
"""
Returns number of elements matching ``xpath``

If you wish to assert the number of matching elements, use *Xpath should match
X times*.
""",
(xpath) ->
    count = queryAll(document, "xpath=#{xpath}").length
    status: "PASS",
    return: do count.toString


keyword "XPath should match X times",
"""
Verifies that the page contains the given number of elements located by the
given ``xpath``.
""",
(xpath, expected_xpath_count, message, loglevel="INFO") ->
    count = queryAll(document, "xpath=#{xpath}").length
    times = parseInt expected_xpath_count, 10
    if count == times
        status: "PASS"
    else
        status: "FAIL",\
        error: message or "XPath '#{locator}' matched '#{times}' times."


keyword "Get horizontal position",
"""
Returns horizontal position of element identified by ``locator``.

The position is returned in pixels off the left side of the page, as an
integer. Fails if a matching element is not found.
""",
(locator) ->
    visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
    for result in queryAll document, locator when visible result
        rect = result.getBoundingClientRect()
        return status: "PASS",\
               return: rect.left
    status: "FAIL",\
    error: "Could not determine position for '#{locator}'"


keyword "Get vertical position",
"""
Returns vertical position of element identified by ``locator``.

The position is returned in pixels off the top of the page, as an integer.
Fails if a matching element is not found.
""",
(locator) ->
    visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
    for result in queryAll document, locator when visible result
        rect = result.getBoundingClientRect()
        return status: "PASS",\
               return: rect.top
    status: "FAIL",\
    error: "Could not determine position for '#{locator}'"
