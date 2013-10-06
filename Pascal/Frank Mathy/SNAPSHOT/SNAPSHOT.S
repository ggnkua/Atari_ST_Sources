* "Snapshot"
* Routine zum Saven von Grafiken nach
* Drcken von ALT+HELP
* (C) Frank Mathy Di, 30.12.1986

.text
                move.l  a7,a5           *Stapelzeiger retten
                move.l  #stapel,a7      *Neuer Stapel

                move.l  #install,-(a7)  *Install-Routine im
                move.w  #38,-(a7)       *Supervisor-M. ausf.
                trap    #14
                addq.l  #6,a7           *Stapelkorrektur

                pea     message         *Hinweis
                move.w  #$9,-(a7)       *PRINT_LINE
                trap    #1              *Gemdos
                addq.l  #6,a7

                move.l  4(a5),a5        *Zeiger auf Basepage
                move.l  #100,d0         *L„nge berechnen
                add.l   12(a5),d0       *Programml„nge
                add.l   20(a5),d0       *DATA-Bereich
                add.l   28(a5),d0       *BSS-Bereich

                clr.w   -(a7)
                move.l  d0,-(a7)        *Programml„nge
                move.w  #$31,-(a7)      *Keep Process
                trap    #1              *Programmende

install:        move.l  $456,a0         *Zeiger auf Tabelle
                move.w  $454,d0         *Zahl der Routinen
                subq.w  #1,d0           *Da DBRA
ins_loop:       tst.l   (a0)            *Belegt ?
                beq.s   ins_j1          *Nein --> Weiter
                addq.l  #4,a0           *N„chster Platz
                dbra    d0,ins_loop     *Schleife
                rts                     *Abbrechen
ins_j1:         move.l  #vblneu,(a0)    *Neue Routine einbauen
                rts

*Neue VBL-Routine

vblneu:         tst.w   $4ee            *ALT + HELP ?
                beq.s   dump            *Ja --> Weiter
                rts

*Dump-Routine

dump:           move.l  $404,error      *Fehlervektor merken
                move.l  dpexit,$404     *Vektor neu setzen
                tst.w   $44c            *320x200-Modus ?
                bne     no320           *Nein --> Weiter

                move.l  $ff8240,palette
                and.l   #$07770777,palette
                move.l  $ff8244,palette+4
                and.l   #$07770777,palette+4
                move.l  $ff8248,palette+8
                and.l   #$07770777,palette+8
                move.l  $ff824c,palette+12
                and.l   #$07770777,palette+12
                move.l  $ff8250,palette+16
                and.l   #$07770777,palette+16
                move.l  $ff8254,palette+20
                and.l   #$07770777,palette+20
                move.l  $ff8258,palette+24
                and.l   #$07770777,palette+24
                move.l  $ff825c,palette+28
                and.l   #$07770777,palette+28

                clr.w   -(a7)           *R/W-Status
                pea     degasname       *Dateiname
                move.w  #$3c,-(a7)      *Create-Funktion
                trap    #1              *Gemdos
                addq.l  #8,a7
                tst.w   d0              *Fehler ?
                bmi     dpexit          *Ja --> Ende
                move.w  d0,handle       *Handle merken
                add.b   #1,degasname+7  *Neuer Name
                cmp.b   #91,degasname+7 *Kein Buchstabe ?
                bne.s   nameok          *Nein --> Weiter
                move.b  #65,degasname+7 *Auf A setzen

nameok:         pea     empty           *Adresse retten
                move.l  #34,-(a7)       *34 Bytes schreiben
                move.w  handle,-(a7)    *Dateihandle
                move.w  #$40,-(a7)      *FWRITE-Funktion
                trap    #1              *GEMDOS
                add.l   #12,a7          *Stapelkorrektur
                tst.w   d0              *Fehler ?
                bmi.s   dpexit          *Ja --> Ende

                bra.s   continue        *Rest schreiben

no320:          clr.w   -(a7)           *R/W-Status
                pea     doodlename      *Dateiname
                move.w  #$3c,-(a7)      *Create-Funktion
                trap    #1              *Gemdos
                addq.l  #8,a7
                tst.w   d0               *Fehler ?
                bmi.s   dpexit           *Ja --> Ende
                move.w  d0,handle        *Handle merken
                add.b   #1,doodlename+7  *Neuer Name
                cmp.b   #91,doodlename+7 *Kein Buchstabe ?
                bne.s   continue         *Nein --> Weiter
                move.b  #65,doodlename+7 *Auf A setzen
                
continue:       move.l  $44e,-(a7)      *Bildschirmstart
                move.l  #32000,-(a7)    *Bildschirmgr”že
                move.w  handle,-(a7)    *Dateihandle
                move.w  #$40,-(a7)      *Fwrite
                trap    #1              *Gemdos
                add.l   #12,a7

                move.w  handle,-(a7)    *Dateihandle
                move.w  #$3e,-(a7)      *Fclose
                trap    #1              *Gemdos
                addq.l  #4,a7

dpexit:         move.l  error,$404
                move.w  #-1,$4ee        *Neuen Dump zulassen
                rts

.data
degasname:      dc.b    "DEGASL_A.PI1",0
doodlename:     dc.b    "DOODLE_A.DOO",0
.even
empty:          dc.w    0
palette:        ds.w    16
message:        dc.b    "Snapshot V1.0 by Frank Mathy installed.\n",0
.even

.bss
error:          ds.l    1
handle:         ds.w    1

                ds.l    40
stapel:         ds.l    1

