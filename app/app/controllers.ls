
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
    $http.get('/1/profile')success ({name}:res) ->
        console.log "logged in", res
        $scope.name = name

mod.MyCtrl1 = <[ $scope ProductSearch ]> +++ ($scope, productSearch) ->
  $scope.updateblah = (which) ->
    i = parseInt $('#categories')scrollLeft!/150
    if $scope.category_index_old!=i then
      $scope.category_index_old = i
  $scope.blah = (which) ->
    i = 1 + Math.abs which - parseInt $('#categories')scrollLeft!/150
    if i>=3 then i=3
    i

  $scope.moreProducts = productSearch.moreResults
  $scope.search = 'HTC'
  $scope.cc = 1
  $scope.results <- productSearch.search("htc")
  console.log \got results

mod.BudgetItem = <[ $scope BudgetItem ]> +++ ($scope, BudgetItem) ->

    $scope.$watch \key ->
        console.log \keychanged
        res <- BudgetItem.get $scope.key
        console.log res
        $scope <<< res{nlikes,nhates,ncuts,nconfuses}
    $scope <<< do
        nlikes: '???'
        nconfuses: '???'
        nhates: '???'
        ncuts: '???'
        like: -> BudgetItem.update $scope.key, \likes, -> $scope.nlike = it.nlike
        hate: -> BudgetItem.update $scope.key, \hates, ->
        confuse: -> BudgetItem.update $scope.key, \confuses, ->
        cut: -> BudgetItem.update $scope.key, \cuts, ->
        addtag: -> BudgetItem.addtag $scope.key, $scope.tagname, ->
            console.log \tagged, it

mod.DailyBread = <[ $scope $http ]> +++ ($scope, $http) ->
    $scope.tax = 80000
    $scope.$watch 'tax' ->
      console.log \tax $scope.tax
      window.__db?setTax $scope.tax
    dailybread!

mod.MyCtrl2 = [
  '$scope'

(s) ->
  s.Title = "MyCtrl2"
]

angular.module('app.controllers', ['http-auth-interceptor']).controller(mod)
