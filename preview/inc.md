---
layout: post
title: An Incremental Approach to Compiler Construction
---

I started working with the paper [An Incremental Approach to Compiler
Construction][paper] by Abdulaziz Ghuloum a couple of months ago. The paper
takes an incremental and pedagogical approach to writing a small scheme compiler
for x86 architecture. The author aims to "write a compiler powerful enough to
compile an interactive evaluator" for the same language used to build it.

Unlike the traditional approach of starting with a full blown programming
language, we start with a very tiny subset of the language and incrementally
improve it one small step at a time. Every step yields a fully working compiler
for a progressively expanding subset of Scheme. Every compiler step produces
real assembly code that can be assembled and executed directly by the hardware.

I think it is an exceptionally solid approach to write an educational compiler
but the paper alone isn't sufficient and I had to wade through tons of other
material to fill the gaps. I hope to explain the paper here in detail and
improve the narrative in some key areas which troubled me when I had to do this
on my own. *You can consider this blog to be an extended tutorial* accompanying
the paper.

To summarize, the goals are

1. A longer and easier introduction to the concepts explained in the paper. This
   is very much necessary for sections like functions, closures and dynamic
   allocation.

1. Provide completely functional code and a cleaner and leaner test suite.

1. Stick with [R5RS][r5rs] - a very simple and minimal scheme standard. The
   paper uses a lot of [Chez Scheme][chez] specific extensions, which is sub
   optimal. Removing some of the extensions like property lists on symbols make
   code easier to understand and using regular math symbols like `+` and `-`
   instead of `fx*` makes the code a lot more elegant.

1. Present the pearls in a better light. The runtime representation of data
   described in the paper for example is a clever hack but it is described in a
   way much more complicated than it should be. I will stick with a simpler
   constant 3 bit tagging scheme rather than the variable encoding used in the
   paper. Tagged pointers and heap allocation can be explained a lot easier with
   some diagrams.

1. A short and quick introduction to x86_64 assembly covering only the subset
   necessary to get started. Most of the resources online to learn assembly tend
   to be outdated and too much information to just get started quickly. We will
   use the relatively easier to read Intel syntax unlike AT&T notation used by
   the paper and focus exclusively on modern 64 bit architecture.

It might be a good idea to read the paper abstract now before proceeding ahead.

# 1. Constant factors

Think of writing a compiler for a language that accepts the number `n` as input
and generates a binary that exits with exit code n. That should be simple and
straightforward, right?

1. What is the format for executable binaries in Linux? Is that an ELF or a.out?
   How do you actually write that binary? Do you need a library or a hex editor?
1. If you copy over that binary to a Mac or BSD, will it work the same?
1. Is it statically linked or dynamic? Do you need glibc? What else do you need
   on the machine? Do you need a linker or assembler?
1. Do you directly generate the binary or generate assembly and convert that into
   an executable with something else?
1. Are there debuggers for assembly? How much assembly knowledge is required to
   get started?

Unless you do a lot of systems programming, I'm sure most of us won't know the
answers to all of these questions. But we haven't even started writing the
compiler yet! We start with a mix of C and asm to tackle some of these problems
to get the foundation right. Writing compilers need not be hard if we take the
right approach.

![Figure 1; XKCD style graph of y = mx + c](./y=mx+c.svg)



















---

[chez]: https://cisco.github.io/ChezScheme
[paper]: http://scheme2006.cs.uchicago.edu/11-ghuloum.pdf
[r5rs]: http://schemers.org/Documents/Standards/R5RS
