============================================
PhantomJS Remote Library for Robot Framework
============================================

This is a proof-of-concept PhantomJS integration for Robot Framework.

This package provides an XML-RPC-service, which implements Robot Framework's
remote library API and relays its commands to PhantomJS using WebSocket.

**Disclaimer:** To be complete enough to be useful, the library should contain
implementations for the same keywords as SeleniumLibrary_. Yet, I'm not sure
if that's worth of the effort. Maybe one should just implement Selenium
`WebDriver Wire Protocol`_ instead...

This borrows many ideas from RoboZombie_ – a similar proof-of-concept remote
library for Zombie.js_.

.. _SeleniumLibrary: http://code.google.com/p/robotframework-seleniumlibrary/
.. _WebDriver Wire Protocol: http://code.google.com/p/selenium/wiki/JsonWireProtocol
.. _RoboZombie: https://github.com/mkorpela/RoboZombie
.. _Zombie.js: http://zombie.labnotes.org/


Requirements
============

- PhantomJS_ available on path
- node.js_ and npm_ with

  * *xmlrpc*
  * *socket.io*
  * *optimist* and
  * *coffee-script* -modules installed

- ``make`` to run ``Makefile``

.. _PhantomJS: http://www.phantomjs.org/
.. _node.js: http://nodejs.org/
.. _npm: http://npmjs.org/


Usage
=====

1. Launch ``phantomrobot`` onto background by ``node phantomrobot.js``.
2. Run a Robot Framework -testsuite (e.g. ``pybot testsuite.txt``).


Arguments
=========

``--port=1337``
    a local port number for this Robot Framework remote library
    (PhantomJS will connect to phantomrobot through port + 1, e.g. 1338)
``--implicit-wait=10``
    implicit timeout for certain keywords, e.g. "page contains";
    disable with ``implicit-wait=-1``
``--implicit-sleep=1``
    time to sleep between trials until implicit timeout
``--screenshots-dir=``
    full path to directory to save screenshot of test failures
    (defaults to the parent of the PhantomJS' working directory)


An example of use
=================

I'm developing and testing this with Plone_, which is usually put together
using buildout_ as follows...

.. _Plone: http://plone.org/
.. _buildout: http://www.buildout.org/


A pybot-buildout
----------------

::

    [buildout]
    extends = buildout.cfg
    find-links += http://packages.affinitic.be/simple
    allow-hosts +=
        robotframework.googlecode.com
        robotframework.org
        code.google.com
        selenium.googlecode.com
        seleniumhq.org
        www.openqa.org
        packages.affinitic.be
    parts += robot

    [versions]
    robotframework = 2.5.7-st1

    [robot]
    recipe = zc.recipe.egg
    eggs = robotframework


An example test suite
---------------------

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
