---
layout: post
title: Lessons learned building a toy compiler
---

I've been working on [Olifant][1] for about 6 weeks now and this is a brief
introduction to things that I learned along the way. Olifant is a compiler
for [simply typed lambda calculus][stlc] with named bindings. The calculus is
compiled into [LLVM IR][llvm] and then to machine code.

We tend to think of compilers as big black boxes which transform some high level
language, let's say C into a binary in one big step. I'd like to present it as a
pipeline of languages and transformations, each a bit simpler and slightly lower
level than the one before it. A complex compiler built out of a series of
transformations in which each of them is a simple independent pure function.

## The big picture

The input language is of the form

    let id = λx:i.x; let k = 42; id k

`λx` means a function that takes one argument `x`. The `:i` indicates that `x`
is of type integer. Everything after the `.` is the body of the function and
here its simply returning the argument. `id k` is a function application with a
single argument `k`. Types of literals like numbers and booleans can be left
out, and will be inferred by the compiler.

The language which I'll call calculus is a series of function or variable
declarations (also called let bindings) and one expression computing a value;
which is returned by the program. For example, the expression above can be
compiled into LLVM IR.

    $ echo 'let id = λx:i.x; id 42' | olifant

```llvm
; ModuleID = 'calc'
source_filename = "<string>"

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

The LLVM IR is low level enough to be very close to metal but still expressive
enough to describe a lot of high level features without too much verbosity. See
the [language reference][llir] for a detailed description. The llc compiler can
compile the IR into executable binary and optionally apply several optimizations
with fine grained control. Using clang is simpler

    $ clang sample.ll
    $ file a.out
    a.out: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked,
    interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, not stripped

The program is so small; it can't even do IO yet :) Evaluating the program
yields no output, but the return value can be fetched using bash special
variables.

    $ ./a.out
    $ echo $?
    42

## Parser

The quintessential first step in any compiler is parsing the source string into
an AST; which is a convenient data structure to work with rather than raw
strings. [Parsec][parsec] and its several forks are excellent for the job and
the paper [xxx TODO] is a beautiful introduction to combinatorial parsing.

Consider a very simple language with just numbers and addition. AST for such a
language can be described very elegantly with the following Haskell type.

```haskell
data E = Number Int | Plus E E

let ten = Plus (Number 6) (Number 4)
```

The first language olifant describes is called the frontend calculus and is
represented by the Haskell type

```haskell
data Calculus =
    Var Text
  | Number Int
  | Bool Bool
  | App Calculus Calculus
  | Lam Text Tipe Calculus
  | Let Text Calculus
  deriving (Eq, Show)
```

Calculus is partly typed. Function arguments are type annotated and the rest of
it can be inferred. The parser is reasonably straight forward and is only about
100 lines of very well documented code. The only class of errors the parser
understands is syntax errors and is very lenient in general. It wont care about
an undefined variable for example.

The expression above will be parsed into

```haskell
[Let "id" (Lam "x" i (Var "x")),
 App (Var "id") (Number 42)]
```

## Core

The second language (and all the subsequent ones for now) are defined using the
same Haskell type, called Core. Core is a very different from Calculus or
the [BNF grammar][bnf] of simply typed lambada calculus. References are either
local or global, and it means very different things to the code generator.
References use a compound data structure to avoid symbol tables; which we will
talk about later in this post. Top level expressions are either variables or
function definitions. There are no higher order functions and so on.

```haskell
-- | All valid types
data Tipe = TUnit | TInt | TBool | TArrow Tipe Tipe
    deriving (Eq, Ord)

-- | An annotated lambda calculus expression
data Expr
    = Var Ref
    | Lit Literal
    | App Tipe Expr Expr
    | Lam Tipe Ref Expr
    deriving Eq

-- | Top level binding of a lambda calc expression to a name
data Bind = Bind Ref Expr
  deriving Eq

-- | A program is a list of bindings and a terminating expression
data Progn = Progn [Bind] Expr
  deriving Eq
```

## Cast

Casting is applying the minimum transformations on calculus to get core. It
ensures that the program is a series of declarations and an expression in the
end. All known types (only function arguments) are retained and the rest of them
are explicitly marked to be of `unit` type (think of Java's Object). Cast either
returns a Core expression or raises a syntax error.

## Rename

One of the interesting things I learned about transformations is that a symbol
table is unnecessary in a lot of cases.

Quoting [AOSA § No Symbol Table][aosa],

> As far as possible, we use an alternative strategy: a variable is a data
> structure that contains all the information about itself. I find this approach
> simpler. Each state of the compiler can augment and annotate more information
> into the reference accordingly. A simple pass can be made even simpler without
> getting into any of the StateT business.

Olifant uses a ref type for variable references

```haskell
-- | A reference; an embedded data structure avoids the need for a symbol table
data Ref = Ref {rname :: Text, raw :: Text, rtipe :: Tipe, scope :: Scope}
    deriving (Eq, Ord)
```

__NOTE: This is still not implemented in olifant__

The rename phase rewrites variable names to avoid runtime ambiguity and
shadowing. It embeds enough data in a ref itself to avoid the need for a classic
symbol table and it feels like a natural way to work with functional programming
languages.

It is an open question weather the 2 approaches are the same.


# Type inference

Type inference for a language without polymorphic types and some annotations is
reasonably straightforward and easy; and I decided to let go some expressive
power (read generics) to keep things simple.

A polymorphic type or a kind is to a variable what a variable is to a value. You
describe the properties of an item from a set and it takes a concrete value at
runtime. For example the identity function in Haskell has the type signature `id
:: a -> a`, which can be read as a function that takes a value of type a and
returns another value of type a. At runtime `a` gets a concrete value like Int
or String; and polymorphic types let us work with a set of types in a generic
way. tldr; I don't have polymorphic types yet.

Complete type inference is possible for a language with polymorphic types even
without any user annotations with a very well known algorithm
called [Hindley-Milner][hm] and its a bit tricky to get right. In the meanwhile
we can use a much simpler algorithm.

[TODO] - Add image from tapl

The scheme requires all function arguments and let bindings to be annotated and
the rest can be inferred. The heuristic is that you need to define the type only
when a new variable is introduced and the same information can be used later.

# Verification

TODO



[1]: https://github.com/jaseemabid/Olifant
[aosa]: http://www.aosabook.org/en/ghc.html
[llir]:http://llvm.org/docs/LangRef.html
[llvm]: http://llvm.org/
[stlc]:https://en.wikipedia.org/wiki/Simply_typed_lambda_calculus
