@include = ->
    @passport = require \passport
    CookieStore = require \cookie-sessions
    @use @express.static __dirname + \/../_public
    @use \bodyParser
    @use CookieStore secret: @config.cookieSecret, onError: ->
        return {}
    @app.use @passport.initialize!
    @app.use @passport.session!
    @use @app.router

    RealBin = require \path .dirname do
        require \fs .realpathSync __filename
    RealBin -= /\/server/

    sendFile = (file) -> ->
        @response.contentType \text/html
        @response.sendfile "#RealBin/_public/#file"

    JsonType = { \Content-Type : 'application/json; charset=utf-8' }

    @helper ensureAuthenticated: (next) ->
        if @request?isAuthenticated! => return next!
        @response.send 401

    @get '/1/profile': ->
        <~ @ensureAuthenticated
        @response.send 'ok '+@request.user.username

    @include \auth
    @get '/:what': sendFile \index.html
