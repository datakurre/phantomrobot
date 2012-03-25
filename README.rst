============
PhantomRobot
============

PhantomRobot is a `Robot Framework`_ test library that uses the popular
PhantomJS_-browser, the headless WebKit-browser, for running acceptance tests
in the background. PhantomRobot is written in and is easily expandable with
CoffeeScript_.

.. _Robot Framework: http://code.google.com/p/robotframework/
.. _PhantomJS: http://www.phantomjs.org/
.. _CoffeeScript: http://coffeescript.org/


Try it out
==========

Checkout the code::

    git clone git://github.com/datakurre/phantomrobot.git

Go to the checkout directory and run the buildout_ for installing all the
dependencies (buildout keeps everything within the checkout directory)::

    cd phantomrobot
    python bootstrap.py --distribute

.. _buildout: http://www.buildout.org/

Next:

a) On a 32-bit Linux, continue with::

    bin/buildout -c buildout-linux-x86.cfg

b) On a 64-bit Linux, continue with::

    bin/buildout -c buildout-linux-x86_64.cfg

c) On an OSX, continue with::

    bin/buildout

After the buildout has compiled node.js_ and installed required
node.js-packages using npm_, you should be able to activate the environment and
compile PhantomRobot::

    source bin/activate
    make

Then launch it (as a blocking foreground process)::

    node phantomrobot.js

Finally, to run some Robot Framework tests using PhantomRobot, just open a new
console, change to the checkout/buildout-directory of PhantomRobot, and::

    source bin/activate
    pybot tests

.. _node.js: http://nodejs.org/
.. _npm: http://npmjs.org/

.. note:: PhantomRobot requires ``phantomjs``-binary, which is provided by
   PhantomJS_' developers for 32-bit Linux, 64-bit Linux, OSX and Windows.
   If the binary distribution doesn't work for you, PhantomJS could be
   `compiled manually`__, at least in theory.

   I've done the compiling once on Cent OS 5 / RHEL 5. I needed to build a more
   recent version of GNU Tar >= 1.2.6 to make npm installing modules
   successfully. Yet, because websockets-support was broken in all existing
   QtWebKit-RPMs (thanks to `a known bug`__), I
   had to build my own WebKit to be able to compile working PhantomJS and get
   PhantomRobot running.

.. __: http://code.google.com/p/phantomjs/wiki/BuildInstructions
.. __: https://bugs.webkit.org/show_bug.cgi?id=47284


Custom keywords
===============

Developing and including your own custom Robot Framework keyword definitions is
easily done in just two steps:

1. Create a ``.coffee``-ending file with your custom keywords as follows::

    keyword "Is defined", (name) ->
        if not eval("typeof #{name} === 'undefined'")
            status: "PASS"
        else
            status: "FAIL",\
            error: "Variable '#{name}' was not defined."

2. Run make with environment variable ``MY_KEYWORDS`` containing a relative
   path to your custom keyword files, e.g.::

    MY_KEYWORDS=*.coffee make

This should result a new ``phantomrobot.js`` including your new keywords.


Advanced custom keywords
========================

PhantomRobot support  *simple* and *advanced* keyword definitions. Simple
keyword definitions begin with ``keyword`` and are somewhat magical: the
defined test function is eventually executed directly within the currently open
browser context and have all the pros and cons of that.

Advanced keyword definitions begin with ``advanced_keyword`` and are executed
outside the currently open browser context. They are not bound to the
restrictions of browser context and can take advantage of `PhantomJS' API`__
(e.g. send *real* click-events).

On the other hand, advanced keywords must take are of evaluating code within
the browser context manually and end their execution by calling the given
callback to pass the results back to the Robot Framework test runner::

    advanced_keyword "Is defined", ([name], callback) ->

        isDefined exists = (name) ->
            not eval("typeof #{name} === 'undefined'")

        if @browser.eval isDefined, name
            callback status: "PASS"
        else
            callback status: "FAIL",\
                     error: "Variable '#{name}' was not defined."

.. __: http://code.google.com/p/phantomjs/wiki/Interface

.. note:: ``@browser.eval`` is a thin wrapper around PhantomJS_'
   *WebPage.evaluate*. It can accept parameters any number of parameters.
   Besides that, it defines a special function ``queryAll`` to be usable to
   make DOM queries with CSS-selector, XPATH-expression or DOM element id.  For
   more examples, please, see built-in keyword definitions.


Selenium keywords
=================

My secret goal is to provide full and fully tested set of keywords available in
Robot Framework SeleniumLibrary_. Unfortunately, it may take some time for me
to find enough free time to get that completed.

.. _SeleniumLibrary: http://code.google.com/p/robotframework-seleniumlibrary/

Meanwhile, you a free to either help or implement your own custom keywords,
e.g. for testing your custom JavaScript-dependent features directly.

Implemented SeleniumLibrary-keywords:

.. raw:: html

    <table border="1" class="keywords">
    <tr>
      <th class="kw">Keyword</th>
      <th class="arg">Arguments</th>
      <th class="doc">Documentation</th>
    </tr>
    <tr>
      <td class="kw"><a name="Assign Id To Element"></a>Assign Id To Element</td>
      <td class="arg">locator=, id=</td>
      <td class="doc">Assigns a temporary identifier to element specified by locator.<br />
    <br />
    This is mainly useful if the locator is complicated/slow XPath expression. Identifier expires when the page is reloaded.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Capture Page Screenshot"></a>Capture Page Screenshot</td>
      <td class="arg">filename=, css=</td>
      <td class="doc">Takes a screenshot of the current page and embeds it into the log.<br />
    <br />
    <i>filename</i> argument specifies the name of the file to write the screenshot into. It works the same was as with Capture Screenshot.<br />
    <br />
    <i>css</i> can be used to modify how the screenshot is taken. By default the bakground color is changed to avoid possible problems with background leaking when the page layout is somehow broken.<br />
    <br />
    <b>Note:</b> <i>css</i> has no effect on phantomrobot.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Click Button"></a>Click Button</td>
      <td class="arg">locator=, dont_wait=</td>
      <td class="doc"></td>
    </tr>
    <tr>
      <td class="kw"><a name="Click Element"></a>Click Element</td>
      <td class="arg">locator=, dont_wait=</td>
      <td class="doc"></td>
    </tr>
    <tr>
      <td class="kw"><a name="Click Link"></a>Click Link</td>
      <td class="arg">locator=</td>
      <td class="doc"></td>
    </tr>
    <tr>
      <td class="kw"><a name="Close All Browsers"></a>Close All Browsers</td>
      <td class="arg"></td>
      <td class="doc">Closes all open browsers and empties the connection cache.<br />
    <br />
    After this keyword new indexes get from Open Browser keyword are reset to 1.<br />
    <br />
    This keyword should be used in test or suite teardown to make sure all browsers are closed.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Close Browser"></a>Close Browser</td>
      <td class="arg"></td>
      <td class="doc">Closes the current browser.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Element Should Be Visible"></a>Element Should Be Visible</td>
      <td class="arg">locator=, message=</td>
      <td class="doc">Verifies that the element identified by <i>locator</i> is visible.<br />
    <br />
    Herein, visible means that the element is logically visible, not optically visible in the current browser viewport. For example, an element that carries display:none is not logically visible, so using this keyword on that element would fail.<br />
    <br />
    <i>message</i> can be used to override the default error message.<br />
    <br />
    Key attributes for arbitrary elements are <i>id</i> and <i>name</i>.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Element Should Contain"></a>Element Should Contain</td>
      <td class="arg">locator=, expected=, message=</td>
      <td class="doc">Verifies element identified by <i>locator</i> contains text expected.<br />
    <br />
    If you wish to assert an exact (not a substring) match on the text of the element, use <i>Element text should be</i><br />
    <br />
    <i>message</i> can be used to override the default error message.<br />
    <br />
    Key attributes for arbitrary elements are <i>id</i> and <i>name</i>.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Element Should Not Be Visible"></a>Element Should Not Be Visible</td>
      <td class="arg">locator=, message=</td>
      <td class="doc">Verifies that the element identified by <i>locator</i> is NOT visible.<br />
    <br />
    This is the opposite of <i>Element should be visible</i>.<br />
    <br />
    <i>message</i> can be used to override the default error message.<br />
    <br />
    Key attributes for arbitrary elements are <i>id</i> and <i>name</i>.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Element Text Should Be"></a>Element Text Should Be</td>
      <td class="arg">locator=, expected=, message=</td>
      <td class="doc">Verifies element identified by <i>locator</i> exactly contains text expected.<br />
    <br />
    In contrast to Element Should Contain, this keyword does not try a substring match but an exact match on the element identified by locator.<br />
    <br />
    <i>message</i> can be used to override the default error message.<br />
    <br />
    Key attributes for arbitrary elements are <i>id</i> and <i>name</i>.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Get Element Attribute"></a>Get Element Attribute</td>
      <td class="arg">attribute_locator=</td>
      <td class="doc">Return value of element attribute.<br />
    <br />
    <i>attribute_locator</i> consists of element locator followed by an @ sign and attribute name, for example "element_id@class".</td>
    </tr>
    <tr>
      <td class="kw"><a name="Get Horizontal Position"></a>Get Horizontal Position</td>
      <td class="arg">locator=</td>
      <td class="doc">Returns horizontal position of element identified by <i>locator</i>.<br />
    <br />
    The position is returned in pixels off the left side of the page, as an integer. Fails if a matching element is not found.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Get Matching XPath Count"></a>Get Matching XPath Count</td>
      <td class="arg">xpath=</td>
      <td class="doc">Returns number of elements matching <i>xpath</i><br />
    <br />
    If you wish to assert the number of matching elements, use <i>Xpath should match X times</i>.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Get Vertical Position"></a>Get Vertical Position</td>
      <td class="arg">locator=</td>
      <td class="doc">Returns vertical position of element identified by <i>locator</i>.<br />
    <br />
    The position is returned in pixels off the top of the page, as an integer. Fails if a matching element is not found.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Go To"></a>Go To</td>
      <td class="arg">url=</td>
      <td class="doc">Navigates the active browser instance to the provided URL.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Input Text"></a>Input Text</td>
      <td class="arg">locator=, text=</td>
      <td class="doc">Types the given text into text field identified by locator.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Maximize Browser Window"></a>Maximize Browser Window</td>
      <td class="arg"></td>
      <td class="doc">Maximizes current browser window.<br />
    <br />
    <b>Note:</b> Just resizes to larger, not maximizes, the browser on phantomrobot.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Mouse Down"></a>Mouse Down</td>
      <td class="arg">locator=</td>
      <td class="doc"></td>
    </tr>
    <tr>
      <td class="kw"><a name="Mouse Up"></a>Mouse Up</td>
      <td class="arg">locator=</td>
      <td class="doc"></td>
    </tr>
    <tr>
      <td class="kw"><a name="Open Browser"></a>Open Browser</td>
      <td class="arg">url=, browser=, alias=</td>
      <td class="doc">Opens a new browser instance to given URL.<br />
    <br />
    Returns the index of this browser instance which can be used later to switch back to it. Index starts from 1 and is reset back to it when Close All Browsers keyword is used. See Switch Browser for example.<br />
    <br />
    <i>url</i> is an optional url to open.<br />
    <br />
    <i>browser</i> is an optional parameter that exists to support SeleniumLibarary and is just ignored.<br />
    <br />
    <i>alias</i> is an optional alias for the browser instance and it can be used for switching between browsers similarly as the index. See Switch Browser for more details about that.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Page Should Contain"></a>Page Should Contain</td>
      <td class="arg">text=, loglevel=</td>
      <td class="doc">Verifies that current page contains text.<br />
    <br />
    If this keyword fails, it automatically logs the page source using the log level specified with the optional loglevel argument. Giving NONE as level disables logging.<br />
    <br />
    <b>Note:</b> <i>loglevel</i> has no effect on phantomrobot.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Page Should Contain Element"></a>Page Should Contain Element</td>
      <td class="arg">locator=, message=, loglevel=</td>
      <td class="doc">Verifies element identified by locator is found from current page.<br />
    <br />
    <i>message</i> can be used to override default error message.<br />
    <br />
    If this keyword fails, it automatically logs the page source using the log level specified with the optional loglevel argument. Giving NONE as level disables logging.<br />
    <br />
    <b>Note:</b> <i>loglevel</i> has no effect on phantomrobot.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Page Should Contain Visible"></a>Page Should Contain Visible</td>
      <td class="arg">text=, loglevel=</td>
      <td class="doc">Verifies that current page contains visible text.<br />
    <br />
    If this keyword fails, it automatically logs the page source using the log level specified with the optional loglevel argument. Giving NONE as level disables logging.<br />
    <br />
    <b>Note:</b> <i>loglevel</i> has no effect on phantomrobot.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Page Should Not Contain"></a>Page Should Not Contain</td>
      <td class="arg">text=, loglevel=</td>
      <td class="doc">Verifies the current page does not contain text.<br />
    <br />
    If this keyword fails, it automatically logs the page source using the log level specified with the optional loglevel argument. Giving NONE as level disables logging.<br />
    <br />
    <b>Note:</b> <i>loglevel</i> has no effect on phantomrobot.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Page Should Not Contain Element"></a>Page Should Not Contain Element</td>
      <td class="arg">locator=, message=, loglevel=</td>
      <td class="doc">Verifies element identified by locator is not found from current page.<br />
    <br />
    <i>message</i> can be used to override default error message.<br />
    <br />
    If this keyword fails, it automatically logs the page source using the log level specified with the optional loglevel argument. Giving NONE as level disables logging.<br />
    <br />
    <b>Note:</b> <i>loglevel</i> has no effect on phantomrobot.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Page Should Not Contain Visible"></a>Page Should Not Contain Visible</td>
      <td class="arg">text=, loglevel=</td>
      <td class="doc">Verifies the current page does not contain visible text.<br />
    <br />
    If this keyword fails, it automatically logs the page source using the log level specified with the optional loglevel argument. Giving NONE as level disables logging.<br />
    <br />
    <b>Note:</b> <i>loglevel</i> has no effect on phantomrobot.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Register Keyword To Run On Failure"></a>Register Keyword To Run On Failure</td>
      <td class="arg">keyword_name=</td>
      <td class="doc">Sets the keyword to execute when a SeleniumLibrary keyword fails.<br />
    <br />
    <i>keyword_name</i> is the name of a SeleniumLibrary keyword that will be executed if another SeleniumLibrary keyword fails. It is not possible to use a keyword that requires arguments. The name is case but not space sensitive. If the name does not match any keyword, this functionality is disabled and nothing extra will be done in case of a failure.<br />
    <br />
    The initial keyword to use is set in importing, and the keyword that is used by default is Capture Screenshot. Taking a screenshot when something failed is a very useful feature, but notice that it can slow down the execution.<br />
    <br />
    This keyword returns the name of the previously registered failure keyword. It can be used to restore the original value later.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Reload Page"></a>Reload Page</td>
      <td class="arg"></td>
      <td class="doc">Simulates user reloading page.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Select From List"></a>Select From List</td>
      <td class="arg">list=, value=</td>
      <td class="doc"></td>
    </tr>
    <tr>
      <td class="kw"><a name="Select Radio Button"></a>Select Radio Button</td>
      <td class="arg">name=, value=</td>
      <td class="doc"></td>
    </tr>
    <tr>
      <td class="kw"><a name="Set Phantom Sleep"></a>Set Phantom Sleep</td>
      <td class="arg">seconds=</td>
      <td class="doc">Sets the sleep between PhantomRobot's implicit retries.<br />
    <br />
    Returns the previous value.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Set Phantom Timeout"></a>Set Phantom Timeout</td>
      <td class="arg">seconds=</td>
      <td class="doc">Sets the timeout for PhantomRobot implicit retries.<br />
    <br />
    Returns the previous value.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Set Selenium Speed"></a>Set Selenium Speed</td>
      <td class="arg">seconds=</td>
      <td class="doc">Sets the delay that is waited after each Selenium command.<br />
    <br />
    This is useful mainly in slowing down the test execution to be able to view the execution. seconds may be given in Robot Framework time format. Returns the previous speed value.<br />
    <br />
    <b>Note:</b> Sets the sleep between retries until timeout on phantomrobot.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Set Selenium Timeout"></a>Set Selenium Timeout</td>
      <td class="arg">seconds=</td>
      <td class="doc">Sets the timeout used by various keywords.<br />
    <br />
    Keywords that expect a page load to happen will fail if the page is not loaded within the timeout specified with seconds.<br />
    <br />
    The previous timeout value is returned by this keyword and can be used to set the old value back later. The default timeout is 5 seconds, but it can be altered in importing.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Start Selenium Server"></a>Start Selenium Server</td>
      <td class="arg"></td>
      <td class="doc">Starts the Selenium Server provided with SeleniumLibrary.<br />
    <br />
    <b>Note:</b> Does nothing on phantomrobot.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Stop Selenium Server"></a>Stop Selenium Server</td>
      <td class="arg"></td>
      <td class="doc">Stops the selenium server (and closes all browsers).</td>
    </tr>
    <tr>
      <td class="kw"><a name="Submit Form"></a>Submit Form</td>
      <td class="arg">locator=</td>
      <td class="doc"></td>
    </tr>
    <tr>
      <td class="kw"><a name="Wait Until Page Contains"></a>Wait Until Page Contains</td>
      <td class="arg">text=, timeout=, error=</td>
      <td class="doc">Waits until text appears on current page.<br />
    <br />
    Fails if timeout expires before the text appears. See introduction for more information about timeout and its default value. error can be used to override the default error message.<br />
    <br />
    <b>Note:</b> <i>timeout</i> has no effect on phantomrobot.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Wait Until Page Contains Element"></a>Wait Until Page Contains Element</td>
      <td class="arg">locator=, timeout=, error=</td>
      <td class="doc">Waits until element specified with locator appears on current page.<br />
    <br />
    Fails if timeout expires before the element appears. See introduction for more information about timeout and its default value.<br />
    <br />
    <i>error</i> can be used to override the default error message.<br />
    <br />
    <b>Note:</b> <i>timeout</i> has no effect on phantomrobot.</td>
    </tr>
    <tr>
      <td class="kw"><a name="Wait Until Page Contains Visible"></a>Wait Until Page Contains Visible</td>
      <td class="arg">text=, timeout=, error=</td>
      <td class="doc">Waits until visible text appears on current page.<br />
    <br />
    Fails if timeout expires before the text appears. See introduction for more information about timeout and its default value. error can be used to override the default error message.<br />
    <br />
    <b>Note:</b> <i>timeout</i> has no effect on phantomrobot.</td>
    </tr>
    <tr>
      <td class="kw"><a name="XPath Should Match X Times"></a>XPath Should Match X Times</td>
      <td class="arg">xpath=, expected_xpath_count=, message=, loglevel=</td>
      <td class="doc">Verifies that the page contains the given number of elements located by the given <i>xpath</i>.</td>
    </tr>
    </table>
    <p id="footer">
    Altogether 42 keywords.<br />
    Generated by <a href="http://code.google.com/p/robotframework/wiki/LibraryDocumentationTool">libdoc.py</a>
    on 2012-03-25 20:05:58.
    </p>


An example test suite
=====================

.. note:: Please, note that Robot framework also supports tests in
   `given–when–then`__-syntax.

.. __: http://robotframework.googlecode.com/svn/tags/robotframework-2.1.2/doc/userguide/RobotFrameworkUserGuide.html#behavior-driven-style

::

    *** Settings ***
    Library  Remote  http://localhost:1337/

    Suite Setup  Start browser
    Suite Teardown  Close browser

    *** Variables ***

    *** Test cases ***

    Plone Accessibility
        Goto homepage
        Click link  Accessibility
        Page should contain  Accessibility

    Plone Log In
        Go to  http://localhost:8080/Plone/login_form
        Page should contain element  __ac_name
        Input text  __ac_name  admin
        Input text  __ac_password  admin
        Click Button  Log in
        Page should contain  now logged in
        click link  Continue to the Plone site home page
        Page should contain  Manage portlets

    *** Keywords ***

    Start browser
        Open browser  http://localhost:8080/Plone/

    Goto homepage
        Go to  http://localhost:8080/Plone/
        Page should contain  Plone site


How does it work?
=================

PhantomRobot

1) provides an XML-RPC-service, which
2) implements Robot Framework's remote library API,
3) spawns a headless PhantomJS client as its child process and
4) relays its commands to that client using WebSockets.

.. note:: (Insert a nice diagram here.)

PhantomRobot borrows some ideas from RoboZombie_ – a similar proof-of-concept
remote library for Zombie.js_.

.. _RoboZombie: https://github.com/mkorpela/RoboZombie
.. _Zombie.js: http://zombie.labnotes.org/


Basic usage
-----------

1. Launch ``phantomrobot`` onto foreground by ``node phantomrobot.js``.
2. Run a Robot Framework -testsuite (e.g. ``pybot testsuite.txt``).

`node phantomrobot.js` accepts the following arguments:

``--port=1337``
    a local port number for this Robot Framework remote library (PhantomJS will
    connect to PhantomRobot through ``port + 1``, e.g. ``1338``)
``--implicit-wait=10``
    implicit timeout for retrying failing keywords, e.g. *page contains* (can
    be disabled with ``implicit-wait=-1`` unless is set explicitly in a test)
``--implicit-sleep=0.1``
    time to sleep between retries until the implicit timeout


Dependencies
------------

All of the following dependencies for running PhantomRobot should be
installed automatically by running the provided buildout:

- PhantomJS_ >= 1.3 available on path
- node.js_ and npm_ with

  * *xmlrpc* >= 0.9.4
  * *socket.io* == 0.8.7 (unknown error with 0.9.0)
  * *optimist* and
  * *coffee-script* >= 1.2.0
