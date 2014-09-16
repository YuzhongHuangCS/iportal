'use strict'
express = require 'express'
fetcher = require './fetcher'
app = express()

app.get '/query', (req, res) ->
	if req.query.id? and req.query.password?
		fetcher.run(req.query.id, req.query.password, res)
	else
		res.send 'invalid'

app.use(express.static('wwwfiles'))

server = app.listen 8000, ->
	console.log "Listening on #{server.address().address}:#{server.address().port}"
