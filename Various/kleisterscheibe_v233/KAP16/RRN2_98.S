*****************************************************************
************************** LUFTSCHLOSS **************************
*               Resetfeste, bootfÑhige RAM-Disk                 *
*                   Written & Ω 1988-1992 by                    *
*           Lutz Preûler (Ahornweg 11, 2904 Hatten)             *
*    &  Claus Brod (Am Felsenkeller 2, 8772 Marktheidenfeld)    *
*****************************************************************

                PART 'Entwicklungsgeschichte'

* V1.0 (3/88, CB): WINZRAM - winzige öbungs-RAM-Disk zum Lernen *
* V1.8 (30.9.88, LP): Resetfeste, bootfÑhige RAM-Disk - herz-   *
*      lichen Dank an Lutz Preûler fÅr diese Version sowie an   *
*      Alex Esser fÅr seine Tips und seine tolle GEMDOS-Serie   *
* V1.9 (12/88, CB): BootfÑhigkeit abschaltbar; RAM-Disk-Routinen*
*      bis zum Gehtnichtmehr (13.5 MBit/s) optimiert, Bootsektor*
*      virtuell (RAM-Disk liefert Fehler -7, Unknown Media, beim*
*      Lesen/Beschreiben des Bootsektors), ACCs von anderen     *
*      Laufwerken als C: bootbar                                *
* V2.0 (1/89, CB): Anpassung an die chaotische Screen-Plazierung*
*      in GFABASIC (grrrr...): memtop immer auf 512-Byte-Grenzen*
*      GFABASIC2.02 reserviert sich beim Start den grîûten      *
*      Speicherblock bis auf 16K (liegt in den meisten FÑllen am*
*      Ende der TPA und schlieût mit dem Bildschirm ab); die    *
*      logische Bildschirmadresse wird dann nach der Formel     *
*      "Speicherblockstart + SpeicherblocklÑnge - 32768" gesetzt*
*      Das geht immer schief, wenn memtop nicht auf einer Page- *
*      Grenze steht, und wahrscheinlich nicht nur dann!         *
* V2.1 (1/89, CB): 16-Bit-FAT (beschleunigt GEMDOS!), neue Nach-*
*      laufroutine; XBRA-Kennung von "Winz" auf "WINZ" geÑndert,*
*      nicht bootbares LUFTSCHLOSS wird durch CAPS LOCK beim    *
*      Reset doch noch bootbar                                  *
* V2.2 (2/89, LP+CB): Nur noch eine FAT, die andere virtuell    *
*      (spart Speicher); Anpassungen an TOS1.0 und ROM-TOS 1.04 *
* V2.3 (7/89, LP): Fehler in myrwabs (virt. FAT) entfernt       *
* V2.4 (1/90, CB): Erkennt auch RAM-TOS 1.04 (8.8.88); bei unbe-*
*      kannten TOS-Versionen wird die MPB-Variable gesucht      *
*      Etwas aussagekrÑftigere Fehlermeldungen                  *
*      neue ACC-Bootmethode (wie in CBHD.SYS), VBL-Liste kann   *
*      jetzt folgenlos im Autoordner verschoben werden          *
*      Anpassung an TOS 1.06                                    *
* V2.5 (6/90, CB): énderungen fÅr SuperCharger Åbernommen (12/  *
*      16-Bit-FAT wahlweise), Nachlaufhemmer verbessert         *
* V2.6 (8/90, CB+BR): Bei unbekannten TOS-Versionen wird die    *
*      MPB-Variable nach der (besseren) Methode von Bernd Rosen-*
*      lecher gesucht.                                          *
* V2.7 (3/91, CB): Anpassung an TOS 2.05, Versuche fuer TT      *
*      KILL_RRD noch anpassen! Neuer AUTO-Ordnertest            *
*      LÑuft jetzt im ST-RAM des TT, beim TT-RAM noch groûe     *
*      Probleme: PÑckchen werden nur im ST-RAM gesucht          *
* V2.8 (5/91, CB + T. Lang): Bootsektor eingebaut               *
* V2.9 (5/91, B. Rosenlecher, CB): Neue selbersuchen-Routine    *
* V2.91: Dreistellige Versionsnummern                           *
*      LÑnderkennung wird in alloc_mem geprÅft                  *
*      Bootmethode wie in CBHD (irgendwo muû noch ein Bug sein, *
*      stîût sich noch mit der CBHD-Methode)                    *
*      Kleine Umstellungen                                      *
* V2.92: LÑnderkennung wird im AUTO-Ordner anders geprÅft, um   *
*      dem AHDI-Hack in der Bootphase auszuweichen. Neue Such-  *
*      routine fÅr MPB.                                         *
* V2.93: CAPS-LOCK-Behandlung korrigiert                        *
* V2.94: Anpassung an englisches TOS 3.01                       *
*        Fehler beim öbertragen von Blîcken Åber den Bootsektor *
*        hinweg behoben                                         *
* V2.95: Wechselstatus kann per Rwabs() gesetzt werden          *
* V2.96: Anpassung an TOS 2.06 und 3.06                         *
* V2.97: TOS-Abfrage auf Tabelle umgestellt                     *
*        Tabelle beginnt mit einem Reserveeintrag und wird mit  *
*        der Kennung "TTAB" angekÅndigt; Rwabs() kennt auch     *
*        32-Bit-Sektornummern; Optimierungen; Luftschloû        *
*        kann wieder ACCs von sich booten, wenn CBHD lÑuft      *
*        In getgroesse war A5 nicht mehr gueltig                *
* V2.98: TOS 2.05 CH; kleine Optimierung bei Abfrage des        *
*        LÑndercodes                                            *
*****************************************************************

                ENDPART

                >PART 'Fehl und Tadel'

* - Probleme mit der ASO-Software

                ENDPART

                OPT F+          ; Schnelladebit an

                >PART 'Konstanten'

kennung         EQU "RSt-"      ; ID-Kennungen der RAM-Disk
kennung2        EQU "WINZ"      ; zweite Kennung (u.a. fÅr XBRA)

version         EQU "2"         ; Versionsnummer
rev             EQU "9"         ; Versionsnummer, 2. Stelle
rev2            EQU "8"

MITALLEM        EQU 0           ; Assemblierflag
fat12           EQU 0           ; 12-Bit-FAT
fat16           EQU 1           ; 16-Bit-FAT
debug           EQU 0

FRG             EQU 1
UK              EQU 3
CH              EQU 8

********************
* Systemvariablen
********************
tr2             EQU $88         ; Trap-2-Vektor
etv_timer       EQU $0400       ; Timer-Vektor
phystop         EQU $042E       ; physikalisches Speicherende
membot          EQU $0432       ; Unteres Speicherende
memtop          EQU $0436       ; Oberes Speicherende
bootdev         EQU $0446       ; Bootlaufwerk
nvbls           EQU $0454       ; LÑnge der VBL-Liste
vblqueue        EQU $0456       ; Start der VBL-Liste
hdv_bpb         EQU $0472       ; BPB-Vektor
hdv_rw          EQU $0476       ; RWABS-Vektor
hdv_mediach     EQU $047E       ; MEDIACH-Vektor
themd           EQU $048E       ; Ur-MD
drvbits         EQU $04C2       ; drvbits (angemeldete Laufwerke)
sysbase         EQU $04F2       ; ->TOS-Header
exec_os         EQU $04FE       ; ->AES-Start

fmemtop         EQU $05A4

groekb          EQU 200         ; Default-Grîûe in KB
; entsprechenden String in zahlstr eintragen!

                ENDPART

                >PART 'Initialisierung'

                TEXT
********************
* prgstart: Jetzt geht's aber los
********************
prgstart:
                movea.l 4(SP),A5        ; Basepageadr. in a5
                move.l  A5,basepage     ; merken
                movea.l 12(A5),A0       ; TextlÑnge
                adda.l  20(A5),A0       ; + DATA-LÑnge
                adda.l  28(A5),A0       ; + BSS-LÑnge
                adda.w  #$0500,A0       ; + Basepage etc.
                move.l  A0,D1
                add.l   A5,D1           ; plus BP-Adresse
                andi.b  #-2,D1          ; gerade machen
                movea.l D1,SP           ; Stackpointer neu setzen
                move.l  A0,-(SP)        ; genÅgend Speicher
                move.l  A5,-(SP)        ; ab Basepage
                clr.w   -(SP)           ; per
                move.w  #$4A,-(SP)      ; GEMDOS-MShrink
                trap    #1              ; reservieren (bzw. Rest freigeben)
                lea     12(SP),SP

                bsr.s   autotest        ; sind wir im Autoordner?

                pea     initall(PC)     ; eigentliche Initialisierung
                move.w  #38,-(SP)
                trap    #14
                addq.l  #6,SP

                clr.w   -(SP)           ; Pterm0
                trap    #1              ; fini!

autotest:
                lea     contrl(PC),A6   ; Zeiger setzen
                move.w  #10,(A6)+       ; appl_init, Anwendung anmelden
                move.l  #1,(A6)+        ; 1 Ausgabeparameter
                moveq   #0,D0
                move.l  D0,(A6)
                lea     global(PC),A6
                move.l  D0,(A6)
                bsr.s   aes

                move.w  global+2(PC),autoflag ; sind wir im AUTO-Ordner?
                beq.s   nurweg

                lea     contrl(PC),A6
                move.w  #19,(A6)+       ; appl_exit, Anwendung abmelden
                move.l  #1,(A6)+        ; 1 Ausgabeparameter
                clr.l   (A6)
aes:
                move.l  #aespb,D1
                move.w  #$C8,D0
                trap    #2
nurweg:
                rts

***********************
* initall: Initialisierungskram
*          muû im Supervisormodus laufen
***********************
initall:
                bsr     checkrdsk       ; RAM-Disk schon installiert?
                tst.b   D2
                bne.s   nurweg          ; ja, dann ohne Meldung beenden

                lea     inittext(PC),A6 ; Info-Text
                bsr     message         ; ausgeben

                bsr     getgroesse      ; Grîûe und evtl. Kennung holen

                moveq   #0,D0
                move.w  numcl(PC),D0    ; Disk-Grîûe in Clustern

                move.l  D0,D1           ; Cluster-Anzahl kopieren

                IF fat16
                add.l   D0,D1           ; Clusterzahl mal 2
                addq.l  #4,D1           ; plus 4 Bytes (Verwaltungsbytes)
                ENDC

                IF fat12
                asr.l   #1,D0           ; Clusterzahl/2
                addx.l  D0,D1           ; d1 = Clusterzahl * 1.5
                addq.l  #3,D1           ; plus 3 Bytes (Verwaltungsbytes)
                ENDC

                lsr.l   #8,D1           ; durch 256
                lsr.l   #1,D1           ; durch 2 (insgesamt also durch 512)
                addq.w  #1,D1           ; +1 zur Sicherheit
                move.w  D1,fat          ; FAT-Grîûe in Sektoren abspeichern
                addq.w  #1,D1           ; +1 (virtueller Bootsektor)
                move.w  D1,fat2         ; Beginn der zweiten FAT
                add.w   fat(PC),D1      ; +LÑnge einer FAT
                add.w   rdlen(PC),D1    ; +LÑnge des Wurzelverzeichnisses
                move.w  D1,datrec       ; ergibt ersten Datensektor

                subq.w  #1,D1           ; minus eins (Bootsektor nur virtuell)
                sub.w   fat(PC),D1      ; minus FAT-Grîûe (eine FAT nur virtuell)

                mulu    spc(PC),D0      ; Clusterzahl in Sektoren wandeln (mal SPC)
                add.l   D1,D0           ; + Verwaltungssektoren
                lsl.l   #8,D0           ; mal 256
                add.l   D0,D0           ; mal 2 (--> *512)
                move.l  D0,groesse      ; Gesamt-Grîûe der RAM-Disk in Bytes

                move.w  driveno(PC),D0  ; Kennung im Namen?
                bge.s   sbootdev        ; ja, weiter

                move.l  drvbits.w,D0    ; nein, freies Laufwerk finden
                moveq   #2,D1           ; mit 'D' beginnen
fdlp:
                lea     nodrives(PC),A6 ; "kein freies Laufwerk mehr"
                addq.w  #1,D1           ; nÑchstes Laufwerk
                cmpi.w  #16,D1          ; schon 'Q' erreicht?
                beq     error
nextdrv:
                btst    D1,D0           ; Laufwerk vorhanden?
                bne.s   fdlp            ; ja: nÑchstes Laufwerk
                bset    D1,D0           ; Laufwerk anmelden
                move.l  D0,drvbits.w    ; Systemvariable aktualisieren
                move.w  D1,driveno      ; Laufwerk fÅr RD-Routine abspeichern
                addi.b  #'A',D1         ; in String schreiben
                move.b  D1,instlw

sbootdev:
                move.b  bootdev+1.w,D0  ; Bootdevice holen
                ext.w   D0
                move.w  D0,oriboot      ; und heftig merken
                move.w  D0,resoboot

                move.l  #routend,D1     ; Routinenende bestimmen
                subi.l  #(routstart-512),D1 ; Routinengrîûe einschl. PÑckchen berechnen
                move.l  D1,routgroesse  ; und ablegen

                add.l   groesse(PC),D1  ; +'Diskgrîûe'
                bsr     alloc_mem       ; d1 Bytes unter memtop reservieren
                tst.l   D0              ; Fehler aufgetreten?
                bne.s   genugsp         ; nein, weiter
                move.l  drvbits.w,D0    ; ja, Laufwerk wieder abmelden
                move.w  driveno(PC),D1
                bclr    D1,D0
                move.l  D0,drvbits.w
                lea     memerror(PC),A6 ; "Fehler bei der Speicherreservierung"
                bra     error           ; Programm abbrechen

genugsp:
                move.l  memtop.w,mtop   ; neues memtop absp.
                move.l  memtop.w,resmtop
                move.l  D1,resmlen      ; LÑnge (tatsÑchlich reserviert) abspeichern

                movea.l D0,A5           ; Adresse der Reset-("PÑckchen")-Routine
                move.l  D0,puffer       ; als Pufferadresse
                move.l  routgroesse(PC),D1 ; plus Routinengrîûe
                add.l   D1,puffer
                addi.l  #512,D0         ; PÑckchen Åberspringen
                move.l  D0,resadr       ; Adresse speichern

                move.w  driveno(PC),resdrive ; Laufwerkskennung abspeichern

                move.l  A5,resproc+4    ; eigene Adr. eintragen
                lea     resproc(PC),A6  ; Start der Reset-Routine
                movea.l A5,A3           ; Zieladr. nach a3
                move.l  #resend,D0      ; LÑnge berechnen...
                sub.l   A6,D0
                lsr.l   #1,D0           ; durch 2 dividieren
                subq.l  #1,D0           ; und - 1 wegen dbra-Schleife
loop1:
                move.w  (A6)+,(A5)+     ; Reset-Routine kopieren
                dbra    D0,loop1

                moveq   #0,D1           ; Reg. lîschen
                move.w  #254,D2         ; 255 Worte addieren
loop2:
                add.w   (A3)+,D1        ; PrÅfsumme bilden
                dbra    D2,loop2
                move.w  #$5678,D2       ; Summe von magic abziehen
                sub.w   D1,D2
                move.w  D2,(A3)         ; Ausgleichssumme eintragen

                movea.l resadr(PC),A5   ; Zieladresse
                lea     routstart(PC),A6 ; Startadresse
                move.l  #routend,D0     ; LÑnge berechnen
                sub.l   A6,D0
                lsr.l   #1,D0           ; (/2)-1 wegen fÅr Kopierschleife
                subq.l  #1,D0
loop3:
                move.w  (A6)+,(A5)+     ; Residente Routinen kopieren
                dbra    D0,loop3

; RAM-Disk-Verwaltungssektoren lîschen
                movea.l puffer(PC),A0   ; 'Diskadresse'
                moveq   #0,D0
                move.w  datrec(PC),D0   ; Erster Datensektor
                subq.w  #1,D0           ; Bootsektor nur virtuell
                sub.w   fat(PC),D0      ; minus FAT-Grîûe (eine FAT nur virtuell)
                lsl.l   #7,D0           ; mal 128
                subq.l  #1,D0           ; und minus eins fÅr dbra
clearit:
                clr.l   (A0)+           ; Verwaltungssektoren lîschen
                dbra    D0,clearit

                st      D7              ; Flag setzen
                movea.l resadr(PC),A0   ; Routinen ausfÅhren
                jmp     (A0)            ; und danach zum Programmende

*****************
* error: Fehlerbehandlung
* IN: A6   -> Fehlerstring
*****************
error:
                bsr     message
                move.w  autoflag(PC),D0 ; sind wir im AUTO-Ordner?
                beq.s   errorende       ; ja, weiter
                move.w  #7,-(SP)        ; Auf Tastendruck warten
                trap    #1
                addq.l  #2,SP
errorende:      rts                     ; und Programmende

                ENDPART

                >PART 'Groesse ermitteln'

*********************
* getgroesse: Grîûe in KB und
*             Kennung aus Basepage/Namen lesen
*********************
getgroesse:
                movea.l basepage(PC),A5 ; Basepageadresse holen
                lea     128(A5),A0
                tst.b   (A0)            ; Kommandozeile leer?
                beq.s   s_dname         ; ja, weiter
                addq.l  #1,A0           ; Stringadresse fÅr Auswertung
                bra.s   analyse         ; und auswerten

s_dname:
                clr.w   -(SP)           ; Prg-Datei suchen
                pea     filename(PC)    ; ->'RR*.PRG'
                move.w  autoflag(PC),D0 ; sind wir im AUTO-Ordner?
                bne.s   noauto          ; nein, weiter
                lea     fname2(PC),A5
                move.l  A5,(SP)         ; sonst: '\AUTO\RR*.PRG'
noauto:
                move.w  #$4E,-(SP)      ; FSFirst
                trap    #1              ; GEMDOS
                addq.l  #8,SP
                tst.w   D0              ; Datei gefunden?
                bne     eingende        ; nicht gefunden -> Default-Werte

                move.w  #$2F,-(SP)      ; Fgetdta, DTA-Adresse holen
                trap    #1              ; GEMDOS
                addq.l  #2,SP
                addi.l  #30+2,D0        ; Zeiger auf Dateiname (nach 'RR')
                movea.l D0,A0           ; in a0
analyse:
                move.b  (A0)+,ramboot   ; von RAM-Disk booten?
                moveq   #4,D0           ; hîchstens vier Bytes
                moveq   #0,D1           ; Register lîschen (Grîûe)
                clr.w   D2              ; (Byteinhalt)
                lea     zahlstr(PC),A1  ; Ausgabe-String
eingloop:
                move.b  (A0),D2         ; Byte auslesen
                sub.b   #'0',D2         ; < '0' ?
                blt.s   keineziff
                cmpi.b  #9,D2           ; > '9' ?
                bgt.s   keineziff
                addq.l  #1,A0           ; Adr. erhîhen
                mulu    #10,D1          ; akt. Wert * 10
                add.l   D2,D1           ; + neue Ziffer
                tst.b   D2
                bne.s   znicht0
                tst.w   D1              ; fÅhrende 0 ? (Wert noch 0)
                beq.s   erste0
znicht0:
                add.w   #'0',D2
                move.b  D2,(A1)+        ; nein: Ziffer in String speichern
erste0:         dbra    D0,eingloop     ; nÑchste Ziffer

keineziff:
                tst.w   D1              ; nichts bzw. 0 als Grîûe?
                beq.s   kenneing        ; ja, weiter
                move.w  D1,numcl        ; sonst: Clusterzahl in BPB eintr.
                clr.b   (A1)            ; Nullbyte an String anhÑngen
kenneing:
                clr.w   D2
                move.b  (A0),D2         ; Byte auslesen
                cmpi.b  #'C',D2         ; < 'C' ?
                blt.s   eingende
                cmpi.b  #'P',D2         ; > 'P' ?
                bgt.s   eingende
                move.b  D2,instlw       ; Kennung (als Buchst.) abspeichern
                subi.w  #'A',D2         ; in Zahl konvertieren
                move.l  drvbits.w,D0    ; Laufwerk schon vorhanden?
                btst    D2,D0
                bne.s   eingende        ; ja: spÑter freies LW finden
                bset    D2,D0           ; nein: Laufwerk anmelden
                move.l  D0,drvbits.w
                move.w  D2,driveno      ; Kennung abspeichern
eingende:
                rts                     ; zurÅck zum Hauptprogramm

                ENDPART

                >PART 'Nach Luftschloss suchen'

*********************
* checkrdsk: RAM-Disk schon installiert?
* OUT: d2.b <>0: RAM-Disk schon da
*********************
checkrdsk:
                clr.b   D2              ; Reg. lîschen
                movea.l phystop.w,A0    ; von phystop abwÑrts untersuchen
chloop:         lea     -512(A0),A0     ; minus 512
                cmpa.l  #$0400,A0       ; schon Systemvar. erreicht?
                beq.s   chexit
                cmpi.l  #$12123456,(A0) ; magic?
                bne.s   chloop
                cmpa.l  4(A0),A0        ; eigene Adresse?
                bne.s   chloop
                cmpi.l  #kennung,10(A0) ; Kennung richtig?
                bne.s   chloop
                cmpi.l  #kennung2,14(A0) ; Kennung richtig?
                bne.s   chloop
                clr.w   D0
                movea.l A0,A1
                move.w  #255,D1         ; Åber 256-1 Worte
chaloop:
                add.w   (A1)+,D0        ; PrÅfsumme bilden
                dbra    D1,chaloop
                cmpi.w  #$5678,D0       ; Magic?
                bne.s   chloop          ; nein, weitersuchen
                st      D2              ; ja, wir haben's; Flag setzen
chexit:         rts

                ENDPART

                >PART 'PÑckchen'

*************************
* resproc: Reset-Routine ("PÑckchen")
* liegt vor den eigentlichen Routinen
* im reservierten Bereich an einer
* 512-Byte-Adresse
*************************
resproc:
                DC.L $12123456  ; Magic
                DC.L 0          ; Platz fÅr die eigene Adresse

                bra.s   resstart        ; Kennung Åberspringen

                DC.L kennung,kennung2 ; Kennung der Reset-Routine

resmlen:
                DC.L 0          ; LÑnge des reserv. Speichers
resdrive:
                DC.W 0          ; RAM-Disk-Handle
resoboot:
                DC.W 0          ; Original-Bootdevice
resmtop:
                DC.L 0          ; neues memtop

resstart:
                movem.l D0-A6,-(SP)     ; Register retten
                movea.l resadr(PC),A0   ; Routinenadr. holen
                sf      D7              ; Flag lîschen
                jsr     (A0)
                movem.l (SP)+,D0-A6     ; Register zurÅck
                rts                     ; weiter im Reset

resadr:         DC.L 0
resend:

                ENDPART

                >PART 'Residente Routinen'

****************************
* routstart: Anfang der residenten Routinen
*            Der folgende Abschnitt wird in den
*            reservierten Bereich kopiert
****************************
routstart:
                tst.b   D7              ; erste Initialisierung?
                bne.s   rinst1
; Speicher reservieren
                move.l  memtop.w,D1     ; memtop
                sub.l   mtop(PC),D1     ; minus altes memtop
                move.l  groesse(PC),D2  ; Grîûe der RAM-Disk in Bytes
                add.l   routgroesse(PC),D2 ; + ProgrammlÑnge
                cmp.l   D2,D1           ; zu groû?
                blt     ierror          ; ja, Fehler! Jemand hat memtop manipuliert!
                bsr     alloc_mem       ; Speicher reservieren
                tst.l   D0              ; Fehler?
                beq     ierror          ; ja
rinst1:
                lea     o_bpb(PC),A0    ; Vektoren umbiegen
                move.l  hdv_bpb.w,(A0)
                lea     mybpb(PC),A0
                move.l  A0,hdv_bpb.w

                lea     o_rw(PC),A0
                move.l  hdv_rw.w,(A0)
                lea     myrwabs(PC),A0
                move.l  A0,hdv_rw.w

                lea     o_media(PC),A0
                move.l  hdv_mediach.w,(A0)
                lea     mymedia(PC),A0
                move.l  A0,hdv_mediach.w

                move.l  drvbits.w,D0    ; Laufmerk anmelden
                move.w  driveno(PC),D1
                bset    D1,D0
                move.l  D0,drvbits.w

                tst.b   D7              ; erste Initialisierung?
                bne.s   rinst2

* Diese Sequenz soll verhindern, daû das Laufwerk A beim Booten von
* der RAM-Disk endlos nachlÑuft.
                move    SR,-(SP)        ; Status retten
                ori     #$0700,SR       ; IRQs aus
                move.b  #14,$FFFF8800.w ; Port A selektieren
                move.b  $FFFF8800.w,D0  ; aktuellen Wert holen
                bset    #2,D0           ; B: deselektieren
                bne.s   sel_ok          ; war schon deselektiert? Dann weiter
                bclr    #1,D0           ; A: selektieren
                move.b  D0,$FFFF8802.w  ; und zurÅckschreiben
sel_ok:
                move    (SP)+,SR        ; IRQs wieder an

rinst2:
                lea     vorspann(PC),A6 ; Grîûe der RAM-Disk
                bsr     message         ; ausgeben
                lea     insttext(PC),A6 ; und das restliche Gelaber
                bsr     message         ; auch

                tst.b   D7              ; erste Initialisierung?
                bne.s   rinst3

                pea     $0BFFFF         ; kbshift
                trap    #13             ; BIOS
                addq.l  #4,SP

                lea     ramboot(PC),A0
                cmpi.b  #'D',(A0)       ; Default: Von RAM-Disk booten?
                beq.s   wirbeamen       ; ja

                btst    #4,D0           ; CAPS LOCK gedrÅckt?
                beq.s   noboot          ; nein, nicht aus RD booten
                bsr.s   capsback        ; CAPS LOCK zurÅcksetzen
                bra.s   ausderluft      ; und aus dem LUFTSCHLOSS booten

wirbeamen:
                btst    #4,D0           ; CAPS LOCK gedrÅckt?
                beq.s   ausderluft      ; nein: booten

noboot:                                 ; Original-Bootlaufwerk anmelden
                bsr.s   capsback        ; CAPS LOCK zurÅcksetzen

                moveq   #0,D3
                move.b  bootdev+1.w,D3  ; altes Bootlaufwerk
                cmp.w   driveno(PC),D3  ; unser Laufwerk?
                bne.s   setdrive        ; nein, weiter
                move.w  oriboot(PC),D3  ; altes Bootlaufwerk
setdrive:
                move.w  D3,-(SP)
                move.w  #14,-(SP)       ; Dsetdrv
                trap    #1
                addq.l  #4,SP
                cmp.b   bootdev+1.w,D3
                beq.s   rinst3
                move.b  D3,bootdev.w
                move.b  D3,bootdev+1.w  ; wegen BIOS-Fehler
rinst3:
                lea     instcopyrt(PC),A6 ; Copyright ausgeben
                bra.s   continit

ausderluft:
                move.w  driveno(PC),-(SP) ; RAM-Disk ist aktuelles Laufwerk
                move.w  #14,-(SP)       ; Dsetdrv
                trap    #1              ; GEMDOS
                addq.l  #4,SP

                move.b  driveno+1(PC),bootdev.w ; Sowohl Hi- als auch Low-Byte
                move.b  driveno+1(PC),bootdev+1.w ; setzen (wegen BIOS-Fehler)

                lea     exec_os+4.w,A0
xbraweiter:
                movea.l -4(A0),A1       ; Vektorinhalt holen
                cmpi.l  #"XBRA",-12(A1) ; XBRA-Kennung?
                bne.s   einhaengen      ; nein, reinhaengen
                movea.l A1,A0
                bra.s   xbraweiter
; A1: aktuelle Vektoradresse
; A0: vorherige Vektoradresse
einhaengen:
                lea     o_execos(PC),A2
                move.l  A1,(A2)         ; alten Zeiger retten
                lea     bootexec(PC),A1
                move.l  A1,-4(A0)       ; eigene Routine einklinken

                lea     instboot(PC),A6 ; fÅr Ausgabe v. Boot-Text
continit:
                bsr     message

ierror:
                IF MITALLEM
; Setzt man das Assemblierflag MITALLEM, werden die folgenden
; Routinchen eingebunden; es kann jeder nach Belieben was Neues
; hinzudichten (Bîmbchen auf eigene Gefahr), was beim Booten
; nÅtzlich sein kînnte...

; evt. andere Initialisierungsroutinen aufrufen:
                tst.b   D7              ; nur wenn nicht erste Initialisierung
                bne.s   fixnfertig

******************
* initrouts: Beliebige Initialisierungsaufgaben
******************
initrouts:
; Zeit aus Tastatur-Prozessor holen
                move.w  #23,-(SP)       ; GETTIME, Datum und Zeit lesen
                trap    #14             ; XBIOS
                addq.l  #2,SP
                move.l  D0,D1           ; retten
                move.w  D0,-(SP)        ; Zeit per
                move.w  #$2D,-(SP)      ; Tsettime
                trap    #1              ; im GEMDOS
                addq.l  #4,SP           ; setzen
                swap    D1              ; Datum holen
                move.w  D1,-(SP)        ; und gleich per
                move.w  #$2B,-(SP)      ; Tsetdate
                trap    #1              ; im GEMDOS
                addq.l  #4,SP

                bclr    #0,$0484.w      ; Tastaturklick aus

; Druckerkonfig. einstellen
                move.l  #$210004,-(SP)  ; Setprt fÅr EPSON-Drucker
                trap    #14             ; XBIOS
                addq.l  #4,SP

                ENDC

fixnfertig:
                rts                     ; zurÅck zur PÑckchenroutine

capsback:
                bclr    #4,D0           ; CAPS LOCK
                move.w  D0,-(SP)        ; wieder zurÅcksetzen
                move.w  #11,-(SP)       ; KbShift
                trap    #13
                addq.l  #4,SP
                rts

                ENDPART

                >PART 'XBRA-Routinen'

***********************************
* rm_xbra: Programm aus XBRA-Kette entfernen
* IN: A0.L Basisvektor der Kette
*     A1.L alter Kettenzustand aus XBRA-Struktur
*     D0.L XBRA-Magic
***********************************
rm_xbra:        movem.l A0-A1,-(SP)     ; alte Vektoren merken
                bsr.s   xbralook
                move.l  A0,D0           ; was gefunden?
                ble.s   rm_ende         ; D0 kleinergleich 0, dann nix gefunden
                move.l  A1,D0           ; gibt es einen VorgÑnger?
                bmi.s   wiefrueher      ; nein
                move.l  4(SP),-4(A1)    ; alten Kettenzustand wiederherstellen
                bra.s   rm_ende
wiefrueher:
                movea.l 4(SP),A0        ; alter Kettenzustand
                movea.l (SP),A1
                move.l  A0,(A1)
rm_ende:
                movem.l (SP)+,A0-A1     ; Register holen
                rts

****************************
* xbralook: Sucht in einer Vektorkette
* nach einem Eintrag
* IN: A0.L Vektoradresse
*     D0.L Magic
* OUT: A0.L Startadresse der gesuchten Routine oder -1L oder 0L
*      A1.L Zeiger auf VorgÑnger in der Vektorkette oder -1L
*           A0.L = 0L
*           A1.L = -1L: Kette brach mit Nullzeiger ab, Magic nicht gefunden
*
*           A0.L = -1L
*           A1.L = -1L: Kette ist nicht vollstÑndig xbraisiert, Magic
*                       nicht gefunden
* USES: A0, D0, A1
****************************
xbralook:
                movea.w #-1,A1          ; prev = -1
                movea.l (A0),A0         ; erster Zeiger
xwhile:
                cmpa.l  #0,A0           ; 0?
                beq.s   xbraout
                cmpi.l  #"XBRA",-12(A0) ; nach XBRA suchen
                bne.s   xbranfnd
                cmp.l   -8(A0),D0       ; Magic?
                beq.s   xbraout
                movea.l A0,A1
                movea.l -4(A0),A0       ; VorgÑnger holen
                bra.s   xwhile
xbranfnd:
                movea.w #-1,A1
                movea.l A1,A0           ; nichts gefunden
xbraout:
                rts

                ENDPART

                >PART 'ACC-Boot'

******************
* bootexec: Installiert Trap-2-Handler fÅr ACC-Boot
******************

                DC.B "XBRA"
                DC.L kennung2
o_execos:
                DC.L 0
bootexec:
                clr.l   -(SP)
                move.w  #32,-(SP)       ; Super
                trap    #1              ; GEMDOS
                addq.l  #6,SP
                move.l  D0,-(SP)

; das AES ist da - C: abmelden
                move.w  driveno(PC),D0
                bsr     setdrv          ; aktuelles Laufwerk im act_pd setzen
                move.w  D0,bootdev.w

                move.w  D0,-(SP)        ; aktuelles Laufwerk setzen
                move.w  #14,-(SP)       ; Dsetdrv
                trap    #1
                addq.l  #4,SP

                lea     o_bits(PC),A0
                move.l  drvbits.w,(A0)  ; drvbits
                bclr    #2,drvbits+3.w  ; Laufwerk C abmelden

                lea     exec_os.w,A0    ; execos-Kette durchsuchen
                move.l  #kennung2,D0    ; nach unserem Magic
                movea.l o_execos(PC),A1 ; alter Kettenzustand
                bsr     rm_xbra         ; aus Kette entfernen

                st      bootphase

                lea     o_trap2(PC),A0
                move.l  tr2.w,(A0)      ; alten Vektor merken
                lea     gettr2(PC),A0
                move.l  A0,tr2.w        ; in Trap 2 einhÑngen

                move.w  #32,-(SP)       ; Super
                trap    #1              ; GEMDOS
                addq.l  #6,SP

                move.l  o_execos(PC),-(SP)
                rts

***************************
* gettr2: Trap-2-Handler wÑhrend der Bootphase
****************************
                DC.B "XBRA"     ; noch ein XBRA-Header
                DC.L kennung2
o_trap2:
                DC.L 0          ; alter Wert des Vektors
gettr2:
                lea     bootphase(PC),A0
                tst.w   (A0)            ; sind wir noch in der Bootphase?
                beq.s   keinrom         ; nein, weiter
                cmp.w   #$73,D0         ; VDI-Aufruf?
                bne.s   keinrom

                movem.l D0-D2/A0-A2,-(SP)
                movea.l D1,A0           ; Zeiger auf VDIPB
                movea.l (A0),A0         ; Zeiger auf contrl[]
                cmpi.w  #1,(A0)         ; v_opnwk?
                bne.s   trap2exit

                lea     bootphase(PC),A0
                clr.w   (A0)            ; Booten ist vorbei

                move.l  o_bits(PC),D0   ; alter drvbits-Vektor
                and.w   #4,D0           ; Bit fÅr Laufwerk C: ausmaskieren
                or.w    D0,drvbits+2.w  ; evt. C: wieder anmelden
                move.w  driveno(PC),D0
                bsr.s   setdrv          ; aktuelles Laufwerk im act_pd setzen

; unseren Traphandler wieder aushÑngen
                lea     tr2.w,A0        ; Trap-2-Kette durchsuchen
                move.l  #kennung2,D0    ; nach dem Magic
                movea.l o_trap2(PC),A1  ; alter Kettenzustand
                bsr     rm_xbra         ; aus Kette austragen

trap2exit:
                movem.l (SP)+,D0-D2/A0-A2 ; Register holen
keinrom:
                move.l  o_trap2(PC),-(SP)
                rts


*********************
* setdrv:
* aktuelles Laufwerk (D0.W) im act_pd setzen
********************
setdrv:
* je nach TOS-Version Zeiger auf act_pd liefern
                movea.l sysbase.w,A0    ; sysbase
                move.w  2(A0),D1        ; TOS-Version
                lea     $602C.w,A1      ; Default fuer act_pd bei TOS 1.0
                cmp.w   #$0102,D1       ; schon BlitterTOS?
                bmi.s   getapexit       ; nein
                movea.l $28(A0),A1      ; act_pd-Adresse holen
getapexit:
                movea.l (A1),A0         ; Zeiger auf aktuelle Basepage
                move.b  D0,$37(A0)      ; aktuelles Laufwerk setzen
                rts

                ENDPART

                >PART 'Stringausgabe'

*******************
* message: Gibt Texte aus
* IN:  a6 Stringadresse
*******************
message:
                move.l  A6,-(SP)        ; Stringadresse
                move.w  #9,-(SP)        ; Cconws
                trap    #1              ; GEMDOS
                addq.l  #6,SP
                rts

                ENDPART

***********************
* Ab hier folgen die eigentlichen
* RAM-Disk-Routinen (CB)
***********************

                >PART 'Getbpb'

******************
* mybpb: Eigene GETBPB-Routine
******************
                DC.B "XBRA"     ; XBRA-Struktur
                DC.L kennung2
o_bpb:          DC.L 0          ; ursprÅngliche Adresse
mybpb:
                move.w  driveno(PC),D0
                cmp.w   4(SP),D0        ; RAM-Disk gemeint?
                beq.s   newbpb          ; ja: an die Arbeit...
                movea.l o_bpb(PC),A0    ; Original-Routine aufrufen
                jmp     (A0)

newbpb:
                lea     wechselstatus(PC),A0
                clr.w   (A0)            ; eigenen Wechselstatus lîschen
                lea     protobpb(PC),A0 ; Zeiger zurÅckgeben
                move.l  A0,D0
                rts                     ; das war's

                ENDPART

                >PART 'Rwabs'

********************
* myrwabs: Eigene RWABS-Routine
********************
                DC.B "XBRA"     ; XBRA-Struktur
                DC.L kennung2
o_rw:           DC.L 0          ; ursprÅngliche Adresse
myrwabs:
                move.w  driveno(PC),D0
                cmp.w   14(SP),D0       ; RAM-Disk gemeint?
                beq.s   newrw           ; ja: an die Arbeit...
                movea.l o_rw(PC),A0     ; Original-Routine aufrufen
                jmp     (A0)

newrw:                                  ; RWABS-Routine
                move.l  6(SP),D0        ; Pufferadresse holen
                beq     chgstatus       ; gleich 0, dann neuen Wechselstatus setzen
                movea.l D0,A0           ; Pufferadresse merken
                move.w  10(SP),D1       ; Sektoranzahl holen

                move.w  12(SP),D0       ; Ab welchem Sektor?
                bpl.s   rwtstboot       ; >=0 ?
                move.l  16(SP),D0       ; lange Sektornummer
rwtstboot:
                bgt.s   nobootsec       ; kein Bootsektor gemeint
                moveq   #0,D2           ; Testen, ob Bootsektor gelesen werden
                btst    D2,5(SP)        ; soll (T. Lang)
                beq.s   bootsec         ; Pseudo-Bootsektor lesen (T. Lang)
                moveq   #-7,D0          ; Unknown Media - Bootsektor nicht lesbar
                rts                     ; und raus

; Neue Routine (C) 1990 Torsten Lang
; Neue Routine, liefert einen Pseudo-Bootsektor, da einige Programme
; (insbesondere Neodesk3) mosern, wenn der Bootsektor nicht verfÅgbar ist.
; Ja, ja, man hÑtte diese Routine mit move.w bzw. move.l schneller machen
; kînnen, dann wÑre sie aber lÑnger (PrÅfung auf ungerade Adressen).
; Auûerdem kommt's hier wirklich nicht drauf an!

bootsec:
                moveq   #10,D2          ; 11 Bytes
btsclr0:        clr.b   (A0)+           ; lîschen
                dbra    D2,btsclr0
; Bootsektordaten Åbertragen
                move.b  protobpb+1(PC),(A0)+ ; BPS im Intel-Format
                move.b  protobpb(PC),(A0)+
                move.b  spc+1(PC),(A0)+ ; SPC
                move.b  #1,(A0)+        ; RES im Intel-Format (1)
                clr.b   (A0)+           ; Hibyte lîschen
                move.b  #2,(A0)+        ; Anzahl der FATs
                move.w  rdlen(PC),D2    ; NDIRS errechnen
                lsl.w   #4,D2           ; durch 16
                move.b  D2,(A0)+        ; Im Intel-Format speichern
                lsr.w   #8,D2           ; Highbyte runtershiften
                move.b  D2,(A0)+        ; und speichern
                move.w  numcl(PC),D2    ; Anzahl der Cluster
                mulu    spc(PC),D2      ; mal SPC
                addq.w  #1,D2           ; + 1 reservierter Sektor
                add.w   fat(PC),D2      ; plus FAT-Sektoren
                add.w   fat(PC),D2
                add.w   rdlen(PC),D2    ; plus DIR-Sektoren
                move.b  D2,(A0)+        ; SEC Im Intel-Format speichern
                lsr.w   #8,D2
                move.b  D2,(A0)+
                clr.b   (A0)+           ; MEDIA (muû in diesem Fall ja nicht
; DOS-kompatibel sein!)
                move.b  fat+1(PC),(A0)+ ; SPF im Intel-Format speichern
                move.b  fat(PC),(A0)+
                move.b  #9,(A0)+        ; SPT (9 Sektoren/Spur) im Intel-Format
                clr.b   (A0)+
                move.b  #2,(A0)+        ; SIDE (2 Seiten) im Intel-Format
                clr.b   (A0)+
                move.w  #483,D2         ; Rest des Bootsektors lîschen
btsclr1:        clr.b   (A0)+
                dbra    D2,btsclr1
                addq.w  #1,D0           ; Startsektor + 1
                subq.w  #1,D1           ; 1 Sektor ist erledigt

; IN: D1  Anzahl der zu Åbertragenden Sektoren
;     A0  Pufferadresse aus Rwabs-Aufruf
;     D0  Startsektor
nobootsec:
                move.l  A0,-(SP)
                lea     wechselstatus(PC),A0
                move.w  (A0),D2         ; Wechselstatus holen
                clr.w   (A0)            ; und lîschen
                movea.l (SP)+,A0

                btst    #1,5(SP)        ; Medienwechsel beachten?
                bne.s   bootcont        ; nein, weiter
                tst.w   D2              ; gab es einen Wechsel?
                beq.s   bootcont        ; nein, weiter
                moveq   #-14,D0         ; Wechselfehler
                rts                     ; und raus

bootcont:
                tst.w   D1              ; noch Sektoren Åbrig?
                beq     rwexit          ; nein, ohne Fehler raus

                move.w  D0,D2           ; Startsektor
                add.w   D1,D2           ; plus Anzahl
                lea     fat2(PC),A2
                cmp.w   (A2),D2         ; letzter Sektor vor FAT2?
                ble.s   rw_rout
                sub.w   -2(A2),D0       ; Sektornummer minus FAT-LÑnge
                cmp.w   #1,D0           ; Zugriff auf FAT1 und FAT2?
                bge.s   rw_rout         ; nein

                movem.l D0-D2/A0-A1,-(SP) ; Register retten
                move.w  24(SP),-(SP)    ; fÅr erneuten Aufruf -- 4(sp)
; im ersten Durchgang bis FAT1-Ende kopieren
                moveq   #1,D1
                sub.w   D0,D1           ; Anzahl der Sektoren
                move.w  D1,D2
                ext.l   D2
                swap    D2
                lsr.l   #7,D2
                movea.l D2,A2           ; in Bytes fÅr Adreûdifferenz
                add.w   fat(PC),D0      ; + FAT-LÑnge
                bsr.s   rw_rout         ; ans Werk
                addq.l  #2,SP           ; Stack korrigieren
                movem.l (SP)+,D0-D2/A0-A1 ; Register zurÅck
; zweiter Durchgang: Ab FAT2 (=FAT1) kopieren
                add.w   D0,D1
                subq.w  #1,D1           ; Anzahl der Sektoren
                moveq   #1,D0           ; Startsektor = 1
                adda.l  A2,A0           ; Pufferadresse korrigieren

rw_rout:
                ext.l   D0
                subq.w  #1,D0           ; Sektornummer minus eins (Bootsektor
; ist virtuell!)
                swap    D0
                lsr.l   #7,D0           ; mal 512
; schneller als "lsl.l #8,d0 - add.l d0,d0"

                movea.l puffer(PC),A1   ; 'Diskadresse'
                adda.l  D0,A1           ; plus Offset
                moveq   #0,D2           ; Bitnummer 0
                btst    D2,5(SP)        ; R/W-Flag testen
                beq.s   copysec         ; Lesen (a0: Ziel, a1: Quelle)
                exg     A0,A1           ; Schreiben: Adressen vertauschen
copysec:
                move.l  A0,D0           ; Adresse gerade?
                btst    D2,D0           ; Bit 0 gesetzt?
                bne.s   ungerade        ; ja, dann ungerade Adresse
                move.l  A1,D0           ; Adresse gerade?
                btst    D2,D0           ; Bit 0 gesetzt?
                beq.s   gerade          ; nein, dann gerade

ungerade:
                subq.w  #1,D1           ; -1 wegen dbra
u1:             moveq   #63,D0          ; 64*8 Bytes kopieren

cplp:
                move.b  (A1)+,(A0)+
                move.b  (A1)+,(A0)+
                move.b  (A1)+,(A0)+
                move.b  (A1)+,(A0)+
                move.b  (A1)+,(A0)+
                move.b  (A1)+,(A0)+
                move.b  (A1)+,(A0)+
                move.b  (A1)+,(A0)+
                dbra    D0,cplp         ; die nÑchsten 8 Bytes
                dbra    D1,u1           ; nÑchster Sektor
                bra.s   rwexit          ; ohne Fehler raus

gerade:
                movem.l D2-D7/A2-A6,-(SP) ; Register retten
                move.w  D1,-(SP)        ; ZÑhler auf Stack
cpeven:
                movem.l (A1)+,D0-D7/A2-A6 ; 52 Bytes holen
                movem.l D0-D7/A2-A6,(A0) ; und schreiben
                movem.l (A1)+,D0-D7/A2-A6 ; 52 Bytes holen
                movem.l D0-D7/A2-A6,52(A0) ; und schreiben
                movem.l (A1)+,D0-D7/A2-A6 ; 52 Bytes holen
                movem.l D0-D7/A2-A6,104(A0) ; und schreiben
                movem.l (A1)+,D0-D7/A2-A6 ; 52 Bytes holen
                movem.l D0-D7/A2-A6,156(A0) ; und schreiben
                movem.l (A1)+,D0-D7/A2-A6 ; 52 Bytes holen
                movem.l D0-D7/A2-A6,208(A0) ; und schreiben
                movem.l (A1)+,D0-D7/A2-A6 ; 52 Bytes holen
                movem.l D0-D7/A2-A6,260(A0) ; und schreiben
                movem.l (A1)+,D0-D7/A2-A6 ; 52 Bytes holen
                movem.l D0-D7/A2-A6,312(A0) ; und schreiben
                movem.l (A1)+,D0-D7/A2-A6 ; 52 Bytes holen
                movem.l D0-D7/A2-A6,364(A0) ; und schreiben
                movem.l (A1)+,D0-D7/A2-A6 ; 52 Bytes holen
                movem.l D0-D7/A2-A6,416(A0) ; und schreiben
                movem.l (A1)+,D0-D7/A2-A4 ; 44 Bytes holen
                movem.l D0-D7/A2-A4,468(A0) ; und schreiben
                lea     512(A0),A0
                subq.w  #1,(SP)         ; ZÑhler auf Stack dekrementieren
                bne.s   cpeven          ; nÑchster Sektor
; diese Verschiebeschleife ist auf einem 8-MHz-ST 13.51 MBit/s schnell -
; wer schafft mehr, ohne die IRQs auszuschalten?
                addq.w  #2,SP           ; Stack justieren
                movem.l (SP)+,D2-D7/A2-A6 ; Register zurÅckholen

rwexit:
                moveq   #0,D0
                rts

chgstatus:
                lea     wechselstatus(PC),A0
                move.w  10(SP),(A0)     ; neuen Wechselstatus Åbernehmen
                bra.s   rwexit          ; ohne Fehler raus

                ENDPART

                >PART 'Mediach'

*************************
* mymedia: Eigene Mediachange-Routine
*************************
                DC.B "XBRA"     ; XBRA-Struktur
                DC.L kennung2
o_media:
                DC.L 0          ; ursprÅngliche Adresse
mymedia:
                move.w  driveno(PC),D0
                cmp.w   4(SP),D0        ; RAM-Disk gemeint?
                beq.s   newmedia        ; ja: an die Arbeit...
                movea.l o_media(PC),A0  ; Original-Routine aufrufen
                jmp     (A0)

newmedia:
                moveq   #0,D0           ; D0 vorbesetzen
                move.w  wechselstatus(PC),D0 ; Wechselstatus holen
                rts                     ; und raus


                ENDPART

                >PART 'Speicher reservieren'

********************
* alloc_mem: GEMDOS-Speicherverwaltung manipulieren
*           (Dank an Alex Esser, siehe auch ST-Computer-Sonderheft Nr.2)
* IN:  d1.l Grîûe des zu reservierenden Speicherblocks
*           Die Routine rundet die Startadresse auf die nÑchstgelegene
*           512-Byte-Grenze unterhalb der eigentlich erforderlichen Grenze
*      d1.l = 0: Nur Grîûe des obersten SpeicherhÑppchens holen
* OUT: d0.l Startadresse/neues memtop
*           oder: Grîûe des obersten SpeicherstÅcks (wenn d1.l=0)
*           oder: 0L (Fehler)
* USES: D0, D1, D2, A0, A1
********************
alloc_mem:
                movea.l $04F2.w,A0      ; sysbase
                movea.l 8(A0),A0        ; TOS-Startadresse ermitteln
getcountry:
                move.w  $1C(A0),D2      ; LÑnderkennung holen
                asr.w   #1,D2           ; PAL-Flag raus

                lea     tostab(PC),A1   ; Zeiger auf TOS-Tabelle
checkentry:
                move.w  (A1),D0         ; TOS-Versionsnummer
                beq     selbersuchen    ; Tabelle zu Ende, selbst suchen
                cmp.w   2(A0),D0        ; richtige Version?
                bne.s   nextentry       ; nein, weiter
                cmp.w   2(A1),D2        ; richtiges Land?
                bne.s   nextentry       ; nein, weiter
                move.l  4(A1),D0        ; TOS-Datum
                bmi.s   getentry        ; negativ, dann holen
                cmp.l   24(A0),D0       ; richtiges Datum?
                beq.s   getentry        ; ja, dann holen
nextentry:
                lea     12(A1),A1       ; Zeiger auf nÑchsten Eintrag
                bra.s   checkentry      ; prÅfen

getentry:
                movea.l 8(A1),A0        ; MPB-Adresse holen
alloc_st:
                move.l  (A0),D0         ; Zeiger auf mfl-Beginn
                beq.s   err             ; mfl leer!
                moveq   #0,D2           ; Default fuer letzten freien Block im ST-RAM
src_fr1:
                btst    #0,7(A0)        ; Startadresse ungerade?
                bne.s   nextone

                move.l  A0,D2           ; MD merken
nextone:
                move.l  (A0),D0         ; nÑchster MD
                beq.s   amende
                movea.l D0,A0
                bra.s   src_fr1
amende:
                move.l  D2,D0
                beq.s   err             ; kein freier Block im ST-RAM
                movea.l D2,A0

                move.l  memtop.w,D0

                move.l  4(A0),D2        ; M_START
                sub.l   D2,D0           ; Obergrenze minus M_START = freier Speicher
                cmp.l   8(A0),D0        ; M_LENGTH, sollte gleich sein
                bhi.s   err             ; ungleich, Speicherverwaltung durcheinander
                tst.l   D1              ; reservieren oder nur abfragen?
                beq.s   ok              ; nur abfragen
                cmp.l   D1,D0           ; genug Speicher frei?
                blt.s   err             ; nein, dann Fehler
                move.l  memtop.w,D0     ; memtop, alte Obergrenze

                sub.l   D1,D0           ; minus LÑnge = neues Speicherende

                move.l  D0,D2           ; d0.l merken
                and.l   #$01FF,D2
                beq.s   reservieren     ; war schon auf 512-Byte-Grenze?
                add.l   D2,D1           ; reservierte Grîûe entsprechend erhîhen
                and.l   #$FFFFFE00,D0   ; untere 9 Bits lîschen

reservieren:
                move.l  D0,memtop.w     ; in memtop ablegen

                movea.l D0,A1           ; neues Speicherende ins Adreûregister
                suba.l  4(A0),A1        ; minus M_START = LÑnge des neuen Blocks
                move.l  A1,8(A0)        ; M_LENGTH, neue LÑnge im mfl-Block merken
ok:             rts                     ; alles roger

mpberr:
                lea     mpberror(PC),A6 ; "MPB-Variable nicht gefunden"
                bsr     message

err:            moveq   #0,D0
                rts

* Hoffentlich von der TOS-Version unabhÑngige Routine, die versucht, den
* MPB zu finden. Erdacht von Bernd Rosenlecher:
* --------------------------------------------------------------------------
* VersionsabhÑngigen Teil ersetzt, lÑuft damit auf allen RAM- (ab 20.11.85)
* & ROM-TOS-Versionen - inkl. STE-TOS 1.6 vom 29.7.89 & TT-TOS 3.01 br 2/91
* --------------------------------------------------------------------------
* IN: nothing, OUT: a0 -> MPB, USES: a1, d0, d2, (PRESERVES d1)
* --------------------------------------------------------------------------
selbersuchen:
                lea     mpbmsg(PC),A6
                bsr     message         ; "Unbekannte TOS-Version!"

                lea     themd.w,A1      ; Ausgangspunkt der Suche
                movea.l membot.w,A2     ; Suchende
                move.l  memtop.w,D0
                sub.l   A2,D0           ; freien Speicher berechnen
                cmp.l   8(A1),D0        ; m_length = memtop-membot?
                bne.s   loop_0          ; da fehlt schon etwas

                lea     $4000,A0        ; Suchbeginn
t_loop:         addq.w  #2,A0           ; nur gerade Adressen absuchen
                cmpa.l  A0,A2           ; Endadresse erreicht?
                bls.s   mpberr          ; Fehler, fertig

                cmpa.l  (A0),A1         ; Zeiger auf themd?
                bne.s   t_loop          ; nein, weitersuchen
                bra.s   fini            ; das war's

loop_0:         movea.l A2,A0           ; Suchbeginn = membot
                moveq   #0,D2           ; VersuchszÑhler
loop_1:         subq.w  #2,A0           ; nur gerade Adressen absuchen
                cmpa.l  #$2000,A0       ; schon am Ende?
                bls.s   stuck           ; wir sind festgefahren

                cmpa.l  (A0),A1         ; Zeiger da?
                bne.s   loop_1          ; weiter testen

; Nun folgen PlausibilitÑtstests fÅr MDs, falls mp_mal
; gefunden wurde, kritisch!

                btst    #0,15(A0)       ; m_own gerade?
                bne.s   loop_1          ; nein, weiter
                btst    #0,7(A0)        ; m_start gerade?
                bne.s   loop_1          ; nein, weiter
                btst    #0,11(A0)       ; m_length gerade?
                bne.s   loop_1          ; nein, weiter

                movea.l A0,A1           ; evtl. neuer MD
                tst.l   12(A0)          ; m_own = 0?
                bne.s   loop_0          ; nein, weiter

                subq.w  #4,A0           ; Adresse des MPB
fini:           move.l  A0,D0           ; RÅckgabewert
                bra     alloc_st

stuck:          addq.w  #1,D2           ; Anzahl der Versuche hochzÑhlen
                movea.l A1,A0           ; war kein gÅltiger m_link
                movea.l (A1),A1         ; alten Zeiger nehmen
                cmp.w   #10,D2          ; maximale Anzahl der Versuche
                bne.s   loop_1
                bra     mpberr

                ENDPART

                >PART 'Daten'

********************
* und nun die Datenfelder
********************
                DC.B "TTAB"

tostab:         DC.W -1,-1
                DC.L -1,-1      ; Reserveeintrag

                DC.W $0100
                DC.W FRG
                DC.L -1
                DC.L $56EC

                DC.W $0102
                DC.W FRG
                DC.L -1
                DC.L $7E8E

                DC.W $0104
                DC.W FRG
                DC.L $08081988
                DC.L $522E

                DC.W $0104
                DC.W FRG
                DC.L -1
                DC.L $5328

                DC.W $0106
                DC.W FRG
                DC.L -1
                DC.L $5368

                DC.W $0205
                DC.W FRG
                DC.L -1
                DC.L $578E

                DC.W $0205
                DC.W CH
                DC.L -1
                DC.L $578E

                DC.W $0206
                DC.W FRG
                DC.L -1
                DC.L $59DA

                DC.W $0301
                DC.W FRG
                DC.L -1
                DC.L $71E2

                DC.W $0301
                DC.W UK
                DC.L -1
                DC.L $70E8

                DC.W $0305
                DC.W FRG
                DC.L -1
                DC.L $70E8

                DC.W $0306
                DC.W FRG
                DC.L -1
                DC.L $73CA

                DC.W 0

puffer:                                 ; Adresse der RAM-Disk-Daten
                DC.L 0

protobpb:       DC.W 512
spc:            DC.W 2,1024
rdlen:          DC.W 7
fat:            DC.W 5
fat2:           DC.W 6
datrec:         DC.W 18         ; BPB der RAM-Disk
numcl:          DC.W groekb
bflags:         DC.W 1          ; 16-Bit-FAT
                DC.L 0

wechselstatus:  DC.W 0

driveno:        DC.W -1         ; Laufwerksnummer der RAM-Disk
ramboot:        DC.B 'D',0      ; RAM-Boot-Flag (oberes Byte
; wird benutzt)

oriboot:        DC.W 0
o_bits:         DC.L 0
bootphase:      DC.W 0          ; Flag fÅr Bootphase

groesse:        DC.L 0
routgroesse:    DC.L 0
mtop:           DC.L 0

vorspann:       DC.B 13,10,"***** LUFTSCHLOSS "
                DC.B version,".",rev,rev2," *****"
                DC.B 13,10,"*        "

zahlstr:        DC.B "200",0,0,0
insttext:       DC.B " KB, "
instlw:         DC.B "X:        *",13,10,0
instboot:       DC.B "* Boote vom LUFTSCHLOSS... *",13,10,0
instcopyrt:
                DC.B "*        Ω 1991 by         *",13,10
                DC.B "* Lutz Preûler & Claus Brod*",13,10,0

; bis hier wird in den reservierten Bereich kopiert
routend:
inittext:       DC.B 13,10,13,10,"*** Die RAM-Disk aus dem ***",13,10
                DC.B "***** SCHEIBENKLEISTER *****",0

mpbmsg:         DC.B 13,10,"Vorsicht: Unbekannte TOS-Version!",7,13,10,0
mpberror:       DC.B "MPB-Variable nicht gefunden!",7,0
memerror:       DC.B 13,10,"Fehler bei der Speicherreservierung!",7,13,10,0
nodrives:       DC.B 13,10,"Keine freie Laufwerkskennung mehr!",7,13,10,0

fname2:         DC.B "\AUTO\"
filename:       DC.B "RR*.PRG",0

                DATA
aespb:          DC.L contrl,global,intin,intout
                DC.L addrin,addrout

                BSS

autoflag:       DS.W 1          ; AUTO-Ordner-Flag
basepage:       DS.L 1          ; Adresse der Basepage

contrl:
opcode:         DS.W 1
sintin:         DS.W 1
sintout:        DS.W 1
saddrin:        DS.W 1
saddrout:       DS.L 1
                DS.W 5
global:         DS.L 8
intin:          DS.W 10
ptsin:          DS.W 10
intout:         DS.W 10
ptsout:         DS.W 10
addrin:         DS.W 10
addrout:        DS.W 10

progende:
                ENDPART

                END
