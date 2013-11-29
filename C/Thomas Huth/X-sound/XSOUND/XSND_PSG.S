*************************************************************
*                          X-SOUND PSG                      *
*    Digi-Sound per Betriebsystem auf jedem ST/E und TT     *
*           Dies ist die Version fÅr den Soundchip          *
*            Geschrieben von Thomas Huth, 1995/96           *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*             Jetzt mit McSn-Cookie UnterstÅtzung           *
*                      dank ChrisP, 1999                    *
*************************************************************


_sysbase        EQU $04F2
_longframe      EQU $059E
_p_cookies      EQU $05A0
resvalid        EQU $0426       ; Reset-Vektor Magic
resvector       EQU $042A       ; der Reset-Vektor

newjarslots     EQU 32          ; Anzahl der EintrÑge in einem neuen Cookiejar

tadr            EQU $FFFFFA1F   ; Timer A Data-Register
tacr            EQU $FFFFFA19   ; Timer A Control-Register

mfpi7adr        EQU $013C       ; Mfp-i7 Adress-Register

                TEXT
start:
                bra     init            ; Routine initialisieren

;### etv_term: ZurÅcksetzen von locksnd ##
                DC.B "XBRAXSND" ; XBRA-Kennung
oldetvterm:     DS.L 1
myetvterm:      movea.l act_pd(PC),A0   ; actpd-Variable holen
                move.l  (A0),D0         ; Aktuelle Basepage => D0
                cmp.l   lock_pd(PC),D0  ; Basepage des Reservierers?
                bne.s   etvtermret      ; Nein: zurÅck
                clr.l   lock_pd         ; Sperre Freigeben
etvtermret:     lea     oldetvterm(PC),A0 ; Alten Wert laden
                jmp     (A0)            ; und springen


;### Hauptverteiler ###
                DC.B "XBRAXSND"
oldtrap14:      DS.L 1          ; Alter Vektor
mytrap14:       move    USP,A0          ; A0 auf Parameter zeigen lassen
                btst    #5,(SP)         ; War schon Supervisor an?
                beq.s   go              ; Ja: Keine Zusatzparameter
                lea     6(SP),A0        ; A0 auf Parameter
                tst.w   _longframe.w    ; Ist Prozessor > 68000?
                beq.s   go              ; Nein: A0 ist OK
                addq.l  #2,A0           ; 2 Zusatzparameter mehr
go:             move.w  (A0)+,D0        ; Funktionsnummer holen, A0 auf Daten
                cmp.w   #13,D0
                beq.s   mfpint          ; Mfpint abfangen
                cmp.w   #26,D0
                beq.s   jdisint         ; Jdisint abfangen
                cmp.w   #27,D0
                beq.s   jenabint        ; Jenabint abfangen
                cmp.w   #31,D0
                beq.s   xbtimer         ; Xbtimer abfangen!
                sub.w   #128,D0         ; Locksnd hat Nr.128
                bmi.s   nrmlxbios       ; Funktionsnummer < 128 => Altes Xbios
                cmp.b   #14,D0
                bge.s   nrmlxbios       ; Nur 13 Routinen vorhanden
                lea     jumptabl(PC),A1 ; Tabelle holen
                add.w   D0,D0           ; D0 * 2 wegen WortlÑnge
                lea     r(PC),A2        ; Start der Routinen
                adda.w  0(A1,D0.w),A2   ; Adresse der Routine in A2
                jmp     (A2)            ; Routine anspringen
nrmlxbios:
                movea.l oldtrap14(PC),A0 ; Alten Vektor laden
                jmp     (A0)            ; und springen

;*** Mfpint auf Timer-A testen ***
mfpint:         cmpi.w  #13,(A0)
                bne.s   nrmlxbios
                move.l  2(A0),taemuaddr
                rte

;*** Jdisint auf i7 und Timer A testen ***
jdisint:        cmpi.w  #13,(A0)
                bne.s   jdii7
                clr.b   taemuon
                rte
jdii7:          cmpi.w  #15,(A0)
                bne.s   nrmlxbios
                clr.b   mfp7emuon
                rte

;*** Jenabint abfangen ***
jenabint:       cmpi.w  #13,(A0)
                bne.s   jeii7
                move.b  #-1,taemuon
                rte
jeii7:          cmpi.w  #15,(A0)
                bne.s   nrmlxbios
                move.b  #-1,mfp7emuon
                rte

;*** Xbtimer auf Timer A testen ***
xbtimer:        tst.w   (A0)            ; Timer-A?
                bne.s   nrmlxbios
                cmpi.w  #8,2(A0)        ; Event-Count-Mode?
                bne.s   noeventmode
                move.b  5(A0),taemucount
                move.b  5(A0),taemudata
                move.l  6(A0),taemuaddr
                move.b  #-1,taemuon
                rte
noeventmode:    clr.b   taemuon
                btst    #0,bufoperstat
                beq     nrmlxbios       ; Kein Sound->Alternativen Timer A setzen
                rte


;** Die Sprungtabelle: **
jumptabl:       DC.W locksnd-r,unlocksnd-r,soundcmd-r,setbuffer-r
                DC.W setsndmode-r,unknown-r,unknown-r,setinterrupt-r
                DC.W buffoper-r,unknown-r,unknown-r,devconnect-r
                DC.W sndstatus-r,buffptr-r

;** RÅckkehr: **
xsndreterr:     moveq   #-1,D0          ; Fehler melden
                rte
xsndretok:      moveq   #0,D0           ; Alles okay
xsndret:        rte

r:                                      ; Hier kommen die Routinen:

;*** Unbekannte Funktion, -32L zurÅckgeben: ***
unknown:        move.l  #-32,D0
                rte


;*** Locksnd ***
locksnd:        tst.l   lock_pd         ; Schon gesperrt?
                beq.s   lockit          ; Nein: Sperren gehen
                move.l  #-129,D0        ; Ja: Als gesperrt melden
                bra.s   xsndret
lockit:         movea.l act_pd(PC),A0   ; act_pd-Variable laden
                move.l  (A0),lock_pd    ; Basepage merken
                moveq   #1,D0
                bra.s   xsndret

;*** Unlocksnd ***
unlocksnd:      tst.l   lock_pd         ; Schon freigegeben?
                bne.s   unlockit        ; Nein: Freigeben
                moveq   #-128,D0        ; Ja: Fehler-Code
                bra.s   xsndret
unlockit:       clr.l   lock_pd         ; Freigabe
                bra.s   xsndretok

;*** Soundcmd ***
soundcmd:       cmpi.w  #-1,2(A0)       ; Alten Wert zurÅckgeben?
                beq.s   retoldcmd
                tst.w   (A0)            ; Ltatten?
                beq.s   ltatten
                cmpi.w  #1,(A0)         ; Rtatten?
                beq.s   rtatten
retoldcmd:
                moveq   #0,D0
                tst.w   (A0)
                beq.s   retoldltat
                cmpi.w  #1,(A0)
                beq.s   retoldrtat
                bra     xsndret
retoldltat:     move.w  lvol(PC),D0     ; Linke LautstÑrke zurÅckgeben
                bra     xsndret
retoldrtat:     move.w  rvol(PC),D0     ; Recht L. zurÅckgeben
                bra     xsndret
ltatten:        move.w  2(A0),lvol
                bra.s   setvol
rtatten:        move.w  2(A0),rvol
setvol:         move.w  lvol(PC),D0
                add.w   rvol(PC),D0
                and.w   #$01FF,D0       ; Sicher ist sicher!
                move.w  #510,D2         ; Statt DÑmpfung -> LautstÑrke
                sub.w   D0,D2
                ext.l   D2              ; D2: Volumewert
                lsl.l   #7,D2           ; D2: 00 01 00 00
                bsr     _volume         ; LautstÑrke D2 setzen
soundcmdret:    move.l  2(A0),D0
                bra     xsndret

;*** Setbuffer ***
setbuffer:      tst.w   (A0)            ; Setzen des Abspielbuffers?
                bne.s   setrecbuf       ; Nein: Aufnahmebuffer merken
                move.l  2(A0),startbuf  ; Adressen merken
                move.l  6(A0),endbuf
                bra     xsndretok
setrecbuf:      cmpi.w  #1,(A0)         ; Aufnahmebuffer?
                bne.s   setbuferr
                move.l  2(A0),recbuf    ; FÅr Buffptr merken
setbuferr:      bra     xsndreterr      ; Fehler signalisieren

;*** Setsndmode ***
setsndmode:     moveq   #0,D0           ; D0 lîschen
                move.w  (A0),D1         ; Modus in D1
                cmpi.w  #1,D1
                beq.s   set16stereo
                cmpi.w  #2,D1
                beq.s   sndmodeset
                tst.w   D1
                bne     xsndreterr      ; UngÅltiger Wert -> Fehler
set8stereo:     move.b  #1,D0           ; 8-Bit stereo
                bra.s   sndmodeset
set16stereo:    move.b  #2,D0           ; 16-Bit stereo
sndmodeset:     move.b  D0,sndmodstat   ; Status merken
                move.b  devconstat(PC),D1
                bra     setmodus        ; Schrittweite+Timerdata eintragen (siehe Devconnect)

;*** Setinterrupt ***
setinterrupt:   tst.w   2(A0)
                beq.s   no_int
                moveq   #-1,D0
                andi.b  #1,3(A0)
                beq.s   intemuoff       ; Nur Wiedergabe
                tst.w   (A0)
                beq.s   ta_on
                move.b  #-1,mfp7emuon
                bra     xsndretok
ta_on:          move.b  #-1,taemuon
                bra     xsndretok
no_int:
                moveq   #0,D0
intemuoff:      tst.w   (A0)
                beq.s   no_ta
                clr.b   mfp7emuon
                rte
no_ta:          clr.b   taemuon
                rte

;*** Buffoper ***
buffoper:       move.w  (A0),D0
                cmp.w   #-1,D0
                beq     retbufopstat    ; Bei -1 Status zurÅckgeben
                and.w   #%1100,D0       ; Soll Aufnahme gestartet werden?
                bne     xsndreterr      ; Ja: Fehler
                move.b  1(A0),D0        ; Modus -> D0
                btst    #0,D0           ; Starten oder beenden?
                bne.s   play_on         ; Wiedergabe starten
                move.b  #0,bufoperstat
                bsr     _play_off       ; Wiedergabe beenden
                bra     xsndretok
play_on:
                move.b  bufoperstat(PC),D1 ; Alter Status
                move.b  D0,bufoperstat  ; Neuen Status merken
                cmpi.b  #8,tacr.w       ; Event-Count-Mode?
                bne.s   nonewta         ; Timer A wurde nicht in Eventmode gesetzt
                move.l  $0134.w,taemuaddr ; Addresse merken
                move.b  #-1,taemuon
                move.b  tadr.w,D0
                move.b  D0,taemucount
                move.b  D0,taemudata
                bra.s   newtaok
nonewta:        btst    #0,D1           ; Wird noch gespielt?
                bne     xsndretok       ; Ja: Sample nicht neu starten
newtaok:        pea     dosoundoff(PC)  ; Dosound ausschalten
                move.w  #$20,-(SP)
                trap    #14
                addq.l  #6,SP
                move.l  endbuf(PC),D0
                sub.l   startbuf(PC),D0
                move.l  D0,size         ; LÑnge
                move.l  startbuf(PC),adr ; Startadresse
                bsr     _play_sam       ; Sample spielen
                bra     xsndretok
retbufopstat:
                moveq   #0,D0
                move.b  bufoperstat(PC),D0 ; Status zurÅckgeben
                rte

;*** Devconnect ***
devconnect:     tst.w   (A0)            ; Ist DMA-Ausgabe gemeint?
                bne     xsndreterr      ; Nein: Fehler melden + zurÅck
                cmpi.w  #8,2(A0)        ; Ist auch D/A-Wandler gemeint?
                bne     xsndreterr      ; Nein: TschÅû dann...
                tst.w   4(A0)           ; Richtige Taktart?
                bne     xsndreterr      ; Nein: zurÅck
                move.w  6(A0),D1        ; GewÅnschte Taktrate in D1
                move.b  D1,sndstat      ; Taktrate merken (fÅr Sndstatus)
                tst.w   D1
                beq     xsndreterr      ; Kein STE-KompatibilitÑtsmodus
                cmp.w   #16,D1
                bhs     xsndreterr      ; Bei unerlaubten Werten zurÅck
                move.b  D1,devconstat
                move.b  sndmodstat(PC),D0 ; Soundmodstatus holen

setmodus:                               ; Hier wird auch von sndsetmode hergesprungen
                tst.b   D0
                bne.s   getstereotabl
                lea     ptablmono(PC),A0 ; Zeiger auf Tabellen fÅr mono
                bra.s   setit
getstereotabl:  lea     ptablstereo(PC),A0 ; Tabelle fÅr stereo
setit:          add.b   D1,D1           ; d1*2
                move.b  -2(A0,D1.w),tdata ; Timerwert eintragen
                move.b  -1(A0,D1.w),D2  ; Schrittweite holen
                cmp.b   #2,D0
                bne.s   setplaystep
                add.b   D2,D2           ; Bei 16-Bit: d2*2
setplaystep:    move.b  D2,playstep+1   ; Schrittweite eintragen
                bra     xsndretok

;*** Sndstatus ***
sndstatus:      tst.w   (A0)
                bne.s   sndstatok       ; Kein Request => ZurÅck
                move.b  sndstat(PC),D0
                cmp.w   #16,D0
                bhs.s   sndstaterr      ; Werte > 16 sind nicht erlaubt
                tst.w   D0
                beq.s   sndstaterr
sndstatok:      bra     xsndretok
sndstaterr:     moveq   #3,D0
                bra     xsndret

;*** Buffptr ***
buffptr:        movea.l (A0),A0         ; Zeiger auf Struktur holen
                move.l  adr(PC),(A0)    ; Aktuelle Position eintragen
                move.l  recbuf(PC),4(A0) ; Aufnahmepuffer eintragen (sicherer!)
                bra     xsndretok


;reset-feste Routine zum Entfernen des Cookie Jars
old_resvalid:   DS.L 1          ;altes Reset-Valid
                DC.L 'XBRA'     ;XBRA-Protokoll
                DC.L 'XSND'     ;‰-soft-Kennung, Cookie-List
old_resvector:  DS.L 1          ;alter Reset-Vektor
cookie_reset:   clr.l   _p_cookies.w    ;Cookie Jar entfernen
                move.l  old_resvector(PC),resvector.w ;Reset-Vektor zurÅck
                move.l  old_resvalid(PC),resvalid.w
                jmp     (A6)            ;weiter mit dem RESET


                EVEN


; Die Variablen:
startbuf:       DC.L startbuf   ; Start des Samples
endbuf:         DC.L endbuf     ; Ende desselben
recbuf:         DC.L recbuf     ; Zeiger auf Aufnahmepuffer (fÅr Buffptr)

act_pd:         DS.L 1          ; Zeiger auf Zeiger auf akt. Basepage
lock_pd:        DC.L 0          ; EnthÑlt Basepage des Locksnd-Aufrufers

lvol:           DC.W 0          ; Linke LautstÑrke
rvol:           DC.W 0          ; Rechte LautstÑrke

playstep:       DC.W 1          ; Schrittweite

taemuaddr:      DC.L 0          ; Timer-A Emulator: Addresse
taemuon:        DC.B 0
mfp7emuon:      DC.B 0
taemucount:     DC.B 1          ; Timer-A Emu ZÑhler
taemudata:      DC.B 1          ; Timer-A Emu Data Register

sndmodstat:     DC.B 0          ; Die verschiedenen Stati
bufoperstat:    DC.B 0
devconstat:     DC.B 7
sndstat:        DC.B 7

                EVEN
cookiedat:      DC.W $0100
                DC.W 30
                DC.W 1
                DC.W 1
                DC.W 0
                DC.W 1
                DC.W 1
                DC.L 0
                DC.L 0
                DC.L 0
                DC.L 0
                DC.L 0

cookiejar:      DS.L newjarslots*2 ; Platz falls ein neuer Cookiejar angelegt werden muss.


; Play-Tabelle fÅr Devconnect und Sndmodstat:
; Aufbau: Timerwert, Schrittweite
ptablmono:      DC.B 26,2,38,2,50,2 ; 49.2KHz , 32.8KHz , 24.6KHz mono
                DC.B 31,1,38,1,44,1 ; 19.7KHz , 16.4KHz , 14.0KHz
                DC.B 50,1,56,1,63,1 ; 12.3KHz , 10.9KHz , 9.8KHz
                DC.B 69,1,75,1,81,1 ; 8.9KHz , 8.2KHz , 7.6KHz
                DC.B 86,1,92,1,99,1 ; 7.0KHz , 6.6KHz , 6.1KHz

ptablstereo:    DC.B 26,4,38,4,50,4 ; Das gleich nochmal, nur fÅr stereo
                DC.B 31,2,38,2,44,2
                DC.B 50,2,56,2,63,2
                DC.B 69,2,38,1,41,1
                DC.B 43,1,46,1,50,1

dosoundoff:     DC.B $07,$7F,$FF,$00

;### Hier folgt die Sample-Player-Routine: ###
*****************************************************************************
*        #==================================================#
*        # TOS PLAYER V1.00, Copyright (C) TOS Magazin 1991 #
*        #==================================================#
* Code: R.A.P.
* Entwickelt mit >>> TurboAss <<< (was sonst?) von Sigma-Soft!
* Dieses Programm dient zur schnellen Ausgabe von 8 Bit Samplen auf STs.
* Da die Ausgabe von Samples moeglichst wenig Zeit in Anspruch nehmen soll,
* war bei diesem Programm die Geschwindigkeit wichtiger als die Lesbarkeit.
* Insbesondere modifiziert der Code sich selbst, indem Samplewerte zu
* Sprungweiten umgerechnet werden. Natuerlich geht es noch ein paar Prozent
* schneller, aber ich denke diese Routine ist schon ein guter Kompromiss.
* Bei 12.5 kHz werden etwa 41% Rechenzeit verbraucht.
* Das Modul erlaubt folgende Aufrufe:
*  _init_sam
*  _play_sam ...
*  _play_off
*  _volume ...
*****************************************************************************

******************************************************************************
* die Variablen...
******************************************************************************
tdata:          DC.B 50         ; Timer A Teiler
                EVEN
size:           DC.L -1         ; Wiviele Daten noch ausgeben?
adr:            DC.L -1         ; Ab welcher Adresse?
buf1:           DC.L -1         ; Buffer 1
buf2:           DC.L -1         ; Buffer 2

******************************************************************************
* _play_sam
* Sample abspielen, Werte ab *start, Laenge len, Timerwert timer
* Die Frequenz des Samples in Hz: 614400/timer (Bsp. 49: 12.54kHz).
* Wichtig: Vor Aufruf von play_sam evtl. Tastenklick abschalten!
* timer sollte nicht unter 30 und darf nicht ueber 255 liegen!!!
* Der Rechenzeitverbrauch ist etwa 2025/timer in Prozent.
******************************************************************************
_play_sam:
                bsr.s   sound_off       ; Erstmal alles Abschalten
                move.l  buf2(PC),e_sm2+2 ; buf2 zuerst spielen, daher:
                bsr     fill_b2         ; buf2 selbst fuellen
                bsr     fill_b2         ; ja: buf2 nochmal fuellen
                bsr.s   sound_on
                rts

******************************************************************************
* _play_off():  Sofort aufhoeren: Sound abschalten
******************************************************************************
_play_off:
                movem.l A1-A2,-(SP)     ; Registers->Stack
                bsr.s   sound_off       ; Erstmal alles Abschalten
                movem.l (SP)+,A1-A2     ; Stack->Registers
                rts

******************************************************************************
* sound_on: Routine gibt den Sound aus, dazu muss er aber vorher abgesch.
*        worden sein (s_off)!
******************************************************************************
sound_on:
                move    #$2500,SR       ; Nur noch MFP
                move.b  #64,$FFFFFA17.w ; AEOI
                move.l  #entry,$0134.w  ; eintragen
                move.b  tdata(PC),tadr.w ; Timer A Data
                move.b  #1,tacr.w       ; Timer A Control
                bset    #5,$FFFFFA07.w  ; Timer A Int. enable
                bset    #5,$FFFFFA13.w  ; Timer A Int. mask
                move    #$2300,SR       ; Interrupts AN->SOUND
                rts

******************************************************************************
* sound_off: Sound vorzeitig abschalten
******************************************************************************
sound_off:
                bsr.s   s_off
                movem.l buf1(PC),A1-A2  ; Bufferadressen holen
                move.w  #br_fill,512(A1) ; bra fill_buffer an's Ende
                move.w  #br_fill,512(A2) ; dto.
                move    #$2300,SR       ; IPL-Status 3
                rts

* s_off: Unabhaengige Subroutine, SUPERVISOR
s_off:
                move    #$2700,SR       ; Alles sperren
                move.l  #imret,$0134.w
                clr.b   tacr.w          ; Timer A Stop
                rts

imret:          rte                     ; evtl. kommt noch ein Interr.!

******************************************************************************
* done: Das war's, jetzt kannste den Sample abschalten
*       Aufruf aus INTERRUPT (Rte)!
******************************************************************************
done:           bsr.s   s_off
                tst.b   taemuon
                beq.s   taemuok
                subq.w  #1,taemucount
                bne.s   taemuok         ; Noch nicht Null erreicht -> weiter
nop_it1:        move.w  6(SP),-(SP)     ; Wird bei 68010 + grîûer geNOPt
                pea     settaemcnt(PC)  ; Stack fÅr rte vorbereiten
                move.w  #$2700,-(SP)
                move.l  taemuaddr(PC),-(SP) ; Via rts springen
                rts
settaemcnt:     move.b  taemudata(PC),taemucount
taemuok:
                tst.b   mfp7emuon
                beq.s   mfp7emuok
nop_it2:        move.w  6(SP),-(SP)     ; siehe nop_it1
                pea     mfp7emuok(PC)
                move.w  #$2700,-(SP)
                move.l  mfpi7adr.w,-(SP)
                rts                     ; Via rts springen
mfp7emuok:
                move.l  startbuf(PC),adr ; Startadresse eintragen
                btst    #1,bufoperstat
                bne.s   samrepeat       ; Samplewiederholung -> nicht abschalten
                move.b  #0,bufoperstat
                rte
samrepeat:
                movem.l D0-D1/A0-A2,-(SP)
                move.l  endbuf(PC),D0
                sub.l   startbuf(PC),D0
                move.l  D0,size         ;> OrginallÑnge eintragen
                bsr     _play_sam
                movem.l (SP)+,D0-D1/A0-A2
                rte

******************************************************************************
* fill_buf: Diese Routine schreibt 256 Words in den Ausgabepuffer
*           Aufruf aus INTERRUPT (Rte)!
******************************************************************************
fill_buf:
                move.l  buf1(PC),e_sm2+2 ; Den Buffer wechseln!
;       * Timing halten: Interrupt emulieren (Trick 17)
nop_it3:        move.w  6(SP),-(SP)     ;> Nîtig fÅr 68010 aufwÑrts, wird bei 68000 geNOPt!
                pea     fi_1(PC)        ; Pseudo RÅcksprungadresse
                move.w  #$2500,-(SP)    ; Pseudo SR Register: Sub-Interrupt
                bra.s   entry
fi_1:
                movem.l D0-D1/A0-A2,-(SP) ; Register sichern (wg. Interrupt)
                bsr.s   fill_b2         ; nach buf2 Fuellen
                movem.l (SP)+,D0-D1/A0-A2 ; Register wieder holen
                rte                     ; Sub-Interrupt fertig!

;       * Den Bereich buf2 fuellen waehrend buf1 (evtl.) gespielt wird
fill_b2:
                movem.l buf1(PC),A0-A1  ; A0/A1: BUF1/2
                exg     A0,A1
                movem.l A0-A1,buf1      ; A0(/A1): BUF2(/1)
                movea.l adr(PC),A1      ; A1: von hier die Samplewerte
                lea     conv_tab(PC),A2 ; A2: Liste der Branches
                move.l  size(PC),D1
                bmi.s   fi_4            ; <0: Da kommt nichts mehr, Ignor.!
                move.w  #255,D0         ; 256 Words in Tabelle
                sub.l   #256,D1
                move.l  D1,size         ; Noch zu spielende Anzahl merken
                bgt.s   fi_3            ; Noch was uebrig? -> Naechstes Mal
                add.w   #256,D1         ; D1 muss >= 0 sein!
                move.w  D1,D0
                add.w   D1,D1
                move.w  #br_dine,0(A0,D1.w) ; An's Ende einen Branch (ENDE)
                subq.w  #1,D0
                bmi.s   fi_4            ; <0: Da ist nix mehr!
;       * Fuellschleife: Rechnet Daten in Code (Branches um)
;       * etwa  52 Zyklen pro Byte
fi_3:           clr.w   D1              ; [4]
                move.b  (A1),D1         ; [8] Samplewert holen (8 Bit)
                adda.w  playstep(PC),A1 ;> Schrittweite addieren
                eori.b  #128,D1         ;> Vorzeichen vertauschen
                add.w   D1,D1           ; [4] *2 = Tabellenindex bilden
                move.w  0(A2,D1.w),(A0)+ ;[20] Branch eintragen!
                dbra    D0,fi_3         ; [16] 256 mal
                move.l  A1,adr          ; Neuer Pointer merken
fi_4:           rts

******************************************************************************
* entry: wird vom Timer-A Interrupt aufgerufen. ACHTUNG: Selbstmodifizierender
*        Code! Der branch muss immer WORD sein!
*        Die Codeteile ab out_0 werden nur durch RAM-MODIFIKATION erreicht
*        und bewirken die Ausgabe eines einzelnen D-A-Wertes:
*        Ausgabe eines Wertes kostet ca. 188 Zyklen (ohne Berechnung)
******************************************************************************
entry:
e_sm2:          move.w  $FFFFFFFF,e_sm1+2 ; [28] Branch holen und patchen
                addq.w  #2,e_sm2+4      ; [12] Bytes weiter im Speicher!
e_sm1:          bra     *+1234          ; [12] Normalerweise: Buffer fuellen

out_0:
                move.l  #$08000000,$FFFF8800.w ; [24] Sound-Register 1
                move.l  #$09000000,$FFFF8800.w ; [24] Sound-Register 2
                move.l  #$0A000000,$FFFF8800.w ; [24] Sound-Register 3
                rte                     ; [64] Erledigt!

* Ab out_1: Uninitialisierte Daten

out_1:
;   hier wird der Code out0-1 noch 255 mal wiederholt (von initialisieren)
                DS.B 255*26
out_256:

conv_tab:
;   Anhand dieser Liste werden die Codeadressen der 256 Routinen berechnet
                DS.W 256

bothbuf:
;   Die Ausgabe-Buffer koennten sich ueberlappen (Word-Grenze!)
                DS.W 256*3+4    ; Bufferbereiche

br_fill         EQU fill_buf-2-e_sm1 ; Branch um Buffer zu fuellen
br_dine         EQU done-2-e_sm1 ; Branch wenn alles fertig


******************************************************************************
* _volume(int vol): Steuert die Lautstaerke (65k = 100%)
* Darf auch geaendert werden, solange Sample noch gespielt wird!
* LautstÑrke wird in D2 Åbergeben.
******************************************************************************
_volume:
                movem.l D3-D4,-(SP)     ; Registers->Stack, D0-2+A0-1 frei
                moveq   #0,D3           ; D3: Summation
;       * conv_tab enthaelt die Branches zu den einzelnen Volume-Werten
                lea     conv_tab(PC),A0
                move.w  #255,D0         ; 256 Schleifen
vo_1:           swap    D3              ; Highword holen
                move.w  D3,D4
                swap    D3
                cmp.w   #255,D4
                ble.s   vo_2            ; Darf nur Leiser werden!
                move.w  #255,D4
vo_2:           mulu    #26,D4
                addq.w  #2,D4           ; Branch ist immer 2 Bytes weiter
                move.w  D4,(A0)+        ; Offset als Index eintragen...
                add.l   D2,D3           ; Naechster Schritt
                dbra    D0,vo_1         ; That's it!
                movem.l (SP)+,D3-D4     ; Stack->Registers
                rts

resident_end:                           ; Bis hier ist X-SOUND resident!

******************************************************************************
* volt: DIE BESTE TABELLE VON ALLEN!
******************************************************************************
volt:
; Lautstaerkewerte im Wort 00 R8 R9 RA:
                DC.W $00,$0200,$0210,$0310,$0410,$0510,$0600,$0610,$0630,$0710,$0720,$0731
                DC.W $0741,$0810,$0820,$0831,$0841,$0900,$0910,$0930,$0940,$0950,$0951,$0953
                DC.W $0962,$0963,$0A10,$0A30,$0A31,$0A50,$0A52,$0A53,$0A62,$0A70,$0A72,$0B10
                DC.W $0B30,$0B31,$0B41,$0B51,$0B53,$0B62,$0B63,$0B72,$0B74,$0B80,$0B81,$0B83
                DC.W $0B84,$0B85,$0B91,$0B93,$0B94,$0C20,$0C21,$0C41,$0C51,$0C53,$0C62,$0C70
                DC.W $0C72,$0C74,$0C75,$0C82,$0C84,$0C85,$0C90,$0C92,$0C94,$0C95,$0C96,$0C97
                DC.W $0C97,$0CA0,$0CA3,$0D20,$0D31,$0D50,$0D52,$0D61,$0D70,$0D72,$0D74,$0D75
                DC.W $0D82,$0D84,$0D90,$0D91,$0D94,$0D95,$0D96,$0D97,$0DA0,$0DA0,$0DA3,$0DA5
                DC.W $0DA6,$0DA7,$0DA8,$0DA8,$0DA8,$0DB1,$0DB4,$0DB6,$0DB7,$0DB7,$0DB8,$0DB8
                DC.W $0DB9,$0DB9,$0DB9,$0DBA,$0DBA,$0DBA,$0DBA,$0DBA,$0DC2,$0DC5,$0DC6,$0E00
                DC.W $0E31,$0E52,$0E62,$0E72,$0E75,$0E81,$0E85,$0E90,$0E93,$0E96,$0E97,$0E98
                DC.W $0E98,$0EA2,$0EA6,$0EA7,$0EA8,$0EA9,$0EA9,$0EA9,$0EB3,$0EB7,$0EB8,$0EB9
                DC.W $0EB9,$0EBA,$0EBA,$0EBA,$0EBA,$0EC0,$0EC0,$0EC0,$0EC7,$0EC7,$0EC8,$0EC8
                DC.W $0EC9,$0ECA,$0ECA,$0ECA,$0ECA,$0ECB,$0ECB,$0ECB,$0ED0,$0ED0,$0ED0,$0ED7
                DC.W $0ED7,$0ED7,$0ED9,$0ED9,$0ED9,$0EDA,$0EDA,$0EDA,$0EDB,$0EDB,$0EDB,$0F00
                DC.W $0F00,$0F00,$0F70,$0F70,$0F90,$0F90,$0F90,$0FA0,$0FA0,$0FA9,$0FB0,$0FB0
                DC.W $0FB0,$0FBA,$0FBA,$0FC0,$0FC0,$0FC9,$0FC9,$0FCA,$0FCA,$0FCA,$0FCB,$0FCB
                DC.W $0FCB,$0FCC,$0FCC,$0FCC,$0FD0,$0FD0,$0FD0,$0FD0,$0FD0,$0FD0,$0FD0,$0FDB
                DC.W $0FDB,$0FDB,$0FDB,$0FDB,$0FDB,$0FDB,$0FDC,$0FDC,$0FDC,$0FDC,$0FDC,$0FDC
                DC.W $0FDD,$0FDD,$0FDD,$0FDD,$0FDD,$0FDD,$0FE0,$0FE0,$0FE0,$0FE0,$0FE0,$0FE0
                DC.W $0FE0,$0FE0,$0FE0,$0FEC,$0FEC,$0FEC,$0FEC,$0FEC,$0FEC,$0FED,$0FED,$0FED
                DC.W $0FED,$0FED,$0FED,$0FED

******************************************************************************
* _init_sam(): zuerst 1 mal aufrufen. Initialisiert die Ausgabe-
*  routine und setzt Volume auf 100%
******************************************************************************

_init_sam:
                movem.l D1-D7/A1-A6,-(SP) ; Registers->Stack
;       * 256 fast gleiche Routinen (spart Platz) erzeugen...
                lea     out_1(PC),A1    ; Destin-Code
                move.w  #254,D1         ; 254 mal kopieren
ini_1:          lea     out_0(PC),A0    ; Source-Code
                move.w  #25,D0          ; 26 Bytes
ini_2:          move.b  (A0)+,(A1)+     ; 1 Byte kopieren
                dbra    D0,ini_2        ; das ganze 26 mal
                dbra    D1,ini_1        ; und das dann 255 mal
;       * ...einziger Unterschied: die Registerwerte (aus volt)
                lea     volt(PC),A0     ; Da sind die Daten...
                lea     out_0(PC),A1    ; Dort der Code
                move.w  #255,D0         ; 256 mal...
ini_3:          move.w  (A0)+,D1        ; D1: 00.R8 R9.RA
                move.w  D1,D2           ; D2 zum Arbeiten
                andi.w  #$0F00,D2       ; D2: R8.00 00.00
                move.w  D2,4(A1)        ; Register 8 eintragen
                move.w  D1,D2           ; D2 ...
                lsl.w   #4,D2
                andi.w  #$0F00,D2       ; D2: R9.00 00.00
                move.w  D2,4+8(A1)      ; Register 9
                move.w  D1,D2           ; D2 ...
                ror.w   #8,D2
                andi.w  #$0F00,D2       ; D2: RA.00 00.00
                move.w  D2,4+16(A1)     ; Register 10 eintragen
                lea     26(A1),A1       ; Auf naechsten Tabellenwert
                dbra    D0,ini_3        ; 256 mal...
;       * Einige Variablen muessen initialisiert werden...
                lea     bothbuf(PC),A0  ; Adresse des Buffers
                move.l  A0,D0           ; muss auf einer 512-Byte Grenze beg!
                ori.w   #511,D0
                addq.l  #1,D0           ; so!
                move.l  D0,buf1         ; Das ist dann Buffer 1
                add.l   #512+2,D0       ; 256 Words + fillbuf-Branch
                move.l  D0,buf2         ; dahinter liegt Buffer 2
                move.w  #$FFFF,D2       ; Volume 100%
                bsr     _volume         ; Tabelle setzen
                tst.w   _longframe.w    ; Ist CPU ein 68000er?
                bne.s   is68000         ; Falls ja mÅssen 3 Stellen geNOPt werden
                move.l  #$4E714E71,D0   ; 2 * NOP in D0
                move.l  D0,nop_it1      ; Zwei NOPs nach nop_it1
                move.l  D0,nop_it2      ;  + nop_it2
                move.l  D0,nop_it3      ;  + nop_it3
is68000:
                movem.l (SP)+,D1-D7/A1-A6 ; Stack->Registers
                rts


;### Routine initialisieren ###
init:
                clr.l   -(SP)
                move.w  #$20,-(SP)      ; In Supervisor umschalten
                trap    #1
                addq.l  #6,SP
                move.l  D0,save_sp      ; Alten Stack merken

                movea.l _sysbase.w,A0
                move.w  2(A0),D0        ; TOS-Version ermitteln
                cmp.w   #$0400,D0       ; Bei TOS ab V4.00 sinnlos
                bhs     error1
                cmp.w   #$0102,D0
                blt.s   tos1_0
                move.l  $28(A0),act_pd  ; Bei TOS 1.02 aufwÑrts einfach holen
                bra.s   actpdok
tos1_0:         move.l  #$602C,act_pd   ; Bei TOS 1.00: Feste Addi eintragen
                move.w  $1C(A0),D1
                and.b   #%11111110,D1   ; Palflag vergessen
                cmp.b   #8,D1           ; Spanisches TOS 1.00?
                bne.s   actpdok
                move.l  #$873C,act_pd   ; Ja: andere Addi
actpdok:
                movea.l $B8.w,A0        ; Alten Vektor nach A0
xbraloop:       cmpi.l  #'XBRA',-12(A0) ; Nach XBRA-Kette suchen
                bne.s   not_installed
                cmpi.l  #'XSND',-8(A0)
                beq     error3          ; Wenn schon installiert: Fehlermeldung
                movea.l -4(A0),A0
                bra.s   xbraloop
not_installed:
                move.l  #'_SND',D0      ; Nach Cookie suchen
                bsr.s   hunt_cookie
                tst.l   D0              ; D0 signalisiert, ob Cookie gefunden!
                bne.s   nocookie        ; Wenn Cookie nicht gefunden, dann ok
                btst    #0,D1
                beq     error2          ; Keine Soundmîglichkeiten = Abbruch
nocookie:

                move.l  #'McSn',D0
                move.l  #cookiedat,D1
                bsr     insert_cookie

                bsr     _init_sam       ; Sample-Routine installieren

                move.l  save_sp(PC),-(SP) ; In User-Mode zurÅck
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP

                pea     mytrap14(PC)
                move.w  #$2E,-(SP)      ; Kennung fÅr Xbios
                move.w  #5,-(SP)        ; Routine einklinken
                trap    #13             ; Setexec
                addq.l  #8,SP
                move.l  D0,oldtrap14    ; Alter Wert sichern

                pea     myetvterm(PC)
                move.w  #$0101,-(SP)    ; Kennung fÅr etv_term
                move.w  #5,-(SP)        ; Setexec
                trap    #13
                addq.l  #8,SP
                move.l  D0,oldetvterm   ; Alten Wert merken

                pea     installedtxt(PC)
                move.w  #9,-(SP)        ; Einschaltmeldung ausgeben
                trap    #1
                addq.l  #6,SP

                clr.w   -(SP)
                move.l  #$0100+resident_end-start,-(SP) ; LÑnge residenten Codes
                move.w  #$31,-(SP)
                trap    #1              ; PRG via Ptermres beenden


; Cookie suchen (siehe ST-Magazin 3/90)
hunt_cookie:
                move.l  D0,D2
                move.l  _p_cookies.w,D0
                beq.s   cookie_ex
                movea.l D0,A0
cookie_l:
                move.l  (A0)+,D3
                move.l  (A0)+,D1
                cmp.l   D2,D3

                beq.s   cookie_f
                tst.l   D3
                bne.s   cookie_l
cookie_ex:
                moveq   #-1,D0
                rts
cookie_f:
                moveq   #0,D0
                rts


insert_cookie:  movem.l D2-D5/A1,-(SP)
                move.l  _p_cookies.w,D3 ;Zeiger auf das Cookie Jar holen
                beq.s   insert_newjar   ;ist leer => Liste einrichten
                movea.l D3,A1
                moveq   #0,D4           ;Anzahl der Slots
ins_oldjar_l:
                addq.w  #1,D4           ;Slotanzahl erhîhen
                movem.l (A1)+,D2-D3     ;Namen und Wert eines Cookies holen
                tst.l   D2              ;leeren Cookie gefunden?
                bne.s   ins_oldjar_l    ;Nein => weiter suchen
                cmp.l   D3,D4           ;alle Slots belegt?
                beq.s   ins_copynewjar  ;Ja! => neue Liste anlegen
                movem.l D0-D3,-8(A1)    ;neuen Cookie & Listenende einfÅgen
                moveq   #0,D0           ;alles ok!
                bra.s   insert_cookie_x ;und raus

insert_newjar:
                move.l  resvector.w,old_resvector
                move.l  resvalid.w,old_resvalid ;alten Reset-Vektor merken
                move.l  #cookie_reset,resvector.w
                move.l  #$31415926,resvalid.w ;und eigenen einsetzen
                lea     cookiejar(PC),A0
                move.l  A0,_p_cookies.w ;Cookie Jar initialisieren
                moveq   #0,D2           ;Markierung: Ende der Cookie-List
                move.l  #newjarslots,D3 ;Anzahl der Slots nach D3
                movem.l D0-D3,(A0)      ;Namen und Wert des Cookies einsetzen
                moveq   #1,D0           ;Liste resetfest eingerichtet, alles ok
                bra.s   insert_cookie_x ;und raus

insert_cookie_e:
                moveq   #-1,D0          ;Fehler, Cookie nicht eingetragen
                bra.s   insert_cookie_x ;und raus

ins_copynewjar:
                cmp.l   #newjarslots,D4 ;reicht der Platz?
                ble.s   insert_cookie_e ;Nein => Fehler und raus
                movea.l _p_cookies.w,A1 ;Anfang der Liste erneut holen
                lea     cookiejar(PC),A0
                move.l  A0,_p_cookies.w ;neuen Cookie Jar eintragen
                subq.w  #2,D4           ;Ende nicht kopieren (-1 fÅr DBRA)
insert_cookie_m:move.l  (A1)+,(A0)+     ;EintrÑge der Liste kopieren
                move.l  (A1)+,(A0)+
                dbra    D4,insert_cookie_m
                move.l  #newjarslots,D3 ;Anzahl der Slots
                movem.l D0-D3,(A0)      ;eigenes Element eintragen + Listenende
                moveq   #2,D0           ;alles ok, resident bleiben
insert_cookie_x:
                movem.l (SP)+,D2-D5/A1
                rts




; Meldung, daû TOS-Version zu groû ist
error1:
                pea     err1txt(PC)
                bra.s   error
; Meldung, daû keine Soundmîglichkeit vorhanden ist
error2:
                pea     err2txt(PC)
                bra.s   error
; Meldung, daû schon installiert
error3:
                pea     err3txt(PC)
; Fehlermeldung ausgeben
error:
                move.w  #9,-(SP)        ; Cconws
                trap    #1
                addq.l  #6,SP
                move.w  #7,-(SP)        ; Crawcin
                trap    #1
                clr.w   (SP)            ; Programm verlassen
                trap    #1


                DATA
err1txt:        DC.B 13,10,"X-SOUND ist nur unter TOS 4.00 sinnvoll!",13,10,0
err2txt:        DC.B 13,10,"Kein Soundchip vorhanden!?!",13,10,0
err3txt:        DC.B 13,10,"X-SOUND ist schon installiert!",13,10,0
installedtxt:
                DC.B 13,10,13,10,"X-SOUND V1.0 wurde installiert."
                DC.B 13,10,189," by Thomas Huth, 1995/1996",13,10,0

                BSS
save_sp:        DS.L 1
                END
