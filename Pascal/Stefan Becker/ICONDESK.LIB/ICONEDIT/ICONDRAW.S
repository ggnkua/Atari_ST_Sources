
*************************************************
* Schnelle Icon-32*32-S/W-Bildschirmausgabe     *
* fÅr Pascal+ / (C)1989 by Stefan Becker        *
* Assembler: DRI                                *
*************************************************
* Aufruf von Pascal:                            *
*  Drawbuf(Screenadr:Long_Integer; Var Bufadr); * * Bufadr gerade!!!
*************************************************

ypos      equ       62                  * Startzeile fÅr Icon
xpos      equ       46                  * Startspaltenbyte fÅr Icon

********************
* Pascal-Interface *
********************

          xdef      DRAWBUF

DRAWBUF:  movem.l   a1-a6/d0-d7,register * Register retten
          move.l    (a7)+,retadr        * RÅcksprungadresse sichern
          move.l    (a7)+,bufadr        * Bufferadresse holen
          move.l    (a7)+,screen        * Bildschirmadresse holen

          bsr.s     drawmain            * Malroutine

          movem.l   register,a1-a6/d0-d7 * Register wiederholen
          move.l    retadr,a0           * RÅcksprungadresse laden
          jmp       (a0)                * zurÅck

********************
* Icondraw-Routine *
********************

drawmain: move.l    bufadr,a0           * a0=Pufferzeiger
          move.l    screen,a1           * Adresse der 1. Zeile berechnen...
          moveq     #ypos,d0
          mulu      #80,d0
          adda.w    d0,a1
          adda.w    #xpos,a1            * a1=Adresse linke Kante
          moveq     #31,d7              * d7: ZeilenzÑhler (32 Zeilen)
drawlp:   move.l    (a0)+,d0            * d0=akt. Iconzeile
          bsr.s     drawrow             * 1 Zeile zeichnen
          adda.w    #8*80,a1            * 8 Screenzeilen tiefer gehen
          dbf       d7,drawlp           * NÑchste Zeile?
          rts

*******************************************
* Zeichne 1 Zeile                         *
* Parameter: d0 = akt. Iconzeilenlangwort *
*            a0 = linke Kante Bildschirm  *
*******************************************

drawrow:  moveq     #31,d6              * Horizontaler PixelzÑhler (=32)
          move.l    a1,a2               * Arbeitskopie linke Kante: a2
rowlp:    btst.l    d6,d0               * Pixel setzen?
          beq.s     nopix
          bsr.s     pixon               * Pixel setzen!
          bra.s     endlp
nopix:    bsr.s     pixoff              * Pixel lîschen
endlp:    addq.l    #1,a2               * NÑchster Durchlauf...
          dbf       d6,rowlp
          rts                           * Fertig!

***************
* Setze Pixel *
***************

pixon:    lea       onpixel,a3
          move.b    (a3)+,d1            * rel. Zeile 0
          or.b      d1,(a2)
          move.b    (a3)+,d1            * rel. Zeile 1
          or.b      d1,1*80(a2)
          move.b    (a3)+,d1            * rel. Zeile 2
          or.b      d1,2*80(a2)
          move.b    (a3)+,d1            * rel. Zeile 3
          or.b      d1,3*80(a2)
          move.b    (a3)+,d1            * rel. Zeile 4
          or.b      d1,4*80(a2)
          rts

****************
* Lîsche Pixel *
****************

pixoff:   lea       offpixel,a3
          move.b    (a3)+,d1            * rel. Zeile 0
          and.b     d1,(a2)
          move.b    (a3)+,d1            * rel. Zeile 1
          and.b     d1,1*80(a2)
          move.b    (a3)+,d1            * rel. Zeile 2
          and.b     d1,2*80(a2)
          move.b    (a3)+,d1            * rel. Zeile 3
          and.b     d1,3*80(a2)
          move.b    (a3)+,d1            * rel. Zeile 4
          and.b     d1,4*80(a2)
          rts

**********
* Daten: *
**********

onpixel:  dc.b      $f8,$f8,$f8,$f8,$f8 * "Sprite" fÅr eingesch. Pixel
offpixel: dc.b      7,7,7,7,7           * "Maske" fÅr ausgesch. Pixel

retadr:   ds.l      1                   * Speicher f. RÅcksprungadresse
bufadr:   ds.l      1                   * Adresse des Icons
screen:   ds.l      1                   * Bildschirmadresse
register: ds.l      14                  * Gerettete 68000-Register

          end

