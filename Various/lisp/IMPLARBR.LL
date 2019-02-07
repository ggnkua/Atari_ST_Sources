;  ********************** IMPLANTATION ************* 
;  ********************** ARBRE BIN  ***************
;
; ** SELECTEURS **
(de racine (arbin)
  (if (arbrevide? arbin)
    (error 'racine 
           "l'arbre est vide"
           arbin)
    (car arbin)
  )
)

(de sag (arbin)
   (if (arbrevide? arbin)
      (error 'sag
             "l'arbre est vide"
             arbin)
      (cadr arbin)
   )
)

(de sad (arbin)
   (if (arbrevide? arbin)
      (error 'sad
             "l'arbre est vide"
             arbin)
      (caddr arbin)
    )
)

; **** L'ARBRE VIDE *****

; variable globale
 (setq arbrevide ())
; on peut aussi le creer
 (de creerarbrevide ()
    ()
 )
; ******** CONSTRUCTEUR *****
(de embranche (racine . l)
  (cond ((or (null l)
             (and l (null (car l)) (null (cadr l))))
         (list racine))
        ((and (car l) (or (null (cdr l)) (null (cadr l))))
         (if (est-arbin? (car l))
            (list racine (car l))
            (error 'embranche
                   "le 2eme argument n'est pas un arbre"
                   (car l)))) 
        (t (if (and (est-arbin? (car l))
                    (est-arbin? (cadr l)))
              (cons racine l)
              (error 'embranche
                     (catenate "les 2emes et 3emes arguments"
                               "doivent etre des arbres")
                     l)))
   )
)

;;; le predicat de reconnaissance de l'arbre vide ;;;;

(de arbrevide? (arbin)
  (if (est-arbin? arbin)
    (null arbin)
    (error 'arbrevide?
           "l'argument n'est pas un arbre"
           arbin)
   )
)

;;;;;;;;;;;;; exemples ;;;;;;;;

(setq arbinex '(et
                  (ou
                     (or
                        ()
                        (ni)))
                   (mais
                      (car
                          (alors))
                      (si
                         ()
                         (sinon)))
                )
)

;;;;;;  Fonctions ;;;;;;;;;;;;;;;;;;;

(de dnbr (arbin)
  (if (arbrevide? arbin)
    0
    (+ 1 (dnbr (sag arbin)) (dnbr (sad arbin))))
)
 
(de miroir (arbin)
  (if (not (arbrevide? arbin))
    (embranche (racine arbin)
               (miroir (sad arbin))
               (miroir (sag arbin)))
   )
)

(de est-arbin? (arbin)
  t
)

