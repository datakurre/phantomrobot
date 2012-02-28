class Form

    "Input text": (params, respond) ->
        id = params[1][0]
        value = params[1][1]

        set_value = (id, value) -> document.getElementById(id)?.value = value

        if @page.eval(set_value, id, value) == value
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Input '#{id}' was not found."

    "Select from list": (params, respond) ->
        needle = params[1][0]
        value = params[1][1]

        select_from_list = (needle, value) ->
            if /css=(.*)/.test needle
                query = needle.match(/css=(.*)/)[1]
                for element in document.querySelectorAll query
                    return element.value = value
            else
                elem = document.getElementById needle
                elem and element.value = value
            return null

        new_value = @page.eval select_from_list, needle, value

        if new_value == value
            respond status: "PASS"
        if not new_value
            respond status: "FAIL", error: "List '#{needle}' was not found."
        else
            respond status: "FAIL", error: "Item '#{new_value}' was selected."


