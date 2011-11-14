phantom.injectJs "socket.io.js"


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


class BaseLibrary

    Open_Browser: (params, respond) ->
        @page = do require("webpage").create
        @page.viewportSize = width: 1024, height: 768
        @page.onConsoleMessage = (msg) -> console.log msg
        respond status: "PASS"

    Close_Browser: (params, respond) ->
        @page = null
        respond status: "PASS"

    Go_To: (params, respond) ->
        url = params[1][0]
        has_been_completed = false
        @page.open url, (status) ->
            if not has_been_completed
                has_been_completed = true
                respond status: "PASS"

    Page_Should_Contain: (params, respond) ->
        needle = params[1][0]
        html = @page.evaluate -> document.documentElement.innerHTML
        if html.indexOf(needle)> -1
            respond status: "PASS"
        else
            respond status: "FAIL"

    Page_Should_Contain_Element: (params, respond) ->
        id = params[1][0]

        # FIXME: PhantomJS >= 1.4 may allow passing variables into evaluate
        fn = null
        eval("fn = function() { document._tvar = '#{id}'; }")
        @page.evaluate fn
        contains_element = @page.evaluate ->
            document.getElementById(document._tvar) and true or false

        if contains_element
            respond status: "PASS"
        else
            respond status: "FAIL"

    # Click_Link: (params, respond) ->
    #     respond status: "FAIL", error: "Keyword not yet implemented."

    # Close_Browser: (params, respond) ->
    #     respond status: "FAIL", error: "Keyword not yet implemented."

    # Input_Text: (params, respond) ->
    #     respond status: "FAIL", error: "Keyword not yet implemented."

    # Click_Button: (params, respond) ->
    #     respond status: "FAIL", error: "Keyword not yet implemented."

    # Location_Should_Be: (params, respond) ->
    #     respond status: "FAIL", error: "Keyword not yet implemented."

    # Title_Should_Be: (params, respond) ->
    #     respond status: "FAIL", error: "Keyword not yet implemented."


new PhantomRobot(new BaseLibrary)
