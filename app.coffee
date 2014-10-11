'use strict'
express = require 'express'
compress = require 'compression'
fetcher = require './fetcher'

app = express()
app.use(compress())

app.get '/query', (req, res) ->
	if req.query.id? and req.query.password?
		fetcher.run(req.query.id, req.query.password, res)
	else
		res.send 'invalid'

app.use(express.static(__dirname + '/wwwfiles'))

exports.app = app
