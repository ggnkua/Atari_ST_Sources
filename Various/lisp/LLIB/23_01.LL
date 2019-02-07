;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FIBONACCI ;;;;;;;;;;;;;;;;;;;;
(de fibonacci (n)
  (or (<= n 1)
      (+ (fibonacci (1- n))
         (fibonacci (- n 2))
       )
   )
)  

;;;;;;;;;;;;;; DECOMPTE DU NBR D'APPELS ;;;;;;;;;;;;;;;;;;;;
(de testfib ()
  (putprop 'fib 0 'nbappels)
  (fib 5)
  (getprop 'fib 'nbappels)
)

(de fib (n)
  (putprop 'fib (+ 1 (getprop 'fib 'nbappels)) 'nbappels)
  (or (<= n 1)
      (+ (fib (1- n))
         (fib (- n 2))
      )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(de fibmemo (n)
  (or (<= n 1)
      (getprop 'fibmemo n)
      (getprop
         (putpropsymb 'fibmemo
                       (+ (fibmemo (1- n)) (fibmemo (- 2 n)))
                       n)
          n)
   )
)

(de putpropsymb (symb valeur indicateur)
  (putprop symb valeur indicateur)
  symb
)






