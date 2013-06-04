---
layout: post
title: " Emacs package management for newbies"
date: Tuesday, 4 Jun 2013 06:57:52 PM IST

comments: true
---
# Emacs package management for newbies

_*Note*: This post requires Emacs v24+_

One of the most important reasons why I use Emacs is the numerous amazing
packages available for almost everything. This post will give you an
introduction to the ecosystem and finding the right modes.

Emacs is a very big software and a lot of functionality is split into major and
minor modes. A buffer can have only one major-mode enabled at a time and any
number of minor-modes. The major mode is almost always language specific, like
'python-mode' or 'emacs-lisp-mode'. The major modes set the basic language
semantics, indentation, syntax highlighting etc. Minor modes are like small
features you can turn on and off as per your wish. You want to automatically
check for spelling mistakes when you type? There is a minor-mode for that (fly
spell-mode). You normally pick a major-mode according to the file type and a
bunch of minor-modes as per your wish.

One of the major problems I faced when I switched to Emacs was that I didn't
know which modes to use and how. I came across 1000s of modes and I was not sure
which of them are commonly used, and also which of those I really require. It
took me quite sometime to get used to all of that, but there is an easy way. An
average emacs user will have at least 20-30 extra modes installed and
maintaining and updating them manually can be a real pain. The built in package
mechanism in Emacs v24+ makes it super easy to install and update them. I prefer
the melpa repository for the large number of curated packages and the pretty web
UI.

This [article](http://batsov.com/articles/2011/08/19/a-peek-at-emacs24/) about
the new features in Emacs24 and this introductory
[article](http://batsov.com/articles/2012/02/19/package-management-in-emacs-the-good-the-bad-and-the-ugly/)
about Emacs packages might help you understand concepts mentioned here easier.

Just like standard linux package repositories, emacs is having 3 popular package
repositories now. You can add this code somewhere in your '~/.emacs.d/init.el'
to activate all the repos.


<pre class="prettyprint lang-scm">
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
			 ("marmalade" . "http://marmalade-repo.org/packages/")
			 ("melpa" . "http://melpa.milkbox.net/packages/")))
</pre>

Here is what you can do, go to the [melpa repository](http://melpa.milkbox.net)
and sort the packages by the number of downloads, and you can see
[magit](https://github.com/magit/magit) topping the list with over 10,000
downloads. There is a decent probability that such packages are going to be both
awesome and useful to you. There are other amazing packages which wont top the
list, like [org-mode](http://orgmode.org/) because they are shipped with Emacs
core.

Now you can install the package with 1 simple command, 'M-x
package-list-packages'

So what packages to use? This is the [list of packages I
use](https://github.com/jaseemabid/emacs.d/blob/master/elpa-list.el). A few of
them just got in there randomly when I was learning and exploring Emacs but
there are some which I just cannot live without now.
[magit](https://github.com/magit/magit) is the most awesome git interface ever.
[org-mode](http://orgmode.org/) is an amazing notes/todo organizer.
[git-commit-mode](https://github.com/lunaryorn/git-modes) ensures that my commit
messages are always sensible and well formatted.
[guru-mode](https://github.com/bbatsov/guru-mode) makes sure that I will use the
proper key bindings and wont fall back to arrow keys once in a while.
[auctex](http://www.gnu.org/software/auctex/) is a really amazing mode for
tex/latex files. [bitlbee](http://www.bitlbee.org/main.php/news.r.html) will let
me tweet as [@jaseemabid](http://twitter.com/jaseemabid) right from Emacs. Other
modes like [nginx-mode](https://github.com/ajc/nginx-mode) and
[haml-mode](https://github.com/nex3/haml-mode) gives me syntax highlighting for
whatever I edit. [rainbow-mode](https://github.com/emacsmirror/rainbow-mode)
will make the colors look
[pretty](http://julien.danjou.info/projects/emacs-packages#rainbow-mode) in my
CSS/HTML files. [Solarized dark](https://github.com/bbatsov/solarized-emacs/) is
my favorite theme and it got packaged as well.
[rinari](http://rinari.rubyforge.org) makes Rails development a breeze. I got
rid of my file manager (thunar/nautilus/nemo) almost completely completely with
[dired](http://www.gnu.org/software/emacs/manual/html_node/emacs/Dired.html).

Some modes are known for its poor state. [php-mode]() is one of the worst and
fortunately I don't have to write much PHP. Another broken mode is 'js-mode' but
there is [js2-mode](https://github.com/mooz/js2-mode), a much better fork. Read
[here](http://steve-yegge.blogspot.in/2008/03/js2-mode-new-javascript-mode-for-emacs.html)
some interesting history about js2-mode.

You might have already come across people who tell you how flexible Emacs is
with emacs-lisp right? Here is an example. What if you want to completely forget
about the default js-mode and switch to js2-mode? You have 2 ways (definitely a
lot more, this is what I know).

1 Ask emacs to open files with a '.js' extension with js2-mode

<pre class="prettyprint lang-scm">
;; Open .js files with js2-mode
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
</pre>

2 Ask emacs to switch to js2-mode whenever js-mode is activated.

<pre class="prettyprint lang-scm">
;; Switch js-mode to js2-mode
;; js-mode
(add-hook 'js-mode-hook
    (lambda ()
        ;; Switch to js2
		(js2-mode)
		)
	)
</pre>

That was easy! elisp might feel a bit alien in the beginning, but its quite easy
to get used to that.

So, get started with emacs and let me know how it went ;)
