(module filter racket
(require "npl.rkt")

(eval-exp
  (call
    (call npl-filter
    (fun #f "x"
      (ifgreater (var "x") (int 10) (int 1) (int 0)))
    )
  (apair (int 11) (apair (int 9) (apair (int 5) (apair (int 12) (aunit)))))
  )
)
)
