*******************************
*                             *
* ROMSPEED V1.2               *
*                             *
* verlegt ROM ins TT-RAM,     *
*                             *
* unterstÅtzt virtuelle       *
*                             *
* Speicherverwaltung OUTSIDE  *
*                             *
* (C) Juli 1991 by Uwe Seimet *
*                             *
*******************************


LOCKED  = 0


GEMDOS   = 1
CCONWS   = 9
PTERMRES = 49


XBIOS    = 14
SUPEXEC  = 38


_p_cookies = $5a0               ;Pointer auf
                                ;cookie-jar


        text

        pea super(pc)
        move #SUPEXEC,-(sp)
        trap #XBIOS
        addq.l #6,sp
        lea ttonly,a3
        tst.b stflg             ;Atari ST?
        bne.b error             ;ja-
        lea mmuerr,a3
        tst.b mmuflg            ;MMU bereits aktiv?
        beq nommu               ;nein-
        tst.b swapflg           ;OUTSIDE?
        beq.b error             ;nein-
nommu:  pea message
        move #CCONWS,-(sp)
        trap #GEMDOS            ;Meldung ausgeben
        addq.l #6,sp
        tst.b ramflg            ;bereits
                                ;installiert?
        bne.b quit              ;ja-
        move.l rompnt,a1        ;neue
                                ;ROM-Startadresse
        sub.l #mem,a1           
        add.l romlen,a1         ;512K Speicher
                                ;reservieren
        move.l 4(sp),a0         ;Basepage-Adresse
        add.l 12(a0),a1         ;TEXT-Segment
        lea $100(a1),a1         ;Basepage-LÑnge
        clr -(sp)
        pea (a1)
        move #PTERMRES,-(sp)    ;Programm
        trap #GEMDOS            ;resident halten

error:
        pea (a3)                ;Fehlermeldung
        move #CCONWS,-(sp)
        trap #GEMDOS
        addq.l #6,sp
quit:   pea notinst
        move #CCONWS,-(sp)
        trap #GEMDOS
        addq.l #6,sp
        clr -(sp)
        trap #GEMDOS


super:
        move.l _p_cookies,d0    ;cookie jar
                                ;vorhanden?
        seq stflg
        beq exit                ;nein-
        move.l d0,a0
loop:   movem.l (a0)+,d0-d1
        tst.l d0                ;Ende der Liste?
        beq.b cend              ;ja-
        cmp.l #"_MCH",d0        ;cookie fÅr
                                ;Computertyp?
        bne nomch               ;nein-
        cmp.l #$00020000,d1     ;TT oder neuer?
        scs stflg
        bra loop
nomch:  cmp.l #"_CPU",d0
        bne nocpu
        cmp #30,d1              ;68030?
        bne exit                ;nein-
        bra loop
nocpu:  cmp.l #"SWAP",d0        ;OUTSIDE?
        bne notout              ;nein-
        st swapflg
        bra loop
notout: cmp.l #"PMMU",d0        ;sonstiges MMU-Programm?
        bne loop                ;nein-
        st mmuflg
        bra loop

cend:   tst.b stflg
        bne exit
        tst.b swapflg
        bne outside
        tst.b mmuflg
        bne exit
outside:cmp #$00e0,$7f8         ;ROMSPEED bereits
                                ;installiert?
        sne ramflg
        bne exit                ;ja-

        move.l #mem+32768,d1
        and #$8000,d1           ;neue ROM-Adresse
                                ;auf Pagegrenze
                                ;ausrichten
        move.l d1,rompnt        ;und merken
        move.l d1,a0            ;PrÅfsummen
        lea $00e80000-8,a1      ;Åberspringen
getlen: cmp.l #$ffffffff,-(a1)  ;Leerbytes
        beq getlen              ;Åberspringen
        sub.l #$00dffffc,a1
        move.l a1,romlen
        move.l a1,d0
        lsr.l #2,d0
        lea $00e00000,a1        ;ROM-Adresse
copy:   move.l (a1)+,(a0)+      ;ins RAM kopieren
        subq.l #1,d0
        bpl copy
        or #5,d1                ;Page-Deskriptor
                                ;markieren und
                                ;schreibschÅtzen
        move.l d1,$7f8          ;in Deskriptor-
                                ;Tabelle
                                ;eintragen
        pflusha                 ;DC.L $F0002400

        tst.b swapflg           ;OUTSIDE
                                ;installiert?
        beq.b exit              ;nein-
        move.l rompnt,a1
        move.l a1,d0
        add.l romlen,d0 
lock:   ptestr #7,(a1),#7,a0    ;Deskriptoradresse
                                ;ermitteln
                                ;DC.L $F0119F17
        bset #LOCKED,2(a0)      ;Systemkopie gegen
        lea ($8000,a1),a1       ;Auslagern sperren
        cmp.l a1,d0
        bcc lock

exit:   rts


        data

message:dc.b $0d,$0a
        dc.b "ROMSPEED V1.2 installiert",$0d,$0a
        dc.b "Ω 1991 by Uwe Seimet",$0d,$0a,$00

notinst:dc.b $0d,$0a
        dc.b "ROMSPEED V1.2 nicht "
        dc.b "installiert!",$0d,$0a,$00

ttonly: dc.b $0d,$0a
        dc.b "ROMSPEED lÑuft nur "
        dc.b "auf dem Atari TT"
        dc.b $0d,$0a,$00

mmuerr: dc.b $0d,$0a
        dc.b "Es ist bereits ein "
        dc.b "MMU-Programm aktiv!"
        dc.b $0d,$0a,$00


        bss

mem:    ds.b 557056     ;512K + 32K

rompnt: ds.l 1          ;Pointer auf ROM-Kopie

romlen: ds.l 1          ;Grîûe des ROM

swapflg:ds.b 1          ;Flag fÅr OUTSIDE

ramflg: ds.b 1          ;Flag fÅr Zweitinstallation

stflg:  ds.b 1          ;Flag fÅr Atari ST

mmuflg: ds.b 1          ;Flag fÅr aktives MMU-Programm

