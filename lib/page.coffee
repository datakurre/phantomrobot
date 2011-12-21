class Page

    "Page should contain": (params, respond) ->
        needle = params[1][0]
        html = @page.evaluate -> document.documentElement.innerHTML
        if html.indexOf(needle) > -1
            respond status: "PASS"
        else
            respond status: "WAIT", error: "Page did not contain '#{needle}'."

    "Page should contain element": (params, respond) ->
        id = params[1][0]

        # FIXME: PhantomJS >= 1.5 may allow passing variables into evaluate
        fn = null
        eval("fn = function() { document._tvar = '#{id}'; }")
        @page.evaluate fn

        contains_element = @page.evaluate ->
            document.getElementById(document._tvar) and true or false

        if contains_element
            respond status: "PASS"
        else
            respond status: "WAIT", error: "Page did not contain '#{id}'.",
