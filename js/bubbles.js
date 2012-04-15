$(function () {
	"use strict";
	var wd = $(document).width(),
		ht = $(document).height(),
		paper = Raphael(0, 0, wd, ht),
		makeBubble = function () {
			var x = parseInt(Math.random() * wd,10),
				y = parseInt(Math.random() * ht,10),
				r = parseInt(Math.random() * 200,10);
			return paper.circle(x, y, r).attr({
				"fill": "#bbb"
			}).animate({
				"fill": "#dedede",
				"stroke": "#e2e2e2",
				"stroke-width": 80,
				"stroke-opacity": 0.5,
				"opacity" : 0.2
			}, 10000);
		},
		myCircle = makeBubble();

	setInterval(function () {
		myCircle = makeBubble();
	}, 8000);
});
