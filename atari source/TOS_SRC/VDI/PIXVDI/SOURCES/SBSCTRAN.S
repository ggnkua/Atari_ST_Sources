********************************  sbsctran.s  *********************************
*
* $Revision: 3.0 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbsctran.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/08/06 20:23:16 $     $Locker:  $
* =============================================================================
*
* $Log:	sbsctran.s,v $
* Revision 3.0  91/08/06  20:23:16  lozben
* New generation VDI
* 
* Revision 2.2  91/07/08  15:58:20  lozben
* File created by Slavik Lozben. This file contains the new
* TRANPARANT blit routine. The assumtion is such that we are dealing with
* ST interleaved screen memory format.
* 
*******************************************************************************

		;
		; Entry routines for transparant byte aligned blits
		; (screen format)
		;
		.globl	trans_pos_row
		.globl	trans_neg_row


		;
		; Entry routines for transparant non aligned blits
		; (screen format)
		;
		.globl	transSrPos
		.globl	transSlPos
		.globl	transSrNeg
		.globl	transSlNeg


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
		.globl	op0_tpf,op1_tpf,op2_tpf,op3_tpf
		.globl	op4_tpf,op5_tpf,op6_tpf,op7_tpf
		.globl	op8_tpf,op9_tpf,opA_tpf,opB_tpf
		.globl	opC_tpf,opD_tpf,opE_tpf,opF_tpf


		;
		; Routines to do inner loop for word aligne blit (pos case)
		;
		.globl	op0_tpi,op1_tpi,op2_tpi,op3_tpi
		.globl	op4_tpi,op5_tpi,op6_tpi,op7_tpi
		.globl	op8_tpi,op9_tpi,opA_tpi,opB_tpi
		.globl	opC_tpi,opD_tpi,opE_tpi,opF_tpi


		;
		; Routines to do fringes for word aligned blit (negative case)
		;
		.globl	op0_tnf,op1_tnf,op2_tnf,op3_tnf
		.globl	op4_tnf,op5_tnf,op6_tnf,op7_tnf
		.globl	op8_tnf,op9_tnf,opA_tnf,opB_tnf
		.globl	opC_tnf,opD_tnf,opE_tnf,opF_tnf


		;
		; Routines to do inner loop for word aligne blit (neg case)
		;
		.globl	op0_tni,op1_tni,op2_tni,op3_tni
		.globl	op4_tni,op5_tni,op6_tni,op7_tni
		.globl	op8_tni,op9_tni,opA_tni,opB_tni
		.globl	opC_tni,opD_tni,opE_tni,opF_tni

*******************************************************************************
************** Routines for the unaligned blit transparant case ***************
*******************************************************************************

		************************************************
		********** shift right positive case ***********
		************************************************
		;
		; Routines to do fringe0 for unaligned blit (positive case)
		;
		.globl	o0Srtpf0,o1Srtpf0,o2Srtpf0,o3Srtpf0
		.globl	o4Srtpf0,o5Srtpf0,o6Srtpf0,o7Srtpf0
		.globl	o8Srtpf0,o9Srtpf0,oASrtpf0,oBSrtpf0
		.globl	oCSrtpf0,oDSrtpf0,oESrtpf0,oFSrtpf0

		;
		; Routines to do inner loop for unaligned blit (pos case)
		;
		.globl	op0Srtpi,op1Srtpi,op2Srtpi,op3Srtpi
		.globl	op4Srtpi,op5Srtpi,op6Srtpi,op7Srtpi
		.globl	op8Srtpi,op9Srtpi,opASrtpi,opBSrtpi
		.globl	opCSrtpi,opDSrtpi,opESrtpi,opFSrtpi

		;
		; Routines to do fringe1 for unaligned blit (positive case)
		;
		.globl	o0Srtpf1,o1Srtpf1,o2Srtpf1,o3Srtpf1
		.globl	o4Srtpf1,o5Srtpf1,o6Srtpf1,o7Srtpf1
		.globl	o8Srtpf1,o9Srtpf1,oASrtpf1,oBSrtpf1
		.globl	oCSrtpf1,oDSrtpf1,oESrtpf1,oFSrtpf1

		************************************************
		********** shift left  positive case ***********
		************************************************
		;
		; Routines to do fringe0 for unaligned blit (positive case)
		;
		.globl	o0Sltpf0,o1Sltpf0,o2Sltpf0,o3Sltpf0
		.globl	o4Sltpf0,o5Sltpf0,o6Sltpf0,o7Sltpf0
		.globl	o8Sltpf0,o9Sltpf0,oASltpf0,oBSltpf0
		.globl	oCSltpf0,oDSltpf0,oESltpf0,oFSltpf0


		;
		; Routines to do inner loop for unaligned blit (pos case)
		;
		.globl	op0Sltpi,op1Sltpi,op2Sltpi,op3Sltpi
		.globl	op4Sltpi,op5Sltpi,op6Sltpi,op7Sltpi
		.globl	op8Sltpi,op9Sltpi,opASltpi,opBSltpi
		.globl	opCSltpi,opDSltpi,opESltpi,opFSltpi

		;
		; Routines to do fringe2 for unaligned blit (positive case)
		;
		.globl	o0Sltpf1,o1Sltpf1,o2Sltpf1,o3Sltpf1
		.globl	o4Sltpf1,o5Sltpf1,o6Sltpf1,o7Sltpf1
		.globl	o8Sltpf1,o9Sltpf1,oASltpf1,oBSltpf1
		.globl	oCSltpf1,oDSltpf1,oESltpf1,oFSltpf1



		************************************************
		********** shift right negative case ***********
		************************************************
		;
		; Routines to do fringe0 for unaligned blit (negative case)
		;
		.globl	o0Srtnf0,o1Srtnf0,o2Srtnf0,o3Srtnf0
		.globl	o4Srtnf0,o5Srtnf0,o6Srtnf0,o7Srtnf0
		.globl	o8Srtnf0,o9Srtnf0,oASrtnf0,oBSrtnf0
		.globl	oCSrtnf0,oDSrtnf0,oESrtnf0,oFSrtnf0

		;
		; Routines to do inner loop for unaligned blit (neg case)
		;
		.globl	op0Srtni,op1Srtni,op2Srtni,op3Srtni
		.globl	op4Srtni,op5Srtni,op6Srtni,op7Srtni
		.globl	op8Srtni,op9Srtni,opASrtni,opBSrtni
		.globl	opCSrtni,opDSrtni,opESrtni,opFSrtni

		;
		; Routines to do fringe1 for unaligned blit (negative case)
		;
		.globl	o0Srtnf1,o1Srtnf1,o2Srtnf1,o3Srtnf1
		.globl	o4Srtnf1,o5Srtnf1,o6Srtnf1,o7Srtnf1
		.globl	o8Srtnf1,o9Srtnf1,oASrtnf1,oBSrtnf1
		.globl	oCSrtnf1,oDSrtnf1,oESrtnf1,oFSrtnf1

		************************************************
		********** shift left  negative case ***********
		************************************************
		;
		; Routines to do fringe0 for unaligned blit (negative case)
		;
		.globl	o0Sltnf0,o1Sltnf0,o2Sltnf0,o3Sltnf0
		.globl	o4Sltnf0,o5Sltnf0,o6Sltnf0,o7Sltnf0
		.globl	o8Sltnf0,o9Sltnf0,oASltnf0,oBSltnf0
		.globl	oCSltnf0,oDSltnf0,oESltnf0,oFSltnf0


		;
		; Routines to do inner loop for unaligned blit (neg case)
		;
		.globl	op0Sltni,op1Sltni,op2Sltni,op3Sltni
		.globl	op4Sltni,op5Sltni,op6Sltni,op7Sltni
		.globl	op8Sltni,op9Sltni,opASltni,opBSltni
		.globl	opCSltni,opDSltni,opESltni,opFSltni

		;
		; Routines to do fringe2 for unaligned blit (negative case)
		;
		.globl	o0Sltnf1,o1Sltnf1,o2Sltnf1,o3Sltnf1
		.globl	o4Sltnf1,o5Sltnf1,o6Sltnf1,o7Sltnf1
		.globl	o8Sltnf1,o9Sltnf1,oASltnf1,oBSltnf1
		.globl	oCSltnf1,oDSltnf1,oESltnf1,oFSltnf1



PLANE_CT  equ	-72	; number of consequitive planes to blt		    +04
FG_COL	  equ	-70	; foreground color (logic op table index:hi bit)    +06
BG_COL	  equ	-68	; background color (logic op table index:lo bit)    +08
OP_TAB	  equ	-66	; logic ops for all fore and background combos	    +10
INNER_CT  equ	-06	; blt inner loop initial count			    +70

*******************************************************************************
*******************************************************************************
*************************** Copy Raster Transparant ***************************
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

trans_pos_row:	move.w	a2,d2			; d2 <- planes - 1
		exg	d4,a3			; save a3 to restore later
		exg	d5,a4			; save a4 to restore later
		lea	fringe0,a3		; a3 -> fr1 space for compile
		lea	innerLoop,a4		; a4 -> inner loop space

tpr_loop:	clr.w	d0			; select log op based on curr
		lsr.w	FG_COL(a6)		; bg and fg color for given
		addx.w	d0,d0			; plane log ops (wd wide)
		lsr.w	BG_COL(a6)		; loc sequentially in OP_TAB as
		addx.w	d0,d0			; fg[0 or 1]/bg[0 or 1]
		move.b	OP_TAB(a6,d0.w),d0	; d0 <- appropriate logic op
		lsl.w	#2,d0			; d1 <- offset into log op tble


		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		move.l	tprf_op(pc,d0.w),a2	; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
tprfCodeFLoop:	move.b	(a2)+,(a3)+
		dbra	d1,tprfCodeFLoop

		;
		; copy inner loop code into mem (yes we are compiling in mem)
		;
		move.l	tpri_op(pc,d0.w),a2	; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
tpriCodeFLoop:	move.b	(a2)+,(a4)+
		dbra	d1,tpriCodeFLoop

		dbra	d2,tpr_loop

		move.w	#%0100111011010010,(a3)	; (a3) <- "jmp (a2)" instruct
		move.w	#%0100111011010010,(a4)	; (a4) <- "jmp (a2)" instruct
		exg	d4,a3			; restore a3
		exg	d5,a4			; restore a4
		bra	pos_row			; start the blit


tprf_op:
	dc.l	op0_tpf,op1_tpf,op2_tpf,op3_tpf,op4_tpf,op5_tpf,op6_tpf,op7_tpf
	dc.l	op8_tpf,op9_tpf,opA_tpf,opB_tpf,opC_tpf,opD_tpf,opE_tpf,opF_tpf

tpri_op:
	dc.l	op0_tpi,op1_tpi,op2_tpi,op3_tpi,op4_tpi,op5_tpi,op6_tpi,op7_tpi
	dc.l	op8_tpi,op9_tpi,opA_tpi,opB_tpi,opC_tpi,opD_tpi,opE_tpi,opF_tpi




trans_neg_row:	move.w	a2,d2			; d2 <- planes - 1
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

tnr_loop:	clr.w	d0			; select log op based on curr
		lsl.w	FG_COL(a6)		; bg and fg color for given
		addx.w	d0,d0			; plane log ops (wd wide)
		lsl.w	BG_COL(a6)		; loc sequentially in OP_TAB as
		addx.w	d0,d0			; fg[0 or 1]/bg[0 or 1]
		move.b	OP_TAB(a6,d0.w),d0	; d0 <- appropriate logic op
		lsl.w	#2,d0			; d1 <- offset into log op tble


		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		move.l	tnrf_op(pc,d0.w),a2	; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
tnrfCodeFLoop:	move.b	(a2)+,(a3)+
		dbra	d1,tnrfCodeFLoop

		;
		; copy inner loop code into mem (yes we are compiling in mem)
		;
		move.l	tnri_op(pc,d0.w),a2	; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
tnriCodeFLoop:	move.b	(a2)+,(a4)+
		dbra	d1,tnriCodeFLoop

		dbra	d2,tnr_loop

		move.w	#%0100111011010010,(a3)	; (a3) <- "jmp (a2)" instruct
		move.w	#%0100111011010010,(a4)	; (a4) <- "jmp (a2)" instruct
		exg	d4,a3			; restore a3
		exg	d5,a4			; restore a4

		bra	neg_row

tnrf_op:
	dc.l	op0_tnf,op1_tnf,op2_tnf,op3_tnf,op4_tnf,op5_tnf,op6_tnf,op7_tnf
	dc.l	op8_tnf,op9_tnf,opA_tnf,opB_tnf,opC_tnf,opD_tnf,opE_tnf,opF_tnf

tnri_op:
	dc.l	op0_tni,op1_tni,op2_tni,op3_tni,op4_tni,op5_tni,op6_tni,op7_tni
	dc.l	op8_tni,op9_tni,opA_tni,opB_tni,opC_tni,opD_tni,opE_tni,opF_tni


*******************************************************************************
*                    Do word aligned blit positive direction		      *
*******************************************************************************

f1_pos0:	lea	f1_pos1,a2	; a2 <- return address 
		jmp	fringe0		; do left fringe
f1_pos1:	addq.w	#2,a0		; a0 -> next source word

		move.w	a3,d4 		; width - 2 in words (1 plane)
		lea	sc_pos1,a2	; a2 <- return address 
sc_pos0:	move.w	(a0)+,d0	; d0 <- current source word
		jmp	innerLoop	; blit inner words
sc_pos1:	dbra	d4,sc_pos0	; fetsch next source word

		exg	d6,d3		; d6 <- d3 fringe mask
		lea	f2_pos,a2	; a2 <- return address 
		jmp	fringe0		; do right fringe (same code)
f2_pos:		addq.w	#2,a0		; a0 -> to next source word
		exg	d6,d3		; d6 <- original fringe mask

		add.w	a4,a0		; a0 -> next SOURCE row
		add.w	a5,a1		; a1 -> next DESTINATION row

pos_row:	dbra	d7,f1_pos0	; do next row
		rts


*******************************************************************************
*                    Do word aligned blit negative direction		      *
*******************************************************************************

f1_neg:		subq.w	#2,a0		; a0 -> current source word
		lea	sc_neg0,a2	; a2 <- return address
		jmp	fringe0		; do right fringe

sc_neg0:	move.w	a3,d4 		; width - 2 in words (1 plane)
		lea	sc_neg2,a2	; a2 <- return address
sc_neg1:	move.w	-(a0),d0	; d0 <- current source word
		jmp	innerLoop	; blit inner words
sc_neg2:	dbra	d4,sc_neg1	; fetsch next source word

		exg	d6,d3		; d6 <- d3 fringe mask
		subq.w	#2,a0		; a0 -> current source word
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

transSrPos:	movem.l	d2/a0/a2/a4/a5,-(sp)	; save registers
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
		lea	srtpf0,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
srtpf0CodeLoop:	move.b	(a2)+,(a3)+
		dbra	d1,srtpf0CodeLoop

		;
		; copy inner loop code into mem (yes we are compiling in mem)
		;
		lea	srtpi,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
srtpiCodeLoop:	move.b	(a2)+,(a4)+
		dbra	d1,srtpiCodeLoop

		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		lea	srtpf1,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
srtpf1CodeLoop:	move.b	(a2)+,(a5)+
		dbra	d1,srtpf1CodeLoop

		dbra	d2,SRPLoop

		move.w	#%0100111011010011,(a3)	; (a3) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a4)	; (a4) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a5)	; (a5) <- "jmp (a3)" instruct

		movem.l	(sp)+,d2/a0/a2/a4/a5	; restore registers
		bra	tSrPentry

		;
		; Routines to do fringe0 for unaligned blit (positive case)
		;
srtpf0:	dc.l	o0Srtpf0,o1Srtpf0,o2Srtpf0,o3Srtpf0
	dc.l	o4Srtpf0,o5Srtpf0,o6Srtpf0,o7Srtpf0
	dc.l	o8Srtpf0,o9Srtpf0,oASrtpf0,oBSrtpf0
	dc.l	oCSrtpf0,oDSrtpf0,oESrtpf0,oFSrtpf0


		;
		; Routines to do inner loop for unaligned blit (pos case)
		;
srtpi:	dc.l	op0Srtpi,op1Srtpi,op2Srtpi,op3Srtpi
	dc.l	op4Srtpi,op5Srtpi,op6Srtpi,op7Srtpi
	dc.l	op8Srtpi,op9Srtpi,opASrtpi,opBSrtpi
	dc.l	opCSrtpi,opDSrtpi,opESrtpi,opFSrtpi

		;
		; Routines to do fringe1 for unaligned blit (positive case)
		;
srtpf1:	dc.l	o0Srtpf1,o1Srtpf1,o2Srtpf1,o3Srtpf1
	dc.l	o4Srtpf1,o5Srtpf1,o6Srtpf1,o7Srtpf1
	dc.l	o8Srtpf1,o9Srtpf1,oASrtpf1,oBSrtpf1
	dc.l	oCSrtpf1,oDSrtpf1,oESrtpf1,oFSrtpf1



srPos:		swap	d2			; shft count1 is now in low wrd
		move.w	a2,d5			; d5 <- planes - 1
*+
* do left fringe
*-
srFr1P0:	lea	srFr1P1,a3		; a3 <- return address
		jmp	fringe0			; do left fringe
srFr1P1:	addq.w	#2,a0			; a0 -> next source wrd

*+
* do inner words
*-
		move.w	INNER_CT(a6),d5		; d5 <- internal count
		lea	srInP1,a3		; a3 <- return address

srInP0:		jmp	innerLoop
srInP1:		addq.w	#2,a0			; a0 -> next source wrd
		dbra	d5,srInP0		; do nxt wrd/nxt plane

*+
* do right fringe
*-
		swap	d6			; mask3 is now in low word
		lea	srFr1P,a3		; a3 <- return address
		jmp	fringe1			; do the right fringe
srFr1P:		addq.w	#2,a0			; a0 -> next source wrd
		swap	d6			; mask1 is now in low word

		add.w	a4,a0			; a0 -> next SOURCE row
		add.w	a5,a1			; a1 -> next DESTINATION row

tSrPentry:	swap	d2			; row count is now in low word
		dbra	d2,srPos		; do nxt row
		rts

*******************************************************************************
*			   Shift left positive case			      *
*******************************************************************************

		************************************************
		*************** Do initial setup ***************
		************************************************

transSlPos:	movem.l	d2/a0/a2/a4/a5,-(sp)	; save registers
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
		lea	sltpf0,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
sltpf0CodeLoop:	move.b	(a2)+,(a3)+
		dbra	d1,sltpf0CodeLoop

		;
		; copy inner loop code into mem (yes we are compiling in mem)
		;
		lea	sltpi,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
sltpiCodeLoop:	move.b	(a2)+,(a4)+
		dbra	d1,sltpiCodeLoop

		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		lea	sltpf1,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
sltpf1CodeLoop:	move.b	(a2)+,(a5)+
		dbra	d1,sltpf1CodeLoop

		dbra	d2,SLPLoop

		move.w	#%0100111011010011,(a3)	; (a3) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a4)	; (a4) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a5)	; (a5) <- "jmp (a3)" instruct

		movem.l	(sp)+,d2/a0/a2/a4/a5	; restore registers
		addq.w	#2,a4			; udjust for shift left case
		add.w	d4,a5			; udjust for shift left case
		bra	tSlPentry

		;
		; Routines to do fringe0 for unaligned blit (positive case)
		;
sltpf0:	dc.l	o0Sltpf0,o1Sltpf0,o2Sltpf0,o3Sltpf0
	dc.l	o4Sltpf0,o5Sltpf0,o6Sltpf0,o7Sltpf0
	dc.l	o8Sltpf0,o9Sltpf0,oASltpf0,oBSltpf0
	dc.l	oCSltpf0,oDSltpf0,oESltpf0,oFSltpf0


		;
		; Routines to do inner loop for unaligned blit (pos case)
		;
sltpi:	dc.l	op0Sltpi,op1Sltpi,op2Sltpi,op3Sltpi
	dc.l	op4Sltpi,op5Sltpi,op6Sltpi,op7Sltpi
	dc.l	op8Sltpi,op9Sltpi,opASltpi,opBSltpi
	dc.l	opCSltpi,opDSltpi,opESltpi,opFSltpi

		;
		; Routines to do fringe1 for unaligned blit (positive case)
		;
sltpf1:	dc.l	o0Sltpf1,o1Sltpf1,o2Sltpf1,o3Sltpf1
	dc.l	o4Sltpf1,o5Sltpf1,o6Sltpf1,o7Sltpf1
	dc.l	o8Sltpf1,o9Sltpf1,oASltpf1,oBSltpf1
	dc.l	oCSltpf1,oDSltpf1,oESltpf1,oFSltpf1



slPos:		swap	d2			; shft count1 is now in low wrd
		move.w	a2,d5			; d5 <- planes - 1
*+
* do left fringe
*-
slFr1P0:	lea	slFr1P1,a3		; a3 <- return address
		jmp	fringe0			; do left fringe
slFr1P1:	addq.w	#2,a0			; a0 -> next source wrd

*+
* do inner words
*-
		move.w	INNER_CT(a6),d5		; d5 <- internal count
		lea	slInP1,a3		; a3 <- return address
		bra	slInP2

slInP0:		jmp	innerLoop
slInP1:		addq.w	#2,a0			; a0 -> next source wrd
slInP2:		dbra	d5,slInP0		; do nxt wrd/nxt plane

*+
* do right fringe
*-
		swap	d6			; mask3 is now in low word
		lea	slFr1P,a3		; a3 <- return address
		jmp	fringe1			; do the right fringe
slFr1P:		addq.w	#2,a0			; a0 -> next source wrd
		swap	d6			; mask1 is now in low word

		add.w	a4,a0			; a0 -> next SOURCE row
		add.w	a5,a1			; a1 -> next DESTINATION row

tSlPentry:	swap	d2			; row count is now in low word
		dbra	d2,slPos		; do next row
		rts

*******************************************************************************
*			   Shift right negative case			      *
*******************************************************************************

		************************************************
		*************** Do initial setup ***************
		************************************************

transSrNeg:	movem.l	d2/a0/a2/a4/a5,-(sp)	; save registers
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
		lea	srtnf0,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
srtnf0CodeLoop:	move.b	(a2)+,(a3)+
		dbra	d1,srtnf0CodeLoop

		;
		; copy inner loop code into mem (yes we are compiling in mem)
		;
		lea	srtni,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
srtniCodeLoop:	move.b	(a2)+,(a4)+
		dbra	d1,srtniCodeLoop

		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		lea	srtnf1,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
srtnf1CodeLoop:	move.b	(a2)+,(a5)+
		dbra	d1,srtnf1CodeLoop

		dbra	d2,SRNLoop

		move.w	#%0100111011010011,(a3)	; (a3) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a4)	; (a4) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a5)	; (a5) <- "jmp (a3)" instruct

		movem.l	(sp)+,d2/a0/a2/a4/a5	; restore registers
		subq.w	#2,a4			; udjust for shift left case
		add.w	d4,a5			; udjust for shift left case
		bra	tSrNentry

		;
		; Routines to do fringe0 for unaligned blit (negative case)
		;
srtnf0:	dc.l	o0Srtnf0,o1Srtnf0,o2Srtnf0,o3Srtnf0
	dc.l	o4Srtnf0,o5Srtnf0,o6Srtnf0,o7Srtnf0
	dc.l	o8Srtnf0,o9Srtnf0,oASrtnf0,oBSrtnf0
	dc.l	oCSrtnf0,oDSrtnf0,oESrtnf0,oFSrtnf0


		;
		; Routines to do inner loop for unaligned blit (neg case)
		;
srtni:	dc.l	op0Srtni,op1Srtni,op2Srtni,op3Srtni
	dc.l	op4Srtni,op5Srtni,op6Srtni,op7Srtni
	dc.l	op8Srtni,op9Srtni,opASrtni,opBSrtni
	dc.l	opCSrtni,opDSrtni,opESrtni,opFSrtni

		;
		; Routines to do fringe1 for unaligned blit (negative case)
		;
srtnf1:	dc.l	o0Srtnf1,o1Srtnf1,o2Srtnf1,o3Srtnf1
	dc.l	o4Srtnf1,o5Srtnf1,o6Srtnf1,o7Srtnf1
	dc.l	o8Srtnf1,o9Srtnf1,oASrtnf1,oBSrtnf1
	dc.l	oCSrtnf1,oDSrtnf1,oESrtnf1,oFSrtnf1



srNeg:		swap	d2			; shft count1 is now in low wrd
		move.w	a2,d5			; d5 <- planes - 1
*+
* do right fringe
*-
		subq.w	#2,a0			; a0 -> next source wrd
srFr1N0:	lea	srFr1N1,a3		; a3 <- return address
		jmp	fringe0			; do right fringe
srFr1N1:	subq.w	#2,a0			; a0 -> next source wrd

*+
* do inner words
*-
		move.w	INNER_CT(a6),d5		; d5 <- internal count
		lea	srInN1,a3		; a3 <- return address
		bra	srInN2

srInN0:		jmp	innerLoop
srInN1:		sub.w	#2,a0			; a0 -> next source wrd
srInN2:		dbra	d5,srInN0		; do nxt wrd/nxt plane

*+
* do left fringe
*-
		swap	d6			; mask3 is now in low word
		lea	srFr1N,a3		; a3 <- return address
		jmp	fringe1			; do the left fringe
srFr1N:		swap	d6			; mask1 is now in low word

		add.w	a4,a0			; a0 -> next SOURCE row
		add.w	a5,a1			; a1 -> next DESTINATION row

tSrNentry:	swap	d2			; row count is now in low word
		dbra	d2,srNeg		; do next row
		rts

*******************************************************************************
*			   Shift left negative case			      *
*******************************************************************************


		************************************************
		*************** Do initial setup ***************
		************************************************

transSlNeg:	movem.l	d2/a0/a2/a4/a5,-(sp)	; save registers
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
		lea	sltnf0,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
sltnf0CodeLoop:	move.b	(a2)+,(a3)+
		dbra	d1,sltnf0CodeLoop

		;
		; copy inner loop code into mem (yes we are compiling in mem)
		;
		lea	sltni,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
sltniCodeLoop:	move.b	(a2)+,(a4)+
		dbra	d1,sltniCodeLoop

		;
		; copy the fringe code into mem (yes we are compiling in mem)
		;
		lea	sltnf1,a0		; a0 -> routine list
		move.l	(a0,d0.w),a2		; a2 <- thread to proper log op
		move.w	-2(a2),d1		; length of code in bytes
sltnf1CodeLoop:	move.b	(a2)+,(a5)+
		dbra	d1,sltnf1CodeLoop

		dbra	d2,SLNLoop

		move.w	#%0100111011010011,(a3)	; (a3) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a4)	; (a4) <- "jmp (a3)" instruct
		move.w	#%0100111011010011,(a5)	; (a5) <- "jmp (a3)" instruct

		movem.l	(sp)+,d2/a0/a2/a4/a5	; restore registers
		bra	tSlNentry

		;
		; Routines to do fringe0 for unaligned blit (positive case)
		;
sltnf0:	dc.l	o0Sltnf0,o1Sltnf0,o2Sltnf0,o3Sltnf0
	dc.l	o4Sltnf0,o5Sltnf0,o6Sltnf0,o7Sltnf0
	dc.l	o8Sltnf0,o9Sltnf0,oASltnf0,oBSltnf0
	dc.l	oCSltnf0,oDSltnf0,oESltnf0,oFSltnf0


		;
		; Routines to do inner loop for unaligned blit (pos case)
		;
sltni:	dc.l	op0Sltni,op1Sltni,op2Sltni,op3Sltni
	dc.l	op4Sltni,op5Sltni,op6Sltni,op7Sltni
	dc.l	op8Sltni,op9Sltni,opASltni,opBSltni
	dc.l	opCSltni,opDSltni,opESltni,opFSltni

		;
		; Routines to do fringe1 for unaligned blit (positive case)
		;
sltnf1:	dc.l	o0Sltnf1,o1Sltnf1,o2Sltnf1,o3Sltnf1
	dc.l	o4Sltnf1,o5Sltnf1,o6Sltnf1,o7Sltnf1
	dc.l	o8Sltnf1,o9Sltnf1,oASltnf1,oBSltnf1
	dc.l	oCSltnf1,oDSltnf1,oESltnf1,oFSltnf1



slNeg:		swap	d2			; shft count1 is now in low wrd
		move.w	a2,d5			; d5 <- planes - 1
*+
* do left fringe
*-
		subq.w	#2,a0			; a0 -> next source wrd
slFr1N0:	lea	slFr1N1,a3		; a3 <- return address
		jmp	fringe0			; do right fringe
slFr1N1:	subq.w	#2,a0			; a0 -> next source wrd

*+
* do inner words
*-
		move.w	INNER_CT(a6),d5		; d5 <- internal count
		lea	slInN1,a3		; a3 <- return address

slInN0:		jmp	innerLoop
slInN1:		subq.w	#2,a0			; a0 -> next source wrd
		dbra	d5,slInN0		; do nxt wrd/nxt plane

*+
* do right fringe
*-
		swap	d6			; mask3 is now in low word
		lea	slFr1N,a3		; a3 <- return address
		jmp	fringe1			; do the left fringe
slFr1N:		swap	d6			; mask1 is now in low word

		add.w	a4,a0			; a0 -> next SOURCE row
		add.w	a5,a1			; a1 -> next DESTINATION row

tSlNentry:	swap	d2			; row count is now in low word
		dbra	d2,slNeg		; do nxt row
		rts
