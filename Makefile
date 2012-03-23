ROBOT = src/phantomrobot.coffee
KEYWORDS = `find src/_*.coffee|LC_ALL=C sort`

all: phantomrobot.js

phantomrobot.js: $(MY_KEYWORDS) src/*.coffee
	cat $(KEYWORDS) $(MY_KEYWORDS) $(ROBOT)|coffee -s -b -c > phantomrobot.js

clean:
	find . -name "phantomrobot.js" -print0|xargs -0 rm
	find . -name "report.html" -print0|xargs -0 rm
	find . -name "log.html" -print0|xargs -0 rm
	find . -name "output.xml" -print0|xargs -0 rm
	find . -name "Altitude.log" -print0|xargs -0 rm
	find . -name "*.png" -print0|xargs -0 rm
