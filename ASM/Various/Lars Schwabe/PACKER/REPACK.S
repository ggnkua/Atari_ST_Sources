*                ENTPACKROUTINE                 *
* --------------------------------------------- *
*   by Lars Schwabe  (c) 1992 MAXON Computer    *
* ********************************************* *

flaenge  = 10206   * hier die FilelÑnge eintragen

* gepackte Bilddaten lesen
         clr  -(sp)          * Datenfile îffnen
         pea  fname2
         move #$3d,-(sp)
         trap #1
         addq.l #8,sp
         move d0,fhandle
         pea pack_speicher   * Bitmap einlesen
         move.l #flaenge,-(sp)
         move fhandle,-(sp)
         move #$3f,-(sp)
         trap #1
         add.l #12,sp
         move fhandle,-(sp)  * File schlieûen
         move #$3e,-(sp)
         trap #1
         addq.l #4,sp

         dc.w $a00a
          move #$03,-(sp)
          trap #14
          addq.l #2,sp         * log. Screen holen
          move.l d0,a0         * ZIEL-Adresse
          lea pack_speicher,a1 * QUELL-Adresse
          jsr repack
         dc.w $a009

         move #$07,-(sp)       * WARTEN...
         trap #1
         addq.l #2,sp
         clr -(sp)
         trap #1


* --------------------------- *
* E N T P A C K R O U T I N E *
* --------------------------- *
repack:  movem.l d0-d1/d3-d4/a0-a4,-(sp)
         lea boolean,a3    * Basis des Arrays
         move (a1)+,d3     * D3 = Anz. der Blîcke
         subq #1,d3
loop1:    moveq #0,d6
          moveq #0,d7
          move.b (a1)+,d6  * X-Koordinate
          move.b (a1)+,d7  * Y-Koordinate
          btst #7,d6
          beq check1
           bset #8,d7   * 8.Bit bei Y setzen
           bclr #7,d6   * 7.Bit bei X lîschen
check1:   moveq #0,d4
          moveq #0,d5
          move.b (a1)+,d4    * Breite
          move.b (a1)+,d5    * Hîhe
          btst #7,d4
          beq check2
           bset #8,d5  * 8.Bit der Hîhe 1
           bclr #7,d4  * 7.Bit der Breite 0
check2:   move.l a0,a2 * (Entpackspeichers)
          move.l a3,a4 * (Boolschen Felde)
          mulu #80,d7
          add d7,a2
          add d6,a2   * A2 = Startbyte im
          add d7,a4   *      32000er-Screen
          add d6,a4   * A4 = gleiches Byte, jedoch
          subq #1,d5  *      im boolschen Feld
          subq #1,d4
          move.b (a1)+,d0
          movem d4-d5,-(sp)   * D4/D5 sichern
loop3:    move d4,d1
loop2:      move.b d0,(a2,d1) * Byte des Blocks
           dbf d1,loop2       * eintragen...
           lea 80(a2),a2
          dbf d5,loop3

* den Block im boolschen Array markieren,
* um die restlichen Bytes zu finden
          movem (sp)+,d4-d5
f_loop2:   move d4,d0
f_loop1:    move.b #1,(a4,d0)
           dbf d0,f_loop1
           lea 80(a4),a4
          dbf d5,f_loop2
         dbf d3,loop1    * ab zum nÑchsten Block

* die Blîcke sind eingetragen, jetzt noch die
* Grafikdaten linear in die LÅcken schreiben
          move #399,d5
grafik_2:  moveq #79,d0
grafik_1:   cmp.b #1,(a3,d0)
            beq gcheck
             move.b (a1)+,(a0,d0)
gcheck:    dbf d0,grafik_1
           lea 80(a3),a3
           lea 80(a0),a0
          dbf d5,grafik_2
         movem.l (sp)+,d0-d1/d3-d4/a0-a4
         rts


* ************ *
* DATA-Segment *
* ************ *
          data
fname2    dc.b "a:\bilder\starp.com",0
*               Filename des gepackten Files
          
          even

* *********** *
* BSS-Segment *
* *********** *
         bss
ssp           ds.l 1
fhandle       ds.w 1
screen_buffer ds.l 8000  * geladenes Bild
pack_speicher ds.l 8000  * gepackte Bilddaten

boolean  ds.l 8000
* (um die noch nicht bearbeiteten Bytes zu finden,
*  denn die Blîcke sind hier markiert)

