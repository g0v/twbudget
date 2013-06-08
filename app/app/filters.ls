# Filters

#angular.module('app.filters', []).
#  filter \commafy, ->
#    (num) ->
#      num = num + ""
#      re = /(-?\d+)(\d{3})/
#      while re.test(num)
#        num = num.replace(re, "$1,$2")
#      num

angular.module('app.filters', []).
  filter \interpolate, [\version, (version) ->
    (text) -> String(text).replace(/\%VERSION\%/mg, version) ]

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
