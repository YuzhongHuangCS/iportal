'use strict'
cheerio = require 'cheerio'

run = (id, password, res) ->
	option(id, password, res)

option = (id, password, res) ->
	loginUrl = 'https://myportal.sutd.edu.sg/psp/EPPRD/'
	loginQueryString = 
		cmd: "login"
		languageCd: "ENG"
	loginPostData = 
		timezoneOffset: "-480"
		userid: id
		pwd: password
	loginOptions =
		url: loginUrl
		method: "POST"
		qs: loginQueryString
		form: loginPostData

	listUrl = 'https://sams.sutd.edu.sg/psc/CSPRD/EMPLOYEE/HRMS/c/SA_LEARNER_SERVICES.SSR_SSENRL_LIST.GBL'
	listQueryString =
		Page: "SSR_SSENRL_LIST"
		Action: "A"
		EMPLID: id
		TargetFrameName:"None"
	listOptions =
			url: listUrl
			qs: listQueryString

	fetch(loginOptions, listOptions, res)

fetch = (loginOptions, listOptions, res) ->
	request = require('request').defaults
		jar: require('request').jar()
		strictSSL: false
		gzip: true
		followAllRedirects: true
		headers:
			"User-Agent": "Node.js/Express"

	request loginOptions, (loginError, loginResponse, loginBody)->
		if loginError
			console.log(loginError)
		else
			request listOptions, (listError, listResponse, listBody) ->
				if listError
					console.log(listError)
				else
					parse(listBody, res)

parse = (body, res) ->
	$ = cheerio.load(body)
	courses = []
	$('table.PSGROUPBOXWBO').each (index, value) ->
		if index != 0
			course = {
				"name": $(this).find('td.PAGROUPDIVIDER').text()
			}

			nodes = []
			$(this).find('span.PSEDITBOX_DISPONLY, span.PSLONGEDITBOX').each (index, value) ->
				node = $(this).text()
				if node.length > 1
					nodes.push(node)

			course['status'] = nodes.shift()
			course['units'] = nodes.shift()
			course['grading'] = nodes.shift()
			course['classNumber'] = nodes.shift()
			course['component'] = nodes.shift()
			course['lessons'] = []

			for i in [0...nodes.length] by 4
				lesson =
					time: nodes[i]
					room: nodes[i+1]
					instructor: nodes[i+2]
					date: nodes[i+3].split(' - ')[0]
				course['lessons'].push(lesson)

			courses.push(course)

	res.json(courses)

exports.run = run
