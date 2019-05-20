class: center

# Incremental approach to compiler construction

### Jaseem Abid

---
class: middle, center

## Build a compiler for a subset of scheme
## by the end of the talk
## even if you know nothing about compilers

---
class: middle

> Real-life compilers are too complex to serve as an educational tool. And the
> gap between real-life compilers and the educational toy compilers is too wide.

---
class: middle

> We show that building a compiler can be as easy as building an interpreter.

---
class: middle

> The compiler we construct accepts a large subset of the Scheme programming
> language and produces assembly code for the Intel-x86 architecture

---
class: middle

> Every step yields a fully working compiler for a progressively expanding
> subset of Scheme. Every compiler step produces real assembly code that can be
> assembled then executed directly by the hardware.

---
class: center, middle

# 🎊

---
class: center, middle

# exit 1

---
class: center, middle

# gcc!

---

### $ cat 1.c

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    exit(1);
}
```

---

### $ gcc -S ... 1.c -o - | cat -n

```c
 1    .file   "1.c"
 2    .intel_syntax noprefix
 3    .text
 4    .section  .text.startup,"ax",@progbits
 5    .p2align 4
 6    .globl  main
 7    .type   main, @function
 8  main:
 9    sub   rsp, 8
10    mov   edi, 1
11    call  exit
12    .size   main, .-main
13    .ident  "GCC: (GNU) 9.1.0"
14    .section  .note.GNU-stack,"",@progbits
```

???

gcc -S -m64 -masm=intel -O3 -fomit-frame-pointer -fno-asynchronous-unwind-tables 1.c -o - | cat -n

---

### $ vi 1.s

```c
 1    .intel_syntax noprefix
 2    .text
 3    .section  .text.startup,"ax",@progbits
 4    .globl  main
 5    .type   main, @function
 6  main:
 7    sub   rsp, 8
 8    mov   edi, 1
 9    call  exit
10    .size   main, .-main
```

---
class: center, middle

# 🤔

---
class: center, middle

## scheme_entry

---
### $ cat 2.c

```c
int scheme_entry() {
    return 42;
}
```

---
### $ cat 3.c

```c
#include <stdio.h>

extern int scheme_entry();

int main() {
    int val = scheme_entry();
    printf("%d\n", val);
    return 0;
}
```

---
### $ cat inc.S

```c
1  scheme_entry:
2    mov	rax, 42
3    ret
```

---
class: middle

# exec

    $ gcc 3.c inc.s
    $ ./a.out
    42

---
class: center, middle

# 💥

---
class: middle

# The constant factors

- Conveniently hiding some OS details
- Link to glibc
- Process life time
- Avoid object files & ELF for now
- argc and argv
- IO
- linkers
- ...

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
