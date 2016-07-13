*** merci pour la routine de mul en long xaz...

*---------------------------------------------------------------*
* Routine de multiplication de 2 ULONG
* Pr‚ : d0.l et d1.l -> valeurs … multiplier
* Post : d0.l : r‚sultat (=$FFFFFFFF en cas d'overflow
xmul	macro	reg1,reg2
	move.l	d1,-(sp)
	move.l	\1,d0
	move.l	\2,d1
	bsr		xmul_routine
	move.l	d0,\2
	move.l	(sp)+,d1
	endm

xmul_routine
	move.l	d2,-(sp)
	swap	d0
	swap	d1

	tst.w	d0		Teste MSW
	beq.s	D0inf10000	d0 < $1 0000

	exg.l	d0,d1

	tst.w	d0		Teste MSW autre valeur
	bne.s	FinOverflow	>$1 0000 => Overflow

D0inf10000
	move.w	d2,-(sp)	On sauve d2.w

	swap	d0		d0.w -> valeur 1
	move.w	d1,d2		d2.w -> MSW valeur 2
	swap	d1		d1.w -> LSW valeur 2

	mulu.w	d0,d1		d1.l -> Partie basse
	mulu.w	d2,d0		d0.l -> Partie haute / $1 0000

	move.w	(sp)+,d2	Restauration

	swap	d0		d0 = d0 * $1 0000
	tst.w	d0		Overflow ?
	bne.s	FinOverflow	Oui

	add.l	d1,d0		On ajoute les 2 parties
	bhs.s	FinMyMulu	Overfow ?

FinOverflow
	moveq.l	#-1,d0		On renvoie $FFFF FFFF

FinMyMulu
	move.l	(sp)+,d2
	rts
