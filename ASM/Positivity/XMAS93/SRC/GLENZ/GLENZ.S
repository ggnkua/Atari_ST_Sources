;**************************************************************************
;**	           Le programme principal!	         **
;**************************************************************************

size	equ	70

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

  move.l	#$7,d0	; Nouvelles couleurs.
  move.l	#colors,a0
  move.w	#$8240,a1
.new_cols:
  move.l 	(a0)+,(a1)+
  dbra	d0,.new_cols

;**************************************************************************

vbl1:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  move.l	screen1_ad,a6

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test
  add.w	#$111,$ffff8240.w
.no_test:

;*************************

  move.w	ang_y,d0
  add.w	#$4,d0
  cmpi.w	#$200,d0
  bne.s	.ang_y_ok
  moveq.l	#$0,d0
.ang_y_ok:
  move.w	d0,ang_y
  move.w	ang_z,d0
  add.w	#$1,d0
  cmpi.w	#$200,d0
  bne.s	.ang_z_ok
  moveq.l	#$0,d0
.ang_z_ok:
  move.w	d0,ang_z

.search_old_box:
  move.l	#new_coords1,a0
  move.w	(a0)+,d0
  move.w	(a0)+,d1
  move.w	d0,d2
  move.w	d1,d3
  move.w	nb_brows,d4
.search_one:
  move.w	(a0)+,d5	; x courant.
  move.w	(a0)+,d6	; y courant.
  cmp.w	d5,d0
  ble.s	.not_xmin
  move.w	d5,d0	; Nouvel xmin.
.not_xmin:
  cmp.w	d5,d2
  bge.s	.not_xmax
  move.w	d5,d2	; Nouvel xmax.
.not_xmax:
  cmp.w	d6,d1
  ble.s	.not_ymin
  move.w	d6,d1	; Nouvel ymin.
.not_ymin:
  cmp.w	d6,d3
  bge.s	.not_ymax
  move.w	d6,d3	; Nouvel ymax.
.not_ymax:
  subq.w	#$1,d4
  cmp.w	#$1,d4
  bne.s	.search_one
  
  move.l	a6,a0	; Effacer la boite qui entoure l'objet
  jsr	cls_box	; et ce sur 3 bitplans.
  addq.l	#$2,a0
  jsr	cls_box
  addq.l	#$2,a0
  jsr	cls_box

.calculate_new_coords:
  move.l	#new_coords1,a1
  move.w	add_z,a2
  jsr	rotate  

.addition_x_y:
  move.l	#new_coords1,a4
  move.w	add_x,d0
  move.w	add_y,d1
  rept	8
  add.w	d0,(a4)+
  add.w	d1,(a4)+
  endr    

  move.w	nb_faces,d7
  move.l	#faces,a5
  move.l	#new_coords1,a4
.one_face:
  move.w	(a5),d0
  move.w	$2(a5),d2
  move.w	$4(a5),d4
  move.w	$2(a4,d0.w),d1	; y1.
  move.w	(a4,d0.w),d0	; x1.
  move.w	$2(a4,d2.w),d3	; y2.
  move.w	(a4,d2.w),d2	; x2.
  move.w	$2(a4,d4.w),d5	; y3.
  move.w	(a4,d4.w),d4	; x3.
.test_visibility:
  sub.w	d2,d0	; d0=x1-x2.
  sub.w	d3,d5	; d5=y3-y2.
  sub.w	d2,d4	; d4=x3-x2.
  sub.w	d3,d1	; d1=y1-y2.
  muls.w	d0,d5	; d5=(y3-y2)*(x1-x2).
  muls.w	d1,d4	; d4=(x3-x2)*(y1-y2).
  sub.l	d4,d5
  beq	.next_face	; Si produit=0, pas d' affichage.
;  cmp.l	#$200,d5
;  bge	.clockwise	; Si >256, sens normal.
;  cmp.l	#-$200,d5
  ble	.anti_clockwise ; Si <-256, sens inverse.
;  bra.s	.next_face

.clockwise:		; Produit>0, affichage normal.
  move.w	$6(a5),d1
  cmp.w	#$2,d1
  beq.s	.next_face	; Un poly sur deux a l' arriere.
  move.l	#coords_buffer,a1
  move.w	(a5),d0
  move.w	$2(a5),d2
  move.w	$4(a5),d4
  move.l	(a4,d0.w),(a1)	; Recopie des sommets.
  move.l	(a4,d2.w),$4(a1)
  move.l	(a4,d4.w),$8(a1)
  move.l	a6,a0
  add.w	#$4,a0	; Pointer sur le bitplan.
  move.w	#$3,d0
  jsr	polygone	; affichage
  bra	.next_face

.anti_clockwise:	; Produit<0, affichage inverse.
  move.l	#coords_buffer,a1
  move.w	(a5),d0
  move.w	$2(a5),d2
  move.w	$4(a5),d4
  move.l	(a4,d0.w),$8(a1) ; Recopie des sommets en inverse.
  move.l	(a4,d2.w),$4(a1)
  move.l	(a4,d4.w),$0(a1)
  move.l	a6,a0
  add.w	$6(a5),a0	; Pointer sur le bitplan.
  move.w	#$3,d0
  jsr	polygone	; affichage
  
.next_face:
  add.w	#$8,a5	; Pointeur sur la face d' apres.
  dbra	d7,.one_face

;*************************  

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test2
  sub.w	#$111,$ffff8240.w
.no_test2:

  move.l	screen1_ad,d0	; Ecran de travail.
  lsr.w	#$8,d0
  move.b	d0,$ffff8203.w
  swap.w	d0
  move.b	d0,$ffff8201.w

  add.w	#$1,add_x	; Prochaine_position.
  move.w	add_z,d0
  add.w	inc_add_z,d0
  bne.s	.add_z_ok
  neg.w	inc_add_z
.add_z_ok: 
  move.w	d0,add_z
 
vbl2:
  move.w	#$25,-(sp)	; Attendre la vbl.
  trap	#$e
  addq.l	#$2,sp

  move.l	screen2_ad,a6

  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test
  add.w	#$111,$ffff8240.w
.no_test:

;*************************

  move.w	ang_y,d0
  add.w	#$4,d0
  cmpi.w	#$200,d0
  bne.s	.ang_y_ok
  moveq.l	#$0,d0
.ang_y_ok:
  move.w	d0,ang_y
  move.w	ang_z,d0
  add.w	#$1,d0
  cmpi.w	#$200,d0
  bne.s	.ang_z_ok
  moveq.l	#$0,d0
.ang_z_ok:
  move.w	d0,ang_z

.search_old_box:
  move.l	#new_coords2,a0
  move.w	(a0)+,d0
  move.w	(a0)+,d1
  move.w	d0,d2
  move.w	d1,d3
  move.w	nb_brows,d4
.search_one:
  move.w	(a0)+,d5	; x courant.
  move.w	(a0)+,d6	; y courant.
  cmp.w	d5,d0
  ble.s	.not_xmin
  move.w	d5,d0	; Nouvel xmin.
.not_xmin:
  cmp.w	d5,d2
  bge.s	.not_xmax
  move.w	d5,d2	; Nouvel xmax.
.not_xmax:
  cmp.w	d6,d1
  ble.s	.not_ymin
  move.w	d6,d1	; Nouvel ymin.
.not_ymin:
  cmp.w	d6,d3
  bge.s	.not_ymax
  move.w	d6,d3	; Nouvel ymax.
.not_ymax:
  subq.w	#$1,d4
  cmp.w	#$1,d4
  bne.s	.search_one
  
  move.l	a6,a0	; Effacer la boite qui entoure l'objet
  jsr	cls_box	; et ce sur 3 bitplans.
  addq.l	#$2,a0
  jsr	cls_box
  addq.l	#$2,a0
  jsr	cls_box

.calculate_new_coords:
  move.l	#new_coords2,a1
  move.w	add_z,a2
  jsr	rotate  

.addition_x_y:
  move.l	#new_coords2,a4
  move.w	add_x,d0
  move.w	add_y,d1
  rept	8
  add.w	d0,(a4)+
  add.w	d1,(a4)+
  endr    

  move.w	nb_faces,d7
  move.l	#faces,a5
  move.l	#new_coords2,a4
.one_face:
  move.w	(a5),d0
  move.w	$2(a5),d2
  move.w	$4(a5),d4
  move.w	$2(a4,d0.w),d1	; y1.
  move.w	(a4,d0.w),d0	; x1.
  move.w	$2(a4,d2.w),d3	; y2.
  move.w	(a4,d2.w),d2	; x2.
  move.w	$2(a4,d4.w),d5	; y3.
  move.w	(a4,d4.w),d4	; x3.
.test_visibility:
  sub.w	d2,d0	; d0=x1-x2.
  sub.w	d3,d5	; d5=y3-y2.
  sub.w	d2,d4	; d4=x3-x2.
  sub.w	d3,d1	; d1=y1-y2.
  muls.w	d0,d5	; d5=(y3-y2)*(x1-x2).
  muls.w	d1,d4	; d4=(x3-x2)*(y1-y2).
  sub.l	d4,d5
  beq	.next_face	; Si produit=0, pas d' affichage.
;  cmp.l	#$200,d5
;  bge	.clockwise	; Si >256, sens normal.
;  cmp.l	#-$200,d5
  ble	.anti_clockwise ; Si <-256, sens inverse.
;  bra.s	.next_face

.clockwise:		; Produit>0, affichage normal.
  move.w	$6(a5),d1
  cmp.w	#$2,d1
  beq.s	.next_face	; Un poly sur deux a l' arriere.
  move.l	#coords_buffer,a1
  move.w	(a5),d0
  move.w	$2(a5),d2
  move.w	$4(a5),d4
  move.l	(a4,d0.w),(a1)	; Recopie des sommets.
  move.l	(a4,d2.w),$4(a1)
  move.l	(a4,d4.w),$8(a1)
  move.l	a6,a0
  add.w	#$4,a0	; Pointer sur le bitplan.
  move.w	#$3,d0
  jsr	polygone	; affichage
  bra	.next_face

.anti_clockwise:	; Produit<0, affichage inverse.
  move.l	#coords_buffer,a1
  move.w	(a5),d0
  move.w	$2(a5),d2
  move.w	$4(a5),d4
  move.l	(a4,d0.w),$8(a1) ; Recopie des sommets en inverse.
  move.l	(a4,d2.w),$4(a1)
  move.l	(a4,d4.w),$0(a1)
  move.l	a6,a0
  add.w	$6(a5),a0	; Pointer sur le bitplan.
  move.w	#$3,d0
  jsr	polygone	; affichage
  
.next_face:
  add.w	#$8,a5	; Pointeur sur la face d' apres.
  dbra	d7,.one_face


;*************************  
  
  cmpi.b	#$38,$fffffc02.w
  bne.s	.no_test2
  sub.w	#$111,$ffff8240.w
.no_test2:

  move.l	screen2_ad,d0	; Ecran de travail.
  lsr.w	#$8,d0
  move.b	d0,$ffff8203.w
  swap.w	d0
  move.b	d0,$ffff8201.w

  add.w	#$1,add_x	; Prochaine_position.
  move.w	add_z,d0
  add.w	inc_add_z,d0
  bne.s	.add_z_ok
  neg.w	inc_add_z
.add_z_ok: 
  move.w	d0,add_z
  move.w	add_y,d0
  addq.w	#$1,d0
  cmp.w	#210,d0
  beq.s	sortie
  move.w	d0,add_y
    
  cmpi.b	#$39,$fffffc02.w
  bne	vbl1
  
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

; *** Appel avec a1=adresse de stockage. ***
; ***            a2=add_z.	         ***

rotate:
  movem.l	d0-a6,-(sp)
  
  move.l	#coords,a0
  move.w	ang_z,d0
  move.w	ang_y,d1
  move.l	#sin_cos,a3
  add.w	d0,d0
  add.w	d1,d1
  move.w	(a3,d0.w),d2	; d2=sin(ang_z).
  move.w	(a3,d1.w),d3	; d3=sin(ang_y).
  add.w	#$100,a3
  move.w	(a3,d0.w),d0	; d0=cos(ang_z).
  move.w	(a3,d1.w),d1	; d1=cos(ang_y).

  move.w	nb_brows,a4	; compteur.
  
.one_point:
  move.w	(a0)+,d4	;d4=x.
  move.w	(a0)+,d5	;d5=y.
  move.w	d4,d6
  move.w	d5,d7
  muls.w	d2,d4
  add.l	d4,d4
  add.l	d4,d4
  swap.w	d4	; d4=x*sin(ang_z).
  muls.w	d0,d6
  add.l	d6,d6
  add.l	d6,d6
  swap.w	d6	; d6=x*cos(ang_z).
  muls.w	d2,d5
  add.l	d5,d5
  add.l	d5,d5
  swap.w	d5	; d5=y*sin(ang_z).
  muls.w	d0,d7
  add.l	d7,d7
  add.l	d7,d7
  swap.w	d7	; d7=y*cos(ang_z).
  sub.w	d5,d6	; d6=x'=x*cos-y*sin.
  add.w	d7,d4	; d4=y'=y*cos+x*sin.
  move.w	d4,a3	; On sauve y' dans a3.
  move.w	d6,d4	; d4=x'.
  move.w	(a0)+,d5	; d5=z.
  move.w	d5,d7
  muls.w	d3,d4
  add.l	d4,d4
  add.l	d4,d4
  swap.w	d4	; d4=x'*sin(ang_y).
  muls.w	d1,d6
  add.l	d6,d6
  add.l	d6,d6
  swap.w	d6	; d6=x'*cos(ang_y).
  muls.w	d3,d5
  add.l	d5,d5
  add.l	d5,d5
  swap.w	d5	; d5=z*sin(ang_y).
  muls.w	d1,d7
  add.l	d7,d7
  add.l	d7,d7
  swap.w	d7	; d7=z*cos(ang_y).
  sub.w	d4,d7	; d7=z'=z*cos-x'*sin.
  add.w	d6,d5	; d5=x"=x'*cos+z*sin.
  move.w	a3,d6	; d6=y'.
.projection:
  add.w	#$100,d7	; d7=z+256.
  add.w	a2,d7	; d7=z+256+addz.
  ext.l	d5
  ext.l	d6
  lsl.w	#$8,d5	; d5=x"*256.
  lsl.w	#$8,d6	; d6=y'*256.
  divs.w	d7,d5	; d5=x"*256/(z'+addz+256).
  divs.w	d7,d6	; d6=y'*256/(z'+addz+256).
  move.w	d5,(a1)+
  move.w	d6,(a1)+
  subq.w	#$1,a4	; Un point de moins.
  cmp.w	#$0,a4
  bne	.one_point
  
  movem.l	(sp)+,d0-a6
  rts
  
polygone:
  include	'a:\polygone\poly_ste.s'
  Section TEXT

cls_box:
  include	'a:\glenz\cls_box.s'
  Section TEXT

;**************************************************************************
  Section DATA

colors:
  dc.w	$0aa,$333,$555,$333
  dc.w	$a00,$a00,$b00,$a00
  dc.w	$000,$000,$000,$000
  dc.w	$000,$000,$000,$000

nb_brows:
  dc.w	8
coords:
  dc.w	size,size,size
  dc.w	-size,size,size
  dc.w	-size,-size,size
  dc.w	size,-size,size
  dc.w	size,size,-size
  dc.w	-size,size,-size
  dc.w	-size,-size,-size
  dc.w	size,-size,-size

nb_faces:
  dc.w	11
faces:
  dc.w	00,04,08,0	; Pt1,pt2,pt3,bitplan.
  dc.w	00,08,12,2
  dc.w	00,20,04,2
  dc.w	00,16,20,0
  dc.w	04,20,24,0
  dc.w	04,24,08,2
  dc.w	20,16,24,2
  dc.w	16,28,24,0
  dc.w	00,28,16,2
  dc.w	12,24,28,2
  dc.w	00,12,28,0
  dc.w	12,08,24,0    

add_x:
  dc.w	-40
add_y:
  dc.w	-10
add_z:
  dc.w	210
inc_add_z:
  dc.w	-1
  
ang_z:
  dc.w	0
ang_y:
  dc.w	0
  
sin_cos:
  incbin	'a:\glenz\sin_cos.xxx'

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
  ds.w	16
new_coords2:
  ds.w	16

coords_buffer:
  ds.w	6
  
screen1_ad:
  ds.l	1
screen2_ad:
  ds.l	1
screens:
  ds.l	16064
  