# Some ideas got from RoboZombie

io = require "socket.io"
if not io
    console.log "requires socket.io"
    console.log "npm install socket.io"

xmlrpc = require "xmlrpc"
if not xmlrpc
    console.log "Requires node-xmlrpc"
    console.log "npm install xmlrpc"

class PhantomProxy

    constructor: ->
        @proxy = require("http").createServer()
        @proxy.listen 1338

        @io = io.listen(@proxy)
        console.log "Listening for PhantomJS on port 1338"

        @io.sockets.on "connection", (socket) ->
            console.log "Got connection from PhantomJS"

            server = xmlrpc.createServer host: "localhost", port: 1337

            # Because robot framework's remote API is synchronous, we may
            # overload single callback-method for all return values.
            sync_callback = null

            create_callback = (name) ->
                (err, params, callback) ->
                    sync_callback = callback
                    socket.emit name, params

            socket.on "callback", (data) -> sync_callback null, data

            api_method_names = [
                "get_keyword_names"
                "get_keyword_documentation"
                "get_keyword_arguments"
                "run_keyword"
            ]

            for name in api_method_names
                console.log "Listening for #{name}"
                server.on name, create_callback name
            console.log("Remote robot server now on port 1337")

        @phantom =\
            require("child_process").exec "phantomjs lib/phantomclient.coffee",
            (err, stdout, stderr) -> console.log stdout
        process.on "SIGTERM", ->  do @phantom.kill

new PhantomProxy
