****************************  hbline.s  ********************************
*
* $Revision: 3.2 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/hbline.s,v $
* =======================================================================
* $Author: lozben $	$Date: 91/02/13 18:34:26 $     $Locker:  $
* =======================================================================
*
* $Log:	hbline.s,v $
* Revision 3.2  91/02/13  18:34:26  lozben
* Adjusted the spelling of some of the linea equates to correspond
* to the ones in the lineaequ.s file.
* 
* Revision 3.1  91/01/31  16:20:29  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.0  91/01/03  15:10:50  lozben
* New generation VDI
* 
* Revision 2.3  90/02/23  18:22:21  lozben
* We now use _FG_B_PLANES as our color index instead of _FG_BP_{0-7}.
* 
* Revision 2.2  89/02/27  17:45:13  lozben
* *** initial revision ***
* 
*************************************************************************


.include	"lineaequ.s"
.include	"vdiincld.s"

		.globl	hb_vline	; make routines available globally
		.globl	hb_hline

		.globl	op_table
		.globl	BLASTER
		.globl	_v_bas_ad

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

*+
*	Hard Vertical Line Code
*
*  in:
*	d4	X
*	d5	Y1
*	d6	X
*	d7	Y2
*
*	a4	pointer to LineA variable base
*-
hb_vline:

	lea	BLASTER+B_OFF,a5	; a5 -> BLASTER reference register

	not.w	d4
	and.w	#$000F,d4		; d4 <- bit number within word
	clr.w	d0
	bset.l	d4,d0			; d0 <- pixel mask   0:DST 1:LINE
	move.w	d0,B_F1_MSK(a5)		; load the fringe mask

	move.w	_v_planes(a4),d0	; d0 <- planes
	move.w	d0,d1
	add.w	d1,d1			; d1 <- offset between words
	subq.w	#1,d0			; d0 <- dbra plane counter

	move.l	_v_bas_ad,a1		; a1 -> start of destination form
	asr.w	#4,d6			; d6 <- X/16
	muls	d6,d1			; d1 <- byte offset to X
	add.l	d1,a1			; a1 -> dst (X,0)

	move.w	_bytes_lin(a4),d2		; d2 <- screen width
	muls	d5,d2			; d2 <- offset to (0,Y1)
	add.l	d2,a1			; a1 -> (X,Y1)

	moveq.l	#7,d2			; d2 <- dbra loop counter

	move.w	_v_lin_wr(a4),d1	; d1 <- offset between lines

	lea	_LN_MASK(a4),a3		; a3 -> line style mask
	move.w	(a3),d3			; d3 <- line style mask

	sub.w	d5,d7			; d7 <- dY
	bge	vl_top


vl_bot:	neg.w	d7			; d7 <- absolute value of dY
	neg.w	d1			; d1 <- offset to next line up
	lea	B_PATTERN+32(a5),a0	; a0 -> last pattern register

vl_b2t:	add.w	d3,d3			; cy <- next style bit
	subx.w	d4,d4			; cy:0 => d0<-0000  cy:1 => d0<-FFFF
	move.w	d4,-(a0)		; load register
	add.w	d3,d3
	subx.w	d4,d4
	move.w	d4,-(a0)
	dbra	d2,vl_b2t

	move.w	#BM_GO+$0F00,d2		; d2 <- SKEW word (start on last line)
	bra	vl_wrap



vl_top:	lea	B_PATTERN(a5),a0	; a0 -> 1st pattern register

vl_t2b:	add.w	d3,d3			; cy <- next style bit
	subx.w	d4,d4			; cy:0 => d0<-0000  cy:1 => d0<-FFFF
	move.w	d4,(a0)+		; load pattern register
	add.w	d3,d3
	subx.w	d4,d4
	move.w	d4,(a0)+
	dbra	d2,vl_t2b		; next 2 registers

	move.w	#BM_GO+$0000,d2		; d2 <- initial pattern index


vl_wrap:

	move.w	d1,B_D_WRAP(a5)		; store destination wrap
	addq.w	#1,d7			; d7  <- dY+1: height

	lea	op_table,a2
	move.w	_WRT_MODE(a4),d1	; d1 <- writing mode
	lsl.w	#2,d1			; d1 <- offset into main table
	add.w	d1,a2			; a2 -> op code table for this mode

	subq.w	#8,d1			; if it's XOR mode ...
	bne	vl_newmask		
	tst.w	_LSTLIN(a4)		; and it's not the last line ...
	bne	vl_newmask

	subq.w	#1,d7			; don't plot last pixel

vl_newmask:

	move.w	d7,d1			; d1 <- line length
	move.w	(a3),d3			; d3 <- pattern for this line
	and.w	#$000F,d1		; d1 <- realignment factor
	rol.w	d1,d3			; d3 <- pattern aligned for next line
	move.w	d3,(a3)			; save it back to _LN_MASK

        move.l  _FG_B_PLANES(a4),d5	; d5 <- color index
	moveq.l	#2,d4			; d4 <- mask for op_table offset
	move.w	#1,B_D_SPAN(a5)		; one word span

vl_loop:

	move.l	a1,B_D_ADDR(a5)		; next plane
	move.w	d7,B_HEIGHT(a5)		; line height

	ror.l	d5			; what color is this plane ?
	scs	d3
	and.w	d4,d3
	move.w	0(a2,d3.w),B_LOGOP(a5)


*******************************************************************************
	move.w	d2,(a5)			; load the SKEW register and fly
*******************************************************************************

vl_sync:

	tas	(a5)
	nop
	bmi	vl_sync

vl_cont:

	addq.w	#2,a1			; a1 -> start of next plane
	dbra	d0,vl_loop		; do the next plane

.ifeq	P68030

	movec.l	cacr,d0			; d2 <- cache control register
	bset.l	#11,d0			; set "Clr DATA Cache" bit
	movec.l	d0,cacr			; clear the data cache
.endc
	rts


*+
*	Hard Horizontal Line Code
* in:
*	d0	offset between pattern words
*	d1	word containing X1
*	d2	span-1 (words)
*	d3	mod 16 mask
*	d4	left fringe mask
*	d5	Y1
*	d6	right fringe mask
*
*	a0	points to 1st pattern word
*	a4	points to line A variables base address  (_v_planes)
*-
hb_hline:

	lea	BLASTER+B_OFF,a5	; a5 -> bit blt reference register
	clr.w	B_S_NXWD(a5)		; proceed from left to right

	addq.w	#1,d2			; d2 <- span
	move.w	d2,B_D_SPAN(a5)

	lea	B_F1_MSK(a5),a3
	move.w	 d4,(a3)+		; B_F1_MSK <- left fringe
	move.w	#-1,(a3)+		; B_CT_MSK <- center fringe
	move.w	 d6,(a3)+		; B_F2_MSK <- right fringe

	move.w	(a4),d2			; d2 <- planes		( _v_planes   )
	move.w	d2,d7
	subq.w	#1,d7			; d7 <- dbra plane counter

	add.w	d2,d2			; d2 <- offset between words in plane
	move.w	d2,(a3)+		; load B_D_NXWD

	move.l	_v_bas_ad,a1		; a1 -> start of dst form
	muls	_bytes_lin(a4),d5	; d5 <- offset to 1st row of dst
	add.l	d5,a1			; a1 -> row containing line

	muls	d2,d1			; d1 <- offset to word containing X1
	add.l	d1,a1			; a1 -> 1st word of line

	lea	B_PATTERN(a5),a2	; a2 -> 1st pattern register
        move.l  _FG_B_PLANES(a4),d5	; d5 <- color index

	move.w	_WRT_MODE(a4),d2	; d2 <- writing mode (0-3)
	add.w	d2,d2
	add.w	d2,d2			; d2 <- offset to writing mode table
	lea	op_table(pc),a4		; a4 -> 1st logic op table
	add.w	d2,a4			; a4 -> writing mode table

	moveq.l	#2,d3			; d3 <- logic op offset mask
	move.w	#BM_GO,d4		; d4 <- SKEW word
	moveq.l	#1,d6			; d6 <- height


hl_loop:

	move.w	(a0),(a2)		; load the pattern into BLASTER
	add.w	d0,a0			; a0 -> next pattern word

	move.l	a1,B_D_ADDR(a5)		; new dst plane
	move.w	d6,B_HEIGHT(a5)		; height of 1

	ror.l	d5			; what color is this plane ?
	scs	d2
	and.w	d3,d2			; d2 <- logic op offset: 0=>0  1=>2
	move.w	0(a4,d2.w),B_LOGOP(a5)	; load the logic op

*******************************************************************************
	move.w	d4,(a5)			; start the BLASTER
*******************************************************************************

hl_sync:

	tas	(a5)
	nop
	bmi	hl_sync

hl_cont:

	addq.l	#2,a1			; a1 -> next dst plane
	dbra	d7,hl_loop

.ifeq	P68030

	movec.l	cacr,d7			; d2 <- cache control register
	bset.l	#11,d7			; set "Clr DATA Cache" bit
	movec.l	d7,cacr			; clear the data cache
.endc
	rts


op_table:  *	 color=0   color=1

	dc.w	BM_PAT+00,BM_PAT+03	; replace
	dc.w	BM_PAT+04,BM_PAT+07	; transparent
	dc.w	BM_PAT+06,BM_PAT+06	; xor
	dc.w	BM_PAT+01,BM_PAT+13	; reverse transparent

	.end
