class TextField

    "Input text": (params, respond) ->
        id = params[1][0]
        value = params[1][1]

        func = (id, value) -> document.getElementById(id)?.value = value
        set_value = @page.call func, id, value

        if set_value == value
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Input '#{id}' was not found."
