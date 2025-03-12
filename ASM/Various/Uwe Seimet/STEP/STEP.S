***************************************
*                                     *
* Stepraten-Einstellung im Bootsektor *
*                                     *
*      (C) 1990 by Uwe Seimet         *
*                                     *
***************************************


*Einige wenige Systemkonstanten

GEMDOS   = 1
CCONIN   = 1
CCONWS   = 9

BIOS     = 13
RWABS    = 4

XBIOS    = 14
PROTOBT  = 18
FLOPRATE = 41

_sysbase   = $4f2


         text

         lea text(pc),a0
         bsr input                  ;Steprate fÅr Laufwerk A: holen
         sub.b #'0',d0
         move d0,ratea              ;und vermerken
         move.b #'B',drive
         lea text(pc),a0
         bsr input                  ;Steprate fÅr Laufwerk B: holen
         sub.b #'0',d0
         move d0,rateb              ;und vermerken
         lea insert(pc),a0
         bsr input                  ;korrekte Diskette einlegen
         cmp.b #$1b,d0              ;Abbruch?
         beq.s quit                 ;ja-
         clr -(sp)
         clr -(sp)                  ;Bootsektor
         move #1,-(sp)
         pea buffer
         move #2,-(sp)              ;Flag fÅr Lesen
         move #RWABS,-(sp)
         trap #BIOS                 ;Bootsektor lesen
         lea 14(sp),sp
         tst d0
         bne.s quit                 ;Fehler-
         move #$6038,buffer         ;Sprung auf Bootprogramm
         lea buffer+$38,a0          ;Beginn des Programms im Bootsektor
         lea boot,a1
         move #stepadr-boot+1,d0    ;LÑnge des Bootprogramms-1
.copy:   move.b (a1)+,(a0)+         ;Bootprogramm kopieren
         dbra d0,.copy
         move #1,-(sp)              ;ausfÅhrbaren Bootsektor erzeugen
         move #-1,-(sp)             ;Disktyp nicht verÑndern
         pea -1                     ;Seriennummer nicht verÑndern
         pea buffer
         move #PROTOBT,-(sp)
         trap #XBIOS
         lea 14(sp),sp
         clr -(sp)
         clr -(sp)                  ;Bootsektor
         move #1,-(sp)
         pea buffer
         move #3,-(sp)              ;Flag fÅr Schreiben
         move #RWABS,-(sp)
         trap #BIOS                 ;Bootsektor schreiben
         lea 14(sp),sp
quit:    clr -(sp)
         trap #GEMDOS               ;das war's

*String ausgeben (Pointer in A0), Zeichen von Tastatur holen
input:
         move.l a0,-(sp)            ;Pointer auf Stringtext
         move #CCONWS,-(sp)
         trap #GEMDOS               ;String ausgeben
         addq.l #6,sp
         move #CCONIN,-(sp)
         trap #GEMDOS               ;Zeichen von Tastatur holen
         addq.l #2,sp
         rts

*Programm fÅr Bootsektor
boot:
         bra.s act		;Sprung auf das eigentliche Programm

ratea:   dc.w 0                     ;Steprate fÅr Floppy A:
rateb:   dc.w 0                     ;Steprate fÅr Floppy B:

*Es folgt das Bootprogramm.
*Die Umschaltung auf eine Bildfrequenz von 60 Hertz in der ersten Zeile
*ist eventuell fÅr Besitzer eines Farbmonitors interessant.
*Dieser Befehl kann natÅrlich auch weggelassen werden.
act:
         bclr #1,$ffff820a          ;Umschaltung auf 60 Hertz (bei Bedarf)
         move.l _sysbase,a0         ;Pointer auf Systemheader
         move #$6ca,d0		;Stepraten-Basis bei TOS 1.0
         cmp #$0102,2(a0)           ;TOS 1.0?
         bcc.s not1_0               ;nein-
         cmp.l #$fc0000,a0          ;altes RAMTOS?
         bcs.s oldtos               ;ja-
         move #$a08,d0		;Stepraten-Basis des RAMTOS
         bra.s oldtos
not1_0:  cmp #$0104,2(a0)           ;TOS 1.4 oder neuer?
         bcc.s newtos               ;ja-
         move #$a4e,d0		;Stepraten-Basis des Blittertos
oldtos:  move d0,stepadr
newtos:  moveq #0,d0
         move ratea(pc),d1
         bsr.s floprate             ;Steprate fÅr Floppy A: setzen
         moveq #1,d0                ;nun noch Floppy B:
         move rateb(pc),d1
floprate:tst stepadr                ;TOS mit FLOPRATE-Funktion?
         beq.s setstep              ;ja-
         move stepadr(pc),a0
         asl #2,d0                  ;Offset fÅr Laufwerk berechnen
         move d1,(a0,d0)
         rts
setstep: move d1,-(sp)              ;neue Steprate
         move d0,-(sp)              ;Laufwerksnummer
         move #FLOPRATE,-(sp)
         trap #XBIOS                ;Steprate setzen
         addq.l #6,sp
         rts


stepadr: dc.w 0

text:    dc.b $0d,$0a,$0a
         dc.b "Bitte wÑhlen Sie die Steprate fÅr Laufwerk "
drive:   dc.b "A:",$0d,$0a,$0a
         dc.b $09,"0.  6 ms",$0d,$0a
         dc.b $09,"1. 12 ms",$0d,$0a
         dc.b $09,"2.  2 ms",$0d,$0a
         dc.b $09,"3.  3 ms",$0d,$0a,$00

insert:  dc.b $0d,$0a,$0a
         dc.b "Bitte die korrekte Diskette in Laufwerk A: legen "
         dc.b "und Taste drÅcken!",$0d,$0a,$0a
         dc.b "[Abbruch mit ESC]",0


         bss

buffer:  ds.b 512                   ;Puffer fÅr Bootsektor
