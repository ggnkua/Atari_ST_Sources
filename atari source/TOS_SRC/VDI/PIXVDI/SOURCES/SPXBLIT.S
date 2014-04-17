*********************************  sbblit.s  **********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbblit.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/08/06 17:34:28 $     $Locker:  $
* =============================================================================
*
* $Log:	sbblit.s,v $
*******************************************************************************


.include	"lineaequ.s"


		.globl	spx_bitblt

*       FRAME PARAMETERS

B_WD	  equ	-76	; width of block in pixels			    +00
B_HT	  equ	-74	; height of block in pixels			    +02
PLANE_CT  equ	-72	; number of consequitive planes to blt		    +04

FG_COL	  equ	-70	; foreground color (logic op table index:hi bit)    +06
BG_COL	  equ	-68	; background color (logic op table index:lo bit)    +08
OP_TAB	  equ	-66	; logic ops for all fore and background combos	    +10

S_XMIN	  equ	-62	; minimum X: source				    +14
S_YMIN	  equ	-60	; minimum Y: source				    +16
S_FORM	  equ	-58	; source form base address			    +18
S_NXWD	  equ	-54	; offset to next word in line  (in bytes)	    +22
S_NXLN	  equ	-52	; offset to next line in plane (in bytes)	    +24
S_NXPL	  equ	-50	; offset to next plane from start of current plane  +26

D_XMIN	  equ	-48	; minimum X: destination			    +28
D_YMIN	  equ	-46	; minimum Y: destination			    +30
D_FORM	  equ	-44	; destination form base address			    +32
D_NXWD	  equ	-40	; offset to next word in line  (in bytes)	    +36
D_NXLN	  equ	-38	; offset to next line in plane (in bytes)	    +38
D_NXPL	  equ	-36	; offset to next plane from start of current plane  +40

OPAQUE	=	-4

*******************************************************************************
*******************************************************************************
**									     **
**	s_xy2addr:							     **
**									     **
**		input:	d0.w =  x coordinate				     **
**			d1.w =  y coordinate				     **
**			a3.l -> line variable structure			     **
**			a6.l -> frame					     **
**									     **
**		output:	a0.l -> address of word containing x,y		     **
**									     **
**									     **
**	d_xy2addr:							     **
**									     **
**		input:	d0.w =  x coordinate.				     **
**			d1.w =  y coordinate.				     **
**			a3.l -> line variable structure			     **
**			a6.l -> frame					     **
**									     **
**		output:	a1.l -> address of word containing x,y		     **
**									     **
**		destroys: d0,d1						     **
**									     **
*******************************************************************************
*******************************************************************************

s_xy2addr:	move.l	S_FORM(a6),a0		; a0 -> strt of srce form (0,0)
		mulu	byte_per_pix(a3),d0	; d0 <- x portion of offset
		mulu	S_NXLN(a6),d1		; d1 <- y portion of offset
		add.l	d0,d1			; d1 <- byte offs into mem frm
		add.l	d1,a0			; a0 -> (x,y)
		rts

d_xy2addr:	move.l	D_FORM(a6),a0		; a0 -> strt of dst form (0,0)
		mulu	byte_per_pix(a3),d0	; d0 <- x portion of offset
		mulu	D_NXLN(a6),d1		; d1 <- y portion of offset
		add.l	d0,d1			; d1 <- byte offs into mem frm
		add.l	d1,a0			; a0 -> (x,y)
		rts
	

*+
* purpose:	set up parameters for bitblt and thread together the
*		appropriate bitblt fragments for software implementation
*		of bitblt
*
* in:		d0.w	Xmin source
*		d2.w	Xmin destination
*		d4.w	Xmax source
*		d6.w	Xmax destination
*
*		a6.l	points to frame with following parameters set:
*
*		Ymin source, Ymax source, Ymin destination, Ymax destination
*		Xmin source, Xmax source, Xmin destination, Xmax destination
*		rectangle height, rectangle width, number of planes
*-
spx_bitblt:	move.l	_lineAVar,a3	; a3 -> linea variable structure
		move.w	S_YMIN(a6),d1	; d1 <- Ymin source
		bsr	s_xy2addr	; a0 -> start of source block

		move.w	D_XMIN(a6),d0	; compute address of source block
		move.w	D_YMIN(a6),d1
		bsr	d_xy2addr	; a1 -> start of destination block

		cmp.l	a1,a0		; which address is larger: src or dst
		blt	do_neg_case	; if source < dest then do neg case

		move.w	B_WD(a6),d3	; d3 <- span in pixels
		beq	leave		; leave if span is zero
		subq.w	#1,d3		; d3 <- span in pixels - 1
		move.w	B_HT(a6),d1	; d1 <- number of lines to blit
		subq.w	#1,d1		; d1 <- number of lines to blit - 1




do_neg_case:





leave:		rts


*+
*	d1.w	number fo lines to blit - 1
*	d3.w	span in pixels - 1
*	d5.w	offset to next line in source
*	d6.w	offset to next line in destination
*
*	a0	points to the source
*	a1	points to the destination
*-


*+
* D' = 0
*-
o0P32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o0P32Loop:	clr.l	(a1)+			; D <- 0
		dbra	d7,o0P32Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o0P32Line		; do next line	

*+
* D' = S AND D
*-
o1P32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o1P32Loop:	and.l	(a0)+,(a1)+		; D <- S
		dbra	d7,o1P32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o1P32Line		; do next line	

*+
* D' = S AND [NOT D]
*-
o2P32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o2P32Loop:	not.l	(a1)			; D' = NOT D
		and.l	(a0)+,(a1)+		; D' = S AND [NOT D]
		dbra	d7,o2P32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o2P32Line		; do next line	

*+
* D' = S (Replace Mode)
*-
o3P32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o3P32Loop:	move.l	(a0)+,(a1)+		; D' = S
		dbra	d7,o3P32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o3P32Line		; do next line	

*+
* D' = [NOT S] AND D (Erase Mode)
*-
o4P32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o4P32Loop:	move.l	(a0)+,d2		; d2 <- S
		not.l	d2			; d2 <- NOT S
		and.l	d2,(a1)+		; D' = [NOT S] AND D
		dbra	d7,o4P32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o4P32Line		; do next line	

*+
* D' = D
*-
o5P32Line:	rts
	
*+
* D' = S XOR D
*-
o6P32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o6P32Loop:	eor.l	(a0)+,(a1)+		; D' = S XOR D
		dbra	d7,o6P32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o6P32Line		; do next line	

*+
* D' = S OR D
*-
o7P32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o7P32Loop:	or.l	(a0)+,(a1)+		; D' = S OR D
		dbra	d7,o7P32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o7P32Line		; do next line	

*+
* D' = NOT [S OR D]
*-
o8P32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o8P32Loop:	or.l	(a0)+,(a1)		; D' = S OR D
		not.l	(a1)+			; D' = NOT [S OR D]
		dbra	d7,o8P32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o8P32Line		; do next line	

*+
* D' = NOT [S XOR D]
*-
o9P32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o9P32Loop:	eor.l	(a0)+,(a1)		; D' = S XOR D
		not.l	(a1)+			; D' = NOT [S XOR D]
		dbra	d7,o9P32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o9P32Line		; do next line	

*+
* D' = NOT D
*-
oAP32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oAP32Loop:	not.l	(a1)+			; D' = NOT D
		dbra	d7,o3P32Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oAP32Line		; do next line	

*+
* D' = S OR [NOT D]
*-
oBP32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oBP32Loop:	not.l	(a1)			; D' = NOT D
		or.l	(a0)+,(a1)+		; D' = S OR [NOT D]
		dbra	d7,oBP32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oBP32Line		; do next line	

*+
* D' = NOT S
*-
oCP32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oCP32Loop:	move.l	(a0)+,d2		; d2 <- S
		not.l	d2			; d2 <- NOT S
		move.l	d2,(a1)+		; D' = NOT S
		dbra	d7,oCP32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oCP32Line		; do next line	

*+
* D' = [NOT S] OR D
*-
oDP32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oDP32Loop:	move.l	(a0)+,d2		; d2 <- S
		not.l	d2			; d2 <- NOT S
		or.l	d2,(a1)+		; D' = [NOT S] OR D
		dbra	d7,oDP32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oDP32Line		; do next line		

*+
* NOT [S AND D]
*-
oEP32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oEP32Loop:	and.l	(a0)+,(a1)		; D' = S AND D
		not.l	(a1)+			; D' = NOT [S AND D
		dbra	d7,oEP32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oEP32Line		; do next line	

*+
* D' = 1
*-
oFP32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oFP32Loop:	move.l	#1,(a1)+		; D' = 1
		dbra	d7,oFP32Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oFP32Line		; do next line	
		

*****************************************
******************************* 16 bit case
*****************************************

*+
* D' = 0
*-
o0P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o0P16Loop:	clr.w	(a1)+			; D <- 0
		dbra	d7,o0P16Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o0P16Line		; do next line	

*+
* D' = S AND D
*-
o1P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o1P16Loop:	and.w	(a0)+,(a1)+		; D <- S
		dbra	d7,o1P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o1P16Line		; do next line	

*+
* D' = S AND [NOT D]
*-
o2P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o2P16Loop:	not.w	(a1)			; D' = NOT D
		and.w	(a0)+,(a1)+		; D' = S AND [NOT D]
		dbra	d7,o2P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o2P16Line		; do next line	

*+
* D' = S (Replace Mode)
*-
o3P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o3P16Loop:	move.w	(a0)+,(a1)+		; D' = S
		dbra	d7,o3P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o3P16Line		; do next line	

*+
* D' = [NOT S] AND D (Erase Mode)
*-
o4P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o4P16Loop:	move.w	(a0)+,d2		; d2 <- S
		not.w	d2			; d2 <- NOT S
		and.w	d2,(a1)+		; D' = [NOT S] AND D
		dbra	d7,o4P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o4P16Line		; do next line	

*+
* D' = D
*-
o5P16Line:	rts
	
*+
* D' = S XOR D
*-
o6P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o6P16Loop:	eor.w	(a0)+,(a1)+		; D' = S XOR D
		dbra	d7,o6P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o6P16Line		; do next line	

*+
* D' = S OR D
*-
o7P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o7P16Loop:	or.w	(a0)+,(a1)+		; D' = S OR D
		dbra	d7,o7P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o7P16Line		; do next line	

*+
* D' = NOT [S OR D]
*-
o8P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o8P16Loop:	or.w	(a0)+,(a1)		; D' = S OR D
		not.w	(a1)+			; D' = NOT [S OR D]
		dbra	d7,o8P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o8P16Line		; do next line	

*+
* D' = NOT [S XOR D]
*-
o9P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o9P16Loop:	eor.w	(a0)+,(a1)		; D' = S XOR D
		not.w	(a1)+			; D' = NOT [S XOR D]
		dbra	d7,o9P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o9P16Line		; do next line	

*+
* D' = NOT D
*-
oAP16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oAP16Loop:	not.w	(a1)+			; D' = NOT D
		dbra	d7,o3P16Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oAP16Line		; do next line	

*+
* D' = S OR [NOT D]
*-
oBP16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oBP16Loop:	not.w	(a1)			; D' = NOT D
		or.w	(a0)+,(a1)+		; D' = S OR [NOT D]
		dbra	d7,oBP16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oBP16Line		; do next line	

*+
* D' = NOT S
*-
oCP16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oCP16Loop:	move.w	(a0)+,d2		; d2 <- S
		not.w	d2			; d2 <- NOT S
		move.w	d2,(a1)+		; D' = NOT S
		dbra	d7,oCP16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oCP16Line		; do next line	

*+
* D' = [NOT S] OR D
*-
oDP16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oDP16Loop:	move.w	(a0)+,d2		; d2 <- S
		not.w	d2			; d2 <- NOT S
		or.w	d2,(a1)+		; D' = [NOT S] OR D
		dbra	d7,oDP16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oDP16Line		; do next line		

*+
* NOT [S AND D]
*-
oEP16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oEP16Loop:	and.w	(a0)+,(a1)		; D' = S AND D
		not.w	(a1)+			; D' = NOT [S AND D
		dbra	d7,oEP16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oEP16Line		; do next line	

*+
* D' = 1
*-
oFP16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oFP16Loop:	move.w	#1,(a1)+		; D' = 1
		dbra	d7,oFP16Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oFP16Line		; do next line	


************************************
*********************** 8 bit case
************************************

*+
* D' = 0
*-
o0P8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o0P8Loop:	clr.b	(a1)+			; D <- 0
		dbra	d7,o0P8Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o0P8Line		; do next line	

*+
* D' = S AND D
*-
o1P8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o1P8Loop:	and.b	(a0)+,(a1)+		; D <- S
		dbra	d7,o1P8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o1P8Line		; do next line	

*+
* D' = S AND [NOT D]
*-
o2P8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o2P8Loop:	not.b	(a1)			; D' = NOT D
		and.b	(a0)+,(a1)+		; D' = S AND [NOT D]
		dbra	d7,o2P8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o2P8Line		; do next line	

*+
* D' = S (Replace Mode)
*-
o3P8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o3P8Loop:	move.b	(a0)+,(a1)+		; D' = S
		dbra	d7,o3P8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o3P8Line		; do next line	

*+
* D' = [NOT S] AND D (Erase Mode)
*-
o4P8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o4P8Loop:	move.b	(a0)+,d2		; d2 <- S
		not.b	d2			; d2 <- NOT S
		and.b	d2,(a1)+		; D' = [NOT S] AND D
		dbra	d7,o4P8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o4P8Line		; do next line	

*+
* D' = D
*-
o5P8Line:	rts
	
*+
* D' = S XOR D
*-
o6P8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o6P8Loop:	eor.b	(a0)+,(a1)+		; D' = S XOR D
		dbra	d7,o6P8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o6P8Line		; do next line	

*+
* D' = S OR D
*-
o7P8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o7P8Loop:	or.b	(a0)+,(a1)+		; D' = S OR D
		dbra	d7,o7P8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o7P8Line		; do next line	

*+
* D' = NOT [S OR D]
*-
o8P8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o8P8Loop:	or.b	(a0)+,(a1)		; D' = S OR D
		not.b	(a1)+			; D' = NOT [S OR D]
		dbra	d7,o8P8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o8P8Line		; do next line	

*+
* D' = NOT [S XOR D]
*-
o9P8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o9P8Loop:	eor.b	(a0)+,(a1)		; D' = S XOR D
		not.b	(a1)+			; D' = NOT [S XOR D]
		dbra	d7,o9P8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o9P8Line		; do next line	

*+
* D' = NOT D
*-
oAP8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oAP8Loop:	not.b	(a1)+			; D' = NOT D
		dbra	d7,o3P8Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oAP8Line		; do next line	

*+
* D' = S OR [NOT D]
*-
oBP8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oBP8Loop:	not.b	(a1)			; D' = NOT D
		or.b	(a0)+,(a1)+		; D' = S OR [NOT D]
		dbra	d7,oBP8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oBP8Line		; do next line	

*+
* D' = NOT S
*-
oCP8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oCP8Loop:	move.b	(a0)+,d2		; d2 <- S
		not.b	d2			; d2 <- NOT S
		move.b	d2,(a1)+		; D' = NOT S
		dbra	d7,oCP8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oCP8Line		; do next line	

*+
* D' = [NOT S] OR D
*-
oDP8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oDP8Loop:	move.b	(a0)+,d2		; d2 <- S
		not.b	d2			; d2 <- NOT S
		or.b	d2,(a1)+		; D' = [NOT S] OR D
		dbra	d7,oDP8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oDP8Line		; do next line		

*+
* NOT [S AND D]
*-
oEP8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oEP8Loop:	and.b	(a0)+,(a1)		; D' = S AND D
		not.b	(a1)+			; D' = NOT [S AND D
		dbra	d7,oEP8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oEP8Line		; do next line	

*+
* D' = 1
*-
oFP8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oFP8Loop:	move.b	#1,(a1)+		; D' = 1
		dbra	d7,oFP8Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oFP8Line		; do next line	
		

**********************************************************************
*********************** Neg case
**********************************************************************

*+
* D' = 0
*-
o0N32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o0N32Loop:	clr.l	-(a1)			; D <- 0
		dbra	d7,o0N32Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o0N32Line		; do next line	

*+
* D' = S AND D
*-
o1N32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o1N32Loop:	and.l	-(a0),-(a1)		; D <- S
		dbra	d7,o1N32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o1N32Line		; do next line	

*+
* D' = S AND [NOT D]
*-
o2N32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o2N32Loop:	not.l	-(a1)			; D' = NOT D
		and.l	-(a0),(a1)		; D' = S AND [NOT D]
		dbra	d7,o2N32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o2N32Line		; do next line	

*+
* D' = S (Replace Mode)
*-
o3N32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o3N32Loop:	move.l	-(a0),-(a1)		; D' = S
		dbra	d7,o3N32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o3N32Line		; do next line	

*+
* D' = [NOT S] AND D (Erase Mode)
*-
o4N32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o4N32Loop:	move.l	-(a0),d2		; d2 <- S
		not.l	d2			; d2 <- NOT S
		and.l	d2,-(a1)		; D' = [NOT S] AND D
		dbra	d7,o4N32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o4N32Line		; do next line	

*+
* D' = D
*-
o5N32Line:	rts
	
*+
* D' = S XOR D
*-
o6N32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o6N32Loop:	eor.l	-(a0),-(a1)		; D' = S XOR D
		dbra	d7,o6N32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o6N32Line		; do next line	

*+
* D' = S OR D
*-
o7N32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o7N32Loop:	or.l	-(a0),-(a1)		; D' = S OR D
		dbra	d7,o7N32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o7N32Line		; do next line	

*+
* D' = NOT [S OR D]
*-
o8N32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o8N32Loop:	or.l	-(a0),-(a1)		; D' = S OR D
		not.l	(a1)			; D' = NOT [S OR D]
		dbra	d7,o8N32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o8N32Line		; do next line	

*+
* D' = NOT [S XOR D]
*-
o9N32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o9N32Loop:	eor.l	-(a0),-(a1)		; D' = S XOR D
		not.l	(a1)			; D' = NOT [S XOR D]
		dbra	d7,o9N32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o9N32Line		; do next line	

*+
* D' = NOT D
*-
oAN32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oAN32Loop:	not.l	-(a1)			; D' = NOT D
		dbra	d7,o3N32Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oAN32Line		; do next line	

*+
* D' = S OR [NOT D]
*-
oBN32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oBN32Loop:	not.l	-(a1)			; D' = NOT D
		or.l	-(a0),(a1)		; D' = S OR [NOT D]
		dbra	d7,oBN32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oBN32Line		; do next line	

*+
* D' = NOT S
*-
oCN32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oCN32Loop:	move.l	-(a0),d2		; d2 <- S
		not.l	d2			; d2 <- NOT S
		move.l	d2,-(a1)		; D' = NOT S
		dbra	d7,oCN32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oCN32Line		; do next line	

*+
* D' = [NOT S] OR D
*-
oDN32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oDN32Loop:	move.l	-(a0),d2		; d2 <- S
		not.l	d2			; d2 <- NOT S
		or.l	d2,-(a1)		; D' = [NOT S] OR D
		dbra	d7,oDN32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oDN32Line		; do next line		

*+
* NOT [S AND D]
*-
oEN32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oEN32Loop:	and.l	-(a0),-(a1)		; D' = S AND D
		not.l	(a1)			; D' = NOT [S AND D
		dbra	d7,oEN32Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oEN32Line		; do next line	

*+
* D' = 1
*-
oFN32Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oFN32Loop:	move.l	#1,-(a1)		; D' = 1
		dbra	d7,oFN32Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oFN32Line		; do next line	
		
***********************************
*********************** 16 bit mode
***********************************

*+
* D' = 0
*-
o0N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o0N16Loop:	clr.w	-(a1)			; D <- 0
		dbra	d7,o0N16Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o0N16Line		; do next line	

*+
* D' = S AND D
*-
o1N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o1N16Loop:	and.w	-(a0),-(a1)		; D <- S
		dbra	d7,o1N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o1N16Line		; do next line	

*+
* D' = S AND [NOT D]
*-
o2N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o2N16Loop:	not.w	-(a1)			; D' = NOT D
		and.w	-(a0),(a1)		; D' = S AND [NOT D]
		dbra	d7,o2N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o2N16Line		; do next line	

*+
* D' = S (Replace Mode)
*-
o3N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o3N16Loop:	move.w	-(a0),-(a1)		; D' = S
		dbra	d7,o3N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o3N16Line		; do next line	

*+
* D' = [NOT S] AND D (Erase Mode)
*-
o4N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o4N16Loop:	move.w	-(a0),d2		; d2 <- S
		not.w	d2			; d2 <- NOT S
		and.w	d2,-(a1)		; D' = [NOT S] AND D
		dbra	d7,o4N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o4N16Line		; do next line	

*+
* D' = D
*-
o5N16Line:	rts
	
*+
* D' = S XOR D
*-
o6N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o6N16Loop:	eor.w	-(a0),-(a1)		; D' = S XOR D
		dbra	d7,o6N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o6N16Line		; do next line	

*+
* D' = S OR D
*-
o7N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o7N16Loop:	or.w	-(a0),-(a1)		; D' = S OR D
		dbra	d7,o7N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o7N16Line		; do next line	

*+
* D' = NOT [S OR D]
*-
o8N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o8N16Loop:	or.w	-(a0),-(a1)		; D' = S OR D
		not.w	(a1)			; D' = NOT [S OR D]
		dbra	d7,o8N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o8N16Line		; do next line	

*+
* D' = NOT [S XOR D]
*-
o9N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o9N16Loop:	eor.w	-(a0),-(a1)		; D' = S XOR D
		not.w	(a1)			; D' = NOT [S XOR D]
		dbra	d7,o9N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o9N16Line		; do next line	

*+
* D' = NOT D
*-
oAN16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oAN16Loop:	not.w	-(a1)			; D' = NOT D
		dbra	d7,o3N16Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oAN16Line		; do next line	

*+
* D' = S OR [NOT D]
*-
oBN16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oBN16Loop:	not.w	-(a1)			; D' = NOT D
		or.w	-(a0),(a1)		; D' = S OR [NOT D]
		dbra	d7,oBN16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oBN16Line		; do next line	

*+
* D' = NOT S
*-
oCN16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oCN16Loop:	move.w	-(a0),d2		; d2 <- S
		not.w	d2			; d2 <- NOT S
		move.w	d2,-(a1)		; D' = NOT S
		dbra	d7,oCN16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oCN16Line		; do next line	

*+
* D' = [NOT S] OR D
*-
oDN16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oDN16Loop:	move.w	-(a0),d2		; d2 <- S
		not.w	d2			; d2 <- NOT S
		or.w	d2,-(a1)		; D' = [NOT S] OR D
		dbra	d7,oDN16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oDN16Line		; do next line		

*+
* NOT [S AND D]
*-
oEN16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oEN16Loop:	and.w	-(a0),-(a1)		; D' = S AND D
		not.w	(a1)			; D' = NOT [S AND D
		dbra	d7,oEN16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oEN16Line		; do next line	

*+
* D' = 1
*-
oFN16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oFN16Loop:	move.w	#1,-(a1)		; D' = 1
		dbra	d7,oFN16Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oFN16Line		; do next line	
		
*************************************************
****************************** 8 bit negative case
*************************************************

*+
* D' = 0
*-
o0N8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o0N8Loop:	clr.b	-(a1)			; D <- 0
		dbra	d7,o0N8Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o0N8Line		; do next line	

*+
* D' = S AND D
*-
o1N8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o1N8Loop:	and.b	-(a0),-(a1)		; D <- S
		dbra	d7,o1N8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o1N8Line		; do next line	

*+
* D' = S AND [NOT D]
*-
o2N8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o2N8Loop:	not.b	-(a1)			; D' = NOT D
		and.b	-(a0),(a1)		; D' = S AND [NOT D]
		dbra	d7,o2N8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o2N8Line		; do next line	

*+
* D' = S (Replace Mode)
*-
o3N8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o3N8Loop:	move.b	-(a0),-(a1)		; D' = S
		dbra	d7,o3N8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o3N8Line		; do next line	

*+
* D' = [NOT S] AND D (Erase Mode)
*-
o4N8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o4N8Loop:	move.b	-(a0),d2		; d2 <- S
		not.b	d2			; d2 <- NOT S
		and.b	d2,-(a1)		; D' = [NOT S] AND D
		dbra	d7,o4N8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o4N8Line		; do next line	

*+
* D' = D
*-
o5N8Line:	rts
	
*+
* D' = S XOR D
*-
o6N8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o6N8Loop:	eor.b	-(a0),-(a1)		; D' = S XOR D
		dbra	d7,o6N8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o6N8Line		; do next line	

*+
* D' = S OR D
*-
o7N8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o7N8Loop:	or.b	-(a0),-(a1)		; D' = S OR D
		dbra	d7,o7N8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o7N8Line		; do next line	

*+
* D' = NOT [S OR D]
*-
o8N8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o8N8Loop:	or.b	-(a0),-(a1)		; D' = S OR D
		not.b	(a1)			; D' = NOT [S OR D]
		dbra	d7,o8N8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o8N8Line		; do next line	

*+
* D' = NOT [S XOR D]
*-
o9N8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o9N8Loop:	eor.b	-(a0),-(a1)		; D' = S XOR D
		not.b	(a1)			; D' = NOT [S XOR D]
		dbra	d7,o9N8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o9N8Line		; do next line	

*+
* D' = NOT D
*-
oAN8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oAN8Loop:	not.b	-(a1)			; D' = NOT D
		dbra	d7,o3N8Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oAN8Line		; do next line	

*+
* D' = S OR [NOT D]
*-
oBN8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oBN8Loop:	not.b	-(a1)			; D' = NOT D
		or.b	-(a0),(a1)		; D' = S OR [NOT D]
		dbra	d7,oBN8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oBN8Line		; do next line	

*+
* D' = NOT S
*-
oCN8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oCN8Loop:	move.b	-(a0),d2		; d2 <- S
		not.b	d2			; d2 <- NOT S
		move.b	d2,-(a1)		; D' = NOT S
		dbra	d7,oCN8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oCN8Line		; do next line	

*+
* D' = [NOT S] OR D
*-
oDN8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oDN8Loop:	move.b	-(a0),d2		; d2 <- S
		not.b	d2			; d2 <- NOT S
		or.b	d2,-(a1)		; D' = [NOT S] OR D
		dbra	d7,oDN8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oDN8Line		; do next line		

*+
* NOT [S AND D]
*-
oEN8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oEN8Loop:	and.b	-(a0),-(a1)		; D' = S AND D
		not.b	(a1)			; D' = NOT [S AND D
		dbra	d7,oEN8Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oEN8Line		; do next line	

*+
* D' = 1
*-
oFN8Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oFN8Loop:	move.b	#1,-(a1)		; D' = 1
		dbra	d7,oFN8Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oFN8Line		; do next line	
		
	.end
