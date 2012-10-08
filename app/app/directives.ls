# Directive

# Create an object to hold the module.
mod = {}

mod.appVersion = [
  'version'

(version) ->

  (scope, elm, attrs) ->
    elm.text(version)
]

mod.whenScrolled = -> (scope, elm, attr) ->
    raw = elm[0]
    elm.bind 'scroll', ->
        if (raw.scrollTop + raw.offsetHeight >= raw.scrollHeight)
            scope.$apply(attr.whenScrolled)

mod.whenHScrolled = -> (scope, elm, attr) ->
    raw = elm[0]
    elm.bind 'scroll', ->
      scope.$apply(attr.whenHScrolled)

# register the module with Angular
angular.module('app.directives', [
  # require the 'app.service' module
  'app.services'
]).directive(mod)
