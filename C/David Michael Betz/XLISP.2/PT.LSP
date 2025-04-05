; This is a sample XLISP program.
; It implements a simple form of programmable turtle
; It only works on the Macintosh version of XLISP at the moment.

; To run it:

;	(load "pt.lsp")

; This should cause the screen to be cleared and two turtles to appear.
; They should each execute their simple programs and then the prompt
; should return.  Look at the code to see how all of this works.

; Get some more memory
(expand 1)

; ::::::::::::
; :: Turtle ::
; ::::::::::::

; Define "Turtle" class
(setq Turtle (send Class :new '(xpos ypos)))

; Answer ":isnew" by initing a position and char and displaying.
(send Turtle :answer :isnew '(x y) '(
    (setq xpos x)
    (setq ypos y)
    (send self :display)
    self))

; Message ":display" prints its char at its current position
(send Turtle :answer :display '() '(
    (moveto xpos ypos)
    (lineto xpos ypos)
    self))

; Message ":goto" goes to a new place after clearing old one
(send Turtle :answer :goto '(x y) '(
    (moveto xpos ypos)
    (setq xpos x)
    (setq ypos y)
    (lineto xpos ypos)
    self))

; Message ":up" moves up
(send Turtle :answer :up '() '(
    (send self :goto xpos (- ypos 10))))

; Message ":down" moves down
(send Turtle :answer :down '() '(
    (send self :goto xpos (+ ypos 10))))

; Message ":right" moves right
(send Turtle :answer :right '() '(
    (send self :goto (+ xpos 10) ypos)))

; Message ":left" moves left
(send Turtle :answer :left '() '(
    (send self :goto (- xpos 10) ypos)))


; :::::::::::::
; :: PTurtle ::
; :::::::::::::

; Define "DPurtle" programable turtle class
(setq PTurtle (send Class :new '(prog pc) '() Turtle))

; Message ":program" stores a program
(send PTurtle :answer :program '(p) '(
    (setq prog p)
    (setq pc prog)
    self))

; Message ":step" executes a single program step
(send PTurtle :answer :step '() '(
    (if (null pc)
	(setq pc prog))
    (if pc
	(progn (send self (car pc))
	       (setq pc (cdr pc))))
    self))

; Message ":step:" steps each turtle program n times
(send PTurtle :answer :step: '(n) '(
    (dotimes (x n) (send self :step))
    self))


; ::::::::::::::
; :: PTurtles ::
; ::::::::::::::

; Define "PTurtles" class
(setq PTurtles (send Class :new '(turtles)))

; Message ":make" makes a programable turtle and adds it to the collection
(send PTurtles :answer :make '(x y &aux newturtle) '(
    (setq newturtle (send PTurtle :new x y))
    (setq turtles (cons newturtle turtles))
    newturtle))

; Message ":step" steps each turtle program once
(send PTurtles :answer :step '() '(
    (mapcar #'(lambda (turtle) (send turtle :step)) turtles)
    self))

; Message ":step:" steps each turtle program n times
(send PTurtles :answer :step: '(n) '(
    (dotimes (x n) (send self :step))
    self))


; Create some programmable turtles
(setq turtles (send PTurtles :new))
(setq t1 (send turtles :make 200 100))
(setq t2 (send turtles :make 210 100))
(send t1 :program '(:left :left :up :right :up))
(send t2 :program '(:right :right :down :left :down))
(show-graphics)
(send turtles :step: 20)
