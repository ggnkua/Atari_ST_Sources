
*		   --------------
*		   ¯ RSC INLINE ®
*		   --------------
*		By: M†rten Lindstr”m
*
* Routines to enable the embedding of a GEM resource in the program file.


***************************
*	RSCFIX		Relocate RSC file
*~~~~~~~~~~~~~~~~~~~~~~~~~~
*  IN: A4 -> RSC file to be relocated

RSCFIX	movem.l	D0-D3/A0-A2/A4,-(SP)
	move.w	20(A4),D3	D3: Number of objects
	moveq	#0,D0	Clear upper word of D0
	move.w	2(A4),D0	Read unsigned word offset
	adda.l	D0,A4	A4->Objects
	bra.s	rscfix2
rscfix1	rsrc_obfix A4,#0	Fix coordinates of object
	lea	24(A4),A4	before moving on to the next one.
rscfix2	dbf	D3,rscfix1

	movem.l	(SP)+,D0-D3/A0-A2/A4
	rts


***************************
*	RSCREL		Relocate RSC file
*~~~~~~~~~~~~~~~~~~~~~~~~~~
*  IN: A4 -> RSC file to be relocated
* OUT: D0: 1=No error, 0=Unknown elements in file

RSCREL	movem.l	D1-D5/A0-A4,-(SP)
	move.l	A4,D4
	moveq	#1,D5	Return code: Initialize to no error
	moveq	#0,D3	Clear upper word of D3

	lea	(A4),A3
	move.w	4(A4),D3
	add.l	D3,A3	A3->TEDINFOs
	move.w	24(A4),D3	D3: Number of TEDINFOs
	bra.s	rscrel2
rscrel1	add.l	D4,(A3)+
	add.l	D4,(A3)+
	add.l	D4,(A3)+
	lea	16(A3),A3
rscrel2	dbf	D3,rscrel1

	lea	(A4),A3
	move.w	6(A4),D3
	add.l	D3,A3	A3->ICONBLKs
	move.w	26(A4),D3	D3: Number of ICONBLKs
	bra.s	rscrel4
rscrel3	add.l	D4,(A3)+
	add.l	D4,(A3)+
	add.l	D4,(A3)+
	lea	22(A3),A3
	tst.l	(A3)
	bne.s	rscrel4
	addq.l	#2,A3
rscrel4	dbf	D3,rscrel3

	lea	(A4),A3
	move.w	8(A4),D3
	add.l	D3,A3	A3->BITBLKs
	move.w	28(A4),D3	D3: Number of BITBLKs
	bra.s	rscrel6
rscrel5	add.l	D4,(A3)+
	lea	10(A3),A3
	tst.l	(A3)
	bne.s	rscrel6
	addq.l	#2,A3
rscrel6	dbf	D3,rscrel5

	lea	(A4),A3
	move.w	10(A4),D3
	add.l	D3,A3	A3->free strings
	move.w	30(A4),D3	D3: Number of free strings
	bra.s	rscrel8
rscrel7	add.l	D4,(A3)+
rscrel8	dbf	D3,rscrel7

	lea	(A4),A3
	move.w	16(A4),D3
	add.l	D3,A3	A3->free images
	move.w	32(A4),D3	D3: Number of free images
	bra.s	rscrel10
rscrel9	add.l	D4,(A3)+
rscrel10	dbf	D3,rscrel9

	lea	(A4),A3
	move.w	18(A4),D3
	add.l	D3,A3	A3->trees
	move.w	22(A4),D3	D3: Number of trees
	bra.s	rscrel12
rscrel11	add.l	D4,(A3)+
rscrel12	dbf	D3,rscrel11

	lea	(A4),A3
	move.w	2(A4),D3
	add.l	D3,A3	A3->Objects
	move.w	20(A4),D3	D3: Number of objects
	bra.s	rscrel16

rscrel13	moveq	#0,D5	Unknown object type
	bra.s	rscrel15
rscrel14	moveq	#-20,D2	Relocate next object
	add.b	7(A3),D2	Object basic type -20
	beq.s	rscrel15	G_BOX
	bmi.s	rscrel13
	subq.b	#5,D2
	beq.s	rscrel15	G_IBOX
	subq.b	#2,D2
	beq.s	rscrel15	G_BOXCHAR
	subq.b	#6,D2
	bgt.s	rscrel13	Greater than G_CICON => unknown
	add.l	D4,12(A3)
rscrel15	rsrc_obfix A3,#0	Finally fix coordinates of object
	lea	24(A3),A3	before moving on to the next one.
rscrel16	dbf	D3,rscrel14

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
*	moveq	#0,D5
*rscrel18	add.l	D4,D2
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
*	move.w	22(A0),D4
*	lsr.w	#3,D4
*	mulu	24(A0),D4	D4: bytes per plane
*	lea	38(A0),A1
*	move.l	A1,(A0)+	Pointer to mono data
*	add.l	D4,A1
*	move.l	A1,(A0)+	Pointer to mono mask
*	add.l	D4,A1
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
*	mulu	D4,D0	D0: bytes in image, assuming
*	add.l	D0,A1	less than 32K/plane
*	move.l	A1,(A0)+	Pointer to unselected mask
*	add.l	D4,A1
*	tst.l	(A0)
*	bne.s	rscrel23
*	addq.l	#8,A0
*	bra.s	rscrel22
*rscrel23	move.l	A1,(A0)+	Pointer to selected image
*	add.l	D0,A1
*	move.l	A1,(A0)+	Pointer to selected mask
*	add.l	D4,A1
*	bra.s	rscrel22
*
*rscrel24	dbf	D2,rscrel21
* - - - - - - - - - - - - -

rscrel25	move.l	D5,D0
	movem.l	(SP)+,D1-D5/A0-A4
	rts


***************************
*	GETTREE		Get tree address
*	GETFRSTP		Get free string pointer
*	GETFRIMP		Get free image pointer
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN: A4 -> RSC file, D3.W: Index of tree /free string /free image
* OUT: A3: Adress of tree  /Address of pointer to free string/image
*      D0: 1=OK, 0 = Tree/string/image with this high number doesn't exist

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
*==========================
GETFRSTP	cmp.w	30(A4),D3
	bcc.s	gettree1	error
	lea	(A4),A3
	moveq	#10,D0
getfrstp1	move.w	0(A4,D0.W),D0
	add.l	D0,A3	A3-> Table of pointers
	move.w	D3,D0
	lsl.w	#2,D0
	add.w	D0,A3	A3-> Pointer to free string/image
	moveq	#1,D0
	rts
*==========================
GETFRSTP	cmp.w	32(A4),D3
	bcc.s	gettree1	error
	lea	(A4),A3
	moveq	#16,D0
	bra.s	getfrstp1
***************************
