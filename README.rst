============================================
PhantomJS Remote Library for Robot Framework
============================================

PhantomRobot is an extendable `Robot Framework`_ remote library to run your
acceptance tests on a headless `PhantomJS`_ (WebKit) browser. PhantomRobot is
written in and is extendable with `CoffeeScript`_.

.. _Robot Framework: http://code.google.com/p/robotframework/
.. _PhantomJS: http://www.phantomjs.org/
.. _CoffeeScript: http://coffeescript.org/


Try it out
----------

Checkout the code::

    git clone git://github.com/datakurre/phantomrobot.git

Change to the checkout directory to the buildout to install dependencies (under
the checkout directory)::

    cd phantomrobot
    python bootstrap.py --distribute

On a 32-bit Linux [1]_, continue with::

    bin/buildout -c buildout-linux-x86.cfg

On a 64-bit Linux [1]_, continue with::

    bin/buildout -c buildout-linux-x86_64.cfg

On a OSX [1]_, continue with::

    bin/buildout

After the buildout has compiled `node.js`_ and installed required
node.js-packages using `npm`_, you should be able to compile PhantomRobot::

    source bin/activate
    make

And launch it (as a blocking foreground process)::

    node phantomrobot.js

To run some Robot Framework tests using PhantomRobot, you could open a new
console, change to the checkout/buildout-directory of PhantomRobot, and::

    source bin/activate
    pybot tests

.. _node.js: http://nodejs.org/
.. _npm: http://npmjs.org/

.. [1] PhantomRobot requires ``phantomjs``-binary, which is provided by
   `PhantomJS`_' developers for 32-bit Linux, 64-bit Linux, OSX and Windows.
   If the binary distribution doesn't work PhantomJS could be compiled
   manually, in theory.

   **Note:** On RHEL5 / CentOS5 I needed to build a more recent version of GNU
   Tar >= 1.2.6 to make npm installing modules successfully.  Yet, because
   websockets-support was broken in all existing QtWebKit-RPMs (thanks to
   https://bugs.webkit.org/show_bug.cgi?id=47284), I had to build my own WebKit
   to be able to compile working PhantomJS and get this running.

About
=====

PhantomRobot provides an XML-RPC-service, which implements Robot Framework's
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
