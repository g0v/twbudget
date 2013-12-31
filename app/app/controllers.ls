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

mod.LoginController = <[ $scope $http authService ]> ++ ($scope, $http, authService) ->
    $scope.$on 'event:auth-loginRequired' ->
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


mod.Profile = <[ $scope $http ]> ++ ($scope, $http) ->
    $scope.name = 'Guest';
    $http.get('/1/profile')success ({name}:res) ->
        $scope.name = name

mod.MyCtrl1 = <[ $scope ProductSearch ]> ++ ($scope, productSearch) ->
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

mod.BudgetItem = <[ $scope $state BudgetItem ]> ++ ($scope, $state, BudgetItem) ->
    $scope.$watch '$state.params.code' (code) ->
      $scope.code = code

    update_from_item = (res) ->
        $scope <<< res{nlikes,nhates,ncuts,nconfuses,tags}

    $scope.$watch \key ->
        res <- BudgetItem.get $scope.key
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
          if !$scope.addunit_quantity then return $('#addunit-modal input:eq(0)') .tooltip("show")
          if !$scope.addunit_unit then return $('#addunit-modal input:eq(1)') .tooltip("show")
          if !jQuery.isNumeric $scope.addunit_value then return $('#addunit-modal input:eq(2)') .tooltip("show")
          # console.log "add-unit: [quantifier: ",$scope.addunit_quantity, ",unit: ",$scope.addunit_unit,",value: ",$scope.addunit_value,"]"
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

mod.DebtClock = <[ $scope $timeout ]> ++ ($scope, $timeout) ->
    # Source: http://www.dgbas.gov.tw/ct.asp?xItem=33906&CtNode=5736&mp=1 總說明 P13
    national-debt = 59412yi * 10000wan * 10000ntd # 依國際貨幣基金定義
    national-payable = 109703yi * 10000wan * 10000ntd # 潛藏負債, 不含地方政府部份

    $scope.data = { yr2012: { base: national-debt + national-payable, interest: 7389 } }
    #console.log($scope.data.yr2008.base)
    #console.log($scope.data.yr2008.interest)
    $scope.refreshDebtClock = ->
        now = new Date()
        spday = new Date(2013, 1-1, 1);
        message = ''
        a = ((now.getTime() - spday.getTime()) / (1000) * $scope.data.yr2012.interest) + $scope.data.yr2012.base;
        a = Math.ceil a
        $scope.total = { debt: a, avg: Math.round(a / 23367320) }
    $scope.scheduleDebtClockRefresh = ->
        timeoutId = $timeout !->
            $scope.refreshDebtClock!
            $scope.scheduleDebtClockRefresh!
        , 1000
    $scope.scheduleDebtClockRefresh!


mod.DailyBread = <[ $scope $http ]> ++ ($scope, $http) ->
    $scope.tax = 80000
    $scope.$watch 'tax' ->
      window.__db?setTax $scope.tax
    dailybread!

mod.UnitMapper = <[ $scope ]> ++ ($scope) ->
  $scope.units=UnitMapper.table

mod.MyCtrl2 = [
  '$scope'
(s) ->
  s.Title = "MyCtrl2"
]

angular.module('app.controllers', ['http-auth-interceptor']).controller(mod)
