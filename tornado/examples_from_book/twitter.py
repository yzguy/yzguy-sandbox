# Tornado Imports
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.httpclient

# Normal Imports
import urllib
import json
import datetime
import time

# Allow user to specify different port to run on
from tornado.options import define, options
define("port", default=8000, help="run on the given port", type=int)

class IndexHandler(tornado.web.RequestHandler):
  def get(self):
    # Capture Quer String Argument
    query = self.get_argument('q')

    # Create HTTPClient object
    client = tornado.httpclient.HTTPClient()

    # Make HTTP Call to twitter API
    response = client.fetch("https://api.twitter.com/1.1/search/tweets.json?" + urllib.urlencode({"q": query, "result_type": "recent", "rpp": 100}))
    
    # Parse JSON Response
    body = json.loads(response.body)

    # Get number of results
    result_count = len(body['results'])

    # Capture current time
    now = datetime.datetime.utcnow()

    # Find oldest tweet
    raw_oldest_tweet_at = body['results'][-1]['created_at']
    oldest_tweet_at = datetime.datetime.strptime(raw_oldest_tweet_at, "%a, %d %b %Y %H:%M:%S +0000")

    # Find difference in time
    seconds_diff = time.mktime(now.timetuple()) - \
        time.mktime(oldest_tweet_at.timetuple())

    # Calculate Tweets per second
    tweets_per_second = float(result_count) / seconds_diff

    # Send back HTML response
    self.write("""
<div style="text-align: center">
    <div style="font-size: 72px;">%s</div>
    <div style="font-size: 144px;">%0.2f</div>
    <div style="font-size: 24px;">tweets per second</div>
</div>""" % (query, tweets_per_second))

if __name__ == "__main__":
    # Parse command line arguments for different port
    tornado.options.parse_command_line()

    # Create app and map handlers to routes
    app = tornado.web.Application(
    handlers=[(
        r"/", IndexHandler
    )])
    # Run HTTP Server
    http_server = tornado.httpserver.HTTPServer(app)
    http_server.listen(options.port)
    tornado.ioloop.IOLoop.instance().start()
