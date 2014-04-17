*********************************************************
* CHKDISK V1.9: Zerstîrungsfreier Nur-Lese-Test fÅr     *
*               Disketten                               *
*                                                       *
* Written 1987-1992  by Claus Brod, Am Felsenkeller 2,  *
*                       8772 Marktheidenfeld            *
*                                                       *
* Aus SCHEIBENKLEISTER, dem etwas anderen Floppybuch    *
*********************************************************

                >PART 'Geschichte'

* Version 1.9, last update 3.1.92                       *
* V1.3: Kommentare verbessert; steigt nur noch auf 'n'  *
*       hin bei "Again" aus; prÅft auf ESC/^C           *
* V1.4: Unit-Abfrage, Fehlertext korrigiert             *
*       ESC auch im HauptmenÅ                           *
* V1.5: Get-Format-Option; maximal 89 Spuren            *
* V1.6: Optimierungen, Umstellung auf MADMAC; Abbruch   *
*       mit ALT-Taste; eigene Floppyroutinen (Speed!)   *
* V1.7: Aufruf mit Parametern in der Kommandozeile      *
*       (a/A oder b/B); alle Ausgaben dezimal;          *
*       funktioniert jetzt auch mit 40-Spur-Formaten;   *
*       bei 10-Sektor-Formaten keine Spurausgabe        *
* V1.8: Angepaût an TurboAss, Zeitschleifen entschÑrft  *
*       Per Hand auch bis 21 Sektoren einstellbar       *
* V1.9: Maximal 22 Sektoren per Hand einstellbar,       *
*       Fehlerkorrekturen (Dank an Uwe Meyer)           *

                ENDPART

                >PART 'Konstanten'

MAXTRACKS       EQU 89          ; maximal 89 Spuren
MAXSECS         EQU 22
ver1            EQU "1"         ; Versionsnummer
ver2            EQU "9"         ; Versionsnummer, 2. Stelle
timeout         EQU 400         ; Timeout-Konstante

************************
* Systemadressen
************************
snd             EQU $FFFF8800   ; Adresse des Soundchips
sndwrt          EQU $FFFF8802   ; Eingabe des Soundchips
mfp             EQU $FFFFFA01   ; Adresse des MFP68901 fÅrs Polling
daccess         EQU $FFFF8604   ; DMA-Access: FDC-Zugriff/SektorzÑhler
dmodus          EQU $FFFF8606   ; DMA-Modusregister
dlow            EQU $FFFF860D   ; DMA-ZÑhler, öbertragungsstart Lowbyte
dmid            EQU $FFFF860B   ; DMA-ZÑhler, Åbertragungsstart Midbyte
dhigh           EQU $FFFF8609   ; DMA-ZÑhler, Åbertragungsstart Highbyte

hz_200          EQU $04BA       ; hz_200-Zaehler
sysbase         EQU $04F2
flock           EQU $043E
nflops          EQU $04A6

                ENDPART

                >PART 'Initialisierung'

*****************************
* Es geht los
*****************************
start:
                movea.l SP,A5           ; Speicherplatz reservieren
                movea.l 4(A5),A5        ; Basepage-Adresse
                move.l  A5,basepage     ; Basepage-Adresse retten
                move.l  12(A5),D0       ; LÑnge von .text
                add.l   20(A5),D0       ; LÑnge von .data
                add.l   28(A5),D0       ; LÑnge von .bss
                add.l   #$0400,D0       ; Platz fÅr Stack+Basepage
                move.l  D0,D1
                add.l   A5,D1           ; plus Basepage-Adresse
                andi.b  #-2,D1          ; gerade machen
                movea.l D1,SP           ; Stackpointer setzen
                move.l  D0,-(SP)        ; Grîûe des zu reservierenden Bereichs
                move.l  A5,-(SP)        ; Startadresse
                clr.w   -(SP)           ; Dummy
                move.w  #$4A,-(SP)      ; MSHRINK
                trap    #1              ; GEMDOS
                lea     12(SP),SP       ; SP korrigieren

                clr.l   -(SP)           ; ab in den Supervisormodus
                move.w  #32,-(SP)       ; SUPER
                trap    #1              ; GEMDOS
                addq.l  #6,SP           ; SP korrigieren
                move.l  D0,-(SP)        ; alten SSP gleich auf Stack
                move.w  #32,-(SP)       ; und auf nÑchsten SUPER-Aufruf vorbereiten

                move.l  #$0E1B,kbshift  ; kbshift vorbelegen
                movea.l sysbase.w,A0    ; sysbase holen
                move.w  2(A0),D0        ; TOS-Version
                cmp.w   #$0102,D0       ; grîûer gleich 1.2?
                blt.s   mainloop        ; nein, weiter
                move.l  36(A0),kbshift  ; kbshift-Adresse Åbertragen

                ENDPART

                >PART 'Hauptschleife'
mainloop:
                lea     header(PC),A2   ; BegrÅûung
                bsr     printmsg        ; ausgeben
                bsr.s   cmd             ; war was GÅltiges in der Kommandozeile?
                bmi.s   command         ; ja

                bsr     parameter       ; Parametereingabe
                bmi.s   nochmal         ; ESC gedrÅckt?
                bsr     main            ; Ab ins Hauptprogramm
nochmal:
                lea     againmsg(PC),A2 ; 'Again (Y/N)' ausgeben
                bsr     printmsg
keyloop:
                bsr     getkey          ; Taste holen
                cmp.b   #'y',D0         ; Nochmal?
                beq.s   mainloop        ; ja, zurÅck
                cmp.b   #'n',D0         ; 'n' gedrÅckt?
                bne.s   keyloop         ; nein, illegales Zeichen

exitus:                                 ; Sense
                bsr     wechsel         ; auf aktuellem Laufwerk Wechsel erzwingen
                trap    #1              ; $20 (SUPER) liegt noch auf Stack
                addq.l  #6,SP           ; SP korrigieren
                clr.w   -(SP)           ; und jetzt ist
                trap    #1              ; Schluû

                ENDPART

                >PART 'Kommandozeilenaufruf'
*********************
* command: Steuert Ablauf, wenn
* was in der Kommandozeile war
*********************
command:
                bsr     getfmt          ; Format holen
                beq.s   exitus          ; Fehler? Dann raus
                lea     m_end(PC),A2
                bsr     printmsg        ; Format ausgeben
                bsr.s   main            ; Diskette prÅfen
                bra.s   exitus          ; und raus hier

*********************
* cmd: PrÅft auf gÅltige Parameter in
*      der Kommandozeile
* IN:  basepage Adresse der basepage
* OUT: MI-Flag, wenn gÅltige Parameter da
*      laufwerk(pc) gewÅnschtes Laufwerk (wenn angeschlossen)
*********************
cmd:
                movea.l basepage(PC),A2 ; Adresse der Basepage
                lea     $80(A2),A2      ; auf Kommandozeile positionieren
                clr.w   D0              ; d0.w lîschen
                move.b  (A2)+,D0        ; LÑnge der Kommandozeile holen
                beq.s   cmdexit         ; gleich 0, dann raus
                subq.w  #1,D0           ; minus eins wegen dbf
nxtchar:
                move.b  (A2)+,D1        ; Zeichen holen
                beq.s   cmdexit         ; 0?
                bclr    #5,D1           ; Bit 5 lîschen
                cmp.b   #'A',D1         ; 'A'?
                beq.s   valid           ; ja
                cmp.b   #'B',D1         ; 'B'?
                beq.s   valid           ; ja
                dbra    D0,nxtchar      ; nÑchstes Zeichen

cmdexit:
                rts
valid:
                move.b  D1,s_drv        ; Laufwerk im Text
                sub.w   #'A',D1         ; ASCII nach Zahl
                cmp.w   nflops.w,D1     ; mit nflops vergleichen
                beq.s   cmdexit         ; ungÅltiges Laufwerk
                lea     laufwerk(PC),A2 ; Adresse der Laufwerksvariablen
                move.w  D1,(A2)         ; Laufwerk merken
                moveq   #-1,D0          ; MI-Flag setzen
                rts

                ENDPART

                >PART 'getbpb'
*********************
* getbpb: BIOS-Parameterblock vom aktuellen
* Laufwerk holen
*********************
getbpb:
                move.w  laufwerk(PC),-(SP) ; Laufwerksnummer auf Stack
                move.w  #7,-(SP)        ; GETBPB
                trap    #13             ; BIOS
                addq.l  #4,SP           ; Stack sÑubern
                bra.s   wechsel         ; Wechsel anmelden

                ENDPART

                >PART 'PrÅfschleife'

*********************
* PrÅfschleife
*********************
main:
                lea     workmsg(PC),A2  ; 'Working...'
                bsr     printmsg        ; ausgeben
                st      flock.w         ; Floppy-VBL sperren
                clr.w   D6              ; aktuelle Seite = 0
                bsr     select          ; Laufwerk und Seite selektieren
                bsr     rsthead         ; Kopf auf Spur 0 fahren
                suba.l  A4,A4           ; aktueller Track = 0
                moveq   #1,D4           ; aktueller Sektor = 1

*********************
* Sektor lesen
*********************
readsec:
                movea.l kbshift(PC),A2
                btst    #3,(A2)         ; ALT gedrÅckt?
                bne.s   diskfertig      ; ja, raus hier
                bsr     rdsec           ; Sektor d4 lesen
                tst.w   D0              ; Fehler passiert?
                bne.s   fehler          ; ja, dann melden
next:
                addq.w  #1,D4           ; nÑchster Sektor
                cmp.w   spt(PC),D4      ; schon alle durch?
                bls.s   readsec         ; nein, nochmal

                moveq   #1,D4           ; Sektor 1
                lea     sides(PC),A2
                cmpi.w  #1,(A2)         ; 1 oder 2 Seiten
                beq.s   nexttrack       ; nur eine Seite
                eori.w  #1,D6           ; Seite wechseln
                bsr     select          ; Seite selektieren
                tst.w   D6              ; Seite prÅfen
                bne.s   readsec         ; schon auf 0 gewechselt? Nein: lesen
nexttrack:
                moveq   #10,D0
                cmp.w   spt(PC),D0      ; 10 Sektoren/Spur?
                beq.s   noout           ; ja, nix ausgeben
                bsr     printtrack      ; Spurnummer ausgeben
noout:
                addq.w  #1,A4           ; nÑchste Spur
                cmpa.w  end(PC),A4      ; schon alle Spuren?
                bge.s   diskfertig      ; ja, dann raus

                bsr     such_hasso      ; Spur anfahren
                bra.s   readsec         ; und zum Lesen

diskfertig:
                bsr     rsthead         ; Kopf auf Spur 0
                clr.w   D0              ; deselektieren
                bsr     do_select
                sf      flock.w         ; Floppy-VBL freigeben
wechsel:
                move.l  D0,-(SP)        ; d0 retten
                move.w  laufwerk(PC),-(SP) ; Laufwerksnummer
                clr.w   -(SP)           ; Sektornr
                move.w  #2,-(SP)        ; sicheren Diskwechsel anmelden
                clr.l   -(SP)           ; Pufferadresse = 0
                clr.w   -(SP)           ; R/W-Flag
                move.w  #4,-(SP)        ; RWABS
                trap    #13
                lea     14(SP),SP
                move.l  (SP)+,D0        ; d0 holen
                rts

                ENDPART

                >PART 'Fehlerausgabe'
*************************
* fehler: Bereitet Errormsg auf
* und gibt sie aus
* IN: d0 Errornumber
*************************
fehler:
                movem.l D0-A6,-(SP)     ; Register retten
                lea     errnum(PC),A6   ; Errorstring
                moveq   #1,D1           ; 1+1 Nibbles wandeln
                bsr.s   d0todec         ; d0 nach dec in String ab a6

                lea     badsec(PC),A6   ; Adresse des Badsec-Strings
                moveq   #1,D1           ; 2 Nibbles wandeln

                move.w  D4,D0           ; Sektornr. holen
                bsr.s   d0todec         ; d0 in String wandeln
                lea     badtrk(PC),A6   ; Adresse des Badtrk-Strings
                moveq   #1,D1           ; 2 Nibbles wandeln
                move.w  A4,D0           ; Aktuellen Track holen
                bsr.s   d0todec         ; d0 in String wandeln
                lea     badsd(PC),A6    ; Adresse des Badsd-Strings
                moveq   #1,D1           ; 2 Nibbles
                move.w  D6,D0           ; Aktuelle Seite
                bsr.s   d0todec         ; in String wandeln

                lea     errormsg(PC),A2 ; Adresse der Message
                bsr.s   printmsg        ; ausgeben und raus
                movem.l (SP)+,D0-A6     ; Register wieder holen
                bra     next            ; nÑchster Sektor

                ENDPART

                >PART 'Zahl in String wandeln'
**************************
* d0.w to decimal string
* IN: Stringadresse in a6
*     Anzahl der zu wandelnden Ziffern-1 in d1
**************************
d0todec:
                movem.l D0-D2,-(SP)     ; Register retten
                and.l   #$FFFF,D0       ; oberes Wort lîschen
nxtdigit:
                move.l  D0,D2           ; d0 nach d2
                divu    #10,D2          ; durch 10
                move.w  D2,D0           ; Quotient nach d0.w
                swap    D2              ; Rest nach d2.w
                add.b   #'0',D2         ; in ASCII wandeln
                move.b  D2,0(A6,D1.w)   ; in String kopieren
                dbra    D1,nxtdigit     ; nÑchste Ziffer
                movem.l (SP)+,D0-D2     ; Register holen
                rts                     ; raus

                ENDPART

                >PART 'Ein- und Ausgabe'

**********************
* Track ausgeben
**********************
printtrack:                             ; Spurnummer ausgeben
                move.l  A4,D0
                lea     s_akt(PC),A6
                moveq   #1,D1           ; 1+1 Nibbles
                bsr.s   d0todec
                lea     m_akt(PC),A2    ; und gleich weiter zur Ausgabe

*********************
* String ausgeben
*********************
printmsg:                               ; String ausgeben (IN: A2)
                move.l  A2,-(SP)        ; Adresse des Strings
                move.w  #9,-(SP)        ; Cconws
                trap    #1              ; GEMDOS
                addq.l  #6,SP
                rts

**********************
* auf Taste warten
**********************
getkey:                                 ; auf Taste warten
                move.w  #7,-(SP)        ; Cnecin
                trap    #1              ; GEMDOS
                addq.l  #2,SP
                cmp.b   #'A',D0
                bls.s   getok
                cmp.b   #'Z',D0
                bhi.s   getok
                bset    #5,D0           ; in Kleinbuchstaben wandeln
getok:
                rts

                ENDPART

                >PART 'MenÅverwaltung'

**********************
* Parameter-MenÅ ausgeben und
* auf Eingaben warten
**********************
parameter:                              ; auf Eingabe von neuen Parametern
                lea     m_end(PC),A2    ; warten
                bsr.s   printmsg
                bsr.s   getkey          ; auf Taste warten
                sub.b   #13,D0          ; RETURN?
                beq.s   fertig          ; ja, mit Check anfangen
                sub.b   #27-13,D0       ; ESC?
                beq.s   paraexit        ; ja, raus hier
                sub.b   #'g'-27,D0      ; Get Format?
                beq.s   op_gtfmt        ; ja, Format holen
                subq.b  #'h'-'g',D0     ; Hilfsseite
                beq.s   op_help         ; anzeigen
                subq.b  #'p'-'h',D0     ; Sektorenanzahl
                beq     op_spt          ; Ñndern
                subq.b  #'s'-'p',D0     ; Seitenanzahl
                beq     op_sides        ; Ñndern
                subq.b  #'t'-'s',D0     ; Trackanzahl
                beq     op_tracks       ; Ñndern
                subq.b  #'u'-'t',D0     ; Unit?
                beq.s   op_drive        ; ja, Ñndern
                bra.s   parameter
fertig:
                moveq   #0,D0
                rts
paraexit:
                moveq   #-1,D0          ; MI-Flag setzen
                rts

*********************
* Hilfsseite anzeigen
*********************
op_help:
                lea     infomsg(PC),A2  ; Adresse der Help-Seite
                bsr.s   printmsg        ; ausgeben
                bsr.s   getkey          ; Auf Taste warten
                lea     header(PC),A2   ; Header
                bsr.s   printmsg        ; ausgeben
                bra.s   parameter

*********************
* op_gtfmt: Format von Laufwerk holen
*********************
op_gtfmt:
                bsr.s   getfmt          ; Format holen
                bra.s   parameter       ; zur Anzeige

getfmt:
                bsr     getbpb          ; BPB vom aktuellen Laufwerk
                tst.l   D0              ; Fehler?
                beq.s   getexit         ; ja, Schluû
                movea.l D0,A0           ; Zeiger auf BPB
                move.w  $12(A0),D0      ; Anzahl der Spuren
                move.w  D0,D4           ; kopieren
                cmp.w   #MAXTRACKS,D0   ; grîûergleich 89 Spuren?
                bge.s   gtsd            ; ja, weiter mit Seiten

                lea     s_end(PC),A6
                moveq   #1,D1           ; 1+1 Nibbles
                bsr     d0todec

gtsd:
                lea     end(PC),A2
                move.w  D4,(A2)         ; Anzahl der Spuren

                move.w  $14(A0),D0      ; Anzahl der Seiten
                lea     sides(PC),A2
                move.w  D0,(A2)         ; Seitenvariable
                add.w   #48,D0          ; In ASCII wandeln
                lea     s_seiten(PC),A2
                move.b  D0,1(A2)        ; Seiten-String

                move.w  $18(A0),D0      ; Anzahl der Sektoren
                lea     spt(PC),A3      ; Track Ñndern
                lea     s_spt(PC),A6
                move.w  D0,(A3)
                moveq   #1,D1           ; 1+1 Nibbles
                bsr     d0todec
                moveq   #-1,D0          ; Z-Flag lîschen
getexit:
                rts

*********************
* Laufwerk einstellen
*********************
op_drive:
                cmpi.w  #1,nflops.w     ; nur ein Laufwerk angeschlossen?
                beq     parameter       ; ja, gleich wieder zurÅck

                lea     s_drv(PC),A2    ; Stringadresse
                lea     laufwerk(PC),A3 ; Adresse der Variablen
                move.w  (A3),D0         ; Wert holen
                eori.w  #1,D0           ; togglen
                move.w  D0,D1           ; Wert kopieren
                add.w   #'A',D1         ; in ASCII wandeln
wr_drv:
                move.b  D1,(A2)         ; String und
                move.w  D0,(A3)         ; Flag Ñndern
                bra     parameter

*********************
* Seitenzahl Ñndern
*********************
op_sides:                               ; Anzahl der Seiten Ñndern
                lea     sides(PC),A2
                lea     s_seiten(PC),A3
                eori.w  #3,(A2)
                eori.b  #3,1(A3)
                bra     parameter

**********************
* Trackzahl Ñndern
**********************
op_tracks:                              ; Anzahl der Tracks Ñndern
                lea     end(PC),A2
                lea     s_end(PC),A6
                move.w  (A2),D0         ; letzte Spur holen
                addq.w  #1,D0
                cmpi.w  #45,D0          ; >44?
                bne.s   uplimit         ; nein, OK
                cmpi.w  #80,D0          ; <80?
                bge.s   uplimit         ; nein, OK
                moveq   #80,D0          ; Tracks auf 80 einstellen
uplimit:
                cmp.b   #MAXTRACKS,D0   ; mehr als MAXTRACKS sind nicht
                bls.s   trackok         ; drin
                moveq   #40,D0          ; Startwert
trackok:
                move.b  D0,1(A2)
                moveq   #1,D1           ; 1+1 Nibbles
                bsr     d0todec         ; wandeln
                bra     parameter

**********************
* Sektoren pro Track Ñndern
**********************
op_spt:                                 ; Anzahl der Sektoren pro
                lea     spt(PC),A3      ; Track Ñndern
                lea     s_spt(PC),A6
                move.w  (A3),D0         ; Sektoren pro Spur holen
                addq.b  #1,D0           ; plus eins
                cmp.b   #MAXSECS,D0     ; schon MAXSECS Sektoren?
                bls.s   sptok           ; nein
                moveq   #1,D0           ; ja, wieder bei 1 anfangen
sptok:
                move.w  D0,(A3)         ; neuen Wert schreiben
                moveq   #1,D1           ; 1+1 Nibbles
                bsr     d0todec         ; in String wandeln
                bra     parameter

                ENDPART

***************************************
* ab hier folgen Routinen fÅr den Floppycontroller
***************************************

                >PART 'IRQ senden'
**************************
* irq: Unterbricht den Controller
**************************
irq:
                moveq   #$D0,D7         ; FORCE IRQ

                ENDPART

                >PART 'Byte an FDC'
******************************
* wrfdc: Byte in d7 an den Controller
* schicken
******************************
wrfdc:
                bsr.s   delay
                move.w  D7,daccess.w    ; d7 ins DMA-Fensterregister

                ENDPART

                >PART 'delay'

*****************************
* delay: Kurze cache-feste Verzîgerung
*****************************
delay:
                tst.b   mfp.w
                tst.b   mfp.w
                tst.b   mfp.w
                tst.b   mfp.w
                rts

                ENDPART

                >PART 'Sektor lesen'
*****************************
* rdsec: Liest einen Sektor auf der aktuellen Spur
* IN: buffer Pufferadresse, d4 Sektor, OUT: d0 Status (>0 -> Fehler)
*****************************
rdsec:
                move.l  #buffer,D7      ; Pufferadresse
                bsr.s   dma             ; als DMA-Adresse schicken
                move.w  #$90,dmodus.w   ; Status lîschen
                move.w  #$0190,dmodus.w
                move.w  #$90,dmodus.w   ; SektorzÑhler
                moveq   #1,D7           ; 1 Sektor
                bsr.s   wrfdc           ; an DMA-Chip schicken
                move.w  #$84,dmodus.w   ; Sektorregister FDC
                move.w  D4,D7           ; Sektornummer
                bsr.s   wrfdc           ; an FDC schicken
                move.w  #$80,dmodus.w   ; Kommandoregister
                moveq   #$80,D7         ; READ SECTOR
                bsr.s   wrfdc           ; d7 an FDC
                moveq   #16+8+4,D7      ; RNF(16)+CRC(8)+LOSTDATA(4) als Maske
                bsr.s   warten_auf_godot ; auf Ende warten
                tst.w   D0              ; Fehler passiert?
                bne.s   rderr           ; ja, Lesefehler

*****************************
* status: Holt DMA-Status nach d0
******************************
status:
                move.w  #$0190,dmodus.w ; SektorzÑhler selektieren
                move.w  dmodus.w,D0     ; Status holen
                btst    #0,D0           ; DMA-Error?
                beq.s   rderr           ; DMA-Fehler passiert
                clr.w   D0              ; nix passiert
rderr:
                rts                     ; raus (d0.w=0: kein Fehler)

                ENDPART

                >PART 'DMA-Adresse setzen'
*****************************
* dma: Setzt DMA-Adresse
* IN: d7 Startadresse
*****************************
dma:
                move.b  D7,dlow.w       ; DMA-Lowbyte
                lsr.l   #8,D7           ; shiften
                move.b  D7,dmid.w       ; DMA-Midbyte
                lsr.l   #8,D7           ; shiften
                move.b  D7,dhigh.w      ; DMA-Highbyte
                rts

                ENDPART

                >PART 'Seek, Restore'
*****************************
* such_hasso: Seek-Befehl
* IN: a4 Spurnummer
*****************************
such_hasso:
                move.w  #$86,dmodus.w   ; Datenregister auswÑhlen
                move.w  A4,D7           ; Tracknummer holen
                bsr     wrfdc           ; Byte in d7 an FDC
                move.w  #$80,dmodus.w   ; Commandregister
                moveq   #$10,D7         ; SEEK ohne Verify, Steprate 6 ms
                bsr     wrfdc           ; Byte an FDC
                bra.s   warten_auf_godot ; Auf FDC warten

*****************************
* rsthead: Faehrt Kopf auf Spur 0
*****************************
rsthead:
                move.w  #$80,dmodus.w   ; Kommandoregister
                moveq   #0,D7           ; Restore, Steprate 6 ms
                bsr     wrfdc           ; an FDC schicken
                bra.s   warten_auf_godot ; auf FDC warten

                ENDPART

                >PART 'FDC-Register lesen'

*****************************
* rdfdc: FDC-Register lesen
*****************************
rdfdc:
                bsr     delay
                move.w  daccess.w,D0    ; Register lesen
                bra     delay

                ENDPART

                >PART 'Auf FDC warten'
*****************************
* warten_auf_godot: Wartet auf FDC
* IN: d7 Errormask, USES: a3.l, d1.l, d2.l
* In daccess muss das Kommando/Statusregister des FDC gewÑhlt sein
*****************************
warten_auf_godot:
                move.w  daccess.w,D1
                btst    #0,D1           ; BUSY gesetzt?
                beq.s   warten_auf_godot ; nein, Moment noch

                move.l  #timeout,D1     ; Timeout
                add.l   hz_200.w,D1     ; ZÑhler addieren
poll:
                btst    #5,mfp.w        ; FDC fertig?
                beq.s   fix_und_fertig  ; ja
                cmp.l   hz_200.w,D1     ; ZÑhler schon soweit?
                bne.s   poll            ; aus und vorbei?

                bsr     irq             ; Kommando abbrechen
                moveq   #1,D0           ; Timeout-Fehler
                rts

fix_und_fertig:
                move.w  #$0180,dmodus.w ; Kommandoregister
                bsr.s   rdfdc           ; Status nach d0 holen
                and.w   D7,D0           ; Fehlerbits maskieren
                rts

                ENDPART

                >PART 'Laufwerk selektieren'
*****************************
* select: Laufwerk und Seite selektieren
* Laufwerk in laufwerk(pc)
* Seite in d6
*****************************
select:
                move.w  laufwerk(PC),D0 ; Laufwerksnummer
                addq.w  #1,D0           ; +1
                add.w   D0,D0           ; mal 2
                add.w   D6,D0           ; Seite addieren

*****************************
* do_select: Und jetzt das Selektierprogramm
* Floppy-VBL muû aus sein
* Laufwerk+Seite in d0.w
* USES: d7.w, d0.w
*****************************
do_select:
                tst.w   D0              ; Laufwerksnummer prÅfen
                bne.s   mach_mal        ; Wenn nicht gerade 0, dann mach los
                move.w  #$80,dmodus.w   ; Statusregister
motor:
                move.w  daccess.w,D7    ; auslesen
                btst    #7,D7           ; Motor noch an?
                bne.s   motor           ; jawoll
mach_mal:
                move.w  D0,D7           ; Laufwerksnummer holen
                eori.b  #7,D7           ; Bits invertieren
                and.b   #7,D7           ; und ausmaskieren
                move    SR,-(SP)        ; Status retten
                ori     #$0700,SR       ; Interrupts aus
                move.b  #14,snd.w       ; Port A wÑhlen
                move.b  snd.w,D0        ; Port A lesen
                and.b   #$F8,D0         ; ausmaskieren
                or.b    D0,D7           ; neue Seite/neues Laufwerk setzen
                move.b  D7,sndwrt.w     ; in Port A
                move    (SP)+,SR        ; Status wieder holen
                rts                     ; und raus

                ENDPART

                DATA

                >PART 'Fehlermeldung'
errormsg:                               ; Fehlermeldung
                DC.B 7,27,'pVerify Error '
errnum:
                DC.B '00 Trk '
badtrk:
                DC.B '00 Sec '
badsec:
                DC.B '00 Sd '
badsd:
                DC.B '00',27,'q',13,10,0
                ENDPART

                >PART 'Hilfsseite'
infomsg:
                DC.B 27,'E',27,'p   CHECKDISK V',ver1,'.',ver2,'   ',13,10
                DC.B '(C) 1987 Claus Brod ',27,'q',13,10,13,10
                DC.B 'CHECKDISK V',ver1,'.',ver2,' is definitely NOT public domain; it is included with',13,10
                DC.B "every copy of 'SCHEIBENKLEISTER' , my book on the ST's mass storage",13,10
                DC.B 'devices. Whoever copies this illegally,  shall be crucified next to',13,10
                DC.B 'Brian (see "The Life of Brian" for details).',13,10,13,10
                DC.B 'CHECKDISK checks every sector on every track - adjust this with the',13,10
                DC.B 'options "Tracks", "Sides", "Sectors per Track" and "Disk Unit". You',13,10
                DC.B 'can even check  HYPERFORMATted disks.  If CHECKDISK finds an error,',13,10
                DC.B 'it tells you where and what kind it is. Use the TED monitor from my',13,10
                DC.B 'book to repair these errors. This is what the error codes mean:',13,10,13,10
                DC.B '01: Timeout                   04: Lost data (should never happen)',13,10
                DC.B '08: CRC checksum error        16: Sector not found (ID error)',13,10
                DC.B 'Combinations may occur, for example:',13,10
                DC.B '24: CRC checksum error in ID field',13,10,13,10
                DC.B 'Any feedback, error reports, love letters etc. to:',13,10
                DC.B 27,'pClaus Brod, Am Felsenkeller 2, D-8772 Marktheidenfeld,',13,10
                DC.B 'phone: West Germany 09391-3206',27,'q',13,10,13,10
                DC.B 'Press ALT during disk check to cancel. Try "chkdsk a:" in a CLI!',0

                ENDPART

                >PART 'Begruessung, MenÅ'
header:
                DC.B 27,'E',27,'p'
                DC.B '      CHECKDISK V',ver1,'.',ver2,'      ',27,'q',13,10
                DC.B '(C) 1987-92 by  Claus Brod',13,10
                DC.B '  From SCHEIBENKLEISTER,  ',13,10
                DC.B '  the slightly different  ',13,10
                DC.B ' floppy & hard disk book. ',13,10,0

againmsg:
                DC.B 13,10,13,10,'Again (Y/N)?',0

workmsg:
                DC.B 27,'Y',32+18,32+0
                DC.B 'Working...',13,10,0

m_end:
                DC.B 27,'Y',32+8,32+0
                DC.B 27,'pT',27,'q Tracks           :  '
s_end:
                DC.B '83',13,10
m_seiten:
                DC.B 27,'pS',27,'q Sides            :  '
s_seiten:
                DC.B '02',13,10
m_spt:
                DC.B 27,'pP',27,'q Sectors per track:  '
s_spt:
                DC.B '11',13,10
                DC.B 27,'pU',27,'q Disk Unit        :  '
s_drv:
                DC.B 'A',13,10,13,10

                DC.B 'G        Get format',13,10
                DC.B 'RETURN   Start checking',13,10
                DC.B 'H        Help',13,10
                DC.B 'ESC/ALT  Cancel',13,10,13,10,13,10,0

m_akt:
                DC.B 27,'j',27,'Y',32+0,32+28,'Track: '
s_akt:
                DC.B '00',27,'k',0

                ENDPART

                >PART 'Variablen'

                EVEN
end:            DC.W 83         ; letzter zu prÅfende Spur
spt:            DC.W 11         ; Sektoranzahl
sides:          DC.W 2          ; Seitenzahl
laufwerk:       DC.W 0          ; Laufwerksnummer

                BSS
kbshift:        DS.L 1          ; Adresse von kbshift
basepage:       DS.L 1          ; Puffer fÅr Basepage-Adresse
buffer:         DS.B 512        ; Sektorpuffer

                ENDPART

                END
