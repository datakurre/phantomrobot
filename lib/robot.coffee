class Robot
    "Capture Page Screenshot": (params, respond) ->
        if @page?.render
            # take a screenshot and embed it into the log
            fs = require "fs"
            filename =\
                "#{robot.screenshots_dir}/#{new Date().getTime()}.png"
            output =\
                "*HTML* "\
                + "<img src='#{fs.workingDirectory}#{fs.separator}"\
                + "#{filename}'/>"
            @page.render filename
            respond status: "PASS"
        else
            respond status: "FAIL", error: "There's no page."

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
            previous = robot.on_failure
            robot.on_failure = keyword
            respond status: "PASS", output: previous
        else
            respond status: "FAIL", error: "There's no keyword '#{keyword}'."

    "Stop Selenium Server": (params, respond) ->
        respond status: "PASS"

