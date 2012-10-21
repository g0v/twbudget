# Services

# Create an object to hold the module.
mod = {}

mod.version = -> "0.1"

mod.ProductSearch = <[ $http ]> +++ ($http) ->
    currentQuery = ''
    results = {}

    search: (query, cb) ->
        currentQuery = query
        $http.get('/1/products/' + currentQuery)success cb

    getResults: -> results
    moreResults: (which) ->
      console.log \more
      results[which]products.push name: 'newly added'

mod.BudgetItem = <[ $http ]> +++ ($http) ->
    get: (cb) ->
        $http.get('/1/budgetitems')success cb
    update: (key, verb, cb) ->
        $http.post("/1/budgetitems/#key/#verb")success cb


angular.module('app.services', []).factory(mod)
