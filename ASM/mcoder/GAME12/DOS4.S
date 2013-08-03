;
; mini-dos
;
; V1.4 10/09/89 optimisation de place avec move (A7)+,d0
;
;	- g‚rer sur VBL l'extinction de la diode
;	- variables DRIVE et NBSIDE en $100 (r‚sistent au RESET)
;
step	equ	3

adload	ds.l	1	;adresse de chargement
track	ds.w	1	;piste courante ou destination
sector	ds.w	1	;secteur … charger
nbsec	ds.w	1	;nb secteurs … charger

*****************************************************************
*								*
* NE PAS TOUCHER AUX 4 VARIABLES SUIVANTES (RUSE AVEC MOVE.L)	*
*								*
*****************************************************************

nberr	ds.b	1	;nbr d'erreurs avant restore
;			prend les valeurs :
;			0,$20,$40,$60,$80,$a0,$c0,$e0
nbrest	ds.b	1	;nbr de restore autoris‚s
;			prend les valeurs :
;			0,$40,$80,$C0
;
errdisk	ds.b	1	;num‚ro erreur
type	ds.b	1

	even
;
; type :
;	0=load sector
;	$ff=goto track
;	1=crc correction (restore et seek)
;
; errdisk :
;	0=chargement en cours
;	1=CRC error
;	2=record not found
;	-1=chargement termin‚ sans erreur
;
senddisk
	st	eteint\w		;ne plus toucher … la diode

	move.b	#$E,$FFFF8800.W
	move.b	drive\w,$FFFF8802.W

	move	#$90,$FFFF8606.W
	move	#$190,$FFFF8606.W
	move	#$90,$FFFF8606.W
	move.b	adload+3\w,$FFFF860D.W
	move.b	adload+2\w,$FFFF860B.W
	move.b	adload+1\w,$FFFF8609.W

	tst.b	initialise\w
	beq.s	reinit
	move	#$86,$FFFF8606.W
	move	track\w,$FFFF8604.W
	move	#$80,$FFFF8606.W
;	st	type\w
;	clr.b	errdisk\w
;	clr.b	nbrest\w
;	clr.b	nberr\w
	move.l	#$000000FF,nberr\w

	move	#$10+step,$ffff8604.w
	RTS
reinit
	move	#$80,$FFFF8606.W
;	move.b	#1,type\w
;	clr.b	errdisk\w
;	clr.b	nbrest\w
;	clr.b	nberr\w
;	move.l	#$00000001,nberr\w
	moveq	#1,d0
	move.l	d0,nberr\w

	move	#step,$ffff8604.w
	RTS
erreur1
	move.b	#1,errdisk\w
	rte
crccorec
	move	(A7)+,d0
	add.b	#$20,nberr\w
	bcs.s	erreur1
	move.b	adload+3\w,$FFFF860D.W
	move.b	adload+2\w,$FFFF860B.W
	move.b	adload+1\w,$FFFF8609.W
	add.b	#$40,nbrest\w
	bcc.s	reload
	move.b	#1,type\w
	move	#step,$FFFF8604.W
	rte
stepin
	st	type\w
	clr	sector\w
	cmp	#82,track\w
	bhs.s	erreur2

	move	#$50+step,$FFFF8604.W
	addq	#1,track\w
	rte
interdisk
	move	d0,-(A7)

	move	$FFFF8604.W,d0
	asl.b	#4,d0
	bcs.s	erreur3

	tst.b	type\w
	bne.s	paload

	tst.b	d0
	bmi.s	crccorec

	move	(A7)+,d0

	add.l	#$400,adload\w
	subq	#1,nbsec\w
	beq.s	finload
;	clr.b	nbrest\w
;	clr.b	nberr\w
	clr.w	nberr\w

	addq	#1,sector\w
	cmp	#5,sector\w
	bhs.s	stepin
reload
	move	#$84,$FFFF8606.W
	move	sector\w,$FFFF8604.W
	move	#$90,$FFFF8606.W
	move	#2,$FFFF8604.W
	move	#$80,$FFFF8606.W
	clr.b	type\w
	move	#$80,$FFFF8604.W
	rte
finload	st	errdisk\w
	rte
erreur3	move	(A7)+,d0
erreur2	move.b	#2,errdisk\w
	rte
paload
	tst.b	d0
	bmi.s	erreur3

	move	(A7)+,d0

	tst.b	type\w
	bmi.s	reload
	move	#$86,$FFFF8606.W
	move	track\w,$FFFF8604.W
	st	initialise\w
	move	#$80,$FFFF8606.W
	st	type\w
	move	#$10+step,$FFFF8604.W
	rte
