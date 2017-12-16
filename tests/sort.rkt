(module sort racket
(require "npl.rkt")

(eval-exp
(call
(fun "sort" "lst"
 (ifaunit (var "lst")
          (aunit)
 (ifaunit (snd (var "lst"))
          (var "lst")
          (mlet*
            (list
            (cons "head" (fst (var "lst")))
            (cons "rList"
              (call
                (call npl-filter
                  (fun #f "x"
                    (ifgreater (var "x") (var "head") (int 1) (int 0))
                  )
                )
                (snd (var "lst"))
                )
            )
            (cons "lList"
              (call
                (call npl-filter
                  (fun #f "x"
                    (ifgreater (var "x") (var "head") (int 0) (int 1))
                  )
                )
                (snd (var "lst"))
                )
            )
            (cons "sorted-rList"
              (call (var "sort") (var "rList")))
            (cons "sorted-lList"
              (call (var "sort") (var "lList")))
            )
            (call
              (call npl-append (var "sorted-lList"))
              (call
                (call npl-append (apair (var "head") (aunit)))
                (var "sorted-rList")
              )
            )
          )
  )
  )
)
(apair (int 10) (apair (int 12) (apair (int 5) (apair (int 13) (apair (int 2) (aunit))))))
)
)
)
