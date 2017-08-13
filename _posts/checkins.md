### May 22

#### Plan

I want to start things off by starting with a very simple compiler. I'm mostly
interested in the backend/optimizations/code generation part of it, so I'll try
to keep the frontend really tiny.

This is the plan of action.

1. Pick the simplest front-end, which might be lambda calculus or forth. Don't
   waste much time here.
1. Pick a decent backend. LLVM might be the best choice because its rock solid,
   actually usable in the wild and has all the might of Apple behind it.
1. Start thinking about an IR.

First step? Learn LLVM

### May 23

#### Progress

Day spent reading various docs on LLVM

1. The LLVM intro docs are a bit dry and boring. Covered a bit of it.
2. The language reference will be handy when I need to look things up.
   [LLVM Language Reference Manual](http://llvm.org/docs/LangRef.html)
3. Kaleidoscope tutorial seems like the canonical place to start, but the code
   is terrible. The [python port](https://github.com/eliben/pykaleidoscope)
   could be more useful. I'm about half way though.
4. Working through Stephen Diehl's Haskell version might be the best thing to do.
   [Implementing a JIT Compiler with Haskell and LLVM](http://www.stephendiehl.com/llvm/)

I got some advice that one of the best ways to learn might be to read through
the generated code for simple C source code, so I'm going to give that a try as
well.

Read through some of the vd source by Saul.

Pairing with Trent and Andrew reminded me how little asm I know and I need to
brush up.

Went to the ML paper reading group and felt stupid :)

#### Reading list

1. [ ] [Embedded Security CTF](https://microcorruption.com/login)
1. [ ] [Articles in tag "LLVM & Clang"](http://eli.thegreenplace.net/tag/llvm-clang)
1. [X] [Static single assignment form - Wikipedia](https://en.wikipedia.org/wiki/Static_single_assignment_form)

#### Plan for tomorrow

Continue with the same reading list.
Attend the vd workshop by Saul

### May 24

#### progress

1. Paired with Dom on some ASM bits, there is quite a lot to learn here.
2. Worked though another chapter of Kaleidoscope
3. Figured out SSA - neat idea
4. Worked through the PWL paper, attended the meetup

#### Reading list

-  [ ] [Using as](https://sourceware.org/binutils/docs/as/)

### May 25

Recovering from a shitty hangover.

I could go down 3 paths right now

1. Kaleidoscope; the 'build a simple language in llvm' tutorial
2. LLVM. Work with the manual, Clang output etc to get a better grasp of the
   language
3. x86 assembly.

Plan for the day: work through Kaleidoscope as much as I can. Avoid
distractions. Refer the llvm manual for concepts that aren't clear.

### May 26

Progress is not as great as I'd love it to be. Continue with the same agenda as
yesterday.

Stay focused!

#### What did I do?

1. Paired with Dhanush on LLVM IR, learned a lot.
1. Compiled a bunch of simple C programs and read through the generated code.
1. Whiteboard discussion about allocators with Timm and Dhanush
1. Managed to read through a lot of llvm-hs source. A bit hard to follow some of
   the details and its not the best Haskell code.
1. Attended the first Haskell meetup. Volunteered to help the group go through
   the book.
1. A nice dinner with 9 fellow RC folks :D

### May 27

First weekend is here. Should do the chores like cleaning up the home and
laundry. Other than that,

1. [X] Setup ledger, see where the expenses are going
1. [X] Setup pass on phone and laptop

### May 29

Monday!

I should start writing some code rather than read through more manuals. Not sure
where exactly to start. Lisper maybe?

#### Progress

Finally started writing some code rather than read through even more LLVM
manuals and made some decent progress. Paired for about 5hrs with Veit and it
was super productive. Thank you Veit! :D

I'm generating some shitty LLVM code now, but its still something. Wil debug and
clean up tomorrow.

#### Reading list

1. Alexis Beingessner's thesis on ownership in rust; "You can't spell Trust
   without Rust"

### May 30

Managed to get Olifant generate the LLVM module, but the code generation is
going wrong somewhere.

Pushed everything to Github.

Paired with Tim and clarified some of the AST bits that were confusing to me.

Paired with Dhanush on his shell for a while, looking at memory leaks.

### May 31

#### Plan for the day

Oliphant (I named the project after the horn) is running into some wierd code
generation issues. In the meanwhile, I'm taking some time to clarify the Haskell
bits I'm not very sure about.

Must get the calc compile correctly today.

#### Progress

I managed to compile tiny numeric expressions into native LLVM code. Its VERY
minimal right now, but working with something that actually works feels a lot
better than just a few abstarct ideas in my head. Yay :D

Its so minimal that the only thing it can do right now is to compute expressions
and return the value. It can't even print them. You have to \`./calc\` and then
use the shell expression \`echo $?\` to see the output.

I'm going to take a break and work on Xmonad for a day or 2 now. Will get back
to this soon.

### June 1

#### Plan

Read through some good Haskell code; Xmonad maybe.

#### Reading list

On green threads

1. [ ] [Green threads explained (intro)](https://c9x.me/articles/gthreads/intro.html)
1. [ ] [Performance of green threads and why it matters - 250bpm](http://250bpm.com/blog:81)
1. [ ] [Comparing Elixir and Go](https://blog.codeship.com/comparing-elixir-go/)

X window programming

1. [ ] [X window programming in Haskell - HaskellWiki](https://wiki.haskell.org/X_window_programming_in_Haskell)

On Haskell

1. [ ] [A Haskell Compiler](http://www.scs.stanford.edu/11au-cs240h/notes/ghc-slides.html###(1)) <- Slides by David Terai

#### Updates

1. Spend the first few hours of the day with XMonad/Xmobar, but that wasn't
   very productive.
1. Discussed with Rudy and Sam Patterson about various green thread
   implementations. Learned a whole bunch of new things.
1. Convinced Trent (maybe? :)) to give Haskell a try.
1. Spend the evening reading 'TAPL' and decided that I'll pick a slightly
   modified lambda calculus as frontend for my compiler. There is a lot of
   compiler tricks I can do there. I could even write a blog about the plan.
1. Discussed with Dhanush and Tim about lambda calculus. I think I finally get
   this.

### June 2

Compile a reasonably larger lambda calc AST to LLVM. Hide in a corner and get
some work done!

### June 5

#### Olifant, plan of action

1. [X] Added a very rudimentary frontend and CLI interface.
1. [X] Need tests. Things are starting to take shape
1. [ ] Expand AST to rest of Lambda Calculus
1. [ ] Write down issues with the LLVM bindings.
1. [ ] Thought and brainstored a lot with a couple of people about the added
   advantage of a simpler custom IR. I think I'll give it a try.
1. [ ] Added local variables to Olifant. Learned a bit about how the memory is
   managed for such local values.

#### Reading list

1. [ ] Watch [Next Level MTL - George Wilson - BFPG 2016-06 - YouTube](https://www.youtube.com/watch?v%3DGZPup5Iuaqw)
1. [ ] [Haskell for all: Why free monads matter](http://www.haskellforall.com/2012/06/you-could-have-invented-free-monads.html)
1. [ ] [Tweag I/O - A new ecosystem for Haskell: the JVM](http://www.tweag.io/posts/2016-10-17-inline-java.html)
1. [ ] [Network Protocols - Programmer's Compendium](https://www.destroyallsoftware.com/compendium/network-protocols?share_key%3D97d3ba4c24d21147)

#### Issues with the library

1. Records share the same fields, causing import conflicts. Will
   OverloadedRecordFields help? OverloadedRecordFields (actually DuplicateRecordFields )
2. Not as type safe as I'd love it to be.
3. Lack of a **good** pretty printer

### June 6

#### Reading list

-  [ ] <https://en.wikipedia.org/wiki/Lambda_lifting>
-  [ ] <http://matt.might.net/articles/closure-conversion/>
-  [ ] <https://wiki.haskell.org/Lambda_lifting>
-  [ ] Paper: [Generating Pseudo-random Floating-Point Values](file:///home/j/Library/Math/downey07randfloat.pdf)

#### Progress

I'm a bit lost in some of the details. Focus

### Jun 8

Last couple of days were not as productive as I'd like it to be. I got stuck
with various issues, had to learn, unlearn and relearn lot of things, and
sometimes I got stuck and I don't even know why.

Olifant is trying to compile a lambda calculus like language into LLVM. I've
been writing this code in Haskell and the Haskell bindings are kind of ugly. The
basic idea is to walk over the AST and produce a huge hairy blob called
LLVM.AST.Module; which you can give to the LLVM C++ API to generate the IR;
which eventually can be compiled down to machine code.

One of the core ideas of Haskell is type safety. The type system should make it
impossible or at the very least hard to represent illogical programs. This
library fails miserably at it. So quite often the LLVM blob I generate is non
sense. The compiler errors from this module object is quite useless and I ended
up picking a pretty printer library to print the LLVM IR without going though
the real compiler. This approach worked in the beginning and helped me make some
progress, but soon it turned out to be a poorly designed library as well. It
crashes for way too often to be of any use. I spend (wasted?) a good part of the
day trying to fix the library, wrote a patch just to realize that someone opened
a very similar PR just 2 days ago.

I spend the rest of the time reading Humans of NY.

### Jun 9

I could stay away from LLVM for a day or 2 and start with transformations in a
higher level representation to a lower level IR completely under my control.

I could also work a bit more and understand symbol tables before I move on with
the design of the IR.

#### Reading list

1. [ ] <http://www.memorymanagement.org/>

### Jun 12

#### Tech:

Spent a lot of time in the last few days thinking about an intermediate IR for
my compiler and I got carried away by very little nuances of it. I'm starting to
get some more clarity on the problem now. Made some progress over the weekend
and today morning. I keep saying 'Not all those who wander are lost' to myself
once in a while.

Ref: <https://en.wikipedia.org/wiki/All_that_is_gold_does_not_glitter>

#### Health:

I should learn to type properly. After years of avoiding it, I think its
starting to hit me. Occasional pain in the hands.

#### Personal:

Spent the Saturday at NLPL rose reading room. New Yorkers, please don't take
that amazing institution for granted. Its glorious beyond words. I felt this
crazy responsibility to be super productive in an environment like that. I'm
planning to spend at least one day a week working from the NYPL main branch on
42nd street.

Spent Sunday at Museum of Natural history, the apple store, steps of the Lincoln
performing center etc with Stefan and Tim. Thanks for the lovely conversation
folks! It gets a bit lonely here away from friends and family and loved ones and
you all are filling the gaps nicely.

Plan for the day:

Should stop working with the low level code generator and start with much more
interesting program transformation techniques.

### June 14

Spent the day at NYPL

### June 15

I cant think of anything more annoying than learning to touch type __properly__,
switching from a laptop keyboard to kinesis and emacs -> spacemacs at the same
time. This is frustrating and hard!

I spent the day at NYPL yesterday and managed to get the frontend for the
compiler working. It can compile simple small expressions to an AST I'm calling
Calculus. I'm planning to spend the day either polishing some of the low level
code generation bits or transformations from the higher level AST to the lower
one.

The code is in a decent shape now and I'd love to pair on this with someone else
for a while. cc: Tim Babb Ethan Raymond. If anyone is interested in fiddling
with compilers in Haskell, please join. There are a lot of interesting sub
problems.

Hands don't hurt anymore and I can type. Avoiding funky key chords helped a lot.

:<3:

Paired with Ethan on making the code generator understand binary types. It was a
very productive session.

Paired with Tim on his visual editor. Wrote some JS again after a long time.
Happy that I don't do it anymore.

### June 23

Taking a day off today. Semi burned out. I should be OK by tomorrow. Didn't
really do anything other than work during last 2 weekends.

Dhanush and I are going to MoMA by ~4pm. Friday entry after 4pm is free. Please
join us if interested.

### July 5

Start of the second half, should be a lot more regular with check-ins now!

Finished off the blog post on Olifant and felt great. It took a lot of effort,
but it feels worth it now that a lot of people are reading it and giving me
positive feedback.

### July 6

Had a very productive pairing session with Dan Luu in the morning. Should do a
lot more reading about the related topics to solidify concepts.

Got a very simple form of FFI working in Olifant and felt awesome. I can call
this a neat milestone.

Made some progress with the book I'm reading, 'The underground railroad' by
Colson Whitehead.

### July 7

Reached RC by 6:30pm and I'm not in a mood to work.

Read through
the [ELF format](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format)
and some related documentation. This is interesting. Also learned that a.out
file is usually not in a.out format but ELf these days.

#### Things I should do soon

1. [X] Fix my tmux setup right (copy paste is broken since I moved to linux)
1. [ ] Work though the cache code and understand it better
1. [X] Read through the ELF stuff
1. [ ] Learn some Rust
1. [x] Apply for the rust outreach program

### July 8

Explored the financial district and took a ferry to Staten Island and back.
Should do more of it.

### July 9

1. Finished 'The underground railroad'
1. Spent a lot of time at Central Park and walking around mid town
1. Went for the Westerlies + Sarah Kay show and loved it

### July 10

1. Woke up at ~4am and I've no idea how or why. Reached RC by ~8am
1. Talked to Wesley about using a combinatorial style parser for his ELF parser.
   Or maybe Erlang style pattern match.
1. Fixed hexchat. Might get active with a couple of IRC channels. #haskell,
   #archlinux and #xmonad maybe
1. Fix the rest of the parser. Arity, precedence and infix ops

### July 11

Terrible day. Ended up staying awake till ~10 in the morning working on Olifant
because I couldn't sleep. Felt terrible and then took a day off and stayed away
from computers and went to the library with a book instead. My sleep patterns
are becoming extremely random and erratic and messed up. I might have to go back
to pills and I really don't want to.

### July 13

Late start due to all the beer last night. Didnt get any work done most of
evening due to game night and even more beer.

Managed to learn some assembly in the little bit of time I could concentrate and
put that all on github.

### July 14

Melatonin seems to be having a good effect on me. Much more regular and better
sleep.

I hope to tinker a bit more with x86 assembly today and try to port some of the
code Dan Luu wrote to figure out cache sizes into assembly from C. I've been
hoping to learn this for a long time and is happy with all the things I've found
so far.

Paired with Lee Haugen on some algorithms in the morning. I've forgotten a lot
and needs a refresher.

Setup hexchat, I guess I'm going back to the IRC days.

Managed to read through a lot more assembly and made some decent progress.

I hope to read a some good C code to learn it better. My candidates were redis
and jemalloc. Maybe git. Marcus suggested sqlite.

Had a very interesting conversation with Marcus on our way to lunch and we made
this small list of things which we don't know the answers for.

-  Who sets up the interrupt table?
-  When is the table setup?
-  How does OS preempt processes?
-  What does the linker even do?
-  Sqlite jemalloc redis as code samples
-  Does slab allocator compact stuff?
-  Relocatable slab?
-  Print hardware int table
-  Did kernel break userspace before? Examples?
-  Number of linux syscalls as of now? The recent ones?
-  C long jump vs short jump

### July 17

1. Woke up pretty late and then had a lazy start on top of that. Lost quite a
   lot of time
1. Finally went bouldering and it was super fun
1. I think I'm finally out of the asm rabbit hole
1. Started learning some rust

### July 18

1. Got my book 'Emperor of all maladies' signed by the author. Happy!
1. I've been very confused and lost about my career prospects and I really don't
   know how to proceed forward. I'm a bit too pessimistic here.
1. Made some progress with rust and really liked most of it. This is really
   interested stuff!

### July 19

1. Paired with Evan and helped him fix his website deployment script
1. Worked with Dan Luu on some more micro bench marking. Aggressive CPU scaling
   might be the factor that makes some programs run slower on my machine. But
   great battery life FTW!
1. Met Nancy and she helped me think a bit more sanely about job search. Thank
   you. :heart:
1. Went to Papers we love. It was great as usual.
1. Got an introduction to an Engineer and 2σ and we talked for a while. I think
   it went good. Should prepare for an interview.
1. Great beer at Houston Hall.

### July 20

1. I should work on my resume and spend some time evaluating a few jobs that
   look interesting.
1. Read some of the chrome tabs that are open since weeks.
1. Deal with the unnecessary evil of hacker rank and  some algo preps

1. Went through the RC jobs directory and narrowed down to 9 companies that
   look interesting. All have offices outside US (obviously) and some of them
   are remote friendly.

- Digital Ocean
- Dropbox
- Heap
- JaneStreet
- NS1
- Stripe
- Spotify

### July 27

Last couple of days were pretty productive; I ended up doing some huge
refactoring on Olifant.

Hans Zimmer yesterday. Definitely an unforgettable experience.

All the conversations with Marcus was massively helpful. It helped me clarify
ideas a lot.

Paired with Dhanush on some Erlang. Its so nice to work with Erlang after such a
long time.

Paired with Stefan again and we found and fixed some tiny bugs. Explained most
of my code to him. We hope to pair tomorrow.

Oliver Wyman interview tomorrow morning. All the best to me. Sleep well; or you
wont wake at 11.

### July 31

Had great weekend after a while because my friend visited and I didn't touch my
laptop. I took some more time off and watched 2 movies. Feeling a lot better
today.

The last couple of working days were productive too. Made some progress with my
compiler, make C FFI work etc. If anyone wants to pair on it, please get in
touch. The code is pretty simple and is in a reasonably good shape.

I had an interview with OW and it didn't go as good as I wanted it to be. I'm
going to take some time preparing for interviews and make sure I don't blow up
anything after this.

### Aug 2

Went to the library and worked through the first 8 chapters of 'Programming
Pearls'. I'd say that was reasonably productive.

Back to RC by about 5. Fiddled with the allocator a bit. Read a chapter or 2
from the Linux programming manual.

Calling it a day early and leaving now. I should get out of RC a bit more.

### Aug 3

Stayed away from RC because I don't want to be anywhere close a job fair. Its a
painful experience to be in the middle of it.

Went to the NYPL instead and worked through a few more chapters of programming
pearls. Read through the nanopass paper again, much more seriously this time.

I only worked for about ~4hrs, but felt that it was a really productive day, so
I walked around midtown for the next couple of hours. Went to Rockefeller and
sat there for a few hours. Spend almost an hour inside the St Patrick's
cathedral.

### Aug 9

Lock picking workshop. Yes, you heard that right.

### Aug 10

Final check in. That sucks.

RC was definitely the most productive 3 months of my life. I learned more about
life, programming, humility, people and the world in this sweet short time than
any other time I can remember. I enjoyed almost all of this so much and it would
be such a shame to not shout it out aloud.

I think I made some decent progress on my compiler. I can certainly look at any
other personal projects that I've ever worked on and confidently say that I've
done better and improved myself; but this is not the time to talk tech.

I will miss all the amazing people I met here and I wish I could spend a lot
more time with each one of you. It was so much comforting to not be the only guy
with crazy ideas. Life is so much easier when you are not the odd one out and I
will miss that feeling the most. I will miss the feeling of belonging somewhere.

I hope I'll be able to stay motivated and keep learning even after I leave this
building. Never graduate!
