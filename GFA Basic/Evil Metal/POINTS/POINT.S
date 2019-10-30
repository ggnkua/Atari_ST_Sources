;
; Routine de point
; Par EVIL METAL/DUNE
; Environ 1600 points en Rept ...
;
	opt	o+
	
nbdots	=	1400

	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	#$F8000,xbios2

 	move.w	#$20,-(sp)
 	trap	#1
 	addq.l	#6,sp
 	move.l	d0,savessp
	move.w	#$777,$ffff8242.w

main:	
	bsr.s	plot
	
	move.w	#$7,$ffff8240.w	
	bsr.s	vsync
	move.w	#$0,$ffff8240.w	
	
	cmpi.b	#57,$fffffc02.w
	bne.s	main

	move.w	#$0,$ffff8240.w	
	move.l	#$7770777,$ffff8244.w	
	
 	move.l  savessp,-(sp)
 	move.w  #$20,-(sp)
 	trap    #1
 	addq.l  #6,sp
	clr	-(sp)
	trap 	#1

Vsync	move.w	$468.w,d7
.1	cmp.w	$468.w,d7
	beq.s	.1
	rts

plot
	move.l	xbios2,a0		a0=ecran
	lea	deca,a3
	lea	v,a4
	lea	ytable,a5

	move.w	#nbdots-1,d7	
	lea	Xy,a1		Table coordonn‚
.dots	
	MOVEM.W	(A1)+,D2-d3
	add.w	d3,d3		Y * 2
	move.w	(a5,d3.w),d0	Y * 160
	add.w	d2,d2		X * 2
	add.w	(a3,d2.w),d0	add deca
	move.w	(a4,d2.w),d1	charge forme
	or.w	d1,(a0,d0.w) 	Affiche point
	dbf	d7,.dots		boucle
	rts
	section data

savessp	dc.l	0
xbios2	dc.l	0

deca	incbin a:\code\deca.inl	
v	incbin a:\code\v.inl	
ytable	incbin a:\code\ytable.inl		

XY	rept	nbdots
	dc.l	0
	endr
