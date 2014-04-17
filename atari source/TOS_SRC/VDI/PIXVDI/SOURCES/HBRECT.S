*****************************  hbrect.s  ********************************
*
* $Revision: 3.2 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/hbrect.s,v $
* =======================================================================
* $Author: lozben $	$Date: 91/02/13 18:22:42 $     $Locker:  $
* =======================================================================
*
* $Log:	hbrect.s,v $
* Revision 3.2  91/02/13  18:22:42  lozben
* Adjusted the spelling of some of the linea equates to correspond
* the ones  in the lineaequ.s file.
* 
* Revision 3.1  91/01/31  16:38:40  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.0  91/01/03  15:11:01  lozben
* New generation VDI
* 
* Revision 2.3  90/02/23  18:20:53  lozben
* We now use _FG_B_PLANES as our color index instead of _FG_BP_{0-7}.
* 
* Revision 2.2  89/02/27  17:45:17  lozben
* *** initial revision ***
* 
*************************************************************************


.include	"lineaequ.s"
.include 	"vdiincld.s"

	.globl	hb_rect

*  offsets into the BLASTER register block for the new blit ST
*
*  note:  base address = BLASTER+B_OFF
*
*	because the SKEW register may be accessed via an
*	"address register indirect" instruction rather than an
*	"address register indirect with displacement" instruction,
*	4 cycles are saved per access
*	

B_OFF		equ	 60		; offset to reference register

B_PATTERN	equ	-60 		; pattern register file
B_S_NXWD	equ	-28 		; offset to next src word
B_S_WRAP	equ	-26 		; wrap from end of one src line to next
B_S_ADDR	equ	-24 		; initial src address
B_F1_MSK	equ	-20 		; 1st fringe mask	0:old 1:new
B_CT_MSK	equ	-18 		; center mask		0:old 1:new
B_F2_MSK	equ	-16 		; 2nd fringe mask	0:old 1:new
B_D_NXWD	equ	-14 		; offset to next dst word
B_D_WRAP	equ	-12 		; wrap from end of one dst line to next
B_D_ADDR	equ	-10 		; initial dst address
B_D_SPAN	equ	-06 		; span in words of dst block
B_HEIGHT	equ	-04 		; pixel height of block
B_LOGOP		equ	-02 		; ctrl word: src^pat combo & logic op #
B_SKEW		equ	 00		; ctrl word: flags, pat index & skew


BF_PAT		equ  	08		; combo flag: 0:all ones  1:pattern
BF_SRC		equ  	09		; combo flag: 0:all ones  1:source
BM_PAT		equ  	$0100		; combo mask: 0:all ones  1:pattern
BM_SRC		equ  	$0200		; combo mask: 0:all ones  1:source
                     
                     
BF_GO		equ  	15		; execution flag         0:false 1:true
BF_HOG		equ  	14		; hog dma flag		 0:false 1:true
BF_SM		equ  	13		; smudge flag		 0:false 1:true
BF_PF		equ  	07		; pre-fetch flag  	 0:false 1:true
BF_FQ		equ  	06		; flush queue flag 	 0:false 1:true
BM_GO		equ  	$8000		; execution mask	
BM_HOG		equ  	$4000		; hog dma mask
BM_SM		equ  	$2000		; smudge mask
BM_PF		equ  	$0080		; pre-fetch mask
BM_FQ		equ  	$0040		; flush queue mask


 	.text

*	BLASTER based rectangle fill
*
* in:
*	d0	word containing Xmin
*	d1	span -1
*	d2	scratch
*	d3	scratch
*	d4	left mask
*	d5	Ymin
*	d6	right mask
*	d7	Ymax
*
*	a2	pointer to LineA variables

hb_rect:

	exg	d1,d2			; d2 <- span - 1, d1 becomes scratch
	lea	BLASTER+B_OFF,a5	; a5 -> bit blt reference register
	clr.w	B_S_NXWD(a5)		; proceed from left to right

	lea	B_F1_MSK(a5),a4
	move.w	 d4,(a4)+		; B_F1_MSK <- left fringe
	move.w	#-1,(a4)+		; B_CT_MSK <- center fringe
	move.w	 d6,(a4)+		; B_F2_MSK <- right fringe

	move.w	d5,d4			; d4 <- initial Y
	sub.w	d5,d7			; d7 <- height -1
	addq.w	#1,d7			; d7 <- height

	move.l	_v_bas_ad,a1		; a1 -> start of dst form
	muls	_bytes_lin(a2),d5	; d5 <- offset to 1st row of dst
	add.l	d5,a1			; a1 -> 1st row of dst rectangle

	move.w	_v_planes(a2),d3	; d3 <- planes
	move.w	d3,d6
	subq.w	#1,d6			; d6 <- dbra plane counter

	add.w	d3,d3			; d3 <- offset between words in plane
	move.w	d3,(a4)+		; load B_D_NXWD

	muls	d3,d0			; d0 <- offset to word containing _X1
	add.l	d0,a1			; a1 -> 1st word of dst rectangle

	move.w	_v_lin_wr(a2),d2	; d2 <- bytes per line
	mulu	d1,d3			; d3 <- (SPAN-1) * NXWD
	sub.w	d3,d2			; d2 <- dst wrap
	move.w	d2,(a4)+		; load B_D_WRAP

	addq.w	#1,d1			; d1 <- span
	move.w	d1,B_D_SPAN(a5)

	lea	op_table,a4		; a4 -> 1st logic op table
	move.w	_WRT_MODE(a2),d0	; d0 <- writing mode (0-3)
	add.w	d0,d0
	add.w	d0,d0			; d0 <- offset to writing mode table
	add.w	d0,a4			; a4 -> writing mode table

	move.l	_patptr(a2),a0		; a0 -> start of pattern
	move.w	_patmsk(a2),d0		; d0 <- pattern index mask

	moveq.l	#15,d3			; d3 <- F mask, hi limit, & dbra count

	cmp.w	d3,d0			; mask > 15 is degenerate case
	bhi	rf_dgen

	move.w	#$808B,d1		; a legitimate mask (0,1,3,7,15) ?
	btst.l	d0,d1
	beq	rf_dgen			; else, handle degenerate case

	and.w	d3,d4			; d4[03:00] <- initial pattern index
	lsl.w	#8,d4			; d4[11:08] <- initial pattern index
	or.w	#BM_GO,d4		; d4 <- SKEW word

	tst.w	_multifill(a2)		; handle multi-plane fill seperately
	bne	rf_multi

        move.l  _FG_B_PLANES(a2),d5	; d5 <- color index

*
*  CASE I:  Standard monoplane patterns ( mask: 0, 1, 3, 7, 15 )
*	    Load the pattern registers once.

	clr.w	d1			; d1 <- initial pattern index
	add.w	d0,d0			; d0 <- pattern offset mask

	lea	B_PATTERN(a5),a2	; a2 -> first pattern register

s1_loop:

	move.w	0(a0,d1.w),(a2)+	; d1 <- load the pattern word
	addq.w	#2,d1			; d1 <- offset to next pattern word
	and.w	d0,d1			; d1 <- clamped to pattern range
	dbra	d3,s1_loop

	moveq.l	#2,d1			; d1 <- logic op offset mask

s1b_loop:

	move.l	a1,B_D_ADDR(a5)
	move.w	d7,B_HEIGHT(a5)

	ror.l	d5			; what color is this plane ?
	scs	d0
	and.w	d1,d0			; d0 <- logic op offset:  0=>0  1=>2
	move.w	0(a4,d0.w),B_LOGOP(a5)  ; load the logic op


*******************************************************************************
	move.w	d4,(a5)			; start the BLASTER
*******************************************************************************

s1b_sync:

	tas	(a5)			; restart blt
	nop
	bmi	s1b_sync

s1b_cont:

	addq.l	#2,a1			; a1 -> next plane
	dbra	d6,s1b_loop

.ifeq	P68030

	movec.l	cacr,d6			; d2 <- cache control register
	bset.l	#11,d6			; set "Clr DATA Cache" bit
	movec.l	d6,cacr			; clear the data cache
.endc
	rts


*
*  CASE II: Standard multiplane pattern (16 words per plane)
*	    Load the pattern registers before each plane

rf_multi:

	cmp.w	#15,d0			; if the pattern isn't 16 words long,
	bne	rf_dgen			; then it's a degenerate case

	moveq.l	#2,d1			; d1 <- logic op offset mask

smb_loop:

	lea	B_PATTERN(a5),a2	; a2 -> first pattern register
	move.l	(a0)+,(a2)+		; load the pattern registers, fast.
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+		; a0 -> start of next pattern plane

	move.l	a1,B_D_ADDR(a5)
	move.w	d7,B_HEIGHT(a5)

	ror.l	d5			; what color is this plane ?
	scs	d0
	and.w	d1,d0			; d0 <- logic op offset: 0=>0  1=>2
	move.w	0(a4,d0.w),B_LOGOP(a5)	; load the logic op


*******************************************************************************
	move.w	d4,(a5)			; start the BLASTER
*******************************************************************************

smb_sync:

	tas	(a5)			; restart blt
	nop
	bmi	smb_sync

smb_cont:

	addq.l	#2,a1			; a1 -> next dst plane
	dbra	d6,smb_loop

.ifeq	P68030

	movec.l	cacr,d6			; d2 <- cache control register
	bset.l	#11,d6			; set "Clr DATA Cache" bit
	movec.l	d6,cacr			; clear the data cache
.endc
	rts



*
*  CASE III.	All degenerate cases arrive here. Rectangles are filled 
*		line by line and plane by plane.

rf_dgen:

	and.w	d0,d4	        	 ; d4 <- initial pattern index
	add.w	d0,d0			 ; d0 <- pattern offset mask
	add.w	d4,d4			 ; d4 <- initial pattern offset
	subq.w	#1,d7			 ; d7 <- height-1 (dbra counter)
	move.w	d7,a3			 ; a3 <- copy of line counter
	move.w	#BM_GO,d1		 ; d1 <- SKEW template

	tst.w	_multifill(a2)
	sne	d3			 ; d3 <- either xx00 or xxFF
	and.w	#32,d3			 ; d3 <- offset to next pattern plane
	lea	B_PATTERN(a5),a2	 ; a2 -> first pattern register

sd1_loop:

	move.l	a1,B_D_ADDR(a5)		 ; start at top of this plane

	ror.l	d5			; what color is this plane ?
	scs	d2
	and.w	#2,d2			 ; d2 <- logic op offset:  0=>0  1=>2
	move.w	0(a4,d2.w),B_LOGOP(a5)	 ; load the logic op for this plane


sd2_loop:

	move.w	#1,B_HEIGHT(a5)		 ; do one line per blt

	move.w	0(a0,d4.w),(a2)		 ; load the current pattern
	addq.w	#2,d4			 ; d4 <- offset to next pattern word
	cmp.w	d0,d4			 ; if greater than mask, reset
	ble	sd2_blast		 ; (that's how matt did it)

	clr.w	d4			 ; d4 <- offset to first word

sd2_blast:

*******************************************************************************
	move.w	d1,(a5)			 ; start the BLASTER
*******************************************************************************

sd2_sync:

	tas	(a5)			 ; restart the blt
	nop
	bmi	sd2_sync

sd2_cont:

	dbra	d7,sd2_loop		 ; do next line in this plane


	move.w	a3,d7			 ; d7 <- reset line counter
	add.w	d3,a0			 ; a0 -> start of next pattern plane
	addq.l	#2,a1			 ; a1 -> next plane
	dbra	d6,sd1_loop		 ; do next plane

.ifeq	P68030

	movec.l	cacr,d6			; d2 <- cache control register
	bset.l	#11,d6			; set "Clr DATA Cache" bit
	movec.l	d6,cacr			; clear the data cache
.endc
	rts

	.end
