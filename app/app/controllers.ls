
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

    update_from_item = (res) ->
        console.log \updatingscope, res
        $scope <<< res{nlikes,nhates,ncuts,nconfuses,tags}

    $scope.$watch \key ->
        console.log \keychanged
        res <- BudgetItem.get $scope.key
        console.log res
        update_from_item res
    $scope <<< do
        nlikes: '???'
        nconfuses: '???'
        nhates: '???'
        ncuts: '???'
        like: -> BudgetItem.update $scope.key, \likes, update_from_item
        hate: -> BudgetItem.update $scope.key, \hates, update_from_item
        confuse: -> BudgetItem.update $scope.key, \confuses, update_from_item
        cut: -> BudgetItem.update $scope.key, \cuts, update_from_item
        addtag: -> 
          if $scope.tagname then BudgetItem.addtag $scope.key, $scope.tagname, update_from_item
        addunit: ->
          if !jQuery.isNumeric $scope.addunit_value then return $ \#addunit-value-group .addClass \error
          $ \#addunit-value-group .removeClass \error
          console.log "add-unit: [quantifier: ",$scope.addunit_quantity,
            ",unit: ",$scope.addunit_unit,",value: ",$scope.addunit_value,"]"
          $ \#addunit-modal .modal \hide
        units: [
          ["" \元 \1 ]
          <[份 營養午餐 25]>
          <[份 營養午餐(回扣) 30]>
          <[人 的一年薪水 308000]>
          <[座 釣魚台 80000000]>
          <[秒 太空旅遊 16666]>
          <[碗 鬍鬚張魯肉飯 68]>
          <[個 便當 50]>
          <[杯 珍奶 30]>
          <[份 雞排加珍奶 60]>
          <[個 晨水匾 700000000]>
          <[個 夢想家 200000000]>
          <[個 林益世(粗估) 83000000]>
          <[座 冰島 2000080000000]>
          <[坪 帝寶 2500000]>
          <[支 iPhone5 25900]>
          <[座 硬兔的小島 2000080000000]>
        ]

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
