# Filters

angular.module('app.filters', []).
  filter \interpolate, [\version, (version) ->
    (text) -> String(text).replace(/\%VERSION\%/mg, version) ]

angular.module('app.filters', []).
  filter \unitconvert, [\$filter, ($filter) ->
    (v) ->
      idx = UnitMapper.get!
      c = CurrencyData[idx]
      v = parseInt(10000 * v / c[2]) / 10000
      v = parseInt(10 * v) / 10  if v > 1 and v < 1000
      v = $filter('number')(v, 0)
      v + c[0] + c[1]
    ]


# TODO Convert to following syntax.
# # Create an object to hold the module.
# mod = {}
# 
# mod.interpolate = [
#   'version'
# 
# (version) ->
# 
#   (text) ->
#     String(text).replace(/\%VERSION\%/mg, version)
# ]
# 
# # register the module with Angular
# angular.module('app.filters', [
#   # require the 'app.service' module
# ]).filter(mod)
