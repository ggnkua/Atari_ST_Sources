	
	globl	opaqu410,xprnt410,rtnop410,rtnxp410
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


*  stretch in X, shrink in Y, 4 interwoven planes
*
*
*  in:
*	a6.l	points to parameter block
*	a7.l	points to pixel fragment continuation point


opaqu410:
xprnt410:

	move.w	X_FINC(a6),a2		; a2 <- X dda increment
	move.l	S_ADDR(a6),a4		; a4 -> src
	move.l	D_ADDR(a6),a5		; a5 -> dst
	move.w	S_NXLN(a6),d2		; d2 <- offset to next src line
	move.w	HT_MIN(a6),d7		; d7 <- height
	dbra	d7,scale_loop		; d7 <- dbra height

	bra	final_resting_place	; quit if null height


scale_loop:

	move.w	Y_FINC(a6),d0
	move.w	Y_FRAC(a6),d1

nxt_s_line:

	add.w	d0,d1			; update Y inc counter
	bcs.s	new_s_line		; loop until new src line is found

	add.w	d2,a4			; a4 -> next source line
	bra.s	nxt_s_line


new_s_line:

	move.w	d1,Y_FRAC(a6)		; save Y DDA accumulator

	move.l	a4,a0			; a0 <- working src pointer
	move.l	a5,a1			; a1 <- working dst pointer

	move.w	S_XPIX(a6),d0		; d0 -> src pixel
	move.w	D_XPIX(a6),d1		; d1 -> dst pixel
	move.w	X_FRAC(a6),d2		; d2 <- X dda accumulator

	move.l	(a0)+,d3		; d3 <- 1st src longword
	move.l	(a0)+,d4		; d4 <- 2nd src longword
	move.l	(a1),d5			; d5 <- 1st dst longword
	move.l	4(a1),d6		; d6 <- 2nd dst longword

	swap	d7			; d7[31:16] <- height count
	move.w	WD_MIN(a6),d7		; d7[15:00] <- width count
	dbra	d7,get_src_pix

	bra	final_resting_place




new_src_pix:

	dbra	d0,get_src_pix		; d0 -> next pixel

	moveq.l	#15,d0			; d0 -> hi bit of next word
	move.l	(a0)+,d3		; d3 <- 1st longword of source
	move.l	(a0)+,d4		; d4 <- 2nd longword of source


get_src_pix:

	lea	pix_up_tab,a3

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


*** THE COLOR FRAGMENT RETURNS HERE UPON TERMINATION ***

rtnop410:
rtnxp410:

	dbra	d7,new_src_pix		; one more pixel bytes the dust.


end_o_line:

	move.l	d5,(a1)+		; flush the destination buffer
	move.l	d6,(a1)+

	move.w	S_NXLN(a6),d2		; d2 <- offset to next src line
	add.w	d2,a4			; a4 -> next src line
	add.w	D_NXLN(a6),a5		; a5 -> next dst line

	swap	d7			; d7[15:00] <- height count
	dbra	d7,scale_loop

	bra	final_resting_place



