* A5  mein fuenftes Programm

      pea      str             ;Adresse von str auf den Stack
      move     #9,-(sp)        ;Funktion 'Print Line'
      trap     #1              ;GEMDOS aufrufen
      addq.l   #6,sp           ;Stack korrigieren

;jetzt warten wir auf einen Tastendruck

fertig
      move      #1,-(sp)       ;Funktion CONIN
      trap      #1             ;GEMDOS aufrufen
      addq.l    #2,sp          ;Stack korrigieren

;nun beenden wir das Programm

      move      #0,-(sp)       ;Funktion TERM(inate)
      trap      #1

      data
str   dc.b      'hallo'
      dc.b      0              ;ein Nullbyte markiert 
                               ;String-Ende !!!!!!!!!

      end                      ;Anweisung an den Assembler



