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


Selenium keywords
=================

My secret goal is to provide full and fully tested set of keywords available in
Robot Framework SeleniumLibrary_. Unfortunately, it may take some time for me
to find enough free time to get that completed.

.. _SeleniumLibrary: http://code.google.com/p/robotframework-seleniumlibrary/

Meanwhile, you a free to either help or implement your own custom keywords,
e.g. for testing your custom JavaScript-dependent features directly.

.. note:: (Insert table of available and tested built-in-keywords here.)


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
restrictions of browser context and can take advantage of `PhantomJS' API`_
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

.. _Phantom JS' API: http://code.google.com/p/phantomjs/wiki/Interface

.. note:: ``@browser.eval`` is a thin wrapper around PhantomJS_'
   *WebPage.evaluate*. It can accept parameters any number of parameters.
   Besides that, it defines a special function ``queryAll`` to be usable to
   make DOM queries with CSS-selector, XPATH-expression or DOM element id.  For
   more examples, please, see built-in keyword definitions.


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
