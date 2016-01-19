* Color-Cycle-Funktion fÅr Farbrotation
* Einschalten: oncycle(<freg>,<lreg>,<richtung>,<speed>)
* Ausschalten: offcycle();
* Bedeutung der Variablen:
* <freg> : Registernummer des Anfangsregisters (0-15)
* <lreg> : Registernummer des Endregisters > <freg>
* <richtung> : Richtung : n < 0 = rÅckw. ; n > 0 = vorw.
* Speed: Geschwindigkeit in (n-1)/50 bzw. (n-1)/60 Sekunden

.text
.xdef _oncycle
_oncycle:       move.l  a0,cyc_buff             *a0 retten
                move.w  4(a7),d0                *lreg holen
                cmp.w   6(a7),d0                *freg < lreg ?
                bge     onc_end                 *Nein --> Ende
                asl.w   #1,d0                   *Mal 2
                ext.l   d0                      *Auf Langwort
                add.l   #$ff8240,d0             *Farbpalette
                move.l  d0,freg                 *Merken
                move.w  6(a7),d0                *freg holen
                asl.w   #1,d0                   *Mal 2
                ext.l   d0                      *Auf Langwort
                add.l   #$ff8240,d0             *Farbpalette
                move.l  d0,lreg                 *Merken
                move.w  8(a7),richtg            *Richtung merken
                move.w  10(a7),speed            *Speed merken
                move.w  speed,count             *In ZÑhler

                clr.l   -(a7)
                move.w  #$20,-(a7)              *In Supervisor-Mode
                trap    #1                      *GEMDOS
                addq.l  #6,a7                   *Stapelzeiger korr.
                move.l  d0,-(a7)

                movea.l $456,a0                 *Zeiger auf VBL-Rout.
                move.w  $454,d0                 *Zahl der VBL-Rout.
                subq.w  #1,d0                   *da DBRA

onc_j1:         tst.l   (a0)                    *Eintrag leer ?
                beq.s   onc_j2                  *Ja --> Weiter
                addq.l  #4,a0                   *NÑchster Eintrag
                dbra    d0,onc_j1               *Schleife
                bra.s   onc_exit                *Ohne Erfolg-->Weiter

onc_j2:         move.l  #cycle,(a0)             *Routine vermerken

onc_exit:       move.w  #$20,-(a7)              *In User-Mode
                trap    #1                      *GEMDOS-Aufruf
                addq.l  #6,a7                   *Stackkorrektur

                move.l  cyc_buff,a0             *a0 zurÅckholen
                clr.l   d0                      *d0 lîschen
onc_end:        rts

.xdef _offcycle
_offcycle:      movem.l a0/d1,cyc_buff          *a0 retten
                clr.l   -(a7)
                move.w  #$20,-(a7)              *In Supervisor-Mode
                trap    #1                      *GEMDOS
                addq.l  #6,a7                   *Stapelzeiger korr.
                move.l  d0,-(a7)

                movea.l $456,a0                 *Zeiger auf VBL-Rout.
                move.w  $454,d0                 *Zahl der VBL-Rout.
                subq.w  #1,d0                   *da DBRA

ofc_j1:         move.l  (a0),d1                 *Wert laden
                cmp.l   #cycle,d1               *Cycle-Routine ?
                beq.s   ofc_j2                  *Ja --> Weiter
                addq.l  #2,a0                   *NÑchste Routine
                dbra    d0,ofc_j1               *Schleife
                bra.s   ofc_exit                *Ohne Erfolg

ofc_j2:         clr.l   (a0)                    *Lîschen

ofc_exit:       move.w  #$20,-(a7)              *In User-Mode
                trap    #1                      *GEMDOS
                addq.l  #6,a7                   *Stapelzeiger korr.
                rts

.bss
freg:           ds.l    1
lreg:           ds.l    1
richtg:         ds.w    1
speed:          ds.w    1
count:          ds.w    1
cyc_buff:       ds.l    2

* Cycle-Routine

.text
cycle:          subq.w  #1,count                *Counter - 1
                bmi.s   cyc_j1                  *Counter<0 --> Weiter
                rts                             *Ende

cyc_j1:         move.w  speed,count             *Counter=Speed
                movem.l a0/d0,cyc_buff          *a0 und d0 retten
                tst.w   richtg                  *Richtung testen
                bmi.s   cyr_j1                  *neg. --> weiter

                move.l  lreg,a0                 *Letztes Registers
                move.w  (a0),d0                 *Farbwert merken

cyv_j1:         move.w  -2(a0),(a0)             *Register rotieren
                subq.l  #2,a0                   *NÑchstes Register
                cmpa.l  freg,a0                 *Erstes Register ?
                bne.s   cyv_j1                  *Nein --> ZurÅck
                move.w  d0,(a0)                 *Farbwert schreiben
                movem.l cyc_buff,a0/d0          *Register holen
                rts                             *Ende

cyr_j1:         move.l  freg,a0                 *Erstes Register
                move.w  (a0),d0                 *Farbwert merken

cyr_j2:         move.w  2(a0),(a0)              *Register rotieren
                addq.l  #2,a0                   *NÑchstes Register
                cmpa.l  lreg,a0                 *Letztes Register ?
                bne.s   cyr_j2                  *Nein --> ZurÅck
                move.w  d0,(a0)                 *Farbwert schreiben
                movem.l cyc_buff,a0/d0          *Register holen
                rts                             *Ende
