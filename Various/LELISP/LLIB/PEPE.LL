; .EnTete "Le_Lisp version 15" " " "L'‚diteur vid‚o PEPE"

; .Chapitre 14 "L'‚diteur vid‚o PEPE"
; .Auteur "J‚r“me Chailloux"
; .INRIA

; Adaptation d'ACT Informatique pour l'IBM PC par Christian Jullien.

(unless (= (version) 15)
        (error 'load "fichier non compatible" 'pepe))

; Tous les symboles pr‚c‚d‚s de : seront cr‚‚s
; dans le package PEPE.

(defvar #:sys-package:colon 'pepe)

; PEPE  est l'‚diteur minimum de Le_Lisp version 15. 
; Il permet d'‚diter des fichiers ou n'importe quelle
; expression Lisp. Il fonctionne sur tout terminal vid‚o
; qui doit au moins permettre l'effacement de tout
; l'‚cran et le positionnement absolu du curseur.

; Le tampon de PEPE est une liste de chaŒnes de caractŠres,
; chacunes d'elles repr‚sentant une ligne.
; Cette repr‚sentation qui a le m‚rite de la simplicit‚
; entrainera la fabrication d'une nouvelle chaŒne pour chaque
; caractŠre tap‚.

; PEPE, tout comme EMACS, garde les propri‚t‚s suivantes\ :
;  - ‚crit entiŠrement en Lisp
;  - extensible trŠs facilement
;  - ind‚pendant vis-…-vis du mat‚riel
;  - reaffichage asynchrone.

; Le terminal virtuel doit ˆtre charg‚ et initialis‚ 
; avant de lire ce fichier par exemple au moyen de :
;       (initty)

; .Section "Les Variables Globales"

(defvar :buffer ())         ; le tampon des lignes
(defvar :xcursor 0)         ; X courant
(defvar :ycursor 0)         ; Y courant
(defvar :column 0)          ; colonne courante
(defvar :ydisplay 0)        ; num‚ro de la 1Šre ligne visible
(defvar :file "tmp")        ; nom du fichier courant
(defvar :commands ())       ; liste des commandes
(defvar :escommands ())     ; liste des ESC-commandes
(defvar :modbuf ())         ; indicateur de tampon modifi‚
(defvar :kill ())           ; la chaŒne du dernier kill
(defvar :searchstrg "")     ; la chaŒne de la derniŠre recherche

; .Section "La Boucle Principale"

(df pepe (:f)
    ; la forme FSUBR‚e de la fonction suivante
    (pepefile :f))

(de pepefile (:f)
    ; la fonction qui ‚value son nom de fichier
    (let ((#:tty:xmax+1  (1+ #:tty:xmax))
          (#:tty:-xmax+1 (- (1+ #:tty:xmax)))
          (#:tty:xmax-1  (1- #:tty:xmax))
          (#:tty:ymax+1  (1+ #:tty:ymax))
          (#:tty:ymax-1  (1- #:tty:ymax))
          (#:tty:xmax+1*ymax (* (1+ #:tty:xmax) #:tty:ymax)))
       (let ((oscreen (makestring (* #:tty:xmax+1 #:tty:ymax+1) #\sp))
             (nscreen (makestring (* #:tty:xmax+1 #:tty:ymax+1) #\sp)))
            (:clrscreen)
            (ifn :f
                 (unless :buffer (setq :buffer (list "")))
                 (setq :file "tmp"
                       :xcursor 0 :ycursor 0
                       :column 0 :ydisplay 0
                       :modbuf ())
                 (cond
                     ((equal :f t)
                       ; je veux un fichier scratch
                       (setq :buffer (list "")))
                     ((atom :f)
                       ; ce doit ˆtre un fichier qui existe
                       (tag eoc (setq :buffer (:readfile :f)))
                       (setq :file (string :f)))
                     (t ; c'est donc un PROGN … ‚valuer
                       (setq :buffer (list ""))
                       (let ((#:sys-package:itsoft ':eval))
                            (eval :f))
                       (setq :buffer (nreverse :buffer)))))
            (typrologue)
            (:menu)
            ;
            ; le top-level proprement dit de PEPE
            ;
            (untilexit pepe
               (tag eoc
                    (:redisplay)
                    (tycursor :xcursor :ycursor)
                    (:pepecmd (:tyi))))
            ; je sors de PEPE : qu'Il soit avec vous!
            (tycursor 0 (1+ #:tty:ymax))
            (tycleol)
            (tycursor 0 #:tty:ymax)
            (tycleol)
            (tyepilogue)
            (tyflush)
            'pepe))))))

(de :eval:eol ()
    ; r‚cup‚ration de la ligne imprim‚e
    ; s'il faut ‚diter le r‚sulat d'une ‚valuation
    (newl :buffer (substring (outbuf) 0 (outpos)))
    (fillstring (outbuf) 0 #\sp (outpos))
    (outpos (lmargin)))

; .Section "Les interprŠtes des commandes"

(de :pepecmd (c)
    ; interprŠte la commande <c>
    ; la A-liste des commandes se trouve dans :commands
    (let ((l (cassq c :commands)))
         (if l (eprogn l)
             ; ce n'est pas une commande
             (if (< c 32)
                 (:deadend)
                 (:insertchar c))))
    (when (setq c (tys))
          (:pepecmd c)))

(de :escommand ()
    ; L'interprŠte des commandes <esc> X
    ; la A-Liste des commandes se trouve dans :escommands
    (let ((c (:tyi)))
         ; passage en majuscule
         (when (and (>= c #/a) (<= c #/z))
               (decr c 32))
         (let ((l (cassq c :escommands)))
              (if l (eprogn l) (:deadend)))))

; .Section "Les fonctions d'affichage"

; A de rares exceptions, ces fonctions n'utilisent pas
; les fonctions du terminal virtuel mais la fonction de
; reaffichage asynchrone REDISPLAYSCREEN.

(de  :redisplay ()
     ; reaffiche toute la fenˆtre visible
     (fillstring nscreen 0 #\SP)
     (let ((y #:tty:-xmax+1)
           (s (length :buffer))
           (l (nthcdr :ydisplay :buffer)))
          (repeat #:tty:ymax
                  (bltstring nscreen (incr y #:tty:xmax+1) 
                             (car l) 0 #:tty:xmax+1)
                  (when (> (slength (nextl l)) #:tty:xmax+1)
                        (chrset (+ y #:tty:xmax) nscreen #/\)))
          (:fillminibuf 0 
                 "Pepe :                        lignes  <M>")
          (:fillminibuf 7 :file)
          (:fillminibufnb (+ #:tty:xmax+1*ymax 28) s)
          (when (<= s 1) 
                (chrset (+ #:tty:xmax+1*ymax 35) nscreen #\sp ))
          (unless :modbuf (:fillminibuf 38 "   "))
          (:trueredisplay)))

(dmd :trueredisplay ()
     `(redisplayscreen nscreen oscreen #:tty:xmax+1 #:tty:ymax+1))

(dmd :fillminibuf (x strg)
     ; ‚crit dans la derniŠre ligne … partir de <x> la chaŒne <strg>
     `(bltstring nscreen 
         (+ #:tty:xmax+1*ymax ,x) ,strg 0))

(de  :fillminibufnb (pos nb)
     ; ‚crit dans nscreen … partir de <x> la valeur num‚rique <nb>
     (if (< nb 10)
         (chrset pos nscreen (+ #/0 nb))
         (:fillminibufnb (1- pos) (div nb 10))
         (chrset pos nscreen (+ #/0 (rem nb 10)))))

(de :clrscreen () 
    ; efface tout l'‚cran
    (tycursor 0 0) 
    (tycls)
    (fillstring oscreen 0 #\sp)
    (:menu))

; .Section "Les fonctions de dialogue"

(de :more ()
    ; demande s'il faut continuer les impressions.
    (:fillminibuf 42 "Encore ? ")
    (:trueredisplay) 
    (tycursor 50 #:tty:ymax)
    (unless (chrpos (:tyi) " YyOoTt") (exit eoc))
    (:fillminibuf 42 "         "))

(de :readname (strg)
    ; Lecture d'une chaŒne sur le terminal
    ; <strg> est la chaŒne d'invite
    (:fillminibuf 42 strg)
    (let ((l) (c) (p (+ 42 (slength strg))))
         (:trueredisplay)
         (tycursor p #:tty:ymax)
         (while (neq (setq c (:tyi)) #^M)
                (cond ((eq c #^G) (exit eoc ()))
                      ((eq c #\bs) 
                       (:fillminibuf (decr p) " ") (decr p) (nextl l))
                      (t (:fillminibuf p (list c)) (newl l c)))
                (:trueredisplay)
                (tycursor (incr p) #:tty:ymax))
         (if l (string (nreverse l)) (exit eoc "")))))

; .Section "Les Fonctions Auxiliaires"

(dmd :deadend ()
     ; fin de la route : on ne plus plus bouger!
     `(progn (tybeep) (exit eoc)))

(dmd :currentline ()
     ; retourne la ligne courante
     `(nth (+ :ydisplay :ycursor) :buffer))

(dmd :currentlines ()
     ; retourne la liste commencant par la ligne courante
     `(nthcdr (+ :ydisplay :ycursor) :buffer))

(dmd :cursor (x y)
     ; change la position du curseur de PEPE
     `(setq :xcursor ,x :ycursor ,y))

; .Section "Une Brouette de Pr‚dicats Utiles"

(dmd :tyi ()
     ; trappe les caractŠres de contr“le sous ms/dos
     '(until (tys)))

(dmd :bolp ()
     ; teste si on se trouve en d‚but de ligne
     `(= :xcursor 0)))

(dmd :eolp ()
     ; teste si on se trouve en fin de ligne
     `(>= :xcursor (slength (:currentline))))

(dmd :bobp ()
     ; teste si on se trouve en d‚but de buffer
     `(and (= :ydisplay 0) (= :ycursor 0)))

(dmd :eobp ()
     ; teste si on se trouve en fin de buffer
     `(>= (+ :ydisplay :ycursor 1) (length :buffer)))

(dmd :bosp ()
     ; teste si on se trouve au d‚but de l'‚cran
     `(= :ycursor 0))

(dmd :eosp ()
     ; teste si on se trouve … la fin de l'‚cran
     `(>= :ycursor #:tty:ymax-1))

; .Section "Les Commandes de Base de PEPE"

(de :left ()
    ; un coup … gauche
    (ifn (:bolp)
         (setq :column (decr :xcursor))
         (:up) (:endline)))

(de :right ()
    ; un coup … droite
    (ifn (:eolp)
         (if (>= :xcursor #:tty:xmax)
             (:deadend)
             (setq :column (incr :xcursor)))
         (:begline) 
         (:down)))

(de :endline ()
    ; va … la fin de la ligne
    (setq :xcursor (min (slength (:currentline)) #:tty:xmax)
          :column :xcursor))

(de :begline ()
    ; va au d‚but de la ligne
    (setq :xcursor 0 :column 0)))

(de :up ()
    ; va … la ligne pr‚c‚dente
    (if (:bobp)
        (:deadend)
        (ifn (:bosp)
             (setq :ycursor (1- :ycursor)
                   :xcursor (min :column
                                     (slength (:currentline))))
             (decr :ydisplay 6)
             (incr :ycursor 5)
             (when (< :ydisplay 0)
                   (setq :ydisplay 0 :ycursor 0)))))

(de :down ()
    ; va … la ligne suivante
    (if (:eobp)
        (:deadend)
        (ifn (:eosp)
             (setq :ycursor (1+ :ycursor)
                   :xcursor (min :column
                                 (slength (:currentline))))
             (incr :ydisplay 6)
             (decr :ycursor 5))))

(de :nextscreen ()
    ; passe … l'‚cran suivant
    (when (> (+ :ydisplay #:tty:ymax-1) (length :buffer))
          (:deadend))
    (incr :ydisplay #:tty:ymax-1)
    (:begline))

(de :prevscreen ()
    ; passe … l'‚cran pr‚c‚dent
    (when (< (decr :ydisplay  #:tty:ymax-1) 0) 
          (setq :ydisplay 0))
    (:begline))

(de :insertchar (c)
    ; rajoute le caractŠre <c> … la position courante
    (if (>= :xcursor #:tty:xmax)
        (:deadend)
        (slet ((l (:currentlines))
               (s (catenate " " (car l))))
              (bltstring s 0 s 1 (1+ :xcursor))
              (chrset :xcursor s c)
              (rplaca l s))
        (setq :column (incr :xcursor) :modbuf t)))

(de :deletechar ()
    ; enlŠve le caractŠre … la position du curseur
    (let ((l (:currentlines)) 
          (s))
         (if (:eolp)
             (rplac l (catenate (car l) (cadr l)) (cddr l))
             (setq s (makestring (1- (slength (car l))) #\sp))
             (bltstring s 0 (car l) 0 :xcursor)
             (bltstring s :xcursor (car l) (1+ :xcursor))
             (rplaca l s)))
    (setq :modbuf t))

(de :breakline ()
    ; casse la ligne … la position du curseur
    (let ((l (:currentlines)))
         (ifn (:eolp)
              (rplac l (substring (car l) 0 :xcursor)
                       (cons (substring (car l) :xcursor) (cdr l)))
              (rplacd l (cons "" (cdr l))))
         (setq :modbuf t)))

(de :killine ()
    ; d‚truit la ligne courante
    (if (:bobp)
        (if (cdr :buffer)
            (setq :kill (nextl :buffer))
            (setq :buffer (list "")))
        (let ((l (:currentlines)))
             (setq :kill (car l))
             (rplac l (cadr l) (cddr l))))
    (setq :modbuf t)
    (if (:eobp)
        (or (:bobp) (:up))
        ; et l'autre cas si la ligne est plus petite
        (when (< (slength (:currentline)) :xcursor)
               (:endline))))

; .Section "Les Fonctions de Recherche"

(de  :search ()
     ; cherche une chaŒne de caractŠres
     (let ((s (tag eoc (:readname "chaine: ")))
           (f (:currentlines))
           (ind :xcursor))
          (cond ((null s) (exit eoc))
                ((eqstring s "") (setq s :searchstrg))
                (t (setq :searchstrg s)))
          (untilexit search
             (let ((r (index s (nextl f) ind)))
                  (cond
                   (r (setq :xcursor (+ r (slength s)))
                      (let ((l1 (length (:currentlines)))
                            (l2 (1+ (length f))))
                           (if (> (+ :ycursor (- l1 l2)) #:tty:ymax-1)
                               (setq :ydisplay (- (length :buffer) l2 2)
                                     :ycursor 2)
                               (setq :ycursor (+ :ycursor (- l1 l2)))))
                      (exit search))
                   ((null f) (exit search (:deadend)))
                   (t (setq ind 0)))))))

(de :matchparent (x)
    ; V‚rificateur de parenthŠses … la Lisp
    ; x peut ˆtre une parenthŠse ou un crochet.
    (tag fin (until (= (:curlexnext) x))))

(de :curlexnext ()
    (let ((char (:curchar)))
         (:right)
         (selectq char
                 (#/( (until (= (:curlexnext) #/))))
                 (#/[ (until (= (:curlexnext) #/])))
                 (#/" (until (= (:curchar) #/") (:right))
                      (:right))
                 (#/# (selectq (:curchar)
                         ((#/( #/[ #/") (:curlexnext))
                         (#// (:right))
                         (t ())))
                 (#/; (:left) (:begline) (:down))
                 (t ()))
         char))

(de :curchar ()
    (let ((line (:currentline)))
         (if (or (<= (slength line) :xcursor) 
                 (eqstring line ""))
             0
             (chrnth :xcursor line))))

; .Section "Les Fonctions sur les Fichiers"

(de :readfile (f)
    ; Lecture d'un fichier : retourne une liste (non vide) 
    ; de lignes d'au plus #:tty:xmax caractŠres.
     (let ((ll) (in (catcherror () (openi f))))
          (if (consp in)
              ; c'est un fichier connu
              (with ((inchan (car in)))
                    (inmax 0)
                    (untilexit eof (newl ll (readstring)))
                    (if (consp ll) (nreverse ll) (list "")))
              ; c'est un nouveau fichier
              (tybeep)     	;  pour indiquer une cr‚ation!
              (list ""))))

(de :writefile (f)
    ; Ecriture d'un fichier
     (let ((out (catcherror () (openo f))))
       (unless (consp out) (:deadend))
       (with ((outchan (car out)))
             (let ((:xcursor :xcursor)
                   (:ycursor :ycursor)
                   (#:system:print-for-read ()))
                  (:cursor 33 #:tty:ymax)
                  (with ((rmargin #:tty:xmax+1))
                        (mapc 'print :buffer))
                  (print '^Z))     ; termine proprement un fichier ascii
             (close (outchan)))    ; Redde Caesari quae sunt Caesaris !
       (setq :modbuf ())))

(de  :insertfile ()
     ; Insert un fichier … la position du curseur.
     (let ((l (:currentlines)))
          (rplacd l (nconc (:readfile (:readname "fichier? "))
                           (cdr l)))
          (setq :modbuf t)))

(de :backup ()
    ; Sauvegarde le tampon courant.
    (let ((index (index "." :file)) (:backup ))
         (setq :backup (catenate (if index
                                         (substring :file 0 index)
                                         :file)
                                     ".BAK"))
         (when (probefile :backup)
               ; Il avait d‚ja un fichier ".BAK", on l'‚fface
               (deletefile :backup))
         (when (probefile :file)
               ; Il avait d‚ja un fichier :file
               (renamefile :file :backup))))

(de  :help ()
     ; affiche un aide m‚moire des commandes.
     (let ((:ycursor :ycursor)
           (y #:tty:-xmax+1)
           (in))
          (unless (catcherror () 
                     (setq in (openi (catenate #:system:llib-directory
                                               'pepehelp
                                               #:system:lelisp-extension))))
                  (:deadend))
          (:clrscreen)
          (with ((inchan in))
                (fillstring nscreen 0 #\SP)
                (untilexit eof
                  (bltstring nscreen (incr y #:tty:xmax+1) 
                             (readstring) 0 #:tty:xmax+1)))
          (:fillminibuf 0 "Aide memoire de PEPE"))
     ; attend la frappe d'un caractŠre pour continuer
     (tag eoc (:more))
     (:clrscreen))


(de #:pepe:menu ()
    (tycursor 0 24)
    (flet ((pitem
                 (n msg)
                 (tyattrib 10)
                 (tyo (explode n))
                 (tyattrib 120)
                 (tyo (explode msg))
                 (tyattrib 7)
                 (tyo #/ )))
          (pitem 1 "HELP ")
          (pitem 2 "SEARCH")
          (pitem 3 " EVAL ")
          (pitem 4 " EXIT ")
          (pitem 5 " SAVE ")
          (pitem 6 " READ ")
          (pitem 7 "INSERT")
          (pitem 8 "WRITE ")
          (pitem 9 "CHANGE")
          (pitem 0 "MATCH)")))

          
; .Section "Les Autres Fonctions"

(de :evalbuffer ()
    ; Evaluation de tout le tampon sans sortir de PEPE
    ; ind‚pendant du format des lignes.
    ; Toutes les impressions vont sur le terminal trŠs proprement
    (let ((#:sys-package:itsoft ':evalbuffer)
          (:buffer :buffer) ; sauvetage du tampon
          (xy #:tty:-xmax+1))
         (with ((lmargin 0)
                (rmargin #:tty:xmax-1))
               (tycursor 0 0) 
               (tyflush)
               (untilexit eoc (print "=> " (eval (read))))
               (:more))))

(de  :evalbuffer:bol ()
     ; nouvelle ligne en entr‚e sous EVALBUFFER
     (ifn :buffer
          (exit eoc)
          (slet ((l (nextl :buffer)) 
                 (n (slength l)))
                (bltstring (inbuf) 0 l)
                (chrset n (inbuf) #\cr)
                (chrset (incr n) (inbuf) #\lf)
                (inmax (incr n)))))

(de  :evalbuffer:eol ()
     ; ITSOFT fin de ligne sous EVALBUFFER
     (fillstring nscreen (incr xy #:tty:xmax+1) #\sp #:tty:xmax+1)
     (bltstring nscreen xy (outbuf) 0 (outpos))
     (fillstring (outbuf) 0 #\sp (outpos))
     (outpos (lmargin))
     (when (>= xy (* #:tty:xmax+1 #:tty:ymax-1))
           (:more) 
           (setq xy #:tty:-xmax+1)))

; .Section "Initialisation des Clefs"

(df defkey (k . f)     (newl :commands (cons (eval k) f)))

(progn

        (defkey  #^@          (eval
                                 (cassq (tyi)
                                   '((#/; . (:help))
                                     (#/< . (:search))
                                     (#/= . (:evalbuffer))
                                     (#/> . (exit pepe))
                                     (#/? . (eprogn (cassq #/S :escommands)))
                                     (#/@ . (eprogn (cassq #/R :escommands)))
                                     (#/A . (:insertfile))
                                     (#/B . (eprogn (cassq #/W :escommands)))
                                     (#/C . (eprogn (cassq #/F :escommands)))
                                     (#/D . (:matchparent #/( ))
                                     (#/G . (eprogn (cassq #/< :escommands)))
                                     (#/H . (:up))
                                     (#/I . (:prevscreen))
                                     (#/K . (:left))
                                     (#/M . (:right))
                                     (#/O . (eprogn (cassq #/> :escommands)))
                                     (#/P . (:down))
                                     (#/Q . (:nextscreen))))))

        (defkey  #^A          (:begline))
        (defkey  #:tty:left   (:left))
        (defkey  #^C          (exit pepe))
        (defkey  #^D          (:deletechar))
        (defkey  #^E          (:endline))
        (defkey  #:tty:right  (:right))
        (defkey  #^G          (:deadend))
        (defkey  #^H          (:left) 
                              (:cursor :xcursor :ycursor) 
                              (:deletechar))
        (defkey  #^K          (:killine))
        (defkey  #^L          (:clrscreen))
        (defkey  #^M          (:breakline) (:right))
        (defkey  #:tty:down   (:down))
        (defkey  #^O          (:breakline))
        (defkey  #:tty:up     (:up))
        (defkey  #^S          (:search))
        (defkey  #^V          (:nextscreen))
        (defkey  #^Y          (:breakline)
                              (:cursor :xcursor :ycursor)
                              (mapc ':insertchar 
                                    (pname :kill)))
        (defkey  #$7F         (:left) 
                              (:cursor :xcursor :ycursor) 
                              (:deletechar))
        (defkey  27           (:escommand))
)

(df defesckey (k . f)     (newl :escommands (cons k f)))

(progn

        (defesckey  #/E    (:evalbuffer))
        (defesckey  #/F    (setq :file 
                                 (:readname "Nom de fichier? ")))
        (defesckey  #/I    (:insertfile))
        (defesckey  #/R    (setq :file (:readname "Fichier? ")
                                 :buffer  (:readfile :file)
                                 :xcursor 0 :ycursor  0
                                 :column  0 :ydisplay 0
                                 :modbuf  ()))
        (defesckey  #/S    (:backup) (:writefile :file))
        (defesckey  #/V    (:prevscreen))
        (defesckey  #/W    (:writefile (:readname "Fichier? ")))
        (defesckey  #/X    (apply (or (getfn '#.#:sys-package:colon 
                                             (concat (:readname
                                                         "Fonction? ")))
                                      ':deadend)
                                  ()))
        (defesckey  #/Z    (:writefile :file)
                           (tycursor 0 #:tty:ymax)
                           (loadfile :file t)
                           (exit pepe))
        (defesckey  #/)    (:matchparent #/())
        (defesckey  #/]    (:matchparent #/[))
        (defesckey  #/<    (setq :ydisplay 0 :xcursor 0 :ycursor 0 :column 0))
        (defesckey  #/>    (setq :ycursor  (length :buffer)
                                 :ydisplay (max 0 (- :ycursor
                                                     (div #:tty:ymax 2)))
                                 :ycursor (- :ycursor :ydisplay 1))
                           (:endline))

        (defesckey  #/?    (:help))
))

; .Section "Pour R‚cup‚rer la Place de PEPE"

(de  pepend ()
     ; d‚truit tous les symboles de :...
     (mapc 'remob (oblist '#.#:sys-package:colon))
     ; red‚finit les fonctions autoload
     (libautoload pepe pepe pepefile))
