**********************************************************************
*                                                                    *
*   Write-Protect.ACC  :  Schreibschutz fÅr alle!                    *
*                                                                    *
*   PD-Soft by P. Fellerich                                          *
*              45, rue des Genàts                                    *
*              L-3482 Dudelange                                      *
*                                                                    *
* Syntax: TURBOASS                                                   *
**********************************************************************
xb_id          equ 'WPrt'
               output 'C:\WRITEPRT.ACC'

               >PART 'RSCDEFS'
WMAIN          equ 0
OBJ_COUNT      equ 20         ;Anzahl objekte in der RSC
FMD_START      equ 0
FMD_GROW       equ 1
FMD_SHRINK     equ 2
FMD_FINISH     equ 3

abort_btn      equ 18
ok_btn         equ 19
               endpart
               >PART 'OS defs'
biostrap       equ $B4
xbiostrap      equ $B8
etv_critic     equ $0404
criticret      equ $048A
savptr         equ $04A2
_drvbits       equ $04C2
               endpart

Start:    lea       stack(pc),sp
          lea       contrl(pc),a6       ;Adresse des Control-Arrays
          lea       addrin(pc),a5
;Appl_init:
          move.l    #$0A000100,d2       ;Das ist 'n Programmierstil!!!!
          movep.l   d2,1(a6)
          move.w    #0,8(a6)            ;Der bleibt immer gleich
          bsr       Call_aes

          move.w    ap_id(pc),intin
          move.l    #wmess,(a5)         ;Adresse Titel
          move.l    #$23010101,d2       ;Menu_register
          movep.l   d2,1(a6)
          bsr       Call_aes
          move.w    intout(pc),menu_id  ;menu_id nicht vergessen

;******** Diverse Initialisationen

          lea       ObjectList(pc),a4
          lea       Wprot(pc),a0
          move.l    a0,(a4)             ;FÅr das AES
          clr.l     (a4)+
;RSC-Init: mit rsrc_obfix
          move.l    a0,(a5)             ;Objektbaum adresse in addrin eintragen
          lea       intin(pc),a5        ;jetzt intin adresse in a5
          move.l    #$72010101,d6
          move.w    #(OBJ_COUNT-1),d7   ;Counter fÅr Objekte

Convloop:
          move.w    d7,(a5)             ;ob-nummer in intin
          movep.l   d6,1(a6)            ;CONTRL setzen
          bsr       Call_aes            ;RSRC_OBFIX
          dbra      d7,Convloop         ;NÑchstes Objekt
;*****  fertig!
          pea       WP_install(pc)      ;Installation der Biosroutine
          move.w    #38,-(sp)           ;Supexec
          trap      #14                 ;XBIOS
          addq.l    #6,sp

;******** Eigentliche ACC-Schleife

ACCloop:  lea       contrl(pc),a6
          lea       msgbuf(pc),a4       ;Wo hamma den das Message?
          move.l    a4,ADDRIN(a6)
;Und EVNT_MESAG:
          move.l    #$17000101,d2
          movep.l   d2,1(a6)
          bsr       Call_aes            ;ab ins AES
          lea       msgbuf(pc),a5       ;Messagebuffer
          cmpi.w    #40,(a5)            ;AC_OPEN ??
          bne.s     ACCloop             ;Nee, forget it
          move.w    menu_id(pc),d2
          cmp.w     8(a5),d2            ;Menu_id?
          bne.s     ACCloop

;****** Jetzt muû die Dialogbox bearbeitet werden:

;**** Daten lesen und Dialog einstellen...
          bsr       GetProt

;FORM_CENTER
          move.l    #Wprot,ADDRIN(a6)
          move.l    #$36000501,d2
          movep.l   d2,1(a6)
          bsr       Call_aes            ;Form_Center

          lea       (2+INTOUT)(a6),a5   ;XYWH Daten hier!
          lea       BoxCoord(pc),a4     ;Variablen fÅr Boxes
          move.l    (a5)+,(a4)+         ;AbspeicheLn
          move.l    (a5)+,(a4)+

;FORM_DIAL
          lea       INTIN(a6),a5
          movea.l   a5,a0
          lea       BoxCoord(pc),a4
          move.w    #FMD_START,(a5)+
          move.l    (a4)+,(a5)+         ;dilittl...
          move.l    (a4)+,(a5)+
          exg       a0,a5
          move.l    (a4)+,(a5)+         ;dibig..
          move.l    (a4)+,(a5)+
          move.l    #$33090100,d2
          movep.l   d2,1(a6)            ;FORM_DIAL fÅr Bildschirm reserv.
          bsr       Call_aes

;OBJC_DRAW
          lea       INTIN(a6),a5
          lea       BoxCoord(pc),a4
          move.w    #WMAIN,(a5)+        ;Start Ob
          move.w    #2,(a5)+            ;ob_drdepth
          move.l    (a4)+,(a5)+         ;Clipping Rectangle xclip,yclip
          move.l    (a4)+,(a5)+         ;wclip,hclip
          move.l    #Wprot,ADDRIN(a6)
          move.l    #$2A060101,d2
          movep.l   d2,1(a6)            ;AES CONTRL
          bsr       Call_aes            ;OBJC_DRAW

;FORM_DO
          move.w    #WMAIN,INTIN(a6)    ;fo_dostartob
          lea       Wprot(pc),a0
          move.l    a0,ADDRIN(a6)       ;fo_dotree
          move.l    #$32010101,d2       ;FORM_DO
          movep.l   d2,1(a6)
          bsr       Call_aes            ;Und AB!

;**** Erst mal Resultat auswerten. (Jetzt hamma die Mîglichkeit)
          move.w    INTOUT(a6),d0       ;fo_doreturn
          cmpi.w    #ok_btn,d0          ;OK angeclickt?
          bne.s     SkipSetProt         ;also!
          bsr.s     SetProt
SkipSetProt:

;**** Dialogbox abbauen
;FORM_DIAL
          lea       contrl(pc),a6       ;Zur Sicherheit...
          lea       intin(pc),a5
          lea       BoxCoord(pc),a4
          move.w    #FMD_FINISH,(a5)+   ;intin adresse von vor 3 Zeilen
          move.l    (a4)+,(a5)+         ;BOXCOORDINATEN einsetzen
          move.l    (a4)+,(a5)+
          lea       BoxCoord(pc),a4
          move.l    (a4)+,(a5)+
          move.l    (a4)+,(a5)+
          move.l    #$33090100,d2
          movep.l   d2,1(a6)            ;FORM_DIAL fÅr Bildschirm freigeben
          bsr       Call_aes            ;AES

          bra       ACCloop             ;Und noch mal von vorne

;************************************************************

SetProt:                                ;**** Datenfluû: DIALOG ==> SUBROUTINE  und  Reset Dialog
          lea       10+WABORT(pc),a0
          clr.w     (a0)                ;Reset State
          clr.w     24(a0)
          move.w    #15,d1              ;Counter in d1
          moveq     #0,d0               ;BitSammler ausnullen
          lea       10+WPDP(pc),a0      ;Pointer auf letztes ObState
ReadLoop: tst.w     (a0)                ;ObState testen
          beq.s     war_nix             ;ObState Null -> bit nicht setzen
          bset      d1,d0               ;Bit setzen
war_nix:  suba.w    #24,a0              ;next ObState
          dbra      d1,ReadLoop         ;weiter
          lea       Prot_drive(pc),a0
          move.w    d0,(a0)             ;Prot_drive speicheLn
          rts

GetProt:  lea       10+WABORT(pc),a0
          clr.w     (a0)                ;Reset State
          clr.w     24(a0)
          move.w    #15,d1              ;Counter in d1
          move.w    Prot_drive(pc),d0   ;BitSammler in d0
          lea       10+WPDP(pc),a0
          moveq     #1,d2
          moveq     #24,d3              ;Adr.dist.
WriteLoop:
          clr.w     (a0)                ;ObState erst mal normal
          btst      d1,d0               ;Bit gesetzt?
          beq.s     warnix1
          or.w      d2,(a0)             ;Selected setzen
warnix1:  suba.l    d3,a0
          dbra      d1,WriteLoop        ;Alle Drives durchnehmen
          rts

WP_install:                             ;Installation fÅr Bios-Routine

          lea       BIOS_neu(pc),a0
          move.l    biostrap.w,-4(a0)
          move.l    a0,biostrap.w       ;Neuen Pointer installieren

          lea       XBIOS_neu(pc),a0
          move.l    xbiostrap.w,-4(a0)  ;Modify Code
          move.l    a0,xbiostrap.w      ;Neuen Pointer installieren

          rts

;************************************************************
;Neue Bios-Routine
               dc.l 'XBRA',xb_id,0
BIOS_neu: lea       6(sp),a0            ;Annahme Supermode
          btst      #5,(sp)             ;Supervisorbit testen
          bne.s     IsBSuper
          move      usp,a0              ;UserStackPointer
IsBSuper: cmpi.w    #4,(a0)             ;Bios-Opcode fÅr RWABS?
          bne.s     BIOS_old            ;nee, also ins Original
          btst      #0,3(a0)            ;RWflag testen
          beq.s     BIOS_old            ;Lesezugriffe sind OK

          move.w    12(a0),d0           ;Device.No in d0
          move.w    Prot_drive(pc),d1   ;Bitmaske der geschÅtzten Drives
          btst      d0,d1
          beq.s     BIOS_old            ;Nicht geschÅtzt, Ende

;******** IF Fehlerfall:
          movem.l   d1-d2/a0-a2,-(sp)   ;RS
          move.w    d0,-(sp)            ;DriveNumber auf Stack
          move.w    #-13,-(sp)          ;FehlerCode
          moveq     #-1,d0              ;Kompat. zum BIOS
          movea.l   etv_critic.w,a0
          jsr       (a0)                ;Critical Error Handler.
          addq.l    #2,sp               ;nur 2
          move.w    (sp)+,ActDriveNr    ;Drive merken
          cmpi.l    #$010000,d0         ;Retry??
          bne.s     stay_protected      ;nee,weiter
          lea       tsavptr(pc),a0      ;merkadr fÅr alten pointer
          move.l    savptr.w,(a0)       ;Originalpointer merken
          lea       end_area(pc),a0     ;neue Save Area-adresse
          move.l    a0,savptr.w         ;Bios interruptfÑhig...
          move.w    #-1,-(sp)           ;mode...
          move.w    #11,-(sp)           ;KBSHIFT
          trap      #13                 ;BIOS
          addq.l    #4,sp
          move.l    tsavptr(pc),savptr.w ;Original Save Area restaurieren
          cmpi.w    #3,d0               ;Shift-Shift?
          bne.s     stay_protected      ;nee, bleib wie du bist
          move.w    ActDriveNr(pc),d0   ;Recall DriveNr
          lea       Prot_drive(pc),a0
          move.w    (a0),d1             ;Bitmaske
          bclr      d0,d1               ;Bit lîschen
          move.w    d1,(a0)             ;natÅrlich zurÅckschreiben
          movem.l   (sp)+,d1-d2/a0-a2   ;Register Restore
          bra.s     BIOS_old            ;Normal weiter, schreiben erlaubt

stay_protected:
          movem.l   (sp)+,d1-d2/a0-a2   ;RR
          moveq     #-13,d0             ;TOS-ERROR -13 simulieren
          rte                           ;Ende der Exception.

BIOS_old: movea.l   (BIOS_neu-4)(pc),a0
          jmp       (a0)

tsavptr:       dc.l 0         ;Zwischenspeicher fÅr Bios savptr

               dc.l 'XBRA',xb_id,0
XBIOS_neu:                              ;neue xbios-routine
          lea       6(sp),a0            ;Annahme Supermode
          btst      #5,(sp)             ;Supervisorbit testen
          bne.s     IsSuper
          move      usp,a0              ;UserStackPointer
IsSuper:  cmpi.w    #9,(a0)             ;XBios-Opcode fÅr Flopwr?
          beq.s     xTest
          cmpi.w    #10,(a0)            ;oder Flopfmt??
          beq.s     xTest
XBIOS_old:
          movea.l   (XBIOS_neu-4)(pc),a0
          jmp       (a0)


xTest:    move.w    10(a0),d0           ;Device.No in d0
          move.w    Prot_drive(pc),d1   ;Bitmaske der geschÅtzten Drives
          btst      d0,d1
          beq.s     XBIOS_old           ;nicht geschÅtzt, forget it
backjmp:  moveq     #-13,d0             ;aber jetzt!
          rte                           ;der rasende Dispatcher


Call_aes: move.l    #aespb,d1
          move.w    #200,d0             ;AES-Opcode
          trap      #2                  ;Gemsys
          rts

               data
aespb:         dc.l contrl,global,intin,intout,addrin,addrout

;******** RSC-Daten:

Wprot:         dc.w -1,1,19,20,0,16 ;éuûere Box
               dc.l $021100
               dc.w 0,0,34,9
WTITLE:        dc.w 2,-1,-1,28,0,0 ;Dialogboxtitel
               dc.l (wmess+2) ;Pointer auf titel
               dc.w 2,1,17,1
WPDA:          dc.w 3,-1,-1,27,1,0 ;WriteProtect Drive A (WPDA)
               dc.l $41FF1100 ;erstes (HIGH) Byte = BOXCHAR
               dc.w 2,3,2,1
WPDB:          dc.w 4,-1,-1,27,1,0
               dc.l $42FF1100
               dc.w 6,3,2,1
WPDC:          dc.w 5,-1,-1,27,1,0
               dc.l $43FF1100
               dc.w 10,3,2,1
WPDD:          dc.w 6,-1,-1,27,1,0
               dc.l $44FF1100
               dc.w 14,3,2,1
WPDE:          dc.w 7,-1,-1,27,1,0
               dc.l $45FF1100
               dc.w 18,3,2,1
WPDF:          dc.w 8,-1,-1,27,1,0
               dc.l $46FF1100
               dc.w 22,3,2,1
WPDG:          dc.w 9,-1,-1,27,1,0
               dc.l $47FF1100
               dc.w 26,3,2,1
WPDH:          dc.w 10,-1,-1,27,1,0
               dc.l $48FF1100
               dc.w 30,3,2,1
WPDI:          dc.w 11,-1,-1,27,1,0
               dc.l $49FF1100
               dc.w 2,5,2,1
WPDJ:          dc.w 12,-1,-1,27,1,0
               dc.l $4AFF1100
               dc.w 6,5,2,1
WPDK:          dc.w 13,-1,-1,27,1,0
               dc.l $4BFF1100
               dc.w 10,5,2,1
WPDL:          dc.w 14,-1,-1,27,1,0
               dc.l $4CFF1100
               dc.w 14,5,2,1
WPDM:          dc.w 15,-1,-1,27,1,0
               dc.l $4DFF1100
               dc.w 18,5,2,1
WPDN:          dc.w 16,-1,-1,27,1,0
               dc.l $4EFF1100
               dc.w 22,5,2,1
WPDO:          dc.w 17,-1,-1,27,1,0
               dc.l $4FFF1100
               dc.w 26,5,2,1
WPDP:          dc.w 18,-1,-1,27,1,0
               dc.l $50FF1100
               dc.w 30,5,2,1
WABORT:        dc.w 19,-1,-1,26,5,0 ;Abort-Button
               dc.l abort
               dc.w 2,7,8,1
WOK:           dc.w 0,-1,-1,26,39,0 ;OK-Button
               dc.l ok
               dc.w 24,7,8,1

;******** Zeichenketten:

wmess:         dc.b '  Write-Protect...',0
abort:         dc.b 'Abort',0
ok:            dc.b 'OK',0

;********

               even
               bss
Prot_drive:    ds.w 1
ActDriveNr:    ds.w 1

menu_id:       ds.w 1
ObjectList:    ds.l 2
BoxCoord:      ds.w 4

sav_area:      ds.w 46        ;Save Area fÅr Bios - 2 aufrufe max.
end_area:

contrl:        ds.w 5

global:        ds.w 2         ;Global-Array: 15 Words
ap_id:         ds.w 3
ap_ptree:      ds.w 10

intin:         ds.w 10
intout:        ds.w 4
addrin:        ds.l 1
addrout:       ds.l 1

msgbuf:        ds.w 8         ;16 Bytes Messagebuffer


               ds.l 64        ;Stackgrîûe
stack:
;***********************

CONTRL         equ 0
INTIN          equ intin-contrl
INTOUT         equ intout-contrl
ADDRIN         equ addrin-contrl
ADDROUT        equ addrout-contrl
               end
