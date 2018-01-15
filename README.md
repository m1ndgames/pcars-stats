# pcars-stats
Project Cars Hotlaps Statistics

The filldb script extracts the races from the dedicated servers lua-stats plugin and writes it into a SQL database.

(It expects to find 'sms_stats_data.json' in the same path.)

The 'vehicle.json' was extracted from the server api. It might need to be updated when new cars/liveries are added to the game.

The php file writes a html table and shows a racers best lap with any car. Some javascript and css was added to make it somewhat fancy...

Beware!
I didnt know any PHP and Javascript, so its hacky and ugly...
+ i need to create some icons

It uses http://listjs.com/ for table sorting/filtering.

Demo: http://stats.m1nd.io/ (Maybe down or broken as i tweak stuff)
