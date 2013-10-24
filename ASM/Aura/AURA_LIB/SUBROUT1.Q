; This file contains additional Subrouts which specially made for the demo
; and so not usable as generally subrouts.
; (C) Copyright 1995 by Jochen Knaus, AURA.

*****************************************************************************
*                                                                           *
* ALLGEMEINE GRAFISCHE UNTERROUTINEN (Fades....).                           *
* INCLUDEFILES NICHT UNBEDINGT IN DIESEM FILE (wo sie halt gÅnstiger sind)  *
*                                                                           *
*  Routine       | P | Datum | Beschreibung                                 *
*  --------------+---+-------+-------------------------------------------   *
*  set_digi_clk  |256| 23.02 | Setzt Uhrzeit digital.                       *
*  hc_show1      |65k| 16.03 | Zeigt Highcolour Bild Åber Linien.           *
*  k_horizont    | 4 | 28.03 | Lîscht Screen mit kÅnstlichem Horizont.      *
*  hc_colclr     |65k|>28.03 | Lîscht HC Screenausschnitt mit Farbverlauf.  *
*  hc_clrscreen  |65k| 06.04 | Lîscht HC Ganzen Screen mit Farbverlauf.     *
*  set_poem      |256| 08.04 | Zeigt Gedicht in SVGA an.                    *
*  hc_clr_scr    |65k| 18.04 | Lîscht HC-Bild (als "Effekt")                *
*  hc_show2      |65L| 25.04 | öberblendung ohne Anhalten des Syncs.        *
*                                                                           *
*****************************************************************************

*****************************************************************************
* Setzt digitale Uhrzeit.                                                   *
* PARAMETER:  d0.l - Screenoffset (inkl. Plane (relativ zur Scan 20))       *
*             d1.w - Flag: == 1 : Auf Zehntel genau ausgeben.               *
*                          == 0 : Normal ausgeben (Stunden/Minuten/Sek.)    *
*****************************************************************************
set_digi_clk: lea       time(pc),a0       ; Aktuelle Uhrzeit holen.
              GET_TIMEA a0,a1

              lea       ([screen.w,pc],20*320.w,d0.l),a0    ; Screenposition.
              lea       timestamp+224,a1  ; Fontadresse.
              lea       5*80.w,a2         ; Offset Source.
              lea       5*320.w,a5        ;    "   Screen.
              lea       time(pc),a6       ; Zeit.
              moveq     #3-1,d7           ; 3 Ausgaben: Stunden/Minuten/Sek.
              add.w     d1,d7             ; Falls Zehntel gewÅnscht.
at_digital:   move.b    (a6)+,d0          ; Wert holen.
              extb      d0                ; --> Long
              divu.w    #10,d0

              lea       (80*38.w,a1,d0.w*8),a3  ; Zehnerstelle: Ziffergfx.adr.  
              move.l    a0,a4
              moveq     #20/5-2,d6        ; 20 Zeilen hohe Ziffern
at_digi_lp:   move.w    (a3),(a4)         ; 4 Zeilen setzen.
              move.w    80*1(a3),320*1(a4)
              move.w    80*2(a3),320*2(a4)
              move.w    80*3(a3),320*3(a4)
              move.w    80*4(a3),320*4(a4)
              adda.l    a2,a3
              adda.l    a5,a4
              dbra      d6,at_digi_lp
              move.w    (a3),(a4)
              move.w    80*1(a3),320*1(a4)
              move.w    80*2(a3),320*2(a4)

              swap      d0                ; Einerstelle
              lea       (19*80.w,a1,d0.w*8),a3  ; Zifferadresse (ohne Dp.)
              tst.w     d7
              bne.s     no_dp             ; Letzte Zahl: kein Doppelpunkt.
         IFNE (HUNDERSTEL-an)
              tst.w     d1                ; Hundertstelstelle nicht mit aus-
              bne.s     at_end            ; geben, da die eh nur rumzittert.
         ENDIF
              lea       -19*80(a3),a3     ; Auf Font mit Doppelpunkt.
no_dp:        lea       16(a0),a4
              moveq     #20/5-2,d6        ; 20 Zeilen hohe Ziffern
at_digi_lp2:  move.w    (a3),(a4)         ; 4 Zeilen setzen.
              move.w    80*1(a3),320*1(a4)
              move.w    80*2(a3),320*2(a4)
              move.w    80*3(a3),320*3(a4)
              move.w    80*4(a3),320*4(a4)
              adda.l    a2,a3
              adda.l    a5,a4
              dbra      d6,at_digi_lp2
              move.w    (a3),(a4)
              move.w    80*1(a3),320*1(a4)
              move.w    80*2(a3),320*2(a4)

              lea       32(a0),a0
              dbra      d7,at_digital     ; NÑchste Zeiteinheit.
at_end:       rts

*****************************************************************************
* LÑût Bild erscheinen, indem es Linien zieht.                              *
*  a0.l  -  High-Colour-Pic 320*240                                         *
*  a1.l  -  Screen (gelîscht).                                              *
*****************************************************************************
HC_SUB        EQU       2                 ; Pixeloffset der Linienendpunkte.
hc_show1:     st        disable_sync

              lea       (640*239.l,a0),a2 ; Sourcebild auf letzter Zeile.
              lea       (640*239.l,a1),a3 ; Bildschirmadresse     "     .

              move.w    #239,d5
              move.w    #240/HC_SUB-1,d7  ; 240 Linien ziehen.
hc_draw_line: move.w    #239,d1           ; y0
              sub.w     d5,d1             ; dy = y0-y1
              move.w    #320,d0           ; dx
              moveq     #0,d2             ; (Als Additionswert UND Scanoffset)
              move.w    d0,d2

              moveq     #0,d4             ; Grafikoffset unten.
              move.l    #319,d3           ;       "      oben.
              move.w    d3,d6             ; Alle Zeilen durchgehen.
hc_spalte:    sub.w     d1,d0             ; a -= dy (kleiner Bresenham)
              bpl.s     hc_no_n_line      ; Neue Zeile ?
              add.w     d2,d0             ; a += dx
              add.l     d2,d3             ; Eine Zeile runter.
              sub.l     d2,d4             ; Eine Zeile hoch.
hc_no_n_line: move.w    (a0,d3.l*2),(a1,d3.l*2) ; Pixel oben kopieren.
              move.w    (a2,d4.l*2),(a3,d4.l*2) ; Pixel unten kopieren.
              tst.l     d4                ; Schon eine Zeile weiter oben ?
              bpl.s     hc_no_clr_d1      ; Dann zur Sicherheit eine Zeile
              move.w    (640.w,a2,d4.l*2),(640.w,a3,d4.l*2) ; weiter unten
hc_no_clr_d1: cmp.l     d2,d3             ; noch einen Pixel setzen.
              blt.s     hc_no_clr_d2
              move.w    (-640.w,a0,d3.l*2),(-640.w,a1,d3.l*2)
hc_no_clr_d2: subq.l    #1,d3             ; Oben: Ein Pixel nach links.
              addq.l    #1,d4             ; Unten: Pixel nach rechts.
              dbra      d6,hc_spalte

              bsr.w     vsync

              subq.w    #HC_SUB,d5        ; Linienenden um ~ Pixel hoch/runter
              dbra      d7,hc_draw_line   ; NÑchste Linie ziehen.

              move.w    #239,d7           ; Zur Sicherheit nochmals den Screen
hc_cpy_scr:   move.w    #320/8-1,d6       ; kopieren, um LÅcken in der Diag-
hc_cpy_scr2:  movem.l   (a0)+,d0-d3       ; onalen zu fÅllen.
              move.l    d0,(a1)+
              move.l    d1,(a1)+
              move.l    d2,(a1)+
              move.l    d3,(a1)+
              dbra      d6,hc_cpy_scr2
              dbra      d7,hc_cpy_scr

              clr.b     disable_sync
              rts

*** Versucht, Åber Sinus einzuwobbeln. Noch nicht fertig... ***
hc_show2:     st        disable_sync      ; VBL-Sync aus.

              move.l    a0,a6             ; Sinus ist oben links und unten
              move.l    a1,a5             ; rechts identisch !
              move.w    #360,d5
              move.w    d5,d0             ; Sinetab.
              moveq     #-0*50,d1         ; y-Offset (Zeile).
              move.w    #180,d7           ; Anzahl DruchlÑufe.
hc_loop_1:    lea       (D_hfi_tab1.l,pc,d0.w*2),a0 ; Sinetab.
              move.w    d1,d2             ; Basiszeile in Screenoffset.
              move.w    d1,d3
              muls.w    #640,d3
              neg.l     d3
              muls.w    #640,d2           ; Scanoffset (auch negativ !)
              lea       (a5,d2.l),a1      ; Bildschirm oben.
              lea       (a6,d2.l),a3      ; Sourcebild oben.
              neg.l     d2                ; Screen/Source unten.
              lea       (640+640*240.l,a5,d2.l),a2
              lea       (640+640*240.l,a6,d2.l),a4
              move.w    #319,d6           ; 320 Spalten.
hc_lp1_spa:   
;             move.w    (a0)+,d2
;             ext.l     d2
;             cmp.l     d3,d2
;             blt.s     hc_no_set
;             move.w    (-640.w,a3,d2.w),(-640.w,a1,d2.w)
;             neg.l     d2
              move.w    -(a4),-(a2)             ; Bildschirm unten Basiszeile.
;             move.w    (a4,d2.w),(a2,d2.w)     ; Wobbel unten Åbernehmen.
;             move.w    (640.w,a4,d2.w),(640.w,a2,d2.w)
;             move.w    (a3,d2.w),(a1,d2.w)     ; Wobbel oben Åbernehmen.
              move.w    (a3)+,(a1)+
              dbra      d6,hc_lp1_spa           ; NÑchste Spalte
              bra.s     hc_weiter
hc_no_set:    addq.l    #2,a3
              addq.l    #2,a1
              subq.l    #2,a4
              subq.l    #2,a2
              dbra      d6,hc_lp1_spa     ; NÑchste Spalte

hc_weiter:    subq.w    #3,d0             ; Sinus bewegen (Sehr langsam, um
              bpl.s     hc1_no_end        ; "organische" Bewegung zu erhalten.
              add.w     d5,d0
hc1_no_end:   addq.w    #1,d1             ; Basislinie wandert weiter.
              bsr.w     vsync             ; Auf VBL warten.
              dbra      d7,hc_loop_1      ; NÑchste Zeile

              clr.b     disable_sync
              rts

*****************************************************************************
* Scrolltext (vor 16 Farb Hintergrund).                                     *
* Hintergrund kann mit Hardwarescrolling bewegt werden, dann wird Blitter   *
* zum Setzten benutzt. Sollte Blitter ausgeschalten sein, wird der Hinter-  *
* grund stillgehalten.                                                      *
*****************************************************************************
scrolltext_1: move.l    #_screens+256,d0
              clr.b     d0
              SET_V_ADR d0,d1             ; Video-RAM auf bel. Screen setzen.

              bsr.w     vsync             ; BildschirmrÅcklauf.
              bsr.w     switch_svga       ; In 640*480*256 Farbenmode gehen.    

              move      #$2700,sr         ; IRQs festhalten.
              move.l    #scr_vbl,$70.w    ; Eigenen VBL (keine 3D-Grafik mehr)
              stop      #$2300

st_main:      bra.s     st_main
scr_vbl:      rte

*****************************************************************************
*  Erzeugt kÅnstlichen Horizont (Auf 4-Planescreen.)                        *
* PARAMETER:  d6.w  -  Anzahl Horizontzeilen / 4 (Farbe 15)                 *
*             d7.w  -  Anzahl Normalezeilen  / 4 (Farbe 0)                  *
*****************************************************************************
k_horizont:   move.l    clr_scr(pc),d0    ; Screen mit Horizont lîschen.
              beq.w     wp_bye            ; Der Horizont besteht aus Farbe 15.
              move.l    d0,a0
              moveq     #-1,d0
              moveq     #-1,d1
              moveq     #-1,d2
              moveq     #-1,d3
              moveq     #-1,d4
              moveq     #-1,d5
              move.l    d0,a1
              move.l    d0,a2
              move.l    d0,a3
              move.l    d0,a4
clr_horizont:                             ; Hotizont erzeugen.
        REPEAT
          REPEAT
              movem.l   d0-d5/a1-a4,-(a0) ; 80 Pixel lîschen
          UNTIL  #(SCR_DX/80-1)
        UNTIL #(4-1)
              dbra      d6,clr_horizont

              moveq     #0,d0
              moveq     #0,d1
              moveq     #0,d2
              moveq     #0,d3
              moveq     #0,d4
              moveq     #0,d5
              move.l    d0,a1
              move.l    d0,a2
              move.l    d0,a3
              move.l    d0,a4
clr_horizont2:                            ; Rest mit Farbe 0 lîschen.
        REPEAT
          REPEAT
              movem.l   d0-d5/a1-a4,-(a0) ; 80 Pixel lîschen
          UNTIL  #(SCR_DX/80-1)
        UNTIL #(4-1)
              dbra      d7,clr_horizont2
              rts

*****************************************************************************
*  Lîscht mit Farbverlauf auf HC-Screen (begrenzte Anzahl Scans...)         *
* PARAMETER:  d6.w  -  Anzahl zu lîschender Zeilen - 1                      *
*             a6.l  -  Farbpalette.                                         *
*****************************************************************************
HC_SCR_DX     EQU       200               ; Anz. horizontale Lîschpixels.
HC_SCR_DY     EQU       199               ; Anz. vertikaler Zeilen.
HC_OFF        EQU       (320-HC_SCR_DX)*2 ; Zeilenoffset.
hc_colclr:    move.l    clr_scr(pc),d0          ; Lîschadresse (Ende !)
              beq.s     hc_cleared
              movea.l   d0,a0
              movea.w   #HC_OFF,a5        ; Zeilenoffset (nach oben!)
hc_clr_zeile:
;             movem.l   (a6)+,d0-d5/a1-a4 ; Farben holen.
              move.l    (a6)+,d0          ; Alle Lîschregister init:
              move.l    d0,d1             ; Schneller als "movem.l (a6)+,REGS"
              move.l    d0,d2
              move.l    d0,d3
              move.l    d0,d4
              move.l    d0,d5
              move.l    d0,a1
              move.l    d0,a2
              move.l    d0,a3
              move.l    d0,a4

          REPEAT                          ; Schleife einer Zeile
              movem.l   d0-d5/a1-a4,-(a0) ; 20 Pixel lîschen
          UNTIL  #(HC_SCR_DX/20-1)
              suba.l    a5,a0
              dbra      d6,hc_clr_zeile
hc_cleared:   rts

*****************************************************************************
* Lîscht ganzen Screen mit Farbverlauf.                                     *
* PARAMETER:  d7.w  -  Anzahl zu lîschender Zeilen - 1                      *
*             a6.l  -  Pointer auf Farbverlauf.                             *
*****************************************************************************
hc_clrscreen: move.l    clr_scr(pc),d0
              beq.s     hc_cleared
              movea.l   d0,a0
hc_cs_zeile:  move.l    (a6)+,d0
              move.l    d0,d1
              move.l    d0,d2
              move.l    d0,d3
              move.l    d0,d4
              move.l    d0,d5
              move.l    d0,a1
              move.l    d0,a2
              move.l    d0,a3
              move.l    d0,a4
          REPEAT
              movem.l   d0-d5/a1-a4,-(a0)
          UNTIL  #(SCR_WIDE/20-1)
              dbra      d7,hc_cs_zeile
              rts

*****************************************************************************
* Zeigt Gedicht an !                                                        *
* Der Screen wird auf 640*480 aufgestockt, es wird immer das begnadete Pic  *
* "gnadenlos" von JMS links eingeblendet und rechts das Gedichtle. Es wird  *
* immer etwas gewartet, bevor beendet wird, es sei denn, der User bequemt   *
* sich und drÅckt die "Halten"-Taste...                                     *  
* PARAMETER:  a0.l  -  Gedichtgrafik (TPI, 320*480).                        *
*****************************************************************************
SETPO_BACKPAL SET       anim_buf+256
set_poem:     pea       (a0)              ; Gedichtsadresse auf dem Stack dep.

              st        disable_sync      ; Eigene Screenverwaltung.
              clr.l     world_vbl         ; Eigenen VBL disablen.
              bsr.w     vsync

              lea       $ffff9800.w,a0    ; Alle Farben auf Hintergrund setzen.
              lea       SETPO_BACKPAL,a1  ; (Und Ausfadepalette sichern.)
              move.l    (a0)+,d0
              clr.l     (a1)+
              move.w    #254,d7
cs_clr_col:   move.l    d0,(a0)+
              clr.l     (a1)+
              dbra      d7,cs_clr_col

              movea.l   scr_lst_256,a0    ; "clr_mem" lîscht nicht ganz genau
              move.w    #640/4-1,d7       ; (...weil ich ein Lamer bin...).
cs_clr_scr:   clr.l     (a0)+
              dbra      d7,cs_clr_scr

              bsr.w     vsync

              movea.l   scr_lst_256,a0    ; Screen lîschen, setzen und Mode:
              move.l    a0,d0             ; 640*480 in 256 Farben.
              SET_V_ADR d0,d1
              lea       (640*480.l,a0),a1
              bsr.w     clr_mem

              move.w    #332,d7                 ; Zwischenbild "gnadenlos" 
              lea       D_gnadenlos+16*6,a0     ; (208*333, 4 Planes) einkop.
              lea       ([scr_lst_256.l,pc],640*147.l),a1
cs_cpy_pic1:  moveq     #208/16-1,d6      ; Auf Planes 0-3
cs_cpy_picl:  move.l    (a0)+,(a1)+
              move.l    (a0)+,(a1)+
              clr.l     (a1)+
              clr.l     (a1)+
              dbra      d6,cs_cpy_picl
              lea       (640-208)(a1),a1
              dbra      d7,cs_cpy_pic1

              lea       D_gnadenlos,a6    ; Palette des "gnadenlos"-Bildes.
              cmp.w     #1000,15*6(a6)    ; Ist Palette bereits umgewandelt ?
              bgt.s     no_wand_gnlo

              movea.l   a6,VDI_PAL
              movea.l   VDI_PAL,DEST_PAL
              moveq     #16,COLSTEPS
              bsr.w     VDI_9800
              lea       D_gnadenlos,a0
              moveq     #16,d7
              bsr.w     mask_pal
              lea       anim_buf,a1       ; Das verblîdete Truepaint-Format in
              bsr.w     konv_pal_tpi      ; normales zurÅckwandeln.

              lea       anim_buf,a0       ; Konvertierte Palette wieder ins
              lea       D_gnadenlos,a1    ; Bild zurÅck, damit sie auch das
              moveq     #15,d7            ; nÑchste Mal noch da ist !
set_po_cpy_b: move.l    (a0)+,(a1)+
              dbra      d7,set_po_cpy_b

              move.w    #1001,15*6(a6)    ; Palette gewandelt !

no_wand_gnlo: movea.l   (sp),VDI_PAL      ; Palette des Gedichts.
              movea.l   VDI_PAL,DEST_PAL
              moveq     #16,COLSTEPS
              bsr.w     VDI_9800
              movea.l   (sp),a0
              moveq     #16,d7
              bsr.w     mask_pal
              lea       anim_buf+64,a1
              bsr.w     konv_pal_tpi

              bsr.w     vsync             ; Videohardware auf 640*480, 256
              bsr.w     switch_svga

              lea       D_gnadenlos,a0    ; "Gnadenlos" einfaden.
              bsr.w     inst_norm_fade
              add.w     #50,frm_counter

              moveq     #100,d7           ; Ein bissle warten.
              bsr.w     vsync_xx

              move.w    #479,d7           ; Gedicht einkopieren.
              movea.l   (sp)+,a0
              lea       16*6(a0),a0
              lea       ([scr_lst_256.l,pc],320-48.w),a1
cs_cpy_pic2:  moveq     #320/16-1,d6      ; Auf Planes 4-7 kopieren (keine
cs_cpy_picm:  clr.l     (a1)+             ; öberdeckung mit dem anderen Bild:
              clr.l     (a1)+
              move.l    (a0)+,(a1)+       ; keine besonderen Anpassungen an der
              move.l    (a0)+,(a1)+       ; Palette.)
              dbra      d6,cs_cpy_picm
              lea       (640-320)(a1),a1
              dbra      d7,cs_cpy_pic2

              bsr.w     vsync             ; Flackerbremse.

              lea       anim_buf+64+4,a0        ; Die Palette des Gedichts se-
              lea       $ffff9800+16*4.w,a1     ; tzen, da sie mit Offset in der
              moveq     #14,d7                  ; Palette nur dumm gefadet
cpcol2:       move.l    (a0)+,(a1)              ; werden kann...
              lea       16*4(a1),a1
              dbra      d7,cpcol2

              move.w    #ANZ_POEM,d7      ; Gedicht anzeigen: eine kleine Pause
              bsr.w     vsync_xx          ; fÅr alle !

              cmp.b     #POEM_SCAN,$fffffc02.w  ; Will jemand das Gedicht etwa
              bne.s     cs_weiter               ; weiterschauen ???
cs_wait_end:  btst      #7,$fffffc02.w    ; ja --> SUPER: warten, bis es
              beq.s     cs_wait_end       ; ihr/ihm auch zu blîd wird...

cs_weiter:    lea       SETPO_BACKPAL,a0  ; Gedicht ausfaden (auf Schwarz!)
              lea       $ffff9800.w,a1
              move.w    #256,d7
              bra.w     fade_in_pal

*****************************************************************************
* Kopiert Speicherbereich in 16 Bytes Blîcken. NICHT optimiert, NICHT an    *
* geschwindigkeitsrelevanten Stellen benutzten.                             *
* a0, a1 : Source/Dest.                                                     *
* d0     : Anzahl 16 Byte Blîcke.                                           *
*****************************************************************************
cpy_mem16:    move.l    (a0)+,(a1)+
              move.l    (a0)+,(a1)+
              move.l    (a0)+,(a1)+
              move.l    (a0)+,(a1)+
              dbra      d0,cpy_mem16
              rts

*****************************************************************************
*  Lîscht High-Colour Screen.                                               *
*****************************************************************************
hc_clr_scr:   movem.l   d0-a6,-(sp)

              clr.l     d0                ; Screenadresse holen.
              move.b    $ffff8201.w,d0
              swap      d0
              move.b    $ffff8203.w,d0
              lsl.w     #8,d0
              move.b    $ffff820d.w,d0

              movea.l   d0,a5
              addi.l    #640*240,d0
              movea.l   d0,a6

              move.w    #119,d7
hc_clr_lp:    bsr.w     vsync

              movea.l   a5,a0
              lea       640(a0),a1
              bsr.w     clr_mem

              movea.l   a6,a1
              lea       -640(a1),a0
              bsr.w     clr_mem

              lea       640(a5),a5
              lea       -640(a6),a6
              dbra      d7,hc_clr_lp
              
              movem.l   (sp)+,d0-a6
              rts

*****************************************************************************
*  Schaltet Videohardware auf ST-Low !                                      *
*  (Die Mugwumps Ani wird mit der "original" ST Palette gefahren.           *
*****************************************************************************
switch_stlow: cmp.b     #2,(system+_MON)  ; VGA-Monitor ?
              beq.s     sw_vga_stlow24

* 320*200, 16 Farben, 50.0 Hz, 15625 Hz
              move.l    #$3e0025,$ffff8282.w
              move.l    #$14023f,$ffff8286.w
              move.l    #$1c0034,$ffff828a.w
              move.l    #$27101ff,$ffff82a2.w
              move.l    #$6f006f,$ffff82a6.w
              move.l    #$1ff026b,$ffff82aa.w
              move.w    #$200,$ffff820a.w
              move.w    #$82,$ffff82c0.w
              clr.w     $ffff8266.w
              move.b    #$0,$ffff8260.w
              move.w    #$0,$ffff82c2.w
              move.w    #$50,$ffff8210.w
              rts

sw_vga_stlow24:
        IFEQ  (_55HZ-an)
* 320*200, 16 Farben, 55.0 Hz, 31470 Hz
              move.l    #$170012,$ffff8282.w
              move.l    #$2020e,$ffff8286.w
              move.l    #$d0011,$ffff828a.w
              move.l    #$47903ed,$ffff82a2.w
              move.l    #$cd00cd,$ffff82a6.w
              move.l    #$3ed0475,$ffff82aa.w
              move.w    #$200,$ffff820a.w
              move.w    #$186,$ffff82c0.w
              clr.w     $ffff8266.w
              move.b    #$0,$ffff8260.w
              move.w    #$5,$ffff82c2.w
              move.w    #$50,$ffff8210.w
     ELSE
* 320*200, 16 Farben, 50.0 Hz, 31470 Hz
              move.l   #$170011,$ffff8282.w
              move.l   #$1020d,$ffff8286.w
              move.l   #$c0011,$ffff828a.w
              move.l   #$4eb040b,$ffff82a2.w
              move.l   #$eb00e9,$ffff82a6.w
              move.l   #$40904e7,$ffff82aa.w
              move.w   #$200,$ffff820a.w
              move.w   #$186,$ffff82c0.w
              clr.w    $ffff8266.w
              move.b   #$0,$ffff8260.w
              move.w   #$5,$ffff82c2.w
              move.w   #$50,$ffff8210.w
        ENDIF
              rts

*****************************************************************************
* öberblendet die Screens mit Bild, schaltet den Sync aber nicht ab, d.h.   *
* eventuelle Animationen, die auf den Screens liegen, laufen weiter.        *
* ACHTUNG: "ready_frame" wird benutzt !!!                                   *
* PARAMETER:  a0.l  -  Pictureadresse (320*240).                            *
*****************************************************************************
hc_show_2:    movem.l   d0-a6,-(sp)

              movea.l   a0,a6
              moveq     #0,d6             ; Startoffset.
              move.l    #640,d4           ; Scanoffset.
              move.w    #239,d7           ; Anzahl Zeilen.
hc_loop_2:    bsr.w     ready_frame       ; Weiterbewegen ermîglichen...
              bsr.w     vsync

              movea.l   a6,a0             ; Zuallererst die neue Zeile auf
              movea.l   screen+4(pc),a1   ; den sichtbaren Screen kopieren,
              adda.l    d6,a1             ; um Flimmern vorzubereiten.
              moveq     #(640/16)-1,d0
              bsr.w     cpy_mem16

              lea       scr_lst_32k,a5    ; Zeile auf alle anderen Screens
              moveq     #ANZ_SCREENS-1,d5 ; kopieren (den bereits kopierten
hc_cpy_scr_2: movea.l   a6,a0             ; herauszufiltern wÑre umstÑndlich
              move.l    (a5)+,a1          ; und wÅrde fast nix bringen...)
              adda.l    d6,a1
              moveq     #(640/16)-1,d0
              bsr.w     cpy_mem16
              dbra      d5,hc_cpy_scr_2

              add.l     d4,d6             ; Screenoffset.
              adda.l    d4,a6             ; Sourcebild runter.
              dbra      d7,hc_loop_2
              
              movem.l   (sp)+,d0-a6
              rts       