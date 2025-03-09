*********************************
*                               *
* ROMSPEED.PRG                  *
*                               *
* verlegt ROM ins TT-RAM        *
*                               *
* (C) Januar 1991 by Uwe Seimet *
*                               *
*********************************


GEMDOS  = 1
CCONWS  = 9
PTERMRES= 49


XBIOS   = 14
SUPEXEC = 38


_p_cookies = $5a0             ;Pointer auf
                              ;cookie-jar


        text

        pea super(pc)
        move #SUPEXEC,-(sp)
        trap #XBIOS
        addq.l #6,sp
        tst.b stflg           ;Atari ST?
        bne.b quitst          ;ja-
        pea message(pc)
        move #CCONWS,-(sp)    ;Meldung
        trap #GEMDOS          ;ausgeben
        addq.l #6,sp
        tst.b ramflg          ;bereits
                              ;installiert?
        bne.b quit            ;ja-
        move.l rompnt,a1      ;neue ROM-
                              ;Startadresse
        sub.l #mem,a1           
        add.l #524288,a1      ;512K Speicher
                              ;reservieren
        move.l 4(sp),a0       ;Basepage-
                              ;Adresse
        add.l 12(a0),a1       ;TEXT-Segment
        lea $100(a1),a1       ;Basepage-LÑnge
        clr -(sp)
        pea (a1)
        move #PTERMRES,-(sp)  ;residentes
        trap #GEMDOS          ;Programm
quitst: pea ttonly(pc)
        move #CCONWS,-(sp)
        trap #GEMDOS
        addq.l #6,sp
quit:   clr -(sp)
        trap #GEMDOS


super:
        move.l _p_cookies,d0  ;cookie jar
                              ;vorhanden?
        seq stflg
        beq.b exit            ;nein-
        move.l d0,a0
loop:   movem.l (a0)+,d0-d1   ;Ende der
        tst.l d0              ;Liste?
        beq.b exit            ;ja-
        cmp.l #"_MCH",d0      ;cookie fÅr
                              ;Computertyp?
        bne loop              ;nein-
        cmp.l #$00020000,d1   ;TT?
        sne stflg
        bne.b exit            ;nein-
        cmp #$00e0,$7f8       ;ROMSPEED schon
                              ;installiert?
        sne ramflg
        bne.b exit            ;ja-

*Die folgenden Befehle sind die entscheidenden

        move.l #mem+32768,d1
        and #$8000,d1         ;neue ROM-
                              ;Adresse
                              ;auf Pagegrenze
                              ;ausrichten
        move.l d1,rompnt      ;und merken
        move.l d1,a0
        lea $00e00000,a1      ;ROM-Adresse
        move.l #131072,d0     ;512K ROM ins
copy:   move.l (a1)+,(a0)+    ;RAM kopieren
        subq.l #1,d0
        bne copy
        or #5,d1              ;Page-Deskriptor
                              ;markieren und
                              ;schreibschÅtzen
                              ;(nicht geschÅtzt
                              ;bei or #1,d1)
        move.l d1,$7f8        ;in Deskriptor-
                              ;Tabelle
                              ;eintragen
        pflusha               ;ATC lîschen
                              ;(identisch mit
                              ;dc.l $F0002400)
exit:   rts                   ;das war alles


message:dc.b $0d,$0a
        dc.b "ROMSPEED V1.0 installiert"
        dc.b $0d,$0a
        dc.b "Ω 1991 by Uwe Seimet"
        dc.b $0d,$0a,$00

ttonly: dc.b $0d,$0a
        dc.b "ROMSPEED lÑuft nur "
        dc.b "auf dem Atari TT"
        dc.b $0d,$0a,$00


        bss

mem:    ds.b 557056 ;512K + 32K

rompnt: ds.l 1    ;Pointer auf ROM-Kopie

ramflg: ds.b 1    ;Flag fÅr Zweitinstallation

stflg:  ds.b 1    ;Flag fÅr Atari ST

