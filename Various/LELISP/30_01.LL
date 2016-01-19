(de est-feuille? (arbre)
  (if (not (or (sad arbre) (sag arbre)))
      t
  )
)

(setq arbintest '(5
                   (2 
                     (4
                        ()
                        (3))
                      (8)
                   )
                   (6 
                     (7 
                        () 
                        (9))
                    )
                   )
)
(de sup (x y)
  (if (> x y)
      x
      y
  )
)

(de maximum (arbin)
     (if (arbrevide? arbin)
          (sup (car arbin) (
                     
                   

