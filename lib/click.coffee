class Click

    Click_Link: (params, respond) ->
        needle = params[1][0]

        # FIXME: PhantomJS >= 1.5 may allow passing variables into evaluate
        fn = null
        eval("fn = function() { document._tvar = '#{needle}'; }")
        @page.evaluate fn

        link = @page.evaluate ->
            for elem in document.querySelectorAll "a"
                text =\
                    elem.innerText.replace(/^\s\s*/, "").replace(/\s\s*$/, "")
                if text == document._tvar
                    rect = elem.getBoundingClientRect()
                    return {
                        left: rect.left + rect.width / 2
                        top: rect.top + rect.height / 2
                    }
            false

        if link
            @page.sendEvent "click", link.left, link.top
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Link '#{needle}' was not found."

    Click_Button: (params, respond) ->
        needle = params[1][0]

        # FIXME: PhantomJS >= 1.5 may allow passing variables into evaluate
        fn = null
        eval("fn = function() { document._tvar = '#{needle}'; }")
        @page.evaluate fn

        button = @page.evaluate ->
            for elem in document.querySelectorAll "input[type='submit']"
                value =\
                    elem.value.replace(/^\s\s*/, "").replace(/\s\s*$/, "")
                if value == document._tvar
                    rect = elem.getBoundingClientRect()
                    return {
                        left: rect.left + rect.width / 2
                        top: rect.top + rect.height / 2
                    }
            false

        if button
            @page.sendEvent "click", button.left, button.top
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Button '#{needle}' was not found."
