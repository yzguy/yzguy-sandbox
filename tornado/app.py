#!/usr/bin/python

import tornado.httpserver
import tornado.ioloop
import tornado.web
import tornado.options

from tornado.options import define, options
define("port", default=8000, help="run on the given port", type=int)

class IndexHandler(tornado.web.RequestHandler):
    def get(self):
        self.render('index.html')

if __name__ == "__main__":
    tornado.options.parse_command_line()

    settings = {
        "template_path": "templates",
        "static_path": "static"
    }

    application = tornado.web.Application([
        (r'/', IndexHandler)
    ], **settings)

    http_server = tornado.httpserver.HTTPServer(application)
    http_server.listen(options.port)
    tornado.ioloop.IOLoop.instance().start()
