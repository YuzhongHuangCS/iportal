'use strict'
cheerio = require 'cheerio'
request = require 'request'

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
	thisRequest = request.defaults
		jar: request.jar()
		strictSSL: false
		gzip: true
		followAllRedirects: true
		headers:
			"User-Agent": "Node.js/Express"

	thisRequest loginOptions, (loginError, loginResponse, loginBody)->
		if loginError
			console.log(loginError)
		else
			thisRequest listOptions, (listError, listResponse, listBody) ->
				if listError
					console.log(listError)
				else
					parse(listBody, res)

parse = (body, res) ->
	$ = cheerio.load(body)
	courses = []
	$('table.PSGROUPBOXWBO').each (index, value) ->
		if index != 0
			info = []
			classes = []
			current = -1
			# It is very dirty here, be careful!
			$(this).find('span.PSEDITBOX_DISPONLY, span.PSLONGEDITBOX').each (index, value) ->
				node = $(this).text()
				if node.length > 1
					if Number(node) and node.length == 4
						current += 1
						classes[current] = []
					if current == -1
						info.push(node)
					else
						classes[current].push(node)

			for item in classes
				course = {
					"name": $(this).find('td.PAGROUPDIVIDER').text()
				}

				course['status'] = info[0]
				course['units'] = info[1]
				course['grading'] = info[2]
				course['classNumber'] = item.shift()
				course['component'] = item.shift()
				course['lessons'] = []

				for i in [0...item.length] by 4
					lesson =
						time: item[i].substring(3)
						room: item[i+1]
						instructor: item[i+2]
						date: item[i+3].split(' - ')[0]
					course['lessons'].push(lesson)

				courses.push(course)

	res.json(courses)

exports.run = run
