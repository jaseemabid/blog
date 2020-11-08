---
layout: post
title: Why I don't like Scheme anymore
---

After a long struggle with Scheme, I'm finally throwing the towel on it. The
comments are specifically about [Chez Scheme][] after working on a [Scheme
Compiler][inc] on and off for a couple of months.

## 1. Lisp syntax is for machines, not humans.

This debate predates me and is my subjective opinion. Lack of syntax makes it
trivial for machines to parse source but makes it a whole lot harder for humans.
_I_ find having a visual structure to programs makes it much easier read, write
and understand programs. Why would you prefer the racket version here over
Python?

```scheme
> (define ht (make-hash))
> (hash-set! ht "apple" '(red round))
> (hash-set! ht "banana" '(yellow long))
> (hash-ref ht "apple")
'(red round)
```

```py
>>> ht = {'apple': ['red', 'round'], 'banana': ['yellow', 'long']}
>>> ht['apple']
['red', 'round']
```

A realistic and larger example is the [match macro][] by [R. Kent Dybvig][kent],
one of the designers of Chez. The source [match.ss][] fits in one page and I
suggest you take a look. There are completely incomprehensible functions more
than 100 lines in there. That is how most lisp in the wild looks like.


## 2. Lack of types is not worth it

Types are the most powerful tool we have for program design and literally no
other feature is worth it. I'd pick a statically typed language with a far
simpler and limited meta programming model compared to Scheme instead of having
to deal with type errors at runtime.

Haskell for example supports simple algebraic data types with pattern matching.

```haskell
-- A binary tree can either be empty or a node with 2 branches.
data Tree a = Empty | Node a (Tree a) (Tree a)
  deriving (Show, Read, Eq)

singleton :: a -> Tree a
singleton x = Node x Empty Empty

insert :: (Ord a) => a -> Tree a -> Tree a
insert x Empty = singleton x
insert x (Node a left right)
    | x == a = Node x left right
    | x < a  = Node a (insert x left) right
    | x > a  = Node a left (insert x right)
```

Haskell would warn if you forget a case, error if you get a typo and makes it
very clear about the branches the code can take. Compare this with a small
utility function I wrote recently.

```scheme
(define (immediate-rep x)
  (cond
   [(fixnum? x) (ash x shift)]
   [(boolean? x) (if x bool-t bool-f)]
   [(null? x) niltag]
   [(char? x) (bitwise-ior (ash (char->integer x) shift) chartag)]
   [else (error 'immediate-rep (format "Unknown form ~a" x))]))
```

Its hard to know if I've covered all the cases or made a typo or added a branch
that will never be taken. Why would you pick latter?

## 3. Expressiveness

Presented without comments, quicksort in Scheme and Haskell.

```scheme
(define (partition compare l1)
  (cond
   ((null? l1) '())
   ((compare (car l1)) (cons (car l1) (partition compare (cdr l1))))
   (else (partition compare (cdr l1)))))

(define (quicksort l1)
  (cond
   ((null? l1) '())
   (else (let ((pivot (car l1)))
           (append (append (quicksort
                            (partition (lambda (x) (< x pivot)) l1))
                           (partition
                            (lambda (x) (= x pivot)) l1))
                   (quicksort
                    (partition (lambda (x) (> x pivot)) l1)))))))
```


```haskell
quicksort :: (Ord a) => [a] -> [a]
quicksort [] = []
quicksort (x:xs) = smaller ++ [x] ++ bigger
  where
    smaller = quicksort [a | a <- xs, a <= x]
    bigger = quicksort [a | a <- xs, a > x]
```

## 4. Macros feel overrated

Adding or removing a feature from a language involves often complex tradeoffs,
classic example being generics in Go. Macros are often touted as the killer
feature of lisp, but I find it not worth letting go so many other features I
care a lot more about.

In the compiler I've been writing recently, there is just one [macro][add-tests]
to have a syntactic sugar for writing [tests][inc-tests]. A lot has been said
about the [benefits][homoiconicity], but in practice I write macros so rarely
and read code a few orders of magnitude more. I'll rather have a language that
makes reading 95% of code easier and writing those occasional macros harder.

## 5. Functional programming

Several functional programming features are missing or poorly supported.

Automatic currying would have been great. This function for example checks if an
expression is a list and starts with a specific tag. Partially applying the
first argument gives a lot of helper functions with neat names.

```scheme
;; This is what we have to write
(define (tagged-list name)
  (lambda (expr)
    (and (list? expr) (eq? name (car expr)) #t)))

(define let? (tagged-list 'let))

;; I wish I could write this instead
(define (tagged-list name expr)
  (and (list? expr) (eq? name (car expr)) #t))

(define let? (tagged-list 'let))
```

A simpler pattern matching system baked into the language would have been great.

Some notion of purity or at least immutability by default would have been so
good to have.

## 6. The tooling is miserable

There isn't a single decent linter, code formatter or something that can catch
typos with static analysis. The equivalent of flake8 or dialyzer is sorely
missed. The popularity of gofmt, rustfmt or [prettier][] proves that auto
formatting code is a great idea. I'm so used to [flycheck][] showing red
squiggly lines under the code, it feels crippled to work without it.
[Hlint][hlint] is so awesome, it improved my code so many times.

Working with none of these is not fun at all.

## What's next?

I'll migrate the [incremental compiler][inc] to Typed Racket to begin with. It
solves some of the problems mentioned here with better tooling, types, much
better standard library and some powerful pattern matching. Its good not having
to rewrite everything from scratch and hopefully the migration will be smooth
and rewarding.

Let me know your thoughts.

[hlint]: http://hackage.haskell.org/package/hlint
[flycheck]: http://www.flycheck.org/en/latest/
[Chez Scheme]: https://www.scheme.com "(chez (chez scheme))"
[add-tests]: https://github.com/jaseemabid/inc/blob/5157d8e9afb414e6b27fc0a9497810ce66ca8ea9/src/tests-driver.scm#L52-L58
[homoiconicity]: http://calculist.org/blog/2012/04/17/homoiconicity-isnt-the-point "Homoiconicity isn’t the point"
[inc-tests]: https://github.com/jaseemabid/inc/tree/master/tests "All the tests in the incremental compiler"
[inc]: https://github.com/jaseemabid/inc "An incremental approach to compiler construction"
[kent]: https://en.wikipedia.org/wiki/R._Kent_Dybvig
[match macro]: https://www.cs.indiana.edu/chezscheme/match/ "Using Match"
[match.ss]: https://www.cs.indiana.edu/chezscheme/match/match.ss
[prettier]: https://prettier.io "Prettier · Opinionated Code Formatter"
