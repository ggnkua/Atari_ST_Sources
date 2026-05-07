*
*
*    Spooler als TOS-Anwendung
*
*

.text

gemdos    equ       1
keep      equ       $31
xbios     equ       14
mfpint    equ       13
bios      equ       13
bcostat   equ       8
bconout   equ       3
setexec   equ       5

mfp       equ       $fffa01             * MFP io-port
mfp_isrb  equ       mfp+16              * Interrupt-In Service Reg. B
soundgen  equ       $ff8800             * Soundchip  

nvbls     equ       $454                * # vbl-routinen
vblqueue  equ       $456                * Vertikal blank Warteschlange
super     equ       32                  * Supervisor Modus
sshiftmd  equ       $44c                * Bildschirmauflîsung
dumpflag  equ       $4ee                * Hardcopy-flag


linea     equ       $a000               * Line-A Routinen
wrt_mode  equ       36
clip      equ       54
xacc_dda  equ       64
mono_status  equ    70
sourcex   equ       72
sourcey   equ       74
destx     equ       76
desty     equ       78
delx      equ       80
dely      equ       82
fbase     equ       84
fwidth    equ       88
style     equ       90
scale     equ       102
chup      equ       104
text_fg   equ       106
text_bg   equ       114

textblt   equ       $a008               * Bitblock-Transfer


*
*         BegrÅûung
*
*
          move.l    #text1,-(sp)        * "ESC E ESC B Druckerspooler"
          move.w    #9,-(sp)
          trap      #gemdos
          add.l     #6,sp

*
*         Eingabe der gewÅnschten Spoolergrîûe
*
*

          move.l    #text2,-(sp)        * ESC B Spoolergrîûe in kByte ?
          move.w    #9,-(sp)
          trap      #gemdos
          add.l     #6,sp

          lea       eingabe,a0          * Eingabepuffer
          move.b    #10,(a0)            * max 10 Eingabezeichen
          bsr       eingab              * kbyte Eingabe

          cmp.w     #-1,d0              * falsche Eingabe ?
          bne       start               * -> nein

          move.w    #100,d0             * -> ja. Standard 100 kByte

start     cmp.w     #9,d0               * 0 kbyte = Abbruch ?
          bcc       start1              * -> nein

          move.l    #text5,-(sp)        * Cursor aus
          move.w    #9,-(sp)
          trap      #gemdos
          add.l     #6,sp


          clr.w     -(sp)
          trap      #gemdos             * -> ja. Ende

start1    ext.l     d0
          move.l    #10,d1              * 1kbyte
          lsl.l     d1,d0
          move.l    d0,size             * Spoolergrîûe in Byte


******************************************************************
*         Sekunden fÅr Autoinitialisation
*
*

          move.l    #text4,-(sp)        * Autoinitialisation . . .
          move.w    #9,-(sp)
          trap      #gemdos
          add.l     #6,sp

          lea       eingabe,a0          * Eingabepuffer
          move.b    #10,(a0)            * max 10 Eingabezeichen
          bsr       eingab              * sec Eingabe
          cmp.w     #-1,d0              * falsche Eingabe ?
          bne       start2              * -> nein

          move.w    #6,d0               * -> ja. Standard 6 sec

start2    move.w    d0,inittime         * Zeit fÅr Autoinitialisation




***********************************************
*
*         Spoolerstatus anzeigen ?
*
*
          move.l    #text3,-(sp)        * ESC B Spoolerstatus anzeigen ?
          move.w    #9,-(sp)
          trap      #gemdos
          add.l     #6,sp

          move.w    #1,-(sp)            * Tastaturabfrage 'n' oder 'N'
          trap      #gemdos
          add.l     #2,sp

          move.w    #0,keinvbl          * das isses !
          move.w    #0,vblenable
          cmp.b     #$6e,d0             * 'n'
          beq       endvbl              * keine Statusanzeige

          cmp.b     #$4e,d0             * 'N'
          beq       endvbl              * keine Statusanzeige

          move.w    #1,keinvbl          * doch vbl...
          move.w    #1,vblenable

endvbl:

***********************************************************************
*    Zeichensatz fÅr den Drucker laden
*

          move.l    #zeich_satz,d0      * Anfang der Zeichensatztabelle
          move.l    d0,tabzeiger        * merken.

          move.l    #text9,-(sp)        * 'Welchen Zeichensatz laden?'
          move.w    #9,-(sp)
          trap      #gemdos
          add.l     #6,sp               * Textausgabe

          lea       eingabe,a0          * Eingabepuffer
          move.b    #12,(a0)            * max 12 Zeichen
          move.l    a0,-(sp)
          move.w    #10,-(sp)           * readline
          trap      #gemdos             * Filenamen lesen
          add.l     #6,sp

          lea       eingabe,a0
          add.l     #2,a0               * ab hier stehen die Zeichen
          cmpi.b    #3,d0               * Eingabe gemacht ?
          bpl       start3              * -> ja.

          lea       text6,a0            * -> nein. Also Standardfile

start3:
          clr.l     d2                  * Zahl lîschen
          clr.l     d3                  * ZÑhler fÅr Zahl lîschen
          clr.l     d4                  * noch keine Zahl gelesen

          move.w    #$2,-(sp)           * read write-Flag
          move.l    a0,-(sp)            * Name der Datei
          move.w    #$3d,-(sp)          * OPEN
          trap      #gemdos             * Datei îffnen
          add.l     #8,sp

          move.w    d0,filedes          * Filedescriptor
          tst.w     d0                  * File gefunden ?
          bpl       start4              * -> ja.

          move.l    #text7,-(sp)        * -> nein. Fehlermeldung ausgeben
          move.w    #9,-(sp)            * und Cursor abschalten.
          trap      #gemdos
          add.l     #6,sp

          move.w    #1,-(sp)            * Auf Tastendruck warten
          trap      #gemdos
          add.l     #2,sp

          clr.w     -(sp)               * Programmende
          trap      #gemdos

start4    move.l    #eingabe,-(sp)      * 1 Byte aus der Datei lesen
          move.l    #1,-(sp)
          move.w    filedes,-(sp)       * Filedescriptor
          move.w    #$3f,-(sp)
          trap      #gemdos
          add.l     #12,sp

          tst.l     d0                  * Lesefehler ?
          bpl       start5              * -> nein.

          move.l    #text8,-(sp)        * -> ja. 
          move.w    #9,-(sp)            * Fehlermeldung ausgeben
          trap      #gemdos
          add.l     #6,sp

          move.w    #1,-(sp)            * Auf Tastendruck warten
          trap      #gemdos
          add.l     #2,sp
          
          cmpi.b    #32,d0              * SPACE gedrÅckt ?
          beq       start4              * -> ja. neuer Versuch

          move.l    #text5,-(sp)        * -> nein. Abbruch
          move.w    #9,-(sp)            * Cursor abschalten
          trap      #gemdos
          add.l     #6,sp

          move.w    filedes,-(sp)       * Datei schliessen
          move.w    #$3e,-(sp)
          trap      #gemdos
          add.l     #4,sp

          clr.w     -(sp)               * Programmende
          trap      #gemdos

start5    lea       eingabe,a0
          move.b    (a0),d3             * gelesenes Byte untersuchen
          cmpi.b    #46,d3              * "." fÅr Fileende ?
          beq       start7              * -> ja.

*
* Zahlenbyte ausmaskieren
*

          sub.b     #48,d3              * ASCII "0"
          bmi       start6              * keine Zahl

          cmpi.b    #9,d3               * Zahl 9
          bgt       start6              * keine Zahl

          mulu      #10,d2              * nÑchstes Digit
          add.l     d3,d2               * neue Zahl in d2
          addq.w    #1,d4               * eingelesene Digits
          bra       start4              * NÑchstes Digit

start6    tst.w     d4                  * Schon 1 Zahl eingelesen ?
          beq       start4              * -> nein. weitermachen

          clr.l     d4                  * -> ja.

          move.l    tabzeiger,a0        * Tabellenzeiger holen
          move.b    d2,(a0)+            * Byte in Tabelle ablegen
          move.l    a0,tabzeiger        * Tabellenzeiger merken
          clr.l     d2
          clr.l     d3                  * Auf zum nÑchsten Zeichen !
          bra       start4

start7    tst.w     d4                  * Schon letzte Zahl eingelesen?
          beq       start8              * -> ja.

          move.l    tabzeiger,a0        * -> nein. Tabellenzeiger holen
          move.b    d2,(a0)+            * Byte in Tabelle ablegen
          move.l    a0,tabzeiger        * Tabellenzeiger merken

start8    move.l    tabzeiger,a0        * Tabelle mit ASCII 
          move.b    #0,(a0)+            * NUL beenden
          move.b    #0,(a0)+
          move.l    a0,d0
          andi.l    #$fffffffe,d0       * Tabellenende auf Wortgrenze
          move.l    d0,tabzeiger        * Ende der Zeichensatztabelle

          move.w    filedes,-(sp)       * Datei schliessen
          move.w    #$3e,-(sp)
          trap      #gemdos
          add.l     #4,sp



****************************************************************
*         weiter mit initialisierung spooler und trap#1
*


          move.l    #newbios,-(sp)      * bios-vektor umbiegen
          move.w    #45,-(sp)
          move.w    #setexec,-(sp)
          trap      #bios
          addq.l    #8,sp
          move.l    d0,trapvekt         * alter trap #13 Vektor

          move.l    #prnint,-(sp)       * Adresse busy-Routine
          clr.w     -(sp)               * als Interrupt-routine #0
          move.w    #mfpint,-(sp)       * initialisieren.
          trap      #xbios
          addq.l    #8,sp
          
******************************************************************
*         Wichtige Variablen initialisieren
*
*

          move.w    #1,konvert          * Druckeranpassung einschalten.
          move.w    #0,prozalt          * noch nicht 0% Spooler angezeigt
          move.w    #1,timeflag         * schon Zeit gemessen worden
          clr.w     prozent             * Drucker spoolt noch nicht
          clr.l     zeichenzahl         * keine auszugebende Zeichen.
          move.w    #0,time             * 0 sec als letzte Zeit
          move.w    #0,spoolvoll        * Spooler ist noch nicht voll
*
*
******************************************************************
*
*    Speicherplatz initialisieren
*
*

          move.l    tabzeiger,a0        * Ende des geladenen Zeichensatzes
          move.l    a0,pstart           * Schreib- und Lesezeiger
          move.l    a0,pin              * initialisieren.
          move.l    a0,pout
          add.l     size,a0             * Groesse des Pufferspeichers.
          addq.l    #2,a0               * Pufferende 1 Wort weiter hinten
          move.l    a0,pend             * Pufferende

          move.l    #meldung,-(sp)      * " Spooler installiert "
          move.w    #$09,-(sp)
          trap      #gemdos
          addq.l    #6,sp

          move.w    #1,-(sp)            * Auf Tastendruck warten
          trap      #gemdos
          add.l     #2,sp


          move.l    4(sp),a6            * Berechnung Programmlaenge
          move.l    #256,d2             * = base-page
          add.l     12(a6),d2           * + text-laenge
          add.l     20(a6),d2           * + data-laenge
          add.l     28(a6),d2           * + bss-laenge
          move.l    pend,d3             * Pufferende
          move.l    #zeich_satz,d4      * Anfang Zeichensatztabelle
          sub.l     d4,d3               * nicht initialisierter Speicher
          add.l     d3,d2               * + PufferlÑnge
          addq.l    #2,d2


          clr.w     -(sp)
          move.l    d2,-(sp)
          move.w    #keep,-(sp)
          trap      #gemdos             * Programm resident halten


**************************************************************
*
*         Neue trap #13   Routine
*
**************************************************************

newbios   move.l    sp,a1               * Supervisor-stack
          move.w    (a1),d0             * Statusregister vom stack
          btst      #13,d0              * Test: Supervisor-bit
          bne       l0                  * bei Aufruf vom Usermodus...
          move.l    usp,a1              * ...Userstack benutzen

l0        cmp.w     #bconout,6(a1)      * Zeichenausgabe ?
          beq       newbconout          * -> ja

          cmp.w     #bcostat,6(a1)      * Statusabfrage ?
          beq       newbcostat          * -> ja

oldbios   move.l    trapvekt,a0         * alter trap #13 Vektor
          jmp       (a0)                * zurueck an bios.


*******************************************************************
*         Neue Druckerausgaberoutine
*         a1: Stackpointer fÅr trap #13
*


newbconout:                             * Neue Zeichenausgabe-routine

          tst.w     8(a1)               * Ausgabe an Drucker ?
          bne       oldbios             * -> nein.

          tst.w     keinvbl             * Spooler-Anzeige gewÅnscht ?
          beq       newbc0              * -> nein.

********************************************************************
*         Spoolerstatus als vbl-Routine anmelden
*

          move.w    #0,keinvbl          * 1x initialisieren reicht !
          movem     d0-d1/a0-a1,-(sp)   * zwischenspeichern

          move.l    #nvbls,a0           * Adresse f. Anz. vbl-routinen
          move.w    (a0),d0             * Anzahl vbl-routinen (=8)
          ext.l     d0
          lsl.l     #2,d0               *  mal 4 Byte (=32 Byte)
          move.l    #vblqueue,a1        * Adresse f. Zeiger auf vbl-liste
          move.l    (a1),a0             * Zeiger auf vbl-liste
          clr.l     d1

loop1     tst.l     (a0,d1)             * Routine genutzt ?
          beq       free                * -> nein.
          addq      #4,d1               * -> ja, nÑchste Adresse
          cmp.l     d0,d1               * Alle EintrÑge getestet ?
          bne       loop1               * -> nein.

          movem     (sp)+,d0-d1/a0-a1   * alte Register
          bra       newbc0              * alle EintrÑge besetzt

free      move.l    a0,d0               * Zeiger auf vbl-liste + offset
          add.l     d1,d0               * ergibt den freien vbl-Vektor
          move.l    d0,a0               * freie vbl-adresse
          lea       vblrout,a1
          move.l    a1,(a0)             * Adresse der vbl-routine

          movem     (sp)+,d0-d1/a0-a1   * alte Register

*
*********************************************************************

newbc0:
          clr.l     d2
          move.b    11(a1),d2           * auszugebendes Zeichen.
          move.w    d2,zeichen          * s.o.



*******************************************************************
*         Autoinitialisation nach LF einleiten
*         a1: Stackpointer
*         zeichen: ASCII - Zeichen
*


          tst.w     spoolvoll           * Spooler voll ?
          bne       newb0a              * -> ja. => keine Initialisation

          tst.w     timeflag            * -> nein. Wurde Zeit gemessen?
          bne       newb2               * -> ja.

          cmp.w     #10,zeichen         * -> nein. LF gesendet ?
          beq       newb0               * -> ja.

newb0a    bsr       newb1               * -> nein. (normal)

          rte                           * Ende Ausgabe

**********
*         Zeit nehmen nach LF
*

newb0     clr.w     d0                  * keine alte Zeit vorhanden
          bsr       zeit                * Uhrzeit nehmen

          move.w    d0,time             * Zeit gemessen.
          move.w    #1,timeflag         * s.o.

          bsr       newb1               * Zeichen drucken und warten

          rte                           * Ende Ausgabe


********************************************************
*         Zeit fÅr Initialisation nehmen
*         a1: Stackpointer
*         zeichen: Zeichen
*

newb2: 
          move.w    #0,timeflag         * zeitmessung zurÅcknehmen
          move.w    time,d0             * alte Zeit nach LF
          bsr       zeit                * Zeit nehmen

          move.w    inittime,d0
          cmp.w     d1,d0               * Zeitintervall schon erreicht ?
          bmi       newb2a              * -> ja.

          bsr       newb1               * -> (normal)

          rte                           * Ende Ausgabe

*
*         Drucker initialisieren
*

newb2a    
          move.w    zeichen,-(sp)       * Zeichen zwischenspeichern

          move.w    #1,konvert          * mit Konvertierung
          move.w    #255,zeichen        * Initialisation mit ASCII 255

          bsr       newb1               * -> Initialisation

          move.w    (sp)+,zeichen       * Gesichertes Zeichen holen

          tst.w     d0                  * wurde initialisiert ?
          beq       newb2b              * -> nein. Abbruch

          bsr       newb1               * -> ja. Es wird gesendet

newb2b    rte                           * Ende der Ausgabe


*****************************************************************
*         Zeichen in 'zeichen' auf Drucker ausgeben
*          hier Unterprogramm
*

newb1:

          cmp.w     #27,zeichen         * ESC fuer Graphik ? (1.st Word?)
          bne       textda              * -> nein.

          clr.w     konvert             * -> ja. => keine Umwandlung

textda    tst.w     konvert             * Flag fuer Umwandlung
          beq       bconout2            * war geloescht.

          lea       zeich_satz,a3       * Umwandlungstabelle
          clr.l     d1                  * zur Sicherheit
          move.w    zeichen,d1          * zu druckendes Zeichen

suchen    move.b    (a3)+,d0            * Zeichen suchen
          beq       bconout2            * 0 fuer Tabellenende

          cmp.b     d0,d1
          beq       istda               * gefunden...

          clr.l     d0
          move.b    (a3)+,d0
          add.l     d0,a3               * naechstes Zeichen
          bra       suchen

istda     move.b    (a3)+,d0            * ...und durch d0 Bytes aus...
          
lp1       move.b    (a3)+,d1            * ...der Tabelle ersetzen.
          ext.w     d1
          move.w    d1,zeichen
          movem.l   d0/a3,-(sp)

          bsr       bconout2            * Zeichenausgabe.

          move.w    d0,d1               * =0 fÅr nicht gedruckt

          movem.l   (sp)+,d0/a3 

          tst.w     d1                  * wurde gedruckt ?
          beq       lp1a                * -> nein.

          subq.b    #1,d0
          bne       lp1                 * weiter mit Ersatzzeichen.

          move.l    #-1,d0              * Ausgabe ok
          rts                           * Ende der Zeichenausgabe.

lp1a      clr.l     d0                  * kein Druck
          rts

*                                         Zeichen ohne Uebersetzung ausg.

*********************************************************************
*         Kommunikation mit Centronics-Schnittstelle
*
*

bconout2:                               * Ausgabe an Drucker/Spooler

          move.l    #6000,d1            * 30 sec. * 200 Hz fuer
          move.l    size,d0             *         30sec-timeout.
  
abfrage   cmp.l     zeichenzahl,d0      * Puffer voll ?
          bne       weiter              * -> nein. is noch Platz da.

**********
*         Spooler Voll
**********

          move.w    #1,spoolvoll        * keine Initialisierung mîglich 
          move.w    #0,timeflag         *  da Spooler voll ist !
          move.w    #100,prozent        *  Meldung "100% Spooler"
          move.l    systakt,takt        * Warteschleife auf Drucker
          tst.w     dumpflag            * Hardcopy in Mache ?
          beq       wartetakt           * -> ja.

          movem     d0-d1,-(sp)         * Speicher retten

          bsr       vblrout             * Anzeige der öberlastung

          movem     (sp)+,d0-d1         * Speicher restaurieren


wartetakt subq.l    #1,takt             * 200 Hz-Timer abgelaufen ?
          bne       wartetakt           * -> nein.
          subq.l    #1,d1               * -> ja. 1 Zyklus weniger.
          bne       abfrage             * max. 6000 Abfragen.
          clr.l     d0                  * keine Ausgabe moeglich.
          rts                           * "timeout"

weiter    tst.l     zeichenzahl         * Puffer leer ?
          bne       l05                 * -> nein. Zeichen zwischenspeich.
          move.l    #500,d0             * 'd0' Warteschleifen fuer Drucker

busy      btst      #0,mfp              * Centronics busy ?
          bne       busy1               * -> ja.
          move.w    zeichen,d0          * -> nein.  alles frei. 
          bsr       ausgabe             * => direkt zum Drucker.

          moveq     #-1,d0              * alles o.k.
          rts

busy1     sub.l     #1,d0               * max. 'd0' busy-Abfragen
          bne       busy                * busy: => ab in'n Puffer.

l05       move.l    pin,a0              * Zeichen zwischenspeichern.
          move.w    zeichen,d0
          move.b    d0,(a0)+
          addq.l    #1,zeichenzahl      * #Zeichen erhoehen.
          cmp.l     pend,a0             * Pufferende erreicht ?
          bne       l1                  * -> nein.
          move.l    pstart,a0           * -> ja. => wieder vorne anfangen

l1        move.l    a0,pin              * Neuer aktueller Pufferzeiger
          move.l    zeichenzahl,d0      * Die Zeichen im Puffer
          move.l    size,d1             * Byte Puffer
          lsr.l     #4,d0               * fÅr 16bit Rechnung !
          move.l    #11,d2
          lsr.l     d2,d1
          mulu.w    #100,d0             * zeichenzahl * 100
          lsr.l     #7,d0
          divu.w    d1,d0               * zeichenzahl * 100 / size
          andi.l    #$ffff,d0           * oberes Wort ausmaskieren
          cmp.w     #100,d0
          ble       prn1                * % ok
          move.w    #100,d0             * max 100%

prn1      move.w    d0,prozent          * % vom Spooler benutzt
          cmpi.w    #98,d0
          bne       prn1a               * # 98 % Spooler

          bsr       vblrout             * Anzeige lîschen

prn1a     cmpi.w    #98,d0              * mehr als 98% Spooler?
          bpl       prn1b               * -> ja.
          
          move.w    #0,spoolvoll        * -> nein. => Spooler nicht voll

prn1b     moveq     #-1,d0              * Alles o.k. Programmende
          rts

****************************************************************
*         Abfrage Druckerstatus
*
*

newbcostat:                             * Abfrage Status.
          tst.w     8(a1)               * Druckerstatus ?
          bne       oldbios             * -> nein.
          move.l    size,d0             
          cmp.l     zeichenzahl,d0      * Zwischenspeicher voll ?
          beq       l2                  * -> ja.
          moveq     #-1,d0              * -> nein. alles o.k.
          rte

l2        clr.l     d0                  * Speicher ist voll.
          rte                           * Meldung: "Drucker nicht bereit"

********************************************************************
*         Centronics - Interrupt - Routine
*
*

prnint    movem.l   d0-d2/a0,-(sp)      * Druck-Interruptroutine.

          move.l    zeichenzahl,d0      * Die Zeichen im Puffer
          move.l    size,d1             * Byte Puffer
          lsr.l     #4,d0               * fÅr 16bit Rechnung !
          move.l    #11,d2
          lsr.l     d2,d1
          mulu.w    #100,d0             * zeichenzahl * 100
          lsr.l     #7,d0
          divu.w    d1,d0               * zeichenzahl * 100 / size
          andi.l    #$ffff,d0           * oberes Wort ausmaskieren
          cmp.w     #100,d0
          ble       prn2                * % ok
          move.w    #100,d0             * max 100%

prn2      move.w    d0,prozent          * % vom Spooler benutzt
          cmpi.w    #98,d0              * mehr als 98% Spooler?
          bpl       prn2a               * -> ja.

          move.w    #0,spoolvoll        * -> nein. => Spooler nicht voll
          cmpi.w    #98,prozent         * Anzeige lîschen ?
          bne       prn2a               * -> nein.

          bsr       vblrout             * -> ja. => Anzeige lîschen.

prn2a     tst.l     zeichenzahl         * Noch Zeichen im Puffer ?
          beq       l4                  * -> nein.

          subq.l    #1,zeichenzahl      * -> ja. => 1 Zeichen weniger
          move.l    pout,a0             * Pufferzeiger f. Ausgabe.
          move.b    (a0)+,d0            * Zeichen abrufen.
          cmp.l     pend,a0             * Pufferende erreicht ?
          bne       l3                  * -> nein.
          move.l    pstart,a0           * -> ja. => von vorne beginnen.

l3        move.l    a0,pout
          bsr       ausgabe             * Ausgabe an Drucker

          tst.l     zeichenzahl         * Puffer leer ?
          bne       l4                  * -> nein

          tst.w     timeflag            * Zeit gemessen ?
          beq       l4                  * -> nein.

          move.w    #0,timeflag         * Drucker 'initialisieren'
          move.w    #1,konvert          * Konvertierung einschalten
          move.w    #12,d0              * FF
          bsr       ausgabe             * ausgeben

l4        movem.l   (sp)+,d0-d2/a0
          bclr      #0,mfp_isrb         * Interrupt Service Register B,
          rte                           * loeschen.



ausgabe   lea       soundgen,a0         * Byte im Port B ausgeben
          move.b    #15,(a0)            * Port B
          move.b    d0,2(a0)            * Zeichen -> Datenregister
          move.b    #14,(a0)            * Port A waehlen.
          move.b    (a0),d0             * Datenregister lesen
          bclr      #5,d0               * Centronics-strobe geben
          move.b    d0,2(a0)            * nach Port A schreiben
          bset      #5,d0               * Strobe loeschen.
          move.b    d0,2(a0)            * nach Port A schreiben
          rts


*******************************************************************
*
*    Vertikal-Blank-Routine
*
*

vblrout:                                * Vertikal-Blank-Routine

          tst.w     dumpflag            * LÑuft Hardcopy ?
          bmi       dis0                * -> nein

          rts                           * -> ja. Ende

dis0      move.w    prozent,d0          * Berechnete Prozente und...
          cmp.w     prozalt,d0          * ...zuletzt berechnete ...
          bne       dis1                * ...unterscheiden sich ?

          rts                           * -> nein. => keine Anzeige.

dis1      move.w    d0,prozalt          * -> ja. Also anzeigen
          move.w    #0,delspalte        * Beginn Druckspalte 0

*
*
*         Bildschirmauflîsung feststellen
*

          move.l    #sshiftmd,a0        * Bildschirmauflîsung
          move.w    (a0),d0             * 0,1,2 fÅr Auflîsung

          move.w    #8,txtfarbe         * fÅr bunt
          move.w    #40,spalte          * 1 zeile hat 40 bytes
          tst.w     d0                  * low-resolution ?
          beq       rez                 * -> ja

          add.w     #40,spalte          * -> nein. 80 bytes pro Zeile
          move.w    #3,txtfarbe         * fÅr 4 Farben
          cmp.w     #1,d0
          beq       rez                 * mittlere Auflîsung
          move.w    #1,txtfarbe         * fÅr monochrom

rez       move.w    spalte,d0
          sub.w     #12,d0              * 12 Zeichen Text
          lsl.w     #3,d0               * Beginn bei Pixel 'spalte'
          move.w    d0,spalte
          move.w    #1,ypos             * -"-              'zeile'
          move.w    #1,font             * 8x8 - Font




********************************************************************
*    Line a  - Variablen sichern
*
********************************************************************

          dc.w      linea
          move.w    wrt_mode(a0),-(sp)
          move.w    clip(a0),-(sp)
          move.w    xacc_dda(a0),-(sp)
          move.w    mono_status(a0),-(sp)
          move.w    sourcex(a0),-(sp)
          move.w    sourcey(a0),-(sp)
          move.w    sourcey(a0),-(sp)
          move.w    destx(a0),-(sp)
          move.w    desty(a0),-(sp)
          move.w    delx(a0),-(sp)
          move.w    dely(a0),-(sp)
          move.l    fbase(a0),-(sp)
          move.w    fwidth(a0),-(sp)
          move.w    style(a0),-(sp)
          move.w    scale(a0),-(sp)
          move.w    chup(a0),-(sp)
          move.w    text_fg(a0),-(sp)
          move.w    text_bg(a0),-(sp)

******************************************************************




          move.w    prozent,d1          * Prozent >> ASCII-Zahl !
          ext.l     d1
          cmp.l     #100,d1
          bne       di1                 * <100%

**********
*         Spooler voll
**********

          move.l    #vbltxt2,d0         * "Spooler voll"
          move.l    d0,vbltext
          bra       di3                 * anzeigen

di1       cmpi.w    #98,d1              * 98% Spooler ?
          bne       di1a1               * -> nein

          tst.w     vblenable           * -> ja. Anzeige gewÅnscht ?
          bne       di1a1               * -> ja.

          move.l    #vbltxt3,d0         * -> nein. Anzeige lîschen
          move.l    d0,vbltext
          bra       di3                 * anzeigen


di1a1     move.w    #32,char            * bei <100% ein " " ausgeben
          bsr       wrtcol

di1a      divu      #10,d1              * 1er und 10er trennen
          clr.l     d0
          move.w    d1,d0               * 10er
          move.l    #16,d2
          lsr.l     d2,d1               * 1er
          add.w     #48,d0              * '0' + int()
          cmp.w     #48,d0              * fÅhrende Nullen ?
          bne       di2                 * keine "0"

          move.w    prozent,d2          * 0 anzeigen bei 100%
          cmp.w     #100,d2
          beq       di2
          move.w    #32,d0              * " " statt "0"

di2       move.w    d0,char
          bsr       wrtcol              * 10er anzeigen
          move.w    d1,d0
          add.w     #48,d0              * '0' + mod()
          move.w    d0,char
          bsr       wrtcol              * 1er anzeigen

          move.l    #vbltxt1,d0         * "% Spooler"
          move.l    d0,vbltext

di3       move.w    #0,d0
          move.l    vbltext,a0
          move.b    (a0)+,d0            * nÑchster Buchstabe
          tst.b     d0                  * existiert ?
          beq       di4                 * -> nein.

          move.l    a0,vbltext
          move.w    d0,char             * -> ja
          bsr       wrtcol              * ausgeben

          bra       di3


********************************************************************
*    Line a  - Variablen sichern
*
********************************************************************

di4       dc.w      linea
          move.w    (sp)+,wrt_mode(a0)
          move.w    (sp)+,clip(a0)
          move.w    (sp)+,xacc_dda(a0)
          move.w    (sp)+,mono_status(a0)
          move.w    (sp)+,sourcex(a0)
          move.w    (sp)+,sourcey(a0)
          move.w    (sp)+,sourcey(a0)
          move.w    (sp)+,destx(a0)
          move.w    (sp)+,desty(a0)
          move.w    (sp)+,delx(a0)
          move.w    (sp)+,dely(a0)
          move.l    (sp)+,fbase(a0)
          move.w    (sp)+,fwidth(a0)
          move.w    (sp)+,style(a0)
          move.w    (sp)+,scale(a0)
          move.w    (sp)+,chup(a0)
          move.w    (sp)+,text_fg(a0)
          move.w    (sp)+,text_bg(a0)

******************************************************************

          rts

*
*         Zeichen in Grafik-Ram schreiben
*

wrtcol:
          movem     d0-d2/a0-a5,-(sp)   * werden durch linea zerstîrt
          move.w    spalte,d0           * Neue Textspalte
          add.w     delspalte,d0
          move.w    d0,xpos
          bsr       printchar           * Zeichen auf Bildschirm
          add.w     #8,delspalte        * nÑchste Spalte fÅr 8x8 - Font
          movem     (sp)+,d0-d2/a0-a5
          rts


printchar:


          dc.w      linea               * Line A  initialisieren

          move.w    font,d0             * Fontnummer
          ext.l     d0
          lsl.l     #2,d0
          move.l    0(a1,d0),a2         * Zeiger auf Font
          move.w    #0,wrt_mode(a0)     * Schreibmodus normal
          move.w    #0,text_bg(a0)      * Farbe #0 als Hintergrund
          move.w    txtfarbe,text_fg(a0)     * Textfarbe
          move.l    76(a2),fbase(a0)    * Beginn der Fontdaten
          move.w    80(a2),fwidth(a0)   * Breite des Fonts
          move.w    #0,sourcey(a0)      * Zeichen ganz malen
          move.w    char,d0             * ASCII-Zeichen 
          ext.l     d0
          sub.w     36(a2),d0           * niedrigster darstellb. ASCII-Wert
          lsl.l     #1,d0               * aus Byte wird Wort
          move.l    72(a2),a1           * Character-offset-tabelle
          move.w    0(a1,d0),sourcex(a0) * Beginn Bitmuster des char.
          move.w    xpos,destx(a0)      * x-Position des char. 
          move.w    ypos,desty(a0)      * y-Position 
*
*         Breite des Zeichens
*
          addq      #2,d0               * nÑchster char := 1 Wort
          move.w    0(a1,d0),d1         * sourcex + 1 Wort
          sub.w     sourcex(a0),d1      * - sourcex
          move.w    d1,delx(a0)         * Zeichenbreite
          move.w    82(a2),dely(a0)     * Zeichenhîhe
*
*         texteffekte
*
          move.w    #0,style(a0)        * Schrift normal
          move.w    #0,scale(a0)        * keine Vergîûerung
          move.w    #0,chup(a0)         * keine Drehung
          move.w    #1,mono_status(a0)  * keine Proportionalschrift
          move.w    #0,clip(a0)         * keine Fensterbegrenzung
          move.w    #$8000,xacc_dda(a0) * wer weiû warum
          dc.w      textblt
          rts


*********************************************************************
*         Berechnung der vergangenen Zeit zwischen zwei Aufrufen
*
*         d0: alte Zeit
*         RETURN: d0: neue Zeit
*                 d1: neue - alte  Zeit
*

zeit:
          movem     d7,-(sp)
          move.w    d0,-(sp)            * alte Zeit retten

          move.w    #23,-(sp)
          trap      #14                 * xbios
          add.l     #2,sp               * d0: Uhrzeit

          move.b    d0,d7               * sekunden bit 0-4
          andi.l    #%11111,d7
          lsl.b     #1,d7               * Alle 2 sec Ausgabe

          lsr.w     #5,d0               * Sekunden rauswerfen
          andi.l    #%111111,d0         * min isolieren
          mulu      #60,d0              * 1 min = 60 sec
          add.w     d7,d0               *   + sec
                

*                                       d0: neue Zeit [sec]

          clr.l     d1   
          move.w    d0,d1               * d1: neue Zeit
          move.w    (sp)+,d7            * alte Zeit holen
          cmp.w     d0,d7               * alte <-> neue Zeit
          bls       zeit1               * innerhalb 1 h

          add.w     #3600,d1            * Stundenwechsel

zeit1     
          sub       d7,d1               * alte Zeit abziehen
          movem     (sp)+,d7
          rts                           * d0: neue Zeit  [sec]
*                                         d1: neue - alte Zeit  [sec]


*******************************************************************
*
*         Eingabe einer natÅrlichen 16 bit Zahl 
*         gefordert: Stringadresse in a0
*         Ergebnis ist in d0
*

eingab:
          movem     d1-d2,-(sp)
          move.l    a0,-(sp)            * Adresse zwischenspeichern
          move.l    a0,-(sp)
          move.w    #$0a,-(sp)          * Zeile lesen
          trap      #1                  * gemdos
          add.l     #6,sp

          move.l    (sp)+,a0            * Adresse zurÅckholen
          add.l     #2,a0               * hier fÑngt die Zahl an
          subq      #1,d0               * das is halt so
          cmp.w     #-1,d0              * Anzahl eingegebener Zeichen - 1
          bne       eingab1             * -> ist ok

eingab0   move.l    #-1,d0              * falsche Eingabe
          movem     (sp)+,d1-d2
          rts

eingab1   clr.l     d1                  * die Zahl
          clr.l     d2                  * das Zeichen

eingab2   move.b    (a0)+,d2            * Zeichen holen
          sub.b     #48,d2              * ASCII "0" 
          bmi       eingab0             * -> keine Zahl

          cmp.b     #9,d2               
          bgt       eingab0             * -> keine Zahl

          mulu      #10,d1              * nÑchstes Digit
          add.l     d2,d1
          dbra      d0,eingab2          * nÑchstes Zeichen

          move.w    d1,d0               * das Ergebnis
          movem     (sp)+,d1-d2         * Speicher restaurieren
          rts



**********************************************************
*
*         Ausgabe einer 32bit Zahl in einen String
*         d0: die Zahl
*         a0: die Adresse des Strings
*         RETURN: a0 Stringende
*

ausgab:
          movem     d0-d3,-(sp)
          andi.l    #$ffff,d0           * nur 16bit Zahl
          clr.l     d1
          clr.l     d3
          move.l    #16,d2              * zum Shiften

ausgab1   divu      #10,d0
          move.w    d0,d1               * zahl / 10
          lsr.l     d2,d0               * divisionsrest
          add.w     #48,d0              * -> ASCII - Zahl  machen
          andi.l    #$ff,d0
          move.w    d0,-(sp)            * Digits von hinten nach vorn
          addq      #1,d3               * 1 Digit mehr
          move.w    d1,d0
          tst.w     d0
          bne       ausgab1             * noch mehr Digits
          subq      #1,d3

ausgab2   

          move.w    (sp)+,d0            * Digit holen
          move.b    d0,(a0)+            * in String speichern
          dbra      d3,ausgab2          * nÑchstes Digit

          move.b    #0,(a0)             * Stringende = "NUL"
          movem     (sp)+,d0-d3
          rts                           * a0: zeigt auf Stringende











.data

char      ds.w      1                   * linea - Buchstabe
zeichenzahl ds.l    1                   * Anzahl Zeichen im Puffer
konvert   ds.w      1                   * Flag fuer Code-Umwandlung
delspalte ds.w      1                   * Buchstabenbreite in Pixeln
eingabe   ds.b      100                 * Tastatureingabepuffer
filedes   ds.w      1                   * Filedescriptor
font      ds.w      1                   * Fontnummer
fontptr   ds.l      1                   * Adresse Fontheader
inittime  ds.w      1                   * Zeitinterval in sec.
keinvbl   ds.w      1                   * =0, falls keine Statusanzeige
pend      ds.l      1                   * Pufferendadresse
pin       ds.l      1                   *    Eingabe-Zeiger
pout      ds.l      1                   *    Ausgabe-Zeiger
prozent   ds.w      1                   * % Auslastung des Spoolers
prozalt   ds.w      1                   * Flag zur Anzeige Spoolerstatus
pstart    ds.l      1                   * Pufferstartadresse
size      ds.l      1                   *    Byte Pufferspeicher
spalte    ds.w      1                   * Beginn Druckspalte
spoolvoll ds.w      1                   * Flag fÅr vollen Spooler
tabzeiger ds.l      1                   * Zeiger auf Zeichensatztabelle
takt      ds.l      1                   * Zaehler fuer Warteschleife
time      ds.w      1                   * Zeit fÅr 1 h in sec.
timeflag  ds.w      1                   * = 1 fÅr Zeitmessung
trapvekt  ds.l      1                   * Adresse altes bios
txtfarbe  ds.w      1                   * FÅr Farbe des Textes
vblenable ds.w      1                   * =1, falls vblrout gewÅnscht
vbltext   ds.l      1                   * Adresse vbltxt
xpos      ds.w      1                   * x-Position des char
ypos      ds.w      1                   * y-Position des char
zeichen   ds.w      1                   * trap'#13 - Buchstabe





    
systakt   dc.l      930                 * 200 Hz - Timer-Zaehlschleife
meldung   dc.b      $0d,$0a,$1b,'B',$1b,'f'
          dc.b      '    Der Spooler ist installiert.',$0d,$0a
          dc.b      '    Bitte eine Taste drÅcken.',0
text1     dc.b      $1b,'E',$1b,'B',$1b,'B',$1b,'B',$1b,'B'
          dc.b      '    D R U C K E R S P O O L E R',$0d,$0a
          dc.b      '         KISOø  22.10.1986',$0d,$0a,0
text2     dc.b      $0d,$0a,$1b,'B'
          dc.b      'Spoolergrîûe in kByte ? (default: 100) '
          dc.b      $0d,$0a,$1b,'e',0
text3     dc.b      $0d,$0a,$1b,'B',$1b,'B'
          dc.b      'Spoolerstatus anzeigen ? (j,n)',$0d,$0a
          dc.b      '                  (default: j) ',0
text4     dc.b      $0d,$0a,$1b,'B'
          dc.b      'Minimale Zeit zwischen 2 Druck-',$0d,$0a
          dc.b      'auftrÑgen ?   (default = 6 sec) ',0
text5     dc.b      $1b,'f',0
text6     dc.b      'FONT.SPL',0
text7     dc.b      13,10,'Die Datei ist nicht zu finden.',13,10
          dc.b      'Zum Abbruch bitte eine Taste drÅcken.',27,'f',0
text8     dc.b      13,10,'Lesefehler !   <SPACE> drÅcken.',13,10,0
text9     dc.b      13,10,13,10,'Welchen Zeichensatz laden?',13,10
          dc.b      '(default : FONT.SPL)     :',0
vbltxt1   dc.b      '% Spooler',0       * maximal 12 (9) Buchstaben
vbltxt2   dc.b      'SPOOLER VOLL',0
vbltxt3   dc.b      '            ',0    * Anzeige lîschen


******************************************************************
*         öbersetzungstabelle:                                   *
*                                                                *
*         Byte :   ASCII - Code vom Atari                       *
*         Byte :   Anzahl der folgenden Bytes                   *
*      ab Byte :   Steuerzeichen,die stattdessen an den Drucker *
*                   gesendet werden sollen                       *
*                                                                *
*         Wichtig:  Ein Punkt kennzeichnet das Tabellenende!     *
*                   Falls zu Zwecken der Dokumentation Zahlen    *
*                   benîtigt werden, dann muû auf LCD-Ziffern    *
*                   ausgewichen werden, damit sie sich von den   *
*                   Daten unterscheiden!                         *
******************************************************************

.even
zeich_satz     ds.w      1              * fÅr Druckerzeichensatz

.end

