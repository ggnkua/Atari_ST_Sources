*** ein file verschluesseln

move.l 4(a7),a5       * laenge rechnen
move.l $c(a5),d0
add.l $14(a5),d0
add.l $1c(a5),d0
add.l #$200,d0        * 200 byte stack
move.l d0,d1
add.l a5,d1
and.l #$fffffffe,d1
move.l d1,a7          * stack vergeben
move.l d0,-(a7)
move.l a5,-(a7)
clr.w -(a7)
move.w #$4a,-(a7)
trap #1               * setblock
add.l #12,a7
move.l #$200,-(a7)    * 512 bytes fuer buffer allocaten
move.w #$48,-(a7)
trap #1
addq.l #6,a7
move.l d0,buffer
cmp.l #$ffffffff,d0   * sind allocated ?
beq error

move.l #titel,-(a7) * schirm loeschen
move.w #9,-(a7)
trap #1
addq.l #6,a7

move.l #text1,-(a7)      * text ausgeben
move.w #9,-(a7)
trap #1
addq.l #6,a7
bsr cr
bsr ask
move.l #name1,a0
move.b #70,(a0)
move.l a0,-(a7)
move.w #10,-(a7)    * readline
trap #1
addq.l #6,a7
move.l #name1a,a1
clr.l d1
move.b -1(a1),d1    * am ende hex 0 als abschluss setzen
move.b #0,0(a1,d1)

bsr cr
bsr ask
move.l #name2,a0
move.b #70,(a0)
move.l a0,-(a7)
move.w #10,-(a7)
trap #1             * noch eine zeile lesen
addq.l #6,a7
move.l #name2a,a1
clr.l d1
move.b -1(a1),d1
move.b #0,0(a1,d1)   *hex 0 ans ende
bsr cr
move.l #text2,-(a7)
move.w #9,-(a7)
trap #1
addq.l #6,a7

 bsr ask
move.l #cdl,a0
move.b #5,(a0)
move.l a0,-(a7)
move.w #10,-(a7)    * readline
 trap #1
 addq.l #6,a7
 move.l #cdl,a0       * a0 zeigt auf zeile
 move.b 1(a0),d0
 cmp.b #5,d0          * sind es auch 5 zeichen ?
 bne error
 addq.l #2,a0         * countbytes ueberspringen
 moveq #4,d2          * 5 buchstaben
 clr.l d3
rd1:
 move.b (a0)+,d0
 sub.b #$20,d0       * in d0 zeichen von space bis hex 5f
 and.l #$3f,d0       * auf 0 bis 3f bringen
 lsl.l #6,d3         * 6 bits hochschieben
 add.l d0,d3         * untere 6 aus d0 nachladen
 dbra d2,rd1:
 add.l d3,d3         * bits 30 -- 1 sind belegt
 move.l d3,rnd       * als rnd(i-1) speichern

 move.w #0,-(a7)
 move.l #name1a,-(a7)
 move.w #$3d,-(a7)   * das erste file oeffnen
 trap #1
 addq.l #8,a7
 move.w d0,fileh1
 cmp.w #0,d0
 bmi error
 
 move.w #0,-(a7)
 move.l #name2a,-(a7)
 move.w #$3c,-(a7)   * das zweite file erzeugen
 trap #1
 addq.l #8,a7
 move.w d0,fileh2
 cmp.w #0,d0
 bge loop
** create fehlgeschlagen
 move.w fileh1,-(a7)   * file 1 schliessen
 move.w #$3e,-(a7)
 trap #1
 addq.l #4,a7
bra error

loop:
 bsr fread
 cmp.w #0,nummer
 beq close
 bsr code
 bsr fwrite
 cmp.w #512,nummer
 beq loop
 bsr close
 bra fertig
******
close:
 move.w fileh1,-(a7) * files schliessen
 move.w #$3e,-(a7)
 trap #1
 move.w fileh2,2(a7)
 trap #1
 addq.l #4,a7
rts

fread:
 move.l buffer,-(a7)
 move.l #512,-(a7)       * ein sektor lesen
 move.w fileh1,-(a7)
 move.w #$3f,-(a7)
 trap #1
 add.l #12,a7
 move.w d0,nummer
 swap d0
 cmp.w #$ffff,d0      * fehler beim lesen ?
 beq abort
rts

code:
 moveq #127,d0
 move.l buffer,a0
code1:
 move.l (a0),d1       *  codierschleife
 bsr random
 eor.l d7,d1
 move.l d1,(a0)+
 dbra d0,code1
rts

fwrite:
move.l buffer,-(a7)
clr.l d0
move.w nummer,d0      * anzahl zurueckschreiben
move.l d0,-(a7)
move.w fileh2,-(a7)
move.w #$40,-(a7)
trap #1
add.l #12,a7
 cmp.w nummer,d0         * fehler beim schreiben ?
 bne abort
rts

ask:
 move.w #63,-(a7) * ausgabe von ?
 move.w #2,-(a7)
 trap #1
 addq.l #4,a7
 rts

cr:
 move.l #crtext,-(a7)  * cr und lf
 move.w #9,-(a7)
 trap #1
 addq.l #6,a7
 rts

fertig:
 move.l #0,(a7)
 trap #1

* berechnet rnd zwischen 1 und 2^31 
* zerstoert d3-d7
* liefert ergebnis in d7
random:
 move.l rnd,d7
 move.l d7,d6
 bsr div
 move.l d4,d5
 muls #-2836,d5
 mulu #42591,d4
 move.l d4,d6
 add.l d4,d4
 add.l d6,d4
 sub.l d4,d7
 moveq #4,d4
ran1:
 move.l d7,d6
 lsl.l#3,d7
 sub.l d6,d7
 dbra d4,ran1
 add.l d5,d7
 bpl randexit
 add.l #$7fffffff,d7
randexit:
 move.l d7,rnd
 rts
div:
 add.l d6,d6
 clr.l d4
 moveq #14,d3
 move.w d6,d5
 swap d6
 and.l #$ffff,d6
div1:
 lsl.w #1,d4
 add.l d6,d6
 lsl.w #1,d5
 bcc div2
 addq.l #1,d6
div2:
 cmp.l #127773,d6
 bmi div3
 sub.l #127773,d6
 addq.w #1,d4
div3:
 dbra d3,div1
 rts

abort:
 bsr close        * vor dem abruch files schliessen
error:
 move.l #errtext,-(a7)
 move.w #9,-(a7)
 trap #1
 addq.l #6,a7      * text ausgeben und auf taste warten
 move.w #1,-(a7)
 trap #1
 addq.l #2,a7
bra fertig

titel:  .dc.b 27,69,"  CODIERPROGRAMM / verschluesselt jedes File !",13,10,0
text1:  .dc.b "Bitte die Filenamen eingeben",0
text2:  .dc.b "5-stelligen Code eingeben",13,10,0
errtext: dc.b " *** Fehler aufgetreten, Abbruch ***",13,10,0
.even
crtext: .dc.b 13,10,0,0
name1:  .ds.b 2
name1a: .ds.b 78
name2:  .ds.b 2
name2a: .ds.b 78
cdl:    .ds.b 8
fileh1: .ds.l 1
fileh2: .ds.l 1
buffer: .ds.l 1  
nummer: .ds.w 1
rnd:    .ds.l 1 
.dc.b " by peter jodda, heidkamp 18,3100 celle//"
.dc.b " algorithm see dr.dobbs #109-november 85"
