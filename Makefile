HTML_FILES=$(shell find app -name '*.jade' | sed s/jade/html/)
JS_FILES=server/app.js server/main.js server/auth.js

.jade.html:
	jade --pretty $<

.ls.js:
	env PATH="$$PATH:./node_modules/LiveScript/bin" livescript -c  $<

server :: $(JS_FILES)

jade :: $(HTML_FILES)

client :: jade
	env PATH="$$PATH:./node_modules/brunch/bin" brunch b

run :: server
	node server/app.js

.SUFFIXES: .jade .html .ls .js
