---
layout: post
title: An Incremental Approach to Compiler Construction
---

I started working with a [paper][paper] of the same title by Abdulaziz Ghuloum a
couple of months ago. The paper takes an incremental pedagogical approach to
writing a small scheme compiler for x86. The author aims to "write a compiler
powerful enough to compile an interactive evaluator" for the same language used
to build it.

Unlike the traditional approach of starting with a full blown programming
language, we start with a very tiny subset of the language and incrementally
improve it one small step at a time. Every step yields a fully working compiler
for a progressively expanding subset of Scheme. Every compiler step produces
real assembly code that can be assembled and executed directly by the hardware.

I think its an exceptionally solid approach to write an educational compiler but
the paper alone isn't sufficient and I had to wade through tons of other
material to fill the gaps. I hope to write a series of blog posts explaining the
process in detail and improving in some key areas which troubled me when I had
to do this on my own. *You can consider this series to be an extended tutorial*
accompanying the paper.

To summarize, the goals are

1. A longer and easier introduction to the same idea with more material to make
   the learning easier. This is very much necessary for some sections like
   functions, closures and dynamic allocation.

2. A short and quick introduction to x86_64 assembly. Its easier to provide a
   short tutorial sufficient to understand the code rather than send the reader
   to a more comprehensive material elsewhere. We will use the relatively easier
   to read Intel syntax unlike AT&T notation used by the paper. We will focus
   exclusively on modern 64 bit architecture so that the code can be compiled on
   a recent Linux distribution without several old 32bit compatibility
   libraries.

3. The runtime representation of data in the paper is a clever hack but its much
   more complicated than it should be. I will stick with a simpler constant 3
   bit tagging scheme rather than the variable encoding used in the paper.
   Tagged pointers and heap allocation can be explained a lot easier with some
   diagrams.

4. A much cleaner and leaner test suite.

It might be a good idea to read the paper abstract now before proceeding ahead.

# 1. Constant factors

Think of writing a compiler for a language that accepts the number `n` as input
and generates a binary that exits with exit code n. That should be simple and
straightforward, right?

1. What is the format for executable binaries in Linux? Is that an ELF or a.out?
   How do you actually write that binary? Do you need a library or a hex editor?
1. If I copy over that binary to a Mac or BSD, will it work the same?
1. Is it statically linked or dynamic? Do we need glibc? What else do we need on
   the machine?
1. Do we directly generate the binary or generate assembly and convert that into
   an executable with something else?
1. Are there debuggers for assembly? How much assembly knowledge is required for
   this task?

Unless you do a lot of systems programming, I'm sure most of us wont know the
answers to all of these questions. But we haven't even started writing the
compiler yet! We start with a mix of C and asm to tackle some of these problems
to get the foundation right. Writing compilers need not be hard if we take the
right approach.

![Figure 1; XKCD style graph of y = mx + c](./y=mx+c.svg)



















---

[paper]: http://scheme2006.cs.uchicago.edu/11-ghuloum.pdf
