class Click

    "Click link": (params, respond) ->
        needle = params[1][0]

        if /css=(.*)/.test needle  # needle is a query
            query = needle.match(/css=(.*)/)[1]

            # FIXME: PhantomJS >= 1.5 may allow passing variables into evaluate
            fn = null
            eval("fn = function() { document._tvar = '#{query}'; }")
            @page.evaluate fn

            link = @page.evaluate ->
                for elem in document.querySelectorAll(document._tvar)
                    rect = elem.getBoundingClientRect()
                    return {
                        left: rect.left + rect.width / 2
                        top: rect.top + rect.height / 2
                    }
                return false
        else
            # FIXME: PhantomJS >= 1.5 may allow passing variables into evaluate
            fn = null
            eval("fn = function() { document._tvar = '#{needle}'; }")
            @page.evaluate fn

            link = @page.evaluate ->
                for elem in document.querySelectorAll "a"
                    text = elem.innerText.replace(/^\s\s*/, "")\
                                         .replace(/\s\s*$/, "")
                    if text == document._tvar
                        rect = elem.getBoundingClientRect()
                        return {
                            left: rect.left + rect.width / 2
                            top: rect.top + rect.height / 2
                        }
                return false

        if link
            @page.sendEvent "click", link.left, link.top
            respond status: "PASS"
        else
            respond status: "WAIT", error: "Link '#{needle}' was not found."

    "Click button": (params, respond) ->
        needle = params[1][0]

        if /css=(.*)/.test needle  # needle is a query
            query = needle.match(/css=(.*)/)[1]

            # FIXME: PhantomJS >= 1.5 may allow passing variables into evaluate
            fn = null
            eval("fn = function() { document._tvar = '#{query}'; }")
            @page.evaluate fn

            button_clicked = @page.evaluate ->
                for elem in document.querySelectorAll document._tvar
                    do elem.click
                    return true
                return false
        else
            # FIXME: PhantomJS >= 1.5 may allow passing variables into evaluate
            fn = null
            eval("fn = function() { document._tvar = '#{needle}'; }")
            @page.evaluate fn

            button_clicked = @page.evaluate ->
                for elem in document.querySelectorAll "input[type='submit']"
                    value =\
                        elem.value.replace(/^\s\s*/, "").replace(/\s\s*$/, "")
                    if value == document._tvar
                        do elem.click
                        return true
                return false

        if button_clicked
            respond status: "PASS"
        else
            respond status: "WAIT", error: "Button '#{needle}' was not found."
