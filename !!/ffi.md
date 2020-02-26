---
layout: post
hidden: true
title: Foreign functions for fun and profit!!
---

⚠ This needs to be massively fact checked, needs examples for all things
mentioned and need several iterations and refinements. This is only draft 1.

---


Foreign functions are amazing - it's magical that you can call functions defined
in one language from another.

Operating systems like Linux manage access to shared resources like files and
network connections with syscalls and typically the API is exposed via the C
standard library. Almost all programming language standard libraries eventually
deep down end up calling into these functions via some kind of FFI[1]. You need
this to write any kind of interesting programs that is more sophisticated than a
desktop calculator.

I've been working on a toy scheme compiler for a while and wanted to figure out
how hard it would be to implement a very simple toy FFI model from scratch and
it turned out to be a lot simpler than I imagined!

To pick a specific example, we can look at how you can call into C/Rust
functions from Scheme even though they differ in so many ways like memory
management, alignment, type systems etc.

There are no functions in x86 assembly. All you have is registers, shared memory
(in the form of stack & heap) and labels you can jump to. So many things you can
take for granted and is implicit in almost all high level languages like
argument passing, return values etc are explicitly managed in assembly. This is
in part really tedious and error prone, but the flexibility also allows
compilers to implement very different programming paradigms on the same hardware
and often make them seamlessly cooperate.

In short, an FFI model either compiles down 2 different languages into the same
kind of assembly functions or add a layer of shim b/w the function calls[2].

< Show an example assembly function >

< Talk about calling conventions/ >

1. https://docs.microsoft.com/en-us/cpp/cpp/argument-passing-and-naming-conventions?view=vs-2019
2. Pick the old style vs fast call example from linux

< Show an example for both kind of calling conventions, real FFI examples>

< Back to scheme, show an example of reading a file >

```
            (let ((open-output-file (lambda (fname)
                                     (let ((fd (rt-open-write fname)))
                                      (vector 'port fname fd))))

                  (f (open-output-file "/tmp/inc/io.txt")))

             (writeln "hello world" f))"#;

```

Clean this up, focus on writeln

```
#[no_mangle]
pub extern "C" fn writeln(data: i64, port: i64) -> i64 {
    let path = str_str(vec_nth(port, 1));
    let s = format!("{}\n", str_str(data));

    fs::write(&path, s).unwrap_or_else(|_| panic!("Failed to write to {}", &path));

    NIL
}

```

Show writeln in rust!

1. Talk about the differences.

- file desciptors are numbers in C, a vector in scheme and a proper struct in
 Rust

-

```
   4   │     .globl "_init"
   5   │ "_init":
   6   │     push rbp
   7   │     mov rbp, rsp
   8   │     mov r12, rdi        # Store heap index to R12
   9   │     lea rax, [rip + 5 + inc_str_0]
  10   │     mov qword ptr [rbp - 24], rax
  11   │     call "open-output-file"
  12   │     mov qword ptr [rbp - 8], rax
  13   │     lea rax, [rip + 5 + inc_str_1]
  14   │     mov rdi, rax
  15   │     mov rax, [rbp - 8]
  16   │     mov rsi, rax
  17   │     sub rsp, 16
  18   │     call "_writeln"
  19   │     add rsp, 16
  20   │     pop rbp
  21   │     ret
```

This is the assembly for scheme, show how line 18 calls into _writeln.

Show how the arguments  are copied into the write registers and stack is
manually aligned in few lines above.


< Pick the assembly rustc generated for _writeln>

<Explain registers as global values >

<Show how the values we wrote from this side is read on the other side even
though its completely different compilers>

< Something something conventions and iterop>

< Demo! Print hello world or something!>

victory!








--


1: Make sure this is right, find examples for both cases. Look up at least what
Rust, cgo, Java and cpython is doing under the hood.


2: Same as 1, but link to https://blog.filippo.io/rustgo for shim exmaple


---

# Reading list


http://composition.al/blog/2018/03/31/four-kinds-of-talk-proposals-that-get-rejected-from-bangbangcon/
