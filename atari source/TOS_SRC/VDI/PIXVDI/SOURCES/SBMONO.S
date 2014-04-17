*********************************  sbmono.s  **********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbmono.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/07/30 12:53:40 $     $Locker:  $
* =============================================================================
*
* $Log:	sbmono.s,v $
* Revision 3.1  91/07/30  12:53:40  lozben
* Changed some absolute offsets to equate offsets.
* 
* Revision 3.0  91/01/03  15:17:23  lozben
* New generation VDI
* 
* Revision 2.1  89/02/21  17:26:13  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  87/11/20  15:17:24  lozben
* Initial revision
* 
*******************************************************************************

.include	"lineaequ.s"

		globl	 sb_mono
		globl	_v_bas_ad


*  no clipping to worry about
*
*   d0.w =  _DESTX
*   d1.w =  _DESTY
*   d2.w =  # of characters
*   d3.w =  _DELY
*   a1   =  line A variable reference base

sb_mono:
	movem.l	a5-a6,-(sp)	; save a5 and a6 
	movea.l	a1,a5		; a5 -. line A variable structure

	muls	_bytes_lin(a5),d1	; d1 <- Y offset
	asr.w	#4,d0			; d0 <- word offset to X
	subx.w	d4,d4			; d4 <- 0000=>even byte  FFFF=>odd byte
	muls	_v_planes(a5),d0	; d0 <- X offset /2
	add.w	d4,d4			; cy:0=>even byte cy:1=>odd byte
	addx.l	d0,d0			; d0 <- byte offset to X

	move.l	_v_bas_ad,a1
	add.l	d0,a1			; a1 -> screen destination
	add.l	d1,a1

	move.l	_FBASE(a5),a0		; a0 -> source form base address
	move.w	_FWIDTH(a5),d0		; d0 <- source form width
	move.l	_INTIN(a5),a2		; a2 -> character string
	move.w	_v_lin_wr(a5),d1	; d1 <- screen form width
	move.w	_WRT_MODE(a5),d4	; d4 <- writing mode
	add.w	d4,d4			; d4 <- writing mode index

	dbra	d3,next_char		; d3 <- character height dbra counter
	movem.l	(sp)+,a5-a6		; restore a5 and a6 
	rts				; quit on null height
	

*	a0   -> source form base
*	a1   -> screen destination
*	a2   -> character string
*
*	d0.w = source form width
*	d1.w = screen form width
*	d2.w = # of characters
*	d3.w = height of character -1 (in rows)
*	d4.w = writing mode index (0,2,4,or6)

mchar_lp:

	move.l	a1,-(sp)		; save screen destination on stack
	move.w	(a2)+,d5		; d5 <- next character from string
	lea	0(a0,d5.w),a3		; a3 -> top-most grfx byt for cur char
	move.w	 _TEXT_FG(a5),d6	; d6 <- foreground color
	move.w	_v_planes(a5),d5	; d5 <- plane count
	bra	next_plane

mplan_lp:

	move.w	d4,d7		; d7 <- writing mode index
	ror.w	#1,d6		; cy <- current plane's foreground color bit
	bcc	bit_clr		; cy:0 => use top half of table

	addq.w	#8,d7		; cy:1 => use bottom half of table

bit_clr:

	move.w	mode_tbl(pc,d7.w),d7	; d7 <- offset to routine
	jmp	mode_tbl(pc,d7.w)	; perform proper operation


mplan_cont:

	addq.l	#2,a1			;destination to next plane

next_plane:

	dbra	d5,mplan_lp		;do next plane


	move.l	(sp)+,a1	; a1 -> original screen destination
	addq.l	#1,a1		; a1 -> next character position
	move.l	a1,d7
	btst.l	#0,d7		; word fault ?
	bne	next_char	; if not, use other half of current word

	move.w	_v_planes(a5),d7	; d7 <- number of planes
	subq.w	#1,d7			; d7 <-	number of planes -1
	add.w	d7,d7			; d7 <- offset to 1st plane of nxt byte
	add.w	d7,a1			; a1 -> next char position

next_char:

	dbra	d2,mchar_lp		; do next character

	moveq.l	#1,d0			; exit blit with success code in d0
	movem.l	(sp)+,a5-a6		; restore a5 and a6 
	rts


mode_tbl:

	dc.w	 mon_zer-mode_tbl	;replace		0
	dc.w	mon_set0-mode_tbl	;transparent		0
	dc.w	 mon_xor-mode_tbl	;exclusive or (xor)	0
	dc.w	mon_not0-mode_tbl	;inverse transparent	0

	dc.w	 mon_rep-mode_tbl	;replace		1
	dc.w	mon_set1-mode_tbl	;transparent		1
	dc.w	 mon_xor-mode_tbl	;exclusive or (xor)	1
	dc.w	mon_not1-mode_tbl	;inverse transparent	1



*  	a1  -> screen address
*  	a3  -> top-most grafix byte in font data of current character
*	a5  -> line A variables base address ( _FWIDTH)
*
*	d0.w = source form width
*	d1.w = screen form width
*	d3.w = height of character (in rows)


*  direct replacement

mon_rep:

	move.l	a1,a6		;copy screen address to temp
	move.l	a3,a4		;copy form address to temp
	move.w	d3,d7		;copy height count to temp

rep_lp:
	move.b	(a4),(a6)	;direct replacement
	adda.w	d0,a4		;advance to next form byte
	adda.w	d1,a6		;advance to next screen byte
	dbra	d7,rep_lp	;go for next line

	bra	mplan_cont


*  all zeros

mon_zer:

	move.l	a1,a6		;copy screen address to temp
	move.w	d3,d7		;copy height count to temp

zer_lp:
	clr.b	(a6)		;all zeros
	adda.w	d1,a6		;advance to next screen byte
	dbra	d7,zer_lp	;go for next line

	bra	mplan_cont



mon_set0:

	swap	d2		;save lower 16 bits in upper 16
	move.l	a1,a6		;copy screen address to temp
	move.l	a3,a4		;copy form address to temp
	move.w	d3,d7		;copy height count to temp

set0_lp:

	move.b	(a4),d2		;fetch next row data
	not.b	d2
	and.b	d2,(a6)		;perform logic op
	adda.w	d0,a4		;advance to next form byte
	adda.w	d1,a6		;advance to next screen byte
	dbra	d7,set0_lp	;go for next line

	swap	d2		;restore d2
	bra	mplan_cont




mon_set1:

	swap	d2
	move.l	a1,a6		;copy screen address to temp
	move.l	a3,a4		;copy form address to temp
	move.w	d3,d7		;copy height count to temp

set1_lp:

	move.b	(a4),d2		;fetch next row data
	or.b	d2,(a6)		;perform logic op
	adda.w	d0,a4		;advance to next form byte
	adda.w	d1,a6		;advance to next screen byte
	dbra	d7,set1_lp	;go for next line

	swap	d2
	bra	mplan_cont




mon_not0:

	swap	d2		;save lower 16 bits in upper 16
	move.l	a1,a6		;copy screen address to temp
	move.l	a3,a4		;copy form address to temp
	move.w	d3,d7		;copy height count to temp

not0_lp:

	move.b	(a4),d2		;fetch next row data
	and.b	d2,(a6)		;perform logic op
	adda.w	d0,a4		;advance to next form byte
	adda.w	d1,a6		;advance to next screen byte
	dbra	d7,not0_lp	;go for next line

	swap	d2		;restore d2
	bra	mplan_cont



mon_not1:

	swap	d2
	move.l	a1,a6		;copy screen address to temp
	move.l	a3,a4		;copy form address to temp
	move.w	d3,d7		;copy height count to temp

not1_lp:

	move.b	(a4),d2		;fetch next row data
	not.b	d2
	or.b	d2,(a6)		;perform logic op
	adda.w	d0,a4		;advance to next form byte
	adda.w	d1,a6		;advance to next screen byte
	dbra	d7,not1_lp	;go for next line

	swap	d2
	bra	mplan_cont



mon_xor:

	swap	d2
	move.l	a3,a4		;copy form address to temp
	move.l	a1,a6		;copy screen address to temp
	move.w	d3,d7		;copy height count to temp

xor_lp:

	move.b	(a4),d2		;fetch next row data
	eor.b	d2,(a6)		;perform logic op
	adda.w	d0,a4		;advance to next form byte
	adda.w	d1,a6		;advance to next screen byte
	dbra	d7,xor_lp	;go for next line

	swap	d2
	bra	mplan_cont

	end
