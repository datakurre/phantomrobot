class TextField

    "Input text": (params, respond) ->
        id = params[1][0]
        value = params[1][1]

        set_value = (id, value) -> document.getElementById(id)?.value = value

        if @page.call(set_value, id, value) == value
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Input '#{id}' was not found."
