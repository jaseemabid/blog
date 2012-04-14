---
layout: post
title: "A jekyll powered blog for yourself"
date: 2012-04-15 02:05
comments: true
---

# A jekyll powered blog for yourself

Googling on the topic should lead you to tutorials on how to get your [jekyll](https://github.com/mojombo/jekyll/) powered blog up in minutes.
[jekyll bootstrap](http://jekyllbootstrap.com/) will even give you a custom script to make deployment easier. This [nettuts article](http://net.tutsplus.com/tutorials/other/building-static-sites-with-jekyll/) could be your first read about jekyll. The official [docs](https://github.com/mojombo/jekyll/wiki) and [octopress](http://octopress.org) give more idea. So here I'm going a bit against my first post. More philosophy and less code.

jekyll is originally by [Tom Preston-Werner aka mojombo](https://github.com/mojombo). You can read his blogs [here](http://tom.preston-werner.com/). Out of all of the posts, [blogging like a hacker](http://tom.preston-werner.com/2008/11/17/blogging-like-a-hacker.html) talks about the inception of jekyll.

I have always felt something similar about blogging but never ever thought I could write something like this bottom up. I'd like to share here why I moved to something like this from the traditional blogging engines. 

When I felt like writing, I wanted to concentrate on my content and not on the style or presentation. When I designed, I dint want to go to 10 blog posts and edit CSS classes there. I wanted to separate them out, because content and presentation are two different things they just don't go well together. jekyll provides enough tools to do this very efficiently. [Octopress](http://octopress.org) adds sugar on top of jekyll and gives you a default template, loads of extra plugins and it makes the first jump into something like this less troublesome. This was important to me. I might move my blog to some other platform someday and I want the transition to be smooth. Posts can be written in a standard format, mardkown. You can read more about it [here](http://daringfireball.net/projects/markdown/syntax), and [here](http://github.github.com/github-flavored-markdown/) and [here](https://github.com/rtomayko/rdiscount). It gives me the freedom to express things exactly the way I wanted it. In a way it reminds me of stuff like [MVC architecture](http://en.wikipedia.org/wiki/Model-view-controller), though they are quite different. 

I feel so insecure when I write content or code and don’t track it with git. I wanted my data or code to be safe even if my laptop crashed midway a sentence. Its pretty usual for me to push to github per commit. I learned git about 2 years back. Thanks to [@Noufal Ibrahim](http://twitter.com/noufalibrahim). Though it was quite a pain to pick it up, I gradually fell in love with git. Thanks to `.netrc` file which will let me push through firewalls like that of [NITC](http://www.nitc.ac.in) allowing only port 80, 443 etc without typing passwords again and again. Im gonna write a lot about git in the future I guess. I could track my blog posts as plain text files, VC it with git and make sure that I exactly know when and how some content posted up on the internet on my name changed and react to it. I cant imagine this on blogger. Here I trust SHA1 security of git and [Linus Torvalds](http://en.wikipedia.org/wiki/Linus_Torvalds) over the blogger servers run by Google.

Forgetting all the uber geek stuff, finally jekyll will output a static site to `_site` folder, which you should be able to deploy to any web server in the world easily. github adds a bit spice and you can directly push the jekyll code and it will deal the rest. (Tom Preston-Werner aka mojombo is a githubber). I am not sure how well it will fit somebody else's needs, but this feels like the right tool for me. Ping me for any help and I will be happy to do so :)

As Tom says,

> I’ve been living with Jekyll for just over a month now. I love it. Driving the development of Jekyll based on the needs of my blog has been very rewarding. I can edit my posts in TextMate, giving me automatic and competent spell checking. I have immediate and first class access to the CSS and page templates. Everything is backed up on GitHub. I feel a lightness now when I’m writing a post. The system is simple enough that I can keep the entire conversion process in my head. The distance from my brain to my blog has shrunk, and, in the end, I think that will make me a better author.

UPDATE : 
	I just added disqus comments to my blog and this is how I did it.

> * Get your [disqus code](http://disqus.com/) and insert it into something like `_includes/disqus.ext` [commit](https://github.com/jaseemabid/jaseemabid.github.com/commit/169706808efb4431fded505fe0052cd2d61fcb6a)
> * Conditionally include it to your post layout [commit](https://github.com/jaseemabid/jaseemabid.github.com/commit/8c5c565c27cd6f7b0207600880e6fe80ace397a9)
> * Make it look good with too less css [comments](https://github.com/jaseemabid/jaseemabid.github.com/commit/48298c4cd9af8390084270b77325f86ffd7984ed)


