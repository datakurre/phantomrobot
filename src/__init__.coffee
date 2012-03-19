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

PhantomKeywords = {}  # will be filled by calling the keyword-function

###
simple keywords are magical
###
keyword = (name, doc=null, fn=null, post_fn=null) ->

    # resolve working set of parameters when some are missing
    if typeof doc == "function"
        if typeof fn == "function"
            post_fn = fn
        fn = doc
        doc = "n/a"

    # resolve arguments from compiled "([foo, bar]) ->" coffee-script function
    args = (str) ->
        results = []
        regexp = /(\S+) = _arg/gim
        loop
            if match = regexp.exec str
                [match, arg] = match
                results.push "#{arg}="
            else
                return results

    # wire up the keyword
    PhantomKeywords[name] = (params, callback) ->
            # call @browser.eval for the keyword main function and given params
            if fn and @browser
                params.unshift fn
                results = @browser.eval params...
            if fn and not @browser
                callback status: "FAIL", error: "Open browser was " +
                                                "not found."
            # call post_fn-func of the keyword when defined
            if fn and post_fn
                results = post_fn results

            # fail if results don't seem to be correct, otherwise ret results
            if not results.status
                callback status: "FAIL", error: "Keyword didn't respond " +
                                                "with status."
            else callback results

    PhantomKeywords[name].__doc__ = doc
    PhantomKeywords[name].__args__ = args do fn.toString


###
advanced keywords are less magical
###
advanced_keyword = (name, doc=null, fn=null) ->

    # resolve working set of parameters when some are missing
    if typeof doc == "function"
        fn = doc
        doc = "n/a"

    # resolve arguments from compiled "([foo, bar]) ->" coffee-script function
    args = (str) ->
        results = []
        regexp = /(\S+) = _arg/gim
        loop
            if match = regexp.exec str
                [match, arg] = match
                if arg != "callback" then results.push "#{arg}="
            else
                return results

    # wire up the keyword
    PhantomKeywords[name] = fn
    PhantomKeywords[name].__doc__ = doc
    PhantomKeywords[name].__args__ = args do fn.toString
