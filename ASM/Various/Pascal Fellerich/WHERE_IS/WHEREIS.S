**********************************************************************
*
*  WHEREIS: kleiner aber feiner FILE-Searcher
*
*  von:   Pascal Fellerich
*         45 rue des Genˆts
*         L-3482 Dudelange
*

               opt F+,P+,O+,W+          ;Fastload,PC-relativ,Optimierungen ein
               path 'E:\UTILITY\'       ;wohin damit?
               output 'WHEREIS.TTP'     ;Name?

               >PART 'Strukturdefinitionen'
*
* Disk Transfer Area - nur fr STACKFRAME innerhalb dieser Routine !!
*
D_RESERVED     equ -44                  ;TOS-interne Infos
D_ATTRIB       equ -23                  ;Attribut
D_TIME         equ -22                  ;Zeit
D_DATE         equ -20
D_LENGTH       equ -18
D_FNAME        equ -14

DTA_LEN        equ 44

* Bitflags:
SSIZE          equ 0
;SDATE          equ 1
;SATTRIB        equ 2

               endpart
               >PART 'Gesabbels'

MAXDIRDEPTH    equ 8                    ;maximal 8 Verschachtelungen erlaubt

STACK          equ 1024                 ; > MAXDIRDEPTH*(DTA_LEN+12) !!

VERSION        equ 0
REVISION       equ 6

               endpart
               >PART 'Header'
*
* Startup-Code
*
Start:    movea.l   4(sp),a4            ;Basepageadresse holen
          movea.w   #$0100+STACK,a5     ;Gr”že der Basepage + Stackgr”že (1k)
          adda.l    12(a4),a5           ;+ Gr”že des TEXT-Segments
          adda.l    20(a4),a5           ;+ Gr”že des DATA-Segments
          adda.l    28(a4),a5           ;+ Gr”že des BSS-Segments
          move.l    a5,d1               ;= Gesamtl„nge des Programms
          and.w     #$FFFE,d1           ;L„nge nun gerade
          add.l     a4,d1               ;+ Programmstart (Basepageadresse)
          movea.l   d1,sp               ;Stack endet dort
          move.l    a5,-(sp)            ;Programml„nge
          move.l    a4,-(sp)            ;Adresse der Basepage
          move.l    #$4A0000,-(sp)      ;Funktionsnummer + Dummyword (0)
          trap      #1                  ;Mshrink(0,Basepageadr,Prgl„nge)
          lea       12(sp),sp           ;Nur noch den Stack korrigieren
;Das war schon alles. In A4 befindet sich noch die Basepageadresse und in a5
;liegt die totale Programml„nge (TRAP #1 zerst”rt D0-D2 und A0-A2!)
          lea       varbase(pc),a6
               base A6,varbase
          move.l    a4,_bpage(a6)
          bsr.s     main                ;Aufruf des Hauptprogrammes
;TERMINIEREN:

          move.w    d0,-(sp)
          move.w    #Pterm,-(sp)
          trap      #1
               endpart
               >PART 'MAIN'
*
* Hauptroutine!
*
main:     lea       title(pc),a0        ;Einschaltmeldung erstmal ausgeben
          bsr       conws
          bsr       getfirstpara        ;ersten Parameter von der CMDLIN holen
beginparam:
          bmi       usage
          cmpi.b    #'-',(a0)           ;ist es ein Schalter?
          beq       switches
; sonst erstes Argument als Searchpattern definieren
          moveq     #'*',d1             ;Allquantor
          moveq     #'?',d2             ;Einzelquantor
          move.l    a0,patstart(a6)
          movea.l   a0,a1
          bsr       Pack_pps            ;Pack Pattern String
          adda.w    d0,a1
          move.l    a1,patend(a6)       ;(new packed) pattern defined!

          moveq     #0,d7               ;Filez„hler in d7 (global!!!)
          bsr       getnextpara         ;Pfad angegeben???
          bpl.s     try1                ;ja!

          bsr       GetPath
          bra.s     try2

trynext:  bsr       getnextpara         ;n„chsten Parameter von der CMDlin holen
          bmi.s     thats_it
try1:     bsr       setpath             ;Pfad von a0..a1 abarbeiten
          bmi.s     try3                ;Fehler -> Abbruch
try2:     bsr       ffind
          beq.s     trynext             ;Fehler?
try3:     rts

thats_it: move.w    d7,d0
          beq.s     ffcnt3
          lea       pathbuffer(pc),a0
          movea.l   a0,a3
          move.b    #' ',(a0)+
          bsr       itoa                ;Anzahl files einsetzen
          subq.w    #1,a0
          lea       msgfiles(pc),a1

ffcnt:    move.b    (a1)+,(a0)+
          bne.s     ffcnt

          tst.w     dflags(a6)
          beq.s     ffcnt2
          move.b    #' ',-1(a0)
          move.l    totallen(pc),d0
          bsr       ltoa
          subq.w    #1,a0
          lea       msgbytes(pc),a1
ffcnt1:   move.b    (a1)+,(a0)+
          bne.s     ffcnt1
ffcnt2:   movea.l   a3,a0
          bsr       conws
          rts

ffcnt3:   lea       msgnofile(pc),a0
          bsr       conws
          rts

usage:    lea       use_it(pc),a0
          bsr       conws
          moveq     #0,d0
          rts                           ;back to caller

* Schalter auswerten:
switches: addq.w    #1,a0               ;'-' berspringen

          move.b    (a0)+,d1            ;Schalter holen

;          cmpi.b    #'A',d1             ;Attributes
;          cmpi.b    #'D',d1             ;
;          cmpi.b    #'F',d1
          cmpi.b    #'S',d1             ;NUR SIZE ERLAUBT!
          bne.s     s1
          st        dflags(a6)

s1:       bsr.s     getnextpara
          bra       beginparam          ;dort geht's hin

               endpart
               >PART 'Parse CMD line'
*
* liest Kommandozeile und liefert:
*  a0: Argument-Start
*  a1: Argument-Ende
*  d0.w : Arg.length
*
getfirstpara:
          movea.l   _bpage(pc),a1
          lea       128(a1),a1
          move.b    (a1)+,d2
          ext.w     d2
          ble.s     nocmd
          move.w    d2,cmdndx(a6)
          move.l    a1,cmdptr(a6)

getnextpara:
          move.w    cmdndx(pc),d2
          movea.l   cmdptr(pc),a1
cutspaces:
          move.b    (a1)+,d0
          beq.s     nocmd
          cmpi.b    #13,d0              ;CR = EOL!
          beq.s     nocmd
          cmpi.b    #32,d0              ;trim Spaces
          beq.s     cutspaces
          cmpi.b    #9,d0               ;and TAB's
          beq.s     cutspaces

          subq.l    #1,a1               ;VOR (!) ersten Char setzen
          movea.l   a1,a0               ;Startzeiger
          moveq     #0,d0               ;Argumentenl„nge
sloop:    move.b    (a1),d1
          beq.s     eoarg
          cmpi.b    #13,d1
          beq.s     eoarg
          cmpi.b    #32,d1              ;Space ?
          beq.s     eoarg
          cmpi.b    #'a',d1             ;upper$
          blt.s     sloop1
          cmpi.b    #'z',d1
          bgt.s     sloop1
          subi.b    #$20,(a1)
sloop1:   addq.w    #1,d0
          addq.w    #1,a1
          dbeq      d2,sloop

eoarg:    subq.w    #1,d2
          move.w    d2,cmdndx(a6)
          move.l    a1,cmdptr(a6)
          tst.w     d0
          rts
nocmd:    moveq     #-1,d0
          rts
               endpart
               >PART 'Set Default paths'
*
* Pfadangabe zwischen a0 und a1 (exclusive) als stdpfad setzen
*
setpath:  movea.l   a0,a2
          move.b    (a0)+,d0
          cmpa.l    a0,a1
          bcs.s     setp1               ;ende des Pfads
          cmpi.b    #'\',d0             ;?direkte Pfadangabe?
          beq.s     isapath3
          move.b    d0,d2
          move.b    (a0)+,d0
          cmpa.l    a0,a1
          bcs.s     setp1
          cmpi.b    #':',d0
          beq.s     isadrive
          movea.l   a2,a0               ;Pfad angegeben
          bra.s     isapath

isadrive: andi.w    #$FF,d2
          move.b    d2,pathbuffer(a6)
          subi.w    #'A',d2             ;Drive angeben; sonst beibehalten.
          movem.l   a0-a1,-(sp)
* neues aktuelles Laufwerk setzen:
          move.w    d2,-(sp)
          move.w    #Dsetdrv,-(sp)
          trap      #1
          addq.w    #4,sp
          movem.l   (sp)+,a0-a1
          tst.w     d0
          bmi.s     setp2
          cmpa.l    a0,a1               ;am Ende angekommen?
          bne.s     isapath
          bsr       rootdir
          bra.s     endit1

isapath3: subq.w    #1,a0
isapath:  pea       (a0)
          clr.b     (a1)                ;Pfadangabe nullterminieren
          move.w    #Dsetpath,-(sp)
          trap      #1
          addq.w    #6,sp

endit1:   move.w    d0,-(sp)
          bsr.s     GetPath             ;intern den 'echten' Pfad merken
          move.w    (sp)+,d0
          rts

setp1:    moveq     #-34,d0             ;Path not found
setp2:    rts

* Pfad aus GEMDOS auslesen & intern merken
GetPath:  move.w    #Dgetdrv,-(sp)
          trap      #1
          addq.w    #2,sp
          addi.b    #'A',d0
          lea       pathbuffer(pc),a1
          move.l    #'?:\.',(a1)
          move.b    d0,(a1)
          clr.w     -(sp)               ;Active drive
          pea       3(a1)
          move.w    #Dgetpath,-(sp)
          trap      #1
          addq.w    #2,sp
          movea.l   (sp)+,a1            ;Zeiger IN den pfad (erster Backslash!)
          addq.w    #2,sp
* Gemdos liefert manchmal (!) als Pfad "DIR\..." aber auch "\DIR\..." !!!!!!
GetPath1: movea.l   a1,a0
          cmpi.b    #'\',(a1)           ;Fall 2 ?
          bne.s     GetPath3            ;nein
GetPath2: move.b    1(a0),(a0)+         ;sonst Pfad ein Byte verschieben...
          bne.s     GetPath2
          movea.l   a1,a0               ;A0 restaurieren

GetPath3: tst.b     (a1)+               ;Stringende suchen
          bne.s     GetPath3
          subq.w    #1,a1
          cmpi.b    #'\',-1(a1)         ;mit Backslash terminiert?
          beq.s     GetPath4
          move.b    #'\',(a1)+          ;sonst anh„ngen!
GetPath4: suba.l    a0,a1
          move.w    a1,pbufndx(a6)      ;merken
          rts
               endpart
               >PART 'ULONG conversion'
**********************************************************************
* ltoa: Convert ulong to string.
* Parameter: a0   - Ptr auf Stringdaten
*            d0.w - Wert
* Return:    a0   - Ptr auf Nullterminierung des Strings
*
* Ver„ndert werden: d1,d2,d3,a0,a1                                   *
**********************************************************************
ltoa:     move.l    d4,-(sp)
          moveq     #9,d1               ;maximale Durchg„nge-1
          move.l    d0,d2
          moveq     #10,d4
          clr.b     -(sp)               ;Nullterminieren...
ltoa1:
          move.l    d2,-(sp)
          moveq     #0,d3
          move.w    (sp)+,d3            ;Highword holen
          divu      d4,d3               ;in d3.low -> wert.high!
          move.w    d3,d2               ;merken
          swap      d2                  ;richtig setzen
          move.w    (sp)+,d3            ;in d3.low -> wert.low
          divu      d4,d3               ;in d3.high -> rest
          move.w    d3,d2               ;in d2.l neuer Quotient
          swap      d3                  ;in d3.w Rest

          addi.b    #'0',d3             ;'0'
          move.b    d3,-(sp)            ;Zahl von hinten nach vorn aufbauen
          cmp.l     d2,d4               ;Daten <10?
          dbgt      d1,ltoa1            ;Nein, noch einer
          tst.w     d2                  ;Daten=0 ??
          beq.s     ltoa2               ;Vornullenunterdrckung, direkt zu loop
          addi.b    #'0',d2             ;Wenn nicht null
          move.b    d2,-(sp)
ltoa2:    move.b    (sp)+,(a0)+         ;String umkehren (FILO)
          bne.s     ltoa2
          move.l    (sp)+,d4
          rts
               endpart
               >PART 'UINT  conversion'
**********************************************************************
* itoa: Convert uword to string.
* Parameter: a0   - Ptr auf Stringdaten
*            d0.w - Wert
* Return:    a0   - Ptr auf Nullterminierung des Strings
*
* Ver„ndert werden: d1,d2,d3,a0,a1                                   *
**********************************************************************
itoa:     moveq     #4,d1               ;maximale Durchg„nge-1
          moveq     #10,d3              ;Konstante
          move.w    d0,d2
          clr.b     -(sp)               ;Nullterminieren...
itoa1:    swap      d2                  ;Weil unsigned: Clear Highword
          clr.w     d2
          swap      d2
          divu      d3,d2
          swap      d2
          addi.b    #'0',d2             ;'0'
          move.b    d2,-(sp)            ;Zahl von hinten nach vorn aufbauen
          swap      d2                  ;Quotient holen
          cmp.w     d2,d3               ;Daten <10?
          dbgt      d1,itoa1            ;Nein, noch einer
          tst.w     d2                  ;Daten=0 ??
          beq.s     itoa2               ;Vornullenunterdrckung, direkt zu loop
          addi.b    #'0',d2             ;Wenn nicht null
          move.b    d2,-(sp)
itoa2:    move.b    (sp)+,(a0)+         ;String umkehren (FILO)
          bne.s     itoa2
          rts
               endpart
               >PART 'File Search'
*
* Die eigentliche Pfadsuche
*
ffind:    link      a5,#-DTA_LEN        ;Platz auf dem Stack
          lea       stackbot(pc),a0
          cmpa.l    a0,sp               ;ist berhaupt noch Platz?
          bcs       fstackoverflow      ;Katastrophe!

          bsr.s     ffsetdta            ;DTA setzen

          move.w    #$37,-(sp)          ;alles aužer Volume Label
          pea       firstspec(pc)
          move.w    #Fsfirst,-(sp)
          trap      #1
          addq.w    #8,sp

nextfile: tst.w     d0                  ;fsret
          bmi.s     nofiles             ;fertich
* File gefunden: ist es ein Ordner?
          btst      #4,D_ATTRIB(a5)
          beq.s     is_a_file
* Es ist ein Ordner: Rekursion vorbereiten!
          lea       D_FNAME(a5),a0
          cmpi.w    #$2E00,(a0)         ;name = '.',0 ??
          beq.s     isnofile            ;dann ausblenden
          move.l    (a0),d1
          andi.w    #$FF00,d1           ;lowbyte=4tes Byte im String
          cmpi.l    #$2E2E0000,d1
          beq.s     isnofile            ;name = '..',0 ??
          bsr.s     chdir               ;change directory
          bmi.s     nofiles             ;Fehlgeschlagen!
* jetzt sind wir im Unterverzeichnis:
          bsr.s     ffind
* jetzt kommen wir zurck:
          tst.w     d0                  ;ist was passiert?
          bmi.s     nofiles             ;Abbruch!
          bsr.s     updir               ;Zurck (MSKOTZ: cd .. )
          bmi.s     nofiles
          bsr.s     ffsetdta            ;DTA zurcksetzen
          bra.s     isnofile

* Es ist eine Datei: versuche zu 'MATCH-en'
is_a_file:
          bsr       matchfile

* keine Datei: was sagt uns FSNEXT ?
isnofile: move.w    #Fsnext,-(sp)
          trap      #1
          addq.w    #2,sp
          bra.s     nextfile

nofiles:  cmpi.w    #-49,d0             ;-49: Das ist KEIN Fehler!
          bne.s     nofile1
          moveq     #0,d0
nofile1:  unlk      a5                  ;das war's -> raus...
          rts

ffsetdta: pea       D_RESERVED(a5)      ;DTA setzen
          move.w    #Fsetdta,-(sp)
          trap      #1
          addq.w    #6,sp
          rts

* Zum Hauptdirectory:
rootdir:  lea       pathbuffer+1(pc),a0
          move.b    #':',(a0)+
          move.b    #'\',(a0)
          clr.w     pbufndx(a6)         ;da sammer
          pea       root(pc)
          bra.s     chdir2

* Eine Ebene h”her im Directorybaum
updir:    lea       pathbuffer(pc),a0
          move.w    pbufndx(pc),d0
          ble.s     updir4
          subq.w    #1,d0
updir1:   cmpi.b    #'\',2(a0,d0.w)
updir2:   dbeq      d0,updir1
          bne.s     updir3              ;Pfad wurde nicht korrekt bearbeitet (intern!)
          move.w    d0,pbufndx(a6)      ;sonst merken
updir4:   pea       goback(pc)          ;'..'
          bra.s     chdir2
updir3:   moveq     #-34,d0
          bra.s     chdir3              ;Path not found!!

* Achtung: chdir immer nur relativ, NIE ABSOLUT verwenden!
chdir:    pea       (a0)
          lea       pathbuffer(pc),a1
          move.w    pbufndx(pc),d0      ;index im Pfadpuffer
chdir1:   addq.w    #1,d0
          move.b    (a0)+,2(a1,d0.w)
          bne.s     chdir1
          move.b    #'\',2(a1,d0.w)
          move.w    d0,pbufndx(a6)

chdir2:   move.w    #Dsetpath,-(sp)
          trap      #1
          addq.w    #6,sp
chdir3:   tst.w     d0                  ;Returnwert Testen
          rts

fstackoverflow:
          moveq     #-1,d0
          bra.s     nofile1

conws:    pea       (a0)
          move.w    #Cconws,-(sp)
          trap      #1
          addq.w    #6,sp
          pea       crlf(pc)
          move.w    #Cconws,-(sp)
          trap      #1
          addq.w    #6,sp
          rts


*  Paramet.: d1: Allquantor                                           *
*            d2: Einzelquantor                                        *
*            d3: endaddress of pat$                                   *
*            d4: endaddress of src$                                   *
*            a1: Pattern$                                             *
*            a2: Source$                                              *
matchfile:
          movem.l   patend(pc),d3/a1    ;2 Longs zugleich
          lea       D_FNAME(a5),a2      ;Source$
          movea.l   a2,a3
mfl1:     tst.b     (a3)+
          bne.s     mfl1
          subq.w    #1,a3
          move.l    a3,d4

          moveq     #'*',d1             ;Allquantor
          moveq     #'?',d2             ;Einzelquantor
          bsr       Hs_match            ;Pažt das Muster?
          tst.w     d0
          bne.s     mfl2
          addq.w    #1,d7               ;Mitz„hlen!
          bsr.s     getwholepath
mfl2:     rts

* File gefunden: dann den gesamten Pfad abfragen.
getwholepath:
          lea       pathbuffer(pc),a1
          movea.l   a1,a2
          adda.w    pbufndx(pc),a1
          addq.w    #3,a1
          lea       D_FNAME(a5),a0
getwp:    move.b    (a0)+,(a1)+         ;Filename kopieren
          bne.s     getwp

          tst.w     dflags(a6)          ;Size mit angeben?
          beq.s     getwp2              ;nein
          subq.w    #1,a1               ;sonst bis nn mit Spaces fllen
          lea       60(a2),a0           ;Position (Spalte) 60
getwp1:   move.b    #' ',(a1)+
          cmpa.l    a0,a1
          blt.s     getwp1
          move.l    D_LENGTH(a5),d0
          add.l     d0,totallen(a6)
          bsr       ltoa
getwp2:   lea       pathbuffer(pc),a0
          bsr.s     conws
          rts

               endpart
               >PART 'HighSpeed-match'
************************************************************************
*  MATCH - sucht strings in substrings.                                *
*  (c) 900309 by P. Fellerich                                          *
* i: input register ; o: output reg;  x: forbidden reg  (local etc)    *
*  Register:                                                           *
*   d0                              o a0 Gefunden bei...               *
* i d1 Allquantor                   i a1 *Pattern$     Stringstart     *
* i d2 Existenzquantor              i a2 *Source$                      *
*   d3                              i a3 *EndPat$      Stringende      *
*   d4                              i a4 *EndSrc$                      *
************************************************************************
***********************************************************************
* Pack_pps: Patternstrings mit Wildcards packen und fr Hs_match      *
*   aufbereiten.                                                      *
* Paramet.: d0: Pattern$l„nge                                         *
*           a1: *Pattern$    ----- wird ver„ndert!!                   *
* Rckgabe: d0: neue Pattern$l„nge                                    *
*                                                                     *
* Register werden (aužer d0) nicht ver„ndert.                         *
***********************************************************************
Pack_pps:
          movem.l   d3-d6/a0-a1,-(sp)

          movea.l   a1,a0               ;src=dest
          moveq     #0,d3               ;allquantorzaehler
          moveq     #0,d4               ;einzelquantorzaehler
          moveq     #0,d5               ;Stringl„ngenz„hler

mnwhile:  subq.w    #1,d0
          bmi.s     mnwend              ;Schleife beenden!
          move.b    (a0)+,d6            ;getchar
          cmp.b     d6,d1               ;Allquantor?
          bne.s     mncase1             ;nein
          addq.w    #1,d3               ;wird eigentlich nur als Flag benutzt
          bra.s     mnwhile             ;n„chster bitte
mncase1:  cmp.b     d6,d2               ;existenzquantor?
          bne.s     mncase2             ;nein
          addq.w    #1,d4
          bra.s     mnwhile             ;schleife auch hier kurzschliežen ('continue')
mncase2:  bsr.s     mnpack              ;es war ein 'normaler' Buchstabe!
          move.b    d6,(a1)+            ;ursprngliches Zeichen dazugeben
          addq.l    #1,d5
          bra.s     mnwhile

mnwend:   bsr.s     mnpack              ;Reste nicht liegenlassen
          move.l    d5,d0               ;Rckgabe = neue Patternstringl„nge

          movem.l   (sp)+,d3-d6/a0-a1
          rts

mnpack1:  move.b    d2,(a1)+            ;'?' in destination
          addq.l    #1,d5
mnpack:   dbra      d4,mnpack1
          tst.w     d3                  ;Allquantorz„hler?
          beq.s     mnpack2
          move.b    d1,(a1)+
          addq.l    #1,d5               ;Stringl„ngenz„hler bercksichtigen
mnpack2:  moveq     #0,d3               ;Z„hler rcksetzen
          moveq     #0,d4
          rts

***********************************************************************
* Hs_match: Highspeed-matchroutine.                                   *
*  Paramet.: d1: Allquantor                                           *
*            d2: Einzelquantor                                        *
*            d3: endaddress of pat$                                   *
*            d4: endaddress of src$                                   *
*            a1: Pattern$                                             *
*            a2: Source$                                              *
*                                                                     *
*  Rckgabe: d0: Boolean: 0(true)=found                               *
*            a0: Pointer auf Fundstelle                               *
*                                                                     *
*  !! Suchstring muž die Form *find* haben (zwischen 2 Allq. stecken) *
*                                                                     *
***********************************************************************
hsm_regs       reg a1-a2
Hs_match: movem.l   hsm_regs,-(sp)
hsentry1: cmpa.l    d3,a1               ;pat$
          bge.s     hstest1
hsentry2: move.b    (a1)+,d5            ;Pattern$ char holen
          cmp.b     d5,d1               ;Allquantor?
          beq.s     hsall_q
          cmp.b     d5,d2               ;Einzelquantor?
          beq.s     hsone_q
          cmpa.l    d4,a2
          bge.s     hsfail
          cmp.b     (a2)+,d5            ;Source$ char vergleichen
          bne.s     hsfail
          bra.s     hsentry1            ;passt - n„chstes Zeichen auch probieren

hsone_q:  cmpa.l    d4,a2               ;Behandlung Einzelquantor
          bge.s     hsfail              ;Source$ fertig
          addq.w    #1,a2               ;n„chste Position einnehmen
          cmpa.l    d3,a1
          blt.s     hsentry2            ;Pat$ nicht am Ende -> von vorne
;      ...geht weiter mit Test wie schon vorhin
hstest1:  cmpa.l    d4,a2
          bge.s     hssuccess           ;src&&pat end
hsfail:   moveq     #-1,d0
          movem.l   (sp)+,hsm_regs
          rts

hsall_q:  cmpa.l    d3,a1
          bge.s     hssuccess           ;wenn pat$ && src$ am ende
          move.b    (a1)+,d5
hsall1:   cmpa.l    d4,a2               ;Source leer?
          bge.s     hsfail              ;nix gefunden - nix da
          cmp.b     (a2)+,d5            ;Zeichen vergleichen
          bne.s     hsall1              ;ungleich -> next one
          move.w    d5,d6               ;Dieses Register unbedingt retten
          bsr.s     Hs_match            ;Rekursion
          move.w    d6,d5
          tst.w     d0
          bmi.s     hsall1              ;nicht erfolgreich
          movea.l   a2,a0               ;Position bergeben!
hssuccess:                              ;Freude sch”ner G”tterfunken - da isset!
          moveq     #0,d0
          movem.l   (sp)+,hsm_regs
          rts
               endpart
               >PART 'Strings & Datas'
**********************************************************************
title:         dc.b " Flexible File Finder for GEMDOS v"
               dc.b VERSION+'0',".",REVISION+'0'
               dc.b " 'WHERE IS' this damned file?",13,10
               dc.b " ½ 1990 by Pascal Fellerich ",13,10,0

use_it:        dc.b "USAGE: WHEREIS [-s] <pattern> [{path}]",13,10,0

msgnofile:     dc.b " No matching file found.",0
msgfiles:      dc.b " file(s) found.   ",0
msgbytes:      dc.b " bytes.",0


firstspec:     dc.b '*.*',0
goback:        dc.b '..',0
root:          dc.b '\',0
crlf:          dc.b 13,10,0

**********************************************************************
               endpart
               >PART 'BSS-Variablen'
* VARIABLEN (global)
               even
               bss
varbase:
_bpage:        ds.l 1
patlen:        ds.w 1
patend:        ds.l 1                   ;Pattern-Endadresse
patstart:      ds.l 1
cmdptr:        ds.l 1
cmdndx:        ds.w 1
totallen:      ds.l 1
dflags:        ds.w 1

*
* Aufbau Pfadbuffer:
*          A : \ P A T H ...
* index:   - - - 0 1 2 3 ...
*
pbufndx:       ds.w 1
pathbuffer:    ds.b MAXDIRDEPTH*13+4
               ds.w 100                 ;100 Zusatz-Sicherheitswords
stackbot:
               endpart
               end
