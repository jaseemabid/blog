---
layout: post
title: Taming complexity with scopes
---

This post should have been called _How to write better python with some
functional programming tricks_.

One of the most powerful aspects of Haskell is its approach to managing side
effects. Consider a function like square.

```haskell
square :: Integer -> Integer
square x = x * x
```

From the type signature of the function, it is evident that the function is pure
and is computing an integer from another Integer. That is all it can do. It
can't write to a file or fetch cached values from Redis. It can't send nuclear
missiles either. And you can be sure of this by inspecting just the function
signature; without even looking at the implementation.

I'd like you to pause, and think about that for a moment. Can you usually take
such a leap of faith in code you write everyday? Is it always evident what a
function does from it's name and type signature?

Consider fetching a value from a dictionary using the lookup function.

```
lookup :: k -> Map k a -> Maybe a
```

Rather than return the value when available and null otherwise, Haskell takes a
different approach. The `lookup` function has the type `Maybe a` in the
signature and it means that the function might not be able to always return the
required value; and will return one of `Just a` or `Nothing` appropriately. This
is different from a null; because these values must be handled differently at
compile time rather than runtime; making it impossible to forget to handle them
and hence completely avoiding null type exceptions.

The Haskell function that can read a character from stdin is called `getChar`
and its type signature looks a bit different.

```
getChar :: IO Char
```

The IO in the signature means that other than doing pure computation, it can
read and write to external data streams like files or network.


You can expect a function which retrieves a User from database using a primary
key to have the signature `ID -> IO (Maybe User)` instead of `ID -> User`. The
fact that the function might make an external call and can fail to find the user
in the DB is very obvious and is not hidden from the programmer.

A function that can optionally return a value or fail with a reason, like the
authenticate function of a web application will have a type of the form `Either
Reason User`; meaning it could return a `Right User` or a fail with `Left
Reason`. Some block of code that needs access to some static configuration will
have `Reader` in the signature. `Writer` is when you need to write some values
from the function, like log lines. `State` can manage mutable state in a content
very explicitly.

---

I'd like to call this property of a function its scope.

The scope of a function is how much it can do. One of the things that makes
Haskell unique is that it gives a way for programmers to explicitly state the
scope of a function statically at compile time. Simple functions to reverse a
list will have the simplest scope as well; like `reverse :: [a] -> [a]`. Complex
bulky functions that needs to do a lot of things at the same time, like parsing
data and manage the state and handle errors will need far more sophisticated
tools like [monad transformers][mtl] and will look ugly; like

```
alistToEnv :: Scheme -> StateT Env (ExceptT String Identity) [(String, Scheme)]
```

Being explicit about the scope forces the programmers to simplify the code. I've
worked with Python functions that span few pages which cannot be reasonably
called functions or be typed in any sensible way in a statically typed program.
This is because most Python programmers think of the scope of their functions in
a way a self respecting decent compiler force you.

.

[mtl]: http://google.com
