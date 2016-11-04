exports.registerHelpers = (hbs) ->

  hbs.registerHelper 'ifCond', (v1, operator, v2, options) ->
    ###
    Register 'ifCond': a helper to handle variable comparisons
    Example: {{#ifCond var1 '==' var2}}
    ###
    switch operator
      when '==', '===', 'is'
        return if v1 is v2 then options.fn(this) else options.inverse(this)
      when '<'
        return if v1 < v2 then options.fn(this) else options.inverse(this)
      when '<='
        return if v1 <= v2 then options.fn(this) else options.inverse(this)
      when '>'
        return if v1 > v2 then options.fn(this) else options.inverse(this)
      when '>='
        return if v1 >= v2 then options.fn(this) else options.inverse(this)
      when '&&', 'and'
        return if v1 and v2 then options.fn(this) else options.inverse(this)
      when '||', 'or'
        return if v1 or v2 then options.fn(this) else options.inverse(this)
      else
        return options.inverse(this)

  hbs.registerHelper 'withItem', (object, options) ->
    ###
    Register 'withItem': a helper that remaps this 'this' variable to another object
    Example: {{#withItem ../anotherobject key=this}}
    ###
    return options.fn object[options.hash.key]

  hbs.registerHelper 'len', (json) ->
    ###
    Register 'len': a helper to get the length of an object
    Example: {{#if (len object)}}
    ###
    return Object.keys(json).length
  return