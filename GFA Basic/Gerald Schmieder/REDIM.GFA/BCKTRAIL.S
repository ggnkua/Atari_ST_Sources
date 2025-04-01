; Sourcecode zur Routine REDIM.INL, die von MKINLINE.GFA erzeugt wird.
; Kopiert die Stringzeiger eines Feldes in ein zweites und verbiegt dabei
; die Backtrailer der Strings, so daû diese dann zum zweiten gehîren.
; Autor: Gerald Schmieder      (c) MAXON Computer 1993
; Erstellt mit dem TURBOASS.


movea.l 4(sp),a0  ; Adresse der Feldinformation des Originals
movea.l 8(sp),a1  ; Adresse der Feldinformation des Ziels
moveq   #-2,d3    ; Vorbelegt fÅr schnelleres 'and'
moveq   #0,d4     ; Vorbelegt fÅr schnelleres 'cmp'
move.l  (a0)+,d0  ; Anzahl der EintrÑge im Original
move.l  (a1)+,d1  ; Anzahl im neuen Array
cmp.l   d1,d0     ; Ist das neue Array kleiner ?
blo.s   change    ; nein => alles klar
move.l  d1,d0     ; Sonst Anzahl der neuen Elemente nehmen

change:
movea.l (a0)+,a2  ; Adresse des Strings
cmpa.w  d4,a2     ; ist a2 ein Nullzeiger ?
beq.s   empty     ; ja => String ist leer
move.w  (a0)+,d1  ; LÑnge in Bytese
move.w  d1,d2     ; nochmal kopieren
addq.w  #1,d2     ; + 1        \
and.w   d3,d2     ; begradigen / wg. mîglichem Nullbyte
move.l  a1,0(a2,d2.w) ; Backtrailer verbiegen
move.l  a2,(a1)+  ; Zeiger in Zielfeld kopieren
move.w  d1,(a1)+  ; LÑnge in Zielfeld kopieren

next:
subq.l  #1,d0     ; kein dbra, da Felddimension
bne.s   change    ; 16 Bit Åberschreiten kînnte !
rts

empty:
addq.l  #2,a0     ; LÑnge Åberspringen
addq.l  #6,a1
bra.s   next
END
