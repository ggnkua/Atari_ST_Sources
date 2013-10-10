; This file includes the movement and initialisation of the different scenes.
; It is useless without the 3D-system.
; Most of the codes in this file is not optimized, as they called one time per
; frame (at maximum), and it doesn't matter if a call use 400 or 600 clockcycles
; per frame...

;  SZENENLIBRARY:
;  Szenendaten und Szenencode, benîtigt die Objektdaten aus "objects.q".
;  Szenen, die mehrmals gestartet werden, mÅssen ALLE eigenen Parameter bei
;  der Initialisierung setzen (DATA reicht nicht).

;  .IMPORT    lightsource,beovek,beo,speed,planes,detail
;  .IMPORT    anim_buf
;  .IMPORT    clr_screen,clr_screens,clr_mem

; Szenenidentifys.
SZ_MATHEM     EQU       0                 ; Mathematica Endscreen

SZ_MC2        EQU       1                 ; Megacubes 2
SZ_SW_VIEL    EQU       2                 ; "Swinging Viel"

SZ_GOURPROOF  EQU       12                ; The proof I can interpolate.
SZ_DOOM_ENG   EQU       7                 ; Dungeon-Explode.

SZ_STARS      EQU       8                 ; Sternenhimmel.

SZ_METRONOM   EQU       13                ; Metronomzeit.
SZ_ANY_TIMES  EQU       14                ; Any times ? Analog- und Digitaluhr.
SZ_FADINGS    EQU       10                ; Fades.

SZ_NACHZIEH   EQU       15                ; Diese Szene zieht nach...
SZ_WORLDPLATE EQU       11                ; World Plates.

SZ_ER2        EQU       3                 ; Enduro Racer 2.
SZ_ISLIFE     EQU       4                 ; Is it life ?
SZ_MATHEM_2   EQU       5                 ; Mathematica Endscreen Version 2.
SZ_ZOOM       EQU       6                 ; Wortzoom.
SZ_GOURFOTO   EQU       9                 ; Mr. Gouraud takes some photos.

STARTANI      EQU       0                 ; Bei Endversion: 0 !

ex_worlds:    ; Erste Nummer ist nur der chronologischen Sortierung.
; 1.)  << MATHEMATICA >> END - KONVERSION.
              DC.B      'Cubeswinger v1.',0
              DC.L      c_swinger_init,c_swinger_frame,c_swinger_vbl,c_swinger_data,0

; 2.)  << MEGACUBES >>
              DC.B      'Megacubes...v1.',0
              DC.L      mc_init,mc_frame,0,mc_data,0

; 3.)  << SCHWINGENDE VIELECKE >>
;      << GEDICHT: XXVIII, Szene (a) >>
              DC.B      'Alles rotiert.',0,0
              DC.L      sw_init,sw_frame,0,sw_data,sw_bmp

; 4.)  << ENDURO-RACER >>
              DC.B      'Enduro Racer. 2',0
              DC.L      er_init,er_frame,0,anim_buf,0 ;er_data

; 6.)  << Is it life ? >>
              DC.B      'Is it life ?',0,0,0,0
              DC.L      il_init,il_frame,il_vbl,il_data,0

; 7.)  << MATHEMATICA >> Version 2
              DC.B      'Cubeswinger v2.',0
              DC.L      c_swinger_init,c_swinger_frame_2,c_swinger_vbl
              DC.L      c_swinger_data,0

; 8.)  << Das zoomende Wort...>>
              DC.B      'Wortzoom.',0,0,0,0,0,0,0
              DC.L      wz_init,wz_frame,wz_vbl,wz_data,0

; 9.) << Doom ? >>
              DC.B      'Doom-Engine ???',0
              DC.L      de_init,de_frame,0,de_data,0

; 10.) << Sternenhimmel >>
              DC.B      'Sternenhimmel.',0,0
              DC.L      sh_init,sh_frame,0,sh_data,0

; 11.)  << Gouraud-Photoalbum >>
              DC.B      'Gouraud Photos.',0
              DC.L      gp_init,gp_frame,0,anim_buf,0 ;gp_data

; 12.)  << Fading Objekts >>
              DC.B      'Fading Objects.',0
              DC.L      fo_init,fo_frame,0,anim_buf,0

; 13.)  << World-Plates >>
              DC.B      'World Plates.',0,0,0
              DC.L      wp_init,wp_frame,0,wp_data,0

; 14.)  << Gour-Proof. >>
              DC.B      'G.P.'
              DS.B      12,0
              DC.L      gb_init,gb_frame,0,gb_data1,0

; 15.)  << Metronome >>
              DC.B      'METRONOM-ZEIT',0,0,0
              DC.L      mz_init,mz_frame,mz_vbl,mz_data,0

; 16.)  << ANY TIMES >>
              DC.B      'Any times ?',0,0,0,0,0
              DC.L      at_init,at_frame,at_vbl,at_data,0

; 17.)  << Der Schweif am Poly... >>
              DC.B      'Der Schweif...',0,0
              DC.L      ds_init,ds_frame,0,ds_data,0

; << Intro >>
              DC.B      'Intro.....',0,0,0,0,0
              DC.L      intro_init,intro_frame,intro_vbl,intro_data,0

; << Testszene fÅr Polyrout (Poly drehbar....) >>

              DC.B      'Polytestcube.',0,0,0
              DC.L      tst_init,tst_frame,tst_vbl,tst_data,0

              DC.L      0                 ; Endkennung.

;=============================================================================

; Defaultbeobachter: Steht um Ursprung und glotzt die z-Achse lang.
def_beo:      DC.W      0,0,0,0,0,0

*****************************************************************************
* Standart-VBLs: Ein-Ausfaden einer 16-Farbpal. und Bearbeitung der Bitmap- *
* Animationen.                                                              *
*****************************************************************************
std_vbl:      move.w    std_fade_in(pc),d0      ; Die zu Einfadenden Objekte
              beq.w     vbl_ani                 ; Åberhaupt schon sichtbar ?
              move.w    vbl_counter(pc),d1
              sub.w     std_svbl(pc),d1
              cmpi.w    #_16_ANZ_SCREENS,d1
              blt.w     vbl_ani                 ; Noch im log. V-Ram versteckt

              subq.w    #1,d0                   ; Sichtbar: Counter runter.
              move.w    d0,std_fade_in

              move.l    std_pal(pc),a0          ; Palette ein-/ausfaden.
              lea       $ffff9800.w,a1          ; (Benutzt Echtzeitfading).
              moveq     #15,d6
              bsr.w     fade_step
              bra.w     vbl_ani                 ; Bitmap-Animationen verwalten.

std_vbl2:     move.w    std_fade_in(pc),d0      ; Analog dem ersten Standart-
              bgt.s     std_v2_do               ; VBL, nur ohne Handling der
sv2_rts:      rts                               ; Bitmap-Anis.
std_v2_do:    move.w    vbl_counter(pc),d1
              sub.w     std_svbl(pc),d1
              cmpi.w    #_16_ANZ_SCREENS,d1
              blt.s     sv2_rts

              subq.w    #1,d0
              move.w    d0,std_fade_in

              move.l    std_pal(pc),a0
              lea       $ffff9800.w,a1
              moveq     #15,d6
              bra.w     fade_step

std_pal:      DC.L      0                 ; Farbpalettenadresse.
std_fade_in:  DC.W      0                 ; Fade-In-Counter.
std_svbl:     DC.W      0

*****************************************************************************
* 'Der Schweif der Polygone': Nachziehen par excellence...                  *
*****************************************************************************
DS_END_0      EQU       300-75            ; Die zwei Objekte.
DS_END        EQU       600               ; Der Megainterpolshader.
ds_beo:       DC.W      0,0,0,25,310,0
ds_init:      suba.l    a0,a0
              moveq     #RELOAD_DS,d0
              bsr.w     new_ani_blk

              lea       clipping,a0
              clr.w     (a0)+
              move.w    #SCR_WIDE-1,(a0)+
              clr.w     (a0)+
              move.w    #SCR_HIGH-1,(a0)

              move.w    #SCR_WIDE,IG_SCR_WIDE   ; Screenbreite
              move.w    #SCR_HIGH,IG_SCR_HIGH   ; Screenhîhe
              move.w    #ANZ_SHD_COLS,IG_ANZ_COLS   ; Schattierungstsufen
              lea       scr_offs,IG_SCAN_OFF    ; Scanoffsettabelle
              lea       l_koo,IG_LEFT_KOO       ; Linke Koordinaten
              lea       add_tab,IG_COL_DIST     ; Farbdistanzbuffer
              lea       add_poi,IG_COL_DIST_PO  ; Farbdistanzpointer
              lea       clipping,IG_CLIPPING    ; Clippbox
              bsr.l     INIT_GOURAUD            ; Gouraudroutine init.

              movea.l   scr_lst_32k+4,a0
              lea       (640*480.l,a0),a1
              bsr.w     clr_mem

              lea       D_file_00,a0      ; Screenhintergrund (HC) entpacken
              movea.l   scr_lst_32k,a1    ; und auf alle Screens kopieren.
              bsr.w     ice_decrunch

              move.b    #an,pals
              clr.b     detail            ; Change erzwingen.

              lea       ds_beo(pc),a0     ; 65K Farben / 25 fps
              moveq     #0,d0             ; Screens NICHT lîschen.
              moveq     #2,d1
              moveq     #4,d2
              moveq     #2,d3
              bsr.w     set_world

              movem.l   scr_lst_32k,a0-a1 ; Hintergrund einblenden.
              move.l    a1,d0
              bsr.w     vsync
              bsr.w     set_scr_adr
              bsr.w     hc_show1
              st        disable_sync

              lea       scr_lst_32k+4,a6
              moveq     #ANZ_SCREENS-2,d7
ds_cpy_scr:   movea.l   scr_lst_32k,a0
              movea.l   (a6)+,a1
              move.l    #(640*240)/16-1,d0
              bsr.w     cpy_mem16
              dbra      d7,ds_cpy_scr
              rts

ds_frame:     lea       ds_data_1+4(pc),a0
              moveq     #1,d0
              moveq     #-2,d1
              moveq     #3,d2
              bsr.w     rot_d03
              lea       16(a0),a0
              neg.w     d0
              neg.w     d1
              neg.w     d2
              bsr.w     rot_d03

              lea       beovek(pc),a0
              subq.w    #1,8(a0)
              cmp.w     #-DS_END_0,8(a0)
              bne.s     ds_no_b_blue

              lea       ds_beo(pc),a1
              move.l    (a1)+,(a0)+
              move.l    (a1)+,(a0)+
              move.l    (a1),(a0)
              move.l    #ds_frame_2,world_frame
              move.l    #ds_data_2,world_data

ds_no_b_blue: moveq     #2,d0
              moveq     #0,d1
              moveq     #-2,d2
              bra.w     rot_d03

ds_frame_2:   lea       ds_data_2+6(pc),a0      ; Das Megaobjekt bewegen.
              moveq     #3,d0
              moveq     #1,d1
              moveq     #-2,d2
              bsr.w     rot_d03

              addq.w    #1,8(a0)          ; ...von oben nach unten.

              cmp.w     #DS_END,8(a0)     ; Ende ?
              blt.s     ds_no_end

              moveq     #10-1,d7
anti_ruckel:  bsr.w     ready_frame       ; DÅrfte gegen ein Ruckeln helfen.
              dbra      d7,anti_ruckel

              lea       D_brainbug,a0     ; ja --> Mit Bild ausblenden.
              bsr.w     ice_decrunch_2

              lea       D_brainbug,a0     ; Das Bild muû invertiert werden,
              move.w    #320*240/8-1,d7   ; damit es besser aussieht !
inv_pic0:     not.l     (a0)+
              not.l     (a0)+
              not.l     (a0)+
              not.l     (a0)+
              dbra      d7,inv_pic0

              lea       D_brainbug+640*180,a0   ; Bild noch nachzentrieren.
              lea       D_brainbug-640*20,a1
              move.w    #640*20/16-1,d0
              bsr.w     cpy_mem16

              move.l    #track_fo_vbl,world_vbl ; Trackerausblender-VBL.

              lea       D_brainbug-640*20,a0
              bsr.w     hc_show_2

wait_s_aus:   tst.l     world_vbl(pc)     ; Warten, bis Tracker weg ist.
              bne.s     wait_s_aus

              moveq     #SZ_WORLDPLATE,d0 ; "Worldplates" starten.
              bra.w     new_animat

ds_no_end:    rts

ds_data:      DC.W      2
ds_data_1:    DC.W      CUBE_24_2,FULL,0,0,0,80,30,10
              DC.W      CUBE_24_3,FULL,0,0,0,-80,-30,-10
ds_data_2:    DC.W      1
              DC.W      CUBE_24,FULL,0,0,0,0,0,0

*****************************************************************************
* Fading-Objekte: Hinter dem Text faden Objekt immer Ziel- und Planlos ein. *
* Etwas kompliziertes Szenenhandling, aber dafÅr sehr flexibel.             *
* Dieser Screen wird fÅr die Credits/Greetings miûbraucht.                  *
*****************************************************************************
FO_INTERPOL   EQU       0                 ; Interpolierte Palette.
FO_DECKEND    EQU       -1                ; Deckende Palette.
FO_RAND       EQU       20                ; Grîûe des Randes des Logos zum Scr.
FO_PALS       EQU       anim_buf+8192     ; Farbpaletten.
FO_POFF       EQU       FO_PALS-4*FO_ANZ_PALS   ; Offset auf Palettenpointer.
FOFO          EQU       anim_buf+512      ; Offset auf Palette aus Farbe 0.
FO_NULLPAL    EQU       anim_buf+30000    ; Nullpalette zum Fade-Out.
FO_BACKPAL    EQU       FO_NULLPAL+2000
fo_init:
        IFEQ  (STARTANI-SZ_FADINGS)
              suba.l    a0,a0
              moveq     #RELOAD_MZ,d0
              bsr.w     new_ani_blk
        ENDIF

              lea       anim_buf,a0       ; Vorerst mit keinem Objekt starten.
              clr.w     (a0)

; EX-Logo auf Plane 7 kopieren (ist die Maske). Plane 5 wird benutzt, damit
; Farbe 0 nirgends auûer im Rand zu sehen ist und so die Maske vollstÑndig
; wirken kann.
              lea       scr_lst_256,a6    ; Auf alle Screens im Vordergrund ein
              lea       D_ex_logo_x,a5    ; E.X-Logo knallen, das durchscheint.
              moveq     #_256_ANZ_SCREENS-1,d7
fo_ex_logo:   move.w    d7,-(sp)
              movea.l   (a6)+,a0          ; Screenadr.

              moveq     #-1,d0
              moveq     #FO_RAND-1,d6     ; Oberen Rand lîschen (d.h. Plane 7
fo_fill_up:   move.w    #SCR_WIDE/16-1,d5 ; setzen, welche alle anderen deckt)
fo_fu:        lea       16(a0),a0
              move.w    d0,-2(a0)
              dbra      d5,fo_fu
              dbra      d6,fo_fill_up

              moveq     #-1,d0            ; Logo einkopieren.
              movea.l   a5,a2
              move.w    #SCR_HIGH-2*FO_RAND-1,d6
fo_cpy_lg1:   move.w    #SCR_WIDE/16-1,d5
fo_cpy_lg2:   clr.l     (a0)+             ; Auf Plane 7 Logo kopieren, Plane 4
              clr.l     (a0)+             ; vollstÑndig setzen, den Rest
              move.w    d0,(a0)+          ; lîschen.
              clr.l     (a0)+
              move.w    (a2)+,(a0)
              not.w     (a0)+             ; Logo noch nicht invertiert.
              dbra      d5,fo_cpy_lg2
              dbra      d6,fo_cpy_lg1

              moveq     #-1,d0            
              moveq     #FO_RAND-1,d6     ; Unteren Rand lîschen (bzw. eben
fo_fill_do:   move.w    #SCR_WIDE/16-1,d5 ; Plane 7 setzen).
fo_fd:        lea       16(a0),a0
              move.w    d0,-2(a0)
              dbra      d5,fo_fd
              dbra      d6,fo_fill_do

              move.w    (sp)+,d7
              dbra      d7,fo_ex_logo     ; NÑchster Screen mit Logo belÑstigen.

; Farbpaletten vorberechnen.
              lea       fo_logo(pc),VDI_PAL     ; Maskenfarbe und Hintergrund im
              movea.l   VDI_PAL,DEST_PAL        ; Normalformat.
              moveq     #2,COLSTEPS
              bsr.l     VDI_9800
              bsr.w     mask_pal

; Berechnet die Palette fÅr's Antialiasing: Die vier Grundfarben der einzelnen
; Planes werden mit jeweils allen anderen geschnitten. Es werden nur die öber-
; schneidungen zweier Farben berechnet, da es bei konvexen Objekten NICHT vor-
; kommen kann, daû entlang einer Polygonkante mehr als 2 FlÑchen sitzen.
              lea       FO_POFF,a3              ; Palettenpointer.
              lea       fo_src_pals(pc),a4      ; Grundfarben.
              lea       FO_PALS,a6              ; Da fliegen die Pals hin.
              moveq     #FO_ANZ_PALS-1,d7
fo_make_pals: move.w    d7,-(sp)          ; Wird als Para gebraucht.

              tst.w     (a4)+             ; Deckende Pal., oder Interpolierte ?
              beq.s     fo_intpol

              movea.l   a4,VDI_PAL        ; Deckende Palette: Farben so anord-
              movea.l   a4,DEST_PAL       ; nen, daû Plane 2 immer Plane 1
              moveq     #4,COLSTEPS       ; deckt etc...
              bsr.w     VDI_9800
              movea.l   a4,a0
              moveq     #4,d7
              bsr.w     mask_pal

              move.l    a6,(a3)+          ; Palettenpointer.

              movem.l   (a4),d0-d3        ; Die 4 Planefarben.
              lea       4*6(a4),a4

              move.l    fo_logo+4(pc),(a6)+     ; Hintergrund immer gleich.
              move.l    d0,(a6)+          ; 1
              move.l    d1,(a6)+          ; 2
              move.l    d1,(a6)+          ; 3
              move.l    d2,(a6)+          ; 4
              move.l    d2,(a6)+          ; 5
              move.l    d2,(a6)+          ; 6
              move.l    d2,(a6)+          ; 7

              moveq     #7,d0             ; 8 Farben (Plane 3 deckt alles...)
fo_dek_pl3:   move.l    d3,(a6)+          
              dbra      d0,fo_dek_pl3     
              bra.w     fo_next_pal

fo_intpol:    lea       FO_PALS+FO_ANZ_PALS*16*4,a5 ; Buffer.
              movea.l   a4,a2
              moveq     #4-1,d7
fo_antialias: movem.w   (a4)+,d0-d2       ; Schnittfarben interpolieren: Anti-
              movem.w   d0-d2,(a5)        ; Grundfarbe immer sichern.
              addq.l    #6,a5
              moveq     #2,d6             ; Mit wivielen anderen Farben ber-
              sub.w     d7,d6             ; echnen ?
              bmi.s     fo_first          ; Mit keiner ? (Plane 0)
              movea.l   a2,a1             ; Auf Farbe 1 gehen.
fo_calc_oth:  movem.w   (a1)+,d3-d5       ; Aliasing !
              sub.w     d0,d3             ; dp = p2-p1 (Abstand bilden).
              sub.w     d1,d4
              sub.w     d2,d5
              asr.w     #1,d3             ; mp = dp/2 (mittlerer Abstand)
              asr.w     #1,d4
              asr.w     #1,d5
              add.w     d0,d3             ; Neue Punkt = mp + p1.
              add.w     d1,d4
              add.w     d2,d5
              movem.w   d3-d5,(a5)        ; Berechneter Punkt sichern.
              addq.l    #6,a5
              dbra      d6,fo_calc_oth    ; Mit nÑchster Farbe schneiden.
fo_first:     dbra      d7,fo_antialias   ; NÑchste Grundfarbe.

              lea       -10*6(a5),a5      ; 10 Farben berechnet: ins normale
              movea.l   a5,VDI_PAL        ; Format zurÅck.
              movea.l   a5,DEST_PAL
              moveq     #10,COLSTEPS
              bsr.w     VDI_9800
              moveq     #10,d7            ; Palette noch fÅr's Fading maskieren.
              movea.l   a5,a0
              bsr.w     mask_pal

              move.l    fo_logo+4(pc),d0  ; Palette erstellen.
              move.l    a6,(a3)+          ; Pointer sichern.
              move.l    d0,(a6)+          ; Farbe 0: Hintergrund.
              move.l    (a5)+,(a6)+       ; Farbe 1: Col 1.
              move.l    (a5)+,(a6)+       ; Farbe 2: Col 2.
              move.l    (a5)+,(a6)+       ; Farbe 3: Col 2 | Col 1.
              move.l    (a5)+,(a6)+       ; Farbe 4: Col 3.
              move.l    (a5)+,(a6)+       ; Farbe 5: Col 3 | Col 1.
              move.l    (a5)+,(a6)+       ; Farbe 6: Col 3 | Col 2.
              move.l    -8(a5),(a6)+      ; Farbe 7: Col 3.
              move.l    (a5)+,d1
              move.l    d1,(a6)+          ; Farbe 8:  Col 4.
              move.l    (a5)+,(a6)+       ; Farbe 9:  Col 4 | Col 1.
              move.l    (a5)+,(a6)+       ; Farbe 10: Col 4 | Col 2.
              move.l    d1,(a6)+          ; Farbe 11: Col 4.
              move.l    (a5)+,(a6)+       ; Farbe 12: Col 4 | Col 3.
              move.l    d1,(a6)+          ; Farbe 13: Col 4.
              move.l    d1,(a6)+          ; Farbe 14: Col 4.
              move.l    d1,(a6)+          ; Farbe 15: Col 4.

fo_next_pal:  move.w    (sp)+,d7          ; NÑchste Palette.
              dbra      d7,fo_make_pals

              clr.b     detail            ; Change erzwingen.
              lea       def_beo(pc),a0    ; 8 Planes / 50 fps
              moveq     #0,d0             ; Screens NICHT lîschen.
              moveq     #1,d1
              moveq     #8,d2
              moveq     #2,d3
              bsr.w     set_world

; Farben vorbereiten.
              lea       FOFO,a0           ; Eine Palette nur aus Objekthinter-
              move.l    fo_logo+4(pc),d0  ; grund (zum Ausfaden).
              moveq     #15,d7
gen_FOFO:     move.l    d0,(a0)+
              dbra      d7,gen_FOFO

              lea       $ffff9800.w,a0    ; Farbe 0: Maskenrand.
              move.l    fo_logo(pc),d0
              move.l    d0,(a0)+
              lea       15*4(a0),a0       ; Farben 1-15 KôNNEN nicht auftreten.

              move.l    fo_logo+4(pc),(a0)+     ; Hintergrund fÅr Objekte.

              moveq     #96+16-2,d7       ; Farben 16-31 sind die Farben, auf
fo_clr16:     clr.l     (a0)+             ; denen die Objekte rumfliegen.
              dbra      d7,fo_clr16

              moveq     #127,d7           ; Farben 128-255 sind die Masken-
fo_set_mask:  move.l    d0,(a0)+          ; farben.
              dbra      d7,fo_set_mask

              lea       FO_BACKPAL,a0     ; Die Palette nur aus Hintergrund.
              move.l    fo_logo+4(pc),d0
              moveq     #15,d7
fo_b_pal:     move.l    d0,(a0)+
              dbra      d7,fo_b_pal
              rts

fo_frame:     move.w    ani_frm(pc),d0          ; Aktueller Framecount.
              sub.w     ([fo_point.w,pc]),d0    ; Neue Animationsphase ?
              beq.s     fo_new_phase            ; ja --> Init.
              neg.w     d0                      ; nein --> Zeit zum Ausfaden ?
              cmpi.w    #48,d0
              bne.s     fo_no_fo
              lea       FO_BACKPAL,a0
              moveq     #64,d5
              moveq     #16,d6
              moveq     #15,d7
              bsr.w     inst_fade
fo_no_fo:     jmp       ([fo_phase.w,pc]) ; Aktuelle Animationsphase.

fo_new_phase: move.l    fo_point(pc),a0
              move.w    d0,fo_startfrm
              addq.l    #2,a0             ; Startframe nun egal.
              move.w    (a0)+,d0          ; Phasennummer.
              bge.s     fo_no_end         ; Phasennummer < 0 --> Ende.

              st        disable_sync

              lea       FO_NULLPAL,a0     ; Nullpalette erzeugen.
              lea       260*4(a0),a1
              bsr.w     clr_mem           ; Lange Init vorbei...

              lea       FO_NULLPAL,a0     ; Die ganze Choose ausfaden.
              lea       $ffff9800.w,a1
              move.w    #256,d7
              bsr.w     fade_in_pal

              lea       $ffff9800.w,a0
              lea       256*4(a0),a1
              bsr.w     clr_mem

              moveq     #SZ_NACHZIEH,d0   ; Die Nachzieh Polys kommen...
              bra.w     new_animat

fo_no_end:    moveq     #64,d5            ; Einfaden initialisieren.
              move.w    (a0)+,d6          ; Startfarbe.
              addi.w    #16,d6            ; Plane 0 ist immerhin gesperrt.
              move.w    d6,fo_startcol
              move.w    (a0)+,d7          ; Anzahl der Farben.
              move.w    d7,fo_anzcols
              move.l    (a0)+,world_data            ; Objekt-Daten.
              move.l    a0,fo_point                 ; Neuen Tabpointer.
              move.l    (FO_POFF.l,pc,d0.w*4),a0    ; Palettenadresse.
              move.l    (fo_ph_adr.b,pc,d0.w*4),fo_phase    ; Phasenroutine.
              bsr.w     inst_fade                   ; Fading installieren.
              jmp       ([fo_in_adr.w,pc,d0.w*4])   ; Phase initialisieren.

fo_phase:     DC.L      fo_rts            ; Aktuelle Phasenroutine.
fo_point:     DC.L      fo_tab            ; Phasendaten auf nÑchstes Objekt.
fo_startfrm:  DC.W      0                 ; Aktueller Startframe.
fo_startcol:  DC.W      0                 ; { Anzahl der Farben.
fo_anzcols:   DC.W      0                 ; } Endfarbe.
fo_datas:     DC.L      anim_buf+1024

FO_ANZ_PALS   EQU       5                 ; Anzahl Farbpaletten.
; Phasenbewegungsroutinen.
fo_ph_adr:    DC.L      fo_phase1,fo_phase2,fo_phase3,fo_phase4,fo_phase5
; Phaseninitialisierungsroutinen.
fo_in_adr:    DC.L      fo_init1,fo_init2,fo_init3,fo_init4,fo_init5

fo_rts:       rts                         ; Die "Dummy"-Routine (fÅr Crash-Tests)
inst_fo_norm: moveq     #64,d5            ; "Normaler" Fade in dieser Ani: ab
              moveq     #16,d6            ; Farbe 16.
              moveq     #15,d7
              bra.w     inst_fade
fo_clr_scr:   moveq     #0,d0             ; Die Planes 0-3 lîschen.
              bra.w     clr_screen_8

***  DIE EINZELNEN PHASENROUTINEN  ***

; Phase 1: Rotierende Megakugel (lame 98 FlÑchen).
fo_init1:     lea       beo(pc),a0        ; Phase 1: Rotiert Beobachter lang-
              move.l    #$00200020,(a0)+  ; sam. Nichts aufregendes.
              move.w    #$0020,(a0)       ; Gut geeignet fÅr STATIC-Objekte.
              move.w    #2,anz_vbls       ; 25 fps
              clr.w     ani_frm
fo_phase1:    lea       beovek(pc),a0
              moveq     #2,d0
              moveq     #2,d1
              moveq     #3,d2
              bsr.w     rot_d03
              bra.w     fo_clr_scr        ; Screen entsprechend lîschen.

; Phase 2: Zwei ziemlich groûe Stern drehen sich am oberen und unteren Bildr.
fo_init2:     moveq     #48,d7
              bsr.w     vsync_xx

              lea       beovek(pc),a0
              clr.l     (a0)+
              clr.l     (a0)+
              move.l    #$00000014,(a0)+
              move.w    #2,anz_vbls       ; 25 fps
fo_phase2:    lea       fp_p2_obj1+4(pc),a0
              moveq     #0,d0
              moveq     #0,d1
              moveq     #3,d2
              bsr.w     rot_d03
              lea       16(a0),a0
              moveq     #-3,d2
              bsr.w     rot_d03
              bra.w     fo_clr_scr

FO_ABSTAND    EQU       116               ; Abstand zwischen den Pfeilen.
; 4 Pfeile rotieren ebenfalls wild.
fo_init3:     moveq     #48,d7            ; Zuerst Buffer leerspielen, damit
              bsr.w     vsync_xx          ; nicht Sterne schon mit 50fps ange-
                                          ; zeigt werden.
              lea       beovek(pc),a0
              clr.l     (a0)+
              clr.l     (a0)+
              move.l    #$00000014,(a0)+
              move.w    #1,anz_vbls       ; 50 fps
fo_phase3:    lea       fo_p3_data+8(pc),a0
              moveq     #7-1,d7
fo_move_up:   subq.w    #2,(a0)+
              addq.l    #8,a0
              dbra      d7,fo_move_up

              moveq     #3,d0             ; Beobachter mitschwingen lassen.
              moveq     #3,d1
              moveq     #3,d2
              lea       beovek(pc),a0
              bsr.w     rot_d03
              bra.w     fo_clr_scr

; 4. Phase: Die ganzen "E"s.
fo_init4:     moveq     #24,d7
              bsr.w     vsync_xx

              lea       beovek(pc),a0
              clr.l     (a0)+
              clr.l     (a0)+
              move.l    #$00000014,(a0)+
              move.w    #2,anz_vbls       ; 25 fps
fo_phase4:    lea       fo_p4_data+6(pc),a0
              moveq     #1,d0
              moveq     #2,d1
              moveq     #-3,d2
              moveq     #3,d3
              moveq     #4-1,d7
fo_lp4:       bsr.w     rot_d03
              subq.w    #2,8(a0)
              lea       16(a0),a0
              exg       d0,d2
              exg       d1,d3
              exg       d1,d0
              dbra      d7,fo_lp4
              bra.w     fo_clr_scr

; 5. Phase: Pfeile verteilt auf einer "Kugel".
fo_init5:     lea       beovek(pc),a0
              clr.l     (a0)+
              clr.l     (a0)+
              move.l    #$00000014,(a0)+
              move.w    #1,anz_vbls       ; 25 fps
fo_phase5:    lea       fo_p5_data+6(pc),a0
              moveq     #FO5_ANZ/2-1,d7
              moveq     #2,d0
              moveq     #1,d1
              moveq     #2,d2
fo5_lp:       add.w     d0,(a0)
              add.w     d1,10(a0)
              exg       d0,d2
              exg       d1,d2
              lea       32(a0),a0
              dbra      d7,fo5_lp
              bra.w     fo_clr_scr

fo_p1_data:   DC.W      1                 ; Phase 1
              DC.W      KUGEL_BIG,STATIC
fo_p2_data:   DC.W      2
fp_p2_obj1:   DC.W      SPI_STERN,FULL,0,0,0,28,48,-200
              DC.W      SPI_STERN2,FULL,0,0,0,-28,-48,-200
fo_p3_data:   DC.W      7
              DC.W      PFEIL,MOVE,0,-1*FO_ABSTAND,0
              DC.W      PFEIL,MOVE,0,0*FO_ABSTAND,0
              DC.W      PFEIL,MOVE,0,1*FO_ABSTAND,0
              DC.W      PFEIL,MOVE,0,2*FO_ABSTAND,0
              DC.W      PFEIL,MOVE,0,3*FO_ABSTAND,0
              DC.W      PFEIL,MOVE,0,4*FO_ABSTAND,0
              DC.W      PFEIL,MOVE,0,5*FO_ABSTAND,0
fo_p4_data:   DC.W      4
              DC.W      LOGO_E_3D,FULL,0,0,0,-50,-60+300,250
              DC.W      LOGO_E_3D,FULL,0,0,0,220,0+300,340
              DC.W      LOGO_E_3D,FULL,0,0,0,-185,100+300,480
              DC.W      LOGO_E_3D,FULL,0,0,0,87,-120+300,290
FO5_ANZ       EQU       12
fo_p5_data:   DC.W      FO5_ANZ

fo_logo:      DC.W      0,0,600           ; Farbe des Logos.
              DC.W      0,0,300           ; Farbe des Hintergrunds im Logo.

; Die Grundpaletten: Aufbau: Plane 0,1,2,3
fo_src_pals:  DC.W      FO_INTERPOL       ; Kugel.
              DC.W      600,0,800,500,0,700,400,0,600,300,0,500 ; Lila
              DC.W      FO_DECKEND        ; Sterne.
              DC.W      800,700,0,600,500,0,400,300,0,200,100,0 ; Gelb
              DC.W      FO_DECKEND        ; Pfeile.
              DC.W      700,500,0,500,300,0,600,200,600,800,400,800
              DC.W      FO_DECKEND        ; "E"s.
              DC.W      500,500,600,700,700,800,300,300,400,900,900,1000
              DC.W      FO_DECKEND
              DC.W      700,700,700,500,500,500,300,300,300,0,0,0

; Einblendungszeiten der einzelnen Phasen (in berechneten Frames).
FO_P1         EQU       3                 ; Phase 1
FO_P2         EQU       FO_P1+200         ;       2
FO_P3         EQU       FO_P2+160         ;       3
FO_P4         EQU       FO_P3+250         ;       4
fo_tab:       DC.W      FO_P1,0,0,15      ; Startframe, Phase (Routine/Farbe)
              DC.L      fo_p1_data
              DC.W      FO_P2,1,0,15      ; Phase 2: Stern dreht sich am
              DC.L      fo_p2_data        ;          unteren Bildrand.
              DC.W      FO_P3,2,0,15      ; Phase 3: Pfeil dich fit.
              DC.L      fo_p3_data
              DC.W      FO_P4,3,0,15      ;       4: Die "E"s fliegen so rum.
              DC.L      fo_p4_data
              DC.W      FO_P4+375,-1      ; Endkennung.

*****************************************************************************
*  "Der Beweis, daû selbst ich so toll bin uns Poly einshaden kann !!!"     *
*  Da die Routs so lame sind, werden viele schîne Pics eingeblendet...      *
*****************************************************************************
ANZ_OR        EQU       96                ; Anzahl Zeilen Orange-weiû Verlauf.
GB_BACK       EQU       $000f             ; Hintergrund auf Startscreen.
GB_LX         EQU       1000
GB_LY         EQU       1000
GB_LZ         EQU       -1000
GB_ENDED      EQU       25*8

GB_WAIT0      EQU       20                ; Wartezeit am Anfang (VBLs)
GB_WAIT1      EQU       85                ; Wartezeit erstes Bild.
GB_WAIT_X     EQU       140               ; Wartezeit drittes Bild.
GB_ANZ_ZB     EQU       200               ; Anz. VBLs fÅr's Zwischenbild.
gb_init:      st        disable_sync      ; Am Anfang etwas warten.
              move.w    #GB_WAIT0,d7
              bsr.w     vsync_xx

              suba.l    a0,a0             ; Aniblock laden.
              moveq     #RELOAD_GB,d0
              bsr.w     new_ani_blk       ; "bs2.dat", GP-Proof, Expl. Dung.

              movea.l   scr_lst_32k+4,a0
              lea       (640*240.l,a0),a1
              bsr.w     clr_mem

              bsr.w     vsync

              move.l    scr_lst_32k+4,d0
              SET_V_ADR d0,d1             

              lea       D_gb_pic1,a0      ; Bild decrunchen.
              movea.l   scr_lst_256,a1
              bsr.w     ice_decrunch

              move.b    #ST_CONST,shading ; Festshading...
              move.b    #aus,pals         ; "Irreale" Paletten

              lea       def_beo(pc),a0
              moveq     #0,d0             ; Screens NICHT lîschen.
              moveq     #2,d1             ; Gouraud High-Colour
              moveq     #4,d2             ; (fÅr Debugging)
              moveq     #2,d3             ; Anzahl VBLs / Pic.
              bsr.w     set_world
              st        disable_sync

              movea.l   scr_lst_256,a0    ; Bild einfaden.
              movea.l   scr_lst_32k+4,a1
              bsr.w     hc_show1
              st        disable_sync
              move.w    #GB_WAIT1,d7      ; Bissle warten, noch...
              bsr.w     vsync_xx

;             move.l    scr_lst_32k+4,d0
;             SET_V_ADR d0,d1
;             clr.l     $ffff9800.w       ; Rand schwarz.

              lea       GB_COL1,STARTCOL  ; Farbverlauf berechnen:
              lea       GB_COL2,ENDCOL    ; hellblau - weiû - orange
              lea       anim_buf,CALC_PAL ; (Der realistische Sonnen-
              moveq     #ANZ_OR,COLSTEPS  ; untergang, Herr Heine).
              bsr.w     CALC_PAL_VDI
              lea       GB_COL2,STARTCOL
              lea       GB_COL3,ENDCOL
              lea       anim_buf+ANZ_OR*6,CALC_PAL
              move.w    #240-ANZ_OR,COLSTEPS
              bsr.w     CALC_PAL_VDI
              lea       anim_buf,VDI_PAL  ; Gesamte Palette in Falcon-Highcol-
              lea       anim_buf,DEST_PAL ; ourformat konvertieren.
              move.w    #240,COLSTEPS
              bsr.w     VDI_XGA

              lea       anim_buf,a0       ; Ganze Palette in Format fÅr die
              lea       240*4(a0),a1      ; Lîschroutine bringen: jede Farbe
              move.w    #240-1,d7         ; doppelt, um Register mit Wert
gb_konv_cols: move.w    (a0),(a1)+        ; schnell initialisieren zu kînnen.
              move.w    (a0)+,(a1)+
              dbra      d7,gb_konv_cols

              lea       scr_lst_32k,a6    ; Alle Screens mit Farbverlauf fÅllen
              lea       anim_buf+240*4*2,a5
              movea.l   (a6),a0           ; Ersten Screen richtig fÅllen.
gb_fill_1st:  move.w    #SCR_HIGH-1,d7    ; 240 Zeilen
gb_fill_line: move.l    -(a5),d0          ; Farbtabelle verkehrtherum (wegen
              move.l    d0,d1             ; der normalen Lîschrout).
              move.l    d0,d2
              move.l    d0,d3
              move.l    d0,d4
              move.l    d0,d5
              move.l    d0,a1
              move.l    d0,a2
              move.l    d0,a3
              move.l    d0,a4
          REPEAT
              movem.l   d0-d5/a1-a4,(a0)
              lea       40(a0),a0
          UNTIL  #(SCR_WIDE/20-1)
              dbra      d7,gb_fill_line   ; NÑchste Linie des "Referenzscreens"

              moveq     #ANZ_SCREENS-3,d7 ; Die restlichen Screens mit Kopie
              movea.l   (a6)+,a5          ; des Ersten fÅllen.
              addq.l    #4,a6             ; Zweiter Screen zum Einfaden: Scr.
gb_fill_scr:  movea.l   (a6)+,a0          ; Die Screens mit dem Urbild fÅllen.
              movea.l   a5,a4
              move.w    #SCR_HIGH-1,d6
gb_cpy_line:
OFF           SET       0
        REPEAT
              movem.l   (a4)+,d0-d5/a1-a2
              movem.l   d0-d5/a1-a2,OFF(a0)
OFF           SET       OFF+32
        UNTIL #(SCR_WIDE/16)-1
              lea       640(a0),a0
              dbra      d6,gb_cpy_line
              dbra      d7,gb_fill_scr

              lea       lightsource(pc),a0
              move.w    #GB_LX,(a0)+
              move.w    #GB_LY,(a0)+
              move.w    #GB_LZ,(a0)+

              lea       hc_cube1+4(pc),a0
              move.w    (D_gb_smooth2.l,pc),(a0)+
              move.w    (D_gb_smooth3.l,pc),(a0)+
              move.w    (D_gb_smooth1.l,pc),(a0)+

              move.l    scr_lst_32k,screen      ; Erstes Objekt auf ersten Scr.
              lea       gb_data1(pc),a0         ; setzen, es ist beim Einfaden
              bsr.w     obj_handler             ; schon vorhanden.

              movea.l   scr_lst_32k,a0    ; Erster Screen einblenden.
              movea.l   scr_lst_32k+4,a1
              bsr.w     hc_show1

              st        disable_sync
              move.l    scr_lst_32k+4,screen    ; Objekt auch auf zweiten Scr.
              lea       gb_data1(pc),a0
              bsr.w     obj_handler
              clr.b     disable_sync

              move.w    vbl_counter(pc),anim_buf
              move.l    #$1,akt_scr             ; GefÅllte Screens anzeigen.
              rts

gb_frame:     move.w    vbl_counter(pc),d0      ; Das Objekt noch ein biûchen
              sub.w     anim_buf,d0             ; regungslos belassen.
              cmp.w     #20,d0
              bgt.s     gb_move
              rts

gb_move:      move.w    gb_count(pc),d0   ; Counter fÅr nichtlineare Bewegung
              addq.w    #1,d0             ; der Kanten.
              andi.w    #255,d0
              bne.w     gb_no_phase       ; Ende der WÅrfel ?

; Das Ende der WÅrfel: Ausblenden und Zwischenbild einblenden,
; dann auf die Animation mit 4 wilden Cubes.

              moveq     #28,d7            ; Den aktuellen Buffer noch etwas
              bsr.w     vsync_xx          ; leerspielen lassen, aber dann
              st        disable_sync      ; den Sync sperren.

              lea       D_saeulen,a0      ; Zwischenbild auf aktuellen log.
              movea.l   screen(pc),a1     ; Screen entpacken (dabei noch die
              pea       (a1)              ; Animation weiterlaufen lassen).
              bsr.w     ice_decrunch

              movea.l   (sp),a0           ; Das Bild ist zwar gepackt, dafÅr
              movea.l   screen(pc),a1
              move.w    #640*240/16-1,d0
              bsr.w     cpy_mem16

              movea.l   (sp)+,a0          ; Zwischenbild einblenden.
              movea.l   screen+4(pc),a1
              bsr.w     hc_show1
              st        disable_sync

              move.w    #GB_ANZ_ZB,d7     ; Zwischenbild stehenlassen.
              bsr.w     vsync_xx

              clr.w     ani_frm           ; Framecounter zurÅck.
              move.l    #gb_frame2,world_frame  ; Neue Frameroutine.
              move.l    #gb_data2,world_data    ; Neue Weltdaten.
              move.b    #ST_CONST,shading       ; Wieder konstantes Shading.
              move.b    #aus,pals               ; Wieder irreale Paletten.
              clr.l     beo                     ; Beobachter in den Ursprung.
              clr.w     beo+4

              move.l    clr_scr(pc),-(sp)
              move.l    screen,clr_scr    ; Den ganzen Screen (also alle 240
              add.l     #640*240,clr_scr
              lea       anim_buf+240*4,a6 ; Zeilen) mit Farbverlauf fÅllen.
              move.w    #239,d7
              bsr.w     hc_clrscreen
              move.l    (sp)+,clr_scr

              bsr.w     gb_frame2         ; Szene mit den vier wilden WÅrfeln
              lea       gb_data2(pc),a0   ; vorberechnen.
              bsr.w     obj_handler

              movem.l   screen(pc),a0-a1  ; Anzeigen und dann raus.
              bra.w     hc_show1          

gb_no_phase:  move.w    d0,gb_count
              move.w    d0,d1
gb_no_phase2: movea.l   world_data(pc),a0
              addq.l    #6,a0

              cmp.w     #255,gb_count     ; Ein Frame vor Schluû ?
              bne.s     gb_use_tab        ; ja --> keine Drehung mehr !

              clr.w     d1

gb_use_tab:   move.w    (D_gb_smooth2.l,pc,d1.w*2),(a0)+
              move.w    (D_gb_smooth3.l,pc,d1.w*2),(a0)+
              move.w    (D_gb_smooth1.l,pc,d1.w*2),(a0)+

              sub.l     #12*640+120,clr_scr     ; Nur Block hinter dem Cube
              bmi.s     gb_rts                  ; lîschen.
              lea       anim_buf+240*4+(20+12)*4,a6 ; (Farbverlauf)
              move.w    #199-23,d6
              bra.w     hc_colclr
gb_rts:       rts

; Bewegungsroutine fÅr die kleinen WÅrfel...
gb_frame2:    cmp.w     #GB_ENDED,ani_frm ; Spuck schon zu Ende ?
              blt.s     gb_no_ended

              st        disable_sync
              lea       D_mugpic3,a0      ; Drittes Bild zeigen.
              movea.l   screen(pc),a1
              bsr.w     ice_decrunch

              movem.l   screen(pc),a0-a1
              bsr.w     hc_show1
              st        disable_sync

              move.w    #GB_WAIT_X,d7
              bsr.w     vsync_xx

              movea.l   screen(pc),a0     ; Unsichtbaren Screen lîschen und
              lea       (640*240.l,a0),a1 ; den leeren Inhalt auf aktuellen
              bsr.w     clr_mem           ; Screen kopieren.

              movem.l   screen(pc),a0-a1
              bsr.w     hc_show1
              st        disable_sync      ; NÑchste Ani:

              moveq     #SZ_DOOM_ENG,d0   ; "Doom Engine" starten.
              bra.w     new_animat

gb_no_ended:  move.w    gb_count(pc),d1
              addq.w    #1,d1
              andi.w    #255,d1
              move.w    d1,gb_count

              move.w    (D_gb_smooth2.l,pc,d1.w*2),d2
              move.w    (D_gb_smooth3.l,pc,d1.w*2),d3
              move.w    (D_gb_smooth1.l,pc,d1.w*2),d4

              lea       gb_data2+6(pc),a0
              move.w    d2,48(a0)
              move.w    d3,32(a0)
              move.w    d4,16(a0)
              move.w    d2,(a0)+
              move.w    d2,48(a0)
              move.w    d3,32(a0)
              move.w    d4,16(a0)
              move.w    d3,(a0)+
              move.w    d4,48(a0)
              move.w    d2,32(a0)
              move.w    d3,16(a0)
              move.w    d4,(a0)+

              moveq     #2,d0             ; Beobachter rotieren: Wir fliegen
              moveq     #2,d1             ; "um" das Objekt...
              moveq     #-2,d2
              lea       beovek(pc),a0
              bsr.w     rot_d03

              lea       anim_buf+240*4+20*4,a6
              move.w    #SCR_DY-1+1,d7
              bra.w     hc_clrscreen

gb_data1:     DC.W      1
hc_cube1:     DC.W      HC_CUBE_2,FULL,45,45,45,0,0,0

gb_data2:     DC.W      4
              DC.W      HC_CUBE_3,FULL,45,45,45,-50,0,-50
              DC.W      HC_CUBE_3,FULL,45,45,45,50,0,-50
              DC.W      HC_CUBE_3,FULL,45,45,45,-50,0,50
              DC.W      HC_CUBE_3,FULL,45,45,45,50,0,50

;GB_COL1      EQU       _ORANGE
;GB_COL2      EQU       _WHITE
;GB_COL3      EQU       gb_skyblue
GB_COL1:      DC.W      0,1000,500        ; ~ Seagreen
GB_COL2:      DC.W      1000,1000,1000
GB_COL3:      DC.W      0,950,1000

gb_skyblue:   DC.W      0,950,1000        ; Helles Blau fÅr Himmel.
gb_count:     DC.W      0

*****************************************************************************
* "World Plates": Eine 3*3*3 Matrix rotierender Platten.                    *
*****************************************************************************
ANZ_NO_ROT    EQU       150               ; ~ Frames Plates nicht rotieren.
ANZ_SM_ROT    EQU       200               ; ~ Frames weich bewegen.
WP_END        EQU       750               ; ~ Frames nach Endbewegung.
WP_WAIT0      EQU       150               ; ~ Bleibt Bild am Anfang stehen.

WP_BACK_R     EQU       0 ;350            ; Hintergrund (VDI-Format)
WP_BACK_G     EQU       0 ;350
WP_BACK_B     EQU       0 ;600
WP_FRONT_R    EQU       0                 ; Vordergrund.
WP_FRONT_G    EQU       300
WP_FRONT_B    EQU       550

WP_NULLPAL    EQU       anim_buf+256
wp_init:      suba.l    a0,a0             ; Tabellen dieses Screens und die
              moveq     #RELOAD_WP,d0     ; Daten des Extros laden.
              bsr.w     new_ani_blk

              move.w    #WP_WAIT0,d7      ; Das Bild noch etwas stehenlassen.
              bsr.w     vsync_xx

              movea.l   scr_lst_32k,a0    ; Total egal, Bild ist auf ALLEN Scr-
              lea       (640*240.l,a0),a1 ; eens.
              bsr.w     clr_mem

              movem.l   scr_lst_32k,a0-a1 ; Bild ausblenden.
              move.l    a1,d0
              bsr.w     vsync
              bsr.w     set_scr_adr
              bsr.w     hc_show1
              st        disable_sync

              lea       wp_basecols(pc),a5      ; Alle Paletten der Animation
              lea       anim_buf,a6             ; berechnen.
              moveq     #3-1,d3
wp_calc_pals: movea.l   a6,a4             ; Buffer.

              move.w    #WP_BACK_R,(a4)+  ; Hintergrundfarbe immer gleich.
              move.w    #WP_BACK_G,(a4)+
              move.w    #WP_BACK_B,(a4)+

              movea.l   a5,STARTCOL       ; Ersten 4 Farben berechnen.
              lea       6(a5),ENDCOL
              movea.l   a4,CALC_PAL
              moveq     #4,COLSTEPS
              bsr.w     CALC_PAL_VDI

              lea       12(a5),STARTCOL   ; Zweiten 4 Farben berechnen.
              lea       18(a5),ENDCOL
              lea       4*6(a4),CALC_PAL
              moveq     #4,COLSTEPS
              bsr.w     CALC_PAL_VDI

              lea       8*6(a4),a4        ; Farben 9-15 konstant.
              lea       wp_front(pc),a3
              moveq     #7-1,d0
cpy_wp_front: move.l    (a3)+,(a4)+
              move.w    (a3)+,(a4)+
              dbra      d0,cpy_wp_front

              movea.l   a6,VDI_PAL        ; Palette in 3*256-Bit Format.
              movea.l   a6,DEST_PAL
              moveq     #16,COLSTEPS
              bsr.w     VDI_9800

              movea.l   a6,a0             ; Palette auf 256000 Farben runter-
              moveq     #16,d7            ; schrauben.
              bsr.w     mask_pal

              lea       16*4(a6),a6       ; NÑchster Buffer.
              lea       24(a5),a5         ; NÑchsten Fade-Grundfarben.
              dbra      d3,wp_calc_pals

              lea       def_beo(pc),a0    ; 16 Farben / 25 fps.
              moveq     #$ff,d0           ; (Beobachter wird auf Default ge-
              moveq     #1,d1             ; setzt, da er eh jeden VBL versetzt
              moveq     #4,d2             ; wird...)
              moveq     #2,d3
              bsr.w     set_world

              moveq     #-1,d0            ; Alle Register auf Lîschen mit
              moveq     #-1,d1            ; Farbe 15 einrichten.
              moveq     #-1,d2
              moveq     #-1,d3
              moveq     #-1,d4
              moveq     #-1,d5
              move.l    d0,a1
              move.l    d0,a2
              move.l    d0,a3
              move.l    d0,a4

              lea       scr_lst_16,a6     ; Auf allen Screens die untere
              moveq     #_16_ANZ_SCREENS-1,d7   ; Statuszeile auf Farbe 15
wp_clr_stat:  move.l    (a6)+,a0
              adda.l    #(VISIBLE_Y1+21)*_16_BYTES_SCAN,a0
              moveq     #20-1,d6
wp_clr_status:
          REPEAT
              movem.l   d0-d5/a1-a4,-(a0) ; 80 Pixel lîschen
          UNTIL  #(SCR_DX/80-1)
              dbra      d6,wp_clr_status  ; NÑchste Zeile lîschen.
              dbra      d7,wp_clr_stat    ; NÑchste Statuszeile.

              lea       WP_NULLPAL,a0     ; Nullpalette erzeugen.
              lea       256*4(a0),a1
              bsr.w     clr_mem

              lea       anim_buf,a0       ; Fade installieren.
              bra.w     inst_norm_fade

; Frameroutine: ein bissle aufwendig, wegen der 3 (4) Phasen und der eigenen
; Lîschroutinen.
wp_frame:     lea       D_wp_cos1,a4      ; Die 4 "SatellitenwÅrfel" drehen
              lea       D_wp_swing,a5     ; sich immer und bewegen sich nett
              lea       e_tab(pc),a6      ; in der Hîhe.
              moveq     #127,d0
              movem.w   (a6),d3-d6        ; Bewegungstabelle und Rotationstab
              addq.w    #1,d3             ; haben beide 128 EintrÑge...
              addq.w    #1,d4
              addq.w    #1,d5
              addq.w    #1,d6
              and.w     d0,d3
              and.w     d0,d4
              and.w     d0,d5
              and.w     d0,d6
              movem.w   d3-d6,(a6)        ; Neue TabstÑnde der WÅrfel.

              lea       e_cubes+4(pc),a0  ; WÅrfelrotationen setzen (Rot-
              move.w    (a4,d3.w*2),d0    ; ationen weich, d.h. nicht linear,
              move.w    (a4,d4.w*2),d1    ; wirkt ein wenig harmonischer).
              move.w    (a4,d5.w*2),d2
              move.w    d0,(a0)+
              move.w    d1,(a0)+
              move.w    d2,(a0)+
              move.w    (a5,d3.w*2),2(a0)
              lea       10(a0),a0
              move.w    d2,(a0)+
              move.w    d1,(a0)+
              move.w    d0,(a0)+
              move.w    (a5,d4.w*2),2(a0)
              lea       10(a0),a0
              move.w    d1,(a0)+
              move.w    d0,(a0)+
              move.w    d2,(a0)+
              move.w    (a5,d5.w*2),2(a0)
              lea       10(a0),a0
              move.w    d2,(a0)+
              move.w    d0,(a0)+
              move.w    d1,(a0)+
              move.w    (a5,d6.w*2),2(a0)

              move.w    wp_beomove(pc),d0 ; Beobachter um den ganzen Turm
              addq.w    #1,d0             ; fahren lassen.
              cmpi.w    #360,d0
              blt.s     wp_beo_rot
              clr.w     d0
wp_beo_rot:   move.w    d0,wp_beomove
              MULF_3    d0,d1
              movem.l   (D_wp_beo.l,pc,d0.w*4),d0-d2
              movem.l   d0-d2,beovek      ; Vektoren und Koordinaten setzen.

              tst.w     wp_mode(pc)       ; Wie wird gerade bewegt ?
              beq.s     wp_move_wild      ; == 0 --> Alle drehen individuell.
              bgt.s     wp_move_sin       ;  > 0 --> Alle drehen gleichfîrmig.

              addq.w    #1,wp_mode        ;  < 0 --> Nur Beobachter dreht sich.
              bne.w     clr_wp            ; Die Starre aufheben ???

              lea       anim_buf+17*4,a0  ; In Farben dieser Phase umfaden.
              moveq     #64,d5
              moveq     #1,d6             ; Farben 9-15 bleiben konstant:
              moveq     #6,d7             ; nicht mitfaden.
              bsr.w     inst_fade

              move.w    #ANZ_SM_ROT,wp_mode
              bra.w     clr_wp

wp_move_sin:  subq.w    #1,wp_mode        ; Counter bis zur wilden Bewegung.
              bne.s     wp_no_fade2       ; Wilde Bewegung hat eigene Farben.

              lea       anim_buf+33*4,a0
              moveq     #64,d5
              moveq     #1,d6
              moveq     #6,d7
              bsr.w     inst_fade

wp_no_fade2:  move.w    wp_smo_cnt(pc),d0 ; Bewegungsart Nummer 1 (in wp):
              addq.w    #1,d0             ; Alle FlÑchen werden sinusfîrmig
              cmpi.w    #60,d0            ; um eine Achse bewegt. Alle FlÑchen
              blt.s     wp_do_smo         ; um die gleiche Achse.
              clr.w     d0
wp_do_smo:    move.w    d0,wp_smo_cnt
              move.w    (D_smooth1.l,pc,d0.w*2),d0
              lea       wp_data+2+4(pc),a0
              moveq     #27-1,d7
wp_cpy_lp:    move.w    d0,(a0)
              lea       16(a0),a0
              dbra      d7,wp_cpy_lp
              bra.w     clr_wp

wp_move_wild: cmp.w     #WP_END-128,ani_frm     ; So langsam das Demo ausfaden?
              bne.s     wp_no_end2

              lea       WP_NULLPAL,a0
              bsr.w     inst_norm_fade
              bra.s     wp_no_end

wp_no_end2:   cmp.w     #WP_END,ani_frm   ; Letzt Ani abbrechen ?
              beq.w     extro

wp_no_end:    move.w    wp_smo_cnt(pc),d0 ; Die FlÑchen gegeneinander drehen.
              addq.w    #1,d0             ; Die inneren werden nach einem
              cmpi.w    #60,d0            ; Cosinus gedreht, die Ñuûeren auf
              blt.s     wp_do_smo2        ; einer Sinusbahn gegeneinander.
              clr.w     d0
wp_do_smo2:   move.w    d0,wp_smo_cnt
              move.w    (D_smooth2.l,pc,d0.w*2),d1
              move.w    (D_smooth1.l,pc,d0.w*2),d0
              move.w    #719,d2           ; Bewegung lÑuft gegeneinander...
              sub.w     d0,d2

              lea       wp_data+6(pc),a0  ; Innere Reihe rotiert um x-Achse,
              moveq     #27/3-1,d7        ; die Ñuûeren um die y-Achse, wobei
wp_rot_pls:   move.w    d0,16*0+2(a0)     ; diese auch schon leicht um die
              move.w    d1,16*1+0(a0)     ; x-Achse gedreht sind.
              move.w    d2,16*2+2(a0)
              lea       48(a0),a0
              dbra      d7,wp_rot_pls

; WP hat eigene Lîschroutine, um "Pseudohorizont" hinzubekommen...
; "Boden" hat Farbe 15, "Horizont" Farbe 0.
clr_wp:       moveq     #60/4-1,d6
              moveq     #(204-60)/4-1,d7
              bra.w     k_horizont

wp_bye:       rts

wp_smo_cnt:   DC.W      0
wp_mode:      DC.W      -ANZ_NO_ROT

; Farben 9-15: Konstant, Farbe 15 "ist" der Horizont.
wp_front:     DC.W      900,900,950,800,800,850,700,700,750,600,600,650
              DC.W      500,500,550,400,400,450,0,200,400

wp_basecols:  DC.W      800,400,0,400,200,0     ; Frontseiten Farbverlauf.
              DC.W      0,400,800,0,200,400     ; FlÑchenrÅcken Farbverlauf.

              DC.W      0,800,0,0,400,0   ; Farben Phase 2.
              DC.W      400,800,0,800,400,0

              DC.W      800,0,0,400,0,0
              DC.W      800,800,0,400,400,0

wp_beomove:   DC.W      0

WP_AB         EQU       240               ; Abstand der Platten (alle Achsen).
wp_data:      DC.W      28+4
; Erste Lage.
              DC.W      XY_QUAD_3,FULL,0,0,0,-WP_AB,-WP_AB,-WP_AB
              DC.W      XY_QUAD_3,FULL,0,0,0,0,-WP_AB,-WP_AB
              DC.W      XY_QUAD_3,FULL,0,0,0,WP_AB,-WP_AB,-WP_AB
              DC.W      XY_QUAD_3,FULL,0,0,0,-WP_AB,0,-WP_AB
              DC.W      XY_QUAD_3,FULL,0,0,0,0,0,-WP_AB
              DC.W      XY_QUAD_3,FULL,0,0,0,WP_AB,0,-WP_AB
              DC.W      XY_QUAD_3,FULL,0,0,0,-WP_AB,WP_AB,-WP_AB
              DC.W      XY_QUAD_3,FULL,0,0,0,0,WP_AB,-WP_AB
              DC.W      XY_QUAD_3,FULL,0,0,0,WP_AB,WP_AB,-WP_AB
; Zweite Lage.
              DC.W      XY_QUAD_1,FULL,0,0,0,-WP_AB,-WP_AB,0
              DC.W      XY_QUAD_1,FULL,0,0,0,0,-WP_AB,0
              DC.W      XY_QUAD_1,FULL,0,0,0,WP_AB,-WP_AB,0
              DC.W      XY_QUAD_1,FULL,0,0,0,-WP_AB,0,0
              DC.W      XY_QUAD_1,FULL,0,0,0,0,0,0
              DC.W      XY_QUAD_1,FULL,0,0,0,WP_AB,0,0
              DC.W      XY_QUAD_1,FULL,0,0,0,-WP_AB,WP_AB,0
              DC.W      XY_QUAD_1,FULL,0,0,0,0,WP_AB,0
              DC.W      XY_QUAD_1,FULL,0,0,0,WP_AB,WP_AB,0

; Dritte Lage.
              DC.W      XY_QUAD_2,FULL,0,0,0,-WP_AB,-WP_AB,WP_AB
              DC.W      XY_QUAD_2,FULL,0,0,0,0,-WP_AB,WP_AB
              DC.W      XY_QUAD_2,FULL,0,0,0,WP_AB,-WP_AB,WP_AB
              DC.W      XY_QUAD_2,FULL,0,0,0,-WP_AB,0,WP_AB
              DC.W      XY_QUAD_2,FULL,0,0,0,0,0,WP_AB
              DC.W      XY_QUAD_2,FULL,0,0,0,WP_AB,0,WP_AB
              DC.W      XY_QUAD_2,FULL,0,0,0,-WP_AB,WP_AB,WP_AB
              DC.W      XY_QUAD_2,FULL,0,0,0,0,WP_AB,WP_AB
              DC.W      XY_QUAD_2,FULL,0,0,0,WP_AB,WP_AB,WP_AB

; Unser seltsames Gebilde ist eingezÑunt: das ist der Zaun.
wp_ring:      DC.W      RING_1,FULL,180,0,0,0,200,0

e_cubes:      DC.W      E_CUBE,FULL,90,90,90,0,25,600
              DC.W      E_CUBE,FULL,90,90,90,0,25,-600
              DC.W      E_CUBE,FULL,90,90,90,600,25,0
              DC.W      E_CUBE,FULL,90,90,90,-600,25,0

e_tab:        DC.W      0,63,127,195

*****************************************************************************
*  INTRO: "Dieses Papiertaschentuch wurde aus Mangos gefertigt".            *
*****************************************************************************
intro_init:   lea       def_beo(pc),a0
              moveq     #$ff,d0
              moveq     #1,d1
              moveq     #4,d2
              moveq     #1,d3
              bsr.w     set_world

              lea       sw_pal,a0
              bsr.w     set_pal

              rts

intro_vbl:    rts
intro_frame:  subq.w    #1,llk
              bra.w     clr_screen
intro_data:   DC.W      1
              DC.W      OBJ_INTRO1,MOVE,50
llk:          DC.W      0,0

*****************************************************************************
*  Wir benutzen keine DOOM-Engine, dafÅr explodiert unser Dungeon nach      *
*  getaner Arbeit... (hehe)                                                 *
*****************************************************************************
DE_COL_PAL    EQU       anim_buf+128      ; Normale Palette.
DE_EXPL_COL   EQU       anim_buf+1024     ; Feuerpalette.

de_beo:       DC.W      0,0,0,0,-50,184
de_init:      
        IFEQ  (STARTANI-SZ_DOOM_ENG)
              moveq     #RELOAD_GB,d0
              suba.l    a0,a0
              bsr.w     new_ani_blk
        ENDIF

              lea       de_beo(pc),a0
              moveq     #$ff,d0
              moveq     #1,d1
              moveq     #4,d2             ; 16 Farben.
              moveq     #2,d3             ; 2 VBL-Standart.
              bsr.w     set_world

              lea       DE_HELL,STARTCOL  ; Farbpalette berechnen.
              lea       DE_DUNKEL,ENDCOL
              lea       DE_COL_PAL,CALC_PAL
              moveq     #14,COLSTEPS
              bsr.w     CALC_PAL_VDI
              lea       DE_COL_PAL,VDI_PAL
              lea       anim_buf+4,DEST_PAL
              moveq     #14,COLSTEPS
              bsr.w     VDI_9800          ; Farbpalette ins Falcon-Format.
              lea       DE_COL_PAL,a0
              moveq     #14,d7
              bsr.w     mask_pal

              lea       DE_EXPL_COL,a6    ; Hintergrundfarbe.
              move.l    de_exp_back(pc),(a6)+
              move.w    de_exp_back+4(pc),(a6)+

              lea       de_exp_col1(pc),STARTCOL    ; Farbverlauf fÅr's Explod-
              lea       de_exp_col2(pc),ENDCOL      ; ieren errechnen.
              movea.l   a6,CALC_PAL
              moveq     #15,COLSTEPS
              bsr.w     CALC_PAL_VDI
              lea       DE_EXPL_COL,VDI_PAL
              movea.l   VDI_PAL,DEST_PAL
              moveq     #16,COLSTEPS
              bsr.w     VDI_9800
              lea       DE_EXPL_COL,a0
              moveq     #16,d7
              bsr.w     mask_pal

              lea       anim_buf,a0
              move.l    #DE_BACK,(a0)     ; Hintergrundfarbe.
              move.l    #DE_FRONT,60(a0)  ; Vordergrund.
              bsr.w     inst_norm_fade

              moveq     #15,d7            ; Ausfadepalette.
              lea       128(a0),a0
de_clr_fo:    clr.l     (a0)+
              dbra      d7,de_clr_fo
              rts

de_exp_back:  DC.W      0,0,0
de_exp_col1:  DC.W      557,137,137       ; Firebrick
de_exp_col2:  DC.W      900,400,0         ; Orange.

DE_BACK       EQU       $00000000
DE_FRONT      EQU       $88000044         ; Blutrote Farbe des Kreuzes.
DE_HELL:      DC.W      220,690,870
DE_DUNKEL:    DC.W      20,130,370

FIREWORKS     EQU       3200              ; Ab Beo-Z gibts Feuerwerk !
DE_WAIT0      EQU       0                 ; ~ VBLs, vor dem Losfahren.
DE_WAIT1      EQU       25                ; ~ VBLs, vor ersten Wand
DE_WAIT2      EQU       88                ; ~ VBLs, vor Kreuz.
DE_WAIT3      EQU       5                 ; ~ VBLs, vor ZurÅckfahren.
DE_WAIT4      EQU       150               ; ~ VBLs, bevor nach Explosion das
                                          ;   Fade-Out gestartet wird.
DE_WAIT_POEM  EQU       135               ; ~ Frames bis Gedicht kommt.
*** Ziemlich aufwendige Phasenweise Bewegung durchs und des "Dungeons"... ***
de_frame:     lea       beovek(pc),a0

              move.b    de_phase(pc),d0   ; Phasenflag.
              bpl.s     de_move           ; < 0 --> Anfangsverzîgerung.

              addq.b    #1,de_phase
              rts

de_move:      bgt.s     de_move_left      ; de_phase == 0 ? --> Nach vorne !

              addq.w    #6,10(a0)         ; Beobachter nach vorne schieben.
              cmpi.w    #1248,10(a0)      ; Ziel Phase 2 erreicht ?
              blt.w     clr_screen        ; Nein --> nur noch lîschen.

              addq.b    #1,de_phase       ; Auf Phase 3 gehen.
              move.w    vbl_counter(pc),de_wait_vbl
              bra.w     clr_screen

de_move_left: subq.b    #2,d0             ; Phase == 2 ?
              bne.w     de_no_exp         ; Nicht in Stellung bringen.

              move.w    vbl_counter(pc),d0      ; Noch ein bissle vor dem
              sub.w     de_wait_vbl(pc),d0      ; Kreuz warten, bevor bis
              cmpi.w    #DE_WAIT2,d0            ; zum Explodierpunkt bewegt
              bgt.s     de_mov_expl             ; wird ?
              bra.w     clr_screen

de_mov_expl:  move.w    #1,anz_vbls       ; Auf 50 fps gehen.

              cmp.w     #360,(a0)         ; Ganzes "Dungeon" in richtige Blick-
              beq.s     no_rot_ac         ; stellung bringen.
              moveq     #2,d0             ; (Rotation mit 2/0/2 sieht zwar
              moveq     #0,d1             ;  besser aus, lÑuft dann aber nicht
              moveq     #-2,d2            ;  mehr in einem VBL.)
              bsr.w     rot_d03

              cmp.w     #360,(a0)
              bne.w     clr_screen

              move.w    vbl_counter(pc),de_wait_vbl
              move.w    #DE_OHNE_KREUZ,de_data  ; Kreuz nicht mehr gebraucht.
              bra.w     clr_screen

no_rot_ac:    move.w    vbl_counter(pc),d0      ; Noch ein bissle vor dem
              sub.w     de_wait_vbl(pc),d0      ; Kreuz warten, bevor bis
              cmpi.w    #DE_WAIT3,d0            ; zum Explodierpunkt bewegt
              bgt.s     de_mov_expl2            ; wird ?
              bra.w     clr_screen

de_mov_expl2: cmp.w     #FIREWORKS,10(a0) ; Noch bis zur Explosionsstelle be-
              blt.w     move_to_expl      ; wegen ?

              lea       16.w,a3           ; Offset Winkel-->Winkel.
              lea       de_expl_mov(pc),a4      ; Movings Explode.
              lea       de_data_exp(pc),a5      ; Datenstruktur Explode.
              lea       de_expl_rot(pc),a6      ; Rotationen Explode.
              move.l    a5,world_data
              addq.l    #6,a5             ; Winkel erstes Objekt.
              moveq     #DE_OHNE_KREUZ-1,d7
de_rot_objs:  movem.w   (a4)+,d0-d2       ; Bewegungen.
              add.w     d0,6(a5)          ; Auf aktuelle Objektkoordinate
              add.w     d1,8(a5)          ; addieren.
              add.w     d2,10(a5)
              movem.w   (a6)+,d0-d2       ; Objektrotationen.
              move.l    a5,a0
              bsr.w     rot_d03           ; FlÑche rotieren.
              adda.l    a3,a5
              dbra      d7,de_rot_objs

              moveq     #0,d0             ; Auch wenn die FlÑchen wegspritzen,
              moveq     #0,d1             ; Beobachter seelenruhig weiter-
              moveq     #2,d2             ; rumdrehen lassen.
              lea       beovek(pc),a0
              bsr.w     rot_d03

              cmp.w     #-DE_WAIT_POEM,de_wait_2    ; Zeit fÅr's Gedicht ???
              bgt.s     de_not_yet

              lea       D_li_xlvi,a0      ; Gedicht setzen.
              moveq     #NOLOAD,d0
              bsr.w     set_poem

              moveq     #SZ_STARS,d0      ; NÑchste Animation: "Sternenhimmel"
              bra.w     new_animat

de_not_yet:   subq.w    #1,de_wait_2      ; Fade-Out starten ???
              bne.w     clr_screen

              lea       anim_buf+128,a0
              bsr.w     inst_norm_fade
              bra.w     clr_screen

move_to_expl: cmpi.w    #-80,6(a0)        ; Beo-X schon soweit rechts, daû das
              bge.s     de_bx_pos         ; "Dungeon" zentriert ist ?
              addq.w    #2,6(a0)
de_bx_pos:    add.w     #16,10(a0)        ; Beo-Z nach hinten verschieben.

              cmp.w     #FIREWORKS,10(a0)
              blt.s     no_expl_pal

              lea       DE_EXPL_COL,a0    ; Farben fÅr Explosion installieren.
              bsr.w     inst_norm_fade    

no_expl_pal:  moveq     #0,d0             ; Den Beobachter drehen lassen,
              moveq     #0,d1             ; gibt zusÑtzlichen "Is das scheiûe,
              moveq     #2,d2             ; aber es sieht nett aus"-Effekt.
              bsr.w     rot_d03
              bra.w     clr_screen

de_no_exp:    tst.b     de_wait(pc)       ; Fliegt er schon nach links ?
              bne.s     de_moved_lt

              move.w    vbl_counter(pc),d0      ; Geringe Zeit vorne an der
              sub.w     de_wait_vbl(pc),d0      ; Mauer warten, um Bewegung
              cmpi.w    #DE_WAIT1,d0            ; nicht zu abbrupt zu machen.
              sge       de_wait
              blt.w     clr_screen        ; Wenn er noch wartet --> Lîschen.

de_moved_lt:  cmp.w     #-340,6(a0)       ; Schon links angekommen ?
              bgt.s     d_move_left

              move.w    vbl_counter(pc),de_wait_vbl
              addq.b    #1,de_phase       ; NÑchste Phase.
              bra.w     clr_screen

d_move_left:  subq.w    #5,6(a0)          ; Nach links fahren.

              addq.w    #1,de_poi
              move.w    de_poi(pc),d0     ; Und Beobachterkipp simulieren.
              move.w    (D_si180_48.l,pc,d0.w*2),4(a0)

              bra.w     clr_screen

de_poi:       DC.W      0,0
de_phase:     DC.B      -DE_WAIT0         ; ~ Ruhezeit am Anfang.
de_wait:      DC.B      0                 ; ~ Ticks steht er vorne.
de_wait_2:    DC.W      DE_WAIT4          ; ~ Fade-Out Verzîgerung
de_wait_vbl:  DC.W      0

DE_OHNE_KREUZ EQU       29                ; Anzahl Objekte ohne Kreuz.
de_data:      DC.W      30
              DC.W      BOPLANE_1,MOVE,0,0,DP_LEN_Z*0   ; Einseitige Boden-
              DC.W      BOPLANE_2,MOVE,0,0,DP_LEN_Z*1   ; flÑchen...
              DC.W      BOPLANE_1,MOVE,0,0,DP_LEN_Z*2
              DC.W      BOPLANE_3,MOVE,0,0,DP_LEN_Z*3
              DC.W      BOPLANE_2,MOVE,170,0,DP_LEN_Z*3
              DC.W      BOPLANE_2,MOVE,0,0,DP_LEN_Z*4
              DC.W      BOPLANE_4,MOVE,0,0,DP_LEN_Z*5
              DC.W      PLANE_XZ_2,MOVE,-170,0,DP_LEN_Z*5
              DC.W      PLANE_XZ_3,MOVE,-340,0,DP_LEN_Z*5
              DC.W      PLANE_XZ_2,MOVE,-340,0,DP_LEN_Z*6

              DC.W      PLANE_XY_2,MOVE,170,-50,DP_LEN_Z/2+DP_LEN_Z*3
              DC.W      PLANE_XY_4,MOVE,0,-50,DP_LEN_Z/2+DP_LEN_Z*5
              DC.W      PLANE_XY_1,MOVE,-170,-50,DP_LEN_Z/2+DP_LEN_Z*4
              DC.W      PLANE_XY_3,MOVE,-340,-50,DP_LEN_Z/2+DP_LEN_Z*4
              DC.W      PLANE_XY_2,MOVE,-170,-50,DP_LEN_Z/2+DP_LEN_Z*5
              DC.W      PLANE_XY_4,MOVE,-340,-50,DP_LEN_Z/2+DP_LEN_Z*6

              DC.W      PLANE_YZ_1,MOVE,-85,-50,0
              DC.W      PLANE_YZ_2,MOVE,85,-50,0
              DC.W      PLANE_YZ_2,MOVE,-85,-50,DP_LEN_Z*1
              DC.W      PLANE_YZ_1,MOVE,85,-50,DP_LEN_Z*1
              DC.W      PLANE_YZ_2,MOVE,-85,-50,DP_LEN_Z*2
              DC.W      PLANE_YZ_3,MOVE,85,-50,DP_LEN_Z*2
              DC.W      PLANE_YZ_4,MOVE,-85,-50,DP_LEN_Z*3
              DC.W      PLANE_YZ_3,MOVE,-85,-50,DP_LEN_Z*4
              DC.W      PLANE_YZ_2,MOVE,85,-50,DP_LEN_Z*4
              DC.W      PLANE_YZ_4,MOVE,85,-50,DP_LEN_Z*5
              DC.W      PLANE_YZ_1,MOVE,-85-340,-50,DP_LEN_Z*5
              DC.W      PLANE_YZ_3,MOVE,-85-170,-50,DP_LEN_Z*6
              DC.W      PLANE_YZ_2,MOVE,-85-340,-50,DP_LEN_Z*6

              DC.W      KREUZ_3,MOVE,-340,-15,DP_LEN_Z*6

; Das ganze Dungeon nochmals, nur als BewegungsflÑchen...
de_data_exp:  DC.W      DE_OHNE_KREUZ
              DC.W      PLANE_XZ_1,FULL,0,0,0,0,0,DP_LEN_Z*0
              DC.W      PLANE_XZ_2,FULL,0,0,0,0,0,DP_LEN_Z*1
              DC.W      PLANE_XZ_3,FULL,0,0,0,0,0,DP_LEN_Z*2
              DC.W      PLANE_XZ_4,FULL,0,0,0,0,0,DP_LEN_Z*3
              DC.W      PLANE_XZ_3,FULL,0,0,0,170,0,DP_LEN_Z*3
              DC.W      PLANE_XZ_2,FULL,0,0,0,0,0,DP_LEN_Z*4
              DC.W      PLANE_XZ_1,FULL,0,0,0,0,0,DP_LEN_Z*5
              DC.W      PLANE_XZ_2,FULL,0,0,0,-170,0,DP_LEN_Z*5
              DC.W      PLANE_XZ_3,FULL,0,0,0,-340,0,DP_LEN_Z*5
              DC.W      PLANE_XZ_4,FULL,0,0,0,-340,0,DP_LEN_Z*6
              DC.W      PLANE_XY_1,FULL,0,0,0,170,-50,DP_LEN_Z/2+DP_LEN_Z*3
              DC.W      PLANE_XY_2,FULL,0,0,0,0,-50,DP_LEN_Z/2+DP_LEN_Z*5
              DC.W      PLANE_XY_4,FULL,0,0,0,-170,-50,DP_LEN_Z/2+DP_LEN_Z*4
              DC.W      PLANE_XY_3,FULL,0,0,0,-340,-50,DP_LEN_Z/2+DP_LEN_Z*4
              DC.W      PLANE_XY_2,FULL,0,0,0,-170,-50,DP_LEN_Z/2+DP_LEN_Z*5
              DC.W      PLANE_XY_1,FULL,0,0,0,-340,-50,DP_LEN_Z/2+DP_LEN_Z*6
              DC.W      PLANE_YZ_1,FULL,0,0,0,-85,-50,0
              DC.W      PLANE_YZ_2,FULL,0,0,0,85,-50,0
              DC.W      PLANE_YZ_3,FULL,0,0,0,-85,-50,DP_LEN_Z*1
              DC.W      PLANE_YZ_4,FULL,0,0,0,85,-50,DP_LEN_Z*1
              DC.W      PLANE_YZ_1,FULL,0,0,0,-85,-50,DP_LEN_Z*2
              DC.W      PLANE_YZ_2,FULL,0,0,0,85,-50,DP_LEN_Z*2
              DC.W      PLANE_YZ_3,FULL,0,0,0,-85,-50,DP_LEN_Z*3
              DC.W      PLANE_YZ_1,FULL,0,0,0,-85,-50,DP_LEN_Z*4
              DC.W      PLANE_YZ_2,FULL,0,0,0,85,-50,DP_LEN_Z*4
              DC.W      PLANE_YZ_3,FULL,0,0,0,85,-50,DP_LEN_Z*5
              DC.W      PLANE_YZ_4,FULL,0,0,0,-85-340,-50,DP_LEN_Z*5
              DC.W      PLANE_YZ_3,FULL,0,0,0,-85-170,-50,DP_LEN_Z*6
              DC.W      PLANE_YZ_2,FULL,0,0,0,-85-340,-50,DP_LEN_Z*6

; Tabelle, wie sich die FlÑchen beim Explodieren drehen.
de_expl_rot:  REPEAT
              DC.W      1,-2,3,-2,1,2,-3,-1
              UNTIL     #14
; Tabelle mit Richtungsvektoren, in die die einzelnen Polys fliegen.
de_expl_mov:  DC.W      2,4,6,-6,-4,-2,4,2,6,-4,-2,-6,4,-2,-4,-6,2,4
              DC.W      3,1,-2,-1,-4,0,1,3,-6,1,1,1,-2,-2,-2,0,0,-6
              DC.W      2,-3,1,-3,-2,-3,2,-2,0,2,-1,-7,-1,0,4,2,2,-4
              DC.W      -3,-1,3,0,-2,-2,4,-1,-4,1,-1,-2,-2,-1,1
              DC.W      -2,3,-6,6,1,1,1,3,2,-3,1,-2,-2,-3,5,-5,2,-1
              DC.W      -1,-2,-5,-1,1,3

de_pal:       DC.L      $00000000
OFF      SET  48
         REPEAT
              DC.B      0,OFF*4,0,0
OFF      SET  OFF-2
         UNTIL #(13-1)
              DC.L      $c0c0c0c0,$ff000000

*****************************************************************************
* Sterne am Himmel (Ich seh den Sternenhimmel, Sternenhimmel, ohoh).        *
* Und die Ballonfahrer erobern die Sterne ("THE HISTORY OF BALLONING" (siehe*
* auch Maonthy Pythons Flying Circus)).                                     *
*****************************************************************************
SH_WAIT0      EQU       150
SH_WAIT1      EQU       150
SH_END        EQU       1500              ; Anzahl Frames fÅr diese Ani.
sh_init:      suba.l    a0,a0
              moveq     #RELOAD_SH,d0
              bsr.w     new_ani_blk

              move.l    scr_lst_16,a0     ; Startbild.
              lea       (160*240.l,a0),a1
              bsr.w     clr_mem
              bsr.w     vsync
              move.l    scr_lst_16,d0
              SET_V_ADR d0,d1

              lea       D_mugpic1,a0            ; Bild wÑhrend des Depackens der
              movea.l   scr_lst_32k+11*4,a1     ; Ani zeigen.
              bsr.w     ice_decrunch

              movea.l   scr_lst_32k+12*4(pc),a0
              lea       (640*240.l,a0),a1
              bsr.w     clr_mem

              bsr.w     vsync
              move.l    scr_lst_32k+12*4(pc),d0
              movea.l   d0,a1
              SET_V_ADR d0,d1
              bsr.w     hardsw_32k
              movea.l   scr_lst_32k+11*4,a0
              bsr.w     hc_show1
              st        disable_sync

              move.w    #SH_WAIT0,d7
              bsr.w     vsync_xx

              bsr.w     show_ani_mw       ; Animation anzeigen.

              movem.l   def_beo(pc),d0-d2 ; Beobachter fÅr Vorberechnung
              movem.l   d0-d2,beovek      ; initialisieren.
              move.b    #1,detail         ; Die Screenwerte stimmen von "DE"
              move.b    #1,planes         ; noch, nur Umstellung der Planes.

              bsr.w     clr_screens

              lea       sh_pal(pc),VDI_PAL
              movea.l   VDI_PAL,DEST_PAL
              moveq     #16,COLSTEPS
              bsr.w     VDI_9800
              bsr.w     mask_pal

; Die Sterne im Hintergrund als Bewegung vorberechnen und auf den Screens ab-
; legen (auf jedem Screen liegt eine Animationsphase).
              moveq     #_16_ANZ_SCREENS-1,d7
sh_s_loop:    move.w    d7,-(sp)
              bsr.w     sw_frame_m        ; Frameroutine.
              lea       sh_data_init(pc),a0
              bsr.w     obj_handler       ; Sterne setzen (mit normaler Rout)
              bsr.w     ready_frame       ; Normales Framefinish.
              bsr.w     sh_in_frame
              bsr.w     vsync             ; Damit der Tracker nicht abstÅrzt.
              move.w    (sp)+,d7
              dbra      d7,sh_s_loop      ; NÑchster Screen.

              clr.b     detail            ; Switch erzwingen.
              lea       def_beo(pc),a0
              moveq     #0,d0             ; 4 Planes, 50 fps, Screens nat-
              moveq     #1,d1             ; Årlich NICHT lîschen.
              moveq     #1,d2
              moveq     #1,d3
              bsr.w     set_world

              move.l    #$00500035,beo    ; Beobachter etwas abseits stellen.
              move.w    #$0025,beo+4

              lea       anim_buf,a0       ; Ausfadepalette mit Farbe 0
              lea       256*4(a0),a1
              bsr.w     clr_mem

              clr.l     bmp_ani           ; Relative Framecounter zurÅck.
              clr.b     disable_sync      ; Sync an.

              lea       sh_pal(pc),a0     ; Einfaden.
              bra.w     inst_norm_fade

sh_in_frame:  moveq     #0,d0             ; Objektbewegungen wÑhrend der Scr-
              moveq     #0,d1             ; eenvorberechnungen.
              moveq     #3,d2
              moveq     #5-1,d7
              lea       sh_rots+4(pc),a0  ; Die vorberechneten Sterne rotieren
              bsr.w     rot_d03           ; "nur" um die z-Achse. Bei 48 Scr-
sh_f_1_lp:    neg.w     d2                ; eens bekommt man bei einem 5-eck-
              lea       16(a0),a0         ; igen Stern also 1.5 pro Step fÅr
              bsr.w     rot_d03           ; eine fÅnftels Umdrehung.
              dbra      d7,sh_f_1_lp
              rts       

sh_frame:     move.w    ani_frm(pc),d0    ; Normale Frameroutine.
              cmpi.w    #SH_END-128,d0    ; Szene ausfaden ?
              bne.s     sh_no_fo

              lea       anim_buf,a0
              bsr.w     inst_norm_fade

sh_no_fo:     cmpi.w    #SH_END,d0        ; Szene am Ende ?
              bne.s     sh_no_end

              moveq     #SZ_METRONOM,d0   ; NÑchste Szene: "Metronomzeit"
              bra.w     new_animat        ; initialisieren.

sh_no_end:    lea       sh_data+6(pc),a0  ; Die einzelnen Ballons hochbewegen.
              moveq     #4-1,d7
              moveq     #0,d0
              moveq     #0,d1
              moveq     #2,d2
sh_frm_lp:    bsr.w     rot_d03
              neg.w     d1
              subq.w    #1,8(a0)
              lea       16(a0),a0
              dbra      d7,sh_frm_lp            

              moveq     #2,d0             ; Nur die 2 Planes der Ballons
              bra.w     clr_plane_2       ; lîschen.

*****************************************************************************
*  Zeigt die Ani von Herm an (9 Bilder, eine Palette)                       *
*****************************************************************************
SM_ANZ_FRM    EQU       4                 ; ~ VBls pro Colstep.
SHW_VBLS      EQU       8                 ; ~ VBLs pro Bild.
SHW_LEN       EQU       140
SHW_WAIT0     EQU       10                ; Warten VOR der Scr.-Umschaltung
SHW_WAIT2     EQU       30                ; Nach Bildausblendung warten...
show_ani_mw:  movem.l   d0-a6,-(sp)

              st        disable_sync

              lea       D_mugani,a0       ; Die ganze Ani entpacken (dauert,
              movea.l   scr_lst_16,a1     ; aber solange wird ja Bild gezeigt)
              bsr.w     ice_decrunch

              moveq     #8,d7             ; Screens umkopieren.
              movea.l   scr_lst_16,a4
              lea       scr_lst_16+9*4,a6
cpy_ani_scr:  movea.l   a4,a0
              movea.l   (a6)+,a1
              move.w    #32000/16-1,d0
              bsr.w     cpy_mem16
              lea       160*200(a4),a4
              dbra      d7,cpy_ani_scr

              moveq     #SHW_WAIT0,d7     ; Noch etwas das Bild sprechen lassen.
              bsr.w     vsync_xx
              movea.l   scr_lst_32k+11*4,a0     ; Bild ausblenden.
              lea       (640*240.l,a0),a1
              bsr.w     clr_mem
              movea.l   scr_lst_32k+11*4,a0
              movea.l   scr_lst_32k+12*4,a1
              bsr.w     hc_show1
              st        disable_sync
              moveq     #SHW_WAIT2,d7
              bsr.w     vsync_xx

              move.l    scr_lst_16,d0     ; In ST-Low Modus gehen !
              bsr.w     set_scr_adr
              bsr.w     switch_stlow

              lea       mugpal_st(pc),a0  ; Palette setzen (STE-Palette!!!)
              lea       $ffff8240.w,a1
              moveq     #2-1,d0
              bsr.w     cpy_mem16

              bsr.w     vsync             ; Ab hier der Cycle-VBL.
              move.l    #shw_vbl,world_vbl

              moveq     #0,d0
              move.w    #SHW_LEN-1,d7
shw_an_lp:    move.w    d7,muganiend
              moveq     #SHW_VBLS-1,d3    ; Ani. nicht jeden VBl.
shw_lplp:     bsr.w     vsync
              dbra      d3,shw_lplp

              move.l    (scr_lst_16+9*4.l,d0.w*4),d1
              SET_V_ADR d1,d2

              addq.w    #1,d0             ; Screens cyclen.
              cmpi.w    #9,d0
              blt.s     no_ma_lp
              moveq     #0,d0
no_ma_lp:     dbra      d7,shw_an_lp

              lea       $ffff9800.w,a0
              lea       256*4(a0),a1
              bsr.w     clr_mem

              clr.l     world_vbl         ; Keine VBL-Rout mehr.
              movem.l   (sp)+,d0-a6
              rts

shw_vbl:      move.w    shw_counter(pc),d3      ; Diesen VBL cyclen ?
              addq.w    #1,d3
              cmpi.w    #SM_ANZ_FRM,d3
              blt.s     smsm_frm
              clr.w     d3

              cmpi.w    #10,muganiend     ; Ani ausfaden ???
              bgt.s     _nonoend          ; ja --> Immer eine Farbe mehr auf
              clr.w     $ffff8242.w       ; Hintergrund setzen.
_nonoend:

              lea       $ffff8240+32.w,a0 ; Farben 1-15 cyclen.
              move.w    -2(a0),d1         ; Farbe 15.
              moveq     #15/3-1,d7
shw_vbl_lp:   move.w    -4(a0),-(a0)
              move.w    -4(a0),-(a0)
              move.w    -4(a0),-(a0)
              dbra      d7,shw_vbl_lp
              move.w    d1,(a0)

smsm_frm:     move.w    d3,shw_counter
              rts

muganiend:    DC.W      150
shw_counter:  DC.W      0

mugpal_st:    DC.W      $0000,$0300,$0B80,$0410,$0C90,$0C20,$05A0,$0DB0
              DC.W      $06C0,$0DA0,$0C80,$0408,$0B09,$0302,$0202,$0109

sh_vbl:       rts
sh_data_init: DC.W      6
sh_rots:      DC.W      SPI_STERN,FULL,85,695,0,200,-150,600
              DC.W      SPI_STERN,FULL,620,20,0,-110,-70,300
              DC.W      SPI_STERN,FULL,79,20,0,250,150,750
              DC.W      SPI_STERN,FULL,80,650,0,-10,90,690
              DC.W      SPI_STERN,FULL,710,690,0,40,-150,1400
              DC.W      SPI_STERN,FULL,40,75,0,-200,150,1300
sh_data:      DC.W      4
              DC.W      O_BALLON,FULL,540,0,0,270,280,350
              DC.W      O_BALLON,FULL,540,0,0,0,430,500
              DC.W      O_BALLON,FULL,540,0,0,-250,340,1200
              DC.W      O_BALLON,FULL,540,0,0,0,880,0

; Hintergrundsterne in dezentem Blau gehalten.
sh_pal:       DC.W      150,0,250
              DC.W      200,300,600,400,500,800,300,400,700 ; Sternfarben

              DC.W      678,918,918,678,918,918     ; Turquoise.
              DC.W      678,918,918,678,918,918

              DC.W      528,768,768,528,768,768,528,768,768
              DC.W      528,768,768,603,843,843,603,843,843
              DC.W      603,843,843,603,843,843

; ***************************************************************************
; * << Gouraud-Photos >> "Ansichten einer Landschaft mit Ballon." (1)       *
; * (1) von Caspar David BDC                                                *
; * << Die MULTIMEDIA-DIASHOW >> !!! (c) 2010 by Microsoft Corpse           *
; ***************************************************************************
GP_ANZ_BO     EQU       55                ; Anzahl der Bodenplatten.
GP_DEEP       EQU       200               ; y-Koord der Bodenplatten.
gp_init:      lea       D_gp_beos+6,a0
              moveq     #$ff,d0
              moveq     #2,d1             ; Gouraud High-Colour
              moveq     #4,d2             ; (fÅr Debugging)
              moveq     #1,d3             ; Anzahl VBLs / Pic.
              bsr.w     set_world

              move.w    show_frm(pc),gp_s_frm   ; Startframe.

              tst.b     use_fpu(pc)       ; FPU vorhanden und benutzt ?
              bne.s     gp_no_fpu

              move.b    #ST_LGTSOURCE,shading   ; Lichtquelle benutzen.
              move.b    #an,pals                ; "Real"-Paletten benutzten.
              bra.s     gp_fin_i_fpu

gp_no_fpu:    move.b    #ST_CONST,shading
              move.b    #aus,pals

gp_fin_i_fpu: lea       anim_buf,a0
              lea       gp_data(pc),a2    ; Standartobjekte
              move.w    (a2)+,d7
              move.w    d7,(a0)
              add.w     #GP_ANZ_BO,(a0)+

              lea       D_gp_bo,a3        ; Bodenplatten setzen (aus Daten-
              move.w    #GP_ANZ_BO-1,d6   ; datei) auslesen.
              bmi.s     gp_kein_boden
              moveq     #0,d0
              moveq     #O_PLANE_1,d1
              moveq     #MOVE,d2
              move.w    #GP_DEEP,d3
gp_gen_bo:    move.w    d0,(a0)
              add.w     d1,(a0)+
              addq.w    #1,d0
              andi.w    #3,d0
              move.w    d2,(a0)+
              movem.w   (a3)+,d4-d5
              move.w    d4,(a0)+
              move.w    d3,(a0)+
              move.w    d5,(a0)+
              dbra      d6,gp_gen_bo
gp_kein_boden:

              subq.w    #1,d7             ; Standartobjekt anfÅgen (Ballons)
              bmi.s     gp_no_data
gp_cp_bal:    move.l    (a2)+,(a0)+
              move.l    (a2)+,(a0)+
              move.l    (a2)+,(a0)+
              move.l    (a2)+,(a0)+
              dbra      d7,gp_cp_bal

gp_no_data:   clr.l     $ffff9800.w
gp_vbl:       rts

gp_frame:     move.w    show_frm(pc),d0
              sub.w     gp_s_frm(pc),d0
              beq.s     gp_nff            ; Erstes Bild beendet ?
              move.w    #65,anz_vbls      ; Dann VBLs-hochfahren (Dias...)

gp_nff:       move.w    gp_beo(pc),d0     ; NÑchsten Kamerapunkt auswÑhlen.
              addi.w    #9,d0
              cmpi.w    #GP_ANZ_BEOS*9,d0 ; Zustand.
              bgt.s     gp_ended          ; "E.X"-Logo dreht sich ?
              bne.s     gp_rule           ; Normale Photos am laufen ?
              move.w    d0,gp_beo         ; "E.X"-Logo Initialisierung.

              lea       anim_buf,a0       ; Ballons in Objektstuktur aus-
              move.w    #GP_ANZ_BO+1,(a0)+      ; blenden und durch "E.X"-Logo
              move.w    #O_EXLOGO_65,(GP_ANZ_BO*10)(a0) ; ersetzen.
              lea       (GP_ANZ_BO*10+4)(a0),a0
              clr.l     (a0)+
              clr.l     (a0)+             ; c = x = 0;
              move.l    #$fe0c00fa,(a0)   ; y = 250, z = -500;

              movem.w   _gp_b2(pc),d0-d7/a0     ; Beo. und Lichtquelle.
              movem.w   d0-d7/a0,lightsource
              bra.s     gp_ended

gp_rule:      move.w    d0,gp_beo               ; Beobachterstatus sichern.
              lea       lightsource(pc),a0      ; Lichtquelle, Beobachter
              movem.w   (D_gp_beos,d0.w*2),d0-d5/a1-a3
              movem.w   d0-d5/a1-a3,(a0)
              bra.w     clr_screen

gp_ended:     lea       anim_buf+GP_ANZ_BO*10+6,a0  ; "E.X"-Rot.
              moveq     #0,d0
              moveq     #0,d1
              moveq     #16,d2
              bsr.w     rot_d03

;             lea       beovek(pc),a0     ; Beobachter drehen: Hintergrund des
;             moveq     #0,d0             ; "E.X"-Logos dreht sich mit.
;             moveq     #-2,d1
;             moveq     #0,d2
;             bsr.w     rot_d03

              move.w    show_frm(pc),d0   ; Wenn Photoalbum durch ist,
              sub.w     gp_s_frm(pc),d0   ; Logo mit 50 fps drehen lassen.
              cmpi.w    #GP_ANZ_BEOS+12,d0
              blt.s     gp_not_fin
              move.w    #4,anz_vbls       ; "E.X"-Logo rotiert schnell.
gp_not_fin:   bra.w     clr_screen

GP_ANZ_BEOS   EQU       18                ; Anzahl "Photos"
; Format:     0-2.w     Lichtquelle
;             3-8.w     Blickwinkel und Beobachter
_gp_b2:       DC.W      100,0,400,$022a,$0000,$0000,$0000,$eb00,$0000
gp_beo:       DC.W      -9
gp_s_frm:     DC.W      0                 ; Startframecounter
gp_data:      DC.W      4                 ; Ballonpositionen.
              DC.W      O_BALLON_65,FULL,540,0,0,-100,0,0
              DC.W      O_BALLON_65,FULL,540,0,0,400,-0,450
              DC.W      O_BALLON_65,FULL,540,0,0,-500,30,950
              DC.W      O_BALLON_65,FULL,540,0,0,100,-170,1200

; ***************************************************************************
; * << Das zoomende Wort >> "E.X"-Logo zoomt und dreht sich weg.            *
; ***************************************************************************
WZ_NEXT_Z     EQU       19000             ; Akt. Char bei ~ z, dann nÑchsten.
wz_init:      moveq     #16,d7            ; Paletten ausmaskieren.
              lea       wz_pal(pc),a0
              bsr.w     mask_pal
              lea       wz_pal2(pc),a0
              bsr.w     mask_pal

              lea       def_beo(pc),a0    ; 8 Planescreen, 50 fps.
              moveq     #$ff,d0
              moveq     #1,d1
              moveq     #4,d2
              moveq     #1,d3
              bsr.w     set_world

              moveq     #64,d5            ; Farben cool umblenden.
              moveq     #0,d6
              moveq     #15,d7
              lea       wz_pal(pc),a0
              bra.w     inst_fade

wz_frame:     tst.w     wz_phase(pc)
              bne.w     wz_fade_out

              lea       add_1(pc),a0
              lea       wz_zoom1+7*2(pc),a1
              movem.w   (a0),d0-d3
              move.w      (a1),d4
              move.w    16(a1),d5
              move.w    32(a1),d6
              move.w    48(a1),d7

              sub.w     d0,d4
              bmi.s     wz_vorne1
              subq.w    #1,d0
              move.w    d0,(a0)
              move.w    d4,(a1)
wz_vorne1:    cmpi.w    #WZ_NEXT_Z,d4
              bgt.s     wz_vorne4
              sub.w     d1,d5
              bmi.s     wz_vorne2
              subq.w    #1,d1
              move.w    d1,2(a0)
              move.w    d5,16(a1)
wz_vorne2:    cmpi.w    #WZ_NEXT_Z,d5
              bgt.s     wz_vorne4
              sub.w     d2,d6
              smi       (wz_phase+1)
              bmi.s     wz_vorne3
              subq.w    #1,d2
              move.w    d2,4(a0)
              move.w    d6,32(a1)
wz_vorne3:    bra.s     wz_vorne4
              cmpi.w    #WZ_NEXT_Z,d6
              bgt.s     wz_vorne4
              sub.w     d3,d7
              bmi.s     wz_vorne4
              subq.w    #1,d3
              move.w    d3,6(a0)
              move.w    d7,48(a1)
wz_vorne4:    moveq     #0,d0
              moveq     #0,d1
              moveq     #2,d2
              lea       wz_zoom2+4(pc),a0 ; Der Punkt rotiert stÑndig.
              bsr.w     rot_d03
              bra.w     clr_screen
;             bra.w     clr_plane_2

wz_fade_out:  lea       wz_phase(pc),a0
              subq.w    #1,(a0)           ; Ausfadephase: Bissle warten.
              bgt.s     wz_no_end
              bne.s     wz_no_zero

              subq.w    #1,(a0)           ; 0 Åbergehen.

wz_no_zero:   cmpi.w    #-80,(a0)         ; Farben schon ausfaden ?
              bne.s     wz_no_col_fo

              moveq     #64,d5            ; Nur die Farben der Buchstaben
              moveq     #1,d6             ; ausfaden.
              moveq     #6,d7
              lea       wz_pal2+4(pc),a0
              bsr.w     inst_fade

wz_no_col_fo: lea       wz_zoom1+12(pc),a0
              lea       32(a0),a1
              move.w    wz_count(pc),d0   ; E und X auf Wurzelbahn rausfliegen
              addq.w    #1,d0             ; lassen.
              move.w    d0,wz_count
              move.w    d0,d1
              neg.w     d1
              move.w    d0,(a0)
              move.w    d1,(a1)
              mulu.w    d0,d0
              lsr.w     #7,d0
              move.w    d0,-(a0)
              neg.w     d0
              move.w    d0,-(a1)

              lea       wz_zoom1+4(pc),a0 ; E und X drehen.
              moveq     #1,d0
              moveq     #0,d1
              moveq     #-2,d2
              bsr.w     rot_d03
              lea       32(a0),a0
              moveq     #2,d2
              bsr.w     rot_d03

wz_no_end:    moveq     #0,d0
              moveq     #0,d1
              moveq     #2,d2
              lea       wz_zoom2+4(pc),a0 ; Punkt rotieren stÑndig.
              bsr.w     rot_d03
              bra.w     clr_screen
;             bra.w     clr_plane_2

wz_vbl:       rts
wz_data:      DC.W      3
wz_zoom1:     DC.W      LOGO_E,FULL,0,0,0,0,0,30000-450
wz_zoom2:     DC.W      LOGO_P1,FULL,0,0,0,0,0,30000-450
wz_zoom3:     DC.W      LOGO_X,FULL,0,0,0,0,0,30000-450

add_1:        DC.W      400
add_2:        DC.W      400
add_3:        DC.W      400
add_4:        DC.W      400
wz_phase:     DC.W      0
wz_count:     DC.W      -1
wz_pal:       DC.L      $00000040
              DC.L      $88880088
              DC.L      $000000bb,$888800aa
              DC.L      $66660066,$77770077,$666600aa,$777700aa
              DC.L      $aa0000aa,$dd0000aa,$aa0000aa,$dd0000aa
              DC.L      $aa0000aa,$dd0000aa,$aa0000aa,$dd0000aa

wz_pal2:      DC.L      $00000040
              DC.L      $00000040
              DC.L      $000000bb,$888800aa
              DC.L      $00000040,$00000040,$00000040,$00000040
              DC.L      $aa0000aa,$dd0000aa,$aa0000aa,$dd0000aa
              DC.L      $aa0000aa,$dd0000aa,$aa0000aa,$dd0000aa

; ***************************************************************************
; * << Is it life ? >> (ZufÑllig auftauchende Quadrate)                     *
; ***************************************************************************
ANZ_IL        EQU       496               ; Anzahl Stellungen.
ANZ_IL_SET    EQU       144               ; max. Anzahl Quadrate gleichzeitig.
il_init:      lea       def_beo(pc),a0
              moveq     #$ff,d0
              moveq     #1,d1
              moveq     #4,d2
              moveq     #1,d3
              bsr.w     set_world

              lea       il_pal(pc),a0
              bsr.w     set_pal

              lea       random,a0         ; Quadrattabelle aufbauen.
              lea       anim_buf,a1
              move.w    #ANZ_IL-1,d7
il_b_lp:      moveq     #0,d0             ; Offsets immer positiv.
              moveq     #0,d1
              move.w    (a0)+,d0          ; Erste Zufallszahl
              move.w    (a0)+,d1          ; Zweite Zufallszahl
              move.w    d0,d2
              divu.w    #20,d0
              divu.w    #25,d1
              swap      d0
              swap      d1
              lsl.w     #3,d0
              lsl.w     #3,d1
              move.l    (20*4+tab_160.l,pc,d1.w*4),d1
              btst      #3,d2             ; ** Manche Blîcke nach rechts.
              bne.s     *+4               ; **
              addq.w    #1,d0             ; **
              add.w     d0,d1
              andi.w    #$7,d2
              move.w    d1,(a1)+
              move.w    d2,(a1)+
              dbra      d7,il_b_lp

              move.w    #ANZ_IL_SET-1,d7  ; Tabellenanfang ans Ende kopieren.
              lea       anim_buf,a0
il_ueberhg:   move.l    (a0)+,(a1)+
              dbra      d7,il_ueberhg

              rts
il_vbl:       rts
il_frame:     bsr.w     clr_screen        ; Kompletten Screen lîschen.

              lea       anim_buf,a6
              move.w    anis(pc),d0
              adda.w    d0,a6

;move.w       vbl_counter(pc),d1
;sub.w        anis_vbl(pc),d1
;subq.w       #1,d1
;bmi.s        il_go_ahead

              move.w    vbl_counter(pc),anis_vbl
              addi.w    #8,d0
              cmp.w     #ANZ_IL*4,d0
              blt.s     il_no_sw_b
              clr.w     d0
il_no_sw_b:   move.w    d0,anis
              
il_go_ahead:  move.w    #ANZ_IL_SET-1,d7
              lea       160*4.w,a5
illp:         move.w    (a6)+,d0
              move.w    (a6)+,d1
              lea       ([screen.w,pc],d0.w),a0
              move.l    (il_8blk.b,pc,d1.w*4),d0
              moveq     #(16/4)/2-1,d6
il_set_lp:    
OFF           SET       0
        REPEAT
              movep.l   d0,OFF(a0)
OFF           SET       OFF+160
        UNTIL #4-1
              adda.l    a5,a0
              dbra      d6,il_set_lp
              dbra      d7,illp
              rts

il_8blk:      DC.L      $000000ff,$ff0000ff,$00ff00ff,$ffff00ff
              DC.L      $0000ffff,$ff00ffff,$00ffffff,$ffffffff

il_pal:       DC.L      $00000020,$00000033,$00000055,$00000077
              DC.L      $00000099,$000000bb,$000000dd,$000000ff
              DC.L      $ff000000,$ee000000,$dd000000,$cc000000
              DC.L      $bb000000,$cc000000,$bb000000,$aa000000

il_data:      DC.W      0

anis:         DC.W      0
anis_vbl:     DC.W      0

*****************************************************************************
* << No history of time >> (Die Zeit ist doch zu relativ...)                *
* Die ganze Sache wird noch Åberblendet von 16 Farben Text.                 *
*****************************************************************************
AT_TXTPAL1    EQU       anim_buf
AT_TXTPAL2    EQU       anim_buf+64
AT_NULLPAL    EQU       anim_buf+128
at_init:      
        IFEQ  (STARTANI-SZ_ANY_TIMES)
              suba.l    a0,a0
              moveq     #RELOAD_MZ,d0
              bsr.w     new_ani_blk
        ENDIF           

              lea       D_illusion,VDI_PAL      ; Textpaletten umwandeln.
              movea.l   VDI_PAL,DEST_PAL
              moveq     #16,COLSTEPS
              bsr.w     VDI_9800
              bsr.w     mask_pal
              lea       AT_TXTPAL1,a1
              bsr.w     konv_pal_tpi
              lea       D_leben,VDI_PAL
              movea.l   VDI_PAL,DEST_PAL
              moveq     #16,COLSTEPS
              bsr.w     VDI_9800
              bsr.w     mask_pal
              lea       AT_TXTPAL2,a1
              bsr.w     konv_pal_tpi

              lea       AT_NULLPAL,a0     ; Palette aus Hintergrund des fol-
              lea       256*4(a0),a1      ; genden Gedichts: schwarz.
              bsr.w     clr_mem

              lea       def_beo(pc),a0
              moveq     #-1,d0            ; Screens NICHT lîschen.
              moveq     #1,d1
              moveq     #8,d2
              moveq     #1,d3
              bsr.w     set_world
              move.l    #1,akt_scr        ; Auf Screenlistenanfang.
              clr.w     ani_frm

              movea.l   free_screen,a0    ; Der unbenîtigte Screen wird zum
              lea       32000(a0),a1      ; Lîschen benutzt, sonst eigene Rout
              bsr.w     clr_mem           ; benîtigt...

              lea       at_pal(pc),a0
              bra.w     inst_norm_fade

AT_WAIT1      EQU       100               ; Anschauungsdauer der Texte...
AT_WAIT2      EQU       100
AT_WAIT3      EQU       50
AT_ENDE       EQU       1100
AT_APPEAR_1   EQU       200               ; Erscheinungszeiten...
AT_APPEAR_2   EQU       350
AT_APPEAR_3   EQU       550
at_frame:     move.w    ani_frm(pc),d0

              cmpi.w    #AT_ENDE-128,d0   ; Fade-Out starten ?
              bne.s     at_no_fo

              lea       AT_NULLPAL,a0
              moveq     #64,d5
              moveq     #0,d6
              move.w    #255,d7
              bsr.w     inst_fade
              bra.s     at_no_ende

at_no_fo:     cmpi.w    #AT_ENDE,d0       ; Das Ende des Uhrenzeigers ?
              bne.s     at_no_ende

              lea       D_hk_xxxv,a0      ; Gedicht setzen.
              moveq     #NOLOAD,d0
              bsr.w     set_poem

              moveq     #SZ_FADINGS,d0    ; "Fading Objects" als Nachfolger-
              bra.w     new_animat        ; animation starten.

at_no_ende:   cmpi.w    #AT_APPEAR_1,d0   ; Muû TEXT 1 (Leben) gesetzt wer-
              bne.s     at_no_txt1        ; den ?

              lea       AT_TXTPAL2+4,a0   ; Palette setzen (Hintergrundfarbe
              bsr.w     at_set_240        ; fÑllt weg)

              lea       D_leben+16*6,a0   ; Textadresse.
              lea       ([screen+4.w,pc],30*320+8.w),a1
              move.w    #AT_WAIT1,d0      ; Wartezeit.
              moveq     #79,d7            ; Hîhe.
              bsr.w     at_set_txt

              move.l    #1,akt_scr
              bra.w     at_no_txt3

at_no_txt1:   cmpi.w    #AT_APPEAR_2,d0   ; Muû TEXT 2 (Sterben) gesetzt
              bne.s     at_no_txt2        ; werden ?

              lea       AT_TXTPAL2+4,a0
              bsr.w     at_set_240
              lea       D_leben+160*80+16*6,a0
              lea       ([screen+4.w,pc],110*320+8.l),a1
              move.w    #AT_WAIT2,d0
              moveq     #79,d7
              bsr.w     at_set_txt

              move.l    #1,akt_scr
              bra.s     at_no_txt3

at_no_txt2:   cmpi.w    #AT_APPEAR_3,d0   ; Muû TEXT 3 (Illusion) gesetzt
              bne.s     at_no_txt3        ; werden ?

              bsr.w     vsync
              st        disable_sync

              lea       AT_TXTPAL1+4,a0   ; Text auf alle Screens kopieren,
              bsr.w     at_set_240        ; damit Uhr weiterlaufen kann.

              lea       scr_lst_256,a6
              moveq     #_256_ANZ_SCREENS-1,d7
at_fill_all:  move.w    d7,-(sp)

              lea       D_illusion+16*6,a0
              movea.l   (a6)+,a1
              lea       20*320+8(a1),a1
              move.w    #199,d7
              bsr.w     cpy_4_8

              move.w    (sp)+,d7
              dbra      d7,at_fill_all

              move.w    #AT_WAIT3,d7      ; Noch etwas warten.
              bsr.w     vsync_xx

              move.l    #1,akt_scr
              clr.b     disable_sync

at_no_txt3:   moveq     #0,d0             ; Planes 0-3 lîschen.
              bsr.w     clr_screen_8

; Digitaluhr setzen.
              move.l    #200*320+88*2+6,d0      ; X-Off 112 Bytes und Plane = 4
              moveq     #1,d1
              bsr.w     set_digi_clk      ; Digiclock setzen.

; Uhrenhintergrund (Kreis) ziemlich undifferenziert auf eine Plane klatschen.
              lea       ([screen.w,pc],(320*72+56*2+0).w),a0
              lea       kreis1+32,a1
              moveq     #95,d7
at_dr_circle: move.w    (a1)+,(a0)
OFFSET        SET       16
          REPEAT
              move.w    (a1)+,OFFSET(a0)
OFFSET        SET       OFFSET+16
          UNTIL #(6-2)
              addq.l    #2,a1
              lea       320(a0),a0
              dbra      d7,at_dr_circle

; Zeit in Zeigerstellungen umrechnen.
              lea       time(pc),a0       ; Stundenzeiger auf 0-11 bringen.
              lea       at_h_zeiger+4(pc),a1
              moveq     #0,d0
              moveq     #12,d3
              move.b    (a0)+,d0
              cmp.b     d3,d0
              blt.s     _0_11
              sub.b     d3,d0
_0_11:        neg.w     d0
              add.w     d3,d0
              mulu.w    #60,d0            ; 1 Stunde ~ 30 Grad (*2 wg. 0.5 sin)
              move.w    d0,(a1)
              lea       16(a1),a1

              move.w    #360,d2
              moveq     #2-1,d7           ; Minuten- und Sekundenzeiger...
at_set_time:  moveq     #0,d0
              move.b    (a0)+,d0          ; Zeit holen [0-60)
              beq.s     at_zero
              MULF_6    d0,d1             ; Eine Zeiteinheit ~ 6 Grad.
              neg.w     d0                ; Rotiert gegen Uhrzeigersinn:
              add.w     d2,d0             ; umdrehen.
              add.w     d0,d0             ; Da 0.5 Grad Sinustab.
at_zero:      move.w    d0,(a1)
              lea       16(a1),a1
              dbra      d7,at_set_time
              rts

at_vbl:       lea       at_hundert(pc),a0 ; FÅr Ditaluhr:
              move.b    (a0)+,d1          ; Hunderstelsekunde bestimmen:
              clr.b     $ffff8961.w
              move.b    $ffff8963.w,d0    ; Bei VerÑnderung der Sekunden wird
              cmp.b     (a0),d0           ; HunderstelzÑhler zurÅckges.,
              beq.s     no_00             ; sonst um 2 erhîht (50Hz~1Sek).
              move.b    d0,(a0)
              moveq     #-2,d1
no_00:        addq.b    #2,d1
              move.b    d1,-(a0)          ; In Hundertstelbuffer
              move.b    d1,time+3         ; In Uhrzeitbuffer spiegeln.
              rts

; Setzt 15 Farben Farbpalette so, dass Planes 0-3 durch 16 Farben auf Planes
; 4-7 immer Åberdeckt sind.
at_set_240:   movem.l   d5-a1,-(sp)

              lea       $ffff9840.w,a1
              moveq     #15-1,d7          ; 15 Farben.
at_set_lp:    moveq     #15,d6            ; Jeweils 16 Farben Åberdecken.
              move.l    (a0)+,d5
at_set_lp2:   move.l    d5,(a1)+
              dbra      d6,at_set_lp2
              dbra      d7,at_set_lp

              movem.l   (sp)+,d5-a1
              rts

; Kopiert 4 Planes Urbild auf einen 8 Planescreen (Urbildbreite immer 320 Pix.)
; PARAMETER:  a0.l  -  Urbild
;             a1.l  -  Screenadresse (bereits poritioniert)
;             d7.w  -  Anzahl Zeilen - 1
cpy_4_8:      moveq     #5-1,d6
cpy_4_8_zei:
       REPEAT
              move.l    (a0)+,(a1)+
              move.l    (a0)+,(a1)+
              addq.l    #8,a1
       UNTIL  #4-1
              dbra      d6,cpy_4_8_zei
              dbra      d7,cpy_4_8
              rts

; Setzt Text und wartet eine Weile.
; d0 - Wartezeit, d7 - Texthîhe, a0 - Textadresse, a1 - Screenadresse
at_set_txt:   pea       (a1)
              move.w    d7,-(sp)
              move.w    d0,-(sp)

              st        disable_sync      ; Screenhandling aus.
              bsr.w     vsync             ; Ausgabe anhalten !!!

              bsr.w     cpy_4_8

              move.w    (sp)+,d7          ; Wartezeit holen.
              beq.s     at_no_wait        ; 0 --> Nicht warten.

              bsr.w     vsync_xx          ; Sonst etwas bummeln...

at_no_wait:   movea.l   free_screen,a0
              move.w    (sp)+,d7
              movea.l   (sp)+,a1
              bsr.w     cpy_4_8

              clr.b     disable_sync
              rts

at_data:      DC.W      3
              DC.W      H_ZEIGER,FULL
at_h_zeiger:  DC.W      0,0,0,0,0,5,M_ZEIGER,FULL
at_m_zeiger:  DC.W      0,0,0,0,0,5,S_ZEIGER,FULL
at_s_zeiger:  DC.W      0,0,0,0,0,5

at_pal:       DC.L      $40000040
              DC.L      $60000080               ; Uhrenhintergrund.
              DC.L      $60600060,$60600060                     ; Zeiger 1
              DC.L      $80800080,$80800080,$70700070,$70700070 ; Zeiger 2
              DC.L      $a0a000a0,$a0a000a0,$a0a000a0,$a0a000a0 ; Zeiger 3
              DC.L      $a0a000a0,$a0a000a0,$a0a000a0,$a0a000a0

at_hundert:   DC.W      0                 ; Digitaluhr Hundertstellcounter.

*****************************************************************************
* Metronome haben ihre eigene Zeitmessung.                                  *
* Die Szene geht in "any times" Åber.                                       *
*****************************************************************************
MZ_ANZ        EQU       10                ; Anzahl der Metronome.
ANZ_METRO     EQU       80                ; Anzahl EintrÑge in Swingdatei.
MZ_BASECOL    EQU       4                 ; Erste Farbe mit Pendeln.
MZ_SEKUNDEN   EQU       7                 ; Anzahl Sekunden Szene normal.
mz_beo:       DC.W      706,0,0,0,-74,8   ; Blick von oben auf die Metronome.
mz_init:      suba.l    a0,a0
              moveq     #RELOAD_MZ,d0
              bsr.w     new_ani_blk

              lea       mz_pal(pc),VDI_PAL
              movea.l   VDI_PAL,DEST_PAL
              moveq     #16,COLSTEPS
              bsr.w     VDI_9800
              lea       mz_pal(pc),a0
              moveq     #16,d7
              bsr.w     mask_pal

              lea       mz_mcols(pc),a4   ; Metronompendelfadings errechnen.
              lea       anim_buf,a5       ; Pointerbuffer
              lea       MZ_ANZ*4(a5),a6   ; Datenbuffer
              moveq     #MZ_ANZ-1,d6
mz_calc_col:  move.l    a6,(a5)+          ; Pointer auf Palette sichern.

              movea.l   a6,CALC_PAL
              movea.l   a4,ENDCOL               ; Farben so shaden, daû eine
              lea       6(a4),STARTCOL          ; halbe Pendelbewegung den
              moveq     #ANZ_METRO/2,COLSTEPS   ; vollen Farbeverlauf hat.
              bsr.w     CALC_PAL_VDI

              lea       (ANZ_METRO/2)*6(a6),a1  ; Pal. spiegelverkehrt kop.
              movea.l   a1,a0                   ; (Kînnte besser mit Falcon-
              moveq     #ANZ_METRO/2-1,d7       ; Palette passieren......)
mz_cpy_pal:   move.w    -(a0),d2          ; B
              move.w    -(a0),d1          ; G
              move.w    -(a0),d0          ; R
              movem.w   d0-d2,(a1)
              addq.l    #6,a1
              dbra      d7,mz_cpy_pal

              movea.l   a6,VDI_PAL        ; Palette ins normale Format.
              movea.l   a6,DEST_PAL
              moveq     #ANZ_METRO,d7
              bsr.w     VDI_9800
              movea.l   a6,a0
              moveq     #ANZ_METRO,d7
              bsr.w     mask_pal

              lea       ANZ_METRO*4(a6),a6      ; Buffer weiter.
              lea       12(a4),a4               ; NÑchsten Farbverlauf...
              dbra      d6,mz_calc_col          ; ...berechnen.

              lea       mz_beo(pc),a0     ; Videosystem umstellen.
              moveq     #0,d0             ; 16 Farben, 25 fps.
              moveq     #1,d1
              moveq     #4,d2
              moveq     #2,d3
              bsr.w     set_world
              move.l    #$1,akt_scr       ; Sofort sichtbar starten.

              lea       mz_pal(pc),a0     ; Szene einfaden.
              moveq     #64,d5
              moveq     #0,d6
              moveq     #15,d7
              bra.w     inst_fade

mz_frame:     lea       metronome(pc),a0        ; Metronompendel schwingen
              lea       metro_counts(pc),a1     ; lassen.
              lea       D_metronom,a2
              move.w    #ANZ_METRO,d4
              moveq     #MZ_ANZ-1,d7      ; Anzahl der Metronome.
mz_move_me:   move.w    (a1),d0           ; Counter dieses Pendels.
              move.w    (a2,d0.w*2),8(a0) ; Ausschlagswert.

              addq.w    #1,d0             ; In Tabelle weitergehen.

              cmp.w     d4,d0
              blt.s     no_sw_back
              sub.w     d4,d0
no_sw_back:   move.w    d0,(a1)+          ; Neuer Tabellenstand.
              lea       16(a0),a0         ; NÑchstes Pendel.
              dbra      d7,mz_move_me

              moveq     #33-1,d6          ; Mit "Horizont" lîschen.
              moveq     #(200-(32*4))/4-1,d7

              addq.w    #1,mz_phase       ; Noch ganz normal pendeln ?
              bmi.w     k_horizont        ; ja --> nur noch lîschen.

              cmpi.w    #150,mz_phase     ; Basiskîrper schon komplett raus-
              bne.s     mz_no_weg         ; geflogen ?

              move.w    #MZ_ANZ,mz_data   ; Dann diesselben nicht mehr bearb.

mz_no_weg:    blt.s     mz_no_beo_m       ; mz_phase < 150

              lea       beo+4(pc),a2
              addq.w    #8,(a2)           ; Beobachter durch die schwingenden
              cmp.w     #1128,(a2)        ; Pendel bewegen...
              bne.s     mz_n_fo           ; Palette ausfaden ?

              lea       mz_pal(pc),a0     ; (Nur Farbe 15 auf Hinter-
              moveq     #64,d5            ; grundniveau bringen)
              moveq     #15,d6
              moveq     #0,d7
              bsr.w     inst_fade

              moveq     #33-1,d6          ; Die Horizontdaten muûten etwas
              moveq     #72/4-1,d7        ; geÑndert werden...
              bra.s     mz_no_beo_m

mz_n_fo:      cmp.w     #1575,(a2)        ; Animation ganz ausblenden ?
              blt.s     mz_no_beo_m

              lea       $ffff9800+4.w,a0  ; Alle Farben auf Hintergrundniveau.
              move.l    mz_pal(pc),d0
              moveq     #15/3-1,d7
mz_clr_col:   move.l    d0,(a0)+
              move.l    d0,(a0)+
              move.l    d0,(a0)+
              dbra      d7,mz_clr_col

              moveq     #SZ_ANY_TIMES,d0
              bra.w     new_animat        ; "any times" einblenden !

mz_no_beo_m:  lea       mz_koerper+4(pc),a0     ; Die Metronomkîrper wegbew.
              moveq     #4,d0             ; Es wird immer eine Reihe horizont-
              moveq     #22,d2            ; al wegbewegt und eine vertikal.
              moveq     #18,d3
              moveq     #MZ_ANZ/2-1,d5
mz_phase_2:   sub.w     d0,(a0)           ; Objekt 1: sub x
              add.w     d0,10(a0)         ; Objekt 2: add x
              adda.l    d2,a0             ; Auf Objekt 3,4
              exg       d2,d3             ; Offsets tauschen (x/y/x/y...)
              dbra      d5,mz_phase_2

              bra.w     k_horizont
              rts

; Im VBL die Pendeldfarben gemÑû des aktuell sichtbaren Ausschlages setzen.
; Wieso die Farben im oberen Border flackern ist mir ehrlich gesagt rÑtsel-
; haft.
mz_vbl:       lea       metro_counts(pc),a0     ; Metronemfarben setzen.
              lea       anim_buf,a1
              lea       $ffff9800+4*MZ_BASECOL.w,a2
              moveq     #_16_ANZ_SCREENS,d1
              moveq     #ANZ_METRO,d2
              moveq     #MZ_ANZ-1,d7
mz_set_col:   movea.l   (a1)+,a3          ; Farbpalette zu diesem Pendel.
              move.w    (a0)+,d0          ; Pendelcounter
              sub.w     d1,d0             ; Counter des sichtbaren Screens
              bpl.s     mz_no_oi          ; errechnen.
              add.w     d2,d0
mz_no_oi:     move.l    (a3,d0.w*4),(a2)+ ; Farbe setzen.
              dbra      d7,mz_set_col     ; NÑchste Pendelfarbe.
              rts

mz_data:      DC.W      20
metronome:    DC.W      METRONOM_PEN1,FULL,0,0,0,-100,-25,-10
              DC.W      METRONOM_PEN2,FULL,0,0,0,100,-25,-10
              DC.W      METRONOM_PEN3,FULL,0,0,0,-100,-25,-10+300
              DC.W      METRONOM_PEN4,FULL,0,0,0,100,-25,-10+300
              DC.W      METRONOM_PEN5,FULL,0,0,0,-100,-25,-10+600
              DC.W      METRONOM_PEN6,FULL,0,0,0,100,-25,-10+600
              DC.W      METRONOM_PEN7,FULL,0,0,0,-100,-25,-10+900
              DC.W      METRONOM_PEN8,FULL,0,0,0,100,-25,-10+900
              DC.W      METRONOM_PEN9,FULL,0,0,0,-100,-25,-10+1200
              DC.W      METRONOM_PEN10,FULL,0,0,0,100,-25,-10+1200
mz_koerper:   DC.W      METRONOM,MOVE,-100,0,0  ; Grundkîrper.
              DC.W      METRONOM,MOVE,100,0,0
              DC.W      METRONOM,MOVE,-100,0,300
              DC.W      METRONOM,MOVE,100,0,300
              DC.W      METRONOM,MOVE,-100,0,600
              DC.W      METRONOM,MOVE,100,0,600
              DC.W      METRONOM,MOVE,-100,0,900
              DC.W      METRONOM,MOVE,100,0,900
              DC.W      METRONOM,MOVE,-100,0,1200
              DC.W      METRONOM,MOVE,100,0,1200

mz_phase:     DC.W      -50*MZ_SEKUNDEN   ; Framecounter intern.
metro_counts: DS.W      MZ_ANZ,0

; Shading fÅr die einzelnen Pendel. Pro Pendel jeweils eine Start- und Endfarbe.
mz_mcols:     DC.W      310,184,818,0,0,0 ; Violett (dunkler)
              DC.W      900,398,000,0,0,0 ; Coral (dunkler)
              DC.W      557,137,137,0,0,0 ; Firebrick
              DC.W      137,557,137,0,0,0 ; Forestgreen
              DC.W      576,859,439,0,0,0 ; Greenyellow
              DC.W      624,624,373,0,0,0 ; Khaki
              DC.W      749,847,847,0,0,0 ; Lightblue
              DC.W      557,137,420,0,0,0 ; Maroon
              DC.W      737,561,561,0,0,0 ; Pink
              DC.W      900,400,000,0,0,0 ; Orange (dunkel)

mz_pal:       DC.W      0,0,0
              DC.W      100,0,400,200,0,500,300,0,600   ; Farben fÅr Grundbau.

              DS.W      10*3,0            ; Pendelfarben egal (VBL)

              DC.W      1000,1000,100     ; Unbenutzt.
              DC.W      80,80,175         ; Boden (graublau)

; ***************************************************************************
; * << Enduro Racer Version 2 >>                                            *
; * Flug Åber eine "No Second Prize"-Ñhnliche Landschaft.                   *
; ***************************************************************************
ANZ_TB        EQU       7                 ; Anz. TannenbÑume.
ANZ_ST        EQU       24                ; Anz. StreckenstÅcke.
ANZ_ER_MOVE   EQU       752               ; Anz. Beobachtersteps (Åber Strecke)
ER_FLY_Y      EQU       -128              ; Flughîhe des Beobachters.
er_beo:       DC.W      30,0,0,0,-0*200,-1000
              DC.W      720-180,0,0,0,-27020,0
er_init:      lea       er_pal(pc),VDI_PAL
              lea       anim_buf+9000,DEST_PAL
              moveq     #16,COLSTEPS
              bsr.w     VDI_9800          ; Palette ins Falcon-Format.
              moveq     #16,d7
              lea       anim_buf+9000,a0
              bsr.w     mask_pal          ; Palette ausmaskieren.

              moveq     #15,d7
              move.l    anim_buf+9000,d0
              lea       anim_buf+9500,a0
er_gen_fo:    move.l    d0,(a0)+
              dbra      d7,er_gen_fo

              lea       anim_buf,a0       ; Welt anhand Zufallsdaten in Ani-
              lea       D_wald,a1         ; buffer aufbauen.
              move.l    a0,a2
              move.w    #ANZ_TB,(a0)+

              move.w    #O_TABAUM_1,d5    ; "move.l #(O_TABAUM_1<<16)|MOVE,d5"
              swap      d5
              move.w    #MOVE,d5
              moveq     #ANZ_TB-1,d7      ; Tannenbaumreihen
              bmi.s     tb_no_tb          ; Keine TannenbÑume.
tb_zeile:     move.l    d5,(a0)+          ; Movekennung und Objektnummer.
              move.w    (a1)+,(a0)+       ; x
              clr.w     (a0)+             ; y immer auf dem Boden...
              move.w    (a1)+,(a0)+       ; z
              dbra      d7,tb_zeile       ; NÑchste Reihe.

tb_no_tb:     add.w     #ANZ_ST,(a2)      ; Strecke aufbauen.
              move.w    #STRECKE_A,d5     ; Streckenobjekt.
              swap      d5
              move.w    #MOVE,d5          ; Ist einfaches "Move"
              lea       D_strecke,a1
              move.w    #ANZ_ST-1,d7
tb_st:        move.l    d5,(a0)+          ; Objektkennung / Typ
              move.w    (a1)+,(a0)+       ; x
              clr.w     (a0)+             ; y ist immer am Boden festgeklebt.
              move.w    (a1)+,(a0)+       ; z
              dbra      d7,tb_st          ; NÑchstes StreckenstÅck.

              lea       -3*4-4(a1),a1     ; Das Starttor um eines der ersten
              add.w     #150,(a1)         ; durchfahrenen Toren zentrieren.
              move.w    (a1)+,er_tor+4
              add.w     #300,(a1)
              move.w    (a1),er_tor+8

              lea       er_add_poi(pc),a2
              lea       er_add1(pc),a1    ; ZusÑtzlichen Objekte (Wand etc...)
              move.w    (a1)+,d7          ; (d.h. MOVE-Objekte).
              subq.w    #1,d7
              bmi.s     er_noadd
              add.w     d7,anim_buf
              addq.w    #1,anim_buf       
er_cpy_add1:  move.l    (a1)+,(a0)+       ; Typ und Objektnummer.
              move.l    a0,(a2)+          ; Pointer auf Koordinate sichern.
              move.l    (a1)+,(a0)+
              move.w    (a1)+,(a0)+       ; Ort.
              dbra      d7,er_cpy_add1

er_noadd:     lea       er_add2(pc),a1    ; ZusÑtzlichen Objekt (bewegten Obj-
              move.w    (a1)+,d7          ; jekte).
              subq.w    #1,d7
              bmi.s     er_noadd2
              lea       er_mobj_1(pc),a2  ; Pointer fÅr Bewegungen...
              add.w     d7,anim_buf
              addq.w    #1,anim_buf       
er_cpy_add2:  move.l    (a1)+,(a0)+       ; Typ und Objektnummer.
              move.l    a0,(a2)+          ; Pointer auf Rot/Ort sichern.
              move.l    (a1)+,(a0)+       ; Rotation/Ort
              move.l    (a1)+,(a0)+
              move.l    (a1)+,(a0)+
              dbra      d7,er_cpy_add2

er_noadd2:    lea       er_beo(pc),a0
              moveq     #$ff,d0           ; 4-Planes / 25 fps
              moveq     #1,d1
              moveq     #4,d2
              moveq     #2,d3
              bsr.w     set_world

              lea       anim_buf+9000,a0  ; Palette einfaden lassen.
              bra.w     inst_norm_fade

er_frame:     movea.l   er_mobj_1(pc),a0
              moveq     #0,d0
              moveq     #0,d1
              moveq     #5,d2
              bsr.w     rot_d03
              subq.w    #7,6(a0)

              moveq     #4-1,d7                 ; Die Kugeln bewegen sich nur
              movea.l   er_add_poi+8(pc),a0     ; auf und wenn sie oben sind,
              addq.l    #2,a0                   ; flippen sie nach unten (was
er_mov_kug:   subq.w    #6,(a0)                 ; ist schon realistisch...)
              cmp.w     #-600,(a0)
              bgt.s     er_nd_kug
              add.w     #600,(a0)
er_nd_kug:    lea       10(a0),a0
              dbra      d7,er_mov_kug

er_rot_beo:   move.w    er_modus(pc),d0   ; Fliegt der Beobachter noch oder
              bmi.s     er_move_spline    ; dreht er sich gerade ?
              beq.s     er_scrclr

              move.w    d0,beovek+2
              subq.w    #2,er_modus
              bra.s     er_scrclr         

er_move_spline:
              move.w    er_stand(pc),d0   ; Beobachter Åber die Strecke dÅsen
              subq.w    #1,d0             ; lassen.
              bgt.s     er_mov_noe
              blt.s     er_scrclr

              move.w    d0,er_stand
              lea       anim_buf+9500,a0
              bra.w     inst_norm_fade

er_mov_noe:   move.w    d0,er_stand
              movem.w   (D_er_move,d0.w*4),d4/d6    ; Beobachterstandpunkt
;             MULF_3    d0,d1
;             movem.w   (D_er_beo,d0.w*2),d1-d3     ; Beobachterblickwinkel
              moveq     #ER_FLY_Y,d5                ; Beobachter"flug"hîhe.
              lea       beovek(pc),a0
              movem.w   d4-d6,6(a0)
              moveq     #0,d0
              moveq     #0,d1
              moveq     #-2,d2
;             bsr.w     rot_d03

er_scrclr:    moveq     #25-1,d6                ; Screen mit "kÅnstlichem"
              moveq     #(200-(25*4))/4-1,d7    ; Horizont lîschen.
              bra.w     k_horizont

er_modus:     DC.W      -1
er_stand:     DC.W      ANZ_ER_MOVE
er_s2:        DC.W      0

er_data:      DC.W      1                 ; Daten werden bei Init erzeugt.
              DC.W      O_CUBE_D,FULL,40,60,70,0,0,0

; *** Die zusÑtzlich eingebauten Objekte, nur beweglich ***
er_add1:      DC.W      6
              DC.W      GIGA_PLATE,MOVE,5400,0,21500
er_tor:       DC.W      GIGA_TOR,MOVE,5800,0,4500
er_kugel_1:   DC.W      KUGEL_1,MOVE,6500,-100,14000
              DC.W      KUGEL_1,MOVE,4500,100,9000
              DC.W      KUGEL_1,MOVE,7000,0,11000
              DC.W      KUGEL_1,MOVE,4000,0,17000

er_add_poi:   DS.L      6

R1SX          EQU       7500
; *** Die zusÑtzlich eingebauten Objekte, beweglich mit Eigenrotation. ***
er_add2:      DC.W      1
              DC.W      ROOMER1,FULL,0,180,0,R1SX,-200,10000

er_mobj_c1:   DC.W      140
er_mobj_1:    DS.L      1

er_pal:       DC.W      100,0,300                       ; 0
              DC.W      700,0,900,600,0,800,500,0,700   ; 1-3
              DC.W      900,700,0,800,600,0,700,500,0   ; 4-6

              DC.W      800,0,800               ; 7   Farbe der "groûen" Wand.
              DC.W      500,0,650,350,0,500     ; 8-9 Farben des Tors.

              DC.W      650,500,390             ; 10    : Mediumwood
              DC.W      600,450,340             ; 11    : Darkwood.
              DC.W      550,400,290             ; 12    : Even darker wood.
              DC.W      910,760,650,860,710,600 ; 13-14 : Lightwood.

              DC.W      360,200,90                      ; 15

*****************************************************************************
* << MEGACUBES-2 >> (Cubetunnel 1, der am Beobachter "vorbeiscrollt")       *
*****************************************************************************
mc_beo:       DC.W      36,0,0,0,0,0
mc_init:      st        disable_sync
              suba.l    a0,a0
              moveq     #RELOAD_MC,d0
              bsr.w     new_ani_blk

              lea       mc_beo(pc),a0     ; Blick leicht nach unten geneigt.
              clr.b     planes            ; VerÑnderungen erzwingen Umschaltung.
              clr.b     detail
              moveq     #$ff,d0
              moveq     #1,d1             ; Planemode
              moveq     #4,d2             ; 16 Farben deckend.
              moveq     #3,d3             ; 50/3 fps zum "Aufladen"
              bsr.w     set_world
              move.l    #$1,akt_scr

              lea       mc_pal(pc),VDI_PAL      ; Farbpalette umwandeln...
              movea.l   VDI_PAL,DEST_PAL
              moveq     #16,COLSTEPS
              bsr.w     VDI_9800
              lea       mc_pal(pc),a0
              moveq     #16,d7
              bsr.w     mask_pal

              lea       anim_buf,a0       ; Ausfadepalette generieren.
              moveq     #15,d7            ; Es wird auf Schwarz ausgefadet,
mc_gen_af:    clr.l     (a0)+             ; wegen Bildrand und "sw_viel".
              dbra      d7,mc_gen_af

              clr.b     disable_sync
              lea       mc_pal(pc),a0
              bra.w     inst_norm_fade

MC_END        EQU       50*4              ; Anzahl Frames sichtbar (normal).
MC_E          EQU       100               ; Anzahl Frames bis 50 fps.
MC_ENDEND     EQU       MC_END+MC_E+30    ; Zeitpunkt fÅr's Gedicht.
MC_WAIT0      EQU       50
mc_frame:     move.w    ani_frm(pc),d0
              cmp.w     #MC_ENDEND,d0
              bne.w     mc_no_poem

              movea.l   free_screen,a0
              lea       (640*240.l,a0),a1
              bsr.w     clr_mem

              lea       D_mugpic0,a0      ; Direkt in Diskbuffer decrunchen,
              bsr.w     ice_decrunch_2    ; damit "sw_viel" regulÑre Screens
                                          ; vorberechnen kann.
              bsr.w     vsync
              bsr.w     hardsw_32k
              move.l    free_screen,d0
              SET_V_ADR d0,d1

              lea       D_mugpic0,a0      ; Bild einblenden.
              movea.l   free_screen,a1
              bsr.w     hc_show1
              st        disable_sync

              move.w    #MC_WAIT0,d7
              bsr.w     vsync_xx

              movea.l   free_screen,a0    ; Und Bild zurÅck in Buffer kopieren.
              move.l    #D_mugpic0+256,d1
              clr.b     d1
              movea.l   d1,a1
              move.w    #640*240/16-1,d0
              bsr.w     cpy_mem16

              bsr.w     vsync
              SET_V_ADR d1,d0

              lea       $ffff9800.w,a0    ; Komplette Farbpalette lîschen.
              lea       256*4(a0),a1
              bsr.w     clr_mem

              moveq     #SZ_SW_VIEL,d0    ; "Swinging Viel" Vorberechnung...
              bra.w     new_animat

mc_no_poem:   cmpi.w    #MC_ENDEND-64,d0  ; Schon Zeit zum Ausfaden ?
              bne.s     mc_no_fade

              lea       anim_buf,a0       ; Ausfaden installieren.
              bsr.w     inst_norm_fade

mc_no_fade:   cmp.w     #MC_END+MC_E,ani_frm    ; Zeit, um aufgeladene Buffer
              bne.s     mc_no_fast              ; mit 50 fps abzulassen ?

              subq.w    #2,anz_vbls

mc_no_fast:   lea       beovek(pc),a0

              cmp.w     #MC_END,ani_frm   ; Beginn des Endes ?
              blt.s     mc_no_end

              tst.w     (a0)              ; Schon voll hochgedreht ?
              beq.s     mc_no_end

              subq.w    #1,(a0)           ; Beobachter nach oben drehen.

mc_no_end:    moveq     #0,d0             ; Beobachter dreht sich.
              moveq     #0,d1
              moveq     #3,d2             ; Rotationsgeschwindigkeit.
              bsr.w     rot_d03

              lea       beo+4(pc),a0      ; Beobachter fliegt vor und wenn sich
              move.w    (a0),d0           ; das Startbild und das aktuelle
              addi.w    #32,d0            ; Bild decken, flippt er zurÅck.
plusplus:     cmpi.w    #-1600+640+64,d0
              blt.s     no_back
              move.w    #-1600,d0
no_back:      move.w    d0,(a0)

;             pea       clear_screen_par(pc)
;             bsr.w     INIT_PARALLEL
              bra.w     clr_screen        ; Screen lîschen.

mc_data:      DC.W      24                ; Tunnel besteht aus 24 WÅrfeln,
              DC.W      MC_CUBE_1,MOVE    ; bzw. jeweils drei Seiten davon...
              DC.W      270,-270,-960
              DC.W      MC_CUBE_2,MOVE
              DC.W      270,270,-960
              DC.W      MC_CUBE_3,MOVE
              DC.W      -270,270,-960
              DC.W      MC_CUBE_4,MOVE
              DC.W      -270,-270,-960
              DC.W      MC_CUBE_1,MOVE
              DC.W      270,-270,-320+1*64
              DC.W      MC_CUBE_2,MOVE
              DC.W      270,270,-320+1*64
              DC.W      MC_CUBE_3,MOVE
              DC.W      -270,270,-320+1*64
              DC.W      MC_CUBE_4,MOVE
              DC.W      -270,-270,-320+1*64
              DC.W      MC_CUBE_1,MOVE
              DC.W      270,-270,320+2*64
              DC.W      MC_CUBE_2,MOVE
              DC.W      270,270,320+2*64
              DC.W      MC_CUBE_3,MOVE
              DC.W      -270,270,320+2*64
              DC.W      MC_CUBE_4,MOVE
              DC.W      -270,-270,320+2*64
              DC.W      MC_CUBE_1,MOVE
              DC.W      270,-270,960+3*64
              DC.W      MC_CUBE_2,MOVE
              DC.W      270,270,960+3*64
              DC.W      MC_CUBE_3,MOVE
              DC.W      -270,270,960+3*64
              DC.W      MC_CUBE_4,MOVE
              DC.W      -270,-270,960+3*64
              DC.W      MC_CUBE_1,MOVE
              DC.W      270,-270,1600+4*64
              DC.W      MC_CUBE_2,MOVE
              DC.W      270,270,1600+4*64
              DC.W      MC_CUBE_3,MOVE
              DC.W      -270,270,1600+4*64
              DC.W      MC_CUBE_4,MOVE
              DC.W      -270,-270,1600+4*64
              DC.W      MC_CUBE_1,MOVE
              DC.W      270,-270,1600+640+5*64
              DC.W      MC_CUBE_2,MOVE
              DC.W      270,270,1600+640+5*64
              DC.W      MC_CUBE_3,MOVE
              DC.W      -270,270,1600+640+5*64
              DC.W      MC_CUBE_4,MOVE
              DC.W      -270,-270,1600+640+5*64

mc_pal:       DC.W      100,0,200 ; MUû wegen des "eyes"-Pic sehr dunkel sein!
              DC.W      900,910,980,850,860,930,800,810,880 ; Silber
              DC.W      800,498,196,750,448,146,700,398,096 ; Gold
              DC.W      859,859,196,819,819,146,769,769,096 ; Goldenrod
              DC.W      650,490,240,600,440,190,550,390,140 ; Bronze
              DC.W      137,420,557,137,420,557             ; Steelblue (2*)

*****************************************************************************
* << Schwinging Viel: Alles rotiert... >>                                   *
* (Screenorg. 8 Planes, Monochromhintergrund, Sprites).                     *
*****************************************************************************
SW_ANZ_BMP    EQU       4                 ; Anzahl Bitmap Animationen.
SW_END        EQU       1600              ; Dann endet det Spaû !
SW_BACK_PAL   EQU       anim_buf+28000    ; Pointer auf Palette aus Hintergrund.

sw_beo:       DC.W      0,0,0,0,0,-150
sw_init:
        IFEQ  (STARTANI-SZ_SW_VIEL)       ; Test dieser Animation ?
              moveq     #RELOAD_MC,d0     ; Dann Daten nachladen !
              suba.l    a0,a0
              bsr.w     new_ani_blk
        ENDIF

              move.b    #1,detail         ; Ausgabe umprogrammieren, ohne
              move.b    #8,planes         ; Hardware zu informieren !
              lea       akt_scr(pc),a0
              move.l    #$00010000,(a0)+
              move.w    #_256_ANZ_VBLS,(a0)+
              move.w    #_256_BYTES_SCAN,(a0)+
              move.l    #_256_BYTES_SCREEN,(a0)+
              move.w    #_256_ANZ_SCREENS,(a0)+
              move.l    #_256_CLR_OFF,(a0)+
              move.l    #scr_lst_256,(a0)
              clr.l     clr_scr

              bsr.w     clr_screens

              lea       beovek(pc),a0
              clr.l     (a0)+
              clr.l     (a0)+
              move.l    #$0000ff6a,(a0)   ; Beo-Z = -150

              lea       D_splat1,a0       ; Im Hintergrundbild (splat1) sind
              move.w    #4000/8-1,d7      ; Farbe 0 und 1 vertauscht. Um nicht
sw_eor_pic:   not.l     (a0)+             ; die Palette umstellen zu mÅssen,
              not.l     (a0)+             ; Bild umwursteln...
              not.l     (a0)+
              not.l     (a0)+
              dbra      d7,sw_eor_pic

              moveq     #8,d0             ; In allen Bilder Hintergrund (splat1)
              moveq     #19,d6            ; auf Plane 5 setzen.
              move.w    #200-1,d7
              lea       D_splat1,a0
              bsr.w     fill_one_plane

              move.l    #anim_buf,free    ; Erste freie Bufferadresse.

              st        disable_sync      ; Drehung der Riesenrades am
              move.w    #2*48-1,d7        ; rechten Rand vorberechnen...
ex_loop:      move.w    d7,-(sp)          ; Zur Sicherheit wegen des Trackers
              bsr.w     vsync             ; werden einige VSyncs eingestreut.
              moveq     #5-1,d5
ex_lp_inner:  move.w    d5,-(sp)
              bsr.w     sw_frame_m
              lea       sw_data_init(pc),a0
              bsr.w     obj_handler
              bsr.w     ready_frame
              move.w    (sp)+,d5
              dbra      d5,ex_lp_inner
              move.w    (sp)+,d7
              dbra      d7,ex_loop

              lea       sw_pal(pc),VDI_PAL      ; Palette umwandeln.
              movea.l   VDI_PAL,DEST_PAL
              moveq     #32,COLSTEPS
              bsr.w     VDI_9800
              lea       sw_pal(pc),a0     ; Palette ausmaskieren.
              moveq     #32,d7
              bsr.w     mask_pal

              lea       SW_BACK_PAL,a0    ; Palette nur aus Hintergrund (zum
              movea.l   a0,a1             ; Ausfaden des Bildes).
              move.l    sw_pal(pc),d0
              moveq     #31,d7
sw_gen_bapal: move.l    d0,(a1)+
              dbra      d7,sw_gen_bapal
              move.l    a1,free

              move.w    #150,d7           ; Das Bild noch etwas hÑngen lassen.
              bsr.w     vsync_xx

              lea       $ffff9800.w,a0    ; Alle 256 Farben auf Hintergrund.
              move.l    sw_pal(pc),d0     ; (Um Farbfehler beim Einfaden zu
              moveq     #256/2-1,d7       ; vermeiden).
sw_cpy_pal:   move.l    d0,(a0)+
              move.l    d0,(a0)+
              dbra      d7,sw_cpy_pal

              bsr.w     hc_clr_scr        ; Das stehende Bild lîschen.

; Die ganzen Sprites in den freien Screen shiften, da der Ani-Buffer sonst
; nur fÅr diesen Zweck vergrîûert werden mÅûte !
              movea.l   free_screen,a3          ; Bufferadresse.
              lea       sw_bmp_anis(pc),a4      ; Datenblîcke.
              lea       sw_sizes(pc),a5         ; Spritegrîûen.
              lea       sw_fades(pc),a6         ; Farbdaten.
              moveq     #SW_ANZ_BMP,d7          ; Anzahl Animationen.
              bsr.w     init_bmp_anis

              clr.l     bmp_ani           ; Relativer Framecounter zurÅck.
              clr.b     disable_sync      ; Sync an.
              move.l    #$1,akt_scr

              clr.b     detail            ; Beide Ñndern, sonst denkt Umsch-
              clr.b     planes            ; altung, daû nichts getan werden muû.
              lea       sw_beo(pc),a0     ; Einplane Modus und 50 fps
              moveq     #0,d0             ; (8 Planemode, Screens nicht clr.)
              moveq     #1,d1             ; (Videohardware erst nach der Vor-
              moveq     #8,d2             ; berechnung umschalten !).
              moveq     #1,d3
              bsr.w     set_world

              clr.w     std_fade_in       ; Zur Sicherheit.
              move.l    #sw_vbl,world_vbl ; VBL installieren.

              lea       sw_pal+4(pc),a0   ; 32 Farben einfaden.
              moveq     #64,d5
              moveq     #1,d6
              moveq     #31,d7
              bra.w     inst_fade

sw_vbl:       bsr.w     vbl_ani           ; Anihandling.

              lea       $ffff9820.w,a0    ; Fading auf Plane 5 Åbernehmen,
              lea       $ffff9860.w,a1    ; damit die Anis alles decken !
              move.l    (a0)+,(a1)+
              move.l    (a0)+,(a1)+
              move.l    (a0)+,(a1)+
              move.l    (a0)+,(a1)+
              move.l    (a0)+,(a1)+
              move.l    (a0)+,(a1)+
              move.l    (a0)+,(a1)+
              move.l    (a0)+,(a1)+
              rts       

sw_frame_m:   moveq     #0,d0             ; Bewegung des vorberechneten
              moveq     #0,d1             ; Rades...
              moveq     #1,d2
              lea       sw_in_rot(pc),a0
              bra.w     rot_d03

sw_frame:     move.w    ani_frm(pc),d0
              cmpi.w    #SW_END-64-64,d0  ; Zeit zum Ausfaden ?
              bne.s     sw_no_fo

              lea       SW_BACK_PAL,a0
              moveq     #64,d5
              moveq     #0,d6
              moveq     #32,d7
              bsr.w     inst_fade
              clr.l     world_vbl         ; Keine BMP-Anis mehr --> VBl aus.

sw_no_fo:     cmpi.w    #SW_END,d0        ; Sollte langsam aufgehîrt werden
              bne.s     sw_no_end         ; und das langersehnte Gedicht zu
                                          ; sehen sein ?
              lea       D_jl_vi,a0
              moveq     #NOLOAD,d0
              bsr.w     set_poem

              moveq     #SZ_GOURPROOF,d0
              bra.w     new_animat

sw_no_end:    moveq     #0,d0                   ; PLANE 0-1
;             pea       clr_plane_2_par(pc)
;             bsr.w     INIT_PARALLEL           ; lîschen.
              bsr.w     clr_plane_2

              lea       sw_stamm(pc),a0
              cmp.w     #180,4(a0)
              blt.s     sw_oben
              cmp.w     #360+180,4(a0)
              bgt.s     sw_oben           

              move.w    #150,6(a0)
              move.w    #-620,8(a0)
              bra.s     sw_good

sw_oben:      move.w    #-100,6(a0)
              move.w    #620,8(a0)

sw_good:      moveq     #9-1,d3           ; Die einfach drehenden Striche.
              lea       16.w,a3           ; Offset Obj->Obj.
              moveq     #0,d0             ; a = b = 0
              moveq     #0,d1
              lea       sw_stamm(pc),a0
              lea       sw_rot_z(pc),a6
sw_rot_str:   move.w    (a6)+,d2          ; c.
              bsr.w     rot_d03
              adda.l    a3,a0
              dbra      d3,sw_rot_str

              lea       sw_obj_1(pc),a0
              lea       sw_xy(pc),a1
              lea       sinus720,a2       ; Sinustabelle
              move.w    (a1),d0
              subq.w    #2,d0
              bpl.s     sw_no_prob
              addi.w    #720,d0
sw_no_prob:   move.w    d0,(a1)+

              move.w    (a2,d0.w*2),d2
              move.w    ((720/4)*2.w,a2,d0.w*2),d1
              ext.l     d1
              ext.l     d2
              asl.l     #8,d1
              asl.l     #8,d2
              swap      d1
              swap      d2

              addq.w    #2,(a1)
              add.w     (a1)+,d1
              subq.w    #2,(a1)
              add.w     (a1),d2

              cmp.w     #-770,(a1)
              bgt.s     sw_no_fl_bk

              neg.w     (a1)
              neg.w     -(a1)

sw_no_fl_bk:  movem.w   d1-d2,6(a0)
              rts

SW_BACK_R     EQU       0
SW_BACK_G     EQU       0
SW_BACK_B     EQU       0
SWG           EQU       225               ; GrÅnanteil fÅr Hintergrungschimm.
sw_pal:       DC.W      SW_BACK_R,SW_BACK_G,SW_BACK_B
              DC.W      250,0,650
              DC.W      300,0,700,350,0,750
              DC.W      400,0,800,450,0,850,500,0,900,550,0,950
              DS.W      8*3,500

              DC.W      500,600,100       ; Hintergrundfarbe "splat1"
              DC.W      250,SWG,650
              DC.W      300,SWG,700,350,SWG,750
              DC.W      400,SWG,800,450,SWG,850,500,SWG,900,550,SWG,950
              DS.W      8*3,500

sw_fades:     DC.W      400,0,800,200,0,400         ; Pacman
              DC.W      700,350,0,250,0,650                         ; Birne
              DC.W      900,0,100,250,0,650                         ; Blut
              DC.W      450,0,900,200,0,600                         ; Nacht

sw_sizes:     DC.W      2,32,5            ; Ani-1: Grîûen x,y, Anzahl Phasen.
              DC.L      D_sw_bitmap1
              DC.W      4,64,1            ; Ani 2: Birne
              DC.L      D_spr_birne
              DC.W      2,35,4            ; Ani 3: Blut (Text)
              DC.L      D_spr_blut
              DC.W      4,70,5            ; Ani 4: Nacht (Text)
              DC.L      D_spr_nacht

sw_bmp_anis:  ; Die Animationen:

; PACMAN !
sw_bmp_ani1:  DC.W      32,50             ; Start-x/y
              DC.W      5,6,0             ; Anz. Anis / Speed / Mode
              DC.W      200,6,32          ; Anzahl Moves / Plane / Fadeschr.
              DC.W      1,0               ; x/y Increment
              DC.L      anim_buf,0        ; Grafikadresse / Tabellenadresse
sw_ani1_pal:  DC.L      0                 ; Fadingpalette (wird generiert)

; BIRNE !
sw_bmp_ani2:  DC.W      232,150           ; Start-x/y
              DC.W      1,6,0             ; Anz. Anis / Speed / Mode
              DC.W      135,6,32          ; Anzahl Moves / Plane / Fadeschr.
              DC.W      0,0               ; x/y Increment
sw_bmp2_adr:  DC.L      0,0               ; Grafikadr. (gen.) / Tab.adr.
sw_ani2_pal:  DC.L      0                 ; Fadingpalette (wird gen.)

; BLUT (TEXT) !
sw_bmp_ani3:  DC.W      110,90            ; Text bewegt sich langsam nach links.
              DC.W      4,10,0
              DC.W      8*10,6,32
              DC.W      -1,0
sw_bmp3_adr:  DC.L      0,0
sw_ani3_pal:  DC.L      0

; NACHT (TEXT) !
sw_bmp_ani4:  DC.W      20,40
              DC.W      5,10,0
              DC.W      5*10*4,6,32
              DC.W      0,0
sw_bmp4_adr:  DC.L      0,0
sw_ani4_pal:  DC.L      0

sw_bmp:       DC.W      40
              DC.L      sw_bmp_ani1
              DC.W      350
              DC.L      sw_bmp_ani2
              DC.W      650
              DC.L      sw_bmp_ani3
              DC.W      950
              DC.L      sw_bmp_ani2
              DC.W      1285
              DC.L      sw_bmp_ani4
              DC.W      -1

sw_xy:        DC.W      719,-770,770
sw_rot_z:     DC.W      1,3,-2,3,-2,1,-2
              DC.W      1,-1,1,-3         ; "grosse" Kreisbahnen.

sw_data:      DC.W      7
              DC.W      BSTAMM_12,FULL
sw_stamm:     DC.W      0,0,600,-100,650,2000
              DC.W      WUERFEL_5,FULL
              DC.W      0,0,500,-300,105,2000
              DC.W      OPEN_QUADRAT,FULL
              DC.W      0,0,100,540,330,5000
              DC.W      BSTAMM_12,FULL
              DC.W      0,0,200,700,-390,4000
              DC.W      WUERFEL_5,FULL
              DC.W      0,0,300,-500,-300,2000
              DC.W      OPEN_QUADRAT,FULL
              DC.W      0,0,400,950,910,4200
              DC.W      BSTAMM_1,FULL
              DC.W      0,0,0,-750,520,3800
              DC.W      BSTAMM_1,FULL
              DC.W      0,0,0,-240,-270,1200
              DC.W      BSTAMM_12,FULL
sw_obj_1:     DC.W      0,0,0,0,0,1200

sw_data_init: DC.W      1
              DC.W      BSTAMM_13,FULL          ; ***
sw_in_rot:    DC.W      0,0,20,330,190,0


******************************************************************************
* << MATHEMATICA >> ENDSCREEN - KONVERSION MIT WöRFELN...                    *
******************************************************************************

C_SWIN_ANZ    EQU       6                 ; Anzahl WÅrfel.
C_COLS_ANZ    EQU       39                ; Anzahl Farbpaletten.
CS_ANZ_FRAMES EQU       50*15             ; Anzahl der Frames bis zum Abwinken.
CS_END        EQU       578-48            ; In (~+CS_ANZ_FRAMES) Frames ausbl.
CS_ANZ_PIC    EQU       100               ; ~ VBLs steht das Pic alleine rum.
col_fade_200: DC.W      C_COLS_ANZ-1
              DC.L      _AQUAMARINE,_BLUEVIOLET,_BROWN,_CADETBLUE
              DC.L      _CORAL,_CORNFLOWERBLUE,_DARKGREEN,_DARKOLIVEGREEN
              DC.L      _DARKORCHID,_DARKSLATEBLUE,_FIREBRICK,_GOLD,_GOLDENROD
              DC.L      _GREENYELLOW,_INDIANRED,_KHAKI,_LIGHTBLUE,_LIGHTSTEELBLUE
              DC.L      _MEDIUMSLATEBLUE,_MIDNIGHTBLUE,_LIMEGREEN,_MAROON
              DC.L      _MEDIUMTURQUOISE,_MEDIUMVIOLETRED,_NAVY,_ORCHID,_ORANGE
              DC.L      _PINK,_PLUM,_SIENNA,_TAN,_THRISTLE,_VIOLET
              DC.L      _VIOLETRED,_YELLOWGREEN,_WHEAT,_SUMMERSKY,_RICHBLUE
              DC.L      _MEDIUMAQUAMARINE,_AQUAMARINE

c_s_beo:      DC.W      0,0,0,0,0,-50
c_swinger_init:
              lea       anim_buf,a5       ; FarbverlÑufe aufbauen.
              lea       col_fade_200(pc),a6
              move.w    (a6)+,d6
col_200_lp:   movea.l   (a6)+,STARTCOL    ; Gibt eine Riesenpalette, die linear
              movea.l   (a6),ENDCOL       ; Åber alle aufgelisteten Farben int-
              movea.l   a5,CALC_PAL       ; erpoliert wird.
              moveq     #64,COLSTEPS
              bsr.w     CALC_PAL_VDI

              movea.l   a5,VDI_PAL
              movea.l   a5,DEST_PAL
              moveq     #64,COLSTEPS
              bsr.w     VDI_9800

              lea       64*4(a5),a5
              dbra      d6,col_200_lp

              lea       cs_back(pc),VDI_PAL
              movea.l   VDI_PAL,DEST_PAL  ; Hintergrund und Vordergrund um-
              moveq     #2,COLSTEPS       ; rechnen.
              bsr.w     VDI_9800

              st        disable_sync
              movea.l   a0,a6
              moveq     #64,d5
              moveq     #0,d6
              moveq     #0,d7
              bsr.w     inst_fade
              add.w     #50,frm_counter
              moveq     #40,d7
              bsr.w     vsync_xx

              lea       $ffff9800.w,a1
              move.l    (a6)+,(a1)        ; Nachblauer Hintergrund.
              move.l    (a6),15*4(a1)     ; Weisser Vordergrund.

              lea       c_s_beo(pc),a0
              moveq     #-1,d0            ; Screens lîschen.
              moveq     #1,d1             ; Planemode
              moveq     #4,d2             ; 16 Farben deckend.
              moveq     #1,d3             ; 50 fps.
              bsr.w     set_world
              
              clr.b     disable_sync
              rts

c_swinger_vbl:
              lea       anim_buf,a0       ; Im VBL Farben faden lassen.
              lea       c_s_col(pc),a1    ; KANN NOCH GANZ GEWALTIG OPTIMIERT WERDEN !!!
              lea       $ffff9804.w,a2
              moveq     #14,d7
c_cols_vbl:   move.w    (a1),d0
              addq.w    #1,d0
              cmpi.w    #C_COLS_ANZ*64,d0
              blt.s     no_loop
              clr.w     d0
no_loop:      move.w    d0,(a1)+
              move.l    (a0,d0.w*4),(a2)+
              dbra      d7,c_cols_vbl
              rts

c_swinger_frame:
              lea       c_swinger_move(pc),a3
              lea       sinus720,a1       ; Sinustabelle
              lea       (720/4)*2(a1),a2  ; Cosinustabelle
              
              move.w    #719,d3
              moveq     #C_SWIN_ANZ-1,d7
c_swing_lp:   move.l    (a3)+,a0          ; Winkel- und Objektkoordinate.
              movem.w   (a3)+,d4-d6/a4-a6 ; Sinusmultiplikationswerte.
              movem.w   (a3)+,d0-d2       ; Tabellenstand.
              add.w     (a3)+,d0          ; Offsets addieren.
              add.w     (a3)+,d1
              add.w     (a3)+,d2

              cmp.w     d3,d0             ; Winkeloffsets clippen.
              blt.s     *+4
              sub.w     d3,d0
              cmp.w     d3,d1
              blt.s     *+4
              sub.w     d3,d1
              cmp.w     d3,d2
              blt.s     *+4
              sub.w     d3,d2

cs_moved:     movem.w   d0-d2,-12(a3)

              tst.w     d4                ; Die Koordinaten werden aus der
              bpl.s     sinus_x           ; normalen Sinus/Cosinustab (0.5 Grad)
              neg.w     d4                ; errechnet, eine abgelegte Tabelle
              move.w    (a2,d0.w*2),d0    ; wÑre viel zu groû und wÅrde vergl-
              bra.s     finished_x        ; eichsweise wenig bringen.
sinus_x:      move.w    (a1,d0.w*2),d0
finished_x:   muls.w    d4,d0
              add.l     d0,d0
              swap      d0

              tst.w     d5
              bpl.s     sinus_y
              neg.w     d5
              move.w    (a2,d1.w*2),d1
              bra.s     finished_y
sinus_y:      move.w    (a1,d1.w*2),d1
finished_y:   muls.w    d5,d1
              add.l     d1,d1
              swap      d1

              tst.w     d6
              bpl.s     sinus_z
              neg.w     d6
              move.w    (a2,d2.w*2),d2
              bra.s     finished_z
sinus_z:      move.w    (a1,d2.w*2),d2
finished_z:   muls.w    d6,d2
              add.l     d2,d2
              swap      d2

              add.w     a4,d0             ; Koordinatenoffsets.
              add.w     a5,d1
              add.w     a6,d2

              move.w    (a3),d4
              subq.w    #1,d4
              add.w     d4,d1             ; y-Koord. nach oben bewegen.

              tst.w     cs_phase(pc)      ; Bereits im Ausblenden ?
              bpl.s     norm_al           ; Ja --> kein ZurÅckflippen mehr.

              cmpi.w    #-260,d1          ; Sonst: ggf. nach unten zurÅck-
              bgt.s     norm_al           ; flippen.
              addi.w    #610,d1
              move.w    d1,d4
norm_al:      move.w    d4,(a3)+

              movem.w   d0-d2,6(a0)       ; Neue Koordinate setzen.
              movem.w   (a3)+,d0-d2       ; Winkel anpassen.
              movea.w   d7,a4
              bsr.w     rot_d03
              move.w    a4,d7

              dbra      d7,c_swing_lp     ; NÑchsten Cube fliegen lassen.

              addq.w    #1,cs_phase
              cmpi.w    #CS_END,cs_phase  ; Schon ganz am Ende ?
              blt.w     clr_screen        ; nein --> nur noch Screen lîschen.

              moveq     #49,d7            ; Buffer leerspielen.
              bsr.w     vsync_xx          ; Syncronisieren.

              lea       nullpal(pc),a0    ; Hintergrund ausfaden.
              bsr.w     inst_norm_fade
              add.w     #50,frm_counter
              moveq     #40,d7
              bsr.w     vsync_xx

              lea       D_li_xxxii,a0     ; "Mein sÅûes Lieb..." (Lyrisches
              moveq     #LOAD,d0          ; Datenblock laden / depacken.
              bsr.w     set_poem          ; Intermezzo XXXII) anzeigen.

              moveq     #SZ_MC2,d0        ; Megacubes-2 starten.
              bra.w     new_animat

c_swinger_frame_2:                        ; Same procedure than....
              lea       beovek(pc),a0     ; Nur mit zusÑtzlichem Swinging Åber
              moveq     #0,d0             ; Beobachterrotation.
              moveq     #0,d1
              moveq     #2,d2
              bsr.w     rot_d03
              bra.w     c_swinger_frame

c_swinger_move:
              DC.L      c_move_1
              DC.W      110,154,0         ; Sinusmultis. (neg.: Cos)
              DC.W      0,0,50            ; Koordinatenoffsets.
              DC.W      0,0,0             ; TabellenstÑnde.
              DC.W      3,2,1             ; Geschwindigkeit.
              DC.W      200
              DC.W      2,2,1
              DC.L      c_move_2          ; Cube 2
              DC.W      -80,-90,0
              DC.W      0,0,110
              DC.W      0,0,0
              DC.W      1,4,1
              DC.W      100
              DC.W      1,2,2
              DC.L      c_move_3          ; Cube 3
              DC.W      -130,-176,0
              DC.W      0,0,170
              DC.W      0,0,0
              DC.W      2,1,1
              DC.W      50
              DC.W      1,3,4
              DC.L      c_move_4          ; Cube 4
              DC.W      160,120,-0
              DC.W      0,0,230
              DC.W      40,0,0
              DC.W      4,2,1
              DC.W      300
              DC.W      3,2,3
              DC.L      c_move_5          ; Cube 5
              DC.W      189,-120,0
              DC.W      0,0,290
              DC.W      60,0,0
              DC.W      4,3,1
              DC.W      250
              DC.W      2,2,3
              DC.L      c_move_6          ; Cube 6
              DC.W      -112,-130,0
              DC.W      0,0,350
              DC.W      0,0,0
              DC.W      3,3,1
              DC.W      150
              DC.W      2,2,3

c_swinger_data:
              DC.W      C_SWIN_ANZ

              DC.W      O_CUBE_A,FULL
c_move_1:     DC.W      0,0,0,-100,0,100
              DC.W      O_CUBE_B,FULL
c_move_2:     DC.W      0,20,40,100,0,100
              DC.W      O_CUBE_C,FULL
c_move_3:     DC.W      0,100,100,0,110,120
              DC.W      O_CUBE_A,FULL
c_move_4:     DC.W      1,120,230,0,-100,100
              DC.W      O_CUBE_B,FULL
c_move_5:     DC.W      230,0,440,0,0,100
              DC.W      O_CUBE_C,FULL
c_move_6:     DC.W      0,20,710,0,0,100

c_s_col:      
COL_1         SET       0
           REPEAT
              DC.W      COL_1
COL_1         SET       COL_1+6
           UNTIL #(14-1)
              DS.W      2
cs_phase:     DC.W      -CS_ANZ_FRAMES

cs_back:      DC.W      314,0,376         ; Hintergrundfarbe.
              DC.W      800,800,800       ; Vordergrunfarbe.
              DS.W      2


; ************ POLYGONTESTSZENE. ***********
tst_init:     lea       def_beo(pc),a0
              moveq     #$ff,d0
              moveq     #1,d1
              moveq     #4,d2
              moveq     #1,d3
              bsr.w     set_world

;             lea       tst_spal(pc),a0
;             lea       tst_epal(pc),a1
;             lea       anim_buf,a2
;             lea       anim_buf+4096,a3
;             moveq     #2,d6
;             moveq     #32,d7
;             bsr.w     calc_fade_pal

              lea       mc_pal,a0
              moveq     #16,d7
              bsr.w     mask_pal

;             jsr       inst1

              lea       mc_pal,a0
              moveq     #64,d5
              moveq     #0,d6
              moveq     #15,d7
              bra.w     inst_fade
tst_vbl:      ;jsr      my_vbl_handler
              rts
tst_frame:    
              IFNE      0
              move.w    tst_count,d0
              addq.w    #1,d0
              cmpi.w    #60,d0
              blt.s     ggh
              clr.w     d0
ggh:          move.w    d0,tst_count
              move.w    (D_smooth1.l,pc,d0.w*2),tst_data+10
              ENDIF
              bra.w     clr_screen

tst_spal:     DC.W      1000,0,0,0,0,1000
tst_epal:     DC.W      0,0,0,0,0,0

tst_count:    DC.W      0
tst_data:     DC.W      1,KUGEL_1,FULL,0,0,0,0,0,0

nullpal:      DS.L      16,0
