ROBOT = src/phantomrobot.coffee
KEYWORDS = `find src/_*.coffee|sort`

all: phantomrobot.js

phantomrobot.js: $(MY_KEYWORDS) src/*.coffee
	cat $(KEYWORDS) $(MY_KEYWORDS) $(ROBOT)|coffee -s -b -c > phantomrobot.js
