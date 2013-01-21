# Services

# Create an object to hold the module.
mod = {}

mod.version = -> "0.1"

mod.ProductSearch = <[ $http ]> ++ ($http) ->
    currentQuery = ''
    results = {}

    search: (query, cb) ->
        currentQuery = query
        $http.get('/1/products/' + currentQuery)success cb

    getResults: -> results
    moreResults: (which) ->
      console.log \more
      results[which]products.push name: 'newly added'

mod.BudgetItem = <[ $http ]> ++ ($http) ->
    get: (key, cb) ->
        $http.get("/1/budgetitems/#key")success cb
    update: (key, verb, cb) ->
        console.log \updating, key, verb
        $http.post("/1/budgetitems/#key/#verb")success cb
    addtag: (key, tag, cb) ->
        $http.post("/1/budgetitems/#key/tags/#tag")success cb


angular.module('app.services', []).factory(mod)
