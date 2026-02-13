*A7  Zeile lesen, Text ausgeben

loop                            ;Endlos-Schleife
                                ;Abruch mit Control_C

       lea       frage,a0       ;Adresse 'Wie heisst Du? ' 
       bsr       print          ;Unterprogramm aufrufen
       

;nun eine Zeile lesen:
       move.b    #80,puffer     ;max. Lange Eingabe
       pea       puffer         ;Pufferadresse -> Stack
       move      #10,-(sp)      ;Funktion READ LINE
       trap      #1             ;GEMDOS aufrufen
       addq.l    #6,sp          ;Stack koorigieren
       move      d0,d1          ;merke Ist-Laenge

       lea       antwrt,a0      ;Adresse 'Guten Tag'
       bsr       print          ;und drucken
       lea       puffer,a0      ;Adresse Puffer
       move.b    #0,2(a0,d1)    ;markiere String-Ende
       addq.l    #2,a0          ;auf Begin Text
       bsr       print          ;und drucken

       bra       loop           ;auf ein Neues

print  pea       (a0)           ;Adresse Text-String
       move      #9,-(sp)       ;Funktion PRINT LINE
       trap      #1          
       addq.l    #6,sp
       rts

       data
frage  dc.b     13,10,'Wie heisst Du? ',0
       ds.w     0
antwrt dc.b     13,10,'Guten Tag, ',0

       bss
puffer ds.b     80
       
       end
