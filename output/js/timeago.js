/*
Copyright (c) 2012 Don Melton
http://opensource.org/licenses/MIT
Adapted from 'jquery.timeago.js'
Copyright (c) 2008-2011 Ryan McGeary
 */
(function($) {
	var adjustTime, properNumber;
	$.fn.timeago = function() {
		this.each(adjustTime);
		setInterval((function(_this) {
			return function() {
				_this.each(adjustTime);
			};
		})(this), 60000);
		return this;
	};
	adjustTime = function() {
		var data, datetime, days, element, hours, minutes, seconds, text, words, years;
		element = $(this);
		data = element.data('timeago');
		if (!data) {
			text = $.trim(element.text());
			if (text.length > 0) {
				element.attr('title', text);
			}
			datetime = element.attr('datetime');
			datetime = $.trim(datetime);
			datetime = datetime.replace(/\.\d\d\d+/, '').replace(/-/, '/').replace(/-/, '/').replace(/T/, ' ').replace(/Z/, ' UTC').replace(/([\+\-]\d\d)\:?(\d\d)/, " $1$2");
			data = new Date(datetime);
			element.data('timeago', data);
		}
		if (isNaN(data)) {
			return false;
		}
		seconds = Math.abs(new Date().getTime() - data.getTime()) / 1000;
		minutes = seconds / 60;
		hours = minutes / 60;
		days = hours / 24;
		years = days / 365;
		words = seconds < 60 && 'seconds ago' || minutes < 2 && 'a minute ago' || minutes < 60 && properNumber(Math.floor(minutes)) + ' minutes ago' || hours < 2 && 'an hour ago' || hours < 24 && properNumber(Math.floor(hours)) + ' hours ago' || days < 2 && 'yesterday' || days < 7 && properNumber(Math.floor(days)) + ' days ago' || days < 14 && 'last week' || days < 30 && properNumber(Math.floor(days / 7)) + ' weeks ago' || days < 60 && 'last month' || days < 365 && properNumber(Math.floor(days / 30)) + ' months ago' || years < 2 && 'last year' || properNumber(Math.floor(years)) + ' years ago';
		element.text(words);
	};
	properNumber = function(number) {
		number = parseInt(number, 10);
		if (number > 1 && number < 10) {
			number = ['two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'][number - 2];
		}
		return number;
	};
})(jQuery);
