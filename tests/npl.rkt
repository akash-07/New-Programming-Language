(module npl racket

; export constructors
(provide
(struct-out var)
(struct-out int)
(struct-out add)
(struct-out mul)
(struct-out sub)
(struct-out div)
(struct-out ifgreater)
(struct-out fun)
(struct-out call)
(struct-out mlet)
(struct-out apair)
(struct-out fst)
(struct-out snd)
(struct-out aunit)
(struct-out isaunit)
eval-exp mlet* ifeq npl-map ifaunit npl-mapAddN npl-filter npl-append npl-sort)

;; definition of structures for npl programs
(struct var  (string) #:transparent)  ;; a variable, e.g., (var "foo")
(struct int  (num)    #:transparent)  ;; a constant number, e.g., (int 17)
(struct add  (e1 e2)  #:transparent)  ;; add two expressions
(struct mul (e1 e2) #:transparent) ;; multiply two expressions
(struct sub (e1 e2) #:transparent) ;; subtract two expressions
(struct div (e1 e2) #:transparent) ;; divides two expressions
(struct ifgreater (e1 e2 e3 e4)    #:transparent) ;; if e1 > e2 then e3 else e4
(struct fun  (nameopt formal body) #:transparent) ;; a recursive(?) 1-argument function
(struct call (funexp actual)       #:transparent) ;; function call
(struct mlet (var e body) #:transparent) ;; a local binding (let var = e in body)
(struct apair (e1 e2)     #:transparent) ;; make a new pair
(struct fst  (e)    #:transparent) ;; get first part of a pair
(struct snd  (e)    #:transparent) ;; get second part of a pair
(struct aunit ()    #:transparent) ;; unit value -- good for ending a list
(struct isaunit (e) #:transparent) ;; evaluate to 1 if e is unit else 0

;; a closure is not in "source" programs but /is/ a npl value; it is what functions evaluate to
(struct closure (env fun) #:transparent)

(define (racketlist->npllist rList)
  (cond [(null? rList) (aunit)]
        [else (apair (car rList) (racketlist->npllist (cdr rList)))]))

(define (npllist->racketlist mList)
  (cond [(aunit? mList) null]
        [else (cons (apair-e1 mList) (npllist->racketlist (apair-e2 mList)))]))

;; lookup a variable in an environment
(define (envlookup env str)
  (cond [(null? env) (error "unbound variable during evaluation" str)]
        [(equal? (car (car env)) str) (cdr (car env))]
        [#t (envlookup (cdr env) str)]))

; evaluating an expression under an environment
(define (eval-under-env e env)
  (cond [(var? e)
         (envlookup env (var-string e))]
        [(add? e)
         (let ([v1 (eval-under-env (add-e1 e) env)]
               [v2 (eval-under-env (add-e2 e) env)])
           (if (and (int? v1)
                    (int? v2))
               (int (+ (int-num v1)
                       (int-num v2)))
               (error "npl addition applied to non-number")))]
        [(mul? e)
         (let ([v1 (eval-under-env (mul-e1 e) env)]
               [v2 (eval-under-env (mul-e2 e) env)])
           (if (and (int? v1)
                    (int? v2))
               (int (* (int-num v1)
                       (int-num v2)))
               (error "npl multiplication applied to non-number")))]
         [(sub? e)
         (let ([v1 (eval-under-env (sub-e1 e) env)]
               [v2 (eval-under-env (sub-e2 e) env)])
           (if (and (int? v1)
                    (int? v2))
               (int (- (int-num v1)
                       (int-num v2)))
               (error "npl subtraction applied to non-number")))]
         [(div? e)
          (let ([v1 (eval-under-env (div-e1 e) env)]
                [v2 (eval-under-env (div-e2 e) env)])
            (if (and (int? v1)
                     (int? v2))
                (int (/ (int-num v1)
                        (int-num v2)))
                (error "npl division applied to non-number")))]
        ;; CHANGE add more cases here
        [(int? e) e]
        [(aunit? e) e]
        [(closure? e) e]
        [(ifgreater? e)
         (let ([e1 (eval-under-env (ifgreater-e1 e) env)]
               [e2 (eval-under-env (ifgreater-e2 e) env)])
           (cond [(or (not (int? e1)) (not (int? e2)))
                  (error (format "not an npl integer: ~v ~v" e1 e2))]
                 [(> (int-num e1) (int-num e2)) (eval-under-env (ifgreater-e3 e) env)]
                 [else (eval-under-env (ifgreater-e4 e) env)]))]
        [(mlet? e)
         (let* ([e1 (eval-under-env (mlet-e e) env)]
               [binding (cons (mlet-var e) e1)])
           (eval-under-env (mlet-body e) (cons binding env)))]
        [(apair? e)
         (let ([e1 (eval-under-env (apair-e1 e) env)]
                [e2 (eval-under-env (apair-e2 e) env)])
           (apair e1 e2))]
        [(fst? e)
         (let ([pr (eval-under-env (fst-e e) env)])
           (if (apair? pr) (apair-e1 pr)
               (error (format "fst: not a pair ~v" pr))))]
        [(snd? e)
         (let ([pr (eval-under-env (snd-e e) env)])
           (if (apair? pr) (apair-e2 pr)
               (error (format "snd: not a pair ~v" pr))))]
        [(isaunit? e)
         (let ([e1 (eval-under-env (isaunit-e e) env)])
           (if (aunit? e1) (int 1) (int 0)))]
        [(fun? e) (closure env e)]
        [(call? e)
         (let ([clos (eval-under-env (call-funexp e) env)]
               [arg1 (eval-under-env (call-actual e) env)])
         (cond [(not (closure? clos))
                 (error (format "not a function ~v" (call-funexp e)))]
                [else
                  (if (boolean? (fun-nameopt (closure-fun clos)))
                      (let ([binding (cons (fun-formal (closure-fun clos)) arg1)])
                        (eval-under-env (fun-body (closure-fun clos)) (cons binding (closure-env clos))))
                      (let ([binding1 (cons (fun-formal (closure-fun clos)) arg1)]
                            [binding2 (cons (fun-nameopt (closure-fun clos)) clos)])
                        (eval-under-env (fun-body (closure-fun clos))
                                        (cons binding2 (cons binding1 (closure-env clos))))))]))]
        [#t (error (format "bad npl expression: ~v" e))]))

;; eval exp
(define (eval-exp e)
  (eval-under-env e null))

(define (ifaunit e1 e2 e3)
  (mlet "v1" e1
        (ifgreater (isaunit (var "v1")) (int 0) e2 e3)))

(define (mlet* lst e2)
  (cond [(null? lst) e2]
        [else
         (mlet (caar lst) (cdar lst)
               (mlet* (cdr lst) e2))]))

(define (ifeq e1 e2 e3 e4)
  (mlet "_x" e1
        (mlet "_y" e2
              (ifgreater
              (ifgreater (var "_x") (var "_y") (int 0) (int 1))
              (ifgreater (var "_y") (var "_x") (int 1) (int 0))
              e3 e4))))

(define npl-map
  (fun "npl-map" "npl-fn"
    (fun "npl-map-partial" "npl-lst"
      (ifaunit (var "npl-lst") (aunit)
               (apair (call (var "npl-fn") (fst (var "npl-lst")))
                      (call (var "npl-map-partial") (snd (var "npl-lst"))))))))

(define npl-mapAddN
  (mlet "map" npl-map
        (fun "npl-AddN" "i"
             (call (var "map") (fun #f "x" (add (var "i") (var "x")))))))

(define npl-filter
  (fun "filter" "fn"
    (fun "filter-partial" "lst"
      (ifaunit (var "lst")
               (aunit)
               (ifeq (call (var "fn") (fst (var "lst")))
                     (int 1)
                     (apair (fst (var "lst"))
                            (call (var "filter-partial") (snd (var "lst"))))
                      (call (var "filter-partial") (snd (var "lst")))
                )
      )
    )
  ))

(define npl-append
  (fun "append" "lst1"
    (fun "append-partial" "lst2"
      (ifaunit (var "lst1")
               (var "lst2")
               (apair (fst (var "lst1"))
                      (call (call (var "append") (snd (var "lst1"))) (var "lst2"))
               )
      )
    )
  ))

(define npl-sort
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
  ))

) ; closing the module
