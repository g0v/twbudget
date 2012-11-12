argv = try require \optimist .argv
json = try JSON.parse do
    require \fs .readFileSync \environment.json \utf8
default_port = if process.env.NODE_ENV is \production => 80 else 8000
port = Number(argv?port or json?PORT_NODEJS or process.env.PORT or process.env.VCAP_APP_PORT) or default_port
host = argv?host or process.env.VCAP_APP_HOST or \0.0.0.0
basepath = (argv?basepath or "") - /\/$/

console.log "Please connect to: http://#{
    if host is \0.0.0.0 then require \os .hostname! else host
}:#port/"

<- (require \zappajs) port, host
@BASEPATH = basepath

@mongoose = require \mongoose
@mongoose.connect json?MONGOLAB_URI ? process.env?MONGOLAB_URI ? \mongodb://localhost/ydh
@config = json ? {}
@config.cookieSecret ?= 'its-secret'
@config.authproviders ?= {}

@include \main

