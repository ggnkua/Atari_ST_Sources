*********************************  sbvline.s  *********************************
*
* $Revision: 3.2 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbvline.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/02/13 11:16:18 $     $Locker:  $
* =============================================================================
*
* $Log:	sbvline.s,v $
* Revision 3.2  91/02/13  11:16:18  lozben
* Entered the statement ".globl	sb_vline".
* 
* Revision 3.1  91/01/29  11:57:19  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.0  91/01/03  15:18:54  lozben
* New generation VDI
* 
* Revision 2.2  89/05/16  16:00:27  lozben
* Fixed sbvline to work in 8 planes.
* 
* Revision 2.1  89/02/21  17:28:05  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************

.include	"lineaequ.s"

MAX_PLANES	equ	 8
FRAG_LEN	equ	MAX_PLANES*4+4


	.globl	_v_bas_ad
	.globl	pixfrag
	.globl	sb_vline

*	Soft Vertical Line Code
*
*  in:
*	d4	X
*	d5	Y1
*	d6	X
*	d7	Y2
*
*	a4	pointer to LineA variable base


sb_vline:	lea	-FRAG_LEN(sp),sp  ; sp -> pixel fragment frame
		move.w	_v_planes(a4),d3  ; d3 <- number of planes

		cmp.w	#MAX_PLANES,d3	; too many planes for the buffer ?
		bhi	sv_quit		; if so, end prematurely

		cmp.w	_WRT_MODE(a4),d0  ; don't build fragment for XOR mode
		beq	sv_nofrag

		move.l	sp,a2		; a2 -> ram for pixel fragment code
		bsr	pixfrag		 

sv_nofrag:	move.w	_v_planes(a4),d0
		add.w	d0,d0		; d0 <- 2 * planes

		move.l	_v_bas_ad,a5	; a5 -> start of destination form
		asr.w	#4,d6		; d6 <- word containing X
		muls	d0,d6		; d6 <- offset to (X,0)
		add.l	d6,a5		; a5 -> dst (X,0)

		move.w	_bytes_lin(a4),d1
		move.w	d1,d6
		muls	d5,d6		; d6 <- offset to (0,Y1)
		add.l	d6,a5		; a5 -> dst (X,Y1)

		move.w	_v_lin_wr(a4),d1  ; d1 <- offset to next line down

		sub.w	d5,d7		; d7 <- dY: Y2-Y1
		bge	sv_wrap		; dY<0  => plot from bottom up

		neg.w	d1		; d1 <- offset to next line up
		neg.w	d7		; d7 <- |dY|

sv_wrap:	move.w	d1,a0		; a0 <- dst wrap when pixel is skipped
		sub.w	d0,d1		; d1 <- dst wrap - (2 * planes)
		move.w	d1,a1		; a1 <- dst wrap when pixel is plotted

		moveq.l	#$0F,d5		; d5 <- mod16 mask

		not.w	d4		; bit numbers ascend from right to left
		and.w	d5,d4		; d4 <- bit number for X mod16
		clr.w	d1
		bset.l	d4,d1		; d1 <- "OR" mask for X mod16

		move.w	_WRT_MODE(a4),d6  ; d6 <- writing mode code
		lsl.w	#2,d6

		cmp.w	#8,d6		; if XOR mode ...
		bne	sv_nxtmask
		tst.w	_LSTLIN(a4)	; and not last line ...
		bne	sv_nxtmask

		subq.w	#1,d7		; don't plot last point  (DRI kludge)

sv_nxtmask:	move.w	_LN_MASK(a4),d2	; d2 <- line style mask for this line
		move.w	d2,d3		; d3 <- line style mask for next line
		move.w	d7,d4		; d4 <- dbra pixel counter
		addq.w	#1,d4		; d4 <- line length
		and.w	d5,d4		; d4 <- alignment value: LENGTH mod16
		rol.w	d4,d3		; d3 <- line style mask for next line
		move.w	d3,_LN_MASK(a4)	; store line style mask for next line

		move.l	sv_tbl(pc,d6.w),d6 ; d6[15:00] <-  return thread offset
		lea	sv_tbl(pc,d6.w),a3 ; a3 <- pixel fragment return thread
		move.l	a3,a4
		sub.w	d0,a4		   ; a4 <- thread into pixel tower code

		move.w	d1,d0		   ; d0 <-  "OR" mask for X mod16
		not.w	d0		   ; d0 <- "AND" mask for X mod16

		swap	d6		   ; d6 <- offset to writing mode code
		jmp	sv_tbl(pc,d6.w)    ; leap into pixel plotter loop


sv_quit:	lea	FRAG_LEN(sp),sp
		rts



*      Offset table of Writing Mode Code entry points.

sv_tbl:		dc.w	    wm0v-sv_tbl		; replace
		dc.w	wm0v_nxt-sv_tbl
		dc.w	    wm1v-sv_tbl		; transparent
		dc.w	wm1v_nxt-sv_tbl
		dc.w	    wm2v-sv_tbl		; XOR
		dc.w	wm2v_nxt-sv_tbl
		dc.w	    wm3v-sv_tbl		; reverse transparent
		dc.w	wm1v_nxt-sv_tbl


*	Vertical Line Fragments
*
*  in:
*	d0	"AND" mask
*	d1	"OR" mask
*	d2	line style mask
*	d7	line height -1
*
*	a0	destination wrap if pixel is skipped
*	a1	destination wrap if pixel is plotted
*	a2	thread to pixel fragment
*	a3	thread back from pixel fragment
*	a4	thread into pixel tower
*	a5	points to destination


wm0v:		rol.w	#1,d2		; cy: next style bit		      8
		bcc	wm0v_clr	; clear pixel if style bit is 0	   10/8

		jmp	(a2)		; a2 -> ram based set pixel fragment  8

wm0v_clr:	jmp	(a4)		; a4 -> entry into clear pixel tower  8

		and.w	d0,(a5)+	; 8 planes			     12
		and.w	d0,(a5)+	;				     12
		and.w	d0,(a5)+	;				     12
		and.w	d0,(a5)+	;				     12
		and.w	d0,(a5)+	; 4 planes			     12
		and.w	d0,(a5)+	;				     12
		and.w	d0,(a5)+	; 2 planes			     12
		and.w	d0,(a5)+	; 1 plane			     12

wm0v_nxt:	add.w	a1,a5		; a5 -> next vertical word	      8
		dbra	d7,wm0v		; plot next pixel		  14/10

		bra	sv_quit




wm3v:		not.w	d2		; invert the style mask		      4

wm1v:		rol.w	#1,d2		; cy: next style bit		      8
		bcc	wm1v_skp	; skip if style bit is 0	   10/8

		jmp	(a2)		; a2 -> ram based set pixel fragment  8

wm1v_nxt:	add.w	a1,a5		; a5 -> next vertical word	      8
		dbra	d7,wm1v		; plot next pixel		  14/10

		bra	sv_quit


wm1v_skp:	add.w	a0,a5		; a5 -> next vertical word	      8
		dbra	d7,wm1v		; plot next pixel		  14/10

		bra	sv_quit



wm2v:		rol.w	#1,d2		; cy: next style bit		      8
		bcc	wm2v_skp	; skip if style bit is 0	   10/8

		jmp	(a4)		; a4 -> entry into xor pixel tower    8

		eor.w	d1,(a5)+	; 8 planes			     12
		eor.w	d1,(a5)+	;				     12
		eor.w	d1,(a5)+	;				     12
		eor.w	d1,(a5)+	;				     12
		eor.w	d1,(a5)+	; 4 planes			     12
		eor.w	d1,(a5)+	;				     12
		eor.w	d1,(a5)+	; 2 planes			     12
		eor.w	d1,(a5)+	; 1 plane			     12

wm2v_nxt:	add.w	a1,a5		; a5 -> next vertical word	      8
		dbra	d7,wm2v		; plot next pixel		  14/10

		bra	sv_quit


wm2v_skp:	add.w	a0,a5		; a5 -> next vertical word	      8
		dbra	d7,wm2v		; plot next pixel		  14/10

		bra	sv_quit
