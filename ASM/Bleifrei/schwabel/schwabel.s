; ----------------------------------------------------------------------------
; - (RxT) 02.06.1995                                                         -
; -                                                                          -
; - 02.06.1995 : Das mit den Hardware-Registern funktioniert.                -
; - 05.06.1995 : Coper-Effekt (schwabeliges Bild) durch manipulation des     -
; -              Line-Offset-Registers innerhalb eines HBI.                  -
; - 20.12.1995 : Die 96K-MOD Routine von Bitmaster arbeitet einwandfrei.     -
; -              Sie benutzt nur den VBI. Die Module duerfen nicht grîûer    -
; -              als 96 KByte sein.                                          -
; ----------------------------------------------------------------------------

DspModInit      EQU 28
DspModOff       EQU 32
DspModPlayerOn  EQU 36
DspModPlayerOff EQU 40
DspModPlayMusic EQU 44
DspModPlayTime  EQU 48
DspModModType   EQU 52
DspModFx        EQU 56
not_used        EQU 60
DspModFlags     EQU 61
DspModSurroundDelay EQU 62
DspModDspTracks EQU 64
DspModPlayInfos EQU 66
DspModSampleSets EQU 70

cnecin          EQU 8
logbase         EQU 3
super           EQU 32
vsync           EQU 37

hbivec          EQU $0120       ; Horizontal-Blanking-Interrupt-Vector
vbivec          EQU $70         ; Vertical-Blanking-Interrupt-Vector
mkbvec          EQU $0118       ; Mouse/Keyboard-Interrupt-Vector
iera            EQU $FFFFFA07   ; Interrupt-Enable-Register A
ierb            EQU $FFFFFA09   ; interrupt-Enable-Register B
isra            EQU $FFFFFA0F   ; Interrupt-Service-Register A
imra            EQU $FFFFFA13   ; Interrupt-Mask-Register A
tbcr            EQU $FFFFFA1B   ; Timer B Control-Register
tbdr            EQU $FFFFFA21   ; Timer B Data-Register

vbaselow        EQU $FFFF820D
vbasemid        EQU $FFFF8203
vbasehigh       EQU $FFFF8201
vcountlow       EQU $FFFF8209
vcountmid       EQU $FFFF8207
vcounthigh      EQU $FFFF8205
linewid         EQU $FFFF820F
hscroll         EQU $FFFF8265

keyctl          EQU $FFFFFC00
keybd           EQU $FFFFFC02

DspHost         EQU $FFFFA200
HostIntVec      EQU $03FC

PCookies        EQU $05A0


start:          DC.W $A00A

                pea     0
                move.w  #super,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,ssp

                move.w  #2,-(SP)        ; Bildschirmadressen holen
                trap    #14
                addq.l  #2,SP
                move.l  D0,oldphys      ; Bildschirmadresse in oldphys speichern
                move.w  #3,-(SP)
                trap    #14
                addq.l  #2,SP
                move.l  D0,oldlog

                bsr     init            ; MOD-Player initialisieren

; Gibt die Versionsnummer aus
                move.l  ver_ptr,-(SP)   ; Diese
                move.w  #9,-(SP)        ; Funktion
                trap    #1              ; auf keinen Fall lîschen
                addq.l  #6,SP           ; Funktioniert sonst nicht

                lea     mod1,A0
play_mod:       lea     voltab4,A1
                movea.l A0,A6
                jsr     player+DspModPlayerOn ;Start Player

                move.l  #bild+256,D0    ; Neue Video Adresse
                and.l   #$FFFFFF00,D0
                move.l  D0,buffscr

                move.b  D0,$FFFF820D
                lsr.l   #8,D0
                move.b  D0,$FFFF8203
                lsr.l   #8,D0
                move.b  D0,$FFFF8201

                bsr     Save_System

                lea     Videl_320_200_True,A0
                bsr     Set_Res

                move.w  #320,$FFFF820E  ; Offset bis zur nÑchsten Zeile

                movea.l buffscr,A0
                lea     picture,A1
                move.w  #200,D1
pic_copy:       move.w  #159,D0
picture_copy:   move.l  (A1),640(A0)
                move.l  (A1)+,(A0)+
                dbra    D0,picture_copy
                adda.l  #640,A0
                dbra    D1,pic_copy

                lea     raster_tabelle1,A0
                move.w  #49,D0
rast_tab_gen1:  move.w  #320,(A0)+
                move.w  #321,(A0)+
                move.w  #322,(A0)+
                move.w  #322,(A0)+
                move.w  #321,(A0)+
                move.w  #320,(A0)+
                move.w  #319,(A0)+
                move.w  #318,(A0)+
                move.w  #318,(A0)+
                move.w  #319,(A0)+
                dbra    D0,rast_tab_gen1
                move.w  #0,raster_index

                move.b  #1,zeilen
                move.w  #0,raster_index ; Index auf Null
                move.w  #0,raster_work
                clr.l   $FFFF9800.w     ; Rahmenfarbe auf Schwarz

; alles fÅr HBI's vorbereiten....
                move.l  vbivec,oldvbi+2
                move.l  #hbi,hbivec
                move.l  #vbi,vbivec
                andi.b  #$DF,ierb
                ori.b   #1,iera
                ori.b   #1,imra
; ....warten....
                move.w  #8,-(SP)
                trap    #1
                addq.l  #2,SP
; ...und tschÅû.
                jsr     player+DspModPlayerOff ;Stop
                clr.b   $FFFF8901.w     ; DMA-Stoppen
                jsr     player+DspModOff

                move.l  oldvbi+2,vbivec
                andi.b  #$FE,iera
                ori.b   #$20,ierb
raus:           bsr     restore_system

                move.l  oldlog,D0
                move.b  D0,$FFFF820D
                lsr.l   #8,D0
                move.b  D0,$FFFF8203
                lsr.l   #8,D0
                move.b  D0,$FFFF8201

                move.l  ssp,-(SP)
                move.w  #super,-(SP)
                trap    #1
                addq.l  #6,SP

                clr.w   -(SP)
                trap    #1

; ------------------------------------------
; ----- A U F   V S Y N C   W A R T E N ----
; ------------------------------------------

wait_vsync:     move.l  D0,-(SP)
                move.l  $0462,D0
wait_wait_x:    cmp.l   $0462,D0
                beq.s   wait_wait_x
                move.l  (SP)+,D0
                rts

; -------------------------------------------------------
; - V E R T I C A L  B L A N K I N G  I N T E R R U P T -
; -------------------------------------------------------

vbi:            movem.l D0-A6,-(SP)
                move.b  #0,tbcr
                jsr     player+44
                move.w  raster_index,D0
                addq.w  #2,D0
                cmp.w   #22,D0          ; 10 Worte + 2
                bne.s   vbi_go_on
                clr.w   D0
vbi_go_on:      move.w  D0,raster_index
                move.w  D0,raster_work
                move.b  zeilen,tbdr     ; alle ... Zeilen ein HBI
                move.b  #8,tbcr
                movem.l (SP)+,D0-A6
oldvbi:         jmp     $FFFFFFFF

; -----------------------------------------------------------
; - H O R I Z O N T A L  B L A N K I N G  I N T E R R U P T -
; -----------------------------------------------------------

; Horizontal Blanking Interrupt
hbi:            movem.l D0/A0-A1,-(SP)
                lea     raster_tabelle1,A0
                move.w  raster_work,D0
                move.w  0(A0,D0.w),$FFFF820E ; Zeilen-Offset-Register
                addi.w  #2,raster_work
                andi.b  #$FE,isra
                movem.l (SP)+,D0/A0-A1
                rte

; ---------------------------------------------
; ------  M O D - P L A Y E R   I N I T -------
; ---------------------------------------------

init:           jsr     player+DspModInit ;install Player
                move.l  A0,ver_ptr

                move.w  #$200B,$FFFF8932.w ;DSP-Out-> DAC & DMA-In
                clr.b   $FFFF8900.w     ;keine DMA-Interrupts
                clr.b   $FFFF8936.w     ;record 1 Track
                move.b  #$40,$FFFF8921.w ;16 Bit

                move.b  #$80,$FFFF8901.w ;select Record-Frame-Register
                move.l  #dma_buffer,D0
                move.l  D0,D1
                move.b  D1,$FFFF8907.w  ;Basis Low
                lsr.l   #8,D1
                move.b  D1,$FFFF8905.w  ;Basis Mid
                lsr.l   #8,D1
                move.b  D1,$FFFF8903.w  ;Basis High
                add.l   #8000,D0
                move.l  D0,D1
                move.b  D1,$FFFF8913.w  ;End Low
                lsr.l   #8,D1
                move.b  D1,$FFFF8911.w  ;End Mid
                lsr.l   #8,D1
                move.b  D1,$FFFF890F.w  ;End High

                move.b  #$B0,$FFFF8901.w ;repeated record

;                move.l  $70.w,old_vbl
;                move.l  #vbl,$70.w
                rts

; ---------------------------------------------
; -------- S E T  V I D E O  M O D E ----------
; ---------------------------------------------
; Parameter:
;             A0.L : Adresse der Betriebsart
;                      (aus der Tabelle)
; ---------------------------------------------

Set_Res:        move.b  #2,$FFFF820A.w  ; Horloge Interne
                clr.b   $FFFF8265.w     ; DÇcalage Pixel Nul
                addq.l  #4,A0
                move.w  (A0)+,$FFFF820E.w ; Offset bis zur nÑchsten Zeile (Words)
                move.w  (A0)+,$FFFF8210.w ; LÑnge der sichtbaren Zeile (Words)
                move.w  (A0)+,D0        ; RÇsolution ST
                move.w  (A0)+,D1        ; RÇsolution FALCON

                move.w  D1,$FFFF8266.w  ; RÇsolution FALCON
                tst.w   (A0)+
                beq.s   FalconRez
                move.b  D0,$FFFF8260.w  ; RÇsolution ST
                move.w  -8(A0),$FFFF8210.w ; Largeur d'une ligne en mots
FalconRez:
;                btst    #7,$FFFF8006.w  ; Ecran VGA ?
;                beq.s   R_Ok            ; Si non,saut...
;                adda.w  #16*2,A0
R_Ok:           move.w  (A0)+,$FFFF8282.w ; HHT-Synchro
                move.w  (A0)+,$FFFF8284.w ; Fin du dÇcodage de la ligne
                move.w  (A0)+,$FFFF8286.w ; DÇbut du dÇcodage de la ligne
                move.w  (A0)+,$FFFF8288.w ; Overscan links
                move.w  (A0)+,$FFFF828A.w ; Overscan rechts
                move.w  (A0)+,$FFFF828C.w ; HSS-Synchro
                move.w  (A0)+,$FFFF828E.w ; HFS
                move.w  (A0)+,$FFFF8290.w ; HEE
                move.w  (A0)+,$FFFF82A2.w ; VFT-Synchro
                move.w  (A0)+,$FFFF82A4.w ; Fin du dÇcodage de l'image
                move.w  (A0)+,$FFFF82A6.w ; DÇbut du dÇcodage de l'image
                move.w  (A0)+,$FFFF82A8.w ; Overscan oben
                move.w  (A0)+,$FFFF82AA.w ; Overscan unten
                move.w  (A0)+,$FFFF82AC.w ; VSS-Synchro
                move.w  (A0)+,$FFFF82C0.w ; Indique rÇsolution FALCON
                move.w  (A0),$FFFF82C2.w ; Informations rÇsolution
                rts

; ---------------------------------------------
; ----------  V I D E O  S A V E --------------
; ---------------------------------------------

Save_System:    lea     Old_System,A0
                move.b  $FFFF8007.w,(A0)+ ; Configuration 68030
                move.b  $FFFF820A.w,(A0)+ ; Synchronisation vidÇo
                move.w  $FFFF820E.w,(A0)+ ; Offset pour prochaine ligne
                move.w  $FFFF8210.w,(A0)+ ; Largeur d'une ligne en mots
                move.b  $FFFF8260.w,(A0)+ ; RÇsolution ST
                move.b  $FFFF8265.w,(A0)+ ; DÇcalage Pixel
                move.w  $FFFF8266.w,(A0)+ ; RÇsolution FALCON
                move.w  $FFFF8282.w,(A0)+ ; HHT-Synchro
                move.w  $FFFF8284.w,(A0)+ ; Fin du dÇcodage de la ligne
                move.w  $FFFF8286.w,(A0)+ ; DÇbut du dÇcodage de la ligne
                move.w  $FFFF8288.w,(A0)+ ; Overscan gauche
                move.w  $FFFF828A.w,(A0)+ ; Overscan droit
                move.w  $FFFF828C.w,(A0)+ ; HSS-Synchro
                move.w  $FFFF828E.w,(A0)+ ; HFS
                move.w  $FFFF8290.w,(A0)+ ; HEE
                move.w  $FFFF82A2.w,(A0)+ ; VFT-Synchro
                move.w  $FFFF82A4.w,(A0)+ ; Fin du dÇcodage de l'image
                move.w  $FFFF82A6.w,(A0)+ ; DÇbut du dÇcodage de l'image
                move.w  $FFFF82A8.w,(A0)+ ; Overscan haut
                move.w  $FFFF82AA.w,(A0)+ ; Overscan bas
                move.w  $FFFF82AC.w,(A0)+ ; VSS-Synchro
                move.w  $FFFF82C0.w,(A0)+ ; Reconnaissance ST/FALCON
                move.w  $FFFF82C2.w,(A0)+ ; Informations rÇsolution

                lea     $FFFF8240.w,A1  ; Palette ST
                moveq   #8-1,D0         ; 8 longs...
Save_ST_Palette:
                move.l  (A1)+,(A0)+     ; Sauve 2 couleurs
                dbra    D0,Save_ST_Palette ; Boucle les 16 mots !

                lea     $FFFF9800.w,A1  ; Palette FALCON
                move.w  #256-1,D0       ; 256 longs...
Save_FALCON_Palette:
                move.l  (A1)+,(A0)+     ; Sauve 1 couleur
                dbra    D0,Save_FALCON_Palette ; Boucle les 256 longs !
                rts

; --------------------------------------------
; ------  V I D E O   R E S T O R E ----------
; --------------------------------------------

restore_system: move    #$2700,SR       ; Interrupts sperren
                lea     Old_System,A0   ; Espace de sauvegarde
                move.b  (A0)+,$FFFF8007.w ; Configuration 68030
                move.b  (A0)+,$FFFF820A.w ; Video-Syncronisation
                move.w  (A0)+,$FFFF820E.w ; Offset pour prochaine ligne
                move.w  (A0)+,$FFFF8210.w ; Largeur d'une ligne en mots
                move.b  (A0)+,D0        ; RÇsolution ST
                move.b  (A0)+,$FFFF8265.w ; DÇcalage Pixel
                move.w  (A0)+,D1        ; RÇsolution FALCON
                move.w  (A0)+,$FFFF8282.w ; HHT-Synchro
                move.w  (A0)+,$FFFF8284.w ; Fin du dÇcodage de la ligne
                move.w  (A0)+,$FFFF8286.w ; DÇbut du dÇcodage de la ligne
                move.w  (A0)+,$FFFF8288.w ; Overscan gauche
                move.w  (A0)+,$FFFF828A.w ; Overscan droit
                move.w  (A0)+,$FFFF828C.w ; HSS-Synchro
                move.w  (A0)+,$FFFF828E.w ; HFS
                move.w  (A0)+,$FFFF8290.w ; HEE
                move.w  (A0)+,$FFFF82A2.w ; VFT-Synchro
                move.w  (A0)+,$FFFF82A4.w ; Fin du dÇcodage de l'image
                move.w  (A0)+,$FFFF82A6.w ; DÇbut du dÇcodage de l'image
                move.w  (A0)+,$FFFF82A8.w ; Overscan haut
                move.w  (A0)+,$FFFF82AA.w ; Overscan bas
                move.w  (A0)+,$FFFF82AC.w ; VSS-Synchro
                move.w  (A0)+,$FFFF82C0.w ; Reconnaissance ST/FALCON
                move.w  (A0)+,$FFFF82C2.w ; Informations rÇsolution
                move.w  D1,$FFFF8266.w  ; Fixe rÇsolution FALCON...
                btst    #0,$FFFF82C0.w  ; RÇsolution FALCON ?
                bne.s   Falcon_Rez      ; Si oui,saut !
                move.b  D0,$FFFF8260.w  ; Fixe rÇsolution ST...
Falcon_Rez:     lea     $FFFF8240.w,A1  ; ST-Farbpalette restaurieren
                moveq   #7,D0           ; 8 Langwîrter...
Rest_ST_Palette:
                move.l  (A0)+,(A1)+     ; immer 2 Farben auf einmal
                dbra    D0,Rest_ST_Palette

                lea     $FFFF9800.w,A1  ; FALCON-Farbpalette restaurieren
                move.w  #255,D0         ; 256 Langwîrter
Rest_FALCON_Palette:
                move.l  (A0)+,(A1)+     ; eine Farbe nach der anderen
                dbra    D0,Rest_FALCON_Palette
                move    #$2000,SR       ; Interrupts freigeben
                rts



                DATA
*************************************************
*                                               *
* LIBRAIRIE DE RESOLUTION EN MODE TRUE-COLOR    *
*                                               *
*************************************************
Videl_320_100_True:
                DC.L 320*100*16/8+256 ; GÇnÇral
                DC.W 0,320,0,$0100
                DC.W 0          ; Flag Ordre

                DC.W 254,203,39,46,143,216,0,0 ; RVB

                DC.W 625,613,47,127,527,619
                DC.W $0181,%1   ; Double Ligne

Videl_320_200_True:
                DC.L 320*200*16/8+256 ; GÇnÇral
                DC.W 0,320,0,$0100
                DC.W 0          ;  Flag Ordre

                DC.W 254,203,39,46,143,216,0,0 ; RVB
                DC.W 625,613,47,127,527,619
                DC.W $0181,%0

                DC.W 198,150,15,682,139,150,0,0 ; VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%101
                EVEN
picture:        IBYTES 'VOX16.TGA'
voltab4:        DC.W $7F00,$7F00,$7F00,$7F00
                DC.W 0,0,0,0

player:         IBYTES 'DSPMOD96.TCE'
mod1:           IBYTES 'SLEEP_WL.MOD'
                BSS
                EVEN
                DS.B 256
ssp:            DS.L 1
oldlog:         DS.L 1
oldphys:        DS.L 1
oldmode:        DS.L 1
Old_System:     DS.L 500        ; Buffer fÅr altes System
buffscr:        DS.L 1
zeilen:         DS.W 1
raster_index:   DS.W 1
raster_work:    DS.W 1
raster_tabelle1:DS.W 500
raster_tabelle2:DS.W 500
                EVEN
ver_ptr:        DS.L 1
dma_buffer:     DS.B 8000
                DS.B 256
bild:           DS.L 38400
                DS.L 38400
                DS.L 38400
                END
