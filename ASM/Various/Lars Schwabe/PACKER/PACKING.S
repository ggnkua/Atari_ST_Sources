*   Blockorientiertes Packen von S/W-Bildern    *
* --------------------------------------------- *
*                    ' pack:'                   *
* EINGABE: A0 - Adresse des 32000 Bytes Screens *
*          A1 - Adresse des 'Packspeichers'     *
*                                               *
* AUSGABE: A0   - Adresse des 32000Byte Screens *
*          A1   - Adresse des 'Packspeichers'   *
*          D0.L - L„nge der gepacken Datei      *
* --------------------------------------------- *
*   by Lars Schwabe   (c) 1992 MAXON Computer   *
*       (erstellt mit dem Devpac Assembler)     *
* ********************************************* *


         clr  -(sp)          * File mit den Bild-
         pea  fname          * daten ”ffnen
         move #$3d,-(sp)
         trap #1
         addq.l #8,sp
         move d0,fhandle
         pea screen_buffer   * Bitmap einlesen
         move.l #32000,-(sp)
         move fhandle,-(sp)
         move #$3f,-(sp)
         trap #1
         add.l #12,sp
         move fhandle,-(sp)  * File schliežen
         move #$3e,-(sp)
         trap #1
         addq.l #4,sp

          lea screen_buffer,a0
          lea pack_speicher,a1
          jsr pack
          move.l a1,adresse
          move.l d0,laenge

         clr -(sp)        * File fr's gepackte
         pea save_name    * Bild erstellen
         move #$3c,-(sp)
         trap #1
         addq.l #8,sp
         move d0,fhandle
         move.l adresse,-(sp)  * Daten schreiben
         move.l laenge,-(sp)
         move fhandle,-(sp)
         move #$40,-(sp)
         trap #1
         add.l #12,sp
         move fhandle,-(sp)    * File schliežen
         move #$3e,-(sp)
         trap #1
         addq.l #4,sp
         clr -(sp)
         trap #1


* --------------------- *
* P A C K R O U T I N E *
* --------------------- *
pack:    movem.l d1-d7/a0-a6,-(sp)
         move.l a1,a4
         clr (a1)          * Blockz„hler auf null
         addq.l #2,a4      * A4=Anfang der Daten
         lea boolean,a2
         move.l a0,a6      * Daten sichern...
         moveq #0,d7       * D6/D7 = X/Y-Z„hler
pl1:      moveq #0,d6      * (aufw„rts z„hlend)
pl2:       move.l a6,a3
           move.b (a6)+,d0 * Byte heraussuchen...
           cmp.b #1,(a2)   * wurde das Byte schon
           beq pl_end      * bearbeitet ???

* gr”žtes Rechteck ab A3 nach D4-D5 schaffen
           move.b d0,byte
           move.l a2,a5
           clr flaeche
           clr hoehe
           moveq #81,d1 * D1 = Spalten bis zum
           sub d6,d1    *      rechten Rand
           move #401,d2 * D2 = Zeilen bis zum
           sub d7,d2    *      unteren Rand
           moveq #-1,d4 * D4 = vorige Breite
           moveq #1,d5  * D5 = H”he (anfangs 1)
           moveq #1,d3  * D3 = akt. Breite
bl1:        cmp d1,d3
            beq failed  * rechten Rand erreicht ?
            cmp d2,d5
            beq ende    * unterer Rand erreicht ?
            cmp.b (a3,d3),d0
            bne failed
            cmp.b #1,(a5,d3) * ist das Byte schon
            beq failed       * in einem Block ???
             addq #1,d3 * rechts war noch ein Byte
             bra.s bl1
failed:     cmp #0,d3   * ist der Block nach unten
            beq ende    * hin abgeschlossen ?
            cmp d3,d4
            bhi neue_b
             move d4,d3     * neue Breite > alte
neue_b:     move d3,d4
            mulu d5,d3      * (Fl„che) A = D5 * D3
            cmp flaeche,d3  * ist diese kleiner
            bls f_kleiner   * als die gr”žte ?
             move d3,flaeche
             move d5,hoehe  * (bessere H”he &  A)
f_kleiner:  lea 80(a3),a3   * neue Zeile
            lea 80(a5),a5   * neue 'Boolean-Reihe'
            addq #1,d5
            moveq #0,d3  * Breite der akt. Zeile 0
            bra.s bl1

* nun muž die passende Breite ermittelt werden
ende:      moveq #0,d4
           move flaeche,d4
           move hoehe,d5
           divu d5,d4

* lohnt es sich berhaupt den Block einzutragen ?
* d.h. (Fl„che) A > 5
          move d4,d0
          mulu d5,d0
          cmp #5,d0
          bls pl_end
           addq #1,(a1)    * Blockz„hler erh”hen
           move.b d6,(a4)+ * X & Y eintragen
           move.b d7,(a4)+
           btst #8,d7
           beq ybit8
            bset #7,-2(a4) * das 7 Bit setzen
ybit8:     move.b d4,(a4)+ * Breite/H”he schreiben
           move.b d5,(a4)+
           move.b byte,(a4)+ * Byte eintragen
           btst #8,d5
           beq fill          * 7. Bit der Breite
            bset #7,-3(a4)   * als 8. Bit der H”he

* im 'Boolean-Feld' die Bytes des Blocks markieren
fill:      subq #1,d4       * Breite
           subq #1,d5       * H”he
           move.l a2,a5     * A5 = Pointer auf den
f_loop2:    move d4,d0      *      ersten Wert
f_loop1:     move.b #1,(a5,d0)
            dbf d0,f_loop1
            lea 80(a5),a5
           dbf d5,f_loop2

pl_end:   addq.l #1,a2  * Boolean-Pointer erh”hen
          addq #1,d6    * X-Schleife schliežen
          cmp #80,d6
          bne pl2
         addq #1,d7     * Y-Schleife schliežen
         cmp #400,d7
         bne pl1

* alle Bl”cke sind eingetragen, jetzt werden
* die restlichen Daten gesucht...
           move (a1),d5
           mulu #5,d5
           addq.l #2,d5     * in D5 wird die
           move.l a0,a3     * L„nge berechnet
           lea boolean,a5
           move #399,d1
de_loop2:  moveq #79,d0
de_loop1:   cmp.b #1,(a5,d0)
            beq de_check1
             addq.l #1,d5   * Dateil„nge erh”hen
             move.b (a3,d0),(a4)+
de_check1:  dbf d0,de_loop1
           lea 80(a3),a3    * neue Bildschirmzeile
           lea 80(a5),a5    * neue 'Boolean-Zeile'
           dbf d1,de_loop2
           move.l d5,d0     * L„nge der Datei
           movem.l (sp)+,d1-d7/a0-a6           
           rts


* ************ *
* DATA-Segment *
* ************ *
          data
fname     dc.b "a:\bilder\olympic.art",0
*              Filename der 32000er-Bitmap

          even
save_name dc.b "a:\bilder\olympic.com",0
*              gepacktes Bild 

          even

* *********** *
* BSS-Segment *
* *********** *
         bss
* vom Hauptprogramm
ssp      ds.l 1
adresse  ds.l 1
laenge   ds.l 1
fhandle  ds.w 1
screen_buffer ds.l 8000     * geladenes Bild
pack_speicher ds.l 8000     * gepackte Bilddaten

* ab hier zur Packroutine
boolean  ds.l 8000   * Boolschen Array zum Packen
hoehe    ds.w 1
flaeche  ds.w 1      * Fl„cheninhalt eines Blocks
byte     ds.b 1      * Byte des Blocks

