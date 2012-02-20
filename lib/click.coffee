class Click

    "Click link": (params, respond) ->
        needle = params[1][0]

        if /css=(.*)/.test needle  # needle is a query
            func = (arg) ->
                for elem in document.querySelectorAll arg
                    rect = elem.getBoundingClientRect()
                    return left: rect.left + rect.width / 2,\
                           top: rect.top + rect.height / 2
                return false
            query = needle.match(/css=(.*)/)[1]
            link = @page.call func, query
        else
            func = (arg) ->
                for elem in document.querySelectorAll "a"
                    text = elem.innerText.replace(/^\s\s*/, "")\
                                         .replace(/\s\s*$/, "")
                    if text == arg
                        rect = elem.getBoundingClientRect()
                        return left: rect.left + rect.width / 2,\
                               top: rect.top + rect.height / 2
                return false
            link = @page.call func, needle

        if link
            @page.sendEvent "click", link.left, link.top
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Link '#{needle}' was not found."

    "Click button": (params, respond) ->
        needle = params[1][0]

        if /css=(.*)/.test needle  # needle is a query
            func = (arg) ->
                for elem in document.querySelectorAll arg
                    do elem.click
                    return true
                return false
            query = needle.match(/css=(.*)/)[1]
            button_clicked = @page.call func, query
        else
            func = (arg) ->
                for elem in document.querySelectorAll "input[type='submit']"
                    value = elem.value.replace(/^\s\s*/, "")\
                                      .replace(/\s\s*$/, "")
                    if value == arg
                        do elem.click
                        return true
                return false
            button_clicked = @page.call func, needle

        if button_clicked
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Button '#{needle}' was not found."
