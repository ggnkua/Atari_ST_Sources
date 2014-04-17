*********************************  xfrmform.s  ********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/xfrmform.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/01/28 18:07:18 $     $Locker:  $
* =============================================================================
*
* $Log:	xfrmform.s,v $
* Revision 3.1  91/01/28  18:07:18  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.0  91/01/03  15:23:38  lozben
* New generation VDI
* 
* Revision 2.3  90/07/17  15:07:10  lozben
* in_place() now skips the one plane mode.
* 
* Revision 2.2  90/07/13  15:36:26  lozben
* Fixed in_place() and out_of_place() to handle higher rezes.
* 
* Revision 2.1  89/02/21  17:29:35  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************

	.include	"lineaequ.s"


	.globl		_TRAN_FM

*******************************************************************************
*
* name:	_r_trnfm
*
* purpose:
*
*	transform a device independent memory form into a device dependent form
*	or vice versa. device independent forms are composed of planes of
*	contiguous memory while device dependent forms are constructed from
*	shuffled planes where corresponding words from sequential planes are
*	contiguous.
*
*
*		device independent		 device dependent
*
*		P0W0 P0W1 ... P0Wn		P0W0 P1W0 ... PmW0
*		P1W0 P1W1 ... P1Wn		P0W1 P1W1 ... PmW1
*		      .				      .
*		      .		      <---->	      .
*		      .				      .
*		PmW0 PmW1 ... PmWn		P0Wn P1Wn ... PmWn
*
*
*	transformation can be performed in place or the transformation may
*	be created at another location. note that inplace transformations
*	take considerably longer to perform.
*
*	source and destination MEMORY FORM DEFINITION BLOCKS are input.
*	the format of the destination is opposite that of the provided source.
*
*	it is assumed that the destination form is large enough to receive
*	the transformed source.
*
*	
* author:	jim eisenstein
*
* parameters
*
*  in:
*
*	_CONTRL		address of control array (word wide)
*
*	control(07-08)	address of source MFDB
*	control(09-10)	address of destination MFDB




MF_BAS_AD	equ	00	; memory form base address (0: physical device)
MF_WD_PIX	equ	04	; form width in pixels ( form width in words /16)
MF_HT_PIX	equ	06	; form height in pixels
MF_WD_WRD	equ	08	; form width in words
MF_FORMAT	equ	10	; form format flag (0:device specific 1:standard)
MF_PLANES	equ	12	; number of memory planes

*	CONTRL ARRAY OFFSETS

C_MFDB_S	equ	14	; pointer to source MFDB
C_MFDB_D	equ	18	; pointer to destination MFDB

.page


_TRAN_FM:

	movem.l	d0-d4/a0-a2,-(sp)

	move.l  _lineAVar,a0		; a0 -> linea var struct
	move.l	_CONTRL(a0),a2		; a2 -> control array
	move.l	C_MFDB_S(a2),a0		; a0 -> source MFDB
	move.l	C_MFDB_D(a2),a1		; a1 -> destination MFDB

	moveq.l	#0,d0			; clear the high word
	move.w	MF_PLANES(a0),d0	; d0 <- # planes
	move.w	d0,d3			; d3 <- # planes
	move.w	MF_HT_PIX(a0),d1	; d1 <- # lines
	move.w	MF_WD_WRD(a0),d2	; d2 <- planar word wrap

	tst.w	MF_FORMAT(a0)
	bne	di_2_dd


*  convert from device dependent to device independent

dd_2_di:

	move.w	#1,MF_FORMAT(a1)	; device independent format flag (dest)

	mulu	d2,d1			; d1 <- length of DI plane (in words)

*					; d0 <- members per group (# of planes)
	bra	do_it			; d1 <- number of groups  (length of plane)



*  convert from device independent to device dependent

di_2_dd:

	clr.w	MF_FORMAT(a1)		; device dependent format flag (dest)

	mulu	d2,d1			; d1 <- length of DI plane	

*					; d0 <- members per group (length of DI plane)
	exg	d0,d1			; d1 <- number of groups  (# of planes)


do_it:

	move.l	MF_BAS_AD(a0),a0	; a0 -> start of source
	move.l	MF_BAS_AD(a1),a1	; a1 -> start of destination

	cmp.l	a0,a1
	beq	xfrm_in_place

	bsr	out_of_place
	bra	quit


xfrm_in_place:

	cmp.w	#1,d3			; see if we have > 1 plane
	beq	quit			; do nothing for one plane
	bsr	in_place

quit:	movem.l	(sp)+,d0-d4/a0-a2
	rts


*  do that crazy in-place shuffle
*
*  in:
*	a0.l	points to start of form
*
*	d0.w	number of members in group
*	d1.w	number of groups
*
*
*			DD -> DI		       DI -> DD
*
*	members:  length of plane in words	     # of planes 
*	groups:	       # of planes 	        length of plane in words


in_place:

	dbra	d1,entry02		; iteration count <- number of units - 1
	rts				; if number was 0, return now
	
loop02:
	clr.l	d2			; initialize count accumulator
	move	d1,d4			; initialize iteration counter
	bra	entry01

loop01:
	add.l	d0,a0			; a0 <- a1 + (2*d0) + 2
	lea	2(a0,d0.l),a0		; a0 -> element to be repositioned
	move.w	(a0),d7			; save element in d7

	move.l	a0,a1			; a1 -> source in transfer
	move.l	a0,a2			; a2 -> destination in transfer
	add.l	d0,d2			; d2 <- length of transfer
	move.l	d2,d3			; d3 <- loop counter
	bra	entry00

loop00:
	move.l	a1,a2
	move.w	-(a1),(a2)		; move word to the right

entry00:
	subq.l	#1,d3
	bge	loop00
	move.w	d7,(a1)			; store target element to new home

entry01:
	dbra	d4,loop01
	move.l	a2,a0			; a0 -> start of next cycle

entry02:
	dbra	d0,loop02		; decrease the width by 1. quit on no width
	rts



*  make that boring out-of-place rearrangement
*
*
*  in:
*
*	a0.l	start of source block
*	a1.l	start of destination block
*
*	d0.w	number of members in group  (destination)
*	d1.w	number of groups	    (destination)

	


out_of_place:
	move.l	d1,d4			; d4 <- pass counter
	add.l	d1,d1			; d0 <- offset to next member word (in bytes)
	bra	entry11

loop11:
	move.l	a1,a2			; a2 <- working destination pointer
	move.l	d0,d3			; d3 <- repeat counter
	bra	entry10

loop10:
	move.w	(a0)+,(a2)		; destination <- source. advance source ptr
	add.l	d1,a2			; advance destination ptr

entry10:
	subq.l	#1,d3
	bge	loop10
	lea	2(a1),a1		; start another pass

entry11:
	subq.l	#1,d4
	bge	loop11
	rts


	end
