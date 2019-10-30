*******************************************************************************
*
*         >>  WPROTECT.S <<                                 V1.03    10.02.1993
*
*   PD Ω by
*   P*ST:
*         Christoph Conrad
*         Adalbertsteinweg 113
*         5100 Aachen
*
*         E-Mail (lieber die als P*ST) direkt Åber
*         MAUS: Christoph Conrad @ AC3
*         ...und die Gateways
*         FIDO: Christoph Conrad % Maus AC3 2:242/2.6
*               ACHTUNG: evt. neu 
*               Christoph Conrad % Maus AC3 2:242/42.333
*       USEnet: Christoph_Conrad@ac3.maus.de
*     Zerberus: Christoph_Conrad%ac3@zermaus.zer
*       Pronet: MAUS:AC3:Christoph_Conrad
*     Internet: conrad@rama.Informatik.RWTH-Aachen.DE
*               (selten, bitte keine ueberlangen Mails!)
*          BTX: Seite *35008024#, im Formular ausfÅllen
*               Christoph_Conrad@AC3.MAUS.DE.UUCP
*               (kostet 90 Pfennig)
*
* Dieses Programm liegt auch dem VIRENDETEKTOR bei, _DEM_ Virensuchprogramm
* auf dem ATARI ST/TT von Volker Soehnitz @ AC. Keiner bietet mehr!
* Lassen Sie sich registrieren und geniessen Schutz vor allen aktuellen
* Viren durch den Updateservice.
*
* WProtect kann und soll weiterkopiert werden, allerdings nur
* _MIT_
* WPROTECT.S
* WPRORSC.S
* VerÑnderungen an Source/Programm NUR zu privaten Zwecken!!
* Wer verÑnderte Versionen von Source oder Programm îffentlich zugÑnglich
* macht, wird von mir ganz schînen érger bekommen!
* WPROTECT.PRG (Unter GEM/Autoordner, durch Umbenennen auch Accessory)
* WPROTECT.RSC
* WPROTECT.RSD (Kuma NRCS)
* WPROTECT.TXT
*
* Liebe Leute, diese Source entstand vor grauer Vorzeit. Also verzeiht mir
* die nicht ganz so Åbersichtliche Programmierung.
*
* Im folgenden bedeute
*
* +  Neues Feature
* -  Beseitigter Bug / Unschînheit / InkompatibilitÑt
* ...mit Grauzonen zwischen beiden!
*
* History:
* 0.97/f: - Sicherungslaufwerk jetzt aus _bootdev ($446)
*         - _drvbits / ProtDrive / ProtDouble wird jetzt als 32 Bit behandelt
*           (Laufwerke A-Z)
*         - Im Accessory werden jetzt bei jeder Aktivierung die aktuellen
*           Schutzwerte aus dem CurrentVec Åbernommen (sonst wÅrde eine
*           zwischenzeitliche énderung Åber einen Programmaufruf ignoriert)
*         + Nachfrage bei Sichern auf X:\AUTO\WPROTECT.PRG (X == Bootlaufwerk),
*           falls Bootlaufwerk als geschÅtzt gilt.
*         + Accessory erkennt nachtrÑglich installierten Schutz.
*         + UnterstÅtzung des VA-Protokolls (VA_START)
*
* Die magische Grenze...
*
* 1.00:   (internal release, not distributed)
*         + GEM-Dialogbox
*           Zum Umwandeln der Resource in Assemblerquellcode verwende
*           ich RSC_TO_S.PRG von
*           ØBernd EcksteinÆ @ AC (Shareware, 10,- die sich lohnen!)
*           Version >= 1.18!! ( Hallo Bernd =:^} )
*         + Erkennung des residenten Prg Åber Cookies anstatt XBRA
*           COOKIE-Library von
*           ØArnd BeissnerÆ @ MS (PD, sehr einfach in der Anwendung)
*           Version >= 1.03!!
*           In Version 1.03 sind noch eine Menge bra, die sich in bra.s
*           umwandeln lassen.
*         + Anpassung des Resourcefiles an Letemfly von
*           ØOliver ScheelÆ @ K (PD, 'man fliegt nicht mehr ohne...')
*           Version >= 1.14!!
*           Die Laufwerksbuttons 'A'-'Z' sind Åber ALT-A - ALT-Z erreichbar.
*           UNDO entspricht dem Abbruchbutton, HELP dem Sichernbutton.
*           In V1.14 verhÑlt sich die Letemfly-form_alert-Routine bezÅglich
*           innerhalb der Box zentrierter Texte anders als die Original-
*           AES-Routine. Dies ist ein rein kosmetisches Problem.
*
* Alle Åber MAUS E-Mail addressierbaren Leute kînnen auch Åber die
* Gateways erreicht werden, indem mein Name und mein Mausknoten (@AC3)
* gegen ihren Namen/MAUS-Knoten ausgetauscht wird, also etwa
*         FIDO: Bernd Eckstein % Maus AC @ 2:242/2.6
*
* 1.01:   + FÅr das Sichern der Konfiguration wird das Bootlaufwerk
*           DGetDrv (GEMDOS 25) im Autoordner-Programm ermittelt.
*         + Versionsnummer abfragbar (siehe Source Label 'Version')
*         + LinksShift+[Button]Nochmal in der Critical-Error-Handler-Box
*           hebt den Schreibschutz fÅr dieses Laufwerk auf!
*
* 1.02:   + WPROTECT.INF-Datei auf der Wurzel des Bootlaufwerkes
*           fÅr das Speichern zu schÅtzender Laufwerke anstatt
*           im Programm selbst.
*
* 1.03:     Bei nachtrÑglich installiertem Programm (Kein Autoordnerprogramm,
*           WPROTECT.PRG als GEM-Programm gestartet und mindestens ein Laufwerk
*           zum Schutz angemeldet):
*         - Es wurde immer versucht auf A:\WPROTECT.INF zu sichern.
*           Gesichert wird nun auf X:\WPROTECT.INF mit X aus _bootdev ($446).
*         - Durch einen Schreibfehler blieb dann fast das ganze Programm
*           resident im Speicher.
*
* Future Releases (* bei genÅgender Programierermotivation)
*         * MetaDOS-Laufwerke werden evt. unterstÅtzt
*         * CPX-Modul (wenn es dazu ein vernÅnftiges Assembler-Toolkit gibt)
*         * Kommandozeile a la
*           WPROTECT +ABC-EFG schÅtzt A/B/C, entschÅtzt E/F/G
*           und lÑsst den Schutzstatus aller anderen Laufwerke unangetastet
*           WPROTECT ++-EF schÅtze alle ausser E und F
*           WPROTECT --+EF entschÅtze alle, schÅtze E und F
*         * Buttons [ SchÅtze alle ] / [ EntschÅtze alle ]
*         + aufgerÑumterer Source
*         + bessere Dokumentation
*
* mfg chris.
*
* Assemblieren mit MadMac V 0.13 (uralt, aber schnell & zuverlÑssig)
* Kommandozeile: -p wprotect
*
* WPRORSC.S (das umgewandelte Resourcefile) + COOKIE.S
* mÅssen sich in demselben Verzeichnis wie WPROTECT.S befinden!
*
* Noch einige Bemerkungen zur RESOURCE. Die Objekte mÅssen mit 'Erst X, dann Y'
* sortiert sein, damit die Laufwerksknîpfe aufsteigende Objektindize haben.
*
* In der umgewandelten Resource bezeichnet
* OBJCs000    Anzahl Objekte in Baum 1
* Objc000000  Label des ersten Objekts in Baum 1
* Falls Ihr Resourcekonverter andere Bezeichnungen wÑhlt, mÅssen Sie
* diese anpassen.
*
*******************************************************************************

WRITE_PROTECT   EQU     -13         ; Bios-Fehlermeldung
_bootdev        EQU     $446
hdv_rw          EQU     $476        ; Harddisk Schreiben-Lesen
_drvbits        EQU     $4C2

NrOfDrives      EQU     26

            .macro AES  func
            lea         \func(pc),a0
            bsr         CallAES
            .endm

            .macro SupExec  func
            lea         \func(pc),a0
            bsr         SupExec
            .endm

            .macro ZeigeAlert  func
            move.l  #\func,addrin
            move.w  #1,intin           ; Defaultbutton 1
            AES     FormAlert
            .endm

           .macro GEMDOS trpno, clean
           .if \trpno != 0
            move.w  #\trpno,-(sp)
           .else
            clr.w   -(sp)
           .endif
            trap    #1
           .if \# = 2
              .if  \clean <= 6         ; -2 wegen trpno
               addq.w  #2+\clean,sp    ; .w ok, da Extension automatisch!
              .else
               lea     2+\clean(sp),sp
              .endif
           .endif
           .endm

           .TEXT
Anfang:     bra     Install

*---------------------------
*---------------------------

Version:    DC.L    '1.03'      ; Position: -18(NewHdvRW)

AutoBootDrv:DC.W    0           ; aktuelles Laufwerk bei Autoordner-Programm
* Bitstring zu schÅtzender Laufwerke Bit 0 == A:, Bit 1 == B: etc.
ProtDrive:  DC.L    0           ; Position: -16(NewHdvRW)

*
* XBRA-Struktur
*
XBRA:       DC.B    "XBRA"      ; Position: -12(NewHdvRW)
Ident:      DC.B    "WPRO"      ; Position: -8(NewHdvRW)
; alter hdv_rw-Vektor
OldHdvRW:   DC.L    0           ; Position: -4(NewHdvRW)

* Neuer hdv_rw-Vektor
NewHdvRW:
ProtDriveOffs   EQU   ProtDrive   - *
AutoBootDrvOffs EQU   AutoBootDrv - *

            movem.l d1-a6,RegSave

            btst.b  #0,5(sp)    ; Read-Write-Flag
            beq.s   gotoOld     ; es wird nur gelesen

            move.w  14(sp),d3   ; Laufwerk 0=A:, 1=B: etc.
            move.l  _drvbits.w,d4
            btst.l  d3,d4       ; gibt's das Laufwerk Åberhaupt ?
            beq.s   gotoOld     ; nein
            move.l  ProtDrive(pc),d4
            btst.l  d3,d4       ; soll Laufwerk geschÅtzt werden ?
            beq.s   gotoOld     ; nein
    .loop:  moveq   #WRITE_PROTECT,d0
          ; D3-D7 / A3-A6 werden vom Critical-Error-Handler gerettet
            bsr.s   CallCritErr ; critical-error-handler aufrufen
            cmp.l   #$10000,d0  ; Retry ?
            bne.s   .wpro

          ; Bei Linksshift+Button[Nochmal] wird der Laufwerksschutz
          ; fÅr das betreffende Laufwerk aufgehoben
            lea     $E1B.w,a1          ; Vorannahme TOS 1.00
            move.l  $4F2.w,a0          ; _sysbase
          ; TOS >= 1.02?
            cmp.w   #$102,2(a0)
            bcs.s   .tos10
            move.l  $24(a0),a1         ; *pkbshift
          ; LinksShift gedrÅckt?
    .tos10: cmp.b   #2,(a1)
            bne.s   .loop
          ; Laufwerksschutz aufheben
            move.w  14(sp),d3   ; Laufwerk 0=A:, 1=B: etc.
            move.l  ProtDrive(pc),d4
            bclr    d3,d4
            move.l  d4,ProtDrive
            bra.s   gotoOld

     .wpro: movem.l RegSave(pc),d1-a6
            moveq   #WRITE_PROTECT,d0
            rts
gotoOld:    movem.l RegSave(pc),d1-a6
            move.l  OldHdvRW(pc),-(sp)
            rts

CallCritErr:move.w  d3,-(sp)    ; Laufwerk
            move.w  d0,-(sp)    ; Fehlercode
            moveq   #-1,d0      ; KompatibilitÑt zum Bios
            move.l  $404.w,a0   ; etv_critic
            jsr     (a0)
            addq.w  #4,sp
            rts

RegSave:    .DCB.L   14,0 ; D1-D7/a0-a6

AutoResident    EQU     *
*----------------------------

*
* Resource einbinden
*
            .include "WPRORSC.S"

AESPB:      DC.L    control, global, intin, intout, addrin, addrout

NotResident:DC.B    "[1][WProtect 1.03:|Bleibe nicht resident.][Ok]",0
            .even

AlertNotInstalled:
            DC.B    "[1][WProtect 1.03:|Bitte installieren!][Ok]",0
            .even

Widmung:    DC.B    "[0][~~~~~~~~~~~~~~~  |  Widmung  an|    Barbara|"
            DC.B    "~~~~~~~~~~~~~~~  ][ Ok ]",0
            .even

NoCookie:   DC.B    "[1][WProtect 1.03:|Kann keinen Cookie anlegen.][Ok]",0
            .even

AlertBootProt:
            DC.B    "[2][WProtect 1.03:|Laufwerk "
AlertBootDrv:
            DC.B    0," ist geschÅtzt.|Trotzdem sichern?]"
            DC.B    "[Ok|Abbruch]",0
            .even

Menu_entry: DC.B    "  ",3," WProtect 1.03  ",0
            .even

FileError:  DC.B    "[1][ Dateifehler beim Speichern | auf "
FileErrDrv: DC.B    "X:\\WPROTECT.INF!][ Ok ]",0
            .even

FName:      DC.B    "X:\\WPROTECT.INF",0   ; 1. Byte == Laufwerk
            .even

* Worte fÅr's control-Feld
* contrl[0..4] = opcode / #intin / #intout / #addrin / #addrout
* O-Ton Profibuch 10te Auflage:
* "DarÅber, welche Werte vor einem AES-Aufruf gesetzt werden mÅssen, gibt es
* keine klaren Informationen. Nîtig ist es auf jeden Fall fÅr contrl[0],
* contrl[1] und contrl[3]. Wenig sinnvoll erscheint es fÅr contrl[2] und
* contrl[4] - schliesslich wissen ja die AES-Funktionen selbst, wie viele
* Werte sie in den Ausgabefeldern zurÅckliefern.
* Die mit dem Original-Entwicklungspaket mitgelieferten Bindings [...] setzen
* allerdings alle Werte des Arrays."
* ...und tatsÑchlich: Unterlasse ich das Vorbesetzen von contrl[2] und
* contrl[4] funktioniert der Aufruf Åber Anklicken der Accessory-MenÅleiste
* nicht mehr.
ApplicationInit:
            DC.W    10,0,1,0,0
ApplExit:   DC.W    19,0,1,0,0
EvntMesag:  DC.W    23,0,1,1,0
MenuRegister:DC.W  35,1,1,1,0

FormAlert:  DC.W    52,1,1,1,0
FormDo:     DC.W    50,1,1,1,0
FormDial:   DC.W    51,9,1,0,0
FormCenter: DC.W    54,0,5,1,0

GrafMouse:  DC.W    78,1,1,1,0
WindUpdate: DC.W    107,1,1,0,0

RSRCObFix:  DC.W    114,1,1,1,0

OBJC_Change:DC.W    47,8,1,1,0
OBJC_Draw:  DC.W    42,6,1,1,0

           .BSS
control:    DS.W    12
global:     DS.W    15
intin:      DS.W    128
intout:     DS.W    128
addrin:     DS.W    128
addrout:    DS.W    128

CurrentVec: DS.L    1   ; NewHdvRW-Vektor
Installed:  DS.B    1   ; 0 : Installiert !
Accessory:  DS.B    1   ; Falls 0 -> Accessory
* beim Abspeichern von ProtDrive darf das Laufwerk, auf dem
* gespeichert wird, nicht geschÅtzt sein. ProtDouble dient als
* Buffer, wÑhrend in ProtDrive das entsprechende Bit gelîscht wird
ProtDouble: DS.L    1
BootDrv:    DS.W    1
ActDrive:   DS.B    1   ; Aktuell zu bearbeitendes Laufwerk
DrvBits:    DS.L    1   ; Kopie von _drvbits ($4C2)
Keep:       DS.L    1

* Per FormCenter ermittelte zentrierte Koordinaten der Dialogbox
xClip:      DS.W    1
yClip:      DS.W    1
wClip:      DS.W    1
hClip:      DS.W    1

MsgBuf:     DS.B    16  ; Nachrichtenbuffer AES

            DS.B    $190    ; 400 Byte Stack reichen dicke
Stack       EQU     *


           .TEXT
*-------------------------
ObjcChange:
* Vorzubesetzen sind
* intin     Objektnummer
* intin+12  newstate
* intin+14  (0) 1 = (nicht) neuzeichnen
* Parameterfelder fÅr OBJC_Change setzen
            clr.w   intin+2         ; reserved
          ; Clipping setzen (quasi abschalten)
            clr.l   intin+4
            move.l  #$7FFF7FFF,intin+8

            move.l  #Objc000000,addrin ; Objektbaumadresse
            AES     OBJC_Change
            rts

ObFixCenter:
* Anpassung Koordinaten Zeichen- in Pixeldarstellung
            move.l  #Objc000000,addrin
            move.w  #OBJCs000-1,d3

  .convert: move.w  d3,intin
            AES     RSRCObFix
            dbra    d3,.convert
            rts

DialogInit: move.l  #Objc000000,addrin
            AES     FormCenter
            move.l  intout+2,xClip
            move.l  intout+6,wClip

            SupExec GetDrvBits
            move.l  DrvBits,d4
            move.l  ProtDrive(pc),d5
            move.w  #NrOfDrives-1,d3      ; 26 Laufwerke testen

            clr.w   intin+14    ; nicht neuzeichnen

     .loop: btst.l  d3,d4       ; gibt's das Laufwerk Åberhaupt ?
            bne.s   .protect    ; ja

            move.w  #8,intin+12     ; DISABLED

            bra.s   .change

  .protect: btst.l  d3,d5           ; soll Laufwerk geschÅtzt werden ?
            bne.s   .prot           ; ja
            clr.w   intin+12        ; NOT SELECTED
            bra.s   .change

     .prot: move.w  #1,intin+12     ; SELECTED

   .change: move.w  d3,d6
            addq.w  #DRIVEA,d6
            move.w  d6,intin        ; Objektnummer
            bsr     ObjcChange
    .loop1: dbra    d3,.loop

            move.w  #1,intin        ; BEG_UPDATE
            AES     WindUpdate

DrawDialog: clr.w   intin           ; Mauszeiger als Pfeil
            AES     GrafMouse

            clr.w   intin           ; FMD_START
            clr.l   intin+2
            clr.l   intin+6
            move.l  xClip,intin+10
            move.l  wClip,intin+14
            AES     FormDial

            clr.w   intin           ; Startobjekt 0
            move.w  #8,intin+2      ; Alle Objektebenen zeichnen
            move.l  xClip,intin+4
            move.l  wClip,intin+8
            AES     OBJC_Draw

Dialog:     clr.w   intin
            move.l  #Objc000000,addrin ; Objektbaumadresse
            AES     FormDo
            move.w  intout,d0

            cmp.w   #WIDMUNG,d0
            bne.s   .weiter
            ZeigeAlert Widmung
            move.w  #WIDMUNG,intin
   .change: clr.w   intin+12
            move.w  #1,intin+14
            bsr     ObjcChange
            bra.s   Dialog

   .weiter: cmp.w   #EXIT,d0
            beq.s   ExitButton

            cmp.w   #SAVE,d0
            bne.s   IsOk?
            bsr     SaveConfig
            move.w  #SAVE,intin
            bra.s   .change

     IsOk?: cmp.w   #OK,d0
            beq.s   OkButton

            bra     Dialog
*------------------------
NewProtDrv: lea     Objc000000(pc),a0   ; Objektbaumadresse
            move.w  #DRIVEA+NrOfDrives-1,d0
            mulu    #24,d0
            adda.l  d0,a0

            move.w  #NrOfDrives-1,d0
            clr.l   d1                 ; Default: alle deselektiert

* Laufwerke durchgehen
     .test: btst.b  #0,11(a0)          ; Selected?
            beq.s   .weiter            ; nein
            bset.l  d0,d1
   .weiter: suba.l  #24,a0             ; nÑchstes Objekt
            dbra    d0,.test
            rts

OkButton:   move.w  d0,intin
            clr.l   intin+12
            bsr     ObjcChange

            bsr     NewProtDrv

            move.l  CurrentVec,a0    ; die neuen Schutzwerte Åbernehmen
            move.l  d1,ProtDriveOffs(a0)

ExitButton: move.w  d0,intin
            clr.l   intin+12
            bsr     ObjcChange

            move.w  #3,intin        ; FMD_FINISH
            clr.l   intin+2
            clr.l   intin+6
            move.l  xClip,intin+10
            move.l  wClip,intin+14
            AES     FormDial

            clr.w   intin           ; END_UPDATE
            AES     WindUpdate

    IsAcc?: tst.b   Accessory
            beq     WaitForAC_OPEN

* Wir sind ein Programm!
            tst.b   Installed
            bne.s   .Protected?     ; brancht falls NICHT installiert
            bra.s   .terminate

*
* Wir sind ein Programm und nicht installiert
*
* Sind Åberhaupt irgendwelche Laufwerke zum SchÅtzen gekennzeichnet worden ?
* Falls nicht, brauchen wir nicht resident zu bleiben
.Protected?:tst.l   ProtDrive
            bne.s   .install

            ZeigeAlert NotResident

        ; ApplExit - Vom AES abmelden
.terminate: AES     ApplExit

            GEMDOS  0               ; PTerm

  .install: SupExec InstallVecs
            bne.s   .raus
            ZeigeAlert NoCookie
            bra.s   .terminate

        ; ApplExit - Vom AES abmelden
     .raus: AES     ApplExit
            SupExec Get_bootdev
            move.w  BootDrv,AutoBootDrv

            clr.w   -(sp)
            pea     AutoResident-Anfang+$100
            GEMDOS  49


WaitForAC_OPEN:
        ; EvntMesag - auf Mitteilung warten
            move.l  #MsgBuf,addrin
            AES     EvntMesag

            cmp.w   #40,MsgBuf            ; AC_OPEN
            beq.s   .test
            cmp.w   #$4711,MsgBuf         ; VA_START (Gemini)
            bne.s   WaitForAC_OPEN

* Falls Accessory ohne installiertes Autoordnerprogramm gestartet
* immer mal wieder nachschauen ob nicht inzwischen Åber WPROTECT.PRG
* (nachtrÑglich gestartet) ein residentes WProtect drin ist.
     .test: bsr     IsInstalled?

            tst.b   Installed
            bne.s   AccNotInstEntry   ; Nicht installiert

            move.l  CurrentVec,a0
            move.l  ProtDriveOffs(a0),ProtDrive

            bra     DialogInit

AccNotInstEntry:
          ; Nicht installiert
            ZeigeAlert AlertNotInstalled

            bra     WaitForAC_OPEN

*-------------------------
CallAES:    movem.l d0-a6,-(sp)
            move.w  (a0)+,control
            move.l  (a0)+,control+2
            move.l  (a0),control+6
            move.l  #AESPB,d1
            move.w  #200,d0
            trap    #2
            movem.l (sp)+,d0-a6
            rts

*-----------------------------------
Install:
* Offiziell dokumentiert:
* Bei Accessories steht in a0 ein Zeiger auf die Basepage.
* Sonst (alles ausser Accessories) ist a0 == 0.
            cmpa.l  #0,a0       ; Basepageadresse in a0?
            seq     Accessory   ; Nein ---> Wir sind ein Programm
            bne.s   .weiter0
            move.l  4(sp),a0    ; Basepageadresse

  .weiter0: move.l  #Stack,sp
            tst.b   Accessory
            beq.s   .cookie

            lea     Stack,a1
            suba.l  a0,a1
            move.l  a1,Keep     ; Anzahl evt. resident zu haltender Bytes

            move.l  Keep,-(sp)
            pea     (a0)        ; ab Basepage
            clr.w   -(sp)       ; Dummy
            GEMDOS  74,10       ; MShrink

** Cookietest - sind wir schonmal installiert ?
   .cookie: bsr     IsInstalled?

*-------------------------------------------------------------
** Beim AES anmelden
            clr.w   global
            AES     ApplicationInit
            tst.w   global
          ; global[0] (GEM-Version) wurde ja vorher auf 0 gesetzt
          ; falls immer noch 0 kann das AES noch nicht initialisiert sein
          ; d.h. wir sind im AUTO-Ordner
            beq.s   AutoOrd

            tst.b   Accessory
            bne.s   .weiter                  ; bne -> Programm

** MenuRegister - In die MenÅzeile eintragen
            move.w  intout,intin
            move.l  #Menu_entry,addrin
            AES     MenuRegister

   .weiter: bsr     ObFixCenter
            tst.b   Accessory
            bne     DialogInit               ; Programm
            tst.b   Installed
            beq     WaitForAC_OPEN
            bra     AccNotInstEntry          ; Accessory

*--------------------------------------------------------
; Auto-Ordner-Programm
AutoOrd:    tst.b   Installed
            bne.s   .install
            move.l  CurrentVec,a0
            move.l  ProtDrive(pc),ProtDriveOffs(a0)
.terminate: GEMDOS  0               ; PTerm

  .install: SupExec InstallVecs
            bne.s   .weiter

            pea     AutoInf1(pc)
            GEMDOS  9,4

            bra.s   .terminate

   .weiter: GEMDOS  25,0            ; DGetDrv, aktuelles Laufwerk
            move.w  d0,AutoBootDrv

            bsr     ReadConfig

            pea     AutoInf0(pc)
            GEMDOS  9,4

*----------
            move.l  ProtDrive(pc),d7
            beq.s   .raus

            pea     ProtectStr(pc)
            GEMDOS  9,4

            clr.w   d5
            lea     Drives+1(pc),a3
     .test: btst    d5,d7
            beq.s   .loopD
            move    d5,d6
            addi.b  #'A',d6
            move.b  d6,(a3)

            pea     Drives(pc)
            GEMDOS  9,4

    .loopD: addq.w  #1,d5
            cmp.b   #NrOfDrives,d5
            blt.s   .test
*----------

     .raus: pea     CRLFCRLF(pc)
            GEMDOS  9,4

            clr.w   -(sp)
            pea     AutoResident-Anfang+$100
            GEMDOS  49

Drives:     DC.B    " A",0
ProtectStr: DC.B    " SchÅtze: ",0
AutoInf0:   DC.B    13,10,"*** WProtect 1.03 RESIDENT.",0
CRLFCRLF:   DC.B    13,10,13,10,0
AutoInf1:   DC.B    "*** WProtect 1.03: kein COOKIE anlegbar.",13,10
            DC.B    "***                NICHT RESIDENT!",13,10,0
            .even

*----------------------

* Bitstring der angemeldeten Laufwerke holen
GetDrvBits: move.l  _drvbits.w,DrvBits       ; angemeldete Laufwerke
            rts

*-------------------

**** Per XBios(38) im Supervisormode ausgefÅhrte Funktionen
SupExec:    pea     (a0)
            move.w  #38,-(sp)
            trap    #14
            addq.w  #6,sp
            rts

*----------------------------------------------------
*  IN: -
* OUT: d0.w == 0 Installation schlug fehl
InstallVecs:move.l  #'WPRO',d0
            move.l  #NewHdvRW,d1
            bsr     CK_WriteJar
            tst.w   d0
            beq.s   .return

            move.l  hdv_rw.w,OldHdvRW
            move.l  #NewHdvRW,hdv_rw.w
   .return: rts

Get_bootdev:tst.b   Installed
            beq.s   .weiter
            move.w  _bootdev.w,BootDrv
            rts
   .weiter: move.l  CurrentVec,a0
            move.w  AutoBootDrvOffs(a0),BootDrv
            rts

*-------------------
SaveConfig:
* Sichern der Konfiguration
            bsr     NewProtDrv
            move.l  d1,d4
            move.l  d1,ProtDrive

        ; ProtDrive zum Sichern retten
            move.l  ProtDrive(pc),ProtDouble

            SupExec Get_bootdev
            move.w  BootDrv,d3

        ; das Laufwerk, auf dem gesichert wird, darf nicht als
        ; geschÅtzt gelten
            bclr.l  d3,d4
            beq.s   .noprot            ; war nicht geschÅtzt

* Bei geschÅtztem Bootlaufwerk nochmal nachfragen,
* ob wirklich gesichert werden soll!
            move.b  d3,AlertBootDrv
            addi.b  #'A',AlertBootDrv
            ZeigeAlert AlertBootProt

            cmpi.w  #2,intout
            beq     SaveRet

   .noprot: move.l  CurrentVec,a0
            move.l  d4,ProtDriveOffs(a0)
            addi.b  #'A',d3

            lea     FName(pc),a0   ; 'X:\\WPROTECT.INF'
            move.b  d3,(a0)
            move.b  d3,FileErrDrv

          ; FCreate
            clr.w   -(sp)
            pea     (a0)
            GEMDOS  60,6
            tst.w   d0
            bmi     FileErr

          ; D3 wird bei GemDos-Aufrufen automatisch gerettet
            move.w  d0,d3

          ; FWrite
            pea     ProtDouble
            pea     4
            move.w  d3,-(sp)
            GEMDOS  64,10
            tst.w   d0
            bmi.s   FileErr

            bsr     FClose

            move.l  ProtDouble,ProtDrive
            move.l  CurrentVec,a0
            move.l  ProtDrive(pc),ProtDriveOffs(a0)
SaveRet:    rts

*-------------------
ReadConfig:
* Einlesen der Konfiguration
            SupExec Get_bootdev
            move.w  BootDrv,d3
            addi.b  #'A',d3

            lea     FName(pc),a0   ; 'X:\\WPROTECT.INF'
            move.b  d3,(a0)

          ; FOpen
            move.w  #1,-(sp)
            pea     (a0)
            GEMDOS  61,6
            tst.w   d0
            bmi     ReadErrAuto

          ; D3 wird bei GemDos-Aufrufen automatisch gerettet
            move.w  d0,d3

          ; FRead
            pea     ProtDrive(pc)
            pea     4
            move.w  d3,-(sp)
            GEMDOS  63,10
            tst.w   d0
            bpl.s   FClose

            bsr     ReadErrAuto
            bra.s   FClose

*--------------------------------------------------
* Ein Dateifehler ist aufgetreten
   FileErr:ZeigeAlert FileError
   FClose: move.w  d3,-(sp)
           GEMDOS  62,2
           rts

*--------------------------------------------------
CookieVal:  DC.L    0
IsInstalled?:
          ; Ab in den Supervisormode
            pea     0
            GEMDOS  32,4
            move.l  d0,-(sp)

            move.l  #'WPRO',d0
            lea     CookieVal(pc),a0
            bsr     CK_ReadJar
            tst.w   d0
            seq     Installed
            bne.s   .installed
            move.l  #NewHdvRW,CurrentVec
            bra.s   .weiter

.installed: move.l  CookieVal(pc),a0
            move.l  a0,CurrentVec
            move.l  ProtDriveOffs(a0),ProtDrive

          ; ZurÅck in den Usermode
   .weiter: GEMDOS  32,4
            rts

ReadErr:    DC.B    "*** WProtect 1.03: "
            DC.B    "Fehler beim Lesen der Konfiguration!",13,10
            DC.B    "Bleibe resident!",0
ReadErrAuto:pea     ReadErr(pc)
            GEMDOS  9,4
            rts

           .include "COOKIE.S"

           .END
