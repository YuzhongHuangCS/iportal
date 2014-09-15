mysql = require 'mysql'
cheerio = require 'cheerio'

conn = mysql.createConnection
    host: 'localhost'
    user: 'nodejs'
    password: 'nodejs'
    database: 'iportal'
    port: 3306

conn.connect()

conn.query 'SELECT `id`, `password` FROM `user`', (error, rows, fields) ->
	rows.forEach (value, index) ->
		loginUrl = 'https://myportal.sutd.edu.sg/psp/EPPRD/'
		loginQueryString = 
			cmd: "login"
			languageCd: "ENG"

		loginPostData = 
			timezoneOffset: "-480"
			userid: value.id
			pwd: value.password

		loginOptions =
			url: loginUrl
			method: "POST"
			qs: loginQueryString
			form: loginPostData

		listUrl = 'https://sams.sutd.edu.sg/psc/CSPRD/EMPLOYEE/HRMS/c/SA_LEARNER_SERVICES.SSR_SSENRL_LIST.GBL'

		listQueryString = {
			Page: "SSR_SSENRL_LIST"
			Action: "A"
			EMPLID: value.id
			TargetFrameName:"None"
		}

		listOptions =
			url: listUrl
			qs: listQueryString

		request = require('request').defaults
			jar: require('request').jar()
			strictSSL: false
			gzip: true
			followAllRedirects: true
			headers:
				"User-Agent": "Nodejs"

		request loginOptions, (loginError, loginResponse, loginBody)->
			if loginError
				console.log(loginError)
			else
				#console.log(loginResponse.statusCode, loginBody)
				#console.log(loginResponse)
				request listOptions, (listError, listResponse, listBody) ->
					if listError
						console.log(listError)
					else
						#console.log(listBody)
						courses = JSON.stringify(parseBody(listBody))
						sql = "UPDATE `user` SET `courses`= ? WHERE `id` = ?"
						inserts = [courses, value.id]
						sql = mysql.format(sql, inserts);
						conn.query sql, (error) ->
							console.log(error) if error

parseBody = (body) ->
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
					date: nodes[i+3]
				course['lessons'].push(lesson)
			courses.push(course)

	return courses
