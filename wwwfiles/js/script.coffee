'use strict'
$(
	->
		if not window.orientation?
			$('div#login').addClass('desktop')

		$(document).keydown (event) ->
			enterKeyCode = 13
			if event.keyCode == enterKeyCode
				$('#loginButton').click()

		$(window).on 'load', (event) ->
			if localStorage.getItem('calendar')
				location.hash = '#list'
			else
				location.hash = '#login'

		$(window).on 'load hashchange', (event) ->
			if location.hash == '#list'
				today()
			if location.hash == '#week'
				thisWeek()

			$('a[href]').removeClass('current')
			switch window.location.hash
				when '#list' then $('a[href=#list]').addClass('current')
				when '#week' then $('a[href=#week]').addClass('current')
				when '#plan' then $('a[href=#plan]').addClass('current')
				when '#about' then $('a[href=#about]').addClass('current')

		$('#loginButton').click ->
			queryString = $('#loginForm').serialize()
			localStorage.setItem('queryString', queryString)
			fetch(queryString)

		$('#yesterday').click ->
			update(-1)
		$('#tomorrow').click ->
			update(1)

		$('#lastweek').click ->
			updateWeek(-7)
		$('#nextweek').click ->
			updateWeek(7)

		$('#refreshButton').click ->
			fetch(localStorage.getItem('queryString'))

		$('#logoutButton').click ->
			localStorage.removeItem('queryString')
			localStorage.removeItem('courses')
			localStorage.removeItem('calendar')
			location.hash = '#login'
)

fetch = (queryString) ->
	$.mobile.loading 'show',
		text: "Prepare data may take a long time, but it is needed only on the first time.",
		textVisible: true,
		textonly: false,
	
	$.ajax
		type: 'GET'
		url: 'query'
		data: queryString
		success: (body)->
			parse(body)
			$.mobile.loading('hide')

parse = (body) ->
	localStorage.setItem('courses', JSON.stringify(body))

	calendar = {}

	for course in body
		for lesson in course.lessons
			lesson['name'] = course.name
			lesson['component'] = course.component
			[day, month, year] = lesson.date.split('/')

			[startTime, endTime] = lesson.time.split(' - ')
			if startTime.substring(startTime.length-2) == 'AM'
				[startHour, startMin] = startTime.replace('AM', '').split(':')
			else
				[startHour, startMin] = startTime.replace('PM', '').split(':')
				startHour = Number(startHour) + 12

			if endTime.substring(endTime.length-2) == 'AM'
				[endHour, endMin] = endTime.replace('AM', '').split(':')
			else
				[endHour, endMin] = endTime.replace('PM', '').split(':')
				endHour = Number(endHour) + 12

			lesson['start'] = Number(startHour) + (startMin) / 60
			lesson['end'] = Number(endHour) + (endMin) / 60

			if not calendar[year]?
				calendar[year] = {}
			if not calendar[year][month]?
				calendar[year][month] = {}
			if not calendar[year][month][day]?
				calendar[year][month][day] = []

			calendar[year][month][day].push(lesson)

	for yearKey, year of calendar
		for monthKey, month of year
			for dayKey, day of month
				day.sort (first, second)->
					return first.start - second.start

	localStorage.setItem('calendar', JSON.stringify(calendar))
	location.hash = '#list'

today = ->
	window.date = new Date()
	render(window.date)

update = (option) ->
	targetDate = window.date
	targetDate.setDate(targetDate.getDate() + option)
	render(targetDate)

render = (date) ->
	$('#todayDate').text(date.toDateString())

	year = String(date.getFullYear())
	month = String(date.getMonth() + 1)
	day = String(date.getDate())
	if month.length == 1
		month = '0' + month
	if day.length == 1
		day = '0' + day

	data = JSON.parse(localStorage.getItem('calendar'))
	if data[year][month][day]?
		courses = data[year][month][day]

		html = ''
		for course in courses
			html += '<div class="ui-body-a ui-corner-all courseUnit">'
			html += 	"<div class='ui-bar ui-bar-a'><h3>#{course.name}</h3></div>"
			html += 	'<div class="ui-body ui-body-a">'
			html += 		"<p><b>Time: </b>#{course.time}</p>"
			html += 		"<p><b>Classroom: </b>#{course.room}</p>"
			html += 		"<p><b>Instructor: </b>#{course.instructor}</p>"
			html += 		"<p><b>Date: </b>#{course.date}</p>"
			html += 		"<p><b>Component: </b>#{course.component}</p>"
			html += 	'</div>'
			html += '</div>'

		$('#courseList').html(html)
	else
		html = ''
		html += '<div class="ui-body-a ui-corner-all courseUnit">'
		html += 	'<div class="ui-bar ui-bar-a"><h3>No class today</h3></div>'
		html += 	'<div class="ui-body ui-body-a">'
		html += 		'<p>Feel free and easy!</p>'
		html += 	'</div>'
		html += '</div>'
		
		$('#courseList').html(html)

thisWeek = ->
	window.date = new Date()
	renderWeek(window.date)

updateWeek = (option)->
	window.date.setDate(window.date.getDate() + option)
	renderWeek(window.date)

renderWeek = (date)->
	startDay = new Date(date)
	startDay.setDate(startDay.getDate() - startDay.getDay() + 1)
	endDay = new Date(startDay)
	endDay.setDate(endDay.getDate() + 4)
	$('#weekDate').text(startDay.toDateString().substring(0, 10) + ' - ' + endDay.toDateString().substring(0, 10))
	html = '<rect id="back" width="100%" height="100%"></rect>'
	xCount = 6
	yCount = 12
	xStep = 100 / xCount
	yStep = 100 / yCount

	for x in [1...xCount]
		html += "<line class='day' x1='#{x*xStep}%' x2='#{x*xStep}%' y1='0%' y2='100%'></line>"

	for y in [1...yCount]
		html += "<line class='hour' x1='0%' x2='100%' y1='#{y*yStep}%' y2='#{y*yStep}%'></line>"

	data = JSON.parse(localStorage.getItem('calendar'))
	thisDay = new Date(date)
	thisDay.setDate(thisDay.getDate() - thisDay.getDay())

	for d in [1...xCount]
		thisDay.setDate(thisDay.getDate() + 1)
		year = String(thisDay.getFullYear())
		month = String(thisDay.getMonth() + 1)
		day = String(thisDay.getDate())
		if month.length == 1
			month = '0' + month
		if day.length == 1
			day = '0' + day

		if data[year][month][day]?
			for lesson in data[year][month][day]
				html += "<rect class='lessonBox' x='#{d*xStep}%' y='#{(lesson.start-9)*yStep}%' width='#{xStep}%' height='#{(lesson.end - lesson.start)*yStep}%'></rect>"
				html += "<text class='lessonText' x='#{(d+0.05)*xStep}%' y='#{(lesson.start-9+0.4)*yStep}%'>#{lesson.name.substring(0, 7)}</text>"
				html += "<text class='lessonText' x='#{(d+0.05)*xStep}%' y='#{(lesson.start-9+0.9)*yStep}%'>#{lesson.name.substring(10)}</text>"

	for y in [0..yCount]
		html += "<text class='clock' x='0' y='#{(y-0.75)*yStep}%'>#{y+8}:00</text>"

	$('svg#weeklyCalender').html(html)