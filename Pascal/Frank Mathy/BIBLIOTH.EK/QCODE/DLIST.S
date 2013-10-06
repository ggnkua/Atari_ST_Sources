* Horizontal-Blank-Routine fÅr mehr als 16 Farben pro Grafikseite
* Wirkt Ñhnlich wie eine Display-List auf den Atari 8-Bit-Rechnern

* Einschalten: ondlist(dlist,abstand)
*              <dlist> ist ein Zeiger auf die Display-List-Daten
*              <abstand> gibt den Abstand zwischen den einzelnen
*              Display-List-énderungen an (Wort)
* éndern der Displaylist: altdlist(dlist);
* Ausschalten: offdlist();

.text
.xdef _ondlist
_ondlist:       move.l  4(a7),dlstart           *Startadresse der D.-List
                move.l  dlstart,dlakt
                move.w  8(a7),dldist            *Abstand zw. HBL-Aufrufen
                clr.l   -(a7)
                move.w  #$20,-(a7)              *In Supervisor-Mode
                trap    #1
                addq.l  #6,a7
                move.l  d0,-(a7)
                move.b  $fffa09,hbl_buff        *Retten der 68901-Register
                move.b  $fffa07,hbl_buff+1
                move.b  $fffa13,hbl_buff+2
                move.l  $118,hbl_buff+4         *Und der Vektoren
                move.l  $120,hbl_buff+8
                move.l  $70,hbl_buff+12
                move.l  $118,vk_2_1+2
                move.l  #vk_2,$118
                and.b   #$df,$fffa09            *Timer C aus
                and.b   #$fe,$fffa07            *Timer B aus
                move.l  #hbl,$120               *Zeiger auf HBL-Routine
                or.b    #1,$fffa07              *Timer B an
                or.b    #1,$fffa13              *Timer B ausmaskieren
                move.l  $70,vbl_alt+2           *JMP auf alte VBL-Routine
                move.l  #vbl,$70                *Neue VBL-Routine setzen
                move.w  #$20,-(a7)              *Ende des Supervisor-Modus
                trap    #1
                addq.l  #6,a7
                clr.l   d0
                rts

.text
.xdef _altdlist
_altdlist:      move.l  4(a7),dlstart           *Neue Dlist vermerken
                rts

.bss
hbl_buff:       ds.w    8

.text
.xdef _offdlist
_offdlist:      clr.l   -(a7)
                move.w  #$20,-(a7)              *In Supervisor-Modus
                trap    #1
                addq.l  #6,a7
                move.l  d0,-(a7)
                move.b  hbl_buff,$fffa09        *Register zurÅcksetzen
                move.b  hbl_buff+1,$fffa07
                move.b  hbl_buff+2,$fffa13
                move.l  hbl_buff+4,$118         *Vektoren zurÅcksetzen
                move.l  hbl_buff+8,$120
                move.l  hbl_buff+12,$70
                move.w  #$20,-(a7)
                trap    #1
                addq.l  #6,a7
                rts

*VBL-Routine

.text
vbl:            move.b  #0,$fffa1b
                movem.l d0/a0-a1,buff
                movea.l #$ff8240,a0
                move.l  dlstart,a1
                move.b  dldist+1,d0
vbl_j1:         move.b  d0,$fffa21
                cmp.b   $fffa21,d0
                bne.s   vbl_j1
vbl_j2:         move.w  (a1)+,d0
                bmi.s   vbl_j3
                move.w  (a1)+,(a0,d0.w)
                bra.s   vbl_j2
vbl_j3:         move.l  a1,dlakt
                movem.l buff,d0/a0-a1
                move.b  #8,$fffa1b
vbl_alt:        jmp     $000000

vk_2:           move.w  #$2500,sr
vk_2_1:         jmp     $000000

.bss
buff:           ds.l    3                       *Puffer fÅr Vektoren etc.
dldist:         ds.w    1                       *Abstand zw. HBL-Aufrufen
dlstart:        ds.l    1                       *Start der D.-List
dlakt:          ds.l    1                       *Aktuelle Zeile in D.-L.

* HBL-Routine
.text
hbl:            movem.l d0/a0-a1,buff
                movea.l #$ff8240,a0
                move.l  dlakt,a1
hbl_j2:         move.w  (a1)+,d0
                bmi.s   hbl_j3
                move.w  (a1)+,(a0,d0.w)
                bra.s   hbl_j2
hbl_j3:         move.l  a1,dlakt
                movem.l buff,d0/a0-a1
                bclr    #0,$fffa0f
                rte
