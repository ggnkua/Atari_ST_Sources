
* TREEDO an AES tree-walker
* by: M†rten Lindstr”m

***************************
*	TREEDO
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN: A3 -> Tree, D2: Object to start with. Do it plus its offspring
*     A0 -> Sub-routine to run for each object
* At routine entry A3 will point to the tree, A2 will point to the object,
* D2 will contain the object number.
* All registers can be freely used.
* All registers EXCEPT D0 will be restored at TREEDO exit.
* D0 will contain whatever the routine sets it to; TREEDO won't touch it

TREEDO	movem.l	D1-D7/A0-A2/A4-A6,-(SP)
	moveq	#24,D1
	mulu	D2,D1
	move.w	0(A3,D1.L),D1
	bsr.s	treedo1
	movem.l	(SP)+,D1-D7/A0-A2/A4-A6
	tst.l	D0	;change to tst.w if preferred
	rts

treedo1	lea	(A3),A2
	moveq	#24,D3
	mulu	D2,D3
	add.l	D3,A2	A2-> object
	movem.l	D1-D2/A0/A2-A3,-(SP)
	jsr	(A0)
	movem.l	(SP)+,D1-D2/A0/A2-A3
	move.w	(A2)+,-(SP)	Save next sibling
	move.w	(A2),D3	D3: First child
	bmi.s	treedo2
	move.w	D1,-(SP)
	move.w	D2,D1	Let object be parent for a while
	move.w	D3,D2	Start with first child
	bsr.s	treedo1	Do the children (recursively)
	move.w	(SP)+,D1	Back to same old parent ...
treedo2	move.w	(SP)+,D2	... but do next sibling
	cmp.w	D1,D2	Make sure it isn't parent
	bne.s	treedo1
	rts

