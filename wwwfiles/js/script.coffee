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
	date = new Date()
	window.date = date
	render(date)

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