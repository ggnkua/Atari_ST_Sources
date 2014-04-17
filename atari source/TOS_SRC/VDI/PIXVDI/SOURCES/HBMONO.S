****************************  hbmono.s  *********************************
*
* $Revision: 3.0 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/hbmono.s,v $
* =======================================================================
* $Author: lozben $	$Date: 91/01/03 15:10:56 $     $Locker:  $
* =======================================================================
*
* $Log:	hbmono.s,v $
* Revision 3.0  91/01/03  15:10:56  lozben
* New generation VDI
* 
* Revision 2.2  89/02/27  17:45:15  lozben
* *** initial revision ***
* 
*************************************************************************

.include	"vdiincld.s"

	.globl	 BLASTER
	.globl	 hb_mono
	.globl	_v_bas_ad

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

*-
*  Mono-spaced text blt; no clipping to worry about
*
*   d0.w =  _DESTX
*   d1.w =  _DESTY
*   d2.w =  # of characters
*   d3.w =  _DELY
*   a1   =  line A variable reference base
*-
hb_mono:
	move.l	a1,a5		    ;a5 -> line A variable structure
	add.l	#84,a5		    ;a5 -> _FBASE
	lea	BLASTER+B_OFF,a4    ;12	 a4 -> base of bitblt regs

	move.l	(a5)+,a0	    ;12	 a0 -> source form
	move.w	(a5),B_S_WRAP(a4)   ;16	 load src form width     ( _FWIDTH   )
	move.w	-86(a5),d7	    ;12	 d7 <- dst form width	 ( _v_lin_wr )
	move.w	d7,B_D_WRAP(a4)	    ;20	 load dst form width
	muls	-90(a5),d1	    ;79> d1 <- offset to dst Ymin( _bytes_lin)
	move.l	-80(a5),a2	    ;12	 a2 -> ascii char string ( _INTIN    )
	move.w	-52(a5),d4	    ;12	 d4 <- writing mode      ( _WRT_MOD  )
	move.w	-88(a5),d5	    ;12	 d5 <- number of planes  ( _v_planes )
	subq.w	#1,d5		    ; 4	 d5 <- dbra plane counter

	move.b	shf_tab(pc,d5.w),d7 ;12	 d7 <- horizontal shift factor
	move.w	d0,d6		    ; 4  d6 <- dst X
	and.w	#$FFF0,d0	    ; 8	 d0 <- clip X to word boundry
	asr.w	d7,d0		    ; 8/10/12  d0 <- offset to dst X
	lsr.w	#4,d6		    ;14	 x flag:0  even  x flag:1 odd
	ext.l	d0		    ; 4	 d0 <- longword offset to dst X
	addx.l	d0,d1		    ; 8	 d1 <- X offset + Y offset + x flag
	add.l	_v_bas_ad,d1	    ;22	 d1 -> start of dst

	move.w	18(a5),d6	    ;12	 d6 <- foreground color  ( _TEXT_FG  )
	move.w	#1,B_D_SPAN(a4)	    ;16	 span of 1 word
	move.w	#BM_SRC,B_LOGOP(a4) ;16  source and no pattern

	bra	char1st		    ;10	 count 1 character off 1st



*	a0   -> source form base
*	d1   -> screen destination
*
*	a2   -> character string
*	a4   -> BLASTER base address
*
*	d0,d7 temp use
*
*	d2.w = # of characters remaining
*	d3.w = height of character (in rows)
*	d4.w = writing mode
*	d5.w = # of planes -1
*	d6.w = foreground color


*		    planes

shf_tab:   *	1 2   4       8

	dc.b	3,2,0,1,0,0,0,0

* same/different "oddness" skew

skewtab:   *	S,D

	dc.b	0,8

*	writing mode table
*
*	     color bit
mon_mode:  *	0,1

	dc.b	0,3		; replace
	dc.b	4,7		; transparent
	dc.b	6,6		; xor
	dc.b	1,13		; reverse transparent


chr_mask:

	dc.w	$FF00,$00FF,$FF00,$00FF

chr_nxwd:

	dc.w	0,0,-1,0

chr_skew:

	dc.w	BM_GO+BM_HOG+00
	dc.w	BM_GO+BM_HOG+08
	dc.w	BM_GO+BM_HOG+08
	dc.w	BM_GO+BM_HOG+00


mchar_loop:

	move.l	a0,d0		;4  d0 -> start of font
	add.w	(a2)+,d0	;8  d0 -> 1st byte of character form
	move.l	d0,a3		;4  a3 -> source

	and.w	#$0001,d0	;8  d0 <- 0:even src addr    1:odd src addr
	move.w	d1,d7		;4  d7 -> destination
	lsr.w	#1,d7		;8  cy <- 0:even dst addr    1:odd dst addr
	addx.w	d0,d0		;4  d0 <- index into tables
	add.w	d0,d0		;4  d0 <- offset into tables

	move.w	chr_mask(pc,d0.w),B_F1_MSK(a4)	;22
	move.w	chr_nxwd(pc,d0.w),B_S_NXWD(a4)	;22
	move.w	chr_skew(pc,d0.w),a5		;14   a5 <- SKEW word

	move.w	d5,d0		;4     d0 <- dbra plane counter
	move.w	d6,d7		;4     d7 <- foreground color
	move.l	d1,a1		;4     a1 -> destination


mplan_loop:

	move.l	a3,B_S_ADDR(a4)	;16    set source address
	move.l	a1,B_D_ADDR(a4)	;16    set destination address
	move.w	d3,B_HEIGHT(a4)	;12    set height
	lsr.w	#1,d7		;8     cy <- current foreground color bit
	addx.w	d4,d4		;8     pick it up in writing mode

	move.b	mon_mode(pc,d4.w),B_LOGOP+1(a4) ;22

	lsr.w	#1,d4		;8     restore writing mode

*******************************************************************************
	move.w	a5,(a4)		;8     load SKEW & GO
*******************************************************************************

	addq.l	#2,a1		;8     a1 -> next plane

mchar_sync:

	tst.w	(a4)		;8     BLASTER has finished
	bmi	mchar_sync	;8/10  when GO flag is lo


mchar_cont:

	dbra	d0,mplan_loop	;10/14 do next plane


	addq.l	#1,d1		;8     d1 -> next character destination
	btst.l	#0,d1		;10    if next character on odd byte boundry,
	bne	char1st		;8/10  dst address is same as last character's

	move.l	a1,d1		;4     d1 -> destination just blasted
	subq.l	#1,d1		;8     d1 -> next character destination

char1st:

	dbra	d2,mchar_loop	;10/14 do next character

.ifeq	P68030

	movec.l	cacr,d0			; d2 <- cache control register
	bset.l	#11,d0			; set "Clr DATA Cache" bit
	movec.l	d0,cacr			; clear the data cache
.endc

	moveq.l	#1,d0		;4	exit blit with success code in d0
	rts			;16

	.end
