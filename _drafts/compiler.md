---
layout: post
title: Lessons learned building a toy compiler
---

I've been working on [Olifant][olifant]; a compiler
for [simply typed lambda calculus][stlc] for last few weeks, and this is an
introduction to things that I learned along the way. Lambda calculus is an
extremely minimal formal system to study programming language theory and
computation in general. Olifant compiles a slightly modified form of lambda
calculus into [LLVM IR][llvm] and then to machine code which can be run
natively.

We tend to think of compilers as big black boxes which transform some high level
language, let's say C into a binary in one big step. I'd like to present it as a
pipeline of languages and transformations, each a bit simpler and slightly lower
level than the one before it; a complex compiler built out of a series of
transformations in which each of them is a simple independent [pure][pure]
function.

## The big picture

The language is called calculus and it looks like this.

    let id = λx:i.x; let k = 42; id k

`λx` is a function that takes one argument `x`. The `:i` indicates that `x` is
of type integer. Everything after the `.` is the body of the function and here
it is simply returning the argument. `id k` is a function application with a
single argument `k`. Calculus is a fairly simple language. A program is a series
of function or variable declarations (also called let bindings) and one
expression in the end. The result of the expression is returned from the program
as the exit code.

The LLVM IR is a language low level enough to be close to metal but still
expressive enough to describe a lot of high level features without too much
verbosity. Targeting LLVM IR instead of x86 assembly turned out to be a very
good idea in retrospect. It is best thought of as a high level machine
independent portable assembly. It is an excellent tool chain for compiler
authors with great tooling, descriptive error messages, blazing fast performance
and sophisticated optimizations built in. See the [language reference][ll-ir]
for a detailed description or follow along for simple examples.

Calculus can be compiled into LLVM IR with the olifant compiler

    $ echo 'let id = λx:i.x; let k = 42; id k' | olifant

This is the equivalent LLVM IR

```llvm
; ModuleID = 'calc'

@k = global i64 42

define i64 @id(i64 %x) {
entry:
  ret i64 %x
}

define i64 @main(i64 %_) {
entry:
  %0 = load i64, i64* @k
  %1 = call i64 @id(i64 %0)
  ret i64 %1
}
```

The llc compiler can compile the IR into an executable binary and optionally
apply several optimizations with fine grained control and provide the machine
assembly. Using clang is even simpler

    $ clang sample.ll -o sample
    $ file sample
    sample: ELF 64-bit LSB executable, x86-64, version 1 (SYSV),
    dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2,
    for GNU/Linux 2.6.32, not stripped

The language is so small; it can't even print the result to the terminal yet :)
The return value of a program can be fetched using bash special variables.

    $ ./sample
    $ echo $?
    42

## Parser

The quintessential first step in any compiler is parsing the source string into
an [Abstract Syntax Tree][ast]; which is just a convenient data structure to
work with rather than raw strings. Olifant uses the venerable combinatorial
parsing library [Parsec][parsec] and the
paper [Monadic Parsing in Haskell][paper] is a beautiful and simple introduction
to the subject.

Consider a very simple language with just numbers and addition. AST for such a
language can be described very elegantly with the following Haskell type.

```haskell
data Expr = Number Int | Plus Expr Expr
```

A sample program like `6 + 4` can then be parsed into

```haskell
Plus (Number 6) (Number 4)
```

The Calculus is so small, it's type can be represented in just a few lines of
Haskell. All Haskell code examples are for illustration purposes and it is not
strictly necessary to understand it to read further.

```haskell
data Calculus =
    Var Text
  | Number Int
  | Bool Bool
  | App Calculus Calculus
  | Lam Text Tipe Calculus
  | Let Text Calculus
```

Calculus is partly typed. Function arguments are type annotated and the rest of
it can be inferred (more on this shortly). The parser is reasonably straight
forward and is only about 100 lines of very well documented [code][parser]. It
is very lenient in general and can only report syntax errors, like `let a =;`
and won't care about an undefined variable.

Parser parses the input expression `let id = λx:id.x; id 42` into

```haskell
[
    Let "id" (Lam "x" i (Var "x")),
  , App (Var "id") (Number 42)
]
```

The 1-1 correspondence between the source language and the Calculus type is
intentional.

## Core

The second language we describe is called Core and is very different from
Calculus. The [BNF][bnf] grammar for Calculus is beautifully recursive but Core
clearly distinguishes what is allowed at the top level vs inside a nested
expression. For example, functions can be defined only at the top level of Core,
but they are allowed anywhere in Calculus. *The limitations might seem arbitrary
and unnecessarily crippling, but it makes subsequent analysis and code
generation much simpler*.

The Core is statically typed with the type of every expression known at compile
time.

```haskell
data Tipe = TUnit | TInt | TBool | TArrow Tipe Tipe
```

An `Expr` is a nested core expression.

```haskell
data Expr
    = Var Ref
    | Lit Literal
    | App Tipe Expr Expr
    | Lam Tipe Ref Expr
```

A let binding is a top level expression of the form `let <name> = <expr>`

```haskell
data Bind = Bind Ref Expr
```

A program is a list of bindings and a terminating expression

```haskell
data Progn = Progn [Bind] Expr
```

## References

Before we move on further, we need to talk about one of the most commonly used
types in Olifant, `Ref` used to represent a variable.

```haskell
data Ref = Ref { name :: Text
               , raw   :: Text
               , tipe :: Tipe
               , scope :: Scope}
```

One of the interesting things I learned about compilers is that a symbol table
is often unnecessary. Typically a symbol table is a mapping from a variable name
to the properties of it like the value, type and the line number it was defined.

Quoting [AOSA § No Symbol Table][aosa],

> In GHC we use symbol tables quite sparingly; mainly in the renamer and type
> checker. As far as possible, we use an alternative strategy: a variable is a
> data structure that contains all the information about itself. Indeed, a large
> amount of information is reachable by traversing the data structure of a
> variable: from a variable we can see its type, which contains type
> constructors, which contain their data constructors, which themselves contain
> types, and so on.

I find this approach fundamentally simpler and a natural way to think in a
purely functional programming language. Rather than represent a variable with
just a string and maintain a shared mapping from the name to all important
attributes, we use a rich type called `Ref` to embed all the attributes in
itself. Each pass of the compiler can augment and annotate more information into
the reference accordingly. Large parts of the program become inherently
stateless and simpler.

## Cast

Casting is applying the minimum transformations on calculus to get core and is
the immediate step after parsing. Cast does basic structural validations and
ensures that the program is a series of declarations and an expression in the
end. All known types (only function arguments for now) are retained and the rest
of them are explicitly marked to be of `unit` type (think of Java's Object).
Types of literal values are inferred here. Cast either returns a Core expression
or raises a syntax error.

## Rename

Core to Core transformations in general preserve semantics but simplify them for
further transformations and code generation. The rename phase rewrites variable
names to avoid runtime ambiguity and shadowing and eliminates the need for
complex symbol tables. The program `let x = 1; let id = λx.x` uses the variable
`x` twice, but they are in no ways related. It is equivalent to `let x = 1; let
id = λy.y` but is simpler in a way that transformations after renamer can be
sure that variable references are globally unique and there is no need to deal
with name collisions.

The user defined name of the reference is preserved in a `Ref` as `raw` and a
new globally unique name is chosen (called name) is used from then onward.

It is an open question if the two approaches are the same and I haven't figured
out the answer yet.

## Type inference

Type inference for a language with some type annotations and
no [polymorphic types][poly] is reasonably straightforward and easy, and I
decided to let go some expressive power (read generics) to keep things simple.

A polymorphic type or a type variable is to a type what a variable is to a
value. You describe the properties of an item from a set and it takes a concrete
value at runtime. For example, the identity function in Haskell has the type
signature `id :: a -> a`, which can be read as a function that takes a value of
polymorphic/generic type a and returns another value of type a. At runtime `a`
gets a concrete value like Int or String, and polymorphic types let us work with
a set of types in a generic way. tldr; I don't have polymorphic types yet.

Complete type inference is possible for a language with polymorphic types even
without any user annotations with a very well known algorithm
called [Hindley-Milner][hm] and its a bit tricky to get right. In the meanwhile,
we can use a much simpler algorithm.

Instead of getting into the formal model, the algorithm can be explained using a
simple heuristic. The problem is to find the type of each expression in the
program without the user explicitly annotating everything. Think of the `auto`
keyword in C++. The idea is to discover that the language can introduce a new
variable in only 2 ways, function arguments and let bindings. As long as all the
parameters of the function are annotated, the information can be used in the
body of the function and need not be repeated. The type of a variable introduced
by let binding can be inferred from the right hand side of the equation, which
is either a term constructed with known types or a type error. Types of literals
line numbers, booleans and strings are obvious after parsing. In practice this
approach worked really well for Olifant.

## Code generation

The code generator accepts a well typed Core as input and generates LLVM IR.
This module took me the longest to write, test and then rewrite several times.

I had to spend a lot of time learning the LLVM nuances and fight with the
Haskell API before things started working.
The [Haskell bindings for LLVM][llvm-hs] provides a thin API around the C++ API
and it is nowhere close to typesafe, so the usual Haskell magic of 'if it
compiles, it works' wasn't applicable at all. I took so many failed approaches
before I settled down with what I have right now.

The basic idea is to initialize a [module][module], and to populate it with
definitions as you traverse the AST. A module contains a list of global
definitions and each function or global variable is translated into one. Global
definitions are composed of blocks and a block constituents of a logical unit
before a branch instruction like a conditional or function return.

The [code][gen] is not hard to understand but uses some reasonably advanced
Haskell machinery like monad transformers to stay clean and maintainable. The
LLVM IR is printed to stdout and can be compiled to machine code with clang as
explained in the beginning of the post.

## Things that need to be talked about

There are a whole lot of things I had to omit from this post to save it from
growing into a 200 page text book, but a few important ones need to be
mentioned.

### 1. Lambda lifting

[Lambda lifting][lift] is the technique used to lift inline function definitions
to top level for easy code generation. This is necessary for the LLVM backend.

__Further reading:__

1. [What is lambda lifting?](https://stackoverflow.com/questions/592584/what-is-lambda-lifting)
2. [A tutorial on lambda lifting](https://gist.github.com/jozefg/652f1d7407b7f0266ae9)
3. [Closure conversion: How to compile lambda](http://matt.might.net/articles/closure-conversion/)

### 2. Single Static Assignment form

[SSA][ssa] is a property of an intermediate representation (IR), which requires
that each variable is assigned exactly once, and every variable is defined
before it is used. It sounds too simple and obvious, but the implications are
amazing. This form makes a lot of optimizations like dead code elimination
significantly simpler.

### 3. Left recursion in combinatorial parsers

I learned about this issue when my parser started going into an infinite loop
for specific inputs. This blog post [Left-recursion in Parsec][parsec-left] is a
decent explanation of the problem.

### 4. Learn  LLVM with C

An excellent way to learn LLVM is to compile very simple C programs with
optimizations turned off. The [examples][examples] folder contains a sample C
file and a Makefile with the right compiler flags.

## Things that didn't work

I went down way too many unsuccessful rabbit holes to list here, but here are a
few

### 1. The one true perfect type safe AST probably doesn't exist

I spent countless sleepless nights on my bed thinking about this problem and
still didn't achieve a satisfactory solution. Can you define your AST in a way
that all semantic errors become type errors? This blog
post [The AST Typing Problem][ast-typing] by Edward Z. Yang is a good
introduction. I might write another post sometime later explaining a few common
strategies.

### 2. Untyped lambda calculus is way harder

### 3. Using a pretty printer library to handle malformed AST is a bad idea

I was pretty stupid and got [warned][pp] by [Stephen Diehl][sdiehl]. I learned
my lesson.

## Next steps

### 1. FFI

A foreign function interface to C will make the language a lot more useful and
powerful; like printing to the terminal. Sigh!

## Reading list

1. David Terei's [slides][slides] on the GHC compiler internals. Most of my
   ideas about tiny passes where shaped by Haskell.


[aosa]: http://www.aosabook.org/en/ghc.html
[ast-typing]: http://blog.ezyang.com/2013/05/the-ast-typing-problem
[ast]: https://en.wikipedia.org/wiki/Abstract_syntax_tree
[bnf]: https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form
[examples]: https://github.com/jaseemabid/Olifant/tree/master/examples
[gen]: https://github.com/jaseemabid/Olifant/blob/master/src/Olifant/Gen.hs
[hm]: https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system
[lift]: https://en.wikipedia.org/wiki/Lambda_lifting
[ll-ir]: http://llvm.org/docs/LangRef.html
[llvm-hs]: https://github.com/llvm-hs/llvm-hs
[llvm]: http://llvm.org/
[module]: http://llvm.org/docs/LangRef.html#module-structure
[olifant]: https://github.com/jaseemabid/Olifant
[paper]: http://www.cs.nott.ac.uk/~pszgmh/pearl.pdf
[parsec-left]: http://stuckinaninfiniteloop.blogspot.com/2011/10/left-recursion-in-parsec.html
[parsec]: https://hackage.haskell.org/package/parsec
[parser]: https://github.com/jaseemabid/Olifant/blob/master/src/Olifant/Parser.hs
[poly]: https://wiki.haskell.org/Polymorphism
[pp]: https://github.com/llvm-hs/llvm-hs-pretty/issues/12#issuecomment-308326909
[pure]: https://en.wikipedia.org/wiki/Pure_function
[sdiehl]: http://www.stephendiehl.com/
[slides]: http://www.scs.stanford.edu/11au-cs240h/notes/ghc-slides.html][A Haskell compiler
[ssa]: https://en.wikipedia.org/wiki/Static_single_assignment_form
[stlc]: https://en.wikipedia.org/wiki/Simply_typed_lambda_calculus
