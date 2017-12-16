(module npl-sort racket
(require "npl.rkt")

(eval-exp
(call npl-sort
  (apair (int 4) (apair (int 5) (apair (int 1) (apair (int 6) (apair (int 0)
    (apair (int 11) (apair (int 2) (apair (int 15) (aunit)))))))))
)
)
)
