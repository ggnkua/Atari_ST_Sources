;******************* CONSTRUCTION A DROITE ************************
(de consdroite (liste element)
  (if (null liste)
      (list element)
      (cons  (car liste) (consdroite (cdr liste) element) )
  )
)
;******************* MOYENNE GENERALISEE (+ de 2 elts) **************
(de somme (liste)
   (if  (null liste)
         0
        (+ (car liste)
           (somme (cdr liste))
        )
   )
)

(de moyenne (n1 n2 . lvar)
 (/ (+ n1 n2 (somme lvar))
    (+ 2 (length lvar))
 )
)
;******************* MOYENNE GENERALISEE (n elts . n>=0) ***********
(de moyennegen ( . lvar)
  (if (null lvar)
         '(Liste Vide)
      (div (somme lvar) (length lvar))
  )
)
;******************* AUGMENTE LES NOTES DE 2 ************************
(de augmente (liste)
  (if (null liste)
    ()
    (cons (+ 2 (car liste)) (augmente (cdr liste)))
  )
)
;******************* AUGMENTE  LES NOTES (lvar) DE 2 ****************
(de augmentebis ( . lvar)
  (if (null lvar)
    ()
    (cons (+ 2 (car lvar)) (augmentebis ( . (cdr lvar)))
  )
)   

