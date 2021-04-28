;File: rot_a2.asm


PI           equ 32767

             .TEXT 


;-----------------------
;Turtle registers:
;       a5: Pointer to horizontal turtle movement routine
;       a6: Turtle's word address
;       d6: Turtle (relevant bit set)
;       d7: bit map width in bytes (sign gives direction of movement)
;
;Macros for the turtle
;

             .MACRO hmove                   ; move turtle horizontally
             .IFNE \1-"x"
             jsr       (a0)
             .ELSE 
             jsr       (a5)
             .ENDIF 
             .ENDM 

             .MACRO vmove                   ; move turtle vertically
             adda.w    d7,a6
             .ENDM 

             .MACRO plot                    ; turtle marks its path
             or.w      d6,(a6)
             .ENDM 

             .MACRO wipe                    ; turtle clears its path
             not.w     d6
             and.w     d6,(a6)
             not.w     d6
             .ENDM 

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
             .CARGS #10*4+4,sadr.l,swb.w,sxp.w,syp.w,swp.w,shp.w,tadr.l,twb.w,txp.w,typ.w,phi.w
             .TEXT 


rotat::      movem.l   d1/d3-d7/a3-a6,-(sp)
             move.w    sxp(sp),d0
             move.w    syp(sp),d1
             add.w     shp(sp),d1
             move.w    swb(sp),d7
             movea.l   sadr(sp),a6
             bsr       cpos
             movea.l   a6,a2                ; A2: start of bitstream line
             move.w    d0,d5                ; D6: Index of first valid bit
             move.w    txp(sp),d0
             move.w    typ(sp),d1
             move.w    phi(sp),d2
             addi.w    #PI/2,d2
             move.w    twb(sp),d7
             movea.l   tadr(sp),a6
             bsr       prepline
             swap.w    d7                   ; D7: step width vmove
             move.w    a3,sxp(sp)           ;SXP: dx for picture y movement
             move.w    a4,syp(sp)           ;SYP: dy
             movea.l   a5,a0                ; A0: function pointer hmove

             move.w    txp(sp),d0
             move.w    typ(sp),d1
             move.w    phi(sp),d2
             move.w    twb(sp),d7
             movea.l   tadr(sp),a6
             bsr       prepline

             move.w    shp(sp),d2           ; D2: line counter
             move.w    #$8000,d3            ; D3: deltax
             move.w    d3,d4                ; D4: deltay

.nxtline:    swap.w    d2
             swap.w    d3
             swap.w    d4
             move.w    swp(sp),d2           ; D2.lw: Pixel counter
             move.w    #$8000,d3            ; D3.lw: deltax
             move.w    d3,d4                ; D4.lw: deltay
             movea.l   a2,a1                ; A1: current bitstream position
             move.l    (a1)+,d1             ; D1: bitstream window
             lsl.l     d5,d1
             moveq.l   #31,d0               ; D0: valid bits in window
             sub.w     d5,d0
             swap.w    d5
             move.w    d6,d5                ; D5.lw: turtle Line start
             move.l    a6,sadr(sp)          ;SADR: turtle Line start

             bra       .hloop
.goon:       add.w     a4,d4
             bcc       .vert
             vmove     "x"
.vert:       add.w     a3,d3
             bcc       .hloop
             hmove     "x"

.hloop:      add.l     d1,d1
             bcs       .draw
             wipe 
             bra       .nxtbit
.draw:       plot 
.nxtbit:     dbf       d0,.lloop
             move.l    (a1)+,d1
             moveq.l   #31,d0
.lloop:      dbf       d2,.goon

.x:          movea.l   sadr(sp),a6
             swap.w    d2
             swap.w    d3
             swap.w    d4
             move.w    d5,d6
             swap.w    d5
             swap.w    d7

             add.w     sxp(sp),d3
             bcc       .yvert
             hmove     "y"
.yvert:      add.w     syp(sp),d4
             bcc       .vloop
             vmove     "y"
.vloop:      suba.w    swb(sp),a2
             swap.w    d7
             dbf       d2,.nxtline

             movem.l   (sp)+,d1/d3-d7/a3-a6
             rts       


;============================================================================
;
; prepline
; ========
;
;    Input  : d0 : x
;             d1 : y
;             d2 : phi
;             d7 : Bitmap width
;             a6 : Bitmap base
;
;    Output : d0 : Bit position of Turtle
;             d6 : Bit mask of Turtle
;             d7 : width of vertical step
;             a3 : dx
;             a4 : dy
;             a5 : horizontal step pointer
;             a6 : Turtle pointer
;
;    Changed Registers:   01234567
;                        D::----::
;                        A---::::-
;
prepline::   tst.w     d2                   ;vertical motion
             bmi       .hmove               ;     I. II. Quadrant ===> up
             neg.w     d7                   ;   III. IV. Quadrant ===> down
.hmove:      lea.l     right(pc),a5         ;horizontal motion
             move.w    d2,d6                ;    I.  IV. Quadrant ===> right
             addi.w    #$4000,d6            ;   II. III. Quadrant ===> left
             bpl       .setturtle
             lea.l     left(pc),a5
.setturtle:  bsr       cpos                 ;place turtle on starting point
             move.w    d0,d1
             move.w    d2,d0                ;calculate abs (sine)
             bsr       sine
             bpl       .abssin
             neg.w     d0
.abssin:     add.w     d0,d0
             movea.w   d0,a4                ; A4: 2*abs(sin(phi))
             move.w    d2,d0                ; A3: 2*abs(cos(phi))
             bsr       cosin
             bpl       .abscos
             neg.w     d0
.abscos:     add.w     d0,d0
             movea.w   d0,a3
             move.w    d1,d0
             rts       

;============================================================================
;
; cpos  Positioning the graphics cursor (Turtle)

; Input: d0 : x coordinate
;        d1 : y coordinate
;        d7 : width of bitmap in bytes
;        a6 : base address of bitmap

; Output: Turtle (d6,a6) is positioned

; Changed registers: 01234567
;                    D::----:u
;                    A------:-

cpos:        muls.w    d7,d1                ;calculate row offset
             bpl       .ok                  ;eliminate sign before bitmap width
             neg.l     d1
.ok:         adda.l    d1,a6                ; + Base address
             ror.l     #4,d0                ; + 2 * (x div 16)
             andi.w    #$0fff,d0
             lea.l     0(a6,d0.w),a6
             lea.l     0(a6,d0.w),a6
             clr.w     d0                   ;turtle position in word:
             rol.l     #4,d0                ; x mod 16
             addq.w    #1,d0                ;  counting bits from left!
             moveq.l   #1,d6
             ror.w     d0,d6
             subq.w    #1,d0
             rts       


left:        rol.w     #1,d6                ;move turtle to left
             bcc       .done
             subq.w    #2,a6
.done:       rts       


right:       ror.w     #1,d6                ;move turtle to right
             bcc       .done
             addq.w    #2,a6
.done:       rts       


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
;    Changed Registers:   01234567
;                        D:-------
;                        A--------
;

cosin:       addi.w    #PI/2,d0             ;cos(p)=sin(p+ã/2)

sine:        movem.l   d1/a0,-(sp)          ;save registers used
             move.w    d0,d1                ;and make copy
             bpl       .quadr12             ;save: I. and II. quadrant only
             neg.w     d0                   ;   if not: mirror angle along x axis
.quadr12:    cmpi.w    #PI/2+1,d0           ; test if II. quadrant
             bcs       .indexing          ; no, then straight into table
             neg.w     d0                   ;  yes, then into table from the end
             addi.w    #PI,d0
.indexing: mulu.w    #sinresol,d0         ;calculate position of relevant table
             lsl.l     #1,d0                ;element: angle*number of table elements
             swap.w    d0                   ;            / 2^14
             add.w     d0,d0                ;            * 2 (as it is a word table)
             lea.l     sintab(pc),a0        ; fetch sine value from table
             move.w    0(a0,d0.w),d0
             lsl.w     #1,d1                ;Was angle in quadrant III or IV?
             bcc       .return              ;  no, then leave as is
             neg.w     d0                   ;  else expand negative sine
.return:     ext.l     d0                   ;to full word
             movem.l   (sp)+,d1/a0          ;so there
             rts       
             .PATH 'A:\'
sintab:      .IBYTES 'SINE.DMP'             ;read in table calculated in BASIC

sinresol     equ *-sintab                   ;produces length of table in bytes

             .END 

