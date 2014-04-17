********************************  sbscolog.s  *********************************
*
* $Revision: 3.0 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbscolog.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/08/06 20:19:42 $     $Locker:  $
* =============================================================================
*
* $Log:	sbscolog.s,v $
* Revision 3.0  91/08/06  20:19:42  lozben
* New generation VDI
* 
* Revision 2.2  91/07/08  14:55:58  lozben
* File created by Slavik Lozben. This file contains the OPAQUE
* logical operation routines which are used by the main calling
* routines to perform Source to Destination blits. The assumtion
* is such that we are dealing with the ST interleved screen memory
* format.
* 
*******************************************************************************

 		;
		; Routines to do fringes for word aligned blit (positive case)
		;
		.globl	op0_opf,op1_opf,op2_opf,op3_opf
		.globl	op4_opf,op5_opf,op6_opf,op7_opf
		.globl	op8_opf,op9_opf,opA_opf,opB_opf
		.globl	opC_opf,opD_opf,opE_opf,opF_opf


		;
		; Routines to do inner loop for word aligned blit (pos case)
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
		; Routines to do inner loop for word aligned blit (neg case)
		;
		.globl	op0_oni,op1_oni,op2_oni,op3_oni
		.globl	op4_oni,op5_oni,op6_oni,op7_oni
		.globl	op8_oni,op9_oni,opA_oni,opB_oni
		.globl	opC_oni,opD_oni,opE_oni,opF_oni


*******************************************************************************
************** Routines for the unaligned blit transparant case ***************
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
		********** shift left positive case ************
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


*****************************************************************************
*********** Logic operations for the left and the right fringe **************
***********  word aligned blit going into positive directions  **************
*****************************************************************************

*+
* D' = 0
*-
		dc.w	op1_opf-op0_opf-3
op0_opf:	not.w	d6		; d6 <- needed mask
		and.w	d6,(a1)+	; D' <- 0
		not.w	d6		; restore d6
*+
* D' = S AND D
*-
		dc.w	op2_opf-op1_opf-3
op1_opf:	move.w	(a0)+,d0	; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		and.w	d1,d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- S AND D

*+
* D' = S AND [NOT D]
*-
		dc.w	op3_opf-op2_opf-3
op2_opf:	move.w	(a1),d0		; d1 <- 1st DESTINATION word
		not.w	d0		;
		and.w	(a0)+,d0	; d0 <- S AND [NOT D] (not fringed)
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <-  S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4_opf-op3_opf-3
op3_opf:	move.w	(a0)+,d0	; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- S

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5_opf-op4_opf-3
op4_opf:	move.w	(a0)+,d0	; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		not.w	d0		;
		and.w	d1,d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- [NOT S] AND D

*+
* D' = D
*-
		dc.w	op6_opf-op5_opf-3
op5_opf:	addq.w	#2,a1		; do nothing (point to nxt dst plane)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7_opf-op6_opf-3
op6_opf:	move.w	(a0)+,d0	; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- S XOR D (XOR mode)

*+
* D' = S OR D
*-
		dc.w	op8_opf-op7_opf-3
op7_opf:	move.w	(a0)+,d0	; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		and.w	d6,d0		;
		or.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- S OR D

*+
* D' = NOT [S OR D]
*-
		dc.w	op9_opf-op8_opf-3
op8_opf:	move.w	(a0)+,d0	; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		or.w	d1,d0		;
		not.w	d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- NOT [S OR D]

*+
* D' = NOT [S XOR D]
*-
		dc.w	opA_opf-op9_opf-3
op9_opf:	move.w	(a0)+,d0	; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		eor.w	d1,d0		;
		not.w	d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- NOT [S XOR D]

*+
* D' = NOT D
*-
		dc.w	opB_opf-opA_opf-3
opA_opf:	move.w	(a1),d1		; d1 <- 1st DESTINATION word
		move.w	d1,d0		;
		not.w	d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- NOT D

*+
* D' = S OR [NOT D]
*-
		dc.w	opC_opf-opB_opf-3
opB_opf:	move.w	(a1),d1		; d1 <- 1st DESTINATION word
		move.w	d1,d0		;
		not.w	d0		;
		or.w	(a0)+,d0	; d0 <- S OR [NOT D] (not fringed)
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opD_opf-opC_opf-3
opC_opf:	move.w	(a0)+,d0	; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		not.w	d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- NOT S

*+
* D' = [NOT S] OR D
*-
		dc.w	opE_opf-opD_opf-3
opD_opf:	move.w	(a0)+,d0	; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		not.w	d0		;
		or.w	d1,d0
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- [NOT S] OR D

*+
* D' = NOT [S AND D]
*-
		dc.w	opF_opf-opE_opf-3
opE_opf:	move.w	(a0)+,d0	; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		and.w	d1,d0		;
		not	d0
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' NOT [S AND D]

*+
* D' = 1
*-
		dc.w	opG_opf-opF_opf-3
opF_opf:	or.w	d6,(a1)+	; D' <- 1's

		dc.w	0
opG_opf:	nop



*****************************************************************************
***********  Logic operations for the inner loop of bit blit   **************
***********  word aligned blit going into positive directions  **************
*****************************************************************************

*+
* D' = 0
*-
		dc.w	op1_opi-op0_opi-3
op0_opi:	clr.w	(a1)+		; D' <- 0

*+
* D' = S AND D
*-
		dc.w	op2_opi-op1_opi-3
op1_opi:	move.w	(a0)+,d0	; d0 <- S
		and.w	d0,(a1)+	; D' <- S AND D

*+
* D' = S AND [NOT D]
*-
		dc.w	op3_opi-op2_opi-3
op2_opi:	move.w	(a0)+,d0	; d0 <- S
		not.w	(a1)		; not the destination word
		and.w	d0,(a1)+	; D' <-  S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4_opi-op3_opi-3
op3_opi:	move.w	(a0)+,(a1)+	; D' <- S

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5_opi-op4_opi-3
op4_opi:	move.w	(a0)+,d0	; d0 < S
		not.w	d0		; d0 <- [NOT S]
		and.w	d0,(a1)+	; D' <- [NOT S] AND D

*+
* D' = D
*-
		dc.w	op6_opi-op5_opi-3
op5_opi:	addq.w	#2,a1		; do nothing (point to nxt src plane)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7_opi-op6_opi-3
op6_opi:	move.w	(a0)+,d0	; d0 <- S
		eor.w	d0,(a1)+	; D' <- S XOR D (XOR mode)

*+
* D' = S OR D
*-
		dc.w	op8_opi-op7_opi-3
op7_opi:	move.w	(a0)+,d0	; d0 <- S
		or.w	d0,(a1)+	; D' <- S OR D

*+
* D' = NOT [S OR D]
*-
		dc.w	op9_opi-op8_opi-3
op8_opi:	move.w	(a0)+,d0	; d0 <- S
		or.w	d0,(a1)		; (a1) <- S OR D
		not.w	(a1)+		; D' <- NOT [S OR D]
		
*+
* D' = NOT [S XOR D]
*-
		dc.w	opA_opi-op9_opi-3
op9_opi:	move.w	(a0)+,d0	; d0 <- S
		eor.w	d0,(a1)		; (a1) <- S OR D
		not.w	(a1)+		; D' <- NOT [S XOR D]

*+
* D' = NOT D
*-
		dc.w	opB_opi-opA_opi-3
opA_opi:	not.w	(a1)+		; D' <- NOT D

*+
* D' = S OR [NOT D]
*-
		dc.w	opC_opi-opB_opi-3
opB_opi:	move.w	(a0)+,d0	; d0 <- S
		not.w	(a1)		; 
		or.w	d0,(a1)+	; D' <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opD_opi-opC_opi-3
opC_opi:	move.w	(a0)+,d0	; d0 <- S
		not.w	d0		; d0 <- NOT S
		move.w	d0,(a1)+	; D' <- NOT S

*+
* D' = [NOT S] OR D
*-
		dc.w	opE_opi-opD_opi-3
opD_opi:	move.w	(a0)+,d0	; d0 <- S
		not.w	d0		; d0 <- NOT S
		or.w	d0,(a1)+	; D' <- [NOT S] OR D

*+
* D' = NOT [S AND D]
*-
		dc.w	opF_opi-opE_opi-3
opE_opi:	move.w	(a0)+,d0	; d0 <- S
		and.w	d0,(A1)		; (a1) <- S AND D
		not.w	(a1)+		; D' NOT [S AND D]

*+
* D' = 1
*-
		dc.w	opG_opi-opF_opi-3
opF_opi:	move.w	#-1,(a1)+	; D' <- 1

		dc.w	0
opG_opi:	nop



*****************************************************************************
*********** Logic operations for the left and the right fringe **************
***********  word aligned blit going into negative directions  **************
*****************************************************************************

*+
* D' = 0
*-
		dc.w	op1_onf-op0_onf-3
op0_onf:	not.w	d6		; d6 <- needed mask
		and.w	d6,-(a1)	; clear out the needed bits
		not.w	d6		; restore d6

*+
* D' = S AND D
*-
		dc.w	op2_onf-op1_onf-3
op1_onf:	move.w	-(a0),d0	; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		and.w	d1,d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- S AND D

*+
* D' = S AND [NOT D]
*-
		dc.w	op3_onf-op2_onf-3
op2_onf:	move.w	-(a1),d0	; d0 <- 1st DESTINATION word
		move.w	d0,d1		; d1 <- 1st DESTINATION word
		not.w	d0		;
		and.w	-(a0),d0	; d0 <- S AND [NOT D] (not fringed)
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <-  S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4_onf-op3_onf-3
op3_onf:	move.w	-(a0),d0	; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- S

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5_onf-op4_onf-3
op4_onf:	move.w	-(a0),d0	; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		not.w	d0		;
		and.w	d1,d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- [NOT S] AND D

*+
* D' = D
*-
		dc.w	op6_onf-op5_onf-3
op5_onf:	subq.w	#2,a1		; do nothing (point to nxt dst plane)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7_onf-op6_onf-3
op6_onf:	move.w	-(a0),d0	; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- S XOR D (XOR mode)

*+
* D' = S OR D
*-
		dc.w	op8_onf-op7_onf-3
op7_onf:	move.w	-(a0),d0	; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		and.w	d6,d0		;
		or.w	d1,d0		;
		move.w	d0,(a1)		; D' <- S OR D

*+
* D' = NOT [S OR D]
*-
		dc.w	op9_onf-op8_onf-3
op8_onf:	move.w	-(a0),d0	; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		or.w	d1,d0		;
		not.w	d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- NOT [S OR D]

*+
* D' = NOT [S XOR D]
*-
		dc.w	opA_onf-op9_onf-3
op9_onf:	move.w	-(a0),d0	; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		eor.w	d1,d0		;
		not.w	d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- NOT [S XOR D]

*+
* D' = NOT D
*-
		dc.w	opB_onf-opA_onf-3
opA_onf:	move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		move.w	d1,d0		;
		not.w	d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- NOT D

*+
* D' = S OR [NOT D]
*-
		dc.w	opC_onf-opB_onf-3
opB_onf:	move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		move.w	d1,d0		;
		not.w	d0		;
		or.w	-(a0),d0	; d0 <- S OR [NOT D] (not fringed)
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opD_onf-opC_onf-3
opC_onf:	move.w	-(a0),d0	; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		not.w	d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- NOT S

*+
* D' = [NOT S] OR D
*-
		dc.w	opE_onf-opD_onf-3
opD_onf:	move.w	-(a0),d0	; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		not.w	d0		;
		or.w	d1,d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- [NOT S] OR D

*+
* D' = NOT [S AND D]
*-
		dc.w	opF_onf-opE_onf-3
opE_onf:	move.w	-(a0),d0	; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		and.w	d1,d0		;
		not	d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' NOT [S AND D]

*+
* D' = 1
*-
		dc.w	opG_onf-opF_onf-3
opF_onf:	or.w	d6,-(a1)	; D <- 1's

		dc.w	0
opG_onf:	nop



*****************************************************************************
***********  Logic operations for the inner loop of bit blit   **************
***********  word aligned blit going into negative directions  **************
*****************************************************************************

		dc.w	op1_oni-op0_oni-3
op0_oni:	clr.w	-(a1)		; D' <- 0

*+
* D' = S AND D
*-
		dc.w	op2_oni-op1_oni-3
op1_oni:	move.w	-(a0),d0	; d0 <- S
		and.w	d0,-(a1)	; D' <- S AND D

*+
* D' = S AND [NOT D]
*-
		dc.w	op3_oni-op2_oni-3
op2_oni:	move.w	-(a0),d0	; d0 <- S
		not.w	-(a1)		; not the destination word
		and.w	d0,(a1)		; D' <-  S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4_oni-op3_oni-3
op3_oni:	move.w	-(a0),-(a1)	; D' <- S

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5_oni-op4_oni-3
op4_oni:	move.w	-(a0),d0	; d0 <- S
		not.w	d0		; d0 <- [NOT S]
		and.w	d0,-(a1)	; D' <- [NOT S] AND D

*+
* D' = D
*-
		dc.w	op6_oni-op5_oni-3
op5_oni:	subq.w	#2,a1		; do nothing (point to nxt src plane)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7_oni-op6_oni-3
op6_oni:	move.w	-(a0),d0	; d0 <- S
		eor.w	d0,-(a1)	; D' <- S XOR D (XOR mode)

*+
* D' = S OR D
*-
		dc.w	op8_oni-op7_oni-3
op7_oni:	move.w	-(a0),d0	; d0 <- S
		or.w	d0,-(a1)	; D' <- S OR D

*+
* D' = NOT [S OR D]
*-
		dc.w	op9_oni-op8_oni-3
op8_oni:	move.w	-(a0),d0	; d0 <- S
		or.w	d0,-(a1)	; (a1) <- S OR D
		not.w	(a1)		; D' <- NOT [S OR D]

*+
* D' = NOT [S XOR D]
*-
		dc.w	opA_oni-op9_oni-3
op9_oni:	move.w	-(a0),d0	; d0 <- S
		eor.w	d0,-(a1)	; (a1) <- S OR D
		not.w	(a1)		; D' <- NOT [S XOR D]

*+
* D' = NOT D
*-
		dc.w	opB_oni-opA_oni-3
opA_oni:	not.w	-(a1)		; D' <- NOT D

*+
* D' = S OR [NOT D]
*-
		dc.w	opC_oni-opB_oni-3
opB_oni:	move.w	-(a0),d0	; d0 <- S
		not.w	-(a1)		; 
		or.w	d0,(a1)		; D' <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opD_oni-opC_oni-3
opC_oni:	move.w	-(a0),d0	; d0 <- S
		not.w	d0		; d0 <- NOT S
		move.w	d0,-(a1)	; D' <- NOT S

*+
* D' = [NOT S] OR D
*-
		dc.w	opE_oni-opD_oni-3
opD_oni:	move.w	-(a0),d0	; d0 <- S
		not.w	d0		; d0 <- NOT S
		or.w	d0,-(a1)	; D' <- [NOT S] OR D

*+
* D' = NOT [S AND D]
*-
		dc.w	opF_oni-opE_oni-3
opE_oni:	move.w	-(a0),d0	; d0 <- S
		and.w	d0,-(A1)	; (a1) <- S AND D
		not.w	(a1)		; D' NOT [S AND D]

*+
* D' = 1
*-
		dc.w	opG_oni-opF_oni-3
opF_oni:	move.w	#-1,-(a1)	; D' <- 1

		dc.w	0
opG_oni:	nop

*******************************************************************************
*******************************************************************************
****************************    UNALIGNED BLIT    *****************************
**************************** Transparant Positive *****************************
*******************************************************************************
*******************************************************************************


*******************************************************************************
***************** Logic operations for the left fringe (0) ********************
*****************  shift right positive case, transparant  ********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	o1Sropf0-o0Sropf0-3
o0Sropf0:	not.w	d6		; get the right mask
		and.w	d6,(a1)+	; mask out the needed bits in dst
		not.w	d6		; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Sropf0-o1Sropf0-3
o1Sropf0:	move.w	(a0)+,d0		; d0 <- src wrd
		move.w	(a1),d1			; d1 <- dst
		lsr.w	d2,d0			; adjust bits we need to splat
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0			; d0 <- (dst eor (src and dst))
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd

*+
* D' = S AND [NOT D]
*-
		dc.w	o3Sropf0-o2Sropf0-3
o2Sropf0:	move.w	(a0)+,d0		; d0 <- src and [not dst]
		move.w	(a1),d1			; d1 <- dst
		not.w	d1			; d1 <- not dst
		lsr.w	d2,d0			; adjust bits we need to splat
		and.w	d1,d0			; d0 <- S AND D
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor (src and dst))
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd

*+
* D' = S (Replace Mode)
*-
		dc.w	o4Sropf0-o3Sropf0-3
o3Sropf0:	move.w	(a0)+,d0		; d0 <- src wrd
		move.w	(a1),d1			; d1 <- dst
		lsr.w	d2,d0			; adjust bits we need to splat
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	o5Sropf0-o4Sropf0-3
o4Sropf0:	move.w	(a0)+,d0		; d0 <- src wrd
		move.w	(a1),d1			; d1 <- dst
		not.w	d0			; not the source
		lsr.w	d2,d0			; adjust bits we need to splat
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0			; d0 <- (dst eor (src and dst))
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd

*+
* D' = D
*-
		dc.w	o6Sropf0-o5Sropf0-3
o5Sropf0:	addq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Sropf0-o6Sropf0-3
o6Sropf0:	move.w	(a0)+,d0		; d0 <- src wrd
		lsr.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		eor.w	d0,(a1)+		; set the dst wrd

*+
* D' = S OR D
*-
		dc.w	o8Sropf0-o7Sropf0-3
o7Sropf0:	move.w	(a0)+,d0		; d0 <- src wrd
		lsr.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		or.w	d0,(a1)+		; set the dst wrd

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*
*-
		dc.w	o9Sropf0-o8Sropf0-3
o8Sropf0:	move.w	(a0)+,d0		; d0 <- src and [not dst]
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- dst
		not.w	d1			; d1 <- not dst
		lsr.w	d2,d0			; adjust bits we need to splat
		and.w	d1,d0			; d0 <- S AND D
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor (src and dst))
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd

*+
* D' = NOT [S XOR D]
*-
		dc.w	oASropf0-o9Sropf0-3
o9Sropf0:	move.w	(a0)+,d0		; d0 <- src wrd
		move.w	(a1),d1			; d1 <- dst
		lsr.w	d2,d0			; adjust bits we need to splat
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		eor.w	d1,d0			; d0 <- (dst eor (src and dst))
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd

*+
* D' = NOT D
*-
		dc.w	oBSropf0-oASropf0-3
oASropf0:	move.w	(a1),d1			; d1 <- dst
		move.w	d1,d0			; d0 <- dst
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd

*+
* D' = S OR [NOT D]
*-
		dc.w	oCSropf0-oBSropf0-3
oBSropf0:	move.w	(a0)+,d0		; d0 <- src wrd
		lsr.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		move.w	(a1),d1			; d1 <- dst wrd
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd

*+
* D' = NOT S
*-
		dc.w	oDSropf0-oCSropf0-3
oCSropf0:	move.w	(a0)+,d0		; d0 <- src wrd
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- dst
		lsr.w	d2,d0			; adjust bits we need to splat
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd

*+
* D' = [NOT S] OR D
*-
		dc.w	oESropf0-oDSropf0-3
oDSropf0:	move.w	(a0)+,d0		; d0 <- src wrd
		not.w	d0			; d0 <- NOT S
		lsr.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		or.w	d0,(a1)+		; set the dst wrd

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	oFSropf0-oESropf0-3
oESropf0:	move.w	(a0)+,d0		; d0 <- src wrd
		not.w	d0			; d0 <- NOT S
		lsr.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		move.w	(a1),d1			; d1 <- dst wrd
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd

*+
* D' = 1
*-
		dc.w	oGSropf0-oFSropf0-3
oFSropf0:	or.w	d6,(a1)+		; set the dst wrd to ones

		dc.w	0
oGSropf0:	nop


*******************************************************************************
******************  Logic operations for the inner loop   *********************
****************** shift right positive case, transparant *********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	op1Sropi-op0Sropi-3
op0Sropi:	clr.w	(a1)+			; clear the dst wrd

*+
* D' = S AND D
*-
		dc.w	op2Sropi-op1Sropi-3
op1Sropi:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0)+,d0		; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		and.w	d0,(a1)+		; dst <- S AND D

*+
* D' = S AND [NOT D]
*-
		dc.w	op3Sropi-op2Sropi-3
op2Sropi:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0)+,d0		; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		move.w	d0,(a1)+		; dst <- S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4Sropi-op3Sropi-3
op3Sropi:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0)+,d0		; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	d0,(a1)+		; dst <- S

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5Sropi-op4Sropi-3
op4Sropi:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0)+,d0		; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		not.w	d0			; d0 <- NOT S
		and.w	d0,(a1)+		; dst <- [NOT S] AND D

*+
* D' = D
*-
		dc.w	op6Sropi-op5Sropi-3
op5Sropi:	addq.w	#2,a1

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7Sropi-op6Sropi-3
op6Sropi:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0)+,d0		; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		eor.w	d0,(a1)+		; dst <- S XOR D

*+
* D' = S OR D
*-
		dc.w	op8Sropi-op7Sropi-3
op7Sropi:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0)+,d0		; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		or.w	d0,(a1)+		; dst <- S OR D

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	op9Sropi-op8Sropi-3
op8Sropi:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0)+,d0		; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- [NOT S] AND [NOT D]
		move.w	d0,(a1)+		; dst <- [NOT S] AND [NOT D]

*+
* D' = NOT [S XOR D]
*-
		dc.w	opASropi-op9Sropi-3
op9Sropi:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0)+,d0		; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		move.w	(a1),d1			; d1 <- D
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		move.w	d0,(a1)+		; dst <- NOT [S XOR D]

*+
* D' = NOT D
*-
		dc.w	opBSropi-opASropi-3
opASropi:	not.w	(a1)+			; not dst wrd

*+
* D' = S OR [NOT D]
*-
		dc.w	opCSropi-opBSropi-3
opBSropi:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0)+,d0		; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		move.w	d0,(a1)+		; dst <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opDSropi-opCSropi-3
opCSropi:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0)+,d0		; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	d0,(a1)+		; dst <- S

*+
* D' = [NOT S] OR D
*-
		dc.w	opESropi-opDSropi-3
opDSropi:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0)+,d0		; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		not.w	d0			; d0 <- NOT S
		or.w	d0,(a1)+		; dst <- [NOT S] OR D

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	opFSropi-opESropi-3
opESropi:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0)+,d0		; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- [NOT S] OR [NOT D]
		move.w	d0,(a1)+		; dst <- [NOT S] OR [NOT D]

*+
* D' = 1
*-
		dc.w	opGSropi-opFSropi-3
opFSropi:	move.w	#-1,(a1)+

		dc.w	0
opGSropi:	nop


*******************************************************************************
***************     Logic operations for the fringe (1)    ********************
***************   shift right positive case, transparant   ********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	o1Sropf1-o0Sropf1-3
o0Sropf1:	not.w	d7			; needed mask
		and.w	d7,(a1)+		; set the dst wrd
		not.w	d7
		not.w	d6			; needed mask
		neg.w	d4			; d4 becomes positive
		and.w	d6,-2(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; d4 becomes negative
		not.w	d6			; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Sropf1-o1Sropf1-3
o1Sropf1:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		move.w	(a0)+,d0		; get src again
		neg	d4			; d4 becomes positive
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; d4 becomes negative

*+
* D' = S AND [NOT D]
*-
		dc.w	o3Sropf1-o2Sropf1-3
o2Sropf1:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		move.w	(a0)+,d0		; get src again
		neg.w	d4			; d4 becomes positive
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; d4 becomes negative

*+
* D' = S (Replace Mode)
*-
		dc.w	o4Sropf1-o3Sropf1-3
o3Sropf1:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		move.w	(a0)+,d0		; get src again
		neg.w	d4			; d4 becomes positive
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; d4 becomes negative

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	o5Sropf1-o4Sropf1-3
o4Sropf1:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- dest
		and.w	d1,d0			; d0 <- [NOT S] AND D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		move.w	(a0)+,d0		; get src again
		not.w	d0			; d0 <- NOT S
		neg.w	d4			; d4 becomes positive
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		and.w	d1,d0			; d0 <- [NOT S] AND D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; d4 becomes negative

*+
* D' = D
*-
		dc.w	o6Sropf1-o5Sropf1-3
o5Sropf1:	addq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Sropf1-o6Sropf1-3
o6Sropf1:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		move.w	(a0)+,d0		; get src again
		neg.w	d4			; d4 becomes positive
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; d4 becomes negative

*+
* D' = S OR D
*-
		dc.w	o8Sropf1-o7Sropf1-3
o7Sropf1:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		or.w	d1,d0			; d0 <- S OR D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		move.w	(a0)+,d0		; get src again
		neg.w	d4			; d4 becomes positive
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		or.w	d1,d0			; d0 <- S OR D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; d4 becomes negative

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	o9Sropf1-o8Sropf1-3
o8Sropf1:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- dest
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- [NOT S] AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		move.w	(a0)+,d0		; get src again
		not.w	d0			; d0 <- NOT S
		neg.w	d4			; d4 becomes positive
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- [NOT S] AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; d4 becomes negative

*+
* D' = NOT [S XOR D]
*-
		dc.w	oASropf1-o9Sropf1-3
o9Sropf1:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		move.w	(a0)+,d0		; get src again
		neg.w	d4			; d4 becomes positive
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; d4 becomes negative

*+
* D' = NOT D
*-
		dc.w	oBSropf1-oASropf1-3
oASropf1:	move.w	(a1),d0			; d1 <- D
		move.w	d0,d1			; d1 <- D
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		neg.w	d4			; d4 becomes positive
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		move.w	d1,d0			; d0 <- D
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; d4 becomes negative

*+
* D' = S OR [NOT D]
*-
		dc.w	oCSropf1-oBSropf1-3
oBSropf1:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		move.w	(a0)+,d0		; get src again
		neg.w	d4			; d4 becomes positive
 		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; d4 becomes negative

*+
* D' = NOT S
*-
		dc.w	oDSropf1-oCSropf1-3
oCSropf1:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- dest
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		move.w	(a0)+,d0		; get src again
		not.w	d0			; d0 <- NOT S
		neg.w	d4			; d4 becomes positive
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; d4 becomes negative

*+
* D' = [NOT S] OR D
*-
		dc.w	oESropf1-oDSropf1-3
oDSropf1:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- dest
		or.w	d1,d0			; d0 <- [NOT S] OR D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		move.w	(a0)+,d0		; get src again
		not.w	d0			; d0 <- NOT S
		neg.w	d4			; d4 becomes positive
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		or.w	d1,d0			; d0 <- [NOT S] OR D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; d4 becomes negative

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	oFSropf1-oESropf1-3
oESropf1:	move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- dest
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- [NOT S] OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		move.w	(a0)+,d0		; get src again
		not.w	d0			; d0 <- NOT S
		neg.w	d4			; d4 becomes positive
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- [NOT S] OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; d4 becomes negative

*+
* D' = 1
*-
		dc.w	oGSropf1-oFSropf1-3
oFSropf1:	or.w	d7,(a1)+		; set the dst wrd
		neg.w	d4			; d4 becomes positive
		or.w	d6,-2(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; d4 becomes negative

		dc.w	0
oGSropf1:	nop


*******************************************************************************
***************** Logic operations for the left fringe (0) ********************
*****************   shift left positive case, transparant  ********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	o1Slopf0-o0Slopf0-3
o0Slopf0:	not.w	d6			; get the right mask
		and.w	d6,(a1)+		; mask out needed bits in dst
		not.w	d6			; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Slopf0-o1Slopf0-3
o1Slopf0:	move.w	(a0)+,d0		; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	(a1),d1			; d1 <- D
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; D <- S AND D

*+
* D' = S AND [NOT D]
*-
		dc.w	o3Slopf0-o2Slopf0-3
o2Slopf0:	move.w	(a0)+,d0		; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; D <- S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	o4Slopf0-o3Slopf0-3
o3Slopf0:	move.w	(a0)+,d0		; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	(a1),d1			; d1 <- D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	o5Slopf0-o4Slopf0-3
o4Slopf0:	move.w	(a0)+,d0		; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		not.w	d0			; d0 <- S
		move.w	(a1),d1			; d1 <- D
		and.w	d1,d0			; d0 <- [NOT S] AND D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; D <- [NOT S] AND D

*+
* D' = D
*-
		dc.w	o6Slopf0-o5Slopf0-3
o5Slopf0:	addq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Slopf0-o6Slopf0-3
o6Slopf0:	move.w	(a0)+,d0		; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	(a1),d1			; d1 <- D
		eor.w	d1,d0			; d0 <- S XOR D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; D <- S XOR D

*+
* D' = S OR D
*-
		dc.w	o8Slopf0-o7Slopf0-3
o7Slopf0:	move.w	(a0)+,d0		; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	(a1),d1			; d1 <- D
		eor.w	d1,d0			; d0 <- S OR D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; D <- S OR D

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	o9Slopf0-o8Slopf0-3
o8Slopf0:	move.w	(a0)+,d0		; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- [NOT S] AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; D <- [NOT S] AND [NOT D]

*+
* D' = NOT [S XOR D]
*-
		dc.w	oASlopf0-o9Slopf0-3
o9Slopf0:	move.w	(a0)+,d0		; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	(a1),d1			; d1 <- D
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; D <- NOT [S XOR D]

*+
* D' = NOT D
*-
		dc.w	oBSlopf0-oASlopf0-3
oASlopf0:	move.w	(a1),d0			; d0 <- D
		move.w	d0,d1			; d1 <- D
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst

*+
* D' = S OR [NOT D]
*-
		dc.w	oCSlopf0-oBSlopf0-3
oBSlopf0:	move.w	(a0)+,d0		; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; D <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	oDSlopf0-oCSlopf0-3
oCSlopf0:	move.w	(a0)+,d0		; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst

*+
* D' = [NOT S] OR D
*-
		dc.w	oESlopf0-oDSlopf0-3
oDSlopf0:	move.w	(a0)+,d0		; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- D
		eor.w	d1,d0			; d0 <- [NOT S] OR D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; D <- [NOT S] OR D

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	oFSlopf0-oESlopf0-3
oESlopf0:	move.w	(a0)+,d0		; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- [NOT S] OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; D <- [NOT S] OR [NOT D]

*+
* D' = 1
*-
		dc.w	oGSlopf0-oFSlopf0-3
oFSlopf0:	or.w	d6,(a1)+		; set the dst wrd to ones

		dc.w	0
oGSlopf0:	nop


*******************************************************************************
******************  Logic operations for the inner loop   *********************
****************** shift left positive case, transparant  *********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	op1Slopi-op0Slopi-3
op0Slopi:	clr.w	(a1)+			; clear the dst wrd

*+
* D' = S AND D
*-
		dc.w	op2Slopi-op1Slopi-3
op1Slopi:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		and.w	d0,(a1)+		; set nxt dst wrd in plane

*+
* D' = S AND [NOT D]
*-
		dc.w	op3Slopi-op2Slopi-3
op2Slopi:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		move.w	d0,(a1)+		; D  <- S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4Slopi-op3Slopi-3
op3Slopi:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	d0,(a1)+		; set nxt dst wrd in plane

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5Slopi-op4Slopi-3
op4Slopi:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		and.w	d0,(a1)+		; D  <- [NOT S] AND D

*+
* D' = D
*-
		dc.w	op6Slopi-op5Slopi-3
op5Slopi:	addq.w	#2,a1

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7Slopi-op6Slopi-3
op6Slopi:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		eor.w	d0,(a1)+		; D <- S XOR D

*+
* D' = S OR D
*-
		dc.w	op8Slopi-op7Slopi-3
op7Slopi:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		or.w	d0,(a1)+		; D <- S OR D

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	op9Slopi-op8Slopi-3
op8Slopi:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- [NOT S] AND [NOT D]
		move.w	d0,(a1)+		; D  <- [NOT S] AND [NOT D]

*+
* D' = NOT [S XOR D]
*-
		dc.w	opASlopi-op9Slopi-3
op9Slopi:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- D
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		move.w	d0,(a1)+		; D  <- NOT [S XOR D]
		
*+
* D' = NOT D
*-
		dc.w	opBSlopi-opASlopi-3
opASlopi:	not.w	(a1)+			; not dst wrd

*+
* D' = S OR [NOT D]
*-
		dc.w	opCSlopi-opBSlopi-3
opBSlopi:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		move.w	d0,(a1)+		; D  <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opDSlopi-opCSlopi-3
opCSlopi:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	d0,(a1)+		; D -> NOT S

*+
* D' = [NOT S] OR D
*-
		dc.w	opESlopi-opDSlopi-3
opDSlopi:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		or.w	d0,(a1)+		; D -> [NOT S] OR D

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	opFSlopi-opESlopi-3
opESlopi:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- [NOT S] OR [NOT D]
		move.w	d0,(a1)+		; D  <- [NOT S] OR [NOT D]

*+
* D' = 1
*-
		dc.w	opGSlopi-opFSlopi-3
opFSlopi:	move.w	#-1,(a1)+

		dc.w	0
opGSlopi:	nop


*******************************************************************************
***************  Logic operations for the right fringe (1) ********************
***************    shift left positive case, transparant   ********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	o1Slopf1-o0Slopf1-3
o0Slopf1:	not.w	d7			; needed mask
		and.w	d7,(a1)+		; set the dst wrd
		not.w	d7
		not.w	d6			; needed mask
		and.w	d6,-2(a1,d4.w)		; set nxt dst wrd in plane
		not.w	d6			; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Slopf1-o1Slopf1-3
o1Slopf1:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	-2(a0,d4.w),d0		; get src again
		move.w	-2(a1,d4.w),d1		; get prev dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = S AND [NOT D]
*-
		dc.w	o3Slopf1-o2Slopf1-3
o2Slopf1:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	-2(a0,d4.w),d0		; get src again
		move.w	-2(a1,d4.w),d1		; get prev dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = S (Replace Mode)
*-
		dc.w	o4Slopf1-o3Slopf1-3
o3Slopf1:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	-2(a0,d4.w),d0		; get src again
		move.w	-2(a1,d4.w),d1		; get prev dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	o5Slopf1-o4Slopf1-3
o4Slopf1:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- dest
		and.w	d1,d0			; d0 <- [NOT S] AND D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	-2(a0,d4.w),d0		; get src again
		not.w	d0			; d0 <- NOT S
		move.w	-2(a1,d4.w),d1		; get prev dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		and.w	d1,d0			; d0 <- [NOT S] AND D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = D
*-
		dc.w	o6Slopf1-o5Slopf1-3
o5Slopf1:	addq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Slopf1-o6Slopf1-3
o6Slopf1:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	-2(a0,d4.w),d0		; get src again
		move.w	-2(a1,d4.w),d1		; get prev dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = S OR D
*-
		dc.w	o8Slopf1-o7Slopf1-3
o7Slopf1:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		or.w	d1,d0			; d0 <- S OR D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	-2(a0,d4.w),d0		; get src again
		move.w	-2(a1,d4.w),d1		; get prev dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		or.w	d1,d0			; d0 <- S OR D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	o9Slopf1-o8Slopf1-3
o8Slopf1:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- dest
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- [NOT S] AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	-2(a0,d4.w),d0		; get src again
		not.w	d0			; d0 <- NOT S
		move.w	-2(a1,d4.w),d1		; get prev dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- [NOT S] AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = NOT [S XOR D]
*-
		dc.w	oASlopf1-o9Slopf1-3
o9Slopf1:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	-2(a0,d4.w),d0		; get src again
		move.w	-2(a1,d4.w),d1		; get prev dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = NOT D
*-
		dc.w	oBSlopf1-oASlopf1-3
oASlopf1:	move.w	(a1),d0			; d0 <- D
		move.w	d0,d1			; d1 <- D
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		move.w	d1,d0			; d0 <- D
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = S OR [NOT D]
*-
		dc.w	oCSlopf1-oBSlopf1-3
oBSlopf1:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	-2(a0,d4.w),d0		; get src again
		move.w	-2(a1,d4.w),d1		; get prev dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = NOT S
*-
		dc.w	oDSlopf1-oCSlopf1-3
oCSlopf1:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- dest
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	-2(a0,d4.w),d0		; get src again
		not.w	d0			; d0 <- NOT S
		move.w	-2(a1,d4.w),d1		; get prev dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = [NOT S] OR D
*-
		dc.w	oESlopf1-oDSlopf1-3
oDSlopf1:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- dest
		or.w	d1,d0			; d0 <- [NOT S] OR D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	-2(a0,d4.w),d0		; get src again
		not.w	d0			; d0 <- NOT S
		move.w	-2(a1,d4.w),d1		; get prev dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		or.w	d1,d0			; d0 <- [NOT S] OR D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	oFSlopf1-oESlopf1-3
oESlopf1:	move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- dest
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- [NOT S] OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	-2(a0,d4.w),d0		; get src again
		not.w	d0			; d0 <- NOT S
		move.w	-2(a1,d4.w),d1		; get prev dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- [NOT S] OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = 1
*-
		dc.w	oGSlopf1-oFSlopf1-3
oFSlopf1:	or.w	d7,(a1)+		; set the dst wrd
		or.w	d6,-2(a1,d4.w)		; set nxt dst wrd in plane

		dc.w	0
oGSlopf1:	nop


*******************************************************************************
*******************************************************************************
****************************     UNALIGNED BLIT   *****************************
**************************** Transparant Negative *****************************
*******************************************************************************
*******************************************************************************


*******************************************************************************
***************** Logic operations for the right fringe (0) *******************
*****************   shift left negative case, transparant   *******************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	o1Slonf0-o0Slonf0-3
o0Slonf0:	not.w	d6			; get the right mask
		and.w	d6,-(a1)		; mask out the needed bits in dst
		not.w	d6			; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Slonf0-o1Slonf0-3
o1Slonf0:	move.w	-(a0),d0		; d0 <- src wrd
		move.w	-(a1),d1		; d1 <- dst
		lsl.w	d2,d0			; adjust bits we need to splat
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0			; d0 <- (dst eor (src and dst))
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd

*+
* D' = S AND [NOT D]
*-
		dc.w	o3Slonf0-o2Slonf0-3
o2Slonf0:	move.w	-(a0),d0		; d0 <- src and [not dst]
		move.w	-(a1),d1		; d1 <- dst
		not.w	d1			; d1 <- not dst
		lsl.w	d2,d0			; adjust bits we need to splat
		and.w	d1,d0			; d0 <- S AND D
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor (src and dst))
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd

*+
* D' = S (Replace Mode)
*-
		dc.w	o4Slonf0-o3Slonf0-3
o3Slonf0:	move.w	-(a0),d0		; d0 <- src wrd
		move.w	-(a1),d1		; d1 <- dst
		lsl.w	d2,d0			; adjust bits we need to splat
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	o5Slonf0-o4Slonf0-3
o4Slonf0:	move.w	-(a0),d0		; d0 <- src wrd
		move.w	-(a1),d1		; d1 <- dst
		not.w	d0			; not the source
		lsl.w	d2,d0			; adjust bits we need to splat
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0			; d0 <- (dst eor (src and dst))
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd

*+
* D' = D
*-
		dc.w	o6Slonf0-o5Slonf0-3
o5Slonf0:	subq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Slonf0-o6Slonf0-3
o6Slonf0:	move.w	-(a0),d0		; d0 <- src wrd
		lsl.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		eor.w	d0,-(a1)		; set the dst wrd

*+
* D' = S OR D
*-
		dc.w	o8Slonf0-o7Slonf0-3
o7Slonf0:	move.w	-(a0),d0		; d0 <- src wrd
		lsl.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		or.w	d0,-(a1)		; set the dst wrd

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*
*-
		dc.w	o9Slonf0-o8Slonf0-3
o8Slonf0:	move.w	-(a0),d0		; d0 <- src and [not dst]
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- dst
		not.w	d1			; d1 <- not dst
		lsl.w	d2,d0			; adjust bits we need to splat
		and.w	d1,d0			; d0 <- S AND D
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor (src and dst))
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd

*+
* D' = NOT [S XOR D]
*-
		dc.w	oASlonf0-o9Slonf0-3
o9Slonf0:	move.w	-(a0),d0		; d0 <- src wrd
		move.w	-(a1),d1		; d1 <- dst
		lsl.w	d2,d0			; adjust bits we need to splat
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		eor.w	d1,d0			; d0 <- (dst eor (src and dst))
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd

*+
* D' = NOT D
*-
		dc.w	oBSlonf0-oASlonf0-3
oASlonf0:	move.w	-(a1),d1		; d1 <- dst
		move.w	d1,d0			; d0 <- dst
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd

*+
* D' = S OR [NOT D]
*-
		dc.w	oCSlonf0-oBSlonf0-3
oBSlonf0:	move.w	-(a0),d0		; d0 <- src wrd
		lsl.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		move.w	-(a1),d1		; d1 <- dst wrd
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd

*+
* D' = NOT S
*-
		dc.w	oDSlonf0-oCSlonf0-3
oCSlonf0:	move.w	-(a0),d0		; d0 <- src wrd
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- dst
		lsl.w	d2,d0			; adjust bits we need to splat
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd

*+
* D' = [NOT S] OR D
*-
		dc.w	oESlonf0-oDSlonf0-3
oDSlonf0:	move.w	-(a0),d0		; d0 <- src wrd
		not.w	d0			; d0 <- NOT S
		lsl.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		or.w	d0,-(a1)		; set the dst wrd

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	oFSlonf0-oESlonf0-3
oESlonf0:	move.w	-(a0),d0		; d0 <- src wrd
		not.w	d0			; d0 <- NOT S
		lsl.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		move.w	-(a1),d1		; d1 <- dst wrd
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd

*+
* D' = 1
*-
		dc.w	oGSlonf0-oFSlonf0-3
oFSlonf0:	or.w	d6,-(a1)		; set the dst wrd to ones

		dc.w	0
oGSlonf0:	nop


*******************************************************************************
******************  Logic operations for the inner loop   *********************
****************** shift left negative case, transparant  *********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	op1Sloni-op0Sloni-3
op0Sloni:	clr.w	-(a1)			; clear the dst wrd

*+
* D' = S AND D
*-
		dc.w	op2Sloni-op1Sloni-3
op1Sloni:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		and.w	d0,-(a1)		; dst <- S AND D

*+
* D' = S AND [NOT D]
*-
		dc.w	op3Sloni-op2Sloni-3
op2Sloni:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		move.w	d0,(a1)			; dst <- S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4Sloni-op3Sloni-3
op3Sloni:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	d0,-(a1)		; dst <- S

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5Sloni-op4Sloni-3
op4Sloni:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		not.w	d0			; d0 <- NOT S
		and.w	d0,-(a1)		; dst <- [NOT S] AND D

*+
* D' = D
*-
		dc.w	op6Sloni-op5Sloni-3
op5Sloni:	subq.w	#2,a1

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7Sloni-op6Sloni-3
op6Sloni:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		eor.w	d0,-(a1)		; dst <- S XOR D

*+
* D' = S OR D
*-
		dc.w	op8Sloni-op7Sloni-3
op7Sloni:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		or.w	d0,-(a1)		; dst <- S OR D

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	op9Sloni-op8Sloni-3
op8Sloni:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- [NOT S] AND [NOT D]
		move.w	d0,(a1)			; dst <- [NOT S] AND [NOT D]

*+
* D' = NOT [S XOR D]
*-
		dc.w	opASloni-op9Sloni-3
op9Sloni:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		move.w	-(a1),d1		; d1 <- D
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		move.w	d0,(a1)			; dst <- NOT [S XOR D]

*+
* D' = NOT D
*-
		dc.w	opBSloni-opASloni-3
opASloni:	not.w	-(a1)			; not dst wrd

*+
* D' = S OR [NOT D]
*-
		dc.w	opCSloni-opBSloni-3
opBSloni:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		move.w	d0,(a1)			; dst <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opDSloni-opCSloni-3
opCSloni:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	d0,-(a1)		; dst <- S

*+
* D' = [NOT S] OR D
*-
		dc.w	opESloni-opDSloni-3
opDSloni:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		not.w	d0			; d0 <- NOT S
		or.w	d0,-(a1)		; dst <- [NOT S] OR D

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	opFSloni-opESloni-3
opESloni:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- [NOT S] OR [NOT D]
		move.w	d0,(a1)			; dst <- [NOT S] OR [NOT D]

*+
* D' = 1
*-
		dc.w	opGSloni-opFSloni-3
opFSloni:	move.w	#-1,-(a1)

		dc.w	0
opGSloni:	nop


*******************************************************************************
***************  Logic operations for the left fringe (1)  ********************
***************    shift left negative case, transparant   ********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	o1Slonf1-o0Slonf1-3
o0Slonf1:	not.w	d7			; needed mask
		and.w	d7,-(a1)		; set the dst wrd
		not.w	d7
		not.w	d6			; needed mask
		neg.w	d4			; make d4 neg
		and.w	d6,(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; make d4 pos
		not.w	d6			; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Slonf1-o1Slonf1-3
o1Slonf1:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		neg.w	d4			; make d4 neg
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; make d4 pos

*+
* D' = S AND [NOT D]
*-
		dc.w	o3Slonf1-o2Slonf1-3
o2Slonf1:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		neg.w	d4			; make d4 neg
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; make d4 pos

*+
* D' = S (Replace Mode)
*-
		dc.w	o4Slonf1-o3Slonf1-3
o3Slonf1:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		neg.w	d4			; make d4 neg
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; make d4 pos

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	o5Slonf1-o4Slonf1-3
o4Slonf1:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- dest
		and.w	d1,d0			; d0 <- [NOT S] AND D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		not.w	d0			; d0 <- NOT S
		neg.w	d4			; make d4 neg
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		and.w	d1,d0			; d0 <- [NOT S] AND D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; make d4 pos

*+
* D' = D
*-
		dc.w	o6Slonf1-o5Slonf1-3
o5Slonf1:	subq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Slonf1-o6Slonf1-3
o6Slonf1:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		neg.w	d4			; make d4 neg
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; make d4 pos

*+
* D' = S OR D
*-
		dc.w	o8Slonf1-o7Slonf1-3
o7Slonf1:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		or.w	d1,d0			; d0 <- S OR D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		neg.w	d4			; make d4 neg
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		or.w	d1,d0			; d0 <- S OR D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; make d4 pos

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	o9Slonf1-o8Slonf1-3
o8Slonf1:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- dest
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- [NOT S] AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		not.w	d0			; d0 <- NOT S
		neg.w	d4			; make d4 neg
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- [NOT S] AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; make d4 pos

*+
* D' = NOT [S XOR D]
*-
 		dc.w	oASlonf1-o9Slonf1-3
o9Slonf1:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		neg.w	d4			; make d4 neg
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; make d4 pos

*+
* D' = NOT D
*-
		dc.w	oBSlonf1-oASlonf1-3
oASlonf1:	move.w	-(a1),d1		; d1 <- prev source word
		move.w	d1,d0			; d0 <- D
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		neg.w	d4			; make d4 neg
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		move.w	d1,d0			; d0 <- D
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; make d4 pos

*+
* D' = S OR [NOT D]
*-
		dc.w	oCSlonf1-oBSlonf1-3
oBSlonf1:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		neg.w	d4			; make d4 neg
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; make d4 pos

*+
* D' = NOT S
*-
		dc.w	oDSlonf1-oCSlonf1-3
oCSlonf1:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- dest
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		not.w	d0			; d0 <- NOT S
		neg.w	d4			; make d4 neg
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; make d4 pos

*+
* D' = [NOT S] OR D
*-
		dc.w	oESlonf1-oDSlonf1-3
oDSlonf1:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- dest
		or.w	d1,d0			; d0 <- [NOT S] OR D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		not.w	d0			; d0 <- NOT S
		neg.w	d4			; make d4 neg
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		or.w	d1,d0			; d0 <- [NOT S] OR D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; make d4 pos

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	oFSlonf1-oESlonf1-3
oESlonf1:	move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- dest
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- [NOT S] OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		not.w	d0			; d0 <- NOT S
		neg.w	d4			; make d4 neg
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- [NOT S] OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; make d4 pos

*+
* D' = 1
*-
		dc.w	oGSlonf1-oFSlonf1-3
oFSlonf1:	or.w	d7,-(a1)		; set the dst wrd
		neg.w	d4			; make d4 neg
		or.w	d6,(a1,d4.w)		; set nxt dst wrd in plane
		neg.w	d4			; make d4 pos

		dc.w	0
oGSlonf1:	nop

*******************************************************************************
***************** Logic operations for the right fringe (0) *******************
*****************  shift right negative case, transparant   *******************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	o1Sronf0-o0Sronf0-3
o0Sronf0:	not.w	d6			; get the right mask
		and.w	d6,-(a1)		; mask out needed bits in dst
		not.w	d6			; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Sronf0-o1Sronf0-3
o1Sronf0:	move.w	-(a0),d0		; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	-(a1),d1		; d1 <- D
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; D <- S AND D

*+
* D' = S AND [NOT D]
*-
		dc.w	o3Sronf0-o2Sronf0-3
o2Sronf0:	move.w	-(a0),d0		; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; D <- S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	o4Sronf0-o3Sronf0-3
o3Sronf0:	move.w	-(a0),d0		; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	-(a1),d1		; d1 <- D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	o5Sronf0-o4Sronf0-3
o4Sronf0:	move.w	-(a0),d0		; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		not.w	d0			; d0 <- S
		move.w	-(a1),d1		; d1 <- D
		and.w	d1,d0			; d0 <- [NOT S] AND D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; D <- [NOT S] AND D

*+
* D' = D
*-
		dc.w	o6Sronf0-o5Sronf0-3
o5Sronf0:	subq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Sronf0-o6Sronf0-3
o6Sronf0:	move.w	-(a0),d0		; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	-(a1),d1		; d1 <- D
		eor.w	d1,d0			; d0 <- S XOR D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; D <- S XOR D

*+
* D' = S OR D
*-
		dc.w	o8Sronf0-o7Sronf0-3
o7Sronf0:	move.w	-(a0),d0		; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	-(a1),d1		; d1 <- D
		eor.w	d1,d0			; d0 <- S OR D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; D <- S OR D

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	o9Sronf0-o8Sronf0-3
o8Sronf0:	move.w	-(a0),d0		; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- [NOT S] AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; D <- [NOT S] AND [NOT D]

*+
* D' = NOT [S XOR D]
*-
		dc.w	oASronf0-o9Sronf0-3
o9Sronf0:	move.w	-(a0),d0		; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	-(a1),d1		; d1 <- D
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; D <- NOT [S XOR D]

*+
* D' = NOT D
*-
		dc.w	oBSronf0-oASronf0-3
oASronf0:	move.w	-(a1),d0		; d0 <- D
		move.w	d0,d1			; d1 <- D
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst

*+
* D' = S OR [NOT D]
*-
		dc.w	oCSronf0-oBSronf0-3
oBSronf0:	move.w	-(a0),d0		; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; D <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	oDSronf0-oCSronf0-3
oCSronf0:	move.w	-(a0),d0		; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst

*+
* D' = [NOT S] OR D
*-
		dc.w	oESronf0-oDSronf0-3
oDSronf0:	move.w	-(a0),d0		; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- D
		eor.w	d1,d0			; d0 <- [NOT S] OR D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; D <- [NOT S] OR D

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	oFSronf0-oESronf0-3
oESronf0:	move.w	-(a0),d0		; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- [NOT S] OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; D <- [NOT S] OR [NOT D]

*+
* D' = 1
*-
		dc.w	oGSronf0-oFSronf0-3
oFSronf0:	or.w	d6,-(a1)		; set the dst wrd to ones

		dc.w	0
oGSronf0:	nop


*******************************************************************************
******************  Logic operations for the inner loop   *********************
******************   shift right negative, transparant    *********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	op1Sroni-op0Sroni-3
op0Sroni:	clr.w	-(a1)			; clear the dst wrd

*+
* D' = S AND D
*-
		dc.w	op2Sroni-op1Sroni-3
op1Sroni:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		and.w	d0,-(a1)		; set nxt dst wrd in plane

*+
* D' = S AND [NOT D]
*-
		dc.w	op3Sroni-op2Sroni-3
op2Sroni:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		move.w	d0,(a1)			; D  <- S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4Sroni-op3Sroni-3
op3Sroni:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	d0,-(a1)		; set nxt dst wrd in plane

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5Sroni-op4Sroni-3
op4Sroni:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		and.w	d0,-(a1)		; D  <- [NOT S] AND D

*+
* D' = D
*-
		dc.w	op6Sroni-op5Sroni-3
op5Sroni:	subq.w	#2,a1

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7Sroni-op6Sroni-3
op6Sroni:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		eor.w	d0,-(a1)		; D <- S XOR D

*+
* D' = S OR D
*-
		dc.w	op8Sroni-op7Sroni-3
op7Sroni:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		or.w	d0,-(a1)		; D <- S OR D

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	op9Sroni-op8Sroni-3
op8Sroni:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- [NOT S] AND [NOT D]
		move.w	d0,(a1)			; D  <- [NOT S] AND [NOT D]

*+
* D' = NOT [S XOR D]
*-
		dc.w	opASroni-op9Sroni-3
op9Sroni:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- D
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		move.w	d0,(a1)			; D  <- NOT [S XOR D]
		
*+
* D' = NOT D
*-
		dc.w	opBSroni-opASroni-3
opASroni:	not.w	-(a1)			; not dst wrd

*+
* D' = S OR [NOT D]
*-
		dc.w	opCSroni-opBSroni-3
opBSroni:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		move.w	d0,(a1)			; D  <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opDSroni-opCSroni-3
opCSroni:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	d0,-(a1)		; D -> NOT S

*+
* D' = [NOT S] OR D
*-
		dc.w	opESroni-opDSroni-3
opDSroni:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		or.w	d0,-(a1)		; D -> [NOT S] OR D

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	opFSroni-opESroni-3
opESroni:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- [NOT S] OR [NOT D]
		move.w	d0,(a1)			; D  <- [NOT S] OR [NOT D]

*+
* D' = 1
*-
		dc.w	opGSroni-opFSroni-3
opFSroni:	move.w	#-1,-(a1)

		dc.w	0
opGSroni:	nop


*******************************************************************************
***************  Logic operations for the left fringe (1)  ********************
***************   shift right negative case, transparant   ********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	o1Sronf1-o0Sronf1-3
o0Sronf1:	not.w	d7			; needed mask
		and.w	d7,-(a1)		; set the dst wrd
		not.w	d7
		not.w	d6			; needed mask
		and.w	d6,(a1,d4.w)		; set nxt dst wrd in plane
		not.w	d6			; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Sronf1-o1Sronf1-3
o1Sronf1:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	(a0,d4.w),d0		; get src again
		move.w	(a1,d4.w),d1		; get prev dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = S AND [NOT D]
*-
		dc.w	o3Sronf1-o2Sronf1-3
o2Sronf1:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	(a0,d4.w),d0		; get src again
		move.w	(a1,d4.w),d1		; get prev dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = S (Replace Mode)
*-
		dc.w	o4Sronf1-o3Sronf1-3
o3Sronf1:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	(a0,d4.w),d0		; get src again
		move.w	(a1,d4.w),d1		; get prev dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	o5Sronf1-o4Sronf1-3
o4Sronf1:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- dest
		and.w	d1,d0			; d0 <- [NOT S] AND D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	(a0,d4.w),d0		; get src again
		not.w	d0			; d0 <- NOT S
		move.w	(a1,d4.w),d1		; get prev dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		and.w	d1,d0			; d0 <- [NOT S] AND D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = D
*-
		dc.w	o6Sronf1-o5Sronf1-3
o5Sronf1:	subq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Sronf1-o6Sronf1-3
o6Sronf1:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	(a0,d4.w),d0		; get src again
		move.w	(a1,d4.w),d1		; get prev dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = S OR D
*-
		dc.w	o8Sronf1-o7Sronf1-3
o7Sronf1:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		or.w	d1,d0			; d0 <- S OR D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	(a0,d4.w),d0		; get src again
		move.w	(a1,d4.w),d1		; get prev dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		or.w	d1,d0			; d0 <- S OR D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	o9Sronf1-o8Sronf1-3
o8Sronf1:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- dest
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- [NOT S] AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	(a0,d4.w),d0		; get src again
		not.w	d0			; d0 <- NOT S
		move.w	(a1,d4.w),d1		; get prev dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- [NOT S] AND [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = NOT [S XOR D]
*-
		dc.w	oASronf1-o9Sronf1-3
o9Sronf1:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	(a0,d4.w),d0		; get src again
		move.w	(a1,d4.w),d1		; get prev dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = NOT D
*-
		dc.w	oBSronf1-oASronf1-3
oASronf1:	move.w	-(a1),d0		; d0 <- D
		move.w	d0,d1			; d1 <- D
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	(a1,d4.w),d1		; d1 <- prev dst wrd in plane
		move.w	d1,d0			; d0 <- D
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = S OR [NOT D]
*-
		dc.w	oCSronf1-oBSronf1-3
oBSronf1:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	(a0,d4.w),d0		; get src again
		move.w	(a1,d4.w),d1		; get prev dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = NOT S
*-
		dc.w	oDSronf1-oCSronf1-3
oCSronf1:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- dest
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	(a0,d4.w),d0		; get src again
		not.w	d0			; d0 <- NOT S
		move.w	(a1,d4.w),d1		; get prev dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = [NOT S] OR D
*-
		dc.w	oESronf1-oDSronf1-3
oDSronf1:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- dest
		or.w	d1,d0			; d0 <- [NOT S] OR D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	(a0,d4.w),d0		; get src again
		not.w	d0			; d0 <- NOT S
		move.w	(a1,d4.w),d1		; get prev dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		or.w	d1,d0			; d0 <- [NOT S] OR D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	oFSronf1-oESronf1-3
oESronf1:	move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- dest
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- [NOT S] OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	(a0,d4.w),d0		; get src again
		not.w	d0			; d0 <- NOT S
		move.w	(a1,d4.w),d1		; get prev dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- [NOT S] OR [NOT D]
		not.w	d1			; restore d1
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = 1
*-
		dc.w	oGSronf1-oFSronf1-3
oFSronf1:	or.w	d7,-(a1)		; set the dst wrd
		or.w	d6,(a1,d4.w)		; set nxt dst wrd in plane

		dc.w	0
oGSronf1:	nop
