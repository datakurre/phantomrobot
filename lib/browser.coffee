class Browser

    "Open browser": (params, respond) ->
        @page = do require("webpage").create
        @page.viewportSize = width: 1024, height: 768
        @page.onConsoleMessage = (msg) -> console.log msg

        @page._robotIsPosting = false
        @page.onResourceRequested = (request) =>
            if request.method == "POST"
                @page._robotIsPosting = request.url
        @page.onResourceReceived = (request) =>
            if @page._robotIsPosting and @page._robotIsPosting == request.url
                @page._robotIsPosting = false

        respond status: "PASS"

    "Maximize browser window": (params, respond) ->
        # FIXME: Maximize
        @page.viewportSize = width: 1024, height: 768
        respond status: "PASS"

    "Close browser": (params, respond) ->
        @page = null
        respond status: "PASS"

    "Go to": (params, respond) ->
        url = params[1][0]
        has_been_completed = false

        if @page._robotIsPosting
            respond status: "WAIT", "There is an incomplete POST in progress."
        else
            @page.open url, (status) ->
                if not has_been_completed
                    has_been_completed = true
                    respond status: "PASS"
