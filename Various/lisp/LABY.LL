;;; CODAGE DU LABYRINTHE ;;;

(setq laby '( (a1 * b1)       (b1 a1 b2)         (c1 c2 d1)
              (a2 a3 b2)      (b2 a2 b1)         (c2 c3 c1)
              (a3 a4 b3 a2)   (b3  a3)           (c3 d3 c2)
              (a4 a5 a3)      (b4 b5 c4)         (c4 b4 d4)
              (a5 a6 a4)      (b5 b6 b4)         (c5 c6 d5)
              (a6 a7 a5)      (b6 b5)            (c6 d6 c5)
              (a7 b7 a6)      (b7 a7 c7)         (c7 b7 d7)

              (d1 c1 e1)      (e1 d1 f1)         (f1 e1 f2)
              (d2 c2 e2)      (e2 d2 e3)         (f2 f1 f3)
              (d3 c3 e3)      (e3 d3 e4 e2)      (f3 f2 f4)
              (d4 c4 e4)      (e4 d4 e5 e3)      (f4 f3 f5)
              (d5 c5)         (e5 e6 e4)         (f5 f4 f6)
              (d6 c6 d7 e6)   (e6 d6 e5)         (f6 f5 f7)
              (d7 c7 d6)      (e7 f7)            (f7 e7 f6)
            )
)
;;;          VERSION CONSTRUCTION/DECONSTRUCTION A GAUCHE

(de thes (case liste)
  (cond
   ((equal case ()) 
     (thes (cadr (member (car  liste) (cassq (cadr liste) laby) ))
           (cdr liste)))
   ((member case liste)
     (thes (cadr (member case (cassq (car liste) laby))) liste))
   ((equal case '*) liste)
   (t (thes (car (cassq case laby)) (cons case liste )))
  )
)

(de thesee (case)
    (reverse (thes case ()))
)
