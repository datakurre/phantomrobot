class Page

    "Page should contain": (params, respond) ->
        needle = params[1][0]

        pageContains = (needle) ->
            if queryAll(document, needle).length > 0
                return true
            xpath = "xpath=//*[contains(text(), '#{needle}')]"
            for result in queryAll document, xpath
                if result.offsetWidth > 0 and result.offsetHeight > 0
                    return true
            return false

        if result = @page.eval pageContains, needle
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Page did not contain '#{needle}'."

    "Wait until page contains": (params, respond) ->
        @["Page should contain"](params, respond)

    "Element should contain": (params, respond) ->
        element = params[1][0]
        needle = params[1][1]

        elementContains = (element, needle) ->
            if (results = queryAll document, element).length
                for result in results
                    if queryAll(document, needle).length > 0
                        return true
                    xpath = "xpath=//*[contains(text(), '#{needle}')]"
                    for subres in queryAll document, xpath
                        if subres.offsetWidth > 0 and subres.offsetHeight > 0
                            return true
                return false
            return null

        if result = @page.eval elementContains, element, needle
            respond status: "PASS"
        else if result == null
            respond status: "FAIL", error: "Element '#{element}' " +
                                           "was not found."
        else
            respond status: "FAIL", error: "Element '#{element}' did not " +
                                           "contain '#{needle}'."

    "Element text should be": (params, respond) ->
        element = params[1][0]
        text = params[1][1]

        getElementText = (element) ->
            for result in queryAll document, element
                return result.innerText.replace /^\s+|\s+$/g, ""
            return null

        if (result = @page.eval getElementText, element) == text
            respond status: "PASS"
        else if result == null
            respond status: "FAIL", error: "Element '#{element}' text " +
                                           "was not found."
        else
            respond status: "FAIL", error: "Element '#{element}' text " +
                                           "'#{result}' != #{text}."

    "Page should contain element": (params, respond) ->
        needle = params[1][0]

        page_contains = (needle) ->
            if /css=(.*)/.test needle
                query = needle.match(/css=(.*)/)[1]
                document.querySelectorAll(query).length > 0
            else
                document.getElementById(needle) and true or false

        if @page.eval page_contains, needle
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Page did not contain '#{needle}'."

    "Wait until page contains element": (params, respond) ->
        @["Page should contain element"](params, respond)

    "Page should not contain element": (params, respond) ->
        needle = params[1][0]
        @["Element should be visible"] params, (response) ->
            if response?.status == "PASS"
                respond status: "FAIL", error: "Page did contain '#{needle}'.",
            else
                respond status: "PASS"

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

        if @page.eval visible_element_found, needle
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

    "XPath should match X times": (params, respond) ->
        xpath = "xpath=" + params[1][0]
        times = parseInt params[1][1], 10

        getXPathMatchTimes = (xpath) -> queryAll(document, xpath).length

        if (result = @page.eval getXPathMatchTimes, xpath) == times
            respond status: "PASS"
        else
            respond status: "FAIL", error: "XPath '#{xpath}' matched only " +
                                           "'#{result}' times."
