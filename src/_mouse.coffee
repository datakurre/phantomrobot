class Mouse

    "Click link": (params, respond) ->
        needle = params[1][0]

        getLinkCoords = (needle) ->
            visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
            for result in queryAll document, needle when visible(result)
                rect = result.getBoundingClientRect()
                return x: rect.left + rect.width / 2,\
                       y: rect.top + rect.height / 2
            trim = (s) -> s.replace /^\s+|\s+$/g, ""
            for result in queryAll document, "xpath=//a" when visible(result)
                if trim(result.innerText) == needle
                    rect = result.getBoundingClientRect()
                    return x: rect.left + rect.width / 2,\
                           y: rect.top + rect.height / 2
            return null

        if coords = @page.eval getLinkCoords, needle
            @page.sendEvent "click", coords.x, coords.y
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Link '#{needle}' was not found."

    "Click element": (params, respond) ->
        needle = params[1][0]

        get_element = (needle) ->
            if /css=(.*)/.test needle
                query = needle.match(/css=(.*)/)[1]
                for elem in document.querySelectorAll query
                    result = elem
                    break
            else
                for elem in document.getElementById(needle)
                    result = elem
                    break
            if result
                rect = result.getBoundingClientRect()
                left: rect.left + rect.width / 2,
                top: rect.top + rect.height / 2
            else false

        if element = @page.eval get_element, needle
            @page.sendEvent "click", element.left, element.top
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Element '#{needle}' was not found."

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

        if @page.eval button_clicked, needle
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Button '#{needle}' was not found."

    "Mouse down": (params, respond) ->
        needle = params[1][0]

        getCoords = (needle) ->
            for result in queryAll document, needle
                rect = result.getBoundingClientRect()
                return x: rect.left + rect.width / 2,\
                       y: rect.top + rect.height / 2
            return null

        if coords = @page.eval getCoords, needle
            @page.sendEvent "mousedown", coords.x, coords.y
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Element '#{needle}' was not found."

    "Mouse up": (params, respond) ->
        needle = params[1][0]

        getCoords = (needle) ->
            for result in queryAll document, needle
                rect = result.getBoundingClientRect()
                return x: rect.left + rect.width / 2,\
                       y: rect.top + rect.height / 2
            return null

        if coords = @page.eval getCoords, needle
            @page.sendEvent "mouseup", coords.x, coords.y
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Element '#{needle}' was not found."
