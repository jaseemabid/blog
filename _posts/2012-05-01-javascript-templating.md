---
layout: post
title: "An introduction to JavaScript templating"
date: Wednesday 02 May 2012 11:12:44 PM IST 
comments: true
---
# An introduction to JavaScript templating. 
Quite often you have might have some JSON data like this ...

    {
        "friends": [
            "john doe",
            "swvist",
            "paul",
            "subin",
            "varun"
        ]
    }

... and you want to render it into a html list like this.

> * john doe
> * swvist
> * paul
> * subin
> * varun

Chances are rare when you build a whole webapp with just static data. You will need to pull data out of your DB, add some html tags and css classes around to display it properly. This post is about doing this task in style, with client side JavaScript. Nothing about PHP, Python, RoR or anything serverside now. May be later.

People will often come up with a very quick and dirty script for the task.

    var result = "",i = 0;
    result += "<ul class='myClass' id='myId'>";
    for (i = 0; i < friends.length; i += 1) {
        result = result + "<li>" + friends[i] + "</li>";
    }
    result += "</ul>";
    // Insert `result` into the right place​​​​​

`<personalDisclaimer>` Sorry, but you are abusing JavaScript, string concatenation, templating and everything that's vaguely related to any of these if you write code like this. The data is too bound to your presentation. [Web developers hate it, and I have mentioned it already](/04-15-2012/jekyll-powered-blog.html). You will ultimately end up with spaghetti code that’s too hard to maintain and it will finally kill the whole damn application. Changing the color of a link should involve only CSS and never editing some html or a class name in JavaScript. If you are doing that, you are _*wrong*_.`</personalDisclaimer>`

There is a root similarity in all of the methods to be discussed. They split your data and template very efficiently. Its a lot more cleaner in [CoffeeScript](http://coffeescript.org/) using the 'String Interpolation' feature. Bad implementation, but still better. You sort of fill in data into your templates.

    list = ''
    style = 'myClass'
    id = 'myId'
    for friend in friends
        list = list + "<li>#{friend}</li>"
    result = "<ul class='#{style}' id='#{id}'>#{list}</ul>"

    // Insert `result` into the right place​​​​​

This idea can't be new to any programmer. We have all used it with printf, [sprintf](http://code.google.com/p/sprintf/) etc in C programming.
If you think you don't need [CoffeeScript](http://coffeescript.org/) just for string interpolation, you can use this [*tiny* script](https://gist.github.com/1321623) to do the same task with JavaScript supplants. Problems : Slower, a bit more to type. 

The same task in [underscore.js](http://documentcloud.github.com/underscore/) gets way better. Its a small library that gives a lot of useful utilities under a global _ object.
Here is a very simple example 

    _.template("hello: <%= name %>", {
        "name": "John Doe"
    });​

    // "hello: John Doe"

<span class="label label-info">Heads up!</span> 
Read the [template documentation](http://documentcloud.github.com/underscore/#template) for a complete overview. [underscore.js](http://documentcloud.github.com/underscore/) is one of the best ways to get things done since the library as such is quite small and provides you with a *lot* of other essential features. I'd seriously recommend learning [underscore.js](http://documentcloud.github.com/underscore/).

The above task in underscore (obviously without the extra new lines)

	var list = "<ul>
			  <%
			    _.each(friends, function(name) {
			      %> <li><%= name %></li> <%
			    });
			  %>
		  </ul>",
	result = _.template(list, friends);​

The gotcha here is that you can add arbitrary JavaScript code in the template blocks. The blocks here are `<%= name %>` for variable interpolation, `<% code %>` for arbitrary JavaScript code and `<%- escaped code %>` for JavaScript code that will be html escaped.

Clean, much neater :)

If you're into the whole "DOM as a Template" thing then [PURE](http://beebole.com/pure/#) could work well. I recently came across this, never used it much till now. This might fit well in some contexts. From the [official site](http://beebole.com/pure/#), [PURE](http://beebole.com/pure/#) is a *Simple and ultra-fast templating tool to generate HTML from JSON data* and here is the sample code

	# HTML template
	<div class="who">
	</div>

	# JSON Data

	{
	  "who": "Hello Wrrrld"
	}

	# Output
	Hello Wrrrld

[Mustache](http://mustache.github.com/) is the big daddy when it comes to templating and Aha! there is a JavaScript port of it like many others. [Mustache.js](https://github.com/janl/mustache.js) templates are language agnostic allowing you to reuse them between frontend and backend. Pretty neat tool.

There is a quick *simple* tutorial by [net.tutsplus](http://net.tutsplus.com/tutorials/JavaScript-ajax/quick-tip-using-the-mustache-template-library/). Check it out for simple mustache code examples.

[JavaScript Micro-Templating](http://ejohn.org/blog/JavaScript-micro-templating/) by [John Resig](http://ejohn.org) (the dude behind [jQuery](jquery.com)) is a pretty crude but good option. Pretty similar to my [*tiny* script](https://gist.github.com/1321623) mentioned earlier.

jQuery templates are good and here is the necessary [tutorial](http://blog.reybango.com/2010/07/09/not-using-jquery-javascript-templates-youre-really-missing-out/)

One more part is left. You still have template strings in your JavaScript. The [html script tag](https://developer.mozilla.org/en/HTML/Element/script) comes for rescue here. By the way [this](http://www.sitepoint.com/javascript-mime-type-damned-if-you-do-damned-if-you-dont/) is a very interesting post on script tags. Worth a read for sure, I promise :) We add our template as a script tag with a *wrong/custom* `type` attribute. Unless its `text/javascript` (which is wrong) or `application/javascript` (which wont work in fucking MSIE), it wont be executed. Here is an example from [handlebars.js](http://handlebarsjs.com/) site.

	<script id="entry-template" type="text/x-handlebars-template">
	  template content
	</script>

You can pull out the content with [jQuery.html()](http://api.jquery.com/html/) and the custom id we set. Quite simple!

    var template = $('script#entry-template').html()
    // Do anything mentioned above with the template variable

Essentially we moved the templates out of script, Nirvana! Whatever be your templating method, do this. Your template should stay in html and not JavaScript.

A few more tools and learning resources are listed below. All share common ideas and learning something new if you know a few wont be tough. There are no silver bullets, and there is no single best template engine for JavaScript.

[liquidmarkup](http://liquidmarkup.org/) is amazing. I use it for this blog, but its all serverside, ruby stuff!

I personally prefer underscore.js. They are fast and lightweight, if you have it loaded already then its a good option.

Your templating solution should depend on the rest of your application stack.

[This question on quora : What is the best JavaScript templating framework and why](http://www.quora.com/What-is-the-best-JavaScript-templating-framework-and-why)

Hope this helps somebody. Comments welcome :)


