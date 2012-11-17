JS_FILES=server/app.js server/main.js server/auth.js server/codemap.js lib/user.js lib/schema.js

.ls.js:
	env PATH="$$PATH:./node_modules/LiveScript/bin" livescript -c  $<

server :: $(JS_FILES)

client ::
	env PATH="$$PATH:./node_modules/brunch/bin" brunch b

run :: server
	node server/app.js

.SUFFIXES: .jade .html .ls .js
