(module test racket
(require "npl.rkt")

(eval-exp
  (call
  (fun "fact" "n"
    (ifeq (var "n") (int 0)
          (int 1)
          (mul (call (var "fact") (sub (var "n") (int 1))) (var "n"))))
  (int 12)
))

(eval-exp
(mlet*
  (list (cons "x" (int 10))
  (cons "y" (add (var "x") (int 2)))
  (cons "factorial" (fun "fact" "n"
    (ifeq (var "n") (int 0)
          (int 1)
          (mul (call (var "fact") (sub (var "n") (int 1))) (var "n"))))
  ))
  (call (var "factorial") (var "y"))
  ))
)
