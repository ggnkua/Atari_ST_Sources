* Spiegeln um X-Achse
* Aufruf: xmirror(ziel,ystart,yend)

.text
.xdef _xmirror
_xmirror:               movem.l d0-d1/a0-a1,-(a7)
                        movea.l 20(a7),a0       *Adresse laden
                        movea.l a0,a1           *Adresse des Spiegelbildes
                        move.w  24(a7),d0       *Startzeile
                        mulu    #160,d0         *Offset berechnen
                        adda.l  d0,a0           *Neue Startadresse berechnen
                        move.w  26(a7),d0       *Letzte Zeile
                        mulu    #160,d0
                        adda.l  d0,a1           *Adresse berechnen

xm_j1:                  move.w  #39,d0          *40 Langworte/Zeile
xm_j2:                  move.l  (a0),d1         *Wert laden
                        move.l  (a1),(a0)+      *Inhalte tauschen
                        move.l  d1,(a1)+
                        dbra    d0,xm_j2

                        suba.l  #320,a1         *Zeile vorher
                        cmp.l   a1,a0           *a0 < a1 ?
                        blt.s   xm_j1           *Ja --> ZurÅck

                        movem.l (a7)+,d0-d1/a0-a1
xm_end:                 rts
