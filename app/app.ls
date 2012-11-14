# Declare app level module which depends on filters, and services
App = angular.module \app, <[ ngCookies ngResource app.controllers app.directives app.filters app.services ui.directives ]>

App.config [ '$routeProvider' '$locationProvider'
($routeProvider, $locationProvider, config) ->
  $routeProvider
    .when \/view2, templateUrl: \/partials/app/partial2.html
    .when \/view3, templateUrl: \/partials/app/partial3.html
    .when \/view4, templateUrl: \/partials/app/partial4.html
    .when \/budget/:code, templateUrl: \/partials/app/partial4.html
    .when \/profile, templateUrl: \/partials/app/profile.html
    # Catch all
    .otherwise redirectTo: \/view4

  # Without serve side support html5 must be disabled.
  $locationProvider.html5Mode true
]
