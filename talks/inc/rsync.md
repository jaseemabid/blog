class: center, middle, big

# RSYNC

---
class: center, middle

# Andrew Tridgell, 1996

---
class: center, middle

# Efficiently updating files over slow network links

---
class: middle

> The rsync algorithm was developed out of my frustration with the long time it
> took to send changes in a source code tree across a dialup network link.

---
class: middle

> In most cases these transfers were actually updates, where an old version of
> the file already existed at the other end of the link.

---
class: middle

> The common methods for file transfer (such as ftp and rcp) didn’t take
> advantage of the old file.

---

# So I started looking for a way of updating files

--

1. It should work on arbitrary data, not just text
--

2. The total data transferred should be about the size of a compressed diff file
--

3. It should be fast for large files and large collections of files
--

4. The algorithm should not assume any prior knowledge of the two files, but should take advantage of similarities if they exist
--

5. The number of round trips should be kept to a minimum to minimize the effect of transmission latency
--

6. The algorithm should be computationally inexpensive, if possible

---
class: center, middle, big, inverse

# A → B

---
class: center, middle

![First attempt](00 - first attempt.png)

---
# Useless in practice

--
1. Matches only on block boundaries

--
2. `echo 1 > foo.txt`

---
# A second try

> [...] A to generate signatures not just at block boundaries, but at all byte
> boundaries.

---
class: middle

> When A compares the signature at each byte boundary with each of the
> signatures `Sj` on block boundaries of `bi` it will be able to find matches at
> non block offsets. This allows for arbitrary length insertions and deletions
> between `ai` and `bi` to be handled.

---
class: center, middle, big, inverse

# O(n<sup>2</sup>)

---
class: middle

> It could be made computationally feasible by making the signature algorithm
> very cheap to compute but this is hard to do without making the signature too
> weak. A weak signature would make the algorithm unusable.

---
# 2 Signatures

### 1<sup>st</sup> signature needs to be very cheap to compute for all byte offsets

### 2<sup>nd</sup> signature needs to have a very low probability of collision

---
# For this algorithm to be effective and efficient we need the following conditions

1. The signature R needs to be cheap to compute at every byte offset in a file

2. The signature H needs to have a very low probability of random collision

3. A needs to perform the matches on all block signatures received from B very
   efficiently, as this needs to be done at all byte offsets

---
class: center, middle

![Roll and Hash](01 - roll and hash.png)

---
class: center, middle

# Strong Signature

--
### Easy; any cryptographic hash would do

---
class: center, middle

# Weak Signature

--
### Not so easy

---
class: middle

### Filter before strong signature
### Able to be computed very cheaply at every byte offset

---
class: center, middle

![Sigma](02 - sigma.png)

---
class: middle, center, big

# Rolling Hashes

---
class: middle, big

```
    MOJO = M * 97^3 +
           O * 97^2 +
           J * 97^1 +
           O
```

---
class: middle

```
    /* Find MOJO given IMOJ */

    IMOJ = I * 97^3 + M * 97^2 + O * 97^1 + J
    MOJO = ???

    _MOJ = IMOJ - I * 97^3
    MOJ_ = _MOJ * 97
    MOJO = MOJ_ + O

    MOJO = 97 * (IMOJ - I * 97^4) + O
```

---
class: middle, center

# Signature Search

--
## Hash Tables

---
class: middle, center

# Signature Search
## Hash Tables <sup>*</sup>

---
# Reconstructing the file

> One of the simplest parts of the rsync algorithm is reconstructing the file on
> B. After sending the signatures to A, B receives a stream of literal bytes
> from A interspersed with tokens representing block matches. To reconstruct the
> file B just needs to sequentially write the literal bytes to the file and
> write blocks obtained from the old file when a token is received.

---
# More!

--
1. Choosing block sizes

--
2. Choosing algorithms

--
3. Hashing speed

--
4. Worst case overhead

--
5. Relative wire performance from A → B vs A ← B

--
6. Relative performance of disk vs network

--
7. Heuristics

--
8. What if A & B are local?

--
9. File size, modification time?

--
10. Git over rsync? [0d0bac](https://github.com/git/git/commit/0d0bac67ce3b3f2301702573f6acc100798d7edd)

--
11. Compression

---

# Refs

1. http://jaseemabid.github.io/talks/rsync
1. The rsync algorithm (pdf)
1. Efficient Algorithms for Sorting and Synchronization (pdf)
1. http://rsync.samba.org/
1. https://en.wikipedia.org/wiki/Rsync
1. `man rsync`
