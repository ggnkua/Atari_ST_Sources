;**************************************************************************
;**	           Le programme principal!	         **
;**************************************************************************

addy	equ	89
rb	equ	70  ; Rayon de la bubble.
rr	equ	12   ; Rayon du reflex.
addr	equ	35  ; Addition pour le reflex.
ymin	equ	90
dist	equ	120 ; Rayon du cercle du parcours.

supervisor_mode:	; INDISPENSABLE.
  move.l	#$0,-(sp)
  move.w	#$20,-(sp)
  trap	#$1
  addq.l	#$6,sp

  dc.w	$a00a	; Bye bye la souris.
  move.b	#$12,$fffffc02.w
  bclr.b	#$0,$484.w
  
screens_adresses:  	; Calcul des adresses des ecrans.
  move.l	#screens,d0
  and.l	#$ffffff00,d0	; S' aligner sur un multiple de 256.
  add.l	#$100,d0
  move.l	d0,screen1_ad	; Adresse de l' ecran 1.
  add.l	#$7d00,d0
  move.l	d0,screen2_ad	; Ecran 2.

save_old_features:	
  move.w	$ffff8260.w,old_res
  move.b	$ffff820a.w,old_sync
  moveq.l	#$0,d0
  move.b	$ffff8201.w,d0	; Base haute.
  swap.w	d0
  move.b	$ffff8203.w,d0	; Moyenne.
  lsl.w	#$8,d0
  move.b	$ffff820d.w,d0	; Basse.( N' existe pas sur ST-STf)
  move.l	d0,old_screen
  move.l	#$7,d0	; Sauver les couleurs qu'on va modifier.
  move.l	#old_colors,a0
  move.w	#$8240,a1
.save_cols:
  move.l 	(a1)+,(a0)+
  dbra	d0,.save_cols

screen_features:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp
  move.w	#$0,$ffff8260.w	; Basse resolution.
  move.b	#$2,$ffff820a.w	; Sync=50Hz.
  move.l	screen2_ad,d0	; Mettre l' adresse de l' ecran 2.
  lsr.w	#$8,d0
  move.b	d0,$ffff8203.w
  swap.w	d0
  move.b	d0,$ffff8201.w
  move.b	#$0,$ffff820d.w
  moveq.l	#$7,d0	
  move.w	#$8240,a0	; Mettre les couleurs a $334.
  move.l	#colors,a1
.put_cols:
  move.l 	(a1)+,(a0)+
  dbra	d0,.put_cols
  
;**************************************************************************

init_timer_b:
  bclr.b	#$0,$fffffa07.w	; Timer B disabled!..
  bset.b	#$0,$fffffa13.w ; Timer B demasked.
  bset.b	#$3,$fffffa17.w	; Soft end of interrupt.
  move.l	#timer_b,$120
  move.b	#$0,$fffffa1b.w	; Timer B stoppe.
  bset.b	#$0,$fffffa07.w	; Timer B enabled.
  
  move.w	#$0,alpha
  move.w	#$0,script_pos
  move.l	#script,a5
  move.l	#script+80,a3
  move.l	#sin_cos,a4
  move.w	#-96,addx
  move.w	#$1,incx
    
vbl1:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  moveq.l	#$7,d0	
  move.w	#$8240,a0	; Couleurs du haut.
  move.l	#colors,a1
.put_cols:
  move.l 	(a1)+,(a0)+
  dbra	d0,.put_cols

.timer_b:
  move.b	#$0,$fffffa1b.w	; Stop the timer.
  move.b	#addy+27,$fffffa21.w ; Wait y lignes.
  move.b	#$8,$fffffa1b.w	; Event count mode.

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test
  add.w	#$111,$ffff8240.w
.no_test:

  move.l	screen1_ad,a6

.clear_everything:
  move.w	xb1,d0
  move.w	yb1,d1
  move.w	rxb1,d2
  move.w	ryb1,d3
  move.l	a6,a0
  jsr	cls_ball	; Clear bubble.
  
  move.w	xb1,d0
  move.w	ys1,d1
  move.w	rxb1,d2
  move.w	rys1,d3
  move.l	a6,a0
  addq.l	#$2,a0
  jsr	cls_ball	; Clear shadow.

  move.w	xr1,d0
  move.w	yr1,d1
  move.w	rxr1,d2
  move.w	ryr1,d3
  move.l	a6,a0
  addq.l	#$4,a0
  jsr	cls_ball	; Clear reflex.

.clear_everything_b:
  move.w	xb1_b,d0
  move.w	yb1_b,d1
  move.w	rxb1_b,d2
  move.w	ryb1_b,d3
  move.l	a6,a0
  addq.l	#$6,a0
  jsr	cls_ball	; Clear bubble.
  
  move.w	xb1_b,d0
  move.w	ys1_b,d1
  move.w	rxb1_b,d2
  move.w	rys1_b,d3
  move.l	a6,a0
  addq.l	#$2,a0
  jsr	cls_ball	; Clear shadow.

  move.w	xr1_b,d0
  move.w	yr1_b,d1
  move.w	rxr1_b,d2
  move.w	ryr1_b,d3
  move.l	a6,a0
  addq.l	#$4,a0
  jsr	cls_ball	; Clear reflex.

********* Calculations and all the rest.
  
.calculations:
  move.w	alpha,d0
  addq.w	#$2,d0	; Tournez maneges.
  cmp.w	#$200,d0	; Un tour complet?
  bne.s	.angle_ok
  moveq.l	#$0,d0
.angle_ok:
  move.w	d0,alpha
  add.w	d0,d0	; 1 mot par sinus.
  move.w	(a4,d0.w),d1	; d1=sin(alpha).
  add.w	#$100,d0
  move.w	(a4,d0.w),d0	; d0=cos(alpha).
  muls.w	#dist,d0
  add.l	d0,d0
  add.l	d0,d0
  swap.w	d0	; d0=dist*cos.
  add.w	#dist,d0	; d0=dist*cos+dist.
  muls.w	#dist,d1
  add.l	d1,d1
  add.l	d1,d1
  swap.w	d1	; d1=dist*sin.
  
  add.w	#$100,d0	; d0=z+256.
  ext.l	d1
  lsl.l	#$8,d1	; d1=x*256.
  divs.w	d0,d1	; d1=x*256/(256+z).
  add.w	addx,d1
  move.w	d1,xb1	; xb1=addx+(x*256/(256+z)).
   
.script:
  move.w	(a5)+,d1	; d1=y.
  move.w	(a5)+,d6	; d6=mulx.
  move.w	(a5)+,d7	; d7=muly.
  add.w	#$1,script_pos
  move.w	script_pos,d2
  cmp.w	script_length,d2
  bne.s	.script_ok
  move.l	#script,a5
  move.w	#$0,script_pos
.script_ok:

  ext.l	d1
  lsl.l	#$8,d1	; d1=y*256.
  move.w	d0,d2
  divs.w	d2,d1	; d1=y*256/(256+z).
  add.w	#addy,d1
  move.w	d1,yb1	; yb1=addy+(y*256/(256+z)).
    
  move.w	#rb,d1
  move.w	d1,d2
  mulu.w	d6,d1
  lsr.l	#$6,d1	; d1=rb*mulx*256.
  divs.w	d0,d1	; d1=(rb*mulx*256/(256+z)).
  move.w	d1,rxb1
  mulu.w	d7,d2
  lsr.l	#$6,d2	; d2=rb*muly*256.
  divs.w	d0,d2	; d1=(rb*muly*256/(256+z)).
  move.w	d2,ryb1
  
  move.w	#ymin,d1
  ext.l	d1
  lsl.w	#$8,d1
  divs.w	d0,d1
  add.w	#addy,d1	; d1=addy+(ymin*256/(256+z)).
  move.w	d1,ys1
  
  move.l	#ymin,d2
  lsl.w	#$8,d2
  move.l	d2,d3
  move.w	d0,d1
  add.w	rxb1,d1
  divs.w	d0,d2
  divs.w	d1,d3
  sub.w	d3,d2	; d2=ymin*256*(1/(256+z)-1/(256+z+rxb)).  
  move.w	d2,rys1
  
  move.w	#addr,d1
  move.w	d1,d2
  mulu.w	d6,d1
  lsr.l	#$6,d1
  divs.w	d0,d1
  add.w	xb1,d1
  move.w	d1,xr1	; xr=xb+(addr*mulx*256/(256+z)).
  mulu.w	d7,d2
  lsr.l	#$6,d2
  divs.w	d0,d2
  sub.w	yb1,d2
  neg.w	d2
  move.w	d2,yr1	; yr=yb+(addr*muly*256/(256+z)).

  move.w	#rr,d1
  move.w	d1,d2
  mulu.w	d6,d1
  lsr.l	#$6,d1	; d1=rb*mulx*256.
  divs.w	d0,d1	; d1=(rb*mulx*256/(256+z)).
  move.w	d1,rxr1
  mulu.w	d7,d2
  lsr.l	#$6,d2	; d2=rb*muly*256.
  divs.w	d0,d2	; d1=(rb*muly*256/(256+z)).
  move.w	d2,ryr1
    
.print_everything:
  move.w	xb1,d0
  move.w	yb1,d1
  move.w	rxb1,d2
  move.w	ryb1,d3
  move.l	a6,a0
  jsr	ball	; Print bubble.
  
  move.w	xb1,d0
  move.w	ys1,d1
  move.w	rxb1,d2
  move.w	rys1,d3
  move.l	a6,a0
  addq.l	#$2,a0
  jsr	ball	; Print shadow.

  move.w	xr1,d0
  move.w	yr1,d1
  move.w	rxr1,d2
  move.w	ryr1,d3
  move.l	a6,a0
  addq.l	#$4,a0
  jsr	ball	; Print reflex.
  
*********

********* The same for the blue bubble.

.calculations_b:
  move.w	alpha,d0
  add.w	d0,d0	; 1 mot par sinus.
  move.w	(a4,d0.w),d1	; d1=sin(alpha).
  neg.w	d1
  add.w	#$100,d0
  move.w	(a4,d0.w),d0	; d0=cos(alpha).
  neg.w	d0
  muls.w	#dist,d0
  add.l	d0,d0
  add.l	d0,d0
  swap.w	d0	; d0=dist*-cos.
  add.w	#dist,d0	; d0=dist*-cos+dist.
  muls.w	#dist,d1
  add.l	d1,d1
  add.l	d1,d1
  swap.w	d1	; d1=dist*-sin.
  
  add.w	#$100,d0	; d0=z+256.
  ext.l	d1
  lsl.l	#$8,d1	; d1=x*256.
  divs.w	d0,d1	; d1=x*256/(256+z).
  add.w	addx,d1
  move.w	d1,xb1_b	; xb1_b=addx+(x*256/(256+z)).
   
.script_b:
  move.w	(a3)+,d1	; d1=y.
  move.w	(a3)+,d6	; d6=mulx.
  move.w	(a3)+,d7	; d7=muly.
  add.w	#$1,script_pos_b
  move.w	script_pos_b,d2
  cmp.w	script_length,d2
  bne.s	.script_ok_b
  move.l	#script,a3
  move.w	#$0,script_pos_b
.script_ok_b:

  ext.l	d1
  lsl.l	#$8,d1	; d1=y*256.
  move.w	d0,d2
  divs.w	d2,d1	; d1=y*256/(256+z).
  add.w	#addy,d1
  move.w	d1,yb1_b	; yb1=addy+(y*256/(256+z)).
    
  move.w	#rb,d1
  move.w	d1,d2
  mulu.w	d6,d1
  lsr.l	#$6,d1	; d1=rb*mulx*256.
  divs.w	d0,d1	; d1=(rb*mulx*256/(256+z)).
  move.w	d1,rxb1_b
  mulu.w	d7,d2
  lsr.l	#$6,d2	; d2=rb*muly*256.
  divs.w	d0,d2	; d1=(rb*muly*256/(256+z)).
  move.w	d2,ryb1_b
  
  move.w	#ymin,d1
  ext.l	d1
  lsl.w	#$8,d1
  divs.w	d0,d1
  add.w	#addy,d1	; d1=addy+(ymin*256/(256+z)).
  move.w	d1,ys1_b
  
  move.l	#ymin,d2
  lsl.w	#$8,d2
  move.l	d2,d3
  move.w	d0,d1
  add.w	rxb1_b,d1
  divs.w	d0,d2
  divs.w	d1,d3
  sub.w	d3,d2	; d2=ymin*256*(1/(256+z)-1/(256+z+rxb)).  
  move.w	d2,rys1_b
  
  move.w	#addr,d1
  move.w	d1,d2
  mulu.w	d6,d1
  lsr.l	#$6,d1
  divs.w	d0,d1
  add.w	xb1_b,d1
  move.w	d1,xr1_b	; xr=xb+(addr*mulx*256/(256+z)).
  mulu.w	d7,d2
  lsr.l	#$6,d2
  divs.w	d0,d2
  sub.w	yb1_b,d2
  neg.w	d2
  move.w	d2,yr1_b	; yr=yb+(addr*muly*256/(256+z)).

  move.w	#rr,d1
  move.w	d1,d2
  mulu.w	d6,d1
  lsr.l	#$6,d1	; d1=rb*mulx*256.
  divs.w	d0,d1	; d1=(rb*mulx*256/(256+z)).
  move.w	d1,rxr1_b
  mulu.w	d7,d2
  lsr.l	#$6,d2	; d2=rb*muly*256.
  divs.w	d0,d2	; d1=(rb*muly*256/(256+z)).
  move.w	d2,ryr1_b
    
.print_everything_b:
  move.w	xb1_b,d0
  move.w	yb1_b,d1
  move.w	rxb1_b,d2
  move.w	ryb1_b,d3
  move.l	a6,a0
  addq.l	#$6,a0
  jsr	ball	; Print bubble.
  
  move.w	xb1_b,d0
  move.w	ys1_b,d1
  move.w	rxb1_b,d2
  move.w	rys1_b,d3
  move.l	a6,a0
  addq.l	#$2,a0
  jsr	ball	; Print shadow.

  move.w	xr1_b,d0
  move.w	yr1_b,d1
  move.w	rxr1_b,d2
  move.w	ryr1_b,d3
  move.l	a6,a0
  addq.l	#$4,a0
  jsr	ball	; Print reflex.
  
*********


  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test2
  sub.w	#$111,$ffff8240.w
.no_test2:

  move.l	screen1_ad,d0	; Ecran de travail.
  lsr.w	#$8,d0
  move.b	d0,$ffff8203.w
  swap.w	d0
  move.b	d0,$ffff8201.w

vbl2:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  moveq.l	#$7,d0	
  move.w	#$8240,a0	; Couleurs du haut.
  move.l	#colors,a1
.put_cols:
  move.l 	(a1)+,(a0)+
  dbra	d0,.put_cols

.timer_b:
  move.b	#$0,$fffffa1b.w	; Stop the timer.
  move.b	#addy+27,$fffffa21.w ; Wait y lignes.
  move.b	#$8,$fffffa1b.w	; Event count mode.

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test
  add.w	#$111,$ffff8240.w
.no_test:

  move.l	screen2_ad,a6


.clear_everything:
  move.w	xb2,d0
  move.w	yb2,d1
  move.w	rxb2,d2
  move.w	ryb2,d3
  move.l	a6,a0
  jsr	cls_ball	; Clear bubble.
  
  move.w	xb2,d0
  move.w	ys2,d1
  move.w	rxb2,d2
  move.w	rys2,d3
  move.l	a6,a0
  addq.l	#$2,a0
  jsr	cls_ball	; Clear shadow.

  move.w	xr2,d0
  move.w	yr2,d1
  move.w	rxr2,d2
  move.w	ryr2,d3
  move.l	a6,a0
  addq.l	#$4,a0
  jsr	cls_ball	; Clear reflex.

.clear_everything_b:
  move.w	xb2_b,d0
  move.w	yb2_b,d1
  move.w	rxb2_b,d2
  move.w	ryb2_b,d3
  move.l	a6,a0
  addq.l	#$6,a0
  jsr	cls_ball	; Clear blue bubble.
  
  move.w	xb2_b,d0
  move.w	ys2_b,d1
  move.w	rxb2_b,d2
  move.w	rys2_b,d3
  move.l	a6,a0
  addq.l	#$2,a0
  jsr	cls_ball	; Clear shadow.

  move.w	xr2_b,d0
  move.w	yr2_b,d1
  move.w	rxr2_b,d2
  move.w	ryr2_b,d3
  move.l	a6,a0
  addq.l	#$4,a0
  jsr	cls_ball	; Clear reflex.


********* Calculations and all the rest.
  
.calculations:
  move.w	alpha,d0
  addq.w	#$2,d0	; Tournez maneges.
  cmp.w	#$200,d0	; Un tour complet?
  bne.s	.angle_ok
  moveq.l	#$0,d0
.angle_ok:
  move.w	d0,alpha
  add.w	d0,d0	; 1 mot par sinus.
  move.w	(a4,d0.w),d1	; d1=sin(alpha).
  add.w	#$100,d0
  move.w	(a4,d0.w),d0	; d0=cos(alpha).
  muls.w	#dist,d0
  add.l	d0,d0
  add.l	d0,d0
  swap.w	d0	; d0=dist*cos.
  add.w	#dist,d0	; d0=dist*cos+dist.
  muls.w	#dist,d1
  add.l	d1,d1
  add.l	d1,d1
  swap.w	d1	; d1=dist*sin.
  
  add.w	#$100,d0	; d0=z+256.
  ext.l	d1
  lsl.l	#$8,d1	; d1=x*256.
  divs.w	d0,d1	; d1=x*256/(256+z).
  add.w	addx,d1
  move.w	d1,xb2	; xb2=addx+(x*256/(256+z)).
   
.script:
  move.w	(a5)+,d1	; d1=y.
  move.w	(a5)+,d6	; d6=mulx.
  move.w	(a5)+,d7	; d7=muly.
  add.w	#$1,script_pos
  move.w	script_pos,d2
  cmp.w	script_length,d2
  bne.s	.script_ok
  move.l	#script,a5
  move.w	#$0,script_pos
.script_ok:

  ext.l	d1
  lsl.l	#$8,d1	; d1=y*256.
  move.w	d0,d2
  divs.w	d2,d1	; d1=y*256/(256+z).
  add.w	#addy,d1
  move.w	d1,yb2	; yb2=addy+(y*256/(256+z)).
    
  move.w	#rb,d1
  move.w	d1,d2
  mulu.w	d6,d1
  lsr.l	#$6,d1	; d1=rb*mulx*256.
  divs.w	d0,d1	; d1=(rb*mulx*256/(256+z)).
  move.w	d1,rxb2
  mulu.w	d7,d2
  lsr.l	#$6,d2	; d2=rb*muly*256.
  divs.w	d0,d2	; d1=(rb*muly*256/(256+z)).
  move.w	d2,ryb2
  
  move.w	#ymin,d1
  ext.l	d1
  lsl.w	#$8,d1
  divs.w	d0,d1
  add.w	#addy,d1	; d1=addy+(ymin*256/(256+z)).
  move.w	d1,ys2
  
  move.l	#ymin,d2
  lsl.w	#$8,d2
  move.l	d2,d3
  move.w	d0,d1
  add.w	rxb1,d1
  divs.w	d0,d2
  divs.w	d1,d3
  sub.w	d3,d2	; d2=ymin*256*(1/(256+z)-1/(256+z+rxb)).  
  move.w	d2,rys2
  
  move.w	#addr,d1
  move.w	d1,d2
  mulu.w	d6,d1
  lsr.l	#$6,d1
  divs.w	d0,d1
  add.w	xb2,d1
  move.w	d1,xr2	; xr=xb+(addr*mulx*256/(256+z)).
  mulu.w	d7,d2
  lsr.l	#$6,d2
  divs.w	d0,d2
  sub.w	yb2,d2
  neg.w	d2
  move.w	d2,yr2	; yr=yb+(addr*muly*256/(256+z)).

  move.w	#rr,d1
  move.w	d1,d2
  mulu.w	d6,d1
  lsr.l	#$6,d1	; d1=rb*mulx*256.
  divs.w	d0,d1	; d1=(rb*mulx*256/(256+z)).
  move.w	d1,rxr2
  mulu.w	d7,d2
  lsr.l	#$6,d2	; d2=rb*muly*256.
  divs.w	d0,d2	; d1=(rb*muly*256/(256+z)).
  move.w	d2,ryr2
    
.print_everything:
  move.w	xb2,d0
  move.w	yb2,d1
  move.w	rxb2,d2
  move.w	ryb2,d3
  move.l	a6,a0
  jsr	ball	; Print bubble.
  
  move.w	xb2,d0
  move.w	ys2,d1
  move.w	rxb2,d2
  move.w	rys2,d3
  move.l	a6,a0
  addq.l	#$2,a0
  jsr	ball	; Print shadow.

  move.w	xr2,d0
  move.w	yr2,d1
  move.w	rxr2,d2
  move.w	ryr2,d3
  move.l	a6,a0
  addq.l	#$4,a0
  jsr	ball	; Print reflex.
  
*********

********* The same for the blue bubble.

.calculations_b:
  move.w	alpha,d0
  add.w	d0,d0	; 1 mot par sinus.
  move.w	(a4,d0.w),d1	; d1=sin(alpha).
  neg.w	d1
  add.w	#$100,d0
  move.w	(a4,d0.w),d0	; d0=cos(alpha).
  neg.w	d0
  muls.w	#dist,d0
  add.l	d0,d0
  add.l	d0,d0
  swap.w	d0	; d0=dist*-cos.
  add.w	#dist,d0	; d0=dist*-cos+dist.
  muls.w	#dist,d1
  add.l	d1,d1
  add.l	d1,d1
  swap.w	d1	; d1=dist*-sin.

  add.w	#$100,d0	; d0=z+256.
  ext.l	d1
  lsl.l	#$8,d1	; d1=x*256.
  divs.w	d0,d1	; d1=x*256/(256+z).
  add.w	addx,d1
  move.w	d1,xb2_b	; xb1_b=addx+(x*256/(256+z)).
   
.script_b:
  move.w	(a3)+,d1	; d1=y.
  move.w	(a3)+,d6	; d6=mulx.
  move.w	(a3)+,d7	; d7=muly.
  add.w	#$1,script_pos_b
  move.w	script_pos_b,d2
  cmp.w	script_length,d2
  bne.s	.script_ok_b
  move.l	#script,a3
  move.w	#$0,script_pos_b
.script_ok_b:

  ext.l	d1
  lsl.l	#$8,d1	; d1=y*256.
  move.w	d0,d2
  divs.w	d2,d1	; d1=y*256/(256+z).
  add.w	#addy,d1
  move.w	d1,yb2_b	; yb1=addy+(y*256/(256+z)).
    
  move.w	#rb,d1
  move.w	d1,d2
  mulu.w	d6,d1
  lsr.l	#$6,d1	; d1=rb*mulx*256.
  divs.w	d0,d1	; d1=(rb*mulx*256/(256+z)).
  move.w	d1,rxb2_b
  mulu.w	d7,d2
  lsr.l	#$6,d2	; d2=rb*muly*256.
  divs.w	d0,d2	; d1=(rb*muly*256/(256+z)).
  move.w	d2,ryb2_b
  
  move.w	#ymin,d1
  ext.l	d1
  lsl.w	#$8,d1
  divs.w	d0,d1
  add.w	#addy,d1	; d1=addy+(ymin*256/(256+z)).
  move.w	d1,ys2_b
  
  move.l	#ymin,d2
  lsl.w	#$8,d2
  move.l	d2,d3
  move.w	d0,d1
  add.w	rxb2_b,d1
  divs.w	d0,d2
  divs.w	d1,d3
  sub.w	d3,d2	; d2=ymin*256*(1/(256+z)-1/(256+z+rxb)).  
  move.w	d2,rys2_b
  
  move.w	#addr,d1
  move.w	d1,d2
  mulu.w	d6,d1
  lsr.l	#$6,d1
  divs.w	d0,d1
  add.w	xb2_b,d1
  move.w	d1,xr2_b	; xr=xb+(addr*mulx*256/(256+z)).
  mulu.w	d7,d2
  lsr.l	#$6,d2
  divs.w	d0,d2
  sub.w	yb2_b,d2
  neg.w	d2
  move.w	d2,yr2_b	; yr=yb+(addr*muly*256/(256+z)).

  move.w	#rr,d1
  move.w	d1,d2
  mulu.w	d6,d1
  lsr.l	#$6,d1	; d1=rb*mulx*256.
  divs.w	d0,d1	; d1=(rb*mulx*256/(256+z)).
  move.w	d1,rxr2_b
  mulu.w	d7,d2
  lsr.l	#$6,d2	; d2=rb*muly*256.
  divs.w	d0,d2	; d1=(rb*muly*256/(256+z)).
  move.w	d2,ryr2_b
    
.print_everything_b:
  move.w	xb2_b,d0
  move.w	yb2_b,d1
  move.w	rxb2_b,d2
  move.w	ryb2_b,d3
  move.l	a6,a0
  addq.l	#$6,a0
  jsr	ball	; Print bubble.
  
  move.w	xb2_b,d0
  move.w	ys2_b,d1
  move.w	rxb2_b,d2
  move.w	rys2_b,d3
  move.l	a6,a0
  addq.l	#$2,a0
  jsr	ball	; Print shadow.

  move.w	xr2_b,d0
  move.w	yr2_b,d1
  move.w	rxr2_b,d2
  move.w	ryr2_b,d3
  move.l	a6,a0
  addq.l	#$4,a0
  jsr	ball	; Print reflex.
  
*********

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test2
  sub.w	#$111,$ffff8240.w
.no_test2:

  move.l	screen2_ad,d0	; Ecran de travail.
  lsr.w	#$8,d0
  move.b	d0,$ffff8203.w
  swap.w	d0
  move.b	d0,$ffff8201.w

  move.w	addx,d0
  add.w	incx,d0
  move.w	d0,addx
  cmp.w	#416,addx
  bne.s	.not_incx
  
  neg.w	incx

.not_incx:
  cmp.w	#-98,addx
  beq.s	sortie
    
  cmpi.b	#$39,$fffffc02.w
  beq.s	sortie
    
  bra	vbl1

;**************************************************************************
sortie:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp
  move.w	old_res,$ffff8260.w
  move.b	old_sync,$ffff820a.w
  move.l	old_screen,d0
  swap.w	d0
  move.b	d0,$ffff8201.w	; Le pire c' est qu'il faut mettre
  swap.w	d0	; $ff820d en dernier.
  rol.w	#$8,d0	
  move.b	d0,$ffff8203.w
  rol.w	#$8,d0	
  move.b	d0,$ffff820d.w
  move.l	#$7,d0	
  move.w	#$8240,a0	; Mettre les couleurs a $334.
  move.l	#old_colors,a1
.restore_cols:
  move.l 	(a1)+,(a0)+
  dbra	d0,.restore_cols

  bset.b	#$0,$484.w
  move.b	#$8,$fffffc02.w
  dc.w	$a009	; Le tank est de retour!
  
  clr.w	-(sp)
  trap	#$1

;**************************************************************************
timer_b:
  move.b	#$0,$fffffa1b.w	; Stop the timer.
  move.l	a0,-(sp)
  move.l	a1,-(sp)
  move.w	#$8240,a0	; Couleurs du bas.
  move.l	#low_colors,a1
  move.l 	(a1)+,(a0)+
  move.l 	(a1)+,(a0)+
  move.l 	(a1)+,(a0)+
  move.l 	(a1)+,(a0)+
  move.l 	(a1)+,(a0)+
  move.l 	(a1)+,(a0)+
  move.l 	(a1)+,(a0)+
  move.l 	(a1)+,(a0)+
  move.l	(sp)+,a1
  move.l	(sp)+,a0
  bclr.b	#$0,$fffffa0f.w	; Interruption finie.
  rte
  
;**************************************************************************
ball:
  include	'a:\ball\ball.s'
  Section TEXT
cls_ball:
  include	'a:\ball\cls_ball.s'
  Section TEXT
  
;**************************************************************************
  Section DATA
  
colors:
  dc.w	$0aa,$e0b,$000,$000
  dc.w	$000,$f8c,$000,$000
  dc.w	$b0e,$606,$000,$000
  dc.w	$c8f,$707,$000,$000

low_colors:
  dc.w	$022,$603,$099,$d0a
  dc.w	$000,$f8c,$000,$000
  dc.w	$306,$d0d,$a0d,$dad
  dc.w	$c8f,$707,$000,$000

sin_cos:
  incbin	'a:\ball\sin_cos.xxx'
  
script_length:		; Taille du script.
  dc.w	80
script:		; Le script: y,mulx,muly.
  incbin	'a:\bubble\bubble.xxx'

script_pos:
  dc.w	0

script_pos_b:
  dc.w	40
    
    
;**************************************************************************
  Section BSS

buffer:
  ds.w	16

alpha:
  ds.w	1

xb1:		; Toutes le coords calculees 
  ds.w	1	; lors de la vbl1.
yb1:
  ds.w	1
rxb1:
  ds.w	1
ryb1:
  ds.w	1
ys1:
  ds.w	1
rys1:
  ds.w	1
xr1:
  ds.w	1
yr1:
  ds.w	1
rxr1:
  ds.w	1
ryr1:
  ds.w	1

xb1_b:		; Pour la bubble bleue.
  ds.w	1
yb1_b:
  ds.w	1
rxb1_b:
  ds.w	1
ryb1_b:
  ds.w	1
ys1_b:
  ds.w	1
rys1_b:
  ds.w	1
xr1_b:
  ds.w	1
yr1_b:
  ds.w	1
rxr1_b:
  ds.w	1
ryr1_b:
  ds.w	1

xb2:		; Toutes le coords calculees 
  ds.w	1	; lors de la vbl2.
yb2:
  ds.w	1
rxb2:
  ds.w	1
ryb2:
  ds.w	1
ys2:
  ds.w	1
rys2:
  ds.w	1
xr2:
  ds.w	1
yr2:
  ds.w	1
rxr2:
  ds.w	1
ryr2:
  ds.w	1

xb2_b:		; Pour la bubble bleue.
  ds.w	1
yb2_b:
  ds.w	1
rxb2_b:
  ds.w	1
ryb2_b:
  ds.w	1
ys2_b:
  ds.w	1
rys2_b:
  ds.w	1
xr2_b:
  ds.w	1
yr2_b:
  ds.w	1
rxr2_b:
  ds.w	1
ryr2_b:
  ds.w	1
 
addx:
  ds.w	1
incx:
  ds.w	1
    
old_res:
  ds.w	1
old_sync:
  ds.w	1
old_screen:
  ds.l	1
old_colors:
  ds.l	8

screen1_ad:
  ds.l	1
screen2_ad:
  ds.l	1
screens:
  ds.l	16064
  