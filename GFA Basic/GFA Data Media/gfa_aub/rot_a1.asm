;File: rot_a1.asm


;=================================================================
;
;rotation       drawing a rotated bitmap
;========
;
; Input: following 68000-C convention
;       L    Address of monochrome source bitmap
;       W    Width of source bitmap in bytes
;       WWWW xywh: Dimensions of source picture
;       L    Address of monochrome destination bitmap
;       W    Width of destination bitmap in bytes
;       WW   xy: Picture rotation point
;       W    Rotation angle phi
;
; Output: --
;
; Changed registers:   01234567
;                     D:-------
;                     A--------
;

             .ABS
             .CARGS #13*4+4,sadr.l,swb.w,sxp.w,syp.w,swp.w,shp.w,tadr.l,twb.w,txp.w,typ.w,phi.w
             .TEXT 


rotat::      movem.l   d1-d7/a0/a1/a3-a6,-(sp)
             move.w    sxp(sp),d0
             move.w    syp(sp),d1
             add.w     shp(sp),d1
             move.w    swb(sp),d2
             movea.l   sadr(sp),a0
             bsr       cpos
             movea.l   a0,a6                ; A6: Base address of first pixel
             move.w    d0,d6                ; D6: Index of first valid bit

             move.w    phi(sp),d0
             bsr       cosin
             movea.w   d0,a0                ; A0: cos(phi) / 2
             move.w    phi(sp),d0
             bsr       sine
             movea.w   d0,a1                ; A1: sin(phi) / 2


             movea.l   tadr(sp),a5          ; A5: Base address destination bitmap
             moveq.l   #0,d5                ; D5: Start x/y coordinates
             move.w    shp(sp),d7           ; D7: Lines counter

.lines:      bsr       line                 ;Rotate straight
             addq.w    #1,d5                ;y-coordinate + 1/2
             bsr       line                 ;Rotate straight (blur)
             addi.w    #1,d5                ;y-coordinate + 1/2
             suba.w    swb(sp),a6           ; next straight
.vloop:      dbf       d7,.lines

             movem.l   (sp)+,d1-d7/a0/a1/a3-a6
             rts       
;============================================================================
;
; line
; ====
;
; Input: a6: Line start source picture
;        d5: y coordinate
; Output: --
;
; Changed registers:  01234567
;                    D:::::'-'
;                    A---::---
; also used:
;           adr, tadr on stack

line:        swap.w    d7                   ; d7: Counter rows/columns
             move.w    a0,d0
             muls.w    d5,d0
             move.l    d0,4+sadr(sp)        ; sadr: y*cos(phi)
             move.w    a1,d0
             muls.w    d5,d0
             move.l    d0,4+tadr(sp)        ; tadr: y*sin(phi)
             swap.w    d5                   ; d5: y/x -coordinate
             clr.w     d5                   ;x-coordinate := 0
             movea.l   a6,a4                ;Initialise bitstream
             move.l    (a4)+,d4             ;and prepare window
             lsl.l     d6,d4
             moveq.l   #31,d3
             sub.w     d6,d3

             move.w    4+swp(sp),d7

.dlne:       lea.l     clear(pc),a3         ;Set pixels or erase
             add.l     d4,d4                ; Test pixel
             bcc       .tst
             lea.l     set(pc),a3
.tst:        dbf       d3,.rot              ;Move window on
             move.l    (a4)+,d4
             moveq.l   #31,d3

.rot:        bsr       dorot                ;rotate pixel
             addq.w    #1,d5                ; x-coordinate + 1/2
             bsr       dorot                ;blur pixel
             addq.w    #1,d5                ; x-coordinate + 1/2

.hloop:      dbf       d7,.dlne             ;remaining pixels in line

             swap.w    d5
             swap.w    d7
             rts       


;============================================================================
;
; dorot
; =====
;
; Input:        a0: cos(phi)
;               a1: sin(phi)
;               a5: Base address destination bitmap
;             d5.w: x
;           tadr.l: y * sin(phi)
;           sadr.l: y * sin(phi)
;              txp: x coordinate rotation point
;              typ: y coordinate rotation point
;              twb: width of destination bitmap in bytes
; Output: --
;
; Changed registers:  01234567
;                    D:::-----
;                    A--------
;
dorot:       move.w    a0,d0                ;cos(phi)*x
             muls.w    d5,d0
             sub.l     8+tadr(sp),d0        ; - y*sin(phi)
             addi.l    #$18000,d0
             swap.w    d0
             add.w     8+txp(sp),d0         ;x' = x0 + [x*cos(p)-y*sin(phi)]

             move.w    a1,d1                ;sin(phi)*x
             muls.w    d5,d1
             add.l     8+sadr(sp),d1        ; + cos(phi)*y
             addi.l    #$18000,d1
             swap.w    d1
             neg.w     d1
             add.w     8+typ(sp),d1         ;y' = y0 - [x*sin(phi)+y*cos(phi)]

             mulu.w    8+twb(sp),d1         ;calculate pixel position in destination bitmap
             ror.l     #3,d0                ;
             andi.w    #$1fff,d0
             add.w     d0,d1
             clr.w     d0
             rol.l     #3,d0
             addq.w    #1,d0
             moveq.l   #1,d2
             ror.b     d0,d2
             jmp       (a3)                 ;either set or erase pixel


clear:       not.w     d2                   ;erase pixel
             and.b     d2,0(a5,d1.w)
             rts       

set:         or.b      d2,0(a5,d1.w)        ;set pixel
             rts       

;============================================================================
;
; cpos       Positioning the graphic cursor (Turtle)
; ====
;
; Input:        d0: x coordinate
;               d1: y coordinate
;               d2: width of bitmap in bytes
;               a0: base address of bitmap

; Output: d1,a0: Turtle is positioned
;                d0: Bit offset in word addressed
;
; Changed registers:   01234567
;                     D::------
;                     A:-------
;
cpos::       muls.w    d2,d1                ;calculate line offset
             adda.l    d1,a0                ; + Base address
             ror.l     #4,d0                ; + 2 * (x div 16)
             andi.w    #$0fff,d0
             lea.l     0(a0,d0.w),a0
             lea.l     0(a0,d0.w),a0
             clr.w     d0                   ;turtle position in word: x mod 16
             rol.l     #4,d0                ;  counting bits from
             addq.w    #1,d0                ;  from the left!
             moveq.l   #1,d1
             ror.w     d0,d1
             subq.w    #1,d0
             rts       


PI           equ 32767

;============================================================================
;
; cosin  Cosine / Sine
; sine
; =====
;
;    Input:  d0 : Angle phi/ã*32768  with  -ã ó phi < ã
;    Output: d0 : sin(phi)*32768 (fractional Format)
;                  cos(phi)*32768
;            CCR : XNZVC
;                  -**00
;
;    changed Registers:     01234567
;                          D:-------
;                          A--------
;

cosin::      addi.w    #PI/2,d0             ;cos(p)=sin(p+ã/2)

sine:        movem.l   d1/a0,-(sp)          ;save registers
             move.w    d0,d1                ;and make copy
             bpl       .quadr12             ;save: only I. and II. quadrant
             neg.w     d0                   ;  if not: mirror angle ; along x axis

.quadr12:    cmpi.w    #PI/2+1,d0           ;test, if II. Quadrant
             bcs       .indexing          ;no, then straight to table
             neg.w     d0                   ;yes, then into table from the end
             addi.w    #PI,d0
.indexing: mulu.w    #sinresol,d0         ;Calculate position of relevant tabel
             lsl.l     #1,d0                ;element: angle * number of table elements
             swap.w    d0                   ;            / 2^14
             add.w     d0,d0                ;            * 2 (word table!)
             lea.l     sintab(pc),a0        ;fetch sine value from table
             move.w    0(a0,d0.w),d0
             lsl.w     #1,d1                ; was angle in quadrant I or IV?
             bcc       .return              ;  no, then leave alone
             neg.w     d0                   ;  else expand negative sine
.return:     ext.l     d0                   ;to full word
             movem.l   (sp)+,d1/a0          ; so there
             rts       
             .PATH 'A:\'
sintab:      .IBYTES "SINE.DMP"             ;read in table calculated in BASIC

sinresol     equ *-sintab                   ;gives length of table in bytes

             .END 

