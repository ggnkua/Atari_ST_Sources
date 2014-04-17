**********************
* MEDIA.S
* Erzeugt auf einem Laufwerk einen Medienwechsel
* Eingabe in Kommandozeile (Laufwerkskennung)
**********************

                GLOBAL _mediach

start:
                movea.l 4(SP),A6        ; ->Basepage

                bsr     cmd             ; Laufwerk aus Kommandozeile holen
                tst.w   D0              ; alle Laufwerke?
                bmi.s   alle            ; ja, weiter
                bsr.s   einzeln         ; nur ein Laufwerk
terminate:
                clr.w   -(SP)
                trap    #1              ; und raus

alle:
                moveq   #31,D0          ; ZÑhler initialisieren
allelp:
                bsr.s   einzeln         ; Wechsel provozieren
                dbra    D0,allelp       ; nÑchstes Laufwerk
                bra.s   terminate       ; und fertig

einzeln:
                move.w  D0,-(SP)        ; auf Stack
                bsr.s   _mediach        ; Wechsel provozieren
                move.w  (SP)+,D0
                rts

************************
* Force Media Change
*
* zwingt GEMDOS, einen Medienwechsel fÅr
* ein bestimmtes Laufwerk anzuerkennen.
* nach den Empfehlungen in der Doku zu
* TOS 1.04.
*
* USAGE:
*     void mediach(devno);
*     int devno;
*
************************
_mediach::
                move.w  4(SP),D0        ; Laufwerksnummer
                lea     mydev(PC),A0
                move.w  D0,(A0)         ; merken
                add.b   #'A',D0
                lea     fspec(PC),A0
                move.b  D0,(A0)         ; Laufwerkskennung setzen

loop:
                clr.l   -(SP)           ; ab in den Super-Modus
                move.w  #32,-(SP)       ; SUPER
                trap    #1              ; GEMDOS
                addq.l  #6,SP
                move.l  D0,-(SP)        ; alten SP auf Stack
                move.w  #32,-(SP)       ; auf neuerlichen SUPER-Aufruf vorbereiten

                lea     o_bpb(PC),A0
                move.l  $0472.w,(A0)+   ; alten BPB-Vektor retten
                move.l  $047E.w,(A0)+   ; alten MEDIA-Vektor retten
                move.l  $0476.w,(A0)    ; alten RWABS-Vektor retten

                move.l  #my_bpb,$0472.w ; neue Vektoren setzen
                move.l  #my_media,$047E.w
                move.l  #my_rwabs,$0476.w

                pea     dta(PC)         ; DTA-Adresse
                move.w  #$1A,-(SP)      ; Fsetdta
                trap    #1
                addq.l  #6,SP
                clr.w   -(SP)           ; Suchattribut 0
                pea     fspec(PC)       ; -> Suchmuster
                move.w  #$4E,-(SP)      ; Fsfirst
                trap    #1
                addq.l  #8,SP

                move.l  o_bpb(PC),$0472.w ; alte Vektoren wieder installieren
                move.l  o_media(PC),$047E.w
                move.l  o_rwabs(PC),$0476.w

done:
                trap    #1              ; GEMDOS
                addq.l  #6,SP
                rts

* eigene BPB-Routine
my_bpb:
                move.w  mydev(PC),D0
                move.w  4(SP),D1
                cmp.w   D1,D0           ; ist es das gewÅnschte Laufwerk?
                bne.s   dooldg          ; nein
                moveq   #0,D0
                rts
dooldg:
                movea.l o_bpb(PC),A0    ; alten BPB-Vektor holen
                jmp     (A0)            ; zur alten Routine

* eigene MEDIA-Routine
* liefert fÅr das gewÅnschte Laufwerk generell 2
* (auf jeden Fall gewechselt)
my_media:
                move.w  mydev(PC),D0
                move.w  4(SP),D1
                cmp.w   4(SP),D0        ; paût die Laufwerksnummer?
                bne.s   dooldm          ; nein, alten Vektor anspringen
                moveq   #2,D0           ; 2 = garantiert gewechselt
                rts
dooldm:
                movea.l o_media(PC),A0  ; alten Vektor holen
                jmp     (A0)

* eigene RWABS-Routine
* liefert fÅr das gewÅnschte Laufwerk -14 (E_CHG)

my_rwabs:
                move.w  mydev(PC),D0
                move.w  14(SP),D1
                cmp.w   14(SP),D0       ; das passende Laufwerk?
                bne.s   dooldr          ; nein
                moveq   #-14,D0         ; E_CHG liefern
                rts

dooldr:
                movea.l o_rwabs(PC),A0  ; alten Vektor anspringen
                jmp     (A0)

*********************
* cmd: PrÅft auf gÅltige Parameter in
*      der Kommandozeile
* IN:  basepage Adresse der basepage
* OUT: d0 gewÅnschtes Laufwerk
*********************
cmd:
                lea     $80(A6),A2      ; auf Kommandozeile positionieren
                moveq   #-1,D0          ; d0.w initialisieren
                clr.w   D1              ; d1.w lîschen
                move.b  (A2)+,D1        ; LÑnge der Kommandozeile holen
                beq.s   cmdexit         ; gleich 0, dann raus
                subq.w  #1,D1           ; minus eins wegen dbf
nxtchar:
                move.b  (A2)+,D2        ; Zeichen holen
                beq.s   cmdexit         ; 0?
                or.w    #32,D2          ; Bit 5 setzen
                cmp.b   #'a',D2         ; <'a'?
                blt.s   nxtchar         ; ja, weitersuchen
                cmp.b   #'z',D2         ; >'z'?
                ble.s   valid           ; nein, gÅltig
                dbra    D1,nxtchar      ; nÑchstes Zeichen

cmdexit:        rts

valid:          sub.w   #$61,D2         ; ASCII nach Zahl
valexit:        move.w  D2,D0           ; Laufwerk nach d0
                rts

fspec:
                DC.B "X:\*.*",0 ; Suchmuster

                BSS
dta:            DS.B 44
mydev:          DS.W 1
o_bpb:          DS.L 1
o_media:        DS.L 1
o_rwabs:        DS.L 1
                END
