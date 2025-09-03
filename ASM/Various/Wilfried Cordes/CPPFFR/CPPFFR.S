;-------------------------------------------------------------
;Wilfried Cordes, Kennedystra·e 20, 2900 Oldenburg
;Druckerpuffer (XBRA CPPF)
;Erstellt mit TurboASS 1.36 (Shareware-Assembler)
;LÑuft erst ab TOS 1.02 (1.2), da BIOS-Vektoren benutzt werden
;-------------------------------------------------------------
                OUTPUT 'CPPFFR.PRG'
                OPT F+   ;Fastload-Bit

KapazitÑt       EQU 32

gemdos          EQU 1
Cconin          EQU 1
cconws          EQU 9
ptermres        EQU 49

xbios           EQU 14
supexec         EQU 38

BusyVektor      EQU $0100

;Systemvariable----------------------------------
_hz_200         EQU $04BA
_sysbase        EQU $04F2
prt_vec         EQU $050A
xbconstat_prn   EQU $051E
xbconin_prn     EQU $053E
xbcostat_prn    EQU $055E
xbconout_prn    EQU $057E

;MFP - General Purpose Input/Output Port
MFP_GPIP        EQU $FFFFFA01
;Data Direction Register
MFP_DDR         EQU $FFFFFA05
;Active Edge Register
MFP_AER         EQU $FFFFFA03
;Interrupt Enable Register - Register B
MFP_IERB        EQU $FFFFFA09
;Interrupt in Service Register - Register B
MFP_ISRB        EQU $FFFFFA11
;Interrupt Mask Register - Register B
MFP_IMRB        EQU $FFFFFA15

;Programmable Sound Generator(PSG) - Register
GISELECT        EQU $FFFF8800
GIREAD          EQU $FFFF8800
GIWRITE         EQU $FFFF8802

                TEXT
Start:
                bra      Init
;Hardcopyausgabe---------------------------------
                DC.B "XBRACPPF"
rette_prt_vec:  DC.L -1
neuer_prt_vec:  move.b   5(SP),D2
                bra.s    TusRein

;Eingabe von paralleler Schnittstelle------------
                DC.B "XBRACPPF"
rette_xbconin:  DC.L -1
neuer_xbconin:  moveq    #-1,D0             ;EOF->Dateiende
                rts

;Test auf Eingabe von paralleler Schnittstelle---
                DC.B "XBRACPPF"
rette_xbconstat:DC.L -1
neuer_xbconstat:moveq    #0,D0              ;Kein Zeichen
                rts

;Test auf Ausgabemîglichkeit in Puffer-----------
                DC.B "XBRACPPF"
rette_xbcostat: DC.L -1
neuer_xbcostat: cmpi.w   #KapazitÑt,Pufferinhalt
                bge.s    Voll
                moveq    #-1,D0             ;Ausgabe ist
                rts                         ;mîglich
Voll:           moveq    #0,D0              ;Puffer ist
                rts                         ;voll

;Puffersystemvariablen---------------------------
TimeOfLastOutput:DC.L 0  ;[Systemticks]
Lesevektor:     DC.W 0   ;Druckzeichen
Schreibvektor:  DC.W 0   ;Freier Platz
Pufferinhalt:   DC.W 0   ;[Bytes]

;Druckausgabe in Puffer--------------------------
                DC.B "XBRACPPF"
rette_xbconout: DC.L -1
neuer_xbconout: move.b   7(SP),D2

TusRein:        move.l   TimeOfLastOutput(PC),D0
                addi.l   #2000,D0

Drucker:        cmpi.w   #KapazitÑt,Pufferinhalt
                blt.s    Ausgabe

                cmp.l    _hz_200.w,D0
                bge.s    Drucker
Fehler:         moveq    #0,D0
                rts

Ausgabe:        move.w   Schreibvektor(PC),D0
                lea      Pufferadresse(PC),A0
                move.b   D2,0(A0,D0.w)

                addi.w   #1,Pufferinhalt

                addq.w   #1,D0
                cmpi.w   #KapazitÑt,D0
                blt.s    OKAY
                moveq    #0,D0
OKAY:           move.w   D0,Schreibvektor
                move.l   _hz_200.w,TimeOfLastOutput
Erfolg:         moveq    #-1,D0

                move     SR,-(SP)
                bsr.s    SchreibeZeichen
                move     (SP)+,SR
                rts

;Neue Busy-Interruptroutine----------------------
                DC.B "XBRACPPF"
RetteBusyInterrupt:DC.L -1
NeuerBusyInterrupt:bsr.s SchreibeZeichen
                move.b   #%11111110,MFP_ISRB.w
                rte

;Ausgabe auf parallele Schnittstelle-------------
SchreibeZeichen:move     #$2700,SR
                btst     #0,MFP_GPIP.w
                bne.s    GEHT_NICHT         ;Ja

                movem.l  D0-D1/A0,-(SP)
                tst.w    Pufferinhalt
                beq.s    Puffer_LEER

                move.w   Lesevektor(PC),D1
                lea      Pufferadresse(PC),A0

;Zeichen in Ausgaberegister schreiben
                move.b   #15,GISELECT.w     ;Port B
                move.b   0(A0,D1.w),GIWRITE.w

;Drucker Ausgabe anzeigen
                move.b   #14,GISELECT.w     ;Port A
                move.b   GIREAD.w,D0
                bclr     #5,D0              ;Strobe->low
                move.b   D0,GIWRITE.w

                subi.w   #1,Pufferinhalt
                nop
                nop
                bset     #5,D0              ;Strobe->high
                move.b   D0,GIWRITE

                addq.w   #1,D1
                cmpi.w   #KapazitÑt,D1      ;KapazitÑt <-> Lesevektor
                blt.s    OKAY1

                moveq    #0,D1
OKAY1:          move.w   D1,Lesevektor

Puffer_LEER:    movem.l  (SP)+,D0-D1/A0
GEHT_NICHT:     rts

Pufferadresse:  DC.W 0

Init:
;TOS-Version ÅberprÅfen--------------------------
                pea      TesteTOSVersion(PC)
                move.w   #supexec,-(SP)
                trap     #xbios
                addq.l   #6,SP

                tst.w    D0
                beq.s    FalscheTOSVersion

;Busyvektor ÅberprÅfen---------------------------
                pea      TesteBusyVektor(PC)
                move.w   #supexec,-(SP)
                trap     #xbios
                addq.l   #6,SP

                cmpi.w   #1,D0
                beq.s    KeinXBRA
                blt.s    Einklinken

;Puffer bereits vorhanden------------------------
                lea      SCHON_DA(PC),A6
                bra.s    Schluss            ;Abschied

;Busyvektor bereits verbogen---------------------
KeinXBRA:       lea      BELEGT(PC),A6
                bra.s    Schluss

FalscheTOSVersion:lea    TOS10(PC),A6
                bra.s    Schluss

;XPFFR braucht TOS 1.2 oder neuere Version-------
TesteTOSVersion:lea      _sysbase.w,A0
                movea.l  (A0),A0
                cmpi.l   #$0102,2(A0)
                blt.s    FalschesTOS
                moveq    #1,D0
                rts
FalschesTOS:    moveq    #0,D0
                rts

;Stringausgabe-----------------------------------
Melde:          move.l   A6,-(SP)
                move.w   #cconws,-(SP)
                trap     #gemdos
                addq.l   #6,SP
                rts

;Schluû nach Fehlern-----------------------------
Schluss:        bsr.s    Melde

                move.w   #Cconin,-(SP)
                trap     #gemdos
                addq.l   #2,SP

                clr.w    -(SP)
                trap     #gemdos

;Testen, ob Busyvektor bereits belegt------------
TesteBusyVektor:btst     #0,MFP_IERB.w
                bne.s    SucheXBRA
                moveq    #0,D0
                rts

;Vektor ist belegt
SucheXBRA:      movea.l  BusyVektor.w,A0
                cmpi.l   #"XBRA",-12(A0)
                bne.s    GibEinsZurÅck
                cmpi.l   #"CPPF",-8(A0)
                beq.s    CPPFGefunden
GibEinsZurÅck:  moveq    #1,D0
                rts
CPPFGefunden:   moveq    #2,D0
                rts

;Neue EinsprÅnge einklinken----------------------
Einklinken:     clr.w    Schreibvektor
                clr.w    Lesevektor
                clr.w    Pufferinhalt

;Vektoren verbiegen
                pea      Eintragen(PC)
                move.w   #supexec,-(SP)
                trap     #xbios
                addq.l   #6,SP

;Arbeitsantritt melden
                lea      MELDUNG(PC),A6
                bsr.s    Melde


;Programm beenden, aber im Speicher belassen
                move.l   #Init-Start+256,D7
                addi.l   #KapazitÑt,D7

                clr.w    -(SP)
                move.l   D7,-(SP)
                move.w   #ptermres,-(SP)
                trap     #gemdos

;Neue Druckervektoren eintragen------------------
Eintragen:      lea      xbconstat_prn.w,A0
                move.l   (A0),rette_xbconstat
                move.l   #neuer_xbconstat,(A0)

                lea      xbconin_prn.w,A0
                move.l   (A0),rette_xbconin
                move.l   #neuer_xbconin,(A0)

                lea      xbcostat_prn.w,A0
                move.l   (A0),rette_xbcostat
                move.l   #neuer_xbcostat,(A0)

                lea      xbconout_prn.w,A0
                move.l   (A0),rette_xbconout
                move.l   #neuer_xbconout,(A0)

                lea      prt_vec.w,A0
                move.l   (A0),rette_prt_vec
                move.l   #neuer_prt_vec,(A0)

;Neuen Busyvektor eintragen
                lea      BusyVektor.w,A0
                move.l   (A0),RetteBusyInterrupt
                move.l   #NeuerBusyInterrupt,(A0)

;Ports auf Eingang schalten
                bclr     #0,MFP_DDR.w
                bclr     #0,MFP_AER.w

;Busyinterrupt ermîglichen
                bset     #0,MFP_IMRB.w
                bset     #0,MFP_IERB.w

;PSG-Register A und B auf Ausgang schalten
                move.b   #7,GISELECT.w
                move.b   GIREAD.w,D0
                or.b     #%11000000,D0
                move.b   D0,GIWRITE.w
                rts

;Initialisierte Daten (Meldungen etc.)-----------
                DATA
MELDUNG:        DC.B 13,10,"*                       *"
                DC.B 13,10,"* CPPFFR eingeschaltet! *"
                DC.B 13,10,"*   Ω Wilfried Cordes   *"
                DC.B 13,10,"*                       *",13,10,0
BELEGT:         DC.B 13,10,"Busyvektor bereits verbogen.",0
TOS10:          DC.B 13,10,"Falsche TOS-Version.",13,10,0
SCHON_DA:       DC.B 13,10,"CPPFFR schon installiert!",13,10,0
                END
