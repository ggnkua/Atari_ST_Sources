********************************  spxmono.s  **********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbmono.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/07/30 12:53:40 $     $Locker:  $
* =============================================================================
*
* $Log:	sbmono.s,v $
*******************************************************************************

.include	"lineaequ.s"

		globl	 spx_mono
		globl	_v_bas_ad

*******************************************************************************
*	
* purpose:  This routine performs a byte aligned block transfer for the
*           purpose of manipulating monospaced byte-wide text. the routine
*           maps an single plane arbitrarilly long byte-wide image to a
*           pixel packed bit map. all transfers are byte/word aligned.
*
*	no clipping to worry about
*
*	d0.w =  _DESTX
*	d1.w =  _DESTY
*	d2.w =  # of characters
*	d3.w =  _DELY
*	a1   =  line A variable reference base
*
*******************************************************************************

spx_mono:
	movem.l	a5/a6,-(sp)		; save registers

	move.l	_v_bas_ad,a3		; a3 -> strt of dst form (0,0)
	mulu	byt_per_pix(a1),d0	; d0 <- x portion of offset
	mulu	_v_lin_wr(a1),d1	; d1 <- y portion of offset
	add.l	d0,d1			; d1 <- byte offs into mem frm
	add.l	d1,a3			; a3 -> (x,y)

	move.l	_INTIN(a1),a0		; a0 -> character string
	move.w	_v_lin_wr(a1),a4	; a4 <- offset to next line in dest
	move.w	_FWIDTH(a1),a5		; a5 <- source form width
	subq.w	#1,d3			; d3 <- cell height - 1
	move.w	#8,d7			; d7 <- width of character
	mulu	byt_per_pix(a1),d7	; d7 <- # of bytes for scan of cell
	sub.w	d7,a4			; udjust offset to next line in dest
	moveq.l	#7,d1			; d1 <- width of char cell - 1

	move.w	_TEXT_FG(a1),d0		; d0 <- text foreground color
	lsl.w	#2,d0			; make d0 long word offset
	add.l	#pal_map,d0		; d0 <- desired offset
	move.l	(a1,d0.w),d4		; a4 <- desired foreground col

	move.w	_TEXT_BG(a1),d0		; d0 <- text background color
	lsl.w	#2,d0			; make d0 long word offset
	add.l	#pal_map,d0		; d0 <- desired offset
	move.l	(a1,d0.w),d6		; a4 <- desired background col

	cmp.w	#16,_v_planes(a1)	; see how many bits per pixel
	beq	spx16Tab		; do 16 bits per pixel case
	blt	spx8Tab			; do 8 bits per pixel case
	lea	Mono32Tab,a6		; a6 -> table of 32 bit routines
	bra	tab_set

spx16Tab:
	lea	Mono16Tab,a6		; a6 -> table of 16 bit routines
	bra	tab_set

spx8Tab:	
	lea	Mono8Tab,a6		; a6 -> table of 8 bit routines

tab_set:
	move.w	_WRT_MODE(a1),d5	; clear for later use
	lsl.w	#2,d5			; d2 <- offset into the table
	move.l	(a6,d5.w),a6		; a0 -> desired routine

	dbra	d2,next_char		; do next character
	movem.l	(sp)+,a5/a6		; restore registers
	moveq.l	#1,d0			; exit blit with success code in d0
	rts

Mono32Tab:	dc.l	New32M1Line,New32M2Line,New32M3Line,New32M4Line
Mono16Tab:	dc.l	New16M1Line,New16M2Line,New16M3Line,New16M4Line
Mono8Tab:	dc.l	New8M1Line,New8M2Line,New8M3Line,New8M4Line

next_char:
	move.l	_FBASE(a1),a2		; a2 -> source form base address
	move.w	(a0)+,d0		; d0 <- current character
	lea	(a2,d0.w),a2		; a2 -> character data
	movem.l	d3/a3,-(sp)		; save registers that get clobbered
	move.w	d1,d5			; d5 <- width of character
	jsr	(a6)
	movem.l	(sp)+,d3/a3		; restore registers that got clobbered
	add.w	d7,a3			; a3 -> to next cell
	dbra	d2,next_char		; do next character
	movem.l	(sp)+,a5/a6		; restore registers
	moveq.l	#1,d0			; exit blit with success code in d0
	rts

*+
*	d1.w	width of character
*	d3.w	cell height
*	d4.l	foreground color
*	d5.w	width of character
*	d6.l	background color
*
*	a2.l	points to font data
*	a3.l	points to the dest
*	a4.w	offset to next line in dest
*	a5.w	font wrap
*-

******************************************************************************
*********************************** 32 bit mode ******************************
******************************************************************************
*+
* Replace mode (1)
*-
New32M1Line:	move.w	(a2),d0			; d0 <- font data
Cur32M1Line:	lsl.w	d0			; if shifted out bit was set
		bcs	Cel32M1Fg		; then splat foreground
		move.l	d6,(a3)+		; set dst to background color
		dbra	d5,Cur32M1Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New32M1Line		; do next line of the cell
		rts

Cel32M1Fg:	move.l	d4,(a3)+		; set dst to foreground color
		dbra	d5,Cur32M1Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New32M1Line		; do next line of the cell
		rts

*+
* Transparant mode (2)
*-
New32M2Line:	move.w	(a2),d0			; d0 <- font data
Cur32M2Line:	lsl.w	d0			; if shifted out bit was set
		bcs	Cel32M2Fg		; then splat foreground
		addq.w	#4,a3			; point to next pixel
		dbra	d5,Cur32M2Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New32M2Line		; do next line of the cell
		rts

Cel32M2Fg:	move.l	d4,(a3)+		; set dst to foreground color
		dbra	d5,Cur32M2Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New32M2Line		; do next line of the cell
		rts

*+
* XOR mode (3)
*-
New32M3Line:	move.w	(a2),d0			; d0 <- font data
Cur32M3Line:	lsl.w	d0			; if shifted out bit was set
		bcs	Cel32M3Fg		; then splat foreground
		addq.w	#4,a3			; point to next pixel
		dbra	d5,Cur32M3Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New32M3Line		; do next line of the cell
		rts

Cel32M3Fg:	eori.l	#-1,(a3)+		; XOR with -1
		dbra	d5,Cur32M3Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New32M3Line		; do next line of the cell
		rts

*+
* Reverse Transparant Mode (4)
*-
New32M4Line:	move.w	(a2),d0			; d0 <- font data
Cur32M4Line:	lsl.w	d0			; if shifted out bit was set
		bcs	Cel32M4Fg		; then splat foreground
		move.l	d6,(a3)+		; set dst to background color
		dbra	d5,Cur32M4Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New32M4Line		; do next line of the cell
		rts

Cel32M4Fg:	addq.w	#4,a3			; point to next pixel
		dbra	d5,Cur32M4Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New32M4Line		; do next line of the cell
		rts

******************************************************************************
*********************************** 16 bit mode ******************************
******************************************************************************

*+
* Replace mode (1)
*-
New16M1Line:	move.w	(a2),d0			; d0 <- font data
Cur16M1Line:	lsl.w	d0			; if shifted out bit was set
		bcs	Cel16M1Fg		; then splat foreground
		move.w	d6,(a3)+		; set dst to background color
		dbra	d5,Cur16M1Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New16M1Line		; do next line of the cell
		rts

Cel16M1Fg:	move.w	d4,(a3)+		; set dst to foreground color
		dbra	d5,Cur16M1Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New16M1Line		; do next line of the cell
		rts

*+
* Transparant mode (2)
*-
New16M2Line:	move.w	(a2),d0			; d0 <- font data
Cur16M2Line:	lsl.w	d0			; if shifted out bit was set
		bcs	Cel16M2Fg		; then splat foreground
		addq.w	#2,a3			; point to next pixel
		dbra	d5,Cur16M2Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New16M2Line		; do next line of the cell
		rts

Cel16M2Fg:	move.w	d4,(a3)+		; set dst to foreground color
		dbra	d5,Cur16M2Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New16M2Line		; do next line of the cell
		rts

*+
* XOR mode (3)
*-
New16M3Line:	move.w	(a2),d0			; d0 <- font data
Cur16M3Line:	lsl.w	d0			; if shifted out bit was set
		bcs	Cel16M3Fg		; then splat foreground
		addq.w	#2,a3			; point to next pixel
		dbra	d5,Cur16M3Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New16M3Line		; do next line of the cell
		rts

Cel16M3Fg:	eori.w	#-1,(a3)+		; XOR with -1
		dbra	d5,Cur16M3Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New16M3Line		; do next line of the cell
		rts

*+
* Reverse Transparant Mode (4)
*-
New16M4Line:	move.w	(a2),d0			; d0 <- font data
Cur16M4Line:	lsl.w	d0			; if shifted out bit was set
		bcs	Cel16M4Fg		; then splat foreground
		move.w	d6,(a3)+		; set dst to background color
		dbra	d5,Cur16M4Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New16M4Line		; do next line of the cell
		rts

Cel16M4Fg:	addq.w	#2,a3			; point to next pixel
		dbra	d5,Cur16M4Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New16M4Line		; do next line of the cell
		rts

******************************************************************************
***********************************  8 bit mode ******************************
******************************************************************************

*+
* Replace mode (1)
*-
New8M1Line:	move.w	(a2),d0			; d0 <- font data
Cur8M1Line:	lsl.w	d0			; if shifted out bit was set
		bcs	Cel8M1Fg		; then splat foreground
		move.b	d6,(a3)+		; set dst to background color
		dbra	d5,Cur8M1Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New8M1Line		; do next line of the cell
		rts

Cel8M1Fg:	move.b	d4,(a3)+		; set dst to foreground color
		dbra	d5,Cur8M1Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New8M1Line		; do next line of the cell
		rts

*+
* Transparant mode (2)
*-
New8M2Line:	move.w	(a2),d0			; d0 <- font data
Cur8M2Line:	lsl.w	d0			; if shifted out bit was set
		bcs	Cel8M2Fg		; then splat foreground
		addq.w	#1,a3			; point to next pixel
		dbra	d5,Cur8M2Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New8M2Line		; do next line of the cell
		rts

Cel8M2Fg:	move.b	d4,(a3)+		; set dst to foreground color
		dbra	d5,Cur8M2Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New8M2Line		; do next line of the cell
		rts

*+
* XOR mode (3)
*-
New8M3Line:	move.w	(a2),d0			; d0 <- font data
Cur8M3Line:	lsl.w	d0			; if shifted out bit was set
		bcs	Cel8M3Fg		; then splat foreground
		addq.w	#1,a3			; point to next pixel
		dbra	d5,Cur8M3Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New8M3Line		; do next line of the cell
		rts

Cel8M3Fg:	eori.b	#-1,(a3)+		; XOR with -1
		dbra	d5,Cur8M3Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New8M3Line		; do next line of the cell
		rts

*+
* Reverse Transparant Mode (4)
*-
New8M4Line:	move.w	(a2),d0			; d0 <- font data
Cur8M4Line:	lsl.w	d0			; if shifted out bit was set
		bcs	Cel8M4Fg		; then splat foreground
		move.b	d6,(a3)+		; set dst to background color
		dbra	d5,Cur8M4Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New8M4Line		; do next line of the cell
		rts

Cel8M4Fg:	addq.w	#1,a3			; point to next pixel
		dbra	d5,Cur8M4Line		; cont with current cell line
		move.w	d1,d5			; d5 <- width of cell
		add.w	a5,a2			; point to next line of cell
		add.w	a4,a3			; point to next line of dest
		dbra	d3,New8M4Line		; do next line of the cell
		rts
	.end
