; ----------------------------------------------------------------------------
; - Bernd HueÅbenett (RxT) 02.06.1995 Obertshausen                            -
; -                                                                          -
; - Dies ist ein Testprogramm fÅuer die Video-Initialisierungsroutinen von    -
; - FATAL DESIGN. Wenn alles klappt werde ich in Zukunft nicht mehr die      -
; - (X)BIOS-Routinen verwenden sondern nur noch die Hardware-Register direkt.-
; -                                                                          -
; - 02.06.1995 : Das mit den Hardware-Registern funktioniert.                -
; - 05.06.1995 : Coper-Effekt (schwabeliges Bild) durch manipulation des     -
;                Line-Offset-Registers innerhalb eines HBI.                  -
; ----------------------------------------------------------------------------

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

vbi:            move.l  D0,-(SP)
                move.b  #0,tbcr
                move.w  raster_index,D0
                addq.w  #2,D0
                cmp.w   #22,D0          ; 10 Worte + 2
                bne.s   vbi_go_on
                clr.w   D0
vbi_go_on:      move.w  D0,raster_index
                move.w  D0,raster_work
                move.b  zeilen,tbdr     ; alle ... Zeilen ein HBI
                move.b  #8,tbcr
                move.l  (SP)+,D0
oldvbi:         jmp     $FFFFFFFe

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
                DC.L 320*100*16/8+256 * GÇnÇral
                DC.W 0,320,0,$0100
                DC.W 0          * Flag Ordre

                DC.W 254,203,39,46,143,216,0,0 * RVB

                DC.W 625,613,47,127,527,619
                DC.W $0181,%1   * Double Ligne

Videl_320_200_True:
                DC.L 320*200*16/8+256 * GÇnÇral
                DC.W 0,320,0,$0100
                DC.W 0          * Flag Ordre

                DC.W 254,203,39,46,143,216,0,0 * RVB
                DC.W 625,613,47,127,527,619
                DC.W $0181,%0

                DC.W 198,150,15,682,139,150,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%101

Videl_320_400_True:
                DC.L 320*200*16/8+256 * GÇnÇral
                DC.W 0,320,0,$0100
                DC.W 0          * Flag Ordre

                DC.W 254,203,39,46,143,216,0,0 * RVB
                DC.W 624,613,47,126,526,619
                DC.W $0181,%10

                DC.W 198,150,15,682,139,150,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%101

Videl_640_200_True:
                DC.L 640*200*16/8+256 * GÇnÇral
                DC.W 0,640,0,$0100
                DC.W 0          * Flag Ordre

                DC.W 510,409,80,113,290,434,0,0 * RVB
                DC.W 625,613,47,127,527,619
                DC.W $0181,%100

Videl_640_400_True:
                DC.L 640*400*16/8+256 * GÇnÇral
                DC.W 0,640,0,$0100
                DC.W 0          * Flag Ordre

                DC.W 510,409,80,113,290,434,0,0 * RVB
                DC.W 624,613,47,126,526,619
                DC.W $0181,%110

Videl_384_128_True:
                DC.L 384*128*16/8+256 * GÇnÇral
                DC.W 0,384,0,$0100
                DC.W 0          * Flag Ordre

                DC.W 254,203,39,14,175,216,0,0 * RVB
                DC.W 625,613,47,71,583,619
                DC.W $0181,%1   * Double Ligne

Videl_768_240_True:
                DC.L 768*240*16/8+256 * GÇnÇral
                DC.W 0,768,0,$0100
                DC.W 0          * Flag Ordre

                DC.W 510,409,80,49,354,434,0,0 * RVB
                DC.W 625,613,47,87,567,619
                DC.W $0181,%100

Videl_768_256_True:
                DC.L 768*256*16/8+256 * GÇnÇral
                DC.W 0,768,0,$0100
                DC.W 0          * Flag Ordre

                DC.W 510,409,80,49,354,434,0,0 * RVB
                DC.W 625,613,47,71,583,619
                DC.W $0181,%100

Videl_768_480_True:
                DC.L 768*480*16/8+256 * GÇnÇral
                DC.W 0,768,0,$0100
                DC.W 0          * Flag Ordre

                DC.W 510,409,80,49,354,434,0,0 * RVB
                DC.W 624,613,47,86,566,619
                DC.W $0181,%110

Videl_768_512_True:
                DC.L 768*512*16/8+256 * GÇnÇral
                DC.W 0,768,0,$0100
                DC.W 0          * Flag Ordre

                DC.W 510,409,80,49,354,434,0,0 * RVB
                DC.W 624,613,47,70,582,619
                DC.W $0181,%110

Videl_384_240_True:
                DC.L 384*240*16/8+256 * GÇnÇral
                DC.W 0,384,0,$0100
                DC.W 0          * Flag Ordre

                DC.W 254,203,39,14,175,216,0,0 * RVB
                DC.W 625,613,47,87,567,619
                DC.W $0181,%0

                DC.W 240,160,0,714,151,200,0,0 * VGA 52.11 Hz
                DC.W 1207,1300,0,163,1123,1203
                DC.W $0186,%101

Videl_384_256_True:
                DC.L 384*256*16/8+256 * GÇnÇral
                DC.W 0,384,0,$0100
                DC.W 0          * Flag Ordre

                DC.W 254,203,39,14,175,216,0,0 * RVB
                DC.W 625,613,47,71,583,619
                DC.W $0181,%0

                DC.W 240,160,0,714,151,200,0,0 * VGA 52.11 Hz
                DC.W 1207,1300,0,131,1155,1203
                DC.W $0186,%101

Videl_384_480_True:
                DC.L 384*480*16/8+256 * GÇnÇral
                DC.W 0,384,0,$0100
                DC.W 0          * Flag Ordre

                DC.W 254,203,39,14,175,216,0,0 * RVB
                DC.W 625,613,47,86,566,619
                DC.W $0181,%10

                DC.W 240,160,0,714,151,200,0,0 * VGA 50.2 Hz
                DC.W 1257,1300,0,163,1123,1253
                DC.W $0186,%100

Videl_384_512_True:
                DC.L 384*512*16/8+256 * GÇnÇral
                DC.W 0,384,0,$0100
                DC.W 0          * Flag Ordre

                DC.W 254,203,39,14,175,216,0,0 * RVB
                DC.W 625,613,47,70,582,619
                DC.W $0181,%10

                DC.W 240,160,0,714,151,200,0,0 * VGA 50.2 Hz
                DC.W 1257,1300,0,131,1155,1253
                DC.W $0186,%100

*************************************************
*                                               *
* LIBRAIRIE DE RESOLUTION EN MODE 2 COULEURS    *
*                                               *
*************************************************

Videl_640_200_2:
                DC.L 640*200/8+256 * GÇnÇral
                DC.W 0,40,0,$0400
                DC.W 0          * Flag Ordre

                DC.W 510,409,80,1007,160,434,0,0 * RVB
                DC.W 625,613,47,127,527,619
                DC.W $0181,%100

                DC.W 198,141,21,627,80,150,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%1001


Videl_640_400_2:
                DC.L 640*400/8+256 * GÇnÇral
                DC.W 0,40,0,$0400
                DC.W 0          * Flag Ordre

                DC.W 510,409,80,1007,160,434,0,0 * RVB
                DC.W 624,613,47,126,526,619
                DC.W $0181,%110

                DC.W 198,141,21,627,80,150,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%1001

Videl_768_256_2:
                DC.L 768*256/8+256 * GÇnÇral
                DC.W 0,48,0,$0400
                DC.W 0          * Flag Ordre

                DC.W 510,409,80,943,224,434,0,0 * RVB
                DC.W 625,613,47,71,583,619
                DC.W $0181,%100


*************************************************
*                                               *
* LIBRAIRIE DE RESOLUTION EN MODE 4 COULEURS    *
*                                               *
*************************************************

Videl_320_200_4:
                DC.L 320*200*2/8+256 * GÇnÇral
                DC.W 0,40,1,$00
                DC.W -1         * Flag Ordre

                DC.W 62,48,8,569,18,52,0,0 * RVB
                DC.W 625,613,47,127,527,619
                DC.W $0181,%0

                DC.W 23,18,1,522,9,17,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%101

Videl_320_400_4:
                DC.L 320*400*2/8+256 * GÇnÇral
                DC.W 0,40,1,$00
                DC.W -1         * Flag Ordre

                DC.W 62,48,8,569,18,52,0,0 * RVB
                DC.W 624,613,47,126,526,619
                DC.W $0181,%10

                DC.W 23,18,1,522,9,17,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%101

Videl_640_200_4:
                DC.L 640*200*2/8+256 * GÇnÇral
                DC.W 0,80,1,$00
                DC.W -1         * Flag Ordre

                DC.W 62,48,8,2,32,52,0,0 * RVB
                DC.W 625,613,47,127,527,619
                DC.W $0181,%100

                DC.W 23,18,1,526,13,17,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%1001

Videl_640_400_4:
                DC.L 640*400*2/8+256 * GÇnÇral
                DC.W 0,80,1,$00
                DC.W -1         * Flag Ordre

                DC.W 62,48,8,2,32,52,0,0 * RVB
                DC.W 624,613,47,126,526,619
                DC.W $0181,%110

                DC.W 23,18,1,526,13,17,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%1001

Videl_384_256_4:
                DC.L 384*256*2/8+256 * GÇnÇral
                DC.W 0,48,1,$00
                DC.W -1         * Flag Ordre

                DC.W 62,48,8,562,27,52,0,0 * RVB
                DC.W 625,613,47,71,583,619
                DC.W $0181,%0

Videl_768_256_4:
                DC.L 768*256*2/8+256 * GÇnÇral
                DC.W 0,96,1,$00
                DC.W -1         * Flag Ordre

                DC.W 62,48,8,567,32,52,0,0 * RVB
                DC.W 625,613,47,71,583,619
                DC.W $0181,%100

*************************************************
*                                               *
* LIBRAIRIE DE RESOLUTION EN MODE 16 COULEURS   *
*                                               *
*************************************************

Videl_320_200_16:
                DC.L 320*200*4/8+256 * GÇnÇral
                DC.W 0,80,0,$00
                DC.W 0          * Flag Ordre

                DC.W 254,203,39,12,109,216,0,0 * RVB
                DC.W 625,613,47,127,527,619
                DC.W $0181,%0

                DC.W 198,141,21,650,107,150,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%101

Videl_320_400_16:
                DC.L 320*400*4/8+256 * GÇnÇral
                DC.W 0,80,0,$00
                DC.W 0          * Flag Ordre

                DC.W 254,203,39,12,109,216,0,0 * RVB
                DC.W 624,613,47,126,526,619
                DC.W $0181,%10

                DC.W 198,141,21,650,107,150,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%101

Videl_640_200_16:
                DC.L 640*200*4/8+256 * GÇnÇral
                DC.W 0,160,0,$00
                DC.W 0          * Flag Ordre

                DC.W 510,409,80,77,254,434,0,0 * RVB
                DC.W 625,613,47,127,527,619
                DC.W $0181,%100

                DC.W 198,141,21,675,124,150,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%1001

Videl_640_400_16:
                DC.L 640*400*4/8+256 * GÇnÇral
                DC.W 0,160,0,$00
                DC.W 0          * Flag Ordre

                DC.W 510,409,80,77,254,434,0,0 * RVB
                DC.W 624,613,47,126,526,619
                DC.W $0181,%110

                DC.W 198,141,21,675,124,150,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%1001

Videl_384_256_16:
                DC.L 384*256*4/8+256 * GÇnÇral
                DC.W 0,96,0,$00
                DC.W 0          * Flag Ordre

                DC.W 254,203,39,748,141,216,0,0 * RVB
                DC.W 625,613,47,71,583,619
                DC.W $0181,%0

Videl_768_256_16:
                DC.L 768*256*4/8+256 * GÇnÇral
                DC.W 0,192,0,$00
                DC.W 0          * Flag Ordre

                DC.W 510,409,80,13,318,434,0,0 * RVB
                DC.W 625,613,47,71,583,619
                DC.W $0181,%100

*************************************************
*                                               *
* LIBRAIRIE DE RESOLUTION EN MODE 256 COULEURS  *
*                                               *
*************************************************

Videl_320_200_256:
                DC.L 320*200+256 * GÇnÇral
                DC.W 0,160,0,$10
                DC.W 0          * Flag Ordre

                DC.W 254,203,39,28,125,216,0,0 * RVB
                DC.W 625,613,47,127,527,619
                DC.W $0181,%0

                DC.W 198,141,21,666,123,150,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%101

Videl_320_400_256:
                DC.L 320*400+256 * GÇnÇral
                DC.W 0,160,0,$10
                DC.W 0          * Flag Ordre

                DC.W 254,203,39,28,125,216,0,0 * RVB
                DC.W 624,613,47,126,526,619
                DC.W $0181,%10

                DC.W 198,141,21,666,123,150,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%101

Videl_640_200_256:
                DC.L 640*200+256 * GÇnÇral
                DC.W 0,320,0,$10
                DC.W 0          * Flag Ordre

                DC.W 510,409,80,93,270,434,0,0 * RVB
                DC.W 625,613,47,127,527,619
                DC.W $0181,%100

                DC.W 198,141,21,683,132,150,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%1001

Videl_640_400_256:
                DC.L 640*400+256 * GÇnÇral
                DC.W 0,320,0,$10
                DC.W 0          * Flag Ordre

                DC.W 510,409,80,93,270,434,0,0 * RVB
                DC.W 624,613,47,126,526,619
                DC.W $0181,%110

                DC.W 198,141,21,683,132,150,0,0 * VGA 47 Hz
                DC.W 1337,1300,100,315,1115,1333
                DC.W $0186,%1001

Videl_384_256_256:
                DC.L 384*256+256 * GÇnÇral
                DC.W 0,192,0,$10
                DC.W 0          * Flag Ordre

                DC.W 254,203,39,764,157,216,0,0 * RVB
                DC.W 625,613,47,71,583,619
                DC.W $0181,%0

Videl_768_256_256:
                DC.L 768*256+256 * GÇnÇral
                DC.W 0,384,0,$10
                DC.W 0          * Flag Ordre

                DC.W 510,409,80,29,334,434,0,0 * RVB
                DC.W 625,613,47,71,583,619
                DC.W $0181,%100
                EVEN
picture:        Incbin 'VOX16.TGA'
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
                DS.B 256
bild:           DS.L 38400
                DS.L 38400
                DS.L 38400
                END
