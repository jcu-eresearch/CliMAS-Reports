
RA = {
    # ----------------------------------------------------------------
    resolve: (doc, data, log_callback) ->
        # doc: a string
        # data: a hash/object
        # log: an optional logging function (will be passed strings)

        # split the doc up into parts
        parts = @_splitDoc doc
        result = []

        for part in parts
            if RA._conditionHolds part.condition, data, log_callback
                if log_callback
                    log_callback "true: [[" + part.condition + "]], content: " + part.content.split('\n')[0][0..20] + "..."
                result.push RA._fillOut(part.content, data)
            else
                if log_callback
                    log_callback "NOT true: [[" + part.condition + "]], content: " + part.content.split('\n')[0][0..20] + "..."

        result.join ""
    # ----------------------------------------------------------------
    _splitDoc: (doc) ->
        # split the doc into parts
        parts = []

        rawparts = doc.split /[^\S\n]*\[\[\s*/
        for part in rawparts
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
    _conditionHolds: (condition, data, log_callback) ->

        conditions = {

            "never": () ->
                false

            "always": () ->
                true

            # left AND right
            "([\\s\\S]*)\\s+(and|AND)\\s+([\\s\\S]*)": (matches) ->
                left = RA._conditionHolds matches[1], data
                right = RA._conditionHolds matches[3], data
                (left and right)

            # left OR right
            "([\\s\\S]*)\\s+(or|OR)\\s+([\\s\\S]*)": (matches) ->
                left = RA._conditionHolds matches[1], data
                right = RA._conditionHolds matches[3], data
                (left or right)

            # left < right   ..less than
            # left > right   ..greater than
            # left = right   ..equal to
            # left == right  ..equal to
            # left != right  ..not equal to
            # left !== right ..not equal to
            # left <> right  ..not equal to
            "(\\S+)\\s*(<|>|==?|!==?|<>)\\s*(\\S+)": (matches) ->
                left = RA._resolveTerm matches[1], data
                right = RA._resolveTerm matches[3], data

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

        if log_callback
            log_callback "FAIL: Bad RA condition [[#{condition}]]"

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
            if term.indexOf("$$") isnt -1
                term = RA._fillOut term, data

            data[term]
        else
            parseInt term
    # ----------------------------------------------------------------
}

# stolen from Showdown...

# export
if typeof module != 'undefined'
    module.exports = RA;

# stolen from AMD branch of underscore
# AMD define happens at the end for compatibility with AMD loaders
# that don't enforce next-turn semantics on modules.
if typeof(define) == 'function' and define.amd
    define 'ra', () ->
        return RA

