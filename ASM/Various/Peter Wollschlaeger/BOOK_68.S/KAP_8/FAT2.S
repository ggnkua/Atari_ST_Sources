* FAT2  Cluster-Liste aus FAT lesen
  
       lea       fat,a4         ;Zeiger auf FAT
       move      #2,d1          ;Startcluster
       bsr       print          ;ausgeben
       
loop   move      d1,d4                
       muls      #3,d1          ; mal 1.5
       asr       #1,d1
       move      d1,d2          ;retten
       bclr      #0,d1          ;auf Wort justieren
       move.l    0(a4,d1),d1    ;aus FAT lesen
       asr.l     #8,d1          ;8 Bit immer
       btst      #0,d2          ;wurde auf Wort justiert?
       bne       s8             ;wenn nicht
       asr.l     #8,d1          ;sonst noch 8 Bit schieben
s8     move      d1,d2          ;vertausche low high
       asl       #8,d1          
       asr       #8,d2
       move.b    d2,d1          ;nun 68000-Format
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

print  ext.l    d1             ;force integer
       move     d1,-(sp)       ;nun den Wert 
       pea      buffer         ;wandeln
       bsr      bindec         ;Ergebnis in buffer
       pea      buffer         ;buffer ausgeben
       move     #9,-(sp)       ;mittels PRTLIN-Funktion
       trap     #1
       addq.l   #6,sp 
       rts  

       include   "bindec.s"

       data  
fat    dc.w      $F7FF,$FF03,$4000,$0560,$00FF,$FFFF
       bss
buffer ds.b      6
       end

