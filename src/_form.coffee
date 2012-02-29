class Form

    "Input text": (params, respond) ->
        input = params[1][0]
        text = params[1][1]

        inputText = (input, text) ->
            for element in queryAll document, input
                element.value = text
                return true
            return false

        if result = @page.eval inputText, input, text
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Input '#{input}' was not found."

    "Select from list": (params, respond) ->
        list = params[1][0]
        value = params[1][1]

        selectFromList = (list, value) ->
            for element in queryAll document, list
                # try select by values
                for i in [0...element?.options.length or 0]
                    if element.options[i].value == value
                        element.selectedIndex = i
                        return true
                # and only then by labels
                trim = (s) -> s.replace /^\s+|\s+$/g, ""
                if element?.value != value
                    for i in [0...element?.options.length or 0]
                        if trim(element.options[i].text) == value
                            element.selectedIndex = i
                            return true
                return false
            return null

        if result = @page.eval selectFromList, list, value
            respond status: "PASS"
        else if result == null
            respond status: "FAIL", error: "List '#{list}' was not found."
        else
            respond status: "FAIL", error: "List '#{list}' did not " +
                                           "contain '#{value}'."

    "Select radio button": (params, respond) ->
        name = params[1][0]
        value = params[1][1]

        getRadioButtonCoords = (name, value) ->
            visible = (el) -> el.offsetWidth > 0 and el.offsetHeight > 0
            for result in queryAll document, "xpath=//input[@name='#{name}']"
                if result.value == value and visible(result)
                    rect = result.getBoundingClientRect()
                    return x: rect.left + rect.width / 2,\
                           y: rect.top + rect.height / 2
            return null

        if coords = @page.eval getRadioButtonCoords, name, value
            @page.sendEvent "click", coords.x, coords.y
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Radio button '#{value}' " +
                                           "for '#{name}' was not found."
