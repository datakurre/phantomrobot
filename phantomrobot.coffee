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

    constructor: ->
        @proxy = require("http").createServer()
        @proxy.listen 1338

        @io = io.listen(@proxy)
        console.log "Listening for PhantomJS on port 1338"

        @io.sockets.on "connection", (socket) ->
            console.log "Got connection from PhantomJS"

            server = xmlrpc.createServer host: "localhost", port: 1337

            # Because robot framework's remote API is synchronous, we may
            # simply overload a single callback-method for all return values.
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
            console.log("Remote robot server is now available on port 1337")

        @phantom =\
            require("child_process").exec "phantomjs phantomrobot.coffee",
            (err, stdout, stderr) -> console.log stdout
        process.on "SIGTERM", -> do @phantom.kill


class PhantomRobot

    constructor: (@library = null) ->
        @socket = io.connect "http://localhost:1338/"
        for name, _ of this
            if name not in ["library", "socket", "create_callback"]
                @create_callback name

    create_callback: (name) ->
        console.log "Listening for #{name}"
        @socket.on name, (params) =>
            @[name] params, (response) =>
                if response?.status == "FAIL"
                    # take a screenshot and embed it to the log
                    fs = require "fs"
                    filename = "#{(new Date).getTime().toString()}.png"
                    response.output =\
                        "*HTML* "\
                        + "<img src='#{fs.workingDirectory}#{fs.separator}"\
                        + "#{filename}'/>"
                    @library.page?.render filename
                @socket.emit "callback", response

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
            @library[params[0].replace(/\s/g, "_")](params, callback)
        catch e
            callback status: "FAIL", error: e.toString()


if not phantom? then do ->
    # on node.js
    global.io = require "socket.io"
    if not io
        console.log "requires socket.io"
        console.log "npm install socket.io"

    global.xmlrpc = require "xmlrpc"
    if not xmlrpc
        console.log "Requires node-xmlrpc"
        console.log "npm install xmlrpc"

    new PhantomProxy

else do ->
    # on phantomjs
    phantom.injectJs "lib/socket.io.js"

    # XXX: new keyword libraries (mixins) must be loaded here:
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
            extend(this, new Browser)
            extend(this, new Click)
            extend(this, new Page)
            extend(this, new TextField)

    new PhantomRobot(new PhantomLibrary)
