;              Variabel Drehen
;           von Dr. Michael SchÅtz
;
;         (c) 1992 MAXON Computer
;
;
;     INPUT:  d0   Drehwinkel
;             dx   Breite des Ausschnittes
;             dy   Hîhe   des Ausschnittes
;             px1  Position zum drehen
;             py1  Position zum drehen
;
;     OUTPUT: Koordinaten des gedrehten
;             Ausschnittes
;             px1  Ecke oben links x
;             py1  Ecke oben links y
;             px2  Ecke unten rechts x
;             py2  Ecke unten rechts y
;
;------------------------------------------------

drehen: bsr     cosi           ; Winkel berechnen
       lea       mx,a1         ; Mittelpunkt x
       lea       my,a5         ; Mittelpunkt y
       move.w    dx,d7         ; breite x
       move.w    dy,d6         ; Breite y
       ext.l     d7            ; als .l
       ext.l     d6            ; als .l
       asr.w     #1,d6         ; /2
       asr.w     #1,d7         ; /2
       move.w    d7,(a1)       ; Mittelpunkt x
       move.w    d6,(a5)       ; Mittelpunkt y
       bsr       up_dreh       ; um Winkel drehen
       sub.w     d6,(a1)       ;
       sub.w     d7,(a5)       ;
       move.w    px1,d0        ; Plus Start x
       add.w     d0,(a1)       ; 
       move.w    py1,d0        ; Plus Start y
       add.w     d0,(a5)       ;
 
block: movea.l   ziel,a0       ; Zielbildschirm
       movea.l   a0,a4         ; auch nach a4
       move.l    #7999,d0      ; 32000 Byte
.0:    clr.l     (a0)+         ; lîschen
       dbra      d0,.0         ; loop
 
       move.w    dx,d5         ; breite x
       addi.w    #1,d5         ; +1
       movea.l   #quelle,a0    ; Quelle start
       clr.w     d3            ; y ZÑhler
       movea.l   a0,a2         ; Quelle
       suba.w    #80,a2        ; -80 (eine Zeile)
.rd0:  clr.w     d1            ; x ZÑhler
       adda.w    #80,a2        ; +80 (eine Zeile)
       movea.l   a2,a0         ; Pointer sichern
.rd1:  move.b    (a0)+,d4      ; Byte holen
       beq       .re           ; =0 ? --> .re
       move.w    #7,d2         ; 7 Bits
 
.rd2:  btst      d2,d4         ; Bit gesetzt ?
       beq       .bit          ; nein --> .bit
       move.w    d1,d7         ; ja  X
       move.w    d3,d6         ;     Y
       bsr       up_dreh       ; errechnen
       add.w     (a1),d6       ; Plus Mitte x
       add.w     (a5),d7       ; Plus Mitte y
.plot: addq.w    #1,d6         ; x+1
       cmpi.w    #399,d7       ; max. y=399
       bgt       .bit          ; zu groû
       tst.w     d7            ; <0?
       blt       .bit          ; zu klein
       cmpi.w    #639,d6       ; max. x=639
       bgt       .bit          ; zu groû
       tst.w     d6            ; <0?
       blt       .bit          ; zu klein
       addi.w    #1,d7         ; y+1
       mulu.w    #80,d7        ; *80 Zeilen
       subi.w    #640,d6       ; x=640-x
       neg.w     d6            ; 
       ext.l     d6            ; und als .l
       divu.w    #8,d6         ; d6=d6/8
       sub.w     d6,d7         ; Spalte
       subq.l    #1,d7         ; -1
       swap.w    d6            ; das Bit
       bset      d6,0(a4,d7.w) ; und setzen
.bit:  addq.w    #1,d1         ; ZÑhler erhîhen
       dbra      d2,.rd2       ; weiter --> .rd2

.ree:  cmp.w     d5,d1         ; Breite x ?
       blt       .rd1          ; nein --> .rd1
       cmp.w     dy,d3         ; Hîhe y ?
       bgt       .npos         ; ja --> .npos
       addq.w    #1,d3         ; sonst Y+1
       bra       .rd0          ; und --> .rd0
.re:   addq.w    #8,d1         ; + 8 Bit
       bra       .ree          ; und weiter


;------------------------------------------------
; Neue Position berechnen
;------------------------------------------------

.npos: move.w    #639,d0       ; max. x
       move.w    #399,d1       ; max. y
       clr.w     d2            ; min. x
       clr.w     d3            ; min. y
       clr.w     d7            ; Pos 0,0
       clr.w     d6            ; 
       bsr       dreh          ; errechnen
       move.w    dx,d7         ; Pos dx,0
       clr.w     d6            ; 
       bsr       dreh          ; errechnen
       move.w    dx,d7         ; Pos dx,dy
       move.w    dy,d6         ; 
       bsr       dreh          ; errechnen
       clr.w     d7            ; Pos 0,dy
       move.w    dy,d6         ; 
       bsr       dreh          ; errechnen

       tst.w     d0            ; Test x1
       bgt       .n1           ; >0 --> .n1
       clr.w     d0            ; sonst =0
.n1:   tst.w     d2            ; Test x2
       bgt       .n2           ; >0 --> .n2
       clr.w     d2            ; sonst =0
.n2:   tst.w     d1            ; Test y1
       bgt       .n3           ; >0 --> .n3
       clr.w     d1            ; sonst =0
.n3:   tst.w     d3            ; Test y2
       bgt       .n4           ; >0 --> .n4
       clr.w     d3            ; sonst =0
.n4:   move.w    d0,px1        ; neue Position
       move.w    d1,py1        ; des gedrehten
       move.w    d2,px2        ; Ausschnittes auf
       move.w    d3,py2        ; Bildschirm ziel
       rts                     ; ende

dreh:  bsr       up_dreh       ; drehen
       add.w     (a1),d6       ; Mittelpunkt x
       add.w     (a5),d7       ; Mittelpunkt y
       cmp.w     d6,d0         ; Der grîûte
       blt       .lo1          ; und der
       move.w    d6,d0         ; kleinste Wert
.lo1:  cmp.w     d7,d1         ; der neuen
       blt       .lo2          ; Koordinaten
       move.w    d7,d1         ; steht in :
.lo2:  cmp.w     d6,d2         ;  d0=x1 klein
       bgt       .lo3          ;  d1=y1 klein
       move.w    d6,d2         ;  d2=x2 groû
.lo3:  cmp.w     d7,d3         ;  d3=y2 groû
       bgt       .lo4          ;
       move.w    d7,d3         ;
.lo4:  rts                     ;


;------------------------------------------------
; Daten
;------------------------------------------------

quelle:   .DC.l 0     ; Adresse des Quellbildes
ziel:     .DC.l 0     ; Adresse der Zielbildes

mx:      .DC.w 0      ; Mittelpunkt x
my:      .DC.w 0      ; Mittelpunkt y

dx:      .DC.w 0      ; Breite x
dy:      .DC.w 0      ; Breite y

px1      .DC.w 0      ; Position x1
py1      .DC.w 0      ; Position y1
px2      .DC.w 0      ; Position x2
py2      .DC.w 0      ; Position y2


;------------------------------------------------
; Die eigentliche Drehroutine
;------------------------------------------------

up_dreh:  movem.l   d0-d4,-(sp)  ; Reg. retten
       move.w    #10000,d2       ; Multiplikator
       move.w    sinx,d3         ; d3=sin(w)
       move.w    cosx,d4         ; d4=cos(w)
       move.w    d3,d0           ; d0=sin(w)
       move.w    d4,d1           ; d1=cos(w)
       muls.w    d6,d4           ; d4=x*cos(w)
       muls.w    d7,d3           ; d3=y*sin(w)
       add.l     d4,d3           ; d3=d3+d4
       divs.w    d2,d3           ; d3=d3/10000
       muls.w    d7,d1           ; d1=y*cos(w)
       muls.w    d6,d0           ; d0=x*sin(w)
       sub.l     d0,d1           ; d1=d1-d0
       divs.w    d2,d1           ; d1=d1/10000
       ext.l     d1              ; neuer x-Wert
       move.l    d1,d6           ; nach d6
       ext.l     d3              ; neuer y-Wert
       move.l    d1,d7           ; nach d7
       movem.l   (sp)+,d0-d4     ; Reg. zurÅck
       rts                       ; und ende


;------------------------------------------------
; Sinus und Cosinuswerte berechnen
;------------------------------------------------

cosi:  cmpi.w    #360,d0         ; Winkel Test
       ble       .0              ; <=360 Grad 
       subi.w    #360,d0         ; sonst -360
       bra       cosi            ; und loop
.0:    add.w     d0,d0           ; 2 Byte Integer
       move.w    d0,winkel       ; als Winkel
       cmpi.w    #181,d0         ; <90  Grad
       blt       .3              ; ja --> .0
       cmpi.w    #361,d0         ; <180 Grad
       blt       .1              ; ja -->.1
       cmpi.w    #540,d0         ; >270 Grad
       bgt       .2              ; ja --> .2
       subi.w    #360,d0         ; -360
       bsr       .3              ;
.r:    neg.w     sinx            ; sinx=-sinx
       neg.w     cosx            ; cosx=-cosx
       rts                       ; und ende
.1:    subi.w    #180,d0         ; -180 (90)
       lea       sin,a0          ; fÅr <= 180 Grad
       move.w    0(a0,d0.w),cosx ; cosx=sin(x-90)
       neg.w     cosx            ; cosx=-cosx
       lea       cos,a0          ;
       neg.w     d0              ;
       move.w    0(a0,d0.w),sinx ; sinx=cos(x-90)
       rts                       ;
.2:    subi.w    #360,d0         ; -360 (180)
       bsr       .1              ; <360
       bra       .r              ;
.3:    lea       sin,a0          ; fÅr <= 90 Grad
       move.w    0(a0,d0.w),sinx ; sinx=sin(d0)
       lea       cos,a0          ;
       neg.w     d0              ;
       move.w    0(a0,d0.w),cosx ; cosx=cos(d0)
       rts                       ;

sinx:   .DC.w 0   ; Sinuswert sin(winkel)
cosx:   .DC.w 0   ; Cosinuswert cos(winkel)
winkel: .DC.w 0   ; Winkel zum Drehen


;------------------------------------------------
; Sinuswerte / sin(x)*1000
;------------------------------------------------

sin:  .DC.w 0000,0174,0348,0523,0697,0871,1045
      .DC.w 1218,1391,1564,1736,1908,2079,2249
      .DC.w 2419,2588,2756,2923,3090,3255,3420
      .DC.w 3583,3746,3907,4067,4226,4383,4539
      .DC.w 4694,4848,5000,5150,5299,5446,5591
      .DC.w 5735,5877,6018,6156,6293,6427,6560
      .DC.w 6691,6819,6946,7071,7193,7313,7431
      .DC.w 7547,7660,7771,7880,7986,8090,8191
      .DC.w 8290,8386,8480,8571,8660,8746,8829
      .DC.w 8910,8987,9063,9135,9205,9271,9335
      .DC.w 9396,9455,9510,9563,9612,9659,9702
      .DC.w 9743,9781,9816,9848,9876,9902,9925
      .DC.w 9945,9961,9975,9986,9993,9998
cos:  .DC.w 10000

