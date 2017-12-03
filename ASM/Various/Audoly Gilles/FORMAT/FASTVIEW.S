	include	"d:\include\gemdos.s"
	include	"d:\include\video.s"

disk=0
debug=0

tx=984
ty=520

	move.l	4(sp),a5
	move.l	12(a5),d0
	add.l	20(a5),d0
	add.l	28(a5),d0
	add.l	#256,d0
	Mshrink a5,d0
	IFEQ disk
	lea.l	fich(pc),a5
	ELSEIF
	lea.l	$81(a5),a5
	ENDC
	move.l	a5,-(sp)
	bsr	load
	addq.w	#4,sp
	move.l	a0,a6
	move.l	a0,source
	Super0

	btst.b	#6,$ffff8006.w
	beq	fini
	
	move.l	$70.w,avbl

	Malloc	#$200000
	tst.l	d0
	blt	fini
	add.l	#640*3*4,d0
	move.l	d0,aecr
	move.l	d0,phy
	add.l	#256,phy
	and.b	#0,phy+3
	add.l	#128,phy
	IFEQ debug
	Setres	phy(pc),phy(pc),#%100001100
	ELSEIF
	Setres	phy(pc),phy(pc),res(pc)
	ENDC

	move.l	#vbl,$70.w
	
	

	move.l	$fffffa06.w,mfp
	IFEQ debug
	clr.l	$fffffa06.w
	ENDC
	
sh_end:	tst.b	(a5)+
	bne.s	sh_end
	move.l	-4(a5),d0
	or.l	#$20202020,d0
	move.l	d0,$140.w
	cmp.l	#"gif ",d0
	bne.s	pas_gif
	bsr	gif
	bra.s	done
pas_gif:	
	
	cmp.l	#"tga ",d0
	bne.s	pas_tga
	bsr	tga
	bra.s	done
pas_tga:	
	cmp.l	#"mtv ",d0
	bne.s	pas_mtv
	bsr	mtv
	bra.s	done
pas_mtv:	
	cmp.l	#"pc1 ",d0
	bne.s	pas_pc1
	bsr	pc1
	bra.s	done
pas_pc1:	
	nop
	
done:	
done0:	
	subq.w	#1,nb_zoom
	blt	alldone
	lsl.w	sizex
	lsl.w	sizey
	move.w	sizex(pc),d6
	move.w	sizey(pc),d7
	move.w	d7,d0
	mulu.w	d6,d0
	move.l	phy,a0
	add.l	d0,a0
	add.l	d0,a0
	lsr.l	#2,d0
	move.l	phy,a1
	add.l	d0,a1
	add.l	d0,a1
	asr.w	d7
	subq.w	#1,d7
	move.w	d6,d4
	lsl.w	d4
	lsr.w	d6
	subq.w	#1,d6
.new_y:	
	move.w	d6,d5
.new_x:	
	move.w	-(a1),d0
	move.w	d0,-(a0)
	move.w	d0,-(a0)
	REPT 0
	movem.l	(a0),d1-d3/a3-a6
	ENDR
	dbra	d5,.new_x
	
	move.w	d6,d5
	lea.l	(a0,d4.w),a2
.new_x2:	
	move.l	-(a2),-(a0)
	dbra	d5,.new_x2
	
	dbra	d7,.new_y
	
	bra	done0
alldone:	
	lea.l	$fffffc02.w,a1
.wk:	
	move.b	(a1),d0
	btst.b	#0,-2(a1)
	bne.s	.wk
	move.l	mfp(pc),$fffffa06.w
	
	Mfree	source(pc)
	tst.l	d0
	blt	fin

	
	;bclr.b	#0,$ffff820a.w
	
	move.w	#$2500,sr
wk:	
	Crawcin
	cmp.b	#$1b,d0
	beq	fin
	cmp.b	#' ',d0
	beq	fin
	cmp.b	#'+',d0
	bne.s	pas_plus
	
	move.l	phy(pc),a0
	move.w	sizex(pc),d7
	mulu.w	sizey(pc),d7
	moveq	#32,d6
	moveq	#64,d5
	moveq	#63,d4
pnew_pixel:
	move.w	(a0),d0
	bfextu	d0{16:5},d1
	addq.w	#1,d1
	cmp.w	d6,d1
	beq.s	.br1
	bfins	d1,d0{16:5}
.br1:	
	bfextu	d0{21:6},d1
	addq.w	#2,d1
	cmp.w	d5,d1
	blo.s	.br2
	moveq	#63,d1
.br2:	bfins	d1,d0{21:6}
	
	bfextu	d0{27:5},d1
	addq.w	#1,d1
	cmp.w	d6,d1
	beq.s	.br3
	bfins	d1,d0{27:5}
.br3:	
	move.w	d0,(a0)+
pp:
	move.w	(a0),d0
	bfextu	d0{16:5},d1
	addq.w	#1,d1
	cmp.w	d6,d1
	beq.s	.br1
	bfins	d1,d0{16:5}
.br1:	
	bfextu	d0{21:6},d1
	addq.w	#2,d1
	cmp.w	d5,d1
	blo.s	.br2
	moveq	#63,d1
.br2:	bfins	d1,d0{21:6}
	
	bfextu	d0{27:5},d1
	addq.w	#1,d1
	cmp.w	d6,d1
	beq.s	.br3
	bfins	d1,d0{27:5}
.br3:	
	move.w	d0,(a0)+
	
	subq.l	#2,d7
	bgt.s	pnew_pixel

	
pas_plus:	
	cmp.b	#'-',d0
	bne.s	pas_moins
	
	move.l	phy(pc),a0
	move.w	sizex(pc),d7
	mulu.w	sizey(pc),d7
mnew_pixel:
	move.w	(a0),d0
	bfextu	d0{16:5},d1
	subq.w	#1,d1
	blt.s	.br1
	bfins	d1,d0{16:5}
.br1:	
	bfextu	d0{21:6},d1
	subq.w	#2,d1
	bge.s	.br2
	moveq	#0,d1
.br2:	bfins	d1,d0{21:6}
	
	bfextu	d0{27:5},d1
	subq.w	#1,d1
	blt.s	.br3
	bfins	d1,d0{27:5}
.br3:	
	move.w	d0,(a0)+
mm:
	move.w	(a0),d0
	bfextu	d0{16:5},d1
	subq.w	#1,d1
	blt.s	.br1
	bfins	d1,d0{16:5}
.br1:	
	bfextu	d0{21:6},d1
	subq.w	#2,d1
	bge.s	.br2
	moveq	#0,d1
.br2:	bfins	d1,d0{21:6}
	
	bfextu	d0{27:5},d1
	subq.w	#1,d1
	blt.s	.br3
	bfins	d1,d0{27:5}
.br3:	
	move.w	d0,(a0)+

	subq.l	#2,d7
	bgt.s	mnew_pixel
	
pas_moins:	
	cmp.l	#$480000,d0
	bne.s	pas_haut
	cmp.w	#ty,sizey
	bls	wk

	moveq	#0,d1
	move.b	$ffff8201.w,d1
	lsl.l	#8,d1
	move.b	$ffff8203.w,d1
	lsl.l	#8,d1
	move.b	$ffff820d.w,d1
	moveq	#0,d0
	move.w	sizex(pc),d0
	lsl.w	#3,d0
	sub.l	d0,d1
	cmp.l	phy(pc),d1
	blo	wk
	swap	d1
	move.b	d1,$ffff8201.w
	rol.l	#8,d1
	move.b	d1,$ffff8203.w
	rol.l	#8,d1
	move.b	d1,$ffff820d.w
	bra	wk

pas_haut:

	cmp.l	#$500000,d0
	bne.s	pas_bas
	cmp.w	#ty,sizey
	bls	wk
	
	moveq	#0,d1
	move.b	$ffff8201.w,d1
	lsl.l	#8,d1
	move.b	$ffff8203.w,d1
	lsl.l	#8,d1
	move.b	$ffff820d.w,d1
	moveq	#0,d0
	move.w	sizex(pc),d0
	lsl.w	#3,d0
	add.l	d0,d1
	move.w	sizey(pc),d0
	sub.w	#ty,d0
	add.w	d0,d0
	muls.w	sizex(pc),d0
	add.l	phy(pc),d0
	cmp.l	d0,d1
	bhs	wk
	swap	d1
	move.b	d1,$ffff8201.w
	rol.l	#8,d1
	move.b	d1,$ffff8203.w
	rol.l	#8,d1
	move.b	d1,$ffff820d.w
	bra	wk

pas_bas:
	cmp.l	#$4b0000,d0
	bne.s	pas_gauche

	moveq	#0,d1
	move.b	$ffff8201.w,d1
	lsl.l	#8,d1
	move.b	$ffff8203.w,d1
	lsl.l	#8,d1
	move.b	$ffff820d.w,d1
	subq.l	#8,d1
	swap	d1
	move.b	d1,$ffff8201.w
	rol.l	#8,d1
	move.b	d1,$ffff8203.w
	rol.l	#8,d1
	move.b	d1,$ffff820d.w

	bra	wk
	
pas_gauche:
	cmp.l	#$4d0000,d0
	bne.s	pas_droite

	moveq	#0,d1
	move.b	$ffff8201.w,d1
	lsl.l	#8,d1
	move.b	$ffff8203.w,d1
	lsl.l	#8,d1
	move.b	$ffff820d.w,d1
	addq.l	#8,d1
	swap	d1
	move.b	d1,$ffff8201.w
	rol.l	#8,d1
	move.b	d1,$ffff8203.w
	rol.l	#8,d1
	move.b	d1,$ffff820d.w

	bra	wk
	
pas_droite:
	cmp.w	#13,d0
	bne	pas_filtre



	move.w	sizex(pc),d1
	add.w	d1,d1
	neg.w	d1
	move.l	phy(pc),a0
	move.w	sizex(pc),d7
	mulu.w	sizey(pc),d7
	not.w	$ffff9800.w
.new_pixel:
moy1:	MACRO
	bfextu	d0{16:5},d6
	IFNE \1
	add.w	d6,d6
	ENDC
	add.w	d6,d5
	ENDM
moy2:	MACRO
	bfextu	d0{21:6},d6
	IFNE \1
	add.w	d6,d6
	ENDC
	add.w	d6,d2
	ENDM
moy3:	MACRO
	bfextu	d0{27:5},d6
	IFNE \1
	add.w	d6,d6
	ENDC
	add.w	d6,d3
	ENDM
moye1:	MACRO
	bfextu	d0{16:5},d5
	lsl.w	#2,d5
	ENDM
moye2:	MACRO
	bfextu	d0{21:6},d2
	lsl.w	#2,d2
	ENDM
moye3:	MACRO
	bfextu	d0{27:5},d3
	lsl.w	#2,d3
	ENDM

	lea.l	(a0,d1),a2
	move.l	a0,a1
	sub.w	d1,a1
	move.w	(a0)+,d0
	moye1	2
	moye2	2
	moye3	2
	move.w	-4(a0),d0
	moy1	1
	moy2	1
	moy3	1
	move.w	(a0),d0
	moy1	1
	moy2	1
	moy3	1
	move.w	(a1)+,d0
	moy1	1
	moy2	1
	moy3	1
	move.w	-4(a1),d0
	moy1	0
	moy2	0
	moy3	0
	move.w	(a1),d0
	moy1	0
	moy2	0
	moy3	0
	move.w	(a2),d0
	moy1	1
	moy2	1
	moy3	1
	move.w	-2(a2),d0
	moy1	0
	moy2	0
	moy3	0
	move.w	+2(a2),d0
	moy1	0
	moy2	0
	moy3	0

	
	lsr.w	#4,d5
	lsr.w	#4,d2
	lsr.w	#4,d3
	lsl.w	#6,d5
	or.w	d2,d5
	lsl.w	#5,d5
	or.w	d3,d5

	move.w	d5,(a2,d1)
	;addq.w	#2,a0

	subq.l	#1,d7
	bgt	.new_pixel
	
	move.l	phy(pc),a0
	move.w	sizex(pc),d7
	move.l	a0,a1
	lsl.w	#2,d7
	sub.w	d7,a1
	lsr.w	#2,d7
	mulu.w	sizey(pc),d7
	add.l	d7,a0
	add.l	d7,a0
	add.l	d7,a1
	add.l	d7,a1
	moveq	#32,d1
.new_pix:
	REPT 32/2
	move.l	-(a1),-(a0)
	ENDR
	sub.l	d1,d7
	bgt	.new_pix
	clr.w	$ffff9800.w

	bra	wk
	
pas_filtre:
	
	bra	wk

	
fin:		
	move.w	#$2300,sr
	move.l	avbl(pc),$70.w
	
	move.w	#0,$ffff820e.w
	Resres
fini:	
	Cconws2	texte(pc)
	Crawcin
	Term
	Term



avbl:	ds.l	1
vbl:	
	rte








set_low:	
	move.b	low(pc),$ffff820d.w
	rts
	movem.l	d0-a6,-(sp)
	move.l	phy(pc),a0
	move.w	sizex(pc),d7
	mulu.w	sizey(pc),d7
	moveq	#0,d0
	moveq	#0,d1
	move.b	low(pc),d0
	move.b	alow(pc),d1
	sub.l	d1,d0
	lea.l	(a0,d0),a1
.new:
	move.l	(a0)+,(a1)+

	subq.l	#4,d7
	bgt.s	.new

	movem.l	(sp)+,d0-a6
	rts
	



	




set_scr:	
	clr.w	nb_zoom
	move.w	sizex(pc),d0
	move.w	sizey(pc),d7
.la:	
	cmp.w	#490,d0
	bhs.s	.ici
	cmp.w	#270,d7
	bhs.s	.ici
	lsl.w	d0
	lsl.w	d7
	addq.w	#1,nb_zoom
	eor.w	#1,$ffff82a2.w
	bra.s	.la
.ici:	
	
	IFEQ debug
	move.w	d0,$ffff8210.w
	move.w	#2,$ffff82a8.w
	move.w	#ty,$ffff82aa.w
	cmp.w	#984,d0
	bls.s	ok
	sub.w	#984,d0
	move.w	d0,$ffff820e.w
	move.w	#984,$ffff8210.w
	clr.w	$ffff8288.w
	move.w	#1000,$ffff828a.w
	bra.s	pas_ok
ok:
	move.w	#984,d1
	sub.w	d0,d1
	asr.w	#1,d1
	;moveq	#0,d1
	add.w	#-40,d1
	move.w	d1,$ffff8288.w
	add.w	d0,d1
	add.w	#48,d1
	;move.w	#1000,d0
	;sub.w	d1,d0
	;sub.w	d1,d0
	move.w	d1,$ffff828a.w
pas_ok:	
	ENDC
	
	move.w	d7,d0
	
	IFEQ debug
	cmp.w	#ty,d0
	bls.s	.ok
	sub.w	#ty,d0
	lsr.w	d0
	moveq	#0,d1
	move.b	$ffff8201.w,d1
	lsl.l	#8,d1
	move.b	$ffff8203.w,d1
	lsl.l	#8,d1
	move.b	$ffff820d.w,d1
	ext.l	d0
	;add.w	#100,d0	;;
	mulu.w	sizex(pc),d0
	add.l	d0,d0
	add.l	d0,d1
	moveq	#0,d0
	move.b	d1,d0

	swap	d1
	move.b	d1,$ffff8201.w
	rol.l	#8,d1
	move.b	d1,$ffff8203.w
	rol.l	#8,d1
	move.b	d1,$ffff820d.w

	bra.s	.pasok
.ok:	
	move.w	#540,d1
	sub.w	d0,d1
	lsr.w	d1
	mulu.w	sizex(pc),d1
	add.l	d1,d1
	add.l	d1,phy

.pasok:	
	;add.w	#8,$ffff82a8.w
	;add.w	#16,$ffff82a8.w
	;add.w	#16,$ffff82aa.w
	ENDC
	rts






cls:	
	move.l	aecr(pc),a0
	move.w	#$8200-1,d0
	moveq	#0,d1
.ef:	
	REPT 8
	move.l	d1,(a0)+
	ENDR
	dbra	d0,.ef
	
	rts






;
;	-- CHARGEMENT IMAGE PC1 --
;
;



pc1:	
	move.w	#320,sizex
	move.w	#200,sizey
	bsr	set_scr
	
	bsr	cls
	clr.l	$ffff9800.w
	
	move.l	phy(pc),a1
	add.l	#320*200*2,a1
	
	

dcomp:	
	lea.l	34(a6),a2	source
	move.w	#199,d7	hauteur
lb1:	moveq	#3,d6	nb de plans-1
lb2:	moveq	#39,d5	largeur/8(bits)
	lea.l	tampon,a0
lb2a:	move.b	(a2)+,d4
	ext.w	d4
	bmi.s	lb4
	sub.w	d4,d5	positif:pas de
lb3:	move.b	(a2)+,(a0)+	regroupement
	dbra	d4,lb3
	bra.s	lb6

lb4:	neg.w	d4	negatif:
	sub.w	d4,d5	regroupement
	move.b	(a2)+,d3	octet … r‚p‚ter d4 fois
lb5:	move.b	d3,(a0)+
	dbra	d4,lb5

lb6:
	cmp.l	#tampon+40,a0
	bhi.s	lb10
	dbra	d5,lb2a
	lea.l	tampon,a0
	moveq	#3,d0
	sub.w	d6,d0
	add.w	d0,d0
	moveq	#19,d1
lb7:	move.w	(a0)+,(a1,d0)
	addq.w	#8,d0
	dbra	d1,lb7
	dbra	d6,lb2
	lea.l	160(a1),a1	ligne suivante
	dbra	d7,lb1
lb10:
	
	lea.l	2(a6),a2
	lea.l	pal(pc),a0
	moveq	#15,d7
.new_col:	
	move.w	(a2)+,d0
	move.w	d0,d6
	move.w	d0,d1
	and.w	#$700,d6
	lsl.w	#5,d6
	and.w	#$800,d1
	lsl.w	#1,d1
	or.w	d1,d6
	
	move.w	d0,d5
	move.w	d0,d1
	and.w	#$70,d5
	lsl.w	#4,d5
	or.w	d5,d6
	and.w	#$80,d1
	or.w	d1,d6
	
	move.w	d0,d5
	move.w	d0,d1
	and.w	#$7,d5
	lsl.w	#2,d5
	or.w	d5,d6
	and.w	#$8,d1
	lsr.w	#1,d1
	or.w	d1,d6
	
	move.w	d6,(a0)+
	dbra	d7,.new_col
	
	move.l	phy(pc),a1
	move.l	a1,a0
	add.l	#320*200*2,a1
	lea.l	pal(pc),a2
	move.w	#320*200-1,d7
pc1_np:
	move.w	d7,d6
	and.w	#$f,d6
	;eor.w	#$f,d6
	movem.w	(a1),d0-d3
	moveq	#0,d5
	btst	d6,d0
	beq.s	pl0
	or.w	#2,d5
pl0:	
	btst	d6,d1
	beq.s	pl1
	or.w	#4,d5
pl1:	
	btst	d6,d2
	beq.s	pl2
	or.w	#8,d5
pl2:	
	btst	d6,d3
	beq.s	pl3
	or.w	#16,d5
pl3:	
	move.w	(a2,d5),(a0)+
	tst.w	d6
	bne.s	.ici
	clr.l	(a1)+
	clr.l	(a1)+
.ici:	
	
	dbra	d7,pc1_np
	
	
	rts


tampon:	ds.l	10



	
	
	
	


;
;	-- CHARGEMENT IMAGE TGA --
;
;

tga:	
	lea.l	12(a6),a6
	move.w	(a6)+,d0
	rol.w	#8,d0
	move.w	d0,sizex
	move.w	(a6)+,d0
	rol.w	#8,d0
	move.w	d0,sizey
	addq.w	#2,a6
	
	bsr	set_scr
	
	bsr	cls
	
	
	clr.l	$ffff9800.w
	move.l	phy(pc),a0
	
	move.w	sizey(pc),d7
	;addq.w	#1,d7
	mulu.w	sizex(pc),d7
.new_point:
	move.b	(a6)+,d0
	lsr.b	#3,d0
	bfins	d0,d1{27:5}
	move.b	(a6)+,d0
	lsr.b	#2,d0
	bfins	d0,d1{21:6}
	move.b	(a6)+,d0
	lsr.b	#3,d0
	bfins	d0,d1{16:5}
	move.w	d1,(a0)+
	subq.l	#1,d7
	bgt.s	.new_point

	rts

	





;
;	-- CHARGEMENT IMAGE MTV --
;
;

mtv:	
	moveq	#0,d6
get_tx:	
	moveq	#0,d0
	move.b	(a6)+,d0
	cmp.b	#" ",d0
	beq.s	get_txf
	sub.b	#'0',d0
	mulu.w	#10,d6
	add.w	d0,d6
	bra.s	get_tx
get_txf:	

	moveq	#0,d7
get_ty:	
	moveq	#0,d0
	move.b	(a6)+,d0
	cmp.b	#10,d0
	beq.s	get_tyf
	sub.b	#'0',d0
	mulu.w	#10,d7
	add.w	d0,d7
	bra.s	get_ty
get_tyf:	
	move.w	d6,sizex
	move.w	d7,sizey

	bsr	set_scr

	move.l	aecr(pc),a0
	move.w	#$8200-1,d0
	moveq	#0,d1
.ef:	
	REPT 8
	move.l	d1,(a0)+
	ENDR
	dbra	d0,.ef

	
	clr.l	$ffff9800.w
	move.l	phy(pc),a0
	
	move.w	sizey(pc),d7
	;addq.w	#1,d7
	mulu.w	sizex(pc),d7
.new_point:
	move.b	(a6)+,d0
	lsr.b	#3,d0
	bfins	d0,d1{16:5}
	move.b	(a6)+,d0
	lsr.b	#2,d0
	bfins	d0,d1{21:6}
	move.b	(a6)+,d0
	lsr.b	#3,d0
	bfins	d0,d1{27:5}
	move.w	d1,(a0)+
	subq.l	#1,d7
	bgt.s	.new_point

	rts

	



;
;	-- CHARGEMENT IMAGE GIF --
;
;





gif:	

	cmp.l	#"GIF8",(a6)+
	bne	fin
	cmp.w	#"7a",(a6)+
	bne	fin
	


	move.w	(a6)+,d0
	rol.w	#8,d0
	move.w	d0,sizex
	move.w	(a6)+,d0
	rol.w	#8,d0
	move.w	d0,sizey
	
	bsr	set_scr
	

	move.b	(a6)+,d0
	and.b	#7,d0
	moveq	#2,d7
	lsl.w	d0,d7
	subq.w	#1,d7
	addq.w	#2,a6
	lea.l	$ffff9800.w,a5
	lea.l	pal(pc),a4
mk_pal:	
	moveq	#0,d2
	move.b	(a6)+,d0
	move.b	d0,d1
	lsr.b	#3,d1
	or.b	d1,d2
	lsl.w	#6,d2
	lsl.l	#8,d0
	move.b	(a6)+,d0
	move.b	d0,d1
	lsr.b	#2,d1
	or.b	d1,d2
	lsl.w	#5,d2
	swap	d0
	move.b	(a6)+,d0
	move.b	d0,d1
	lsr.b	#3,d1
	or.b	d1,d2
	move.l	d0,(a5)+
	move.w	d2,(a4)+
	dbra	d7,mk_pal
	clr.l	$fffff9800.w
	
	move.l	aecr(pc),a0
	move.w	#$8200-1,d0
	moveq	#0,d1
.ef:	
	REPT 8
	move.l	d1,(a0)+
	ENDR
	dbra	d0,.ef
	
	btst.b	#6,9(a6)
	sne.b	int
	add.w	#10,a6
	

get_byte:	MACRO
	move.b	(a6)+,d0
	addq.w	#1,byte_ctr-prefix(a0)
	move.w	byte_count(pc),d6
	cmp.w	byte_ctr(pc),d6
	bge.s	.endifg
	move.w	d0,byte_count-prefix(a0)
	beq.s	.endifg
	move.b	(a6)+,d0
	move.w	#1,byte_ctr-prefix(a0)
.endifg:	
	ENDM

	move.w	sizex(pc),d0
	mulu.w	sizey(pc),d0
	lea.l	pal(pc),a3
	lea.l	prefix(pc),a0
	lea.l	suffix(pc),a1
	lea.l	transla(pc),a2
	move.l	phy(pc),a4
raster:	
	moveq	#0,d0
	move.b	(a6)+,d0
	move.w	d0,code_size-prefix(a0)
	moveq	#1,d1
	lsl.w	d0,d1
	move.w	d1,cc-prefix(a0)
	addq.w	#1,d1
	move.w	d1,eoi-prefix(a0)
	get_byte
	moveq	#1,d4
start_up:	
	bsr	init_string_table
get_code:	MACRO
	moveq	#1,d1
	clr.w	d3
	move.w	bits(pc),d7
	subq.w	#1,d7
.br:	
	move.w	d0,d6
	and.w	d4,d6
	beq.s	.endif2
	or.w	d1,d3
.endif2:	
	add.w	d1,d1
	rol.b	d4
	bcc.s	.endif1
	get_byte
.endif1:	
	dbra	d7,.br
	ENDM
	get_code
	
	move.w	d3,d7
	cmp.w	cc(pc),d7
	beq.s	start_up
.endif0:
	add.w	d7,d7
	move.w	(a1,d7),d6
	add.w	d6,d6
	move.w	(a3,d6),(a4)+
	;subq.l	#1,nbpix
	;ble	imagedone
	move.w	d3,old_code-prefix(a0)

decomp_loop:
	get_code
	move.w	d3,d7
	cmp.w	cc(pc),d7
	beq	start_up
	cmp.w	eoi(pc),d7
	beq.s	imagedone
	cmp.w	next_code(pc),d7
	bhs.s	.else0
	bsr	exist
	bra.s	decomp_loop
.else0:	
	bne.s	decomp_loop
	bsr	nonexist
	bra	decomp_loop

imagedone:
	
	
	tst.b	int
	beq	pas_int
	
	move.w	sizex(pc),d7
	lsr.w	#1,d7
	subq.w	#1,d7
	move.l	a4,d5
	move.w	sizey(pc),d5
	;move.w	sizey(pc),d5
	lsr.w	#3,d5
	move.l	phy(pc),a0
	move.w	d5,d4
	add.w	d4,d4
	mulu.w	sizex(pc),d4
	move.l	a0,a1
	add.l	d4,a1
	move.l	a1,a2
	add.l	d4,a2
	move.l	a2,a3
	add.l	d4,d4
	add.l	d4,a3
	move.l	a3,a4
	add.l	d4,a4
	add.l	d4,a4
	move.l	a4,phy

	moveq	#0,d1
	move.b	$ffff8201.w,d1
	lsl.l	#8,d1
	move.b	$ffff8203.w,d1
	lsl.l	#8,d1
	move.b	low(pc),d1
	add.l	a4,d1
	sub.l	a0,d1
	moveq	#0,d0
	move.b	d1,d0
	clr.b	d1
	add.l	#256,d1
	move.b	low(pc),alow
	move.b	d1,low
	lsr.l	#8,d1
	move.b	d1,$ffff8203.w
	lsr.l	#8,d1
	move.b	d1,$ffff8201.w
	sub.w	d0,a4
	lea.l	256(a4),a4
	bsr	set_low

	subq.w	#1,d5
exg0:	
	move.w	d7,d6
exg1:	
	move.l	(a1)+,(a4)+
	dbra	d6,exg1

	move.w	d7,d6
exg2:	move.l	(a3)+,(a4)+
	dbra	d6,exg2
	
	move.w	d7,d6
exg3:	move.l	(a2)+,(a4)+
	dbra	d6,exg3
	
	move.w	d7,d6
exg4:	move.l	(a3)+,(a4)+
	dbra	d6,exg4
	
	move.w	d7,d6
exg5:	move.l	(a0)+,(a4)+
	dbra	d6,exg5
	
	move.w	d7,d6
exg6:	move.l	(a3)+,(a4)+
	dbra	d6,exg6
	
	move.w	d7,d6
exg7:	move.l	(a2)+,(a4)+
	dbra	d6,exg7
	
	move.w	d7,d6
exg8:	move.l	(a3)+,(a4)+
	dbra	d6,exg8
	
	dbra	d5,exg0
	
	
	
pas_int:	
	rts



init_string_table:
	move.w	code_size(pc),d6
	moveq	#1,d7
	lsl.w	d6,d7
	addq.w	#1,d7
	moveq	#0,d6
.ef:	
	clr.w	(a0)+
	move.w	d6,(a1)+
	clr.w	(a2)+
	addq.w	#1,d6
	dbra	d7,.ef

	lea.l	prefix(pc),a0
	lea.l	suffix(pc),a1
	lea.l	transla(pc),a2
	
	move.w	code_size(pc),d6
	moveq	#1,d7
	lsl.w	d6,d7
	addq.w	#2,d7
	move.w	d7,next_code-prefix(a0)
	
	move.w	code_size(pc),bits-prefix(a0)
	addq.w	#1,bits
	move.w	bits(pc),d6
	moveq	#1,d7
	lsl.w	d6,d7
	subq.w	#1,d7
	move.w	d7,high_value-prefix(a0)
	
	rts




	add.w	d6,d6
	move.w	(a3,d6),(a4)+
	




exist:	
	move.w	d3,d2
	bsr	translate
	move.w	tran_ptr(pc),d7
	add.w	d7,d7
.repeat:	
	move.w	(a2,d7),d6
	add.w	d6,d6
	move.w	(a3,d6),(a4)+
	subq.w	#2,d7
	bge.s	.repeat
	
	move.w	old_code(pc),prefi-prefix(a0)
	move.w	tran_ptr(pc),d7
	add.w	d7,d7
	move.w	(a2,d7),suffi-prefix(a0)
	bsr	add_code
	move.w	d3,old_code-prefix(a0)
	rts




nonexist:
	move.w	old_code(pc),d2
	bsr	translate
	move.w	old_code(pc),prefi-prefix(a0)
	move.w	tran_ptr(pc),d7
	add.w	d7,d7
	move.w	(a2,d7),suffi-prefix(a0)
.repeat:	
	move.w	(a2,d7),d6
	add.w	d6,d6
	move.w	(a3,d6),(a4)+
	subq.w	#2,d7
	bge.s	.repeat
	
	move.w	suffi(pc),d6
	add.w	d6,d6
	move.w	(a3,d6),(a4)+
	bsr	add_code
	move.w	d3,old_code-prefix(a0)
	rts



add_code:
	move.w	next_code(pc),d7
	add.w	d7,d7
	move.w	prefi(pc),(a0,d7)
	move.w	suffi(pc),(a1,d7)
	addq.w	#1,next_code-prefix(a0)
	move.w	next_code(pc),d7
	subq.w	#1,d7
	cmp.w	high_value(pc),d7
	bne.s	.endif0
	addq.w	#1,bits-prefix(a0)
	lsl.w	high_value
	addq.w	#1,high_value-prefix(a0)
	cmp.w	#13,bits-prefix(a0)
	bne.s	.endif1
	move.w	#12,bits-prefix(a0)
.endif1:	
.endif0:	
	rts






translate:	
	clr.w	tran_ptr-prefix(a0)
.once_more:
	move.w	d2,d7
	add.w	d7,d7
	move.w	tran_ptr(pc),d6
	add.w	d6,d6
	move.w	(a1,d7),(a2,d6)
.if0:	
	move.w	d2,d7
	cmp.w	eoi(pc),d7
	bls.s	.endif0
	add.w	d7,d7
	move.w	(a0,d7),d2
	addq.w	#1,tran_ptr-prefix(a0)
	bra	.once_more
.endif0:	
	rts
















fsize:			;*fname.L
	movem.l	d1-a6,-(sp)
	lea.l	56+4(sp),a6
	Fsetdta2	fdta(pc)
	Fsfirst	(a6),#0
	tst.l	d0
	blt	fini
	move.l	fdta+26(pc),d0
	movem.l	(sp)+,d1-a6
	rts		;d0=size
fdta:	ds.l	12

	
fload:			;*fname.L,*buff.L
	movem.l	d1-a6,-(sp)
	lea.l	56+4(sp),a6
	Fopen	(a6),#0
	tst.l	d0
	blt	fini
	move.l	d0,d6
	Fread	d6,#20000000,4(a6)
	tst.l	d0
	blt	fini
	move.l	d0,d7
	Fclose	d6
	move.l	d7,d0
	movem.l	(sp)+,d1-a6
	rts		;d0=size


load:			;*fname.L
	movem.l	d1-d7/a1-a6,-(sp)
	lea.l	52+4(sp),a6

	move.l	(a6),-(sp)
	bsr	fsize
	addq.w	#4,sp
	Malloc	d0
	tst.l	d0
	blt	fin
	move.l	d0,a0
	move.l	a0,-(sp)
	move.l	(a6),-(sp)
	bsr	fload
	addq.w	#8,sp

	movem.l	(sp)+,d1-d7/a1-a6
	rts		;d0=size	a0=adr



	
	DATA



texte:	dc.b	27,"E"
	dc.b	"Fast viewer, for TV or ST monitors,",13,10
	dc.b	"by AUDOLY GILLES (audoly@orque.unice.fr)",13,10
	dc.b	"reconized formats: GIF, MTV, PC1, TGA ",13,10,10
	dc.b	"keys to try:",13,10
	dc.b	"'+','-': lighten, darken",13,10
	dc.b	"arrow  : move (I'm not sure about it,",13,10
	dc.b	"        I have an old develloper Falcon)",13,10
	dc.b	"RETURN : smooth",13,10
	dc.b	"SPACE  : quit",13,10
	dc.b	"ESC    : quit",13,10
	dc.b	0
	

	


	IFEQ disk
fich:	
	dc.b	"c:\utils\zzcompro\spd\speeder.tga",0
	;dc.b	"e:\sauv_ecr.tga",0
	;dc.b	"h:\10.tga",0
	ENDC
	
	even

	BSS

mem_pal:	ds.l	256
res:	ds.w	1
phy:	ds.l	1
mfp:	ds.l	1
code_size:	ds.w	1
cc:	ds.w	1
eoi:	ds.w	1
byte_count: ds.w	1
byte_ctr:	ds.w	1
bits:	ds.w	1
high_value: ds.w	1
old_code:	ds.w	1
next_code:	ds.w	1
bv:	ds.w	1
prefi:	ds.w	1
suffi:	ds.w	1
tran_code:	ds.w	1
tran_ptr:	ds.w	1

nb_zoom:	ds.w	1
sizex:	ds.w	1
sizey:	ds.w	1
int:	ds.w	1

nbhbl:	ds.w	1
deca:	ds.w	1
pal:	ds.w	256

prefix:	ds.w	$1000
suffix:	ds.w	$1000
transla:	ds.w	$1000

low:	ds.b	1
alow:	ds.b	1
aecr:	ds.l	1
source:	ds.l	1

liste:	ds.w	1000	

;ecr0:	ds.l	640*3
;ecr:	ds.b	$200000		
	
	END



