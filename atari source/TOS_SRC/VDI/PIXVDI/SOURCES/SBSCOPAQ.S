********************************  sbscopaq.s  *********************************
*
* $Revision: 3.0 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbscopaq.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/08/06 20:21:17 $     $Locker:  $
* =============================================================================
*
* $Log:	sbscopaq.s,v $
* Revision 3.0  91/08/06  20:21:17  lozben
* New generation VDI
* 
* Revision 2.2  91/07/08  15:56:12  lozben
* File screated by Slavik Lozben. This file contains the new
* OPAQUE blit routine. The assumtion is such that we are dealing with
* ST interleaved screen memory format.
* 
*******************************************************************************

		;
		; Entry routines for opaque byte aligned blits
		; (screen format)
		;
		.globl	opaq_pos_row
		.globl	opaq_neg_row


		;
		; Entry routines for transparant non aligned blits
		; (screen format)
		;
		.globl	opaqSrPos
		.globl	opaqSlPos
		.globl	opaqSrNeg
		.globl	opaqSlNeg


		;
		; space where we can compile fringe routines as well
		; as inner loop routines to do our logic op blit
		;
		.globl	fringe0
		.globl	innerLoop
		.globl	fringe1


		;
		; Routines to do fringes for word aligned blit (positive case)
		;
		.globl	op0_opf,op1_opf,op2_opf,op3_opf
		.globl	op4_opf,op5_opf,op6_opf,op7_opf
		.globl	op8_opf,op9_opf,opA_opf,opB_opf
		.globl	opC_opf,opD_opf,opE_opf,opF_opf


		;
		; Routines to do inner loop for word aligne blit (pos case)
		;
		.globl	op0_opi,op1_opi,op2_opi,op3_opi
		.globl	op4_opi,op5_opi,op6_opi,op7_opi
		.globl	op8_opi,op9_opi,opA_opi,opB_opi
		.globl	opC_opi,opD_opi,opE_opi,opF_opi


		;
		; Routines to do fringes for word aligned blit (negative case)
		;
		.globl	op0_onf,op1_onf,op2_onf,op3_onf
		.globl	op4_onf,op5_onf,op6_onf,op7_onf
		.globl	op8_onf,op9_onf,opA_onf,opB_onf
		.globl	opC_onf,opD_onf,opE_onf,opF_onf


		;
		; Routines to do inner loop for word aligne blit (neg case)
		;
		.globl	op0_oni,op1_oni,op2_oni,op3_oni
		.globl	op4_oni,op5_oni,op6_oni,op7_oni
		.globl	op8_oni,op9_oni,opA_oni,opB_oni
		.globl	opC_oni,opD_oni,opE_oni,opF_oni

*******************************************************************************
***************** Routines for the unaligned blit opaque case *****************
*******************************************************************************

		************************************************
		********** shift right positive case ***********
		************************************************
		;
		; Routines to do fringe0 for unaligned blit (positive case)
		;
		.globl	o0Sropf0,o1Sropf0,o2Sropf0,o3Sropf0
		.globl	o4Sropf0,o5Sropf0,o6Sropf0,o7Sropf0
		.globl	o8Sropf0,o9Sropf0,oASropf0,oBSropf0
		.globl	oCSropf0,oDSropf0,oESropf0,oFSropf0

		;
		; Routines to do inner loop for unaligned blit (pos case)
		;
		.globl	op0Sropi,op1Sropi,op2Sropi,op3Sropi
		.globl	op4Sropi,op5Sropi,op6Sropi,op7Sropi
		.globl	op8Sropi,op9Sropi,opASropi,opBSropi
		.globl	opCSropi,opDSropi,opESropi,opFSropi

		;
		; Routines to do fringe1 for unaligned blit (positive case)
		;
		.globl	o0Sropf1,o1Sropf1,o2Sropf1,o3Sropf1
		.globl	o4Sropf1,o5Sropf1,o6Sropf1,o7Sropf1
		.globl	o8Sropf1,o9Sropf1,oASropf1,oBSropf1
		.globl	oCSropf1,oDSropf1,oESropf1,oFSropf1

		************************************************
		********** shift left  positive case ***********
		************************************************
		;
		; Routines to do fringe0 for unaligned blit (positive case)
		;
		.globl	o0Slopf0,o1Slopf0,o2Slopf0,o3Slopf0
		.globl	o4Slopf0,o5Slopf0,o6Slopf0,o7Slopf0
		.globl	o8Slopf0,o9Slopf0,oASlopf0,oBSlopf0
		.globl	oCSlopf0,oDSlopf0,oESlopf0,oFSlopf0


		;
		; Routines to do inner loop for unaligned blit (pos case)
		;
		.globl	op0Slopi,op1Slopi,op2Slopi,op3Slopi
		.globl	op4Slopi,op5Slopi,op6Slopi,op7Slopi
		.globl	op8Slopi,op9Slopi,opASlopi,opBSlopi
		.globl	opCSlopi,opDSlopi,opESlopi,opFSlopi

		;
		; Routines to do fringe2 for unaligned blit (positive case)
		;
		.globl	o0Slopf1,o1Slopf1,o2Slopf1,o3Slopf1
		.globl	o4Slopf1,o5Slopf1,o6Slopf1,o7Slopf1
		.globl	o8Slopf1,o9Slopf1,oASlopf1,oBSlopf1
		.globl	oCSlopf1,oDSlopf1,oESlopf1,oFSlopf1



		************************************************
		********** shift right negative case ***********
		************************************************
		;
		; Routines to do fringe0 for unaligned blit (negative case)
		;
		.globl	o0Sronf0,o1Sronf0,o2Sronf0,o3Sronf0
		.globl	o4Sronf0,o5Sronf0,o6Sronf0,o7Sronf0
		.globl	o8Sronf0,o9Sronf0,oASronf0,oBSronf0
		.globl	oCSronf0,oDSronf0,oESronf0,oFSronf0

		;
		; Routines to do inner loop for unaligned blit (neg case)
		;
		.globl	op0Sroni,op1Sroni,op2Sroni,op3Sroni
		.globl	op4Sroni,op5Sroni,op6Sroni,op7Sroni
		.globl	op8Sroni,op9Sroni,opASroni,opBSroni
		.globl	opCSroni,opDSroni,opESroni,opFSroni

		;
		; Routines to do fringe1 for unaligned blit (negative case)
		;
		.globl	o0Sronf1,o1Sronf1,o2Sronf1,o3Sronf1
		.globl	o4Sronf1,o5Sronf1,o6Sronf1,o7Sronf1
		.globl	o8Sronf1,o9Sronf1,oASronf1,oBSronf1
		.globl	oCSronf1,oDSronf1,oESronf1,oFSronf1

		************************************************
		********** shift left  negative case ***********
		************************************************
		;
		; Routines to do fringe0 for unaligned blit (negative case)
		;
		.globl	o0Slonf0,o1Slonf0,o2Slonf0,o3Slonf0
		.globl	o4Slonf0,o5Slonf0,o6Slonf0,o7Slonf0
		.globl	o8Slonf0,o9Slonf0,oASlonf0,oBSlonf0
		.globl	oCSlonf0,oDSlonf0,oESlonf0,oFSlonf0


		;
		; Routines to do inner loop for unaligned blit (neg case)
		;
		.globl	op0Sloni,op1Sloni,op2Sloni,op3Sloni
		.globl	op4Sloni,op5Sloni,op6Sloni,op7Sloni
		.globl	op8Sloni,op9Sloni,opASloni,opBSloni
		.globl	opCSloni,opDSloni,opESloni,opFSloni

		;
		; Routines to do fringe2 for unaligned blit (negative case)
		;
		.globl	o0Slonf1,o1Slonf1,o2Slonf1,o3Slonf1
		.globl	o4Slonf1,o5Slonf1,o6Slonf1,o7Slonf1
		.globl	o8Slonf1,o9Slonf1,oASlonf1,oBSlonf1
		.globl	oCSlonf1,oDSlonf1,oESlonf1,oFSlonf1



PLANE_CT  equ	-72	; number of consequitive planes to blt		    +04
FG_COL	  equ	-70	; foreground color (logic op table index:hi bit)    +06
BG_COL	  equ	-68	; background color (logic op table index:lo bit)    +08
OP_TAB	  equ	-66	; logic ops for all fore and background combos	    +10
INNER_CT  equ	-06	; blt inner loop initial count			    +70

*******************************************************************************
*******************************************************************************
****************************** Copy Raster Opaque *****************************
*******************************************************************************
*******************************************************************************


*+
* Do any number of planes.
*
*	in	a0	src address
*		a1	dst address
*		a2	planes - 1
*		a3	width - 2 in words (1 plane)
*		a4	offset to next source row
*		a5	offset to next dest row
*		a6	bitblt parameter blosk adr
*
*		d3	fringe mask one
*		d6	fringe mask two
*		d7	row count
*-

opaq_pos_row:	move.w	a2,d2			; d2 <- planes - 1
		exg	d4,a3			; save a3 to restore later
		exg	d5,a4			; save a4 to restore later
		lea	fringe0,a3		; a3 -> fr1 space for compile
		lea	innerLoop,a4		; a4 -> inner loop space

opr_loop:	moveq.l	#0,d0			; select log op based on curr
		lsr.w	FG_COL(a6)		; bg and fg color for given
		addx.w	d0,d0			; plane log ops (wd wide)
		lsr.w	BG_COL(a6)		; loc sequentially in OP_TAB as
		addx.w	d0,d0			; fg[0 or 1]/bg[0 or 1]
		move.b	OP_TAB(a6,d0.w),d0	; d0 <- appropriate logic op
		lsl.w	#2,d0			; d1 <- offset into log op tble


		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		move.l	oprf_op(pc,d0.w),a2	; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
oprfCodeFLoop:	move.b	(a2)+,(a3)+
		dbra	d1,oprfCodeFLoop

		;
		; copy inner loop code into mem (yes we are compiling in mem)
		;
		move.l	opri_op(pc,d0.w),a2	; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
opriCodeFLoop:	move.b	(a2)+,(a4)+
		dbra	d1,opriCodeFLoop

		dbra	d2,opr_loop

		move.w	#%0100111011010010,(a3)	; (a3) <- "jmp (a2)" instruct
		move.w	#%0100111011010010,(a4)	; (a4) <- "jmp (a2)" instruct
		exg	d4,a3			; restore a3
		exg	d5,a4			; restore a4
		bra	pos_row			; start the blit


oprf_op:
	dc.l	op0_opf,op1_opf,op2_opf,op3_opf,op4_opf,op5_opf,op6_opf,op7_opf
	dc.l	op8_opf,op9_opf,opA_opf,opB_opf,opC_opf,opD_opf,opE_opf,opF_opf

opri_op:
	dc.l	op0_opi,op1_opi,op2_opi,op3_opi,op4_opi,op5_opi,op6_opi,op7_opi
	dc.l	op8_opi,op9_opi,opA_opi,opB_opi,opC_opi,opD_opi,opE_opi,opF_opi




opaq_neg_row:	move.w	a2,d2			; d2 <- planes - 1
		exg	d4,a3			; save a3 to restore later
		exg	d5,a4			; save a4 to restore later
		lea	fringe0,a3		; a3 -> fr1 space for compile
		lea	innerLoop,a4		; a4 -> inner loop space

		addq.w	#1,d2			; d2 <- planes
		move.w	FG_COL(a6),d0		; d0 <- FG col so we can rotate
		ror.w	d2,d0			; prepare to shift to the left
		move.w	d0,FG_COL(a6)		; store shifted FG value
		move.w	BG_COL(a6),d0		; d0 <- BG col so we can rotate
		ror.w	d2,d0			; prepare to shift to the left
		move.w	d0,BG_COL(a6)		; store shifted BG value
		subq.w	#1,d2			; d2 <- planes - 1

onr_loop:	clr.w	d0			; select log op based on curr
		lsl.w	FG_COL(a6)		; bg and fg color for given
		addx.w	d0,d0			; plane log ops (wd wide)
		lsl.w	BG_COL(a6)		; loc sequentially in OP_TAB as
		addx.w	d0,d0			; fg[0 or 1]/bg[0 or 1]
		move.b	OP_TAB(a6,d0.w),d0	; d0 <- appropriate logic op
		lsl.w	#2,d0			; d1 <- offset into log op tble


		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		move.l	onrf_op(pc,d0.w),a2	; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
onrfCodeFLoop:	move.b	(a2)+,(a3)+
		dbra	d1,onrfCodeFLoop

		;
		; copy inner loop code into mem (yes we are compiling in mem)
		;
		move.l	onri_op(pc,d0.w),a2	; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
onriCodeFLoop:	move.b	(a2)+,(a4)+
		dbra	d1,onriCodeFLoop

		dbra	d2,onr_loop

		move.w	#%0100111011010010,(a3)	; (a3) <- "jmp (a2)" instruct
		move.w	#%0100111011010010,(a4)	; (a4) <- "jmp (a2)" instruct
		exg	d4,a3			; restore a3
		exg	d5,a4			; restore a4

		bra	neg_row

onrf_op:
	dc.l	op0_onf,op1_onf,op2_onf,op3_onf,op4_onf,op5_onf,op6_onf,op7_onf
	dc.l	op8_onf,op9_onf,opA_onf,opB_onf,opC_onf,opD_onf,opE_onf,opF_onf

onri_op:
	dc.l	op0_oni,op1_oni,op2_oni,op3_oni,op4_oni,op5_oni,op6_oni,op7_oni
	dc.l	op8_oni,op9_oni,opA_oni,opB_oni,opC_oni,opD_oni,opE_oni,opF_oni


*******************************************************************************
*                    Do word aligned blit positive direction		      *
*******************************************************************************

f1_pos0:	lea	f1_pos1,a2	; a2 <- return address 
		jmp	fringe0		; do left fringe

f1_pos1:	move.w	a3,d4 		; width - 2 in words (1 plane)
		lea	sc_pos1,a2	; a2 <- return address 
sc_pos0:	jmp	innerLoop	; blit inner words
sc_pos1:	dbra	d4,sc_pos0	; fetsch next source word

		exg	d6,d3		; d6 <- d3 fringe mask
		lea	f2_pos,a2	; a2 <- return address 
		jmp	fringe0		; do right fringe (same code)
f2_pos:		exg	d6,d3		; d6 <- original fringe mask

		add.w	a4,a0		; a0 -> next SOURCE row
		add.w	a5,a1		; a1 -> next DESTINATION row

pos_row:	dbra	d7,f1_pos0	; do next row
		rts


*******************************************************************************
*                    Do word aligned blit negative direction		      *
*******************************************************************************

f1_neg:		lea	sc_neg0,a2	; a2 <- return address
		jmp	fringe0		; do right fringe

sc_neg0:	move.w	a3,d4 		; width - 2 in words (1 plane)
		lea	sc_neg2,a2	; a2 <- return address
sc_neg1:	jmp	innerLoop	; blit inner words
sc_neg2:	dbra	d4,sc_neg1	; fetsch next source word

		exg	d6,d3		; d6 <- d3 fringe mask
		lea	f2_neg,a2	; a2 <- return address
		jmp	fringe0		; do left fringe (same code)
f2_neg:		exg	d6,d3		; d6 <- original fringe mask

		add.w	a4,a0		; a0 -> next SOURCE row
		add.w	a5,a1		; a1 -> next DESTINATION row

neg_row:	dbra	d7,f1_neg	; do next row
		rts


*******************************************************************************
*******************************************************************************
****************************** UNALIGNED BLIT *********************************
*******************************************************************************
*******************************************************************************

*+
*	in	a0	src address
*		a1	dst address
*		a2	planes - 1
*		a4	offset to next source row
*		a5	offset to next dest row
*		a6	bitblt parameter block adr
*
*		d2	shift count1 (low word) / row count (high word)
*		d3	shift count2 (low word)
*		d4	offset to next word in plane
*		d6	mask1 (low word)/mask3 (high word)
*		d7	mask2 (low word)
*-

*******************************************************************************
*			   Shift right positive case			      *
*******************************************************************************

		************************************************
		*************** Do initial setup ***************
		************************************************

opaqSrPos:	movem.l	d2/a0/a2/a4/a5,-(sp)	; save registers
		move.w	a2,d2			; d2 <- planes - 1
		lea	fringe0,a3		; a3 -> fr0 space for compile
		lea	innerLoop,a4		; a4 -> inner loop space
		lea	fringe1,a5		; a3 -> fr1 space for compile

SRPLoop:	clr.w	d0			; select log op based on curr
		lsr.w	FG_COL(a6)		; bg and fg color for given
		addx.w	d0,d0			; plane log ops (wd wide)
		lsr.w	BG_COL(a6)		; loc sequentially in OP_TAB as
		addx.w	d0,d0			; fg[0 or 1]/bg[0 or 1]
		move.b	OP_TAB(a6,d0.w),d0	; d0 <- appropriate logic op
		lsl.w	#2,d0			; d0 <- offset into log op tble


		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		lea	sropf0,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
sropf0CodeLoop:	move.b	(a2)+,(a3)+
		dbra	d1,sropf0CodeLoop

		;
		; copy inner loop code into mem (yes we are compiling in mem)
		;
		lea	sropi,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
sropiCodeLoop:	move.b	(a2)+,(a4)+
		dbra	d1,sropiCodeLoop

		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		lea	sropf1,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
sropf1CodeLoop:	move.b	(a2)+,(a5)+
		dbra	d1,sropf1CodeLoop

		dbra	d2,SRPLoop

		move.w	#%0100111011010011,(a3)	; (a3) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a4)	; (a4) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a5)	; (a5) <- "jmp (a3)" instruct

		movem.l	(sp)+,d2/a0/a2/a4/a5	; restore registers
		bra	oSrPentry

		;
		; Routines to do fringe0 for unaligned blit (positive case)
		;
sropf0:	dc.l	o0Sropf0,o1Sropf0,o2Sropf0,o3Sropf0
	dc.l	o4Sropf0,o5Sropf0,o6Sropf0,o7Sropf0
	dc.l	o8Sropf0,o9Sropf0,oASropf0,oBSropf0
	dc.l	oCSropf0,oDSropf0,oESropf0,oFSropf0


		;
		; Routines to do inner loop for unaligned blit (pos case)
		;
sropi:	dc.l	op0Sropi,op1Sropi,op2Sropi,op3Sropi
	dc.l	op4Sropi,op5Sropi,op6Sropi,op7Sropi
	dc.l	op8Sropi,op9Sropi,opASropi,opBSropi
	dc.l	opCSropi,opDSropi,opESropi,opFSropi

		;
		; Routines to do fringe1 for unaligned blit (positive case)
		;
sropf1:	dc.l	o0Sropf1,o1Sropf1,o2Sropf1,o3Sropf1
	dc.l	o4Sropf1,o5Sropf1,o6Sropf1,o7Sropf1
	dc.l	o8Sropf1,o9Sropf1,oASropf1,oBSropf1
	dc.l	oCSropf1,oDSropf1,oESropf1,oFSropf1



srPos:		swap	d2			; shft count1 is now in low wrd
		move.w	a2,d5			; d5 <- planes - 1
*+
* do left fringe
*-
srFr1P0:	lea	srFr1P1,a3		; a3 <- return address
		jmp	fringe0			; do left fringe


*+
* do inner words
*-
srFr1P1:	move.w	INNER_CT(a6),d5		; d5 <- internal count
		lea	srInP1,a3		; a3 <- return address

srInP0:		jmp	innerLoop
srInP1:		dbra	d5,srInP0		; do nxt wrd/nxt plane

*+
* do right fringe
*-
		swap	d6			; mask3 is now in low word
		lea	srFr1P,a3		; a3 <- return address
		jmp	fringe1			; do the right fringe
srFr1P:		swap	d6			; mask1 is now in low word

		add.w	a4,a0			; a0 -> next SOURCE row
		add.w	a5,a1			; a1 -> next DESTINATION row

		swap	d2			; row count is now in low word
		dbra	d2,srPos		; do nxt row
		rts

oSrPentry:	neg.w	d4			; offset to previous word
		swap	d2			; row count is now in low word
		dbra	d2,srPos		; do nxt row
		rts

*******************************************************************************
*			   Shift left positive case			      *
*******************************************************************************

		************************************************
		*************** Do initial setup ***************
		************************************************

opaqSlPos:	movem.l	d2/a0/a2/a4/a5,-(sp)	; save registers
		move.w	a2,d2			; d2 <- planes - 1
		lea	fringe0,a3		; a3 -> fr0 space for compile
		lea	innerLoop,a4		; a4 -> inner loop space
		lea	fringe1,a5		; a3 -> fr1 space for compile

SLPLoop:	clr.w	d0			; select log op based on curr
		lsr.w	FG_COL(a6)		; bg and fg color for given
		addx.w	d0,d0			; plane log ops (wd wide)
		lsr.w	BG_COL(a6)		; loc sequentially in OP_TAB as
		addx.w	d0,d0			; fg[0 or 1]/bg[0 or 1]
		move.b	OP_TAB(a6,d0.w),d0	; d0 <- appropriate logic op
		lsl.w	#2,d0			; d0 <- offset into log op tble


		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		lea	slopf0,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
slopf0CodeLoop:	move.b	(a2)+,(a3)+
		dbra	d1,slopf0CodeLoop

		;
		; copy inner loop code into mem (yes we are compiling in mem)
		;
		lea	slopi,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
slopiCodeLoop:	move.b	(a2)+,(a4)+
		dbra	d1,slopiCodeLoop

		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		lea	slopf1,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
slopf1CodeLoop:	move.b	(a2)+,(a5)+
		dbra	d1,slopf1CodeLoop

		dbra	d2,SLPLoop

		move.w	#%0100111011010011,(a3)	; (a3) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a4)	; (a4) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a5)	; (a5) <- "jmp (a3)" instruct

		movem.l	(sp)+,d2/a0/a2/a4/a5	; restore registers
		add.w	d4,a4			; udjust for shift left case
		add.w	d4,a5			; udjust for shift left case
		bra	oSlPentry

		;
		; Routines to do fringe0 for unaligned blit (positive case)
		;
slopf0:	dc.l	o0Slopf0,o1Slopf0,o2Slopf0,o3Slopf0
	dc.l	o4Slopf0,o5Slopf0,o6Slopf0,o7Slopf0
	dc.l	o8Slopf0,o9Slopf0,oASlopf0,oBSlopf0
	dc.l	oCSlopf0,oDSlopf0,oESlopf0,oFSlopf0


		;
		; Routines to do inner loop for unaligned blit (pos case)
		;
slopi:	dc.l	op0Slopi,op1Slopi,op2Slopi,op3Slopi
	dc.l	op4Slopi,op5Slopi,op6Slopi,op7Slopi
	dc.l	op8Slopi,op9Slopi,opASlopi,opBSlopi
	dc.l	opCSlopi,opDSlopi,opESlopi,opFSlopi

		;
		; Routines to do fringe1 for unaligned blit (positive case)
		;
slopf1:	dc.l	o0Slopf1,o1Slopf1,o2Slopf1,o3Slopf1
	dc.l	o4Slopf1,o5Slopf1,o6Slopf1,o7Slopf1
	dc.l	o8Slopf1,o9Slopf1,oASlopf1,oBSlopf1
	dc.l	oCSlopf1,oDSlopf1,oESlopf1,oFSlopf1



slPos:		swap	d2			; shft count1 is now in low wrd
		move.w	a2,d5			; d5 <- planes - 1
*+
* do left fringe
*-
slFr1P0:	lea	slFr1P1,a3		; a3 <- return address
		jmp	fringe0			; do left fringe

*+
* do inner words
*-
slFr1P1:	move.w	INNER_CT(a6),d5		; d5 <- internal count
		lea	slInP1,a3		; a3 <- return address
		bra	slInP1

slInP0:		jmp	innerLoop
slInP1:		dbra	d5,slInP0		; do nxt wrd/nxt plane

*+
* do right fringe
*-
		swap	d6			; mask3 is now in low word
		lea	slFr1P,a3		; a3 <- return address
		jmp	fringe1			; do the right fringe
slFr1P:		swap	d6			; mask1 is now in low word

		add.w	a4,a0			; a0 -> next SOURCE row
		add.w	a5,a1			; a1 -> next DESTINATION row

oSlPentry:	swap	d2			; row count is now in low word
		dbra	d2,slPos		; do next row
		rts

*******************************************************************************
*			   Shift right negative case			      *
*******************************************************************************

		************************************************
		*************** Do initial setup ***************
		************************************************

opaqSrNeg:	movem.l	d2/a0/a2/a4/a5,-(sp)	; save registers
		move.w	a2,d2			; d2 <- planes - 1
		lea	fringe0,a3		; a3 -> fr0 space for compile
		lea	innerLoop,a4		; a4 -> inner loop space
		lea	fringe1,a5		; a3 -> fr1 space for compile

		addq.w	#1,d2			; d2 <- planes
		move.w	FG_COL(a6),d0		; d0 <- FG col so we can rotate
		ror.w	d2,d0			; prepare to shift to the left
		move.w	d0,FG_COL(a6)		; store shifted FG value
		move.w	BG_COL(a6),d0		; d0 <- BG col so we can rotate
		ror.w	d2,d0			; prepare to shift to the left
		move.w	d0,BG_COL(a6)		; store shifted BG value
		subq.w	#1,d2			; d2 <- planes - 1

SRNLoop:	clr.w	d0			; select log op based on curr
		lsl.w	FG_COL(a6)		; bg and fg color for given
		addx.w	d0,d0			; plane log ops (wd wide)
		lsl.w	BG_COL(a6)		; loc sequentially in OP_TAB as
		addx.w	d0,d0			; fg[0 or 1]/bg[0 or 1]
		move.b	OP_TAB(a6,d0.w),d0	; d0 <- appropriate logic op
		lsl.w	#2,d0			; d0 <- offset into log op tble


		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		lea	sronf0,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
sronf0CodeLoop:	move.b	(a2)+,(a3)+
		dbra	d1,sronf0CodeLoop

		;
		; copy inner loop code into mem (yes we are compiling in mem)
		;
		lea	sroni,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
sroniCodeLoop:	move.b	(a2)+,(a4)+
		dbra	d1,sroniCodeLoop

		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		lea	sronf1,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
sronf1CodeLoop:	move.b	(a2)+,(a5)+
		dbra	d1,sronf1CodeLoop

		dbra	d2,SRNLoop

		move.w	#%0100111011010011,(a3)	; (a3) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a4)	; (a4) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a5)	; (a5) <- "jmp (a3)" instruct

		movem.l	(sp)+,d2/a0/a2/a4/a5	; restore registers
		add.w	d4,a4			; udjust for shift left case
		add.w	d4,a5			; udjust for shift left case
		bra	oSrNentry

		;
		; Routines to do fringe0 for unaligned blit (negative case)
		;
sronf0:	dc.l	o0Sronf0,o1Sronf0,o2Sronf0,o3Sronf0
	dc.l	o4Sronf0,o5Sronf0,o6Sronf0,o7Sronf0
	dc.l	o8Sronf0,o9Sronf0,oASronf0,oBSronf0
	dc.l	oCSronf0,oDSronf0,oESronf0,oFSronf0


		;
		; Routines to do inner loop for unaligned blit (neg case)
		;
sroni:	dc.l	op0Sroni,op1Sroni,op2Sroni,op3Sroni
	dc.l	op4Sroni,op5Sroni,op6Sroni,op7Sroni
	dc.l	op8Sroni,op9Sroni,opASroni,opBSroni
	dc.l	opCSroni,opDSroni,opESroni,opFSroni

		;
		; Routines to do fringe1 for unaligned blit (negative case)
		;
sronf1:	dc.l	o0Sronf1,o1Sronf1,o2Sronf1,o3Sronf1
	dc.l	o4Sronf1,o5Sronf1,o6Sronf1,o7Sronf1
	dc.l	o8Sronf1,o9Sronf1,oASronf1,oBSronf1
	dc.l	oCSronf1,oDSronf1,oESronf1,oFSronf1



srNeg:		swap	d2			; shft count1 is now in low wrd
		move.w	a2,d5			; d5 <- planes - 1
*+
* do right fringe
*-
srFr1N0:	lea	srFr1N1,a3		; a3 <- return address
		jmp	fringe0			; do right fringe

*+
* do inner words
*-
srFr1N1:	move.w	INNER_CT(a6),d5		; d5 <- internal count
		lea	srInN1,a3		; a3 <- return address
		bra	srInN1

srInN0:		jmp	innerLoop
srInN1:		dbra	d5,srInN0		; do nxt wrd/nxt plane

*+
* do left fringe
*-
		swap	d6			; mask3 is now in low word
		lea	srFr1N,a3		; a3 <- return address
		jmp	fringe1			; do the left fringe
srFr1N:		swap	d6			; mask1 is now in low word

		add.w	a4,a0			; a0 -> next SOURCE row
		add.w	a5,a1			; a1 -> next DESTINATION row

oSrNentry:	swap	d2			; row count is now in low word
		dbra	d2,srNeg		; do next row
		rts

*******************************************************************************
*			   Shift left negative case			      *
*******************************************************************************


		************************************************
		*************** Do initial setup ***************
		************************************************

opaqSlNeg:	movem.l	d2/a0/a2/a4/a5,-(sp)	; save registers
		move.w	a2,d2			; d2 <- planes - 1
		lea	fringe0,a3		; a3 -> fr0 space for compile
		lea	innerLoop,a4		; a4 -> inner loop space
		lea	fringe1,a5		; a3 -> fr1 space for compile

		addq.w	#1,d2			; d2 <- planes
		move.w	FG_COL(a6),d0		; d0 <- FG col so we can rotate
		ror.w	d2,d0			; prepare to shift to the left
		move.w	d0,FG_COL(a6)		; store shifted FG value
		move.w	BG_COL(a6),d0		; d0 <- BG col so we can rotate
		ror.w	d2,d0			; prepare to shift to the left
		move.w	d0,BG_COL(a6)		; store shifted BG value
		subq.w	#1,d2			; d2 <- planes - 1

SLNLoop:	clr.w	d0			; select log op based on curr
		lsl.w	FG_COL(a6)		; bg and fg color for given
		addx.w	d0,d0			; plane log ops (wd wide)
		lsl.w	BG_COL(a6)		; loc sequentially in OP_TAB as
		addx.w	d0,d0			; fg[0 or 1]/bg[0 or 1]
		move.b	OP_TAB(a6,d0.w),d0	; d0 <- appropriate logic op
		lsl.w	#2,d0			; d0 <- offset into log op tble


		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		lea	slonf0,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
slonf0CodeLoop:	move.b	(a2)+,(a3)+
		dbra	d1,slonf0CodeLoop

		;
		; copy inner loop code into mem (yes we are compiling in mem)
		;
		lea	sloni,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
sloniCodeLoop:	move.b	(a2)+,(a4)+
		dbra	d1,sloniCodeLoop

		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		lea	slonf1,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
slonf1CodeLoop:	move.b	(a2)+,(a5)+
		dbra	d1,slonf1CodeLoop

		dbra	d2,SLNLoop

		move.w	#%0100111011010011,(a3)	; (a3) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a4)	; (a4) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a5)	; (a5) <- "jmp (a3)" instruct

		movem.l	(sp)+,d2/a0/a2/a4/a5	; restore registers
		bra	oSlNentry

		;
		; Routines to do fringe0 for unaligned blit (positive case)
		;
slonf0:	dc.l	o0Slonf0,o1Slonf0,o2Slonf0,o3Slonf0
	dc.l	o4Slonf0,o5Slonf0,o6Slonf0,o7Slonf0
	dc.l	o8Slonf0,o9Slonf0,oASlonf0,oBSlonf0
	dc.l	oCSlonf0,oDSlonf0,oESlonf0,oFSlonf0


		;
		; Routines to do inner loop for unaligned blit (pos case)
		;
sloni:	dc.l	op0Sloni,op1Sloni,op2Sloni,op3Sloni
	dc.l	op4Sloni,op5Sloni,op6Sloni,op7Sloni
	dc.l	op8Sloni,op9Sloni,opASloni,opBSloni
	dc.l	opCSloni,opDSloni,opESloni,opFSloni

		;
		; Routines to do fringe1 for unaligned blit (positive case)
		;
slonf1:	dc.l	o0Slonf1,o1Slonf1,o2Slonf1,o3Slonf1
	dc.l	o4Slonf1,o5Slonf1,o6Slonf1,o7Slonf1
	dc.l	o8Slonf1,o9Slonf1,oASlonf1,oBSlonf1
	dc.l	oCSlonf1,oDSlonf1,oESlonf1,oFSlonf1



slNeg:		swap	d2			; shft count1 is now in low wrd
		move.w	a2,d5			; d5 <- planes - 1
*+
* do left fringe
*-
slFr1N0:	lea	slFr1N1,a3		; a3 <- return address
		jmp	fringe0			; do right fringe

*+
* do inner words
*-
slFr1N1:	move.w	INNER_CT(a6),d5		; d5 <- internal count
		lea	slInN1,a3		; a3 <- return address

slInN0:		jmp	innerLoop
slInN1:		dbra	d5,slInN0		; do nxt wrd/nxt plane

*+
* do right fringe
*-
		swap	d6			; mask3 is now in low word
		lea	slFr1N,a3		; a3 <- return address
		jmp	fringe1			; do the left fringe
slFr1N:		swap	d6			; mask1 is now in low word

		add.w	a4,a0			; a0 -> next SOURCE row
		add.w	a5,a1			; a1 -> next DESTINATION row

		swap	d2			; row count is now in low word
		dbra	d2,slNeg		; do nxt row
		rts

oSlNentry:	neg.w	d4			; make d4 pos
		swap	d2			; row count is now in low word
		dbra	d2,slNeg
		rts
