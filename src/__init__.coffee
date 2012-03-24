###
Copyright (C) 2011-2012  Asko Soukka <asko.soukka@iki.fi>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
###

# Define the global keyword dictionary to hold the registered keywords
PhantomKeywords = {}

##
# Define the registration command for simple keywords
keyword = (name, doc=null, fn=null) ->
    ###
    Simple keywords must contain the name and the keyword function, but may
    also contain a docstring.

    Simple keywords are magical. Their contents is wrapped and executed
    directly on the currently open browser context. They simply take paramters,
    execute their code using those parameters on the currently open browser
    context and return a results dictionary with status: "PASS" or "FAIL".

    Simple keywords must be syncronous.
    ###

    # Resolve the working set of parameters when some are missing.
    if typeof doc == "function"
        fn = doc
        doc = "n/a"

    # Define helper to resolve keyword arguments from a serialized function.
    args = (str) ->
        results = []
        args = str.match(/function \(([^\)]*)\)/im)[1] or ""
        for arg in args.split ","
            arg = arg.replace /^\s+|\s+$/, ''
            if arg.length > 0 then results.push "#{arg}="
        return results

    # Wire up the keyword function (wrapper).
    PhantomKeywords[name] = (params, callback) ->
            # Call @browser.eval for the keyword function (with given params).
            if fn and @browser
                results = @browser.eval.apply @, [fn].concat(params)
            # Fail when no browser context was defined (no browser opened).
            if fn and not @browser
                callback status: "FAIL",\
                         error: "No open browser was found."
            # Fail when results don't seem to be correct.
            if not results?.status
                callback status: "FAIL",\
                         error: "Keyword didn't respond correctly."
            # Otherwise, return the results.
            else callback results

    # Set the docstring and parse the arguments.
    PhantomKeywords[name].__doc__ = doc
    PhantomKeywords[name].__args__ = args do fn.toString


##
# Define the registration command for advanced keywords.
advanced_keyword = (name, doc=null, fn=null) ->
    ###
    Advanced keywords must contain the name and the keyword function, but may
    also contain a docstring.

    Advanced keyword are not so magical. They are executed on the normal
    PhantomJS-context: code for browser context must be evaluated manually.
    Advanced keywords will receive two arguments: an array of passed arguments
    and a callback method to be called with the results.

    Advanced keyword can contain asynchronous code, because they can just pass
    the received callback-method forward.
    ###

    # Resolve the working set of parameters when some are missing.
    if typeof doc == "function"
        fn = doc
        doc = "n/a"

    # Define helper to resolve keyword arguments from a serialized function.
    args = (str) ->
        results = []
        regexp = /(\S+) = _arg/gim
        loop
            if match = regexp.exec str
                [match, arg] = match
                if arg != "callback" then results.push "#{arg}="
            else
                return results
        # ^ Advanced keyword definitions must contain the full argument list in
        # the function definition, like ([arg1, arg2], callback) -> ... See
        # built-in keywords for more examples.

    # Wire up the keyword function, set its docstring and parse the arguments.
    PhantomKeywords[name] = fn
    PhantomKeywords[name].__doc__ = doc
    PhantomKeywords[name].__args__ = args do fn.toString
