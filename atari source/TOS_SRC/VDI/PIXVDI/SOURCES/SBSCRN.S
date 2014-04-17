*********************************  sbscrn.s  **********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbscrn.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/08/06 20:05:51 $     $Locker:  $
* =============================================================================
*
* $Log:	sbscrn.s,v $
* Revision 3.1  91/08/06  20:05:51  lozben
* We now use _copytran in the overlay variable space rather than
* _COPYTRAN a linea structure variable.
* 
* Revision 3.0  91/08/06  19:34:05  lozben
* New generation VDI
* 
* Revision 2.4  91/07/08  16:26:22  lozben
* Made changes so that we can perform new TRANSPARANT and OPAQUE
* blit operations (we created new better routines).
* 
* Revision 2.3  90/01/11  12:24:15  lozben
* Added routine to do unaligned src to dst blit. Memory is interleaved.
* 
* Revision 2.2  89/12/07  14:42:37  lozben
* *** Initial Revision ***
* 
*******************************************************************************

		.globl	trans_pos_row
		.globl	trans_neg_row
		.globl	transSrPos
		.globl	transSlPos
		.globl	transSrNeg
		.globl	transSlNeg
		.globl	_copytran		; blit transparant flag

		.globl	opaq_pos_row
		.globl	opaq_neg_row
		.globl	opaqSrPos
		.globl	opaqSlPos
		.globl	opaqSrNeg
		.globl	opaqSlNeg


*+
* purpose: This file does source to destination bit blit without any other
*	   frills. The idea is not to tare in the multi plane mode (i.e.
*	   we do all planes at once) and blit much faster. The memory
*	   format is always interleaved planes.
*
* author:	Slavik Lozben
*		Atari corp.
*-

	.globl	set_fringe,get_fringe,d_xy2addr,s_xy2addr
	.globl	scrn_blt

*       FRAME PARAMETERS

B_WD	  equ	-76	; width of block in pixels			    +00
B_HT	  equ	-74	; height of block in pixels			    +02
PLANE_CT  equ	-72	; number of consequitive planes to blt		    +04

FG_COL	  equ	-70	; foreground color (logic op table index:hi bit)    +06
BG_COL	  equ	-68	; background color (logic op table index:lo bit)    +08
OP_TAB	  equ	-66	; logic ops for all fore and background combos	    +10

S_XMIN	  equ	-62	; minimum X: source				    +14
S_YMIN	  equ	-60	; minimum Y: source				    +16
S_FORM	  equ	-58	; source form base address			    +18
S_NXWD	  equ	-54	; offset to next word in line  (in bytes)	    +22
S_NXLN	  equ	-52	; offset to next line in plane (in bytes)	    +24
S_NXPL	  equ	-50	; offset to next plane from start of current plane  +26

D_XMIN	  equ	-48	; minimum X: destination			    +28
D_YMIN	  equ	-46	; minimum Y: destination			    +30
D_FORM	  equ	-44	; destination form base address			    +32
D_NXWD	  equ	-40	; offset to next word in line  (in bytes)	    +36
D_NXLN	  equ	-38	; offset to next line in plane (in bytes)	    +38
D_NXPL	  equ	-36	; offset to next plane from start of current plane  +40

P_ADDR	  equ	-34	; address of pattern buffer   (0:no pattern)	    +42
P_NXLN	  equ	-30	; offset to next line in pattern  (in bytes)	    +46
P_NXPL	  equ	-28	; offset to next plane in pattern (in bytes)	    +48
P_MASK	  equ	-26	; pattern index mask				    +50

***					    			    ***
***   these parameters are internally set, some have dual purpose   ***
***					                            ***

P_INDX	  equ	-24	; initial pattern index				    +52

S_ADDR	  equ	-22	; initial source address 			    +54
S_XMAX	  equ	-18	; maximum X: source				    +58
S_YMAX	  equ	-16	; maximum Y: source				    +60

D_ADDR	  equ	-14	; initial destination address			    +62
D_XMAX	  equ	-10	; maximum X: destination			    +66
D_YMAX	  equ	-08	; maximum Y: destination			    +68

INNER_CT  equ	-06	; blt inner loop initial count			    +70
DST_WR	  equ	-04	; destination form wrap (in bytes)		    +72
SRC_WR	  equ	-02	; source form wrap (in bytes)			    +74

***						   ***
*** more internal parameters (notice overlap above ***
***						   ***

SHFT1	=	-24
SHFT2	=	-22
MASK1	=	-20
MASK2	=	-14
MASK3	=	-12
OPAQUE	=	-4


*+
*  in:		d4.w	words in source - 1
*		d6.w	words in destination - 1
*-
scrn_blt:	move.w	d4,d2		; d2 <- will later get inner loop count

		move.w	D_NXWD(a6),d5	; d5 <- next word increment (l2r src)
		muls	d5,d6		; d6 <- row width offset in bytes (dst)
		move.w	S_NXWD(a6),d5	; d5 <- next word increment (l2r src)
		muls	d5,d4		; d4 <- row width offset in bytes (src)

		move.w	S_XMIN(a6),d0	; compute address of destination block
		move.w	S_YMIN(a6),d1
		bsr	s_xy2addr	; a0 -> start of source block

		sub.w	d3,d4		; d4 <- SRC_WR (r2l)

		move.w	D_XMIN(a6),d0	; compute address of source block
		move.w	D_YMIN(a6),d1
		bsr	d_xy2addr	; a1 -> start of destination block

		sub.w	d3,d6		; d6 <- DST_WR (r2l)

		cmp.l	a1,a0		; which address is larger: src or dst
		bne	sNotEqToD	; diff source and dest addresses
		move.w	S_XMIN(a6),d0
		cmp.w	D_XMIN(a6),d0	; compare starting pixels
sNotEqToD:	bcc	l2r_t2b		; select dir based on address order

r2l_b2t:	move.w	S_XMAX(a6),d0	; compute address of src low rt corner
		move.w	S_YMAX(a6),d1
		bsr	s_xy2addr	; a0 -> end of src block

		move.w	D_XMAX(a6),d0	; compute address of dst low rt corner
		move.w	D_YMAX(a6),d1
		bsr	d_xy2addr	; a1 -> end of destination block

		neg.w	d5		; d5 <- next word increment (r2l src)

		bra	set_fringe

l2r_t2b:	neg.w	d4		; d4 <- SRC_WR (l2r)
		neg.w	d6		; d6 <- DST_WR (l2r)

set_fringe:	move.w	d4,a4		; source wrap       (SRC_WR)
		move.w	d6,a5		; destination wrap  (DST_WR)

		move.w	S_XMIN(a6),d6	; min Y src
		move.w	D_XMIN(a6),d7	; min X dst
		and.w	#15,d6		; d6 <- Xmin src mod 16
		and.w	#15,d7		; d7 <- Xmin src mod 16
		sub.w	d6,d7		; d7 <- (Sxmin mod 16) - (Dxmin mod 16)	
		bne	unaligned	; do unaligned blit

		bsr	get_fringe
		move.l	d6,d7
		move.w	d7,d3
		swap	d3
		move.w	d7,d3		; d3 <- right fringe in low and high
		swap	d7
		move.w	d7,d6		; d6 <- left fringe in low and high

		tst.w	d5		; d5 < 0 => r2l. swap masks
		bmi	fringe_ok
		exg	d3,d6		; switch left fringe mask with right

fringe_ok:	move.w	B_HT(a6),d7	; d7 <- row count
		move.w	PLANE_CT(a6),d4
		beq	leave		; on zero planes just get out

*+
* Blits any number of planes. As long as the're in ST screen format and,
* Source and Destination are pixel aligned.
*-
setup:		subq.w	#1,d2
		move.w	d2,a3		; a3 <- width - 2 in words (1 plane)
		subq.w	#1,a3		; a3 <- width - 3 in words (1 plane)
		mulu.w	d4,d2		; d2 <- total width - 1 in words
		move.w	d2,d0		; d0 <- total width - 1 in words
		move.w	d0,d1		; d1 <- total width - 1 in words0
		lsr.w	#3,d1		; d1 <- count (# of 4 longs at a time)
		and.w	#6,d0		; d0 <- offset into the tower
		neg.w	d0

		move.w	d4,a2		; a2 <- planes
		subq.w	#1,a2		; adjust count
		lsl.w	#1,d4		; make d4 word offset
		tst.w	d5		; see if nxt wrd incr is neg
		bmi	neg_setup

		sub.w	d4,a5		; adjust for n - 1 planes
		tst.w	_copytran	; see if blit transparanat flag is on
		beq	setup1		; if not do regular blit
		subq.w	#2,a4		; adjust for 1 plane
		jmp	trans_pos_row	; go to transparant blit

setup1:		sub.w	d4,a4		; adjust for n - 1 planes
		tst.w	OPAQUE(a6)	; see if we are doing OPAQUE blit
		beq	gotoPosRow	; branch if just straight blit
		jmp	opaq_pos_row	; do generalized opaque blit

gotoPosRow:	lea	PTow1(pc,d0.w),a3
		move.w	d2,d4		; d4 <- width - 1 words
		move.w	d1,d2		; d2 <- count (# of 4 longs at a time)
		bra	pos_row		; start the blit


neg_setup:	add.w	d4,a1		; adjust for predecrement
		add.w	d4,a5		; adjust for n planes
		tst.w	_copytran	; see if blit transparanat flag is on
		beq	setup2		; if not do regular blit
		addq.w	#2,a4		; adjust for n planes
		addq.w	#2,a0		; adjust for predecrement
		jmp	trans_neg_row	; go to transparant blit

setup2:		add.w	d4,a4		; adjust for n planes
		add.w	d4,a0		; adjust for predecrement
		tst.w	OPAQUE(a6)	; see if we are doing OPAQUE blit
		beq	gotoNegRow	; branch if just straight blit
		jmp	opaq_neg_row	; do generalized opaque blit

gotoNegRow:	lea	NTow1(pc,d0.w),a3
		move.w	d2,d4		; d4 <- width - 1 words
		move.w	d1,d2		; d2 <- count (# of 4 longs at a time)
		bra	neg_row

*+
* Do any number of planes.
*
*	in	a0	src address
*		a1	dst address
*		a2	planes - 1
*		a4	offset to next source row
*		a5	offset to next dest row
*		a6	bitblt parameter block adr
*
*		d2	inner loop count
*		d3	fringe mask one
*		d6	fringe mask two
*		d7	row count
*-
f1_pos:		move.w	a2,d5		; d5 <- planes - 1
f1_pos_loop:	move.w	(a0)+,d0	; d0 <- 1st SOURCE word
		move.w	(a1),d1		; d1 <- 1st DESTINATION word
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- S
		dbra	d5,f1_pos_loop

		move.w	d2,d5 		; reinitialize inner loop counter
		btst	#0,d4
		beq	PTow0
		move.w	(a0)+,(a1)+	; DEST <- SOURCE
PTow0:		jmp	(a3)
sc_pos:		move.l	(a0)+,(a1)+	; blit 4 longs at once
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
PTow1:		dbra	d5,sc_pos

f2_pos:		move.w	a2,d5		; d5 <- planes - 1
f2_pos_loop:	move.w	(a0)+,d0	; d0 <- SOURCE last word
		move.w	(a1),d1		; d1 <- DESTINATION last word
		eor.w	d1,d0		;
		and.w	d3,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)+	; D' <- S
		dbra	d5,f2_pos_loop

		add.w	a4,a0		; a0 -> next SOURCE row
		add.w	a5,a1		; a1 -> next DESTINATION row

pos_row:	dbra	d7,f1_pos	; do next row
leave:		rts

*+
* Neg case
*-
f1_neg:		move.w	a2,d5		; d5 <- planes - 1	
f1_neg_loop:	move.w	-(a0),d0	; d0 <- 1st SOURCE word
		move.w	-(a1),d1	; d1 <- 1st DESTINATION word
		eor.w	d1,d0		;
		and.w	d6,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- S
		dbra	d5,f1_neg_loop

		move.w	d2,d5 		; reinitialize inner loop counter
		btst	#0,d4
		beq	NTow0
		move.w	-(a0),-(a1)	; DEST <- SOURCE
NTow0:		jmp	(a3)
sc_neg:		move.l	-(a0),-(a1)	; blit 4 longs at once
		move.l	-(a0),-(a1)
		move.l	-(a0),-(a1)
		move.l	-(a0),-(a1)
NTow1:		dbra	d5,sc_neg

f2_neg:		move.w	a2,d5		; d5 <- planes - 1
f2_neg_loop:	move.w	-(a0),d0	; d0 <- SOURCE last word
		move.w	-(a1),d1	; d1 <- DESTINATION last word
		eor.w	d1,d0		;
		and.w	d3,d0		;
		eor.w	d1,d0		;
		move.w	d0,(a1)		; D' <- S
		dbra	d5,f2_neg_loop

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
*	in	a0	src address (unadjusted)
*		a1	dst address (unadjusted)
*		a4	offset to next source row
*		a5	offset to next dest row
*		a6	bitblt parameter block adr
*
*		d2	length in words - 1
*		d5	nxt wrd incr (could be neg)
*-


unaligned:	move.w	PLANE_CT(a6),d4
		beq	leave			; on zero planes just get out
		move.l	#0,a2			; clear out the whole register
		move.w	d4,a2			; a2 <- number of planes
		subq.w	#1,a2			; adjust the counter
*+
* Blits any number of planes. As long as the're in ST screen format and,
* Source and Destination are pixel aligned.
*-
shiftSetup:	tst.w	_copytran		; see if blit transp flag is on
		bne	trShiftSetup		; if so do transparant blit
		subq.w	#2,d2			; subtract last fringe + 1
		tst.w	OPAQUE(a6)		; see if doing general PAQUE
		bne	shiftS0			; if so skip multiplying
		mulu.w	d4,d2			; d2 <- inner loop cnt in wrds
shiftS0:	move.w	d2,INNER_CT(a6)		; store inner cnt for later use

		lsl.w	#1,d4			; make d4 word offset
		tst.w	d5			; see if nxt wrd incr is neg
		bmi	nShiftSetup

		sub.w	d4,a4			; adjust for n - 1 planes
		sub.w	d4,a5			; adjust for n - 1 planes
		bra	shiftPos		; start the blit

*+
* Unaligned case predecrement
*-
nShiftSetup:	add.w	d4,a4			; adjust for n - 1 planes
		add.w	d4,a5			; adjust for n - 1 planes
		add.w	d4,a0			; adjust for predecrement
		add.w	d4,a1			; adjust for predecrement
		neg.w	d4			; offs to the prev wrd in plane
		bra	shiftNeg

************************************************+
*
* Adjust some variables for tansparant blit
*-
trShiftSetup:	subq.w	#2,d2			; subtract last fringe + 1
		move.w	d2,INNER_CT(a6)		; store inner cnt for later use

		lsl.w	#1,d4			; make d4 word offset
		tst.w	d5			; see if nxt wrd incr is neg
		bmi	trNShiftSetup

		sub.w	#2,a4			; adjust for 1 plane
		sub.w	d4,a5			; adjust for n planes
		bra	shiftPos		; start the blit

*+
* Unaligned case predecrement
*-
trNShiftSetup:	addq.w	#2,a4			; adjust for 1 plane
		addq.w	#2,a0			; for predecrementing
		add.w	d4,a1			; adjust for predecrement
		add.w	d4,a5			; adjust for n planes
		neg.w	d4			; offs to the prev wrd in plane
		bra	shiftNeg

************************************************-

*+
* Unaligned case postincrement
*-
shiftPos:	move.w	S_XMIN(a6),d0		; d0 <- source x min
		move.w	D_XMIN(a6),d2		; d2 <- destination x min
		and.w	#15,d0			; d0 <- strt pix in the wrd src
		and.w	#15,d2			; d2 <- strt pix in the wrd dst
		cmp.w	d0,d2			; see which way to shift
		blt	cslp0			; if < 0 do shift left

*+
* case shift right positive
*-
csrp0:		lea	srPentry(pc),a3		; a3 -> entry routine for blit
		tst.w	_copytran		; see if blt trnsprnt flg is on
		beq	csrp2			; if not then skip
		lea	transSrPos,a3		; a3 -> trns entry for blit

csrp2:		tst.w	OPAQUE(a6)		; see if OPAQUE blt flag is on
		beq	csrp3			; if not then skip
		lea	opaqSrPos,a3		; a3 -> opaq entry for blit

csrp3:		move.w	#$ffff,d6
		lsr.w	d2,d6			; d6 <- MASK1
		move.w	d6,MASK1(a6)		; save MASK1
		sub.w	d0,d2			; d2 <- shft SHFT1 (rght shft)
		move.w	d2,SHFT1(a6)		; save SHFT1 (right shift)
		move.w	#16,d3			; d3 <- # of pixels in word
		sub.w	d2,d3			; d3 <- shft SHFT2 (left shft)
		move.w	d3,SHFT2(a6)		; save SHFT2 (left shift)
		move.w	#$ffff,d6		; d6 <- $ffff
		move.w	S_XMAX(a6),d1		; d1 <- source x max
		and.w	#15,d1			; d1 <- end pix in the src wrd
		add.w	d2,d1			; d1 <- end pix in the dst wrd
		sub.w	#15,d1			; see if we went over wrd bndry
		bgt	csrp1
		neg	d1
		lsl.w	d1,d6			; clear out the needed bits
		move.w	d6,MASK2(a6)		; save MASK2
		clr.w	MASK3(a6)		; clear MASK3
		bra 	unlgnSetup

csrp1:		add.w	d4,a5			; adjust offset to nxt dst wrd
		move.w	d6,MASK2(a6)		; save MASK2
		lsr.w	d1,d6
		not.w	d6			; d6 <- MASK3
		move.w	d6,MASK3(a6)		; save MASK3
		bra 	unlgnSetup

*+
* case shift left positive
*-
cslp0:		lea	slPentry(pc),a3		; a3 -> entry routine for blit
		tst.w	_copytran		; see if blt trnsprnt flg is on
		beq	cslp2			; if not then skip
		lea	transSlPos,a3		; a3 -> trns entry for blit

cslp2:		tst.w	OPAQUE(a6)		; see if OPAQUE blt flag is on
		beq	cslp3			; if not then skip
		lea	opaqSlPos,a3		; a3 -> opaq entry for blit

cslp3:		move.w	#$ffff,d6
		lsr.w	d2,d6			; d6 <- MASK1
		sub.w	d2,d0			; d0 <- shft SHFT2 (left shft)
		move.w	d0,SHFT2(a6)		; save SHFT2 (left shift)
		move.w	d6,MASK1(a6)		; save MASK1
		move.w	#16,d3			; d3 <- # of pixels in word
		sub.w	d0,d3			; d3 <- shft SHFT1 (rght shft)
		move.w	d3,SHFT1(a6)		; save SHFT1 (right shift)
		move.w	#$ffff,d6		; d6 <- $ffff
		move.w	S_XMAX(a6),d1		; d1 <- source x max
		and.w	#15,d1			; d1 <- end pix in the src wrd
		sub.w	d0,d1			; d1 <- end pix in the dst wrd
		addq.w	#1,d1
		ble	cslp1
		move.w	d6,MASK2(a6)		; MASK2
		lsr.w	d1,d6
		not.w	d6			; d6 <- MASK3
		move.w	d6,MASK3(a6)		; save MASK3
		bra 	unlgnSetup
		
cslp1:		sub.w	d4,a5			; adjust offset to nxt dst wrd
		neg.w	d1
		lsl.w	d1,d6			; clear out the needed bits
		move.w	d6,MASK2(a6)		; save MASK2
		clr.w	MASK3(a6)		; save MASK3
		bra 	unlgnSetup

*+
*  Unaligned case predecrement
*-
shiftNeg:	move.w	S_XMAX(a6),d0		; d0 <- source x max
		move.w	D_XMAX(a6),d2		; d2 <- destination x max
		and.w	#15,d0			; d0 <- strt pix in the wrd src
		and.w	#15,d2			; d2 <- strt pix in the wrd dst
		cmp.w	d0,d2
		blt	csln0			; if > 0 do shift left
		
*+
* case shift right negative
*-
csrn0:		lea	srNentry(pc),a3		; a3 -> entry routine for blit
		tst.w	_copytran		; see if blt trnsprnt flg is on
		beq	csrn2			; if not then skip
		lea	transSrNeg,a3		; a3 -> trns entry for blit

csrn2:		tst.w	OPAQUE(a6)		; see if OPAQUE blt flag is on
		beq	csrn3			; if not then skip
		lea	opaqSrNeg,a3		; a3 -> opaq entry for blit

csrn3:		move.w	#$ffff,d6
		lsr.w	d2,d6
		lsr.w	d6
		not.w	d6			; d6 <- MASK1
		move.w	d6,MASK1(a6)		; save MASK1
		sub.w	d0,d2			; d1 <- shft SHFT2 (rght shft)
		move.w	d2,SHFT2(a6)		; save SHFT2 (rght shft)
		move.w	#$ffff,d6		; d6 <- $ffff
		sub.w	#16,d2
		neg.w	d2			; d2 <- SHFT1 (lft shft)
		move.w	d2,SHFT1(a6)		; save SHFT1 (lft shift)
		move.w	S_XMIN(a6),d1		; d1 <- source x min
		and.w	#15,d1			; d1 <- end pix in the src wrd
		add.w	SHFT2(a6),d1		; d1 <- end pix in the dst wrd
		sub	#16,d1
		blt	csrn1
		lsr.w	d1,d6			; clear out the needed bits
		move.w	d6,MASK2(a6)		; save MASK2
		clr.w	MASK3(a6)		; save MASK3
		sub.w	d4,a5			; adjust offset to nxt dst wrd
		bra 	unlgnSetup
		
csrn1:		add.w	#16,d1			; d1 <- D_XMIN mod 16
		move.w	d6,MASK2(a6)		; save MASK2
		lsr.w	d1,d6			; d6 <- MASK3
		move.w	d6,MASK3(a6)		; save MASK3
		bra 	unlgnSetup

*+
* case shift left negative
*-
csln0:		lea	slNentry(pc),a3		; a3 -> entry routine for blit
		tst.w	_copytran		; see if blt trnsprnt flg is on
		beq	csln2			; if not then skip
		lea	transSlNeg,a3		; a3 -> trns entry for blit

csln2:		tst.w	OPAQUE(a6)		; see if OPAQUE blt flag is on
		beq	csln3			; if not then skip
		lea	opaqSlNeg,a3		; a3 -> opaq entry for blit

csln3:		move.w	#$ffff,d6
		lsr.w	d2,d6
		lsr.w	d6
		not.w	d6			; d6 <- MASK1
		move.w	d6,MASK1(a6)		; save MASK1
		sub.w	d2,d0			; d2 <- shft SHFT1 (lft shft)
		move.w	d0,SHFT1(a6)		; save SHFT1 (lft shift)
		move.w	#16,d3
		sub.w	d0,d3			; d3 <- shft SHFT2 (rght shft)
		move.w	d3,SHFT2(a6)		; save SHFT2 (rght shift)
		move.w	#$ffff,d6		; d6 <- $ffff
		move.w	S_XMIN(a6),d1		; d1 <- source x max
		and.w	#15,d1			; d1 <- end pix in the src wrd
		sub.w	d0,d1			; d1 <- end pix in the dst wrd
		blt	csln1
		lsr.w	d1,d6			; clear out the needed bits
		move.w	d6,MASK2(a6)		; save MASK2
		clr.w	MASK3(a6)		; save MASK3
		bra 	unlgnSetup
		
csln1:		add.w	d4,a5			; adjust offset to nxt dst wrd
		neg	d1
		move.w	d6,MASK2(a6)		; save MASK2
		lsl.w	d1,d6			; d6 <- MASK3
		not.w	d6			; adjust for our logic
		move.w	d6,MASK3(a6)		; save MASK3

*+
* Setup the registers for the blit
*-
unlgnSetup:	move.w	B_HT(a6),d2		; look below for info
		swap	d2
		move.w	SHFT1(a6),d2
		move.w	SHFT2(a6),d3
		move.w	MASK3(a6),d6
		swap	d6
		move.w	MASK1(a6),d6
		move.w	MASK2(a6),d7
		jmp	(a3)			; do the blit

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
*		d6	mask1 (low word) / mask3 (high word)
*		d7	mask2 (low word)
*-

*******************************************************************************
*			   Shift right positive case			      *
*******************************************************************************

srPos:		swap	d2			; shft count1 is now in low wrd
		move.w	a2,d5			; d5 <- planes - 1

*+
* do left fringe
*-
srFr0P:		move.w	(a0)+,d0		; d0 <- src wrd
		move.w	(a1),d1			; d1 <- dst
		lsr.w	d2,d0			; adjust bits we need to splat
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst wrd
		dbra	d5,srFr0P		; do next plane

*+
* do inner words
*-
		move.w	INNER_CT(a6),d5		; d5 <- internal count

srInP:		move.w	(a0,d4.w),d1		; d1 <- prev source word
		lsl.w	d3,d1			; shift the other way now
		move.w	(a0)+,d0		; d0 <- source word
		lsr.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	d0,(a1)+		; dst <- S
		dbra	d5,srInP		; do nxt wrd/nxt plane

*+
* do right fringe
*-
		swap	d6			; mask3 is now in low word
		move.w	a2,d5			; d5 <- planes - 1
srFr1P:		move.w	(a0,d4.w),d1		; d1 <- prev source word
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
		neg	d4			; d4 becomes negative
		dbra	d5,srFr1P		; do nxt plane
		swap	d6			; mask1 is now in low word

		add.w	a4,a0			; a0 -> next SOURCE row
		add.w	a5,a1			; a1 -> next DESTINATION row

		swap	d2			; row count is now in low word
		dbra	d2,srPos		; do nxt row
		rts

srPentry:	move.w	a2,d0			; d0 <- planes - 1
		add.w	d0,INNER_CT(a6)		; adjust the count
		neg.w	d4			; offset to previous word
		swap	d2			; row count is now in low word
		dbra	d2,srPos		; do nxt row
		rts

*******************************************************************************
*			   Shift left positive case			      *
*******************************************************************************

slPos:		swap	d2			; shft count1 is now in low wrd
		move.w	a2,d5			; d5 <- planes - 1

*+
* do left fringe
*-
slFr0P:		move.w	(a0)+,d0		; d0 <- scc wrd
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	(a1),d1			; d1 <- D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)+		; set the dst
		dbra	d5,slFr0P		; do nxt plane

*+
* do inner words
*-
		move.w	INNER_CT(a6),d5		; d5 <- internal count
		bra	slInPEn			; start blitting

slInP:		move.w	(a0)+,d0		; d0 <- source word
		lsl.w	d3,d0			; adjust bits we need to splat
		move.w	-2(a0,d4.w),d1		; fetch second part of the word
		lsr.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	d0,(a1)+		; set nxt dst wrd in plane
slInPEn:	dbra	d5,slInP		; do nxt wrd/nxt plane

*+
* do right fringe
*-
		swap	d6			; MASK3 is now in low word
		move.w	a2,d5			; d5 <- planes - 1
slFr1P:		move.w	(a0)+,d0		; d0 <- source word
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
		dbra	d5,slFr1P		; do the nxt plane
		swap	d6			; MASK1 is now in low word

		add.w	a4,a0			; a0 -> next SOURCE row
		add.w	a5,a1			; a1 -> next DESTINATION row

		swap	d2			; row count is now in low word
		dbra	d2,slPos		; do next row
		rts

slPentry:	add.w	d4,a4			; udjust for shift left case
		add.w	d4,a5			; udjust for shift left case
		swap	d2			; row count is now in low word
		dbra	d2,slPos		; do next row
		rts

*******************************************************************************
*			   Shift left negative case			      *
*******************************************************************************

slNeg:		swap	d2			; shft count1 is now in low wrd
		move.w	a2,d5			; d5 <- planes - 1

*+
* do right fringe
*-
slFr0N:		move.w	-(a0),d0		; d0 <- src wrd
		move.w	-(a1),d1		; d1 <- dst
		lsl.w	d2,d0			; adjust bits we need to splat
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask the out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst wrd
		dbra	d5,slFr0N		; do nxt plane

*+
* do inner words
*-
		move.w	INNER_CT(a6),d5		; d5 <- internal count

slInN:		move.w	-2(a0,d4.w),d1		; d1 <- prev source word
		lsr.w	d3,d1			; shift the other way now
		move.w	-(a0),d0		; d0 <- source word
		lsl.w	d2,d0			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- the needed source
		move.w	d0,-(a1)		; dst <- S
		dbra	d5,slInN		; do nxt wrd/nxt plane

*+
* do left fringe
*-
		swap	d6			; MASK3 is now in low word
		move.w	a2,d5			; d5 <- planes - 1
slFr1N:		move.w	-2(a0,d4.w),d1		; d1 <- prev source word
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
		dbra	d5,slFr1N		; do the nxt plane
		swap	d6			; MASK1 is now in low word


		add.w	a4,a0			; a0 -> next SOURCE row
		add.w	a5,a1			; a1 -> next DESTINATION row

		swap	d2			; row count is now in low word
		dbra	d2,slNeg
		rts

slNentry:	move.w	a2,d0			; d0 <- planes - 1
		add.w	d0,INNER_CT(a6)		; adjust the count
		neg.w	d4			; make d4 pos
		swap	d2			; row count is now in low word
		dbra	d2,slNeg
		rts

*******************************************************************************
*			   Shift right negative case			      *
*******************************************************************************

srNeg:		swap	d2			; shift count1 is in low word
		move.w	a2,d5			; d5 <- planes - 1
*+
* do right fringe
*-
srFr0N:		move.w	-(a0),d0		; d0 <- scc wrd
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; adjust bits we need to splat
		or.w	d1,d0			; d0 <- S
		move.w	-(a1),d1		; d1 <- D
		eor.w	d1,d0			; d0 <- (dst eor src)
		and.w	d6,d0			; mask out needed bits
		eor.w	d1,d0			; d0 <- wanted source
		move.w	d0,(a1)			; set the dst
		dbra	d5,srFr0N		; do nxt plane

*+
* do inner words
*-
		move.w	INNER_CT(a6),d5		; d5 <- internal count
		bra	srInNEn

srInN:		move.w	-(a0),d0		; d0 <- source word
		lsr.w	d3,d0			; adjust bits we need to splat
		move.w	(a0,d4.w),d1		; fetch second part of the word
		lsl.w	d2,d1			; shift the other way now
		or.w	d1,d0			; d0 <- the needed source
		move.w	d0,-(a1)		; set nxt dst wrd in plane
srInNEn:	dbra	d5,srInN		; do nxt wrd/nxt plane

*+
* do left fringe
*-
		swap	d6			; MASK3 is now in low word
		move.w	a2,d5			; d5 <- planes - 1
srFr1N:		move.w	-(a0),d0		; d0 <- source word
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

		dbra	d5,srFr1N		; do nxt plane
		swap	d6			; MASK1 is now in low word


		add.w	a4,a0			; a0 -> next SOURCE row
		add.w	a5,a1			; a1 -> next DESTINATION row

                swap	d2			; row count is now in low word
		dbra	d2,srNeg		; do next row
		rts

srNentry:	add.w	d4,a4			; udjust for shift left case
		add.w	d4,a5			; udjust for shift left case
                swap	d2			; row count is now in low word
		dbra	d2,srNeg		; do next row
		rts

	.end
