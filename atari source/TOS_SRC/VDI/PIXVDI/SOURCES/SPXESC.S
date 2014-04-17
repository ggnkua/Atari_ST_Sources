********************************  spxesc.s  ***********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbescape.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/01/31 12:04:31 $     $Locker:  $
* =============================================================================
*
* $Log:	$
*******************************************************************************

.include	"lineaequ.s"

		.globl	_v_bas_ad
		.globl	spx_cell
		.globl	spx_blank
		.globl	spx_neg_cell
		.globl	spx_scrup
		.globl	spx_scrdn

*******************************************************************************
*	
* name: spx_cell (soft blt version for pixel pact architecture)
*
* purpose:  This routine performs a byte aligned block transfer for the
*           purpose of manipulating monospaced byte-wide text. the routine
*           maps an single plane arbitrarilly long byte-wide image to a
*           pixel packed bit map. all transfers are byte/word aligned.
*
* in:	a0.l	points to contiguous source block (1 byte wide)
*	a1.l	points to destination (1st plane, top of block)
*	d6.l	foreground 
*	d7.l	background 
*
* damaged:	a2-a3/a5/d0-d7
*
*******************************************************************************

            
spx_cell:	move.w	v_fnt_wr(a4),d2		; d2 <- src width (in bytes)
		move.w	v_cel_ht(a4),d4
		subq.w	#1,d4			; d4 <- cell height -1
		move.l	v_off_ad(a4),a2		; a2 -> offset table
		move.w	2(a2),d1		; d1 <- width of the cell
		move.w	d1,d5			; we use d5 and keep d1
		lsl.w	#2,d5			; 32 bits per pixel : 4 bytes
		move.w	_v_lin_wr(a4),d3	; d3 <- dst width (in bytes)
		sub.w	d5,d3			; adjust for post increment
		subq.w	#1,d1			; adjust counter
		move.w	d1,d5			; reload d5
		move.l	a0,a2			; a2 -> font data
		move.l	a1,a3			; a3 -> dst
		cmp.w	#16,_v_planes(a4)	; see how many bit per pixel
		beq	spx_16_cell		; do 16 bits per pixel case
		blt	spx_8_cell		; do 8 bits per pixel case

;
; 24/32 bits per pixel case
;
new_32_line:	move.w	(a2),d0			; d0 <- font data
curr_32_line:	lsl.w	d0			; if shifted out bit was set
		bcs	cell_32_fg		; then splat foreground
		move.l	d7,(a3)+		; set dst to background color
		dbra	d5,curr_32_line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	d2,a2			; point to next line of cell
		add.w	d3,a3			; point to next line of dest
		dbra	d4,new_32_line		; do next line of the cell
		rts

cell_32_fg:	move.l	d6,(a3)+		; set dst to foreground color
		dbra	d5,curr_32_line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	d2,a2			; point to next line of cell
		add.w	d3,a3			; point to next line of dest
		dbra	d4,new_32_line		; do next line of the cell
		rts

;
; 16 bits per pixel case
;
spx_16_cell:	addq.w	#1,d5			; d5 <- cell width
		add.w	d5,d3			; adjust wrap for postincrmnt
		add.w	d5,d3			;    for the word case
		subq.w	#1,d5			; adjust counter back
new_16_line:	move.w	(a2),d0			; d0 <- font data
curr_16_line:	lsl.w	d0			; if shifted out bit was set
		bcs	cell_16_fg		; then splat foreground
		move.w	d7,(a3)+		; set dst to background color
		dbra	d5,curr_16_line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	d2,a2			; point to next line of cell
		add.w	d3,a3			; point to next line of dest
		dbra	d4,new_16_line		; do next line of the cell
		rts

cell_16_fg:	move.w	d6,(a3)+		; set dst to foreground color
		dbra	d5,curr_16_line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	d2,a2			; point to next line of cell
		add.w	d3,a3			; point to next line of dest
		dbra	d4,new_16_line		; do next line of the cell
		rts

;
; 8 bits per pixel case
;
spx_8_cell:	addq.w	#1,d5			; d5 <- cell width
		lsr.w	#2,d5			; adjust wrap for postincrmnt
		add.w	d5,d3			;    for the byte case
		move.w	d1,d5			; restore counter back

new_8_line:	move.w	(a2),d0			; d0 <- font data
curr_8_line:	lsl.w	d0			; if shifted out bit was set
		bcs	cell_8_fg		; then splat foreground
		move.b	d7,(a3)+		; set dst to background color
		dbra	d5,curr_8_line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	d2,a2			; point to next line of cell
		add.w	d3,a3			; point to next line of dest
		dbra	d4,new_8_line		; do next line of the cell
		rts

cell_8_fg:	move.b	d6,(a3)+		; set dst to foreground color
		dbra	d5,curr_8_line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	d2,a2			; point to next line of cell
		add.w	d3,a3			; point to next line of dest
		dbra	d4,new_8_line		; do next line of the cell
		rts



*******************************************************************************
*
* title:	 Scroll
*
*
* author:	jim eisenstein
*
*
*   Scroll copies a source region as wide as the screen to an overlapping
*   destination region on a one cell-height offset basis.  Two entry points
*   are provided:  Partial-lower scroll-up, partial-lower scroll-down.
*   Partial-lower screen operations require cell y # indicating the top line
*   where scrolling will take place.
*
*   After the copy is performed, any non-overlapping area of the previous
*   source region is "erased" by filling with the background color.
*
* 
*  in:  d1.w	   cell Y of region top
*	v_cel_my   cell Y of region bottom
*
*
*  munged:	d0-d7/a2-a3
*		
*
*******************************************************************************

spx_scrup:

	move.w	v_cel_my(a4),d3		; d3 <- Ymax
	move.w	d3,d7
	sub.w	d1,d7			; d7 <- height of region in cells -1
	beq	blank_up

	mulu	v_cel_ht(a4),d7		; d7 <- scroll region height

	move.w	v_cel_ht(a4),d0		; d0 <- cell height
	mulu.w	d0,d1
	mulu.w	_v_lin_wr(a4),d0	; d0 <- cell wrap
	mulu.w	_v_lin_wr(a4),d1	; d1 <- offset to (0,Ymin)

	move.l	_v_bas_ad,a3		; a3 -> base of screen
	add.l	d1,a3			; a3 -> scroll dst: Ymin
	move.l	a3,a2
	add.l	d0,a2			; a2 -> scroll src: Ymin+1

	move.w	_v_lin_wr(a4),d0	; d0 <- bytes per line
	lsr.w	#4,d0			; d0 <- iterations per line
	mulu	d0,d7			; d7 <- total iterations
	subq.w	#1,d7			; d7 <- dbra loop counter

loop_up:

	move.l	(a2)+,(a3)+		; move 16 bytes in a hurry
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	dbra	d7,loop_up

blank_up:

	clr.w	d0			; d0 <- Xmin
	move.w	v_cel_mx(a4),d2		; d2 <- Xmax
	move.w	d3,d1			; d1 <- Ymax  d3 <- Ymax
	move.l	V_ROUTINES(a4),a2
	move.l	V_BLANK(a2),a2		; a2 -> proper blank routine
	jmp	(a2)			; fill the vacated space



spx_scrdn:

	move.w	v_cel_my(a4),d3		; d3 <- Ymax
	move.w	d3,d7
	sub.w	d1,d7			; d7 <- height of region in cells -1
	beq	blank_dn

	mulu	v_cel_ht(a4),d7		; d7 <- scroll region pixel height

	move.w	v_cel_ht(a4),d0		; d0 <- cell height
	mulu.w	d0,d3
	mulu.w	_v_lin_wr(a4),d0	; d0 <- cell wrap
	mulu.w	_v_lin_wr(a4),d3	; d3 <- offset to (0,Ymin)

	move.l	_v_bas_ad,a2		; a2 -> base of screen
	add.l	d3,a2			; a2 -> scroll src: 1st word of Ymax
	move.l	a2,a3
	add.w	d0,a3			; a3 -> scroll dst: 1st word of Ymax+1

	move.w	_v_lin_wr(a4),d0	; d0 <- bytes per line
	lsr.w	#4,d0			; d0 <- iterations per line
	mulu	d0,d7			; d7 <- total iterations
	subq.w	#1,d7			; d7 <- dbra loop counter

loop_dn:

	move.l	-(a2),-(a3)		; move 16 bytes in a hurry
	move.l	-(a2),-(a3)
	move.l	-(a2),-(a3)
	move.l	-(a2),-(a3)
	dbra	d7,loop_dn

blank_dn:

	clr.w	d0			; d0 <- Xmin
	move.w	v_cel_mx(a4),d2		; d2 <- Xmax
	move.w	d1,d3			; d1 <- Ymin  d3 <- Ymin
	move.l	V_ROUTINES(a4),a2
	move.l	V_BLANK(a2),a2		; a2 -> proper blank routine
	jmp	(a2)			; fill the vacated space


*******************************************************************************
*
* title:	Blank blt
*
* purpose:	This routine fills a cell-word aligned region with the
*		background color.  The rectangular region is specified by a
*		top/left cell x,y and a bottom/right cell x,y, inclusive.
*
* in:	d0	cell Xmin of region
*	d1	cell Ymin of region
*	d2	cell Xmax of region
*	d3	cell Ymax of region
*
*
* mutated:	d4-d7/a2-a3/a5
*
*******************************************************************************

spx_blank:	move.w	d0,d4			; d4 <- X min
		move.w	d2,d5			; d5 <- X max
		sub.w	d4,d5			; d5 <- span in cells - 1
		addq.w	#1,d5			; d5 <- span in cells
		move.l	v_off_ad(a4),a2		; a2 -> offset table
		mulu	2(a2),d5		; 2(a2) contains width of cell
		move.w	d5,d7			; d7 <- span in pixels
		mulu	byt_per_pix(a4),d7	; d7 <- span in bytes
		sub.w	_v_lin_wr(a4),d7	; d7 <- neg offset to prev line
		neg.w	d7			; d7 <- pos offset to next line
		subq.w	#1,d5			; adjust counter to zero base

		move.w	d1,d4			; d4 <- Y min
		move.w	d3,d6			; d5 <- Y max
		sub.w	d4,d6			; d6 <- # lines to blank out - 1
		addq.w	#1,d6			; d6 <- # lines to blank out
		mulu	v_cel_ht(a4),d6		; d6 <- height in pixels
		subq.w	#1,d6			; adjust counter to zero based

		mulu	v_cel_ht(a4),d4		; d4 <- y offset into the screen
		mulu	_v_lin_wr(a4),d4	;
		move.l	_v_bas_ad,a3		; a3 -> video base address
		add.l	d4,a3			; a2 -> curr starting scanline
		move.w	d0,d4			; d4 <- X min of region
		mulu	byt_per_pix(a4),d4	; d4 <- offset in bytes
		mulu	2(a2),d4		; d4 <- offset into scanline
		add.l	d4,a3			; a3 -> start of region

		move.l	d5,a2			; a2 <- span in cells - 1
		move.l	vl_col_bg(a4),d5	; d5 <- background color
		cmp.w	#16,_v_planes(a4)	; see how many bits per pixel
		beq	px16BlLine		; branches to 16 bits per pix
		blt	px8BlLine		; branches to 16 bits per pix
		
;
; Blank out 32 bit case
;
px32BlLine:	move.w	a2,d4			; d4 <- # of pixels to clr - 1
blankLongs:	move.l	d5,(a3)+		; 
		dbra	d4,blankLongs
		add.w	d7,a3			; point into next scanline
		dbra	d6,px32BlLine		; do next line
		rts
;
; Blank out 16 bit case
;
px16BlLine:	move.w	a2,d4			; d4 <- # of pixels to clr - 1
blankWords:	move.w	d5,(a3)+		; 
		dbra	d4,blankWords
		add.w	d7,a3			; point into next scanline
		dbra	d6,px16BlLine		; do next line
		rts
;
; Blank out 8 bit case
;
px8BlLine:	move.w	a2,d4			; d4 <- # of pixels to clr - 1
blankBytes:	move.b	d5,(a3)+		; 
		dbra	d4,blankBytes
		add.w	d7,a3			; point into next scanline
		dbra	d6,px8BlLine		; do next line
		rts



*******************************************************************************
*	
* name:		spx_neg_cell
*
* purpose:	This routine negates the contents of an arbitrarily tall 
*		byte/word wide cell composed of an arbitrary number of
*		(atari styled) bit-planes. cursor display can be
*		acomplished via this procedure. since a second 
*		negation restores the original cell condition, there is
*		no need to save	the contents beneath the cursor block.
*
* in:		a1.l	  points to destination (1st plane, top of block)
*
*
* destroyed:	d4-d7/a0-a2
*
*******************************************************************************


spx_neg_cell:	move.w	_v_lin_wr(a4),d4
		move.w	v_cel_ht(a4),d5
		subq.w	#1,d5			; for dbra.

		move.l	v_off_ad(a4),a0		; a0 -> offset table
		move.w	2(a0),d6		; d6 <- cell width
		subq.w	#1,d6			; for dbra

		cmp.w	#16,_v_planes(a4)	; see how many bit per pixel
		beq	neg_16_loop		; do 16 bits per pixel case
		blt	neg_8_loop		; do 8 bits per pixel case

neg_32_loop:	move.l	a1,a2			; a2 -> start of curr line
		move.w	d6,d7			; cell width - 1
neg_long:	not.l	(a2)+			; neg curr pix
		dbra	d7,neg_long
		add.w	d4,a1			; point to next scan line
		dbra	d5,neg_32_loop		; do next line
		rts

neg_16_loop:	move.l	a1,a2			; a2 -> start of curr line
		move.w	d6,d7			; cell width - 1
neg_word:	not.w	(a2)+			; neg curr pix
		dbra	d7,neg_word
		add.w	d4,a1			; point to next scan line
		dbra	d5,neg_16_loop		; do next line
		rts

neg_8_loop:	move.l	a1,a2			; a2 -> start of curr line
		move.w	d6,d7			; cell width - 1
neg_byte:	not.b	(a2)+			; neg curr pix
		dbra	d7,neg_byte
		add.w	d4,a1			; point to next scan line
		dbra	d5,neg_8_loop		; do next line
		rts




	.end
