(module fibonacci racket
(require "npl.rkt")

(eval-exp
(call
(fun "fib" "n"
  (ifeq (var "n") (int 0)
    (int 1)
    (ifeq (var "n") (int 1)
    (int 1)
    (add (call (var "fib") (sub (var "n") (int 1)))
         (call (var "fib") (sub (var "n") (int 2)))))))
(int 5))
)
)
