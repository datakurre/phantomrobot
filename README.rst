============================================
PhantomJS Remote Library for Robot Framework
============================================

This is a proof-of-concept PhantomJS integration for Robot Framework.

This package provides an XML-RPC-service, which implements Robot Framework's
remote library API, spawns a headless PhantomJS client and relays its commands
to that client using WebSockets.

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

- PhantomJS_ >= 1.3 available on path
- node.js_ and npm_ with

  * *xmlrpc* >= 0.9.4 (fails with 0.9.3)
  * *socket.io* == 0.8.7 (fails with 0.9.0)
  * *optimist* and
  * *coffee-script* >= 1.2.0 -modules installed

- ``make`` to run ``Makefile``

**Note:** On RHEL5 / CentOS5 I needed to build a more recent version of GNU Tar
>= 1.2.6 to make npm installing modules successfully.  Yet, because
websockets-support was broken in all existing QtWebKit-RPMs (thanks to
https://bugs.webkit.org/show_bug.cgi?id=47284), I had to build my own WebKit to
be able to compile working PhantomJS and get this running.

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
    a local port number for this Robot Framework remote library (PhantomJS will
    connect to phantomrobot through ``port + 1``, e.g. ``1338``)
``--implicit-wait=10``
    implicit timeout for supporting keywords, e.g. *page contains* (can be
    disabled with ``implicit-wait=-1``)
``--implicit-sleep=0.1``
    time to sleep between trials until implicit timeout


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
    parts += robot
    find-links += http://packages.affinitic.be/simple
    versions=versions

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
