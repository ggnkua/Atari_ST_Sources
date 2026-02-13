* A4  mein viertes Programm

      lea      str,a1          ;Adresse von str -> a1
loop
      move.b   (a1)+,d0
      cmpi.b   #0,d0           ;ist es das 0-Byte?
      beq      fertig          ;wenn ja, -> fertig
      move     d0,-(sp)        ;Zeichen auf den Stack    
      move     #2,-(sp)        ;Funktion CONOUT
      trap     #1              ;GEMDOS aufrufen
      addq.l   #4,sp           ;Stack korrigieren
      bra      loop            ;branch nach loop
      
    

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



