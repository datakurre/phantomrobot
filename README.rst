PhantomJS Remote Library for Robot Framework
============================================

This is a proof-of-concept PhantomJS integration for Robot Framework.

This package provides an XML-RPC-service, which implements Robot Framework's
remove library API and relays its commands to PhantomJS using WebSocket.

To be complete enough to be useful, the library should contain implementations
for the same keywords as SeleniumLibrary_. Yet, I'm not sure if that's worth of
the effort, because maybe one should just implement Selenium `WebDriver Wire
Protocol`_ instead.

This borrows many ideas from RoboZombie_ – a similar proof-of-concept remote
library for Zombie.js_.

.. _SeleniumLibrary: http://code.google.com/p/robotframework-seleniumlibrary/
.. _WebDriver Wire Protocol: http://code.google.com/p/selenium/wiki/JsonWireProtocol
.. _RoboZombie: https://github.com/mkorpela/RoboZombie
.. _Zombie.js: http://zombie.labnotes.org/


Requirements
------------

- PhantomJS_
- node.js_ and  npm_ with

  * *xmlrpc*
  * *socket.io* and
  * *coffee-script* installed

- ``make`` to run ``Makefile``

.. _PhantomJS: http://www.phantomjs.org/
.. _node.js: http://nodejs.org/
.. _npm: http://npmjs.org/


Usage
-----

1. Launch ``phantomrobot`` onto background by ``node phantomrobot.js``.
2. Run Robot Framework -test, e.g. by ``pybot testsuite.txt``.


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
        Go to  http://localhost:8080/plone/login_form
        Page should contain element  __ac_name
        Input text  __ac_name  admin
        Input text  __ac_password  admin
        Click Button  Log in
        Wait until keyword succeeds  1  1  Page should contain  now logged in
        click link  Continue to the Plone site home page
        Wait until keyword succeeds  1  1  Page should contain  Manage portlets


    *** Keywords ***

    Start browser
        Open browser  http://localhost:8080/plone/

    Goto homepage
        Go to  http://localhost:8080/plone/
        Page should contain  Plone site
