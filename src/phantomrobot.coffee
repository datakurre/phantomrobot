###
Copyright (C) 2011  Asko Soukka <asko.soukka@iki.fi>

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

###
This package provides an XML-RPC-service, which implements Robot Framework's
remote library API, spawns a headless PhantomJS client and relays its commands
to that client using WebSockets.
###

class PhantomProxy

    constructor: (port, timeout, sleep) ->
        ###
        @io is a socket.io-server connected by PhantomJS via WebSockets
        ###
        @io = io.listen(port + 1)
        console.log "Listening for PhantomJS on port #{port + 1}"

        @io.sockets.on "connection", (socket) ->
            console.log "Got connection from PhantomJS"

            ###
            setup logger by re-using socket.io's logger
            ###
            socket.on "info", (msg) -> socket.log.info msg
            socket.on "debug", (msg) -> socket.log.debug msg
            socket.on "warn", (msg) -> socket.log.warn msg
            socket.on "error", (msg) -> socket.log.error msg

            ###
            server is an xmlrpc server connected by Robot Framework
            ###
            server = xmlrpc.createServer host: "localhost", port: port

            create_callback = (name) -> (err, params, callback) ->
                callback_id = new Date().getTime()
                socket.on callback_id, (data) -> callback null, data
                socket.emit name, params.concat [callback_id]

            for name in ["get_keyword_names", "get_keyword_documentation",\
                         "get_keyword_arguments", "run_keyword"]
                server.on name, create_callback name

            console.log "Remote robot server is now listening on port #{port}"

        path = require "path"
        fullpath = path.join __dirname, "phantomrobot.js"
        relpath = path.relative process.cwd(), fullpath
        phantomjs = "phantomjs #{relpath} #{port + 1} #{timeout} #{sleep}"
        child_process = require "child_process"

        console.log phantomjs
        @phantom = child_process.exec phantomjs, (err, stdout, stderr) ->
            console.log err or stdout
        process.on "SIGTERM", -> do @phantom.kill


class PhantomRobot

    constructor: (@library=null, @port, @timeout, @sleep,\
                  @on_failure="Capture page screenshot") ->
        @socket = io.connect "http://localhost:#{port}/"
        @info "port #{@port} timeout #{@timeout} sleep #{@sleep}"
        for name, _ of this
            if name not in ["library", "port", "timeout", "sleep",
                            "on_failure", "socket", "create_callback",
                            "info", "debug", "warn", "error"]
                @create_callback name
        window.robot = this  # make me a global variable

    ###
    setup logger by re-using socket.io's logger
    ###
    info: (msg) -> @socket.emit "info", msg
    debug: (msg) -> @socket.emit "debug", msg
    warn: (msg) -> @socket.emit "warn", msg
    error: (msg) -> @socket.emit "error", msg

    ###
    main execution loop to retry commands until success or timeout
    ###
    create_callback: (name) ->
        @info "listening for #{name}"
        @socket.on name, (params) =>
            timeout = new Date().getTime() + @timeout * 1000
            callback_id = do params.pop

            callback = (response) =>
                timenow = new Date().getTime()
                # on FAIL, retry after @sleep until the timeout
                if response?.status == "FAIL" and timenow < timeout
                    setTimeout =>
                        @[name] params, (response) => callback response
                    , @sleep * 1000
                    response.status = "RETRY"
                # on FAIL and the timeout, run @on_failure keyword and return
                if response?.status == "FAIL"
                    if @on_failure
                        @run_keyword [@on_failure, []], (sub) =>
                            response.output = sub?.output or response?.output
                            @socket.emit callback_id, response
                    else
                        @socket.emit callback_id, response
                # on any success, return the result
                if response?.status not in ["FAIL", "RETRY"]
                    @socket.emit callback_id, response

                # on RETRY, log it
                else if response?.status == "RETRY"
                    @debug "RETRY #{response.error}"

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
        if params?.length
            try
                if params[0] of @library
                    @library[params[0]](params, callback)
                else
                    @library[params[0].replace(/\s/g, "_")](params, callback)
            catch e
                callback status: "FAIL", error: e.toString()
        else
            callback status: "FAIL", "Got run_keyword without any parameters."


if not phantom? then do ->
    ###
    Executed on node.js
    ###
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
        optimist = require("optimist").default
            port: 1337
            "implicit-wait": 10
            "implicit-sleep": 0.1
        argv = optimist.argv
    catch e
        console.log "Requires node-optimist"
        console.log "npm install optimist"
        process.exit 1

    new PhantomProxy argv.port, argv["implicit-wait"], argv["implicit-sleep"]

else do ->
    ###
    Executed on phantomjs
    ###
    phantom.injectJs "socket.io.js"

    extend = (obj, mixin) ->
      for name, method of mixin
          obj[name] = method

    class PhantomLibrary
        constructor: ->
            extend(this, new Robot)
            extend(this, new Browser)
            extend(this, new Page)
            extend(this, new Mouse)
            extend(this, new Form)

    port = parseInt(phantom.args[0], 10)
    timeout = parseFloat(phantom.args[1], 10)
    sleep = parseFloat(phantom.args[2], 10)

    new PhantomRobot(new PhantomLibrary, port, timeout, sleep)
