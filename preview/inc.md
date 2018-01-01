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
   paper. Tagged pointers and heap allocation needs a few good diagrams.

1. A short and quick introduction to x86_64 assembly covering only the subset
   necessary to get started. Most of the resources online to learn assembly tend
   to be outdated and too comprehensive to get started quickly. We will use the
   relatively easier to read Intel syntax unlike AT&T notation used by the paper
   and focus exclusively on modern 64 bit architecture.

It might be a good idea to read the paper abstract now before proceeding ahead.

# 1. Constant factors

Think of writing a compiler for a language that accepts the number `n` as input
and generates a binary that exits with exit code n. That should be simple and
straightforward, right?

1. What is the format for executable binaries in Linux? Is that an ELF or a.out?
   How do you generate that binary? Do you need a library or a hex editor?
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


# 2. A quick introduction to x86 assembly

Why would you bother learning assembly anymore? There are so many abstractions
between the programmer and the machine for a typical consumer application on the
cloud that it's often impossible to trace your code all the way down to the
hardware and really understand what's going on. I find it fascinating to dive
deep and understand the true cost of high level programming language features.
For example, there is no function call involved in `(null? x)` and it takes just
one x86 instruction to compute the result (light travels about 30cm in the
meanwhile). More insight into the lower layers of abstractions will help you say
precisely how much memory a vector takes or the overhead caused by the garbage
collector or function calls.

The most basic concepts we need to look at are registers, the common
instructions, the 86 stack, how the memory is addressed and function calls.

## Registers

Registers are memory that can be accessed very quickly by the processor. There
are 16 64 bit general purpose registers on a modern Intel x86_64 CPU and they
are named RAX, RBX, RCX, RDX, RDI, RSI, RBP, RSP and R8-R15. These processors
are backward compatible to versions way before I was born. The 32 bit versions
of the same registers are named EAX, EBX etc and they occupy the lower half of
the 64 bit register. E here stands for Extended because it extended the 16 bit
registers that predated them namely AX, BX etc. The lower and upper 8 bits of a
16 bit register like AX can be accessed as AH and AL.

< Figure x86 registers >

## Stack

The x86 stack is a large contiguous chunk of memory that is used for keeping
track of function calls, local variables and other state. Since we have only a
fixed number of registers, we need the stack to store your precious cat
pictures. Stack grows _down_ from a high address to a lower address in an
inverted direction and the `RSP` register or the stack pointer points to the top
of the stack. Even though we use the term top, it is the lower most address and
pushing a value to the stack decrements the value of the stack pointer.

< Figure x86 stack >

You can allocate space on the stack by decrementing the stack pointer like `RSP
= RSP - 16`. Stack allocation and deallocation is a single numeric operation and
hence super fast. Local variables grow the stack downwards and when the function
returns, we can quickly set RSP back to its value before the function started to
reclaim all the space in one go! There is no need for a garbage collector to
reclaim the space used by local variables after the function returns.

[Julia Evans][julia] as always wrote a [great introductory blog post][jvns
stack] on stack and the blog [Raw Linux Threads via System Calls][threads]
contains a lot of useful information. I've used similar examples here as well.

## Functions

x86 functions are quite unlike the counterparts in high level programming
languages. The way arguments are passed and the results are returned is called a
[calling convention][convention] and there are several of them. The [System V
AMD64 ABI][sysv] convention for example passes the first 6 arguments in
registers RDI, RSI, RDX, RCX, R8 and R9 and expects the return value in RAX. The
C calling convention (cdecl) at the same time passes all arguments in the stack.
As long as the function caller and callee agree upon a specific convention, we
are free to mix several of them however we want. Here is a short example as per
the Sys V convention.

```nasm
plus:
    mov rax, rdi
    add rax, rsi
    add rax, rdx
    ret

main:
    mov rdi, 1
    mov rsi, 2
    mov rdx, 3
    call plus
```

The plus function gets 3 arguments in registers RDI, RSI and RDX. RDI is moved
to RAX and the other 2 are subsequently added to it. The final result is left in
RAX before returning from the function.

## Memory addressing

If you are familiar with pointers in C, you should find this section quite
simple and straightforward. Contents at a specific address can be conveniently
accessed with the special syntax `[]`, very similar to the C dereferencing
operator `*`. To move the contents of address let's say 0x555532a to register
RAX, we can use the mov operator like `mov rax, [0x555532a]`.

It is quite common to operate on memory addresses relative to RSP which points
to the top of the stack. For example, `mov dword ptr [rsp + 20], 0` writes the
value 0 to an address 20 bytes below the stack pointer. Memory is most
frequently accessed with the mov instruction, but other instructions like ADD
can also use it directly using the same notation. There are several complex
addressing modes but we will need only a tiny subset here.

> Fun fact: The mov instruction has so many variations that this single
> instruction is [turning compete][turing complete].

---

The easiest way to get started is to write some very simple C programs and see
the generated assembly. Consider this example:

```c
{% include_relative sample.c %}
```

You can ask clang (or GCC, it accepts the same flags) to dump the assembly
generated.

```shell
$ clang -S -masm=intel -o - sample.c
```

The generated assembly looks somewhat like this

```nasm
{% include_relative sample.s %}
```

Now this code sample contains more information than I should have put into
probably the first assembly code you are reading, but the good part is that it
covers most of what we need in just one example.

Now to explain the sample code.

➊ The lines that start with a dot is a directive to the assembler. `.text` marks
   the starting of the code section.

❷ `.intel_syntax noprefix` denotes that we are going to use the Intel syntax
   instead of the AT&T style, which I find ugly and counter intuitive. There is
   an interesting comparison of the 2 styles [here][gas syntax].

❸ Declares a function called `add`. Directive `.globl add` makes the symbol
   global such that the linker can find it.

❹ Moves the contents of the 32 bit register `EDI` into the memory location with
   address 4 bytes below the stack pointer. This instruction roughly transalates
   to the C snippet `*(RSP - 4) = EDI`. The first argument to the function is
   being saved into the stack.

❺ Save the second argument in the stack.

❻ Moves the previously saved value from stack back to the register `ESI`.

❼ Add the contents of the register `ESI` and memory address `RSP - 8` and leaves
   the result in the register. Equivalent to `ESI = ESI + *(RSP - 8)`

❽ Values are returned to the caller by moving it to the `RAX` register.

❾ Return back to the caller.

❿ Allocate 24 bytes on the stack to hold the local variables.

⓫ and ⓬ Save the value of `a` and `b` to stack.

⓭ and ⓮ Copy the first argument to `EDI` and second argument to `ESI` before the
   function call as per the [Sys V][sysv] convention.

⓯ Call the function. The result will be available in `RAX` after the function
   call.

⓰ Reclaim the stack space used for local variables.

⓱ Return `RAX` from ⓰ back to the caller of main.

Phew! We covered a lot. Take a break. Breathe.

> The generated assembly is slightly edited for clarity. Use the flags
> `-fno-asynchronous-unwind-tables -fomit-frame-pointer` to generate code that
> is easier to read.

_Exercises:_

1. Compare the code generated by GCC and Clang.
1. Drop the `-masm=intel` flag to generate AT&T syntax.
1. Observe changes in generated code with varying optimization levels like
   `-O1`, `-O3` etc.
1. Read the assembly generated by larger C programs for other features like
   arrays, local and global variables, function calls etc.

---

[chez]: https://cisco.github.io/ChezScheme
[convention]: https://en.wikipedia.org/wiki/X86_calling_conventions
[gas syntax]: http://x86asm.net/articles/what-i-dislike-about-gas/
[julia]: https://jvns.ca
[jvns stack]: https://jvns.ca/blog/2016/02/27/a-few-notes-on-the-stack
[paper]: http://scheme2006.cs.uchicago.edu/11-ghuloum.pdf
[r5rs]: http://schemers.org/Documents/Standards/R5RS
[sysv]: http://wiki.osdev.org/System_V_ABI#x86-64
[threads]: http://nullprogram.com/blog/2015/05/15/
[turing complete]: https://www.cl.cam.ac.uk/~sd601/papers/mov.pdf
