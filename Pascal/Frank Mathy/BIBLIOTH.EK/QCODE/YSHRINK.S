* Y-Schrumpfen von ganzen Bildschirmseiten
* Aufruf: yshrink(quelle,ziel,faktor,yoffset)
* <faktor>: neue Hîhe (1 bis 200), wenn negativ --> kopfstehend
* <offset> ist der Zeilenoffset
* offset <= 200-faktor

.text
.xdef _yshrink
_yshrink:               movem.l d0-d7/a0-a5,-(a7)
                        movea.l 60(a7),a0       *Quelle
                        movea.l 64(a7),a1       *Ziel
                        move.w  70(a7),d1       *Offset
                        muls    #160,d1         *Zeilenoffset berechnen
                        adda.l  d1,a1           *Neue Zieladresse
                        move.w  68(a7),d0       *Faktor
                        bmi.s   ysneg           *Negativ --> Kopfstehend

                        move.w  #100,d1         *ZÑhler
                        move.w  #199,d2         *ZÑhler fÅr Zeilen

ysp_j1:                 add.w   d0,d1           *ZÑhler erhîhen
                        cmp.w   #200,d1         *ZÑhler >= 200 ?
                        blt.s   ysp_j3          *Nein --> Weiter

                        sub.w   #200,d1         *ZÑhler == ZÑhler - 200
                        move.w  #4,d3           *5*8 Langworte/Zeile

ysp_j2:                 movem.l (a0)+,d4-d7/a2-a5 *Laden
                        movem.l d4-d7/a2-a5,(a1)  *ZurÅckschreiben
                        adda.l  #32,a1            *Zeiger neu setzen
                        dbra    d3,ysp_j2         *In Schleife
                        bra.s   ysp_j4            *Weiter

ysp_j3:                 adda.l  #160,a0         *QuellzÑhler erhîhen
ysp_j4:                 dbra    d2,ysp_j1       *ZurÅck in Schleife

                        movem.l (a7)+,d0-d7/a0-a5 *ZurÅckholen
                        rts

ysneg:                  neg.w   d0              *Betrag bilden
                        move.w  d0,d1           *Wert in d1
                        subq.w  #1,d1
                        muls    #160,d1         *zusÑtzlicher Zeilenoffset
                        adda.l  d1,a1           *Zieladresse berechnen

                        move.w  #100,d1         *ZÑhler
                        move.w  #199,d2         *ZÑhler fÅr Zeilen

ysn_j1:                 add.w   d0,d1           *ZÑhler erhîhen
                        cmp.w   #200,d1         *ZÑhler >= 200 ?
                        blt.s   ysn_j3          *Nein --> Weiter

                        sub.w   #200,d1         *Um 200 erniedrigen
                        move.w  #4,d3           *5*8 Langwîrter

ysn_j2:                 movem.l (a0)+,d4-d7/a2-a5 *Werte lesen
                        movem.l d4-d7/a2-a5,(a1)  *Werte schreiben
                        adda.l  #32,a1            *Zeilzeiger erhîhen
                        dbra    d3,ysn_j2         *Schleife
                        suba.l  #320,a1           *Zwei Zeilen zurÅck
                        bra.s   ysn_j4            *Weiter

ysn_j3:                 adda.l  #160,a0         *Quellzeiger erhîhen
ysn_j4:                 dbra    d2,ysn_j1       *Schleife

                        movem.l (a7)+,d0-d7/a0-a5
                        rts
