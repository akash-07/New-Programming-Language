(module test1 racket
(require "npl.rkt")

(eval-exp
(call (call npl-map (fun #f "x"
              (mul (var "x") (var "x"))))
  (apair (int 10) (apair (int 12) (apair (int 13) (aunit))))
)
)
)
