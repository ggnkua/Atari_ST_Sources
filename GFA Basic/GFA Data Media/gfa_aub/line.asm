;File: line.asm

;-----------------------
;Turtle registers:
;       a5: Pointer to horizontal turtle movement routine
;       a6: Turtle's word address
;       d6: Turtle (relevant bit set)
;       d7: bit map width in bytes (sign gives direction of movement)

             .MACRO hmove                   ; move turtle horizontally
             jsr       (a5)
             .ENDM 

             .MACRO vmove                   ; move turtle vertically
             adda.w    d7,a6
             .ENDM 

             .MACRO plot                    ; turtle marks its path
             or.w      d6,(a6)
             .ENDM 

;===============================================================
;line   Drawing a line (vector) as bit map

; Input: following 68000-C convention
;       W       Length of straight (in pixels)
;       L       Address of monochrome destination bitmap
;       W       Width of destination bitmap in bytes
;       WW      xy: Starting point of straight line
;       W       Ascension angle phi

; Output: --

; Changed registers: 01234567
;                    D:-------
;                    A--------

             .ABS
             .CARGS #10*4+4,len.w,tadr.l,twb.w,txp.w,typ.w,phi.w
             .TEXT 

line:        movem.l   d1/d3-d7/a3-a6,-(sp)
             move.w    twb(sp),d7           ;Direction of motion up/down
             move.w    phi(sp),d0           ;   I. II. Quadrant ===> up
             bmi       .hmove               ; III. IV. Quadrant ===> down
             neg.w     d7
.hmove:      lea.l     right(pc),a5         ;Direction of motion left/right
             addi.w    #$4000,d0            ;   I.  IV. Quadrant ===> right
             bpl       .setturtle           ;  II. III. Quadrant ===> left
             lea.l     left(pc),a5
.setturtle:  move.w    txp(sp),d0           ; position turtle on starting point
             move.w    typ(sp),d1
             movea.l   tadr(sp),a6
             bsr       cpos
             move.w    phi(sp),d0           ; calculate abs(sine)
             bsr       sine
             bpl       .abssin
             neg.w     d0
.abssin:     add.w     d0,d0
             movea.w   d0,a4                ; A4: 2*abs(sin(phi))
             move.w    phi(sp),d0           ; A3: 2*abs(cos(phi))
             bsr       cosin
             bpl       .abscos
             neg.w     d0
.abscos:     add.w     d0,d0
             movea.w   d0,a3

             moveq.l   #0,d3                ;deltax
             moveq.l   #0,d4                ;deltay
             move.w    len(sp),d5           ;length
             bra       .lloop

.goon:       add.w     a3,d3
             bcc       .vert
             hmove 
.vert:       add.w     a4,d4
             bcc       .lloop
             vmove 
.lloop:      plot 
             dbf       d5,.goon

.x:          movem.l   (sp)+,d1/d3-d7/a3-a6
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

cosin:       addi.w    #$3fff,d0            ;cos(p)=sin(p+ã/2)

sine:       movem.l   d1/a0,-(sp)          ;save registers used
             move.w    d0,d1                ;and make copy
             bpl       .quadr12             ;save: I. and II. quadrant only
             neg.w     d0                   ;   if not: mirror angle along x axis
.quadr12:    cmpi.w    #$4000,d0            ; test if II. quadrant
             bcs       .indexing          ; no, then straight into table
             neg.w     d0                   ;  yes, then into table from the end
             addi.w    #$7fff,d0
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

