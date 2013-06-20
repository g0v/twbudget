# Declare app level module which depends on filters, and services
angular.module \app, <[ partials ngResource app.controllers app.directives app.filters app.services ui.directives ui.state ]>

.config <[$stateProvider $urlRouterProvider $locationProvider]> ++ ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $stateProvider
    .state 'view2' do
      url: '/view2'
      templateUrl: '/partials/partial2.html'
    .state 'view3' do
      url: '/view3'
      templateUrl: '/partials/partial3.html'
      controller: \BudgetItem
    .state 'budget' do
      url: '/budget'
      templateUrl: '/partials/partial4.html'
      controller: \BudgetItem
    .state 'budget.detail' do
      url: '/budget/{code}'
      templateUrl: '/partials/partial4.html'
    .state 'debtclock' do
      url: '/debtclock'
      templateUrl: '/partials/debtclock.html'
    .state 'profile' do
      url: '/profile'
      templateUrl: '/partials/profile.html'

  $urlRouterProvider
    .otherwise('/budget')

  $locationProvider.html5Mode true

.run <[$rootScope $state $stateParams $location]> ++ ($rootScope, $state, $stateParams, $location) ->
  $rootScope.$state = $state
  $rootScope.$stateParam = $stateParams
  $rootScope.go = -> $location.path it
  #$rootScope._build = window.global.config.BUILD
  $rootScope.$on \$stateChangeSuccess (e, {url,name}) ->
    window?ga? 'send' 'pageview' page: url, title: name
