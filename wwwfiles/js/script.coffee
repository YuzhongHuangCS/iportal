$(
	->
		$(document).keydown (event) ->
			enterKeyCode = 13
			if event.keyCode == enterKeyCode
				$('#loginButton').click()

		$('#loginButton').click ->
			console.log 'clicked'
			'''
			$.ajax
				type: 'GET'
				url: 'query'
				data: $('#loginForm').serialize()
				success: parse
			'''
			parse(JSON.parse(localStorage.getItem('courses')))

)

parse = (body) ->
	#localStorage.setItem('courses', JSON.stringify(body))

	calendar = {}

	'''
	month = {}
	months = {}
	for day in [1..31]
		day = String(day)
		if day.length == 1
			day = '0' + day
		month[day] = []
		console.log month
	
	for monthIndex in [1..12]
		monthIndex = String(monthIndex)
		if monthIndex.length == 1
			monthIndex = '0' + monthIndex
		months[monthIndex] = month
	'''

	for year in [2014..2014]
		calendar[year] = {}
		for month in [9..12]
			month = String(month)
			if month.length == 1
				month = '0' + month
			calendar[year][month] = {}
			
			for day in [1..31]
				day = String(day)
				if day.length == 1
					day = '0' + day
				calendar[year][month][day] = []

	for course in body
		for lesson in course.lessons
			[day, month, year] = lesson.date.split('/')
			lesson['name'] = course.name
			calendar[year][month][day].push(lesson)

	console.log calendar
	localStorage.setItem('calendar', JSON.stringify(calendar))