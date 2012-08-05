$(function () {
	"use strict";
	var twitter = function (elem) {
		var data = $(elem).html(),
			reg = /@(\w{1,})/g,
			res = data.match(reg),
			len = res.length,
			i;

		for (i = 0; i < len; i += 1) {
			data = data.replace(res[i],
								$('<a>').attr({
									"href": "http://twitter.com/" + res[i].slice(1)
								}).html(res[i]).prop('outerHTML'));
		}
		$(elem).html(data);
		return this;
	};

	$(function(){
		$('pre').addClass('prettyprint');
		prettyPrint();
		twitter($('body'));
	});
});
