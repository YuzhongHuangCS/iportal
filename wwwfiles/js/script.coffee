'use strict'
$(
	->
		if typeof(window.orientation) == 'undefined'
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
			$('a[href]').removeClass('current')
			switch location.hash
				when '#list' then $('a[href=#list]').addClass('current')
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

			if not calendar[year]?
				calendar[year] = {}
			if not calendar[year][month]?
				calendar[year][month] = {}
			if not calendar[year][month][day]?
				calendar[year][month][day] = []

			calendar[year][month][day].push(lesson)

	localStorage.setItem('calendar', JSON.stringify(calendar))
	location.hash = '#list'

today = ->
	window.monthDayCount =
		1: 31
		2: 28
		3: 31
		4: 30
		5: 31
		6: 30
		7: 31
		8: 31
		9: 30
		10: 31
		11: 30
		12: 31

	d = new Date()
	year = String(d.getFullYear())
	month = String((d.getMonth() + 1))
	day = String (d.getDate())

	if month.length == 1
		month = '0' + month
	if day.length == 1
		day = '0' + day

	window.year = year
	window.month = month
	window.day = day

	render(year, month, day)

update = (option) ->
	year = Number(window.year)
	month = Number(window.month)
	day = Number(window.day)

	'''
	Improvement needed
		handle of leap year
	'''

	if option == -1
		day -= 1
		if day <= 0
			month -= 1
			if month <= 0
				month = 12
				year -= 1
			day = window.monthDayCount[month]

	else
		day += 1
		if day > window.monthDayCount[month]
			day = 1
			month += 1
			if month > 12
				month = 1
				year += 1

	year = String(year)
	month = String(month)
	day = String(day)

	if month.length == 1
		month = '0' + month
	if day.length == 1
		day = '0' + day

	render(year, month, day)

	window.year = year
	window.month = month
	window.day = day

render = (year, month, day) ->

	todayDate = "#{year}/#{month}/#{day}"
	$('#todayDate').text(todayDate)

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