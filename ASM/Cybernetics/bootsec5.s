*-------------------------------------------------------------------------*
*									  *
*	BOOT SECTOR 'RELAPSE I INSERT'		- CYBERNETICS 1992 -	  *
*									  *
*-------------------------------------------------------------------------*

*-------------------------------------------------------------------------*
system:	set	1
cpu:	set	1
d:	set	6
dep:	set	127
*-------------------------------------------------------------------------*

	output	e:\code\effects.grx\bootsecs\insert.inl
	
	ifne	system
	clr.w	-(sp)			* Resolution
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	clr.l	-(sp)			* Superviseur
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp

	move.l	$fffffa06.w,oldtim	* Sauvegarde timers
	move.l	$70.w,oldvbl		* & vbl
	move.b	#2,$ffff820a.w		* Synchro … 50 hz
	endc

	lea	vbl(pc),a0		* Fixe new vbl
	move.l	a0,$70.w		*
	clr.l	$fffffa06.w		* Timers off

	ifne	system
	lea	ecran(pc),a1
	else
	lea	32700.w,a1		*
	endc

	move.l	a1,base+2-vbl(a0)	*


	opt	o+,a+,p+
					*--------------------------*
					*  DEBUT BOOT
					*--------------------------*

	lea	160.w,a5
	moveq.l	#-1,d0			*

eff:	clr.b	(a1)+			* Efface ecran 2
	dbra.w	d0,eff			*

	lea	data(pc),a3
	lea	base+2+6(pc),a1
	move.w	#-2000,d7
	moveq.l	#findata-data-1,d2
calcul:	move.b	(a3)+,d0
	bpl.s	minus
	add.w	#34*8,d7
	cmp.b	#-64,d0
	beq.s	saut
minus:
	move.w	d0,d1
	and.w	#7,d0
	asl.w	#5,d0
	add.w	d7,d0
	move.w	d0,(a1)+

	and.w	#$78,d1
	asl.w	#3,d1
	sub.w	#64*2,d1
	move.w	d1,(a1)+

saut:	dbra.w	d2,calcul
	clr.l	(a1)+

main:					**** MAIN LOOP
	stop	#$2300			* Vsync

	ifne	cpu
	move.w	#7,$ffff8240.w
	endc

	moveq.l	#dep,d0
	lea	base+2+4(pc),a1		* Gestion Z
	subq.w	#1,(a1)
	bgt.s	okprof
	move.w	d0,(a1)
	eor.w	#$111,(a3)
okprof:
	move.w	#dep+dep/6*2,d0
	sub.w	(a1),d0
	divu.w	#dep/6,d0
	mulu.w	(a3),d0
	move.w	d0,$ffff8242.w

	move.l	$44e.w,a6		* Flip ecran
	move.l	base+2(pc),d0
	move.l	d0,$44e.w
	move.l	a6,-(a1)
	lea	$ffff8203.w,a0
	movep.l	d0,(a0)

	moveq.l	#8,d7			
	moveq.l	#7,d0
rast:	moveq.l	#1,d2
twice:	move.w	#294,d1
temp2:	dbra.w	d1,temp2
 	eor.w	d7,d0
	move.w	d0,$ffff8240.w
	dbra.w	d2,twice
	dbra.w	d0,rast
					**** EFFACEMENT
 	moveq.l	#-1,d0			*
	lea	$ffff8a28.w,a0		*
 	move.l	d0,(a0)+		* Init blitter
 	move.w	d0,(a0)+		* Init blitter
	move.w	d7,(a0)+		* Inc X
	move.w	d7,(a0)+		* Inc Y dest
	move.l	a6,(a0)+		*
	move.l	#20*65536+200,(a0)+	*
	clr.w	(a0)+			*
	move.w	#%11000000*256,(a0)	*
					**** TRACAGE

	move.b	d0,-(a0)		* Hog + combi log (Bits '1')
	addq.w	#6,a1
repeat:
	ifne	cpu
	move.w	#$4,$ffff8240.w
	endc

	move.l 	a6,a0			* Adresse ecran

	bsr.s	calc
	move.w	d4,d0
	add.w	a5,d0

	bsr.s	calc
	move.w	d4,d1
	add.w	#100,d1

	bsr.s	calc
	move.w	d4,d2
	add.w	a5,d2

	bsr.s	calc
	add.w	#100,d4
	
	ifne	cpu
	move.w	#$6,$ffff8240.w
	endc

	bsr.s	rect1plane		* Un ptit rectangle ??

	tst.l	(a1)			* Boucle
	bne.s	repeat			*

	ifne	cpu
	clr.w	$ffff8240.w
	endc
	
	ifne	system
	cmp.b	#185,$fffffc02.w
	bne	main
	else
	bra	main
	endc
	
	ifne	system
	move.b	#0,$ffff820a.w			* Synchro … 50 hz
	move.l	oldtim(pc),$fffffa06.w		* Restaure timers
	move.l	oldvbl(pc),$70.w		* Restaure vbl
	clr.w	-(sp)				* Fin
	trap	#1
oldtim:	dc.l	0				* 
oldvbl:	dc.l	0				*
	endc

*-------------------------------------------------------------------------*
vbl:	rte					* New vbl
*-------------------------------------------------------------------------*

calc:	move.w	(a1)+,d4
	muls.w	#d,d4
	divs.w	base+2+4(pc),d4
dadu:	rts

rect1plane:

	tst.w	d0			* Si x1 < 0
	bpl.s	.okh1			*
 	tst.w	d2			*   Si x2 < 0 Alors no rectangle
	bmi.s	dadu			*   Sinon
	moveq.l	#0,d0			*     x1 = 0
.okh1: 					*   Finsi
					* Finsi
					
	move.w	#319,d7			* Precharge #319 dans d7
	cmp.w	d7,d2			* Si x2 > 319
	ble.s	.okh2			*
	cmp.w	d7,d0			*   Si x1 > 319 Alors
	bgt.s	dadu			*     no rectangle
	move.w	d7,d2			*   Sinon x2 = 319
					*   Finsi
.okh2:					* Finsi

	tst.w	d1			* Si y1 < 0
	bpl.s	.okv1			*
 	tst.w	d4			*   Si y2 < 0 Alors no rectangle
	bmi.s	.norect			*   Sinon
	moveq.l	#0,d1			*     x1 = 0
.okv1: 					*   Finsi
					* Finsi
			
	move.w	#199,d7			* Precharge #199 dans d7
	cmp.w	d7,d4			* Si y2 > 199
	ble.s	.okv2			*
	cmp.w	d7,d1			*   Si y1 > 199 Alors
	bgt.s	.norect			*     no rectangle
	move.w	d7,d4			*   Sinon y2 = 199
					*   Finsi
.okv2:					* Finsi

	sub.w	d1,d4			*
	addq.w	#1,d4			* Hauteur
	
	mulu.w	#160,d1			* Adr affichage + y1 * 160
	add.w	d1,a0			*
	
	moveq.l	#$fffffff0,d7
	move.w	d0,d6			* Adr affichage + offset horizontal
	and.w	d7,d6			*
	lsr.w	#1,d6			*
	add.w	d6,a0			*
	
	move.w	d2,d3			* Adr affichage + offset horizontal
	and.w	d7,d3			*
	lsr.w	#1,d3			*
	sub.w	d6,d3			*
	move.w	a5,d6			* Calcul 
	sub.w	d3,d6			*
	move.w	d6,$ffff8a30.w		* Inc Y dest
	lsr.w	#3,d3			* Nombre de mots	
	
	moveq.l	#0,d6			*
	moveq.l	#15,d1			*
	and.w	d1,d0			*
	sub.w	d0,d1			*
	bset.l	d1,d6			*
	subq.l	#1,d6			*

	moveq.l	#0,d7			*
	moveq.l	#15,d1			*
	and.w	d1,d2			*
	sub.w	d2,d1			*
	bset.l	d1,d7			*
	subq.l	#1,d7			*
	not.w	d7			*
	move.w	d7,$ffff8a2c.w		* Masque droit

	move.l	a0,$ffff8a32.w		* Adresse dest
	tst.w	d3
	bne.s	.oklarg			* Si largeur en nb mots = 0 Alors
	and.w	d7,d6			*   Masque gauche and masque droit
.oklarg:				*   blitter de masque gauche
	
	move.w	d6,$ffff8a28.w		* Masque gauche
	addq.w	#1,d3			* Finsi	
	movem.w	d3-d4,$ffff8a36.w	* Hori size & Vert size
	move.w	#%11000000*256,$ffff8a3c.w	* No partage & Go !
	
.norect:
	rts				* Retour



data:	dc.b	0*8+3,7*8+4		* 'I'
	dc.b	0*8+1,1*8+6
	dc.b	6*8+1,7*8+6

	dc.b	128+0*8+0,7*8+1		* 'N'
	dc.b	0*8+6,7*8+7
	dc.b	1*8+1,2*8+2
	dc.b	2*8+2,3*8+3
	dc.b	3*8+3,4*8+4
	dc.b	4*8+4,5*8+5
	dc.b	5*8+5,6*8+6
	
	dc.b	128+0*8+0,1*8+7		* 'S'
	dc.b	1*8+0,3*8+1
	dc.b	3*8+0,4*8+7
	dc.b	4*8+6,6*8+7
	dc.b	6*8+0,7*8+7
	
	dc.b	128+0*8+0,1*8+7		* 'E'
	dc.b	1*8+0,6*8+1
	dc.b	6*8+0,7*8+7
	dc.b	3*8+1,4*8+6

	dc.b	128+0*8+0,1*8+7		* 'R'
	dc.b	1*8+0,7*8+1
	dc.b	3*8+0,4*8+7
	dc.b	4*8+5,5*8+6
	dc.b	5*8+6,7*8+7
	dc.b	1*8+6,3*8+7
	
	dc.b	128+0*8+0,1*8+7		* 'T'
	dc.b	0*8+3,7*8+4
	
	dc.b	-128+64
	
	dc.b	128+0*8+0,1*8+6		* 'D'
	dc.b	1*8+0,6*8+1
	dc.b	6*8+0,7*8+6
	dc.b	1*8+6,6*8+7

	dc.b	128+0*8+3,7*8+4		* 'I'
	dc.b	0*8+1,1*8+6
	dc.b	6*8+1,7*8+6

	dc.b	128+0*8+0,1*8+7		* 'S'
	dc.b	1*8+0,3*8+1
	dc.b	3*8+0,4*8+7
	dc.b	4*8+6,6*8+7
	dc.b	6*8+0,7*8+7

	dc.b	128+0*8+0,7*8+1		* 'K'
	dc.b	3*8+1,4*8+3
	dc.b	2*8+2,3*8+3
	dc.b	1*8+3,2*8+4
	dc.b	0*8+4,1*8+6
	dc.b	4*8+3,5*8+4
	dc.b	5*8+4,6*8+5
	dc.b	6*8+5,7*8+6
	
	dc.b	-128+64
	
	dc.b	128+0*8+1,7*8+2		* '1'
	dc.b	1*8+0,2*8+1

findata:	
	
base:	dc.w	$100
	
	Section	bss

	ifne	system
	ds.l	2000
	endc

	ifne	system
ecran:	ds.b	65536
	endc