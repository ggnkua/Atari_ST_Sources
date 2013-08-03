; *************************************************************************
; ****                        The CAKEHEAD demo.                       ****
; ****                     By Dracula of Positivity.                   ****
; *************************************************************************

  opt	o+

dist_user = 256
dist_user2 = 8

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

  dc.w	$a00a	; Fuck mouse. ( And remember to scotch
  move.b	#$12,$fffffc02.w ; it else it'll explode. )
  
  move.l	$114.w,old_timerc ; Save timer c.
  move.l	#null_timerc,$114.w ; And fuck it....
  move.w	#$0,$452.w	; Fuck the system vbl.
  move.l	$70.w,old_vbl

  move.l	#null_vbl,$70.w
  
; *************************************************************************

  move.w	#$25,-(sp)
  trap	#$e
  addq.l	#$2,sp

  move.b	#$0,$ffff8260.w
  
  move.l	#$ffff8240,a0
  move.l	#old_colors,a1
  move.l	#colors,a2
  rept	8
  move.l	(a0),(a1)+
  move.l	(a2)+,(a0)+
  endr

; *************************************************************************
    
  move.l	#precalcs,a0	; Do the precalculations.
  move.l	#image1,a1
  move.l	#img1_adresses,a2
  jsr	precalc_one
  move.l	#precalcs+98000,a0 ; And now for image2.
  move.l	#image2,a1
  move.l	#img2_adresses,a2
  jsr	precalc_one
  
 
; *************************************************************************

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
  add.w	#456,d1	; d1=456+400*cos(3*par)*sin(2*par).
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

; *************************************************************************

system_friendly:
  move.l	old_vbl,$70.w	; Restore old vbl.

  move.l	old_timerc,$114.w ; Restore Old Timer. (Lucky Luke rules.)
  move.b	#$8,$fffffc02.w ; The mouse which exploded before.
  dc.w	$a009

  move.w	#$25,-(sp)	; Wait the vbl.
  trap	#$e
  addq.l	#$2,sp

  move.l	#-$1,-(sp)	; Restore screen.
  move.l	#-$1,-(sp)
  move.w	#-$1,-(sp)
  move.w	#$5,-(sp)
  trap	#$e
  add.l	#$c,sp
  
  move.l	#$ffff8240,a0	; Restore colors.
  move.l	#old_colors,a1
  rept	8
  move.l	(a1)+,(a0)+
  endr

  clr.w	-(sp)	; The end.
  trap	#$1

; **********************************************************************
mapping_vbl:
  addq.l	#$1,$466.w	; Increase _frclock.
  movem.l	d0-d1,-(sp)
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
  move.b	d1,$ffff8209.w	; Show it.
  lsr.w	#$8,d1
  move.b	d1,$ffff8207.w
  swap.w	d1
  move.b	d1,$ffff8205.w
  movem.l	(sp)+,d0-d1
  rte

; *************************************************************************
null_vbl:
  addq.l	#$1,$466.w	; Increase _frclock.
  rte
   
; *************************************************************************
null_timerc:		; This do... Nothing.
  addq.l	#$1,$4ba.w	; Interrupt counter.
  bclr.b	#$5,$fffffa11.w	; Interrupt no more in service.
  rte

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

colors:
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
  ds.b	32000
;  incbin	'a:\logo1.xxx'
screen3:
  ds.b	32000
;  incbin	'a:\logo2.xxx'

; **********************************************************************
  Section BSS

old_x:
  ds.w	6

old_vbl:
  ds.l	1    
old_colors:
  ds.w	16
old_timerc:
  ds.l	1
    
img1_adresses:		; Adresses for all the precalculation of
  ds.l	50	; the first image.
  
img2_adresses:		; The same for image 2.
  ds.l	50
  
precalcs:		; There will be ~ 200 Kb of precalcs.
  ds.b	196000  

screen1:
  ds.b	32000
  
  Section TEXT

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

; *************************************************************************
  Section TEXT

clear_4b:
  include	'a:\sources\clear_4b.s'

mapped_poly:
  include	'a:\sources\polymap.s'

  Section TEXT

precalc_one:
  include	'a:\sources\precalc.s'
