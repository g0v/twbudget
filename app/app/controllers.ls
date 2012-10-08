
mod = {}

mod.AppCtrl = [
  '$scope'
  '$location'
  '$resource'
  '$rootScope'

(s, $location, $resource, $rootScope) ->

  # Uses the url to determine if the selected
  # menu item should have the class active.
  s.$location = $location
  s.$watch('$location.path()', (path) ->
    s.activeNavId = path || '/'
  )

  # getClass compares the current url with the id.
  # If the current url starts with the id it returns 'active'
  # otherwise it will return '' an empty string. E.g.
  #
  #   # current url = '/products/1'
  #   getClass('/products') # returns 'active'
  #   getClass('/orders') # returns ''
  #
  s.getClass = (id) ->
    if s.activeNavId.substring(0, id.length) == id
      return 'active'
    else
      return ''
]

mod.LoginController = <[ $scope $http authService ]> +++ ($scope, $http, authService) ->
    $scope.$on 'event:auth-loginRequired' ->
      console.log \authrequired
      $scope.loginShown = true
    $scope.$on 'event:auth-loginConfirmed' ->
      $scope.loginShown = false

    window.addEventListener 'message' ({data}) ->
        <- $scope.$apply
        if data.auth
            $scope.message = ''
            authService.loginConfirmed!
        if data.authFailed
            $scope.message = data.message || 'login failed'

    $scope.message = ''
    $scope.submit = ->
        $http.post 'auth/login' $scope{email, password}
        .success ->
            $scope.message = ''
            authService.loginConfirmed!
        .error ->
            $scope.message = if typeof it is \object => it.message else it


mod.Profile = <[ $scope $http ]> +++ ($scope, $http) ->
    $scope.name = 'Guest';
    $http.get('/1/profile')success {name} ->
        console.log "logged in"
        $scope.name = name

mod.MyCtrl1 = <[ $scope ]> +++ ($scope) ->
  $scope.title = "Myctrl1"
  $scope.moreProducts = (which)->
      console.log \more
      $scope.results[which]products.push name: 'newly added'+which
  $scope.search = 'HTC'
  $scope.blah = (which)->
    
  $scope.cc = 1
  $scope.results =
      * name: 'ONE'
        categoryKey: 'htc:one'
        products:
          * name: 'ONE X'
          * name: 'ONE S'
          * name: 'ONE A'
          * name: 'ONE B'
          * name: 'ONE C'
      * name: 'Desire'
        categoryKey: 'htc:desire'
        products:
          * name: 'Desire HD'
          * name: 'Desire MD'
          * name: 'Desire LD'
      * name: 'Accessory: case'
        products: 
          * name: 'Mickey Mouse'
          * name: 'Crystal Shell'
          * name: 'Extreme Thin'
      * name: 'Accessory: case'
        products: 
          * name: 'Mickey Mouse'
          * name: 'Mickey Mouse'
          * name: 'Mickey Mouse'
      * name: 'Accessory: case'
        products: 
          * name: 'Mickey Mouse'
          * name: 'Mickey Mouse'
          * name: 'Mickey Mouse'
      * name: 'Accessory: case'
        products: 
         * name: 'Mickey Mouse'
         * name: 'Mickey Mouse'
         * name: 'Mickey Mouse'
      * name: 'Accessory: case'
        products: 
         * name: 'Mickey Mouse'
         * name: 'Mickey Mouse'
         * name: 'Mickey Mouse'
      * name: 'Accessory: case'
        products: 
         * name: 'Mickey Mouse'
         * name: 'Mickey Mouse'
         * name: 'Mickey Mouse'
      * name: 'Accessory: case'
        products: 
         * name: 'Mickey Mouse'
         * name: 'Mickey Mouse'
         * name: 'Mickey Mouse'

mod.MyCtrl2 = [
  '$scope'

(s) ->
  s.Title = "MyCtrl2"
]

angular.module('app.controllers', ['http-auth-interceptor']).controller(mod)
