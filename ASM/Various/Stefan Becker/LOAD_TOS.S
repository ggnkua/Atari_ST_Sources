
**********************************************************
* Lade ein TOS-IMG von Diskette und starte es.           *
* Klinke auch Flexdisk Version 1.2 aus!                  *
**********************************************************
* (C)1989 by Stefan Becker                               *
**********************************************************
* Assembler: DRI, TC-Assembler o.Ñ. | Tabulatorweite: 10 *
**********************************************************

****************
* Trap-Equals: *
****************

Gemdos    equ       1                   * Trapnummern:
Bios      equ       13
Xbios     equ       14

*************************
* Funktionsnummern etc. *
*************************

fsfirst   equ       $4e                 * TOS-Funktionsnummern
mshrink   equ       $4a
malloc    equ       $48
fread     equ       $3f
fclose    equ       $3e
fopen     equ       $3d
fgetdta   equ       $2f
supexec   equ       38
super     equ       $20
cconws    equ       9
dsetdrv   equ       $e

basepag   equ       4                   * Basepage-Konstanten:
text_sg   equ       12
data_sg   equ       20
bss_sg    equ       28

_sysbase  equ       $4f2                * Systemvariablen...
_bootdev  equ       $446

*****************
* Hauptprogramm *
*****************

prgstart: move.l    basepag(a7),a0      * Startadresse des Programms nach a0
          clr.l     d0
          move.w    #$100,d0            * ProgrammlÑnge: 256 Bytes Base-Page
          add.l     text_sg(a0),d0      * + LÑnge des Text-Segments
          add.l     data_sg(a0),d0      * + LÑnge des Data-Segments
          add.l     bss_sg(a0),d0       * + LÑnge des BSS-Segments
          lea       stacktop,a7         * Stack setzen...

          move.l    d0,-(a7)            * Mshrink(prgstart-256,bedarf)
          move.l    #prgstart-256,-(a7)
          clr.w     -(a7)
          move.w    #mshrink,-(a7)
          trap      #Gemdos
          adda.w    #12,a7

          bsr       checktos            * Welche TOS-Version ist das?

          lea       hello,a0            * Copyright ausgeben
          bsr       print

          lea       tosname,a0          * TOS.IMG laden...
          bsr       rdalloc
          tst.l     d0                  * OK?
          beq       notfound            * Nein, Fehler + Programmende
          move.l    d0,source           * Adresse merken

          bsr       flexkill            * Evtl. Flexdisk eliminieren!

          clr.w     -(a7)               * Dsetdrv(0) (Drive="A")
          move.w    #dsetdrv,-(a7)
          trap      #Gemdos
          addq.l    #4,a7

          move.w    #super,-(a7)        * Supervisormode an
          trap      #Gemdos

          move.w    #0,_bootdev         * Boot-Device:="A"

          lea       stacktop,a7         * Supervisorstack neu setzen
          move.l    source,a0           * TOS anspringen:
          jmp       (a0)                * Auffi geht's!

notfound: lea       notos,a0            * Kein TOS.IMG da => Fehlermeldung
          bra       error

*******************************
* Teste aktuelle TOS-Version. *
* RAM-TOS? => Nix laden!      *
*******************************

checktos: pea       chksup(pc)          * Routine im Supervisormode starten
          move.w    #supexec,-(a7)
          trap      #Xbios
          addq.l    #6,a7

          move.l    os_start,d0         * Lese Startadresse des TOS
          cmp.l     #$fc0000,d0         * Startadresse=ROM?
          beq       isromtos            * Ja, alles in Ordnung!

          lea       onlyrom,a0          * Meldung ausgeben
          bsr       print               * + Programmende
          clr.w     -(a7)               * Pterm()
          trap      #Gemdos
isromtos: rts

chksup:   move.l    _sysbase,a0         * Anfang des TOS suchen:
          move.l    8(a0),d0            * aus Header holen und
          move.l    d0,os_start         * merken
          rts

os_start: dc.l      0                   * Startadresse des TOS!

****************************************
* Flexkill 1.2                         *
****************************************
* (Lîscht den FD-Treiber durch öber-   *
*  schreiben der diversen MAGIC-Werte) *
****************************************

flexkill: pea       flmain(pc)          * Kill-Routine im Supervisormode!
          move.w    #supexec,-(a7)
          trap      #Xbios
          addq.l    #6,a7
          rts                           * Fertig!

flmain:   cmp.l     #"ALEX",$600        * Flexdisk-Markierung da?
          bne       noflex
          clr.l     $600                * Markierung weg!
          move.l    $604,a0             * Zeiger auf Flexdisk-Treiber
          clr.l     $604                * Zeiger weg!
          clr.l     (a0)                * Magic-Header auch weg!
noflex:   rts                           * The end of Flexdisk and soft lies!

*************************
* Gebe eine Meldung aus *
*************************

print:    move.l    a0,-(a7)            * Fehlermeldung ausgeben
          move.w    #cconws,-(a7)
          trap      #Gemdos
          addq.l    #6,a7
          rts

*************************************
* Programmabbruch mit Fehlermeldung *
* Fehlermeldungsstring in a0        *
*************************************

error:    move.l    a0,-(a7)            * Fehlermeldung ausgeben
          move.w    #cconws,-(a7)
          trap      #Gemdos
          addq.l    #6,a7

          pea       taste               * "Bitte Taste drÅcken!" ausgeben
          move.w    #cconws,-(a7)
          trap      #Gemdos
          addq.l    #6,a7

          move.w    #2,-(a7)            * Bconin(2) (Auf Taste warten)
          move.w    #2,-(a7)
          trap      #Bios
          addq.l    #4,a7

endprg:   clr.w     -(a7)
          trap      #Gemdos             * Programmabbruch!!!

**********************************************************
* Lese Datei ein und reserviere gleich Speicher dafÅr    *
**********************************************************
* Ausgbe: d0=Adresse des Puffers =0 falls nicht gefunden *
*         d1=LÑnge der Datei                             *
**********************************************************

rdalloc:  move.l    a0,name             * Namen merken
          clr.w     -(a7)               * Fsfirst(name,0)
          move.l    a0,-(a7)
          move.w    #fsfirst,-(a7)
          trap      #Gemdos
          addq.l    #8,a7
          tst.l     d0                  * Ergebnis?
          bge       found1              * OK => weiter im Text
nf:       clr.l     d0                  * Nix gefunden
          rts
found1:   move.w    #fgetdta,-(a7)      * Adresse des DTA Puffers
          trap      #Gemdos
          addq.l    #2,a7
          move.l    d0,a0
          move.l    26(a0),len          * DateilÑnge auslesen
          move.l    len,-(a7)           * Malloc(len)
          move.w    #malloc,-(a7)
          trap      #Gemdos
          addq.l    #6,a7
          tst.l     d0
          bne       enough              * Genug Speicher da?
          lea       noram,a0            * Nein => Fehlermeldung
          bra       error
enough:   move.l    d0,ptr              * Speicheradresse merken
          clr.w     -(a7)               * Fopen(name,0)
          move.l    name,-(a7)
          move.w    #fopen,-(a7)
          trap      #Gemdos
          addq.l    #8,a7
          tst.w     d0                  * Geklappt?
          bpl       found2              * Ja => weiter im Text
          bra       nf                  * Nein => Fehlermeldung+Abbruch
found2:   move.w    d0,fhandle
          move.l    ptr,-(a7)           * Fopen(fhandle,len,ptr)
          move.l    len,-(a7)
          move.w    d0,-(a7)
          move.w    #fread,-(a7)
          trap      #Gemdos
          lea       12(a7),a7
          cmp.l     len,d0              * geklappt?
          beq       gelesen             * Ja => weiter
          lea       rderror,a0          * Lesefehler+Abbruch
          bra       error
gelesen:  move.w    fhandle,-(a7)       * Fclose(fhandle)
          move.w    #fclose,-(a7)
          trap      #Gemdos
          addq.l    #4,a7
          move.l    ptr,d0              * Ergebnisse liefern!
          move.l    len,d1
          rts

fhandle:  dc.w      0
name:     dc.l      0
ptr:      dc.l      0
len:      dc.l      0
source:   dc.l      0

****************
* Datensegment *
****************

          data

          dc.b      "Hier evtl. TOS-Dateinamen reinpatchen =>"
tosname:  dc.b      "TOS.IMG",0
          dc.w      10
taste:    dc.b      "Bitte Taste drÅcken!",13,10,0
noram:    dc.b      7,13,10
          dc.b      "Fehler: Zu wenig Speicher frei!",13,10,0
rderror:  dc.b      7,13,10
          dc.b      "Fehler: Lesefehler beim Laden des TOS!",13,10,0
notos:    dc.b      7,13,10
          dc.b      "Fehler: TOS.IMG kann nicht gefunden werden!",13,10,0
onlyrom:  dc.b      13,10
          dc.b      "TOS-Starter tut nix bei Ram-TOS!",13,10,0
hello:    dc.b      13,10
          dc.b      "TOS-Startprogramm (C)1989 by Stefan Becker.",13,10
          dc.b      "TOS.IMG wird geladen. Bitte etwas Geduld..."
          dc.b      13,10,0

*************************
* Block-Storage-Segment *
*************************

          bss

junk:     ds.b      $30000

stack:    ds.w      500
stacktop: ds.w      1

          end

***********
* The end *
***********

