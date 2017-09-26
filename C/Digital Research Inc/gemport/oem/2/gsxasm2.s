*		public routines

		globl	_trap
		globl	_end_pts
		globl	_fill_line
		globl	_get_pix
		globl	_put_pix
		globl	_RECTFILL
		globl	_TRNSFONT

*		external routines.

		globl	concat
		globl	xline

*		external variables

		globl	_X1
		globl	_Y1
		globl	_X2
		globl	_Y2
		globl	_WRT_MODE
		globl	_patmsk
		globl	_patptr
		globl	_multifill
		globl	_FG_BP_1
		globl	_FG_BP_2
		globl	_FG_BP_3
		globl	_FG_BP_4
		globl	_PTSIN
		globl	_INTIN
		globl	_INTOUT
		globl	ortbl
		globl	retsav
		globl	_search_color
		globl	_seed_type
		globl	_v_bas_ad
		globl	_v_planes
		globl	_v_lin_wr
		globl	lf_tab

		globl	htab

		globl	_FBASE
		globl	_FWIDTH
		globl	_DELY
		globl	_INTIN
		globl	_PTSIN
		globl	_CLIP
		globl	_XMN_CLIP
		globl	_XMX_CLIP
		globl	_YMN_CLIP
		globl	_YMX_CLIP

****************************
*  Equates for VME10       *
****************************
vme10		.equ	0	; for selecting VME10 specific software
v_pl_dspl	.equ	$10000	; # of bytes between VME10 video planes
rev_vid		.equ	1	; for selecting reverse video specific code

		.text			; open program segment.

_trap:	move.l	(sp)+,retsav		; remove return address from stack
	trap	#1                      ; invoke GEMDOS 
	movea.l	retsav,a0              	; get return address of caller 
	jmp	(a0)			; get there a lot faster then by
*					; pushing and popping the stack	

*******************************************************************************
*									      *
*	_TRNSFONT							      *
*		This routine converts a font to standard form		      *
*									      *
*		input:	_FWIDTH = width of font data in bytes.		      *
*			_DELY   = number of scan lines in font.		      *
*			_FBASE  = starting address of the font data.	      *
*									      *
*		output: none.						      *
*									      *
*		destroys: d0,d1,d2 & a0. 	                              *
*******************************************************************************


_TRNSFONT:	move.w	_FWIDTH, d0	* Width of a scan line in bytes times
		mulu.w	_DELY, d0	* number of scan lines divided by two
		lsr.w	#1, d0		* is number of words to byte swap
		subq.w	#1, d0		* minus one for dbra

		movea.l	_FBASE, a0	* Starting address of the data
		moveq.l	#8,d2		* get shift count for swapping bytes
swap_loop:	move.w	(a0), d1	* Get word
		ror.w	d2, d1		* swap bytes(use faster instruction)
		move.w	d1, (a0)+	* put it back
		dbra	d0, swap_loop
		rts

********************************************************************************
********************************************************************************
**									      **
**	_put_pix:							      **
**		This routine plots a pixel for anybody (even BASIC).	      **
**									      **
**		input:	_INTIN(0) = pixel value.			      **
**			_PTSIN(0) = x coordinate.			      **
**			_PTSIN(1) = y coordinate.			      **
**									      **
**		output: none.						      **
**									      **
**		destroys: d0,d1,d2,d3,a0,& a1.				      **
**		destroys: d0,d1,d2,d3,d4,a0,a1,&a2 for VME10.		      **
********************************************************************************
********************************************************************************

_put_pix:	move.l	_PTSIN,a0	; fetch ptr to _PTSIN array.
		move.w	(a0)+,d0	; fetch x coord.
		move.w	(a0),d1		; fetch y coord.
		jsr	concat		; convert to physical offset.
		move.l	_v_bas_ad,a1	; fetch ptr to video base address.
ifne vme10
		adda.w	d1,a1		; base + offset.
endc
ifeq vme10
		adda.l	d1,a1		; base + offset.
		lea.l	v_pl_dspl,a2	; # of bytes between video planes
		moveq.l	#1,d4		; init for faster rotate instruction
endc
		add.w	d0,d0		; word indexing.
		lea	ortbl,a0
		move.w	0(a0,d0.w),d0	; fetch the pixel word mask. (for setting bits)
		move.w	d0,d1
		not.w	d1		; not the mask. (for clearing bits)
		move.w	_v_planes,d2	; fetch # of bit_planes.
		subq.w	#1,d2		; # of bit_planes -1. (loop counter)
		move.l	_INTIN,a0	; fetch ptr to _INTIN array.
		move.w	(a0),d3		; fetch pixel value.
ifeq rev_vid
		not.w	d3		; invert pixel value for reverse video
endc
ifne vme10
ppx_lp:		ror.w	#1,d3		; rotate pixel bit and put in carry.
		bcc	ppx_clr		; if 0, clear the bit.
		or.w	d0,(a1)+	; if 1, set the bit.
		dbra	d2,ppx_lp
		rts

ppx_clr:	and.w	d1,(a1)+	; clear the bit.
		dbra	d2,ppx_lp
endc
ifeq vme10
		bra.b	ppx_rot		; already have correct pixel address
ppx_lp:		adda.l	a2,a1		; address of pixel in next video plane
ppx_rot:	ror.w	d4,d3		; rotate pixel bit and put in carry.
		bcc	ppx_clr		; if 0, clear the bit.
		or.w	d0,(a1) 	; if 1, set the bit.
		dbra	d2,ppx_lp
		rts

ppx_clr:	and.w	d1,(a1) 	; clear the bit.
		dbra	d2,ppx_lp
endc
		rts
		page
********************************************************************************
********************************************************************************
**									      **
**	_get_pix:							      **
**		This routine gets a pixel for anybody (even BASIC).	      **
**									      **
**		input:  _PTSIN(0) = x coordinate.			      **
**			_PTSIN(1) = y coordinate.			      **
**									      **
**		output:	d0 = pixel value.				      **
**									      **
**		destroys: d0,d1,d2,d3, & a0.				      **
**		destroys: d0,d1,d2,d3,d4 & a0,a1,a2 for VME10.		      **
********************************************************************************
********************************************************************************

_get_pix:	move.l	_PTSIN, a0	; fetch ptr to _PTSIN array.
		move.w	(a0)+, d0	; fetch x coord.
		move.w	(a0), d1	; fetch y coord.
		jsr	concat		; convert to physical offset.
		move.l	_v_bas_ad, a0	; fetch ptr to video base address.
ifne vme10
		adda.w	d1, a0		; base + offset.
endc
ifeq vme10
		adda.l	d1,a0		; base + offset.
		lea.l   v_pl_dspl,a2	; # of bytes between video planes
endc
		add.w	d0, d0		; word indexing.
		lea	ortbl, a1
		move.w	0(a1,d0.w), d1	; fetch the pixel word mask.
		move.w	_v_planes, d2	; fetch # of bit_planes.
ifne vme10
		move.w	d2, d0
		add.w	d0, d0		; xinc.
		subq.w	#1, d2		; # of bit_planes - 1. (loop counter)
		adda.w	d0, a0		; point to highest-order bit_plane. (+2)
endc
ifeq vme10
		subq.w	#1,d2		; # of bit_planes - 1. (loop counter)
		moveq.l	#1,d4		; init for faster shift & or instr
endc
		moveq.l	#0, d0		; init the value accumulator.
		bra	gpxl_in
ifne vme10
gpx_lp:		asl.w	#1, d0		; shift accumulator for next bit_plane.
gpxl_in:	move.w	-(a0), d3	; fetch a bit.
endc
ifeq vme10
gpx_lp:		asl.w	d4,d0		; shift accumulator for next bit_plane.
		adda.l	a2,a0   	; address of pixel in next video plane
gpxl_in:	move.w	(a0),d3		; fetch a bit
endc
		and.w	d1, d3		; test the bit.
		beq	gpxl_bot	; if 0, branch.
ifne vme10
		ori.w	#1, d0		; if 1, set value accumulator bit.
endc
ifeq vme10
		or.w	d4, d0		; if 1, set value accumulator bit.
endc
gpxl_bot:	dbra	d2,gpx_lp
		rts

		page
********************************************************************************
********************************************************************************
**									      **
**	_fill_line:							      **
**		This routine fills a line for "seedfill" using the "xline"    **
**	routine.							      **
**									      **
**		input:	4(sp) = xleft.					      **
**			6(sp) = xright.					      **
**			8(sp) = y.					      **
**									      **
**		output: filled line.					      **
**									      **
**		destroys: everything.					      **
**									      **
********************************************************************************
********************************************************************************
*
*
_fill_line:
		move.l	_v_bas_ad,a5	; fetch video base address.
		lea	_FG_BP_1,a4	; point to array of bit_plane values.
ifne vme10
		move.w	_v_planes,a3	; a3 := xinc. (# of planes)
		move.w	a3,d3
		adda.w	a3,a3		; word xinc.
		subq.w	#1,d3		; d3 := (# of planes) -1.
endc
ifeq vme10
		move.w	_v_planes,d3	; d3 := xinc. (# of planes)
		subq.w	#1,d3		; d3 := (# of planes) -1.
		lea.l	v_pl_dspl,a3	; # of bytes between video planes
endc
		move.w	4(sp),d0	; fetch xleft. (input to concat)
		move.w	d0,d4		; save for later.

		move.w	8(sp),d1	; fetch y. (input to concat)
		move.w	d1,d5		; save for later.
		jsr	concat		; form physical offset.
ifne vme10
		adda.w	d1,a5		; base + physical offset.
endc
ifeq vme10
		adda.l	d1,a5		; base + physical offset.
endc
		move.w	6(sp),d2	; fetch xright.
		and.w	_patmsk,d5	; compute pattern index.
		asl.w	#1,d5		; word indexing.
		move.l	_patptr,a0	; ptr to start of pattern.
		adda.w	d5,a0		; index into pattern.
		clr.w	a1		; default offset = 0.
ifeq vme10
		lea.l	xline,a2	; address of HABLINE entry point
		tst.w	_multifill	; multi-plane fill pattern?
		beq.b	xline_entry	; no, branch.
		move.w	#32,a1		; yes, offset = 32.
xline_entry:
		jmp	(a2)		; fill the horizontal line with color.
endc
ifne vme10
		tst.w	_multifill	; multi-plane fill pattern?
		beq	xline		; no, branch.
		move.w	#32,a1		; yes, offset = 32.
*
*	d4 = xleft.			a5 = ptr to destination.
*	d3 = # of bit_planes - 1	a4 = ptr to _FG_BP_1.
*	d2 = xright.			a3 = xinc.
*       for VME10 software              a3 = # of bytes between video planes   
*	d1 = fill pattern.		a1 = offset to next planes fill pattern
*	d0 = xleft and $000F.           a0 = ptr to fill pattern. 
*
		bra	xline		; fill the horizontal line with color.
endc
		page
********************************************************************************
********************************************************************************
**									      **
**	_end_pts:							      **
**		This routine finds the endpoints of a section of solid color  **
**	for the _seed_fill routine.					      **
**									      **
**		input:	4(sp) = xstart.					      **
**			6(sp) = ystart.					      **
**			8(sp) = ptr to endxleft.			      **
**			C(sp) = ptr to endxright.			      **
**									      **
**		output: endxleft  := left endpoint of solid color.	      **
**			endxright := right endpoint of solid color.	      **
**			d0	  := success flag.			      **
**					0 => no endpoints or xstart on edge.  **
**					1 => endpoints found.		      **
**									      **
**		destroys: everything.					      **
**									      **
********************************************************************************
********************************************************************************
*
*
_end_pts:	move.w	6(sp),d1	; fetch y coordinate. (input to concat)
		cmp.w	_YMN_CLIP, d1	; Clip to the present viewport
		bmi	ep_ret0		; if above the top, return 0.

		cmp.w	_YMX_CLIP,d1
		bgt	ep_ret0		; if below the bottom, return 0.
*
		move.l	_v_bas_ad,a5	; fetch video base address.
ifne vme10
		move.w	_v_planes,a3	; a3 := xinc. (# of planes)
		move.w	a3,d3
		adda.w	a3,a3		; word xinc.
		subq.w	#1,d3		; d3 := (# of planes) -1.
endc
ifeq vme10
         	move.w	_v_planes,d3	; d3 := # of planes
		subq.w	#1,d3		; d3 := (# of planes) -1.
		lea.l	v_pl_dspl,a3	; # of bytes between video planes
endc
		move.w	4(sp),d0	; fetch x coordinate. (input to concat)
		move.w  d0,d7		; save for finding right endpoints
		jsr	concat		; form physical offset.
ifne vme10
		adda.w	d1,a5		; base + physical offset.
endc
ifeq vme10
		adda.l	d1,a5		; base + physical offset.
endc
*
*	d4 = scratch.			a5 = ptr to word containing low-order pixel bit.
*	d3 = # of bit_planes - 1	a4 = scratch.
*	d1 = scratch.
*	d0 = x coord and $000F.
*
		add.w	d0,d0		; word indexing.
		lea	ortbl,a4	; table of pixel masks.
		move.w	0(a4,d0.w),d0	; fetch the pixel mask.
		move.w	d0,a0		; save the pixel mask.
		moveq.l	#0,d1		; clear the pixel value accumulator.
		move.w	d3,a1		; save # of bit_planes - 1.
		move.l	a5,a2		; save pixel word pointer.
ifne vme10
		adda.w	a3,a5		; point to highest-order bit_plane. (+2)
endc
ifeq vme10
		moveq.l	#1,d6		; init for faster shift and or instrs.
endc
		bra	pxl_in
*
*  Get color value of requested pixel.
*
ifne vme10
px_lp:		asl.w	#1,d1		; shift accumulator for next bit_plane.
pxl_in:		move.w	-(a5),d4	; fetch a bit.
endc
ifeq vme10
px_lp:		asl.w	d6,d1		; shift accumulator for next bit_plane.
		adda.l  a3,a5	        ; point to same word in next bit plane
pxl_in:		move.w	(a5),d4 	; fetch a bit.
endc
		and.w	d0,d4		; test the bit.
		beq	pxl_bot		; if 0, branch.
ifne vme10
		ori.w	#1,d1		; if 1, set value accumulator bit.
endc
ifeq vme10
		or.w	d6,d1		; if 1, set value accumulator bit.
endc
pxl_bot:	dbra	d3,px_lp
*
		move.l	a2,a5		; restore the pixel word pointer.
		move.w	a1,d3		; restore the # of bit_planes - 1.
ifne vme10
		move.w	_XMX_CLIP,d6	; fetch right side of x viewport
endc
ifeq vme10
		move.l	a6,-(sp)	; save 'C' frame pointer
		movea.w	_XMX_CLIP,a6	; fetch right side of x viewport
endc
		move.l	a5,-(sp)	; push a5. (this adds 4 to the parameter offsets)

*	d7 = x coordinate.
*****************************************************************************
* for VME10 software:							    *
*	d6 = 1 for faster instr. types  a6 = right side of viewport	    *
*****************************************************************************
*	d6 = right side of viewport
*	d5 = scratch.			a5 = ptr to word containing low-order pixel bit.
*	d4 = scratch.			a4 = scratch.
*	d3 = # of bit_planes - 1	a3 = xinc.
******************************************************************************
*       for VME10 software              a3 = # of bytes between video planes *
******************************************************************************
*	d2 = color we are looking for	a2 = saved a5.
*	d1 = pixel value accumulator.	a1 = saved d3.
*	d0 = pixel mask.		a0 = saved d0.

		move.w	d1,d2		; this is the color we are searching for
		bra	rnl1		; branch around redundant test.
*
rnedg_lp:	cmp.w	d1,d2		; while (pixel value <> search color)
		bne	rt_nedge
ifne vme10
rnl1:		cmp.w	d6,d7		; and (x coord < x resolution).
endc
ifeq vme10
rnl1:		cmp.w	a6,d7		; and (x coord < x resolution).
endc
		bgt	rt_nedge

		addq.w	#1,d7		; increment x coord.
ifne vme10
		ror.w	#1,d0		; "increment" the pixel mask and a5.
endc
ifeq vme10
		ror.w	d6,d0		; "increment" the pixel mask and a5.
endc
		bcc	rn_gpx		; if no wrap, branch.
ifne vme10
		adda.w	a3,a5		; else point to next bit_plane 0.
endc
ifeq vme10
		addq.w	#2,a5		; point to next word in same bit_plane 
endc
rn_gpx:		movea.l	a5,a2		; save a5.

*	Now, search to the right.

		moveq.l	#0,d1		; clear the pixel value.
ifne vme10
		adda.w	a3,a5		; point to highest-order bit_plane. (+2)
endc
		bra	rnpxl_in

ifne vme10
rnpx_lp:	asl.w	#1,d1		; shift accumulator for next bit_plane.
rnpxl_in:	move.w	-(a5),d4	; fetch a bit.
endc
ifeq vme10
rnpx_lp:	asl.w	d6,d1		; shift accumulator for next bit_plane.
		adda.l	a3,a5		; point to same word in next bit_plane.
rnpxl_in:	move.w	(a5),d4		; fetch a bit
endc
		and.w	d0,d4		; test the bit.
		beq	rnpxl_bot	; if 0, branch.
ifne vme10
		ori.w	#1,d1		; if 1, set value accumulator bit.
endc
ifeq vme10
		or.w	d6,d1		; if 1, set value accumulator bit.
endc		
rnpxl_bot:	dbra	d3,rnpx_lp
		move.l	a2,a5		; restore the pixel word pointer.
		move.w	a1,d3		; restore the # of bit_planes - 1.
		bra	rnedg_lp

rt_nedge:	move.l	(sp)+,a5	; pop a5. (this subtracts 4 from offsets)
ifne vme10
		adda.w	a3,a5		; to use predecrement addressing.
endc
		subq.w	#1,d7		; backup the x coord by 1.
ifne vme10
		movea.l	12(sp),a4	; fetch ptr to endxright.
endc
ifeq vme10
		movea.l	16(sp),a4	; fetch ptr to endxright.
endc
		move.w	d7,(a4)		; output x coord to endxright.
		move.l	a5,a2		; save a5.
ifne vme10
		move.w	4(sp),d7	; fetch x coord again.
		move.w	_XMN_CLIP, d6	; fetch left side of x viewport
endc
ifeq vme10
		move.w	8(sp),d7	; fetch x coord again.
		move.w	_XMN_CLIP, a6	; fetch left side of x viewport
endc
		move.w	a0,d0		; restore pixel mask.

*	Now, search to the left.

*	d7 = x coordinate.
*****************************************************************************
* for VME10 software:							    *
*	d6 = 1 for faster instr. types  a6 = left side of viewport	    *
*****************************************************************************
*	d6 = left side of x viewport
*	d5 = scratch.			a5 = ptr to word containing low-order pixel bit.
*	d4 = scratch.			a4 = scratch.
*	d3 = # of bit_planes - 1	a3 = xinc.
******************************************************************************
*       for VME10 software		a3 = # of bytes between video planes *
******************************************************************************
*	d2 = color we are looking for	a2 = saved a5.
*	d1 = pixel value accumulator.	a1 = saved d3.
*	d0 = pixel mask.		a0 = saved d0.

		bra	lnlp1		; d1 isn't ready yet.

lnedg_lp:	cmp.w	d1,d2		; while (pixel value <> search color)
		bne	lt_nedge
ifne vme10
lnlp1:		cmp.w	d6, d7		; and (x coord inside viewport).
endc
ifeq vme10
lnlp1:		cmp.w	a6, d7		; and (x coord inside viewport).
endc
		bmi	lt_nedge
		subq.w	#1,d7		; decrement x coord.
		rol.w	d6,d0		; "decrement" the pixel mask and a5.
		bcc	ln_gpx		; if no wrap, branch.
ifne vme10
		suba.w	a3,a5		; else point to previous bit_plane 0.
endc
ifeq vme10
		subq.w 	#2,a5           ; point to next word in same bit_plane 
endc
ln_gpx:		movea.l	a5,a2		; save a5.

*	Now, get the next pixel value.

		moveq.l	#0,d1		; clear the pixel value.
		bra	lnpxl_in

ifne vme10
lnpx_lp:	asl.w	#1,d1		; shift accumulator for next bit_plane.
lnpxl_in:	move.w	-(a5),d4	; fetch a bit.
endc
ifeq vme10
lnpx_lp:	asl.w	d6,d1		; shift accumulator for next bit_plane.
		adda.l	a3,a5           ; point to same word in next bit_plane.
lnpxl_in:	move.w	(a5),d4	        ; fetch a bit.
endc
		and.w	d0,d4		; test the bit.
		beq	lnpxl_bot	; if 0, branch.
ifne vme10
		ori.w	#1,d1		; if 1, set value accumulator bit.
endc
ifeq vme10
		or.w	d6,d1		; if 1, set value accumulator bit.
endc
lnpxl_bot:	dbra	d3,lnpx_lp
		move.l	a2,a5		; restore the pixel word pointer.
		move.w	a1,d3		; restore the # of bit_planes - 1.
		bra	lnedg_lp

lt_nedge:	addq.w	#1,d7		; backup the x coord by 1.
ifeq vme10
		movea.l	(sp)+,a6	; restore 'C' frame pointer
endc	
		movea.l	8(sp),a4	; fetch ptr to endxleft.
		move.w	d7,(a4)		; output x coord to endxleft.

		cmp.w	_search_color, d2
		beq	ep_is_search

		move.w	_seed_type, d0	; return segment not of search color
		eori.w	#1,d0
		rts

ep_is_search:	move.w	_seed_type, d0	; return segment is of search color
		eori.w	#0,d0
		rts

ep_ret0:	moveq.l	#0,d0		; return(1). (success)
		rts

		page
********************************************************************************
********************************************************************************
**									      **
**	_RECTFILL:							      **
**		This routine fills a rectangular area of the screen with a    **
**	pattern using a "bitblt" algorithm similar to "_HABLINE"'s.	      **
**		Actually, this routine just clips and copies the inputs for   **
**	use by "BOX_FILL".						      **
**									      **
**		input:	_X1	  = x coord of upper left corner.	      **
**			_Y1	  = y coord of upper left corner.	      **
**			_X2	  = x coord of lower right corner.	      **
**			_Y2	  = y coord of lower right corner.	      **
**			_CLIP	  = clipping flag. (0 => no clipping.	      **
**			_XMN_CLIP = x clipping minimum.			      **
**			_XMX_CLIP = x clipping maximum.			      **
**			_YMN_CLIP = y clipping minimum.			      **
**			_YMX_CLIP = y clipping maximum.			      **
**									      **
**		output: _X1 = x coord of upper left corner.		      **
**			_Y1 = y coord of upper left corner.		      **
**			_X2 = x coord of lower right corner.		      **
**			_Y2 = y coord of lower right corner.		      **
**									      **
**		destroys: nothing.					      **
**									      **
********************************************************************************
********************************************************************************
*
*
rf_out:		rts
*
_RECTFILL:	tst.w	_CLIP
		beq	BOX_FILL		; if no clipping, just do it.
*
*	clipping.
*
		move.w	_XMN_CLIP,d0
		move.w	_X1,d1
		move.w	_X2,d2
		cmp.w	d0,d1			; is x1 >= xmn_clip?
		bge	rf_xmx			; yes, branch.
		cmp.w	d0,d2			; is x2 < xmn_clip
		blt	rf_out			; yes, branch. (clipped box is null)
		move.w	d0,_X1			; clip x1.
rf_xmx:		move.w	_XMX_CLIP,d0
		cmp.w	d0,d2			; is x2 <= xmx_clip?
		ble	rf_yclip		; yes, branch. (x clip is done)
		cmp.w	d0,d1			; is x1 > xmx_clip?
		bgt	rf_out			; yes, branch. (clipped box is null)
		move.w	d0,_X2			; clip x2.
*
rf_yclip:	move.w	_YMN_CLIP,d0
		move.w	_Y1,d1
		move.w	_Y2,d2
		cmp.w	d0,d1			; is y1 >= ymn_clip?
		bge	rf_ymx			; yes, branch.
		cmp.w	d0,d2			; is y2 < ymn_clip
		blt	rf_out			; yes, branch. (clipped box is null)
		move.w	d0,_Y1			; clip y1.
rf_ymx:		move.w	_YMX_CLIP,d0
		cmp.w	d0,d2			; is y2 <= ymx_clip?
		ble	BOX_FILL		; yes, branch. (y clip is done)
		cmp.w	d0,d1			; is y1 > ymx_clip?
		bgt	rf_out			; yes, branch. (clipped box is null)
		move.w	d0,_Y2			; clip y2.
*
*	fall through to BOX_FILL.
*
		page
********************************************************************************
********************************************************************************
**									      **
**	BOX_FILL:							      **
**		This routine fills a rectangular area of the screen with a    **
**	pattern using a "bitblt" algorithm similar to "_HABLINE"'s.	      **
**		This routine handles all 3 video resolutions.		      **
**									      **
**		input:  _X1 = x coord of upper left corner.		      **
**			_Y1 = y coord of upper left corner.		      **
**			_X2 = x coord of lower right corner.		      **
**			_Y2 = y coord of lower right corner.		      **
**			_WRT_MODE = writing mode.			      **
**									      **
**		output: none.						      **
**									      **
**		destroys: everything.					      **
**									      **
********************************************************************************
********************************************************************************
parm_size	.equ	16		; temporary stack area size 
patindx		.equ	14		; copy of current pattern index
patmsk		.equ	12		; copy of maximum pattern index
v_lin_wr	.equ	10		; copy of # of bytes per scan line
pat_start	.equ	6		; copy of pattern starting address
pat_ptr 	.equ	2		; copy of pattern pointer
pl_cnt		.equ	0		; copy of video plane count

BOX_FILL:	move.l	a6,-(sp)	; save C frame pointer
		adda.w	#-parm_size,sp	; allocate temporary stack area
		move.l	_v_bas_ad,a5	; fetch video base address.
ifne vme10
		move.w	_v_planes,a3	; a3 := xinc. (# of planes)
		move.w	a3,d3
		adda.w	a3,a3		; word xinc.
		subq.w	#1,d3		; d3 := (# of planes) -1.
endc
ifeq vme10
		move.w	_v_planes,d3	; d3 := # of video planes.
		subq.w	#1,d3		; d3 := (# of planes) -1.
		lea.l	v_pl_dspl,a3	; # of bytes between video planes.
endc
		move.w	_X1,d0		; fetch X1. (input to concat)
		move.w	d0,d4		; save for later.
		move.w	_Y1,d1		; fetch Y1. (input to concat)
		move.w	d1,d5		; save for later.
		jsr	concat		; form physical offset.
ifne vme10
		adda.w	d1,a5		; base + physical offset.
endc
ifeq vme10
		adda.l	d1,a5		; base + physical offset.
endc
		move.w	_X2,d2		; fetch X2.
		move.w	_Y2,d6		; fetch Y2.
		sub.w	d5,d6		; line loop counter.
		and.w	_patmsk,d5	; compute pattern index.
		movea.l	a5,a6		; save copy of destination address
		move.w	d3,pl_cnt(sp)	; save copy of plane count on stack
		move.w	d5,patindx(sp) 	; save pattern index in low word
		move.w	_v_lin_wr,v_lin_wr(sp) ; save # bytes per scan line
		move.w	_patmsk,patmsk(sp) ; save max. pattern index on stack
		asl.w	#1,d5		; word indexing.
		move.l	_patptr,a0	; ptr to start of pattern.
		move.l	a0,pat_start(sp) ; save starting address of pattern 
		adda.w	d5, a0		; point into pattern
		move.l	a0,pat_ptr(sp)	; save on local frame. (current pattern ptr)
		lea	lf_tab,a2	; point to fringe table.
*
*	d7 = scratch.		a5 = ptr to destination.
*	d6 = line loop counter.	a4 = ptr to _FG_BP_1.
*	d5 = scratch.		a3 = xinc.
*******************************************************************************
*       for VME10 software	a3 = # of bytes between video planes.	      *
*******************************************************************************
*	d4 = X1.		a2 = ptr to fringe table.
*	d3 = # of bit_planes - 1.
*	d2 = X2.		a0 = ptr to fill pattern.
*	d1 = scratch.
*	d0 = X1 and $000F.
*
		asl.w	#1,d0		; word index for left fringe.
		move.w	0(a2,d0.w),d0	; fetch left fringe mask.
		not.w	d0		; not left fringe mask.
		move.w	d2,d7		; X2.
		andi.w	#$000F,d7	; X2 and $000F.
		asl.w	#1,d7		; word index.
		move.w	2(a2,d7.w),d7	; fetch not right fringe mask.
		moveq.l	#4,d5
		lsr.w	d5,d4		; X1/16.
		lsr.w	d5,d2		; X2/16.
		sub.w	d4,d2		; X2/16 - X1/16.
		subq.w	#1,d2		; inner loop count. (-1,0,>0.)
*
*					; -1 => X1 and X2 in same word.
*					; 0  => 2 words, inner loop = 0.
*					; >0 => LM,inner loop,RM.
*
		bpl	bf_cont		; >= 0 normal case.
		addq.w	#1,d2		; loop count := 0.
		or	d7,d0		; combine both masks.
		moveq	#-1,d7		; prevent right mask from effecting screen.
bf_cont:	move.w	_WRT_MODE,d5	; decode write mode.
		asl.w	#2,d5		; longword indexing.
		lea	htab,a2		; point to start of decode table.
		movea.l	0(a2,d5.w),a2	; address of HABLINE writing mode fragment.
		clr.w	a1		; default offset = 0.
		tst.w	_multifill	; multi-plane fill pattern?
		beq	bf_1st_line	; no, branch.
		move.w	#32,a1		; yes, offset = 32.
		bra.b	bf_1st_line
*
*                                 a6 = copy of ptr to destination.
*	d7 = right mask.	  a5 = ptr to destination.
*	d6 = line loop counter.	  a4 = ptr to _FG_BP_1.
*	d5 = scratch.		  a3 = xinc.
*******************************************************************************
*       for VME10 software        a3 = # of bytes between video planes.       *
*******************************************************************************
*	d4 = scratch.	  	  a2 = ptr to HABLINE writing mode fragment.
* 	d3 = # of bit_planes - 1. a1 = offset to next bit-plane's fill pattern.
*	d2 = inner loop count.	  a0 = ptr to fill pattern.
*	d1 = scratch.
*	d0 = left mask (or left "and" right masks).
*
*
bf_loop:
		adda.w	v_lin_wr(sp),a6	; move down a line.
		movea.l	a6,a5		; set destination pointer

		addq.w	#1,patindx(sp) 	; increment pattern count.
		addq.l	#2,pat_ptr(sp)	; increment pattern pointer.
		move.w	patindx(sp),d3	; get pattern count
		cmp.w	patmsk(sp),d3	; pattern count > pattern maximum?
		ble.b	bf_pat		; no, branch.
		move.l	pat_start(sp),pat_ptr(sp) ; reset the pattern pointer
		clr.w	patindx(sp)	; reset the pattern count.
bf_pat:		movea.l	pat_ptr(sp),a0	; point to the next line of pattern.
		move.w	pl_cnt(sp),d3	; restore video plane count
bf_1st_line:
		lea	_FG_BP_1,a4	; set bit plane value pointer
		jsr	(a2)		; draw a horizontal line.
		dbra	d6,bf_loop	; rectangle loop.
		adda.w	#parm_size,sp	; remove temporary stack variables
		movea.l	(sp)+,a6	; restore C frame pointer
		rts
		.end
