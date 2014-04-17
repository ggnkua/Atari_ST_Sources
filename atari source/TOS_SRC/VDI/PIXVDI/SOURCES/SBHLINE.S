*********************************  sbhline.s  *********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbhline.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/01/30 15:06:09 $     $Locker:  $
* =============================================================================
*
* $Log:	sbhline.s,v $
* Revision 3.1  91/01/30  15:06:09  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.0  91/01/03  15:17:13  lozben
* New generation VDI
* 
* Revision 2.2  89/05/16  13:04:11  lozben
* Fixed sb_hline() and sb_rect() to work in the 8 plane mode.
* 
* Revision 2.1  89/02/21  17:26:06  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  87/11/20  15:17:18  lozben
* Initial revision
* 
*******************************************************************************


.include	"lineaequ.s"


		globl	sb_hline,sb_rect,_v_bas_ad


*	SOFT VERSION OF HORIZONTAL LINE ROUTINE
*
* in:
*	d0	offset between pattern words
*	d1	word containing X1
*	d2	span-1 (words)
*	d3	mod 16 mask
*	d4	lf fringe mask
*	d5	Y1
*	d6	rt fringe mask
*
*	a0	points to 1st pattern word
*	a4	points to line A variables base address  ( _v_planes )


sb_hline:

	move.l	_v_bas_ad,a1
	muls	_bytes_lin(a4),d5		; d5 <- offset to (0,Y)
	add.l	d5,a1	
	move.w	d0,a2			; a2 <- offset between pattern words
	move.w	_v_planes(a4),d7
	move.w	d7,d0			; d0 <- number of planes
	add.w	d0,d0			; d0 <- offset between dst words
	muls	d0,d1			; d1 <- offset to (X,0)
	add.l	d1,a1			; a1 -> start of destination

	subq.w	#1,d7			; d7 <- planes-1

	move.l	d2,a3			; a3 <- span - 1 (words)
	move.l	_FG_B_PLANES(a4),d2	; d2 <- color value

	move.w	_WRT_MODE(a4),d1

	add.w	d1,d1
	lea	wrt_tbl(pc,d1.w),a5
	add.w	(a5),a5
	jmp	(a5)



wrt_tbl:

	dc.w	rep_mode-*
	dc.w	xpr_mode-*
	dc.w	xor_mode-*
	dc.w	rxp_mode-*




*	SOFT VERSION OF RECTANGLE FILL ROUTINE
*
* in:
*	d0	word containing Xmin
*	d1	scratch
*	d2	span -1
*	d3	scratch
*	d4	left fringe mask
*	d5	Ymin
*	d6	right fringe mask
*	d7	Ymax
*
*	a2	pointer to LineA variables

sb_rect:

	link	a6,#-20			; a6 -> local variable space

	move.w	_WRT_MODE(a2),d1
	add.w	d1,d1
	lea	wrt_tbl(pc,d1.w),a5
	add.w	(a5),a5			; a5 -> writing mode subroutine

	sub.w	d5,d7			; d7 <- vertical height -1

	move.l	_v_bas_ad,a1
	move.w	_bytes_lin(a2),d1
	muls	d5,d1			; d2 <- offset to (0,Ymin)
	add.l	d1,a1			; a1 -> (0,Ymin)

	move.w	_v_planes(a2),d1
	muls	d1,d0
	add.l	d0,d0			; d0 <- offset to (Xmin,0)
	add.l	d0,a1			; a1 -> (Xmin,Ymin)

	move.w	d1,d0
	add.w	d0,d0			; d0 <- offset between dst words

	subq.w	#1,d1			; d2 <- planes - 1
	move.w	d1,-(a6)		; save plane counter
	move.w	d2,-(a6)		; save span counter

	move.w	d2,a3			; a3 <- span - 1
	move.l	_FG_B_PLANES(a2),d2		; a2 <- color index
	move.l	d2,-(a6)		; save color index

	move.w	_v_lin_wr(a2),d3
	sub.w	d0,d3
	move.w	d3,-(a6)		; save line wrap value

	move.w	_patmsk(a2),d3
	and.w	d3,d5			; d5 <- initial pattern index
	add.w	d5,d5			; d5 <- initial pattern offset
	move.w	d5,-(a6)		; save initial pattern offset
	add.w	d3,d3			; d3 <- maximum pattern offset
	move.w	d3,-(a6)		; save maximum pattern offset

	move.l	_patptr(a2),a0
	move.l	a0,-(a6)		; save pointer to base of pattern
	add.w	d5,a0			; a0 -> first pattern word

	move.w	d7,-(a6)		; save vertical line counter

	move.w	d1,d7			; d7 <- planes -1

	moveq.l	#0,d1
	tst.w	_multifill(a2)
	beq	r_poff

	moveq.l	#32,d1

r_poff:	move.l	d1,a2			; a2 <- offset between pattern words


* in:
*
*	d0	offset between destination words
*	d1	scratch
*	d2	color index
*	d3	scratch
*	d4	left fringe mask
*	d5	scratch
*	d6	right fringe mask
*	d7	planes-1
*
*	a0	points to 1st pattern word
*	a1	points to destination
*	a2	offset between pattern words
*	a3	span - 1
*	a4	scratch
*	a5	pointer to horizontal line subroutine
*	a6	pointer to parameter block:
*
*		+00	vertical line count -1
*		+02	pointer to pattern base
*		+06	pattern offset maximum
*		+08	current pattern offset
*		+10	line wrap (line width - 2*planes)
*		+12	pointer to bitplane color array ( _FG_BP_1 )
*		+16	span in words -1
*		+18	planes -1



r_loop:	jsr	   (a5)			; do one horizontal line
	subq.w	#1,(a6)+		; decrement line counter
	bcs	r_exit

	move.l	(a6)+,a0		; a0 -> pattern base
	move.w	(a6)+,d1		; d1 <- pattern offset maximum
	move.w	(a6),d3			; d3 <- pattern offset
	addq.w	#2,d3			; d3 <- offset to next pattern word
	cmp.w	d1,d3			; reset offset if it exceeds
	ble	r_save			; pattern index maximum

	clr.w	d3			; d3 <- initial offset

r_save:	move.w	d3,(a6)+		; save updated offset

	add.w	   d3,a0		; a0 -> next pattern word
	add.w	(a6)+,a1		; a1 -> next horizontal line
	move.l	(a6)+,d2		; d2 <- color index
	move.w	(a6)+,a3		; a3 <- span -1
	move.w	(a6)+,d7		; d7 <- planes -1

	lea	-20(a6),a6		; a6 -> bottom of parameter block
	bra	r_loop

r_exit:	lea	18(a6),a6		; a6 -> top of parameter block
	unlk	a6			; restore stack pointer
	rts




*	horizontal line writing modes
*
*	a0	points to 1st pattern word
*	a1	points to destination
*	a2	offset between pattern words
*	a3	span - 1
*	a4	scratch
*
*	d0	offset between destination words
*	d1	scratch
*	d2	color index
*	d3	scratch
*	d4	left fringe mask
*	d5	scratch
*	d6	right fringe mask
*	d7	planes-1



xor_mode:

xor_lp:	move.l	a1,a4			; a4 -> working dst pointer
	move.w	a3,d5			; d5 <- span counter
	move.w	(a0),d3			; d3 <- current pattern
	add.w	a2,a0			; a0 -> next pattern word

xor_lf:	move.w	d4,d1			; d1 <- mask
	and.w	d3,d1			; d1 <- masked pattern
	eor.w	d1,(a1)+		; set left fringe: a1 -> next bitplane
	subq.w	#1,d5
	bcs	xor_nx			; catch single word case

	subq.w	#1,d5
	bcs	xor_rf			; catch two word case

xor_md:	add.w	d0,a4			; a4 -> next word in bitplane
	eor.w	d3,(a4)			; xor pattern in
	dbra	d5,xor_md

xor_rf:	move.w	d6,d1			; d1 <- mask
	and.w	d3,d1			; d1 <- masked pattern
	add.w	d0,a4			; a4 -> next dst word
	eor.w	d1,(a4)	

xor_nx:	dbra	d7,xor_lp

	rts




rep_mode:

	not.w	d4			; invert the fringe masks
	not.w	d6

rep_lp:	move.l	a1,a4			; a4 -> working dst pointer
	move.w	a3,d5			; d5 <- span counter
	move.w	(a0),d3			; d3 <- current pattern
	add.w	a2,a0			; a0 -> next pattern word

	roxr.w	#1,d2
	bcs	re1_lf

re0_lf:	move.w	d4,d1			; d1 <- inverted mask
	and.w	d1,(a1)+		; set left fringe: a1 -> next bitplane
	subq.w	#1,d5
	bcs	re0_nx			; catch single word case

	subq.w	#1,d5
	bcs	re0_rf			; catch two word case

	clr.w	d1			; d1 <- fill value for mid-section

re0_md:	add.w	d0,a4			; a4 -> next word in bitplane
	move.w	d1,(a4)			; clear the middle
	dbra	d5,re0_md

re0_rf:	move.w	d6,d1			; d1 <- inverted mask
	add.w	d0,a4			; a4 -> next dst word
	and.w	d1,(a4)			; set right fringe

re0_nx:	dbra	d7,rep_lp

	not.w	d4			; restore the fringe masks
	not.w	d6
	rts


re1_lf:	move.w	(a4),d1			; d1 <- destination word
	eor.w	d3,d1
	and.w	d4,d1			; use inverted mask
	eor.w	d3,d1
	move.w	d1,(a1)+		; set left fringe: a1 -> next bitplane
	subq.w	#1,d5
	bcs	re1_nx			; catch single word case

	subq.w	#1,d5
	bcs	re1_rf			; catch two word case

re1_md:	add.w	d0,a4			; a4 -> next word in bitplane
	move.w	d3,(a4)
	dbra	d5,re1_md

re1_rf:	add.w	d0,a4			; a4 -> next dst word
	move.w	(a4),d1			; d1 <- destination word
	eor.w	d3,d1
	and.w	d6,d1			; use inverted mask
	eor.w	d3,d1
	move.w	d1,(a4)

re1_nx:	dbra	d7,rep_lp

	not.w	d4			; restore the fringe masks
	not.w	d6
	rts


xpr_mode:

xpr_lp:	move.l	a1,a4			; a4 -> working dst pointer
	move.w	a3,d5			; d5 <- span counter
	move.w	(a0),d3			; d3 <- current pattern
	add.w	a2,a0			; a0 -> next pattern word

	roxr.w	#1,d2			; choose procedure for this bitplane
	bcs	xpr1			; based on the current bitplane color

xpr0:	not.w	d3			; d3 <- inverted pattern
	bsr	xp0_lf			; 1 in original pattern maps to 0
	dbra	d7,xpr_lp		; 0 in original pattern is transparent
	rts

xpr1:	bsr	xp1_lf			; 1 in pattern maps to 1 in DST
	dbra	d7,xpr_lp		; 0 in pattern is transparent
	rts


rxp_mode:

rxp_lp:

	move.l	a1,a4			; a4 -> working dst pointer
	move.w	a3,d5			; d5 <- span counter
	move.w	(a0),d3			; d3 <- current pattern
	add.w	a2,a0			; a0 -> next pattern word

	roxr.w	#1,d2			; choose procedure for this bitplane
	bcs	rxp1			; based on the current bitplane color

rxp0:	bsr	xp0_lf			; 0 in pattern maps to 0 in DST
	dbra	d7,rxp_lp		; 1 in pattern is transparent
	rts

rxp1:	not.w	d3			; d3 <- inverted pattern
	bsr	xp1_lf			; 0 in original pattern maps to 1
	dbra	d7,rxp_lp		; 1 in original pattern is transparent
	rts


*  1 in pattern maps to 0 in destination
*  0 in pattern is transparent

xp0_lf:	move.w	d4,d1			; d1 <- mask
	not.w	d1			; 
	or.w	d3,d1			; d1 <- masked pattern
	and.w	d1,(a1)+		; set left fringe: a1 -> next bitplane
	dbra	d5,xp0_2t

	rts				; catch single word case

xp0_2t:	subq.w	#1,d5
	bcs	xp0_rf			; catch two word case

xp0_md:	add.w	d0,a4			; a4 -> next word in bitplane
	and.w	d3,(a4)	
	dbra	d5,xp0_md

xp0_rf:	move.w	d6,d1			; d1 <- pattern
	not.w	d1
	or.w	d3,d1			; d1 <- masked pattern
	add.w	d0,a4			; a4 -> next dst word
	and.w	d1,(a4)	

	rts


*  1 in pattern maps to 1 in destination
*  0 in pattern is transparent

xp1_lf:	move.w	d4,d1			; d1 <- mask
	and.w	d3,d1			; d1 <- masked pattern
	or.w	d1,(a1)+		; set left fringe: a1 -> next bitplane
	dbra	d5,xp1_2t

	rts				; catch single word case

xp1_2t:	subq.w	#1,d5
	bcs	xp1_rf			; catch two word case

xp1_md:	add.w	d0,a4			; a4 -> next word in bitplane
	or.w	d3,(a4)			; xor pattern in
	dbra	d5,xp1_md

xp1_rf:	move.w	d6,d1			; d1 <- pattern
	and.w	d3,d1			; d1 <- masked pattern
	add.w	d0,a4			; a4 -> next dst word
	or.w	d1,(a4)

	rts
