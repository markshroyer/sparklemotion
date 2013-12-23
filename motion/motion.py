#!/usr/bin/env python

from __future__ import print_function

import sparkle
import flask
app = flask.Flask(__name__)

@app.route('/')
def root():
    return flask.redirect('/static/index.html')

@app.route('/static/<path:filename>')
def static(filename):
    return flask.send_from_directory('static', filename)

@app.route('/color', methods=['PUT'])
def set_color():
    color = flask.request.data
    sparkle.set_color(color)
    print("color = {0}".format(color))
    return ""

if __name__ == '__main__':
    app.debug = True
    app.run(host='0.0.0.0', port=80)
