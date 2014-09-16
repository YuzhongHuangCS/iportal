'use strict'
$(
	->
		$(document).keydown (event) ->
			enterKeyCode = 13
			if event.keyCode == enterKeyCode
				$('#loginButton').click()

		$('#loginButton').click ->
			$.ajax
				type: 'GET'
				url: 'query'
				data: $('#loginForm').serialize()
				success: parse

			#parse(JSON.parse(localStorage.getItem('courses')))

		$(window).on 'load', (event) ->
			if location.hash == '#list'
				render()
)

parse = (body) ->
	localStorage.setItem('courses', JSON.stringify(body))

	calendar = {}

	for course in body
		for lesson in course.lessons
			lesson['name'] = course.name
			[day, month, year] = lesson.date.split('/')

			if not calendar[year]?
				calendar[year] = {}
			if not calendar[year][month]?
				calendar[year][month] = {}
			if not calendar[year][month][day]?
				calendar[year][month][day] = []

			calendar[year][month][day].push(lesson)

	localStorage.setItem('calendar', JSON.stringify(calendar))
	render()

render = ->
	leftJustify = (string, length, char) ->
		fill = []
		while fill.length + string.length < length
		  fill[fill.length] = char

		return fill.join('') + string

	d = new Date()
	year = String(d.getFullYear())
	month = String((d.getMonth() + 1))
	day = String (d.getDate() - 1)

	month = leftJustify(month, 2, '0')
	day = leftJustify(day, 2, '0')

	#console.log(year, month, day)

	data = JSON.parse(localStorage.getItem('calendar'))
	if data[year][month][day]?
		courses = data[year][month][day]
		#console.log courses
	else
		alert('Today have no course')
		#console.log 'Today have no course'

	html = ''
	for course in courses
		html += '<ul data-role="listview" data-inset="true" class="ui-listview ui-listview-inset ui-corner-all ui-shadow">'
		for key, value of course
			html += "<li class='ui-li-static ui-body-inherit'>#{key}: #{value}</li>"
		html += '</ul>'

	#console.log html
	$('#courseList').html(html)
	
	location.hash = '#list'