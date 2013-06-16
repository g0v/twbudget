# Declare app level module which depends on filters, and services
App = angular.module \app, <[ partials ngCookies ngResource app.controllers app.directives app.filters app.services ui.directives ]>

App.config [ '$routeProvider' '$locationProvider'
($routeProvider, $locationProvider, config) ->
  $routeProvider
    .when \/view2, templateUrl: \/partials/partial2.html
    .when \/view3, templateUrl: \/partials/partial3.html
    .when \/view4, templateUrl: \/partials/partial4.html
    .when \/budget/:code, templateUrl: \/partials/partial4.html
    .when \/debtclock, templateUrl: \/partials/debtclock.html
    .when \/profile, templateUrl: \/partials/profile.html
    # Catch all
    .otherwise redirectTo: \/view4

  # Without serve side support html5 must be disabled.
  $locationProvider.html5Mode true
]
