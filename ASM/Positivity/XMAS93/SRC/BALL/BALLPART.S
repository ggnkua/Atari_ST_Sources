;**************************************************************************
;**	           Le programme principal!	         **
;**************************************************************************

incx	equ	1
incy	equ	2
incz	equ	4
inc_add_y	equ	1
fin_add_y	equ	350
add_x	equ	159
cls_add	equ	21
norm_add	equ	20

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

vbl1:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test
  add.w	#$111,$ffff8240.w
.no_test:

  move.l	screen1_ad,a6

.cls_balls:
  move.l	#new_coords1,a1
  move.l	a6,a0
  move.w	(a1)+,d0
  add.w	#add_x,d0
  move.w	(a1)+,d1
  add.w	add_y,d1
  move.w	$e(a1),d2
  add.w	#cls_add,d2
  move.w	d2,d3
  jsr	cls_ball
  
  addq.l	#$2,a0
  addq.l	#$2,a1
  move.w	(a1)+,d0
  add.w	#add_x,d0
  move.w	(a1)+,d1
  add.w	add_y,d1
  move.w	$a(a1),d2
  add.w	#cls_add,d2
  move.w	d2,d3
  jsr	cls_ball

  addq.l	#$2,a0
  addq.l	#$2,a1
  move.w	(a1)+,d0
  add.w	#add_x,d0
  move.w	(a1)+,d1
  add.w	add_y,d1
  move.w	$6(a1),d2
  add.w	#cls_add,d2
  move.w	d2,d3
  jsr	cls_ball

.new_parameters:
  add.w	#inc_add_y,add_y
  add.w	#incx,ang_x
  cmp.w	#$1ff,ang_x
  ble.s	.not_ang_x
  sub.w	#$1ff,ang_x
.not_ang_x:
  add.w	#incy,ang_y
  cmp.w	#$1ff,ang_y
  ble.s	.not_ang_y
  sub.w	#$1ff,ang_y
.not_ang_y:
  add.w	#incz,ang_z
  cmp.w	#$1ff,ang_z
  ble.s	.calculations
  sub.w	#$1ff,ang_z
    	
.calculations:
  move.l	#coords,a0
  move.l	#new_coords1,a1
  move.w	ang_z,d0
  move.w	ang_y,d1
  move.w	ang_x,d2
  jsr	rotations

.print_balls:
  move.l	#new_coords1,a1
  move.l	a6,a0
  move.w	(a1)+,d0
  add.w	#add_x,d0
  move.w	(a1)+,d1
  add.w	add_y,d1
  move.w	$e(a1),d2
  add.w	#norm_add,d2
  move.w	d2,d3
  jsr	ball
  
  addq.l	#$2,a0
  addq.l	#$2,a1
  move.w	(a1)+,d0
  add.w	#add_x,d0
  move.w	(a1)+,d1
  add.w	add_y,d1
  move.w	$a(a1),d2
  add.w	#norm_add,d2
  move.w	d2,d3
  jsr	ball

  addq.l	#$2,a0
  addq.l	#$2,a1
  move.w	(a1)+,d0
  add.w	#add_x,d0
  move.w	(a1)+,d1
  add.w	add_y,d1
  move.w	$6(a1),d2
  add.w	#norm_add,d2
  move.w	d2,d3
  jsr	ball
  
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

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test
  add.w	#$111,$ffff8240.w
.no_test:

  move.l	screen2_ad,a6

.cls_balls:
  move.l	#new_coords2,a1
  move.l	a6,a0
  move.w	(a1)+,d0
  add.w	#add_x,d0
  move.w	(a1)+,d1
  add.w	add_y,d1
  move.w	$e(a1),d2
  add.w	#cls_add,d2
  move.w	d2,d3
  jsr	cls_ball
  
  addq.l	#$2,a0
  addq.l	#$2,a1
  move.w	(a1)+,d0
  add.w	#add_x,d0
  move.w	(a1)+,d1
  add.w	add_y,d1
  move.w	$a(a1),d2
  add.w	#cls_add,d2
  move.w	d2,d3
  jsr	cls_ball

  addq.l	#$2,a0
  addq.l	#$2,a1
  move.w	(a1)+,d0
  add.w	#add_x,d0
  move.w	(a1)+,d1
  add.w	add_y,d1
  move.w	$6(a1),d2
  add.w	#cls_add,d2
  move.w	d2,d3
  jsr	cls_ball

.new_parameters:
  add.w	#inc_add_y,add_y
  add.w	#incx,ang_x
  cmp.w	#$1ff,ang_x
  ble.s	.not_ang_x
  sub.w	#$1ff,ang_x
.not_ang_x:
  add.w	#incy,ang_y
  cmp.w	#$1ff,ang_y
  ble.s	.not_ang_y
  sub.w	#$1ff,ang_y
.not_ang_y:
  add.w	#incz,ang_z
  cmp.w	#$1ff,ang_z
  ble.s	.calculations
  sub.w	#$1ff,ang_z
    	
.calculations:
  move.l	#coords,a0
  move.l	#new_coords2,a1
  move.w	ang_z,d0
  move.w	ang_y,d1
  move.w	ang_x,d2
  jsr	rotations

.print_balls:
  move.l	#new_coords2,a1
  move.l	a6,a0
  move.w	(a1)+,d0
  add.w	#add_x,d0
  move.w	(a1)+,d1
  add.w	add_y,d1
  move.w	$e(a1),d2
  add.w	#norm_add,d2
  move.w	d2,d3
  jsr	ball
  
  addq.l	#$2,a0
  addq.l	#$2,a1
  move.w	(a1)+,d0
  add.w	#add_x,d0
  move.w	(a1)+,d1
  add.w	add_y,d1
  move.w	$a(a1),d2
  add.w	#norm_add,d2
  move.w	d2,d3
  jsr	ball

  addq.l	#$2,a0
  addq.l	#$2,a1
  move.w	(a1)+,d0
  add.w	#add_x,d0
  move.w	(a1)+,d1
  add.w	add_y,d1
  move.w	$6(a1),d2
  add.w	#norm_add,d2
  move.w	d2,d3
  jsr	ball

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test2
  sub.w	#$111,$ffff8240.w
.no_test2:

  move.l	screen2_ad,d0	; Ecran de travail.
  lsr.w	#$8,d0
  move.b	d0,$ffff8203.w
  swap.w	d0
  move.b	d0,$ffff8201.w
  
  cmpi.b	#$39,$fffffc02.w
  beq.s	sortie
  cmp.w	#fin_add_y,add_y
  ble	vbl1
  
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
ball:
  include	'a:\ball\ball.s'
  Section TEXT
cls_ball:
  include	'a:\ball\cls_ball.s'
  Section TEXT
rotations:
  include	'a:\ball\rot_3b.s'
  Section TEXT
  
;**************************************************************************
  Section DATA
  
colors:
  dc.w	$0aa,$5aa,$0ea,$57a
  dc.w	$03c,$5ad,$0ee,$cee
  dc.w	$000,$000,$000,$000
  dc.w	$000,$000,$000,$000

coords:
  dc.w	0,80,0
  dc.w	69,-40,0
  dc.w	-69,-40,0

add_y:
  dc.w	$ff50
ang_x:
  dc.w	0
ang_y:
  dc.w	0
ang_z:
  dc.w	0
    
;**************************************************************************
  Section BSS

buffer:
  ds.w	16
old_res:
  ds.w	1
old_sync:
  ds.w	1
old_screen:
  ds.l	1
old_colors:
  ds.l	8

new_coords1:
  ds.w	12
new_coords2:
  ds.w	12
  
screen1_ad:
  ds.l	1
screen2_ad:
  ds.l	1
screens:
  ds.l	16064
  