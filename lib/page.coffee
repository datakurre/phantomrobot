class Page

    "Page should contain": (params, respond) ->
        needle = params[1][0]

        page_contains = (needle) ->
            if /css=(.*)/.test needle
                query = needle.match(/css=(.*)/)[1]
                document.querySelectorAll(query).length > 0
            else
                document.documentElement.innerHTML.indexOf(needle) > -1

        if @page.call page_contains, needle
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Page did not contain '#{needle}'."

    "Element should contain": (params, respond) ->
        element = params[1][0]
        content = params[1][1]

        element_contains = (element, content) ->
            if /css=(.*)/.test element
                query = element.match(/css=(.*)/)[1]
                results = document.querySelectorAll(query)
                elem = results.length and results[0] or null
            else
                elem = document.getElementById(element)

            if elem and /css=(.*)/.test content
                query = content.match(/css=(.*)/)[1]
                elem.querySelectorAll(query).length > 0
            else if elem
                elem.innerHTML.indexOf(content) > -1
            else false

        if @page.call element_contains, element, content
            respond status: "PASS"
        else
            respond status: "FAIL",\
                    error: "Element '#{element}' did not contain '#{content}'."

    "Page should contain element": (params, respond) ->
        needle = params[1][0]

        page_contains = (needle) ->
            if /css=(.*)/.test needle
                query = needle.match(/css=(.*)/)[1]
                document.querySelectorAll(query).length > 0
            else
                document.getElementById(needle) and true or false

        if @page.call page_contains, needle
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Page did not contain '#{needle}'."

    "Wait until page contains element": (params, respond) ->
        @["Page should contain element"](params, respond)

    "Element should be visible": (params, respond) ->
        needle = params[1][0]

        visible_element_found = (needle) ->
            if /css=(.*)/.test needle
                query = needle.match(/css=(.*)/)[1]
                for element in document.querySelectorAll query
                    if element.offsetWidth > 0 and element.offsetHeight > 0
                        return true
                return false
            else
                elem = document.getElementById needle
                elem and elem.offsetWidth > 0 and elem.offsetHeight > 0

        if @page.call visible_element_found, needle
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Page had no visible '#{needle}'.",

    "Element should not be visible": (params, respond) ->
        needle = params[1][0]
        @["Element should be visible"] params, (response) ->
            if response?.status == "PASS"
                respond status: "FAIL", error: "Page had visible '#{needle}'.",
            else
                respond status: "PASS"
