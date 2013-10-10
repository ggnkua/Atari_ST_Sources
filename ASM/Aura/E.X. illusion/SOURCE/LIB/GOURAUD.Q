; This file contains the interpolated filler. Everything done by the 030.
; (C) Copyright 1995 by Jochen Knaus, AURA.

; ====================================================================
; GOURAUDROUTINE...
; KOMPLETTE AUSGABEROUTINE (Bindet Randberechung (PMOD) als Mod. ein.)

; VERSION:            1.01
; CODINGSTART:        Mai 1994
; LETZTES UPDATE:     21.08.1994
; LETZTER BUGFIX:     06.04.1995 (Farben bei Hlines...)
; CPU:                68020 (68030-Datencache wird angesteuert)
; ASSEMBLER:          Easy-Ass
; FORMAT:             PMOD

; Der Cache wird so gut als mîglich genutzt.
; FÅllen NUR auf HighColourscreen mîglich.

; PhÑnomenal: Die erste Routine, die durch den Datencache merkbar
; beschleunigt wird (fÅllen Åber Tabellen).
; ====================================================================

SCR_H         EQU     256                 ; HÑngt von Polygonroutine ab !

              MODUL   "F:\LIB\GOURAUD.INC"
              MC68030
              ORG     0
              OPT     D-,O+

              bra.w   draw_gouraud        ; Polygon ausgeben
              bra.w   init_gouraud        ; Routinen initialisieren
              bra.w   build_s_offs        ; Generiert Scanlineoffsets

              DC.B    'PMOD'
              DC.B    'Gouraud+Fill   ',0
              DC.B    'BDCannibal/AURA',0
              DC.B    '049408940101'
              DC.B    '20V-------------'

adrs:         DS.L    7
scr_wide:     DC.W    0
scr_high:     DC.W    0
anz_cols:     DC.W    0

raender:      INLINE  "F:\LIB\GOURAND.INC"      ; Randberechnung PMOD.

; ====================================================================
; Initialisiert Gouraudroutine.

; d0.w        - Bildschirmbreite Pixel
; d1.w        - Bildschirmhîhe Pixelzeilen
; d2.w        - Anzahl zum Shaden verwendeter Zeilen
; a0.l        - Scanlineoffsets
; a1.l        - Linke Koordinaten (Pointer auf alle Koordinatenarrays)
; a2.l        - Farbdistanzbuffer ((4*ANZ_COLS*SCR_WIDE)*4)
; a3.l        - Farbdistanzpointer ((ANZ_COLS*2+1)*4)
; a4.l        - Maximalkoordinatenarray (minx/maxx/miny/maxy), WORD.
; ====================================================================
init_gouraud: move.l  a4,d3
              exg     d3,a0
              lea     adrs(pc),a4
              lea     scr_wide(pc),a5
              movem.w d0-d2,(a5)          ; scr_wide, scr_high, anz_cols

              move.l  d3,(a4)+            ; Scanlineoffsets
              move.l  a1,(a4)             ; Linke Farben
              addi.l  #SCR_H*2,(a4)+
              move.l  a1,(a4)
              addi.l  #SCR_H*2*3,(a4)+    ; Rechte Farben
              move.l  a1,(a4)+            ; Linke Koordinaten
              lea     SCR_H*2*2(a1),a1
              move.l  a1,(a4)+            ; Rechte Koordinaten
              move.l  a2,(a4)+            ; Farbdifferenzbuffer.
              lea     (a3,d2.w*4),a5
              move.l  a5,(a4)             ; Farbdiff.poi. (dx=0)

              bsr.w   (raender)           ; Clipping initialisieren.

              move.l  a2,a0               ; Farbdistanztabelle berechnen.
              move.l  a3,a1
              move.w  d2,d1               ; Anzahl Farben in d1.w
              bra.w   init_distanz        ; inkl. <rts>

; ====================================================================
; Generiert Scanlinetabelle.

; d0.w        - Bytes / Scan
; d1.w        - Anzahl Scans
; a0.l        - Scanlinebuffer (Grîûe: Anzahl Scans)
; ====================================================================
build_s_offs: pea     (a1)
              suba.l  a1,a1               ; a1=0 (erster Offset)
              subq.w  #1,d1
              bmi.s   no_generate
build_soff:   move.l  a1,(a0)+            ; Offset sichern.
              adda.w  d0,a1               ; Offset nÑchste Zeile.
              dbra    d1,build_soff
no_generate:  move.l  (sp)+,a1
              rts

; ====================================================================
; Gibt Polygon geshadet aus (auf Highcolourscreen (16 Bit)).

; a0.l        - Screenadresse.
; a5.l        - Urpunkte.
; a6.l        - Polygonstruktur.
; ====================================================================
draw_gouraud: movem.l d0-a6,-(sp)
              
              movec   cacr,d0             ; Alten Cachestatus sichern,
              move.l  d0,-(sp)            ; und ohne Datencache Randber-
              moveq   #$11,d0             ; echnung durchziehen.
              movec   d0,cacr

              move.l  (a6)+,-(sp)         ; Farbe momentan ungebraucht.
              pea     (a0)                ; Screenadresse.

              movem.l adrs+4(pc),a1-a4    ; Farben und Koordinatenarrays
              move.w  (a6)+,d7            ; Anzahl Punkte
              bsr.w   (raender+4)         ; Polygonkanten berechnen.
              beq.s   poly_in             ; Z=1 -> innerhalb.

poly_out:     addq.l  #8,sp               ; Stack ausgleichen.
              move.l  (sp)+,d0            ; Cache zurÅcksetzen.
              movec   d0,cacr
              movem.l (sp)+,d0-a6
              rts

poly_in:      moveq   #0,d0               ; d0.high lîschen, .l-Zugriffe
              move.w  a3,d7               ; max_y
              move.w  a2,d0               ; min_y
              sub.w   d0,d7               ; dy
              bmi.s   poly_out            ; Sollte eigentlich nie vorkommen...

              lea     adrs(pc),a0
              move.l  ([a0],d0.w*4),d4    ; y-Bildschirmoffset
              add.l   (sp),d4             ; + Videobase -> Videoadr. in d4

              movea.l 24(a0),a5           ; Distanzpointerarray
              movem.l 4(a0),a1-a4         ; Farben- und Koordinatenarrays
              add.w   d0,d0               ; min_y*2
              adda.l  d0,a1               ; Arrays auf richtigen Stand
              adda.l  d0,a2
              adda.l  d0,a3
              adda.l  d0,a4
              move.l  ([a0],4.w),d5       ; Bytes pro Scan (=Scanoff[1])
              move.l  #$80000000,d6       ; const d6 (Nachkomma Koord)

              subq.w  #1,d7               ; dy-1
              bmi.s   poly_out            ; Sollte eigentlich...

              moveq   #$11,d1             ; Default: IC enable, DC disable
              move.l  4(sp),d0            ; Farbenpointer (oder 0)
              beq.w   blue_poly           ; (long) 0 -> Blaues Polygon

              move.l  d0,a2               ; Farbtabellenadresse
              move.w  #$1111,d1           ; Tabellenzugriffe: DC enable
              movec   d1,cacr

gouloop_tab:  move.l  d4,a0               ; Videoadresse dieser Zeile
              move.l  d6,d0               ; Nachkomma = $8000
              move.w  (a1)+,d0            ; c1
              move.w  (a3)+,d2            ; x1
              move.w  SCR_H*2(a4),d1      ; c2 (Koordinatenarray nach Colarr.)
              move.w  (a4)+,d3            ; x2
              sub.w   d0,d1               ; dc
              sub.w   d2,d3               ; dx
;             bmi.w   n_line              ; Sollte nie auftreten !
              bmi.s   okokls              ; Sollte nie auftreten !
              adda.l  d2,a0               ; Scr.adr. + 2*x1
              adda.l  d2,a0
              move.l  (a5,d1.w*4),a6
              move.l  (a6,d3.w*4),d1      ; dc/dx: Additionswert (aus Tabelle)

              lsr.w   #1,d3
              bcc.s   gerade
              addx.l  d1,d0
              move.w  (a2,d0.w*2),(a0)+
gerade:       subq.w  #1,d3
              bmi.s   okokls
fill_stupid:  addx.l  d1,d0
              move.w  (a2,d0.w*2),(a0)+
              addx.l  d1,d0
              move.w  (a2,d0.w*2),(a0)+
              dbra    d3,fill_stupid
okokls:       add.l   d5,d4               ; Videoadr. nÑchste Zeile
              dbra    d7,gouloop_tab
              bra.w   poly_out

              move.w  d3,d2
              asr.w   #3,d3
              subq.w  #1,d3
              bmi.s   tab_restline

tab_colour:   REPEAT
              addx.l  d1,d0
              move.w  (a2,d0.w*2),(a0)+
              UNTIL   #7
              dbra    d3,tab_colour

tab_restline: moveq   #7,d3
              and.w   d3,d2               ; Restliche Linie "normal" fÅllen.
              eor.w   d3,d2
              move.w  d2,d3               ; d2.w*3
              add.w   d2,d2
              add.w   d3,d2
              jmp     (tab_rest.b,pc,d2.w*2)

tab_rest:     REPEAT
              addx.l  d1,d0
              move.w  (a2,d0.w*2),(a0)+
              UNTIL   #6

n_line:       add.l   d5,d4               ; Videoadr. nÑchste Zeile
              dbra    d7,gouloop_tab
              bra.w   poly_out

blue_poly:    movec   d1,cacr             ; Cache abfetzen
gouloop_blue: move.l  d4,a0               ; Screenadr. init.
              move.l  d6,d0               ; d0.high init.
              move.w  (a1)+,d0            ; col1
              move.w  (a2)+,d1            ; col2
              move.w  (a3)+,d2            ; x1
              move.w  (a4)+,d3            ; x2
              sub.w   d0,d1               ; dc
              sub.w   d2,d3               ; dx
              bmi.w   n_line_blue         ; Sollte nie auftreten !
              adda.l  d2,a0               ; Scr.adr. + 2*x1
              adda.l  d2,a0
              move.l  (a5,d1.w*4),a6
              move.l  (a6,d3.w*4),d1      ; dc/dx: Additionswert (aus Tabelle)

              move.w  d3,d2
              asr.w   #3,d3
              subq.w  #1,d3
              bmi.s   blue_restline

blue_colour:  REPEAT
              addx.l  d1,d0
              move.w  d0,(a0)+
              UNTIL   #7
              dbra    d3,blue_colour

blue_restline:
              moveq   #7,d3
              and.w   d3,d2               ; Restliche Linie "normal" fÅllen.
              eor.w   d3,d2
              jmp     (blue_rest.b,pc,d2.w*4)

blue_rest:    REPEAT
              addx.l  d1,d0
              move.w  d0,(a0)+
              UNTIL   #6

n_line_blue:  add.l   d5,d4               ; Videoadr. nÑchste Zeile
              dbra    d7,gouloop_blue
              bra.w   poly_out

; ====================================================================
; Generiert Distanztabellen. Reassemblierte Version aus der gecrashten
; Version 1.02 (Edison verkraftete ein frei im Speicher rumfetzendes
; Polygon nicht ganz...)

; d0.w        - Screenbreite
; d1.w        - Anzahl zum Shaden verwendeter Farben
; a0.l        - Farbdistanzarray
; a1.l        - Farbdistanzpointerarray
; ====================================================================
init_distanz:
  movem.l   d0-a6,-(sp)
  MOVE.W    D0,D2 
  SUBQ.W    #1,D2 
  EXT.L     D1
  MOVE.L    D1,D3 
  MOVE.L    D1,D7 
  NEG.L     D7
farbe:
  CLR.L     D0
  MOVE.W    D2,D6 
  MOVE.L    A0,(A1)+
n_distanz:
  CLR.L     D1
  MOVE.L    D7,D7 
  BEQ.S     col0_dx0
  MOVE.L    D0,D0 
  BEQ.S     col0_dx0
  MOVE.L    D7,D1 
  SWAP      D1
  DIVS.L    D0,D1 
  SWAP      D1
col0_dx0:
  MOVE.L    D1,(A0)+
  ADDQ.L    #1,D0 
  DBF       D6,n_distanz
  ADDQ.L    #1,D7 
  CMP.W     D3,D7 
  BLT.S     farbe
  MOVEM.L   (A7)+,A0-A6/D0-D7 
  RTS 
