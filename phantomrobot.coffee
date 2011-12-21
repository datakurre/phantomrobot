# Copyright (C) 2011  Asko Soukka <asko.soukka@iki.fi>
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


class PhantomProxy

    constructor: (port=1337, timeout=10, sleep=1, screenshots_dir="..") ->
        @proxy = require("http").createServer()
        @proxy.listen port + 1

        @io = io.listen(@proxy)
        console.log "Listening for PhantomJS on port #{port + 1}"

        @io.sockets.on "connection", (socket) ->
            console.log "Got connection from PhantomJS"

            server = xmlrpc.createServer host: "localhost", port: port

            # Because robot framework's remote API is synchronous, we may
            # simply overload a single callback-method for all return values.
            sync_callback = null

            create_callback = (name) ->
                (err, params, callback) ->
                    sync_callback = callback
                    socket.emit name, params

            socket.on "callback", (data) ->
                sync_callback null, data

            api_method_names = [
                "get_keyword_names"
                "get_keyword_documentation"
                "get_keyword_arguments"
                "run_keyword"
            ]

            for name in api_method_names
                console.log "Listening for #{name}"
                server.on name, create_callback name
            console.log "Remote robot server is now listening on port #{port}"

        @phantom =\
            require("child_process").exec "phantomjs phantomrobot.js "\
                + "#{port + 1} #{timeout} #{sleep} #{screenshots_dir}",
            (err, stdout, stderr) -> console.log stdout
        process.on "SIGTERM", -> do @phantom.kill


class PhantomRobot

    constructor: (@library=null, @port=1338, @timeout=10, @sleep=1,\
                  @screenshots_dir=".",\
                  @on_failure="Capture Page Screenshot") ->
        @socket = io.connect "http://localhost:#{port}/"
        for name, _ of this
            if name not in ["library", "port", "timeout", "sleep",
                            "screenshots_dir", "on_failure",
                            "socket", "create_callback"]
                @create_callback name
        window.robot = this

    create_callback: (name) ->
        console.log "Listening for #{name}"
        @socket.on name, (params) =>
            timeout = new Date().getTime() + @timeout* 1000

            callback = (response) =>
                if response?.status == "WAIT"
                    # on WAIT, retry after @sleep until timeout
                    if new Date().getTime() < timeout
                        setTimeout =>
                            @[name] params, (response) => callback response
                        , @sleep * 1000
                    else
                        response.status = "FAIL"

                if response?.status == "FAIL"
                    if @on_failure
                        @run_keyword [@on_failure, []], (sub) =>
                            response.output = sub?.output or response?.output
                            @socket.emit "callback", response
                    else
                        @socket.emit "callback", response

                else if response?.status == "PASS"
                    console.log response
                    @socket.emit "callback", response

            @[name] params, (response) => callback response

    get_keyword_names: (params, callback) ->
        names = (name.replace(/\_/g, " ") for name, _ of @library\
            when name[0].toUpperCase() == name[0])
        callback names

    get_keyword_documentation: (params, callback) ->
        callback "n/a"

    get_keyword_arguments: (params, callback) ->
        callback ["*args"]

    run_keyword: (params, callback) ->
        try
            if params[0] of @library
                @library[params[0]](params, callback)
            else
                @library[params[0].replace(/\s/g, "_")](params, callback)
        catch e
            callback status: "FAIL", error: e.toString()


if not phantom? then do ->
    # on node.js
    try
        global.io = require "socket.io"
    catch e
        console.log "requires node-socket.io"
        console.log "npm install socket.io"
        process.exit 1

    try
        global.xmlrpc = require "xmlrpc"
    catch e
        console.log "Requires node-xmlrpc"
        console.log "npm install xmlrpc"
        process.exit 1

    try
        optimist = require "optimist"
    catch e
        console.log "Requires node-optimist"
        console.log "npm install optimist"
        process.exit 1

    argv = optimist.argv

    port = argv?.port or 1337
    timeout = argv?["implicit-wait"] or 10
    sleep = argv?["implicit-sleep"] or 1
    screenshots_dir = argv?["screenshots-dir"] or ".."

    new PhantomProxy port, timeout, sleep, screenshots_dir

else do ->
    # on phantomjs
    phantom.injectJs "lib/socket.io.js"

    # XXX: new keyword libraries (mixins) must be loaded here:
    phantom.injectJs "lib/robot.js"
    phantom.injectJs "lib/browser.js"
    phantom.injectJs "lib/click.js"
    phantom.injectJs "lib/page.js"
    phantom.injectJs "lib/textfield.js"

    extend = (obj, mixin) ->
      for name, method of mixin
          obj[name] = method

    class PhantomLibrary
        constructor: ->
            # XXX: ... and merged into main library here:
            extend(this, new Robot)
            extend(this, new Browser)
            extend(this, new Click)
            extend(this, new Page)
            extend(this, new TextField)

    port = phantom.args.length > 0 and parseInt(phantom.args[0], 10) or 1338
    timeout = phantom.args.length > 1 and parseInt(phantom.args[1], 10) or 10
    sleep = phantom.args.length > 2 and parseInt(phantom.args[2], 10) or 1
    screenshots_dir = phantom.args.length > 3 and phantom.args[3] or ".."

    new PhantomRobot(new PhantomLibrary, port, timeout, sleep, screenshots_dir)
