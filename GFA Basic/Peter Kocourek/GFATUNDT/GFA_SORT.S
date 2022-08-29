;** Befehlserweiterung fÅr GfA-BASIC   V0.1  S.D. **
;** Sortierung eines 1-dimensionalen Stringfeldes **
;**  Aufruf: MONITOR(*a$())  **

run:
 move.l 4(sp),a5
 lea stack,sp ;neuen Stack einrichten
 move.l #ende-run+$500,-(sp) ;Speicher reservieren
 move.l a5,-(sp) ;Speicher-Anfang
 clr -(sp)
 move #$4a,-(sp) ;Setblock
 trap #1
 add.l #12,sp

 pea init ;Vektorverbiegung
 move #$26,-(sp) ;mit Super_Execute
 trap #14 ;ausfÅhren
 addq.l #6,sp

 pea param ;Environment
 pea param ;Kommandozeile
 pea fname ;Filename: GFABASIC.PRG
 clr -(sp) ;Load and Go
 move #$4b,-(sp) ;PEXEC
 trap #1 ;GfA-BASIC starten
 add.l #16,sp ;nach GfA-Quit

exit:
 clr -(sp)
 trap #1 ;Term => Desktop

init: ;Zeiger verbiegen
 move.l #main,$10 ;Illegal-Pointer auf eigene Routine
 rts ;fertig

param: dc.w 0 ;kein Env. / Com.line
fname: dc.b "GFABASIC.PRG",0
even

main:
 move.l d0,a0 ;Parameter in A0
 cmp #1,4(a0) ;eindimensional ?
 bne error ;nein !
 move.l (a0),a0 ;Adresse des Feldes in A0
 clr.l d4
 clr.l d5
loop:
 move.l (a0),d0 ;Anzahl der Felder
 subq #2,d0

 clr d3 ;Flag lîschen
 moveq #4,d1
lop1:
 move.l 0(a0,d1),a1 ;Adresse von A$(0) ect.
 move.l 6(a0,d1),a2 ;Adresse von A$(1) ect.
 move.b (a2),d2
 cmp.b (a1),d2 ;Vergleich
 bpl noswap ;OK

 move.l a1,6(a0,d1)
 move.l a2,0(a0,d1) ;Adressentausch
 move 4(a0,d1),d4 ;LÑnge 0
 move 10(a0,d1),d5 ;LÑnge 1
 move d5,4(a0,d1)
 move d4,10(a0,d1) ;LÑngentausch
 addq #1,d4
 and #$fffe,d4 ;LÑnge ggf. aufrunden
 addq #1,d5
 and #$fffe,d5
 move.l 0(a1,d4),d6 ;Backtrailer 0
 move.l 0(a2,d5),0(a1,d4) ;BT1 in BT0
 move.l d6,0(a2,d5) ;BT0 in BT1
 st d3 ;Flag setzen

noswap:
 addq.l #6,d1
 dbra d0,lop1 ;weiter
 tst d3 ;fertig ?
 bne loop ;nein: nochmal

stop:
 addq.l #2,2(sp) ;PC auf Befehl nach ILLEGAL
 rte ;zurÅck zu GfA-BASIC

error:
 move #7,-(sp)
 move #2,-(sp)
 trap #1 ;Glocke
 addq.l #4,sp
 bra stop

ende:

data
 blk.l $100
stack: blk.l 1
