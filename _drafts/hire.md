---
layout: post
title: We want to hire ourselves
---

I want to talk about hiring biases.

I interviewed for Amazon last year. The interviewer asked me to build a service
which converted numbers written in digits like 76 to it's long form, Seventy
Six. Now you can take this problem in several directions, but the only thing
they wanted out of me was to say that parsing the input depends on a locale and
I need a 'ParserFactory' which takes the locale as input. Now for a mediocre
programmer who has never programmed in anything other than Java his entire life
(I looked him up on LinkedIn and Github), knowing about those silly design
patterns is of paramount importance. How can you call yourself a programmer if
you don't know Java design patterns? He wouldn't have hired me even if I had a
Turing award in some other domain.

Most Amazonians I met during the interview process wanted me to solve one of
those algorithm puzzles you find on geeksforgeeks.com. Someone wanted me to find
the volume above weird shaped tumblers. What I saw and felt there is an ego echo
chamber. All of those programmers (I'm not generalizing all programmers at
Amazon, only the ones I met) are there because they spent hundreds of hours
solving silly puzzles and now they can't even see programming beyond that. You
are judged based on what they are good at and what they think is important even
though it is a useless skill for the job.

I recently interviewed for Myntra. One of the interviewers wanted me to print a
matrix in a spiral and find the longest common sub sequence in 2 strings. Easy.
He was a young programmer and probably practiced those programs recently so he
considers that to be most important thing someone should know. Another
interviewer wanted me to come up with a silly scheme to change password hashing
scheme in the login flow. I'm now fairly certain that they did this recently and
he just wanted to validate the silly hack from someone else.

"If you have to ship an API in 2 weeks, but if your colleague needs months to do
his part, how will you resolve the conflict?" Question is courtesy Myntra - one
among the several dozens of behavioral questions. Someone considered fine
bureaucratic escalation dance important. I've had to deal with negligible
management overhead in all the startups I've worked for and didn't have the
slightest clue how to answer that question _correctly_.

We consider the things we know to be most important traits to look for. Any
company that does this for a long time is unknowingly reducing the diversity of
the team one candidate at a time.

Now why am I talking about this? I've had an order of magnitude more resume
rejections than anyone else I know. I've [written][rejections] about some of
them in the past, but this is different. I consider myself a fairly competent
programmer and I was just genuinely trying to understand why I didn't get some
of those jobs.

I _believe_ a good number of them didn't want to hire me because they didn't see
much in me which they could relate to. Let's look at my [resume][resume] for a
moment. Almost all my side projects in the recent past are in Haskell, and if
you have never dabbled in functional programming, Haskell knowledge is not
something you will ever appreciate. Most programmers wouldn't have read a single
paper in years and running a [Papers we love][pwl] chapter is not something they
will value at all. I've been spending a lot of time writing [compilers][inc],
[and][olifant] [interpreters][lisper]. I know less than 5 people in my friend
circle who can understand even a bit of x86 assembly and it is very hard for
most people to see why I get excited about it. None of the people who have ever
interviewed me (except maybe Saju) would have cared for any of that. None of
them understood why I had to run away to [RC][rc] from a mediocre job.

If you remove Functional Programming, Haskell, Compilers, type systems and all
of that, there is not much left in my resume. This might able be why I never
even went past recruiters at Uber, Flipkart and InMobi. All of this doesn't mean
I won't be able to do the job well. I've built the usual suspects at all of my
previous jobs. I've inherited very poorly written REST API servers, improved and
built on top of them several times in the past.

I acknowledge that I'll fall for this too. I'll get excited and jump on the
couch if someone starts talking about compilers to me. But let's take a moment
to listen to the other side of the story next time we interview someone. Let's
look at code on Github to see how well someone can code rather than what you ask
them to write on a paper or google docs under pressure. Let's acknowledge that
they might not have seen Dijkstra's shortest path algorithm in years and it's
ok. Give the odd one out a chance. We might see the biases clearly if we were
forced to write down concisely why we _didn't_ each candidate we met.




[inc]:         https://github.com/jaseemabid/inc
[lisper]:      https://github.com/jaseemabid/lisper
[olifant]:     https://github.com/jaseemabid/Olifant
[pwl]:         https://paperswelove.org
[rc]:          https://recurse.com
[rejections]:  /2016/11/30/rejections.html
[resume]:      /Jaseem Abid.pdf
