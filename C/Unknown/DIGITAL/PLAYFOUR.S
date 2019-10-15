*****************************************************************************
*
* File: PLAYFOUR.S
*
* #========================================================#
* # TOS MULTI-PLAYER V1.00, Copyright (C) TOS Magazin 1991 #
* #========================================================#
*
*
* Entwickelt mit >>> TurboAss <<< (was sonst?) von Sigma-Soft!
* In diesem Sourcecode sind einige spezielle TurboAss-Befehle
* enthalten, die aber ueberaus nuetzlich sind!
*
* Vorgesehen zum Linken mit Programmen in C
*
* 4 Kanal Player fuer Samples, voll Interruptgesteuert
*
* Speziell auf STE-Rechnern wird die Initialisierung des MICROWIRE-Interface
* untersttzt indem die Hoehen etwas abgesenkt werden.)
*
* Achtung OMIKRON.Basic-Programmierer: OM.Basic ruft alle Programme
* immer im SUPERVISOR-Modus auf, das mag der Player nicht.
*
* Ein Interrupt konstanter Frequenz (mein Vorschlag: 12.5 kHz) bedient
* den "DA-Wandler" (siehe vorhergehender Teil der Serie) mit Sample-
* werten aus 2 Buffern (buf1/2). Jeder Buffer enthaelt 256 Werte, wobei
* die Buffereintraege Sprungweiten darstellen: Jedem der 256 moeglichen
* Werte entspricht eine kleine DA-Routine (ab out_0). Ist einer der Buffer
* leer, wird er in einem unterlagerten Interrupt aufgefuellt, indem am
* Ende eines jeden Buffers ein Branch auf die Fuellroutine ein-
* getragen ist (fill_buf).
*
* Da die Ausgabe von Samples moeglichst wenig Zeit in Anspruch nehmen soll,
* war bei diesem Programm die Geschwindigkeit wichtiger als die Lesbarkeit.
* Insbesondere modifiziert der Code sich an vielen Stellen selbst!
*
* Bei 12.5 kHz werden etwa 62% Rechenzeit verbraucht, aber auch schon
* mit niedereren Frequenzen lassen sich ganz gute Ergebnisse erzielen.
* Z. B. liegt bei 10kHz der Zeitverbrauch bei 50%!
*
* Das Modul erlaubt folgende Aufrufe von C aus:
*
* - init_sam()
* - play_on()
* - play_off()
* - load_sam()
* - volume()    *
* - load_sam()
* - note_on()   *
* - note_off()  *
* - sustain()   *
* - pitch_b()   *
* - vibrato()   *
* - arpeggio()  *
* - prg_chg()   *
*
* - clock
* - psamples
*
* Nur die Routinen mit einem (*) duerfen auch aus Interrupts auf-
* gerufen werden (also im SUPERVISOR). Routinen ohne (*) duerfen
* duerfen NUR im USERMODE aufgerufen werden und nicht aus Interrupts!
* Wichtig: Als Interrupt ist nur der HBL oder der VBL erlaubt, da es
* sonst zu Prioritaetskonflikten kommt.
*
* Globals: Die meisten C Compiler stellen externen Variablen einen
* Underscore "_" voran!
*
* Register: Alle C-Routinen ver„ndern nur D0/A0
*
* Specials: Der Kanal #15 nimmt eine Sonderstellung ein: Auf ihm werden
* note_on()-Aufrufe anhand der Sampleliste gemappt (Gut fuer Drums) und
* note_off()-Aufrufe ignoriert (Drumsamples duerfen immer ausklingen!).
*
*****************************************************************************

    OPT D+
;       * Funktionsdeklarationen
    GLOBAL _init_sam,_volume,_play_off,_play_on,_load_sam
    GLOBAL _note_on,_note_off,_sustain,_pitch_b,_vibrato
    GLOBAL _arpeggio,_prg_chg

;       * Globale Variablen
    GLOBAL _clock,_psamples             ; Uhrzeit und Feld der Samplesadressen

******************************************************************************
* volt: DIE BESTE D/A-TABELLE VON ALLEN!
******************************************************************************

volt:
; Lautstaerkewerte im Wort 00 R8 R9 RA:
    DC.W $0000,$0200,$0210,$0310,$0410,$0510,$0600,$0610,$0630,$0710,$0720,$0731
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
* die Variablen...
******************************************************************************

;       * Variablen Sample 0
adr0:                                   ; Adresse Sample 0
    DC.L -1
step0:                                  ; Schrittweite Sample 0
    DC.L -1
indx0:                                  ; Index im Sample 0
    DC.L -1
pitch0:                                 ; 8 Additive Pitch Sample 0
    DC.L -1,-1,-1,-1,-1,-1,-1,-1
pind0:                                  ; Welcher der 3 Pitch? (nur HW)
    DC.L -1
maxpind0:                               ; Maximale Pitchanzahl (nur HW)
    DC.L -1
sustain0:                               ; Sustain ON/OFF Sample 0 (nur HW)
    DC.L -1

;       * Variablen Sample 1
adr1:                                   ; dto. Sample 1,2,3
    DC.L -1
step1:
    DC.L -1
indx1:
    DC.L -1
pitch1:
    DC.L -1,-1,-1,-1,-1,-1,-1,-1
pind1:
    DC.L -1
maxpind1:
    DC.L -1
sustain1:
    DC.L -1

;       * Variablen Sample 2
adr2:
    DC.L -1
step2:
    DC.L -1
indx2:
    DC.L -1
pitch2:
    DC.L -1,-1,-1,-1,-1,-1,-1,-1
pind2:
    DC.L -1
maxpind2:
    DC.L -1
sustain2:
    DC.L -1

;       * Variablen Sample 3
adr3:
    DC.L -1
step3:
    DC.L -1
indx3:
    DC.L -1
pitch3:
    DC.L -1,-1,-1,-1,-1,-1,-1,-1
pind3:
    DC.L -1
maxpind3:
    DC.L -1
sustain3:
    DC.L -1

;       * Allgemeine Variablen
buf1:                                   ; Buffer 1
    DC.L -1
buf2:                                   ; Buffer 2
    DC.L -1
tdata:                                  ; Timer A Teiler
    DC.W -1                             ; 49: 12.538 kHz Interrupt

woistwas:                               ; Zeiger auf die Datenbereiche
    DC.L adr0,adr1,adr2,adr3

; * Silentio: Der ganz leise Sample...
; * Vor einem Sample liegen auch noch einige Informationen
silentio:
    DC.L 2
    DC.L 2
    DC.L 2
    DC.L 2
zerosam:                                ; Hierauf zeigen abgeschaltete Sam.
    DC.B 127,0

iserve:                                 ; Flag: Buffer in Arbeit?
    DC.W 0

_clock::                                ; Playerclock: alle Takt/256
    DC.W 0

; * Hier liegen 31 Zeiger auf Sampledaten...
; * Das Feld darf auch extern benutzt werden z. Bsp. um die Samples
; * mit einem Entpacker zu laden, wie in der Demo gezeigt
_psamples::
    DS.L 32

; * Hier liegen 16 Zeiger auf Sampledaten, Das Programm eines jeden Kanals
pkanalsam:
    DS.L 16

******************************************************************************
*
* C: prg_chg(int kanal,int prg) Stellt auf dem Kanal (0..15) das Programm
*    0..31 ein (0..31 wird mit Modulo berechnet)
*
******************************************************************************

_prg_chg::
        move.w          D1,-(SP)        ; D1 sichern
        move.w          8(SP),D0        ; D0: Programm
        andi.w          #31,D0          ;     modulo 32
        add.w           D0,D0
        add.w           D0,D0

        move.w          6(SP),D1        ; D1: Kanal
        add.w           D1,D1
        add.w           D1,D1

        lea             pkanalsam(PC),A0 ; -128(x.x) geht gerade noch...
        move.l          -128(A0,D0.w),0(A0,D1.w) ; Eintragen
        move.w          (SP)+,D1
        rts

******************************************************************************
*
* C: arpeggio(int kanal, int note1, int note 2, int note 3): Spielt ein
*    3-Ton Arpeggio (Tonhoehen in MIDI-Noten, wie note_on)
*    (Funktioniert auch auf Kanal 15).
*
******************************************************************************

_arpeggio::
        lea             (SP),A0
        movem.l         D1-D2/A1-A3,-(SP)
        lea             (A0),A2         ; A2: Merkt den Stackpoiner

        move.w          4(A2),D0        ; Kanal holen
        andi.w          #3,D0
        add.w           D0,D0           ; fuer einen der 4 Player-Kanaele!
        add.w           D0,D0

        lea             woistwas(PC),A3
        movea.l         0(A3,D0.w),A3   ; A3: Adr0

    BASE A3,adr0                        ; A3: Basisregister des Arrays
        clr.w           maxpind0(A3)    ; maxpind loeschen
        clr.w           pind0(A3)       ; pind loeschen

        move.w          6(A2),-(SP)     ; note1
        move.w          4(A2),-(SP)     ; kanal
        bsr             _note_on        ; 1. Note versuchen anzuschalten
        addq.w          #4,SP

        move.l          step0(A3),D0    ; Was kam raus?
        clr.l           step0(A3)
        move.l          D0,pitch0(A3)   ; pitch0[0] = Note 0

        move.w          8(A2),D0        ; 2. Note holen
        sub.w           #36,D0
        add.w           D0,D0
        add.w           D0,D0
        lea             steps(PC),A1
        move.l          0(A1,D0.w),pitch0+8(A3) ; Schrittweite 2. Frequenz

        move.w          10(A2),D0       ; 3. Note holen
        sub.w           #36,D0
        add.w           D0,D0
        add.w           D0,D0
        move.l          0(A1,D0.w),pitch0+4(A3) ; Schrittweite 3. Frequenz

        move.w          #2*4,maxpind0(A3) ; Starte Arpeggio!
    BASE A3,OFF
        movem.l         (SP)+,D1-D2/A1-A3
        rts

******************************************************************************
*
* C: pitch_b(int kanal, int pitch) Stellt den Kanal auf Pitch-Bender
*    pitch 0..127
*
******************************************************************************

_pitch_b::
        move.w          4(SP),D0        ; Kanal holen
        andi.w          #3,D0
        add.w           D0,D0           ; fuer einen der 4 Player-Kanaele!
        add.w           D0,D0

        lea             woistwas(PC),A0
        movea.l         0(A0,D0.w),A0
        lea             (pitch0-adr0)(A0),A0 ; A0: Pitch[0]

        clr.w           4*9(A0)         ; maxpind loeschen
        clr.w           4*8(A0)         ; pind loeschen

        move.w          6(SP),D0        ; von 0..127 auf
        sub.w           #64,D0          ; -64..0..63
        add.w           D0,D0           ; -127..127
        ext.l           D0
        asl.l           #8,D0

        move.l          D0,(A0)         ; Eintragen!
        rts

******************************************************************************
*
* C: vibrato(int kanal, int size) Schaltet fuer den Kanal ein Vibrato an
*    size: 0..127
*
******************************************************************************

_vibrato::
        move.w          4(SP),D0        ; Kanal holen
        andi.w          #3,D0
        add.w           D0,D0           ; fuer einen der 4 Player-Kanaele!
        add.w           D0,D0

        lea             woistwas(PC),A0
        movea.l         0(A0,D0.w),A0
        lea             (pitch0-adr0)(A0),A0 ; A0: Pitch[0]

        clr.w           4*9(A0)         ; maxpind loeschen
        clr.w           4*8(A0)         ; pind loeschen

        move.w          6(SP),D0        ; von 0..127 auf
        lsl.w           #6,D0           ; 0...8192
        ext.l           D0

        clr.l           (A0)            ; 0 Listenplatz-Nr.
        move.l          D0,4(A0)        ; 1
        move.l          D0,12(A0)       ; 3
        neg.l           D0
        clr.l           16(A0)          ; 4
        move.l          D0,20(A0)       ; 5
        move.l          D0,28(A0)       ; 7
        neg.l           D0
        add.l           D0,D0
        move.l          D0,8(A0)        ; 2
        neg.l           D0
        move.l          D0,24(A0)       ; 6

        move.w          #7*4,4*9(A0)    ; Vibrato: 8 Eintraege breit
        rts

******************************************************************************
*
* C: sustain(int kanal, int newsus) Sustain einschalten, newsus:
*    0: Sustain aus, <>0; Sustain an, Vorsicht bei ungeloopten Samplen!!!
*
******************************************************************************

_sustain::
        move.w          4(SP),D0        ; Kanal holen: Sustain gilt immer
        andi.w          #3,D0
        add.w           D0,D0           ; fuer einen der 4 Player-Kanaele!
        add.w           D0,D0

        lea             woistwas(PC),A0
        movea.l         0(A0,D0.w),A0
        move.w          6(SP),(sustain0-adr0)(A0) ; Sustain merken...
        rts

******************************************************************************
*
* C: note_on(int kanal,int note) Startet auf Kanal die Note (Nr. 36..96)
*    Kanal 15 nimmt eine Sonderstellung ein: Hier wird wird die Ton-
*    hoehe anhand der Samplestabelle gemappt (Sinn: Drums!), dabei wird
*    das Schalgzeug auf den Playkanal 3 gelegt.
*
******************************************************************************

_note_on::
        lea             (SP),A0
        movem.l         D1-D3/A1,-(SP)  ; Register sichern

        move.w          6(A0),D0        ; D0: Notennummer holen
        sub.w           #36,D0          ; <36: zu tief!
        bmi.s           n_ign
        cmp.w           #60,D0          ; >=96: zu hoch!
        bge.s           n_ign

        add.w           D0,D0           ; Index in Stepliste errechnen
        add.w           D0,D0           ; oder Sampleliste

        cmpi.w          #15,4(A0)       ; Drumkanal (#15)?
        beq.s           drum_on         ; Ja: ->Drums

        lea             steps(PC),A1
        move.l          0(A1,D0.w),D2   ; D2: @ Frequenz-Step

        move.w          4(A0),D0        ; Kanal holen
        add.w           D0,D0
        add.w           D0,D0
        lea             pkanalsam(PC),A1
        move.l          0(A1,D0.w),D1   ; D1: @ Sampleadr. des Kanals
        add.l           #16,D1          ; Sample beginnt 16 Bytes dahinter

        andi.w          #15,D0          ; 16 MIDI Kanaele aber nur 4 Players
        lea             woistwas(PC),A1
        movea.l         0(A1,D0.w),A1   ; A1: Zeigt auf Samplevariablen

        tst.w           (sustain0-adr0)(A1) ; Sustain aktiv?
        bne.s           n_frq           ; JA: Nur Frequenz setzen!

n_doch: moveq           #0,D3           ; D3: @ Index auf 0

        movem.l         D1-D3,(A1)      ; 3 auf einen Streich!
n_ign:  movem.l         (SP)+,D1-D3/A1
        rts

n_frq:  cmpi.l          #zerosam,(A1)   ; Schon was drauf ?
        beq.s           n_doch          ; Dann trotzdem!
        move.l          D2,(step0-adr0)(A1) ; Nur Frequenz!
        bra.s           n_ign

;       * Drumnote!
drum_on:
        lea             adr3(PC),A1     ; Zeigt auf Playkanal 3
        move.l          #65536,D2       ; D2: @ Schrittweite 1

        andi.w          #127,D0         ; auf 32 Moegliche begrenzen
        lea             _psamples(PC),A0 ; Adresse der 32 Zeiger
        move.l          0(A0,D0.w),D1
        add.l           #16,D1          ; D1: @ Sampleadresse
        bra.s           n_doch          ; Schreiben wie bisher...

******************************************************************************
*
* C: note_off(int kanal): Kanal abschalten,
*    wird auf Kanal 15 ignoriert (Drumkanal)
*    (Wer geloopte Samples auf Kanal 15 legt ist selbst schuld!).
*
******************************************************************************

_note_off::
        move.w          4(SP),D0
        cmpi.w          #15,D0          ; Kanal #15?
        beq.s           no_nt           ; Ignorieren!
        movem.l         D1-D2/A1,-(SP)

        add.w           D0,D0
        add.w           D0,D0
        andi.w          #15,D0          ; 16 MIDI Kanaele aber nur 4 Players
        lea             woistwas(PC),A0
        movea.l         0(A0,D0.w),A0   ; A0: Zeigt auf Samplevariablen

        tst.w           (sustain0-adr0)(A0) ; Sustain?
        bne.s           n_off           ; JA: Nicht abschalten!

        move.l          #zerosam,D0     ; Sample 'silentio'
        movea.l         (A0),A1
        cmp.l           A1,D0           ; Garnix da?
        beq.s           n_off           ; Finger weg von silentio!

        tst.w           -2(A1)          ; Geloopter Sample ?
        beq.s           n_onc

;       * Sample mit Loop: Ausfaden lassen
        subq.l          #8,(A0)         ; Auf Fade-Info schalten
        addq.w          #8,(indx0-adr0+2)(A0) ; Im Index vermerken
        bra.s           n_off           ; Das war's

;       * Sample ohne Loop: Abschalten!
n_onc:
        moveq           #0,D1           ; Step 0
        moveq           #0,D2           ; Index 0
        movem.l         D0-D2,(A0)      ; Alle 3 auf einmal

n_off:
        movem.l         (SP)+,D1-D2/A1
no_nt:
        rts

******************************************************************************
*
* C: long load_sam(char *adresse, char *name, int volume, int index)
*    Laedt einen SMS-Sample mit Namen *name an die Adresse
*    adresse. Volume: 0..32..63 Aufruf-Mode: USER
*    index: Nummer des Samples (fuer's Protokoll, 0..31)
*    Return: >0: Anzahl der geladenen Bytes, <=0: Fehler!
*    Wichtig: init_sam() setzt das Sampleprotokoll zurueck!
*
******************************************************************************

_load_sam::
        lea             (SP),A0
        movem.l         D1-D7/A1-A6,-(SP) ; Register sichern

        movea.l         4(A0),A6        ; A6: Zeigt auf Adresse
        move.w          12(A0),D7       ; D7: Volume 0..32..63
        move.w          14(A0),D4       ; D4: Samplenummer
        add.w           D4,D4
        add.w           D4,D4
        lea             _psamples(PC),A1 ; Adresse intern merken...
        move.l          A6,0(A1,D4.w)   ; in psamples

;       * Datei oeffnen
        clr.w           -(SP)           ; 0: READ
        move.l          8(A0),-(SP)     ; Dateiname uebergeben
        move.w          #$003D,-(SP)    ; Fopen
        trap            #1
        lea             8(SP),SP
        tst.l           D0
        bmi             lo_f            ; <0: Fehler aufgetreten!
        move.w          D0,D6           ; D6: Handle

        pea             magic(PC)       ; Header lesen
        move.l          #8,-(SP)        ; 8 Bytes lang
        move.w          D6,-(SP)        ; Handle
        move.w          #$003F,-(SP)    ; Fread
        trap            #1
        lea             12(SP),SP

        cmpi.l          #8,D0           ; Genau 8?
        bne.s           lo_c
        cmpi.l          #$00002938,magic ; MACIC: $2938, sonst ist's
        bne.s           lo_c            ; kein SMS Sample.

        pea             (A6)            ; Sampledaten lesen
        move.l          #32766,-(SP)    ; Maximal 32 kB erlaubt!
        move.w          D6,-(SP)        ; Handle
        move.w          #$003F,-(SP)    ; Fread
        trap            #1
        lea             12(SP),SP
        tst.l           D0              ; Fehler ?
        ble.s           lo_c            ; < 0 !!!!
        ori.b           #1,D0           ; D0: ODD
        addq.l          #1,D0           ; D0: EVEN

        move.l          D0,D5           ; D5 merkt sich die Laenge

        bsr.s           lo_cls          ; Datei schliessen

;       * In dieser Schleife wird der Sample auf eine beliebige Laut-
;       * staerke umgerechnet. Meine Empfehlung: Die durchschnittliche
;       * Lautstaerke sollte etwa 32 betragen.
        lea             16(A6),A0       ; A0: SOURCE
        move.w          D7,D3           ; D3: VOLUME
        move.l          D5,D0           ; wiviel war's nochmal?
        subi.l          #17,D0          ; D0: COUNTER.w
        ble.s           lo_f            ; So kurze Sample gibt's nicht!

nvol:   clr.w           D1              ; Sample auf Volume umrechnen
        move.b          (A0),D1         ; und auf (0..255) clippen
        sub.w           #128,D1
        muls            D3,D1           ; (-128..127)*(1..63)
        asr.w           #6,D1           ; bei Vol32: -64..64
        add.w           #127,D1
        bpl.s           grmion
        clr.b           (A0)+
        bra.s           dolvo
grmion: cmp.w           #255,D1
        bgt.s           grmax
        move.b          D1,(A0)+
        bra.s           dolvo
grmax:  move.b          #255,(A0)+
dolvo:  dbra            D0,nvol

        move.l          D5,D0           ; Alles Ok: Laenge zurueckgeben
lo_ok:
        movem.l         (SP)+,D1-D7/A1-A6 ; Register holen
        rts
lo_c:
        bsr.s           lo_cls          ; Fehler mit Fclose
lo_f:                                   ; Fehler aufgetreten!
        moveq           #-1,D0
        bra.s           lo_ok

;       * Datei schliessen
lo_cls:
        move.w          D6,-(SP)        ; Handle
        move.w          #$003E,-(SP)
        trap            #1
        addq.l          #4,SP
        rts

magic:                                  ; Dateikennung ueberpruefen
    DC.L -1,-1

******************************************************************************
*
* C: long *play_on(int timer) Sound-Interrupt aktivieren, Variablen setzen
*    Returnwert: Zeiger auf die Adressen adr0-adr3 (woistwas, zur Spielerei)
*    USERMODE
*
******************************************************************************

_play_on::
        move.w          4(SP),tdata     ; Timer merken
        movem.l         D1-D7/A1-A6,-(SP) ; Registers->Stack
        bsr             sound_off       ; Erstmal alles Abschalten

;       * Sampleadressen und Schrittweiten auf 0 setzen, Index auf 0
        lea             adr0(PC),A0
        move.w          #((buf1-adr0)/4)-1,D0 ; Variablen der 4 Player
pon_3:  clr.l           (A0)+
        dbra            D0,pon_3

        move.l          #zerosam,D0
        move.l          D0,adr0         ; Sample zeigen auf '127'
        move.l          D0,adr1
        move.l          D0,adr2
        move.l          D0,adr3

;       * Sonstige Variablen init.
        clr.w           _clock          ; Start mit 0 Uhr!
        lea             pkanalsam(PC),A0
        move.w          #15,D0
        lea             silentio(PC),A1
pon_2:  move.l          A1,(A0)+
        dbra            D0,pon_2

        move.l          buf2(PC),e_sm2+2 ; buf2 zuerst spielen, daher:

        movea.l         buf1(PC),A0     ; Adressen der Buffer holen
        movea.l         buf2(PC),A1
        move.w          #255,D0         ; 256 Eintraege pro Buffer
        move.w          #3252,D1        ; Branch: Mittelwerte ausgeben
pon_1:  move.w          D1,(A0)+
        move.w          D1,(A1)+
        dbra            D0,pon_1

        bsr             sound_on

        movem.l         (SP)+,D1-D7/A1-A6 ; Stack->Registers

        lea             woistwas(PC),A0 ; Adressen zurueckgeben (Spielen)
        move.l          A0,D0
        rts

******************************************************************************
*
* C: play_off() Sound stoppen, Systemtimer wieder an, USERMODE
*
******************************************************************************

_play_off::
        movem.l         D1-D7/A1-A6,-(SP) ; Registers->Stack
        bsr             sound_off       ; Erstmal alles Abschalten
        movem.l         (SP)+,D1-D7/A1-A6 ; Stack->Registers
        rts

******************************************************************************
*
* C: init_sam(): zuerst 1 mal aufruf., im USER Mode (!!! OM.Basic !!!)
*    Schaltet Tastaturklick aus und setzt Volume auf 1024 (100%)
*
******************************************************************************

_init_sam::
        movem.l         D1-D7/A1-A6,-(SP) ; Registers->Stack

;       * TRAP #15 initialisieren:
        pea             initrap(PC)     ; Umstaendlicher
        move.w          #38,-(SP)       ; Aufruf im SUPERVISOR
        trap            #14             ; via XBIOS
        addq.l          #6,SP           ; (Aber nur einmal!)

;       * 256 fast gleiche Routinen (spart Platz) erzeugen...
        lea             out_1(PC),A1    ; Destin-Code
        move.w          #254,D1         ; 254 mal kopieren
ini_1:  lea             out_0(PC),A0    ; Source-Code
        move.w          #25,D0          ; 26 Bytes
ini_2:  move.b          (A0)+,(A1)+     ; 1 Byte kopieren
        dbra            D0,ini_2        ; das ganze 26 mal
        dbra            D1,ini_1        ; und das dann 255 mal

;       * ...einziger Unterschied: die Registerwerte (aus volt)
        lea             volt(PC),A0     ; Da sind die Daten...
        lea             out_0(PC),A1    ; Dort der Code
        move.w          #255,D0         ; 256 mal...
ini_3:  move.w          (A0)+,D1        ; D1: 00.R8 R9.RA

        move.w          D1,D2           ; D2 zum Arbeiten
        andi.w          #$0F00,D2       ; D2: R8.00 00.00
        move.w          D2,4(A1)        ; Register 8 eintragen

        move.w          D1,D2           ; D2 ...
        lsl.w           #4,D2
        andi.w          #$0F00,D2       ; D2: R9.00 00.00
        move.w          D2,4+8(A1)      ; Register 9

        move.w          D1,D2           ; D2 ...
        ror.w           #8,D2
        andi.w          #$0F00,D2       ; D2: RA.00 00.00
        move.w          D2,4+16(A1)     ; Register 10 eintragen

        lea             26(A1),A1       ; Auf naechsten Tabellenwert
        dbra            D0,ini_3        ; 256 mal...

;       * Einige Variablen muessen initialisiert werden...
        lea             bothbuf(PC),A0  ; Adresse des Buffers
        move.l          A0,D0           ; muss auf einer 512-Byte Grenze beg!
        ori.w           #511,D0
        addq.l          #1,D0           ; so!
        move.l          D0,buf1         ; Das ist dann Buffer 1
        add.l           #512+2,D0       ; 256 Words + fillbuf-Branch
        move.l          D0,buf2         ; dahinter liegt Buffer 2

        move.w          #1024,-(SP)     ; Volume 100%
        bsr             _volume         ; Tabelle setzen
        addq.w          #2,SP           ;

        bsr.s           mwini           ; MICROWIRE (STE) initialisieren

;       * Annahme: kein Sample geladen: Alle 31 Adressen auf Silentio
        lea             _psamples(PC),A0
        move.w          #31,D0
        lea             silentio(PC),A1
ini_6:  move.l          A1,(A0)+
        dbra            D0,ini_6

;       * Initialisierung der Schrittweiten
        lea             freq(PC),A0     ; Frequenzliste fuer 1 Oktave
        lea             steps(PC),A1    ; Dahin berechnen
        move.w          #4,D0

ini_4:  move.w          #11,D1          ; 12 Toene pro Oktave
        lea             (A0),A2
ini_5:  move.l          (A2)+,D2        ; Schrittweite aus freq
        lsl.l           #2,D2           ; erst mal mal 8
        lsr.l           D0,D2           ; pro Oktave 1 mal durch 2 teilen
        move.l          D2,(A1)+        ; Schrittweite abspeichern
        dbra            D1,ini_5        ; naechster Ton
        dbra            D0,ini_4        ; naechste Oktave

        movem.l         (SP)+,D1-D7/A1-A6 ; Stack->Registers
        rts

; Liste der Schrittweiten fuer eine Oktave
freq:DC.L 65536,69433,73562,77936,82570,87480,92682
    DC.L 98193,104032,110218,116772,123715

******************************************************************************
* mwini: Initialisiert MICROWIRE (Klangregler) Interface auf STE.
* Hat auf ST keine Wirkung, Bus-/Adress-Fehler werden abgefangen!
******************************************************************************

mwini:
        trap            #15             ; SUPERVISOR
        move            #$2700,SR       ; Voller Error
        move.l          #imret,$00000060.w ; Unechte Unterbrechung abfangen
        movem.l         D0-A7,steregs   ; Ohne Stack, aber Stack merken
        move            USP,A0          ; UStack auch...
        move.l          A0,steusp
        move.l          $00000008.w,obusf ; Alle Fehler abfangen
        move.l          $0000000C.w,oadrf ; BUS und Adresse
        lea             merr(PC),A0
        move.l          A0,$00000008.w  ; Bus- und Adress-fehler ?
        move.l          A0,$0000000C.w  ; Kein Problem!

        movea.l         #$FFFF8924,A0   ; A0: Mmask
        movea.l         #$FFFF8922,A1   ; A1: Mdata
        lea             mwdata(PC),A2   ; A2: *Daten
        move.l          #2047,(A0)
        bsr.s           w100
mnext:  move.w          (A2)+,D0
        beq.s           merr            ; 0: Fertig!
        move.w          D0,(A1)
        bsr.s           w100
        bra.s           mnext

merr:   move            #$2700,SR       ; Alles Stoppen
        move.l          obusf(PC),$00000008.w
        move.l          oadrf(PC),$0000000C.w
        movea.l         steusp(PC),A0
        move            A0,USP
        movem.l         steregs(PC),D0-A7
        move            #$0300,SR       ; USER Mode
        rts

w100:   move.w          #200,D0         ; MW muss Daten 'verdauen'
wx1:    dbra            D0,wx1
        rts

steregs:DS.L 16
steusp:DC.L -1
obusf:DC.L -1
oadrf:DC.L -1

;       * Diese Daten werden an das MICROWIRE gesendet:
;       * Hoehen: - 3 dB, sonst volle Pulle
mwdata:DC.W 1256,1363,1300,1164,1094,1025,0

******************************************************************************
*
* C: volume(int vol): Steuert die Lautstaerke (1024 = 100%)
*    Darf auch geaendert werden, solange Samples noch gespielt werden!
*
******************************************************************************

_volume::
        lea             (SP),A0
        movem.l         D1-D7/A1-A6,-(SP) ; Registers->Stack
        move.w          4(A0),D2        ; D2: Volume-Wert
        ext.l           D2
        lsl.l           #6,D2           ; D2: 00 01 00 00
        moveq           #0,D3           ; D3: Summation

;       * conv_tab enthaelt die Branches zu den einzelnen Volume-Werten
        lea             conv_tab_l(PC),A0 ; conv_tab_0 von DS.w 383,2 gef.!
        move.w          #255,D0         ; 256 Schleifen
vo_1:   swap            D3              ; Highword holen
        move.w          D3,D4
        swap            D3
        cmp.w           #255,D4
        ble.s           vo_2            ; Darf nur Leiser werden!
        move.w          #255,D4
vo_2:   mulu            #26,D4
        addq.w          #2,D4           ; Branch ist immer 2 Bytes weiter
        move.w          D4,(A0)+        ; Offset als Index eintragen...
        add.l           D2,D3           ; Naechster Schritt
        dbra            D0,vo_1         ; That's it!

        move.w          #384,D0         ; conv_tab_mx mit MAXIMUM fuellen.
vo_3:   move.w          D4,(A0)+        ; A0 stimmt noch von oben
        dbra            D0,vo_3         ; 385 mal...

        movem.l         (SP)+,D1-D7/A1-A6 ; Stack->Registers
        rts

* initrap: installiert den TRAP #15 um schneller in den SUPERVISOR zu gelangen
*          und schaltet Tastenklick aus
initrap:                                ; Aufruf im SUPERVISOR
        lea             trap15(PC),A0
        move.l          A0,$000000BC.w

        bclr            #0,$00000484.w  ; Und Tastenklick OFF

        rts

trap15: ori.w           #$2000,(SP)     ; USER->SUPERVISOR
        rte

******************************************************************************
* sound_on: Routine gibt den Sound aus, dazu muss er aber vorher abgesch.
*        worden sein (s_off)! Aufruf im USER Mode
******************************************************************************

sound_on:
        trap            #15
        move            #$2700,SR       ; Alles Aus!

        move.b          #64,$FFFFFA17.w ; AEOI
        move.l          #$07007F00,$FFFF8800.w ;

        lea             entry(PC),A0    ; Timer A Vektor
        move.l          A0,$00000134.w  ; eintragen
        move.b          tdata+1(PC),$FFFFFA1F.w ; Timer A Data
        move.b          #1,$FFFFFA19.w  ; Timer A Control

        bset            #5,$FFFFFA07.w  ; Timer A Int. enable
        bset            #5,$FFFFFA13.w  ; Timer A Int. mask

        bclr            #5,$FFFFFA09.w  ; Timer C Int. disablen

        move            #$0300,SR       ; Interrupts AN->SOUND
        rts

******************************************************************************
* sound_off: 4-Kanal-Sound abschalten, Aufruf im USER Mode
******************************************************************************

sound_off:
        trap            #15             ; SUPERVISOR
        bsr.s           s_off

        movem.l         buf1(PC),A0-A1  ; Bufferadressen holen
        move.w          #BR_FILL,512(A0) ; bra fill_buffer an's Ende
        move.w          #BR_FILL,512(A1) ; dto.

        move            #$0300,SR       ; USER,  IPL-Status 3
        rts

* s_off: Unabhaengige Subroutine, SUPERVISOR
s_off:
        move            #$2700,SR       ; Alles sperren
        move.l          #imret,$00000134.w
        clr.b           $FFFFFA19.w     ; Timer A Stop

        bset            #5,$FFFFFA09.w  ; Timer C Int. enable
        rts

imret:  rte                             ; evtl. kommt noch ein Interr.!

******************************************************************************
* treat: Berechnung der Frequenzvariationen Vibrato, Pitch-Bender und
*        Arpeggio!
******************************************************************************

    BASE A5,adr0                        ; Adressen vereinfachen
treat:
        moveq           #0,D4           ; D4: Soll-Frequenz
        movea.l         (A5),A6         ; Sampleadresse holen
        cmpa.l          #zerosam,A6     ; Ausgeschaltet?
        beq.s           tr_off          ; JA: Nichts machen
        move.l          step0(A5),D4    ; Step 0 holen
        move.w          pind0(A5),D5    ; Index in 2-er Schritten
        add.l           pitch0(A5,D5.w),D4 ; Zu Step den aktuellen Pitch add.
        subq.w          #4,D5           ; Index verkleinern
        bge.s           tr_iok
        move.w          maxpind0(A5),D5 ; Liste wieder von vorne!
tr_iok:
        move.w          D5,pind0(A5)    ; Und den Index merken
        andi.l          #$0007FFFF,D5   ; Schrittweite < 8
tr_off:
        rts
    BASE A5,OFF

******************************************************************************
* fill_buf: Diese Routine schreibt 256 Words in den Ausgabepuffer
*           Aufruf aus INTERRUPT (Rte)!
******************************************************************************

fill_buf:
        move.l          buf1(PC),e_sm2+2 ; Den Buffer wechseln!

;       * Timing halten: Interrupt emulieren (Trick 17)
        pea             fi_1(PC)        ; Pseudo Rcksprungadresse
        move.w          #$2500,-(SP)    ; Pseudo SR Register: Sub-Interrupt
        bra             entry
fi_1:
        tas.b           iserve          ; Overrun verhindern!
        bmi             fi_2            ; !!! Overrun !!!

        movem.l         D0-A6,-(SP)     ; Alle Register sichern

;       * Initialisieren der Register
        movem.l         buf1(PC),A5-A6  ; A5/A6: BUF1/2
        exg             A5,A6           ; Buffer tauschen
        movem.l         A5-A6,buf1

;       * Pro Sample werden 3 Variablen verwendet...
;       * Berechnung von Arpeggio, Vibrato und Pitch-Bender:

        lea             adr0(PC),A5     ; Pitch-Spielereien
        bsr.s           treat
        lea             (A6),A0         ; A0 : Adresse Sample 0
        move.l          indx0(PC),D0    ; D0 : Index Sample 0
        move.l          D4,D6           ; D6 : Schrittweite Sample 0

        lea             adr1(PC),A5
        bsr.s           treat
        lea             (A6),A1         ; A1 : Adresse Sample 1
        move.l          indx1(PC),D1    ; D1 : Index Sample 1
        move.l          D4,D7           ; D7 : Schrittweite Sample 1

        lea             adr2(PC),A5
        bsr.s           treat
        lea             (A6),A2         ; A2 : Adresse Sample 2
        move.l          indx2(PC),D2    ; D2 : Index Sample 2
        movea.l         D4,A4           ; A4 : Schrittweite Sample 2

        lea             adr3(PC),A5
        bsr             treat
        lea             (A6),A3         ; A3 : Adresse Sample 3
        move.l          indx3(PC),D3    ; D3 : Index Sample 3
        movea.l         D4,A6           ; A6 : Schrittweite Sample 3

        movea.l         buf1(PC),A5     ; A5 : Frisch!

;       * REPT 8: 8 mal bsr.s a 32 Bytes: 256 Bytes auf einen Schlag
    REPT 8
        bsr.s           fill_b2         ; 32 Bytes nach buf2++
    ENDR

        lea             adr0(PC),A5     ; A5 : Basisregister

;       * Der BASE - Befehl bestimmt A5 als Variablenbasis
;       * (ersetzt ....(A5) durch   .....-adr0(A5))

    BASE A5,adr0

        move.l          A0,adr0(A5)     ; A0 : Adresse Sample 0
        move.l          D0,indx0(A5)    ; D0 : Index Sample 0

        move.l          A1,adr1(A5)     ; A1 : Adresse Sample 1
        move.l          D1,indx1(A5)    ; D1 : Index Sample 1

        move.l          A2,adr2(A5)     ; A2 : Adresse Sample 2
        move.l          D2,indx2(A5)    ; D2 : Index Sample 2

        move.l          A3,adr3(A5)     ; A3 : Adresse Sample 3
        move.l          D3,indx3(A5)    ; D3 : Index Sample 3

        addq.w          #1,_clock(A5)   ; Clock erhoehen

    BASE A5,OFF

        movem.l         (SP)+,D0-A6     ; Register wieder holen
        sf              iserve          ; iserve nun frei

fi_2:
        rte                             ; Sub-Interrupt fertig!

; Den Bereich buf2 fuellen waehrend buf1 (evtl.) gespielt wird
; Alle Register werden verwendet!

;       * A0/D0: Sample 0 / Index 0
;       * A1/D1: Sample 1 / Index 1
;       * A2/D2: Sample 2 / Index 2
;       * A3/D3: Sample 3 / Index 3

;       * A5: Buffer

;       * D4: Work A
;       * D5: Zahler / Work B

;       * D6: Step 0
;       * D7: Step 1
;       * A4: Step 2
;       * A6: Step 3

fill_b2:
;       * Fuellschleife: Rechnet Daten in Code (Branches um)
;       * etwa 168 Zyklen pro Byte + Overhead

        move.l          #15,D5          ; D5: Zaehler und Work

;       * Diese Schleife errechnet sich 32 Samplebytes
fi_3:   swap            D5              ; D5: Doppelt verwendet!

;       * swap und dbf kosten Zeit, daher nur alle 2 Aufrufe testen
;       * REPT n: n-Mal den Code der R-Schleife wiederholen
;       * Die Berechnung eines Bytes kostet etwa 168 Zyklen (ohne
;       * Initialisierungen etc. Da auf ATARI STE die Ausgabe von
;       * Samples via DMA erfolgen kann, wuerde der Player (mit einigen
;       * kleineren Aenderungen) dort nur 22% Rechenzeit ( STE mit 8Mhz
;       * bei 12.538 kHz Ausgabefrequenz) verbrauchen!!!
;       * Auf normalen STs verbraucht der Player etwa 62% Rechenzeit (12.5 kHz)

    REPT 2
        clr.w           D4              ; [4]  A = 0
        move.b          0(A0,D0.w),D4   ; [16] A Holen: Samplebyte 0
        move.b          0(A1,D1.w),D5   ; [16] B Holen: Samplebyte 1
        add.w           D5,D4           ; [4]  B zu A addieren
        move.b          0(A2,D2.w),D5   ; [16] B Holen: Samplebyte 2
        add.w           D5,D4           ; [4]  B zu A addieren
        move.b          0(A3,D3.w),D5   ; [16] B Holen: Samplebyte 3
        add.w           D5,D4           ; [4]  B zu A addieren
        add.w           D4,D4           ; [4]  A = 2 * A
        move.w          conv_tab_0(PC,D4.w),(A5)+ ; [20] Branch holen und eintragen...

;       * Jeden Sample ein Schritt(chen) weiter...
        swap            D0              ; [4]
        swap            D1              ; [4]
        swap            D2              ; [4]
        swap            D3              ; [4]

        add.l           D6,D0           ; [8]
        add.l           D7,D1           ; [8]
        add.l           A4,D2           ; [8]
        add.l           A6,D3           ; [8]

        swap            D0              ; [4]
        swap            D1              ; [4]
        swap            D2              ; [4]
        swap            D3              ; [4]
    ENDR

        swap            D5              ; Zaehlervariable
        dbra            D5,fi_3
        bra             loopen          ; Loops testen

;       * conv_tab muss in der Naehe von fi_3 liegen, wegen d(PC) Adress.
conv_tab_0:
;   Anhand dieser Liste werden die Codeadressen der 256 Routinen berechnet
;       * Untersteuerter Bereich (DA-Ausgabe 0: Sprung zu out_0)
    DS.W 383,2

;       * Linearer Bereich (DA-Ausgabe prop. zum Wert)
conv_tab_l:
    DS.W 256

;       * Uebersteuerter Bereich (DA-Ausgbabe MAX: Sprung abh. von volume)
conv_tab_mx:
    DS.W 385

loopen:
;       * Jetzt noch testen, ob ein Sample geloopt werden muss...
;       * Sample 0
        cmp.w           -6(A0),D0       ; Loopmarke erreicht?
        blt.s           fnol1           ; Nein: Weiter ->
        tst.w           -2(A0)          ; Geloopter Sample (Hold?)
        beq.s           fonce0          ; Ja: ->
        sub.w           -2(A0),D0       ; Loop vom Index abziehen!
        bra.s           fnol1           ; Weiter->
fonce0: lea             zerosam(PC),A0  ; 0-Adresse setzen
        moveq           #0,D0           ; Index auf 0
        moveq           #0,D6           ; Kein Step
fnol1:
;       * Sample 1
        cmp.w           -6(A1),D1       ; Loopmarke erreicht?
        blt.s           fnol2           ; Nein: Weiter ->
        tst.w           -2(A1)          ; Geloopter Sample (Hold?)
        beq.s           fonce1          ; Ja: ->
        sub.w           -2(A1),D1       ; Loop vom Index abziehen!
        bra.s           fnol2           ; Weiter->
fonce1: lea             zerosam(PC),A1  ; 0-Adresse setzen
        moveq           #0,D1           ; Index auf 0
        moveq           #0,D7           ; Kein Step
fnol2:
;       * Sample 2
        cmp.w           -6(A2),D2       ; Loopmarke erreicht?
        blt.s           fnol3           ; Nein: Weiter ->
        tst.w           -2(A2)          ; Geloopter Sample (Hold?)
        beq.s           fonce2          ; Ja: ->
        sub.w           -2(A2),D2       ; Loop vom Index abziehen!
        bra.s           fnol3           ; Weiter->
fonce2: lea             zerosam(PC),A2  ; 0-Adresse setzen
        moveq           #0,D2           ; Index auf 0
        lea             0.w,A4          ; Kein Step (A4 eigtl. Zahl!)
fnol3:
;       * Sample 3
        cmp.w           -6(A3),D3       ; Loopmarke erreicht?
        blt.s           fnol4           ; Nein: Weiter ->
        tst.w           -2(A3)          ; Geloopter Sample (Hold?)
        beq.s           fonce3          ; Ja: ->
        sub.w           -2(A3),D3       ; Loop vom Index abziehen!
        bra.s           fnol4           ; Weiter->
fonce3: lea             zerosam(PC),A3  ; 0-Adresse setzen
        moveq           #0,D3           ; Index auf 0
        lea             0.w,A6          ; Kein Step (A6 eigtl. Zahl!)
fnol4:

        rts                             ; OK!

******************************************************************************
* entry: wird vom Timer-A Interrupt aufgerufen. ACHTUNG: Selbstmodifizierender
*        Code! Der branch muss immer WORD sein!
*        Die Codeteile ab out_0 werden nur durch RAM-MODIFIKATION erreicht
*        und bewirken die Ausgabe eines einzelnen D-A-Wertes:
*        Ausgabe eines Wertes kostet ca. 188 Zyklen (ohne Berechnung)
******************************************************************************

entry:
e_sm2:  move.w          $FFFFFFFF,e_sm1+2 ; [28] Branch holen und patchen
        addq.w          #2,e_sm2+4      ; [12] Bytes weiter im Speicher!
e_sm1:  bra             *+1234          ; [12] Normalerweise: Buffer fuellen

out_0:
        move.l          #$08000000,$FFFF8800.w ; [24] Sound-Register 1
        move.l          #$09000000,$FFFF8800.w ; [24] Sound-Register 2
        move.l          #$0A000000,$FFFF8800.w ; [24] Sound-Register 3
        rte                             ; [64] Erledigt!

* Ab out_1: Uninitialisierte Daten

out_1:
;   hier wird der Code out0-1 noch 255 mal wiederholt (von initialisieren)
    DS.B 255*26
out_256:

bothbuf:
;   Die Ausgabe-Buffer koennten sich ueberlappen (Word-Grenze! -> 3 aus 2)
    DS.W 256*3+4                        ; Bufferbereiche

steps:
;   Die 60 Schrittweiten im Format W.W
    DS.L 60

BR_FILL EQU fill_buf-2-e_sm1            ; Branch um Buffer zu fuellen

ende:                                   ; * Got it! *
    END
