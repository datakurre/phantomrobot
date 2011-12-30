class Page

    "Page should contain": (params, respond) ->
        needle = params[1][0]

        if /css=(.*)/.test needle  # needle is a query
            query = needle.match(/css=(.*)/)[1]

            # FIXME: PhantomJS >= 1.5 may allow passing variables into evaluate
            fn = null
            eval("fn = function() { document._tvar = '#{query}'; }")
            @page.evaluate fn

            page_contains = @page.evaluate ->
                document.querySelectorAll(document._tvar).length > 0
        else
            html = @page.evaluate -> document.documentElement.innerHTML
            page_contains = html.indexOf(needle) > -1

        if page_contains
            respond status: "PASS"
        else
            respond status: "WAIT", error: "Page did not contain '#{needle}'."

    "Page should contain element": (params, respond) ->
        needle = params[1][0]

        if /css=(.*)/.test needle  # needle is a query
            query = needle.match(/css=(.*)/)[1]

            # FIXME: PhantomJS >= 1.5 may allow passing variables into evaluate
            fn = null
            eval("fn = function() { document._tvar = '#{query}'; }")
            @page.evaluate fn

            page_contains = @page.evaluate ->
               document.querySelectorAll(document._tvar).length > 0
        else
            # FIXME: PhantomJS >= 1.5 may allow passing variables into evaluate
            fn = null
            eval("fn = function() { document._tvar = '#{needle}'; }")
            @page.evaluate fn

            page_contains = @page.evaluate ->
                document.getElementById(document._tvar) and true or false

        if page_contains
            respond status: "PASS"
        else
            respond status: "WAIT", error: "Page did not contain '#{needle}'."

    "Wait until page contains element": (params, respond) ->
        @["Page should contain element"](params, respond)

    "Element should be visible": (params, respond) ->
        needle = params[1][0]

        if /css=(.*)/.test needle
            query = needle.match(/css=(.*)/)[1]

            # FIXME: PhantomJS >= 1.5 may allow passing variables into evaluate
            fn = null
            eval("fn = function() { document._tvar = '#{query}'; }")
            @page.evaluate fn

            visible_element_found = @page.evaluate ->
                for element in document.querySelectorAll document._tvar
                    if element.offsetWidth > 0 and element.offsetHeight > 0
                        return true
                return false
        else
            # FIXME: PhantomJS >= 1.5 may allow passing variables into evaluate
            fn = null
            eval("fn = function() { document._tvar = '#{needle}'; }")
            @page.evaluate fn

            visible_element_found = @page.evaluate ->
                el = document.getElementById document._tvar
                if el and el.offsetWidth > 0 and el.offsetHeight > 0
                    return true
                else
                    return false

        if visible_element_found
            respond status: "PASS"
        else
            respond status: "WAIT", error: "Page had no visible '#{needle}'.",

    "Element should not be visible": (params, respond) ->
        needle = params[1][0]
        @["Element should be visible"] params, (response) ->
            if response?.status == "PASS"
                respond status: "WAIT", error: "Page had visible '#{needle}'.",
            else
                respond status: "PASS"
