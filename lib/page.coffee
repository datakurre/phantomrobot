class Page

    "Page should contain": (params, respond) ->
        needle = params[1][0]

        if /css=(.*)/.test needle  # needle is a query
            func = (arg) -> document.querySelectorAll(arg).length > 0
            query = needle.match(/css=(.*)/)[1]
            page_contains = @page.call func, query
        else
            func = (arg) ->
                document.documentElement.innerHTML.indexOf(arg) > -1
            page_contains = @page.call func, needle

        if page_contains
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Page did not contain '#{needle}'."

    "Page should contain element": (params, respond) ->
        needle = params[1][0]

        if /css=(.*)/.test needle  # needle is a query
            func = (arg) -> document.querySelectorAll(arg).length > 0
            query = needle.match(/css=(.*)/)[1]
            page_contains = @page.call func, query
        else
            func = (arg) -> document.getElementById(arg) and true or false
            page_contains = @page.call func, needle

        if page_contains
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Page did not contain '#{needle}'."

    "Wait until page contains element": (params, respond) ->
        @["Page should contain element"](params, respond)

    "Element should be visible": (params, respond) ->
        needle = params[1][0]

        if /css=(.*)/.test needle
            func = (arg) ->
                for element in document.querySelectorAll arg
                    if element.offsetWidth > 0 and element.offsetHeight > 0
                        return true
                return false
            query = needle.match(/css=(.*)/)[1]
            visible_element_found = @page.call func, query
        else
            func = (arg) ->
                el = document.getElementById arg
                if el and el.offsetWidth > 0 and el.offsetHeight > 0
                    return true
                else
                    return false
            visible_element_found = @page.call func, needle

        if visible_element_found
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Page had no visible '#{needle}'.",

    "Element should not be visible": (params, respond) ->
        needle = params[1][0]
        @["Element should be visible"] params, (response) ->
            if response?.status == "PASS"
                respond status: "FAIL", error: "Page had visible '#{needle}'.",
            else
                respond status: "PASS"
