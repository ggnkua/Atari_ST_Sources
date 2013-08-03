; ************************************************************************
; *****                                                              *****
; *****		  FRACTALUS		     *****
; *****                                                              *****
; ************************************************************************
; *****  The Mandelbrot Set Calculated And Visualized With Z-Depth.  *****
; *****                      By Alain BROBECKER.                     *****
; *****	Coded on 7th and 8th of June 1994. (~ 1.5 Days)      *****
; ************************************************************************
; The whole thing is not optimised. The Mandelbrot set is calculated using
; a mirror, so the full calculation of the set would take a bit more than
; 30 seconds. There are three muls per iteration, the max nb of iterations
; is 32, and there are 32 colors displayed. The Z depth could be optimised
; by using an inverse table instead of making divs!
; There are other effects that can be obtained, by changing the value of
; the "convergent" points. (Put $1f or $0 instead of $20.)

; At the beginning all colors must be black, cos this are the initials
; colors of the fade.

time	equ 1750	; Approx 35 sec.
dist	equ 256
dist2	equ 8

supervisor:
  move.l	#$0,-(sp)
  move.w	#$20,-(sp)
  trap	#$1	; User mode is shit....
  addq.l	#$6,sp

initialisations:	
  dc.w	$a00a	; Fuck the mouse.
  move.b	#$12,$fffffc02.w
  move.b	$484.w,old_conterm
  clr.b	$484.w	; No bip, no repeat.
  move.l	$114.w,old_timerc ; Unusefull for a demo.
  move.l	#null_timerc,$114.w ; Put a "null" routine.
  move.l	$70.w,old_vbl	; I have to use my own Vbl.
  move.l	#null_vbl,$70.w	; A "null" vbl for the moment.
  
.screen_features:
  move.w	#$25,-(sp) 
  trap	#$e
  addq.l	#$2,sp
  
  move.b	$ffff8260.w,old_rez
  move.b	$ffff8201.w,old_screen
  move.b	$ffff8203.w,old_screen+1
  move.b	$ffff820d.w,old_screen+2

; ************************************************************************
; Print the text on screen1.

  move.l	#$0,$466.w	; _frclock to 0.
  
print_text:
  move.l	#screen1+160*10,a0
  addq.l	#$6,a0
  move.l	#text,a1
  move.l	#fonts,a2	
  move.w	nb_lines_text,d0 ; Nb of lines of text.
.one_line:
  move.w	#19,d1	; 40 chars per line.
.two_char:
  moveq.l	#$0,d2
  move.b	(a1)+,d2	; d2=char to print.
  sub.b	#$40,d2	; It begins on the @.
  lsl.w	#$3,d2	; 8 bytes per char.
  move.b	(a2,d2.w),(a0)	; Print the char.
  move.b	$1(a2,d2.w),160(a0)
  move.b	$2(a2,d2.w),320(a0)
  move.b	$3(a2,d2.w),480(a0)
  move.b	$4(a2,d2.w),640(a0)
  move.b	$5(a2,d2.w),800(a0)
  move.b	$6(a2,d2.w),960(a0)
  move.b	$7(a2,d2.w),1120(a0)
  addq.l	#$1,a0
  moveq.l	#$0,d2
  move.b	(a1)+,d2	; d2=char to print.
  sub.b	#$40,d2	; It begins on the @.
  lsl.w	#$3,d2	; 8 bytes per char.
  move.b	(a2,d2.w),(a0)	; Print the char.
  move.b	$1(a2,d2.w),160(a0)
  move.b	$2(a2,d2.w),320(a0)
  move.b	$3(a2,d2.w),480(a0)
  move.b	$4(a2,d2.w),640(a0)
  move.b	$5(a2,d2.w),800(a0)
  move.b	$6(a2,d2.w),960(a0)
  move.b	$7(a2,d2.w),1120(a0)
  addq.l	#$7,a0
  dbra	d1,.two_char
  add.l	#1600-160,a0	; Jump ten lines.
  dbra	d0,.one_line

.ramvideo_on_screen1:
  move.w	#$25,-(sp) 
  trap	#$e
  addq.l	#$2,sp
  move.b	#$0,$ffff8260.w	; Low res.
  move.b	screen1_ad+1,$ffff8201.w
  move.b	screen1_ad+2,$ffff8203.w
  move.b	screen1_ad+3,$ffff820d.w

; ************************************************************************
; Show the text: Fade from black to colors.

show_text:
  move.l	#colors,a6
  moveq.l	#$f,d7	; 16 steps for fading.

.one_vbl:
 rept	3
  move.w	#$25,-(sp) 
  trap	#$e
  addq.l	#$2,sp
 endr
 
  move.w	#$8240,a5
 rept	8
  move.l	(a6)+,(a5)+
 endr
  dbra	d7,.one_vbl
  
; ************************************************************************
; ************************************************************************
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
  move.b	#$20,(a0)+	; So, the color is full black.
  move.b	#$20,(a1)+
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
; Fade the text from colors to black.

unshow_text:
  move.l	#colors+512,a6
  moveq.l	#$f,d7	; 16 steps for fading.

.one_vbl:
 rept	3
  move.w	#$25,-(sp) 
  trap	#$e
  addq.l	#$2,sp
 endr
 
  move.w	#$8260,a5
 rept	8
  move.l	-(a6),-(a5)
 endr
  dbra	d7,.one_vbl

; ************************************************************************
; Convert the mandelbrot image into linear mode, and put the vbl which
; allows to see a 32 colors image.

show_mandel:
  move.l	#image,a0
  jsr	convert_image
  
  move.l	#show_vbl,$70.w

.fade_colors:
  move.l	#colors,a6
  moveq.l	#$f,d7	; 16 steps for fading.

.one_vbl:
 rept	4
  move.w	#$25,-(sp) 
  trap	#$e
  addq.l	#$2,sp
 endr
 
  move.w	#$8240,a5
 rept	8
  move.l	(a6)+,(a5)+
 endr
  dbra	d7,.one_vbl


; ************************************************************************
; ************************************************************************
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
; Fade the mandelbrot set from colors to black.

unshow_mandel:
  move.l	#colors+512,a6
  moveq.l	#$f,d7	; 16 steps for fading.

.one_vbl:
 rept	3
  move.w	#$25,-(sp) 
  trap	#$e
  addq.l	#$2,sp
 endr
 
  move.w	#$8260,a5
 rept	8
  move.l	-(a6),-(a5)
 endr
  dbra	d7,.one_vbl
  
; ************************************************************************
; Show the Z-depth Mandelbrot set in 32 colors.

show_mandel_z:
  move.l	#image2,a0
  jsr	convert_image
  
.fade_colors:
  move.l	#colors,a6
  moveq.l	#$f,d7	; 16 steps for fading.

.one_vbl:
 rept	4
  move.w	#$25,-(sp) 
  trap	#$e
  addq.l	#$2,sp
 endr
 
  move.w	#$8240,a5
 rept	8
  move.l	(a6)+,(a5)+
 endr
  dbra	d7,.one_vbl

.wait:
  move.w	#$25,-(sp) 
  trap	#$e
  addq.l	#$2,sp
  cmp.l	#time,$466.w
  ble.s	.wait
  
; ************************************************************************
; Fade the Z-depth Mandelbrot set from colors to black.

unshow_mandel_z:
  move.l	#colors+512,a6
  moveq.l	#$f,d7	; 16 steps for fading.

.one_vbl:
 rept	3
  move.w	#$25,-(sp) 
  trap	#$e
  addq.l	#$2,sp
 endr
 
  move.w	#$8260,a5
 rept	8
  move.l	-(a6),-(a5)
 endr
  dbra	d7,.one_vbl
  
  move.l	#null_vbl,$70.w	; No need to swap screens now.

; ************************************************************************
the_end:
  move.w	#$25,-(sp) 
  trap	#$e	; Vsync
  addq.l	#$2,sp

  move.l	#$4450445,$ffff8242.w ; Devpac does not restore colors.
  move.w	#$445,$ffff8246.w
  
  move.b	old_rez,$ffff8260.w ; Restore screen features.
  move.b	old_screen,$ffff8201.w
  move.b	old_screen+1,$ffff8203.w
  move.b	old_screen+2,$ffff820d.w

  move.l	old_vbl,$70.w	; Restore the Vbl.
  move.l	old_timerc,$114.w ; Restore old timerC rout.
  move.b	old_conterm,$484.w
  move.b	#$8,$fffffc02.w ; Restore mouse.
  dc.w	$a009
    
  clr.w	-(sp)
  trap	#$1

; ************************************************************************
; Routine which converts a 32 colors,320*199 image into two images
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
null_timerc:		; "Null" routine for the timerC.
  addq.l	#$1,$4ba.w	; Increment interrupt counter.
  bclr.b	#$5,$fffffa11.w	; Interrupt no more in service.
  rte

; ************************************************************************
null_vbl:		; "Null" vbl routine.
  addq.l	#$1,$466.w	; Increment _frclock.
  cmp.l	#$0,$4d2.w	; A music routine?
  beq.s	.no_music
.music:		; Yes, so execute it.
  move.l	a0,-(sp)
  move.l	$4d2.w,a0
  jsr	(a0)
  move.l	(sp)+,a0
.no_music:
  rte

; ************************************************************************
show_vbl:		; Vbl rout which switch between screens.
  addq.l	#$1,$466.w	; Increment _frclock.
  cmp.l	#$0,$4d2.w	; A music routine?
  beq.s	.no_music
.music:		; Yes, so execute it.
  move.l	a0,-(sp)
  move.l	$4d2.w,a0
  jsr	(a0)
  move.l	(sp)+,a0
.no_music:
  btst.b	#$0,$469.w	; _frclock odd or even?
  beq.s	.screen1
.screen2:		; Show screen2 next vbl.
  move.b	screen2_ad+1,$ffff8201.w  
  move.b	screen2_ad+2,$ffff8203.w  
  move.b	screen2_ad+3,$ffff820d.w  
  rte

.screen1:		; Show screen1 next vbl.
  move.b	screen1_ad+1,$ffff8201.w  
  move.b	screen1_ad+2,$ffff8203.w  
  move.b	screen1_ad+3,$ffff820d.w  
  rte

; ************************************************************************
  Section DATA
  
conv1_table:
  dc.b	$00,$00,$10,$10,$20,$20,$30,$30
  dc.b	$40,$40,$50,$50,$60,$60,$70,$70
  dc.b	$80,$80,$90,$90,$a0,$a0,$b0,$b0
  dc.b	$c0,$c0,$d0,$d0,$e0,$e0,$f0,$f0
  dc.b	$a0

conv2_table:
  dc.b	$00,$10,$10,$20,$20,$30,$30,$40
  dc.b	$40,$50,$50,$60,$60,$70,$70,$80
  dc.b	$80,$90,$90,$a0,$a0,$b0,$b0,$c0
  dc.b	$c0,$d0,$d0,$e0,$e0,$f0,$f0,$f0
  dc.b	$a0

colors:
  incbin	'..\fractal\fade.xxx'

fonts:
  incbin	'..\fractal\fonts.xxx'

nb_lines_text:
  dc.w	14
text:
  dc.b	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
  dc.b	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
  dc.b	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
  dc.b	'@@@@@@@@@@@@@@@PLEASE@WAIT[@@@@@@@@@@@@@'
  dc.b	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
  dc.b	'@@@@@@@@YOU@HAVE@NO@CHOICE@ANYWAY[@@@@@@'
  dc.b	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
  dc.b	'@@I@AM@CALCULATING@THE@MANDELBROT@SET[@@'
  dc.b	'@@IT@TAKES@APPROXIMATELY@FIFTEEN@SECS[@@'
  dc.b	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
  dc.b	'@@@@@THE@ROUTINE@IS@NOT@OPTIMISED[@@@@@@'
  dc.b	'@@@THERE@ARE@THREE@MULS@PER@ITERATION[@@'
  dc.b	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
  dc.b	'@BY@THE@WAY@THERE@IS@SOMETHING@UNUSUAL[@'
  dc.b	'@@@@@@@@@@@@@@@@@ENJOY[@@@@@@@@@@@@@@@@@' 

screen1_ad:
  dc.l	screen1

screen2_ad:
  dc.l	screen2

; ************************************************************************
  Section BSS

old_vbl:		; All the parameters for screen,
  ds.l	1	; and interrupts...
old_timerc:
  ds.l	1
old_conterm:
  ds.w	1 
old_rez:
  ds.w	1
old_screen:
  ds.l	1

image2:
  ds.b	320*200
    
image:
  ds.b	320*200

screen1:
  ds.b	32000

screen2:
  ds.b	32000
