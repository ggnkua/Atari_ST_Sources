*
*         >>  WPROTECT.S <<                  V0.97/f     09.11.1991
*         Ω by
*         Christoph Conrad
*         Adalbertsteinweg 113
*         5100 Aachen
*
*         MAUSnet: Christoph Conrad @ AC3
*
* Liebe Leute, diese Source entstand vor grauer Vorzeit. Also verzeiht mir
* die nicht ganz so Åbersichtliche Programmierung.
*
* History:
* 0.97/f: - Sicherungslaufwerk aus _bootdev ($446)
*         - _drvbits / ProtDrive / ProtDouble wird jetzt als 32 Bit behandelt
*         - Im Accessory werden jetzt bei jeder Aktivierung die aktuellen
*           Schutzwerte aus dem CurrentVec uebernommen (sonst wuerde eine
*           zwischenzeitliche Aenderung ueber einen Programmaufruf ignoriert)
*         + Nachfrage bei Sichern auf X:\AUTO\WPROTECT.PRG (X == Bootlaufwerk),
*           falls Bootlaufwerk als geschÅtzt gilt.
*         + Accessory erkennt nachtrÑglich installierten Schutz.
*         + UnterstÅtzung des VA-Protokolls (VA_START)
*
* Future Releases: (kann aber nochwas dauern)
* 1.00:   + GEM-Dialogbox
* mfg chris.
*
WRITE_PROTECT   EQU     -13         ; Bios-Fehlermeldung
_bootdev        EQU     $446
hdv_rw          EQU     $476        ; Harddisk Schreiben-Lesen
_drvbits        EQU     $4C2

           .TEXT
Anfang:     bra     Install

*---------------------------
*---------------------------
* Neuer hdv_rw-Vektor

* Bitstring zu schÅtzender Laufwerke Bit 0 == A:, Bit 1 == B: etc.
ProtDrive:  DC.L    0           ; Position: -16(NewHdvRW)

ProtDriveOffs EQU    -16

*
* XBRA-Struktur
*
XBRA:       DC.B    "XBRA"      ; Position: -12(NewHdvRW)
Ident:      DC.B    "WPRO"      ; Position: -8(NewHdvRW)
; alter hdv_rw-Vektor
OldHdvRW:   DC.L    0           ; Position: -4(NewHdvRW)

NewHdvRW:   btst.b  #0,5(sp)    ; Read-Write-Flag
            beq.s   gotoOld     ; es wird nur gelesen

            move.w  14(sp),d3   ; Laufwerk 0=A:, 1=B: etc.
            move.l  _drvbits,d4
            btst.l  d3,d4       ; gibt's das Laufwerk Åberhaupt ?
            beq.s   gotoOld     ; nein
            move.l  ProtDrive(pc),d4
            btst.l  d3,d4       ; soll Laufwerk geschÅtzt werden ?
            beq.s   gotoOld     ; nein
    .loop:  moveq   #WRITE_PROTECT,d0
            bsr.s   CallCritErr ; critical-error-handler aufrufen
            cmp.l   #$10000,d0  ; Retry ?
            beq.s   .loop
            moveq   #WRITE_PROTECT,d0
            rts
gotoOld:    move.l  OldHdvRW(pc),-(sp)
            rts

CallCritErr:movem.l a0-a2/d1-d2,RegSave
            move.w  d3,-(sp)    ; Laufwerk
            move.w  d0,-(sp)    ; Fehlercode
            moveq   #-1,d0      ; KompatibilitÑt zum Bios
            move.l  $404,a0     ; etv_critic
            jsr     (a0)
            addq.l  #4,sp
            movem.l RegSave(pc),a0-a2/d1-d2
            rts

RegSave:   .DCB.L   5,0 ; A0-A2/D1-D2

AutoResident    EQU     *
*----------------------------
*----------------------------

AESPB:      DC.L    control, global, intin, intout, addrin, addrout

AlertNotInstalled:
            DC.B    "[1][WProtect 0.97/f: |Bitte installieren!][Ok]",0
            .even

Alert0:     DC.B    "[2][ Christoph Conrad ",189," 0.97/f| | Laufwerk "
Laufwerk0:  DC.B    0,": "
SchutzStatus:DC.B   0
            DC.B    "][   ",4,"   |   ",3,"   | Weiter ]",0
            .even

Alert1:     DC.B    "[2][ Christoph Conrad ",189," 0.97/f| | Laufwerk "
Laufwerk1:  DC.B    0,":  | Sichern = | Ende-Button+ShiftLinks+Alt]["
Schutz:     DC.B    0,"Schutz |"
Normal:     DC.B    0,"Normal |  Ende  ]",0
            .even

Alert2:     DC.B    "[2][ Christoph Conrad ",189," 0.97/f| | Laufwerk "
Laufwerk2:  DC.B    0," ist geschÅtzt.| Trotzdem sichern?]"
            DC.B    "[Ok|Abbruch]",0
            .even

Menu_entry: DC.B    "  ",3," WProtect 0.97/f  ",0
            .even

FileError:  DC.B    "[1][ Dateifehler beim Speichern | auf "
FileErrDrv: DC.B    "X:\\AUTO\\WPROTECT.PRG !][ Ok ]",0
            .even

NotInstalled:DC.B    "[1][ Nicht installiert ! ][ Ok ]",0
            .even

FName:      DC.B    "X:\\AUTO\\WPROTECT.PRG",0   ; 1. Byte == Laufwerk
            .even

* Worte fÅr's control-Feld
* contrl[0..4] = opcode / #intin / #intout / #addrin / #addrout
ApplicationInit:
            DC.W    10,0,1,0,0
ApplExit:   DC.W    19,0,1,0,0
EvntMesag:  DC.W    23,0,1,1,0
MenuRegister:DC.W  35,1,1,1,0
FormAlert:  DC.W    52,1,1,1,0

           .BSS
control:    DS.W    12
global:     DS.W    15
intin:      DS.W    128
intout:     DS.W    128
addrin:     DS.W    128
addrout:    DS.W    128

CurrentVec: DS.L    1   ; NewHdvRW-Vektor
ap_id:      DS.W    1   ; application-id
Installed:  DS.B    1   ; 0 : Installiert !
Accessory:  DS.B    1   ; Falls 0 -> Accessory
* beim Abspeichern von ProtDrive darf das Laufwerk, auf dem
* gespeichert wird, nicht geschÅtzt sein. ProtDouble dient als
* Buffer, wÑhrend in ProtDrive das entsprechende Bit gelîscht wird
ProtDouble: DS.L    1
BootDrv:    DS.W    1
ActDrive:   DS.B    1   ; Aktuell zu bearbeitendes Laufwerk
DrvBits:    DS.L    1   ; Kopie von _drvbits ($4C2)
SysBase:    DS.L    1
Keep:       DS.L    1

MsgBuf:     DS.B    16  ; Nachrichtenbuffer AES

            DS.B    $190    ; 400 Byte Stack reichen dicke
Stack       EQU     *


           .TEXT
*-------------------------
AlertEins:  lea     GetDrvBits(pc),a0
            bsr     SupExec

* Hinter die Laufwerkskennzeichnung in der Alertbox wird der
* Schutzstatus eingefÅgt
* S: Schutz ein
* N: Normal
            lea     SchutzStatus(pc),a0
            move.b  #'N',(a0)       ; Annahme 'nicht geschÅtzt'
            move.b  ActDrive,d0
            move.l  ProtDrive(pc),d1
            btst.l  d0,d1
            beq.s   .NotProt
            move.b  #'S',(a0)       ; Annahme war falsch

* Alertbox darstellen
  .NotProt: lea     Laufwerk0(pc),a0
            bsr     ActDriveInString
            move.w  #2,intin
            lea     Alert0(pc),a0
            bsr     ZeigeAlert

            cmp.w   #3,intout
            beq.s   AlertZwei       ; 'Weiter'-Button angewÑhlt

            bsr     GetNextValidDrive
            bra     AlertEins


*---------------------
AlertZwei:
* Vor den Auswahlbutton (SchÅtzen/Normal), der dem aktuell
* geltenden Status entspricht, wird ein Checkmark (ASCII 8) gesetzt
* Der nicht geltende Statusbutton wird Defaultbutton
            lea     Schutz(pc),a0   ; Annahme 'Normal'
            lea     Normal(pc),a1
            move.w  #1,intin
            move.b  ActDrive,d0
            move.l  ProtDrive(pc),d1
            btst.l  d0,d1
            beq.s   .NotProt
            exg     a0,a1           ; Annahme falsch
            move.w  #2,intin
  .NotProt: move.b  #' ',(a0)
            move.b  #8,(a1)

* Alertbox darstellen
            lea     Laufwerk1(pc),a0
            bsr     ActDriveInString
            lea     Alert1(pc),a0
            bsr     ZeigeAlert
            cmp.w   #3,intout
            beq.s   ShiftAlt?   ; 'Ende'-Button angewÑhlt

* es wurde entweder der 'SchÅtzen'- oder der
* 'Lîschen'-Button angewÑhlt
            move.b  ActDrive,d0
            move.l  ProtDrive(pc),d1
            bclr.l  d0,d1       ; Annahme 'Lîschen'-Button
            cmp.w   #2,intout
            beq.s   .ok
            bset.l  d0,d1       ; Annahme war falsch
       .ok: move.l  d1,ProtDrive

            bra     AlertEins
*------------------------

GetKbShift: move.w  #-1,-(sp)
            move.w  #11,-(sp)
            trap    #13         ; KbShift
            addq.l  #4,sp
            rts

ShiftAlt?:  move.l  CurrentVec,a0    ; die neuen Schutzwerte Åbernehmen
            move.l  ProtDrive(pc),ProtDriveOffs(a0)

            bsr     GetKbShift

* Wird Shift-Alt gedrÅckt (Sichern der Konfiguration)
            cmpi.b  #%1010,d0   ; Sichern (Shift-Alt(links))
            bne.s   IsAcc?

            bsr     SaveConfig

    IsAcc?: tst.b   Accessory
            beq.s   WaitForAC_OPEN

* Wir sind ein Programm!
            tst.b   Installed
            bne.s   .Protected?     ; brancht falls NICHT installiert
            bra.s   .terminate

* Sind Åberhaupt irgendwelche Laufwerke zum SchÅtzen gekennzeichnet worden ?
* Falls nicht, brauchen wir nicht resident zu verbleiben
.Protected?:tst.l   ProtDrive
            bne.s   .install

            lea     NotInstalled(pc),a0
            bsr     ZeigeAlert

        ; ApplExit - Vom AES abmelden
.terminate: lea     ApplExit(pc),a0
            bsr     CallAES

            clr.w   -(sp)
            trap    #1              ; PTerm0

  .install: lea     InstallVecs(pc),a0
            bsr     SupExec
        ; ApplExit - Vom AES abmelden
            lea     ApplExit(pc),a0
            bsr     CallAES
            clr.w   -(sp)
            move.l  Keep,-(sp)
            move.w  #49,-(sp)       ; PTermRes
            trap    #1


WaitForAC_OPEN:
        ; EvntMesag - auf Mitteilung warten
            move.l  #MsgBuf,addrin
            lea     EvntMesag(pc),a0
            bsr     CallAES

            cmp.w   #40,MsgBuf            ; AC_OPEN
            beq.s   .test
            cmp.w   #$4711,MsgBuf			; VA_START (Gemini) 
            bne.s   WaitForAC_OPEN

* Falls Accessory ohne installiertes Autoordnerprogramm gestartet
* immer mal wieder nachschauen ob nicht inzwischen Åber WPROTECT.PRG
* (nachtrÑglich gestartet) ein residentes WProtect drin ist.
     .test: lea     XbraTest(pc),a0
            bsr     SupExec

            tst.b   Installed
            bne     AccNotInstEntry   ; Nicht installiert

            move.l  CurrentVec,a0
            move.l  ProtDriveOffs(a0),ProtDrive

            bra     AlertEins

AccNotInstEntry:
          ; Nicht installiert
            move.w  #1,intin
            lea     AlertNotInstalled(pc),a0
            bsr     ZeigeAlert

            bra     WaitForAC_OPEN

* Aktuelles Laufwerk als Buchstabe einfÅgen
ActDriveInString:
            move.b  ActDrive,(a0)
            addi.b  #'A',(a0)
            rts

ZeigeAlert:
        ; FormAlert - Alertbox ausgeben
            move.l  a0,addrin
            lea     FormAlert(pc),a0
            bsr.s   CallAES
            rts

*-------------------------
CallAES:    move.w  (a0)+,control
            move.l  (a0)+,control+2
            move.l  (a0),control+6
            move.l  #AESPB,d1
            move.w  #200,d0
            trap    #2
            rts

*-----------------------------------
Install:
* Offiziell dokumentiert:
* Bei Accessories steht in a0 ein Zeiger auf die Basepage.
* Sonst (alles ausser Accessories) ist a0 == 0.
            cmpa.l  #0,a0
            seq     Accessory   ; Nein ---> Wir sind ein Programm
            bne.s   .weiter
            move.l  4(sp),a0

   .weiter: move.l  #Stack,sp
            lea     Stack,a1
            suba.l  a0,a1
            move.l  a1,Keep     ; Anzahl resident zu haltender Bytes

            move.l  Keep,-(sp)
            pea     (a0)        ; ab Basepage
            clr.w   -(sp)       ; Dummy
            move.w  #74,-(sp)
            trap    #1          ; MShrink
            lea     12(sp),sp

** XBRA - sind wir schonmal installiert ?
            lea     XbraTest(pc),a0
            bsr     SupExec
            bra     ApplInit

; Kommandozeile ??
*** noch nicht implementiert

; Auto-Ordner-Programm
AutoOrd:    tst.b   Installed
            bne.s   .install
            move.l  CurrentVec,a0
            move.l  ProtDrive(pc),ProtDriveOffs(a0)
            clr.w   -(sp)
            trap    #1

  .install: lea     InstallVecs(pc),a0
            bsr     SupExec

            pea     AutoInf0(pc)
            move.w  #9,-(sp)
            trap    #1
            addq.l  #6,sp

*----------
            clr.w   d5
            move.l  ProtDrive(pc),d7
            lea     Drives+1(pc),a3
     .test: btst    d5,d7
            beq.s   .loopD
            move    d5,d6
            addi.b  #'A',d6
            move.b  d6,(a3)

            pea     Drives(pc)
            move.w  #9,-(sp)
            trap    #1
            addq.l  #6,sp

    .loopD: addq.w  #1,d5
            cmp.b   #32,d5
            blt.s   .test
*----------

            pea     AutoInf1(pc)
            move.w  #9,-(sp)
            trap    #1
            addq.l  #6,sp

            clr.w   -(sp)
            pea     AutoResident-Anfang+$100
            move.w  #49,-(sp)
            trap    #1

Drives:     DC.B    " A",0
AutoInf0:   DC.B    13,10,"*** WProtect 0.97/f RESIDENT DRIVE",0
AutoInf1:   DC.B    13,10,0

** Beim AES anmelden
ApplInit:   lea     ApplicationInit(pc),a0
            move.w  #0,global
            bsr     CallAES
            tst.w   global
          ; global[0] (GEM-Version) wurde ja vorher auf 0 gesetzt
          ; falls immer noch 0 kann das AES noch nicht initialisiert sein
          ; d.h. wir sind im AUTO-Ordner
            beq     AutoOrd
            move.w  intout,ap_id

            tst.b   Accessory
            bne.s   .weiter                ; bne -> Programm

** MenuRegister - In die MenÅzeile eintragen
            move.w  ap_id,intin
            move.l  #Menu_entry,addrin
            lea     MenuRegister(pc),a0
            bsr     CallAES

   .weiter: tst.b   Accessory
            bne     AlertEins               ; Programm
            tst.b   Installed
            beq     WaitForAC_OPEN
            bra     AccNotInstEntry         ; Accessory

*----------------------

* Bitstring der angemeldeten Laufwerke holen
GetDrvBits: move.l  _drvbits,DrvBits    ; angemeldete Laufwerke
            rts

GetNextValidDrive:
* nÑchstes gÅltiges Laufwerk bestimmen
            move.b  ActDrive,d0

   .search: subq.b  #1,d0       ; Annahme 'voriges Laufwerk' angeklickt
            cmp.w   #1,intout
            beq.s   .ok
            addq.b  #2,d0       ; Annahme falsch
       .ok: and.b   #31,d0      ; maximal 32 Laufwerke (0..31)
            move.l  DrvBits,d1
            btst.l  d0,d1
            beq.s   .search

            move.b  d0,ActDrive
            rts

*-------------------

**** Per XBios(38) im Supervisormode ausgefÅhrte Funktionen
SupExec:    pea     (a0)
            move.w  #38,-(sp)
            trap    #14
            addq.l  #6,sp
            rts

XbraTest:   move.l  hdv_rw,a0
* Lîschen Installed nicht nîtig, da BSS
* Vorannahme also: Installiert
 .xbratest: cmpi.l  #"XBRA",-12(a0)
            bne.s   .NotInstall
            cmpi.l  #"WPRO",-8(a0)  ; Kennung des Programmes
            beq.s   .Installed
            move.l  -4(a0),a0
            cmpa.l  #$60C,a0
            bcs.s   .NotInstall
            cmpa.l  #$3FFF00,a0
            bhi.s   .NotInstall
            bra.s   .xbratest

.NotInstall:move.l  #NewHdvRW,CurrentVec
            st      Installed       ; Nicht installiert
            bra.s   .return

.Installed: sf      Installed
            move.l  a0,CurrentVec
            move.l  ProtDriveOffs(a0),ProtDrive
   .return: rts


InstallVecs:move.l  hdv_rw,OldHdvRW
            move.l  #NewHdvRW,hdv_rw
            rts

Get_bootdev:move.w  _bootdev,BootDrv
            rts

*-------------------
SaveConfig:
* Sichern der Konfiguration
        ; ProtDrive zum Sichern retten
            move.l  ProtDrive(pc),ProtDouble

            lea     Get_bootdev(pc),a0
            bsr     SupExec
            move.w  BootDrv,d3

            move.l  ProtDrive(pc),d4
        ; das Laufwerk, auf dem gesichert wird, darf nicht als
        ; geschÅtzt gelten
            bclr.l  d3,d4
            beq.s   .add            ; war nicht geschÅtzt

* Bei geschÅtztem Bootlaufwerk nochmal nachfragen, ob wirklich gesichert
* werden soll! Dies auch bei NICHT installiertem WProtect.
            lea     Alert2(pc),a0
            move.b  d3,Laufwerk2
            addi.b  #'A',Laufwerk2
            bsr     ZeigeAlert

            cmpi.w  #2,intout
            beq.s   SaveRet

            tst.b   Installed
            bne.s   .add
            move.l  CurrentVec,a0
            move.l  d4,ProtDriveOffs(a0)
      .add: addi.b  #'A',d3

            lea     FName(pc),a0   ; 'A:\\AUTO\\WPROTECT.PRG'
            move.b  d3,(a0)
            move.b  d3,FileErrDrv

          ; FOpen
            move.w  #1,-(sp)
            pea     (a0)
            move.w  #61,-(sp)
            trap    #1
            addq.l  #8,sp
            tst.w   d0
            bmi.s   FileErr

          ; D3 wird bei GemDos-Aufrufen automatisch gerettet
            move.w  d0,d3

          ; FSeek
            clr.w   -(sp)
            move.w  d3,-(sp)
            move.l  #28+ProtDrive-Anfang,-(sp)
            move.w  #66,-(sp)
            trap    #1
            lea     10(sp),sp
            tst.w   d0
            bmi.s   FileErr

          ; FWrite
            pea     ProtDouble
            move.l  #4,-(sp)
            move.w  d3,-(sp)
            move.w  #64,-(sp)
            trap    #1
            lea     12(sp),sp
            tst.w   d0
            bmi.s   FileErr

    FClose: move.w  d3,-(sp)
            move.w  #62,-(sp)
            trap    #1
            addq.l  #4,sp

            move.l  ProtDouble,ProtDrive
SaveRet:    rts

* Ein Dateifehler ist aufgetreten
   FileErr: move.w  #1,intin
            lea     FileError(pc),a0
            bsr     ZeigeAlert
            bra.s   FClose

           .END
