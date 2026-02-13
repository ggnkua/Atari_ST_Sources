* FAT1 Cluster-Liste aus FAT lesen
 
       move      #2,d1          ;Startcluster
       bsr       print          ;ausgeben
       
loop   lea       fat,a4         ;Zeiger auf FAT
       move      d1,d4          ;Cluster kopieren           
       muls      #3,d1          ; mal 1.5
       asr       #1,d1
       ext.l     d1             ;als Langwort
       add.l     d1,a4          ;  auf Fat-Start addieren
       move.b    1(a4),d1       ;High-Byte in 8088
       asl       #8,d1          ;auf 68000-Position
       move.b    (a4),d1        ;nun Low-Byte hinzu 
       btst      #0,d4          ;teste Entry
       beq       gerade         ;wenn gerade
       asr       #4,d1          ;sonst schiebe
gerade andi      #$FFF,d1       ;nur 12 Bit gueltig
       cmpi      #$FFF,d1       ;Ende der Liste?
       beq       fini           ;wenn so
       bsr       print          ;sonst Cluster drucken
       bra       loop           ;und auf ein Neues
            
fini   move      #1,-(sp)       ;Funktion CONIN
       trap      #1             ;GEMDOS aufrufen
       addq.l    #2,sp          ;Stack korrigieren
       move      #0,-(sp)       ;Funktion TERM(inate)
       trap      #1

print  ext.l     d1            	;force integer
       move      d1,-(sp)       ;nun den Wert 
       pea       buffer         ;wandeln
       bsr       bindec         ;Ergebnis in buffer
       pea       buffer         ;buffer ausgeben
       move      #9,-(sp)       ;mittels PRTLIN-Funktion
       trap      #1
       addq.l    #6,sp 
       rts  

       include   "bindec.s"

       data  
fat    dc.w      $F7FF,$FF03,$4000,$0560,$00FF,$FFFF
       bss
buffer ds.b      6
       end




