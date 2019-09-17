
*		   --------------
*		   ¯ RSC INLINE ®
*		   --------------
*		By: M†rten Lindstr”m
*
* Routines to enable use of GEM resources incorporated in program file

***************************
*	RSCREL		Relocate RSC file
*~~~~~~~~~~~~~~~~~~~~~~~~~~
*  IN: A4 -> RSC file to be relocated
* OUT: D0: 1=No error, 0=Unknown elements in file

RSCREL	movem.l	D1-D3/A0-A1/A4,-(SP)
	move.l	A4,D1
	moveq	#1,D3	Return code: Initiate to no error

	moveq	#0,D0
	lea	(A4),A0
	move.w	4(A4),D0
	add.l	D0,A0	A0->TEDINFOs
	move.w	24(A4),D0	D0: Number of TEDINFOs
	bra.s	rscrel2
rscrel1	add.l	D1,(A0)+
	add.l	D1,(A0)+
	add.l	D1,(A0)+
	lea	16(A0),A0
rscrel2	dbf	D0,rscrel1

	lea	(A4),A0
	move.w	6(A4),D0
	add.l	D0,A0	A0->ICONBLKs
	move.w	26(A4),D0	D0: Number of ICONBLKs
	bra.s	rscrel4
rscrel3	add.l	D1,(A0)+
	add.l	D1,(A0)+
	add.l	D1,(A0)+
	lea	22(A0),A0
	tst.l	(A0)
	bne.s	rscrel4
	addq.l	#2,A0
rscrel4	dbf	D0,rscrel3

	lea	(A4),A0
	move.w	8(A4),D0
	add.l	D0,A0	A0->BITBLKs
	move.w	28(A4),D0	D0: Number of BITBLKs
	bra.s	rscrel6
rscrel5	add.l	D1,(A0)+
	lea	10(A0),A0
	tst.l	(A0)
	bne.s	rscrel6
	addq.l	#2,A0
rscrel6	dbf	D0,rscrel5

	lea	(A4),A0
	move.w	10(A4),D0
	add.l	D0,A0	A0->free strings
	move.w	30(A4),D0	D0: Number of free strings
	bra.s	rscrel8
rscrel7	add.l	D1,(A0)+
rscrel8	dbf	D0,rscrel7

	lea	(A4),A0
	move.w	16(A4),D0
	add.l	D0,A0	A0->free images
	move.w	32(A4),D0	D0: Number of free images
	bra.s	rscrel10
rscrel9	add.l	D1,(A0)+
rscrel10	dbf	D0,rscrel9

	lea	(A4),A0
	move.w	18(A4),D0
	add.l	D0,A0	A0->trees
	move.w	22(A4),D0	D0: Number of trees
	bra.s	rscrel12
rscrel11	add.l	D1,(A0)+
rscrel12	dbf	D0,rscrel11

	lea	(A4),A0
	move.w	2(A4),D0
	add.l	D0,A0	A0->Objects
	move.w	20(A4),D0	D0: Number of objects
	bra.s	rscrel16
rscrel13	moveq	#0,D3	Unknown object type
	bra.s	rscrel15
rscrel14	moveq	#-20,D2	Relocate next object
	add.b	7(A0),D2	Object basic type -20
	beq.s	rscrel15	G_BOX
	bmi.s	rscrel13
	subq.b	#5,D2
	beq.s	rscrel15	G_IBOX
	subq.b	#2,D2
	beq.s	rscrel15	G_BOXCHAR
	subq.b	#6,D2
	bgt.s	rscrel13	Greater than G_CICON => unknown
	add.l	D1,12(A0)
rscrel15	lea	24(A0),A0
rscrel16	dbf	D0,rscrel14

* Uncomment the following if you use colour icons for TOS 4+
* - - - - - - - - - - - - -  Relocate any TOS 4+ extension
*	moveq	#4,D0
*	and.w	(A4),D0
*	beq.s	rscrel25
*	move.w	34(A4),D0
*	add.l	D0,A4
*	addq.l	#4,A4
*	lea	(A4),A0
*	move.l	(A0),D2
*	bgt.s	rscrel18
*rscrel17	move.l	(A0),D2  Relocate extension header pointer table
*	ble.s	rscrel19
*	moveq	#0,D3
*rscrel18	add.l	D1,D2
*rscrel19	move.l	D2,(A0)+
*	bne.s	rscrel17
*	move.l	(A4),A0	A0-> pointer table
*	move.l	A0,D2
*	ble.s	rscrel25
** - - - - - - - - - - - - - Set pointers in CICONBLKs and related structures
*	lea	(A0),A4
*
*	moveq	#-1,D2
*rscrel20	addq.w	#1,D2	Forward A0 to end of pointer table
*	tst.l	(A0)+	and count number of CICONBLKs
*	bpl.s	rscrel20
*	bra.s	rscrel24	D2: Number of CICONBLKs
*
*rscrel21	move.l	A0,(A4)+	Do CICONBLK. A0: Pointer to CICONBLK
*	move.w	22(A0),D1
*	lsr.w	#3,D1
*	mulu	24(A0),D1	D1: bytes per plane
*	lea	38(A0),A1
*	move.l	A1,(A0)+	Pointer to mono data
*	add.l	D1,A1
*	move.l	A1,(A0)+	Pointer to mono mask
*	add.l	D1,A1
*	move.l	A1,(A0)+	Pointer to icon text
*	lea	12(A1),A1
*	lea	22(A0),A0
*
*rscrel22	exg	A0,A1	Do CICON
*	tst.l	(A1)
*	beq.s	rscrel24	No CICON
*	move.l	A0,(A1)	A0: Pointer to CICON
*	move.w	(A0)+,D0
*	lea	20(A0),A1
*	move.l	A1,(A0)+	Pointer to unselected image
*	mulu	D1,D0	D0: bytes in image, assuming
*	add.l	D0,A1	less than 32K/plane
*	move.l	A1,(A0)+	Pointer to unselected mask
*	add.l	D1,A1
*	tst.l	(A0)
*	bne.s	rscrel23
*	addq.l	#8,A0
*	bra.s	rscrel22
*rscrel23	move.l	A1,(A0)+	Pointer to selected image
*	add.l	D0,A1
*	move.l	A1,(A0)+	Pointer to selected mask
*	add.l	D1,A1
*	bra.s	rscrel22
*
*rscrel24	dbf	D2,rscrel21
* - - - - - - - - - - - - -

rscrel25	movem.l	(SP)+,D1-D3/A0-A1/A4
	move.l	D3,D0
	rts


***************************
*    RSCFIX, TREEFIX	Convert character coordinates
*~~~~~~~~~~~~~~~~~~~~~~~~~~	into pixels
* IN: A4 -> RSC file
*  or A3 -> TREE,	respectively

RSCFIX	movem.l	D1/A1/A3,-(SP)
	lea	(A4),A1
	moveq	#0,D1
	move.w	18(A4),D1
	add.l	D1,A1	A1-> Table of pointers to trees
	move.w	22(A4),D1	D1: Number of trees
	bra.s	rscfix2
rscfix1	move.l	(A1)+,A3
	bsr.s	TREEFIX
rscfix2	dbf	D1,rscfix1
	movem.l	(SP)+,D1/A1/A3
	rts

*==========================
TREEFIX	movem.l	D0-D3/A0-A2,-(SP)
	moveq	#0,D3
treefix1	rsrc_obfix A3,D3
	moveq	#24,D0
	mulu	D3,D0
	addq.w	#1,D3
	btst	#5,9(A3,D0.W)	Last object?
	beq.s	treefix1
	movem.l	(SP)+,D0-D3/A0-A2
	rts

* Alternative version making use of TREEDO below:
*TREEFIX	movem.l	D0/D2/A0,-(SP)
*	lea	treefix1(PC),A0	To do for each object
*	moveq	#0,D2	Begin with root
*	bsr.s	TREEDO
*	movem.l	(SP)+,D0/D2/A0
*	rts
*treefix1	rsrc_obfix A3,D2
*	rts

***************************
*	TREEDO
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN: A3 -> Tree, D2: Object to start with. Do it plus its offspring
*     A0 -> Sub-routine to run for each object
* At routine entry A3 will point to the tree, A2 will point to the object,
* D2 will contain the object number.
* All registers can be freely used.
* All registers EXCEPT D0 will be restored at TREEDO exit.
* D0 will contain whatever the routine sets it to, TREEDO won't touch it

TREEDO	movem.l	D1-D7/A0-A2/A4-A6,-(SP)
	moveq	#24,D1
	mulu	D2,D1
	move.w	0(A3,D1.L),D1
	bsr.s	treedo1
	movem.l	(SP)+,D1-D7/A0-A2/A4-A6
	tst.l	D0
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

***************************
*	GETTREE		Get tree address
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN: A4 -> RSC file, D3.W: Tree number
* OUT: A3 -> Tree, D0: 1=OK, 0 = Tree with this high number doesn't exist

GETTREE	cmp.w	22(A4),D3
	bcc.s	gettree1	error
	lea	(A4),A3
	moveq	#0,D0
	move.w	18(A4),D0
	add.l	D0,A3	A3-> Table of pointers to trees
	move.w	D3,D0
	lsl.w	#2,D0
	add.w	D0,A3
	move.l	(A3),A3	A3-> Tree
	moveq	#1,D0
	rts
gettree1	moveq	#0,D0
	rts
