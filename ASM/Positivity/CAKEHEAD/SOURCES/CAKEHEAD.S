; *************************************************************************
; ****                        The CAKEHEAD demo.                       ****
; ****                     By Dracula of Positivity.                   ****
; *************************************************************************

  opt	o+

wait_text = 120		; Nb of vbls to wait when showing text.
wait_image = 450	; ... when showing image.
wait_begin = 50		; ... before the first text.
wait_text2 = 300	; ... text in the middle.

dist_user = 256
dist_user2 = 8

nb_points = 28
dist_max = 48
dec_alpha = 3
dec_beta = 5
dec_y_angle = 4
y_bounce = 89
x_pos = 159

system_fuckup:
  move.l	#$0,-(sp)	; First go in supervisor mode.
  move.w	#$20,-(sp)
  trap	#$1
  addq.l	#$6,sp

  move.l	#$ffff8240,a0	; Then save the gem colors.
  move.l	#old_colors,a1
  move.w	#$7,d0
.save_one:
  move.l	(a0)+,(a1)+
  dbra	d0,.save_one

  move.b	$ffff8201.w,old_physbase ; Save old res and physbase.
  move.b	$ffff8203.w,old_physbase+1
  move.b	$ffff8260.w,old_res
    
  dc.w	$a00a	; Fuck mouse. ( And remember to scotch
  move.b	#$12,$fffffc02.w ; it else it'll explode. )
  
  move.l	$114.w,old_timerc ; Save timer c.
  move.l	#null_timerc,$114.w ; And fuck it....
  move.w	#$0,$452.w	; Fuck the system vbl.
  move.l	$70.w,old_vbl

  move.b	$484.w,conterm	; Sauve ce bidule.
  clr.b	$484.w	; No bip,no repeat.

  moveq.l	#$1,d0
  jsr	music
  move.l	#null_vbl,$70.w

  
; *************************************************************************
; Fading from gem colors to all black.

  move.l	#fade_buffer,a2	; Precalc color tables.
  move.l	#old_colors,a0
  move.l	#black_colors,a1
  jsr	makefade

  move.l	#fade_buffer,a0
  move.w	#$f,d0	; 16 tables for fading.
.fade_one:
  jsr	wait_vbl
  jsr	wait_vbl
  jsr	wait_vbl
  jsr	wait_vbl
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr
  dbra	d0,.fade_one

  jsr	wait_vbl
  move.b	#$0,$ffff8260.w	; Low resolution.
  
  move.l	#screen1,d0	; Show screen1.
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  rol.w	#$8,d0
  move.b	d0,$ffff8203.w
  rol.w	#$8,d0
  move.b	d0,$ffff820d.w

; *************************************************************************
; Print text.  
 
  move.l	#$0,$466.w
  moveq.l	#wait_begin,d0
  jsr	wait_until
  
  move.l	#screen1,a0	; Clear screen1.
  moveq.l	#$0,d0
  moveq.l	#$0,d1
  move.l	#319,d2
  move.l	#199,d3
  jsr	clear_4b
  move.l	#screen1+14400,a0 ; Print text.
  move.l	#text1,a1
  jsr	print
  jsr	show_text	; And show it.

  move.l	#screen1,a0	; The same with text2.
  moveq.l	#$0,d0
  moveq.l	#89,d1
  move.l	#319,d2
  moveq.l	#111,d3
  jsr	clear_4b
  move.l	#screen1+14400,a0
  move.l	#text2,a1
  jsr	print
  jsr	show_text

  move.l	#screen1,a0	; And with text3.
  moveq.l	#$0,d0
  moveq.l	#89,d1
  move.l	#319,d2
  moveq.l	#111,d3
  jsr	clear_4b
  move.l	#screen1+14400,a0
  move.l	#text3,a1
  jsr	print
  jsr	show_text

; *************************************************************************
; Show the logo, and do the precalcs.

mapping_precalcs.
  move.l	#fade_buffer,a2	; Precalc color tables.
  move.l	#black_colors,a0
  move.l	#image_colors,a1
  jsr	makefade
  
  move.l	#$0,$466.w	; Reset _frclock.
  move.l	#image_vbl,$70.w ; Show images during precalcs.

  move.l	#fade_buffer,a0	; Fade to image colors.
  move.w	#$f,d0	; 16 tables for fading.
.fade_one:
  jsr	wait_vbl
  jsr	wait_vbl
  jsr	wait_vbl
  jsr	wait_vbl
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr
  dbra	d0,.fade_one
      
  move.l	#precalcs,a0	; Do the precalculations.
  move.l	#image1,a1
  move.l	#img1_adresses,a2
  jsr	precalc_one
  move.l	#precalcs+98000,a0 ; And now for image2.
  move.l	#image2,a1
  move.l	#img2_adresses,a2
  jsr	precalc_one

  move.l	#wait_image,d0	; Wait until _frclock=wait_image.
  jsr	wait_until  

  move.l	#fade_buffer+512,a0
  move.w	#$f,d0	; Fade to black.
.fade_two:
  jsr	wait_vbl
  jsr	wait_vbl
  jsr	wait_vbl
  jsr	wait_vbl
  move.w	#$8260,a1
 rept	8
  move.l	-(a0),-(a1)
 endr
  dbra	d0,.fade_two

  move.l	#screen1,a0	; Clear the screens.
  moveq.l	#$0,d0
  moveq.l	#$0,d1
  move.l	#319,d2
  move.l	#199,d3
  jsr	clear_4b

  move.l	#screen2,a0
  jsr	clear_4b

  move.l	#screen3,a0
  jsr	clear_4b
  
  
; *************************************************************************
; *************************************************************************
;  The mapped cube .....
; *************************************************************************
; *************************************************************************

mapped_cube:

  move.l	#fade_buffer,a2	; Precalc color tables.
  move.l	#mapping_colors,a0
  move.l	#black_colors,a1
  jsr	makefade

  move.l	#mapping_colors,a0 ; This time, no fading.
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr

  move.l	#mapping_vbl,$70.w
 
one_frame:
  move.w	show_screen,d0
  move.w	work_screen,d1
  addq.w	#$1,d1	; d1=work_screen+1.
  cmp.w	#$2,d1	; Are we after the three screens?
  ble.s	.work_ok
  moveq.l	#$0,d1	; Then back on screen 0.
.work_ok:		; Now d1 contain the next work screen.
  cmp.w	d1,d0	; Next work screen=actual show screen?
  beq.s	one_frame	; Then wait again.
.next_work:		; Else we can work on next screen.
  move.w	d1,work_screen
  move.w	d1,d4	; For the old xmin and xmaxs.
  add.w	d4,d4
  add.w	d4,d4
  move.l	#old_x,a1	
  cmp.w	#$0,d1
  bne.s	.not_screen1
  move.l	#screen1,a0
  bra.s	.work_it
.not_screen1:
  cmp.w	#$1,d1
  bne.s	.not_screen2
  move.l	#screen2,a0
  bra.s	.work_it
.not_screen2:
  move.l	#screen3,a0
  
.work_it:		; Clear the old mapped cube.
  move.w	(a1,d4.w),d0
  moveq.l	#50,d1
  move.w	$2(a1,d4.w),d2
  move.w	#149,d3
  jsr	clear_4b
  
.go:
  move.w	cube_angle,d2	; Angle around y.
  subq.w	#$5,d2	; New angle.
  bge.s	.angle_ok
  add.w	#$200,d2
.angle_ok:
  move.w	d2,cube_angle

  move.l	#sinus,a2
  move.w	cube_par,d0	; Parameter for the curve.
  addq.w	#$1,d0	; Next parameter.
  cmp.w	#$200,d0
  blt.s	.par_ok 
  sub.w	#$200,d0
.par_ok:
  move.w	d0,cube_par
  add.w	d0,d0	; 2 words per sinus.
  move.w	(a2,d0.w),d6	; d6=sin(cube_par).
  move.w	d0,d1
  cmp.w	#$200,d1
  blt.s	.par_ok2 
  sub.w	#$200,d1
.par_ok2:
  add.w	d1,d1	; d1=4*cube_par.
  move.w	(a2,d1.w),d7	; d7=sin(2*cube_par).
  add.w	d0,d1
  cmp.w	#$400,d1
  blt.s	.par_ok3 
  sub.w	#$400,d1
.par_ok3:
  add.w	#$100,a2
  move.w	(a2,d0.w),d0	; d0=cos(cube_par).
  move.w	(a2,d1.w),d1	; d1=cos(3*cube_par).
  muls.w	#400,d1
  swap.w	d1
  rol.l	#$2,d1
  muls.w	d6,d1
  swap.w	d1
  rol.l	#$2,d1
  add.w	#420,d1	; d1=456+400*cos(3*par)*sin(2*par).
  muls.w	#200,d0
  swap.w	d0
  rol.l	#$2,d0
  muls.w	d7,d0
  swap.w	d0
  rol.l	#$2,d0	; d0=200*sin(par)*cos(par).
  
  jsr	print_cube	; Print it.
  
  move.w	d0,(a1,d4.w)
  move.w	d1,$2(a1,d4.w)
  
  cmpi.b	#$39,$fffffc02.w
  bne	one_frame

  move.l	#fade_buffer,a0	; Fade to black.
  move.w	#$f,d0	; 16 tables for fading.
.fade_one:
  jsr	wait_vbl
  jsr	wait_vbl
  jsr	wait_vbl
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr
  dbra	d0,.fade_one


; *************************************************************************
; Text in the middle of the demo.

middle_text:
  move.l	#null_vbl,$70.w

  move.l	#screen1,d0	; Show screen1.
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  rol.w	#$8,d0
  move.b	d0,$ffff8203.w
  rol.w	#$8,d0
  move.b	d0,$ffff820d.w
 
  move.l	#screen1,a0	; Clear screen1.
  moveq.l	#$0,d0
  moveq.l	#$0,d1
  move.l	#319,d2
  move.l	#199,d3
  jsr	clear_4b

  move.l	#screen1+3200,a0 ; Print text.
  move.l	#text4,a1
  jsr	print
  move.l	#screen1+6720,a0 ; Print text.
  move.l	#text5,a1
  jsr	print
  move.l	#screen1+10240,a0 ; Print text.
  move.l	#text6,a1
  jsr	print
  move.l	#screen1+17280,a0 ; Print text.
  move.l	#text7,a1
  jsr	print
  move.l	#screen1+24320,a0 ; Print text.
  move.l	#text8,a1
  jsr	print

.show_text:
  move.l	#fade_buffer,a2	, Precalc color tables.
  move.l	#black_colors,a0
  move.l	#white_colors,a1
  jsr	makefade
  move.l	#fade_buffer+512,a2
  move.l	#white_colors,a0
  move.l	#text_colors,a1
  jsr	makefade
  move.l	#fade_buffer+1024,a2
  move.l	#text_colors,a0
  move.l	#black_colors,a1
  jsr	makefade
  move.l	#$0,$466.w	; Reset _frclock.
  move.l	#fade_buffer,a0
  move.w	#31,d0	; 32 tables for fading in.
.fade_in_one:
  jsr	wait_vbl
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr
  dbra	d0,.fade_in_one

  move.l	#wait_text2,d0	; Wait until _frclock=wait_text.
  jsr	wait_until

  move.w	#$f,d0	; 16 tables for fading out.
.fade_out_one:
  jsr	wait_vbl
  jsr	wait_vbl
  jsr	wait_vbl
  jsr	wait_vbl
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr
  dbra	d0,.fade_out_one

; *************************************************************************
; *************************************************************************
; The skullsphere.
; *************************************************************************
; *************************************************************************

skullsphere:
  move.l	#screen1,a0	; Clear screen1.
  moveq.l	#$0,d0
  moveq.l	#$0,d1
  move.l	#319,d2
  move.l	#199,d3
  jsr	clear_4b

  move.l	#screen2,a0	; Clear screen2.
  jsr	clear_4b
  
  move.l	#black_colors,a0
  move.l	#white_colors,a1
  move.l	#fade_buffer,a2
  jsr	makefade
  move.l	a1,a0
  move.l	#skull_colors,a1
  add.l	#480,a2
  jsr	makefade

  move.l	#fade_buffer,a6
  moveq.l	#$0,d7
          
; *************************************************************************
skull_vbl_one:
  jsr	wait_vbl

  addq.l	#$1,d7
  cmp.l	#31,d7
  bge.s	.no_color
  move.w	#$8240,a5
 rept	8
  move.l	(a6)+,(a5)+
 endr   
 .no_color:  

;  move.w	#$334,$ffff8240.w
    
.clear_old:
  move.l	#screen1,a0
  move.w	#x_pos,d0	; Pos of the sphere 2 vbls before.
  move.w	old_y1,d1
  move.w	d0,d2
  move.w	d1,d3
  move.w	#dist_max+12,d4
  sub.w	d4,d0	; Calculate the box around.
  sub.w	d4,d1
  add.w	d4,d2
  add.w	d4,d3
  jsr	clear_2b	; Clear old skullsphere.
  
.new_angles:
  move.w	alpha,d0	; Calculate the angle around z.
  subq.w	#dec_alpha,d0
  bge.s	.alpha_pos	; Is he negative?
  add.w	#$200,d0	; Then add 2*pi to alpha.
.alpha_pos:
  move.w	d0,alpha	; Store new alpha.
  move.w	beta,d1	; Calculate the angle around x.
  subq.w	#dec_beta,d1
  bge.s	.beta_pos	; Is he negative?
  add.w	#$200,d1	; Then add 2*pi to beta.
.beta_pos:
  move.w	d1,beta	; Store new beta.

  move.l	#coords,a0
  move.l	#sorted_array,a1
  move.w	#nb_points,a2
  jsr	rotation	; Rotate the sphere.
  
.calc_position:
  move.w	#x_pos,d0
  move.w	y_angle,d1
  subq.w	#dec_y_angle,d1	; Angle for the bounce.
  bge.s	.y_angle_pos	; Is it negative?
  add.w	#$200,d1	; Then add 2*pi.
.y_angle_pos:
  move.w	d1,y_angle	; Store new angle.
  move.l	#sinus,a0
  add.w	d1,d1
  move.w	(a0,d1.w),d1	; d1=Sinus(angle).
  muls.w	#y_bounce,d1
  add.l	d1,d1
  add.l	d1,d1
  swap.w	d1	; d1=y_bounce*sin(angle).
  cmp.w	#$0,d1
  bmi.s	.y_ok	; d1 negative?
  neg.w	d1  
.y_ok:
  add.w	#145,d1
  move.w	d1,old_y1
  move.l	#screen1,a0
  jsr	print_sphere

.show_screen:
  move.l	#screen1,d0 ; screen nb 1.
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  ror.w	#$8,d0
  move.b	d0,$ffff8203.w
  ror.w	#$8,d0
  move.b	d0,$ffff820d.w

;  move.w	#$556,$ffff8240.w

; *************************************************************************
skull_vbl_two:
  jsr	wait_vbl

;  move.w	#$334,$ffff8240.w
  
.clear_old:
  move.l	#screen2,a0
  move.w	#x_pos,d0	; Pos of the sphere 2 vbls before.
  move.w	old_y2,d1
  move.w	d0,d2
  move.w	d1,d3
  move.w	#dist_max+12,d4
  sub.w	d4,d0	; Calculate the box around.
  sub.w	d4,d1
  add.w	d4,d2
  add.w	d4,d3
  jsr	clear_2b	; Clear old skullsphere.
  

.new_angles:
  move.w	alpha,d0	; Calculate the angle around z.
  subq.w	#dec_alpha,d0
  bge.s	.alpha_pos	; Is he negative?
  add.w	#$200,d0	; Then add 2*pi to alpha.
.alpha_pos:
  move.w	d0,alpha	; Store new alpha.
  move.w	beta,d1	; Calculate the angle around x.
  subq.w	#dec_beta,d1
  bge.s	.beta_pos	; Is he negative?
  add.w	#$200,d1	; Then add 2*pi to beta.
.beta_pos:
  move.w	d1,beta	; Store new beta.

  move.l	#coords,a0
  move.l	#sorted_array,a1
  move.w	#nb_points,a2
  jsr	rotation	; Rotate the sphere.
  
.calc_position:
  move.w	#x_pos,d0
  move.w	y_angle,d1
  subq.w	#dec_y_angle,d1	; Angle for the bounce.
  bge.s	.y_angle_pos	; Is it negative?
  add.w	#$200,d1	; Then add 2*pi.
.y_angle_pos:
  move.w	d1,y_angle	; Store new angle.
  move.l	#sinus,a0
  add.w	d1,d1
  move.w	(a0,d1.w),d1	; d1=Sinus(angle).
  muls.w	#y_bounce,d1
  add.l	d1,d1
  add.l	d1,d1
  swap.w	d1	; d1=y_bounce*sin(angle).
  cmp.w	#$0,d1
  bmi.s	.y_ok	; d1 negative?
  neg.w	d1  
.y_ok:
  add.w	#145,d1
  move.w	d1,old_y2
  move.l	#screen2,a0
  jsr	print_sphere

.show_screen:
  move.l	#screen2,d0 ; screen nb 2.
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  ror.w	#$8,d0
  move.b	d0,$ffff8203.w
  ror.w	#$8,d0
  move.b	d0,$ffff820d.w

;  move.w	#$556,$ffff8240.w
  
  cmpi.b	#$39,$fffffc02.w
  bne	skull_vbl_one

; *************************************************************************
; Now fade out to quit skullsphere.

  moveq.l	#28,d7
one_fade_out:  
  jsr	wait_vbl
  move.w	#$8260,a5
 rept	8
  move.l	-(a6),-(a5)
 endr   
  dbra	d7,one_fade_out
  
; *************************************************************************
; Again some text.
  move.l	#screen1,d0	; Show screen1.
  swap.w	d0
  move.b	d0,$ffff8201.w
  swap.w	d0
  rol.w	#$8,d0
  move.b	d0,$ffff8203.w
  rol.w	#$8,d0
  move.b	d0,$ffff820d.w

  move.l	#screen1,a0	; Clear screen1.
  moveq.l	#$0,d0
  moveq.l	#$0,d1
  move.l	#319,d2
  move.l	#199,d3
  jsr	clear_4b
  move.l	#screen1+14400,a0 ; Print text.
  move.l	#text9,a1
  jsr	print
  jsr	show_text	; And show it.

; *************************************************************************
system_friendly:
  move.l	old_vbl,$70.w	; Restore old vbl.

  move.w	#$8800,a0	; Stop the noise.
  move.l	#$8080000,(a0)
  move.l	#$9090000,(a0)
  move.l	#$a0a0000,(a0)

  move.b	conterm,$484.w	; Remettre ce bidule.

  move.w	#$1,$452.w	; Vbl queue is here again.
  
  move.l	old_timerc,$114.w ; Restore Old Timer. (Lucky Luke rules.)
  move.b	#$8,$fffffc02.w ; The mouse which exploded before.
  dc.w	$a009
  jsr	wait_vbl

  move.b	old_physbase,$ffff8201.w
  move.b	old_physbase+1,$ffff8203.w
  move.b	#$0,$ffff820d.w
  move.b	old_res,$ffff8260.w ; Restore screen.
  
.restore_colors:
  move.l	#fade_buffer,a2	; Precalc color tables.
  move.l	#black_colors,a0
  move.l	#old_colors,a1
  jsr	makefade
  
  move.l	#fade_buffer,a0	; Fade to image colors.
  move.w	#$f,d0	; 16 tables for fading.
.fade_one:
  jsr	wait_vbl
  jsr	wait_vbl
  jsr	wait_vbl
  jsr	wait_vbl
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr
  dbra	d0,.fade_one

  clr.w	-(sp)	; The end.
  trap	#$1

; *************************************************************************
; *************************************************************************
; *************************************************************************
; Vbl for the texture mapping cos I use triple buffering.

mapping_vbl:
  addq.l	#$1,$466.w	; Increase _frclock.
  movem.l	d0-a6,-(sp)
  move.w	show_screen,d0
  move.w	work_screen,d1
  addq.w	#$1,d0	; d0=show_screen+1.
  cmp.w	#$2,d0	; Are we after the three screens?
  ble.s	.show_ok
  moveq.l	#$0,d0	; Then back on screen 0.
.show_ok:		; Now d0 contain the next show screen.
  cmp.w	d1,d0	; Next show screen=actual work screen?
  beq.s	.next_show	; Then show this screen.
  move.w	d0,show_screen	; Else show the next screen.
.next_show:
  move.w	show_screen,d0	; d0 is the good show screen.
  cmp.w	#$0,d0
  bne.s	.not_screen1
  move.l	#screen1,d1
  bra.s	.show_it
.not_screen1:
  cmp.w	#$1,d0
  bne.s	.not_screen2
  move.l	#screen2,d1
  bra.s	.show_it
.not_screen2:
  move.l	#screen3,d1

.show_it:
  move.l	d1,d0
  swap.w	d0
  lsr.w	#$8,d1
  move.b	d0,$ffff8201.w
  move.b	d0,$ffff8205.w
  move.b	d1,$ffff8203.w
  move.b	d1,$ffff8207.w
  swap.w	d0
  move.b	d0,$ffff820d.w
  move.b	d0,$ffff8209.w
  jsr	music+$8
  movem.l	(sp)+,d0-a6
  rte

; *************************************************************************
; Routine for showing the text.

show_text:
  movem.l	d0-a6,-(sp)
  move.l	#fade_buffer,a2	, Precalc color tables.
  move.l	#black_colors,a0
  move.l	#white_colors,a1
  jsr	makefade
  move.l	#fade_buffer+512,a2
  move.l	#white_colors,a0
  move.l	#text_colors,a1
  jsr	makefade
  move.l	#fade_buffer+1024,a2
  move.l	#text_colors,a0
  move.l	#black_colors,a1
  jsr	makefade
  move.l	#$0,$466.w	; Reset _frclock.
  move.l	#fade_buffer,a0
  move.w	#31,d0	; 32 tables for fading in.
.fade_in_one:
  jsr	wait_vbl
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr
  dbra	d0,.fade_in_one

  moveq.l	#wait_text,d0	; Wait until _frclock=wait_text.
  jsr	wait_until

  move.w	#$f,d0	; 16 tables for fading out.
.fade_out_one:
  jsr	wait_vbl
  jsr	wait_vbl
  jsr	wait_vbl
  jsr	wait_vbl
  move.w	#$8240,a1
 rept	8
  move.l	(a0)+,(a1)+
 endr
  dbra	d0,.fade_out_one

  movem.l	(sp)+,d0-a6
  rts
  
; *************************************************************************
; Uninteresting routs.

wait_vbl:		; Wait the increase of _frclock.
  move.l	d0,-(sp)
  move.l	$466.w,d0
.wait:
  cmp.l	$466.w,d0
  beq.s	.wait
  move.l	(sp)+,d0
  rts

wait_until:		; Wait until _frclock=d0.
  cmp.l	$466.w,d0
  bne.s	wait_until
  rts

image_vbl:		; Simply flick between screen 2 and 3.
  addq.l	#$1,$466.w	; Increase _frclock.
  movem.l	d0-a6,-(sp)
  move.l	$466.w,d0
  and.l	#$1,d0	; Test the parity of $466.w
  cmp.w	#$0,d0
  bne.s	.screen2
.screen3:
  move.l	#screen3,d0
  bra.s	.display    
.screen2:
  move.l	#screen2,d0
.display:
  move.b	d0,$ffff8209.w
  lsr.w	#$8,d0
  move.b	d0,$ffff8207.w
  swap.w	d0
  move.b	d0,$ffff8205.w
  jsr	music+$8
  movem.l	(sp)+,d0-a6
  rte
     
null_vbl:
  addq.l	#$1,$466.w	; Increase _frclock.
  movem.l	d0-a6,-(sp)
  jsr	music+$8
  movem.l	(sp)+,d0-a6
  rte
   
null_timerc:		; This do... Nothing.
  addq.l	#$1,$4ba.w	; Interrupt counter.
  bclr.b	#$5,$fffffa11.w	; Interrupt no more in service.
  rte

; *************************************************************************
; ***                 Routine which print the mapped cube.              ***
; ***                         Dracula/Positivity.                       ***
; *************************************************************************
; Parameters:	a0.l = adress of the ramvideo.
;	d0.w = x of the center of the cube.
;	d1.w = z of the center of the cube.
;	d2.w = angle around y.
; Return:	d0.w = x_min.
;	d1.w = x_max.

print_cube:
  
  movem.l	d2-a6,-(sp)
  
  move.l	#sinus,a1
  add.w	d2,d2	; One word per sinus.
  move.w	(a1,d2.w),d7	; d7=sin(angle).
  add.w	#$100,d2
  move.w	(a1,d2.w),d6	; d6=cos(a).
  muls.w	#56,d6	; d6=56*cos(a).
  rol.l	#$2,d6
  swap.w	d6
  muls.w	#56,d7	; d7=56*sin(a).
  rol.l	#$2,d7
  swap.w	d7
  move.l	#.coords,a1	; Put the coords in here.
.fisrt_point:
  move.w	d0,d2
  move.w	d1,d3
  add.w	d6,d2	; d2=x1=R*cos(a)+x.
  add.w	d7,d3	; d3=z1=R*sin(a)+z.
  add.w	#dist_user,d3	; Add the depth.
  ext.l	d2
  lsl.w	#dist_user2,d2
  divs.w	d3,d2	; d2=x'=(x*dist_user)/(z+dist_user).
  add.w	#159,d2	; Recenter on screen.
  move.w	d2,(a1)+
  move.l	#50*dist_user,d2
  divs.w	d3,d2	; d2=y'=(50*dist_user)/(z+dist_user).
  move.w	d2,(a1)+
.second_point:
  move.w	d0,d2
  move.w	d1,d3
  sub.w	d7,d2	; d2=x2=-R*sin(a)+x.
  add.w	d6,d3	; d3=z2=R*cos(a)+z.
  add.w	#dist_user,d3	; Add the depth.
  ext.l	d2
  lsl.w	#dist_user2,d2
  divs.w	d3,d2	; d2=x'=(x*dist_user)/(z+dist_user).
  add.w	#159,d2	; Recenter on screen.
  move.w	d2,(a1)+
  move.l	#50*dist_user,d2
  divs.w	d3,d2	; d2=y'=(50*dist_user)/(z+dist_user).
  move.w	d2,(a1)+
.third_point:
  move.w	d0,d2
  move.w	d1,d3
  sub.w	d6,d2	; d2=x3=-R*cos(a)+x.
  sub.w	d7,d3	; d3=z3=-R*sin(a)+z.
  add.w	#dist_user,d3	; Add the depth.
  ext.l	d2
  lsl.w	#dist_user2,d2
  divs.w	d3,d2	; d2=x'=(x*dist_user)/(z+dist_user).
  add.w	#159,d2	; Recenter on screen.
  move.w	d2,(a1)+
  move.l	#50*dist_user,d2
  divs.w	d3,d2	; d2=y'=(50*dist_user)/(z+dist_user).
  move.w	d2,(a1)+
.fourth_point:
  move.w	d0,d2
  move.w	d1,d3
  add.w	d7,d2	; d2=x4=R*sin(a)+x.
  sub.w	d6,d3	; d3=z4=-R*cos(a)+z.
  add.w	#dist_user,d3	; Add the depth.
  ext.l	d2
  lsl.w	#dist_user2,d2
  divs.w	d3,d2	; d2=x'=(x*dist_user)/(z+dist_user).
  add.w	#159,d2	; Recenter on screen.
  move.w	d2,(a1)+
  move.l	#50*dist_user,d2
  divs.w	d3,d2	; d2=y'=(50*dist_user)/(z+dist_user).
  move.w	d2,(a1)+

  move.l	#.coords,a6	; Put the coords in here.

.poly_one:
  move.w	(a6),d0	; x1.
  move.w	$4(a6),d1	; x2.
  cmp.w	d1,d0	; Is x1 bigger than x2?
  bge.s	.poly_two
  move.w	$2(a6),d2	; Then print it.
  move.w	$6(a6),d3	; Then print it.
  move.l	#img1_adresses,a1
  jsr	mapped_poly

.poly_two:
  move.w	$4(a6),d0	; x2.
  move.w	$8(a6),d1	; x3.
  cmp.w	d1,d0	; Is x2 bigger than x3?
  bge.s	.poly_three
  move.w	$6(a6),d2	; Then print it.
  move.w	$a(a6),d3	; Then print it.
  move.l	#img2_adresses,a1
  jsr	mapped_poly

.poly_three:
  move.w	$8(a6),d0	; x3.
  move.w	$c(a6),d1	; x4.
  cmp.w	d1,d0	; Is x3 bigger than x4?
  bge.s	.poly_four
  move.w	$a(a6),d2	; Then print it.
  move.w	$e(a6),d3	; Then print it.
  move.l	#img1_adresses,a1
  jsr	mapped_poly

.poly_four:
  move.w	$c(a6),d0	; x4.
  move.w	(a6),d1	; x1.
  cmp.w	d1,d0	; Is x4 bigger than x1?
  bge.s	.end
  move.w	$e(a6),d2	; Then print it.
  move.w	$2(a6),d3	; Then print it.
  move.l	#img2_adresses,a1
  jsr	mapped_poly

.end:		; Search x_min and x_max.
  move.w	(a6),d0
  move.w	d0,d1
  moveq.l	#$2,d7	; Three points to watch.
.watch_one:
  addq.l	#$4,a6	; Next x.
  move.w	(a6),d2
  cmp.w	d2,d0	; Current x<d0?
  ble.s	.not_xmin
  move.w	d2,d0	; Then it's the new min.
.not_xmin:
  cmp.w	d2,d1	; Current x>d1?
  bge.s	.not_xmax
  move.w	d2,d1	; Then it's the new max.
.not_xmax:
  dbra	d7,.watch_one
  
  movem.l	(sp)+,d2-a6
  rts

; *************************************************************************
  Section BSS
  
.coords:
  ds.w	8

  Section TEXT
; *************************************************************************
; ***             Routine for the calculation of the points.            ***
; ***                         Dracula/Positivity.                       ***
; *************************************************************************
; Parameters:	a0.l = adress where are the coords.
;	a1.l = adress of the "sorted array".
;	a2.w = nb of points.
;	d0.w = alpha. ( Angle around z. )
;	d1.w = beta. ( Angle around x. )
; * The "sorted array" looks like this:
;   There are "mini arrays" of 64 words in it, each one corresponding
;   to a distance, so when calculations are up, I put the coords in
;   this array according to his distance. 
; * Each mini array begins with a word indicating the ((number of coords
;   in it)-1) *4. ( 2 words per coordset. ) Then there are 63 words where
;   to put the coordsets.
; * When I will print the skulls, I will only have to go in all the
;   mini arrays in the "growing" order, see if there are coordsets in
;   the mini array and then print them. Then I will put the nb_coords
;   indicator to zero.

rotation:
  movem.l	d0-a6,-(sp)
  
  move.l	#sinus+$100,a3	; Adress of the cos table.
  add.w	d0,d0	; Each sinus takes a word.
  add.w	d1,d1
  move.w	(a3,d0.w),d2	; Cos(alpha).
  move.w	(a3,d1.w),d3	; Cos(beta).
  suba.w	#$100,a3	; Sinus table.
  move.w	(a3,d0.w),d0	; Sin(a).
  move.w	(a3,d1.w),d1	; Sin(b).

.two_points:		; Calculate two points in one time.
  move.w	(a0)+,d4
  move.w	d4,d5	; d4=d5=x1.
  move.w	(a0)+,d6
  move.w	d6,d7	; d6=d7=y1.
  muls.w	d2,d4	; d4=x1*cos(a).
  rol.l	#$2,d4	; Sinus were premultiplicated by 16384.
  swap.w	d4
  muls.w	d0,d6	; d6=y1*sin(a).
  rol.l	#$2,d6
  swap.w	d6
  muls.w	d0,d5	; d5=x1*sin(a).
  rol.l	#$2,d5
  swap.w	d5
  muls.w	d2,d7	; d7=y1*cos(a).
  rol.l	#$2,d7
  swap.w	d7
  sub.w	d6,d4	; x1'=x1*cos(a)-y1*sin(a).
  add.w	d7,d5	; y1'=x1*sin(a)+y1*cos(a).
  move.w	d4,a3	; Store x1' in a3.
  move.w	d5,d4	; d4=d5=y1'.
  move.w	(a0)+,d6
  move.w	d6,d7	; d6=d7=z1.
  muls.w	d1,d4	; d4=y1'*sin(b).
  rol.l	#$2,d4
  swap.w	d4
  muls.w	d1,d6	; d6=z1*sin(b).
  rol.l	#$2,d6
  swap.w	d6
  muls.w	d3,d5	; d5=y1'*cos(b).
  rol.l	#$2,d5
  swap.w	d5
  muls.w	d3,d7	; d7=z1*cos(b).
  rol.l	#$2,d7
  swap.w	d7
  move.w	d7,a4	; Store z1*cos(b).
  move.w	d5,a5	; Store y1'*cos(b).
  neg.w	d5	; -y1'*cos(b).
  sub.w	d6,d5	; d5=y2".
  sub.w	d4,d7	; d7=z2'.
  bmi.s	.z2_neg	; Is z2' negative?
.z2_pos:  
  lsl.w	#$7,d7	; 128 bytes per distance.
  addq.w	#$4,(a1,d7.w)	; A new coordset will be added.
  add.w	(a1,d7.w),d7	; d7 "points" after the coordset.
  move.w	d5,(a1,d7.w)	; Store y2"
  move.w	a3,d5
  neg.w	d5
  move.w	d5,-$2(a1,d7.w)	; Store x2'=-x1'.
  
  move.w	a5,d5	; -y1'*cos(b).
  sub.w	d6,d5	; d5=y1".
  add.w	a4,d4	; d4=z1'=y1'*sin(b)+z1*cos(b).
  bmi.s	.z1_neg	; Is z1' negative?

.z1_pos:
  lsl.w	#$7,d4	; 128 bytes per distance.
  addq.w	#$4,(a1,d4.w)	; A new coordset will be added.
  add.w	(a1,d4.w),d4	; d4 "points" after the coordset.
  move.w	d5,(a1,d4.w)	; Store y1"
  move.w	a3,-$2(a1,d4.w)	; Store x1'.

.next_two:
  subq.w	#$1,a2	; One set of four points less.
  cmp.w	#$0,a2
  bne	.two_points

  movem.l	(sp)+,d0-a6	; The end.
  rts

.z2_neg:  		; z2' negative, then take the "symetric".
  neg.w	d7	
  neg.w	d5
  lsl.w	#$7,d7	; 128 bytes per distance.
  addq.w	#$4,(a1,d7.w)	; A new coordset will be added.
  add.w	(a1,d7.w),d7	; d4 "points" after the coordset.
  move.w	d5,(a1,d7.w)	; Store -y2"
  move.w	a3,-$2(a1,d7.w)	; Store -x2'=x1'.
  
  move.w	a5,d5	; -y1'*cos(b).
  sub.w	d6,d5	; d5=y1".
  add.w	a4,d4	; d4=z1'=y1'*sin(b)+z1*cos(b).
  bge.s	.z1_pos	; Is z1' positive?

.z1_neg:		; z1' negative, then take the "symetric."
  neg.w	d4
  neg.w	d5
  lsl.w	#$7,d4	; 128 bytes per distance.
  addq.w	#$4,(a1,d4.w)	; A new coordset will be added.
  add.w	(a1,d4.w),d4	; d7 "points" after the coordset.
  move.w	d5,(a1,d4.w)	; Store -y1"
  move.w	a3,d5
  neg.w	d5
  move.w	d5,-$2(a1,d4.w)	; Store -x1'.

.next_two_2:
  subq.w	#$1,a2	; One set of four points less.
  cmp.w	#$0,a2
  bne	.two_points

  movem.l	(sp)+,d0-a6	; The end.
  rts

; *************************************************************************
; ****         Routines generated with my code generator.              ****
; ****   The skull is coming from the Burning Illusion from DNT-Crew.  ****
; *************************************************************************
; Parameters:	a0.l = adress of the ramvideo.
; *  Note that the end of the routines where not generated by my
; spriterout generator, but I wrote them so that to print a skull,
; I have no jsr and rts ( Which are a waste of time), so the end
; of the skullrouts are the continuation of the main sphere printing.

skull0:	ANDI.L	#$807F807F,(A0)
	ORI.L	#$5C806380,(A0)
	ANDI.L	#$3F003F,$A0(A0)
	ORI.L	#$BE40C1C0,$A0(A0)
	ANDI.L	#$1F001F,$140(A0)
	ORI.L	#$BE60C1E0,$140(A0)
	ANDI.L	#$1F001F,$1E0(A0)
	ORI.L	#$ECE0F3E0,$1E0(A0)
	ANDI.L	#$1F001F,$280(A0)
	ORI.L	#$B1E0CE20,$280(A0)
	ANDI.L	#$1F001F,$320(A0)
	ORI.L	#$7BE0FFC0,$320(A0)
	ANDI.W	#$1F,$3C0(A0)
	ORI.L	#$7BC0FFE0,$3C0(A0)
	ANDI.W	#$1F,$460(A0)
	ORI.L	#$B5A0FFE0,$460(A0)
	ANDI.W	#$803F,$500(A0)
	ORI.L	#$4E407FC0,$500(A0)
	ANDI.W	#$C07F,$5A0(A0)
	ORI.L	#$2A803F80,$5A0(A0)
	ORI.L	#$1F001F00,$640(A0)
	ANDI.W	#$E0FF,$6E0(A0)
	ORI.L	#$1A001F00,$6E0(A0)
  subq.w	#$4,d4	; One skull less.
  bgt	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts

skull1:	ANDI.L	#$C03FC03F,(A0)
	ORI.L	#$2E4031C0,(A0)
	ANDI.L	#$801F801F,$A0(A0)
	ORI.L	#$5F2060E0,$A0(A0)
	ANDI.L	#$800F800F,$140(A0)
	ORI.L	#$5F3060F0,$140(A0)
	ANDI.L	#$800F800F,$1E0(A0)
	ORI.L	#$767079F0,$1E0(A0)
	ANDI.L	#$800F800F,$280(A0)
	ORI.L	#$58F06710,$280(A0)
	ANDI.L	#$800F800F,$320(A0)
	ORI.L	#$3DF07FE0,$320(A0)
	ANDI.W	#$800F,$3C0(A0)
	ORI.L	#$3DE07FF0,$3C0(A0)
	ANDI.W	#$800F,$460(A0)
	ORI.L	#$5AD07FF0,$460(A0)
	ANDI.W	#$C01F,$500(A0)
	ORI.L	#$27203FE0,$500(A0)
	ANDI.W	#$E03F,$5A0(A0)
	ORI.L	#$15401FC0,$5A0(A0)
	ORI.L	#$F800F80,$640(A0)
	ANDI.W	#$F07F,$6E0(A0)
	ORI.L	#$D000F80,$6E0(A0)
  subq.w	#$4,d4	; One skull less.
  bgt	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts

skull2:	ANDI.L	#$E01FE01F,(A0)
	ORI.L	#$172018E0,(A0)
	ANDI.L	#$C00FC00F,$A0(A0)
	ORI.L	#$2F903070,$A0(A0)
	ANDI.L	#$C007C007,$140(A0)
	ORI.L	#$2F983078,$140(A0)
	ANDI.L	#$C007C007,$1E0(A0)
	ORI.L	#$3B383CF8,$1E0(A0)
	ANDI.L	#$C007C007,$280(A0)
	ORI.L	#$2C783388,$280(A0)
	ANDI.L	#$C007C007,$320(A0)
	ORI.L	#$1EF83FF0,$320(A0)
	ANDI.W	#$C007,$3C0(A0)
	ORI.L	#$1EF03FF8,$3C0(A0)
	ANDI.W	#$C007,$460(A0)
	ORI.L	#$2D683FF8,$460(A0)
	ANDI.W	#$E00F,$500(A0)
	ORI.L	#$13901FF0,$500(A0)
	ANDI.W	#$F01F,$5A0(A0)
	ORI.L	#$AA00FE0,$5A0(A0)
	ORI.L	#$7C007C0,$640(A0)
	ANDI.W	#$F83F,$6E0(A0)
	ORI.L	#$68007C0,$6E0(A0)
  subq.w	#$4,d4	; One skull less.
  bgt	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts

skull3:	ANDI.L	#$F00FF00F,(A0)
	ORI.L	#$B900C70,(A0)
	ANDI.L	#$E007E007,$A0(A0)
	ORI.L	#$17C81838,$A0(A0)
	ANDI.L	#$E003E003,$140(A0)
	ORI.L	#$17CC183C,$140(A0)
	ANDI.L	#$E003E003,$1E0(A0)
	ORI.L	#$1D9C1E7C,$1E0(A0)
	ANDI.L	#$E003E003,$280(A0)
	ORI.L	#$163C19C4,$280(A0)
	ANDI.L	#$E003E003,$320(A0)
	ORI.L	#$F7C1FF8,$320(A0)
	ANDI.W	#$E003,$3C0(A0)
	ORI.L	#$F781FFC,$3C0(A0)
	ANDI.W	#$E003,$460(A0)
	ORI.L	#$16B41FFC,$460(A0)
	ANDI.W	#$F007,$500(A0)
	ORI.L	#$9C80FF8,$500(A0)
	ANDI.W	#$F80F,$5A0(A0)
	ORI.L	#$55007F0,$5A0(A0)
	ORI.L	#$3E003E0,$640(A0)
	ANDI.W	#$FC1F,$6E0(A0)
	ORI.L	#$34003E0,$6E0(A0)
  subq.w	#$4,d4	; One skull less.
  bgt	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts

skull4:	ANDI.L	#$F807F807,(A0)
	ORI.L	#$5C80638,(A0)
	ANDI.L	#$F003F003,$A0(A0)
	ORI.L	#$BE40C1C,$A0(A0)
	ANDI.L	#$F001F001,$140(A0)
	ORI.L	#$BE60C1E,$140(A0)
	ANDI.L	#$F001F001,$1E0(A0)
	ORI.L	#$ECE0F3E,$1E0(A0)
	ANDI.L	#$F001F001,$280(A0)
	ORI.L	#$B1E0CE2,$280(A0)
	ANDI.L	#$F001F001,$320(A0)
	ORI.L	#$7BE0FFC,$320(A0)
	ANDI.W	#$F001,$3C0(A0)
	ORI.L	#$7BC0FFE,$3C0(A0)
	ANDI.W	#$F001,$460(A0)
	ORI.L	#$B5A0FFE,$460(A0)
	ANDI.W	#$F803,$500(A0)
	ORI.L	#$4E407FC,$500(A0)
	ANDI.W	#$FC07,$5A0(A0)
	ORI.L	#$2A803F8,$5A0(A0)
	ORI.L	#$1F001F0,$640(A0)
	ANDI.W	#$FE0F,$6E0(A0)
	ORI.L	#$1A001F0,$6E0(A0)
  subq.w	#$4,d4	; One skull less.
  bgt	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts

skull5:	ANDI.L	#$FC03FC03,(A0)
	ORI.L	#$2E4031C,(A0)
	ANDI.L	#$F801F801,$A0(A0)
	ORI.L	#$5F2060E,$A0(A0)
	ANDI.L	#$F800F800,$140(A0)
	ORI.L	#$5F3060F,$140(A0)
	ANDI.L	#$F800F800,$1E0(A0)
	ORI.L	#$767079F,$1E0(A0)
	ANDI.L	#$F800F800,$280(A0)
	ORI.L	#$58F0671,$280(A0)
	ANDI.L	#$F800F800,$320(A0)
	ORI.L	#$3DF07FE,$320(A0)
	ANDI.W	#$F800,$3C0(A0)
	ORI.L	#$3DE07FF,$3C0(A0)
	ANDI.W	#$F800,$460(A0)
	ORI.L	#$5AD07FF,$460(A0)
	ANDI.W	#$FC01,$500(A0)
	ORI.L	#$27203FE,$500(A0)
	ANDI.W	#$FE03,$5A0(A0)
	ORI.L	#$15401FC,$5A0(A0)
	ORI.L	#$F800F8,$640(A0)
	ANDI.W	#$FF07,$6E0(A0)
	ORI.L	#$D000F8,$6E0(A0)
  subq.w	#$4,d4	; One skull less.
  bgt	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts

skull6:	ANDI.L	#$FE01FE01,(A0)
	ORI.L	#$172018E,(A0)
	ANDI.L	#$FC00FC00,$A0(A0)
	ORI.L	#$2F90307,$A0(A0)
	ANDI.L	#$FC00FC00,$140(A0)
	ORI.L	#$2F90307,$140(A0)
	ORI.L	#$80008000,$148(A0)
	ANDI.L	#$FC00FC00,$1E0(A0)
	ORI.L	#$3B303CF,$1E0(A0)
	ORI.L	#$80008000,$1E8(A0)
	ANDI.L	#$FC00FC00,$280(A0)
	ORI.L	#$2C70338,$280(A0)
	ORI.L	#$80008000,$288(A0)
	ANDI.W	#$FC00,$320(A0)
	ORI.L	#$1EF03FF,$320(A0)
	ORI.W	#$8000,$328(A0)
	ANDI.W	#$7FFF,$32A(A0)
	ANDI.W	#$FC00,$3C0(A0)
	ORI.L	#$1EF03FF,$3C0(A0)
	ANDI.W	#$7FFF,$3C8(A0)
	ORI.W	#$8000,$3CA(A0)
	ANDI.W	#$FC00,$460(A0)
	ORI.L	#$2D603FF,$460(A0)
	ORI.L	#$80008000,$468(A0)
	ANDI.W	#$FE00,$500(A0)
	ORI.L	#$13901FF,$500(A0)
	ANDI.W	#$FF01,$5A0(A0)
	ORI.L	#$AA00FE,$5A0(A0)
	ORI.L	#$7C007C,$640(A0)
	ANDI.W	#$FF83,$6E0(A0)
	ORI.L	#$68007C,$6E0(A0)
  subq.w	#$4,d4	; One skull less.
  bgt	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts

skull7:	ANDI.L	#$FF00FF00,(A0)
	ORI.L	#$B900C7,(A0)
	ANDI.L	#$FE00FE00,$A0(A0)
	ORI.L	#$17C0183,$A0(A0)
	ORI.L	#$80008000,$A8(A0)
	ANDI.L	#$FE00FE00,$140(A0)
	ORI.L	#$17C0183,$140(A0)
	ORI.L	#$C000C000,$148(A0)
	ANDI.L	#$FE00FE00,$1E0(A0)
	ORI.L	#$1D901E7,$1E0(A0)
	ORI.L	#$C000C000,$1E8(A0)
	ANDI.L	#$FE00FE00,$280(A0)
	ORI.L	#$163019C,$280(A0)
	ANDI.W	#$3FFF,$28A(A0)
	ORI.L	#$C0004000,$288(A0)
	ANDI.W	#$FE00,$320(A0)
	ORI.L	#$F701FF,$320(A0)
	ANDI.W	#$3FFF,$32A(A0)
	ORI.L	#$C0008000,$328(A0)
	ANDI.W	#$FE00,$3C0(A0)
	ORI.L	#$F701FF,$3C0(A0)
	ANDI.W	#$3FFF,$3C8(A0)
	ORI.L	#$8000C000,$3C8(A0)
	ANDI.W	#$FE00,$460(A0)
	ORI.L	#$16B01FF,$460(A0)
	ANDI.W	#$3FFF,$468(A0)
	ORI.L	#$4000C000,$468(A0)
	ANDI.W	#$FF00,$500(A0)
	ORI.L	#$9C00FF,$500(A0)
	ORI.L	#$80008000,$508(A0)
	ANDI.W	#$FF80,$5A0(A0)
	ORI.L	#$55007F,$5A0(A0)
	ORI.L	#$3E003E,$640(A0)
	ANDI.W	#$FFC1,$6E0(A0)
	ORI.L	#$34003E,$6E0(A0)
  subq.w	#$4,d4	; One skull less.
  bgt	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts

skull8:	ANDI.L	#$FF80FF80,(A0)
	ORI.L	#$5C0063,(A0)
	ORI.L	#$80008000,8(A0)
	ANDI.L	#$FF00FF00,$A0(A0)
	ORI.L	#$BE00C1,$A0(A0)
	ANDI.W	#$3FFF,$A8(A0)
	ORI.L	#$4000C000,$A8(A0)
	ANDI.L	#$FF00FF00,$140(A0)
	ORI.L	#$BE00C1,$140(A0)
	ANDI.W	#$1FFF,$148(A0)
	ORI.L	#$6000E000,$148(A0)
	ANDI.L	#$FF00FF00,$1E0(A0)
	ORI.L	#$EC00F3,$1E0(A0)
	ORI.L	#$E000E000,$1E8(A0)
	ANDI.L	#$FF00FF00,$280(A0)
	ORI.L	#$B100CE,$280(A0)
	ANDI.W	#$1FFF,$28A(A0)
	ORI.L	#$E0002000,$288(A0)
	ANDI.W	#$FF00,$320(A0)
	ORI.L	#$7B00FF,$320(A0)
	ANDI.W	#$1FFF,$32A(A0)
	ORI.L	#$E000C000,$328(A0)
	ANDI.W	#$FF00,$3C0(A0)
	ORI.L	#$7B00FF,$3C0(A0)
	ANDI.W	#$1FFF,$3C8(A0)
	ORI.L	#$C000E000,$3C8(A0)
	ANDI.W	#$FF00,$460(A0)
	ORI.L	#$B500FF,$460(A0)
	ANDI.W	#$1FFF,$468(A0)
	ORI.L	#$A000E000,$468(A0)
	ANDI.W	#$FF80,$500(A0)
	ORI.L	#$4E007F,$500(A0)
	ANDI.W	#$3FFF,$508(A0)
	ORI.L	#$4000C000,$508(A0)
	ANDI.W	#$FFC0,$5A0(A0)
	ORI.L	#$2A003F,$5A0(A0)
	ORI.L	#$80008000,$5A8(A0)
	ORI.L	#$1F001F,$640(A0)
	ANDI.W	#$FFE0,$6E0(A0)
	ORI.L	#$1A001F,$6E0(A0)
  subq.w	#$4,d4	; One skull less.
  bgt	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts

skull9:	ANDI.L	#$FFC0FFC0,(A0)
	ORI.L	#$2E0031,(A0)
	ANDI.W	#$3FFF,8(A0)
	ORI.L	#$4000C000,8(A0)
	ANDI.L	#$FF80FF80,$A0(A0)
	ORI.L	#$5F0060,$A0(A0)
	ANDI.W	#$1FFF,$A8(A0)
	ORI.L	#$2000E000,$A8(A0)
	ANDI.L	#$FF80FF80,$140(A0)
	ORI.L	#$5F0060,$140(A0)
	ANDI.W	#$FFF,$148(A0)
	ORI.L	#$3000F000,$148(A0)
	ANDI.L	#$FF80FF80,$1E0(A0)
	ORI.L	#$760079,$1E0(A0)
	ANDI.W	#$FFF,$1E8(A0)
	ORI.L	#$7000F000,$1E8(A0)
	ANDI.L	#$FF80FF80,$280(A0)
	ORI.L	#$580067,$280(A0)
	ANDI.W	#$FFF,$28A(A0)
	ORI.L	#$F0001000,$288(A0)
	ANDI.W	#$FF80,$320(A0)
	ORI.L	#$3D007F,$320(A0)
	ANDI.W	#$FFF,$32A(A0)
	ORI.L	#$F000E000,$328(A0)
	ANDI.W	#$FF80,$3C0(A0)
	ORI.L	#$3D007F,$3C0(A0)
	ANDI.W	#$FFF,$3C8(A0)
	ORI.L	#$E000F000,$3C8(A0)
	ANDI.W	#$FF80,$460(A0)
	ORI.L	#$5A007F,$460(A0)
	ANDI.W	#$FFF,$468(A0)
	ORI.L	#$D000F000,$468(A0)
	ANDI.W	#$FFC0,$500(A0)
	ORI.L	#$27003F,$500(A0)
	ANDI.W	#$1FFF,$508(A0)
	ORI.L	#$2000E000,$508(A0)
	ANDI.W	#$FFE0,$5A0(A0)
	ORI.L	#$15001F,$5A0(A0)
	ANDI.W	#$3FFF,$5A8(A0)
	ORI.L	#$4000C000,$5A8(A0)
	ORI.L	#$F000F,$640(A0)
	ORI.L	#$80008000,$648(A0)
	ANDI.W	#$FFF0,$6E0(A0)
	ORI.L	#$D000F,$6E0(A0)
	ANDI.W	#$7FFF,$6E8(A0)
	ORI.W	#$8000,$6EA(A0)
  subq.w	#$4,d4	; One skull less.
  bgt	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts

skullA:	ANDI.L	#$FFE0FFE0,(A0)
	ORI.L	#$170018,(A0)
	ANDI.W	#$1FFF,8(A0)
	ORI.L	#$2000E000,8(A0)
	ANDI.L	#$FFC0FFC0,$A0(A0)
	ORI.L	#$2F0030,$A0(A0)
	ANDI.L	#$FFF0FFF,$A8(A0)
	ORI.L	#$90007000,$A8(A0)
	ANDI.L	#$FFC0FFC0,$140(A0)
	ORI.L	#$2F0030,$140(A0)
	ANDI.L	#$7FF07FF,$148(A0)
	ORI.L	#$98007800,$148(A0)
	ANDI.L	#$FFC0FFC0,$1E0(A0)
	ORI.L	#$3B003C,$1E0(A0)
	ANDI.W	#$7FF,$1E8(A0)
	ORI.L	#$3800F800,$1E8(A0)
	ANDI.L	#$FFC0FFC0,$280(A0)
	ORI.L	#$2C0033,$280(A0)
	ANDI.L	#$7FF07FF,$288(A0)
	ORI.L	#$78008800,$288(A0)
	ANDI.W	#$FFC0,$320(A0)
	ORI.L	#$1E003F,$320(A0)
	ANDI.W	#$7FF,$32A(A0)
	ORI.L	#$F800F000,$328(A0)
	ANDI.W	#$FFC0,$3C0(A0)
	ORI.L	#$1E003F,$3C0(A0)
	ANDI.W	#$7FF,$3C8(A0)
	ORI.L	#$F000F800,$3C8(A0)
	ANDI.W	#$FFC0,$460(A0)
	ORI.L	#$2D003F,$460(A0)
	ANDI.W	#$7FF,$468(A0)
	ORI.L	#$6800F800,$468(A0)
	ANDI.W	#$FFE0,$500(A0)
	ORI.L	#$13001F,$500(A0)
	ANDI.W	#$FFF,$508(A0)
	ORI.L	#$9000F000,$508(A0)
	ANDI.W	#$FFF0,$5A0(A0)
	ORI.L	#$A000F,$5A0(A0)
	ANDI.W	#$1FFF,$5A8(A0)
	ORI.L	#$A000E000,$5A8(A0)
	ORI.L	#$70007,$640(A0)
	ORI.L	#$C000C000,$648(A0)
	ANDI.W	#$FFF8,$6E0(A0)
	ORI.L	#$60007,$6E0(A0)
	ANDI.W	#$3FFF,$6E8(A0)
	ORI.L	#$8000C000,$6E8(A0)
  subq.w	#$4,d4	; One skull less.
  bgt	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts

skullB:	ANDI.L	#$FFF0FFF0,(A0)
	ORI.L	#$B000C,(A0)
	ANDI.L	#$FFF0FFF,8(A0)
	ORI.L	#$90007000,8(A0)
	ANDI.L	#$FFE0FFE0,$A0(A0)
	ORI.L	#$170018,$A0(A0)
	ANDI.L	#$7FF07FF,$A8(A0)
	ORI.L	#$C8003800,$A8(A0)
	ANDI.L	#$FFE0FFE0,$140(A0)
	ORI.L	#$170018,$140(A0)
	ANDI.L	#$3FF03FF,$148(A0)
	ORI.L	#$CC003C00,$148(A0)
	ANDI.L	#$FFE0FFE0,$1E0(A0)
	ORI.L	#$1D001E,$1E0(A0)
	ANDI.L	#$3FF03FF,$1E8(A0)
	ORI.L	#$9C007C00,$1E8(A0)
	ANDI.L	#$FFE0FFE0,$280(A0)
	ORI.L	#$160019,$280(A0)
	ANDI.L	#$3FF03FF,$288(A0)
	ORI.L	#$3C00C400,$288(A0)
	ANDI.W	#$FFE0,$320(A0)
	ORI.L	#$F001F,$320(A0)
	ANDI.L	#$3FF03FF,$328(A0)
	ORI.L	#$7C00F800,$328(A0)
	ANDI.W	#$FFE0,$3C0(A0)
	ORI.L	#$F001F,$3C0(A0)
	ANDI.W	#$3FF,$3C8(A0)
	ORI.L	#$7800FC00,$3C8(A0)
	ANDI.W	#$FFE0,$460(A0)
	ORI.L	#$16001F,$460(A0)
	ANDI.W	#$3FF,$468(A0)
	ORI.L	#$B400FC00,$468(A0)
	ANDI.W	#$FFF0,$500(A0)
	ORI.L	#$9000F,$500(A0)
	ANDI.W	#$7FF,$508(A0)
	ORI.L	#$C800F800,$508(A0)
	ANDI.W	#$FFF8,$5A0(A0)
	ORI.L	#$50007,$5A0(A0)
	ANDI.W	#$FFF,$5A8(A0)
	ORI.L	#$5000F000,$5A8(A0)
	ORI.L	#$30003,$640(A0)
	ORI.L	#$E000E000,$648(A0)
	ORI.L	#$30003,$6E0(A0)
	ANDI.W	#$1FFF,$6E8(A0)
	ORI.L	#$4000E000,$6E8(A0)
  subq.w	#$4,d4	; One skull less.
  bgt	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts

skullC:	ANDI.L	#$FFF8FFF8,(A0)
	ORI.L	#$50006,(A0)
	ANDI.L	#$7FF07FF,8(A0)
	ORI.L	#$C8003800,8(A0)
	ANDI.L	#$FFF0FFF0,$A0(A0)
	ORI.L	#$B000C,$A0(A0)
	ANDI.L	#$3FF03FF,$A8(A0)
	ORI.L	#$E4001C00,$A8(A0)
	ANDI.L	#$FFF0FFF0,$140(A0)
	ORI.L	#$B000C,$140(A0)
	ANDI.L	#$1FF01FF,$148(A0)
	ORI.L	#$E6001E00,$148(A0)
	ANDI.W	#$FFF0,$1E0(A0)
	ORI.L	#$E000F,$1E0(A0)
	ANDI.L	#$1FF01FF,$1E8(A0)
	ORI.L	#$CE003E00,$1E8(A0)
	ANDI.L	#$FFF0FFF0,$280(A0)
	ORI.L	#$B000C,$280(A0)
	ANDI.L	#$1FF01FF,$288(A0)
	ORI.L	#$1E00E200,$288(A0)
	ANDI.W	#$FFF0,$320(A0)
	ORI.L	#$7000F,$320(A0)
	ANDI.L	#$1FF01FF,$328(A0)
	ORI.L	#$BE00FC00,$328(A0)
	ANDI.W	#$FFF0,$3C0(A0)
	ORI.L	#$7000F,$3C0(A0)
	ANDI.W	#$1FF,$3C8(A0)
	ORI.L	#$BC00FE00,$3C8(A0)
	ANDI.W	#$FFF0,$460(A0)
	ORI.L	#$B000F,$460(A0)
	ANDI.W	#$1FF,$468(A0)
	ORI.L	#$5A00FE00,$468(A0)
	ANDI.W	#$FFF8,$500(A0)
	ORI.L	#$40007,$500(A0)
	ANDI.W	#$3FF,$508(A0)
	ORI.L	#$E400FC00,$508(A0)
	ANDI.W	#$FFFC,$5A0(A0)
	ORI.L	#$20003,$5A0(A0)
	ANDI.W	#$7FF,$5A8(A0)
	ORI.L	#$A800F800,$5A8(A0)
	ORI.L	#$10001,$640(A0)
	ORI.L	#$F000F000,$648(A0)
	ORI.L	#$10001,$6E0(A0)
	ANDI.W	#$FFF,$6E8(A0)
	ORI.L	#$A000F000,$6E8(A0)
  subq.w	#$4,d4	; One skull less.
  bgt	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts

skullD:	ANDI.W	#$FFFC,(A0)
	ORI.L	#$20003,(A0)
	ANDI.L	#$3FF03FF,8(A0)
	ORI.L	#$E4001C00,8(A0)
	ANDI.L	#$FFF8FFF8,$A0(A0)
	ORI.L	#$50006,$A0(A0)
	ANDI.L	#$1FF01FF,$A8(A0)
	ORI.L	#$F2000E00,$A8(A0)
	ANDI.L	#$FFF8FFF8,$140(A0)
	ORI.L	#$50006,$140(A0)
	ANDI.L	#$FF00FF,$148(A0)
	ORI.L	#$F3000F00,$148(A0)
	ORI.L	#$70007,$1E0(A0)
	ANDI.L	#$FF00FF,$1E8(A0)
	ORI.L	#$67009F00,$1E8(A0)
	ANDI.L	#$FFF8FFF8,$280(A0)
	ORI.L	#$50006,$280(A0)
	ANDI.L	#$FF00FF,$288(A0)
	ORI.L	#$8F007100,$288(A0)
	ANDI.W	#$FFF8,$320(A0)
	ORI.L	#$30007,$320(A0)
	ANDI.L	#$FF00FF,$328(A0)
	ORI.L	#$DF00FE00,$328(A0)
	ANDI.W	#$FFF8,$3C0(A0)
	ORI.L	#$30007,$3C0(A0)
	ANDI.W	#$FF,$3C8(A0)
	ORI.L	#$DE00FF00,$3C8(A0)
	ANDI.W	#$FFF8,$460(A0)
	ORI.L	#$50007,$460(A0)
	ANDI.W	#$FF,$468(A0)
	ORI.L	#$AD00FF00,$468(A0)
	ANDI.W	#$FFFC,$500(A0)
	ORI.L	#$20003,$500(A0)
	ANDI.W	#$1FF,$508(A0)
	ORI.L	#$7200FE00,$508(A0)
	ORI.L	#$10001,$5A0(A0)
	ANDI.W	#$3FF,$5A8(A0)
	ORI.L	#$5400FC00,$5A8(A0)
	ORI.L	#$F800F800,$648(A0)
	ANDI.W	#$7FF,$6E8(A0)
	ORI.L	#$D000F800,$6E8(A0)
  subq.w	#$4,d4	; One skull less.
  bgt	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts

skullE:	ORI.L	#$10001,(A0)
	ANDI.L	#$1FF01FF,8(A0)
	ORI.L	#$72008E00,8(A0)
	ANDI.W	#$FFFC,$A0(A0)
	ORI.L	#$20003,$A0(A0)
	ANDI.L	#$FF00FF,$A8(A0)
	ORI.L	#$F9000700,$A8(A0)
	ANDI.W	#$FFFC,$140(A0)
	ORI.L	#$20003,$140(A0)
	ANDI.L	#$7F007F,$148(A0)
	ORI.L	#$F9800780,$148(A0)
	ORI.L	#$30003,$1E0(A0)
	ANDI.L	#$7F007F,$1E8(A0)
	ORI.L	#$B380CF80,$1E8(A0)
	ANDI.W	#$FFFC,$280(A0)
	ORI.L	#$20003,$280(A0)
	ANDI.L	#$7F007F,$288(A0)
	ORI.L	#$C7803880,$288(A0)
	ANDI.W	#$FFFC,$320(A0)
	ORI.L	#$10003,$320(A0)
	ANDI.L	#$7F007F,$328(A0)
	ORI.L	#$EF80FF00,$328(A0)
	ANDI.W	#$FFFC,$3C0(A0)
	ORI.L	#$10003,$3C0(A0)
	ANDI.W	#$7F,$3C8(A0)
	ORI.L	#$EF00FF80,$3C8(A0)
	ANDI.W	#$FFFC,$460(A0)
	ORI.L	#$20003,$460(A0)
	ANDI.W	#$7F,$468(A0)
	ORI.L	#$D680FF80,$468(A0)
	ORI.L	#$10001,$500(A0)
	ANDI.W	#$FF,$508(A0)
	ORI.L	#$3900FF00,$508(A0)
	ANDI.W	#$1FF,$5A8(A0)
	ORI.L	#$AA00FE00,$5A8(A0)
	ORI.L	#$7C007C00,$648(A0)
	ANDI.W	#$83FF,$6E8(A0)
	ORI.L	#$68007C00,$6E8(A0)
  subq.w	#$4,d4	; One skull less.
  bgt	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts

skullF:	ANDI.L	#$FF00FF,8(A0)
	ORI.L	#$B900C700,8(A0)
	ORI.L	#$10001,$A0(A0)
	ANDI.L	#$7F007F,$A8(A0)
	ORI.L	#$7C808380,$A8(A0)
	ORI.L	#$10001,$140(A0)
	ANDI.L	#$3F003F,$148(A0)
	ORI.L	#$7CC083C0,$148(A0)
	ORI.L	#$10001,$1E0(A0)
	ANDI.L	#$3F003F,$1E8(A0)
	ORI.L	#$D9C0E7C0,$1E8(A0)
	ORI.L	#$10001,$280(A0)
	ANDI.L	#$3F003F,$288(A0)
	ORI.L	#$63C09C40,$288(A0)
	ANDI.W	#$FFFE,$320(A0)
	ORI.W	#1,$322(A0)
	ANDI.L	#$3F003F,$328(A0)
	ORI.L	#$F7C0FF80,$328(A0)
	ANDI.W	#$FFFE,$3C0(A0)
	ORI.W	#1,$3C2(A0)
	ANDI.W	#$3F,$3C8(A0)
	ORI.L	#$F780FFC0,$3C8(A0)
	ORI.L	#$10001,$460(A0)
	ANDI.W	#$3F,$468(A0)
	ORI.L	#$6B40FFC0,$468(A0)
	ANDI.W	#$7F,$508(A0)
	ORI.L	#$9C80FF80,$508(A0)
	ANDI.W	#$80FF,$5A8(A0)
	ORI.L	#$55007F00,$5A8(A0)
	ORI.L	#$3E003E00,$648(A0)
	ANDI.W	#$C1FF,$6E8(A0)
	ORI.L	#$34003E00,$6E8(A0)
  subq.w	#$4,d4	; One skull less.
  bgt.s	one_skull
  add.w	d6,a3	; Next mini array.
  dbra	d7,one_mini_array
  movem.l	(sp)+,d0-a6	; Classic too!
  rts


; *************************************************************************
; ****       Routine which prints the skullsphere from the datas       ****
; ****                 stored in the "sorted array".                   ****
; *************************************************************************
; Parameters:	a0.l = adress of the ramvideo.
;	d0.w = x position of the sphere.
;	d1.w = y position of the sphere.

print_sphere:
  movem.l	d0-a6,-(sp)	; Classic he!

  move.l	a0,a6	; We'll change the ramvideo adress.
  move.l	#skull_adresses,a5 ; Adress of the skullrouts.
  move.l	#conv_tables,a4 ; I want something fast.
  move.l	#sorted_array,a3
  moveq.l	#dist_max+1,d7	; Beyond dist_max, mini arrays are empty.
  move.w	#128,d6	; Size of one mini array.
  moveq.l	#$0,d5
one_mini_array:
  move.w	(a3),d4	; Nb of skulls for this distance*4.
  beq.s	next_dist	: Array empty?
.mini_array_not_empty:    
  move.l	a3,a2	; We will change a2 else.
  move.w	d5,(a2)+	; Put zero, for next time.
one_skull:
  move.l	a6,a0	; Adress of the ramvideo.
  move.w	(a2)+,d2	; x.
  move.w	(a2)+,d3	; y.
  add.w	d0,d2
  add.w	d1,d3
  add.w	d3,d3	; d3=y*2.
  add.w	(a4,d3.w),a0	; a0 points on the good line.
  add.w	d2,d2
  add.w	d2,d2	; d4=x*4.
  add.w	#400,d2	; To point on x conversion table.	
  add.w	(a4,d2.w),a0	; a0 points on the good word.
  move.w	$2(a4,d2.w),d2	; x mod(16)*4. ( Skew*4. )
  move.l	(a5,d2.w),a1	; Adress of the skull rout to use.
  jmp	(a1)

  subq.w	#$4,d4	; One skull less.
  bgt.s	one_skull
  
next_dist:
  add.l	d6,a3	; Next mini array.
  dbra	d7,one_mini_array

  movem.l	(sp)+,d0-a6	; Classic too!
  rts

; *************************************************************************
; *************************************************************************
; *************************************************************************
; All the routines...
; *************************************************************************
; *************************************************************************
; *************************************************************************

  Section TEXT

print:
  include	'a:\sources\print.s'
  
clear_4b:
  include	'a:\sources\clear_4b.s'

clear_2b:
  include	'a:\sources\clear_2b.s'

makefade:
  include	'a:\sources\makefade.s'

mapped_poly:
  include	'a:\sources\polymap.s'

  Section TEXT

precalc_one:
  include	'a:\sources\precalc.s'

; **********************************************************************
  Section DATA

cube_par:
  dc.w	256+128+64
cube_angle:
  dc.w	20

work_screen:
  dc.w	0
show_screen:
  dc.w	1

black_colors:
  dc.w	$000,$000,$000,$000
  dc.w	$000,$000,$000,$000
  dc.w	$000,$000,$000,$000
  dc.w	$000,$000,$000,$000
white_colors:
  dc.w	$000,$555,$555,$555
  dc.w	$555,$555,$555,$555
  dc.w	$555,$555,$555,$555
  dc.w	$555,$555,$555,$555
text_colors:
  dc.w	$000,$555,$444,$222
  dc.w	$000,$000,$000,$000
  dc.w	$000,$000,$000,$000
  dc.w	$000,$000,$000,$000
image_colors:
  dc.w	$000,$888,$111,$999
  dc.w	$222,$aaa,$333,$bbb
  dc.w	$444,$ccc,$555,$ddd
  dc.w	$666,$eee,$777,$fff
mapping_colors:
  dc.w	$000,$888,$111,$999
  dc.w	$222,$aaa,$333,$bbb
  dc.w	$444,$ccc,$555,$ddd
  dc.w	$666,$eee,$777,$fff

image1:
  incbin	'a:\datas\map1.xxx'
image2:
  incbin	'a:\datas\map2.xxx'

sinus:
  incbin	'a:\datas\sinus.xxx'
     
screen2:
  incbin	'a:\datas\image1.xxx'
screen3:
  incbin	'a:\datas\image2.xxx'

text1: dc.b	'Musik by Big Alec.',0
text2: dc.b	'Logo by Dom Dracula & Dom''s A1200.',0
text3: dc.b	'Code by Dracula.',0
text4: dc.b	'You''ve seen Shaded Mapping.',0
text5: dc.b	'For the first time ever on ST&Amiga!',0
text6: dc.b	'Coming next is a SkullSphere.',0
text7: dc.b	'Greetings to all our friends...',0
text8: dc.b	'Enjoy or die...',0
text9: dc.b	'The End!',0

  even
conv_tables:

N set 0		; Conversion table y->y*160.
 rept	200
  dc.w	N
N set N+$a0
 endr

N set 0		; x -> offset + skew*4.
 rept	20
  dc.w	N,00,N,04,N,08,N,12,N,16,N,20,N,24,N,28
  dc.w	N,32,N,36,N,40,N,44,N,48,N,52,N,56,N,60
N set N+8
 endr

skull_colors:
  dc.w	$000,$667,$446,$223
  dc.w	$000,$000,$000,$000
  dc.w	$000,$000,$000,$000
  dc.w	$000,$000,$000,$000

skull_adresses:
  dc.l	skull0,skull1,skull2,skull3
  dc.l	skull4,skull5,skull6,skull7
  dc.l	skull8,skull9,skullA,skullB
  dc.l	skullC,skullD,skullE,skullF

coords:
  incbin	'a:\datas\coords.xxx'

old_y1:		; y of the sphere stored here.
  dc.w	99
old_y2:
  dc.w	99

music:
  incbin	'a:\datas\big_alec.xxx'

    
; **********************************************************************
  Section BSS

  even
  
old_x:
  ds.w	6

old_vbl:
  ds.l	1    
old_colors:
  ds.w	16
old_timerc:
  ds.l	1
old_physbase:
  ds.w	1
old_res:
  ds.w	1    
img1_adresses:		; Adresses for all the precalculation of
  ds.l	50	; the first image.
  
img2_adresses:		; The same for image 2.
  ds.l	50
  
precalcs:		; There will be ~ 200 Kb of precalcs.
  ds.b	196000  

screen1:
  ds.b	32160

fade_buffer:		; Up to 3 fading tables.
  ds.w	16*16*3

sorted_array:		; dist_max distances.
  ds.w	(dist_max+4)*64

alpha:		; Angle around z.
  ds.w	1
beta:		; For beta=angle around x.
  ds.w	1

y_angle:		; Angle for the bounces.
  ds.w	1

conterm:
  ds.w	1 

