* A1 mein erstes Programm

       move     #'h',-(sp)     ;das 'h' soll gedruckt werden
       move     #2,-(sp)       ;Funktion CONOUT
       trap     #1             ;GEMDOS aufrufen
       addq.l   #4,sp          ;Stack Pointer auf Ausgangswert
  

       move     #'a',-(sp)     ;das 'a' soll gedruckt werden
       move     #2,-(sp)       ;Funktion CONOUT
       trap     #1  
       addq.l   #4,sp          ;Stack Pointer auf Ausgangswert
  

;nun machen Sie weiter mit l l o

;jetzt warten wir auf einen Tastendruck

      move      #1,-(sp)       ;Funktion CONIN
      trap      #1             ;GEMDOS aufrufen
      addq.l    #2,sp          ;Stack korrigieren

;nun beenden wir das Programm

      move      #0,-(sp)       ;Funktion TERM(inate)
      trap      #1

      end                      ;Anweisung an den Assembler



