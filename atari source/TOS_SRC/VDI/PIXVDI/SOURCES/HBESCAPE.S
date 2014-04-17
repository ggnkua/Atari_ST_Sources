****************************  hbescape.s  *******************************
*
* $Revision: 3.2 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/hbescape.s,v $
* =======================================================================
* $Author: lozben $	$Date: 91/02/13 18:06:35 $     $Locker:  $
* =======================================================================
*
* $Log:	hbescape.s,v $
* Revision 3.2  91/02/13  18:06:35  lozben
* Adjusted the spelling of some of the linea equates to correspond to the ones
* in the lineaequ.s file.
* 
* Revision 3.1  91/01/31  15:59:03  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.0  91/01/03  15:10:36  lozben
* New generation VDI
* 
* Revision 2.5  90/03/06  14:58:00  lozben
* Changed "move.l #$FF,dx" to "moveq.l #-1,dx" at one time it was
* "moveq.l #$FF,dx".
* 
* Revision 2.4  90/02/26  17:38:50  lozben
* Fixed the code to work with turbo assembler.
* 
* Revision 2.3  90/02/20  15:16:12  lozben
* Changed "bra blank_it" to "jmp blank_it".
* 
* Revision 2.2  89/02/27  17:45:10  lozben
* *** initial revision ***
* 
*************************************************************************

.include	"lineaequ.s"
.include 	"vdiincld.s"
*  Offsets into BLASTER parameter block

B_OFF		equ	 60	; offset to reference register

B_PATTERN	equ	-60 	; pattern register file
B_S_NXWD	equ	-28 	; offset to next src word
B_S_WRAP	equ	-26 	; wrap from end of one src line to next
B_S_ADDR	equ	-24 	; initial src address
B_F1_MSK	equ	-20 	; 1st fringe mask	0:old 1:new
B_CT_MSK	equ	-18 	; center mask		0:old 1:new
B_F2_MSK	equ	-16 	; 2nd fringe mask	0:old 1:new
B_D_NXWD	equ	-14 	; offset to next dst word
B_D_WRAP	equ	-12 	; wrap from end of one dst line to next
B_D_ADDR	equ	-10 	; initial dst address
B_D_SPAN	equ	-06 	; span in words of dst block
B_HEIGHT	equ	-04 	; pixel height of block
B_LOGOP		equ	-02 	; ctrl word: src^pat combo & logic op #
B_SKEW		equ	 00	; ctrl word: flags, pat index & skew


BF_PAT		equ  	08	; combo flag: 0:all ones  1:pattern
BF_SRC		equ  	09	; combo flag: 0:all ones  1:source
BM_PAT		equ  	$0100	; combo mask: 0:all ones  1:pattern
BM_SRC		equ  	$0200	; combo mask: 0:all ones  1:source
                     
                     
BF_GO		equ  	15	; execution flag         0:false 1:true
BF_HOG		equ  	14	; hog dma flag		 0:false 1:true
BF_SM		equ  	13	; smudge flag		 0:false 1:true
BF_PF		equ  	07	; pre-fetch flag  	 0:false 1:true
BF_FQ		equ  	06	; flush queue flag 	 0:false 1:true
BM_GO		equ  	$8000	; execution mask	
BM_HOG		equ  	$4000	; hog dma mask
BM_SM		equ  	$2000	; smudge mask
BM_PF		equ  	$0080	; pre-fetch mask
BM_FQ		equ  	$0040	; flush queue mask


	.globl	hb_cell
	.globl	hb_blank
	.globl	hb_scrup
	.globl	hb_scrdn
	.globl	blank_it

*	external variables

	xdef	BLASTER		* first register of bit blt

*******************************************************************************
*	
* name:	 	hb_cell
*
* author:	j.d.eisenstein
*
* purpose:
*
*	This routine performs a byte aligned block transfer for the purpose of 
*	manipulating monospaced byte-wide text. the routine maps an single
*	plane, arbitrarilly tall, byte-wide image to a multi-plane bit map.
*	All transfers are byte aligned. Hardware BitBlt is employed.
*
* in:	a0.l	points to character source
*	a1.l	points to destination (1st plane, top of block)
*	d6.w	foreground 
*	d7.w	background 
*
*
*  mutated registers:	a2/d0-d4/d6-d7
*
*
*******************************************************************************

            
hb_cell:

	lea	BLASTER+B_OFF,a5		; a5 -> B_SKEW (reference reg)
	move.l	a1,a2				; a2 <- working copy:dst ptr

	moveq.l	#1,d2				;
	move.w	d2,B_D_SPAN(a5)			; span is always one word

	move.w	a0,d0				; calculate an index value
	move.w	a1,d1				; based upon the even or
	and.w	d2,d0				; odd byte alignments of
	lsr.w	#1,d1				; the source and destination
	addx.w	d0,d0				; pointers
	add.w	d0,d0				; d0 <- offset value

	move.w	chr_mask(pc,d0.w),B_F1_MSK(a5)	;
	move.w	chr_nxwd(pc,d0.w),B_S_NXWD(a5)	;
	move.w	chr_skew(pc,d0.w),d0		; d0 <- SKEW word

	move.w	v_fnt_wr(a4),B_S_WRAP(a5)	;
	move.w	_v_lin_wr(a4),B_D_WRAP(a5)	;

	move.w	v_cel_ht(a4),d1			; d1 <- height
	move.w	_v_planes(a4),d2
	subq.w	#1,d2				; d2 <- dbra plane counter
	moveq.l	#BF_GO-8,d4			; d4 -> BLASTER GO flag


char_loop:

	move.l	a0,B_S_ADDR(a5)			; BLASTER doesn't see LSB
	move.l	a2,B_D_ADDR(a5)			;
	move.w	d1,B_HEIGHT(a5)			;

	clr.w	d3				; select one of four logic
	lsr.w	#1,d6				; operations based on the
	addx.w	d3,d3				; current foreground and
	lsr.w	#1,d7				; background color bits
	addx.w	d3,d3				; for this plane
	add.w	d3,d3				; d3 <- word offset
	move.w	chr_op(pc,d3.w),B_LOGOP(a5)	;

*******************************************************************************
	move.w	d0,(a5)				; load skew word and GO
*******************************************************************************

	addq.l	#2,a2				; a1 -> next plane of dst

char_sync:

	tst.w	(a5)				; in HOG mode so wait for
	bmi	char_sync			; completion.

char_cont:

	dbra	d2,char_loop			; do the next plane

.ifeq	P68030

	movec.l	cacr,d2			; d2 <- cache control register
	bset.l	#11,d2			; set "Clr DATA Cache" bit
	movec.l	d2,cacr			; clear the data cache
.endc
	rts



*		src	  0     0     1     1
*		dst	  0     1     0     1

chr_mask:	dc.w	$FF00,$00FF,$FF00,$00FF
chr_nxwd:	dc.w	$0000,$0000,$FFFF,$0000

chr_skew:	dc.w	BM_GO+BM_HOG+00
		dc.w	BM_GO+BM_HOG+08
		dc.w	BM_GO+BM_HOG+08
		dc.w	BM_GO+BM_HOG+00
	
chr_op:		dc.w	BM_SRC+00,BM_SRC+12,BM_SRC+03,BM_SRC+15


*******************************************************************************
*
* title:	Scroll
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
*	v_cel_mx   cell Y of region bottom
*	_BV_SCRUP  points to desired version of scroll up routine
*	_BV_SCRDN  points to desired version of scroll down routine
*
*  munged:	d0-d7/a2-a3/a5
*
*
*******************************************************************************

hb_scrup:

	lea	BLASTER+B_OFF+B_S_NXWD,a5

	moveq.l	#$02,d6
	move.w	d6,(a5)+		; load B_S_NXWD
	move.w	d6,(a5)+		; load B_S_WRAP

	move.w	v_cel_wr(a4),d5		; d5 <- span (bytes)
	move.w	d5,d4
	mulu	d1,d4			; d4 <- dst offset
	move.l	_v_bas_ad,a2		; a2 -> base of screen
	add.l	d4,a2			; a2 -> top of dst
	lea	0(a2,d5.w),a3		; a3 -> top of src
	move.l	a3,(a5)+		; load B_S_ADDR

	moveq.l	#-1,d7			; scroll on word boundries
	move.l	d7,(a5)+		; load B_F1_MSK and B_CT_MSK
	move.w	d7,(a5)+		; load B_F2_MSK

	move.w	d6,(a5)+		; load B_D_NXWD
	move.w	d6,(a5)+		; load B_D_WRAP
	move.l	a2,(a5)+		; load B_D_ADDR

	asr.w	#1,d5			; d5 <- span (words)

	move.w	v_cel_my(a4),d3		; d3 <- maximum cell Y
	move.w	d3,d2
	sub.w	d1,d2			; d2 <- number of rows to blt
	ble	fu_start		; catch degenerate case

	move.w	d5,(a5)+		; load B_D_SPAN
	move.l	a5,a3			; a3 -> B_HEIGHT (line counter)
	move.w	d2,(a5)+		; load B_HEIGHT
	move.w	#BM_SRC+03,(a5)+	; load B_LOGOP:  replace mode

	move.w	#BM_GO,d2		; d2 <- GO and SKEW bytes

*******************************************************************************
	move.w	d2,(a5)			; scroll the screen
*******************************************************************************

su_sync:

	tas	(a5)			; restart blt
	nop				; blt restarts after this is executed
	bmi	su_sync			; quit if blt had already finished

.ifeq	P68030

	movec.l	cacr,d0			; d2 <- cache control register
	bset.l	#11,d0			; set "Clr data Cache" bit
	movec.l	d0,cacr			; clear the data cache
.endc

fu_start:

	clr.w	d0			; d0 <- Xmin
	move.w	v_cel_mx(a4),d2		; d2 <- Xmax
	move.w	d3,d1			; d1 <- Ymax  d3 <- Ymax
	jmp	blank_it		; fill the vacated space


hb_scrdn:

	lea	BLASTER+B_OFF+B_S_NXWD,a5

	moveq.l	#-02,d6
	move.w	d6,(a5)+		; B_S_NXWD = -2 (next word to the left)
	clr.w	   (a5)+		; B_S_WRAP =  0 (for xtra SRC read)

	move.w	v_cel_wr(a4),d5		; d5 <- cell wrap (bytes)
	move.w	d5,d4
	move.w	v_cel_my(a4),d3		; d3 <- maximum cell Y
	mulu	d3,d4			; d4 <- offset to top of last row

	move.l	_v_bas_ad,a3		; a3 -> base of screen
	lea	-2(a3,d4.l),a3		; a3 -> last word of src
	move.l	a3,(a5)+		; load B_S_ADDR

	moveq.l	#-1,d7			; scroll on word boundries
	move.l	d7,(a5)+		; load B_F1_MSK and B_CT_MSK
	move.w	d7,(a5)+		; load B_F2_MSK

	move.w	d6,(a5)+		; B_D_NXWD = -2 (next word to the left)
	move.w	d6,(a5)+		; B_D_WRAP = -2 (next word to the left)

	lea	0(a3,d5.w),a2		; a2 -> last word of dst
	move.l	a2,(a5)+		; load B_D_ADDR

	asr.w	#1,d5			; d5 <- span (words)
	sub.w	d1,d3			; d3 <- number of rows to blt
	ble	fd_start		; catch degenerate case

	move.w	d5,(a5)+		; load B_D_SPAN
	move.l	a5,a3			; a3 -> B_HEIGHT        (for sync test)
	move.w	d3,(a5)+		; load B_HEIGHT

	move.w	#BM_SRC+03,(a5)+	; load B_LOGOP:replace mode

*******************************************************************************
	move.w	#BM_GO+BM_PF,(a5)	; GO: (xfer right to left) (skew=0)
*******************************************************************************

sd_sync:

	tas	(a5)			; restart blt
	nop				; blt restarts after this is executed
	bmi	sd_sync			; quit if blt had already finished

.ifeq	P68030

	movec.l	cacr,d0			; d2 <- cache control register
	bset.l	#11,d0			; set "Clr Data Cache" bit
	movec.l	d0,cacr			; clear the data cache
.endc

fd_start:

	clr.w	d0			; d0 <- Xmin
	move.w	v_cel_mx(a4),d2		; d2 <- Xmax
	move.w	d1,d3			; d1 <- Ymin  d3 <- Ymin
	jmp	blank_it		; fill the vacated space

*******************************************************************************
*
* title:	 Blank it
*
* author:	 jim eisenstein
*
* purpose:
*
*  This routine fills a cell-word aligned region with the background
*  color.  The rectangular region is specified by a top/left cell x,y
*  and a bottom/right cell x,y, inclusive.
*
* in:	d0	  cell Xmin of region
*	d1	  cell Ymin of region
*	d2	  cell Xmax of region
*	d3	  cell Ymax of region
*
*	_BV_BLANK pointer to blanking routine (hb_blank uses BLASTER)
*
* mutated:	d3-d7/a2-a3/a5
*
*
*******************************************************************************


blank_tab: *    fringe masks		*   odd      odd  multi word 
*	   *      rt    lf		*  Xmin     Xmax     SPAN

	dc.w	$0000,$FF00		*   0	     0        0
	dc.w	$FF00,$FFFF		*   0	     0        1
	dc.w	$0000,$FFFF		*   0	     1        0
	dc.w	$FFFF,$FFFF		*   0	     1        1
	dc.w	$0000,$0000		*   1	     0        0 ** undefined **
	dc.w	$FF00,$00FF		*   1	     0        1
	dc.w	$0000,$00FF		*   1	     1        0
	dc.w	$FFFF,$00FF		*   1	     1        1



hb_blank:

	lea	BLASTER+B_OFF+B_F1_MSK,a5

	move.w	d0,d4			; d4 <- X min
	move.w	d2,d5			; d5 <- X max

	clr.w	d6
	lsr.w	#1,d4			; d4 <- word offset to Xmin
	addx.w	d6,d6
	lsr.w	#1,d5			; d5 <- word offset to Xmax
	addx.w	d6,d6
	sub.w	d4,d5			; d5 <- span-1 (words)
	sne	d7
	add.b	d7,d7			; 1 dst word  =:00  <>:FF
	roxl.w	#3,d6			; d6 <- offset into fringe table

	move.l	blank_tab(pc,d6.w),d7	; d7 <- fringes
	move.w	d7,(a5)+		; load B_F1_MSK
	move.w	#$FFFF,(a5)+		; load B_CT_MSK
	swap	d7
	move.w	d7,(a5)+		; load B_F2_MSK

	move.w	v_cel_wr(a4),d7		; d7 <- cell wrap (bytes)
	mulu	d1,d7			; d7 <- offset to top of row at Ymin
	move.l	_v_bas_ad,a2		; a2 -> base of screen
	add.l	d7,a2			; a2 -> top of row at Ymin

	move.w	_v_planes(a4),d6	; d6 <- number of planes
	move.w	d6,d7
	add.w	d7,d7			; d7 <- offset between words (in bytes)
	move.w	d7,(a5)+		; load B_D_NXWD

	mulu	d7,d4			; d4 -> offset to Xmin
	add.w	d4,a2			; a2 -> start of dst

	move.w	d5,d4			; d4 <- SPAN -1
	mulu	d7,d4			; d4 <- actual width of span - NXWD
	neg.w	d4
	add.w	_v_lin_wr(a4),d4	; d4 <- WRAP
	move.w	d4,(a5)+		; load B_D_WRAP

	move.l	a2,(a5)+		; load B_D_ADDR

	addq.w	#1,d5			; d5 <- SPAN
	move.w	d5,(a5)+		; load B_D_SPAN

	move.l	a5,a3			; a3 -> B_HEIGHT
	addq.l	#4,a5			; a5 -> B_SKEW   (reference register)

	move.w	d3,d4			; d4 <- Ymax
	sub.w	d1,d4			; d4 <- Ymax-Ymin
	addq.w	#1,d4			; d4 <- number of cells high
	mulu	v_cel_ht(a4),d4		; d4 <- height of region

	move.w	#BM_GO,d3		; d3 <- SKEW control word
	subq.w	#1,d6			; d6 <- dbra plane counter
	move.w	v_col_bg(a4),d7		; d7 <- background color


blank_loop:

	move.l	a2,B_D_ADDR(a5)		; load starting address for this plane
	move.w	d4,(a3)			; load B_HEIGHT
	lsr.w	#1,d7			; cy <- color bit for this plane
	scs	B_LOGOP+1(a5)		; bit:0 => op 0  bit:1 => op 15

*******************************************************************************
	move.w	d3,(a5)			; dispatch BLASTER
*******************************************************************************

blank_sync:

	tas	(a5)			; restart blt
	nop				; blt restarts after this is executed
	bmi	blank_sync		; quit if blt had already finished

blank_cont:

	addq.l	#2,a2			; a2 -> start of next plane
	dbra	d6,blank_loop

.ifeq	P68030

	movec.l	cacr,d0			; d2 <- cache control register
	bset.l	#11,d0			; set "Clr Data Cache" bit
	movec.l	d0,cacr			; clear the data cache
.endc

	rts
