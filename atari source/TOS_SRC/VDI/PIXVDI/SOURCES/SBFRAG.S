******************* Revision Control System *****************************
*
* $Author: lozben $
* =======================================================================
*
* $Date: 91/01/03 15:16:56 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	sbfrag.s,v $
* Revision 3.0  91/01/03  15:16:56  lozben
* New generation VDI
* 
* Revision 2.1  89/02/21  17:25:52  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  87/11/20  15:17:11  lozben
* Initial revision
* 
*
* =======================================================================
*
* $Revision: 3.0 $
* =======================================================================
*
* $Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbfrag.s,v $
* =======================================================================
*
*************************************************************************


SRC_WR		equ	-2
DST_WR		equ	-4
INNER_CT	equ	-6

P_ADDR		equ	-34	; address of pattern buffer
P_NXLN		equ	-30	; offset to next line in pattern  (in bytes)
P_NXPL		equ	-28	; offset to next plane in pattern (in bytes)
P_MASK		equ	-26	; pattern index mask

F1OP		equ	 8
F2OP		equ	22

       	.globl 	mode_00,mode_01,mode_02,mode_03,mode_04,mode_05,mode_06,mode_07
	.globl 	mode_08,mode_09,mode_10,mode_11,mode_12,mode_13,mode_14,mode_15

	.globl	f0_l2r_rt,f1_l2r_rt,f2_l2r_rt,fl_l2r_rt
	.globl	f0_l2r_lf,f1_l2r_lf,f2_l2r_lf,fl_l2r_lf
	.globl	f0_r2l_rt,f1_r2l_rt,f2_r2l_rt,fl_r2l_rt
	.globl	f0_r2l_lf,f1_r2l_lf,f2_r2l_lf,fl_r2l_lf

	.globl	f0_left,f0_right,f2_update,f1_dst,f1_drt,f2_dst,p1_update


* name:
*	bltfrag.s
*
* purpose:
*
*	these fragments may be threaded together to perform all the prescribed
*	operations of the GSX bitblt.
*
* author:
*
*	jim eisenstein
*	atari corp.
*
* latest update:
*
*	25-jan-85
*
*
*  in:
*	d2.w		signed offset to next word in SOURCE
*	d3.w		signed offset to next word in DESTINATION
*	d4.w		shift count
*	d5(15:00)	iterations of inner loop
*	d5(31:16)	row counter
*	d6(15:00)	initial fringe mask
*	d6(31:16)	final fringe mask
*
*
*	a0.l		points to first word of SOURCE
*	a1.l		points to first word of DESTINATION
*	a2.l		thread from inner loop to logic op fragment
*	a3.l		thread from logic op fragment back to inner loop
*	a4.l		thread from update fragment back to 1st fringe fragment
*	a6.l		frame pointer
*
*	frame offsets
*
*	SRC_WR		offset from current word to first word of next row of source
*	DST_WR		offset from current word to first word of next row of dest
*	INNER_CT	inner loop count
*

	nop

.page

***				   ***
***   PATTERN PARAMETER UPDATING   ***
***				   ***

p1_update:

	swap	d7		; d7(15:00) <- raw pattern index pointer	 4
	move.w	d7,d0		; d0 <- pattern index				 4
	add.w	P_NXLN(a6),d7	; advance index counter to next line		12
	swap	d7		; d7(15:00) <- old pattern word			 4

	and.w	P_MASK(a6),d0	; d0 <- index into pattern 			12

	move.l	a6,d1		; d1 <- temporary home for frame pointer	 4
	move.l	P_ADDR(a6),a6	; a6 -> top of pattern block (for this plane)   16
	move.w	0(a6,d0.w),d7	; d7 <- new pattern word			14
	move.l	d1,a6		; a6 -> frame					 4

	jmp	(a5)		; thread to first fringe fragment		 8


.page

***					       ***
***   FIRST FRINGE FRAGMENTS:single transfer   *** 
***					       ***


f0_left:

	move.w	(a0),d0		; d0(31:16) <- most recent SOURCE word		 8
	rol.w	d4,d0		; d0(15:00) <- aligned word		      6-22
	jmp	F1OP(a2)	; send to DESTINATION via logic op		10



f0_right:

	move.w	(a0),d0		; d0(31:16) <- most recent SOURCE word		 8
	ror.w	d4,d0		; d0(15:00) <- aligned word		      6-22
	jmp	F1OP(a2)	; send to DESTINATION via logic op		10


.page

***			       ***
***   FIRST FRINGE FRAGMENTS   *** 
***			       ***


*	move from right to left.
*	fetch 2 Source words.
*	store 1 Destination fringe.
*	shift right.

f1_r2l_rt:

	move.w	(a0),d0		; d0 <- SOURCE 1st word				 8
	adda.w	d2,a0		; a0 -> SOURCE 2nd word				 8
	swap	d0		; d0(31:16) <- 1st SRC word			 4


*	move from right to left.
*	fetch 1 Source word.
*	store 1 Destination fringe.
*	shift right to achieve a net left shift.

f0_r2l_rt:

	move.w	(a0),d0		; d0(31:16) <- most recent SOURCE word		 8
	swap	d0		; d0(15:00) <- 1st SOURCE word or garbage	 4

	move.l	d0,d1		; d1(31:16) <- set up for INNER LOOP		 4

	ror.l	d4,d0		; d0(15:00) <- aligned right fringe	      8-24

	jmp	F1OP(a2)	; send to DESTINATION via logic op		10




*	move from right to left.
*	fetch 2 Source words.
*	store 1 Destination fringe.
*	rotate left to achieve a net right shift.

f1_r2l_lf:

	move.w	(a0),d0		; d0 <- 1st SOURCE word				 8
	adda.w	d2,a0		; a0 -> 2nd SOURCE word				 8
	swap	d0		; d0(31:16) <- SRC word				 4


*	move from right to left.
*	fetch 1 Source word.
*	store 1 Destination fringe.
*	rotate left.

f0_r2l_lf:

	move.w	(a0),d0		; d0(15:00) <- SRC wrd				 8

	move.l	d0,d1		; set up d1(31:16) for inner loop		 4
	swap	d1		; d1(31:16) <- 1st word for bit pump		 4

	rol.l	d4,d0		; d0(15:00) <- aligned SRC right fringe	      8-24

	jmp	F1OP(a2)	; thread to logic op fragment for 1st fringe	10



*	move from left to right.
*	fetch 2 Source words.
*	store 1 Destination fringe.
*	rotate right to achieve a net left shift.

f1_l2r_rt:

	move.w	(a0),d0		; d0 <- 1st SOURCE word				 8
	adda.w	d2,a0		; a0 -> 2nd SOURCE word				 8
	swap	d0		; d0(31:16) <- SRC 1st word (old)		 4


*	move from left to right.
*	fetch 1 Source word.
*	store 1 Destination fringe.
*	rotate right.

f0_l2r_rt:

	move.w	(a0),d0		; d0(15:00) <- SRC 2nd word (new)		 8

	move.l	d0,d1		; set up d1(31:16) for inner loop		 4
	swap	d1		; d1(31:16) <- SOURCE 2nd word			 4

	ror.l	d4,d0		; d0(15:00) <- aligned left fringe	      8-24

	jmp	F1OP(a2)	; mask and write to DESTINATION			10



*	move from left to right.
*	fetch 2 Source words.
*	store 1 Destination fringe.
*	shift left.

f1_l2r_lf:

	move.w	(a0),d0		; d0 <- SOURCE 1st word				 8
	adda.w	d2,a0		; a0 -> SOURCE 2nd word				 8
	swap	d0		;						 4


*	move from left to right.
*	fetch 1 Source word.
*	store 1 Destination fringe.
*	shift left to achieve a net right shift.

f0_l2r_lf:

	move.w	(a0),d0		; d0(31:16) <- SOURCE 2nd word (new)		 8
	swap	d0		; d0(15:00) <- SOURCE 1st word (old)		 4

	move.l	d0,d1		; d1(31:16) <- set up for INNER LOOP		 4

	rol.l	d4,d0		; d0(15:00) <- aligned SRC left fringe	      8-24

	jmp	F1OP(a2)	; write mode and store to DESTINATION		10



.page

***			     ***
***   INNER LOOP FRAGMENTS   ***
***			     ***

i1_r2l_rt:

	adda.w	d2,a0		; a0 -> new SOURCE word				 8
	adda.w	d3,a1		; a1 -> new DESTINATION word			 8

	move.l	d1,d0		; d0(31:16) <- old SOURCE word			 4

	move.w	(a0),d0		; d0(15:00) <- old SOURCE word			 8
	swap	d0		; d0(31:16) <- new SOURCE word			 4
	move.l	d0,d1		; d1(31:16) <- new SOURCE word (unaligned)	 4

	ror.l	d4,d0		; d0(15:00) <- alligned SOURCE: new|old	      8-24

	jmp	(a2)		; write aligned SOURCE to DESTINATION		 8



i1_r2l_lf:

	adda.w	d2,a0		; a0 -> new SOURCE word				 8
	adda.w	d3,a1		; a1 -> new DESTINATION word			 8

	move.l	d1,d0		; d0(31:16) <- old SOURCE word			 4

	move.w	(a0),d0		; d0(15:00) <- new SOURCE word			 8
	move.l	d0,d1		; d0(31:16) <- old SOURCE word			 4
	swap	d1		; d1(31:16) <- new SOURCE word (unaligned)	 4

	rol.l	d4,d0		; d0(15:00) <- alligned SOURCE: new|old	      8-24

	jmp	(a2)		; write aligned SOURCE to DESTINATION		 8



i1_l2r_rt:

	adda.w	d2,a0		; a0 -> new SOURCE word				 8
	adda.w	d3,a1		; a1 -> new DESTINATION word			 8

	move.l	d1,d0		; d0(31:16) <- old SOURCE word			 4

	move.w	(a0),d0		; d0(15:00) <- new SOURCE word			 8
	move.l	d0,d1		; d0(31:16) <- old SOURCE word			 4
	swap	d1		; d1(31:16) <- new SOURCE word (unaligned)	 4

	ror.l	d4,d0		; d0(15:00) <- alligned SOURCE: old|new	      8-24

	jmp	(a2)		; write aligned SOURCE to DESTINATION		 8



i1_l2r_lf:

	adda.w	d2,a0		; a0 -> new SOURCE word				 8
	adda.w	d3,a1		; a1 -> new DESTINATION word			 8

	move.l	d1,d0		; d0(31:16) <- old SOURCE word			 4

	move.w	(a0),d0		; d0(15:00) <- old SOURCE word			 8
	swap	d0		; d0(31:16) <- new SOURCE word			 4
	move.l	d0,d1		; d1(31:16) <- new SOURCE word (unaligned)	 4

	rol.l	d4,d0		; d0(15:00) <- alligned SOURCE: old|new	      8-24

	jmp	(a2)		; write aligned SOURCE to DESTINATION		 8





.page

***							     ***
***   INNER LOOP COUNTER and SECOND FRINGE REQUIRING FETCH   ***
***							     ***

f2_r2l_rt:

	dbra	d5,i1_r2l_rt	; do another INNER LOOP cycle		   (10)/14

	adda.w	d2,a0		; a0 -> last SOURCE word			 8

  	move.l	d1,d0		; d0(31:16) <- next to last SOURCE word		 4
  	move.w	(a0),d0		; d0(15:00) <- last SOURCE word			 8

	ror.l	d4,d0		; d0(31:16) <- alligned SRC: new|old	      8-24

	bra	f2_flush	; send fringe to DESTINATION			10



f2_r2l_lf:

	dbra	d5,i1_r2l_lf	; do another INNER LOOP cycle		   (10)/14

	adda.w	d2,a0		; a0 -> new SOURCE word				 8

  	move.l	d1,d0		; d0(31:16) <- next to last SOURCE word		 4
  	move.w	(a0),d0		; d0(15:00) <- last SOURCE word			 8
  
  	rol.l	d4,d0		; d0(15:00) <- alligned SRC: new|old	      8-24

	bra	f2_out		; send fringe to DESTINATION			10



f2_l2r_rt:

	dbra	d5,i1_l2r_rt	; do another INNER LOOP cycle		   (10)/14

	adda.w	d2,a0		; a0 -> new SOURCE word				 8

  	move.l	d1,d0		; d0(31:16) <- next to last SOURCE word		 4
  	move.w	(a0),d0		; d0(15:00) <- last SOURCE word			 8
  
  	ror.l	d4,d0		; d0(15:00) <- alligned SRC: old|new	      8-24

	bra	f2_out		; send fringe to DESTINATION			10



f2_l2r_lf:

	dbra	d5,i1_l2r_lf	; do another INNER LOOP cycle		   (10)/14

	adda.w	d2,a0		; a0 -> new SOURCE word				 8

  	move.l	d1,d0		; d0(31:16) <- next to last SOURCE word		 4
  	move.w	(a0),d0		; d0(15:00) <- last SOURCE word			 8

	rol.l	d4,d0		; d0(31:16) <- alligned SRC left fringe	      8-24

	bra	f2_flush	; send fringe to DESTINATION			10



.page

***							     ***
***   INNER LOOP COUNTER and SECOND FRINGE REQUIRING FLUSH   ***
***							     ***

fl_r2l_rt:

	dbra	d5,i1_r2l_rt	; do another INNER LOOP cycle		   (10)/14
	bra	f2_flush	;						10

fl_r2l_lf:

	dbra	d5,i1_r2l_lf	; do another INNER LOOP cycle		   (10)/14
	bra	f2_flush	;						10

fl_l2r_rt:

	dbra	d5,i1_l2r_rt	; do another INNER LOOP cycle		   (10)/14
	bra	f2_flush	;						10

fl_l2r_lf:

	dbra	d5,i1_l2r_lf	; do another INNER LOOP cycle		   (10)/14
****	bra	f2_flush	; fall through to f2_flush			10




.page

***					    ***
***   FINAL FRINGE OUTPUT and ROW CONTROL   ***
***					    ***

f2_flush:

	swap	d0		; d0(15:00) <- the target fringe		 4

f2_out:
	adda.w	d3,a1		; a1 -> last DESTINATION word			 8

  	swap	d6		; d6(15:00) <- 2nd fringe mask  		 4
  	jmp	F2OP(a2)	; process 2nd fringe   				10
f2_rtn:
  	swap	d6		; d6(15:00) <- 1st fringe mask			 4

  	move.w	INNER_CT(a6),d5	; reinit inner loop counter			12

f2_update:

	swap	d5		; access row counter				 4
	subq.w	#1,d5		; decrement row counter				 4
	beq	f2_end		;					    (10)/8
	swap	d5		;						 4

  	adda.w	SRC_WR(a6),a0	; a0 -> last word of next line: SRC		16
  	adda.w	DST_WR(a6),a1	; a1 -> last word of next line: DST		16
  
	jmp	(a4)		; thread to first fringe fragment		 8


f2_end:	rts




.page

***					***
***   UNARY ALTERATION OF DESTINATION   ***
***	logic ops: 00, 05, 10, 15	***
***					***

f1_dst:
	jmp	F1OP(a2)	; write 1st fringe				10

i1_dst:
	adda.w	d3,a1		; a1 -> new DESTINATION word			 8
	jmp	(a2)		; write to DESTINATION				 8

f2_dst:
	dbra	d5,i1_dst	; do another INNER LOOP cycle		   (10)/14

	adda.w	d3,a1		; a1 -> last DESTINATION word			 8
  	swap	d6		; d6(15:00) <- 2nd fringe mask  		 4
  	jmp	F2OP(a2)	; process 2nd fringe   				10
f2_drt:	swap	d6		; d6(15:00) <- 1st fringe mask			 4

  	move.w	INNER_CT(a6),d5	; reinit inner loop counter			12

f1_drt:
	swap	d5		;						 4
	subq.w	#1,d5		; decrement row counter				 4
	beq	f2_end		;					    (10)/8
	swap	d5		;						 4

  	adda.w	DST_WR(a6),a1	; a1 -> initial word of next line: DST		16
  
	jmp	(a4)		; thread to first fringe fragment		 8






.page


***					     ***
***	INNER LOOP WRITING MODE FRAGMENTS    ***
***				     	     ***

*  in:
*	a1.l	points to destination word
*	a3.l	thread to next fragment
*	d0.w	contains aligned source

***				 	       ***
***	FIRST FRINGE WRITING MODE FRAGMENTS    ***
***				 	       ***

*  in:
*	a1.l	points to destination word
*	a3.l	thread to next fragment
*	d0.w	contains aligned source
*	d1.w	scratch
*	d6.w	fringe mask

***				 	 	***
***	SECOND FRINGE WRITING MODE FRAGMENTS    ***
***				 		***

*  in:
*	a1.l	points to destination word
*	d0.w	contains aligned source
*	d1.w	scratch
*	d6.w	fringe mask
*
*		this fragment threads to "f2_flush"

*  NOTE: all "f1op_xx" fragments are offset 06 from "mode_xx" fragments
*        all "f2op_xx" fragments are offset 18 from "mode_xx" fragments


	and.w	d7,d0		; S and P					 4
mode_00:
	move.w	#$0000,(a1)	; D' <- S=0   					12
	jmp	(a3)		; 						 8

	and.w	d7,d0		; S and P					 4
f1op_00:
	not.w	d6		; D' <- 0					 4
	and.w	d6,(a1)		;						12
	not.w	d6		;						 4
	jmp	(a3)		;						 8

	ds.w	2

	and.w	d7,d0		; S and P					 4
f2op_00:
	not.w	d6		; D' <- 0
	and.w	d6,(a1)
	not.w	d6
	bra	f2_drt		; *%&$@!




	and.w	d7,d0		; S and P					 4
mode_01:
	and.w	d0,(a1)		; D' <- S and D   				12
	jmp	(a3)		;						 8

	ds.w	1

	and.w	d7,d0		; S and P					 4
f1op_01:
	not.w	d6
	or.w	d6,d0
	not.w	d6
	and.w	d0,(a1)
	jmp	(a3)

	ds.w	1

	and.w	d7,d0		; S and P					 4
f2op_01:
	not.w	d6
	or.w	d6,d0
	not.w	d6
	and.w	d0,(a1)
	bra	f2_rtn



	and.w	d7,d0		; S and P					 4
mode_02:
	not.w	(a1)		; D' <- S and [not D]				12
	and.w	d0,(a1)		; 		   				12
	jmp	(a3)		;						 8

	and.w	d7,d0		; S and P					 4
f1op_02:
	not.w	d0
	and.w	d6,d0	
	or.w	d0,(a1)		; D' <- not {[not S] or D}
	eor.w	d6,(a1)
	jmp	(a3)

	ds.w	1

	and.w	d7,d0		; S and P					 4
f2op_02:
	not.w	d0
	and.w	d6,d0	
	or.w	d0,(a1)		; D' <- not {[not S] or D}
	eor.w	d6,(a1)
	bra	f2_rtn



	and.w	d7,d0		; S and P					 4
mode_03:
	move.w	d0,(a1)		; D' <- S   					 8
	jmp	(a3)		; 						 8

	ds.w	1

	and.w	d7,d0		; S and P					 4
f1op_03:
	move.w	(a1),d1		; D' <- S
	eor.w	d1,d0
	and.w	d6,d0
	eor.w	d1,d0
	move.w	d0,(a1)
	jmp	(a3)

	and.w	d7,d0		; S and P					 4
f2op_03:
	move.w	(a1),d1		; D' <- S
	eor.w	d1,d0
	and.w	d6,d0
	eor.w	d1,d0
	move.w	d0,(a1)
	bra	f2_rtn


	and.w	d7,d0		; S and P					 4
mode_04:
	not.w	d0		; D' <- [not S] and D				 4
	and.w	d0,(a1)		;		   				12
	jmp	(a3)		;						 8

	and.w	d7,d0		; S and P					 4
f1op_04:
	and.w	d6,d0
	not.w	d0
	and.w	d0,(a1)
	jmp	(a3)

	ds.w	2

	and.w	d7,d0		; S and P					 4
f2op_04:
	and.w	d6,d0
	not.w	d0
	and.w	d0,(a1)
	bra	f2_rtn




mode_05:			* dummy label. Never called!!!!
	

	and.w	d7,d0		; S and P					 4
mode_06:
	eor.w	d0,(a1)		; D' <- S xor D   				12
	jmp	(a3)		; 						 8

	ds.w	1

	and.w	d7,d0		; S and P					 4
f1op_06:
	and.w	d6,d0
	eor.w	d0,(a1)
	jmp	(a3)

	ds.w	3

	and.w	d7,d0		; S and P					 4
f2op_06:
	and.w	d6,d0
	eor.w	d0,(a1)
	bra	f2_rtn



	and.w	d7,d0		; S and P					 4
mode_07:
	or.w	d0,(a1)		; D' <- S or D   				12
	jmp	(a3)		;						 8

	ds.w	1

	and.w	d7,d0		; S and P					 4
f1op_07:
	and.w	d6,d0
	or.w	d0,(a1)
	jmp	(a3)

	ds.w	3

	and.w	d7,d0		; S and P					 4
f2op_07:
	and.w	d6,d0
	or.w	d0,(a1)
	bra	f2_rtn


	and.w	d7,d0		; S and P					 4
mode_08:
	or.w	d0,(a1)		; D' <- not [S or D]				12
	not.w	(a1)		;			  			12
	jmp	(a3)		;						 8

	and.w	d7,d0		; S and P					 4
f1op_08:
	and.w	d6,d0
	or.w	d0,(a1)
	eor.w	d6,(a1)
	jmp	(a3)

	ds.w	2

	and.w	d7,d0		; S and P					 4
f2op_08:
	and.w	d6,d0
	or.w	d0,(a1)
	eor.w	d6,(a1)
	bra	f2_rtn


	and.w	d7,d0		; S and P					 4
mode_09:
	not.w	d0		; D' <- [not S] xor D				 4
	eor.w	d0,(a1)		;						12
	jmp	(a3)		; 						 8

	and.w	d7,d0		; S and P					 4
f1op_09:
	and.w	d6,d0
	eor.w	d0,(a1)
	eor.w	d6,(a1)
	jmp	(a3)

	ds.w	2

	and.w	d7,d0		; S and P					 4
f2op_09:
	and.w	d6,d0
	eor.w	d0,(a1)
	eor.w	d6,(a1)
	bra	f2_rtn


	and.w	d7,d0		; S and P					 4
mode_10:
	not.w	(a1)		; D' <- not D					12
	jmp	(a3)		; 						 8

	ds.w	1

	and.w	d7,d0		; S and P					 4
f1op_10:
	eor.w	d6,(a1)
	jmp	(a3)

	ds.w	4

	and.w	d7,d0		; S and P					 4
f2op_10:
	eor.w	d6,(a1)
	bra	f2_drt		; %$#@*!



	and.w	d7,d0		; S and P					 4
mode_11:
	not.w	(a1)		; D' <- S or [not D]				12
	or.w	d0,(a1)		;		   				12
	jmp	(a3)		; 						 8

	and.w	d7,d0		; S and P					 4
f1op_11:
	eor.w	d6,(a1)
	and.w	d6,d0
	or.w	d0,(a1)
	jmp	(a3)

	ds.w	2

	and.w	d7,d0		; S and P					 4
f2op_11:
	eor.w	d6,(a1)
	and.w	d6,d0
	or.w	d0,(a1)
	bra	f2_rtn



	and.w	d7,d0		; S and P					 4
mode_12:
	not.w	d0		; D' <- not S					 4
	move.w	d0,(a1)		; 	   					 8
	jmp	(a3)		;						 8

	and.w	d7,d0		; S and P					 4
f1op_12:
	or.w	d6,(a1)
	and.w	d6,d0
	eor.w	d0,(a1)
	jmp	(a3)

	ds.w	2

	and.w	d7,d0		; S and P					 4
f2op_12:
	or.w	d6,(a1)
	and.w	d6,d0
	eor.w	d0,(a1)
	bra	f2_rtn


	and.w	d7,d0		; S and P					 4
mode_13:
	not.w	d0		; D' <- [not S] or D				12
	or.w	d0,(a1)		; 						12
	jmp	(a3)		;						 8

	and.w	d7,d0		; S and P					 4
f1op_13:
	not.w	d0
	and.w	d6,d0
	or.w	d0,(a1)
	jmp	(a3)

	ds.w	2

	and.w	d7,d0		; S and P					 4
f2op_13:
	not.w	d0
	and.w	d6,d0
	or.w	d0,(a1)
	bra	f2_rtn


	and.w	d7,d0		; S and P					 4
mode_14:
	and.w	d0,(a1)		; D' <- not [S and D]				12
	not.w	(a1)		; 						12
	jmp	(a3)		;						 8

	and.w	d7,d0		; S and P					 4
f1op_14:
	not.w	d0		; D' <- [not S] and [not D]
	eor.w	d6,(a1)
	and.w	d6,d0
	or.w	d0,(a1)
	jmp	(a3)

	ds.w	1

	and.w	d7,d0		; S and P					 4
f2op_14:
	not.w	d0		; D' <- [not S] and [not D]
	eor.w	d6,(a1)
	and.w	d6,d0
	or.w	d0,(a1)
	bra	f2_rtn



	and.w	d7,d0		; S and P					 4
mode_15:
	move.w	#$FFFF,(a1)	; D' <- S=1   					12
	jmp	(a3)		; 						 8

	and.w	d7,d0		; S and P					 4
f1op_15:
	or.w	d6,(a1)
	jmp	(a3)

	ds.w	4

	and.w	d7,d0		; S and P					 4
f2op_15:
	or.w	d6,(a1)
	bra	f2_drt		; %$#@*!



	end
