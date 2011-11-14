class Browser

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
