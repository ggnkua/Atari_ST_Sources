; This file contains additional Subrouts which specially made for the demo
; and so not usable as generally subrouts.
; (C) Copyright 1995 by Jochen Knaus, AURA.

*****************************************************************************
*                                                                           *
* ZUSéTZLICHE Unterroutinen fÅr allgemeinere Effekte/Routinen.              *
* Start: MÑrz 95                                                            *
* Die Spriterouts schlucken Platz, dafÅr sind sie schnell und schnell ent-  *
* wickelt...                                                                *
*                                                                           *
*****************************************************************************

; .IMPORT     bmp_ani_clrs

; Routinenliste (nach Entstehungszeit geordnet):
; <shift_sprite_mono>   : Pre-Shiftet Einplane-Sprite.
; <set_sprite_mono>     : Setzt Monosprite (unmaskiert) (auf Planescreen)
; <do_ani>              : Initialisiert Bitmap (Oneplane) Animation.
; <run_ani>             : Frameroutine des Animationsplayers
; <vbl_ani>             : VBL-Routine des Aniplayers (fÅr's Fading)
; <calc_fo_9800>        : Berechnet Fade.
; <set_text_plane>      : Setzt Text auf planeorientiertem Screen.
; <fade_in_pal>         : Fadet Palette ein (Echtzeit)
; <fade_step>           : FÅhrt einen Fadingschritt aus (aus "Lamemine")
; <mask_pal>            : Maskiert Bit 0 und 1 in RGB-Teilen einer Pal. aus.
; <calc_fade>           : Berechnet Farbpalettenfade (Nicht in Lib abgedeckt)
; <switch_svga>         ; Schaltet Videohardware auf 640*480 mit 256 Farben.
; <switch_svga16>       : Schaltet Videohardware auf 640*480 mit 16 Farben.
; <fill_one_plane>      : FÅllt eine Plane aller Screens mit Monochom-Bild.
; <show_pic_4pl>        : Zeigt ein 4 Plane Bild auf 4 Plane Screen an.

; TEXTBREITENDEFINES:
TXT_224       EQU       0                 ; Breite: 224 Pixel.


*****************************************************************************
*  Bereitet Bitmap-Anis (1 Plane) vor.                                      *
* PARAMETER:  a3.l  -  Bufferadresse.                                       *
*             a4.l  -  Animationsrohdaten (Bewegung...)                     *
*             a5.l  -  Spritegrîûen.                                        *
*             a6.l  -  Fadinginformationen.                                 *
*             d7.w  -  Anzahl Sprites.                                      *
* RETURN:     a3.l  -  Erste freie Bufferadresse.                           *
*****************************************************************************
init_bmp_anis:
              movem.l   d0-a2/a4-a6,-(sp)

              subq.w    #1,d7
              trapmi.w  #-1101

init_ani:     move.w    d7,-(sp)

              movem.w   (a5)+,d0-d2       ; Spritegrîûen und Anz. Animationen.
              move.l    (a5)+,a0          ; Spritegrafikdaten.
              movea.l   a3,a1
              move.l    a3,20(a4)         ; Grafikadresse einfÅgen.
              bsr.w     shift_sprite_mono ; Sprite vorshiften.

              movea.l   a1,a2             ; Fadingpalette berechnen.
              movea.l   a6,a0
              lea       6(a0),a1
              moveq     #32,d7
              movem.l   d0-d7/a3-a6,-(sp)
              bsr.w     calc_fo_9800
              movem.l   (sp)+,d0-d7/a3-a6
              move.l    a2,28(a4)         ; Palettenadresse einfÅgen.
              lea       32*4(a2),a2
              movea.l   a2,a3

              lea       32(a4),a4         ; Auf nÑchste Bitmapstruktur.
              lea       12(a6),a6         ; NÑchstes Fading.

              move.w    (sp)+,d7
              dbra      d7,init_ani       ; NÑchste Animation.

              movem.l   (sp)+,d0-a2/a4-a6
              rts

*****************************************************************************
* Initialisiert Bitmap (Einplane) Animation.                                *
* PARAMETER:                                                                *
*  d0.w  -  Start-X                                                         *
*  d1.w  -  Start-Y                                                         *
*  d2.w  -  Anzahl Animationsstufen                                         *
*  d3.w  -  Animationsgeschwindigkeit                                       *
*  d4.w  -  Bewegungsflag (0=Incrments/<>0=Tabellenzugriff)                 *
*  a0.l  -  GFX-Adresse                                                     *
*  a1.l  -  Additional Pointer.                                             *
*  a2.l  -  Farbpalettenadresse.                                            *
*  a3.w  -  x-Increment (bei d4==0)                                         *
*  a4.w  -  y-          "                                                   *
*****************************************************************************
do_ani:       lea       ax(pc),a6         ; Parameter Åbernehmen.
              movem.w   d0-d7,(a6)        ; Adressen       "
              movem.l   a0-a2,ani_pnt

              lea       add_x(pc),a0
              movem.w   a3-a4,(a0)              ; x/y Increments.
              clr.l     (ani-add_x)(a0)         ; Ani.stufe und Anicounter.
              clr.w     (ani_cou-add_x)(a0)     ; Gesamtframecounter
              move.w    #-1,(ani_s_frm-add_x)(a0)   ; Startframe.
              clr.w     (ani_mode-add_x)(a0)    ; Modeflags.
              subq.w    #1,d7                   ; Anz.Anis - 1
              move.w    d7,(ani_fade-add_x)(a0) ; Fade-In/Out-Counter

              lea       bmp_ani_clrs,a0   ; Spritelîschadressen lîschen.
              moveq     #_16_ANZ_SCREENS-1,d7
da_clr:       clr.l     (a0)+
              dbra      d7,da_clr

              st        bmp_init          ; Animation Initialisiert-Flag.
              rts

*****************************************************************************
* Frameroutine des Mono-Bitmapplayers: Spielt initialisierte Ani ab.        *
* PARAMETER:  keine.                                                        *
*****************************************************************************
run_ani:      move.w    akt_log(pc),d7
              lea       (bmp_ani_clrs.l,pc,d7.w*4),a2
              move.l    (a2),d0
              beq.s     ra_no_clr

              move.l    d0,a0
              movem.w   ([ani_pnt.w,pc]),d0-d1
              bsr.w     bmp_clr_blk
              clr.l     (a2)

ra_no_clr:    move.w    ani_s_frm(pc),d0  ; Erstes Sprite ?
              bpl.s     ra_nfi            ; ja --> Startscreen merken.
              move.w    akt_log(pc),ani_s_frm
ra_nfi:       move.w    ani_cou(pc),d0    ; Weit genug bewegt ?
              addq.w    #1,d0
              cmp.w     anz_aniss(pc),d0
              sge       ani_fo            ; ja --> Ausfadeflag setzen.
              bge.s     ra_no_set         ; ja --> nicht setzen.
              move.w    d0,ani_cou

              movem.w   ax(pc),d0-d1      ; Spritekoordinate
              movem.w   ani(pc),d2-d3     ; Aktuelle Animation/Anicounter.
              addq.w    #1,d3
              cmp.w     anispeed(pc),d3   ; Neue Ani gefÑllig.
              blt.s     ra_nna
              clr.w     d3
              addq.w    #1,d2             ; NÑchste Ani.
              cmp.w     aniss(pc),d2      ; Letzte Anistufe gewesen ?
              blt.s     ra_nla
              clr.w     d2                ; ja --> wieder erste.
ra_nla:       move.w    d2,ani
ra_nna:       move.w    d3,anicount

              move.l    screen(pc),a0     ; Sprite setzen.
              adda.w    ani_plane(pc),a0
              move.l    ani_pnt(pc),a1
              bsr.w     set_sprite_mono

              tst.w     animove(pc)       ; Lineare Bewegung ?
              bne.s     ra_tab_mode       ; nein --> Tabellenmodus.

              lea       ax(pc),a0               ; Additionswerte auf Koords.
              movem.w   (add_x-ax)(a0),d0-d1    ; addieren.
              add.w     d0,(a0)+
              add.w     d1,(a0)
              rts                         ; Das wars.

ra_tab_mode:  move.w    ani_cou(pc),d0    ; Koordinaten aus Tabelle auslesen.
              move.l    ([ani_tab.w,pc],d0.w*4),ax
ra_no_set:    rts       

*****************************************************************************
* VBL-Routine des Animationsplayers.                                        *
* PARAMETER:  keine.                                                        *
*****************************************************************************
vbl_ani:      tst.b     ani_fo(pc)        ; Ausfaden ?
              beq.s     va_no_fo

              move.w    ani_fade(pc),d0   ; Fadecounter.
              cmp.w     anz_fades(pc),d0  ; Schon voll ausgefadet ?
              bge.s     va_rts

              move.l    ([ani_pal.w,pc],d0.w*4),d1  ; Farbe.
              addq.w    #1,d0
              move.w    d0,ani_fade

              move.w    ani_plane(pc),d0  ; In entsprechende Setzroutine
              jmp       ([ap_setpal.w,pc,d0.w*2])   ; springen.

va_no_fo:     move.w    ani_s_frm(pc),d0  ; Startframe
              bmi.s     va_rts            ; Noch nicht gestartet ?
              cmp.w     akt_scr(pc),d0    ; Neu sichtbar ?
              bne.s     noset
              st        ani_mode
noset:        tst.b     ani_mode(pc)      ; Sprite schon sichtbar ?
              beq.s     va_rts

              move.w    ani_fade(pc),d0   ; Fadecounter ein: bereits voll
              beq.s     va_rts            ; eingefadet ?
              move.l    ([ani_pal.w,pc],d0.w*4),d1  ; Farbe.
              subq.w    #1,d0
              move.w    d0,ani_fade

              move.w    ani_plane(pc),d0  ; In entsprechende Setzroutine
              jmp       ([ap_setpal.w,pc,d0.w*2])   ; springen.

va_rts:       rts

ap_setpal:    DC.L      sp_plane0,sp_plane1,sp_plane2,sp_plane3

sp_plane0:    move.l    d1,$ffff9804.w    ; Palette fÅr Plane 0 setzen.
              rts
sp_plane1:    lea       $ffff9808.w,a0    ; Palette fÅr Plane 1 setzen.
              move.l    d1,(a0)+
              move.l    d1,(a0)
              rts
sp_plane2:    lea       $ffff9810.w,a0    ; Palette fÅr Plane 2 setzen.
              move.l    d1,(a0)+
              move.l    d1,(a0)+
              move.l    d1,(a0)+
              move.l    d1,(a0)
              rts
sp_plane3:    lea       $ffff9820.w,a0    ; Palette fÅr Plane 3 setzen.
              move.l    d1,(a0)+
              move.l    d1,(a0)+
              move.l    d1,(a0)+
              move.l    d1,(a0)+
              move.l    d1,(a0)+
              move.l    d1,(a0)+
              move.l    d1,(a0)+
              move.l    d1,(a0)
              rts

ax:           DC.W      0                 ; { Start-X
ay:           DC.W      0                 ; | Start-Y
aniss:        DC.W      0                 ; | Anzahl Animationen.
anispeed:     DC.W      0                 ; | Frames pro Anistufe.
animove:      DC.W      0                 ; | Bewegungsmodus.
anz_aniss:    DC.W      0                 ; |  
ani_plane:    DC.W      0                 ; | Planeoffset.
anz_fades:    DC.W      32                ; } Anzahl Fadingschritte.
ani_pnt:      DC.L      0                 ; { Grafikadresse (geshiftet!)
ani_tab:      DC.L      0                 ; | [Bewegungstabelle]
ani_pal:      DC.L      0                 ; } Fadingpalette.

add_x:        DC.W      1                 ; Lokale Variablen, mÅssen Init-
add_y:        DC.W      0                 ; ialisiert werden.
ani:          DC.W      0                 ; Aktuelle Animationsstufe.
anicount:     DC.W      0                 ; Framecounter fÅr Animation.
ani_cou:      DC.W      0                 ; Gesamter Framecounter fÅr Fadeout.
ani_s_frm:    DC.W      -1                ; Startframe.
ani_mode:     DC.B      0                 ; Animationsmodus.
ani_fo:       DC.B      0                 ; Fadeoutflag.
ani_fade:     DC.W      31                ; Fadecounter.
bmp_init:     DC.W      0                 ; Anim. Init. Flag

*****************************************************************************
* Setzt Monosprite ungeclippt mit Breite bis max. 128 Pixel Breite.         *
* (4 oder 8 Plane Screenorganisation.)                                      *
*                                                                           *
*  d0.w  -  x-Koord.                                                        *
*  d1.w  -  y-Koord.                                                        *
*  d2.w  -  Animationsnummer.                                               *
*  a0.l  -  Screenadresse (auf entsprechendem Plane)                        *
*  a1.l  -  Spritedaten.                                                    *
*  a2.l  -  Buffer fÅr Lîschadresse.                                        *
*                                                                           *
* Clipping fehlt nur am rechten Rand.                                       *
*****************************************************************************
set_sprite_mono:
              moveq     #0,d5             ; Grafikoffset Default == 0
              moveq     #0,d6             ; Zeilenadd.
              moveq     #0,d7             ; Hîhenoffset

              lea       clipping+4(pc),a3
              cmp.w     (a3)+,d1          ; Sprite oben raus ?
              bge.s     bs_nu_clipp

              move.w    -(a3),d6
              sub.w     d1,d6             ; Anzahl Zeilen, die wegfallen.
              move.w    d6,d7             ; Zeilen, die oben wegfallen.
              move.w    (a3)+,d1

bs_nu_clipp:  movea.w   d1,a4             ; y sichern.

              cmpi.b    #8,planes         ; Zeilenoffsets verschieden...
              bne.s     sm_tab_160
              add.l     (tab_320.l,pc,d1.w*4),a0    ; Screenoffset berechnen.
              bra.s     sm_fin_tab
sm_tab_160:   add.l     (tab_160.l,pc,d1.w*4),a0    ; Screenoffset berechnen.
sm_fin_tab:   move.w    d0,d1
              bpl.s     no_clipp_l

              move.w    d0,d5
              neg.w     d5
              asr.w     #4,d5             ; Grafikoffset.
              addq.w    #1,d5
              bra.s     no_hor_off        ; Keine Offsetberechnung.

no_clipp_l:   andi.w    #$fff0,d1
              cmpi.b    #8,planes
              beq.s     sm_no_shift
              lsr.w     #1,d1
sm_no_shift:  adda.w    d1,a0
no_hor_off:   move.l    a0,(a2)           ; Lîschadresse setzen.

              movem.w   (a1)+,d1/d3-d4    ; Breite / Hîhe (-1) / Grîûe.
              sub.w     d6,d3             ; Anzahl weggeclippter Zeilen.
              bmi.w     comp_out          ; Sprite komplett oben raus ?

              move.w    a4,d6
              add.w     d3,d6
              cmp.w     (a3),d6           ; Sprite unten geclippt ?
              ble.s     no_cl_do

              sub.w     (a3),d6           ; Anzahl ÅberzÑhliger Zeilen.
              sub.w     d6,d3             ; Von Hîhe abziehen.
              bmi.s     comp_out          ; Sprite komplett unten raus ?

no_cl_do:     move.w    d7,d6             ; Grafikoffset Clipping oben.
              beq.s     no_co_up          ; Kein Offset da: mul sparen.
              mulu.w    d1,d7             ; Breite des Sprites * ClippÅber-
              add.w     d6,d7             ; hang (oben weggeclippt).
              add.w     d7,d7

no_co_up:     move.l    (a1,d2.w*4),a1    ; Animationsgrafik.
              sub.w     d5,d1             ; Breite bei Clipp verkleinern.
              bmi.s     comp_out
              add.w     d5,d5             ; Grafiklineoffset.
              adda.l    d5,a1             ; Horizontaler Clippoffset addieren.
              adda.l    d7,a1             ; Vertikaler Clippoffset.
              move.w    d3,d2

              andi.w    #$f,d0            ; Shiftstatus.
              mulu.w    d4,d0             ; Entsprechend geshiftete GFX.
              bne.s     set_shifted       ; != 0 --> geshiftet.

              add.w     d6,d6
              sub.w     d6,a1
              subq.w    #1,d1             ; ungeshiftet --> verschmÑlern.
              bmi.s     comp_out

              cmpi.b    #8,planes         ; 8 oder 4 Planes setzen ?
              bne.s     sm_s162

              lea       320.w,a2          ; Zeilenoffset.
              move.w    (sesp_offs2.w,pc,d1.w*2),d1
              jmp       (sesp_first2.w,pc,d1.w)

sm_s162:      lea       160.w,a2          ; Zeilenoffset.
              move.w    (sesp_offs.b,pc,d1.w*2),d1  ; Offset Setzroutine.
              jmp       (sesp_first.b,pc,d1.w)      ; Routine anspringen.

set_shifted:  adda.l    d0,a1             ; Auf entsprechende Shiftgfx.
              cmpi.b    #8,planes         ; 8 oder 4 Planes setzen ?
              bne.s     sm_s16

              lea       320.w,a2          ; Zeilenoffset.
              move.w    (sesp_offs2.w,pc,d1.w*2),d1
              jmp       (sesp_first2.w,pc,d1.w)

sm_s16:       lea       160.w,a2          ; Zeilenoffset.
              move.w    (sesp_offs.b,pc,d1.w*2),d1
              jmp       (sesp_first.b,pc,d1.w)

comp_out:     clr.l     (a2)
              rts

; Relative Einsprungoffsets (je nach Spritebreite) in entspre. Routs.
sesp_offs:    DC.W      sesp_0-sesp_first,sesp_1-sesp_first,sesp_2-sesp_first
              DC.W      sesp_3-sesp_first,sesp_4-sesp_first,sesp_5-sesp_first
              DC.W      sesp_6-sesp_first,sesp_7-sesp_first,sesp_8-sesp_first

sesp_offs2:   DC.W      sesp_02-sesp_first2,sesp_12-sesp_first2,sesp_22-sesp_first2
              DC.W      sesp_32-sesp_first2,sesp_42-sesp_first2,sesp_52-sesp_first2
              DC.W      sesp_62-sesp_first2,sesp_72-sesp_first2,sesp_82-sesp_first2

SSP_MOVE      MACRO                       ; Macro zum Erzeugen der Routinen
              move.w    (a1)+,(a0)        ; fÅr die einzelnen Breiten.
OFF         SET  8
          REPEAT                          ; Angegebene Anzahl (+1) Moves einfÅgen.
              move.w    (a1)+,OFF(a0)
OFF         SET  OFF+8
          UNTIL   #\1
              adda.l    d5,a1
              adda.l    a2,a0             ; NÑchste Zeile.
              ENDM

SSP_MOVE2     MACRO                       ; Analog oben, nur fÅr 8 Planes-Scr.
              move.w    (a1)+,(a0)
OFF         SET  16
          REPEAT
              move.w    (a1)+,OFF(a0)
OFF         SET  OFF+16
          UNTIL   #\1
              adda.l    d5,a1
              adda.l    a2,a0
              ENDM

sesp_first:
sesp_0:       move.w    (a1)+,(a0)        ; Breite 16 Pixel (kann nur
              adda.l    d5,a1
              adda.l    a2,a0             ; bei ungeshiftetem 16-Pixel
              dbra      d2,sesp_0         ; Block auftreten!!!)
              rts
sesp_1:       SSP_MOVE  0                 ; 32 Pixel
              dbra      d2,sesp_1
              rts
sesp_2:       SSP_MOVE  1                 ; 48 Pixel
              dbra      d2,sesp_2
              rts
sesp_3:       SSP_MOVE  2                 ; 64 Pixel
              dbra      d2,sesp_3
              rts
sesp_4:       SSP_MOVE  3                 ; 80 Pixel
              dbra      d2,sesp_4
              rts
sesp_5:       SSP_MOVE  4                 ; 96 Pixel
              dbra      d2,sesp_5
              rts
sesp_6:       SSP_MOVE  5                 ; 112 Pixel
              dbra      d2,sesp_6
              rts
sesp_7:       SSP_MOVE  6                 ; 128 Pixel
              dbra      d2,sesp_7
              rts
sesp_8:       SSP_MOVE  7                 ; 144 Pixel
              dbra      d2,sesp_8
              rts

sesp_first2:
sesp_02:      move.w    (a1)+,(a0)        ; Breite 16 Pixel (kann nur
              adda.l    d5,a1
              adda.l    a2,a0             ; bei ungeshiftetem 16-Pixel
              dbra      d2,sesp_02        ; Block auftreten!!!)
              rts
sesp_12:      SSP_MOVE2 0                 ; 32 Pixel
              dbra      d2,sesp_12
              rts
sesp_22:      SSP_MOVE2 1                 ; 48 Pixel
              dbra      d2,sesp_22
              rts
sesp_32:      SSP_MOVE2 2                 ; 64 Pixel
              dbra      d2,sesp_32
              rts
sesp_42:      SSP_MOVE2 3                 ; 80 Pixel
              dbra      d2,sesp_42
              rts
sesp_52:      SSP_MOVE2 4                 ; 96 Pixel
              dbra      d2,sesp_52
              rts
sesp_62:      SSP_MOVE2 5                 ; 112 Pixel
              dbra      d2,sesp_62
              rts
sesp_72:      SSP_MOVE2 6                 ; 128 Pixel
              dbra      d2,sesp_72
              rts
sesp_82:      SSP_MOVE2 7                 ; 144 Pixel
              dbra      d2,sesp_82
              rts

*****************************************************************************
*  d0.w  -  Breite.                                                         *
*  d1.w  -  Hîhe.                                                           *
*  a0.l  -  Lîschadresse.                                                   *
*****************************************************************************
bmp_clr_blk:  cmpi.b    #8,planes         ; 8 Plane Mode ?
              bne.s     sm_clr_16

              lea       320.w,a1          ; Zeilenoffset.
              move.w    (clsp_offs2.w,pc,d0.w*2),d2
              moveq     #0,d0
              jmp       (clsp_02.w,pc,d2.w)

sm_clr_16:    lea       160.w,a1          ; Zeilenoffset.
              move.w    (clsp_offs.b,pc,d0.w*2),d2
              moveq     #0,d0
              jmp       (clsp_0.b,pc,d2.w)

clsp_offs:    DC.W      0,clsp_1-clsp_0,clsp_2-clsp_0,clsp_3-clsp_0
              DC.W      clsp_4-clsp_0,clsp_5-clsp_0,clsp_6-clsp_0,clsp_7-clsp_0
              DC.W      clsp_8-clsp_0
clsp_offs2:   DC.W      0,clsp_12-clsp_02,clsp_22-clsp_02,clsp_32-clsp_02
              DC.W      clsp_42-clsp_02,clsp_52-clsp_02,clsp_62-clsp_02,clsp_72-clsp_02
              DC.W      clsp_82-clsp_02

SSP_CLR       MACRO                       ; Macro zum Erzeugen der Clearrouts.
              move.w    d0,(a0)
OFF         SET  8
          REPEAT
              move.w    d0,OFF(a0)
OFF         SET  OFF+8
          UNTIL   #\1
              adda.l    a1,a0
              ENDM

SSP_CLR2      MACRO                       ; Macro zum Erzeugen der Clearrouts.
              move.w    d0,(a0)
OFF         SET  16
          REPEAT
              move.w    d0,OFF(a0)
OFF         SET  OFF+16
          UNTIL   #\1
              adda.l    a1,a0
              ENDM

clsp_0:       clr.w     (a0)
              adda.l    a1,a0
              dbra      d1,clsp_0
              rts
clsp_1:       SSP_CLR   0
              dbra      d1,clsp_1
              rts
clsp_2:       SSP_CLR   1
              dbra      d1,clsp_2
              rts
clsp_3:       SSP_CLR   2
              dbra      d1,clsp_3
              rts
clsp_4:       SSP_CLR   3
              dbra      d1,clsp_4
              rts
clsp_5:       SSP_CLR   4
              dbra      d1,clsp_5
              rts
clsp_6:       SSP_CLR   5
              dbra      d1,clsp_6
              rts
clsp_7:       SSP_CLR   6
              dbra      d1,clsp_7
              rts
clsp_8:       SSP_CLR   7
              dbra      d1,clsp_8
              rts

clsp_02:      clr.w     (a0)              ; Der ganze Spaû noch fÅr 8 Planes.
              adda.l    a1,a0
              dbra      d1,clsp_02
              rts
clsp_12:      SSP_CLR2  0
              dbra      d1,clsp_12
              rts
clsp_22:      SSP_CLR2  1
              dbra      d1,clsp_22
              rts
clsp_32:      SSP_CLR2  2
              dbra      d1,clsp_32
              rts
clsp_42:      SSP_CLR2  3
              dbra      d1,clsp_42
              rts
clsp_52:      SSP_CLR2  4
              dbra      d1,clsp_52
              rts
clsp_62:      SSP_CLR2  5
              dbra      d1,clsp_62
              rts
clsp_72:      SSP_CLR2  6
              dbra      d1,clsp_72
              rts
clsp_82:      SSP_CLR2  7
              dbra      d1,clsp_82
              rts


*****************************************************************************
* Shiftet Sprite(s) in bel. Grîûe vor.                                      *
*                                                                           *
*  d0.w  -  Breite in Words.                                                *
*  d1.w  -  Hîhe in Zeilen.                                                 *
*  d2.w  -  Anzahl Sprites (Animationsstufen).                              *
*  a0.l  -  Spriteadresse.                                                  *
*  a1.l  -  Bufferadresse.                                                  *
*                                                                           *
* RET: a1 - liegt auf erster Bufferadresse HINTER geshifteten Daten.        *
*****************************************************************************
shift_sprite_mono:
              movem.l   d0-d7/a0/a2-a6,-(sp)

              move.w    d0,d3
              move.w    d1,d4
              move.w    d2,d5

              subq.w    #1,d0             ; Parameter in "dbf"-Format.
              bmi.s     sp_err_rts
              subq.w    #1,d1
              bmi.s     sp_err_rts
              subq.w    #1,d2
              bmi.s     sp_err_rts

              move.w    d3,(a1)+          ; Breite an Bufferstart.
              move.w    d1,(a1)+          ; Hîhe          "

              addq.w    #1,d3             ; Breite wird durch shiften grîûer.
              mulu.w    d3,d4
              add.w     d4,d4             ; *2 (sollte nicht >32k werden)
              move.w    d4,(a1)+          ; Grîûe an Bufferstart.

              move.l    a1,a5                   ; FÅr Pointerliste.
              lea       (4.b,a1,d2.w*4),a1      ; Auf GFX-Datenbuffer.

sprite_lp:    move.l    a1,(a5)+          ; Pointer auf dieses Sprite.
              moveq     #15,d7            ; 16 Shiftstadien.
shift_lp:     move.l    a0,a6
              move.w    d7,d6
              eori.w    #15,d6            ; Akt. Shift.
              bne.s     norm_shift

              move.w    d1,d5             ; Einfach "raw" rÅberziehen.
sh_cp_lp:     move.w    d0,d4
sh_cp_zlp:    move.w    (a6)+,(a1)+
              dbra      d4,sh_cp_zlp
              dbra      d5,sh_cp_lp

              move.w    d1,d3             ; Da Sprite nicht verbereitert
              addq.w    #1,d3             ; werden muûte, Buffer Åbergehen,
              add.w     d3,d3             ; um Offsets konstant zu halten.
              adda.w    d3,a1
              bra.s     next_shift

norm_shift:   moveq     #0,d3             ; Sprite shiften: Breite um ein Wort
              move.w    d1,d5             ; verbreitern.
sh_cp_lp2:    move.w    d0,d4
sh_cp_zlp2:   move.w    (a6)+,d3          ; Wort holen.
              ror.l     d6,d3             ; Shiften (Rest vom vorigen Wort rein)
              move.w    d3,(a1)+          ; Sichern.
              clr.w     d3
              rol.l     d6,d3             ; Rest in Stellung bringen.
              swap      d3
              dbra      d4,sh_cp_zlp2     ; NÑchstes Wort in der Breite.
              ror.l     d6,d3             ; Zusatzwort sichern.
              move.w    d3,(a1)+
              moveq     #0,d3
              dbra      d5,sh_cp_lp2      ; NÑchste Zeile.

next_shift:   dbra      d7,shift_lp       ; NÑchster Shiftstatus.
              move.l    a6,a0             ; NÑchste GFX.
              dbra      d2,sprite_lp      ; NÑchstes Sprite.

sp_err_rts:   movem.l   (sp)+,d0-d7/a0/a2-a6
              rts

*****************************************************************************
*  Setzt Text auf planeorientiertem Screen:                                 *
*             8-Plane Modus: Plane 4                                        *
*             ;;16-Farb-Modus: Farbe 15                                     *
*  Die Setzroutinen sind aus GeschwindigkeitsgrÅnden auf einzelne           *
*  horizontale Grîûen beschrÑnkt, was durch selbstmodifizierenden Code um-  *
*  gangen werden kînnte.                                                    *
* PARAMETER:                                                                *
*  a0.l  -  Textadresse (Grafik !!!)                                        *
*  d0.w  -  x-Koordinate (bereits mit $fff0 verandet)                       *
*  d1.w  -  y-Koordinate.                                                   *
*  d2.w  -  Breite: "Standartgrîûen": 0.w == 224 Pixel breit.               *
*                                     1.w ==                                *
*  d3.w  -  Hîhe in Zeilen (-1)                                             *
*****************************************************************************
set_text_plane:
              move.l    (tab_320.l,pc,d1.w*4),a1    ; Videoadresse (bleibt die
              adda.l    screen(pc),a1     ; Gleiche im 1 Plane und 16 Farb-
              lsr.w     #1,d0             ; modus).
              adda.w    d0,a1
              lea       320.w,a2          ; Scanoffset

;             cmp.b     #8,planes         ; 16 Farb-Modus ?
;             beq.w     set_text_16

              addq.l    #8,a1             ; Auf Plane 4

              move.w    (st1.b,pc,d2.w*2),d2
              jmp       (st1.b,pc,d2.w)

st1:          DC.W      st1_224-st1

st1_224:                                  ; Setzt 224 Pixel breiten Text.
              move.w    (a0)+,(a1)        ; Nulloffset getrennt rausziehen.
OFF    SET    16
       REPEAT
              move.w    (a0)+,OFF(a1)
OFF    SET  OFF+16
       UNTIL  #(13-1)
              adda.l    a2,a1             ; Scanoff.
              dbra      d3,st1_224        ; NÑchste Zeile.
              rts

set_text_16:  move.w    (st4.b,pc,d2.w*2),d2    ; 16 Farbmodus.
              jmp       (st4.b,pc,d2.w)
              rts

st4:          DC.W      st4_224-st4       ; Tabelle der 16 Farbroutinen.

st4_224:      lea       160-14*4.w,a2     ; Text 224 Pixel breit auf 16
st4_224_2:    moveq     #7-1,d7           ; Farbscreen setzen.
st4_224_lp:   move.w    (a0)+,d0
              or.w      d0,(a1)+
              or.w      d0,(a1)+
              or.w      d0,(a1)+
              or.w      d0,(a1)+
              move.w    (a0)+,d0
              or.w      d0,(a1)+
              or.w      d0,(a1)+
              or.w      d0,(a1)+
              or.w      d0,(a1)+
              dbra      d7,st4_224_lp
              adda.l    a2,a1
              dbra      d3,st4_224_2
              rts

*****************************************************************************
*  Berechnet Fadeout.                                                       *
*  a0.l  -  Startfarbe (VDI-Format)                                         *
*  a1.l  -  Endfarbe   (     "    )                                         *
*  a2.l  -  Buffer fÅr Palette im Falcon-Palettenformat.                    *
*  d7.w  -  Anzahl Fades.                                                   *
*****************************************************************************
calc_fo_9800: bsr.w     CALC_PAL_VDI

              move.l    a2,VDI_PAL
              move.l    VDI_PAL,DEST_PAL
              bra.w     VDI_9800

*****************************************************************************
*  Maskiert untersten 2 Bits der RGB-Teilen aus.                            *
*  PARAMETER: a0.l  -  Palette.                                             *
*             d7.w  -  Anzahl Farben                                        *
*****************************************************************************
mask_pal:     movem.l   d6-a0,-(sp)
              subq.w    #1,d7
              bmi.s     mapa_rts
              move.l    #$fcfc00fc,d6
and_loop3:    and.l     d6,(a0)+          ; 24 Bit Farbformat (SVGA) => 18 Bit
              dbra      d7,and_loop3      ; Farbformat (Falcon)
mapa_rts:     movem.l   (sp)+,d6-a0
              rts

*****************************************************************************
* Farben einfaden (Sourcepalette beliebig).                                 *
* Palette MUû maskiert sein (d.h. die untersten 2 Bits == 0)                *
* Fadet komplette Palette ein und terminiert erst dann.                     *
*  d7.w  -  Anzahl Farben.                                                  *
*  a0.l  -  Palette.                                                        *
*  a1.l  -  Hardwarereg.adr (z.B. $ffff9800).                               *
*****************************************************************************
fade_in_pal:  movea.l   a0,a6             ; Pointer sichern.
              movea.l   a1,a5
              move.w    d7,d5             ; Grîûe der Palette.
              subq.w    #1,d5
              bmi.s     fp_rts
              moveq     #63,d7            ; Max. 64 Fadingsschritte.
fade_pal_lp:  bsr.w     vsync             ; VSync.
              movea.l   a6,a0
              movea.l   a5,a1
              move.w    d5,d6
              bsr.s     fade_step         ; Einen Schritt faden.
              dbra      d7,fade_pal_lp
              rts

*****************************************************************************
* Farben einfaden (Relikt aus "Lamemmine"), EIN Fadingschritt ausfÅhren.    *
* Palette MUû maskiert sein (d.h. die untersten 2 Bits == 0)                *
* PARAMETER:  a0.l  -  Palette.                                             *
*             a1.l  -  Hardwarepalettenadresse.                             *
*             d6.w  -  Anzahl Farben (-1)                                   *
*****************************************************************************
fade_step:    
    IFNE 0
              movea.l   a1,a2             ; Routine abgewandelt aus "Lamemmine"
              movea.l   a0,a1
              movea.l   a2,a3
              moveq     #8,d4
              lea       $080000,a4
              lea       $040000,a5
              lea       $08000000,a6
              move.l    #$04000000,d5
fade_2:       move.l    (a3),d0           ; da Bytezugriffe auf Palettenregs.
              move.l    (a1)+,d1          ; Bugs erzeugen !

              cmp.b     d0,d1             ; Blau
              beq.s     bin_blau
              bhi.s     addb

              sub.b     d4,d0
addb:         addq.b    #$04,d0
bin_blau:     move.l    d0,d2
              move.l    d1,d3
              swap      d2
              swap      d3

              cmp.b     d2,d3             ; GrÅn
              beq.s     bin_grÅn
              bhi.s     addg

              sub.l     a4,d0
addg:         add.l     a5,d0
bin_grÅn:     lsr.w     d4,d2
              lsr.w     d4,d3

              cmp.b     d2,d3             ; Rot
              beq.s     bin_rot
              bhi.s     addr

              sub.l     a6,d0
addr:         add.l     d5,d0
bin_rot:      move.l    d0,(a3)+          ; Neue Farbe zurÅck.
              dbra      d6,fade_2
fp_rts:       rts
  ENDIF
              movea.l   a1,a2             ; Routine abgewandelt aus "Lamemmine"
              movea.l   a0,a1
              movea.l   a2,a3
fade_2:       move.l    (a3),d0           ; da Bytezugriffe auf Palettenregs.
              move.l    (a1)+,d1          ; Bugs erzeugen !

              cmp.b     d0,d1             ; Blau
              beq.s     bin_blau
              bhi.s     addb

              subq.b    #$08,d0
addb:         addq.b    #$04,d0
bin_blau:     move.l    d0,d2
              move.l    d1,d3
              swap      d2
              swap      d3

              cmp.b     d2,d3             ; GrÅn
              beq.s     bin_grÅn
              bhi.s     addg

              sub.l     #$080000,d0
addg:         add.l     #$040000,d0
bin_grÅn:     lsr.w     #8,d2
              lsr.w     #8,d3

              cmp.b     d2,d3             ; Rot
              beq.s     bin_rot
              bhi.s     addr

              sub.l     #$08000000,d0
addr:         add.l     #$04000000,d0
bin_rot:      move.l    d0,(a3)+
              dbra      d6,fade_2
fp_rts:       rts


*****************************************************************************
* Berechnet Fade zwischen zwei Paletten.                                    *
* PARAMETER:                                                                *
*  a0.l  -  Sourcepalette (VDI-Format)                                      *
*  a1.l  -  Zielpalette   (VDI-Format)                                      *
*  a2.l  -  Zielbuffer    ($ffff9800)                                       *
*  a3.l  -  Buffer (min. 6*Anzahl Farben*Anz Fadingschritte groû)           *
*  d6.w  -  Anzahl Farben in Palette.                                       *
*  d7.w  -  Anzahl Fadeschritte.                                            *
*****************************************************************************
calc_fade_pal:
              movem.l   d0-a6,-(sp)
              
              movea.l   a3,a4             ; Parameter sichern (wegen Libcalls)
              movea.l   a0,a5
              movea.l   a1,a6
              pea       (a2)

              move.w    d6,d5
              subq.w    #1,d5
              move.w    d5,d4
              trapmi.w  #-400

calc_i_col:   movea.l   a5,STARTCOL       ; Erstmal Fade Åber allen Farben
              movea.l   a6,ENDCOL         ; berechnen (einzelnd).
              movea.l   a3,CALC_PAL
              bsr.w     CALC_PAL_VDI

              movea.l   a3,VDI_PAL        ; Palette ins Falcon-Palettenformat.
              movea.l   a3,DEST_PAL
              bsr.w     VDI_9800

              lea       (a3,d7.w*4),a3    ; Buffer weitergehen.
              addq.l    #6,a5             ; In Source- und Zielpalette weiter-
              addq.l    #6,a6             ; gehen.
              dbra      d5,calc_i_col     ; NÑchste Einzelfarbe.

              move.w    d7,d0
              subq.w    #1,d7             ; Jetzt die Paletten nach Fadeing-
              trapmi.w  #-401             ; schritten zusammenkleistern.

              movea.l   (sp)+,a2          ; Destinationbuffer.
cp_put_toge:  movea.l   a4,a3             ; Individuelle Paletten.
              move.w    d4,d5             ; Anzahl Farben - 1
cp_tog:       move.l    (a3),(a2)+        ; Farbe kopieren.
              lea       (a3,d0.w*4),a3    ; NÑchste Farbe selber Fade.
              dbra      d5,cp_tog         ; Alle Farben hintereinander.
              addq.l    #4,a4
              dbra      d7,cp_put_toge    ; NÑchster Fadingschritt.

              movem.l   (sp)+,d0-a6
              rts

*****************************************************************************
*  Videohardware auf 640*480*256 Farben legen (VRam bereits umgelegt).      *
*****************************************************************************
switch_svga:  cmp.b     #2,(system+_MON)  ; VGA-Monitor ?
              beq.s     sw_svga_vga

* Monitor: RGB/TV
* 640*480, 256 Farben, 50.0 Hz (interl.), 15625 Hz
              move.l   #$1fe0187,$ffff8282.w
              move.l   #$400078,$ffff8286.w
              move.l   #$12901a7,$ffff828a.w
              move.l   #$270026b,$ffff82a2.w
              move.l   #$130058,$ffff82a6.w
              move.l   #$238026b,$ffff82aa.w
              move.w   #$200,$ffff820a.w
              move.w   #$182,$ffff82c0.w
              clr.w    $ffff8266.w
              move.w   #$10,$ffff8266.w
              move.w   #$6,$ffff82c2.w
              move.w   #$140,$ffff8210.w
              rts

sw_svga_vga:
* Monitor: VGA
* 640*480, 256 Farben, 50.0 Hz, 31470 Hz
              MOVE.L    #$C60091,$FFFF8282.W
              MOVE.L    #$1902AF,$FFFF8286.W
              MOVE.L    #$880096,$FFFF828A.W
              MOVE.L    #$4EB045D,$FFFF82A2.W
              MOVE.L    #$9D009D,$FFFF82A6.W
              MOVE.L    #$45D04E7,$FFFF82AA.W
              MOVE.W    #$200,$FFFF820A.W
              MOVE.W    #$186,$FFFF82C0.W
              CLR.W     $FFFF8266.W
              MOVE.W    #$10,$FFFF8266.W
              MOVE.W    #$8,$FFFF82C2.W
              MOVE.W    #$140,$FFFF8210.W
              rts

; Schaltet im 256 Farben Modus mit 32MHz Videotakt.
;switch_svga2:          cmp.b             #2,(system+_MON)  ; VGA-Monitor ?
              beq.s     sw_svga_vga       ; ja --> Dann egal.

              IFNE      0
              move.l   #$1ff0197,$ffff8282.w
              move.l   #$500056,$ffff8286.w
              move.l   #$10601b4,$ffff828a.w
              move.l   #$26e0263,$ffff82a2.w
              move.l   #$170046,$ffff82a6.w
              move.l   #$2260269,$ffff82aa.w
              move.w   #$200,$ffff820a.w
              move.w   #$182,$ffff82c0.w
              clr.w    $ffff8266.w
              move.w   #$10,$ffff8266.w
              move.w   #$6,$ffff82c2.w
              move.w   #$140,$ffff8210.w
              ENDIF
              move.l   #$1fe0187,$ffff8282.w
              move.l   #$400050,$ffff8286.w
              move.l   #$10101a7,$ffff828a.w
              move.l   #$2700265,$ffff82a2.w
              move.l   #$2f0042,$ffff82a6.w
              move.l   #$222026b,$ffff82aa.w
              move.w   #$200,$ffff820a.w
              move.w   #$182,$ffff82c0.w
              clr.w    $ffff8266.w
              move.w   #$10,$ffff8266.w
              move.w   #$6,$ffff82c2.w
              move.w   #$140,$ffff8210.w
              rts

*****************************************************************************
*  Schaltet auf 640*480*16 Farben um. (VRam muû schon umgelegt sein).       *
*  Die Auflîsungen natÅrlich mit Screenspain bzw. Screenblaster 3 erzeugt ! *
*****************************************************************************
switch_svga16:
              cmp.b     #2,(system+_MON)  ; VGA-Monitor ?
              beq.s     sw_svga_vga16

* Monitor: RGB/TV
* 640*480, 16 Farben, 50.0 Hz (intrl.), 15625 Hz
              move.l   #$1fe0187,$ffff8282.w
              move.l   #$400062,$ffff8286.w
              move.l   #$11301a7,$ffff828a.w
              move.l   #$270026b,$ffff82a2.w
              move.l   #$130054,$ffff82a6.w
              move.l   #$234026b,$ffff82aa.w
              move.w   #$200,$ffff820a.w
              move.w   #$182,$ffff82c0.w
              clr.w    $ffff8266.w
              move.w   #$0,$ffff8266.w
              move.w   #$6,$ffff82c2.w
              move.w   #$A0,$ffff8210.w
              rts

sw_svga_vga16:
* Monitor: VGA
* 640*480, 16 Farben, 50.0 Hz, 31470 Hz
              MOVE.L   #$170013,$FFFF8282.W
              MOVE.L   #$10210,$FFFF8286.W
              MOVE.L   #$F0012,$FFFF828A.W
              MOVE.L   #$4EB04D5,$FFFF82A2.W
              MOVE.L   #$4300A9,$FFFF82A6.W
              MOVE.L   #$46904E7,$FFFF82AA.W
              MOVE.W   #$200,$FFFF820A.W
              MOVE.W   #$186,$FFFF82C0.W
              CLR.W    $FFFF8266.W
              MOVE.B   #$0,$FFFF8260.W
              MOVE.W   #$8,$FFFF82C2.W
              MOVE.W   #$A0,$FFFF8210.W
              rts

*****************************************************************************
* FÅllt ein Plane aller Screens mit einem Monochrom-Bild (auf planeorient-  *
* iertem Screen).                                                           *
*  PARAMETER: d0.w  -  Planeoffset.                                         *
*             d6.w  -  Startscan im Screen.                                 *
*             d7.w  -  Anzahl Zeilen.                                       *
*             a0.l  -  Bildadresse.                                         *
*****************************************************************************
fill_one_plane:
              movem.l   d0-a6,-(sp)
              ext.l     d0                ; Wir nachher als Long gebraucht.

              move.b    planes(pc),d5     ; 8-PLanescreen ?
              subq.b    #8,d5
              bne.s     fop_one

              lea       scr_lst_256,a6              ; Screenliste.
              move.l    (tab_320.l,pc,d6.w*4),d6    ; Screenoffset.
              add.l     d0,d6                       ; Planeoff. zum Screenoff.
              moveq     #_256_ANZ_SCREENS-1,d4      ; Anzahl Screens.
              moveq     #16,d2                      ; Grafikoffset Wort.
              lea       48.w,a4                     ; Grafikoffset Wort * 3.
              lea       320.w,a3                    ; Grafikoffset Linie.
              bra.s     fop_fill

fop_one:      lea       scr_lst_16,a6               ; Parameter fÅr 4-Planes.
              move.l    (tab_160.l,pc,d6.w*4),d6
              add.l     d0,d6                       ; Planeoff. zum Screenoff.
              moveq     #_16_ANZ_SCREENS-1,d4
              moveq     #8,d2
              lea       24.w,a4
              lea       160.w,a3

fop_fill:     move.l    a0,a1             ; Source.
              move.l    (a6)+,a2          ; Screen.
              adda.l    d6,a2             ; Auf Startzeile/-plane.
              move.w    d7,d3             ; Anzahl Zeilen.
fop_fill_ln:  moveq     #SCR_WIDE/64-1,d1 ; Zeile in 64er Schritten.
fop_zeile:    move.w    (a1)+,(a2)        ; Offset 0
              move.w    (a1)+,(a2,d2.w)   ;        1
              move.w    (a1)+,(a2,d2.w*2) ;        2
              move.w    (a1)+,(a2,a4.w)   ;        3
              lea       (a2,d2.w*4),a2    ; 64 Pixel weiter.
              dbra      d1,fop_zeile      ; NÑchster Block.
              dbra      d3,fop_fill_ln    ; NÑchste Zeile.
              dbra      d4,fop_fill       ; NÑchster Screen fÅllen.

              movem.l   (sp)+,d0-a6
              rts

*****************************************************************************
* Setzt Farbpalette fÅr ein Truepaintpic. (Die unteren 16 Farben sind etwas *
* besoffen angeordnet, die Korrektur findet nur Åber die Farbpalette statt. *
* PARAMETER:  d7.w  -  Anzahl Farben.                                       *
*****************************************************************************
set_pal_tpi:  pea       (a1)              ; Ruft lediglich das allgemeine
              lea       $ffff9800.w,a1    ; Unterprogramm auf.
              bsr.s     konv_pal_tpi
              move.l    (sp)+,a1
              rts

konv_pal_tpi: move.l    (a0)+,(a1)        ; Truepaint geht halt nach dem VDI.
              move.l    (a0)+,15*4(a1)    ; (Konvertiert im Palettenformat)
              move.l    (a0)+,1*4(a1)
              move.l    (a0)+,2*4(a1)
              move.l    (a0)+,4*4(a1)
              move.l    (a0)+,6*4(a1)
              move.l    (a0)+,3*4(a1)
              move.l    (a0)+,5*4(a1)
              move.l    (a0)+,7*4(a1)
              move.l    (a0)+,8*4(a1)
              move.l    (a0)+,9*4(a1)
              move.l    (a0)+,10*4(a1)
              move.l    (a0)+,12*4(a1)
              move.l    (a0)+,14*4(a1)
              move.l    (a0)+,11*4(a1)
              move.l    (a0)+,13*4(a1)

              subi.w    #16,d7            ; Mehr als 16 Farben ?
              ble.s     tpi_pal_rts       ; ja --> Dann Rest setzen.

              lea       16*4(a1),a1
              subq.w    #1,d7             ; >= 0
t_p_s_rest:   move.l    (a0)+,(a1)+
              dbra      d7,t_p_s_rest
tpi_pal_rts:  rts


; Konvertiert TPI-Palette im XGA Format.
konv_pal_tpi2:
              move.w    (a0)+,(a1)
              move.w    (a0)+,15*2(a1)
              move.w    (a0)+,1*2(a1)
              move.w    (a0)+,2*2(a1)
              move.w    (a0)+,4*2(a1)
              move.w    (a0)+,6*2(a1)
              move.w    (a0)+,3*2(a1)
              move.w    (a0)+,5*2(a1)
              move.w    (a0)+,7*2(a1)
              move.w    (a0)+,8*2(a1)
              move.w    (a0)+,9*2(a1)
              move.w    (a0)+,10*2(a1)
              move.w    (a0)+,12*2(a1)
              move.w    (a0)+,14*2(a1)
              move.w    (a0)+,11*2(a1)
              move.w    (a0)+,13*2(a1)
              rts

spiegel:      movem.w   d1/d7,-(sp)       ; Spiegel Wort, UNGETESTET !
              moveq     #15,d7            ; Relativ langsam.
              moveq     #0,d1
flip_lp:      btst      d7,d0
              beq.s     fw_no_set
              bset      #0,d1
fw_no_set:    add.l     d1,d1
              dbra      d7,flip_lp
              lsr.l     #1,d1
              move.w    d1,d0
              movem.w   (sp)+,d1/d7
              rts

*****************************************************************************
* Zeigt 4 Plane-Bild auf 4 Plane Screen an.                                 *
*  d0.w  -  Breite / 16 - 1                                                 *
*  d1.w  -  Hîhe - 1                                                        *
*  a0.l  -  Bild (TPI ohne Header).                                         *
*  a1.l  -  Screenadresse (positioniert!).                                  *
*****************************************************************************
show_pic_4pl: link      a5,#-16*4         ; Eine Palette lokal gebraucht.
              st        disable_sync

              movea.l   a0,a6
              movea.l   a1,a3
              movea.l   a0,DEST_PAL       ; Farbpalette umrechnen.
              moveq     #16,COLSTEPS
              bsr.w     VDI_9800
              movea.l   a6,a0
              moveq     #16,COLSTEPS
              bsr.w     mask_pal
              movea.l   a6,a0             ; Und Palette in routineneigenen
              lea       -16*4(a5),a1      ; Palettenbuffer umkopieren.
              moveq     #16,d7
              bsr.w     konv_pal_tpi

              lea       -16*4(a5),a0      ; Palette wieder zurÅckkopieren, da
              movea.l   a6,a1             ; auf lokale Parameter kein Fading
              moveq     #15,d7            ; angemeldet werden kann.
s4_cpypal:    move.l    (a0)+,(a1)+
              dbra      d7,s4_cpypal

              move.w    d0,d2
              neg.w     d2
              lea       (160-8.w,d2.w*8),a2     ; Zeilenoffset.
              lea       16*6(a6),a1             ; Bilddaten.
cpy_zeile_4:  move.w    d0,d7             ; Anzahl Worte in der Breite.
cpy_spalte_4: move.l    (a1)+,(a3)+       ; 16 Pixel kopieren.
              move.l    (a1)+,(a3)+
              dbra      d7,cpy_spalte_4
              adda.l    a2,a3             ; NÑchste Zeile.
              dbra      d1,cpy_zeile_4

              movea.l   a6,a0             ; Bild einfaden.
              bsr.w     inst_norm_fade
              add.w     #50,frm_counter

              unlk      a5
              rts