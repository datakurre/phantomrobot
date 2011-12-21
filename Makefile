all: phantomrobot.js lib/browser.js lib/click.js lib/page.js lib/textfield.js lib/robot.js

lib/robot.js: lib/robot.coffee
	coffee -b -c lib/robot.coffee

phantomrobot.js: phantomrobot.coffee
	coffee -b -c phantomrobot.coffee

lib/browser.js: lib/browser.coffee
	coffee -b -c lib/browser.coffee

lib/click.js: lib/click.coffee
	coffee -b -c lib/click.coffee

lib/page.js: lib/page.coffee
	coffee -b -c lib/page.coffee

lib/textfield.js: lib/textfield.coffee
	coffee -b -c lib/textfield.coffee
