class: center, middle

# Incremental approach to compiler construction

### Jaseem Abid

---
class: center, middle

# Let's build a compiler even if you know nothing about it

---
class: center, middle

# Incrementally

---
class: center, middle

# Agenda:

## Build a compiler for a small subset of scheme by the end of the talk

---
class: center, middle

# Abstract:

> Real-life compilers are too complex to serve as an educational tool. And the
> gap between real-life compilers and the educational toy compilers is too wide.

---
class: center, middle


> We show that building a compiler can be as easy as building an interpreter.

---
class: center, middle


> The compiler we construct accepts a large subset of the Scheme programming
> language and produces assembly code for the Intel-x86 architecture

---
class: center, middle


> Every step yields a fully working compiler for a progressively expanding
> subset of Scheme. Every compiler step produces real assembly code that can be
> assembled then executed directly by the hardware.

---
class: center, middle

# :)

---
class: center, middle

# The simplest language in existence

---
class: center, middle

# exit 1

---
class: center, middle

# 0 or 1

---
class: center, middle

# The constant factors

- exit codes
- glibc
- object files
- main
- elf
- argc and argv
- executable
- process life time
- linkers

---
class: center, middle

# Let's start by asking someone who knows how to do it

---
class: center, middle

# gcc!

---
class: center, middle

#  file 1.c

     1	#include <stdio.h>
     2	#include <stdlib.h>
     3
     4	int main() {
     5      exit(1);
     6	}

---
class: center, middle

#  $ gcc -S -O3 --omit-frame-pointer 1.c -o - | cat -n

     1		.file	"1.c"
     2		.section	.text.startup,"ax",@progbits
     3		.p2align 4,,15
     4		.globl	main
     5		.type	main, @function
     6	main:
     7	.LFB24:
     8		.cfi_startproc
     9		subq	$8, %rsp
    10		.cfi_def_cfa_offset 16
    11		movl	$1, %edi
    12		call	exit@PLT
    13		.cfi_endproc
    14	.LFE24:
    15		.size	main, .-main
    16		.ident	"GCC: (GNU) 7.1.1 20170630"
    17		.section	.note.GNU-stack,"",@progbits

---
class: center, middle

# Still a lot of things going on there!

---
class: center, middle

# Cheat a bit
---
class: center, middle

# scheme_entry
---
class: center, middle

# file 2.c

     1    int scheme_entry() {
     2        return 42;
     3    }

---
class: center, middle

# file 2.S

     1    scheme_entry:
     2        movl	$42, %eax
     3        ret

---
class: center, middle

# file 3.c

     1	#include <stdio.h>
     2
     3	extern int scheme_entry();
     4
     5	int main() {
     6      int val = scheme_entry();
     7      printf("%d\n", val);
     8      return 0;
     9	}
    10

---
class: center, middle

# ~

    $ gcc 3.c inc.s
    $ ./a.out
    0
---
class: center, middle

# BAM!

---
class: center, middle

# Step 0.

---
class: center, middle

# 24 more

---
class: center, middle

# Primiliminary issues

- Target audience
- What do I need to know?
- Source language
- Target language
- Development methodology
- Testing infrastructure
- End goal
- Talk POV

---
class: center, middle

# 1. Integers

---
class: center, middle

# 2. Immediate Constants

- Machine words
- Types must be available at runtime
- integer?, printf
- mask and tag

---
class: center, middle

# 3. Unary primitives

  - Primitives that accept one word
  - No need for a function call
  - Inline asm
  - inc, dec, int->char, zero?, null?

---
class: center, middle

# ???
