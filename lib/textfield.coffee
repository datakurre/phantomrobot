class TextField

    "Input Text": (params, respond) ->
        id = params[1][0]
        value = params[1][1]

        # FIXME: PhantomJS >= 1.5 may allow passing variables into evaluate
        fn = null
        eval("fn = function() { document._tvar = '#{id}'; }")
        @page.evaluate fn
        eval("fn = function() { document._tvar2 = '#{value}'; }")
        @page.evaluate fn

        set_value = @page.evaluate ->
            document.getElementById(document._tvar).value = document._tvar2

        if set_value == value
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Input '#{id}' was not found."
