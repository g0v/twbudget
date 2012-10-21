global <<< require \../lib/user
Strategy = {}
LocalStrategy = require('passport-local').Strategy
Strategy.GitHub = require('passport-github').Strategy
Strategy.Twitter = require('passport-twitter').Strategy
Strategy.Facebook = require('passport-facebook').Strategy

findOrCreateUser = (profile, provider, done) ->
    err, user <- User.findOne 'accounts.id': profile.id, 'accounts.provider': provider
    return done(null, user) if user?id

    console.log profile
    # XXX check email for existing user
    user = new User do
        accounts: [ provider: provider, id: profile.id ]
        email: profile.emails?0?value
        name: profile.displayName
    err <- user.save
    return done(err, null) if err
    console.log \newuser, user
    done(null, user)

@include = ->
    passport = @passport
    passport.serializeUser (user, done) -> done(null, user.id)

    passport.deserializeUser (id, done) ~>
        User.findById id, null, null, (err, user) ->
            if err
                console.log err
                return done null, null
            done null, user

    mount_auth = (provider, args = {}) ~>
        @app.get "/auth/#{provider}", passport.authenticate(provider, args), ->
        @get "/auth/#{provider}/callback": ->
            auth = passport.authenticate provider, (err,user,info) ~>
                done = (err, user, info) ~>
                    result = if user => auth: 1, user: user else authFailed: 1, challenges: info
                    @render 'authdone.jade': profile: JSON.stringify(result), layout: no
                if user
                    err <- @request.logIn user
                    if (err) => return done(err)
                    return done(null, user)
                done(err, user, info)
            auth @request, @response, ->

    for _provider, strategy_class of Strategy => let strategy_class, provider = _provider.toLowerCase!
        config = @config.authproviders[provider]
        return unless config
        strategy = do
            params = { callbackURL: @config.base_uri + "auth/#provider/callback" } <<< if config.client_id => do
                clientID: config.client_id
                clientSecret: config.secret
            else do
                consumerKey: config.consumer_key
                consumerSecret: config.consumer_secret
            # some way to hook user code here
            (accessToken, refreshToken, profile, done) <- new strategy_class params
            <- process.nextTick
            findOrCreateUser profile, provider, done
        passport.use strategy
        mount_auth provider, config.options

    @view 'authdone.jade': '''
        !!! 5
        html
            head
                title done
                //script(src='/js/vendor.js')
                script(type='text/javascript')
                    window.opener.postMessage(!{profile}, window.location);
                    window.close();
            body
'''

    passport.use new LocalStrategy usernameField: \email, (...args) ->
        User.authenticate(...args)

    @post '/auth/login': ->
        auth = passport.authenticate 'local', (err, user, info) ~>
            if err => return next(err)
            if (!user)
                return @response.send info, 403
            @request.logIn user, (err) ~>
                if (err) => return next(err)
                @response.send user
        auth @request, @response, ->

    @app.get '/auth/logout', (req, res) ->
        req.logout()
        res.send 'ok'
