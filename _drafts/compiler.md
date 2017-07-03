---
layout: post
title: Lessons learned building a toy compiler
---

I've been working on [Olifant][olifant]; a compiler
for [simply typed lambda calculus][stlc] with named bindings for last few weeks
and this is a quick introduction to things that I learned along the way. Lambda
calculus is an extremely minimal formal system to study programming language
theory and computation in general. Olifant compiles a slightly modified form of
lambda calculus into [LLVM IR][llvm] and then to machine code which can be then
run natively.

We tend to think of compilers as big black boxes which transform some high level
language, let's say C into a binary in one big step. I'd like to present it as a
pipeline of languages and transformations, each a bit simpler and slightly lower
level than the one before it. A complex compiler built out of a series of
transformations in which each of them is a simple independent [pure][pure]
function.

## The big picture

The input language is of the form

    let id = λx:i.x; let k = 42; id k

`λx` is a function that takes one argument `x`. The `:i` indicates that `x` is
of type integer. Everything after the `.` is the body of the function and here
it is simply returning the argument. `id k` is a function application with a
single argument `k`. Types of literals like numbers and booleans can be left out
and will be inferred by the compiler.

The language which I'll call calculus is a series of function or variable
declarations (also called let bindings) and one expression computing a value;
which is returned by the program. For example, the expression above can be
compiled into the following LLVM IR.

    $ echo 'let id = λx:i.x; id 42' | olifant

```llvm
; ModuleID = 'calc'

define i64 @id(i64 %x) {
entry:
  ret i64 %x
}

define i64 @main(i64 %_) {
entry:
  %0 = call i64 @id(i64 42)
  ret i64 %0
}
```

The LLVM IR is a language low level enough to be very close to metal but still
expressive enough to describe a lot of high level features without too much
verbosity. See the [language reference][llir] for a detailed description. The
llc compiler can compile the IR into an executable binary and optionally apply
several optimizations with fine grained control. Using clang is simpler

    $ clang sample.ll -o sample
    $ file sample
    sample: ELF 64-bit LSB executable, x86-64, version 1 (SYSV),
    dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2,
    for GNU/Linux 2.6.32, not stripped

The language is so small; it can't even print the value to the terminal yet :)
(because getchar and putchar are not defined) Evaluating the program yields no
output, but the return value can be fetched using bash special variables.

    $ ./sample
    $ echo $?
    42

## Parser

The quintessential first step in any compiler is parsing the source string into
an [Abstract Syntax Tree][ast]; which is a convenient data structure to work
with rather than raw strings. Olifant uses the venerable combinatorial parsing
library [Parsec][parsec] and the paper [Monadic Parsing in Haskell][paper] is a
beautiful and simple introduction to the subject.

Consider a very simple language with just numbers and addition. AST for such a
language can be described very elegantly with the following Haskell type.

```haskell
data Expr = Number Int | Plus Expr Expr
```

A sample program like `6 + 4` can then be parsed into

```haskell
Plus (Number 6) (Number 4)
```

Similarly, Calculus is represented by the Haskell type

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
forward and is only about 100 lines of very well documented code. The only class
of errors the parser understands is syntax errors and is very lenient in
general. It won't care about an undefined variable for example.

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
but they are allowed anywhere in Calculus.

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

The limitations in Core seems arbitrary and unnecessarily crippling, but it
makes subsequent analysis and code generation much simpler.

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

Casting is applying the minimum transformations on calculus to get core. Cast
does basic structural validations and ensures that the program is a series of
declarations and an expression in the end. All known types (only function
arguments) are retained and the rest of them are explicitly marked to be of
`unit` type (think of Java's Object). Cast either returns a Core expression or
raises a syntax error.

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

It is an open question if the two approaches are the same.

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

## Verification

TODO

## Code generation

TODO

[aosa]: http://www.aosabook.org/en/ghc.html
[ast]: https://en.wikipedia.org/wiki/Abstract_syntax_tree
[bnf]: https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form
[hm]: https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system
[llir]: http://llvm.org/docs/LangRef.html
[llvm]: http://llvm.org/
[olifant]: https://github.com/jaseemabid/Olifant
[paper]: http://www.cs.nott.ac.uk/~pszgmh/pearl.pdf
[parsec]: https://hackage.haskell.org/package/parsec
[poly]: https://wiki.haskell.org/Polymorphism
[pure]: https://en.wikipedia.org/wiki/Pure_function
[stlc]: https://en.wikipedia.org/wiki/Simply_typed_lambda_calculus
