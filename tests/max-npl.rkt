(module max-npl racket
(require "npl.rkt")

(eval-exp
(call
(fun "max" "lst"
  (ifaunit (snd (var "lst"))
    (fst (var "lst"))
    (mlet "max_rem"
      (call (var "max") (snd (var "lst")))
      (ifgreater (var "max_rem") (fst (var "lst"))
        (var "max_rem")
        (fst (var "lst")))
    )
  )
)
(apair (int 4) (apair (int 5) (apair (int 2) (aunit))))
)
)


)
