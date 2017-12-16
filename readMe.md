# New Programming Language (npl) v1.0

**Documentation for npl**

**1. Primitive Values in npl**

`(int n)` is a NPL expression (a constant) where `n` is a Racket integer.

`(var s)` is a NPL expression (a variable use) where `s` is a Racket string.

`(apair e1 e2)` denotes a pair in NPL. `e1` and `e2` are NPL expressions.

`(aunit)` represents a unit value in NPL. Essentially it's a value holding no data much like `void` in C or `null` in Racket. Notice that `(aunit)` is a unit value in NPL and not `aunit`.

A NPL list is a NPL pair with first element being a NPL
expression and second element being another NPL list. In other words, nested NPL pairs form a NPL list with the empty list
being `(aunit)`.

Eg. `(apair (int 10) (apair (int 12) (apair (int 13) (aunit))))`

**2. Accessor functions**

`(fst e)` and `(snd e)` retrieve the first and second element of
a NPL pair only when `e` is a NPL pair, else it throws an error.

These can also be used recursively to retrieve elements of a
NPL list.

**3. Other library functions**

 `(add e1 e2)` is a NPL expression that adds two sub-expressions
 `e1` and `e2` after evaluating them. For addition to hold, `e1` and `e2` should evaluate to NPL integer `(int n)`.

 Similarly, we have `(sub e1 e2)`, `(mul e1 e2)` and `(div e1 e2)`.

 `(isaunit e)` evaluates `e`, if the result is `(aunit)`, then
 `(int 1)` is returned or else `(int 0)` is returned.

 **4. Conditionals**

 NPL library provides two Conditional constructs for handling control flow.

 `(ifgreater e1 e2 e3 e4)` is a NPL expression where the result is `e3` if `e1` is strictly greater than `e2` else the result is
 `e4`. Only one of `e3` and `e4` is evaluated. All four should be
 NPL expressions.

 `(ifeq e1 e2 e3 e4)` is a much like `ifgreater` but evaluates `e3` if and only if `e1` and `e2` are equal integers. The evaluated expression is the overall result.

 `(ifaunit e1 e2 e3)` evaluates `e1`, if the result is `(aunit)`,
 then it evaluates `e2` and that is the overall result or else it
 evaluates `e3` and that is the overall result.

**5. let expressions**

NPL offers two types of let expressions: `mlet` and `mlet*` much like the Racket's `let` and `let*`.

`(mlet s e1 e2)` is a NPL expression where `s` is a Racket string and `e1` and `e2` are NPL expressions. The result of evaluating `e1` is bound to variable `s` in evaluation of `e2`.

`(mlet* ((s1.e1) (s2.e2) ... (sn.en)) e)` is another NPL
construct that takes in a Racket list of Racket pairs and a NPL expression `e`. Each Racket pair is a Racket string and a NPL expression such that the result of evaluating the NPL expression `ei` is bound to variable `si`. `ei` is evaluated in an environment where `s1` through `si-1` is bound to `e1` through `ei-1`. Finally `e` is evaluated in an environment where each `si` is bound to the corresponding `ei` and the result of the whole expression is the result of evaluating `e`.

**6. Functions**

All functions in NPL are one argument functions, not internally like Haskell but in true sense that is you cannot declare a two argument function in NPL. Functions are first class citizens and can be assigned to variables. Functions that take two or more argument can be written by currying functions together.

`(fun nameopt var body)` declares a new function in NPL. `nameopt` and `var` are Racket strings and `body` is a NPL expression denoting the body of function which is evaluated in an environment where `nameopt` is bound to the same function and `var` is bound to the argument passed to the function when the function is called.

For eg. `(fun "addOne" "x" (add (var "x") (int 1)))` denotes a NPL function that adds one to its argument. Notice the `(var "x")` which denotes the usage of variable `x` inside the function body.

`(call fn arg)` denotes a function call where `fn` and `arg` are NPL expressions such that `fn` evaluates to a function and `arg` represents the argument to the function.

For eg. `(call (var "addOne") (int 4))` calls the function `addOne` declared above with the argument `(int 4)`.

**7. Extensions to NPL**

Some handy functions have been conjured up using the above primitives to save time and energy.

`npl-map` is a NPL function which takes in a NPL function and returns another NPL function which takes in a NPL list and applies the function to every element of the list returning a new NPL list (much like `map` function in functional languages).

`npl-mapAddN` is a NPL function that takes in a NPL integer `i` and returns a NPL function that takes in a NPL list and returns a new NPL list with integer `i` being added to every element of the list.

`npl-filter` is a NPL function that takes in a NPL function which acts like a predicate and returns another NPL function which takes in a NPL list and returns a new NPL list containing only those elements on which the predicate function holds. Your predicate function should return `(int 1)` if the predicate holds or else it should return `(int 0)`.

`npl-append` is a NPL function that takes in a NPL list and returns another function which also takes in a NPL list and returns a new NPL list with the second list appended to the first list.

`npl-sort` is a NPL sorting function which takes in a NPL list as an argument and returns a new sorted NPL list.

**8. The actual interpreter**

The interpreter doesn't appear as a prompt but is essentially the function `(eval-exp e)` which takes in a NPL expression `e` and evaluates it.

**9. Using NPL**

NPL files end with a `'.rkt'` extension since they are ultimately Racket files. Racket's module system requires you to declare `(module filename racket ....code here....)` at the top level in your program where `"filename.rkt"` is your NPL file. The first statement of the program must be `(require "npl.rkt")` which imports `npl` and it's library functions. `"npl.rkt"` should be present in the same directory as the your file `"filename.rkt"`.

**10. Sample program**

Below is a sample factorial program in NPL.

```
; filepath
; C:\Users\USER\Desktop\Racket\Interpreter\tests\factorial.rkt
; npl.rkt is in the same directory

(module factorial racket
(require "npl.rkt")

(eval-exp
  (call
  (fun "fact" "n"
    (ifeq (var "n") (int 0)
          (int 1)
          (mul (call (var "fact") (sub (var "n") (int 1))) (var "n"))))
  (int 12)
))

```
Output

```
C:\Users\USER\Desktop\Racket\Interpreter\tests>racket factorial.rkt
(int 479001600)
```

Sample usage of `npl-sort` function.

```
; filepath
; C:\Users\USER\Desktop\Racket\Interpreter\tests\npl-sort.rkt
; npl.rkt in the same directory

(module npl-sort racket
(require "npl.rkt")

  (eval-exp
    (call npl-sort
      (apair (int 4) (apair (int 5) (apair (int 1) (apair (int 6) (apair (int 0)
        (apair (int 11) (apair (int 2) (apair (int 15) (aunit)))))))))
    )
  )
)

```
Output

```
C:\Users\USER\Desktop\Racket\Interpreter\tests>racket npl-sort.rkt
(apair (int 0) (apair (int 1) (apair (int 2) (apair (int 4) (apair (int
5) (apair (int 6) (apair (int 11) (apair (int 15) (aunit)))))))))
```
