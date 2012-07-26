---
layout: post
title: "Programming lessons I learned"
date: Thursday, 26 Jul 26 05:37:41 PM IST
comments: true
---
# Programming lessons I learned

Things I learned outside the classroom that might help somebody :)

### 1. Learn to version control your code.

Learn [Git](http://git-scm.com)!

Its a bit pain to learn, agreed! so is every other VCS out there. It will surely
change the way you code forever, if you put some effort into learning it
properly.

The basic idea of git is that you can get back to any version of your code at
any time. It makes collaboration a breeze. It will tell you who added a line of
code at what point of time. You commit when something works, add a decent commit
message
[[[1]]](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
[[[2]]](https://github.com/erlang/otp/wiki/Writing-good-commit-messages) to help
yourself later, and continue working. Before the next commit, look at the diff
to see what you are going to commit, think again if that is exactly what you
want to do and go on. Are you stuck with some nasty bugs? Revert to last known
working version, and continue your work in a fresh manner or stash your current
changes for later review.

Read [Git best practices](http://sethrobertson.github.com/GitBestPractices/).
Its one of the most dense articles I have come across yet. It will surely reward
you.

Here are a [few tutorials](https://gist.github.com/1321592) I collected which
might help.

### 2. Have some sane white space in your code.

White spaces are important.

The ideal way to fix this will be to use [emacs smart tabs](http://www.emacswiki.org/SmartTabs)

People who find that difficult should at least use the whitespace highlight
plugin with gedit. Here is a screen shot with white space plugin enabled.
![whitespace](../img/ws.png)

Intent all your lines with either fixed amount of spaces alone, say 4 or with
tabs alone. Tabs are better because they lead to smaller files and anybody can
adjust tab widths to read it as per their convenience without actually editing
the file. This makes patches real patches and not just white space
modifications. It makes the file consistent across platforms and editors.

### 3. Pick a real programmers editor.

I'm going a bit inclined here. Pick emacs, not vim.

There are infinite number of comparisons online. I'll state my reason for
picking emacs over vim. Vim is a modal editor and it suggests you stay in the
normal mode by default. It makes moving around very easy and when you want to
insert text, you type `i` to get to insert mode and then type in the content.

I realized that this is not how "I" work with my code. Emacs is not a modal
editor. You can insert text at all times. It uses control meta keys more
efficiently and makes moving around and inserting text at the same time a
breeze. I think I can beat a kickass vim guy with my basic emacs skills.

Watch this [video](http://emacsrocks.com/e02.html)

Here are some good emacs videos to get started.

1. [EmacsRocks](http://emacsrocks.com/)
2. [emacsmovies.org](http://emacsmovies.org/)
3. [PeepCode](https://peepcode.com/products/meet-emacs/), if you can pay for it

If you prefer downloading videos for offline viewing, use wget for downloading all EmacsRocks episodes:)

```
    wget http://dl.dropbox.com/u/3615058/emacsrocks/emacs-rocks-{01..11}.mov?dl=1
```

### 4. Contribute to a FOSS

This is actually easier than it sounds. Pick some small application, interact
with the community and fix issues which you can. I was able to fix some issues
with gedit during my last vacation and I am working on more of it now. Also, I
am porting the JavaScript code in gitweb to a standards compliant version using
jQuery which was a proposed Google Summer of Code 2012 project. Hoping to get
those patches accepted soon :P

Comments welcome :)
