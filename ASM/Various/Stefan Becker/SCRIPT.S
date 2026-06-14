
*******************************************
* SCRIPT.S                                *
*******************************************
* Lenkt die TOS-Bildschirmausgabe zusÑtz- *
* lich in einen speziellen Speicherbe-    *
* reich um. Von dort aus kann sie mit     *
* "FIXSCRPT" abgespeichert werden!        *
*******************************************
* XBRA-Kennung: 'SCRI'                    *
*******************************************
* (C)1989 by Stefan Becker                *
* Assembler: TC-Assembler                 *
*******************************************

****************
* Trap-Equals: *
****************

Gemdos    equ       1                   * Trapnummern:
Bios      equ       13
Xbios     equ       14

********************
* Funktionsnummern *
********************

mshrink   equ       $4a
ptermres  equ       $31
supexec   equ       38
cconws    equ       9

**************
* Konstanten *
**************

basepag   equ       4                   * Basepage-Konstanten:
text_sg   equ       12
data_sg   equ       20
bss_sg    equ       28

farbreg   equ       $ff8240             * Farbpalettenregister 0

kennung   equ       'SCRI'              * XBRA-Kennung

stacksize equ       300                 * Programm-Stackgrîûe in Bytes

*****************
* Hauptprogramm *
*****************

prgstart: move.l    basepag(a7),a0      * Startadresse des Programms nach a0
          clr.l     d0
          move.w    #$100,d0            * ProgrammlÑnge: 256 Bytes Base-Page
          add.l     text_sg(a0),d0      * + LÑnge des Text-Segments
          add.l     data_sg(a0),d0      * + LÑnge des Data-Segments
          add.l     bss_sg(a0),d0       * + LÑnge des BSS-Segments
          move.l    d0,bedarf           * Speicherbedarf merken
          lea       stacktop,a7         * Stack setzen...

          bsr       lookdoub            * Testen, ob SCRIPT bereits resident
          bsr       getram              * Speichergrîûe fÅr Puffer ermitteln

          move.l    bedarf,-(a7)        * Mshrink(prgstart-256,bedarf)
          move.l    #prgstart-256,-(a7)
          clr.w     -(a7)
          move.w    #mshrink,-(a7)
          trap      #Gemdos
          adda.w    #12,a7
          tst.l     d0                  * Fehler?
          beq       enough              * Nein, Auf Wiedersehen

          pea       noram               * Fehlermeldung
          bra       errex               * Programmabbruch

enough:   bsr       initbuf             * Puffer initialisieren
          bsr       install             * Traps 13,14 umlenken

          pea       installst           * Installiert-Meldung ausgeben
          move.w    #cconws,-(a7)
          trap      #Gemdos
          addq.l    #6,a7

          lea       size1,a0            * Gebe installierte Grîûe aus
          bsr       Cconwstc
          move.l    bufsize,d0
          bsr       dezout
          lea       size2,a0
          bsr       Cconwstc

          clr.w     -(a7)               * Return-Code 0
          move.l    bedarf,-(a7)        * Speicherbedarf
          move.w    #ptermres,-(a7)     * Ptermres
          trap      #1                  * ausfÅhren => Programmende

*****************************
* Ermittle Gîûe des Puffers *
*****************************

getram:   bsr       getsize             * Wunschgrîûe aus Namen auslesen
          move.l    d0,bufsize          * Grîûe merken
          add.l     d0,bedarf           * Speicherbedarf+=Puffergrîûe
          rts

*************************************************
* Sieh nach, ob Scripts bereits installiert ist *
*************************************************

lookdoub: clr.w     dejavu              * Flagge auf noch nicht da setzen!

          pea       tstmain(pc)         * Supervisormode
          move.w    #supexec,-(a7)
          trap      #Xbios
          addq.l    #6,a7

          tst.w     dejavu              * War Script bereits installiert?
          bne       douberr             * Ja, Fehlermeldung ausgeben
          rts                           * Nein, alles OK

tstmain:  move.l    $46e,a0             * Monitor-Wechsel-Vektor holen
          cmp.l     #kennung,8(a0)      * Script-Kennung vorhanden?
          bne       nixda1              * Nein, fertig
          move.w    #-1,dejavu          * Ja, Flagge setzen
nixda1:   rts                           * Fertig mit dem Supervisorkram

douberr:  pea       doublein            * Fehlermeldung ausgeben
errex:    move.w    #cconws,-(a7)
          trap      #Gemdos
          addq.l    #6,a7

          move.w    #2,-(a7)            * Bconin(2) aufrufen (=Tastendruck)
          move.w    #2,-(a7)
          trap      #Bios
          addq.l    #4,a7

          clr.w     -(a7)               * Programmabbruch!!!
          trap      #Gemdos

*************************
* Puffer initialisieren *
*************************

initbuf:  lea       buffer,a0           * Pufferanfang laden
          move.l    a0,buffers          * ins Info-Feld fÅr Fixscript
          move.l    a0,bptr             * Zeiger auf Pufferanfang
          rts

***********************************************
* Traps und Monitor-Wechsel-Vektor  umlenken  *
***********************************************

install:  pea       inmain(pc)          * Umlenkungen im Supervisormode
          move.w    #supexec,-(a7)
          trap      #Xbios
          addq.l    #6,a7
          rts

inmain:   lea       new_13(pc),a0       * Trap #13 umlenken
          move.l    $b4,old_13
          move.l    a0,$b4

          lea       new_1(pc),a0        * Trap #1 umlenken
          move.l    $84,old_1
          move.l    a0,$84

          lea       monstruc(pc),a0     * Monitor-Wechsel-Vektor umlenken
          move.l    $46e,oldmon         * vorher alten Vektor merken
          move.l    a0,$46e
          rts

***********************
* Neue Trap13-Routine *
***********************

xbra_13:  dc.l      'XBRA'              * XBRA-Struktur anlegen:
          dc.l      kennung             * Identifikation: FAKE-Drive
old_13:   dc.l      0                   * vorerst 0, dann alte Trap-Adr.

new_13:   move.l    a7,a0
          move.w    (a0),d0             * Statuswort laden
          btst      #13,d0              * Supervisormode?
          bne       sup_13              * Ja!
          move.l    usp,a0              * Parameter des laufenden Programms
          subq.l    #6,a0               * holen...
sup_13:   addq.l    #6,a0               * Entweder USP oder SSP je nach S-Bit
          move.w    (a0),d0             * gewÑhlte Funktionsnummer lesen

          cmp.w     #3,d0               * Bconout?
          beq       bco

nix_13:   move.l    old_13,a0           * Etwas anderes, wie normal...
          jmp       (a0)

************************
* Neue Bconout-Routine *
************************

bco:      cmp.w     #2,2(a0)            * Volume=2? (Console)
          bne       nix_13              * Nein, normal ans Bios weitergeben
          move.w    4(a0),d0
          bsr       savech              * Zeichen merken und ...
          bra       nix_13              * ans Bios weitergeben

**********************
* Neue Trap1-Routine *
**********************

xbra_1:   dc.l      'XBRA'              * XBRA-Struktur anlegen:
          dc.l      kennung             * Identifikation: FAKE-Drive
old_1:    dc.l      0                   * vorerst 0, dann alte Trap-Adr.

new_1:    move.l    a7,a0
          move.w    (a0),d0             * Statuswort laden
          btst      #13,d0              * Supervisormode?
          bne       sup_1               * Ja!
          move.l    usp,a0              * Parameter des laufenden Programms
          subq.l    #6,a0               * holen...
sup_1:    addq.l    #6,a0               * Entweder USP oder SSP je nach S-Bit
          move.w    (a0),d0             * gewÑhlte Funktionsnummer lesen

          cmp.w     #2,d0               * Cconout?
          beq       ccon
          cmp.w     #9,d0               * Cconws?
          beq       ccws
          cmp.w     #$40,d0             * Fwrite?
          beq       fwrt

nix_1:    move.l    old_1,a0            * wie normal
          jmp       (a0)

************************
* Neue Cconout-Routine *
************************

ccon:     move.w    2(a0),d0            * Zeichen auslesen
          bsr       savech              * und merken
          bra       nix_1               * weiter wie sonst

***********************
* Neue Cconws-Routine *
***********************

ccws:     move.l    2(a0),a0            * Stringzeiger holen
          bsr       savestr             * und ganzen String merken
          bra       nix_1               * weiter wie sonst

***********************
* Neue Fwrite-Routine *
***********************

fwrt:     cmp.l     #1,2(a0)            * handle=1? (Console)
          bne       nix_1               * Nein, normal weiter
          move.l    4(a0),d0            * LÑnge an saveblk Åbergeben
          move.l    8(a0),a0            * Anfang an saveblk Åbergeben
          bsr       saveblk             * Speicherblock merken
          bra       nix_1               * weiter wie gehabt

********************************
* Zeichen in Puffer Åbernehmen *
* TC-Code: savech(char c)      *
********************************
* Eingabe: ch in d0            *
********************************

savech:   move.w    d3,-(a7)
          move.b    d0,d3
          move.l    bufsize,d1
          lea       buffer,a0
          adda.l    d1,a0
          movea.l   bptr,a1
          cmpa.l    a0,a1
          bls       L101AE
          bsr       inv
          bra       L101BC
L101AE:   movea.l   bptr,a0
          addq.l    #1,bptr
          move.b    d3,(a0)
L101BC:   move.w    (a7)+,d3
          rts

*******************************
* String in Puffer Åbernehmen *
* TC-Code: savestr(char *s)   *
*******************************
* Eingabe: *s in a0           *
*******************************

savestr:  move.l    a2,-(a7)
          movea.l   a0,a2
          bra       L101D2
L101CC:   move.b    (a2)+,d0
          jsr       savech(pc)
L101D2:   move.b    (a2),d0
          bne       L101CC
          movea.l   (a7)+,a2
          rts

***************************************
* Speicherblock in Puffer Åbernehmen  *
* TC-Code: saveblk(char *s, long len) *
***************************************
* Eingabe: *s   in a                  *
*           len in d0                 *
***************************************

saveblk:  movem.l   d3-d4/a2,-(a7)
          movea.l   a0,a2
          move.l    d0,d4
          moveq     #0,d3
          bra       L101F4
L101EC:   move.b    (a2)+,d0
          jsr       savech(pc)
          addq.l    #1,d3
L101F4:   cmp.l     d3,d4
          bgt       L101EC
          movem.l   (a7)+,d3-d4/a2
          rts

*****************************************
* Kurzes Bildschirmflackern=Puffer voll *
*****************************************

inv:      tst.l     full                * "Puffer voll" schon angezeigt?
          bne       inv_bye             * Ja, das tut's!
          move.w    #10,d0              * Nein, 10X "flackern"
al_loop:  bsr       invers
          bsr       wait
          bsr       normal
          bsr       wait
          dbf       d0,al_loop
          move.l    #-1,full            * Flagge setzen
inv_bye:  rts
*
* Bildschirm invertieren
*
invers:   move.w    farbreg,d1
          bclr      #0,d1
          move.w    d1,farbreg
          rts
*
* Bildschirm normal
*
normal:   move.w    farbreg,d1
          bset      #0,d1
          move.w    d1,farbreg
          rts
*
* kurze Pause
*
wait:     move.l    #20000,d1
wloop:    subq.l    #1,d1
          bne       wloop
          rts

*************************************
* Teste, ob Zeichen eine Ziffer ist *
*************************************

isdig:    cmp.b     #$30,d0
          bcs       L10194
          cmp.b     #$39,d0
          bhi       L10194
          moveq     #1,d1
          bra       L10196
L10194:   clr.w     d1
L10196:   move.w    d1,d0
          rts

*********************************
* Wandle einen String eine Zahl *
*********************************

doconv:   move.l    d3,-(a7)
          move.l    a2,-(a7)
          movea.l   a0,a2
          moveq     #0,d3
          bra       L101C0
L101AA:   move.l    d3,d0
          lsl.l     #2,d0
          add.l     d3,d0
          add.l     d0,d0
          move.l    d0,d3
          clr.w     d1
          move.b    (a2)+,d1
          sub.w     #$30,d1
          ext.l     d1
          add.l     d1,d3
L101C0:   move.b    (a2),d0
          jsr       isdig(pc)
          tst.w     d0
          bne       L101AA
          move.l    d3,d0
          movea.l   (a7)+,a2
          move.l    (a7)+,d3
          rts

**************************************
* Lese Speicherbedarf aus Dateinamen *
**************************************

getsize:  move.l    d3,-(a7)
          move.l    a2,-(a7)
          jsr       Fgetdta(pc)
          movea.l   a0,a2
          clr.w     d0
          lea       name,a0
          jsr       Fsfirst(pc)
          tst.w     d0
          blt       L101FE
          lea       $24(a2),a0
          jsr       doconv(pc)
          move.l    d0,d3
          bne       L10206
L101FE:   move.l    #$19000,d0
          bra       L1020C
L10206:   move.l    d3,d0
          moveq     #$A,d1
          lsl.l     d1,d0
L1020C:   movea.l   (a7)+,a2
          move.l    (a7)+,d3
          rts

******************
* Fsfirst-Aufruf *
******************

Fsfirst:  move.w    d0,-(a7)
          move.l    a0,-(a7)
          move.w    #$4E,-(a7) ;Fsfirst
          trap      #1 ;GEMDOS
          addq.w    #8,a7
          rts

******************
* Fgetdta-Aufruf *
******************

Fgetdta:  move.w    #$2F,-(a7) ;Fgetdta
          trap      #1 ;GEMDOS
          addq.w    #2,a7
          movea.l   d0,a0
          rts

*******************************
* Dezimale Long-Zahlenausgabe *
* (TC-Code)                   *
*******************************
* Zahl in d0                  *
*******************************

dezout:   link      a6,#-$12
          movem.l   d3-d4/a2-a3,-(a7)
          move.l    d0,d4
          lea       -18(a6),a2
          movea.l   a2,a3
          clr.w     d3
          bra       L101A4
L1019E:   move.b    #$20,(a3)+
          addq.w    #1,d3
L101A4:   cmp.w     #$10,d3
          blt       L1019E
          clr.b     (a3)
          lea       $F(a2),a3
          moveq     #$11,d3
L101B2:   subq.w    #1,d3
          move.l    d4,d0
          moveq     #$A,d1
          jsr       _lmod(pc)
          add.b     #$30,d0
          move.b    d0,(a3)
          subq.w    #1,a3
          move.l    d4,d0
          moveq     #$A,d1
          jsr       _ldiv(pc)
          move.l    d0,d4
          tst.l     d0
          bne       L101B2
          tst.w     d3
          beq       L101B2
          movea.l   a2,a3
          bra       L101DC
L101DA:   addq.w    #1,a3
L101DC:   cmpi.b    #$20,(a3)
          beq       L101DA
          movea.l   a3,a0
          jsr       Cconwstc(pc)
          movem.l   (a7)+,d3-d4/a2-a3
          unlk      a6
          rts

_ldiv:    move.l    d0,d2
          bpl       L1022C
          neg.l     d0
L1022C:   eor.l     d1,d2
          movea.l   d2,a1
          tst.l     d1
          bpl       L10236
          neg.l     d1
L10236:   move.l    d1,d2
          swap      d2
          tst.w     d2
          bne       L10272
          move.l    d0,d2
          swap      d2
          tst.w     d2
          bne       L10256
          divu      d1,d0
          swap      d0
          clr.w     d0
          swap      d0
          move.l    a1,d2
          bpl       L10254
          neg.l     d0
L10254:   rts

L10256:   clr.w     d0
          swap      d0
          swap      d2
          divu      d1,d0
          movea.w   d0,a0
          move.w    d2,d0
          divu      d1,d0
          swap      d0
          move.w    a0,d0
          swap      d0
          move.l    a1,d2
          bpl       L10270
          neg.l     d0
L10270:   rts

L10272:   movea.l   d1,a0
          swap      d0
          moveq     #0,d1
          move.w    d0,d1
          clr.w     d0
          moveq     #$F,d2
          add.l     d0,d0
          addx.l    d1,d1
L10282:   sub.l     a0,d1
          bcc       L10288
          add.l     a0,d1
L10288:   addx.l    d0,d0
          addx.l    d1,d1
          dbf       d2,L10282
          not.w     d0
          move.l    a1,d2
          bpl       L10298
          neg.l     d0
L10298:   rts

_lmod:    movea.l   d0,a1
          move.l    d0,d2
          bpl       L102A2
          neg.l     d0
L102A2:   tst.l     d1
          bpl       L102A8
          neg.l     d1
L102A8:   move.l    d1,d2
          swap      d2
          tst.w     d2
          bne       L102DE
          move.l    d0,d2
          swap      d2
          tst.w     d2
          bne       L102C6
          divu      d1,d0
          clr.w     d0
          swap      d0
          move.l    a1,d2
          bpl       L102C4
          neg.l     d0
L102C4:   rts

L102C6:   clr.w     d0
          swap      d0
          swap      d2
          divu      d1,d0
          move.w    d2,d0
          divu      d1,d0
          clr.w     d0
          swap      d0
          move.l    a1,d2
          bpl       L102DC
          neg.l     d0
L102DC:   rts

L102DE:   movea.l   d1,a0
          move.l    d0,d1
          clr.w     d0
          swap      d0
          swap      d1
          clr.w     d1
          moveq     #$F,d2
          add.l     d1,d1
          addx.l    d0,d0
L102F0:   sub.l     a0,d0
          bcc       L102F6
          add.l     a0,d0
L102F6:   addx.l    d1,d1
          addx.l    d0,d0
          dbf       d2,L102F0
          roxr.l    #1,d0
          move.l    a1,d2
          bpl       L10306
          neg.l     d0
L10306:   rts

****************************
* Cconws-Aufruf in Turbo-C *
****************************

Cconwstc: move.l    a0,-(a7)
          move.w    #9,-(a7) ;Cconws
          trap      #1 ;GEMDOS
          addq.w    #6,a7
          rts

**************************************
* Struktur fÅr FIXSCRIPT (Åber $46e) *
**************************************
* FIXSCRIPT ermittelt so Position &  *
* LÑnge des Puffers                  *
**************************************

monstruc: move.l    oldmon,a0           * Vektor bleibt wie vorher
          jmp       (a0)

          dc.l      kennung             * Markierung: Hier Script-ST!
buffers:  dc.l      0                   * Eintrag   : Pufferanfang
bptr:     dc.l      0                   * Eintrag   : Pufferzeiger
bufsize:  dc.l      0                   * Gîûe des Script-Puffers in Bytes
full:     dc.l      0                   * Flagge    : <>0 => Puffer voll!

******************
* Programm-Daten *
******************

          data

***********
* Strings *
***********

name:     dc.b      'SCRIPT??.TOS',0

noram:    dc.b      13,10
          dc.b      "Zu wenig Speicher fÅr Script-ST!!"
          dc.b      13,10,0

installst:dc.b      13,10
          dc.b      "Script-ST resident. (C)1989 by Stefan Becker."
          dc.b      13,10,0

doublein: dc.b      13,10
          dc.b      "Script-ST war bereits resident!!!"
          dc.b      13,10,0

size1:    dc.b      "Installierte Grîûe: ",0
size2:    dc.b      " Bytes.",13,10,0

***************
* Bss-Segment *
* (Variablen) *
***************

          bss

dejavu:   ds.w      1                   * 1: Script war vorher schon da!
bedarf:   ds.l      1                   * Speicherbedarf des Programms
oldmon:   ds.l      1                   * alter Monitor-Wechsel-Vektor

stack:    ds.w      stacksize/2         * Speicher fÅr Programm-Stack
stacktop: ds.w      1

buffer:   ds.w      1                   * Ab hier folgt der Puffer!!!

          end

