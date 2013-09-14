
	
	globl	opaqu411,xprnt411,rtnop411,rtnxp411
	globl	final_resting_place,pix_up_table


STATUS		equ	00

S_FORM		equ	02	; src form base address
S_NXLN		equ	06	; src form width in bytes
S_XMIN		equ	08	; Xmin of src region 
S_YMIN		equ	10	; Ymin of src region
S_WD		equ	12	; width in pixels of src region
S_HT		equ	14	; height in pixels of src region

D_FORM		equ	16	; dst form base address
D_NXLN		equ	20	; dst form width in bytes
D_XMIN		equ	22	; Xmin of dst region 
D_YMIN		equ	24	; Ymin of dst region
D_WD		equ	26	; width in pixels of dst region
D_HT		equ	28	; height in pixels of dst region

*------------------------- MAINTAINED INTERNALLY -----------------------------*

S_ADDR		equ	30	; address of first word of src region
S_XPIX		equ	34	; first pixel of first word    (15:msb 00:lsb)

D_ADDR		equ	36	; address of first word of src region
D_XPIX		equ	40	; first pixel of first word    (15:msb 00:lsb)

WD_MIN		equ	42	; width in pixels of smallest region
HT_MIN		equ	44	; height in pixels of smallest region

X_FINC		equ	46	; min width / max width      (fractional part)
X_FRAC		equ	48	; X DDA accumulator         (init to X_FINC/2)
Y_FINC		equ	50	; min height / max height    (fractional part) 
Y_FRAC		equ	52	; Y DDA accumulator         (init to Y_FINC/2)

D_SPAN		equ	54	; dst word span -1
D_LMSK		equ	56	; lf dst mask in hi and lo words (0:old 1:new)
D_RMSK		equ	60	; rt dst mask in hi and lo words (0:old 1:new)

SP_SAV		equ	64

	

*  stretch in X, stretch in Y, 4 woven planes   opaque
*
*  in:
*	a6	points to parameter block
*	a7	points to return point from


opaqu411:
xprnt411:

	move.w	X_FINC(a6),a2		; a2 <- X dda increment
	move.l	S_ADDR(a6),a4		; a4 -> src
	move.l	D_ADDR(a6),a5		; a5 -> dst
	move.w	S_NXLN(a6),d2		; d2 <- offset to next src line
	move.w	HT_MIN(a6),d7		; d7 <- height
	dbra	d7,scale_loop		; d7 <- dbra height

	bra	final_resting_place	; quit if null height


scale_loop:

	swap	d7			; d7[31:16] <- height count

same_s_line:

	move.l	a4,a0			; a0 <- working src pointer
	move.l	a5,a1			; a1 <- working dst pointer

	move.w	S_XPIX(a6),d0		; d0 -> src pixel
	move.w	D_XPIX(a6),d1		; d1 -> dst pixel
	move.w	X_FRAC(a6),d2		; d2 <- X dda accumulator
	move.l	(a0)+,d3		; d3 <- 1st src longword
	move.l	(a0)+,d4		; d4 <- 2nd src longword
	move.l	(a1),d5			; d5 <- 1st dst longword
	move.l	4(a1),d6		; d6 <- 2nd dst longword
	move.w	WD_MIN(a6),d7		; d7[15:00] <- width count

	dbra	d7,get_src_pix

	bra	final_resting_place


new_src_pix:

	dbra	d0,get_src_pix		; d0 -> next pixel

	moveq.l	#15,d0			; d0 -> hi bit of next word
	move.l	(a0)+,d3		; d3 <- 1st longword of source
	move.l	(a0)+,d4		; d4 <- 2nd longword of source


get_src_pix:

	lea	pix_up_table,a3

plane_1:
	btst.l	d0,d3
	beq.s	plane_3
	
	lea	08(a3),a3

plane_3:
	btst.l	d0,d4
	beq.s	plane_0
	
	lea	32(a3),a3

plane_0:
	add.w	#16,d0			; d0 -> bits in hi word
	btst.l	d0,d3
	beq.s	plane_2
	
	lea	04(a3),a3

plane_2:
	btst.l	d0,d4
	beq.s	frag_jmp
	
	lea	16(a3),a3

frag_jmp:

	sub.w	#16,d0
	move.l	(a3),a3
	jmp	(a3)




*** THE TRANSPARENT COLOR FRAGMENT RETURNS HERE UPON TERMINATION ***

rtnxp411:

	dbra	d7,new_src_pix		; one more pixel bytes the dust.

xp_eol:

	move.l	d5,(a1)+		; flush the destination buffer
	move.l	d6,(a1)+

	add.w	D_NXLN(a6),a5		; a5 -> next dst line

	move.w	Y_FINC(a6),d0
	add.w	d0,Y_FRAC(a6)
	bcc.s	same_s_line

	add.w	S_NXLN(a6),a4		; a4 -> next src line

	swap	d7			; d7[15:00] <- height count
	dbra	d7,scale_loop

	bra	final_resting_place




*** THE OPAQUE COLOR FRAGMENT RETURNS HERE UPON TERMINATION ***

rtnop411:

	dbra	d7,new_src_pix		; one more pixel bytes the dust.

op_eol:

	move.l	d5,(a1)+		; flush the destination buffer
	move.l	d6,(a1)+

next_d_line:

	move.w	Y_FINC(a6),d0
	add.w	d0,Y_FRAC(a6)		; update Y inc counter
	bcc.s	copy_d_line		; repeat present line unless rollover


	add.w	S_NXLN(a6),a4		; a4 -> next source line
	add.w	D_NXLN(a6),a5		; a5 -> next destination line

	swap	d7			; d7[15:00] <- height count
	dbra	d7,scale_loop

	bra	final_resting_place



*  copy last line scaled to next line of destination

copy_d_line:

	move.l	a5,a0			; a0 -> source of copy
	add.w	D_NXLN(a6),a5		; a5 -> next line in destination
	move.l	a5,a1			; a1 -> target of copy

	move.l	D_LMSK(a6),d5		; d5 <- left mask
	move.l	D_RMSK(a6),d6		; d6 <- right mask
	move.w	D_SPAN(a6),d2		; d2 <- word count -1


*  mask is positive for source


l_fringe:

*  planes 0 and 1

	move.l	(a0)+,d3		; d3   <- src0
	move.l	(a1),d4			; d4   <- dst
	eor.l	d4,d3			; src1 <- src0 xor dst
	and.l	d5,d3			; src2 <- src1 and mask
	eor.l	d4,d3			; src3 <- src2 xor dst   (dst|src)
	move.l	d3,(a1)+		; dst  <- dst|src

*  planes 2 and 3

	move.l	(a0)+,d3		; d3   <- src0
	move.l	(a1),d4			; d4   <- dst
	eor.l	d4,d3			; src1 <- src0 xor dst
	and.l	d5,d3			; src2 <- src1 and mask
	eor.l	d4,d3			; src3 <- src2 xor dst   (dst|src)
	move.l	d3,(a1)+		; dst  <- dst|src

	subq.w	#1,d2
	bcs.s	next_d_line		; one fringe case

	subq.w	#1,d2
	bcs.s	r_fringe		; two fringe case


center:

	move.l	(a0)+,(a1)+		; splat the center words
	move.l	(a0)+,(a1)+
	dbra	d2,center


r_fringe:

*  planes 0 and 1

	move.l	(a0)+,d3		; d3   <- src0
	move.l	(a1),d4			; d4   <- dst
	eor.l	d4,d3			; src1 <- src0 xor dst
	and.l	d6,d3			; src2 <- src1 and mask
	eor.l	d4,d3			; src3 <- src2 xor dst   (dst|src)
	move.l	d3,(a1)+		; dst  <- dst|src


*  planes 2 and 3

	move.l	(a0)+,d3		; d3   <- src0
	move.l	(a1), d4		; d4   <- dst
	eor.l	d4,d3			; src1 <- src0 xor dst
	and.l	d6,d3			; src2 <- src1 and mask
	eor.l	d4,d3			; src3 <- src2 xor dst   (dst|src)
	move.l	d3,(a1)+		; dst  <- dst|src

	bra.s	next_d_line		; repeat when necessary

	end
