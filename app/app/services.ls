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

angular.module('app.services', []).factory(mod)
