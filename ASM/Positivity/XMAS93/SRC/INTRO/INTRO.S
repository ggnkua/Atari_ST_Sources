;**************************************************************************
;**	           Le programme principal!	         **
;**************************************************************************

path_length	equ	1500
box_size	equ	101
sub_y	equ	200
col1	equ	$caa
col2	equ	$3aa
col3	equ	$2aa
col4	equ	$3aa
col5	equ	$2aa
col6	equ	$9aa

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
  
;**************************************************************************
print_the_note:
  move.w	#$7,d0
  move.l	#positif_cols,a0
  move.w	#$8240,a1
.put_cols:
  move.l 	(a0)+,(a1)+
  dbra	d0,.put_cols


  move.l	screen2_ad,a0
  jsr	cls
  add.l	#11728,a0
  move.l	#note,a1
  move.w	#52,d0	; 53 lignes.
.one_line:
  rept	8
  move.w	(a1),(a0)+
  move.w	(a1),(a0)+
  move.w	(a1),(a0)+
  move.w	(a1)+,(a0)+
  endr
  add.l	#96,a0
  dbra	d0,.one_line

  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  
  move.w	#500,d7
.one_vbl:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  cmpi.b	#$39,$fffffc02.w
  beq.s	positivity
  dbra	d7,.one_vbl
  
;**************************************************************************
positivity:
  move.l	screen2_ad,a0
  jsr	cls

  move.l	screen2_ad,a0
  jsr	cls
  add.l	#12680,a0
  move.l	#positif,a1
  move.w	#40,d0	; 41 lignes.
.one_line:
  rept	40
  move.w	(a1)+,(a0)+
  endr
  add.l	#80,a0
  dbra	d0,.one_line

  move.w	#500,d7
.one_vbl:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  cmpi.b	#$39,$fffffc02.w
  beq.s	prepare_screens
  dbra	d7,.one_vbl
  
    
;**************************************************************************

prepare_screens:
  move.l	screen2_ad,a0
  jsr	cls
  move.l	screen1_ad,a0
  jsr	cls
  add.w	#$1e06,a0
  move.l	screen2_ad,a1
  add.w	#$1e06,a1
  move.l	#logo,a2
  move.w	#$7cf,d0
.copy:
  move.w	(a2),(a0)
  move.w	(a2)+,(a1)
  addq.l	#$8,a0
  addq.l	#$8,a1
  dbra	d0,.copy

change_path:
  move.l	#path,a0
  move.w	#path_length-1,d0
.one_word:
  move.w	(a0),d1	; Connerie de PC!...
  rol.w	#$8,d1
  move.w	d1,(a0)+
  move.w	(a0),d1
  rol.w	#$8,d1
  move.w	d1,(a0)+
  dbra	d0,.one_word  
  
;**************************************************************************

  move.l	#path,a5	; a5 pointe sur le path.
  
vbl1:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  move.l	screen2_ad,d0	; Ecran de travail.

  move.l	d0,d1
  move.l	d1,d2
  lsr.w	#$8,d1
  swap.w	d0
  move.b	d0,$ffff8201.w	; Put the adress.
  move.b	d1,$ffff8203.w
  move.b	d2,$ffff820d.w
  move.b	d0,$ffff8205.w	; Put the adress.
  move.b	d1,$ffff8207.w
  move.b	d2,$ffff8209.w

  move.l	screen1_ad,a6

  move.w	bitplane,d7	; d7 indique sur quel biplan on est.
  add.w	#$1,d7
  cmp.w	#$3,d7
  beq.s	.bitplane_0	; Bitplan 0?
  cmp.w	#$1,d7
  beq	.bitplane_1

.bitplane_2:
  move.w	d7,bitplane
  move.w	-$16(a5),d1	; Effacer bitplan 1 entierement.
  sub.w	#sub_y,d1
  move.w	-$18(a5),d0
  move.w  	#box_size,d2
  addq.l	#$2,a6
  move.l	a6,a0
  jsr	cls_box
  bra	.calculations

.bitplane_0:
  moveq.l	#$0,d7
  move.w	d7,bitplane
  move.w	-$16(a5),d1	; Effacer bitplan 0 entierement.
  sub.w	#sub_y,d1
  move.w	-$18(a5),d0
  move.w  	#box_size,d2
  move.l	a6,a0
  jsr	cls_box
  bra	.calculations

.bitplane_1:
  move.w	d7,bitplane
  move.w	-$16(a5),d1	; Effacer bitplan 2 entierement.
  sub.w	#sub_y,d1
  move.w	-$18(a5),d0
  move.w  	#box_size,d2
  addq.l	#$4,a6	; Pour l' affichage.
  move.l	a6,a0
  jsr	cls_box

.calculations:

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test
  add.w	#$111,$ffff8240.w
.no_test:

  move.w	alpha,d0
  addq.w	#$4,d0	; Incrementer l' angle.
  cmp.w	#$200,d0	; alpha=512?
  bne	.alpha_ok
  moveq.l	#$0,d0	; Alors c' est equivalent a 0.
.alpha_ok:
  move.w	d0,alpha
  move.l	#sin_cos,a0
  add.w	d0,d0	; 1 sinus=1 mot.
  move.w	(a0,d0.w),d1	; d1=sin(alpha).
  add.w	#$100,a0
  move.w	(a0,d0.w),d0	; d0=cos(alpha).

  move.w	(a5)+,d6	; d6=incx.
  move.w	(a5)+,d7	; d7=incy.
  sub.w	#sub_y,d7
  
  move.l	#coords,a0
  move.l	#new_coords,a1

  rept	6
  
  move.w	(a0)+,d2	; d2=x.
  move.w	(a0)+,d3	; d3=y.
  move.w	d2,d4
  move.w	d3,d5
  muls.w	d0,d2	; d2=x*cos.
  add.l	d2,d2
  add.l	d2,d2
  swap.w	d2
  muls.w	d1,d4	; d4=x*sin.
  add.l	d4,d4
  add.l	d4,d4
  swap.w	d4
  muls.w	d0,d3	; d3=y*cos.
  add.l	d3,d3
  add.l	d3,d3
  swap.w	d3
  muls.w	d1,d5	; d5=y*sin.
  add.l	d5,d5
  add.l	d5,d5
  swap.w	d5
  sub.w	d5,d2	; d2=x*cos-y*sin.
  add.w	d4,d3	; d3=x*sin+y*cos.
  add.w	d6,d2	; d2=d2+incx.
  add.w	d7,d3	; d3=d3+incy.
  move.w	d2,(a1)+
  move.w	d3,(a1)+
  
  endr

  move.l	a6,a0	
  move.l	#new_coords,a1
  moveq.l	#$3,d0
  jsr	polygone	; Affichage du premier triangle.

  move.l	a6,a0
  move.l	#new_coords+12,a1
  moveq.l	#$3,d0	; Affichage du second triangle.
  jsr	polygone
  
  add.w	#$1,path_pos
  
  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test2
  sub.w	#$111,$ffff8240.w
.no_test2:

vbl2:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  move.l	screen1_ad,d0	; Ecran de travail.

  move.l	d0,d1
  move.l	d1,d2
  lsr.w	#$8,d1
  swap.w	d0
  move.b	d0,$ffff8201.w	; Put the adress.
  move.b	d1,$ffff8203.w
  move.b	d2,$ffff820d.w
  move.b	d0,$ffff8205.w	; Put the adress.
  move.b	d1,$ffff8207.w
  move.b	d2,$ffff8209.w

  move.l	screen2_ad,a6

  move.w	bitplane,d7	; d7 indique sur quel biplan on est.
  cmp.w	#$0,d7
  beq.s	.bitplane_0	; Bitplan 0?
  cmp.w	#$1,d7
  beq	.bitplane_1

.bitplane_2:
  move.l	#colors2,a0
  move.w	#$8240,a1
  rept	8
  move.l	(a0)+,(a1)+	; Couleurs pour ce bitplan.
  endr
  move.w	-$16(a5),d1	; Effacer bitplan 1 entierement.
  sub.w	#sub_y,d1
  move.w	-$18(a5),d0
  move.w  	#box_size,d2
  addq.l	#$2,a6	; Pour l' affichage.
  move.l	a6,a0
  jsr	cls_box
  bra	.calculations

.bitplane_0:
  move.l	#colors0,a0
  move.w	#$8240,a1
  rept	8
  move.l	(a0)+,(a1)+	; Couleurs pour ce bitplan.
  endr
  move.w	-$16(a5),d1	; Effacer bitplan 0 entierement.
  sub.w	#sub_y,d1
  move.w	-$18(a5),d0
  move.w  	#box_size,d2
  move.l	a6,a0
  jsr	cls_box
  bra	.calculations

.bitplane_1:
  move.l	#colors1,a0
  move.w	#$8240,a1
  rept	8
  move.l	(a0)+,(a1)+	; Couleurs pour ce bitplan.
  endr
  move.w	-$16(a5),d1	; Effacer bitplan 2 entierement.
  sub.w	#sub_y,d1
  move.w	-$18(a5),d0
  move.w  	#box_size,d2
  addq.l	#$4,a6	; Pour l' affichage.
  move.l	a6,a0
  jsr	cls_box

.calculations:

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test
  add.w	#$111,$ffff8240.w
.no_test:

  move.w	alpha,d0
  addq.w	#$4,d0	; Incrementer l' angle.
  cmp.w	#$200,d0	; alpha=512?
  bne	.alpha_ok
  moveq.l	#$0,d0	; Alors c' est equivalent a 0.
.alpha_ok:
  move.w	d0,alpha
  move.l	#sin_cos,a0
  add.w	d0,d0	; 1 sinus=1 mot.
  move.w	(a0,d0.w),d1	; d1=sin(alpha).
  add.w	#$100,a0
  move.w	(a0,d0.w),d0	; d0=cos(alpha).

  move.w	(a5)+,d6	; d6=incx.
  move.w	(a5)+,d7	; d7=incy.
  sub.w	#sub_y,d7
  
  move.l	#coords,a0
  move.l	#new_coords,a1

  rept	6
  
  move.w	(a0)+,d2	; d2=x.
  move.w	(a0)+,d3	; d3=y.
  move.w	d2,d4
  move.w	d3,d5
  muls.w	d0,d2	; d2=x*cos.
  add.l	d2,d2
  add.l	d2,d2
  swap.w	d2
  muls.w	d1,d4	; d4=x*sin.
  add.l	d4,d4
  add.l	d4,d4
  swap.w	d4
  muls.w	d0,d3	; d3=y*cos.
  add.l	d3,d3
  add.l	d3,d3
  swap.w	d3
  muls.w	d1,d5	; d5=y*sin.
  add.l	d5,d5
  add.l	d5,d5
  swap.w	d5
  sub.w	d5,d2	; d2=x*cos-y*sin.
  add.w	d4,d3	; d3=x*sin+y*cos.
  add.w	d6,d2	; d2=d2+incx.
  add.w	d7,d3	; d3=d3+incy.
  move.w	d2,(a1)+
  move.w	d3,(a1)+
  
  endr

  move.l	a6,a0	
  move.l	#new_coords,a1
  moveq.l	#$3,d0
  jsr	polygone	; Affichage du premier triangle.

  move.l	a6,a0
  move.l	#new_coords+12,a1
  moveq.l	#$3,d0	; Affichage du second triangle.
  jsr	polygone
  
  add.w	#$1,path_pos
  
  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test2
  sub.w	#$111,$ffff8240.w
.no_test2:

  cmpi.b	#$39,$fffffc02.w
  beq.s	sortie
  cmp.w	#path_length,path_pos
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

polygone:
  include	'a:\polygone\poly_ste.s'
  Section TEXT

cls_box:
  include	'a:\intro\cls_box.s'
  Section TEXT

cls:
  movem.l	d0-d1/a0,-(sp)
  move.w	#7999,d0
  moveq.l	#$0,d1
.cls_one:
  move.l	d1,(a0)+
  dbra	d0,.cls_one
  movem.l	(sp)+,d0-d1/a0
  rts
    
;**************************************************************************
  Section DATA

positif_cols:
  dc.w	$0aa,$aaa,$5aa,$faa
  dc.w	$000,$000,$000,$f44
  dc.w	$000,$000,$000,$7dd
  dc.w	$000,$000,$000,$777
  
bitplane:
  dc.w	0
  
colors0:
  dc.w	$0aa,col1,col2,col1
  dc.w	col3,col1,col2,col1
  dc.w	$022,col4,col5,col4
  dc.w	col6,col4,col5,col4

colors1:
  dc.w	$0aa,col2,col3,col2
  dc.w	col1,col1,col1,col1
  dc.w	$022,col5,col6,col5
  dc.w	col4,col4,col4,col4

colors2:
  dc.w	$0aa,col3,col1,col1
  dc.w	col2,col2,col1,col1
  dc.w	$022,col6,col4,col4
  dc.w	col5,col5,col4,col4

coords:
  dc.w	0,-100
  dc.w	-86,50
  dc.w	86,50
  dc.w	0,100
  dc.w	86,-50
  dc.w	-86,-50

alpha:
  dc.w	0

path_pos:
  dc.w	0
    
path:
  incbin	'a:\intro\path.xxx'

logo:
  incbin	'a:\intro\logo.xxx'
        
sin_cos:
  incbin	'a:\intro\sin_cos.xxx'

note:
  incbin	'a:\intro\note.xxx'
  
positif:
  incbin	'a:\intro\positif.xxx'

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

new_coords:
  ds.w	12

screen1_ad:
  ds.l	1
screen2_ad:
  ds.l	1
screens:
  ds.l	16064
  