class Click

    "Click link": (params, respond) ->
        needle = params[1][0]

        get_link = (needle) ->
            if /css=(.*)/.test needle
                query = needle.match(/css=(.*)/)[1]
                for elem in document.querySelectorAll query
                    result = elem
                    break
            else
                for elem in document.querySelectorAll "a"
                    text = elem.innerText.replace(/^\s\s*/, "")\
                                         .replace(/\s\s*$/, "")
                    if text == needle then result = elem
            if result
                rect = result.getBoundingClientRect()
                left: rect.left + rect.width / 2,
                top: rect.top + rect.height / 2
            else false

        if link = @page.call get_link, needle
            @page.sendEvent "click", link.left, link.top
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Link '#{needle}' was not found."

    "Click button": (params, respond) ->
        needle = params[1][0]

        button_clicked = (needle) ->
            if /css=(.*)/.test needle
                query = needle.match(/css=(.*)/)[1]
                for elem in document.querySelectorAll query
                    result = elem
                    break
            else
                for elem in document.querySelectorAll "input[type='submit']"
                    value = elem.value.replace(/^\s\s*/, "")\
                                      .replace(/\s\s*$/, "")
                    if value == needle then result = elem
            if result
                do result.click or true
            else false

        if @page.call button_clicked, needle
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Button '#{needle}' was not found."
