; ************************************************************************
; *****                                                              *****
; *****		  FRACTALUS		     *****
; *****                                                              *****
; ************************************************************************
; *****  The Mandelbrot Set Calculated And Visualized With Z-Depth.  *****
; *****                      By Alain BROBECKER.                     *****
; *****	     Coded on 7th and 8th of June 1994.              *****
; ************************************************************************
; The whole thing is not optimised. The Mandelbrot set is calculated using
; a mirror, so the full calculation of the set would take a bit more than
; 30 seconds. There are three muls per iteration, the max nb of iterations
; is 32, and there are 32 colors displayed. The Z depth could be optimised
; by using an inverse table instead of making divs!

dist	equ 256
dist2	equ 8

supervisor:
  move.l	#$0,-(sp)
  move.w	#$20,-(sp)
  trap	#$1
  addq.l	#$6,sp

  move.l	#colors,a0
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr
   
; ************************************************************************
; Let' s begin with the standard calculation of the mandelbrot set.
; To gain time, I calculate only the lines between 0-99, the lines
; between 100-198 are just mirrored...
calculate_set:
  move.l	#image,a0	  ; To store the calculated datas.
  move.l	#image+320*198,a1 ; For the symetry.
  move.w	#$0,a2	; a2=y.
  move.l	#-819,a3	; a3=(65536*(y2-y1))/100.
  move.l	#81920,d0	; d0=y1*65536=cy.
.one_y:
  move.w	#$0,a4	; a4=x.
  move.l	#563,a5	; a5=(65536*(x2-x1))/320.
  move.l	#-131072,d1	; d1=x1*65536=cx.
.one_x:
  move.l	d0,d2	; d2=yn=cy.
  lsr.l	#$8,d2
  move.l	d1,d3	; d3=xn=cx.
  lsr.l	#$8,d3
  move.w	#$8,a6	; a6=nb_iter.
.one_iter:
  move.w	d2,d4	; d4=d2=yn.
  move.w	d3,d5	; d5=d3=xn.
  move.w	d4,d6
  muls.w	d4,d4	; d4=yn^2.
  muls.w	d5,d6	; d6=xn*yn.
  add.l	d6,d6	; d6=2*xn*yn.
  muls.w	d5,d5	; d5=xn^2.
  move.l	d1,d3	; d3=cx.
  add.l	d5,d3	; d3=cx+xn^2.
  sub.l	d4,d3	; d3=cx+xn^2-yn^2.
  lsr.l	#$8,d3	; d3=x(n+1).
  move.l	d0,d2	; d2=cy.
  add.l	d6,d2	; d2=cy+2*xn*yn.
  lsr.l	#$8,d2	; d2=y(n+1).
  add.l	d5,d4	; d4=xn^2+yn^2.
  cmp.l	#$800000,d4	; xn^2+yn^2>128?
  bge.s	.divergent
  addq.w	#$1,a6	; nb_iter=nb_iter+1.
  cmp.w	#$20,a6	; nb_iter=32?
  bne.s	.one_iter
; If nb_iter=256, then we have made the process 32 times and
; xn^2+yn^2 was always <256, then the "suite" is convergent.
.convergent:	
  move.b	#$0,(a0)+	; So, the color is full black.
  move.b	#$0,(a1)+
; Another nice idea is to put "move.b #$1f,(a0)+",...
  add.l	a5,d1	; cx=cx+(65536*(x2-x1))/320.
  addq.w	#$1,a4	; x=x+1.
  cmp.w	#320,a4	; x=320?
  bne.s	.one_x
  add.l	a3,d0	; cy=cy+(65536*(y2-y1))/100.
  sub.w	#640,a1	; a1 must go up.
  addq.w	#$1,a2	; y=y+1.
  cmp.w	#100,a2	; y=100?
  bne.s	.one_y
  bra.s	.end_of_calcul
  
; In case xn^2+yn^2 becames bigger than 512, the "suite" is divergent
; and the color is nb_iter.
.divergent:
  move.w	a6,d2
  move.b	d2,(a0)+	; The color is nb_iter.
  move.b	d2,(a1)+
  add.l	a5,d1	; cx=cx+(65536*(x2-x1))/320.
  addq.w	#$1,a4	; x=x+1.
  cmp.w	#320,a4	; x=320?
  bne.s	.one_x
  add.l	a3,d0	; cy=cy+(65536*(y2-y1))/100.
  sub.w	#640,a1	; a1 must go up.
  addq.w	#$1,a2	; y=y+1.
  cmp.w	#100,a2	; y=100?
  bne	.one_y

.end_of_calcul

; ************************************************************************
; Put the Z-depth effect on the Mandelbrot set.

z_depth:
  move.l	#image,a0
  move.l	#image2,a1
  move.w	#199,d0	; d0=z.
.one_z:
  move.w	d0,d1
  add.w	#dist,d1	; d1=z+dist.
  move.l	#350*dist,d2	; The bottom is fixed to 99.
  divs.w	d1,d2	; d2=99*256/(z+dist)=y_bottom'.
  move.l	#-159,d3	; d3=x.
.one_x:
  move.l	d3,d4
  lsl.l	#dist2,d4	; d4=x*dist.
  divs.w	d1,d4	; d4=x'=x*dist/(z+dist).
  move.b	(a0)+,d5	; d5=color=heigth.
  move.l	#350,d6
  sub.b	d5,d6	; d6=y=y_bottom-heigth.
  lsl.l	#dist2,d6	; d6=y*dist.
  divs.w	d1,d6    	; d6=y'=y*dist/(z+dist).
  move.w	d2,d7
  sub.w	d6,d7	; d7=y_bottom'-y'=nb of y.
.conv_coords:
  move.l	a1,a2
  add.w	#159,d4	; d4=x'+159.
  add.w	d4,a2	; a2 points on the good x.
  sub.w	#140,d6	; d6=y'+100.
  muls.w	#320,d6	; d6=(y'+100)*320.
  add.l	d6,a2	; a2 points on the good (x;y).
;  subq.w	#$1,d7	; Beware the dbra.
.draw_one:
  move.b	d5,(a2)	; Draw on point.
  add.w	#320,a2	; Next line.
  dbra	d7,.draw_one
  addq.l	#$1,d3	; x=x+1.
  cmp.l	#161,d3
  bne.s	.one_x
  dbra	d0,.one_z
  
; ************************************************************************
; Show the Mandelbrot set in 32 colors.

  move.w	#$25,-(sp)
  trap	#$e
  addq.l	#$2,sp
  move.b	#$0,$ffff8260.w
  
  move.l	#image2,a0
  jsr	convert_image
  
vbl1:
  move.w	#$25,-(sp)
  trap	#$e
  addq.l	#$2,sp
  
  move.l	#screen1,d0	; Display screen1 next vbl.
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  move.w	d0,d1
  ror.w	#$8,d0
  move.b	d0,$ffff8203.w
  move.b	d1,$ffff820d.w

vbl2:
  move.w	#$25,-(sp)
  trap	#$e
  addq.l	#$2,sp
  
  move.l	#screen2,d0	; Display screen2 next vbl.
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  move.w	d0,d1
  ror.w	#$8,d0
  move.b	d0,$ffff8203.w
  move.b	d1,$ffff820d.w
  
  cmpi.b	#$39,$fffffc02.w
  bne.s	vbl1

  
  	

; ************************************************************************
the_end:
  move.w	#$25,-(sp)
  trap	#$e
  addq.l	#$2,sp
  move.b	#$1,$ffff8260.w

  move.l	$44e.w,d0
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  move.w	d0,d1
  ror.w	#$8,d0
  move.b	d0,$ffff8203.w
  move.b	d1,$ffff820d.w
  
  clr.w	-(sp)
  trap	#$1

; ************************************************************************
; Routine which converts a 32 colors,320*199 image into tow images
; with 16 colors each.
; ************************************************************************
; Parameters:	a0=adress of the image.

convert_image:
  movem.l	d0-d6/a0-a4,-(sp)

  move.l	a0,a4
    
  move.l	#screen1,a1	; Convert to the first screen.
  move.l	#conv1_table,a2	; Conv_table 32->16 when x+y is odd.
  move.l	#conv2_table,a3	; ... when x+y is even.
  moveq.l	#$0,d0
  
  moveq.l	#98,d5	; Convert 2*99 lines.
.two_lines:
  moveq.l	#19,d6	; 20*16 pixels per line.
.line_1:  
 rept	8
  move.b	(a0)+,d0	; The color into d0.
  move.b	(a2,d0.w),d0	; x+y is odd.
  add.b	d0,d0
  addx.w	d4,d4
  add.b	d0,d0
  addx.w	d3,d3
  add.b	d0,d0
  addx.w	d2,d2
  add.b	d0,d0
  addx.w	d1,d1
  move.b	(a0)+,d0	; The color into d0.
  move.b	(a3,d0.w),d0	; x+y is even this time.
  add.b	d0,d0
  addx.w	d4,d4
  add.b	d0,d0
  addx.w	d3,d3
  add.b	d0,d0
  addx.w	d2,d2
  add.b	d0,d0
  addx.w	d1,d1
 endr
  movem.w	d1-d4,(a1)
  addq.l	#$8,a1
  dbra	d6,.line_1

  moveq.l	#19,d6	; 20*16 pixels per line.
.line_2:  
 rept	8
  move.b	(a0)+,d0	; The color into d0.
  move.b	(a3,d0.w),d0	; y incremented=>x+y is even.
  add.b	d0,d0
  addx.w	d4,d4
  add.b	d0,d0
  addx.w	d3,d3
  add.b	d0,d0
  addx.w	d2,d2
  add.b	d0,d0
  addx.w	d1,d1
  move.b	(a0)+,d0	; The color into d0.
  move.b	(a2,d0.w),d0	; x+y is odd.
  add.b	d0,d0
  addx.w	d4,d4
  add.b	d0,d0
  addx.w	d3,d3
  add.b	d0,d0
  addx.w	d2,d2
  add.b	d0,d0
  addx.w	d1,d1
 endr
  movem.w	d1-d4,(a1)
  addq.l	#$8,a1
  dbra	d6,.line_2

  dbra	d5,.two_lines

  move.l	#screen2,a1	; The same with screen 2.
  moveq.l	#98,d5	; Convert 2*99 lines.
.two_lines_2:
  moveq.l	#19,d6	; 20*16 pixels per line.
.line_1_2:  
 rept	8
  move.b	(a4)+,d0	; The color into d0.
  move.b	(a3,d0.w),d0	; x+y is odd.
  add.b	d0,d0
  addx.w	d4,d4
  add.b	d0,d0
  addx.w	d3,d3
  add.b	d0,d0
  addx.w	d2,d2
  add.b	d0,d0
  addx.w	d1,d1
  move.b	(a4)+,d0	; The color into d0.
  move.b	(a2,d0.w),d0	; x+y is even this time.
  add.b	d0,d0
  addx.w	d4,d4
  add.b	d0,d0
  addx.w	d3,d3
  add.b	d0,d0
  addx.w	d2,d2
  add.b	d0,d0
  addx.w	d1,d1
 endr
  movem.w	d1-d4,(a1)
  addq.l	#$8,a1
  dbra	d6,.line_1_2

  moveq.l	#19,d6	; 20*16 pixels per line.
.line_2_2:
 rept	8
  move.b	(a4)+,d0	; The color into d0.
  move.b	(a2,d0.w),d0	; y incremented=>x+y is even.
  add.b	d0,d0
  addx.w	d4,d4
  add.b	d0,d0
  addx.w	d3,d3
  add.b	d0,d0
  addx.w	d2,d2
  add.b	d0,d0
  addx.w	d1,d1
  move.b	(a4)+,d0	; The color into d0.
  move.b	(a3,d0.w),d0	; x+y is odd.
  add.b	d0,d0
  addx.w	d4,d4
  add.b	d0,d0
  addx.w	d3,d3
  add.b	d0,d0
  addx.w	d2,d2
  add.b	d0,d0
  addx.w	d1,d1
 endr
  movem.w	d1-d4,(a1)
  addq.l	#$8,a1
  dbra	d6,.line_2_2
  
  dbra	d5,.two_lines_2
  
  movem.l	(sp)+,d0-d6/a0-a4
  rts
  
; ************************************************************************
  Section DATA
  
conv1_table:
  dc.b	$00,$00,$10,$10,$20,$20,$30,$30
  dc.b	$40,$40,$50,$50,$60,$60,$70,$70
  dc.b	$80,$80,$90,$90,$a0,$a0,$b0,$b0
  dc.b	$c0,$c0,$d0,$d0,$e0,$e0,$f0,$f0

conv2_table:
  dc.b	$00,$10,$10,$20,$20,$30,$30,$40
  dc.b	$40,$50,$50,$60,$60,$70,$70,$80
  dc.b	$80,$90,$90,$a0,$a0,$b0,$b0,$c0
  dc.b	$c0,$d0,$d0,$e0,$e0,$f0,$f0,$f0

colors:
;  dc.w	$000,$cff,$b77,$bee
;  dc.w	$366,$3dd,$a55,$acc
;  dc.w	$244,$2bb,$933,$9aa
;  dc.w	$122,$199,$811,$888
  
  dc.w	$000,$888,$811,$199
  dc.w	$122,$9aa,$933,$2bb
  dc.w	$244,$acc,$a55,$3dd
  dc.w	$366,$bee,$b77,$cff  

; ************************************************************************
  Section BSS

image2:
  ds.b	320*199
    
image:
  ds.b	320*199

screen1:
  ds.b	32000

screen2:
  ds.b	32000
