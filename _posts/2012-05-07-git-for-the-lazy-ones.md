---
layout: post
title: "Git for the very lazy ones like me"
date: Monday 07 May 2012 02:19:41 AM IST
comments: true
---

# Git for the very lazy ones like me.

This post is proof that I'm lazy at heart to the core!

I came across git over year ago. It's a quite hard tool to learn, but once you get it, Its *bloody awesome*. It will change the way you code, forever. If its not, learn it well, again.

Here I am sharing a few ways in which I am making git "awesomer", or say better for lazy guys like me, saving some typing.

`<disclaimer>` I don't give a damn about windows users. I don't care if things I share don't work for them. I hate M$, people using M$ products ( includes skype also ) and everything that is vaguely or remotely related to them. Things I blog here works on my primary machine powered by Debian Sid and that's all I know. `</disclaimer>`

### 1. Save some typing with awesome aliases.

Its a long list of aliases, so its quite sensible to hack bash and add a new alias file. Add the following code to your `.bashrc`. I'm not sure of other platforms, sorry. I think its same for tcsh, dash, ksh etc

	if [ -f ~/.bash_aliases ]; then
		. ~/.bash_aliases
	fi

Now all this to `~/.bash_aliases`

	# git aliases

	alias gs='git status '
	alias ga='git add '
	alias gb='git branch '
	alias gc='git commit'
	alias gd='git diff'
	alias go='git checkout '
	alias gl='git log '
	alias gk='gitk --all&'
	alias gg='gitg --all'
	alias got='git '
	alias get='git '
	alias gits='git status '

It saves you from typos like 'get' and 'got'. `git status` being the most common command is aliased to `gs` and `gits`

My favorite is `alias go='git checkout '`. When you want to go to 'master', you say `go master` or `go issue53`. I think it makes a lot more sense than `git checkout master` or `git co master`. 

Not enough, there is a special one. This one saves a lot of typing for less frequently typed commands or often ones like `g commit`

	alias g='git '

Add it to the previous list.

Here comes the problem. We are quite used to bash auto completion. Transformations like `git com<tab>` => `git commit` comes quite handy. It just wont work with `g com<tab>`. Hack bash again!!!

Add this to your `~/.bashrc`

	complete -o default -o nospace -F _git g

Aha, one more problem solved !!

Next trick is quite common and actually much cooler, because you don't have to type at all. You can edit the environment variable `PS1` in bash to change your primary prompt. We can add the current state of the git repository to the prompt. That means a lot less `git status` because you can just get the info from your prompt.

Here are 3 images.

#### Default prompt

![Default prompt](/img/git/default.png "Default prompt")

#### Prompt in a clean git working directory

![Prompt in a clean git working directory](/img/git/clean.png "Prompt in a clean git working directory")

#### Prompt in a dirty git working directory

![Prompt in a dirty git working directory](/img/git/dirty.png "Prompt in a clean git working directory")

The current branch is shown as `[master]` if pwd is a git tracked directory, else its just ignored. the `*` means the working tree is dirty, Ie, there is something that you haven't stashed/commited yet.

Add this to your `~/.bashrc` for the new prompt.

	function parse_git_dirty {
	  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo "*"
	}
	function parse_git_branch {
	  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)]/"
	}

	export PS1='\[\033[1;33m\]\w\[\033[0m\] [\T \d] $(parse_git_branch) \n -> '

I have always wondered why people put their name or the hostname in their prompt, unless they are 'always ssh' dudes, which most of us are not, the hostname is a quite useless thing wasting space. Also its multi-line, means you have more space to type commands. As a bonus it shows the present working directory and time also :)

I am in the middle of building something *awesome* with [git hooks](http://git-scm.com/book/en/Customizing-Git-Git-Hooks). This post will soon be 
updated with more stuff :)

Thanks to @jasim_ab for inspiring me to write this one :)
