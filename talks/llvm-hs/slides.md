class: center, middle, inverse

# llvm-hs
## Good, Bad and Ugly

Jaseem Abid

@jaseemabid

---
class: center, middle, inverse

# Olifant
## A simple compiler for simply typed λ calculus

---
class: center, middle

# A -> B

---
class: center,middle

#  A  -> -> -> -> -> -> ->  B

---
class: center, middle

# let id = /x:i.x; id 42

---
class: center, middle

# Parse

## String -> AST (Calculus)

---
class: center, middle

# Cast

## Calculus -> Core

---
class: center, middle

# 😊

---
class: center, middle

# Core -> Core

## Small changes interleaved with a verifier

---
class: center, middle

# Compilers vs Interpreters

---
class: center

## Rename

--
## Type Check

--
## Lambda Lift

--
## Constant propagation

--
## ...

--
## ??

---
class: center, middle

# SSA

---
class: center, middle

# Code generation

---
class: center, middle

#  LLVM!

## _Fireworks_

---
class: center, middle, inverse

#  DEMO

---
class: center,middle

#  A  -> -> -> -> -> -> ->  B

---
class: center

#  A lot of things that didn't work, stuff I learned

--
## Typed IR

--
## Why do you need a symbol table anyway?

--
## FFI, JIT

--
## How do I do TCO? CPS?

---

background-image: url(end.jpg)
