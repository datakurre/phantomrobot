all: phantomrobot.js

phantomrobot.js: src/*.coffee
	cat `find src/_*.coffee` src/phantomrobot.coffee|coffee -s -b -c > phantomrobot.js
