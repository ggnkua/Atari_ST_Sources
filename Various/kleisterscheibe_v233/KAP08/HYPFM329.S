*********************************************************
*                   HYPERFORMAT V3.29                   *
*                                                       *
* Written & (C) 1987,1988,1989... by                    *
*                         Claus Brod                    *
*                         Am Felsenkeller 2             *
*                         8772 Marktheidenfeld          *
*                         09391/3206                    *
*            &                                          *
*                         JÅrgen Stessun                *
*                         Beckstraûe 7                  *
*                         3100 Celle                    *
*                                                       *
* Aus dem SCHEIBENKLEISTER, dem etwas anderen Floppy-   *
* und Harddiskbuch                                      *
*                                                       *
* Die wichtigsten Features:                             *
*   Formatiert Disks bis auf 960000 Bytes               *
*   HYPER-DENSITY-Format bis auf 1.7 MB                 *
*   Wertvolle Format-Optionen: Quickformat (20s fÅr 1S, *
*   35s fÅr 2S), MS-DOS-kompatibles Format (auch 40-    *
*   spurig), Verifizieren mit Belegt-Markierung defekter*
*   Cluster, "Softformat"                               *
*   Default-Tasten fÅr Standardformate                  *
*   lÑuft als .ACC und .PRG                             *
*   Viele Formatparameter einstellbar: Sektoranzahl (1- *
*   22), Diskname, AusfÅhrbarkeit des Bootsektors,      *
*   Steprate beim Formatieren, Interleave, zusÑtzlicher *
*   Sektorvorspann fÅr mehr Speed, Sektoren pro Cluster,*
*   Spiralisierung, Laufwerk, Spuranzahl (40-44 bzw.    *
*   80-86), Kopfberuhigungszeit...                      *
* V3.28, fÅr alle STs (auch Mega); last update 30.10.91 *
*                                                       *
* Entstehungsgeschichte:                                *
*   V1.0 Januar 1987, Version fÅr RAM-TOS               *
*   V2.0 MÑrz 1987, Version fÅr RAM- und ROM-           *
*      TOS (erstmals verîffentlicht in ST-Computer 6/87)*
*   V2.1 - V2.24: Diverse Annehmlichkeiten              *
*   ab V2.5 BlitterTOS-fÑhig durch eigene FDC-Routinen  *
*                                                       *
*   2.5-2.56++(letzte PD-Version): Formatiert 2K mehr   *
*   (Umgehung eines GEMDOS-Fehlers); fragt nach Disk-   *
*   namen; Restore Head nach letztem Track; Fehler-     *
*   nummernausgabe: Highbyte = Fehlerquelle             *
*   (00=Boot, 01=Fmt, 02=FDC, 04=Memory, 08=Verify)     *
*   Lowbyte ist die Fehlerart                           *
*   2.57 (schon wieder eine letzte PD-Version): 2K-Trick*
*   wird wegen Kompatibidings nicht mehr verwendet      *
*   2.6-2.8: 9/10-Sektor-Formate, Quickformat-Option    *
*   rÅckwÑrts formatieren, Zeit-Optimierungen, AufrÑum- *
*   arbeiten, Steprate als Variable, Grenzen bei den    *
*   Parametern erweitert, verbesserte Tastaturabfrage,  *
*   Funktionstasten eingebaut, ausfÅhrlichere Fehler-   *
*   meldungen, Verify markiert schlechte Sektoren       *
*                                                       *
*   2.8-2.99: Kosmetik, Trackausgabe, MS-DOS kompatibles*
*   Mediabyte, Bootsektoren an MS-DOS angepaût, Spirali-*
*   sierung, Nachspann mit Extrasektor eingebaut, 40-   *
*   Spur-Formate, MS-DOS-Default-Formate, Steprate auch *
*   aus MenÅ, zusÑtzlicher Header abschaltbar, Help-    *
*   seite geÑndert, ESC nach 'Insert disk' mîglich      *
*   Super-Quick-Format                                  *
*                                                       *
*   3.00: Spiralisierung lÑuft mit Super-Quick-Format   *
*   EntrÅmpelung im Super-Quick-Teil, LÅcken angeglichen*
*   Versionsnummer parametrisiert, Unschînheit bei der  *
*   Speicherreservierung behoben                        *
*   3.01: Spiralisierung jetzt regelmÑûiger bei 2seiti- *
*   gen Disketten; makevf verbessert                    *
*   3.02: Anzahl der FAT-Sektoren jetzt flexibel (wird  *
*   vor dem Formatieren ausgerechnet); spc als Variable *
*   Programmierung von AS68 auf MADMAC umgestellt       *
*   3.03: neue Option 'Cluster size'                    *
*   3.04: Clustergrîûe wird jetzt auch bei Standard-    *
*   formaten eingestellt                                *
*   3.05: Zahlenausgaben jetzt in dezimal, maximal 8    *
*   Sektoren pro Cluster                                *
*   3.06: 11-Sektor-Format leicht geÑndert (NEC1037)    *
*   Default fÅr 'additional header' jetzt 'n', maximal  *
*   224 Rootdir-EintrÑge (fÅr DOS); markbad verbessert  *
*   3.07: Formatier-Abbruch mit ALTERNATE-Taste         *
*   3.08: Optimierungen (Dank an Thomas Kitlar)         *
*   lÑuft jetzt auch als ACC (einfach umnennen), fÅhren-*
*   de Nullen bei Dezimalausgabe werden unterdrÅckt     *
*   Tastaturpuffer wird auch in inputname geleert, Un-  *
*   sauberkeit in writeboot behoben, Stapelzeiger in    *
*   exitus korrigiert (exitus2), 0-4 Verifyversuche     *
*   wÑhlbar, keine Namenseingabe bei Superquick mehr,   *
*   ALT bricht auch Verify ab, Dir-Parameter wird bei   *
*   Default-Formaten gesetzt, interne Optimierungen     *
*   Herzlichen Dank an JÅrgen Stessun!                  *
*   3.09: 2K-GEMDOS-Fehler wird jetzt nicht mehr        *
*   korrigiert (seufz); man halte sich an neue TOS-Ver- *
*   sionen oder 2KPATCH.PRG; AES-Gemurkse               *
*   3.1: Neuerlichen Dank an JÅrgen Stessun!            *
*   Label-Erzeugung klappt jetzt auch mit TOS1.4        *
*   Tastaturoutine verbessert, ^C wird abgefangen,      *
*   Speicherverwaltung neu, ACC verweigert sich, wenn   *
*   zuwenig Speicher da, Fehler in TRK80 raus, nach     *
*   Fehler rsthead, Kosmetik, Optimierungen             *
*   Additional header jetzt konstant bei Offset 6200    *
*   SchreibgeschÅtzte Diskette wird per Crit-Err-Handler*
*   angemahnt; Åberarbeitet zur Verîffentlichung        *
*   3.2: Patches by JÅrgen, 14-Sektor-Format,           *
*   Ausgabe der Spurnummer wÑhrend der DMA-öbertragung  *
*   neue Default-Formate, maximal 3 Verify-Versuche     *
*   3.21: Settling delay repariert, IntrasektorlÅcke    *
*   beim 11er-Format um eins verkÅrzt, normales 9er-    *
*   etwas groûzÅgiger, appl_init/exit auch bei PRG,     *
*   Ausstieg auch ohne Disk im Laufwerk mîglich         *
*   3.22: HDSEL.ACC wird Gelegenheit zum Umschalten     *
*   F10 erlaubt automatisches Umschalten auf 10 MHz     *
*   Maus an bei Disknamen-Alert                         *
*   3.23: ACC meldet Speichermangel per Alert           *
*   Ausbau fÅr maximal 20 Sektoren (HD-Disks)           *
*   3.24: Steprate wird ab 1.1 MB auf 6ms gestellt;     *
*   Mediabyte-Anpassung fÅr PS2-Formate                 *
*   Gap-Tabelle durch String "HYPER-GAPS" gekennzeichnet*
*   3.25: Maximal 21 Sektoren, andere LÅcken            *
*   3.26: F10 schaltet Bit 6 im Soundchip direkt um,    *
*   dadurch auch Formate mit weniger als 12 Sektoren im *
*   HD-Modus mîglich                                    *
*   3.27: LÑût sich als ACC aus GEMINI per Iconklick    *
*   aufrufen; Anpassung an grîûere Auflîsungen          *
*   'Back to menu' statt 'Again'; Frage nicht mehr im   *
*   ACC                                                 *
*   3.28: 22 Sektoren im HD-Modus (dank T. Lang)        *
*   bei schreibgeschÅtzter Disk keine Alertbox mehr,    *
*   machte nur érger                                    *
*   3.29: Fehler beim Schreiben von Diskettennamen      *
*   behoben (Dank an Christoph Zwerschke)               *
* Assembliert mit TURBO-ASS                             *
*********************************************************

version         EQU 3+48        ; Versionsnummer in ASCII
rev1            EQU 2+48        ; Revisionsnummer in ASCII
rev2            EQU 9+48        ; Revisionsnummer, zweite Stelle

virgin1         EQU $CB         ; Virgin data, Highbyte
virgin2         EQU $CB         ; Virgin data, Lowbyte

bpt10           EQU 7984        ; Bytesumme bei 10.24 MHz
bpt8            EQU 6256        ; 10 MHz: 7800, 8 MHz: 6256

h21gap1         EQU 10          ; LÅcken fÅr 21 Sektoren
h21gap2         EQU 8
h21gap31        EQU 22
h21gap32        EQU 12
h21gap4         EQU 24

h22gap1         EQU 3           ; LÅcken fÅr 22 Sektoren
h22gap2         EQU 4
h22gap31        EQU 22
h22gap32        EQU 12
h22gap4         EQU 2

h14gap1         EQU 8           ; LÅcken fÅr das 14-Sektor-Format
h14gap2         EQU 2
h14gap31        EQU 22
h14gap32        EQU 12
h14gap4         EQU 5

h13gap1         EQU 30          ; LÅcken fÅr 13 Sektoren
h13gap2         EQU 12
h13gap31        EQU 22
h13gap32        EQU 12
h13gap4         EQU 39

q12gap1         EQU 40          ; LÅcken fÅr Quickformat, 12 Sektoren
q12gap2         EQU 12
q12gap31        EQU 22
q12gap32        EQU 12
q12gap4         EQU 30

gap1            EQU 3           ; Gap 1     (LÅcken zwischen
gap2            EQU 3           ; Gap 2      den Daten fÅr
gap31           EQU 22          ; Gap 3.1    11-Sektor-Format)
gap32           EQU 12          ; Gap 3.2
gap4            EQU 2           ; Gap 4

qgap1           EQU 21          ; Gap 1     (LÅcken fÅr Quickformat,
qgap2           EQU 12          ; Gap 2      10 Sektoren)
qgap31          EQU 22          ; Gap 3.1
qgap32          EQU 12          ; Gap 3.2
qgap4           EQU 21          ; Gap 4

n10gap1         EQU 80          ; Gaps fÅr normales 10er-Format
n10gap2         EQU 12
n10gap31        EQU 22
n10gap32        EQU 12
n10gap4         EQU 38

ngap1           EQU 100         ; Gap 1     (LÅcken fÅr normales
ngap2           EQU 12          ; Gap 2      Format)
ngap31          EQU 22          ; Gap 3.1
ngap32          EQU 12          ; Gap 3.2
ngap4           EQU 38          ; Gap 4

q9gap1          EQU 60          ; Gap 1     LÅcken fÅr Quick 1, 9 Sektoren
q9gap2          EQU 12          ; Gap 2
q9gap31         EQU 22          ; Gap 3.1
q9gap32         EQU 12          ; Gap 3.2
q9gap4          EQU 40          ; Gap 4

************************
* Formatparameter, von denen man seine Finger lassen sollte
* (sind zwar als Parameter aus dem Programm herausgezogen,
*  erzwingen aber énderungen im Programm, wenn man sie fÅr
*  eigene Zwecke umbiegt)
************************
res             EQU 1           ; Reservierte Sektoren
fat             EQU 2           ; Anzahl der FATs
bufflength      EQU 25000       ; LÑnge des Trackpuffers
timeout         EQU $060000     ; Timeout-Konstante
scrlen          EQU 32000       ; SchirmlÑnge
maxfatsecs      EQU 10          ; maximal 10 FAT-Sektoren
max_dir         EQU 224         ; Maximalzahl von Rootdir-EintrÑgen (<256!!!)

q8schwelle      EQU 11          ; ab wieviel Sektoren ist QUICK verboten
q10schwelle     EQU 21
maxsecs         EQU 22          ; Maximalzahl einstellbarer Sektoren
maxtracks       EQU 87          ; maximale Spuranzahl
maxverifies     EQU 3           ; Maximalzahl der Verifyversuche

************************
* Systemadressen
************************
snd             EQU $FFFF8800   ; Adresse des Soundchips
sndwrt          EQU $FFFF8802   ; Ein/Ausgabe des Soundchips
mfp             EQU $FFFFFA01   ; Adresse des MFP68901 fÅrs Polling
daccess         EQU $FFFF8604   ; DMA-Access: FDC-Zugriff/SektorzÑhler
dmodus          EQU $FFFF8606   ; DMA-Modusregister
dlow            EQU $FFFF860D   ; DMA-ZÑhler, öbertragungsstart Lowbyte
dmid            EQU $FFFF860B   ; DMA-ZÑhler, Åbertragungsstart Midbyte
dhigh           EQU $FFFF8609   ; DMA-ZÑhler, Åbertragungsstart Highbyte

*****************
* Routine zum Reservieren von Speicherplatz
*****************
reserve:
                lea     reserve-256(PC),A5 ; Basepagestart
                lea     nstapel(PC),SP  ; neuer Stackpointer
                tst.l   36(A5)          ; haben wir Eltern?
                beq     resacc          ; nein, wir sind ein Accessory!

                move.l  12(A5),D0       ; LÑnge von .text
                add.l   20(A5),D0       ; LÑnge von .data addieren
                add.l   28(A5),D0       ; LÑnge von .bss addieren
                add.l   #maxfatsecs*512+bufflength+256,D0
; Platz fÅr FATs und Spurpuffer

                move.l  D0,-(SP)        ; Grîûe des Bereichs
                bsr     prgzeig         ; Zeiger setzen

                move.l  A5,-(SP)        ; Startadresse, ab der reserviert wird
                clr.w   -(SP)           ; Dummy (reserviert)
                move.w  #74,-(SP)       ; SETBLOCK
                trap    #1              ; im GEMDOS
                lea     12(SP),SP       ; Stack korrigieren

                bsr     fila6           ; Zeiger setzen
                move.w  #10,(A6)+       ; appl_init, Anwendung anmelden
                move.l  #1,(A6)+        ; 1 Ausgabeparameter
                clr.l   (A6)
                bsr     aes             ; AES-Aufruf
                move.w  intout(PC),apid ; Application-ID retten

                move.w  #77,(A6)+
                move.l  #5,(A6)+
                clr.l   (A6)
                bsr     aes
                move.w  intout(PC),grhandle

                bsr     fila6
                move.w  #107,(A6)+      ; wind_update
                move.l  #$010001,(A6)+
                clr.l   (A6)
                move.w  #3,intin        ; wir haben die Mauskontrolle
                bsr     aes

                DC.W $A00A      ; Maus aus
                bsr     ans_werk        ; zur Hauptroutine
                DC.W $A009      ; Maus an

                bsr     fila6
                move.w  #107,(A6)+      ; wind_update
                move.l  #$010001,(A6)+
                clr.l   (A6)
                move.w  #2,intin        ; Mauskontrolle wieder bei AES
                bsr     aes

                bsr     fila6           ; Zeiger setzen
                move.w  #19,(A6)+       ; appl_exit, Anwendung abmelden
                move.l  #1,(A6)+        ; 1 Ausgabeparameter
                clr.l   (A6)
                bsr     aes             ; AES-Aufruf

                clr.w   -(SP)           ; Raus in die bîse Welt
                trap    #1              ; TERM

***********************
* resacc: Programm als Acc anmelden
***********************
resacc:
                bsr     fila6           ; Zeiger setzen
                move.w  #10,(A6)+       ; appl_init, Anwendung anmelden
                move.l  #1,(A6)+        ; 1 Ausgabeparameter
                clr.l   (A6)
                bsr     aes             ; AES-Aufruf
                move.w  intout(PC),apid ; Application-ID retten

                move.w  #77,(A6)+
                move.l  #5,(A6)+
                clr.l   (A6)
                bsr     aes
                move.w  intout(PC),grhandle

                move.w  #35,(A6)+       ; menu_register, Namen eintragen
                move.l  #$010001,(A6)+  ; 1*intin, 1*intout
                move.l  #$010000,(A6)   ; 1*addrin
                move.w  apid(PC),intin  ; Application-ID
                move.l  #accname,addrin ; Zeiger auf Namen
                bsr     aes
                move.w  intout(PC),accid ; Accessory-ID merken

**************************
* accloop: Auf Anklicken warten
**************************
accloop:
                bsr     fila6           ; Zeiger setzen
                bsr     ereignis        ; auf ein Ereignis warten
                lea     msgbuff(PC),A0
                cmpi.w  #40,(A0)        ; AC_OPEN?
                bne.s   accgemini
                move.w  msgbuff+8(PC),D0 ; Acc-Nummer holen
                cmp.w   accid(PC),D0    ; sind wir das?
                beq.s   accopen         ; ja, sind wir
accgemini:
                cmpi.w  #$4711,(A0)
                bne.s   accloop
accopen:
                move.l  #scrlen+(maxfatsecs*512)+bufflength,-(SP)
; soviel Platz brauchen wir
                moveq   #-1,D0          ; wieviel freier Speicher
                bsr     malloc          ; MALLOC
                move.l  (SP)+,D1
                cmp.l   D0,D1           ; genug Speicher da?
                bcs.s   speichersatt    ; ja
                bsr     memalert        ; Speichermangel melden
                bra.s   accloop         ; nein, zurÅck zur Schleife
speichersatt:
                move.l  D1,D0           ; Speicher allokieren
                bsr     malloc
                movea.l D0,A0           ; Start der FAT-Sektoren
                bsr     acczeig         ; Zeiger fÅrs ACC setzen

                DC.W $A00A      ; Maus aus
                moveq   #0,D7           ; Schirm retten
                bsr     scrcopy

                bsr     fila6
                move.l  #$680002,(A6)+  ; WIND_GET, 2*int_in
                move.w  #7,(A6)+        ; 5*int_out
                clr.l   (A6)            ; 0*addr_in, 0*addr_out
                lea     intin(PC),A0
                clr.w   (A0)+           ; Fenster 0
                move.w  #5,(A0)         ; WF_FULLXYWH
                bsr     aes
                lea     intout+2(PC),A0
                move.l  (A0)+,xpos      ; X/Y-Position holen
                move.l  (A0),size       ; Breite/Hîhe holen

                bsr     fila6
                move.l  #$330009,(A6)+  ; FORM_DIAL, 9*intin
                move.w  #1,(A6)+        ; 1*intout
                clr.l   (A6)
                lea     intin(PC),A0
                clr.w   (A0)+
                move.l  xpos(PC),D0
                move.l  size(PC),D1
                move.l  D0,(A0)+
                move.l  D1,(A0)+
                move.l  D0,(A0)+
                move.l  D1,(A0)+        ; Koordinaten setzen
                bsr     aes

                bsr     ans_werk        ; los geht's

                moveq   #1,D7           ; Schirm zurÅckkopieren
                bsr     scrcopy

                bsr     fila6
                move.l  #$330009,(A6)+  ; FORM_DIAL, 9*intin
                move.w  #1,(A6)+        ; 1*intout
                clr.l   (A6)
                lea     intin(PC),A0
                move.w  #3,(A0)+        ; FMD_FINISH
                move.l  xpos(PC),D0
                move.l  size(PC),D1
                move.l  D0,(A0)+
                move.l  D1,(A0)+
                move.l  D0,(A0)+
                move.l  D1,(A0)+        ; Koordinaten setzen
                bsr     aes

                move.l  fatstart(PC),-(SP) ; Speicherblock-Anfang
                move.w  #73,-(SP)       ; MFREE
                trap    #1              ; GEMDOS
                addq.l  #6,SP

                DC.W $A009      ; Maus an
                bra     accloop         ; zur ACC-Schleife


* Speicher per MALLOC besorgen
malloc:
                move.l  D0,-(SP)
                move.w  #72,-(SP)       ; MALLOC
                trap    #1
                addq.l  #6,SP
                rts

* Zeiger fÅr PRG oder ACC setzen
prgzeig:
                lea     fats(PC),A0     ; Zeiger fÅrs PRG
acczeig:
                lea     zei(PC),A1      ; ab hier fÅrs Accessory
                move.l  A0,fatstart     ; FAT-Start merken
                lea     maxfatsecs*512(A0),A0
; LÑnge der FATs
                move.l  A0,bf           ; Spurpuffer-Anfang
                lea     bufflength(A0),A0
; Spurpuffer-LÑnge
                move.l  A0,scrsave      ; Schirmpuffer-Anfang
                movea.l fatstart(PC),A0 ; Startadresse
                move.l  #((maxfatsecs*512+(bufflength/2))/4)-1,D0
; LÑnge
clloop:
                clr.l   (A0)+           ; allokierten Bereich lîschen
                dbra    D0,clloop
                rts

memalert:
                move.w  #52,(A6)+       ; form_alert
                move.l  #$010001,(A6)+  ; 1*intin, 1*intout
                move.l  #$010000,(A6)+  ; 1*addr_in
                move.w  #1,intin        ; Default-Button
                move.l  #nomem,addrin   ; "Zuwenig Speicher"
                bra.s   aes

ereignis:
                move.w  #25,(A6)+       ; evnt_multi
                move.l  #$100007,(A6)+  ; 10*intin, 7*intout
                move.l  #$010000,(A6)   ; 1*addrin
                move.l  #msgbuff,addrin ; Message-Puffer
                move.l  #$130001,intin  ; Parameter
                move.l  #$010001,intin+4

*********************
* aes: Ruft das AES auf
*********************
aes:
                move.l  #aespb,D1       ; -> Zeiger-Puffer
                move.w  #$C8,D0         ; AES ist gewÅnscht
                trap    #2              ; GEM-Aufruf
fila6:
                lea     contrl(PC),A6
                lea     zei(PC),A5
                rts

********************
* scrcopy: Bildschirm in Puffer kopieren oder
*          Puffer in Bildschirm kopieren
* IN: d7.l 0=Bildschirm->Puffer
*          1=Puffer->Bildschirm
********************
scrcopy:
                move.w  #3,-(SP)        ; Schirmadresse holen
                trap    #14             ; XBIOS
                addq.l  #2,SP
                movea.l D0,A0           ; Adresse kopieren
                movea.l scrsave(PC),A1  ; Pufferadresse
                move.w  #scrlen/4-1,D1  ; SchirmlÑnge (funktioniert nicht auf Groûbild!)
                tst.l   D7              ; hin oder zurÅck
                beq.s   scr1            ; hinkopieren
                exg     A0,A1           ; Quelle/Ziel vertauschen
scr1:
                move.l  (A0)+,(A1)+
                dbra    D1,scr1
                rts


* neue Tastatur-Routine
                DC.B "XBRA"
                DC.B "CBHY"
oldvec:
                DC.L 0

kbddrv:
                move.l  $04A2.w,tsavp   ; savptr retten
                lea     endarea(PC),A0  ; neuer Bereich
                move.l  A0,$04A2.w

                move.l  #$0E0001,-(SP)  ; IOREC von Tastatur
                trap    #14
                addq.l  #4,SP

                movea.l D0,A0           ; Zeiger auf Tabelle
                move.w  8(A0),-(SP)     ; Tail Index (Schreibzeiger)
                move.l  A0,-(SP)        ; Zeiger auf Tabelle
                movea.l oldvec(PC),A0   ; normale Tastaturroutine
                jsr     (A0)            ; ausfÅhren
                movea.l (SP)+,A1        ; Zeiger auf Tabelle
                move.w  8(A1),D2        ; Tail Index (Schreibzeiger)
                cmp.w   (SP)+,D2        ; gleich altem Index?
                beq.s   nokeys          ; ja, keine Taste gedrÅckt
                movea.l 0(A1),A2        ; Zeiger auf Eingabepuffer
                move.l  0(A2,D2.w),D0   ; Taste holen
                cmp.w   #3,D0           ; ^C?
                beq.s   simul           ; jawoll
                cmp.w   #19,D0          ; ^S?
                beq.s   simul           ; jawoll
                cmp.w   #32,D0          ; kleiner als Space
                bcc.s   nokeys          ; nein
                cmp.w   #13,D0          ; RETURN?
                beq.s   nokeys          ; ja
                tst.w   keyflag         ; alle Tasten benutzen?
                beq.s   nokeys          ; ja
                cmp.w   #8,D0           ; Backspace?
                beq.s   nokeys
                cmp.w   #24,D0          ; ^X?
                beq.s   nokeys
simul:
                subi.w  #4,8(A1)        ; Tail um 4 Zeichen zurÅck
                bclr    #1,$0484.w      ; Repeat ausschalten
out:
                move.l  tsavp(PC),$04A2.w ; alten savptr holen
                rts                     ; und raus
nokeys:
                bset    #1,$0484.w      ; Repeat an
                bra.s   out             ; fertig!

*
vektorinit:
                move.w  #34,-(SP)       ; KBDVBASE
                trap    #14
                addq.l  #2,SP
                movea.l D0,A2           ; Zeiger auf Tabelle
                move.l  D0,kshift
                move    SR,-(SP)        ; IRQs aus
                ori     #$0700,SR       ; IRQs aus
                lea     oldvec(PC),A0   ; Zeiger auf Vektor-Puffer
                move.l  32(A2),(A0)     ; Adresse der alten IKBD-Routine
                lea     kbddrv(PC),A1   ; neue Routine
                move.l  A1,32(A2)       ; installieren
                move    (SP)+,SR        ; IRQs wieder an
                rts

*************************
* ans_werk: Hauptroutine
*************************
ans_werk:
                clr.l   -(SP)           ; Supervisormodus an
                move.w  #32,-(SP)       ; SUPER
                trap    #1
                addq.l  #6,SP
                move.l  D0,-(SP)        ; SP gleich retten

                lea     kbshift(PC),A2
                move.l  #$0E1B,(A2)     ; kbshift vorbelegen
                movea.l $04F2.w,A0      ; sysbase holen
                move.w  2(A0),D0        ; TOS-Version
                cmp.w   #$0102,D0       ; grîûer gleich 1.2?
                blt.s   fatreserve      ; nein, weiter
                move.l  36(A0),(A2)     ; kbshift-Adresse Åbertragen

fatreserve:
                bsr.s   vektorinit      ; IKBD-Vektor umbiegen

**************************
* main: Holt Parameter, formatiert
* und gibt Gelegenheit zur Wiederholung
**************************
main:
                lea     intromsg(PC),A5 ; Intromeldung
                bsr     printmsg        ; ausgeben

main0:
                clr.w   offset          ; Vektor zurÅcksetzen
                lea     z1(PC),A5       ; Ein/Ausgabebereich sÑubern
                bsr     printmsg        ; ausgeben

                movea.l fatstart(PC),A0 ; Start des Arbeits-Bereichs
                move.l  #((maxfatsecs*512+bufflength)/4)-1,D0
mclloop:
                clr.l   (A0)+           ; Bereich lîschen
                dbra    D0,mclloop

main2:
                bsr     parameters      ; Parameter einstellen
                lea     diskmsg(PC),A5  ; Adresse des Strings holen
                bsr     printmsg        ; 'Insert disk'
                bsr     waitforkey      ; auf Taste warten
                cmp.b   #27,D0          ; ESC gedrÅckt?
                beq.s   main0           ; ja, zurÅck ins MenÅ

                bsr     wechsel         ; Wechsel simulieren und HD.ACC Gelegenheit
; zum Umschalten geben

                st      $043E.w         ; Floppy-VBL sperren
                bsr     tracktest       ; auf HD testen

                bsr     calc_secs       ; Sektoren ausrechnen
                bsr     mkfatsecs       ; FAT-Sektoren vorbereiten

                cmpi.w  #13,fmtflag     ; Formatieren oder nur Bootsektor?
                bne.s   nurboot         ; nur Bootsektor schreiben
                bsr     formatdisk      ; eigentliche Formatierroutine
                tst.w   D0              ; Fehler beim Formatieren?
                bne     error           ; ab zur Fehlerroutine

nurboot:
                bsr     writeboot       ; Bootsektor etc. schreiben
                tst.w   D0              ; Fehler passiert?
                bne     error           ; ja, Nirwana lockt

                cmpi.w  #2,quickflag    ; Quick-Modus 2?
                beq.s   main0           ; ja, dann keinen Namen eingeben lassen

                bsr     inputname       ; Diskettenname holen
                tst.b   D0              ; etwas eingegeben?
                beq.s   main0           ; nein, weiter
                bsr     writename       ; Diskettennamen schreiben
                tst.w   D0              ; Fehler?
                bne     error           ; ja, leider
                bra     main0           ; zur Schleife

exitus2:
                addq.l  #4,SP           ; damit der Stapel stimmt
exitus:
                move.w  accid(PC),D0    ; sind wir ein Acc?
                bpl.s   beenden         ; ja, raus hier
                lea     againmsg(PC),A5 ; 'Back to menu (Y/N)?'
                bsr     printmsg        ; ausgeben
ynloop:
                bsr     getkey          ; auf Taste warten
                cmp.b   #27,D0          ; ESC?
                beq.s   beenden
                cmp.b   #'y',D0
                beq     main
                cmp.b   #'n',D0
                bne.s   ynloop

beenden:
                moveq   #0,D0           ; deselektieren, bitteschîn
                bsr     mach_mal
                sf      $043E.w         ; Floppy-VBL freigeben

* Wechsel auf Laufwerk simulieren
                bsr.s   wechsel         ; Wechsel auf Laufwerk simulieren

                movea.l kshift(PC),A2
                move    SR,-(SP)        ; Status retten
                ori     #$0700,SR       ; IRQs aus
                move.l  oldvec(PC),32(A2) ; alten Vektor
                move    (SP)+,SR        ; rÅckinstallieren

                move.w  #32,-(SP)       ; SUPER
                trap    #1              ; zurÅck in Usermodus
                addq.l  #6,SP
                rts

wechsel:
                move.w  laufwerk(PC),-(SP) ; Laufwerksnummer
                clr.w   -(SP)           ; Sektornummer
                move.w  #2,-(SP)        ; count
                clr.l   -(SP)           ; Pufferadresse 0
                clr.w   -(SP)           ; R/W-Flag
                move.w  #4,-(SP)        ; RWABS
                trap    #13             ; BIOS
                lea     14(SP),SP       ; SP korrigieren
                rts

***********************
* formatdisk: von Track endtrack bis 0 formatieren
***********************
formatdisk:
                lea     z1(PC),A5       ; Schirm sÑubern
                bsr     printmsg

                lea     trackmsg(PC),A5 ; Adresse der Trackmessage
                cmpi.w  #2,quickflag    ; Super-Quick?
                bne.s   noquick         ; nein, kein Super-Quickformat
                lea     track2msg(PC),A5 ; alternative Trackmessage
noquick:
                bsr     printmsg        ; ausgeben

                move.w  laufwerk(PC),D0 ; aktuelles Laufwerk holen
                addq.w  #1,D0           ; +1 (=1 fuer Drv A, =2 fuer Drv B)
                lsl.w   #1,D0           ; mal 2 (=2 fÅr A, =4 fÅr B)
                bsr     do_select       ; Laufwerk selektieren

                bsr     rsthead         ; Kopf auf Spur 0 (zur Sicherheit)

                movea.l bf(PC),A6       ; Trackpufferadresse nach a6
                bsr     mktrack         ; Prototyp-Track erstellen
                tst.w   D0              ; Fehler?
                bne.s   fmterror        ; ja, raus hier

                lea     side(PC),A2     ; Adresse des Seitenpuffers
                move.w  endtrack(PC),D4 ; ab Endtrack formatieren
floop:
                bsr     such_hasso      ; Track suchen
                bsr     formattrack     ; einen Track formatieren
                tst.w   D0              ; Fehler passiert?
                bne.s   fmterror        ; ja, durchreichen

                movea.l kbshift(PC),A6
                btst    #3,(A6)         ; ALT-Taste gedrÅckt?
                bne.s   fmterror        ; ja, raus hier

                bsr.s   calcspir        ; Spiraloffsetberechnung
                subq.w  #1,D4           ; NÑchster Track
                bpl.s   floop           ; alle Tracks formatiert?
                clr.w   D0              ; kein Fehler
                rts                     ; geschafft, raus

***********************
* auf Spurdichte prÅfen
* OUT: d0   0=normale Dichte
*           $1100=HYPER DENSITY
***********************
tracktest:
                bsr     rdtrk           ; eine Spur lesen
                move.w  #$1100,D0
                move.w  D2,headerpos    ; TracklÑnge merken
                subi.w  #25,headerpos   ; minus 25 ergibt Headerposition

                sub.l   #$1900,D2       ; mehr als 6400 Bytes?
                bpl.s   testexit        ; ja, dann neuer Quarz
                clr.w   D0              ; Keine Hyper-Density
testexit:
                move.w  D0,density      ; Dichte merken
                rts

fmterror:
                move.l  D0,-(SP)
                bsr     rsthead         ; Kopf auf Spur 0
                move.l  (SP)+,D0
                or.w    #$0100,D0       ; Fehler kommt aus fmt-Routine
                rts                     ; raus

memerror:
                and.w   #$FF,D0         ; die unteren 8 Bit ausmaskieren
                or.w    #$0400,D0       ; Fehler kommt aus mem-Routine
                rts                     ; raus

************************
* calcspir: Spiralfaktor addieren
************************
calcspir:
                lea     offset(PC),A0   ; Adresse des Spiraloffsets
                move.w  (A0),D0         ; Wert holen
                add.w   spirfaktor(PC),D0 ; plus Spiralfaktor
                cmp.w   realspt(PC),D0  ; mit maximaler Sektorzahl vergleichen
                bmi.s   spirok          ; kleiner, dann ok
                sub.w   realspt(PC),D0  ; maximale Sektorzahl abziehen
spirok:
                move.w  D0,(A0)         ; Neuen Offset schreiben
                rts

************************
* prntrk: Aktuellen Track ausgeben
* IN: d4 Tracknummer
************************
prntrk:
                movem.l D1/A2/A5-A6,-(SP) ; d1 und a2/a5/a6 retten
                lea     s_akt(PC),A6    ; Stringadresse holen
                bsr     d4todec         ; d4 nach dec in String ab a6
                lea     s_trk(PC),A5    ; Trackmessage
                bsr     printmsg        ; aktuellen Track ausgeben
                movem.l (SP)+,D1/A2/A5-A6 ; Register holen
                rts

************************
* Verify-Routine
************************
machvf:
                moveq   #1,D4           ; Start bei Sektor 1

nextone:
                move.w  vfflag(PC),vecount ; Maximalzahl der Verify-Versuche
vagain:
                bsr     rdsec           ; Sektor d4 lesen
                tst.w   D0              ; Fehler passiert?
                beq.s   vfloop          ; nein, nÑchster Sektor

                movea.l kbshift(PC),A6
                btst    #3,(A6)         ; ALT gedrÅckt?
                bne.s   fmterror        ; ja, dann raus hier

                subq.w  #1,vecount      ; VerifyzÑhler - 1
                bne.s   vagain          ; nochmal?

                or.w    #$0800,D0       ; Fehler kommt aus Verify
                bsr.s   markbad         ; schlechten Cluster in FAT markieren
                clr.w   D0              ; Fehler lîschen
vfloop:
                addq.w  #1,D4           ; nÑchster Sektor
                cmp.w   spt(PC),D4      ; schon alle durch?
                bls.s   nextone         ; nein, nochmal
                rts                     ; fertig (d0.w=0)

************************
* markbad: Schlechten Sektor in FAT mit $FF7 markieren
* IN: d4 Sektornr., trk(pc) Tracknummer, spt(pc) Sektoren pro Track
* side(pc) Seitenzahl, sd(pc) aktuelle Seite
************************
markbad:
                movem.l D0-A6,-(SP)     ; Register retten
                move.w  D4,actsec       ; aktuellen Sektor merken

                move.w  trk(PC),D3      ; Aktuelle Tracknummer
                clr.w   D1              ; d1.w lîschen
                move.b  side(PC),D1     ; Seitenzahl holen
                mulu    D1,D3           ; Tracknummer * Seitenzahl
                add.w   sd(PC),D3       ; plus aktuelle Seite (0 oder 1)
                mulu    spt(PC),D3      ; mal spt (Sektoren pro Spur)
                add.w   D4,D3           ; plus physikalische Sektornr.
                subq.w  #1,D3           ; minus eins ergibt logische Sektornr.

                clr.w   D1              ; d1.w lîschen
                move.b  entries(PC),D1  ; Anzahl der Dir-EintrÑge
                lsr.w   #4,D1           ; durch 16 ergibt Dir-Sektoren
                move.w  secsperfat(PC),D4 ; Sektoren pro FAT
                add.w   D4,D4           ; mal 2
                addq.w  #1,D4           ; plus eins (Bootsektor)
                add.w   D4,D1           ; Dir-Sektoren+FATs+Bootsek. = Datrec
                sub.w   D1,D3           ; logsec-datrec
                bpl.s   log_bigger      ; negatives Ergebnis?
                clr.w   D3              ; Cluster 0
                bra.s   calcfat         ; weiter
log_bigger:
                divu    spc(PC),D3      ; durch Sektoren pro Cluster (normal 2)
                addq.w  #2,D3           ; plus 2 ergibt Clusternummer
calcfat:
                move.w  D3,D1           ; Clusternummer retten
                lsr.w   #1,D3           ; Clusternummer durch 2
                add.w   D1,D3           ; plus Clnum ( also Clnum * 1.5 )
                move.w  #$0FF7,D2       ; Kennzeichen fÅr 'Cluster kaputt'
                btst    #0,D1           ; Clusternummer ungerade?
                beq.s   cleven          ; ja
                lsl.w   #4,D2           ; Kennzeichen mal 16
cleven:
                movea.l fatstart(PC),A5 ; Zeiger auf Beginn der FAT
                move.b  1(A5,D3.w),D1   ; Highbyte aus der FAT holen
                lsl.w   #8,D1           ; Byte in obere HÑlfte retten
                move.b  0(A5,D3.w),D1   ; Lowbyte holen
                or.w    D2,D1           ; mit Kennzeichen verodern
                move.b  D1,0(A5,D3.w)   ; Lowbyte schreiben
                lsr.w   #8,D1           ; um ein Byte shiften
                move.b  D1,1(A5,D3.w)   ; Highbyte schreiben

                bsr.s   senderror       ; Errormsg ausgeben (d0=error)

                movem.l (SP)+,D0-A6     ; Register holen
                rts                     ; und raus

*************************
* senderror: Bereitet Errormsg auf
* und gibt sie aus
* IN: d0 Errornumber
*************************
senderror:
                lea     errnum(PC),A6   ; Errorstring
                move.w  D0,D4           ; d0 nach d4
                move.w  D0,-(SP)        ; Fehlernummer retten
                moveq   #3,D1           ; 3+1 Nibbles = 1 Wort wandeln
                bsr     d4tohex         ; d4 nach hex in String ab a6

                lea     badsec(PC),A6   ; Adresse des Badsec-Strings
                move.w  actsec(PC),D4   ; Sektornr holen
                bsr     d4todec         ; d4 in String wandeln
                lea     badtrk(PC),A6   ; Adresse des Badtrk-Strings
                move.w  trk(PC),D4      ; Aktuellen Track holen
                bsr     d4todec         ; d4 in String wandeln
                lea     badsd(PC),A6    ; Adresse des Badsd-Strings
                move.w  sd(PC),D4       ; Aktuelle Seite
                bsr     d4todec         ; in String wandeln

                lea     errormsg(PC),A5 ; Adresse der Message
                bsr     printmsg        ; ausgeben und raus

                move.w  (SP)+,D0        ; Fehlernummer holen
                cmp.w   #$F3,D0         ; Schreibschutz?
                rts

************************
* formattrack: Einen Track formatieren
* d5:Seite, d4:Track, a6:Puffer
************************
formattrack:
                movea.l bf(PC),A6       ; Pufferadresse holen
                move.w  quickflag(PC),D0 ; Quickflag holen
                cmp.w   #2,D0           ; =2 (Super-Quick)?
                beq.s   extraquick      ; ja, besondere Formatierroutine

                clr.w   errflag         ; Error-Flags lîschen
                cmpi.b  #2,(A2)         ; 1 oder 2 Seiten?
                bne.s   onlyone         ; nur eine
                moveq   #1,D5           ; Seite 1 formatieren
                bsr.s   do_fmt
                move.w  D0,errflag      ; Fehler aus d0 ablegen

                bsr     calcspir        ; Spiraloffsetberechnung
onlyone:
                clr.w   D5              ; Seite 0 formatieren
                bsr.s   do_fmt          ; Spur formatieren
                tst.w   D0              ; Fehler passiert?
                bne.s   fmt2err         ; ja, durchreichen
                tst.w   errflag         ; Fehler auf der RÅckseite?
                bne.s   fmt2err         ; ja, durchreichen
fmt2ok:
                clr.w   D0              ; kein Fehler
fmt2err:
                rts

do_fmt:
                movem.l D1-D7/A2-A6,-(SP) ; Register retten
                lea     actsec(PC),A5   ; Adresse von actsec
                clr.w   (A5)            ; lîschen
                bsr     fmt             ; Track formatieren
                tst.w   D0              ; Fehler passiert?
                bne.s   keinvf          ; ja, weiter

                tst.w   quickflag       ; Quick-Formatierung?
                bne.s   keinvf          ; ja, dann kein Verify

                tst.w   vfflag          ; Verify?
                beq.s   keinvf          ; nein, nix da
                bsr     machvf          ; ja, in die Verify-Routine
keinvf:
                movem.l (SP)+,D1-D7/A2-A6 ; Register holen und
                rts

**************************
* extraquick: Superschnelle Formatierroutine
* fÅr doppelseitige Disketten
**************************
extraquick:
                movem.l D1-D7/A2-A6,-(SP) ; Register retten

                lea     trk(PC),A0      ; Adresse des aktuellen Tracks
                move.w  D4,(A0)+        ; aktuellen Track ablegen
                move.l  A6,(A0)+        ; Adresse des Puffers
                move.w  D5,(A0)         ; Seite in sd ablegen

                move.w  laufwerk(PC),D0 ; aktuelles Laufwerk
                addq.w  #1,D0           ; plus eins
                add.w   D0,D0           ; mal 2
                bsr     do_select       ; Vorderseite des aktuellen Laufwerks

                bsr.s   extrafmt        ; Track formatieren
                movem.l (SP)+,D1-D7/A2-A6 ; Register holen

                tst.w   D0              ; Fehler passiert?
                beq     xfmt            ; nein
                or.w    #$0100,D0       ; Fehler kommt aus fmt
                rts                     ; und raus

**************************
* extrafmt: Track superquick formatieren
**************************
extrafmt:
                lea     secno(PC),A6    ; Adresse der Sektornummerntabelle
                moveq   #0,D0           ; d0 lîschen
                move.w  offset(PC),D0   ; aktuellen Offset holen
                adda.w  D0,A6           ; auf Tabellenanfang addieren

                lea     sectable(PC),A5 ; Adresse der Sektortabelle
                move.w  trk(PC),D1      ; aktuelle Tracknr. nach d1

eadjust:
                movea.l (A5)+,A0        ; Erste Adresse holen
                cmpa.l  #0,A0           ; a0 testen
                beq.s   esid2           ; =0, alles erledigt
                move.b  D1,(A0)         ; aktuellen Track einsetzen
                move.b  (A6)+,2(A0)     ; Sektornummer in Track kopieren
                bra.s   eadjust

esid2:
                bsr     calcspir        ; Spiralisierung neu berechnen
                lea     sectable(PC),A5 ; Adresse der Sektortabelle
                lea     secno(PC),A6    ; Adresse der Sektornummern
                moveq   #0,D0           ; d0.l = 0
                move.w  offset(PC),D0   ; Offset in der Sektornr.tabelle
                adda.l  D0,A6           ; plus Basisadresse

eadj2:
                movea.l (A5)+,A0        ; Adresse holen
                cmpa.l  #0,A0           ; gleich 0?
                beq.s   erananspeck     ; jawohl, es kann losgehen
                move.b  D1,280(A0)      ; Tracknr anpassen
                move.b  (A6)+,280+2(A0) ; Sektornr anpassen
                bra.s   eadj2

erananspeck:
                lea     addhd(PC),A0    ; Adresse von addhd
                tst.w   (A0)            ; zusÑtzlicher Sektorvorspann?
                beq.s   enoadd          ; nein
                movea.l nachspann(PC),A3 ; Adresse des Nachspanns
                move.b  D1,(A3)         ; Tracknummer schreiben
                move.b  D1,280(A3)      ; auch in RÅckseite

enoadd:
                move.l  bf(PC),D7       ; Start des Puffers
                movea.l D7,A4           ; nach a4 retten
                lea     160(A4),A4      ; plus 160

* a4 enthÑlt jeweils die nÑchste Umschaltadresse
                bsr     dma             ; d7 als DMA-Startadresse

                lea     aktsd(PC),A2    ; aktuelle Seite
                clr.w   (A2)            ; ist Vorderseite

                move.w  #$0190,dmodus.w ; DMA-Status sÑubern
                move.w  #$90,dmodus.w
                move.w  #$0190,dmodus.w ; Sektorregister des DMA-Chips
                moveq   #31,D7          ; maximal 31 Sektoren
                bsr     wrfdc           ; d7 an Controller schicken

                move    SR,-(SP)        ; Prozessorstatus retten
                ori     #$0700,SR       ; Interrupts aus

                move.w  #$0180,dmodus.w ; Kommandoregister zum Schreiben
                moveq   #$F0+8,D7       ; format_track-Befehl
                bsr     wrfdc

                move.l  #30000,D4       ; ZÑhler

wtirq:
                btst    #5,mfp.w        ; IRQ da?
                beq.s   daswars         ; ja, Schluû
                bsr     getdma          ; DMA-Adresse nach d2
                cmp.l   A4,D2           ; mit Umschaltadresse vergleichen
                bls.s   chkend          ; kleiner, dann warten
                bsr.s   switchit        ; umschalten
chkend:
                cmp.l   dmaend(PC),D2   ; DMA-Ende erreicht?
                bge.s   daswars         ; ja, raus hier
                dbra    D4,wtirq        ; weiter warten

daswars:
                lea     aktsd(PC),A2
                clr.w   (A2)            ; auf Vorderseite umschalten
                move    (SP)+,SR        ; Prozessorstatus holen

                bsr     rdfdc           ; Status nach d0 holen
                and.w   #64+4,D0        ; WPRT+LOSTDATA ausmaskieren
                bsr     irq             ; FDC abwÅrgen
                clr.w   quick           ; Quick-Flag lîschen
                tst.w   D0              ; Fehler passiert?
                beq     dmastatus       ; nein, weiter
                rts                     ; Fehler passiert, mit Fehler raus

switchit:
                movem.l D0-D2/A2,-(SP)  ; Register retten
                lea     aktsd(PC),A2    ; Adresse von aktsd
                eori.w  #1,(A2)         ; aktuelle Seite invertieren
                move.w  (A2),D0         ; und holen

                lea     300(A4),A4      ; Umschaltadresse erhîhen

                move.w  laufwerk(PC),D0 ; Laufwerksnummer
                addq.w  #1,D0           ; plus 1
                add.w   D0,D0           ; mal 2
                add.w   aktsd(PC),D0    ; plus aktuelle Seite
                eori.w  #7,D0           ; fÅr Hardware
                and.w   #7,D0           ; invertieren

                move.b  #14,snd.w       ; Port A selektieren
                move.b  snd.w,D1        ; Wert aus Port A holen
                move.b  #$27,sndwrt.w   ; alles deselektieren

                move.l  #2000,D2        ; ZÑhler
shortwt:
                dbra    D2,shortwt      ; kurze Verzîgerung
                and.b   #$F8,D1         ; untere drei Bits wegmaskieren
                or.b    D0,D1           ; alter Wert or neue Selektion
                move.b  D1,sndwrt.w     ; in Port A schreiben

                movem.l (SP)+,D0-D2/A2  ; Register holen
                rts                     ; raus

**************************
* fmt: Eigene Formatierroutine
**************************
fmt:
                lea     trk(PC),A0      ; Adresse des aktuellen Tracks
                move.w  D4,(A0)+        ; aktuellen Track ablegen
                move.l  A6,(A0)+        ; Adresse des Puffers ablegen (in bf)
                move.w  D5,(A0)         ; Seite in sd ablegen

                move.w  laufwerk(PC),D0 ; aktuelles Laufwerk
                addq.w  #1,D0           ; +1 (=1 fÅr A, =2 fÅr B)
                add.w   D0,D0           ; mal 2 (=2 fÅr A, =4 fÅr B)
                add.b   D5,D0           ; Seite addieren
                bsr     do_select       ; Seite und Laufwerk selektieren

                bsr.s   machhin         ; Track formatieren
                tst.w   D0              ; Fehlerflag testen
                beq.s   xfmt            ; kein Fehler passiert

                or.w    #$0100,D0       ; Fehler kommt aus fmt
xfmt:
                rts                     ; und raus

***********************
* machhin: Erledigt die Dreckarbeit
***********************
machhin:
                lea     secno(PC),A6    ; Adresse der Sektornummerntabelle
                moveq   #0,D0           ; d0 lîschen
                move.w  offset(PC),D0   ; aktuellen Offset holen
                adda.w  D0,A6           ; auf Tabellenanfang addieren

                lea     sectable(PC),A5 ; Adresse der Sektortabelle
                move.w  trk(PC),D1      ; aktuelle Tracknr. nach d1
                move.w  sd(PC),D0       ; aktuelle Seite nach d0

adjust:
                movea.l (A5)+,A0        ; Erste Adresse holen
                cmpa.l  #0,A0           ; a0 testen
                beq.s   rananspeck      ; =0, alles erledigt
                move.b  D1,(A0)+        ; aktuellen Track einsetzen
                move.b  D0,(A0)+        ; aktuelle Seite einsetzen
                move.b  (A6)+,(A0)+     ; Sektornummer in Track kopieren
                bra.s   adjust

rananspeck:
                lea     addhd(PC),A0    ; Adresse von addhd
                tst.w   (A0)            ; zusÑtzlicher Sektorvorspann?
                beq.s   noadd           ; nein
                movea.l nachspann(PC),A3 ; Adresse des Nachspanns
                move.b  D1,(A3)         ; Tracknummer schreiben
                move.b  D0,1(A3)        ; Seitennummer schreiben
noadd:
                move.w  quickflag(PC),quick ; Quickflag setzen oder lîschen

                move.l  bf(PC),D7       ; Start des Puffers
                bsr     dma             ; als DMA-Startadresse

                move.w  #$0190,dmodus.w ; DMA-Status sÑubern
                move.w  #$90,dmodus.w
                move.w  #$0190,dmodus.w ; Sektorregister des DMA-Chips
                moveq   #31,D7          ; maximal 31 Sektoren
                bsr     wrfdc           ; d7 an Controller schicken

                move.w  #$0180,dmodus.w ; Kommandoregister zum Schreiben
                moveq   #$F0,D7         ; format_track-Befehl
                add.w   settling(PC),D7 ; Settling-Zeit
                bsr     wrfdc

                move.w  trk(PC),D4      ; Tracknummer holen
                bsr     prntrk          ; und ausgeben

                moveq   #64+4,D7        ; Fehlermaske (WPRT+LOSTDATA)
                bsr     warten_auf_godot ; Auf Ende des Kommandos warten
                tst.w   D0              ; Fehler passiert?
                beq.s   dmastatus       ; nein, weiter

kaputt:
                rts                     ; Fehler passiert (d0=Fehlernr.)

dmastatus:
                bsr     status          ; DMA-Status nach d0 holen
                btst    #0,D0           ; Fehler?
                beq.s   kaputt          ; ja, Fehler
                clr.w   D0              ; Fehlerflag lîschen
                rts

**************************
* mktrack: Prototyp eines Tracks erstellen
* OUT: d0 0:   alles klar
*         <>0: Fehler
**************************
mktrack:
                movem.l D1-A6,-(SP)     ; Register retten

                move.l  A6,bf           ; Pufferadresse sichern

                move.w  quickflag(PC),D0 ; Quickflag holen
                cmp.w   #2,D0           ; =2 (Super-Quick)?
                beq     extramake       ; ja, besondere Prototyproutine

                lea     ngaps(PC),A4    ; Zeiger auf Gap-Tabellen
                move.w  spt(PC),D1      ; Anzahl der Sektoren holen
                sub.w   #9,D1           ; minus 9
                bpl.s   mk2             ; weniger als 9 Sektoren?
                clr.w   D1              ; d1=0
mk2:
                mulu    #10,D1          ; mal 10
                adda.l  D1,A4           ; plus Tabellenstart
                move.w  quickflag(PC),D0 ; Quickflag holen
                mulu    #5,D0           ; mal 5
                adda.w  D0,A4           ; plus Tabellenstart

                move.l  #$1100,D0       ; Default: Fehler
                tst.w   density         ; HYPER DENSITY?
                bne.s   mk1             ; ja, weiter
                cmpi.w  #12,spt         ; mehr als 11 Sektoren?
                bcs.s   proto           ; nein, weiter
                bra     mkexit          ; mit Fehler zurÅck

mk1:
                tst.w   quickflag       ; Quick?
                beq.s   proto           ; nein, weiter
                cmpi.w  #10,spt         ; 10 Sektoren?
                bne.s   proto           ; nein, weiter
                subq.w  #5,A4           ; normale LÅckengrîûe, bitte
                cmpi.w  #11,spt         ; 11 Sektoren?
                bne.s   proto           ; nein, weiter
                lea     -20(A4),A4      ; LÅcken wie bei 9-Sektor-Format

***********************
* proto: Erstellt einen Track und die Sektortabelle
* IN: a4 Zeiger auf Gap-Tabelle
***********************
proto:
                clr.w   D5              ; SektorzÑhler
                lea     secno(PC),A6    ; Adresse der Sektornummerntabelle

                lea     sectable(PC),A5 ; Adresse der Sektortabelle
                moveq   #1,D3           ; mit Sektor 1 anfangen
                movea.l bf(PC),A2       ; Adresse des Puffers

                move.b  (A4),D1         ; Gap1 (Post Index Mark)
                moveq   #$4E,D0         ; LÅckenbytes
                bsr     wbmult          ; in Puffer schreiben
nsect2:
                move.w  D3,D4           ; Sektornummer retten

nsect:
                move.b  1(A4),D1        ; Gap2 (Pre Address Mark)
                clr.b   D0              ; Nullbytes
                bsr     wbmult          ; in Puffer schreiben
                moveq   #2,D1           ; 3 Syncbytes (nicht Ñndern!)
                moveq   #$F5,D0         ; $F5 schreiben (wird zu Sync $A1)
                bsr     wmult

                addq.w  #1,D5           ; ein Sektor mehr
                move.b  #$FE,(A2)+      ; $FE, Adreûmarke schreiben
                move.l  A2,(A5)+        ; aktuelle Adresse in Tabelle
                clr.b   (A2)+           ; Tracknummer (Default 0)
                clr.b   (A2)+           ; Seite       (Default 0)
                move.b  D4,(A2)+        ; Sektor
                move.b  D4,(A6)+        ; Sektornr in Sektornummerntabelle
                move.b  #2,(A2)+        ; Grîûenbyte (2 -> 512 Bytes)
                move.b  #$F7,(A2)+      ; Checksumme schreiben lassen

                move.b  2(A4),D1        ; Gap3 (Post Address Mark 1)
                moveq   #$4E,D0         ; $4E schreiben
                bsr     wbmult
                move.b  3(A4),D1        ; Gap3 (Post Address Mark 2), mit
                clr.b   D0              ; PAM1 zusammen mind. 34 Bytes
                bsr     wbmult
                moveq   #2,D1           ; 3 Syncbytes (nicht Ñndern!)
                moveq   #$F5,D0         ; $F5 schreiben (wird zu Sync $A1)
                bsr     wmult
                move.b  #$FB,(A2)+      ; $FB, Datenblockmarke

                move.w  #$FF,D1         ; 256 Worte
wrvirgin:
                move.b  #virgin1,(A2)+  ; Virgin data, highbyte
                move.b  #virgin2,(A2)+  ; Virgin data, lowbyte
                dbra    D1,wrvirgin     ; 256mal

                move.b  #$F7,(A2)+      ; Checksumme schreiben lassen
                move.w  spt(PC),D0      ; Sektoren pro Spur
*    cmp.w   d5,d0           ; schon alle Sektoren geschrieben?
*    beq.s   nogap4          ; ja

                move.b  4(A4),D1        ; Gap4 (Post Data Mark)

                cmp.w   #13,D0          ; 13 Sektoren      ?????????
                bmi.s   dontcut

                sub.w   addhd(PC),D1    ; evt. minus eins
dontcut:
                moveq   #$4E,D0         ; LÅckenbytes
                bsr     wbmult          ; in Puffer schreiben

                add.w   ileave(PC),D4   ; Interleave draufzÑhlen
                cmp.w   spt(PC),D4      ; mit grîûter Sektornummer
                ble.s   nsect           ; vergleichen

                addq.w  #1,D3           ; Startsektor plus eins
                cmp.w   ileave(PC),D3   ; mit Interleavefaktor vergleichen
                ble     nsect2          ; kleiner, dann weiter

nogap4:
                moveq   #2,D1           ; 3 Nullbytes
                clr.b   D0              ; $00
                bsr     wmult           ; schreiben

                move.w  addhd(PC),D0    ; ZusÑtzlicher Header?
                beq.s   nofasthd        ; nein

                ext.l   D5
                move.w  headerpos(PC),D1 ; Offset fÅr zusÑtzlichen Vorspann
                ext.l   D1
                add.l   bf(PC),D1       ; + Pufferstart
                sub.l   A2,D1           ; minus aktuelle Adresse
                sub.l   D5,D1
                sub.l   D5,D1           ; CRC-Bytes abziehen
                subq.l  #3,D1           ; kein Platz, wenn negativ
                bmi.s   addsofort

                moveq   #0,D0           ; Nullbytes schreiben
                bsr.s   wmult

addsofort:
                moveq   #2,D1           ; 3 Syncs
                moveq   #$F5,D0         ; $F5 (wird zu Sync $A1)
                bsr.s   wmult           ; schreiben
                move.b  #$FE,(A2)+      ; Adreûmarke schreiben

                move.l  A2,nachspann    ; aktuelle Adresse des Nachspanns ablegen

                clr.b   (A2)+           ; Tracknummer (Default 0)
                clr.b   (A2)+           ; Seitennummer (Default 0)
                move.b  #$CB,(A2)+      ; Sektornummer
                move.b  #2,(A2)+        ; Grîûe
                move.b  #$F7,(A2)+      ; Checksumme schreiben lassen

nofasthd:
                move.w  D5,realspt      ; Anzahl der wirklich erzeugten Sektoren merken

                lea     secno(PC),A3    ; Adresse der Sektornummerntabelle
                subq.w  #1,D5           ; Sektoranzahl minus eins fÅr dbf
copysec:
                move.b  (A3)+,(A6)+     ; Sektorentabelle verdoppeln
                dbra    D5,copysec      ; fÅr Spiralisierung

                lea     dmaend(PC),A3   ; Adresse der DMA-Endadresse
                lea     32(A2),A0       ; 32 Bytes addieren (DMA-Puffer)
                move.l  A0,(A3)         ; DMA-Endadresse fÅr Quickfmt ablegen
                clr.l   (A5)+           ; Ende der Sektortabelle markieren

                move.l  #bpt10+50,D1    ; Bytes pro Track + 50 (10 MHz)
                tst.w   density         ; HYPER DENSITY?
                bne.s   adjgap5         ; ja, weiter
                move.l  #bpt8+50,D1     ; Bytes pro Track + 50
adjgap5:
                sub.l   A2,D1           ; minus geschriebene Bytes
                add.l   bf(PC),D1       ; plus Pufferstart
                bmi.s   mkexit2         ; negativ?
                moveq   #$FC,D0         ; LÅckenbytes schreiben
                bsr.s   wmult
mkexit2:
                moveq   #0,D0           ; kein Fehler
mkexit:
                movem.l (SP)+,D1-A6     ; Register holen
                rts                     ; und raus

***************************
* wmult: Schreibt Byte in d0 (d1+1)mal in den Puffer ab a2
***************************
wbmult:
                and.w   #$FF,D1         ; oberes Byte von d1.w lîschen
wmult:                                  ; Bytes in Puffer schreiben
                move.b  D0,(A2)+
                dbra    D1,wmult
                clr.w   D1              ; d1.w lîschen
                rts

***************************
* extramake: Erstelle Track fÅr Super-Quick-Format
* IN: a6,bf(pc)     Zeiger auf Trackpuffer
***************************
extramake:
                clr.w   D5              ; SektorzÑhler
                lea     secno(PC),A6    ; Adresse der Sektornummerntabelle
                lea     sectable(PC),A5 ; Adresse der Sektortabelle
                moveq   #1,D3           ; mit Sektor 1 anfangen
                movea.l bf(PC),A2       ; Adresse des Puffers

ensect2:
                move.w  D3,D4           ; Sektornummer retten

ensect:
                moveq   #10,D1          ; 11 LÅckenbytes
                clr.b   D0              ; Nullbytes
                bsr.s   wmult           ; in Puffer schreiben
                moveq   #2,D1           ; 3 Syncbytes (nicht Ñndern!)
                moveq   #$F5,D0         ; $F5 schreiben (wird zu Sync $A1)
                bsr.s   wmult

                addq.w  #1,D5           ; ein Sektor mehr
                move.b  #$FE,(A2)+      ; $FE, Adreûmarke schreiben
                move.l  A2,(A5)+        ; aktuelle Adresse in Tabelle
                clr.b   (A2)+           ; Tracknummer (Default 0)
                clr.b   (A2)+           ; Seite       (Default 0)
                move.b  D4,(A2)+        ; Sektor
                move.b  D4,(A6)+        ; Sektornr in Sektornummerntabelle
                move.b  #2,(A2)+        ; Grîûenbyte (2 -> 512 Bytes)
                move.b  #$F7,(A2)+      ; Checksumme schreiben lassen

                moveq   #33,D1          ; 34 LÅckenbytes
                clr.b   D0
                bsr.s   wmult           ; in Puffer schreiben
                moveq   #2,D1           ; 3 Syncbytes
                moveq   #$F5,D0
                bsr.s   wmult
                move.b  #$FB,(A2)+      ; Datenmarke
                moveq   #232,D1         ; 233 Sektorbytes
                moveq   #virgin1,D0     ; Virgin
                bsr.s   wbmult          ; in Puffer schreiben
                moveq   #2,D1
                moveq   #$F5,D0         ; Syncbytes schreiben
                bsr.s   wmult
                move.b  #$FE,(A2)+      ; Adreûmarke
                clr.b   (A2)+           ; Tracknummer, Default 0
                move.b  #1,(A2)+        ; Seitennummer
                move.b  D4,(A2)+        ; Sektornummer
                move.b  #2,(A2)+        ; Grîûenbyte
                move.b  #$F7,(A2)+      ; PrÅfsumme

                moveq   #33,D1          ; 34 LÅckenbytes
                clr.b   D0
                bsr.s   wmult           ; in Puffer schreiben
                moveq   #2,D1           ; 3 Syncbytes
                moveq   #$F5,D0
                bsr.s   wmult
                move.b  #$FB,(A2)+      ; Datenmarke
                moveq   #232,D1         ; 233 Sektorbytes
                moveq   #virgin1,D0     ; Virgin
                bsr     wbmult          ; in Puffer schreiben

                moveq   #30,D1          ; 31 LÅckenbytes
                clr.b   D0
                bsr     wmult           ; kurze LÅcke zwischen Sektoren

                add.w   ileave(PC),D4   ; Interleave draufzÑhlen
                cmp.w   spt(PC),D4      ; mit grîûter Sektornummer
                ble.s   ensect          ; vergleichen

                addq.w  #1,D3           ; Startsektor plus eins
                cmp.w   ileave(PC),D3   ; mit Interleavefaktor vergleichen
                ble     ensect2         ; kleiner, dann weiter

                move.w  addhd(PC),D0    ; ZusÑtzlicher Header?
                beq.s   enofasthd       ; nein

                moveq   #30,D1          ; 31 LÅckenbytes
                clr.b   D0              ; Nullbytes schreiben
                bsr     wmult

                moveq   #2,D1           ; 3 Syncs
                moveq   #$F5,D0         ; $F5 (wird zu Sync $A1)
                bsr     wmult           ; schreiben
                move.b  #$FE,(A2)+      ; Adreûmarke schreiben

                move.l  A2,nachspann    ; aktuelle Adresse des Nachspanns ablegen

                clr.b   (A2)+           ; Tracknummer (Default 0)
                clr.b   (A2)+           ; Seitennummer (Default 0)
                move.b  #$CB,(A2)+      ; Sektornummer
                move.b  #2,(A2)+        ; Grîûe
                move.b  #$F7,(A2)+      ; Checksumme schreiben lassen

                move.w  #270,D1         ; 271 LÅckenbytes
                clr.b   D0              ; (Nullbytes)
                bsr     wmult           ; in Puffer schreiben
                moveq   #2,D1
                moveq   #$F5,D0
                bsr     wmult           ; Syncs schreiben
                move.b  #$FE,(A2)+      ; Adreûmarke
                clr.b   (A2)+           ; Tracknummer
                move.b  #1,(A2)+        ; Seitennummer
                move.b  #$CB,(A2)+      ; Sektornummer
                move.b  #2,(A2)+        ; Grîûe
                move.b  #$F7,(A2)+      ; PrÅfsumme

enofasthd:
                move.w  D5,realspt      ; Anzahl der wirklich erzeugten Sektoren

                lea     secno(PC),A3    ; Adresse der Sektornummerntabelle
                subq.w  #1,D5           ; Sektoranzahl minus eins fÅr dbf
ecopysec:
                move.b  (A3)+,(A6)+     ; Sektorentabelle verdoppeln
                dbra    D5,ecopysec     ; fÅr Spiralisierung

                lea     dmaend(PC),A3   ; Adresse der DMA-Endadresse
                lea     32(A2),A0       ; 32 Bytes addieren (DMA-Puffer)
                move.l  A0,(A3)         ; DMA-Endadresse fÅr Quickfmt ablegen
                clr.l   (A5)+           ; Ende der Sektortabelle markieren

                moveq   #100,D1         ; LÅckenbytes am Trackende
                moveq   #$4E,D0         ; schreiben
                bsr     wmult

                movem.l (SP)+,D1-A6     ; Register holen
                moveq   #0,D0           ; kein Fehler
                rts                     ; und raus

***************************
* mkbytstr: d4.b in String wandeln
***************************
mkbytstr:
                moveq   #100,D1         ; 3 Dezimalziffern
                bra.s   w0

**************************
* d4 to decimal string
* IN: Stringadresse in a6
**************************
d4todec:
                moveq   #10,D1          ; 2 Dezimalziffern
w0:
                movem.l D0-D4/A6,-(SP)  ; Register retten
                move.b  #(' '-'0'),D2
                move.w  D4,D3           ; Zahl merken
w1:
                ext.l   D3
                cmp.w   #1,D1           ; schon letzte Ziffer?
                bne.s   w2              ; nein
                clr.w   D2              ; kein Space erlaubt
w2:
                divu    D1,D3           ; Rest durch Teiler
                beq.s   dezpr1          ; war schon 0
                clr.w   D2              ; kein Space erlaubt
dezpr1:
                bsr.s   deznum          ; Ziffer ausgeben
                swap    D3              ; Rest der Division
                divu    #10,D1          ; nÑchster Teiler
                bne.s   w1              ; Ergebnis ungleich 0?
                movem.l (SP)+,D0-D4/A6
                rts

deznum:
                tst.w   D2              ; mit Space?
                beq.s   deznum1         ; nein
                add.b   D2,D3           ; Offset zu Space addieren
deznum1:
                add.b   #'0',D3
                move.b  D3,(A6)+
                rts

**************************
* d4 to hexadecimal string
* IN: Stringadresse in a6
*     Anzahl der zu wandelnden Nibbles-1 in d1
**************************
d4tohex:
                movem.l D1-D2/D4,-(SP)  ; Register retten
nextbyte:
                move.l  D4,D2           ; d4 nach d2
                asr.l   #4,D4           ; 1 Nibble weiter
                and.l   #$0F,D2         ; unterstes Nibble ausmaskieren
                cmp.b   #9,D2           ; Zahl oder Buchstabe?
                bls.s   numeric         ; Zahl, dann weiter
                addq.b  #7,D2           ; Buchstabe, plus 7
numeric:
                add.b   #'0',D2         ; in ASCII wandeln
                move.b  D2,0(A6,D1.w)   ; in String kopieren
                dbra    D1,nextbyte     ; nÑchstes Byte

                movem.l (SP)+,D1-D2/D4  ; Register holen
                rts                     ; raus

**************************
* writeboot: Bootsektor etc. schreiben
**************************
writeboot:
                bsr     mkmedia         ; Mediabyte richtigstellen
                lea     bootsector(PC),A5 ; Bootsektor-Adresse
                move.l  #$EB349049,(A5) ; DOS-Kennung schreiben
                move.l  #'BM  ',4(A5)   ; nur der VollstÑndigkeit halber

                move.w  executable(PC),D0 ; AusfÅhrbarkeitsflag holen
                beq.s   wrboot          ; gleich 0, dann schreiben

                move.l  #$60384C6F,(A5) ; TOS-Kennung schreiben
                move.l  #'ader',4(A5)

wrboot:
                move.w  secsperfat(PC),D0 ; Anzahl der FAT-Sektoren holen
                move.b  D0,spf          ; FAT-Sektoranzahl schreiben
                move.w  spc(PC),D0      ; Sektoren pro Cluster holen
                move.b  D0,bspc         ; Spc schreiben

                lea     bootsector(PC),A5 ; Adresse des Bootsektors
                move.w  executable(PC),-(SP) ; AusfÅhrbarkeitsflag
                move.w  #-1,-(SP)       ; Disktyp nicht Ñndern
                move.l  #$11000000,-(SP) ; Seriennummer zufÑllig erzeugen
                move.l  A5,-(SP)        ; Adresse des Puffers Åbergeben
                move.w  #18,-(SP)       ; PROTOBT
                trap    #14             ; im XBIOS
                lea     14(SP),SP       ; Stack sÑubern

                lea     bootsector(PC),A5 ; Adresse des Bootsektors
                clr.w   D6              ; logischer Sektor 0
                bsr.s   wrlogsec        ; schreiben
                tst.w   D0              ; Fehler passiert?
                bne.s   berr            ; ja, durchreichen

                moveq   #1,D6           ; ab logischem Sektor 1
abfatsec1:
                movea.l fatstart(PC),A5 ; Adresse des ersten FAT-Sektors
cnochmal:
                bsr.s   wrlogsec        ; logischen Sektor schreiben
                tst.w   D0              ; Fehler passiert?
                bne.s   berr            ; ja, durchreichen
                lea     512(A5),A5      ; nÑchster FAT-Sektor
                addq.l  #1,D6           ; nÑchster Sektor
                move.w  secsperfat(PC),D0 ; Sektoren pro FAT holen
                addq.w  #1,D0           ; plus 1
                cmp.l   D0,D6           ; schon erster Sektor der zweiten FAT?
                beq.s   abfatsec1       ; 2.FAT schreiben
                add.w   secsperfat(PC),D0 ; d0 plus secsperfat
                cmp.l   D0,D6           ; schon 2. FAT fertig?
                bne.s   cnochmal        ; nein, 2. FAT schreiben

                clr.w   D3              ; ZÑhler lîschen
                move.b  entries(PC),D3  ; Anzahl der Dir-EintrÑge holen
                lsr.w   #4,D3           ; durch 16 = Anzahl der Dir-Sektoren
                subq.w  #1,D3           ; minus eins fÅr dbf
                lea     cleansector(PC),A5 ; Adresse des cleansectors
nochndir:
                bsr.s   wrlogsec        ; logischen Sektor schreiben
                tst.w   D0              ; Fehler?
                bne.s   berr            ; ja

                addq.w  #1,D6           ; nÑchster logischer Sektor
                dbra    D3,nochndir     ; nÑchster Dir-Sektor
                rts                     ; raus (d0.w=0)

berr:
                and.w   #$FF,D0         ; Highbyte lîschen
                rts                     ; -> 00 fÅr Fehler in writeboot

*******************
* writesector: Einen physikalischen Sektor schreiben
* Seite in d4, Track in d5, Sektor in d6, Pufferadresse in a5
*******************
writesector:
                move.w  D6,actsec       ; aktuellen Sektor ablegen
                move.w  D4,sd           ; aktuelle Seite ablegen
                move.w  D5,trk          ; aktuelle Spur ablegen
                move.w  #1,-(SP)        ; Count
                move.w  D4,-(SP)        ; Seite
                move.w  D5,-(SP)        ; Track
                move.w  D6,-(SP)        ; Sektor
                move.w  laufwerk(PC),-(SP) ; Laufwerk
                clr.l   -(SP)           ; FÅllsel
                move.l  A5,-(SP)        ; Pufferadresse
                move.w  #9,-(SP)        ; FLOPWR
                trap    #14             ; Xbios
                lea     20(SP),SP       ; Stack sÑubern
                rts

********************
* wrlogsec: Einen logischen Sektor schreiben
* logische Sektornummer in d6, Pufferadresse in a5
********************
wrlogsec:
                move.l  D6,-(SP)        ; logische Sektornummer retten
                clr.w   D0              ; d0 lîschen
                move.b  side(PC),D0     ; Seitenzahl holen
                mulu    spt(PC),D0      ; mal Sektorenzahl
                divs    D0,D6           ; logische Sektornr / dspt
                move.w  D6,D5           ; Tracknummer
                swap    D6              ; Rest der Division
                moveq   #0,D4           ; Vorderseite
                cmp.w   spt(PC),D6      ; >= Sektorenzahl?
                blt.s   sideok          ; nein, Seite stimmt schon
                moveq   #1,D4           ; RÅckseite
                sub.w   spt(PC),D6      ; Sektorenanzahl abziehen
sideok:
                addq.w  #1,D6           ; plus eins
                bsr.s   writesector     ; Sektor schreiben
                move.l  (SP)+,D6        ; d6 zurÅckholen
                rts


********************
* inputname: Holt Diskettennamen
********************
inputname:
                lea     z1(PC),A5       ; unteren Schirm sÑubern
                bsr.s   printmsg

                lea     namemsg(PC),A5  ; Message
                bsr.s   printmsg        ; ausgeben
                lea     namebuf+2(PC),A5 ; Puffer fÅr Eingabe
                st      keyflag-namebuf(A5) ; nur definierte Tasten erlaubt
                move.b  #14,(A5)        ; maximale LÑnge
                move.l  A5,-(SP)        ; auf Stack
                bsr.s   leerebuf        ; Puffer leeren

                move.w  #10,-(SP)       ; Read Line
                trap    #1              ; GEMDOS
                addq.l  #6,SP           ; Stack sÑubern
                sf      keyflag-namebuf(A5) ; Keyflag lîschen
                rts

********************
* writename: Diskettennamen schreiben
********************
writename:
                moveq   #0,D0
                move.b  s_drv(PC),D0    ; Laufwerkszeichen
                lea     namebuf+1(PC),A5 ; Pfadadresse
                move.b  D0,(A5)         ; Laufwerk einkopieren
                move.b  2(A5),D0        ; LÑnge des Namens merken
                move.w  #':\',1(A5)     ; A:\name
                clr.b   3(A5,D0.w)      ; mit 0 abschlieûen

                DC.W $A009      ; Maus kurzzeitig wieder an
                move.w  #8,-(SP)        ; Volume Label erzeugen
                move.l  A5,-(SP)        ; Pfadadresse auf Stack
                move.w  #60,-(SP)       ; Fcreate
                trap    #1              ; GEMDOS
                addq.l  #8,SP           ; Stack sÑubern
                tst.w   D0              ; Fehler?
                bmi.s   nameerr         ; ja
                move.w  D0,-(SP)        ; Handle auf Stack
                move.w  #62,-(SP)       ; Fclose
                trap    #1              ; GEMDOS
                addq.l  #4,SP           ; Stack sÑubern
nameerr:
                move.w  D0,-(SP)
                DC.W $A00A      ; Maus wieder aus
                move.w  (SP)+,D0
                rts

********************
* printmsg: String ausgeben
* Adresse in a5
********************
printmsg:
                move.l  A5,-(SP)        ; Message ausgeben
                move.w  #9,-(SP)        ; PRINTLINE
                trap    #1              ; im GEMDOS
                addq.l  #6,SP           ; Stack sÑubern
                rts

***********************
* waitforkey: 'Taste drÅcken' ausgeben
* und auf Taste warten
***********************
waitforkey:
                lea     keymsg(PC),A5   ; 'Taste drÅcken'
                bsr.s   printmsg        ; ausgeben

getkey:
                bsr.s   leerebuf        ; Einsprungpunkt ohne Message
bufempty:
                move.w  #7,-(SP)        ; Auf Taste warten
                trap    #1              ; GEMDOS Conin without echo
                addq.l  #2,SP
                cmp.b   #64,D0          ; kleiner gleich A?
                bls.s   gewandelt
                cmp.b   #91,D0          ; grîûer gleich Z?
                bge.s   gewandelt
                add.b   #32,D0          ; in Kleinbuchstaben wandeln
gewandelt:
                rts

************************
* leerebuf: Tastaturpuffer leeren
************************
leerebuf:
                move.w  #11,-(SP)       ; CONSTAT
                trap    #1              ; GEMDOS
                addq.l  #2,SP           ; Stapel sÑubern
                tst.w   D0              ; Zeichen im Puffer?
                beq.s   gewandelt       ; nein, leer -> raus
                move.w  #7,-(SP)        ; Taste holen
                trap    #1              ; CONIN without echo
                addq.l  #2,SP           ; Stack sÑubern
                bra.s   leerebuf        ; jetzt Puffer leer?

************************
* Error-Routine (IN: Fehlernummer in d0)
* Gibt Fehler aus und verabschiedet sich
************************
error:
                cmp.w   #$1100,D0       ; kein HYPER-Density?
                bne.s   error1
                lea     nicht10(PC),A5  ; -> falscher Takt
                bsr.s   printmsg
                bra.s   nosend
error1:
                bsr     senderror       ; Errormsg ausgeben
nosend:
                bsr.s   waitforkey      ; auf Taste warten
                bra     main0           ; und raus

***************************
* parameters: Gibt Menue aus
* und erlaubt énderungen
***************************
parameters:
                bsr     gethd           ; Soundchip auslesen
                move    pstatus(PC),SR
                move.b  #' ',haken
                btst    #6,D0           ; Bit 6 gesetzt?
                beq.s   para2
                move.b  #'+',haken
para2:
                bsr     mkmedia         ; Mediabyte ausrechnen

                lea     msg_parms(PC),A5
                bsr     printmsg        ; MenÅ ausgeben

                bsr.s   getkey          ; Auf Taste warten

                lea     keys(PC),A4     ; Adresse der Tastentabelle
                lea     options(PC),A6  ; Sprungdistanzen
                tst.b   D0              ; normale Taste/Sondertaste?
                bne.s   normkey         ; normale Taste
                swap    D0              ; Scancode in unteres Wort
                lea     fkeys(PC),A4    ; Sondertastentabelle
                lea     foptions(PC),A6 ; Sprungdistanzen

normkey:
                movea.l A4,A5           ; Start der Tasten nach a5
keyloop:
                move.b  (A4)+,D1        ; Tastencode aus Tabelle holen
                beq.s   parameters      ; Tabellenende? Dann zum Menue
                cmp.b   D0,D1           ; Mit gedrÅckter Taste vergleichen
                bne.s   keyloop         ; ungleich, weitersuchen

                subq.l  #1,A4           ; Offset -1
                suba.l  A5,A4           ; Offset berechnen (Ergebnis in a4)
                move.l  A4,D2           ; In Datenregister
                add.w   D2,D2           ; mal 2
                move.w  0(A6,D2.w),D2   ; Relative Startadresse
                lea     reserve(PC),A5  ; Start des Programms
                jmp     0(A5,D2.w)      ; Routine anspringen

****************************
* end_parms: Ausstieg per
* CR oder B
****************************
end_parms:
                move.w  D0,fmtflag      ; fmt oder boot? In fmtflag ablegen
mksecend:
                rts                     ; byebyte


*************************
* mkspir: Schreibt Spiralparameter
* IN: d4.b spt
*************************
mkspir:
                lea     s_spir(PC),A6   ; Stringadresse
                lea     spirfaktor(PC),A3 ; Variablenadresse
                move.w  D4,(A3)         ; Wert schreiben
                bra     mkbytstr        ; d4.b in String wandeln

***************************
* mksec: Schreibt Sektorparameter
* IN: d4.b spt
***************************
mksec:
                lea     b_spt(PC),A4    ; Adresse im Bootsektor
                lea     s_spt(PC),A6    ; Stringadresse
                lea     spt(PC),A3      ; Adresse der Variablen
                move.b  D4,(A4)         ; in Bootsektor schreiben
                move.w  D4,(A3)         ; In Variable schreiben
                bsr     mkbytstr        ; d4.b in String wandeln
                cmpi.w  #q10schwelle,(A3) ; mehr als Quickschwelle?
                blt.s   mksecend        ; nein, raus
                clr.w   D0              ; Quickparameter=0
                bra.s   mkquick         ; setzen

***************************
* mkside: Schreibt Seitenparameter
* IN: d4.b Seitenzahl
***************************
mkside:
                lea     s_sides(PC),A6  ; Stringadresse
                lea     side(PC),A3     ; Adresse im Bootsektor
                move.b  D4,(A3)         ; In Bootsektor schreiben
                bsr     mkbytstr        ; d4.b -> String
                cmp.b   #2,D4           ; 2 Seiten?
                beq.s   mksideend       ; ja, raus hier
                move.w  quickflag(PC),D0 ; Quickflag holen
                cmp.w   #2,D0           ; auf Super-Quick gestellt?
                bne.s   mksideend       ; nein, alles klar
                subq.w  #1,D0           ; doch, Super-Quick aus
                bsr.s   mkquick         ; Quick-Parameter schreiben
mksideend:
                rts

***************************
* mkspc: Schreibt spc-Parameter
* IN: d4 Sektoren pro Cluster (1 oder 2)
***************************
mkspc:
                lea     s_spc(PC),A6    ; Stringadresse
                lea     spc(PC),A3      ; Adresse der Variablen
                move.w  D4,(A3)         ; Variable schreiben
                bra     mkbytstr        ; String erstellen

***************************
* mktracks: Schreibt Trackparameter
* IN: d4 Endtrack
***************************
mktracks:
                lea     s_tracks(PC),A6 ; Stringadresse
                lea     endtrack(PC),A3 ; Adresse der Variablen
                move.w  D4,(A3)         ; In Variable schreiben
                bra     mkbytstr        ; d4.b -> String

***************************
* mkinter: Schreibt Interleaveparameter
* IN: d4
***************************
mkinter:
                lea     s_inter(PC),A6  ; Stringadresse
                lea     ileave(PC),A3   ; Interleave-Adresse
                move.w  D4,(A3)         ; Wert schreiben
                bra     mkbytstr        ; d4.b -> String

***************************
* mkquick: Quickparameter schreiben
* IN: d0
***************************
mkquick:
                clr.w   D1              ; d1.w = 0
                move.b  side(PC),D1     ; Seitenzahl
                cmp.w   #2,D1           ; Zwei Seiten?
                beq.s   do_mkquick      ; ja, Super-Quick erlaubt
                cmp.w   #2,D0           ; Super-Quick aktiviert?
                bne.s   do_mkquick      ; nein, ok
                subq.w  #1,D0           ; doch, dann minus eins
do_mkquick:
                lea     s_quick(PC),A6  ; Stringadresse
                lea     quickflag(PC),A3 ; Adresse der Variablen
                move.w  D0,D4           ; Wert nach d4
                beq.s   neinsetz
                move.w  D4,(A3)         ; Flag Ñndern
                bra     mkbytstr        ; String Ñndern
neinsetz:
                move.w  D4,(A3)
                move.b  #'0',2(A6)      ; 'n' schreiben
                rts

***************************
* mkdir: Directoryparameter setzen
* IN: d4
***************************
mkdir:
                lea     s_dir(PC),A6    ; Stringadresse
                lea     entries(PC),A3  ; Adresse der EintrÑge
                move.b  D4,(A3)         ; Wert schreiben
                bra     mkbytstr        ; d4.b -> String

***************************
* mkstep: Steprate setzen
* IN: d4
***************************
mkstep:
                lea     s_step(PC),A6   ; Stringadresse
                lea     steprate(PC),A3 ; Variablenadrese
                move.w  D4,(A3)
                add.w   D4,D4           ; mal 2 (Offset in Tabelle)
                lea     millis(PC),A3   ; -> Tabelle
                adda.w  D4,A3           ; + Offset
                move.b  (A3)+,(A6)+
                move.b  (A3),(A6)
                rts

***************************
* op_f1: Default auf F1
* einseitiges Normalformat
* 1 Seite, Interleave 11, 80 Tracks, 9 Sektoren
***************************
op_f1:
                moveq   #1,D4           ; 1 Seite
                bsr     mkside          ; Seitenparameter schreiben

std1:
                moveq   #9,D4           ; 9 Sektoren
                bsr     mksec           ; Sektorparameter schreiben
                moveq   #2,D4           ; 2 Sektoren pro Cluster
                bsr     mkspc
                moveq   #79,D4          ; bis Track 79
                bsr     mktracks        ; Tracks schreiben
                moveq   #11,D4          ; Interleave 11
                bsr.s   mkinter         ; Interleaveparameter schreiben
                moveq   #0,D4           ; Spiralfaktor 0
                bsr     mkspir
dir112:
                moveq   #112,D4         ; 112 VerzeichniseintrÑge
                bsr.s   mkdir
                moveq   #3,D4           ; 3 ms Steprate
                bsr.s   mkstep
                bra     parameters

***************************
* op_f2: Default auf F2
* Normalformat 2S
***************************
op_f2:
                moveq   #2,D4           ; 2 Seiten
                bsr     mkside          ; Seitenparameter schreiben
                bra.s   std1            ; sonst wie einseitiges Normalformat

***************************
* op_f3: Default auf F3
* FAT 2S (2S, 10 Sektoren, Interl. 1, 83 Tracks)
***************************
op_f3:
                moveq   #2,D4           ; 2 Seiten
                bsr     mkside          ; Seitenparameter
                moveq   #10,D4          ; 10 Sektoren
                bsr     mksec           ; Sektorenparameter
                moveq   #2,D4           ; 2 Sektoren pro Cluster
                bsr     mkspc           ; spc schreiben
                moveq   #1,D4           ; Interleave 1
                bsr     mkinter         ; Interleaveparameter
                moveq   #82,D4          ; letzter Track 82
                bsr     mktracks        ; Trackparameter
                moveq   #2,D4           ; Spiralfaktor 2
                bsr     mkspir          ; setzen
                bra.s   dir112

***************************
* op_f4: Default auf F4
* HYPERFORMAT 2S (11 S., 83 Spuren, Interl. 6)
***************************
op_f4:
                moveq   #2,D4           ; 2 Seiten
                bsr     mkside          ; Seitenparameter setzen
                moveq   #82,D4          ; letzter Track 82
                bsr     mktracks        ; Trackparameter setzen
                moveq   #2,D4           ; 2 Sektoren pro Cluster
                bsr     mkspc           ; spc schreiben
                moveq   #11,D4          ; 11 Sektoren
                bsr     mksec           ; Sektorenparameter setzen
                clr.w   D0              ; quickflag lîschen
                bsr     mkquick         ; Quickparameter setzen
                moveq   #6,D4           ; Interleave 6
                bsr     mkinter         ; Interleaveparameter setzen
                bra.s   dir112          ; 112 EintrÑge

***************************
* op_f5: Default auf F5
* MS-DOS 2S (40 Spuren, 8 Sektoren, 2S, Interleave 1,
* $40 Dir-EintrÑge, 1 Sektor pro Cluster)
***************************
op_f5:
                moveq   #2,D4           ; 1 Seite
                bsr     mkside          ; Seitenparameter setzen

                moveq   #8,D4           ; 8 Sektoren
                bsr     mksec           ; Sektorenparameter
                moveq   #1,D4           ; 1 Sektor pro Cluster
                bsr     mkspc           ; spc schreiben
                moveq   #1,D4           ; Interleave 1
                bsr     mkinter         ; Interleaveparameter
                moveq   #39,D4          ; letzter Track 39
                bsr     mktracks        ; Trackparameter
                moveq   #$40,D4         ; $40 Dir-EintrÑge
                bsr     mkdir           ; Dir-Parameter
                moveq   #0,D4           ; Spiralfaktor 0
                bsr     mkspir          ; setzen
                lea     s_exe(PC),A2    ; Stringadresse
                lea     executable(PC),A3 ; Adresse der executable-Variablen
                move.b  #'n',(A2)       ; String auf 'n'
                clr.w   (A3)            ; Flag lîschen
                bra     parameters

***************************
* op_f6: Default auf F6
* 1.1 MB: 13 Sektoren, Interleave 1, 2 Seiten, 83 Spuren,
* Spiralfaktor 3
***************************
op_f6:
                moveq   #13,D4          ; 13 Sektoren
                bsr     mksec
                moveq   #1,D4           ; Interleave 1
                bsr     mkinter
f6_2:
                moveq   #2,D4           ; 2 Sektoren/Cluster
                bsr     mkspc
f6_1:
                moveq   #2,D4           ; 2 Seiten
                bsr     mkside
                moveq   #0,D4           ; Steprate 6 ms
                bsr     mkstep
                moveq   #82,D4          ; letzte Spur: 82
                bsr     mktracks
                moveq   #3,D4           ; Spiralfaktor 3
                bsr     mkspir
                bra     parameters

***************************
* op_f7: Default auf F7
* 1.2 MB: 14 Sektoren, Interleave 7, 2 Seiten, 83 Spuren,
* Spiralfaktor 3
***************************
op_f7:
                moveq   #7,D4           ; Interleave 7
                bsr     mkinter
                moveq   #14,D4          ; 14 Sektoren pro Spur
                bsr     mksec
                bra.s   f6_2            ; weiter wie 1.1-MB-Format

***************************
* op_f8: Default auf F8
* 1.2 MB (AT-kompatibel): 15 S., Interl. 1, 2 Seiten, 83 Spuren,
* Spiralfaktor 3
***************************
op_f8:
                moveq   #15,D4          ; 15 Sektoren
f8_1:
                bsr     mksec
                moveq   #1,D4           ; 1 Sektor/Cluster
                bsr     mkspc
                move.l  #224,D4         ; 224 Dir-EintrÑge
                bsr     mkdir
                moveq   #1,D4           ; Interleave 1
                bsr     mkinter
                bra.s   f6_1            ; weiter wie 1.1-MB-Format

***************************
* op_f9: Default auf F9
* 1.44 MB (PS2-kompatibel): 18 S, Interl. 1, 2 Seiten, 83 Spuren,
* Spiralfaktor 3
***************************
op_f9:
                moveq   #18,D4          ; 18 Sektoren
                bra.s   f8_1

***************************
* op_f10: Togglet das Bit 6 im Port A des Soundchips
* Ist es gesetzt, ist HYPER DENSITY aktiviert, ansonsten
* lÑuft der FDC auf 8 MHz.
***************************
op_f10:
                bsr.s   gethd           ; Soundchip auslesen
                bchg    #6,D0           ; Bit 6 togglen
                move.b  D0,sndwrt
                move    pstatus(PC),SR
                bra     parameters

gethd:
                move    SR,pstatus
                ori     #$0700,SR
                move.b  #14,snd.w
                move.b  snd.w,D0
                rts

****************************
* op_help: Help-Seite anzeigen
****************************
op_help:
                lea     infomsg(PC),A5  ; Adresse der Help-Seite
                bsr     printmsg        ; ausgeben
                bsr     getkey          ; Auf Taste warten
                lea     intromsg(PC),A5 ; Header
                bsr     printmsg        ; ausgeben
                bra     parameters

***************************
* op_drive: Laufwerk einstellen
***************************
op_drive:
                move.w  $04A6.w,D0      ; nflops, Zahl angeschlossener Drives
                cmpi.w  #1,D0           ; nur eine?
                beq     parameters      ; ja, gleich wieder zurÅck

                lea     s_drv(PC),A2    ; Stringadresse
                lea     laufwerk(PC),A3 ; Adresse der Variablen
                move.w  (A3),D0         ; Wert holen
                moveq   #'B',D1         ; 'B' als Default
                eori.w  #1,D0           ; togglen
                bne.s   wr_drv
                moveq   #'A',D1         ; Auf B Ñndern
wr_drv:
                lea     msgdrv(PC),A4   ; Stringadresse von diskmsg
                move.b  D1,(A4)         ; neuen String schreiben
                bra     wr_exe          ; und Rest schreiben

*************************
* op_quick: Quickflag Ñndern
*************************
op_quick:
                lea     s_quick(PC),A6  ; Stringadresse
                lea     quickflag(PC),A3 ; Adresse der Variablen
                move.w  (A3),D4         ; Wert holen
                addq.w  #1,D4           ; plus eins
                cmpi.w  #3,D4           ; mehr als zwei geht nicht
                bne.s   wr_quick
                moveq   #0,D4           ; Default 0
wr_quick:
                clr.w   D0              ; d0.w = 0
                move.b  side(PC),D0     ; Seitenzahl
                cmp.w   #2,D0           ; Zwei Seiten?
                beq.s   chksecs         ; ja, Super-Quick erlaubt
                cmp.w   #2,D4           ; Super-Quick aktiviert?
                bne.s   chksecs         ; nein, ok
                clr.w   D4              ; doch, dann Quick aus
chksecs:
                lea     spt(PC),A4      ; Adresse der Sektorenanzahl
                cmpi.w  #q10schwelle,(A4) ; grîûer gleich Quickschwelle?
                blt     wr_inter        ; nein, raus
                moveq   #0,D4           ; String und Flag auf 0
                bra     wr_inter        ; schreiben und raus

***************************
* op_spiral: Spiralfaktor Ñndern
***************************
op_spiral:
                lea     s_spir(PC),A6   ; Stringadresse
                lea     spirfaktor(PC),A3 ; Variablenadresse

                move.w  (A3),D4         ; Wert holen
                addq.w  #1,D4           ; plus eins
                cmp.w   spt(PC),D4      ; mehr als spt geht nicht
                bne     wr_inter
                moveq   #0,D4           ; Default
                bra     wr_inter

*************************
* op_addhd: Flag fÅr zusÑtzlichen Header Ñndern
*************************
op_addhd:
                lea     s_addhd(PC),A2  ; Stringadresse
                lea     addhd(PC),A3    ; Adresse der Variablen
                bra.s   exorvf

*************************
* op_vf: Verify-Flag Ñndern
*************************
op_vf:                                  ; Verifyflag Ñndern
                lea     s_verify(PC),A2 ; Stringadresse
                lea     vfflag(PC),A3   ; Adresse der Variablen
                cmpi.w  #maxverifies,(A3) ; Maximum erreicht?
                bne.s   veryon          ; nein
                move.b  #'n',(A2)       ; sonst kein Verify
                clr.w   (A3)            ; 0 Versuche
                bra.s   param1
veryon:
                addq.w  #1,(A3)         ; Versuche + 1
                move.w  (A3),D0
                add.b   #'0',D0         ; in ASCII wandeln
                move.b  D0,(A2)         ; in String schreiben
param1:
                bra     parameters

*************************
* op_exe: AusfÅhrbarkeitsflag Ñndern
*************************
op_exe:                                 ; AusfÅhrbarkeitsflag Ñndern
                lea     s_exe(PC),A2    ; Stringadresse
                lea     executable(PC),A3 ; Adresse der Variablen

exorvf:
                move.w  (A3),D0
                moveq   #'y',D1         ; Yes als Default
                eori.w  #1,D0           ; Flag invertieren
                bne.s   wr_exe          ; nicht ausfÅhrbar?
                moveq   #'n',D1         ; auf 'No' Ñndern
wr_exe:
                move.b  D1,(A2)         ; String und
                move.w  D0,(A3)         ; Flag Ñndern
                bra     parameters

***************************
* op_step: Steprate Ñndern
***************************
op_step:
                lea     s_step(PC),A6   ; Stringadresse
                lea     steprate(PC),A3 ; Variablenadrese
                move.w  (A3),D4         ; Wert holen
                addq.w  #1,D4           ; plus eins
                and.l   #3,D4
                move.w  D4,(A3)
                add.w   D4,D4           ; mal 2 (Offset in Tabelle)
                lea     millis(PC),A3   ; -> Tabelle
                adda.w  D4,A3           ; + Offset
                move.b  (A3)+,(A6)+
                move.b  (A3),(A6)
                bra     parameters
millis:
                DC.B ' 6','12',' 2',' 3'

***************************
* op_sectors: Anzahl der Sektoren Ñndern
***************************
op_sectors:                             ; Sektoren Ñndern
                lea     b_spt(PC),A4    ; Adresse im Bootsektor
                lea     s_spt(PC),A6    ; Stringadresse
                lea     spt(PC),A3      ; Adresse der Variablen

                move.w  (A3),D4         ; Wert holen
                addq.w  #1,D4           ; plus eins
                cmpi.w  #maxsecs+1,D4   ; mehr als maxsecs Sektoren geht nicht
                bne.s   wr_secs
                moveq   #1,D4           ; Wert-Default

wr_secs:
                move.b  D4,(A4)         ; In b_spt schreiben
                move.w  D4,(A3)
                bsr     mkbytstr
                move.w  D4,D5           ; Sektoranzahl kopieren
                cmpi.w  #q10schwelle,D4 ; grîûer gleich Quickschwelle?
                blt.s   wron1           ; nein, weiter
                lea     quickflag(PC),A3 ; Adresse des Quickflags
                lea     s_quick+2(PC),A6 ; Stringadresse
                clr.w   (A3)            ; quickflag lîschen
                move.b  #'0',(A6)       ; String Ñndern

wron1:
                lea     spirfaktor(PC),A3 ; -> Spiralfaktor
                cmp.w   (A3),D5
                bpl.s   wron2
                lea     s_spir(PC),A6
                move.w  D5,D4
                subq.w  #1,D4
                move.w  D4,(A3)
                bsr     mkbytstr

wron2:
                bra     parameters

**************************
* mkmedia: Mediabyte errechnen und schreiben
**************************
mkmedia:
                movem.l D0/D2-D3,-(SP)  ; Register retten

                moveq   #$F8-1,D2
                clr.w   D3              ; d3.w lîschen
                move.b  side(PC),D3     ; Seitenzahl holen

                move.w  endtrack(PC),D0 ; letzten Track holen
                cmp.w   #78,D0          ; mit Track 78 vergleichen
                bpl.s   trk80           ; 80-Track-Format
                moveq   #$FC-1,D2       ; Default fÅr 40-Track-Disks
                move.w  spt(PC),D0      ; Sektoren pro Track
                subq.w  #8,D0           ; zufÑlligerweise 8?
                bne.s   trk80           ; nein, weiter
                moveq   #$FE-1,D2       ; Default fÅr 40 Tracks, 8 Sektoren

trk80:
                add.w   D2,D3           ; Media-Default + Seite/Track/Sektoren
                move.w  spt(PC),D0      ; Sektoren pro Track
                cmp.w   #18,D0          ; mehr als 18 Sektoren?
                bmi.s   mdwrite         ; nein
                moveq   #$F0,D3         ; PS2-Format: Mediabyte $F0
mdwrite:
                lea     media(PC),A2    ; Adresse des Mediabytes
                move.b  D3,(A2)         ; schreiben
                movea.l fatstart(PC),A2 ; Adresse des ersten FAT-Sektors
                move.b  D3,(A2)         ; Media-Byte schreiben

                movem.l (SP)+,D0/D2-D3  ; Register holen
                rts

**************************
* op_settle: Wartezeit bei Spurwechsel einstellen
**************************
op_settle:
                lea     s_settling(PC),A6 ; Stringadresse
                lea     settling(PC),A3 ; Settlingrate
                eori.w  #4,(A3)
                move.b  #'n',(A6)
                tst.w   (A3)
                beq.s   nosettl
                move.b  #'y',(A6)
nosettl:
                bra     parameters

**************************
* op_tracks: Letzten Track Ñndern
**************************
op_tracks:                              ; Tracks Ñndern
                lea     s_tracks(PC),A6 ; Stringadresse
                lea     endtrack(PC),A3 ; Adresse der Variablen
                move.w  (A3),D4         ; Wert
                addq.w  #1,D4           ; um eins erhîhen
                cmpi.w  #44,D4          ; grîûer Track 44?
                bne.s   uplimit         ; nein, OK
                cmpi.w  #79,D4          ; kleiner Track 79?
                bge.s   uplimit         ; nein, OK
                moveq   #79,D4          ; Tracks auf 79 einstellen
uplimit:
                cmpi.w  #maxtracks+1,D4 ; mehr als maxtracks lÑuft nicht
                bne.s   wr_inter        ; schreiben
                moveq   #39,D4          ; letzter Track 39
                bra.s   wr_inter

***************************
* op_side: Anzahl der Seiten Ñndern
***************************
op_side:                                ; Seiten Ñndern
                lea     s_sides(PC),A6  ; Stringadresse
                lea     side(PC),A3     ; Adresse im Bootsektor
                clr.w   D4              ; d4 lîschen
                move.b  (A3),D4         ; Seitenzahl nach d0 holen
                eori.b  #3,D4           ; Seitenzahl Ñndern
                move.b  D4,D3           ; Seitenzahl retten
                add.b   #$F8-1,D3       ; in Mediabyte wandeln
                move.b  D3,media        ; Mediabyte schreiben
                movea.l fatstart(PC),A2 ; Adresse der ersten FAT
                move.b  D3,(A2)         ; Media-Byte schreiben
                movem.l D4/A3/A6,-(SP)  ; Register retten
                cmp.b   #2,D4           ; 2 Seiten?
                beq.s   sdok            ; ja, raus hier
                move.w  quickflag(PC),D0 ; Quickflag holen
                cmp.w   #2,D0           ; auf Super-Quick gestellt?
                bne.s   sdok            ; nein, alles klar
                subq.w  #1,D0           ; doch, Super-Quick aus
                bsr     mkquick         ; Quick-Parameter schreiben
sdok:
                movem.l (SP)+,D4/A3/A6  ; Register wieder holen
                bra.s   wr_dir          ; Flag und String schreiben und raus

***************************
* op_dir: Anzahl der DirectoryeintrÑge Ñndern
***************************
op_dir:
                lea     s_dir(PC),A6    ; Stringadresse
                lea     entries(PC),A3  ; Adresse der EintrÑge
                clr.w   D4              ; d4 lîschen
                move.b  (A3),D4         ; Anzahl der EintrÑge holen
                add.b   #16,D4          ; 16 aufaddieren
                cmpi.b  #max_dir,D4     ; schon mehr als erlaubt?
                bne.s   wr_dir          ; nein, fertig
                moveq   #16,D4          ; wieder von vorne

wr_dir:
                bsr     mkbytstr        ; d4.b in String
                move.b  D4,(A3)         ; Wert schreiben
                bra     parameters      ; heim zu Mami

**************************
* op_inter: Interleave-Faktor einstellen
**************************
op_inter:
                lea     s_inter(PC),A6  ; Stringadresse
                lea     ileave(PC),A3   ; Interleave-Adresse
                move.w  (A3),D4         ; Wert holen
                addq.w  #1,D4
                cmpi.w  #maxsecs+1,D4   ; schon maxsecs erreicht?
                bne.s   wr_inter        ; schreiben
                moveq   #1,D4           ; wieder auf 1 zurÅck

wr_inter:
                bsr     mkbytstr        ; d4.b in String wandeln
                move.w  D4,(A3)         ; Wert schreiben
                bra     parameters      ; heim zu Mami

***************************
* op_spc: Sektoren pro Cluster einstellen
***************************
op_spc:
                lea     s_spc(PC),A6    ; Stringadresse
                lea     spc(PC),A3      ; Adresse der spc-Variablen
                move.w  (A3),D4         ; Wert holen
                lsl.w   #1,D4           ; mal 2
                cmp.w   #16,D4          ; >=16 Sektoren/Cluster?
                bne.s   wr_inter        ; nein, schreiben
                moveq   #1,D4           ; 1 Sektor pro Cluster
                bra.s   wr_inter        ; schreiben

***************************
* calc_secs: Anzahl der Sektoren ausrechnen
* Formel: (endtrack+1)*spt*side
****************************
calc_secs:
                clr.w   D1              ; d1 lîschen
                lea     sectors(PC),A3
                move.w  endtrack(PC),D0 ; Letzter Track
                addq.w  #1,D0           ; plus eins
                mulu    spt(PC),D0      ; mal Sektorenanzahl
                move.b  side(PC),D1
                mulu    D1,D0           ; mal side

                move.b  D0,(A3)         ; Lowbyte schreiben
                asr.l   #8,D0           ; Highbyte holen
                move.b  D0,1(A3)        ; und schreiben
                rts

******************************
* mkfatsecs: FAT-Grîûe ausrechnen, FATs vorbereiten
******************************
mkfatsecs:
                movem.l D0-A6,-(SP)     ; Register retten
                moveq   #0,D0           ; d0 lîschen
                lea     sectors(PC),A0  ; Adresse der Sektoranzahl
                move.b  1(A0),D0        ; Highbyte Sektoranzahl
                asl.l   #8,D0           ; mal 256
                move.b  (A0),D0         ; Lowbyte Sektoranzahl
                divu    spc(PC),D0      ; durch Sektoren pro Cluster
                mulu    #3,D0           ; mal 3
                lsr.w   #1,D0           ; durch 2

                lsr.w   #8,D0           ; durch 256
                lsr.w   #1,D0           ; durch 2 (also durch 512)
                addq.w  #1,D0           ; plus ein Reservesektor
                move.w  D0,secsperfat   ; schreiben

                movea.l fatstart(PC),A0 ; Start der FATs
                subq.w  #1,D0           ; fÅr dbf

clrnxtsec:
                move.w  #511,D1         ; BytezÑhler
clrfatsec:
                clr.b   (A0)+           ; Byte lîschen
                dbra    D1,clrfatsec    ; nÑchstes Byte
                dbra    D0,clrnxtsec    ; nÑchster Sektor

                movea.l fatstart(PC),A0 ; Start der FATs
                move.l  #$F9FFFF00,(A0) ; Default-Kennung schreiben

                movem.l (SP)+,D0-A6     ; Register holen
                rts                     ; und bye-bye

******************************
* wrfdc: Byte in d7 an den Controller
* schicken
******************************
wrfdc:
                nop                     ; kleine Verzîgerung
                nop
                move.w  D7,daccess      ; d7 ins Access-Register des DMA-Chips
                nop                     ; und noch'ne Verzîgerung
                nop
                rts

**************************
* irq: Unterbricht den Controller
**************************
irq:
                moveq   #$D0,D7         ; Force Interrupt
                bsr.s   wrfdc           ; d7 an den Controller
                moveq   #15,D1          ; 16 SchleifendurchlÑufe

******************************
* as_time_goes_by: Warteschleife
* mit d1 DurchlÑufen
******************************
as_time_goes_by:
                dbra    D1,as_time_goes_by ; Looping (huiii...)
                rts                     ; back to the future

*****************************
* rdsec: Liest einen Sektor auf der aktuellen Spur
* IN: bf(pc) Pufferadresse, d4 Sektor, OUT: d0 Status (>0 -> Fehler)
*****************************
rdsec:
                move.l  bf(PC),D7       ; Pufferadresse
                add.l   #bufflength-1024,D7 ; plus bufflength-1024 (Sektorpuffer)
                bsr.s   dma             ; DMA-Adresse schicken
                move.w  #$90,dmodus.w   ; Status lîschen
                move.w  #$0190,dmodus.w
                move.w  #$90,dmodus.w   ; SektorzÑhler
                moveq   #1,D7           ; 1 Sektor
                bsr.s   wrfdc           ; an DMA-Chip schicken
                move.w  #$84,dmodus.w   ; Sektorregister FDC
                move.w  D4,D7           ; Sektornummer
                bsr.s   wrfdc           ; an FDC schicken
                move.w  #$80,D7         ; d7=$80
                move.w  D7,dmodus.w     ; Kommandoregister selektieren
                bsr.s   wrfdc           ; d7 an FDC (READ SECTOR)
                moveq   #16+8+4,D7      ; RNF(16)+CRC(8)+LOSTDATA(4) als Maske
                bsr     warten_auf_godot ; auf Ende warten
                tst.w   D0              ; Fehler passiert?
                bne.s   rderr           ; ja, Lesefehler

*****************************
* status: Holt DMA-Status nach d0
******************************
status:
                move.w  #$0190,dmodus.w ; SektorzÑhler selektieren
                move.w  dmodus.w,D0     ; Status holen
                and.w   #1,D0           ; DMA-Error?
                beq.s   rderr           ; DMA-Fehler passiert
                clr.w   D0              ; nix passiert
                rts                     ; raus (d0.w=0)

rderr:
                or.w    #$0200,D0       ; Fehler kommt aus Controllerroutine
                rts

*****************************
* dma: Setzt DMA-Adresse
* IN: d7 Startadresse
*****************************
dma:
                move.b  D7,dlow         ; DMA-Lowbyte
                lsr.l   #8,D7           ; shiften
                move.b  D7,dmid         ; DMA-Midbyte
                lsr.l   #8,D7           ; shiften
                move.b  D7,dhigh        ; DMA-Highbyte
                rts

*****************************
* rdtrk: Liest eine Spur und erkennt Hyper-Density
*****************************
rdtrk:
                move.w  laufwerk(PC),D0 ; aktuelles Laufwerk
                addq.w  #1,D0           ; +1
                add.w   D0,D0           ; mal 2
                bsr     do_select
                move.l  bf(PC),D7       ; Pufferadresse holen
                bsr.s   dma             ; als DMA-Adresse schicken
                move.w  #$90,dmodus.w
                move.w  #$0190,dmodus.w
                move.w  #$90,dmodus.w   ; DMA-SektorzÑhler selektieren
                moveq   #20,D7          ; maximal 20 Sektoren
                bsr     wrfdc           ; an DMA-Chip
                move.w  #$80,dmodus.w   ; Kommandoregister
                moveq   #$E4,D7         ; READ TRACK mit Settling Delay
                bsr     wrfdc           ; an FDC schicken
                moveq   #4,D7           ; LOST DATA als Maske
                bsr.s   warten_auf_godot ; aufs Ende warten
                bsr     getdma          ; DMA-Adresse holen
                sub.l   bf(PC),D2       ; minus Startadresse
                rts

*****************************
* such_hasso: Seek-Befehl
*****************************
such_hasso:
                move.w  #$86,dmodus.w   ; Datenregister auswÑhlen
                move.w  D4,D7           ; Tracknummer holen
                bsr     wrfdc           ; Byte in d7 an FDC
                moveq   #$10,D7         ; SEEK ohne Verify
                bra.s   typ1

*****************************
* rsthead: Faehrt Kopf auf Spur 0
*****************************
rsthead:
                moveq   #0,D7           ; Restore
typ1:
                move.w  #$80,dmodus.w   ; Kommandoregister
                add.w   steprate(PC),D7 ; plus Steprate
                add.w   settling(PC),D7 ; plus Settling
                bsr     wrfdc           ; an FDC schicken
                bra.s   warten_auf_godot ; auf FDC warten

*****************************
* rdfdc: FDC-Register lesen
*****************************
rdfdc:
                nop                     ; kurz warten
                nop
                move.w  daccess.w,D0    ; Register lesen
                nop
                nop                     ; nochmal warten
                rts

*****************************
* warten_auf_godot: Wartet auf FDC
* IN: d7 Errormask, USES: a3.l, d1.l, d2.l (mindestens)
*****************************
warten_auf_godot:
                moveq   #25,D1          ; auf BUSY warten
wt:
                dbra    D1,wt

                move.l  #timeout,D1     ; Timeout
poll:
                btst    #5,mfp.w        ; FDC fertig?
                beq.s   fix_und_fertig  ; ja
                subq.l  #1,D1           ; Timeout runterzÑhlen
                beq.s   auszeit         ; aus und vorbei

                lea     quick(PC),A3
                tst.w   (A3)            ; Quickflag gesetzt?
                beq.s   poll            ; nein, weiter warten

                bsr.s   getdma          ; aktuelle DMA-Adresse nach d2
                cmp.l   dmaend(PC),D2   ; DMA-Ende erreicht?
                blt.s   poll            ; nein, weiter warten

                move.w  #$0180,dmodus.w ; Kommandoregister
                bsr.s   rdfdc           ; Status nach d0 holen
                and.w   D7,D0           ; Fehlerbits maskieren
                bsr     irq             ; FDC abwÅrgen
                clr.w   (A3)            ; Quick-Flag lîschen
                rts

auszeit:
                bsr     irq             ; Kommando abbrechen
                move.w  #$0201,D0       ; Fehler in warten + Timeoutflag
                rts

fix_und_fertig:
                move.w  #$0180,dmodus.w ; Kommandoregister
                bsr.s   rdfdc           ; Status nach d0 holen
                and.w   D7,D0           ; Fehlerbits maskieren
                rts

*****************************
* getdma: aktuelle DMA-Adresse nach d2 holen
*****************************
getdma:
                moveq   #0,D2           ; d2 lîschen
                move.b  dhigh.w,D2      ; DMA-Highbyte lesen
                lsl.l   #8,D2           ; shiften
                move.b  dmid.w,D2       ; DMA-Midbyte lesen
                lsl.l   #8,D2           ; shiften
                move.b  dlow.w,D2       ; DMA-Lowbyte lesen
                rts

*****************************
* do_select: Und jetzt das Selektierprogramm
* Floppy-VBL muss aus sein, zu selektierendes Laufwerk in d0
* USES: d7.w
*****************************
do_select:
                tst.w   D0              ; Laufwerksnummer prÅfen
                bne.s   mach_mal        ; Wenn nicht gerade 0, dann mach los
                move.w  #$80,dmodus.w   ; Statusregister
                move.l  #timeout,D1     ; maximale PrÅfzeit
motor:
                move.w  daccess.w,D7    ; auslesen
                btst    #7,D7           ; Motor noch an?
                beq.s   mach_mal        ; nein, weiter
                subq.l  #1,D1           ; jawoll, weiter warten
                bne.s   motor
mach_mal:
                move.w  D0,D7           ; Laufwerksnummer holen
                eori.b  #7,D7           ; Bits invertieren
                and.b   #7,D7           ; und ausmaskieren
                bsr     gethd           ; Inhalt von Port A holen
                and.b   #$F8,D0         ; ausmaskieren
                or.b    D0,D7           ; neue Seite/neues Laufwerk setzen
mach_2:
                move.b  D7,sndwrt       ; in Port A
                move    pstatus(PC),SR  ; Status wieder holen
                rts                     ; und raus

**********************
* und jetzt die Daten
**********************
zei:
accname:        DC.B '  Hyperformat ',version,'.',rev1,rev2,0
                EVEN
aespb:          DC.L contrl,global,intin,intout
                DC.L addrin,addrout
; Parameterblock fÅr AES

***************************
* Der Text
***************************
intromsg:
                DC.B 27,'E',27,'f',27,'p'
                DC.B '===== H Y P E R F O R M A T   ',version,'.',rev1,rev2,' =====',13,10
                DC.B '===Ω 1989 Claus Brod & JÅrgen Stessun===',27,'q'
                DC.B 27,'e',13,10,0

msg_parms:
                DC.B 27,'f',27,'Y',32+2,32+0
                DC.B '     ',27,'pT',27,'q  Last track             :'
s_tracks:
                DC.B ' 82',13,10
                DC.B '     ',27,'pD',27,'q  Directory entries      :'
s_dir:
                DC.B '112',13,10
                DC.B '     ',27,'pS',27,'q  Sides                  :'
s_sides:
                DC.B '  2',13,10
                DC.B '     ',27,'pI',27,'q  Interleave factor      :'
s_inter:
                DC.B '  6',13,10
                DC.B '     ',27,'pP',27,'q  Sectors per track      :'
s_spt:
                DC.B ' 11',13,10
                DC.B '     ',27,'pF',27,'q  Spiral factor          :'
s_spir:
                DC.B '  2',13,10
                DC.B '     ',27,'pR',27,'q  Step rate (ms)         : '
s_step:
                DC.B ' 3',13,10
                DC.B '     ',27,'pC',27,'q  Cluster size           :'
s_spc:
                DC.B '  2',13,10
                DC.B '     ',27,'pV',27,'q  Verify count           :  '
s_verify:
                DC.B 'n',13,10
                DC.B '     ',27,'pW',27,'q  Settling delay         :  '
s_settling:
                DC.B 'n',13,10
                DC.B '     ',27,'pE',27,'q  Executable bootsector  :  '
s_exe:
                DC.B 'n',13,10
                DC.B '     ',27,'pA',27,'q  Additional header      :  '
s_addhd:
                DC.B 'n',13,10
                DC.B '     ',27,'pU',27,'q  Disk unit              :  '
s_drv:
                DC.B 'A',13,10
                DC.B '     ',27,'pQ',27,'q  Quickformat            :'
s_quick:
                DC.B '  0',13,10


                DC.B '=============Special keys:==============',13,10
                DC.B 27,'pCR',27,'q Format '
                DC.B 27,'pB',27,'q Softfmt '
                DC.B 27,'pESC',27,'q Quit '
                DC.B 27,'pHELP',27,'q Help',13,10

                DC.B '=============Default keys:==============',13,10
                DC.B 27,'pF1',27,'q TOS 1S '
                DC.B 27,'pF2',27,'q TOS 2S '
                DC.B 27,'pF3',27,'q FAT 2S ',27,'pF4',27,'q HYPER'
                DC.B 13,10
                DC.B 27,'pF5',27,'q DOS 2S '
                DC.B 27,'pF6',27,'q 1.1 MB '
                DC.B 27,'pF7',27,'q 1.2 MB '
                DC.B 27,'pF8',27,'q AT-Fmt '
                DC.B 13,10
                DC.B 27,'pF9',27,'q 1.5 MB '
                DC.B 27,'pF10',27,'q HD-Flag'
haken:
                DC.B ' ',13,10,27,'f',0

                EVEN
infomsg:
                DC.B 27,'E',27,'p'
                DC.B '           HYPERFORMAT V',version,'.',rev1,rev2,'           ',13,10
                DC.B '       The First 1700 KB Formatter     ',13,10
                DC.B '       Ω 1989 Claus Brod/J.Stessun     ',27,'q',13,10

                DC.B 'Later versions than V2.57 of HYPERFORMAT are definitely NOT in',13,10
                DC.B 'the public domain - so beware! V',version,'.',rev1,rev2
                DC.B ' has too many  features to',13,10
                DC.B 'count them all  here.  You can get full instructions by buying',13,10
                DC.B "'SCHEIBENKLEISTER', my book  on the ST's mass storage devices.",13,10
                DC.B "You as a user can help me:   Drop me a line if there's trouble",13,10
                DC.B 'with HYPERFORMAT. My address:',13,10,13,10
                DC.B 27,'p'
                DC.B '             Claus Brod              ',13,10
                DC.B '          Am Felsenkeller 2          ',13,10
                DC.B 'D-8772 Marktheidenfeld (West Germany)',13,10
                DC.B '  Phone:  (West Germany) 09391-3206  ',27,'q',13,10

                DC.B 13,10
                DC.B 'Some of the most stunning features of HYPERFORMAT:',13,10
                DC.B '- up to 960000 bytes on a 2S disk',13,10
                DC.B '- up to 1222656 bytes on a 2S disk with HYPER DENSITY circuit',13,10
                DC.B '- up to 1.7 MB (AT/PS2 compatible) on a 2SHD disk',13,10
                DC.B '- MSDOS-compatible format routines',13,10
                DC.B '- Fast format routines (<20 seconds for a double sided disk)',13,10
                DC.B '- Special formats supported (1-18 sectors, interleaving,  spi-',13,10
                DC.B '  ral formats, FASTLOAD formats, executable boot sectors etc.)',13,10
                DC.B '- Verify option, disk labels, drives A and B supported',13,10
                DC.B '- Runs as .ACC and .PRG on all TOS versions',0

*********************
* verschiedene Ausgabetexte
*********************
                EVEN
nicht10:
                DC.B 27,'Y',32+23,32+1,27,'pError: Switch to HYPER DENSITY!',27,'q',0
trackmsg:
                DC.B 27,'Y',32+22,32+1,27,'pFormatting track: ',0
track2msg:
                DC.B 27,'Y',32+22,32+1,27,'pFormatting...',0
s_trk:
                DC.B 27,'Y',32+22,32+19,27,'p'
s_akt:
                DC.B '00',27,'q',0

namemsg:
                DC.B 27,'Y',32+22,32+1,27,'pVolume label (CR=no disk name):',27,'q',0

errormsg:
                DC.B 27,'Y',32+23,32+1,7,27,'pFormat Error $'
errnum:
                DC.B '0000 Trk '
badtrk:
                DC.B ' 0 Sec '
badsec:
                DC.B ' 0 Sd '
badsd:
                DC.B ' 0',27,'q',0

z1:
                DC.B 27,'q',27,'Y',32+22,32+0,27,'M',27,'M',27,'M',27,'M',0
; Cursor positionieren, 4 Zeilen lîschen

againmsg:
                DC.B 27,'Y',32+23,32+1,'Back to menu (Y/N)? ',0
diskmsg:
                DC.B 13,10,' Insert disk in drive '
msgdrv:
                DC.B 'A.',0
keymsg:
                DC.B 13,10,' Press key.',0
nomem:
                DC.B '[3][    Zuwenig freier|    Speicher!][Grmpf]',0

                EVEN
*************************
* interne Variablen
*************************
spt:                                    ; Sektoren pro Track
                DC.W 11         ; normalerweise 11 (HYPERFORMAT)
laufwerk:                               ; Laufwerk
                DC.W 0
ileave:                                 ; Interleave-Faktor
                DC.W 6
endtrack:                               ; Letzter zu formatierender Track
                DC.W 82
executable:                             ; AusfÅhrbarkeitsflag
                DC.W 0
vfflag:                                 ; Verifyflag
                DC.W 0
steprate:
                DC.W 3          ; Steprate
addhd:
                DC.W 0          ; ZusÑtzlicher Header (0=nein)?
aktsd:
                DC.W 0

fatstart:
                DC.L 0          ; Start der FATs im Speicher
secsperfat:
                DC.W 3          ; Sektoren pro FAT
spc:
                DC.W 2          ; Sektoren pro Cluster
spirfaktor:
                DC.W 2          ; Spiralfaktor

                DC.B "HYPER-GAPS"
* LÅcken fÅr normale Dichte
ngaps:
                DC.B ngap1-1,ngap2-1,ngap31-1,ngap32-1,ngap4-1 ; LÅcken fÅr <=9
                DC.B q9gap1-1,q9gap2-1,q9gap31-1,q9gap32-1,q9gap4-1 ; Sektoren

                DC.B n10gap1-1,n10gap2-1,n10gap31-1,n10gap32-1,n10gap4-1 ; 10 Sektoren
                DC.B qgap1-1,qgap2-1,qgap31-1,qgap32-1,qgap4-1 ; mit Quick

                DC.B gap1-1,gap2-1,gap31-1,gap32-1,gap4-1 ; 11 Sektoren
                DC.B gap1-1,gap2-1,gap31-1,gap32-1,gap4-1 ; mit Quick

                DC.B ngap1-1,ngap2-1,ngap31-1,ngap32-1,ngap4-1 ; LÅcken fÅr 12 Sektoren
                DC.B q12gap1-1,q12gap2-1,q12gap31-1,q12gap32-1,q12gap4-1 ; mit Quick

                DC.B h13gap1-1,h13gap2-1,h13gap31-1,h13gap32-1,h13gap4-1 ; 13 Sektoren
                DC.B h13gap1-1,h13gap2-1,h13gap31-1,h13gap32-1,h13gap4-1

                DC.B h14gap1-1,h14gap2-1,h14gap31-1,h14gap32-1,h14gap4-1 ; 14 Sektoren
                DC.B h14gap1-1,h14gap2-1,h14gap31-1,h14gap32-1,h14gap4-1

                DC.B ngap1-1,ngap2-1,ngap31-1,ngap32-1,ngap4-1 ; 15 Sektoren
                DC.B q9gap1-1,q9gap2-1,q9gap31-1,q9gap32-1,q9gap4-1

                DC.B ngap1-1,ngap2-1,ngap31-1,ngap32-1,ngap4-1 ; 16 Sektoren
                DC.B q9gap1-1,q9gap2-1,q9gap31-1,q9gap32-1,q9gap4-1

                DC.B ngap1-1,ngap2-1,ngap31-1,ngap32-1,ngap4-1 ; 17 Sektoren
                DC.B q9gap1-1,q9gap2-1,q9gap31-1,q9gap32-1,q9gap4-1

                DC.B ngap1-1,ngap2-1,ngap31-1,ngap32-1,ngap4-1 ; 18 Sektoren
                DC.B q9gap1-1,q9gap2-1,q9gap31-1,q9gap32-1,q9gap4-1

                DC.B ngap1-1,ngap2-1,ngap31-1,ngap32-1,ngap4-1 ; 19 Sektoren
                DC.B qgap1-1,qgap2-1,qgap31-1,qgap32-1,qgap4-1

                DC.B q9gap1-1,q9gap2-1,q9gap31-1,q9gap32-1,q9gap4-1 ; 20 Sektoren
                DC.B qgap1-1,qgap2-1,qgap31-1,qgap32-1,qgap4-1

                DC.B h21gap1-1,h21gap2-1,h21gap31-1,h21gap32-1,h21gap4-1 ; 21 Sektoren
                DC.B h21gap1-1,h21gap2-1,h21gap31-1,h21gap32-1,h21gap4-1

                DC.B h22gap1-1,h22gap2-1,h22gap31-1,h22gap32-1,h22gap4-1 ; 22 Sektoren
                DC.B h22gap1-1,h22gap2-1,h22gap31-1,h22gap32-1,h22gap4-1

* Tastatur- und Routinentabellen
keys:
                DC.B 27,13,'bdsteivupqfarcw',0
                EVEN
fkeys:
                DC.B 98,59,60,61,62,63,64,65,66,67,68
                DC.B 0
* HELP-Taste und Funktionstasten
                EVEN
options:
                DC.W exitus2-reserve,end_parms-reserve
                DC.W end_parms-reserve,op_dir-reserve,op_side-reserve,op_tracks-reserve
                DC.W op_exe-reserve,op_inter-reserve,op_vf-reserve
                DC.W op_drive-reserve,op_sectors-reserve,op_quick-reserve
                DC.W op_spiral-reserve,op_addhd-reserve,op_step-reserve
                DC.W op_spc-reserve,op_settle-reserve

foptions:
                DC.W op_help-reserve,op_f1-reserve,op_f2-reserve,op_f3-reserve
                DC.W op_f4-reserve,op_f5-reserve,op_f6-reserve,op_f7-reserve
                DC.W op_f8-reserve,op_f9-reserve,op_f10-reserve

*************************
* Ein Standard-Bootsektor
*************************
                EVEN
bootsector:
                DC.B 96,56,'Loader',203,31,238
                DC.B 0,2
bspc:
                DC.B 2          ; Sektoren pro Cluster
                DC.B res,0,fat
entries:
                DC.B 112,0      ; EintrÑge in Wurzelverzeichnis
sectors:
                DC.B 34,7       ; Sektoranzahl
media:
                DC.B $F9        ; Media-Byte
spf:
                DC.B 3,0        ; Sektoren pro FAT
b_spt:                                  ; Anzahl der Sektoren
                DC.B 11,0
side:
                DC.B 2,0,0,0,0,0,0,0,0,0,0,0,0,4
                DC.B 0,0,0,0,128,0,84,79
                DC.B 83,32,32,32,32,32,73,77
                DC.B 71,0,51,250,255,226,0,0
                DC.B 4,130,63,57,0,0,4,70
                DC.B 63,60,0,7,78,77,88,79
                DC.B 74,128,103,0,0,246,42,64
                DC.B 65,250,255,208,74,144,102,6
                DC.B 32,185,0,0,4,50,48,45
                DC.B 0,8,225,72,208,128,56,64
                DC.B 217,250,255,184,48,58,255,170
                DC.B 103,16,60,58,255,166,56,58
                DC.B 255,164,38,122,255,162,96,0
                DC.B 0,180,60,45,0,10,56,45
                DC.B 0,8,216,109,0,6,38,122
                DC.B 255,146,97,0,0,178,102,0
                DC.B 0,170,32,76,48,45,0,6
                DC.B 225,72,227,72,65,240,0,0
                DC.B 67,250,255,124,144,252,0,32
                DC.B 177,204,109,0,0,142,112,10
                DC.B 18,48,0,0,178,49,0,0
                DC.B 102,234,81,200,255,244,126,0
                DC.B 30,40,0,27,225,79,30,40
                DC.B 0,26,44,122,255,78,38,122
                DC.B 255,70,66,132,190,124,15,240
                DC.B 108,82,54,7,85,67,198,237
                DC.B 0,2,214,109,0,12,184,124
                DC.B 0,64,108,8,74,68,103,14
                DC.B 182,69,103,16,97,72,102,66
                DC.B 225,140,227,140,215,196,60,3
                DC.B 58,3,66,132,216,109,0,2
                DC.B 218,109,0,2,52,7,226,74
                DC.B 212,71,18,54,32,1,225,73
                DC.B 18,54,32,0,8,7,0,0
                DC.B 103,2,232,73,194,124,15,255
                DC.B 62,1,96,168,74,68,103,4
                DC.B 97,12,102,6,47,58,254,224
                DC.B 78,117,66,128,78,117,63,57
                DC.B 0,0,4,70,63,6,63,4
                DC.B 47,11,66,103,63,60,0,4
                DC.B 78,77,222,252,0,14,74,64
                DC.B 78,117,78,101,117,116,101,114
                DC.B 32,66,111,111,116,101,114,13
                DC.B 10,40,67,41,49,57,56,53
                DC.B 32,65,116,97,114,105,32,67
                DC.B 111,114,112,46,13,10,0,0
                DC.B 'HYPERFORMAT V',version,'.',rev1,rev2
                DC.B ' (C) 1989 by Claus Brod',0,0,0,0
                DC.L 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


accid:          DC.W -1

                BSS
cleansector:
                DS.B 512        ; ein leerer Sektor
settling:
                DS.W 1
grhandle:
                DS.W 1

apid:           DS.W 1

xpos:           DS.W 2
size:           DS.W 2

msgbuff:
                DS.B 16
contrl:
opcode:         DS.W 1
sintin:         DS.W 1
sintout:        DS.W 1
saddrin:        DS.W 1
saddrout:       DS.L 1
                DS.W 5
global:         DS.L 8
intin:          DS.W 80
ptsin:          DS.W 80
intout:         DS.W 80
ptsout:         DS.W 80
addrin:         DS.W 80
addrout:        DS.W 80

tsavp:          DS.L 1
savarea:        DS.B 2*$2E
endarea:
kshift:         DS.L 1
keyflag:        DS.W 1

vecount:        DS.W 1          ; VerifyzÑhler
namebuf:        DS.B 20         ; Eingabepuffer
dmaend:
                DS.L 1          ; DMA-Endadresse
quick:
                DS.W 1          ; Quickformat-Flag
quickflag:
                DS.W 1          ; Hilfsflag fÅr Quickformat
trk:
                DS.W 1          ; aktuelle Tracknummer
bf:
                DS.L 1          ; Pufferadresse
sd:
                DS.W 1          ; aktuelle Seitennummer
actsec:
                DS.W 1          ; aktuelle Sektornummer

density:
                DS.W 1          ; Flag fÅr die Dichte (0=normal, $1100=HYPER)
pstatus:
                DS.W 1          ; Platz fÅr Prozessorstatus

headerpos:
                DS.W 1          ; Position des Headers

fmtflag:                                ; Formatierflag
                DS.W 1
                DS.W 1
kbshift:                                ; ->Adresse der Kbshift-Variablen
                DS.L 1
errflag:                                ; Fehlerflag
                DS.W 1
nachspann:                              ; Adresse des Nachspanns
                DS.L 1
realspt:                                ; Zahl der wirklich erzeugten
                DS.W 1          ; Sektoren pro Track
offset:                                 ; Offset in die Sektornummerntabelle
                DS.W 1
                DS.W $0500      ; Platz fÅr Stack
nstapel:        DS.L 1

secno:          DS.B 2*maxsecs+2
sectable:       DS.L 2*maxsecs  ; Sektorentabelle
scrsave:        DS.L 1          ; Adresse des Schirmpuffers
fats:           DS.B 1          ; ab hier beginnen die FATs, muû am Ende stehen!!!

                END
