* A6  die DBcc-Schleife
* Buchstaben A..Z drucken

        move      #25,d1        ;der Schleifenzaehler

        move      #'A',d2       ;Anfangszustand

loop    move      d2,-(sp)      ;Buchstabe auf Stack
        move      #2,-(sp)      ;Funktion CONOUT
        trap      #1            ;GEMDOS aufrufen
        addq.l    #4,sp         ;Stack korrigieren
        addq      #1,d2         ;naechster Buchstabe
        dbra      d1,loop       ;Siehe Text!

;jetzt warten wir auf einen Tastendruck

       move      #1,-(sp)       ;Funktion CONIN
       trap      #1             ;GEMDOS aufrufen
       addq.l    #2,sp          ;Stack korrigieren

;nun beenden wir das Programm

       move      #0,-(sp)       ;Funktion TERM(inate)
       trap      #1

       end                      ;Anweisung an den Assembler

