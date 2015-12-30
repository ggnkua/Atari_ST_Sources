
enable_debug_curves	equ 0
 
 SECTION TEXT
 
 even

 rsreset

curve_start_x	rs.w 1
curve_start_y	rs.w 1
curve_midle_x	rs.w 1
curve_midle_y	rs.w 1
curve_final_x	rs.w 1
curve_final_y	rs.w 1
curve_lenght	rs.w 1
curve_offset	rs.w 1
_curve_max_	equ __RS

CurveData	ds.l _curve_max_


 
; Input:
; a0=pointer on a curve parameter 
; Ouput:
; d0=x
; d1=y
BezierInterpolate
 COLORHELP #$077
 movem.l d2/d3,-(sp)
 
 ; Right median point
 move curve_final_x(a0),d0
 sub curve_midle_x(a0),d0
 muls curve_offset(a0),d0
 divs curve_lenght(a0),d0
 add curve_midle_x(a0),d0
 
 move curve_final_y(a0),d1
 sub curve_midle_y(a0),d1
 muls curve_offset(a0),d1
 divs curve_lenght(a0),d1
 add curve_midle_y(a0),d1
    
 ; Left median point
 move curve_midle_x(a0),d2
 sub curve_start_x(a0),d2
 muls curve_offset(a0),d2
 divs curve_lenght(a0),d2
 add curve_start_x(a0),d2
 
 move curve_midle_y(a0),d3
 sub curve_start_y(a0),d3
 muls curve_offset(a0),d3
 divs curve_lenght(a0),d3
 add curve_start_y(a0),d3
 
 ; Final point
 sub d2,d0
 muls curve_offset(a0),d0
 divs curve_lenght(a0),d0
 add d2,d0
 
 sub d3,d1
 muls curve_offset(a0),d1
 divs curve_lenght(a0),d1
 add d3,d1
      
 movem.l (sp)+,d2/d3
 rts
  
 
 ifne enable_debug_curves
 
; Compute in 2 the average of 1 and 3 
MEDIANPOINT macro
 move.l \1,\2			; 4
 add.l \3,\2			; 8
 lsr.l #1,\2			; 8+2=12
 and.w #$7FFF,\2		; 8
 ; Total=4+8+12+8=32 nops
 endm 

MEDIANPOINT_D7 macro
 move.l \1,d7			; 4
 add.l \3,d7			; 8
 lsr.l #1,d7			; 8+2=12
 and.w #$7FFF,d7		; 8
 move.l d7,\2
 ; Total=4+8+12+8=32 nops
 endm 
  
; 14*32=448 nops
 
; a0/a1/a2
; generates d3=d0|d1
; generated d4=d1|d2
ComputeCurveLevel0
 move.l a0,(a6)+	; First point

 ; d0,d1,d2,d3,d4,d5,d6,d7 are free
 MEDIANPOINT a0,d0,a1
 MEDIANPOINT a1,d1,a2
 
 ; d2,d3,d4,d5,d6,d7 are free
 MEDIANPOINT a0,d2,d0
 MEDIANPOINT d0,d3,d1
 MEDIANPOINT d1,d4,a2
  
 ; d0,d1,d5,d6,d7 are free
 MEDIANPOINT a0,d0,d2
 MEDIANPOINT d2,d1,d3
 MEDIANPOINT d3,d5,d4
 MEDIANPOINT d4,d6,a2

 ; d2,d3,d4,d7 are free
 MEDIANPOINT a0,d2,d0
 MEDIANPOINT d0,d3,d1
 MEDIANPOINT d1,d4,d5
 MEDIANPOINT d5,d7,d6
 MEDIANPOINT d6,d0,a2

 ; d1,d5,d6 are free
 MEDIANPOINT a0,d1,d2
 MEDIANPOINT d2,d5,d3
 MEDIANPOINT d3,d6,d4
 MEDIANPOINT d4,d2,d7
 MEDIANPOINT d7,d3,d0
 MEDIANPOINT d0,d4,a2

 ; d0,d7 are free
 MEDIANPOINT_D7 a0,a1,d1
 MEDIANPOINT_D7 d1,a3,d5
 MEDIANPOINT_D7 d5,a4,d6
 MEDIANPOINT_D7 d6,a5,d2
 MEDIANPOINT_D7 d2,d0,d3
 MEDIANPOINT_D7 d3,d1,d4
 MEDIANPOINT_D7 d4,d2,a2
 
 ; d3,d4,d5,d6 are free
 MEDIANPOINT    a0,d3,a1
 MEDIANPOINT    a1,d4,a3
 MEDIANPOINT    a3,d5,a4
 MEDIANPOINT    a4,d6,a5
 MEDIANPOINT_D7 a5,a1,d0
 MEDIANPOINT_D7 d0,a3,d1
 MEDIANPOINT_D7 d1,a4,d2
 MEDIANPOINT_D7 d2,a5,a2

 ; d0,d1,d2 are free
 
 move.l d3,(a6)+
 move.l d4,(a6)+
 move.l d5,(a6)+
 move.l d6,(a6)+
 move.l a1,(a6)+
 move.l a3,(a6)+
 move.l a4,(a6)+
 move.l a5,(a6)+
     
 move.l a2,(a6)+	; Last point
 
 rts
 
NBPOINT	equ 256
 
curve_start	dc.w 80,20
curve_mid	dc.w 250,250
curve_end	dc.w 350,90
 
_CurveStart 
 ds.l NBPOINT
_CurveEnd 
 ds.l 100
 


ComputeCurveWithInterpolation
 move curve_start+0,d0	; p0x
 move curve_start+2,d1	; p0y

 move curve_mid+0,d2	; p1x
 move curve_mid+2,d3	; p1y

 move curve_end+0,d4	; p2x
 move curve_end+2,d5	; p2y

 move d2,d6
 sub d0,d6
 move d6,dx01

 move d3,d6
 sub d1,d6
 move d6,dy01

 move d4,d6
 sub d2,d6
 move d6,dx12

 move d5,d6
 sub d3,d6
 move d6,dy12
    
 moveq #0,d7
.interpolate_loop 

 ; Left median point
 move dx01,d6
 ext.l d6
 muls d7,d6
 divs #NBPOINT,d6
 add curve_start+0,d6
 move d6,p01x
 
 move dy01,d6
 ext.l d6
 muls d7,d6
 divs #NBPOINT,d6
 add curve_start+2,d6
 move d6,p01y
 
 ; Right median point
 move dx12,d6
 ext.l d6
 muls d7,d6
 divs #NBPOINT,d6
 add curve_mid+0,d6
 move d6,p12x
 
 move dy12,d6
 ext.l d6
 muls d7,d6
 divs #NBPOINT,d6
 add curve_mid+2,d6
 move d6,p12y

 ; Median line size
 move p12x,d6
 sub p01x,d6
 move d6,dx0112

 move p12y,d6
 sub p01y,d6
 move d6,dy0112

 ; Final point
 move dx0112,d6
 ext.l d6
 muls d7,d6
 divs #NBPOINT,d6
 add p01x,d6
 move d6,(a6)+
 
 move dy0112,d6
 ext.l d6
 muls d7,d6
 divs #NBPOINT,d6
 add p01y,d6
 move d6,(a6)+
   
 add #1,d7
 cmp #NBPOINT,d7
 bne .interpolate_loop 
   
 rts
 

DrawTestCurve
 ;
 ; Compute the curve
 ;
 lea _CurveStart,a6
 move.l curve_start,a0
 move.l curve_mid,a1
 move.l curve_end,a2
 ;bsr ComputeCurveLevel0
 bsr ComputeCurveWithInterpolation
  
 ;
 ; Draw the points
 ;
 lea _CurveStart,a0
.draw_points
 moveq.l #0,d0
 moveq.l #0,d1
 moveq.l #0,d2
 moveq.l #0,d3
 
 move (a0)+,d0	; x0
 move (a0)+,d1	; y0
 
 ;bsr DrawPixel

 move 0(a0),d2	; x1
 move 2(a0),d3	; y1
 bsr DrawLine
  
 cmp.l #_CurveEnd-4,a0
 bne.s .draw_points 
 rts  
 endc
 
 
; d0.w=x0
; d1.w=y0 
; d2.w=x1
; d3.w=y1
DrawLine
 ;illegal
 
 moveq.l #1,d4	; ix
 sub.w d0,d2	; dx
 bpl.s .dx_positive
.dx_negative 
 neg.w d2		; abs(dx)
 moveq.l #-1,d4
.dx_positive 

 moveq.l #1,d5	; iy
 sub.w d1,d3	; dy
 bpl.s .dy_positive
.dy_negative 
 neg.w d3		; abs(dy)
 moveq.l #-1,d5
.dy_positive 
   
; d0=x0
; d1=x1
; d2=abs(dx)
; d3=abs(dy)
; d4=ix
; d5=iy
; d6=err

 cmp.w d2,d3
 bhi.s DrawVertical

DrawHorizontal
 move d2,d6
 
 move d3,d7
 add d3,d7
 sub d2,d7
 
 add d3,d3
 add d2,d2

.horizontal_loop
 bsr DrawPixel
 tst.w d7
 bmi .skip
 sub d2,d7
 add d5,d1
.skip 
 add d3,d7
 add d4,d0
 dbra d6,.horizontal_loop
 rts
  
DrawVertical
 move d3,d6
 
 move d2,d7
 add d2,d7
 sub d3,d7

 add d3,d3
 add d2,d2
  
.vertical_loop  
 bsr DrawPixel
 tst.w d7
 bmi .skip
 sub d3,d7
 add d4,d0
.skip 
 add d2,d7
 add d5,d1
 dbra d6,.vertical_loop
 rts


; d0.b=color index
SetPixelColor
 lea _AdrDrawPixel,a0
 
 moveq #$81,d1
 lsr #1,d0 
 bcs .skip_p0 
 moveq #$c3,d1
.skip_p0 
 move.b d1,0(a0)

 moveq #$81,d1
 lsr #1,d0 
 bcs .skip_p1
 moveq #$c3,d1
.skip_p1
 move.b d1,2(a0)
  
 moveq #$81,d1
 lsr #1,d0 
 bcs .skip_p2
 moveq #$c3,d1
.skip_p2
 move.b d1,4(a0)

 moveq #$81,d1
 lsr #1,d0 
 bcs .skip_p3
 moveq #$c3,d1
.skip_p3
 move.b d1,6(a0)

 ; Note: Could also be done with a table of 16 entries, each with 4 bytes containing eithe $81 or $c3,
 ; then just load the right long value, and use movep.l to write the four values. 
 rts

;TablePixelmask
; dc.b $81,$81,$81,$81
  
; $81=10000001
; $C3=11000011

; d0.w=x
; d1.w=y 
DrawPixel
 movem.l d0-a6,-(sp)
 
 and #511,d0
 and #255,d1
 
 move.l ptr_scr_1,a0
 
 moveq.l #0,d2
 
 move.w d0,d2
 lsr.w #4,d2
 lsl.w #3,d2
 add.w d2,a0
 
 mulu blit_stride,d1
 add.l d1,a0
 
 and.w #15,d0
 
 lea PixelMask,a3
 add d0,a3
 add d0,a3
 move (a3),d0
 move d0,d1
 not d1

; or.w d0,(a0)+		; 8158
; and.w d1,(a0)+	; c358
    
_AdrDrawPixel
 or.w d0,(a0)+
 or.w d0,(a0)+
 or.w d0,(a0)+
 or.w d0,(a0)+
 
 movem.l (sp)+,d0-a6
 rts
  
 
 ifne enable_debug_curves

DrawPixel_OldAndCrappy
 movem.l d0-a6,-(sp)
 
 and #511,d0
 and #255,d1
 
 move.l ptr_scr_1,a1
 
 moveq.l #0,d2
 
 move.w d0,d2
 lsr.w #4,d2
 lsl.w #3,d2
 add.w d2,a1
 
 mulu blit_stride,d1
 add.l d1,a1
 
 and.w #15,d0
 
 lea PixelMask,a3
 add d0,a3
 add d0,a3
 move (a3),d0
  
 or.w d0,6(a1)
 not.w d0
 and.w d0,0(a1)
 and.w d0,2(a1)
 and.w d0,4(a1)
 
 movem.l (sp)+,d0-a6
 rts
  
 endc
 

 SECTION DATA

 even 

PixelMask
pixl set $8000
 REPT 16
 dc.w pixl
pixl set pixl/2
 ENDR
 	
 
 SECTION BSS
  
 even

 ifne enable_debug_curves
 
dx01	ds.w 1
dy01	ds.w 1

dx12	ds.w 1
dy12	ds.w 1

p01x	ds.w 1
p01y	ds.w 1
		
p12x	ds.w 1
p12y	ds.w 1

dx0112	ds.w 1
dy0112	ds.w 1
 
 endc
  
 
 
 