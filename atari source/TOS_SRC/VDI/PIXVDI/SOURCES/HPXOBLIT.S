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
.include	"vdiincld.s"

		.globl	hpx_bitblt
		.globl	spx_tbitblt

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

***					    			    ***
***   these parameters are internally set, some have dual purpose   ***
***					                            ***

P_INDX	  equ	-24	; initial pattern index				    +52

S_ADDR	  equ	-22	; initial source address 			    +54
S_XMAX	  equ	-18	; maximum X: source				    +58
S_YMAX	  equ	-16	; maximum Y: source				    +60

D_ADDR	  equ	-14	; initial destination address			    +62
D_XMAX	  equ	-10	; maximum X: destination			    +66
D_YMAX	  equ	-08	; maximum Y: destination			    +68

INNER_CT  equ	-06	; blt inner loop initial count			    +70
DST_WR	  equ	-04	; destination form wrap (in bytes)		    +72
SRC_WR	  equ	-02	; source form wrap (in bytes)			    +74


*  offsets into the BLASTER register block for the new blit ST
*
*  note:  base address = BLASTER+B_OFF
*
*	because the SKEW register may be accessed via an
*	"address register indirect" instruction rather than an
*	"address register indirect with displacement" instruction,
*	4 cycles are saved per access
*	

B_OFF		equ	 60		; offset to reference register

B_PATTERN	equ	-60 		; pattern register file
B_S_NXWD	equ	-28 		; offset to next src word
B_S_WRAP	equ	-26 		; wrap from end of one src line to next
B_S_ADDR	equ	-24 		; initial src address
B_F1_MSK	equ	-20 		; 1st fringe mask	0:old 1:new
B_CT_MSK	equ	-18 		; center mask		0:old 1:new
B_F2_MSK	equ	-16 		; 2nd fringe mask	0:old 1:new
B_D_NXWD	equ	-14 		; offset to next dst word
B_D_WRAP	equ	-12 		; wrap from end of one dst line to next
B_D_ADDR	equ	-10 		; initial dst address
B_D_SPAN	equ	-06 		; span in words of dst block
B_HEIGHT	equ	-04 		; pixel height of block
B_LOGOP		equ	-02 		; ctrl word: src^pat combo & logic op #
B_SKEW		equ	 00		; ctrl word: flags, pat index & skew


BF_PAT		equ  	08		; combo flag: 0:all ones  1:pattern
BF_SRC		equ  	09		; combo flag: 0:all ones  1:source
BM_PAT		equ  	$0100		; combo mask: 0:all ones  1:pattern
BM_SRC		equ  	$0200		; combo mask: 0:all ones  1:source
                     
                     
BF_GO		equ  	15		; execution flag         0:false 1:true
BF_HOG		equ  	14		; hog dma flag		 0:false 1:true
BF_SM		equ  	13		; smudge flag		 0:false 1:true
BF_PF		equ  	07		; pre-fetch flag  	 0:false 1:true
BF_FQ		equ  	06		; flush queue flag 	 0:false 1:true
BM_GO		equ  	$8000		; execution mask	
BM_HOG		equ  	$4000		; hog dma mask
BM_SM		equ  	$2000		; smudge mask
BM_PF		equ  	$0080		; pre-fetch mask
BM_FQ		equ  	$0040		; flush queue mask

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
		mulu	byt_per_pix(a3),d0	; d0 <- x portion of offset
		mulu	S_NXLN(a6),d1		; d1 <- y portion of offset
		add.l	d0,d1			; d1 <- byte offs into mem frm
		add.l	d1,a0			; a0 -> (x,y)
		rts

d_xy2addr:	move.l	D_FORM(a6),a1		; a0 -> strt of dst form (0,0)
		mulu	byt_per_pix(a3),d0	; d0 <- x portion of offset
		mulu	D_NXLN(a6),d1		; d1 <- y portion of offset
		add.l	d0,d1			; d1 <- byte offs into mem frm
		add.l	d1,a1			; a0 -> (x,y)
		rts
	

*+
* purpose:	set up parameters for bitblt and thread together the
*		appropriate bitblt fragments for software implementation
*		of bitblt. We are dealing with opaque case.
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
hpx_bitblt:	
	tst.w	S_NXPL(a6)		; see if we are doing transparant blit
	bne	skip0			; if not then skip
	jmp	spx_tbitblt		; else do transparant blit

skip0:	move.l	_lineAVar,a3		; a3 -> linea variable structure
	lea	BLASTER+B_OFF,a5	; a5 -> SKEW (bit blt reference reg)
	move.w	S_YMIN(a6),d1		; d1 <- Ymin source
	bsr	s_xy2addr		; a0 -> start of source block

	move.w	D_XMIN(a6),d0		; compute address of source block
	move.w	D_YMIN(a6),d1
	bsr	d_xy2addr		; a1 -> start of destination block

	cmp.l	a1,a0			; which address is larger: src or dst
	blt	do_neg_case		; if source < dest then do neg case

	move.w	B_WD(a6),B_D_SPAN(a5)	; set span in words
	ble	leave			; leave if span is zero
	move.w	B_HT(a6),B_HEIGHT(a5)	; set height in lines
	ble	leave			; leave if number of lines is zero

	move.w	#2,B_S_NXWD(a5)		; set offset to next src word
	move.w	S_NXLN(a6),d5		; d5 <- src line wrap (in bytes)
	lsr.w	d5			; d5 <- src line wrap (in words)
	sub.w	B_WD(a6),d5		; d5 <- source linewrap - span
	addq.w	#1,d5			; last word fetch does increment
	lsl.w	d5			; offset to nxt src line in bytes
	move.w	d5,B_S_WRAP(a5)		; wrap from end of one src line to nxt
	move.l	a0,B_S_ADDR(a5)		; set starting src adr
	
	move.w	#2,B_D_NXWD(a5)		; set offset to next dst word
	move.w	D_NXLN(a6),d5		; d5 <- dst line wrap (in bytes)
	lsr.w	d5			; d5 <- dst line wrap (in words)
	sub.w	B_WD(a6),d5		; d5 <- destination linewrap - span
	addq.w	#1,d5			; last word fetch does increment
	lsl.w	d5			; offset to nxt dst line in bytes
	move.w	d5,B_D_WRAP(a5)		; wrap from end of one dst line to nxt
	move.l	a1,B_D_ADDR(a5)		; set starting dst adr
		
	move.w	#-1,B_F1_MSK(a5)	; set up the 1st fringe mask
	move.w	#-1,B_CT_MSK(a5)	; set up the center mask
	move.w	#-1,B_F2_MSK(a5)	; set up the 2nd fringe mask
		
	move.b	#2,B_LOGOP(a5)			; set halftone op to source
	move.b	OP_TAB(a6),B_LOGOP+1(a5)	; set the blit logic op

*******************************************************************************
	move.w	#$8000,(a5)		; load control word (GO:1 HOG:0)
*******************************************************************************

blt_p_sync:

	tas	(a5)			; attempt to restart blt
	nop				; this is executed prior to restart
	bmi	blt_p_sync		; quit if blt had finished

.ifeq	P68030

	movec.l	cacr,d0			; d2 <- cache control register
	bset.l	#11,d0			; set "Clr DATA Cache" bit
	movec.l	d0,cacr			; clear the data cache
.endc

leave:	rts

******************************************************************************
************************** 16 bit case negative case *************************
******************************************************************************

do_neg_case:

	move.w	S_XMAX(a6),d0		; d0 <- Xmax source
	move.w	S_YMAX(a6),d1		; d1 <- Ymax source
	bsr	s_xy2addr		; a0 -> start of source block

	move.w	D_XMAX(a6),d0		; d0 <- Xmax source
	move.w	D_YMAX(a6),d1		; d1 <- Ymax source
	bsr	d_xy2addr		; a1 -> start of destination block

	move.w	B_WD(a6),B_D_SPAN(a5)	; set span in words
	ble	leave			; leave if span is zero
	move.w	B_HT(a6),B_HEIGHT(a5)	; set height in lines
	ble	leave			; leave if number of lines is zero

	move.w	#-2,B_S_NXWD(a5)		; set offset to next src word
	move.w	S_NXLN(a6),d5		; d5 <- src line wrap (in bytes)
	lsr.w	d5			; d5 <- src line wrap (in words)
	sub.w	B_WD(a6),d5		; d5 <- source linewrap - span
	lsl.w	d5			; offset to nxt src line in bytes
	neg.w	d5			; we are going in neg direction
	move.w	d5,B_S_WRAP(a5)		; wrap from end of one src line to nxt
	move.l	a0,B_S_ADDR(a5)		; set starting src adr
	
	move.w	#-2,B_D_NXWD(a5)	; set offset to next dst word
	move.w	D_NXLN(a6),d5		; d5 <- dst line wrap (in bytes)
	lsr.w	d5			; d5 <- dst line wrap (in words)
	sub.w	B_WD(a6),d5		; d5 <- destination linewrap - span
	addq.w	#1,d5			; last word fetch does increment
	lsl.w	d5			; offset to nxt dst line in bytes
	neg.w	d5			; we are going in neg direction
	move.w	d5,B_D_WRAP(a5)		; wrap from end of one dst line to nxt
	move.l	a1,B_D_ADDR(a5)		; set starting dst adr
		
	move.w	#-1,B_F1_MSK(a5)	; set up the 1st fringe mask
	move.w	#-1,B_CT_MSK(a5)	; set up the center mask
	move.w	#-1,B_F2_MSK(a5)	; set up the 2nd fringe mask
		
	move.b	#2,B_LOGOP(a5)			; set halftone op to source
	move.b	OP_TAB(a6),B_LOGOP+1(a5)	; set the blit logic op

*******************************************************************************
 	move.w	#$8080,(a5)		; load control word (GO:1 HOG:0)
*******************************************************************************

blt_n_sync:

	tas	(a5)			; attempt to restart blt
	nop				; this is executed prior to restart
	bmi	blt_n_sync		; quit if blt had finished

.ifeq	P68030

	movec.l	cacr,d0			; d2 <- cache control register
	bset.l	#11,d0			; set "Clr DATA Cache" bit
	movec.l	d0,cacr			; clear the data cache
.endc
	rts

	.end
