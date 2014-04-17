****************************  hbbitblt.s  *******************************
*
* $Revision: 3.0 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/hbbitblt.s,v $
* =======================================================================
* $Author: lozben $	$Date: 91/01/03 15:10:24 $     $Locker:  $
* =======================================================================
*
* $Log:	hbbitblt.s,v $
* Revision 3.0  91/01/03  15:10:24  lozben
* New generation VDI
* 
* Revision 2.2  89/02/27  17:45:02  lozben
* *** initial revision ***
* 
*************************************************************************
.include 	"vdiincld.s"

	.globl	hb_bitblt
	.globl	BLASTER

*       FRAME PARAMETERS

B_WD		equ	-76	; width of block in pixels
B_HT		equ	-74	; height of block in pixels

PLANE_CT	equ	-72	; number of consequitive planes to blt

FG_COL		equ	-70	; foreground color (logic op tab index:hi bit)
BG_COL		equ	-68	; background color (logic op tab index:lo bit)
OP_TAB		equ	-66	; logic ops for all fore and background combos
S_XMIN		equ	-62	; minimum X: source
S_YMIN		equ	-60	; minimum Y: source
S_FORM		equ	-58	; source form base address
S_NXWD		equ	-54	; offset to next word in line  (in bytes)
S_NXLN		equ	-52	; offset to next line in plane (in bytes)
S_NXPL		equ	-50	; offset to next plane from start of this plane

D_XMIN		equ	-48	; minimum X: destination
D_YMIN		equ	-46	; minimum Y: destination
D_FORM		equ	-44	; destination form base address
D_NXWD		equ	-40	; offset to next word in line  (in bytes)
D_NXLN		equ	-38	; offset to next line in plane (in bytes)
D_NXPL		equ	-36	; offset to next plane from start of this plane

P_ADDR		equ	-34	; address of pattern buffer   (0:no pattern)
P_NXLN		equ	-30	; offset to next line in pattern  (in bytes)
P_NXPL		equ	-28	; offset to next plane in pattern (in bytes)
P_MASK		equ	-26	; pattern index mask

P_INDX		equ	-24	; initial pattern index

S_ADDR		equ	-22	; initial source address
S_XMAX		equ	-18	; maximum X: source	
S_YMAX		equ	-16	; maximum Y: source	

D_ADDR		equ	-14	; initial destination address
D_XMAX		equ	-10	; maximum X: destination
D_YMAX		equ	-08	; maximum Y: destination

INNER_CT	equ	-06	; blt inner loop initial count
DST_WR		equ	-04	; destination form wrap (in bytes)
SRC_WR		equ	-02	; source form wrap (in bytes)

FRAME_LEN	equ	 76




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

	.text

* name:		blastman.s
*
* author:	j.d.eisenstein
*
* purpose:	this is the VDI preamble to the BLASTER hardware bit blt.
*		this is designed to work in conjunction with _COPYRFM routine.
*		presently there is no support for pattern generation.
*		this is not designed to work with LINE A.
*
* entry point:	blast_man
*
* in:		d0	SRC X min
*		d2	DST X min
*		d4	SRC X max
*		d6	DST X max
*
*		a6	points to parameter frame



*  fringe mask tables. This table must be within 128 bytes of fringe routine
*  	  0:orignal dst  1: src op dst  * Invert lf fringe mask *

fr_lf_mask:

	dc.w	$0000	

fr_rt_mask:

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


hb_bitblt:

	lea	BLASTER+B_OFF,a5	; a5 -> SKEW (bit blt reference reg)

*  make the left and right fringe masks

	moveq.l	#$0F,d1			; d1 <- modulo 16 mask

	move.w	d2,d5			; d5 <- D_XMIN
	and.w	d1,d5			; d5 <- D_XMIN mod16
	move.w	d5,d7			; d7 <- D_XMIN mod16	
	add.w	d5,d5			; d5 <- offset into mask table
	move.w	fr_lf_mask(pc,d5.w),d3
	not.w	d3
	swap	d3			; d3[31:16] <- lf fringe mask


	move.w	d6,d5			; d5 <- D_XMAX
	and.w	d1,d5			; d5 <- D_XMAX mod16
	add.w	d5,d5			; d5 <- offset into mask table
	move.w	fr_rt_mask(pc,d5.w),d3	; d3[15:00] <- rt fringe mask


*  create discriminator (and primordial skew count)

	move.w	d0,d5			; d5 <- S_XMIN
	and.w	d1,d5			; d5 <- S_XMIN mod16
	sub.w	d5,d7			; d7 <- D_XMIN mod16 - S_XMIN mod16


*  convert X parameters to word displacements

	lsr.w	#4,d0			; d0 <- S_XMIN / 16	
	lsr.w	#4,d4			; d4 <- S_XMAX / 16	
	lsr.w	#4,d2			; d2 <- D_XMIN / 16	
	lsr.w	#4,d6			; d6 <- D_XMAX / 16	


b2t_r2l:

*  assume SRC addr < DST addr
*  calculate maximum base addresses

*  SRC max

	move.w	d4,d1			; d1 <- S_XMAX/16
	sub.w	d0,d4			; d4 <- S_SPAN-1

	muls	S_NXWD(a6),d1		; d1 <- S_XMAX/16 * S_NXWD
	
	move.w	S_YMAX(a6),d5
	muls	S_NXLN(a6),d5		; d5 <- YMAX * S_NXLN

	add.l	d1,d5			; d5 <- (YMAX * NXLN)+(XMAX/16 * NXWD)
	move.l	S_FORM(a6),a2		; a2 -> SRC form
	lea	0(a2,d5.l),a0		; a0 -> SRC block (XMAX,0)


*  DST max

	move.w	d6,d1			; d1 <- D_XMAX/16
	sub.w	d2,d6			; d6 <- D_SPAN -1
	bgt	fringe_ok		; check for single fringe case

	move.l	d3,d5			; merge both masks into one
	swap	d5			; d3[15:00] <- single fringe mask
	and.l	d5,d3			; d3[31:16] <- single fringe mask


fringe_ok:

	muls	D_NXWD(a6),d1		; d1 <- D_XMAX/16 * D_NXWD

	move.w	D_YMAX(a6),d5
	move.w	d5,P_INDX(a6)		; initial pattern index

	muls	D_NXLN(a6),d5		; d5 <- D_YMAX * D_NXLN

	add.l	d1,d5			; d5 <- (YMAX * NXLN)+(XMAX/16 * NXWD)
	move.l	D_FORM(a6),a3		; a3 -> DST form
	lea	0(a3,d5.l),a1		; a1 -> DST block (XMAX,0)

	moveq.l	#00,d1			; d1[bit3] L->R xfer   0:false 1:true

	cmp.l	a1,a0
	bgt	t2b_l2r			; S_ADDR > D_ADDR => t2b l2r
	bne	save_fringe_masks	; S_ADDR < D_ADDR => b2t r2l

	tst.w	d7			; Dx&F - Sx&F < 0 => t2b l2r
	bge	save_fringe_masks	; else		  => b2t r2l


t2b_l2r:	

*  SRC addr > DST addr
*  calculate minimum base addresses

*  SRC min


	move.w	d0,d1			; d1 <- Xmin/16
	muls	S_NXWD(a6),d1		; d1 <- Xmin/16 * NXWD

	move.w	S_YMIN(a6),d5
	muls	S_NXLN(a6),d5		; d5 <- Ymin * NXLN

	add.l	d1,d5			; d5 <- (Ymin * NXLN)+(Xmin/16 * NXWD)
	lea	0(a2,d5.l),a0		; a0 -> SRC block (XMAX)


*  DST min

	move.w	d2,d1			; d1 <- Xmin/16
	muls	D_NXWD(a6),d1		; d1 <- Xmin/16 * NXWD

	move.w	D_YMIN(a6),d5
	move.w	d5,P_INDX(a6)		; initial pattern index
	muls	D_NXLN(a6),d5		; d5 <- Ymin * NXLN

	add.l	d1,d5			; d5 <- (Ymin * NXLN)+(Xmin/16 * NXWD)
	lea	0(a3,d5.l),a1		; a1 -> DST block (XMIN)

	moveq.l	#08,d1			; d1[bit3] L->R xfer   0:false 1:true

	swap	d3			; lf fringe is 1st fringe


save_fringe_masks:

	move.w	#$FFFF,B_CT_MSK(a5)	; load center fringe

	move.w	d3,B_F1_MSK(a5)		; load first fringe
	swap	d3
	move.w	d3,B_F2_MSK(a5)		; load second fringe

	move.w	d6,d0			; d0 <- B_D_SPAN -1
	addq.w	#1,d0			; d0 <- B_D_SPAN
	move.w	d0,B_D_SPAN(a5)		; load blt with DST word span

	tst.w	d7			; d7 = Dx&F - Sx&F
	bge	compare_spans

	addq.w	#2,d1			; d1[bit1] Sx&F>Dx&F    0:false 1:true


compare_spans:

	cmp.w	d4,d6
	bne	calculate_wrap

	addq.w	#4,d1			; d1[bit2] spans equal  0:false 1:true


calculate_wrap:

	move.w	S_NXWD(a6),d2
	move.w	D_NXWD(a6),d3

	move.w	d4,d0			; d0 <- S_SPAN-1

	muls	d2,d4			; S_WRAP = S_NXLN - (S_NXWD * S_SPAN-1)
	neg.w	d4
	add.w	S_NXLN(a6),d4		; d4 <- S_WRAP

	add.w	d6,d0			; d0 <- S_SPAN - 1 + D_SPAN - 1

	muls	d3,d6			; D_WRAP = D_NXLN - (D_NXWD * D_SPAN-1)
	neg.w	d6
	add.w	D_NXLN(a6),d6		; d6 <- D_WRAP

	btst.l	#3,d1			; alter values based on dir of xfer
	bne	save_wrap

	neg.w	d2			; d2 <- S_NXWD for L<-R xfer
	neg.w	d3			; d3 <- D_NXWD for L<-R xfer
	neg.w	d4			; d4 <- S_WRAP for L<-R xfer
	neg.w	d6			; d6 <- D_WRAP for L<-R xfer

save_wrap:

	move.w	d6,B_D_WRAP(a5)
	move.w	d4,B_S_WRAP(a5)

*  special case: 1 source word and 1 destination word

	tst.w	d0			; d0=0 => 1 src wrd and 1 dst wrd
	bne	blt_setup

	move.w	d7,d2			; S_NXWD<0:left shift  else:right shift
	add.w	#16,d1			; d1[bit4] 1 wrd src&dst 0:false 1:true

blt_setup:

	and.w	#$000F,d7		; d7 <- skew count
	or.w	blt_ctrl(pc,d1.w),d7	; d7 <- skew count w/ctrl flags & GO

	move.w	d3,B_D_NXWD(a5)
	move.w	d2,B_S_NXWD(a5)		; S_NXWD=0 => SRC always loaded into
	bne	not_insane		; low 16 bits of shifter, so...

*:* S_NXWD=0 is a strange case :*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*

	bset.l	#BF_PF,d7		; always prefetch.
	bra	not_insane

*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*


*   T a B l E   f O r   S e T t I n G   b L t   c O n T r O l   F l A g S
*
*
*		      spans  Sx&F>              pre     flush
*		L->R  equal  Dx&F              fetch    queue
*		----  -----  -----             -----    -----
*		 0      0      0        	 0	  1
*		 0      0      1		 1	  0
*		 0      1      0		 1        1
*		 0      1      1		 0        0
*	      	 1      0      0		 0        1
*		 1      0      1		 1	  0
*		 1      1      0		 0	  0
*		 1      1      1		 1	  1
*
*
*							0:false 1:true

blt_ctrl:

	dc.w	BM_GO+00000+BM_FQ
	dc.w	BM_GO+BM_PF+00000
	dc.w	BM_GO+BM_PF+BM_FQ
	dc.w	BM_GO+00000+00000
	dc.w	BM_GO+00000+BM_FQ
	dc.w	BM_GO+BM_PF+00000
	dc.w	BM_GO+00000+00000
	dc.w	BM_GO+BM_PF+BM_FQ

*  single word src and dst: no pre-fetch or post flush

	dc.w	BM_GO+00000+00000
	dc.w	BM_GO+00000+00000
	dc.w	BM_GO+00000+00000
	dc.w	BM_GO+00000+00000
	dc.w	BM_GO+00000+00000
	dc.w	BM_GO+00000+00000
	dc.w	BM_GO+00000+00000
	dc.w	BM_GO+00000+00000



not_insane:

*  initialize blt time variables

	move.w	S_NXPL(a6),a2
	move.w	D_NXPL(a6),a3

	move.w	BG_COL(a6),d2
	move.w	FG_COL(a6),d3

	move.w	B_HT(a6),d4
	move.w	PLANE_CT(a6),d5

	move.w	#BM_SRC,B_LOGOP(a5)	; load default for src^pat combo

	move.l	P_ADDR(a6),a4		; a4 -> pattern
	move.l	a4,d6			; is a pattern required ?
	beq	blt_0_count		; if not, skip initial pattern test

	or.w	#BM_PAT,B_LOGOP(a5)	; indicate pattern


*  filter out complex patterns

	move.w	P_NXLN(a6),d0		; if NXLN isn't 2, use blast_1
	subq.w	#2,d0
	bne	blast_1

	move.w	P_MASK(a6),d0		; if MASK isn't 1E or 1F, use blast_1
	and.w	#$FFFE,d0
	cmp.w	#$001E,d0
	bne	blast_1


*  setup simple patterned blt

	move.w	P_INDX(a6),d0		; if pattern is combined with source,
	and.w	#$000F,d0		; include initial pattern index in
	rol.w	#8,d0			; B_SKEW control word
       	or.w	d0,d7	

	move.w	P_NXPL(a6),d0		; d0 <- offset to subsequent planes
	bne	blt_0_multi		; if pattern is mono plane ...

	moveq.l	#00,d6			; load pattern and turn off reload
	bra	blt_0_mono		; (after load a4 will be set to 0)



*  the commonly used multi-plane BLASTER control loop


blt_0_loop:

	move.l	a0,B_S_ADDR(a5)		; load blt with SRC addr
	move.l	a1,B_D_ADDR(a5)		; load blt with DST addr
	move.w	d4,B_HEIGHT(a5)		; load # rows to blt

	clr.w	d6			; select logic op based on current
	lsr.w	#1,d3			; background and foreground color for
	addx.w	d6,d6			; the given plane. logic ops are held 
	lsr.w	#1,d2			; in OP_TAB as f0:b0 f0:b1 f1:b0 f1:b1
	addx.w	d6,d6			; hi byte of B_LOGOP is not altered.

	move.b	OP_TAB(a6,d6.w),B_LOGOP+1(a5)

*******************************************************************************
	move.w	d7,(a5)			; load control word (GO:1 HOG:0)
*******************************************************************************

	add.w	a2,a0			; a0 -> new SRC plane
	add.w	a3,a1			; a1 -> new DST plane

blt_0_sync:

	tas	(a5)			; attempt to restart blt
	nop				; this is executed prior to restart
	bmi	blt_0_sync		; quit if blt had finished

blt_0_multi:

	move.l	a4,d6			; d6 <- address of pattern block
	beq	blt_0_count		; no pattern if address is null


blt_0_mono:

	lea	B_PATTERN(a5),a5	; a5 -> 1st PATTERN register

	move.l	(a4)+,(a5)+		; load pattern into registers
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+

	lea	28(a5),a5		; a5 -> B_SKEW (BLASTER reference reg)

	move.l	d6,a4
	add.w	d0,a4			; a4 -> next pattern plane


blt_0_count:

	dbra	d5,blt_0_loop
.ifeq	P68030

	movec.l	cacr,d5			; d2 <- cache control register
	bset.l	#11,d5			; set "Clr DATA Cache" bit
	movec.l	d5,cacr			; clear the data cache
.endc	
	rts




*  all other weird pattern configurations

blast_1:

	move.w	P_NXLN(a6),d0
	
	move.w	P_INDX(a6),d1		; calculate initial index value.
	muls	d0,d1
	move.w	d1,P_INDX(a6)

	move.w	P_MASK(a6),d1
	move.l	P_ADDR(a6),a4

	tst.w	d6			; sign of D_NXLN determines traversal
	bge	blt_1_start		; direction of pattern file

	neg.w	d0			; negate P_NXLN
	bra	blt_1_start


*  the degenerate pattern BLASTER control loop (one row at a time)

blt_1_loop:

	move.l	a0,B_S_ADDR(a5)		; load blt with SRC addr
	move.l	a1,B_D_ADDR(a5)		; load blt with DST addr

	clr.w	d6			; select logic op based on current
	lsr.w	#1,d3			; background and foreground color for
	addx.w	d6,d6			; the given plane. logic ops are held 
	lsr.w	#1,d2			; in OP_TAB as f0:b0 f0:b1 f1:b0 f1:b1
	addx.w	d6,d6			; hi byte of B_LOGOP is not altered.

	move.b	OP_TAB(a6,d6.w),B_LOGOP+1(a5)

	swap	d2			; d2[31:16] <- background color vector
	swap	d3			; d3[31:16] <- foreground color vector
	move.w	P_INDX(a6),d3		; d3[15:00] <- initial pattern index

	moveq.l	#01,d6			; d6 <- single line count
	bra	blt_1_enter


blt_1_next:

	move.w	d3,d2			; d2 <- raw index to this line
	add.w	d0,d3			; d3 <- raw index to next line
	and.w	d1,d2			; d2 <- masked index to this line
	move.w	(a4,d2.w),B_PATTERN(a5)	; load pattern into first pattern reg

	move.w	d6,B_HEIGHT(a5)		; do a line at a time


*******************************************************************************
	move.w	d7,(a5)			; load control word (GO:1 HOG:0)
*******************************************************************************

blt_1_sync:
	
	nop				; allow for interrupts to break through
	tas	(a5)			; restart the BLASTER
	bmi	blt_1_sync

blt_1_enter:

	dbra	d4,blt_1_next


	add.w	a2,a0			; a0 -> new SRC plane
	add.w	a3,a1			; a1 -> new DST plane
	add.w	P_NXPL(a6),a4		; a4 -> new PATTERN plane

	swap	d2			; d2[15:00] <- background color vector
	swap	d3			; d3[15:00] <- foreground color vector

	move.w	B_HT(a6),d4		; d4 <- number of rows to blt

blt_1_start:

	dbra	d5,blt_1_loop

.ifeq	P68030

	movec.l	cacr,d5			; d2 <- cache control register
	bset.l	#11,d5			; set "Clr DATA Cache" bit
	movec.l	d5,cacr			; clear the data cache
.endc	
	rts

	.end
