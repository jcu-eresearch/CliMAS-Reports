define [
    'underscore'
], (_) ->

    RA = {
        # ----------------------------------------------------------------
        initialize: () ->
            _.bindAll this
        # ----------------------------------------------------------------
        resolve: (doc, data) ->
            # doc: a string
            # data: a hash/object

            fillOut = @_fillOut
            conditionHolds = @_conditionHolds

            # split the doc up into parts
            parts = @_splitDoc doc
            result = []

            _.each parts, (part) ->
                if conditionHolds part.condition, data
                    console.log ["RA --- true:", part.condition, part.content.split('\n')[0][0..30] + "..."]
                    result.push fillOut(part.content, data)
                else
                    console.log ["RA --- NOT true:", part.condition, part.content.split('\n')[0][0..30] + "..."]

            result.join ""
        # ----------------------------------------------------------------
        _splitDoc: (doc) ->
            # split the doc into parts
            parts = []

            rawparts = doc.split /[^\S\n]*\[\[\s*/
            _.each rawparts, (part) ->
                bits = part.split /\s*\]\][^\S\n]*/
                if bits.length > 1
                    parts.push {
                        condition: bits[0]
                        content: bits.slice(1).join(" ]] ")
                    }
                else
                    parts.push {
                        condition: "always"
                        content: bits[0]
                    }

            parts
        # ----------------------------------------------------------------
        _conditionHolds: (condition, data) ->
            # protect loss of "this"
            resolveTerm = RA._resolveTerm

            conditions = {

                "never": () ->
                    false

                "always": () ->
                    true

                "(\\S+)\\s*(<|>|==?|!==?|<>)\\s*(\\S+)": (matches) ->
                    left = resolveTerm matches[1], data
                    right = resolveTerm matches[3], data

                    switch matches[2]
                        when '<'
                            left < right
                        when '>'
                            left > right
                        when '=','=='
                            left == right
                        when '!=','!==','<>'
                            left != right
            }

            for pattern, evaluator of conditions
                regex = new RegExp pattern
                match_result = regex.exec condition
                if match_result?
                    return evaluator match_result

            console.warn "Bad condition: #{condition}"
            return false
        # ----------------------------------------------------------------
        _fillOut: (content, data) ->
            filledOut = content
            for varname, value of data
                # split/join to replace all instances :)
                filledOut = filledOut.split("\$\$" + varname).join(value)

            filledOut
        # ----------------------------------------------------------------
        _resolveTerm: (term, data) ->
            if isNaN term
                console.log ['term is:', term]
                if term.indexOf("$$") isnt -1
                    console.log ['term is:', term]
                    term = RA._fillOut term, data
                    console.log ['filled out term is:', term]

                data[term]
            else
                parseInt term
        # ----------------------------------------------------------------
    }
