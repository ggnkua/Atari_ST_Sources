*********************************  sbblit.s  **********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbblit.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/08/06 17:34:28 $     $Locker:  $
* =============================================================================
*
* $Log:	sbblit.s,v $
* Revision 3.1  91/08/06  17:34:28  lozben
* Made changes so the code could work with multiple linea variable structures.
* 
* Revision 3.0  91/08/06  17:15:30  lozben
* New generation VDI
* 
* Revision 2.7  91/07/26  12:07:25  lozben
* Found a way not to put a nop. Look at comment 2.6 & label sb_blit.
* 
* Revision 2.6  91/07/26  11:34:51  lozben
* Added a nop in fron of a ".ifeq" directive. There is a bug in the assembler.
* You can't have ".ifeq" directive on the same line as a label.
* 
* Revision 2.5  91/07/08  16:29:23  lozben
* We now set COPYTRAN and OPAQUE flags when appropriate.
* 
* Revision 2.4  90/02/16  12:24:52  lozben
* Fixed some of the code so that it can be assembled with mas.
* 
* Revision 2.3  90/01/11  12:20:28  lozben
* Added code to check for the case of unaligned src to dst copy (Atari
* ST/TT screen memory format). If check turns out to be true go to new
* special case code.
* 
* Revision 2.2  89/12/07  12:12:04  lozben
* Added code to make a call to scrn_wrd_blt in proper cases. The routine
* does a fast source to destination blit, which is on the same pixel
* boundaries.
* 
* Revision 2.1  89/02/21  17:24:32  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************

.include	"vdiincld.s"

	.globl	sb_bitblt,set_fringe,get_fringe,d_xy2addr,s_xy2addr
	.globl	scrn_blt,_copytran

	.globl	f0_l2r_rt,f1_l2r_rt,f2_l2r_rt,fl_l2r_rt
	.globl	f0_l2r_lf,f1_l2r_lf,f2_l2r_lf,fl_l2r_lf
	.globl	f0_r2l_rt,f1_r2l_rt,f2_r2l_rt,fl_r2l_rt
	.globl	f0_r2l_lf,f1_r2l_lf,f2_r2l_lf,fl_r2l_lf

	.globl	f0_left,f0_right,f2_update,f1_dst,f1_drt,f2_dst,p1_update

	.globl	mode_00,mode_01,mode_02,mode_03,mode_04,mode_05,mode_06,mode_07
	.globl	mode_08,mode_09,mode_10,mode_11,mode_12,mode_13,mode_14,mode_15



*+
* purpose:	set up parameters for bitblt and thread together the
*		appropriate bitblt fragments for software implementation
*		of bitblt
*
* author:	jim eisenstein
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

P_ADDR	  equ	-34	; address of pattern buffer   (0:no pattern)	    +42
P_NXLN	  equ	-30	; offset to next line in pattern  (in bytes)	    +46
P_NXPL	  equ	-28	; offset to next plane in pattern (in bytes)	    +48
P_MASK	  equ	-26	; pattern index mask				    +50

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

***						   ***
*** more internal parameters (notice overlap above ***
***						   ***

SHFT1	=	-24
SHFT2	=	-22
MASK1	=	-20
MASK2	=	-14
MASK3	=	-12
OPAQUE	=	-4

*+
*  in:	d0.w	X min source
*	d2.w	X min destination
*	d4.w	X max source
*	d6.w	X max destination
*-
.ifeq	P68030

sb_bitblt:
	;
	; We are going to compile things in memory later on, so flush the
	; the instruction cache if we are on a 68030
	;
	movec.l	cacr,d5			; d5 <- cache control register
	bset.l	#3,d5			; set "Clr Instr Cache" bit
	movec.l	d5,cacr			; clear the instruction cache

.else

sb_bitblt:

.endc
	move.l  _lineAVar,a4		; a4 -> linea var struct
	clr.w	OPAQUE(a6)		; set OPAQUE flag off
	clr.w	_copytran		; turn blit transparant flag off

	moveq.l	#$0F,d5			; d5 <- mod 16 mask

	move.w	d0,d1
	and.w	d5,d1			; d1 <- Xmin src mod 16 
	move.w	d2,d3
	and.w	d5,d3			; d3 <- Xmin dst mod 16

	lsr.w	#4,d0			; d0 <- Xmin source word offset
	lsr.w	#4,d2			; d2 <- Xmin destination word offset
	lsr.w	#4,d4			; d4 <- Xmax source word offset
	lsr.w	#4,d6			; d6 <- Xmax destination word offset

	sub.w	d0,d4			; d4 <- # source words - 1
	sub.w	d2,d6			; d6 <- # destination words - 1

	move.w	d4,d5
	sub.w	d6,d5			; d5 <- # src. words - # dst. words 

	sub.w	d3,d1			; d1 <- (Sxmin mod 16) - (Dxmin mod 16)	

	move.w	d4,d7			; and both src and dst occupy
	add.w	d6,d7			; three or more words apiece ...
	cmp.w	#4,d7
	bcs	std_blt

	tst.l	P_ADDR(a6)		; and no pattern is involved ...
	bne	std_blt			; do the special word aligned blt

	move.w	PLANE_CT(a6),d7		; d7 <- # planes
	lsl.w	#1,d7			; make d7 word offset

	cmp.w	D_NXWD(a6),d7		; see if we are in ST interleved plns
	bne	sbBl0			; if not, do other more general case
	cmp.w	#2,D_NXPL(a6)		; see if we are in ST interleaved plns
	bne	sbBl0			; if not, do other more general case

	cmp.w	S_NXWD(a6),d7		; see if we are in ST intrleaved plns
	bne	trns_blt		; if not, do other cases
	cmp.w	#2,S_NXPL(a6)		; see if we are in ST interleaved plns
	bne	trns_blt		; if not, do other cases

	tst.l	FG_COL(a6)		; and fore and back colors are 0 ... 
	bne	opaque_blt	
	cmp.b	#03,OP_TAB(a6)		; and D'<- S is the logic operation ...	
	bne	opaque_blt
	jmp	scrn_blt		; do fast non tearing blit

opaque_blt:
	move.w	#1,OPAQUE(a6)		; d2 <- OPAQUE flag on
	jmp	scrn_blt		; do fast non tearing blit

trns_blt:
	cmp.w	#2,S_NXWD(a6)		; see if next source word is word away
	bne	sbBl0			; if not do other more general case
	cmp.w	#0,S_NXPL(a6)		; see if doing transparant blit
	bne	sbBl0			; if so do fast non tearing blit
	move.w	#-1,_copytran		; turn blit transparant flag on
	jmp	scrn_blt

sbBl0:	tst	d1			; see if S and D are pixel aligned
	bne	std_blt			; if Xmin src mod16 = Xmin DST mod16 ..
	bra	word_blt		; if so do pixel aligned blit D' <- S


std_blt:

*  in:
*	d1.w	(source Xmin mod 16)-(destination Xmin mod 16)
*	d4.w	words in source -1
*	d5.w	source words - destination words
*	d6.w	words in destination -1
*
* produce:
*
*	d4.w	rotation count
*	d5.w	configuration code:
*
*			bit  0	   logical shift direction	rt:1   lf:0
*
*			bit  1     actual shift direction:
*
*				   1: opposite of logical shift 
*				   0: same direction as shift
*
*
*			bit  2	   blt direction		r2l:1 l2r:0
*
*			bit  3    source width : destination width
*				   
*				   0: source words =  destination words
*				   1: source words <> destination words 
*
*		note: width delta is either 1 word or 0 words


	move.w	d6,d0			; d6 <- destination words -1
	subq.w	#1,d0			; d0 <- initial inner loop counter
	move.w	d0,INNER_CT(a6)

	and.w	#1,d5			;    0:S=D     1:S<>D
	lsl.w	#3,d5			; 0000:S=D  1000:S<>D

	move.w	d4,d7			; d7 <- source words -1

	move.w	d1,d4			; d4 <- (Sxmin mod 16) - (Dxmin mod 16)
	move.w	d1,d2			; d2 might be used as tie breaker


*   set logical shift direction

	tst.w	d4
	bgt	act_shift		; Smod16-Dmod16 > 0 => logical lf shift
	beq	start_addr		; zero is special case (pure lf rotate)

	neg.w	d4			; d4 <- positive shift value
	addq.w	#1,d5			; Smod16-Dmod16 < 0 => logical rt shift
		
act_shift:	

	cmp.w	#8,d4
	blt	start_addr

	addq.w	#2,d5			; actual shift is opposite direction
	neg.w	d4			; from logical shift direction
	add.w	#16,d4



start_addr:

*   calculate starting addresses for source and destination. use these
*   addresses to determine direction of transfer.



	move.w	S_XMIN(a6),d0		; compute address of destination block
	move.w	S_YMIN(a6),d1
	bsr	s_xy2addr		; a0 -> start of block

	muls	S_NXWD(a6),d7		; d7 <- row width offset (source)
	sub.w	d3,d7			; d7 <- SRC_WR (for r2l xfer)


	move.w	D_XMIN(a6),d0		; compute address of destination block
	move.w	D_YMIN(a6),d1
	move.w	d1,P_INDX(a6)		; save destination Y for pattern index
	bsr	d_xy2addr		; a1 -> start of block

	muls	D_NXWD(a6),d6		; d6 <- row width offset (destination)
	sub.w	d3,d6			; d6 <- DST_WR: row wd-form wrap: r2l

	cmp.l	a1,a0			; a0 -> start of source block
	bhi	t2b_l2r			; SRC addr > DST addr  =>  t2b/l2r
	bne	b2t_r2l			; SRC addr < DST addr  =>  b2t/r2l

	tst.w	d2			; position within word => xfer dir
	bge	t2b_l2r			; t2b/l2r when source addr => dst


b2t_r2l:

	addq.w	#4,d5			; set the "right to left" flag

	move.w	S_XMAX(a6),d0		; compute address of src low rt corner
	move.w	S_YMAX(a6),d1
	bsr	s_xy2addr		; a0 -> end of source block

	move.w	D_XMAX(a6),d0		; compute address of dst low rt corner
	move.w	D_YMAX(a6),d1
	move.w	d1,P_INDX(a6)		; save destination Y for pattern index
	bsr	d_xy2addr		; a1 -> end of destination block

	neg.w	P_NXLN(a6)		; reverse dir of pattern traversal

	bra	big_fringe


t2b_l2r:

	neg.w	d7			; d7 <- SRC_WR (form wrap-row wd: l2r)
	neg.w	d6			; d6 <- DST_WR


big_fringe:

	move.w	d7,SRC_WR(a6)		; source wrap
	move.w	d6,DST_WR(a6)		; destination wrap

	bsr	get_fringe

	move.w	S_NXWD(a6),d2		; d2 <- source increment
	move.w	D_NXWD(a6),d3		; d3 <- destination increment

	btst.l	#2,d5			; r2l case => swap fringes
	beq	save_addr		; and negate inter word increments

	swap	d6
	neg.w	d2
	neg.w	d3

save_addr:

	move.l	a0,S_ADDR(a6)		; save source address for other planes
	move.l	a1,D_ADDR(a6)		; save dst address for other planes

	asl.w	#3,d5			; d5(07:00) offset to fragment record

	move.l	frag_tab+04(pc,d5.w),a3	; a3 <- thread from op frag to in loop
	move.l	frag_tab+00(pc,d5.w),a4	; a4 <- thread from update frag to
					;     1st fringe
	
	tst.w	INNER_CT(a6)		; INNER_CT = -1  =>  Destination is 
	bge	pre_flight		; only one word wide. (a special case)

	move.l	d6,d0
	swap	d0
	and.w	d0,d6			; d6(15:00) <- single word fringe mask

	lea	f2_update,a3		; a3 <- thread that bypasses 2nd fringe

	btst.l	#6,d5			
	bne	pre_flight		; skip if source is 2 words wide

	lsr.w	#1,d5			; entries are 4 bytes wide
	and.w	#$C,d5
	move.l	solo_tab(pc,d5.w),a4	; a4 <- thread from update frag to
					;     1st fringe
	bra	pre_flight


solo_tab:

	dc.l	f0_left			; no reverse logical lf physical left
	dc.l	f0_right		; no reverse logical rt physical right
	dc.l	f0_right		;    reverse logical lf physical right
	dc.l	f0_left			;    reverse logical rt physical left


                                                   
*	0000:l2rf1fll  0001:l2rf0f2r  0010:l2rf1flr  0011:l2rf0f2l
*	0100:r2lf0f2l  0101:r2lf1flr  0110:r2lf0f2r  0111:r2lf1fll
*	1000:l2rf1f2l  1001:l2rf0flr  1010:l2rf1f2r  1011:l2rf0fll
*	1100:r2lf1f2l  1101:r2lf0flr  1110:r2lf1f2r  1111:r2lf0fll
                                                   
frag_tab:                                          
*		    a4        a3

	dc.l	f1_l2r_lf,fl_l2r_lf	; l2rf1fll
	dc.l	f0_l2r_rt,f2_l2r_rt	; l2rf0f2r
	dc.l	f1_l2r_rt,fl_l2r_rt	; l2rf1flr
	dc.l   	f0_l2r_lf,f2_l2r_lf	; l2rf0f2l

	dc.l	f0_r2l_lf,f2_r2l_lf	; r2lf0f2l
	dc.l	f1_r2l_rt,fl_r2l_rt	; r2lf1flr
	dc.l	f0_r2l_rt,f2_r2l_rt	; r2lf0f2r
	dc.l	f1_r2l_lf,fl_r2l_lf	; r2lf1fll

	dc.l	f1_l2r_lf,f2_l2r_lf	; l2rf1f2l
	dc.l	f0_l2r_rt,fl_l2r_rt	; l2rf0flr
	dc.l	f1_l2r_rt,f2_l2r_rt	; l2rf1f2r
	dc.l   	f0_l2r_lf,fl_l2r_lf	; l2rf0fll

	dc.l	f1_r2l_lf,f2_r2l_lf	; r2lf1f2l
	dc.l	f0_r2l_rt,fl_r2l_rt	; r2lf0flr
	dc.l	f1_r2l_rt,f2_r2l_rt	; r2lf1f2r
	dc.l	f0_r2l_lf,fl_r2l_lf	; r2lf0fll


pre_flight:

	tst.l	P_ADDR(a6)		; pattern and source ?
	beq	next_plane		; no pattern if pointer is null

	lea	p1_update,a5		; a4 -> pattern controller
	exg	a5,a4			; a5 -> first fringe

	move.w	P_NXLN(a6),d0		; set up initial pattern line index
	bge	first_index

	neg	d0

first_index:

	muls	P_INDX(a6),d0		; initial Y * delta Y
	move.w	d0,P_INDX(a6)


next_plane:

	clr.w	d0			; select the logic op based on current
	lsr.w	FG_COL(a6)		; background and foreground color for
	addx.w	d0,d0			; the given plane. logic ops (wd wide)
	lsr.w	BG_COL(a6)		; located sequentially in OP_TAB table
	addx.w	d0,d0			; as fg0/bg0 fg0/bg1 fg1/bg0 fg1/bg1

	move.b	OP_TAB(a6,d0.w),d0	; d0 <- appropriate logic op
	move.w	d0,d1
	lsl.w	#2,d1			; d1 <- offset into logic op table
	move.l	log_op(pc,d1.w),a2	; a2 <- thread to appropriate logic op

	move.w	B_HT(a6),d5		; d5(31:16) <- row count
	swap	d5
	move.w	INNER_CT(a6),d5		; d5(15:00) <- inner loop counter

	move.w	#%1000010000100001,d1	; logic ops 15,10,5,0 are special cases
	btst.l	d0,d1			; where operation is performed
					;     directly upon
	bne	unary_blt		; the dst independent of the source

	tst.l	P_ADDR(a6)		; skip this stuff if no pattern
	beq	do_the_blt

	lea	-2(a2),a2		; a2 -> pattern and source + logic op

	move.w	P_INDX(a6),d7		; d7(31:16) <- initial pattern index
	swap	d7

do_the_blt:

	jsr	(a4)			; blt the plane

np_cont:

	subq.w	#1,PLANE_CT(a6)
	beq	quit_blt

	move.l	S_ADDR(a6),a0		; a0 -> next source plane
	add.w	S_NXPL(a6),a0
	move.l	a0,S_ADDR(a6)

	move.l	D_ADDR(a6),a1		; a1 -> next destination plane
	add.w	D_NXPL(a6),a1
	move.l	a1,D_ADDR(a6)

	move.l	P_ADDR(a6),d0		; update pattern plane base pointer
	beq	next_plane		; if pointer isn't null

	move.l	d0,a2
	add.w	P_NXPL(a6),a2
	move.l	a2,P_ADDR(a6)
	bra	next_plane


quit_blt:

	rts


log_op:
	dc.l   	mode_00,mode_01,mode_02,mode_03,mode_04,mode_05,mode_06,mode_07
	dc.l	mode_08,mode_09,mode_10,mode_11,mode_12,mode_13,mode_14,mode_15



unary_blt:

	cmp.w	#05,d0			; logic op 5 is a nop
	beq	np_cont

	movem.l	a3-a4,-(sp)		; save routine threads

	lea	f1_dst,a4		; a4 -> start of unary blt
	lea	f2_dst,a3		; a3 <- logic op return thread (wd >1)
	tst.w	d5			; different thread if width =1

	bge	call_unary

	lea	f1_drt,a3		; a3 <- logic op return thread (wd =1)

call_unary:

	jsr	(a4)

	movem.l	(sp)+,a3-a4
	bra	np_cont




*   get fringe masks for right and left sides
*
*  in:
*	a6.l		frame pointer
*	D_XMAX(a6)	destination X max
*	D_XMIN(a6)	destination X min
*
* out:
*	d0.w		trash
*
*	d6(15:00)	left fringe mask
*	d6(31:16)	right fringe mask

get_fringe:

*   right mask first


	move.w	D_XMAX(a6),d0		; d0 <- Xmax of DESTINATION
	and.w	#$F,d0			; d0 <- Xmax mod 16
	add.w	d0,d0			; d0 <- offset to right fringe mask
	move.w	fr_r_mask(pc,d0.w),d6	; d6 <- right fringe mask

	swap	d6			; d6(31:16) <- right fringe mask

*   now the left mask

	move.w	D_XMIN(a6),d0		; d0 <- Xmin of DESTINATION
	and.w	#$F,d0			; d0 <- Xmax mod 16
	add.w	d0,d0			; d0 <- offset to left fringe mask
	move.w	fr_l_mask(pc,d0.w),d6	; d6 <- left fringe mask

	not.w	d6			; d6(15:00) <- left fringe mask

	rts


fr_l_mask:

	dc.w	$0000	

fr_r_mask:

	dc.w	$8000
	dc.w	$C000
	dc.w	$E000
	dc.w	$F000
	dc.w	$F800
	dc.w	$FC00
	dc.w	$FE00
	dc.w	$FF00
	dc.w	$FF80
	dc.w	$FFC0
	dc.w	$FFE0
	dc.w	$FFF0
	dc.w	$FFF8
	dc.w	$FFFC
	dc.w	$FFFE
	dc.w	$FFFF



*******************************************************************************
*******************************************************************************
**									     **
**	s_xy2addr:							     **
**									     **
**		input:	d0.w =  x coordinate.				     **
**			d1.w =  y coordinate.				     **
**			a6.l -> frame					     **
**									     **
**		output:	d3.w =  line wrap (in bytes)			     **
**			a0.l -> address of word containing x,y		     **
**									     **
**									     **
**	d_xy2addr:							     **
**									     **
**		input:	d0.w =  x coordinate.				     **
**			d1.w =  y coordinate.				     **
**			a6.l -> frame					     **
**									     **
**		output: d3.w =  line wrap (in bytes)			     **
**			a1.l -> address of word containing x,y		     **
**									     **
**									     **
**	        physical offset =  (y*bytes_per_line) + (x/16)*word_offset   **
**									     **
**		destroys: d0,d1						     **
**									     **
*******************************************************************************
*******************************************************************************


s_xy2addr:

	move.l	S_FORM(a6),a0		; a0 -> start of source form (0,0)
	move.w	S_NXLN(a6),d3		; d3 <- inter line offset

	lsr.w	#4,d0			; d0 <- X word count
	muls	S_NXWD(a6),d0		; d0 <- x portion of offset

	muls	d3,d1			; d1 <- y portion of offset

	add.l	d0,d1			; d1 <- byte offset into memory form
	add.l	d1,a0			; a0 -> word containing (x,y)

	rts



d_xy2addr:

	move.l	D_FORM(a6),a1		; a0 -> start of destination form (0,0)
	move.w	D_NXLN(a6),d3		; d3 <- inter line offset

	lsr.w	#4,d0			; d0 <- X word count
	muls	D_NXWD(a6),d0		; d0 <- x portion of offset

	muls	d3,d1			; d1 <- y portion of offset

	add.l	d0,d1			; d1 <- byte offset into memory form
	add.l	d1,a1			; a1 -> word containing (x,y)

	rts




word_blt:

*  in:
*	d4.w	words in source -1
*	d6.w	words in destination -1
*

*   1st.  get initial address of transfer and calculate wrap values

	move.w	d4,d0
	subq.w	#2,d0			; d0 <- inner loop counter (count-1)
	move.w	d0,INNER_CT(a6)		; save initial count

	move.w	S_NXWD(a6),d5		; d5 <- next word increment (l2r src)
	muls	d5,d4			; d4 <- row width offset in bytes (src)

	move.w	D_NXWD(a6),d7		; d7 <- next word increment (l2r dest)
	muls	d7,d6			; d6 <- row width offset in bytes (dst)


	move.w	S_XMIN(a6),d0		; compute address of destination block
	move.w	S_YMIN(a6),d1
	bsr	s_xy2addr		; a0 -> start of source block

	sub.w	d3,d4			; d4 <- SRC_WR (r2l)

	move.w	D_XMIN(a6),d0		; compute address of source block
	move.w	D_YMIN(a6),d1
	bsr	d_xy2addr		; a1 -> start of destination block

	sub.w	d3,d6			; d6 <- DST_WR (r2l)


	cmp.l	a1,a0			; which address is larger: src or dst
	bcc	l2r_t2b			; select dir based on address order


r2l_b2t:

	move.w	S_XMAX(a6),d0		; compute address of src low rt corner
	move.w	S_YMAX(a6),d1
	bsr	s_xy2addr		; a0 -> end of src block

	move.w	D_XMAX(a6),d0		; compute address of dst low rt corner
	move.w	D_YMAX(a6),d1
	bsr	d_xy2addr		; a1 -> end of destination block

	neg.w	d5			; d2 <- next word increment (r2l src)
	neg.w	d7			; d5 <- next word increment (r2l dst)

	bra	set_fringe


l2r_t2b:

	neg.w	d4			; d4 <- SRC_WR (l2r)
	neg.w	d6			; d6 <- DST_WR (l2r)


set_fringe:

	move.w	d5,d2			; d2 <- src inter word increment
	move.w	d7,d3			; d3 <- dst inter word increment

	move.w	d4,a4			; source wrap       (SRC_WR)
	move.w	d6,a5			; destination wrap  (DST_WR)

	bsr	get_fringe

	tst.w	d2			; d2<0 => r2l. swap masks
	bpl	fringe_ok

	swap	d6

fringe_ok:


*   set up word to word increment values  

	move.l	a0,S_ADDR(a6)		; save src address for other planes
	move.l	a1,D_ADDR(a6)		; save dst address for other planes

	move.w	B_HT(a6),d7		; d7 <- row count

	move.w	PLANE_CT(a6),d4

	bra	sc_plane


*  fast word aligned blt. general case: multiple planes


sc_mp_f1:

	move.w	(a0),d0		; d0 <- 1st SOURCE word			 8
	move.w	(a1),d1		; d1 <- 1st DESTINATION word		 8
	eor.w	d1,d0		;					 4
	and.w	d6,d0		;					 4
	eor.w	d1,d0		;					 4
	move.w	d0,(a1)		; D' <- S				 8

	adda.w	d2,a0		; a0 -> 2nd SOURCE word			 8
	adda.w	d3,a1		; a1 -> 2nd DESTINATION word		 8

sc_mp_loop:

	move.w	(a0),(a1)	; DEST <- SOURCE			12

	adda.w	d2,a0		; a0 -> next SOURCE word		 8
	adda.w	d3,a1		; a1 -> next DESTINATION word		 8

	dbra	d5,sc_mp_loop	;				   (10)/14

sc_mp_f2:

	swap	d6		; d6 <- second fringe			 4
	move.w	(a0),d0		; d0 <- SOURCE last word		 8
	move.w	(a1),d1		; d1 <- DESTINATION last word		 8
	eor.w	d1,d0		;					 4
	and.w	d6,d0		;					 4
	eor.w	d1,d0		;					 4
	move.w	d0,(a1)		; D' <- S				 8
	swap	d6		; d6 <- first fringe			 4

	add.w	a4,a0		; a0 -> next SOURCE row			 8
	add.w	a5,a1		; a1 -> next DESTINATION row		 8

sc_mp_enter:

	move.w	INNER_CT(a6),d5 ; reinitialize inner loop counter	12
	dbra	d7,sc_mp_f1	; do next row			   (10)/14


	move.w	B_HT(a6),d7	; d7 <- row counter

	move.l	S_ADDR(a6),a0	; advance to next plane
	move.l	D_ADDR(a6),a1
	add.w	S_NXPL(a6),a0
	add.w	D_NXPL(a6),a1	
	move.l	a0,S_ADDR(a6)
	move.l	a1,D_ADDR(a6)


sc_plane:

	dbra	d4,sc_mp_enter

	rts


	end
