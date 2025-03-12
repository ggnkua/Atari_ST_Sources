EXPORT sublupe2,sublupe4,sublupe8

IMPORT zweifach,vierfach,achtfach

; Parameter fÅr alle 3 Routinen:
; A0 = Quelladresse,
; A1 = Zieladresse,
; D0 = Breite in Bytes
; D1 = Zeilen in Pixel

TEXT

MODULE sublupe2:
          movem.l a2-a3/d3,-(a7) 
          lea   zweifach,a3 
          subq  #1,d0
          subq  #1,d1
nextline: movea.l a1,a2 
          move.w d0,d2
nextbyte: clr.w  d3
          move.b (a0)+,d3 ; Quellbyte * 2 als  
                          ; Index in die
                          ; Vergrîûerungstabelle
          add.w  d3,d3 
          move.w (a3,d3.w),(a1)+ ; Wert kopieren
          dbf   d2,nextbyte
          move.w d0,d2
copyline: move.w (a2)+,(a1)+  ; Zeile kopieren
          dbf   d2,copyline
          dbf   d1,nextline
          movem.l (a7)+,a2-a3/d3 
          rts
ENDMOD        

MODULE sublupe4: 
          movem.l a2-a3/d3-d4,-(a7) 
          lea   vierfach,a3  
          move.w d0,d4  ; Abstand in der Tabelle
          ext.l  d4     ; (Zugriff auf Longs)
          lsl.l  #2,d4  ; ausrechnen
          subq  #1,d1
          subq  #1,d0
nextline: movea.l a1,a2 
          move.w d0,d2
nextbyte: clr.w  d3
          move.b (a0)+,d3  ; wie sublupe2
          add.w  d3,d3     ; Quellbyte * 4
          add.w  d3,d3
          move.l (a3,d3.w),(a1)+
          dbf   d2,nextbyte
          moveq  #2,d3
dreilines:move.w d0,d2    ; Ergebnis 3 mal
                          ;  kopieren
copyline: move.l (a2)+,(a1)+ 
          dbf   d2,copyline
          suba.l d4,a2 
          dbf   d3,dreilines
          dbf   d1,nextline
          movem.l (a7)+,a2-a3/d3-d4
          rts
ENDMOD

MODULE sublupe8: 
          movem.l a2-a4/d3-d7,-(a7) 
          move.w d0,d2 
          move.w d0,d7
          ext.l  d2
          lsl.l  #3,d2 ; Tabellenabstand 2 Longs
          subq  #1,d1
          subq  #1,d7
          lea   achtfach,a3 
nextline: movea.l a1,a2 
          move.w d7,d3
nextbyte: clr.w  d6
          move.b (a0)+,d6
          add.w  d6,d6     ; Quellbyte * 8
          add.w  d6,d6
          add.w  d6,d6
          lea   (a3,d6.w),a4 
          move.l (a4)+,(a1)+  ; 2 Longs Ergebnis
          move.l (a4),(a1)+   ; kopieren
          dbf   d3,nextbyte
          moveq  #5,d4  ; 5 Zeilen + 1 weiûe
                        ; oder 6 Zeilen kopieren
                        ; (je nach Maske)
fivelines:move.w d7,d3
copyline: move.l (a2)+,(a1)+ 
          move.l (a2)+,(a1)+ 
          dbf   d3,copyline
          suba.l d2,a2 
          dbf   d4,fivelines
          move.w d7,d0   ; weiûe Zeile
clearline:clr.l  (a1)+ 
          clr.l  (a1)+ 
          dbf   d0,clearline
          dbf   d1,nextline
          movem.l (a7)+,a2-a4/d3-d7
          rts
ENDMOD

END
