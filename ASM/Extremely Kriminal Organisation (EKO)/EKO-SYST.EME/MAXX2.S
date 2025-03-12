*-------------------------------------------------------------------------*
* surf from iguana   adaption sur falcon par major x/eko
*-------------------------------------------------------------------------*
	Section Text
dimx	equ	192
dimy	equ	80
	
	pea	$00.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#4,sp

	bsr	def_screen

	bsr	set_rez
	clr.l	$ffff9800.w
	bsr	clear_screen
	bsr	dsp_load
	tst.l	d0
	bmi	fin
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	bsr	calc_pal
	bsr	send_pal
*-------------------------------------- install la VBL
	move.l	#-384*120*2,scroll_off
	move.l	#384*2,scroll_inc
	move.l	$70,jmp+2
	move.l	#vbl,$70
*--------------------------------------
	clr.l	$466.w
	
vbl_loopz:
*-------------------------------------- grafix
	move.l	#0,haut			* le logo monte
	move.l	#300,inc
	move.w	#30,nb_vbl
	move.l	#offset,ptr
	bsr	go_up
	*move.l	#0,haut			* le logo reste en haut
	move.l	#0,inc
	move.w	#20,nb_vbl
	move.l	#offset,ptr
	bsr	go_up	
	move.l	#0,haut			* le logo tombe
	move.l	#0,inc
	move.w	#20,nb_vbl
	move.l	#off_vide,ptr
	bsr	go_up
	move.w	#0,angl1		* vague
	move.w	#156,angl2	
	move.l	#5000,haut
	move.w	#40,nb_vbl
	bsr	wave
*-------------------------------------- Niko
	move.l	#0,haut
	move.l	#400,inc
	move.w	#20,nb_vbl
	move.l	#offset2,ptr
	bsr	go_up
	*move.l	#0,haut
	move.l	#-400,inc
	move.w	#40,nb_vbl
	move.l	#offset2,ptr
	bsr	go_up
	move.l	#-384*2,scroll_inc	* pour le scroll 
	move.w	#0,angl1
	move.w	#156,angl2
	move.l	#5000,haut
	move.w	#20000,nb_vbl
	bsr	wave

fin:
*-------------------------------------- remet la vbl
	move.l	jmp+2,$70
*--------------------------------------
	bsr	tend_rez
	
	clr.w	-(sp)
	trap	#1
vbl:
	move.l	d0,-(sp)
	move.l	scroll_off,d0
	add.l	scroll_inc,d0
	blt.s	no_at_bottom
	moveq	#0,d0
no_at_bottom:
	cmpi.l	#-384*120*2,d0
	bge.s	no_at_top
	move.l	#-384*120*2,d0
no_at_top:
	move.l	d0,scroll_off
	add.l	physik,d0
	move.l	d0,scroll_buff
	move.b	scroll_buff+1,$ffff8201.w
	move.b	scroll_buff+2,$ffff8203.w
	move.b	scroll_buff+3,$ffff820d.w
	move.l	(sp)+,d0
jmp:
	jmp	$12345678

wave:
	btst	#0,nb_vbl+1
	beq.s	no_increm
	lea	sintab,a0
	move.w	angl1,d0
	move.w	angl2,d1
	add.w	#8,d0
	add.w	#10,d1
	move.w	d0,angl1
	move.w	d1,angl2
	and.w	#1023,d0
	and.w	#1023,d1
	move.w	0(a0,d0.w*2),d0
	move.w	0(a0,d1.w*2),d1
	muls	#dimx/2-5,d0
	lsl.l	#1,d0
	swap	d0
	muls	#dimy/2-5,d1
	lsl.l	#1,d1
	swap	d1
	add.w	#dimx/2,d0
	add.w	#dimy/2,d1
	mulu	#dimx,d1
	add.w	d1,d0
	*move.w	#dimx/2+dimx*dimy/2,off_wave+4
	*move.w	#dimx/2+40*dimx,d0
	move.w	d0,off_wave+2
no_increm:
	bsr	do_surf
	lea	off_wave,a1
	move.l	haut,d0
	bsr	send_plage
	sub.w	#1,nb_vbl
	bne	wave
	rts
go_up:
	bsr	do_surf
	move.l	ptr,a1
	move.l	haut,d0
	bsr	send_plage
	move.l	inc,d0
	add.l	d0,haut	
	subq.w	#1,nb_vbl
	bne.s	go_up
	rts

do_surf:
	moveq	#10,d0
	move.l	back,a0
	adda.w	#40,a0
.re1
	move.w	#0,(a0)+
	addq	#2,a0
	dbf	d0,.re1

	move.l	$466.w,d0
	move.l	back,a0
	adda.w	#40,a0
.re
	move.w	#-1,(a0)+
	addq	#2,a0
	dbf	d0,.re

	move.l	back,d0
	move.l	physik,back
	move.l	d0,physik

	*move.l	#-1,$ffff9800.w
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	clr.l	$466.w
	*move.l	#0,$ffff9800.w
	
	bsr	aff_surf

	cmpi.b	#$39,$fffffc02.w
	beq	fin
	rts


aff_surf:
	move.l	back,a0
	adda.l	#dimx*4*(120-1),a0
	move.l	#dimx*4,d5
	lea	$ffffa204+2,a2
	lea	$ffffa202.w,a3
	move.w	#dimx-1,d7
next_colonne:
	move.l	a0,a1
	addq.l	#4,a0
next_segment:
	bra.s	zlika
ici
	move.w	(a2),d1
	move.w	d1,d2
	swap	d2
	move.w	d1,d2
next_pix:
	move.l	d2,(a1)
	sub.l	d5,a1
	dbf	d0,next_pix
zlika:
wait1:	btst.b	#0,(a3)
	beq.s	wait1

	move.w	(a2),d0
	bpl.s	ici			; si pas fin on boucle
	dbf	d7,next_colonne

	rts
	
send_plage:
	lea	$ffffa206.w,a0		*a1 pointe sur le port HOST
	lea	$ffffa202.w,a2
wait_1
	btst.b	#1,(a2)			*On attend que le DSP soit
	beq.s	wait_1			*pret … recevoir
	move.w	(a1)+,d7
	move.w	d7,(a0)
	beq.s	no_plage
	move.l	d0,-2(a0)
	subq.w	#1,d7
send_plage_loopz:
wait_2
	btst.b	#1,(a2)			*On attend que le DSP soit
	beq.s	wait_2			*pret … recevoir
	move.w	(a1)+,(a0)
	move.w	(a1)+,(a0)
	dbf	d7,send_plage_loopz
no_plage:
	rts

calc_pal:
	lea	degrad,a0
	lea	color,a1
	move.b	3(a0),d0
	sub.b	(a0),d0
	ext.w	d0
	swap	d0
	clr.w	d0
	divs.l	#dimy,d0
	move.b	4(a0),d1
	sub.b	1(a0),d1
	ext.w	d1
	swap	d1
	clr.w	d1
	divs.l	#dimy,d1
	move.b	5(a0),d2
	sub.b	2(a0),d2
	ext.w	d2
	swap	d2
	clr.w	d2
	divs.l	#dimy,d2
	move.b	(a0),d3
	ext.w	d3
	swap	d3
	clr.w	d3
	move.b	1(a0),d4
	ext.w	d4
	swap	d4
	clr.w	d4
	move.b	2(a0),d5
	ext.w	d5
	swap	d5
	clr.w	d5
	move.w	#dimy-1,d7
calc_pal_l:
	swap	d7
	bfextu	d3{8+2:5},d6		* r
	bfins	d6,d7{16:5}
	bfextu	d4{8+2:6},d6		* v
	bfins	d6,d7{16+5:6}
	bfextu	d5{8+2:5},d6		* b
	bfins	d6,d7{16+5+6:5}		
	move.w	d7,(a1)+
	add.l	d0,d3
	add.l	d1,d4
	add.l	d2,d5
	swap	d7
	dbf	d7,calc_pal_l
	rts
send_pal:
	lea	$ffffa206.w,a0		*a1 pointe sur le port HOST
	lea	color,a1
wait_dsp2:
	btst.b	#1,$ffffa202.w		*On attend que le DSP soit
	beq	wait_dsp2		*pret … recevoir
	move.w	#dimy-1,d7
degrad_loopz:
	move.w	(a1)+,(a0)
	dbf	d7,degrad_loopz
	rts

clear_screen:
	move.l	back,a0
	moveq	#0,d0
	move.w	#384*240/2-1,d7
clear_loopz:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d7,clear_loopz
	rts
*-------------------------------------------------------------------------*
* Routine d'execution d'un LOD
*
* Parametre:
*	a6 = pointeur sur le nom du fichier a executer
* Sorti:
*	d0 Si d0 = -1 il y a eu une erreur
*-------------------------------------------------------------------------*
dsp_load:			*Procedure d'envoi du .lod au
	move.w	#3,-(sp)
	move.l	#dsp_bin_fin-dsp_bin,d0
	divu	#3,d0
	move.l	d0,-(sp)
	pea	dsp_bin
	move.w	#109,-(sp)
	trap	#14
	add.w	#12,sp
	rts

def_screen:
	move.l	#screen+4,d0
	and.b	#$fc,d0
	add.l	#384*120*2,d0
	move.l	d0,back
	add.l	#384*240*2,d0
	move.l	d0,physik
	rts

set_rez:
	DC.W	$A00A			* coupe Souris			

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_pbas
	
	move.w	#-1,-(sp)		* Save rez
	move.w	#$58,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	d0,old_rezo
		*%FSOPV8NNN
	move.w	#%001100100,-(sp)	* Set rez
	move.w	#3,-(sp)
	move.l	back,-(sp)
	move.l	back,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#14,sp

	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp

	bset	#0,$ffff82c3.w	* doublage de ligne
	rts
tend_rez:
	move.w	old_rezo,-(sp)		* Set rez
	move.w	#3,-(sp)
	move.l	old_pbas,-(sp)
	move.l	old_pbas,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#14,sp
	DC.W	$A009			* tend mouse
	rts
*--------------------------*
	section	DATA
*--------------------------*
offset:
	incbin	grafix.off
offset2:	
	incbin	niko.off
off_vide:
	dc.w	0
color:
	ds.w	80
degrad:
	dc.b	0,63,63
	dc.b	0,0,22
off_wave:
	dc.w	1,0,1
sintab:
	incbin	D:\UNIX\DATA\EKO-SYST.EME\sin_tab.bin	
dsp_bin:
	incbin	D:\UNIX\DATA\EKO-SYST.EME\surf.p56
dsp_bin_fin:
	even
*--------------------------*
	section	BSS
*--------------------------*
scroll_inc:
	ds.l	1
scroll_off:
	ds.l	1
scroll_buff:
	ds.l	1
angl1:
	ds.w	1
angl2:
	ds.w	1
nb_vbl:
	ds.w	1
haut:
	ds.l	1
inc:
	ds.l	1
ptr:
	ds.l	1
back:
	ds.l	1
physik:
	ds.l	1
old_rezo:
	ds.w	1
old_pbas:
	ds.l	1
screen:
	ds.w	384*240*2+2