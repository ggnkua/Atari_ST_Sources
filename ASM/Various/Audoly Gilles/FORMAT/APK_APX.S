disk=1
	include	"d:\include\gemdos.s"
lzw_max=4096
	
dprg:	
	move.l	4(sp),a5
	move.l	12(a5),d0
	add.l	20(a5),d0
	add.l	28(a5),d0
	add.l	#256,d0
	Mshrink a5,d0
	lea.l	$81(a5),a5
	IFEQ disk
	lea.l	fich(pc),a5
	ENDC
	move.l	a5,-(sp)
	bsr	load
	addq.w	#4,sp
	move.l	a0,adresse
	move.l	a0,a6
	movem.l	entete(pc),d0-d2
	cmp.l	(a0),d0
	bne	fin
	cmp.l	4(a0),d1
	bne	fin
	cmp.l	8(a0),d2
	bne	fin
	
	add.w	#12,a6
	move.w	(a6)+,d6
	move.w	d6,entete+12
	move.w	(a6)+,d7
	move.w	d7,entete+14
	addq.l	#4,a6
	
	
	mulu.w	d7,d6

	move.l	a5,a4
ch_fin:	
	tst.b	(a4)+
	bne.s	ch_fin
ch_pt:	
	cmp.b	#".",-(a4)
	bne.s	ch_pt
	addq.w	#1,a4
	move.l	(a4),d0
	or.l	#$20202020,d0
	cmp.l	#"apk ",d0
	bne	fin
	move.b	#"A",(a4)+
	move.b	#"P",(a4)+
	move.b	#"X",(a4)+
	clr.b	(a4)+
	Fcreate	a5,#0
	move.l	d0,d7
	Fwrite2	d7,#20,entete(pc)





	move.l	d6,d0
	add.l	d0,d0
	Malloc	d0
	move.l	d0,a0
	move.l	a0,a5
	move.l	a0,adresse

	move.l	(a6)+,d0
	move.l	a6,a4
	add.l	d0,a6
	
	Malloc	d6
	move.l	d0,a0
	
	move.w	#31,-(sp)
	pea.l	(a0)
	pea.l	(a4)
	bsr	lzw_depack
	move.l	a0,-(sp)
	Mfree	a4
	move.l	(sp)+,a0
	
n set 16
	move.l	a5,a4
	move.l	a0,a1
	move.l	d6,d0
	subq.l	#2,d0
	moveq	#$1f,d2
	move.b	(a1)+,d1
	moveq	#0,d3
	move.b	d1,d3
	and.w	d2,d3
	move.w	d3,(a4)+
.extr0:	
	add.b	(a1)+,d1
	moveq	#0,d3
	move.b	d1,d3
	and.w	d2,d3
	move.w	d3,(a4)+
	subq.l	#1,d0
	bge.s	.extr0
	
	
	Mfree	a0
	
	
	move.l	(a6)+,d0
	move.l	a6,a4
	add.l	d0,a6
	
	Malloc	d6
	move.l	d0,a0
	
	move.w	#63,-(sp)
	pea.l	(a0)
	pea.l	(a4)
	bsr	lzw_depack
	move.l	a0,-(sp)
	Mfree	a4
	move.l	(sp)+,a0
	
	move.l	a5,a4
	move.l	a0,a1
	move.l	d6,d0
	subq.l	#2,d0
	moveq	#$3f,d2
	move.b	(a1)+,d1
	moveq	#0,d3
	move.b	d1,d3
	and.w	d2,d3
	lsl.w	#5,d3
	or.w	d3,(a4)+
.extr1:	
	add.b	(a1)+,d1
	moveq	#0,d3
	move.b	d1,d3
	and.w	d2,d3
	lsl.w	#5,d3
	or.w	d3,(a4)+
	subq.l	#1,d0
	bge.s	.extr1
	
	Mfree	a0	
	
	
	move.l	(a6)+,d0
	move.l	a6,a4
	add.l	d0,a6
	
	Malloc	d6
	move.l	d0,a0
	
	move.w	#31,-(sp)
	pea.l	(a0)
	pea.l	(a4)
	bsr	lzw_depack
	move.l	a0,-(sp)
	Mfree	a4
	move.l	(sp)+,a0
	
	move.l	a5,a4
	move.l	a0,a1
	move.l	d6,d0
	subq.l	#2,d0
	moveq	#$1f,d2
	moveq	#11,d4
	move.b	(a1)+,d1
	moveq	#0,d3
	move.b	d1,d3
	and.w	d2,d3
	lsl.w	d4,d3
	or.w	d3,(a4)+
.extr2:	
	add.b	(a1)+,d1
	moveq	#0,d3
	move.b	d1,d3
	and.w	d2,d3
	lsl.w	d4,d3
	or.w	d3,(a4)+
	subq.l	#1,d0
	bge.s	.extr2
	
	
	Mfree	a0


	add.l	d6,d6
	Fwrite	d7,d6,adresse
	

	Fclose	d7
	
	
fin:
fini0:	
	Term


fsize:			;*fname.L
	movem.l	d1-a6,-(sp)
	lea.l	56+4(sp),a6
	Fsetdta2	fdta(pc)
	Fsfirst	(a6),#0
	tst.l	d0
	blt	fini0
	move.l	fdta+26(pc),d0
	movem.l	(sp)+,d1-a6
	rts		;d0=size
fdta:	ds.l	12

	
fload:			;*fname.L,*buff.L
	movem.l	d1-a6,-(sp)
	lea.l	56+4(sp),a6
	Fopen	(a6),#0
	tst.l	d0
	blt	fini0
	move.l	d0,d6
	Fread	d6,#20000000,4(a6)
	tst.l	d0
	blt	fini0
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
	move.l	d0,a0
	move.l	a0,-(sp)
	move.l	(a6),-(sp)
	bsr	fload
	addq.w	#8,sp

	movem.l	(sp)+,d1-d7/a1-a6
	rts		;d0=size	a0=adr




;********************************************************************
;*                                                                  *
;*  d‚compresse en lzw                                              *
;*                                                                  *
;********************************************************************

lzw_depack:			;src.L,dest.L,fin_src.L,max.W
	movem.l	d0-a6,-(sp)
n set 60+4
	move.l	n(sp),a0
	move.l	n+4(sp),a1
	lea.l	index,a2
	lea.l	buffer,a3
	move.w	n+8(sp),d0
	move.w	d0,d7
	addq.w	#1,d7	;d7=nb d'elts dans la table
	moveq	#0,d1
.mk:	
	move.w	#-1,(a3)+	;valeur
	move.w	d1,(a3)+	;valeur
	addq.w	#1,d1
	dbra	d0,.mk
	
	move.l	(a0)+,d1	;taille dest
	subq.l	#1,d1
	
	move.l	(a0)+,d6

	moveq	#16,d3
		
	bfffo	d7{16:16},d4
	sub.w	#32,d4
	neg.w	d4
	bfextu	d6{0:d4},d0
	move.w	d4,d5
	
	move.b	d0,(a1)+
	move.w	d0,(a3)+
	clr.b	(a3)+
	lea.l	buffer,a2
lzwd0:	
	addq.w	#1,d7
	cmp.w	#lzw_max,d7
	blo.s	.ouf

; pas de bol, il faut r‚initialiser la table !
	lea.l	index,a2
	lea.l	buffer,a3
	move.w	n+8(sp),d0
	move.w	d0,d7
	addq.w	#1,d7	;d7=nb d'elts dans la table
	moveq	#0,d4
.mk:	
	move.w	#-1,(a3)+	;valeur
	move.w	d4,(a3)+	;valeur
	addq.w	#1,d4
	dbra	d0,.mk

	bfffo	d7{16:16},d4
	sub.w	#32,d4
	neg.w	d4
	bfextu	d6{d5:d4},d0
	move.w	d4,d5
	
	move.b	d0,(a1)+
	move.w	d0,(a3)+
	clr.b	(a3)+
	lea.l	buffer,a2
	subq.l	#1,d1
	bgt.s	lzwd0
	bra	lzwd1
	
.ouf:
	bfffo	d7{16:16},d4
	sub.w	#32,d4
	neg.w	d4
	bfextu	d6{d5:d4},d0
	add.w	d4,d5
	cmp.w	d3,d5	;d3=16
	blo.s	.pas_lire
	swap	d6
	move.w	(a0)+,d6
	sub.w	d3,d5	;d3=16
.pas_lire:	
	move.w	d7,d4
	subq.w	#1,d4
	cmp.w	d4,d0
	bhi	lzwd1
	bne.s	.tant_mieu
	move.w	d0,d2	;cas o— l'on utilise l'entr‚e pr‚c‚dante
			;qui n'est pas encore complŠtement d‚finie
	move.l	(a2,d2.w*4),d2
	blt.s	.fin_phrase0
.loop0:	swap	d2
	move.l	(a2,d2.w*4),d2
	bge.s	.loop0
.fin_phrase0:
	move.b	d2,(a3)
.tant_mieu:	
	move.w	d0,d2	;prochain elt … ajouter dans la table
	move.l	a1,a5	;a5=memoire de a1
	
	REPT 11
	move.l	(a2,d0.w*4),d0
	blt.s	.fin_phrase
	move.b	d0,(a1)+
	swap	d0
	ENDR
	move.l	(a2,d0.w*4),d0
	blt.s	.fin_phrase
.loop:	move.b	d0,(a1)+
	swap	d0
	move.l	(a2,d0.w*4),d0
	bge.s	.loop
.fin_phrase:
	move.b	d0,(a1)+
	move.b	d0,(a3)+	;pour completer
	move.l	a1,d4
.next:	
	move.b	(a5),d0
	move.b	-(a1),(a5)+
	move.b	d0,(a1)
	cmp.l	a1,a5
	blo.s	.next
	move.l	d4,a1
	move.w	d2,(a3)+
	clr.b	(a3)+
	
	subq.l	#1,d1
	bgt	lzwd0
lzwd1:
	movem.l	(sp)+,d0-a6
	rtd	#10









	DATA
	
	IFEQ disk
fich:	dc.b	"e:\speeder\menu0.blp",0
	ENDC
	even
entete:	
	dc.b	"WordPerPixel"
	dc.w	0,0,0,0

texte1:	dc.b	"rouge",13,10,0
texte2:	dc.b	"vert",13,10,0
texte3:	dc.b	"bleu",13,10,0
	BSS

adresse:	ds.l	1
adresse2:	ds.l	1
index:	ds.l	2*256
buffer:	ds.l	100000


	END	


