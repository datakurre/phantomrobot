all: phantomrobot.js lib/robot.js lib/browser.js lib/page.js lib/click.js lib/form.js

phantomrobot.js: phantomrobot.coffee
	coffee -b -c phantomrobot.coffee

lib/robot.js: lib/robot.coffee
	coffee -b -c lib/robot.coffee

lib/browser.js: lib/browser.coffee
	coffee -b -c lib/browser.coffee

lib/page.js: lib/page.coffee
	coffee -b -c lib/page.coffee

lib/click.js: lib/click.coffee
	coffee -b -c lib/click.coffee

lib/form.js: lib/form.coffee
	coffee -b -c lib/form.coffee
