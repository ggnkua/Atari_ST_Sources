; This file contains the intro and the extro of the demo.
; (C) Copyright 1995 by Jochen Knaus, AURA.

*****************************************************************************
*  Intro und Extro und andere Dinge, die im Demo vorkommen...               *
*****************************************************************************
WAIT_POEM     EQU       130+40            ; Anzahl VBLs ohne Gedicht.
WAIT_POEM_2   EQU       150               ; Anzahl VBLs zum Lesen.
INT_WAIT0     EQU       100               ; AURA-Logo auf dem Screen.
INT_WAIT1     EQU       100               ; Die vier Texte.
INT_WAIT2     EQU       15

INT_LOGOPAL   EQU       anim_buf+2000     ; Buffer fÅr Hintergrundpalette.
INT_TXT_PAL1  EQU       INT_LOGOPAL+128   ; Palette nur aus Hintergrund.
INT_TXT_PAL2  EQU       INT_TXT_PAL1+128
intro:        st        disable_sync      ; VBL ok, nur kein Screenhandling.

              movea.l   scr_lst_256,a0    ; Einen Bildschirm lîschen.
              lea       (640*480.l,a0),a1
              bsr.w     clr_mem

              bsr.w     vsync             ; Videohardware setzen.
              move.l    scr_lst_256,d0    ; Einen Screen nehmen.
              bsr.w     set_scr_adr
              bsr.w     switch_svga       ; 640*480 in 256 Farben Mode.

              lea       D_l_viii,a0       ; Gedicht einkopieren.
              movea.l   scr_lst_256,a1
              adda.l    #(240-70)*640+13*16,a1
              move.w    #150-1,d7
in_cpy_ged:   moveq     #13-1,d6
              movea.l   a1,a2
in_cpy_gedlp: move.w    (a0)+,(a2)
              lea       16(a2),a2
              dbra      d6,in_cpy_gedlp
              lea       640(a1),a1
              dbra      d7,in_cpy_ged

              lea       ged_pal(pc),a0    ; Gedicht einfaden...
              lea       $ffff9804.w,a1
              moveq     #1,d7
              bsr.w     fade_in_pal

              move.w    #WAIT_POEM,d7
              bsr.w     vsync_xx

              lea       $ffff9800.w,a0    ; Gedicht ausfaden...
              lea       $ffff9804.w,a1
              moveq     #1,d7
              bsr.w     fade_in_pal

              lea       $ffff9800.w,a0    ; Alle Farben auf Hintergrund.
              move.l    (a0)+,d0
              move.w    #254,d7
kalt_pal:     move.l    d0,(a0)+
              dbra      d7,kalt_pal

              move.l    scr_lst_256,a0    ; Das Gedicht lîschen.
              lea       (640*480.l,a0),a1
              bsr.w     clr_mem

              lea       D_intro_back,a0   ; Hintergrundbild decrunchen.
              movea.l   scr_lst_32k+4,a1
              bsr.w     ice_decrunch

              bsr.w     vsync             ; Schaltet Screen auf Introback um.
              bsr.w     hardsw_32k        ; (Die rosa Blumen im blauen Gewirr)
              move.l    scr_lst_32k+1*4,d0
              bsr.w     set_scr_adr

              movea.l   scr_lst_32k+1*4,a0      ; Doublebuffering vorbereiten.
              movea.l   scr_lst_32k+2*4,a1
              move.w    #(640*240)/16-1,d0
              bsr.w     cpy_mem16
              movea.l   scr_lst_32k+1*4,a0
              movea.l   scr_lst_32k+3*4,a1
              move.w    #(640*240)/16-1,d0
              bsr.w     cpy_mem16

              lea       D_auralogo,a0     ; "AURA"-Logopalette umrechnen.
              lea       INT_LOGOPAL,a1
              bsr.w     int_konv_pal

              lea       D_intro_1,VDI_PAL ; Textpalette 1 umrechnen.
              lea       INT_TXT_PAL1,a1
              bsr.w     int_konv_pal

              lea       D_intro_2,VDI_PAL ; Textpalette 2 umrechnen.
              lea       INT_TXT_PAL2,a1
              bsr.w     int_konv_pal

              lea       D_auralogo+16*6,a0      ; AURA-Logo in High-Colour.
              movea.l   scr_lst_32k,a1
              lea       INT_LOGOPAL,a2
              moveq     #13,d0            ; Breite = 13*16 = 208 Pixel
              moveq     #107,d1           ; Hîhe   = 107 Zeilen 
              bsr.w     in_planes_hc

              movea.l   scr_lst_32k,a0    ; AURA-Logo setzen.
              movea.l   scr_lst_32k+2*4,a1
              move.w    #208,d0
              move.w    #107,d1
              bsr.w     in_set_hc

              bsr.w     vsync
              move.l    scr_lst_32k+2*4,d0
              bsr.w     set_scr_adr       ; AURA-Logo steht nun auf'm Screen.

              move.w    #INT_WAIT0,d7
              bsr.w     vsync_xx

              lea       D_intro_1+16*6,a0 ; Texte (1) in HC umrechnen.
              movea.l   scr_lst_32k,a1
              lea       INT_TXT_PAL1,a2
              moveq     #20,d0            ; Breite = 320 Pixel
              move.w    #240,d1           ; Hîhe   = 240 Zeilen 
              bsr.w     in_planes_hc

              lea       D_intro_2+16*6,a0 ; Texte (2) in HC umrechnen.
              movea.l   scr_lst_32k+1*4,a1
              lea       INT_TXT_PAL2,a2
              moveq     #20,d0            ; Breite = 320 Pixel
              moveq     #64,d1            ; Hîhe   = 64 Zeilen  
              bsr.w     in_planes_hc

              move.l    scr_lst_32k+3*4,a0      ; Einen Screen mit Hintergrund.
              move.l    scr_lst_32k+4*4,a1
              move.w    #(640*240)/16-1,d0
              bsr.w     cpy_mem16
              movea.l   scr_lst_32k+1*4,a0      ; "E.X Illusion" setzen.
              movea.l   scr_lst_32k+4*4,a1
              lea       (640*100+80.l,a1),a1
              move.w    #250,d0
              move.w    #60,d1
              bsr.w     in_set_hc

              move.l    scr_lst_32k+4*4,d0      ; "E.X Illusion" sichtbar.
              bsr.w     set_scr_adr       

              lea       txt_offs(pc),a6   ; Textoffsets und Grîûen.
              moveq     #3-1,d7           ; Texte.
intro_txts:   move.w    d7,d0
              move.w    #INT_WAIT1,d7     ; Warten...
              bsr.w     vsync_xx
              move.w    d0,d7

              movea.l   scr_lst_32k+3*4,a0      ; Zuerst ganzen Screen lîschen.
              movea.l   scr_lst_32k+1*4,a1
              move.w    #(640*240)/16-1,d0
              bsr.w     cpy_mem16
              bsr.w     vsync
              move.l    scr_lst_32k+1*4,d0
              bsr.w     set_scr_adr

              movea.l   scr_lst_32k+1*4,a0
              movea.l   scr_lst_32k+4*4,a1
              move.w    #(640*240)/16-1,d0
              bsr.w     cpy_mem16

              move.w    d7,d0
              move.w    #INT_WAIT2,d7     ; Und dann noch etwas warten...
              bsr.w     vsync_xx
              move.w    d0,d7

              movem.l   (a6)+,d2-d3       ; Offset Sourcebild / Destbild.
              movem.w   (a6)+,d0-d1       ; Grîûen.
              movea.l   scr_lst_32k,a0    ; Sourcebase.
              movea.l   scr_lst_32k+4*4,a1
              adda.l    d2,a0             ; In Stellung.
              adda.l    d3,a1
              bsr.w     in_set_hc

              bsr.w     vsync             ; Setzt Screen mit neuem Text.
              move.l    scr_lst_32k+4*4,d0
              bsr.w     set_scr_adr

              dbra      d7,intro_txts

              move.w    #INT_WAIT1,d7     ; Purer Hintergrund zeigen.
              bsr.w     vsync_xx
              move.l    scr_lst_32k+1*4,d0
              bsr.w     set_scr_adr
              move.w    #INT_WAIT2,d7
              bsr.w     vsync_xx

              movea.l   scr_lst_32k,a0    ; Intro ausblenden.
              lea       (640*240.l,a0),a1
              bsr.w     clr_mem
              movea.l   scr_lst_32k,a0
              movea.l   scr_lst_32k+1*4,a1
              bsr.w     hc_show1
              st        disable_sync

              bsr.w     vsync             ; Auf 16 Farben gehen, damit das Um-
              bra.w     hw_switch_16      ; faden wirkt !

txt_offs:     DC.L      640*32*5,640*(240-48)
              DC.W      320,32

              DC.L      640*32*0,640*100
              DC.W      320,32

              DC.L      640*32*1,640*(240-3*32-10)
              DC.W      320,32*3

int_konv_pal: movem.l   d0-a6,-(sp)       ; Paletten der Logos, Texte... in
              pea       (a1)              ; High-Colour Palette umrechnen.
              movea.l   a0,a6
              movea.l   VDI_PAL,DEST_PAL
              moveq     #16,COLSTEPS
              bsr.w     VDI_XGA
              movea.l   a6,a0
              movea.l   (sp),a1
              bsr.w     konv_pal_tpi2

              movea.l   (sp)+,a0          ; Wenn auûer Farbe 0 noch eine der
              addq.l    #2,a0             ; Palette den Farbwert 0 hat, wird
              moveq     #14,d7            ; diese auf ganz dunkles grau gesetzt
chk_000:      tst.w     (a0)+             ; ,da sie sonst ebenfalls Maske wÑre.
              bne.s     notzerooo
              move.w    #%100000100001,-2(a0)
notzerooo:    dbra      d7,chk_000

              movem.l   (sp)+,d0-a6
              rts

ged_pal:      DC.L      $a0a000d0         ; Introgedichtsfarbe.

*****************************************************************************
*  DIES ist das Extro !!!                                                   *
*****************************************************************************
EXT_PAL1      EQU       anim_buf+512
EXT_PAL2      EQU       anim_buf+1024
EXT_PAL3      EQU       anim_buf+1536

EX_WAIT0      EQU       120               ; ~ Warten wenn Hintergrund steht.
EX_WAIT1      EQU       300               ; ~ bleiben die Gedichtsinfos stehen.
EX_WAIT2      EQU       180               ; ~ GeburtstabgswÅnsche davor.
EX_WAIT3      EQU       100               ; ~ GeburtstabgswÅnsche danach.
EX_WAIT4      EQU       375               ; ~ Schriftzug auf altem Hintergrund.
EX_WAIT5      EQU       400

extro:        st        disable_sync      ; Der Sync war noch an.

              lea       D_file_x0,a0      ; Alles auf eine Erscheinung eines
              movea.l   free_screen,a1    ; High-Colourbildes vorbereiten.
              bsr.w     ice_decrunch
              movea.l   scr_lst_32k,a0
              lea       (640*240.l,a0),a1
              bsr.w     clr_mem

              bsr.w     vsync

              move.l    scr_lst_32k,d0    ; Die Erscheinung auftreten lassen.
              move.l    d0,a1
              bsr.w     set_scr_adr
              bsr.w     hardsw_32k

              movea.l   free_screen,a0    ; Das erste Bild einblenden.
              bsr.w     hc_show1
              st        disable_sync

              lea       D_extro,a0        ; Farbpaletten der Texte wandeln.
              lea       EXT_PAL1,a1
              bsr.w     int_konv_pal
              lea       D_extro2,a0
              lea       EXT_PAL2,a1
              bsr.w     int_konv_pal
              lea       D_extro3,a0
              lea       EXT_PAL3,a1
              bsr.w     int_konv_pal

              moveq     #20,d0            ; Alle Texte in High-Colour wandeln.
              move.w    #5*32-1,d1
              lea       D_extro+16*6,a0
              movea.l   scr_lst_32k+1*4,a1
              lea       EXT_PAL1,a2
              bsr.w     in_planes_hc
              moveq     #20,d0            ; Die GeburtstagswÅnsche.
              move.w    #199,d1
              lea       D_extro2+16*6,a0
              movea.l   scr_lst_32k+4*4,a1
              lea       EXT_PAL2,a2
              bsr.w     in_planes_hc
              moveq     #20,d0            ; Die Gedichtcredits.
              move.w    #199,d1
              lea       D_extro3+16*6,a0
              movea.l   scr_lst_32k+5*4,a1
              lea       EXT_PAL3,a2
              bsr.w     in_planes_hc

              movea.l   scr_lst_32k,a0    ; Gedichtscredits zeigen.
              movea.l   scr_lst_32k+2*4,a1
              move.w    #(640*240)/16-1,d0
              bsr.w     cpy_mem16
              move.w    #EX_WAIT0,d7
              movea.l   scr_lst_32k+5*4,a0
              movea.l   scr_lst_32k+2*4,a1
              adda.l    #640*15,a1
              move.w    #300,d0
              move.w    #180,d1
              bsr.w     in_set_hc
              movea.l   scr_lst_32k+2*4,a0
              movea.l   scr_lst_32k,a1
              bsr.w     hc_show1
              st        disable_sync
              move.w    #EX_WAIT1,d7
              bsr.w     vsync_xx
              movea.l   free_screen,a0
              movea.l   scr_lst_32k,a1
              bsr.w     hc_show1
              st        disable_sync
              movea.l   scr_lst_32k,a0
              movea.l   scr_lst_32k+2*4,a1
              move.w    #(640*240)/16-1,d0
              bsr.w     cpy_mem16

              move.w    #EX_WAIT2,d7
              bsr.w     vsync_xx
              movea.l   scr_lst_32k+4*4,a0      ; GeburtstagsglÅckwÅnsche.
              movea.l   scr_lst_32k+2*4,a1
              adda.l    #-640*3+240,a1
              move.w    #224,d0
              moveq     #31,d1
              bsr.w     in_set_hc
              bsr.w     vsync
              move.l    scr_lst_32k+2*4,d0
              bsr.w     set_scr_adr
              move.w    #EX_WAIT3,d7
              bsr.w     vsync_xx
              move.l    scr_lst_32k,d0
              bsr.w     set_scr_adr
              movea.l   scr_lst_32k,a0
              movea.l   scr_lst_32k+2*4,a1
              move.w    #(640*240)/16-1,d0
              bsr.w     cpy_mem16

              lea       D_file_x10,a0     ; Hintergrund fÅr Copyrightmessage.
              movea.l   scr_lst_32k+3*4,a1
              bsr.w     ice_decrunch

              movea.l   scr_lst_32k+3*4,a0
              movea.l   scr_lst_32k+5*4,a1
              move.l    #(640*240)/16-1,d0
              bsr.w     cpy_mem16

              movem.l   scr_lst_32k+1*4,a0-a1   ; "X-Moon is shining" Message
              adda.l    #640*180+190,a1         ; auf beide HintergrÅnde
              move.w    #224,d0                 ; schmeiûen !
              moveq     #31,d1
              bsr.w     in_set_hc
              movea.l   scr_lst_32k+3*4,a1
              adda.l    #640*180+190,a1
              bsr.w     in_set_hc
              bsr.w     vsync
              move.l    scr_lst_32k+2*4,d0
              bsr.w     set_scr_adr
              move.w    #EX_WAIT4,d7
              bsr.w     vsync_xx
              movea.l   scr_lst_32k+3*4,a0      ; Zweiter Hintergrund zeigen.
              movea.l   scr_lst_32k+2*4,a1
              bsr.w     hc_show1
              st        disable_sync
              move.w    #EX_WAIT5,d7      ; Noch etwas stehenlassen.
              bsr.w     vsync_xx
              move.l    scr_lst_32k+5*4,d0
              bsr.w     set_scr_adr

              movea.l   scr_lst_32k+5*4,a0
              movea.l   scr_lst_32k+3*4,a1
              move.l    #(640*240)/16-1,d0
              bsr.w     cpy_mem16

        IFEQ  (INST_DSP_MOD-an)           ; Endtune starten.
              movem.l   d0-a6,-(sp)

              lea       module,a0         ; Tune laden.
              moveq     #RELOAD_MUSIC,d0
              bsr.w     new_ani_blk

              move.w    #$2700,sr

              lea       module,a0         ; Das Endmod mit 50KHz abzocken.
              lea       ext_tim_a(pc),a1  ; (Und das mit dem "neueren" Player).
              moveq     #MOD_PRESCALE2,d0
              moveq     #-1,d1
              moveq     #50,d2            ; 50Hz.
              moveq     #-1,d3
              bsr.l     D_paula
              move.w    #START_VOL,D_paula+16   ; LaustÑrke relativ zivil.

              move.l    #music,$70.w
              stop      #$2300

              movem.l   (sp)+,d0-a6
        ENDIF

              movea.l   scr_lst_32k+1*4,a0      ; Noch die Copyrightmessage
              movea.l   scr_lst_32k+3*4,a1      ; zeigen.
              adda.l    #640*64,a0
              adda.l    #640*72,a1
              move.w    #256,d0
              moveq     #95,d1
              bsr.w     in_set_hc
              bsr.w     vsync
              move.l    scr_lst_32k+3*4,d0
              bsr.w     set_scr_adr

endless_loop: bra.s     endless_loop      ; Nur der Reset kann uns wecken...

music:        movem.l   d0-a6,-(sp)       ; Extro-VBL.
              bsr.l     (D_paula+4)
              movem.l   (sp)+,d0-a6
              addq.w    #1,vbl_counter
              rte

ext_tim_a:    bsr.l     (D_paula+8)       ; Extro-Timer A.
              rte

*****************************************************************************
* Setzt High-Coloursprite.                                                  *
* PARAMETER:  d0.w  -  Breite Pixeln.                                       *
*             d1.w  -  Hîhe in Pixeln.                                      *
*             a0.l  -  Sourcebild (320*240)                                 *
*             a1.l  -  Zielbild (320*240)                                   *
*****************************************************************************
SHDLINE       EQU       5                 ; Entfernung des Schattenpunktes.
SHADOW        EQU       9                 ; Dif. Schatten->Normal (16~50%)
in_set_hc:    movem.l   d0-a6,-(sp)

              subq.w    #1,d0
              trapmi.w  #-2000
              subq.w    #1,d1
              trapmi.w  #-2001

              moveq     #11,d6            ; Shiftwert fÅr Rot.
              moveq     #5,d7             ; Shiftwert fÅr GrÅn.

inset_zeile:  move.w    d0,d2
              movea.l   a0,a2
              movea.l   a1,a3
inset_pixel:  addq.l    #2,a3
              move.w    (a2)+,d3          ; Pixel gesetzt ?
              beq.w     noset_pix
              move.w    d3,-2(a3)

              lea       (640+2)*SHDLINE-2(a3),a4
              move.w    (a4),d3           ; Schattenwurf:
              move.w    d3,d4             ; Verkleinern der RGB-Komponenten mit
              move.w    d3,d5             ; einem konstanten Wert.

              lsr.w     d6,d3
              lsr.w     d7,d4
              andi.w    #$1f,d3
              andi.w    #$3f,d4
              andi.w    #$1f,d5

              subi.b    #SHADOW,d3        ; Rot-Anteil bearbeiten.
              bpl.s     no_zeroo_1        ; Wenn < 0, dann kein Rot mehr da...
              clr.w     d3
no_zeroo_1:   subi.b    #2*SHADOW,d4      ; GrÅn bekommt doppelte Dosis.
              bpl.s     no_zeroo_2
              clr.w     d4
no_zeroo_2:   subi.w    #SHADOW,d5        ; Blau.
              bgt.s     no_minus_3
              clr.w     d5
no_minus_3:   lsl.w     d6,d3             ; Die abgeshadeten Komponenten wieder
              lsl.w     d7,d4             ; zusammenbringen und Pixel mit neuem
              or.w      d3,d4             ; Farbwert schreiben.
              or.w      d4,d5
              move.w    d5,(a4)

noset_pix:    dbra      d2,inset_pixel    ; NÑchster Pixel.
              lea       640(a0),a0
              lea       640(a1),a1
              dbra      d1,inset_zeile    ; NÑchste Zeile.

              movem.l   (sp)+,d0-a6
              rts
                                                                                
*****************************************************************************
* Konvertiert 4 planebild in High-Colourbild.
* PARAMETER:  d0.w  -  Breite in 16 Pixeln.                                 *
*             d1.w  -  Hîhe in Zeilen.                                      *
*             a0.l  -  Sourcebild (4 Planes)                                *
*             a1.l  -  Zielbuffer (Organisation: 320*d1)                    *
*             a2.l  -  Farbpalette im XGA Format.                           *
*****************************************************************************
in_planes_hc: movem.l   d0-a6,-(sp)

              subq.w    #1,d0
              trapmi.w  #-2000
              subq.w    #1,d1
              trapmi.w  #-2001

              clr.w     (a2)                    ; Hintergrundfarbe immer 0 (Maske!)

              movea.l   a1,a6
              move.w    d0,d6
              move.w    d1,d7
conv_zeile:   move.w    d6,d5
              movea.l   a6,a4             ; Zielbuffer-Zeile.
conv_blk:     movem.l   (a0)+,d0-d1       ; Alle 4 Planes holen.
              swap      d0
              swap      d1
              moveq     #15,d4            ; 16 Pixel konvertieren.
conv_pixel:   clr.w     d2

              btst      d4,d0             ; Die Angaben in den Planes in
              beq.s     no_set3           ; 4 Bit Wert umrechnen.
              bset      #0,d2             
no_set3:      swap      d0
              btst      d4,d0
              beq.s     no_set2
              bset      #1,d2
no_set2:      swap      d0
              btst      d4,d1
              beq.s     no_set1
              bset      #2,d2
no_set1:      swap      d1
              btst      d4,d1
              beq.s     no_set0
              bset      #3,d2
no_set0:      swap      d1

              move.w    (a2,d2.w*2),(a4)+ ; Pixel mit Palettenwert schreiben.
              dbra      d4,conv_pixel     ; NÑchster Pixel.
              dbra      d5,conv_blk       ; NÑchster 16 Pixel Block.

              lea       640(a6),a6        ; NÑchste Zeile im Zielbuffer.
              dbra      d7,conv_zeile     ; NÑchste Zeile konvertieren.

              movem.l   (sp)+,d0-a6
              rts
