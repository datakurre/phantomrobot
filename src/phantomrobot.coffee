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

class PhantomProxy
    ###
    PhantomProxy a Node.js XML-RPC-server, which implements Robot Framework's
    remote library API, spawns a headless PhantomJS client as its child
    process, and relays its commands to that client using WebSockets:
    PhantomProxy has a socket.io-based WebSockets-server (http), to which the
    spawned PhantomJS client connects to receive Robot Framework test keywords.
    ###

    constructor: (port, timeout, sleep) ->
        # Define a socket.io-server to be connected by PhantomJS.
        @io = io.listen(port + 1)
        console.log "Listening for PhantomJS on port #{port + 1}"

        # On a socket.io-connection, launch the XML-RPC-server.
        @io.sockets.on "connection", (socket) ->
            console.log "Got connection from PhantomJS"

            # Setup our custom loggers by re-using socket.io's logger.
            socket.on "info", (msg) -> socket.log.info msg
            socket.on "debug", (msg) -> socket.log.debug msg
            socket.on "warn", (msg) -> socket.log.warn msg
            socket.on "error", (msg) -> socket.log.error msg

            # Define an XML-RPC-server to be connected by Robot Framework.
            server = xmlrpc.createServer host: "localhost", port: port

            # Define re-usable callback to relay Robot Framework commands
            # the the connected socket.io-client (our PhantomJS-client).
            create_callback = (name) -> (err, params, callback) ->
                callback_id = new Date().getTime()
                socket.on callback_id, (data) -> callback null, data
                socket.emit name, params.concat [callback_id]
                # ^ Each XML-RPC-call will have its private socket.io-callback.

            # Define XML-RPC-methods for Robot Framework using the re-usable
            # callback defined above.
            server.on "get_keyword_names",
                create_callback "get_keyword_names"

            server.on "get_keyword_documentation",
                create_callback "get_keyword_documentation"

            server.on "get_keyword_arguments",
                create_callback "get_keyword_arguments"

            server.on "run_keyword",
                create_callback "run_keyword"

            console.log "Remote robot server is now listening on port #{port}"
            # ^ Done. PhantomJS is connected and PhantomRobot is listening...

        # Build our PhantomJS launch command with relative path to the cwd.
        path = require "path"
        fullpath = path.join __dirname, "phantomrobot.js"
        relpath = path.relative process.cwd(), fullpath
        phantomjs = "phantomjs #{relpath} #{port + 1} #{timeout} #{sleep}"
        child_process = require "child_process"

        # Spawn a new PhantomJS-client as a child process.'
        console.log phantomjs
        @phantom = child_process.exec phantomjs, (err, stdout, stderr) ->
            console.log err or stdout
        # Kill the PhantomJS-child on SIGTERM.
        process.on "SIGTERM", -> do @phantom.kill


class PhantomRobot
    ###
    PhantomRobot is a PhantomJS-application, which connects to PhantomProxy
    using WebSockets (socket.io), implements Robot Framework's remote library
    API, and executes the actual test keywords on PhantomJS.
    ###

    constructor: (@library=null, @port, @timeout, @sleep,\
                  @on_failure="Capture page screenshot") ->
        # Connect to PhantomProxy using socket.io (WebSockets)
        @socket = io.connect "http://localhost:#{port}/"
        @info "port #{@port} timeout #{@timeout} sleep #{@sleep}"

        # Create socket.io-methods for Robot Framework's remote library API.
        @create_callback "get_keyword_names"
        @create_callback "get_keyword_documentation"
        @create_callback "get_keyword_arguments"
        @create_callback "run_keyword"

        # Define PhantomRobot instance as a global variable `robot`.
        window.robot = this

    # Setup our custom loggers.
    info: (msg) -> @socket.emit "info", msg
    debug: (msg) -> @socket.emit "debug", msg
    warn: (msg) -> @socket.emit "warn", msg
    error: (msg) -> @socket.emit "error", msg

    # Define the main callback execution loop, which implicitly retries failing
    # test keywords until either success or timeout.
    create_callback: (name) ->
        @info "listening for #{name}"
        @socket.on name, (params) =>
            # Define a timeout and pop the unique callback-method name.
            timeout = new Date().getTime() + @timeout * 1000
            callback_id = do params.pop

            # Define the callback loop with implicit retry until the timeout.
            callback = (results) =>
                now = new Date().getTime()

                # On FAIL, retry after @sleep until the timeout.
                if results?.status == "FAIL" and now < timeout
                    setTimeout =>
                        try @[name] params, (results) => callback results
                        catch e then callback status: "FAIL",\
                                              error: do e.toString
                    , @sleep * 1000
                    results.status = "RETRY"

                # On FAIL and the timeout, run @on_failure keyword and return.
                if results?.status == "FAIL"
                    if @on_failure
                        @run_keyword [@on_failure, []], (sub) =>
                            results.output = sub?.output or results?.output
                            @socket.emit callback_id, results
                    else
                        @socket.emit callback_id, results

                # On any success, return the results.
                if results?.status not in ["FAIL", "RETRY"]
                    @socket.emit callback_id, results

                # On RETRY, log it.
                else if results?.status == "RETRY"
                    @debug "RETRY #{results.error}"

            # Execute the method using the callback loop and catch exceptions.
            try @[name] params, (results) => callback results
            catch e then callback status: "FAIL",\
                                  error: do e.toString

    # Return names of implemented keywords.
    get_keyword_names: ([], callback) ->
        names = (name.replace(/\_/g, " ") for name, _ of @library\
            when name[0].toUpperCase() == name[0])
        callback names

    # Return keyword's documentation.
    get_keyword_documentation: ([keyword], callback) ->
        if not keyword of @library
            keyword = keyword.replace(/\s/g, "_")
        callback @library[keyword].__doc__

    # Return keyword's argument specification.
    get_keyword_arguments: ([keyword], callback) ->
        if not keyword of @library
            keyword = keyword.replace(/\s/g, "_")
        callback @library[keyword].__args__

    # Return names of implemented keywords.
    run_keyword: ([keyword, params], callback) ->
        try
            if not keyword of @library
                keyword = keyword.replace(/\s/g, "_")
            @library[keyword] params, callback
        catch e
            callback status: "FAIL", error: e.toString()


##
# The "main function", when PhanomRobot is executed on Node.js.
if not phantom? then do ->
    # Require "node-socket.io"
    try
        global.io = require "socket.io"
    catch e
        console.log "requires node-socket.io"
        console.log "npm install socket.io"
        process.exit 1
    # Require "node-xmlrpc"
    try
        global.xmlrpc = require "xmlrpc"
    catch e
        console.log "Requires node-xmlrpc"
        console.log "npm install xmlrpc"
        process.exit 1
    # Require "optimist" and parse command line arguments
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
    # Create a new PhantomProxy-instance with the parsed cmd-line arguments.
    new PhantomProxy argv.port, argv["implicit-wait"], argv["implicit-sleep"]

##
# The "main function", when PhanomRobot is executed on PhantomJS.
else do ->
    # Require "socket.io" (the client library)
    phantom.injectJs "socket.io.js"

    # Parse the command line arguments.
    port = parseInt(phantom.args[0], 10)
    timeout = parseFloat(phantom.args[1], 10)
    sleep = parseFloat(phantom.args[2], 10)

    # Define a Robot Framework -keyword library from the registered keywords.
    class PhantomLibrary
        constructor: -> for name, func of PhantomKeywords then @[name] = func

    # Create a new PhantomRobot-instance with the keyword library and args.
    new PhantomRobot(new PhantomLibrary, port, timeout, sleep)
