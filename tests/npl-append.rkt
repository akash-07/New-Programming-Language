(module npl-append racket
(require "npl.rkt")
(eval-exp
  (call
    (call npl-append
    (apair (int 1) (apair (int 2) (aunit)))
    )
  (apair (int 3) (apair (int 4) (apair (int 5) (aunit))))
  )
)
)
