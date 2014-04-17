********************************  sbsctlog.s  *********************************
*
* $Revision: 3.0 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbsctlog.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/08/06 20:21:45 $     $Locker:  $
* =============================================================================
*
* $Log:	sbsctlog.s,v $
* Revision 3.0  91/08/06  20:21:45  lozben
* New generation VDI
* 
* Revision 2.2  91/07/08  15:51:16  lozben
* File created by Slavik Lozben. This file contains the TRANPARANT
* logical operation routines which are use by the main calling
* routines to perform Source to Destination blits. The assumtion
* is such that we are dealing with the ST interleaved screen memory
* format.
* 
*******************************************************************************

		;
		; Routines to do fringes for word aligned blit (positive case)
		;
		.globl	op0_tpf,op1_tpf,op2_tpf,op3_tpf
		.globl	op4_tpf,op5_tpf,op6_tpf,op7_tpf
		.globl	op8_tpf,op9_tpf,opA_tpf,opB_tpf
		.globl	opC_tpf,opD_tpf,opE_tpf,opF_tpf


		;
		; Routines to do inner loop for word aligned blit (pos case)
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
		; Routines to do inner loop for word aligned blit (neg case)
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
		********** shift left positive case ************
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


*****************************************************************************
*********** Logic operations for the left and the right fringe **************
***********  word aligned blit going into positive directions  **************
*****************************************************************************

*+
* D' = 0
*-
		dc.w	op1_tpf-op0_tpf-3
op0_tpf:	not.w	d6		; d6 <- needed mask
		and.w	d6,(a1)+	; D' <- 0
		not.w	d6		; restore d6
*+
* D' = S AND D
*-
		dc.w	op2_tpf-op1_tpf-3
op1_tpf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		and.w	d1,d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- S AND D

*+
* D' = S AND [NOT D]
*-
		dc.w	op3_tpf-op2_tpf-3
op2_tpf:	move.w	(a1),d0		; d1 <- 1st DESTINATION word
		not.w	d0		;
		and.w	(a0),d0		; d0 <- S AND [NOT D] (not fringed)
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <-  S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4_tpf-op3_tpf-3
op3_tpf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- S

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5_tpf-op4_tpf-3
op4_tpf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
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
		dc.w	op6_tpf-op5_tpf-3
op5_tpf:	addq.w	#2,a1		; do nothing (point to nxt dst plane)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7_tpf-op6_tpf-3
op6_tpf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- S XOR D (XOR mode)

*+
* D' = S OR D
*-
		dc.w	op8_tpf-op7_tpf-3
op7_tpf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		and.w	d6,d0		;
		or.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- S OR D

*+
* D' = NOT [S OR D]
*-
		dc.w	op9_tpf-op8_tpf-3
op8_tpf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
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
		dc.w	opA_tpf-op9_tpf-3
op9_tpf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
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
		dc.w	opB_tpf-opA_tpf-3
opA_tpf:	move.w	(a1),d1		; d1 <- 1st DESTINATION word
		move.w	d1,d0		;
		not.w	d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- NOT D

*+
* D' = S OR [NOT D]
*-
		dc.w	opC_tpf-opB_tpf-3
opB_tpf:	move.w	(a1),d1		; d1 <- 1st DESTINATION word
		move.w	d1,d0		;
		not.w	d0		;
		or.w	(a0),d0		; d0 <- S OR [NOT D] (not fringed)
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opD_tpf-opC_tpf-3
opC_tpf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		not.w	d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- NOT S

*+
* D' = [NOT S] OR D
*-
		dc.w	opE_tpf-opD_tpf-3
opD_tpf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
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
		dc.w	opF_tpf-opE_tpf-3
opE_tpf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
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
		dc.w	opG_tpf-opF_tpf-3
opF_tpf:	or.w	d6,(a1)+	; D' <- 1's

		dc.w	0
opG_tpf:	nop



*****************************************************************************
***********  Logic operations for the inner loop of bit blit   **************
***********  word aligned blit going into positive directions  **************
*****************************************************************************

*+
* D' = 0
*-
		dc.w	op1_tpi-op0_tpi-3
op0_tpi:	clr.w	(a1)+		; D' <- 0

*+
* D' = S AND D
*-
		dc.w	op2_tpi-op1_tpi-3
op1_tpi:	and.w	d0,(a1)+	; D' <- S AND D

*+
* D' = S AND [NOT D]
*-
		dc.w	op3_tpi-op2_tpi-3
op2_tpi:	not.w	(a1)		; not the destination word
		and.w	d0,(a1)+	; D' <-  S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4_tpi-op3_tpi-3
op3_tpi:	move.w	d0,(a1)+	; D' <- S

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5_tpi-op4_tpi-3
op4_tpi:	not.w	d0		; d0 <- [NOT S]
		and.w	d0,(a1)+	; D' <- [NOT S] AND D
		not.w	d0		; reload the clobered src wrd

*+
* D' = D
*-
		dc.w	op6_tpi-op5_tpi-3
op5_tpi:	addq.w	#2,a1		; do nothing (point to nxt src plane)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7_tpi-op6_tpi-3
op6_tpi:	eor.w	d0,(a1)+	; D' <- S XOR D (XOR mode)

*+
* D' = S OR D
*-
		dc.w	op8_tpi-op7_tpi-3
op7_tpi:	or.w	d0,(a1)+	; D' <- S OR D

*+
* D' = NOT [S OR D]
*-
		dc.w	op9_tpi-op8_tpi-3
op8_tpi:	or.w	d0,(a1)		; (a1) <- S OR D
		not.w	(a1)+		; D' <- NOT [S OR D]


*+
* D' = NOT [S XOR D]
*-
		dc.w	opA_tpi-op9_tpi-3
op9_tpi:	eor.w	d0,(a1)		; (a1) <- S OR D
		not.w	(a1)+		; D' <- NOT [S XOR D]

*+
* D' = NOT D
*-
		dc.w	opB_tpi-opA_tpi-3
opA_tpi:	not.w	(a1)+		; D' <- NOT D

*+
* D' = S OR [NOT D]
*-
		dc.w	opC_tpi-opB_tpi-3
opB_tpi:	not.w	(a1)		; 
		or.w	d0,(a1)+	; D' <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opD_tpi-opC_tpi-3
opC_tpi:	not.w	d0		; d0 <- NOT S
		move.w	d0,(a1)+	; D' <- NOT S
		not.w	d0		; reload the clobered src wrd

*+
* D' = [NOT S] OR D
*-
		dc.w	opE_tpi-opD_tpi-3
opD_tpi:	not.w	d0		; d0 <- NOT S
		or.w	d0,(a1)+	; D' <- [NOT S] OR D
		not.w	d0		; reload the clobered src wrd

*+
* D' = NOT [S AND D]
*-
		dc.w	opF_tpi-opE_tpi-3
opE_tpi:	and.w	d0,(A1)		; (a1) <- S AND D
		not.w	(a1)+		; D' NOT [S AND D]

*+
* D' = 1
*-
		dc.w	opG_tpi-opF_tpi-3
opF_tpi:	move.w	#-1,(a1)+	; D' <- 1

		dc.w	0
opG_tpi:	nop



*****************************************************************************
*********** Logic operations for the left and the right fringe **************
***********  word aligned blit going into negative directions  **************
*****************************************************************************

*+
* D' = 0
*-
		dc.w	op1_tnf-op0_tnf-3
op0_tnf:	not.w	d6		; d6 <- needed mask
		and.w	d6,-(a1)	; clear out the needed bits
		not.w	d6		; restore d6

*+
* D' = S AND D
*-
		dc.w	op2_tnf-op1_tnf-3
op1_tnf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		and.w	d1,d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- S AND D

*+
* D' = S AND [NOT D]
*-
		dc.w	op3_tnf-op2_tnf-3
op2_tnf:	move.w	-(a1),d0	; d1 <- 1st DESTINATION word
		not.w	d0		;
		and.w	(a0),d0		; d0 <- S AND [NOT D] (not fringed)
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <-  S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4_tnf-op3_tnf-3
op3_tnf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- S

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5_tnf-op4_tnf-3
op4_tnf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
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
		dc.w	op6_tnf-op5_tnf-3
op5_tnf:	subq.w	#2,a1		; do nothing (point to nxt dst plane)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7_tnf-op6_tnf-3
op6_tnf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- S XOR D (XOR mode)

*+
* D' = S OR D
*-
		dc.w	op8_tnf-op7_tnf-3
op7_tnf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		and.w	d6,d0		;
		or.w	d1,d0		;
		move.w	d0,(a1)		; D' <- S OR D

*+
* D' = NOT [S OR D]
*-
		dc.w	op9_tnf-op8_tnf-3
op8_tnf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
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
		dc.w	opA_tnf-op9_tnf-3
op9_tnf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
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
		dc.w	opB_tnf-opA_tnf-3
opA_tnf:	move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		move.w	d1,d0		;
		not.w	d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- NOT D

*+
* D' = S OR [NOT D]
*-
		dc.w	opC_tnf-opB_tnf-3
opB_tnf:	move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		move.w	d1,d0		;
		not.w	d0		;
		or.w	(a0),d0		; d0 <- S OR [NOT D] (not fringed)
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opD_tnf-opC_tnf-3
opC_tnf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		not.w	d0		;
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- NOT S

*+
* D' = [NOT S] OR D
*-
		dc.w	opE_tnf-opD_tnf-3
opD_tnf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
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
		dc.w	opF_tnf-opE_tnf-3
opE_tnf:	move.w	(a0),d0		; d0 <- 1st SOURCE word
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
		dc.w	opG_tnf-opF_tnf-3
opF_tnf:	or.w	d6,-(a1)	; D <- 1's

		dc.w	0
opG_tnf:	nop



*****************************************************************************
***********  Logic operations for the inner loop of bit blit   **************
***********  word aligned blit going into negative directions  **************
*****************************************************************************

		dc.w	op1_tni-op0_tni-3
op0_tni:	clr.w	-(a1)		; D' <- 0

*+
* D' = S AND D
*-
		dc.w	op2_tni-op1_tni-3
op1_tni:	and.w	d0,-(a1)	; D' <- S AND D

*+
* D' = S AND [NOT D]
*-
		dc.w	op3_tni-op2_tni-3
op2_tni:	not.w	-(a1)		; not the destination word
		and.w	d0,(a1)		; D' <-  S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4_tni-op3_tni-3
op3_tni:	move.w	d0,-(a1)	; D' <- S

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5_tni-op4_tni-3
op4_tni:	not.w	d0		; d0 <- [NOT S]
		and.w	d0,-(a1)	; D' <- [NOT S] AND D
		not.w	d0		; reload the clobered src wrd

*+
* D' = D
*-
		dc.w	op6_tni-op5_tni-3
op5_tni:	subq.w	#2,a1		; do nothing (point to nxt src plane)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7_tni-op6_tni-3
op6_tni:	eor.w	d0,-(a1)	; D' <- S XOR D (XOR mode)

*+
* D' = S OR D
*-
		dc.w	op8_tni-op7_tni-3
op7_tni:	or.w	d0,-(a1)	; D' <- S OR D

*+
* D' = NOT [S OR D]
*-
		dc.w	op9_tni-op8_tni-3
op8_tni:	or.w	d0,-(a1)	; (a1) <- S OR D
		not.w	(a1)		; D' <- NOT [S OR D]

*+
* D' = NOT [S XOR D]
*-
		dc.w	opA_tni-op9_tni-3
op9_tni:	eor.w	d0,-(a1)	; (a1) <- S OR D
		not.w	(a1)		; D' <- NOT [S XOR D]

*+
* D' = NOT D
*-
		dc.w	opB_tni-opA_tni-3
opA_tni:	not.w	-(a1)		; D' <- NOT D

*+
* D' = S OR [NOT D]
*-
		dc.w	opC_tni-opB_tni-3
opB_tni:	not.w	-(a1)		; 
		or.w	d0,(a1)		; D' <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opD_tni-opC_tni-3
opC_tni:	not.w	d0		; d0 <- NOT S
		move.w	d0,-(a1)	; D' <- NOT S
		not.w	d0		; reload the clobered src wrd
*+
* D' = [NOT S] OR D
*-
		dc.w	opE_tni-opD_tni-3
opD_tni:	not.w	d0		; d0 <- NOT S
		or.w	d0,-(a1)	; D' <- [NOT S] OR D
		not.w	d0		; reload the clobered src wrd

*+
* D' = NOT [S AND D]
*-
		dc.w	opF_tni-opE_tni-3
opE_tni:	and.w	d0,-(A1)	; (a1) <- S AND D
		not.w	(a1)		; D' NOT [S AND D]

*+
* D' = 1
*-
		dc.w	opG_tni-opF_tni-3
opF_tni:	move.w	#-1,-(a1)	; D' <- 1

		dc.w	0
opG_tni:	nop

*******************************************************************************
*******************************************************************************
****************************    UNALIGNED BLIT   ******************************
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
		dc.w	o1Srtpf0-o0Srtpf0-3
o0Srtpf0:	not.w	d6		; get the right mask
		and.w	d6,(a1)+	; mask out the needed bits in dst
		not.w	d6		; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Srtpf0-o1Srtpf0-3
o1Srtpf0:	move.w	(a0),d0			; d0 <- src wrd
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
		dc.w	o3Srtpf0-o2Srtpf0-3
o2Srtpf0:	move.w	(a0),d0			; d0 <- src and [not dst]
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
		dc.w	o4Srtpf0-o3Srtpf0-3
o3Srtpf0:	move.w	(a0),d0			; d0 <- src wrd
		move.w	(a1),d1			; d1 <- dst
		lsr.w	d2,d0			; adjust bits we need to splat
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	o5Srtpf0-o4Srtpf0-3
o4Srtpf0:	move.w	(a0),d0			; d0 <- src wrd
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
		dc.w	o6Srtpf0-o5Srtpf0-3
o5Srtpf0:	addq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Srtpf0-o6Srtpf0-3
o6Srtpf0:	move.w	(a0),d0			; d0 <- src wrd
		lsr.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		eor.w	d0,(a1)+		; set the dst wrd

*+
* D' = S OR D
*-
		dc.w	o8Srtpf0-o7Srtpf0-3
o7Srtpf0:	move.w	(a0),d0			; d0 <- src wrd
		lsr.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		or.w	d0,(a1)+		; set the dst wrd

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*
*-
		dc.w	o9Srtpf0-o8Srtpf0-3
o8Srtpf0:	move.w	(a0),d0			; d0 <- src and [not dst]
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
		dc.w	oASrtpf0-o9Srtpf0-3
o9Srtpf0:	move.w	(a0),d0			; d0 <- src wrd
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
		dc.w	oBSrtpf0-oASrtpf0-3
oASrtpf0:	move.w	(a1),d1			; d1 <- dst
		move.w	d1,d0			; d0 <- dst
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd

*+
* D' = S OR [NOT D]
*-
		dc.w	oCSrtpf0-oBSrtpf0-3
oBSrtpf0:	move.w	(a0),d0			; d0 <- src wrd
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
		dc.w	oDSrtpf0-oCSrtpf0-3
oCSrtpf0:	move.w	(a0),d0			; d0 <- src wrd
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
		dc.w	oESrtpf0-oDSrtpf0-3
oDSrtpf0:	move.w	(a0),d0			; d0 <- src wrd
		not.w	d0			; d0 <- NOT S
		lsr.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		or.w	d0,(a1)+		; set the dst wrd

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	oFSrtpf0-oESrtpf0-3
oESrtpf0:	move.w	(a0),d0			; d0 <- src wrd
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
		dc.w	oGSrtpf0-oFSrtpf0-3
oFSrtpf0:	or.w	d6,(a1)+		; set the dst wrd to ones

		dc.w	0
oGSrtpf0:	nop


*******************************************************************************
******************  Logic operations for the inner loop   *********************
****************** shift right positive case, transparant *********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	op1Srtpi-op0Srtpi-3
op0Srtpi:	clr.w	(a1)+			; clear the dst wrd

*+
* D' = S AND D
*-
		dc.w	op2Srtpi-op1Srtpi-3
op1Srtpi:	move.w	-2(a0),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		and.w	d0,(a1)+		; dst <- S AND D

*+
* D' = S AND [NOT D]
*-
		dc.w	op3Srtpi-op2Srtpi-3
op2Srtpi:	move.w	-2(a0),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		move.w	d0,(a1)+		; dst <- S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4Srtpi-op3Srtpi-3
op3Srtpi:	move.w	-2(a0),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	d0,(a1)+		; dst <- S

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5Srtpi-op4Srtpi-3
op4Srtpi:	move.w	-2(a0),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		not.w	d0			; d0 <- NOT S
		and.w	d0,(a1)+		; dst <- [NOT S] AND D

*+
* D' = D
*-
		dc.w	op6Srtpi-op5Srtpi-3
op5Srtpi:	addq.w	#2,a1

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7Srtpi-op6Srtpi-3
op6Srtpi:	move.w	-2(a0),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		eor.w	d0,(a1)+		; dst <- S XOR D

*+
* D' = S OR D
*-
		dc.w	op8Srtpi-op7Srtpi-3
op7Srtpi:	move.w	-2(a0),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		or.w	d0,(a1)+		; dst <- S OR D

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	op9Srtpi-op8Srtpi-3
op8Srtpi:	move.w	-2(a0),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
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
		dc.w	opASrtpi-op9Srtpi-3
op9Srtpi:	move.w	-2(a0),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		move.w	(a1),d1			; d1 <- D
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		move.w	d0,(a1)+		; dst <- NOT [S XOR D]

*+
* D' = NOT D
*-
		dc.w	opBSrtpi-opASrtpi-3
opASrtpi:	not.w	(a1)+			; not dst wrd

*+
* D' = S OR [NOT D]
*-
		dc.w	opCSrtpi-opBSrtpi-3
opBSrtpi:	move.w	-2(a0),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		move.w	d0,(a1)+		; dst <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opDSrtpi-opCSrtpi-3
opCSrtpi:	move.w	-2(a0),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	d0,(a1)+		; dst <- S

*+
* D' = [NOT S] OR D
*-
		dc.w	opESrtpi-opDSrtpi-3
opDSrtpi:	move.w	-2(a0),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		not.w	d0			; d0 <- NOT S
		or.w	d0,(a1)+		; dst <- [NOT S] OR D

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	opFSrtpi-opESrtpi-3
opESrtpi:	move.w	-2(a0),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
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
		dc.w	opGSrtpi-opFSrtpi-3
opFSrtpi:	move.w	#-1,(a1)+

		dc.w	0
opGSrtpi:	nop


*******************************************************************************
***************     Logic operations for the fringe (1)    ********************
***************   shift right positive case, transparant   ********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	o1Srtpf1-o0Srtpf1-3
o0Srtpf1:	not.w	d7			; needed mask
		and.w	d7,(a1)+		; set the dst wrd
		not.w	d7
		not.w	d6			; needed mask
		and.w	d6,-2(a1,d4.w)		; set nxt dst wrd in plane
		not.w	d6			; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Srtpf1-o1Srtpf1-3
o1Srtpf1:	move.w	-2(a0),d1		; d1 <- prev source word
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
		move.w	(a0),d0			; get src again
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = S AND [NOT D]
*-
		dc.w	o3Srtpf1-o2Srtpf1-3
o2Srtpf1:	move.w	-2(a0),d1		; d1 <- prev source word
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
		move.w	(a0),d0			; get src again
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
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
		dc.w	o4Srtpf1-o3Srtpf1-3
o3Srtpf1:	move.w	-2(a0),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		move.w	(a0),d0			; get src again
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	o5Srtpf1-o4Srtpf1-3
o4Srtpf1:	move.w	-2(a0),d1		; d1 <- prev source word
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
		move.w	(a0),d0			; get src again
		not.w	d0			; d0 <- NOT S
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		and.w	d1,d0			; d0 <- [NOT S] AND D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = D
*-
		dc.w	o6Srtpf1-o5Srtpf1-3
o5Srtpf1:	addq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Srtpf1-o6Srtpf1-3
o6Srtpf1:	move.w	-2(a0),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		move.w	(a0),d0			; get src again
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = S OR D
*-
		dc.w	o8Srtpf1-o7Srtpf1-3
o7Srtpf1:	move.w	-2(a0),d1		; d1 <- prev source word
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
		move.w	(a0),d0			; get src again
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		or.w	d1,d0			; d0 <- S OR D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	o9Srtpf1-o8Srtpf1-3
o8Srtpf1:	move.w	-2(a0),d1		; d1 <- prev source word
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
		move.w	(a0),d0			; get src again
		not.w	d0			; d0 <- NOT S
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
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
		dc.w	oASrtpf1-o9Srtpf1-3
o9Srtpf1:	move.w	-2(a0),d1		; d1 <- prev source word
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
		move.w	(a0),d0			; get src again
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
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
		dc.w	oBSrtpf1-oASrtpf1-3
oASrtpf1:	move.w	(a1),d0			; d1 <- D
		move.w	d0,d1			; d1 <- D
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
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
		dc.w	oCSrtpf1-oBSrtpf1-3
oBSrtpf1:	move.w	-2(a0),d1		; d1 <- prev source word
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
		move.w	(a0),d0			; get src again
 		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
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
		dc.w	oDSrtpf1-oCSrtpf1-3
oCSrtpf1:	move.w	-2(a0),d1		; d1 <- prev source word
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
		move.w	(a0),d0			; get src again
		not.w	d0			; d0 <- NOT S
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = [NOT S] OR D
*-
		dc.w	oESrtpf1-oDSrtpf1-3
oDSrtpf1:	move.w	-2(a0),d1		; d1 <- prev source word
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
		move.w	(a0),d0			; get src again
		not.w	d0			; d0 <- NOT S
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		or.w	d1,d0			; d0 <- [NOT S] OR D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	oFSrtpf1-oESrtpf1-3
oESrtpf1:	move.w	-2(a0),d1		; d1 <- prev source word
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
		move.w	(a0),d0			; get src again
		not.w	d0			; d0 <- NOT S
		move.w	-2(a1,d4.w),d1		; get nxt dst wrd in plane
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
		dc.w	oGSrtpf1-oFSrtpf1-3
oFSrtpf1:	or.w	d7,(a1)+		; set the dst wrd
		or.w	d6,-2(a1,d4.w)		; set nxt dst wrd in plane

		dc.w	0
oGSrtpf1:	nop


*******************************************************************************
***************** Logic operations for the left fringe (0) ********************
*****************   shift left positive case, transparant  ********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	o1Sltpf0-o0Sltpf0-3
o0Sltpf0:	not.w	d6			; get the right mask
		and.w	d6,(a1)+		; mask out needed bits in dst
		not.w	d6			; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Sltpf0-o1Sltpf0-3
o1Sltpf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		dc.w	o3Sltpf0-o2Sltpf0-3
o2Sltpf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		dc.w	o4Sltpf0-o3Sltpf0-3
o3Sltpf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		dc.w	o5Sltpf0-o4Sltpf0-3
o4Sltpf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		dc.w	o6Sltpf0-o5Sltpf0-3
o5Sltpf0:	addq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Sltpf0-o6Sltpf0-3
o6Sltpf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		dc.w	o8Sltpf0-o7Sltpf0-3
o7Sltpf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		dc.w	o9Sltpf0-o8Sltpf0-3
o8Sltpf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		dc.w	oASltpf0-o9Sltpf0-3
o9Sltpf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		dc.w	oBSltpf0-oASltpf0-3
oASltpf0:	move.w	(a1),d0			; d0 <- D
		move.w	d0,d1			; d1 <- D
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst

*+
* D' = S OR [NOT D]
*-
		dc.w	oCSltpf0-oBSltpf0-3
oBSltpf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		dc.w	oDSltpf0-oCSltpf0-3
oCSltpf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		dc.w	oESltpf0-oDSltpf0-3
oDSltpf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		dc.w	oFSltpf0-oESltpf0-3
oESltpf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		dc.w	oGSltpf0-oFSltpf0-3
oFSltpf0:	or.w	d6,(a1)+		; set the dst wrd to ones

		dc.w	0
oGSltpf0:	nop


*******************************************************************************
******************  Logic operations for the inner loop   *********************
****************** shift left positive case, transparant  *********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	op1Sltpi-op0Sltpi-3
op0Sltpi:	clr.w	(a1)+			; clear the dst wrd

*+
* D' = S AND D
*-
		dc.w	op2Sltpi-op1Sltpi-3
op1Sltpi:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		and.w	d0,(a1)+		; set nxt dst wrd in plane

*+
* D' = S AND [NOT D]
*-
		dc.w	op3Sltpi-op2Sltpi-3
op2Sltpi:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		move.w	d0,(a1)+		; D  <- S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4Sltpi-op3Sltpi-3
op3Sltpi:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	d0,(a1)+		; set nxt dst wrd in plane

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5Sltpi-op4Sltpi-3
op4Sltpi:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		and.w	d0,(a1)+		; D  <- [NOT S] AND D

*+
* D' = D
*-
		dc.w	op6Sltpi-op5Sltpi-3
op5Sltpi:	addq.w	#2,a1

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7Sltpi-op6Sltpi-3
op6Sltpi:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		eor.w	d0,(a1)+		; D <- S XOR D

*+
* D' = S OR D
*-
		dc.w	op8Sltpi-op7Sltpi-3
op7Sltpi:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		or.w	d0,(a1)+		; D <- S OR D

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	op9Sltpi-op8Sltpi-3
op8Sltpi:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		dc.w	opASltpi-op9Sltpi-3
op9Sltpi:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- D
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		move.w	d0,(a1)+		; D  <- NOT [S XOR D]
		
*+
* D' = NOT D
*-
		dc.w	opBSltpi-opASltpi-3
opASltpi:	not.w	(a1)+			; not dst wrd

*+
* D' = S OR [NOT D]
*-
		dc.w	opCSltpi-opBSltpi-3
opBSltpi:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		move.w	d0,(a1)+		; D  <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opDSltpi-opCSltpi-3
opCSltpi:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	d0,(a1)+		; D -> NOT S

*+
* D' = [NOT S] OR D
*-
		dc.w	opESltpi-opDSltpi-3
opDSltpi:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		or.w	d0,(a1)+		; D -> [NOT S] OR D

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	opFSltpi-opESltpi-3
opESltpi:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		dc.w	opGSltpi-opFSltpi-3
opFSltpi:	move.w	#-1,(a1)+

		dc.w	0
opGSltpi:	nop


*******************************************************************************
***************  Logic operations for the right fringe (1) ********************
***************    shift left positive case, transparant   ********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	o1Sltpf1-o0Sltpf1-3
o0Sltpf1:	not.w	d7			; needed mask
		and.w	d7,(a1)+		; set the dst wrd
		not.w	d7
		not.w	d6			; needed mask
		and.w	d6,-2(a1,d4.w)		; set nxt dst wrd in plane
		not.w	d6			; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Sltpf1-o1Sltpf1-3
o1Sltpf1:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	2(a0),d0		; get src again
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
		dc.w	o3Sltpf1-o2Sltpf1-3
o2Sltpf1:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		move.w	2(a0),d0		; get src again
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
		dc.w	o4Sltpf1-o3Sltpf1-3
o3Sltpf1:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	2(a0),d0		; get src again
		move.w	-2(a1,d4.w),d1		; get prev dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	o5Sltpf1-o4Sltpf1-3
o4Sltpf1:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- dest
		and.w	d1,d0			; d0 <- [NOT S] AND D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	2(a0),d0		; get src again
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
		dc.w	o6Sltpf1-o5Sltpf1-3
o5Sltpf1:	addq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Sltpf1-o6Sltpf1-3
o6Sltpf1:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	2(a0),d0		; get src again
		move.w	-2(a1,d4.w),d1		; get prev dst wrd in plane
		lsl.w	d3,d0			; shift the other way now
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,-2(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = S OR D
*-
		dc.w	o8Sltpf1-o7Sltpf1-3
o7Sltpf1:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		or.w	d1,d0			; d0 <- S OR D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	2(a0),d0		; get src again
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
		dc.w	o9Sltpf1-o8Sltpf1-3
o8Sltpf1:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		move.w	2(a0),d0		; get src again
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
		dc.w	oASltpf1-o9Sltpf1-3
o9Sltpf1:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	(a1),d1			; d1 <- dest
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	2(a0),d0		; get src again
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
		dc.w	oBSltpf1-oASltpf1-3
oASltpf1:	move.w	(a1),d0			; d0 <- D
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
		dc.w	oCSltpf1-oBSltpf1-3
oBSltpf1:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		move.w	2(a0),d0		; get src again
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
		dc.w	oDSltpf1-oCSltpf1-3
oCSltpf1:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- dest
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	2(a0),d0		; get src again
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
		dc.w	oESltpf1-oDSltpf1-3
oDSltpf1:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	(a1),d1			; d1 <- dest
		or.w	d1,d0			; d0 <- [NOT S] OR D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
		move.w	2(a0),d0		; get src again
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
		dc.w	oFSltpf1-oESltpf1-3
oESltpf1:	move.w	(a0),d0			; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	2(a0),d1		; fetch second part of the word
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
		move.w	2(a0),d0		; get src again
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
		dc.w	oGSltpf1-oFSltpf1-3
oFSltpf1:	or.w	d7,(a1)+		; set the dst wrd
		or.w	d6,-2(a1,d4.w)		; set nxt dst wrd in plane

		dc.w	0
oGSltpf1:	nop


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
		dc.w	o1Sltnf0-o0Sltnf0-3
o0Sltnf0:	not.w	d6		; get the right mask
		and.w	d6,-(a1)	; mask out the needed bits in dst
		not.w	d6		; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Sltnf0-o1Sltnf0-3
o1Sltnf0:	move.w	(a0),d0			; d0 <- src wrd
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
		dc.w	o3Sltnf0-o2Sltnf0-3
o2Sltnf0:	move.w	(a0),d0			; d0 <- src and [not dst]
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
		dc.w	o4Sltnf0-o3Sltnf0-3
o3Sltnf0:	move.w	(a0),d0			; d0 <- src wrd
		move.w	-(a1),d1		; d1 <- dst
		lsl.w	d2,d0			; adjust bits we need to splat
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	o5Sltnf0-o4Sltnf0-3
o4Sltnf0:	move.w	(a0),d0			; d0 <- src wrd
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
		dc.w	o6Sltnf0-o5Sltnf0-3
o5Sltnf0:	subq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Sltnf0-o6Sltnf0-3
o6Sltnf0:	move.w	(a0),d0			; d0 <- src wrd
		lsl.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		eor.w	d0,-(a1)		; set the dst wrd

*+
* D' = S OR D
*-
		dc.w	o8Sltnf0-o7Sltnf0-3
o7Sltnf0:	move.w	(a0),d0			; d0 <- src wrd
		lsl.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		or.w	d0,-(a1)		; set the dst wrd

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*
*-
		dc.w	o9Sltnf0-o8Sltnf0-3
o8Sltnf0:	move.w	(a0),d0			; d0 <- src and [not dst]
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
		dc.w	oASltnf0-o9Sltnf0-3
o9Sltnf0:	move.w	(a0),d0			; d0 <- src wrd
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
		dc.w	oBSltnf0-oASltnf0-3
oASltnf0:	move.w	-(a1),d1		; d1 <- dst
		move.w	d1,d0			; d0 <- dst
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd

*+
* D' = S OR [NOT D]
*-
		dc.w	oCSltnf0-oBSltnf0-3
oBSltnf0:	move.w	(a0),d0			; d0 <- src wrd
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
		dc.w	oDSltnf0-oCSltnf0-3
oCSltnf0:	move.w	(a0),d0			; d0 <- src wrd
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
		dc.w	oESltnf0-oDSltnf0-3
oDSltnf0:	move.w	(a0),d0			; d0 <- src wrd
		not.w	d0			; d0 <- NOT S
		lsl.w	d2,d0			; adjust bits we need to splat
		and.w	d6,d0			; mask out bits we don't splat
		or.w	d0,-(a1)		; set the dst wrd

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	oFSltnf0-oESltnf0-3
oESltnf0:	move.w	(a0),d0			; d0 <- src wrd
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
		dc.w	oGSltnf0-oFSltnf0-3
oFSltnf0:	or.w	d6,-(a1)		; set the dst wrd to ones

		dc.w	0
oGSltnf0:	nop


*******************************************************************************
******************  Logic operations for the inner loop   *********************
****************** shift left negative case, transparant  *********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	op1Sltni-op0Sltni-3
op0Sltni:	clr.w	-(a1)			; clear the dst wrd

*+
* D' = S AND D
*-
		dc.w	op2Sltni-op1Sltni-3
op1Sltni:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		and.w	d0,-(a1)		; dst <- S AND D

*+
* D' = S AND [NOT D]
*-
		dc.w	op3Sltni-op2Sltni-3
op2Sltni:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		move.w	d0,(a1)			; dst <- S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4Sltni-op3Sltni-3
op3Sltni:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	d0,-(a1)		; dst <- S

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5Sltni-op4Sltni-3
op4Sltni:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		not.w	d0			; d0 <- NOT S
		and.w	d0,-(a1)		; dst <- [NOT S] AND D

*+
* D' = D
*-
		dc.w	op6Sltni-op5Sltni-3
op5Sltni:	subq.w	#2,a1

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7Sltni-op6Sltni-3
op6Sltni:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		eor.w	d0,-(a1)		; dst <- S XOR D

*+
* D' = S OR D
*-
		dc.w	op8Sltni-op7Sltni-3
op7Sltni:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		or.w	d0,-(a1)		; dst <- S OR D

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	op9Sltni-op8Sltni-3
op8Sltni:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
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
		dc.w	opASltni-op9Sltni-3
op9Sltni:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		move.w	-(a1),d1		; d1 <- D
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		move.w	d0,(a1)			; dst <- NOT [S XOR D]

*+
* D' = NOT D
*-
		dc.w	opBSltni-opASltni-3
opASltni:	not.w	-(a1)			; not dst wrd

*+
* D' = S OR [NOT D]
*-
		dc.w	opCSltni-opBSltni-3
opBSltni:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		move.w	d0,(a1)			; dst <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opDSltni-opCSltni-3
opCSltni:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	d0,-(a1)		; dst <- S

*+
* D' = [NOT S] OR D
*-
		dc.w	opESltni-opDSltni-3
opDSltni:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; or the needed mask into S
		not.w	d0			; d0 <- NOT S
		or.w	d0,-(a1)		; dst <- [NOT S] OR D

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	opFSltni-opESltni-3
opESltni:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
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
		dc.w	opGSltni-opFSltni-3
opFSltni:	move.w	#-1,-(a1)

		dc.w	0
opGSltni:	nop


*******************************************************************************
***************  Logic operations for the left fringe (1)  ********************
***************    shift left negative case, transparant   ********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	o1Sltnf1-o0Sltnf1-3
o0Sltnf1:	not.w	d7			; needed mask
		and.w	d7,-(a1)		; set the dst wrd
		not.w	d7
		not.w	d6			; needed mask
		and.w	d6,(a1,d4.w)		; set nxt dst wrd in plane
		not.w	d6			; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Sltnf1-o1Sltnf1-3
o1Sltnf1:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = S AND [NOT D]
*-
		dc.w	o3Sltnf1-o2Sltnf1-3
o2Sltnf1:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
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
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
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
		dc.w	o4Sltnf1-o3Sltnf1-3
o3Sltnf1:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	o5Sltnf1-o4Sltnf1-3
o4Sltnf1:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
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
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		and.w	d1,d0			; d0 <- [NOT S] AND D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = D
*-
		dc.w	o6Sltnf1-o5Sltnf1-3
o5Sltnf1:	subq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Sltnf1-o6Sltnf1-3
o6Sltnf1:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = S OR D
*-
		dc.w	o8Sltnf1-o7Sltnf1-3
o7Sltnf1:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		or.w	d1,d0			; d0 <- S OR D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a0),d0			; get src again
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		or.w	d1,d0			; d0 <- S OR D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	o9Sltnf1-o8Sltnf1-3
o8Sltnf1:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
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
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
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
		dc.w	oASltnf1-o9Sltnf1-3
o9Sltnf1:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
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
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
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
		dc.w	oBSltnf1-oASltnf1-3
oASltnf1:	move.w	-(a1),d1		; d1 <- prev source word
		move.w	d1,d0			; d0 <- D
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		move.w	d1,d0			; d0 <- D
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = S OR [NOT D]
*-
		dc.w	oCSltnf1-oBSltnf1-3
oBSltnf1:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
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
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
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
		dc.w	oDSltnf1-oCSltnf1-3
oCSltnf1:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
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
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = [NOT S] OR D
*-
		dc.w	oESltnf1-oDSltnf1-3
oDSltnf1:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
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
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		or.w	d1,d0			; d0 <- [NOT S] OR D
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	oFSltnf1-oESltnf1-3
oESltnf1:	move.w	2(a0),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	(a0),d0			; d0 <- source word
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
		move.w	(a1,d4.w),d1		; get nxt dst wrd in plane
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
		dc.w	oGSltnf1-oFSltnf1-3
oFSltnf1:	or.w	d7,-(a1)		; set the dst wrd
		or.w	d6,(a1,d4.w)		; set nxt dst wrd in plane

		dc.w	0
oGSltnf1:	nop

*******************************************************************************
***************** Logic operations for the right fringe (0) *******************
*****************  shift right negative case, transparant   *******************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	o1Srtnf0-o0Srtnf0-3
o0Srtnf0:	not.w	d6			; get the right mask
		and.w	d6,-(a1)		; mask out needed bits in dst
		not.w	d6			; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Srtnf0-o1Srtnf0-3
o1Srtnf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		dc.w	o3Srtnf0-o2Srtnf0-3
o2Srtnf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		dc.w	o4Srtnf0-o3Srtnf0-3
o3Srtnf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		dc.w	o5Srtnf0-o4Srtnf0-3
o4Srtnf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		dc.w	o6Srtnf0-o5Srtnf0-3
o5Srtnf0:	subq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Srtnf0-o6Srtnf0-3
o6Srtnf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		dc.w	o8Srtnf0-o7Srtnf0-3
o7Srtnf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		dc.w	o9Srtnf0-o8Srtnf0-3
o8Srtnf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		dc.w	oASrtnf0-o9Srtnf0-3
o9Srtnf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		dc.w	oBSrtnf0-oASrtnf0-3
oASrtnf0:	move.w	-(a1),d0		; d0 <- D
		move.w	d0,d1			; d1 <- D
		not.w	d0			; d0 <- NOT D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst

*+
* D' = S OR [NOT D]
*-
		dc.w	oCSrtnf0-oBSrtnf0-3
oBSrtnf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		dc.w	oDSrtnf0-oCSrtnf0-3
oCSrtnf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		dc.w	oESrtnf0-oDSrtnf0-3
oDSrtnf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		dc.w	oFSrtnf0-oESrtnf0-3
oESrtnf0:	move.w	(a0),d0			; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		dc.w	oGSrtnf0-oFSrtnf0-3
oFSrtnf0:	or.w	d6,-(a1)		; set the dst wrd to ones

		dc.w	0
oGSrtnf0:	nop


*******************************************************************************
******************  Logic operations for the inner loop   *********************
******************   shift right negative, transparant    *********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	op1Srtni-op0Srtni-3
op0Srtni:	clr.w	-(a1)			; clear the dst wrd

*+
* D' = S AND D
*-
		dc.w	op2Srtni-op1Srtni-3
op1Srtni:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		and.w	d0,-(a1)		; set nxt dst wrd in plane

*+
* D' = S AND [NOT D]
*-
		dc.w	op3Srtni-op2Srtni-3
op2Srtni:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		and.w	d1,d0			; d0 <- S AND [NOT D]
		move.w	d0,(a1)			; D  <- S AND [NOT D]

*+
* D' = S (Replace Mode)
*-
		dc.w	op4Srtni-op3Srtni-3
op3Srtni:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	d0,-(a1)		; set nxt dst wrd in plane

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	op5Srtni-op4Srtni-3
op4Srtni:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		and.w	d0,-(a1)		; D  <- [NOT S] AND D

*+
* D' = D
*-
		dc.w	op6Srtni-op5Srtni-3
op5Srtni:	subq.w	#2,a1

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	op7Srtni-op6Srtni-3
op6Srtni:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		eor.w	d0,-(a1)		; D <- S XOR D

*+
* D' = S OR D
*-
		dc.w	op8Srtni-op7Srtni-3
op7Srtni:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		or.w	d0,-(a1)		; D <- S OR D

*+
* D' = NOT [S OR D] (same as [NOT S] AND [NOT D])
*-
		dc.w	op9Srtni-op8Srtni-3
op8Srtni:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		dc.w	opASrtni-op9Srtni-3
op9Srtni:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- D
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		move.w	d0,(a1)			; D  <- NOT [S XOR D]
		
*+
* D' = NOT D
*-
		dc.w	opBSrtni-opASrtni-3
opASrtni:	not.w	-(a1)			; not dst wrd

*+
* D' = S OR [NOT D]
*-
		dc.w	opCSrtni-opBSrtni-3
opBSrtni:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- D
		not.w	d1			; d1 <- NOT D
		or.w	d1,d0			; d0 <- S OR [NOT D]
		move.w	d0,(a1)			; D  <- S OR [NOT D]

*+
* D' = NOT S
*-
		dc.w	opDSrtni-opCSrtni-3
opCSrtni:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	d0,-(a1)		; D -> NOT S

*+
* D' = [NOT S] OR D
*-
		dc.w	opESrtni-opDSrtni-3
opDSrtni:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		or.w	d0,-(a1)		; D -> [NOT S] OR D

*+
* D' = NOT [S AND D] (same as [NOT S] OR [NOT D])
*-
		dc.w	opFSrtni-opESrtni-3
opESrtni:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		dc.w	opGSrtni-opFSrtni-3
opFSrtni:	move.w	#-1,-(a1)

		dc.w	0
opGSrtni:	nop


*******************************************************************************
***************  Logic operations for the left fringe (1)  ********************
***************   shift right negative case, transparant   ********************
*******************************************************************************

*+
* D' = 0
*-
		dc.w	o1Srtnf1-o0Srtnf1-3
o0Srtnf1:	not.w	d7			; needed mask
		and.w	d7,-(a1)		; set the dst wrd
		not.w	d7
		not.w	d6			; needed mask
		and.w	d6,(a1,d4.w)		; set nxt dst wrd in plane
		not.w	d6			; restore d6

*+
* D' = S AND D
*-
		dc.w	o2Srtnf1-o1Srtnf1-3
o1Srtnf1:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		and.w	d1,d0			; d0 <- S AND D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	-2(a0),d0		; get src again
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
		dc.w	o3Srtnf1-o2Srtnf1-3
o2Srtnf1:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		move.w	-2(a0),d0		; get src again
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
		dc.w	o4Srtnf1-o3Srtnf1-3
o3Srtnf1:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	-2(a0),d0		; get src again
		move.w	(a1,d4.w),d1		; get prev dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		eor.w	d1,d0
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = [NOT S] AND D (Erase Mode)
*-
		dc.w	o5Srtnf1-o4Srtnf1-3
o4Srtnf1:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- dest
		and.w	d1,d0			; d0 <- [NOT S] AND D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	-2(a0),d0		; get src again
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
		dc.w	o6Srtnf1-o5Srtnf1-3
o5Srtnf1:	subq.w	#2,a1			; do nthng (pnt to nxt dst pln)

*+
* D' = S XOR D (XOR mode)
*-
		dc.w	o7Srtnf1-o6Srtnf1-3
o6Srtnf1:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	-2(a0),d0		; get src again
		move.w	(a1,d4.w),d1		; get prev dst wrd in plane
		lsr.w	d3,d0			; shift the other way now
		and.w	d6,d0
		eor.w	d1,d0			; d0 <- wanted src
		move.w	d0,(a1,d4.w)		; set nxt dst wrd in plane

*+
* D' = S OR D
*-
		dc.w	o8Srtnf1-o7Srtnf1-3
o7Srtnf1:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		or.w	d1,d0			; d0 <- S OR D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	-2(a0),d0		; get src again
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
		dc.w	o9Srtnf1-o8Srtnf1-3
o8Srtnf1:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		move.w	-2(a0),d0		; get src again
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
		dc.w	oASrtnf1-o9Srtnf1-3
o9Srtnf1:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	-(a1),d1		; d1 <- dest
		eor.w	d1,d0			; d0 <- S XOR D
		not.w	d0			; d0 <- NOT [S XOR D]
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	-2(a0),d0		; get src again
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
		dc.w	oBSrtnf1-oASrtnf1-3
oASrtnf1:	move.w	-(a1),d0		; d0 <- D
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
		dc.w	oCSrtnf1-oBSrtnf1-3
oBSrtnf1:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		move.w	-2(a0),d0		; get src again
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
		dc.w	oDSrtnf1-oCSrtnf1-3
oCSrtnf1:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- dest
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	-2(a0),d0		; get src again
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
		dc.w	oESrtnf1-oDSrtnf1-3
oDSrtnf1:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		not.w	d0			; d0 <- NOT S
		move.w	-(a1),d1		; d1 <- dest
		or.w	d1,d0			; d0 <- [NOT S] OR D
		eor.w	d1,d0
		and.w	d7,d0
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set nxt dst wrd in plane
		move.w	-2(a0),d0		; get src again
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
		dc.w	oFSrtnf1-oESrtnf1-3
oESrtnf1:	move.w	(a0),d0			; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0),d1		; fetch second part of the word
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
		move.w	-2(a0),d0		; get src again
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
		dc.w	oGSrtnf1-oFSrtnf1-3
oFSrtnf1:	or.w	d7,-(a1)		; set the dst wrd
		or.w	d6,(a1,d4.w)		; set nxt dst wrd in plane

		dc.w	0
oGSrtnf1:	nop
