class Robot

    "Start Selenium Server": (params, respond) ->
        respond status: "PASS"

    "Set Phantom Timeout": (params, respond) ->
        timeout = params[1][0]
        seconds = /(\d)+s/
        if seconds.test(timeout)
            robot.timeout = timeout.match(seconds)[1]
            respond status: "PASS"
        respond status: "FAIL", error: "Unsupported timeout '#{timeout}'."

    "Set Selenium Timeout": (params, respond) ->
        @["Set Phantom Timeout"] params, respond

    "Register Keyword to Run on Failure": (params, respond) ->
        keyword = params[1][0]
        names = (name.replace(/\_/g, " ") for name, _ of this\
            when name[0].toUpperCase() == name[0])
        if keyword in names
            robot.on_failure.push(keyword)
            respond status: "PASS"
        else
            # respond status: "FAIL", error: "There's no keyword '#{keyword}'."
            respond status: "PASS"

    "Stop Selenium Server": (params, respond) ->
        respond status: "PASS"

