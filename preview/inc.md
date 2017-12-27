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


# 2. A quick and dirty introduction to x86 assembly

Why would you bother learning assembly anymore? There are so many abstractions
between the user and the machine for a typical consumer app on the cloud that
it's often impossible to trace your code all the way down to the hardware and
really understand what's going on. I find it fascinating to dive deep and
understand the true cost of high level programming language features. For
example, there is no function call involved in a code like `(null? x)`. It
requires just one x86 instruction (light travels about 30cm in the time taken to
figure that out on my laptop) to compute the result and a few more to make a
Scheme Boolean result. You will be able to say precisely how much memory a
vector takes in memory or the overhead caused by the garbage collector or
function calls.

The easiest way to get started is to write some very simple C programs and see
the generated assembly.

Consider this C code.

```c
     1	#include <stdio.h>
     2
     3	int add(int a, int b) {
     4	    return a + b;
     5	}
     6
     7	int main(int argc, char** argv) {
     8	    int a = 10;
     9	    int b = 20;
    10	    return add(a, b);
    11	}
```

You can ask clang (or GCC, it accepts the same flags) to dump the assembly
generated.

```shell
$ clang  -S -masm=intel -o - foo.c
```

The generated assembly looks somewhat like this

```nasm
     1		.text
     2		.intel_syntax noprefix
     3		.file	"foo.c"
     4		.globl	add
     5		.p2align	4, 0x90
     6		.type	add,@function
     7	add:
     8		mov	dword ptr [rsp - 4], edi
     9		mov	dword ptr [rsp - 8], esi
    10		mov	esi, dword ptr [rsp - 4]
    11		add	esi, dword ptr [rsp - 8]
    12		mov	eax, esi
    13		ret
    14
    15		.globl	main
    16		.p2align	4, 0x90
    17		.type	main,@function
    18	main:
    19		sub	rsp, 24
    20		mov	dword ptr [rsp + 20], 0
    21		mov	dword ptr [rsp + 16], edi
    22		mov	qword ptr [rsp + 8], rsi
    23		mov	dword ptr [rsp + 4], 10
    24		mov	dword ptr [rsp], 20
    25		mov	edi, dword ptr [rsp + 4]
    26		mov	esi, dword ptr [rsp]
    27		call	add
    28		add	rsp, 24
    29		ret
    30
    31
    32		.ident	"clang version 5.0.0 (tags/RELEASE_500/final)"
    33		.section	".note.GNU-stack","",@progbits
```

Now this code sample contains more information than I should have put into
probably the first assembly code you are reading, but the good part is that it
covers most of what we need in just one example.

There are 16 general purpose registers on a modern Intel x86_64 CPU and they are
named RAX, RBX, RCX, RDX, RDI, RSI, RBP, RSP and R8-R15. These processors are
backward compatible to versions way before I was born. The 32 bit versions of
the same registers are named EAX, EBX etc and they occupy the lower half of the
64 bit register. E here stands for Extended because it extended the 16 bit
registers that predated them. The 16 bit registers can be accessed as AX, BX etc
and the lower and upper 8 bits of a 16 bit register like AX can be accessed as
AH and AL. Your shiny new machine can run 35year old 8 bit assembly just fine.

Some registers are reserved for specific purposes and we use 2 of them. `RSP` is
the stack pointer. `RBP` points to the base of the current stack frame. It took
me a long time to really understand x86 stacks. This ride is going to be a bit
bumpy but rewarding. The stack grows _down_ from a high address to a lower
address. An inverted gravity defying stack indeed! Since we have only a fixed
number of registers, we need the stack to store local variables and your
precious cat pictures. `RSP` points to the top of the stack or the lower most
address. You can allocate space on the stack by decrementing the stack pointer
like `RSP = RSP - 16`. Stack allocation and deallocation is a single numeric
operation and super fast. Local variables slowly grow the stack downwards and
when the function returns, we can quickly set RSP back to its initial value to
reclaim all the space in one go! There is no need for a garbage collector to
reclaim the space used by local variables after the function returns. C calls
them automatic variables.

**TODO:** Use the real line numbers than the sequence markdown generates. Be
explicit about the links.

1. The lines that start with a dot is a directive to the assembler. `.text`
marks the starting of the code section.

2. `.intel_syntax noprefix` denotes that we are going to use the Intel syntax.
   The other option is AT&T which I find ugly and counter intuitive.

8. Assembly code is a list of instructions and most of the mnemonics like ADD,
   RET, CALL etc are obvious. MOV instruction is used for moving memory. Fun
   fact: the instruction has so many variations that this single instruction is
   [turning compete][turing complete]. `mov dword ptr [rsp - 4], edi` moves the
   contents of the 32 bit register `EDI` into the memory location with address
   `RSP - 4`. The `[]` is an address dereferencing operator. Now you know where
   the pointer arithmetic in C comes from - there is hardware support to do it
   very efficiently. And now you know why you should avoid such low level memory
   unsafe languages - it's very easy to get this wrong unless you are really
   careful. This instruction roughly transalates to the C snippet `*(RSP - 4) =
   EDI`.

  > The generated assembly is slightly edited for clarity. Use the flags
  > `-fno-asynchronous-unwind-tables -fomit-frame-pointer` to generate code that
  > is easier to read.

_Exercises:_

1. Compare the code generated by GCC and Clang.
1. Drop the `-masm=intel` flag to generate AT&T syntax. This is the form the
   paper uses but I prefer intel.
1. Observe changes in generated code with varying optimization levels like
   `-O1`, `-O3` etc.
1. Read the assembly generated by larger C programs for other features like
   arrays, local and global variables, function calls etc.

















---

[chez]: https://cisco.github.io/ChezScheme
[paper]: http://scheme2006.cs.uchicago.edu/11-ghuloum.pdf
[r5rs]: http://schemers.org/Documents/Standards/R5RS
