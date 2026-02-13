* A2  mein zweites Programm

      lea      str,a1          ;Adresse von str -> a1
      move     (a1)+,-(sp)     ;das h auf den Stack
      move     #2,-(sp)        ;Funktion CONOUT
      trap     #1              ;GEMDOS aufrufen
      addq.l   #4,sp           ;Stack korrigieren

      move    (a1)+,-(sp)      ;das a auf den Stack
      move     #2,-(sp)        ;Funktion CONOUT
      trap     #1              ;GEMDOS aufrufen
      addq.l   #4,sp           ;Stack korrigieren

;u.s.w. mit l l o 

;jetzt warten wir auf einen Tastendruck

      move      #1,-(sp)       ;Funktion CONIN
      trap      #1             ;GEMDOS aufrufen
      addq.l    #2,sp          ;Stack korrigieren

;nun beenden wir das Programm

      move      #0,-(sp)       ;Funktion TERM(inate)
      trap      #1

      data
str   dc.b      ' h a l l o '

      end                      ;Anweisung an den Assembler



