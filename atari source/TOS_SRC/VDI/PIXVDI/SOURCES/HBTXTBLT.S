****************************  hbtxtblt.s  *******************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/hbtxtblt.s,v $
* =======================================================================
* $Author: lozben $	$Date: 91/02/01 15:30:42 $     $Locker:  $
* =======================================================================
*
* $Log:	hbtxtblt.s,v $
* Revision 3.1  91/02/01  15:30:42  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.0  91/01/03  15:11:07  lozben
* New generation VDI
* 
* Revision 2.3  90/03/01  18:19:10  lozben
* Changed some syntax to work with the turbo assembler.
* 
* Revision 2.2  89/02/27  17:45:19  lozben
* *** initial revision ***
* 
*************************************************************************

.include	"lineaequ.s"
.include 	"vdiincld.s"

	.globl	 BLASTER
	.globl	 hb_text

*   base of Line "A" variables

	.globl	_v_bas_ad

*    Some of Jim Eisenstein's bloody blastman code came in handy here
*
*
*  offsets into the BLASTER register block for the new blit ST
*
*  note:  base address = BLASTER+B_OFF
*
*	because the SKEW register may be accessed via an
*	"address register indirect" instruction rather than an
*	"address register indirect with displacement" instruction,
*	4 cycles are saved per access


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

THICKEN		equ	0
LIGHT		equ	1
SKEW		equ	2
UNDER		equ	3
OUTLINE		equ	4
SHADOW		equ	5

THICKM		equ	$1
LIGHTM		equ	$2
SKEWM		equ	$4
UNDERM		equ	$8
OUTLINEM	equ	$10
SHADOWM		equ	$20


		offset	0

		ds.w	1	;width of source form (in bytes)
s_next		equ	-*
		ds.w	1	;width of destination form (in bytes)
d_next		equ	-*
		ds.w	1	;offset to back-up ptr to plane 0 (0,2 or 6)
prevpln0	equ	-*
		ds.w	1	;height of area to blit (in scanlines)
height		equ	-*
		ds.w	1	;# of planes (1,2, or 4)
nbrplane	equ	-*
		ds.w	1	;foreground color temp
forecol		equ	-*
		ds.w	1	;background color temp
backcol		equ	-*
		ds.w	1	;inverted liten mask (in effect if .NE. 0)
litemsk		equ	-*
		ds.w	1	;skew mask (skew in effect if .NE. 0)
skewmsk		equ	-*
		ds.w	1	;skew case offset to use if in effect
skewcase	equ	-*
		ds.w	1	;currently free buffer (0 or cell_siz)
buffree		equ	-*
		ds.w	1	;writing mode
wrt_mod		equ	-*
		ds.w	1	;XACC to use for scaling
tmp_xacc	equ	-*
		ds.w	1	;computed delx to use for scaling
tmp_delx	equ	-*
		ds.w	1	;computed dely to use for scaling
tmp_dely	equ	-*
		ds.w	1	;clip adjust value (add) for sourcex,destx
delsdx		equ	-*
		ds.w	1	;clip adjust value (add) for sourcey,desty
delsdy		equ	-*
		ds.w	1	;clip adjust value (subtract) for delx
deldelx		equ	-*
		ds.w	1	;clip adjust value (subtract) for dely
deldely		equ	-*
		ds.w	1	;clipping required if -1 (else 0)
clipon		equ	-*
		ds.w	1	;local destination y-position
locdesty	equ	-*
		ds.w	1	;local destination x-position
locdestx	equ	-*
		ds.w	1	;weight to use for bold form expansion
locweigt	equ	-*
ramlen		equ	-*


	.text

hb_text:

	link	a4,#ramlen		;a4 -> local ram
	lea	BLASTER+B_OFF,a5	;a5 -> BLASTER regs

	clr.w	buffree(a4)		;set buffer #0 as free one

	movem.w	_DELX(a6),d5-d6		;d5=_DELX;d6=dely

	tst.w	_DOUBLE(a6)		;are we scalin?
	beq	adr_nobd		;br if not

*   scaling; calculate _DELX, dely for clip purposes 

	move.w	d6,-(sp)		;pass DELY on stack to ACT_SIZ
	jsr	_ACT_SIZ		;find scaled dely in d0 (leaves d6 be)
	addq.l	#2,sp			;restore stack
	move.w	d0,d6			;copy computed DELY to d5

	move.w	_XACC_DDA(a6),d1		;d1 = dda accum
	move.w	_DDA_INC(a6),d2		;d2 = dda increment
	moveq	#0,d3			;clear calculated _DELX accumulator
	move.w	d5,d0			;use original _DELX for loop count
	bra	clc_n_su		;enter dbra loop

doub_wid:
	add.w	d2,d1			;_XACC_DDA <- _XACC_DDA + _DDA_INC
	bcc	no_db_wd
	addq.w	#1,d3			;to inc or not to inc--that is the ?
no_db_wd:
clc_n_su:
	dbra	d0,doub_wid
*
	btst.b	#0,_T_SCLSTS+1(a6)	;check scaling up or down
	beq	scal_dwn		;br if scale down
	add.w	d5,d3			;else, scale up--add iter count
scal_dwn:
	move.w	d1,tmp_xacc(a4)		;save xacc accum
	move.w	d3,d5			;scaled _DELX to d5
*
	move.w	d6,tmp_dely(a4)		;save scaled y for use later
	move.w	d5,tmp_delx(a4)		; & x too
	beq	no_blit			;** 25-Feb can't handle 0 widths
*
*  end scaling calculations
*
adr_nobd:
*
*  d5 = adjusted _DELX
*  d6 = adjusted dely
*
*  now, get more destination parms for clip purposes
*
	move.w	_STYLE(a6),d0		;get style flags
	moveq	#0,d1			;assume no skew offsets
	btst	#SKEW,d0		;check for skew
	beq	adr_nosk
	move.w	_R_OFF(a6),d1
	add.w	_L_OFF(a6),d1		;d1 = total of left & right offsets
adr_nosk:
	movem.w	_DESTX(a6),d2-d3	;d2 = _DESTX, d3 = desty
	movem.w	d2-d3,locdestx(a4)	;save in local
*
	clr.w	locweigt(a4)		;assume no local bold form expand
*
	andi.w	#THICKM+SKEWM+OUTLINEM,d0	;check those affecting clip
	beq	adr_nadj		;skip flag adjustments
*
	btst.l	#THICKEN,d0		;check for boldface
	beq	adr_notk		;skip if none
	tst.w	_MONO_STATUS(a6)	;if bold, then in monospaced mode?
	beq	do_thik			;if not mono-spaced, add weight
*
*    Mono-spaced....
*  for compatibilty with textblt, mono-spaced must be ignored if outlined
*  or rotated..
*  
	btst.l	#OUTLINE,d0		;is outline on?
	bne	do_thik			;if so, ignore mono-spaced
	tst.w	_CHUP(a6)		;is rotate on?
	beq	adr_notk		;if not, mono-space by no form expand
do_thik:
*  else, form expand by weight
*
	move.w	_WEIGHT(a6),d4
	move.w	d4,locweigt(a4)
	add.w	d4,d5			;d5 = increased computed _DELX
adr_notk:
	add.w	d1,d5			;add skew offsets (if applicable)
*
	btst	#OUTLINE,d0		;check for outline
	beq	adr_nadj		;skip outline adjust if not outlinin'
	addq.w	#2,d5			;add enough for perimeter on _DELX
	addq.w	#2,d6			;  & likewise for dely
adr_nadj:
*
*  now check rotatin'..
*
	move.w	_CHUP(a6),d0		;get rotate value
	beq	chk_clip		;if none, get on with clip
*
	cmpi.w	#900,d0			;90 degrees?
	bne	add180
*
*  90 degreee rotate
*
	sub.w	d5,d3			;desty <- desty - _DELX move up by DELX
	move.w	d3,locdesty(a4)		;save in local desty
	bra	exgxy			;swap _DELX & dely then clip check
add180:
	cmpi.w	#1800,d0		;180 degrees?
	bne	add270
*
*  180 degree rotate
*
	sub.w	d5,d2			;DESTX <- DESTX - DELX (move rite delx)
	move.w	d2,locdestx(a4)
	bra	chk_clip
add270:
	cmpi.w	#2700,d0		;270 degrees?
	bne	chk_clip		;we don't do no stinkin "obtuse" angles
*
*  270 degree rotate
*
exgxy:
	exg	d5,d6			;DELX <-> DELY (swap for clip check)
*
*****************************************
*
*  Accept char (if all or part is visible)
*  or reject char (if none is visible)
*
*	old	new
*	---	---
*	d0	d2	destx	
*	d1	d5	_DELX
*	d2	d3	desty
*	d3	d6	dely
*	d5	d0	clip flag
*
chk_clip:
	moveq	#0,d0		;clear clip flag bit #31 (assume none)
	move.l	d0,deldely(a4)	;clear clip adjust values for _DELX,dely
	move.l	d0,delsdy(a4)	;clear clip adj values for sourcex/y, destx/y
*
	tst.w	_CLIP(a6)	;check for clipping engaged
	beq	clp_done	;br if not--skip further checking
*
*  y -coord clip check..
*
	move.w	_YMN_CLIP(a6),d4	;get ymin clip boundary
	cmp.w	d4,d3			;top edge >= Y-MIN?
	bge	chk_ymx			;br if so, y min ok
*
*  partially above clip window, check if totally above..
*
	move.w	d4,d0
	sub.w	d3,d0
	move.w	d0,delsdy(a4)		;get adjust value for desty/sourcey
	add.w	d0,deldely(a4)		;adjust adjust value for dely
*
	add.w	d6,d3			;DESTY = DESTY + DELY
	moveq	#-1,d0			;set clip indicator
	cmp.w	d4,d3			;bottom edge > Y-MIN?
	ble	no_blit			;no part within clip window;its gone
	sub.w	d6,d3			;reget desty
chk_ymx:
	move.w	_YMX_CLIP(a6),d4	;get ymax
	cmp.w	d4,d3			;top edge > Y-MAX?
	bgt	no_blit			;exit if so,its totally off window
*
	add.w	d6,d3			;DESTY = DESTY + DELY
	subq.w	#1,d3			;DESTY 0 based
	sub.w	d4,d3			;bottom edge <= Y-MAX
	ble	chk_xmn			;br if so, y-coord wholly within window
*
*  partial clipping of bottom portion..
*
	add.w	d3,deldely(a4)		;adjust adjust value for dely
	moveq	#-1,d0			;set clip indicator
*
*  x - coord clip check..
*
chk_xmn:
	move.w	_XMN_CLIP(a6),d4	;get xmin
	cmp.w	d4,d2			;left edge >= X-MIN?
	bge	chk_xmx			;br if so, go check X-MAX
*
*  partially to left of clip window, check if totally left..
*
	move.w	d4,d0
	sub.w	d2,d0
	move.w	d0,delsdx(a4)
	add.w	d0,deldelx(a4)
*
	add.w	d5,d2			;DESTX = DESTX + DELX
	moveq	#-1,d0			;must clip in x
	cmp.w	d4,d2			;right edge > X-MIN?
	ble	no_blit
	sub.w	d5,d2
chk_xmx:
	move.w	_XMX_CLIP(a6),d4
	cmp.w	d4,d2			;left edge > X-MAX?
	bgt	no_blit			;exit if so, its totally off window
*
	add.w	d5,d2			;DESTX = DESTX + DELX
	subq.w	#1,d2			;DESTX 0 based
	cmp.w	d4,d2			;right edge <= X-MAX?
	ble	clp_done		;br if so, no x-clip
	sub.w	d4,d2
	add.w	d2,deldelx(a4)
	moveq	#-1,d0			;set clip indicator
*
*  clip check done..
*
clp_done:
	move.w	d0,clipon(a4)		;save clip indicator
*
*  set up 1st text blit source (always fontform)..
*
	move.w	_FWIDTH(a6),s_next(a4)	;1st blit src always fontform
	move.w	_DELY(a6),height(a4)	;1st blit src always from font
	clr.w	litemsk(a4)		;assume no liten (only screen blt uses)
	clr.w	skewmsk(a4)		;assume no skew (only screen blt uses)
*
*  init regs for fontform source blit
*
	move.w	_SOURCEX(a6),d0		;d0 = fontform SRC X min
	move.w	_DELX(a6),d3		;get x width
	subq.w	#1,d3			;adjust
	bmi	no_blit			;can't blit 0 or neg widths

	move.w	d0,d4
	add.w	d3,d4			;d4 = fontform SRC X max
*
	move.w	d0,d2			;d2 = SRC X min
	lsr.w	#4,d2			;/8 = byte # on horz
	add.w	d2,d2			;force word boundary
	move.w	_SOURCEY(a6),d5		;get SRC Y min
	move.w	_DELY(a6),d7
	subq.w	#1,d7
	bmi	no_blit

	add.w	d7,d5			;SRC Y max
	mulu	_FWIDTH(a6),d5		;d5 = offset due to Y coord
	movea.l	d5,a0
	adda.l	_FBASE(a6),a0
	adda.w	d2,a0			;a0 => source ptr
*
*  a0 => src ptr, d0 = src XMIN, d4 = src XMAX, d3 = delx-1, d7 = dely-1
*         d1 = sum of skew offsets
*
	tst.w	_DOUBLE(a6)		;are we scalin'?
	beq	chk_skw			;br if not

.page
*******************************************************************************
*
*	scale from font form to 1st buffer buffer
*
*******************************************************************************

replicat:

	swap	d1			;save sum of skew offsets in upper

	move.w	d7,d5			;we need dely - 1 in d5

	mulu	_FWIDTH(a6),d7		;put source ptr back up at top
	suba.l	d7,a0			;a0 -> top of character
*
	move.w	d0,d2			;sourcex
	andi.w	#$F,d2			;form tsdad (source "dot" address)
*
	move.w	d3,d1			;get DELX - 1 in d1
	addq.w	#1,d1			;d1 =  DELX
	movea.l	_scrtchp(a6),a1		;a1 -> destination; always 1st buffer
	move.w	_scrpt2(a6),buffree(a4)	;set buffer #2 as free one now
*
	move.w	#$8000,d3		;d3=dx
	move.w	d3,d4			;d4=bp
	lsr.w	d2,d3
*
noline:
	lsr.w	#3,d1
	add.w	d1,d1
	addq.w	#2,d1
noline1:
	move.w	d1,d_next(a4)
	move.w	d1,s_next(a4)		;will be used for source later
	move.l	a1,a3			;save for use later
*
	move.w	_T_SCLSTS(a6),d7
	roxr.l	#1,d7
	moveq	#0,d7
	roxr.l	#1,d7
*
	move.w	_FWIDTH(a6),d7
	move.w	_DDA_INC(a6),d2
	move.w	#32767,d6
	tst.l	d7
	bmi	rep_ylop
y_dwn_lp:
	add.w	d2,d6
	bcc	y_no_drw
	bsr	yloop
y_no_drw:
	adda.w	d7,a0
	dbra	d5,y_dwn_lp
	bra	y_rep_don
rep_ylop:
	add.w	d2,d6
	bcc	y_no_rep
	bsr	yloop
y_no_rep:
	bsr	yloop
	adda.w	d7,a0
	dbra	d5,rep_ylop
y_rep_don:
	move.w	tmp_xacc(a4),_XACC_DDA(a6)
repexit1:
	move.l	_scrtchp(a6),a0		;this destination is now top source
*
repexit:
	move.w	tmp_dely(a4),d7		;get scaled dely
	move.w	d7,height(a4)		;replace height
	subq.w	#1,d7			;adjust for dely - 1
	clr.w	d0			;d0 = 0 = src XMIN
	move.w	tmp_delx(a4),d3		;get scaled delx
	subq.w	#1,d3			;d3 = delx - 1
	move.w	d3,d4			;d4 = delx - 1 also
	move.w	d7,d2			;scaled dely - 1 to temp
	mulu	s_next(a4),d2		; * scalines
	adda.l	d2,a0			;a0 => bottom/left of char
*
	swap	d1			;restore sum of skew offsets
*
*  a0 => src ptr, d0 = src XMIN, d4 = src XMAX, d3 = delx-1, d7 = dely-1
*
*    end replicate
*
chk_skw:
	moveq	#16,d6			;get 15 + 1
	moveq	#0,d5			;assume no horz fudge
*
	move.w	#BM_SRC,B_LOGOP(a5)	;all blits need this
	move.w	#-1,B_CT_MSK(a5)	;center msk always $ffff
*
*  see if we need to blit into buffer 1st...
*
	move.w	_STYLE(a6),d2		;get style flags in d2
	andi.w	#SKEWM+THICKM+OUTLINEM,d2  ;any of these in effect?
	beq	chk_rota		;br if not
*
chk_chup:
	tst.w	_CHUP(a6)		;rotation?
	bne	prebltt			;if so, we must "preblit"
*
	cmpi.w	#SKEWM,d2		;skew only?
	bne	nt_skewo
	tst.l	d0			;clipped?
	bpl	scrn_blt		;if not, skip preblit
	bra	preskew
nt_skewo:
	cmpi.w	#SKEWM+THICKM,d2	;skew & thicken only?
	bne	prebltt
	tst.l	d0			;clipped?
	bpl	preblt
	bra	preskew
prebltt:
	btst	#SKEW,d2
	beq	preblt	
preskew:
	move.w	#cas1-skewx,skewcase(a4) ;assume case I
	move.w	_SKEWMASK(a6),skewmsk(a4) ;save inverted mask
	not.w	skewmsk(a4)		;make it right
	add.w	d1,d5			;add skew offsets to weight
*
*  need to blit into buffer 1st...
*
preblt:	add.w	locweigt(a4),d5		;add validated bold corpulence
*
	btst	#OUTLINE,d2
	beq	outline0
	addq.w	#2,d5			;increase width by 2
	addq.w	#1,d6			;   but buffer width by 3
	moveq	#1,d2			;dst XMIN = 1
	bra	outline1
outline0:
	moveq	#0,d2			;set dst XMIN = 0
outline1:
	add.w	d3,d6			;add 15 to delx
	add.w	d5,d6			;add effects fudge to delx
*
	lsr.w	#4,d6
	add.w	d6,d6			;d6 = # of bytes wide (word boundry)
	move.w	d6,d_next(a4)
	move.w	d6,d1			;save 
	mulu	d7,d6			;d6 = offset to bottom row
	move.l	_scrtchp(a6),a1		;get destination as 1st buffer
	adda.w	_scrpt2(a6),a1		;always use buffer #2
	clr.w	buffree(a4)		;set-up buffer #1 as free
*
	move.l	a1,a2			;save top/left for use by bold routine
	move.l	a1,a3			;for use by clear routine
	add.l	d6,a1			;a1 => bot/left of destination (buffer)
	tst.w	d2			;is outline required?
	beq	no_out			;br if no outline
*
	add.w	d1,d1			;d1 = # bytes in 2 scanlines of buffer
	add.w	d1,d6			;add 3 more scanlines to # buffer bytes
	adda.w	d1,a2			;move top ptr down 2 more scanlines
	adda.w	d1,a1			;move bot ptr down 2 more scanlines
no_out:
*
*  need to clear buffer 1st
*
	add.w	d1,d6			;total bytes in dest buffer
	lsr.w	#1,d6			;# of words
	moveq	#0,d1
	bra	clearb2i
clearb2:
	move.w	d1,(a3)+
clearb2i:
	dbra	d6,clearb2
*
*  destination now clear
*
	move.w	d3,d6			;d6 = delx - 1
	add.w	d2,d6			;d6 = delx - 1 + dst XMIN = dst XMAX
	add.w	d5,d3			;d3 = delx - 1 + weight + skew offsets
*
	move.w	#2,B_D_NXWD(a5)		;save mono to mono in blit hardware
	clr.w	prevpln0(a4)		;skew needs this
	move.w	#1,nbrplane(a4)
	move.w	#1,forecol(a4)		;set-up colors
	clr.w	backcol(a4)
	move.w	#7,wrt_mod(a4)		;use replace mode for this stuff
*
	movem.l	a1/d2-d3/d7,-(sp)
	move.w	height(a4),-(sp)	;save in case skewing wants to destroy
	bsr	norm_blt		;stuff to buffer
	move.w	(sp)+,height(a4)
*
	btst.b	#THICKEN,_STYLE+1(a6)
	beq	skp_bold
*
*  do bolding in buffer
*
*  a2 => top/left of bold buffer
*
	move.w	height(a4),d3		;scanline height
	move.w	_WEIGHT(a6),d1		;boldness
	subq.w	#1,d1			;d1 = boldness - 1
*
	tst.w	_MONO_STATUS(a6)
	beq	weightok
	clr.w	locweigt(a4)
weightok:
*
	move.w	d_next(a4),d0
	lsr.w	#1,d0			;word width
	subq.w	#1,d0			;d0 = word width - 1
	bra	thicki
*
blinelp:
	moveq	#0,d6			;clear slop from previous bolding
	move.w	d0,d2			;copy word width - 1 to temp
boldlp:
	moveq	#0,d4			;clear grafix accumulator
	move.w	(a2),d4			;pick up next grafix
	swap	d4			;to hi word (use d4 for accumulator)
	move.l	d4,d7			;save unbolded in d7 for shifting
	move.w	d1,d5			;copy boldness - 1 to temp
thicklp:
	lsr.l	#1,d7			;shift unbolded
	or.l	d7,d4			;or into accumulator (for smear)
	dbra	d5,thicklp		;go for full smear
*
	swap	d4
	or.w	d6,d4			;OR in slop from previous word
*
	move.w	d4,(a2)+		;replace
	swap	d4			;get slop-over (if any)
	move.w	d4,d6			;save
	dbra	d2,boldlp		;go for next word in line
thicki:
	dbra	d3,blinelp		;go for next scanline
*
skp_bold:
	movem.l	(sp)+,a0/d0/d3/d7
	move.w	d3,d4			;new src xmax is delx - 1 (wt&offset)
*
	move.w	d_next(a4),s_next(a4)
*
	tst.w	d0			;outline puts 1 here, else 0
	beq	chk_rota		;skip if no outlinin' ta do
*
	movem.l	a0/d0/d3-d4/d7,-(sp)
*
	move.l	_scrtchp(a6),a0
	adda.w	_scrpt2(a6),a0		;top of buffer
	move.w	s_next(a4),d7
	addq.w	#2,height(a4)
	move.w	height(a4),d6
	
*   Outline the contents of buffer
*
*  a0 -> top line of buffer (to be used as temp line buffer, assumed cleared)
*  d6 = # of vertical lines
*  d7 = form width in bytes (must be even)
*
outlin:
	lea	(a0,d7.w),a1	;bump mid line to "real" top line
outlin1:
	lea	(a1,d7.w),a2	;set up a2 to point to 1 line below current
	lsr.w	d7		;# of words in horz line
	subq.w	#1,d7		;for "dbra" sweetie
	bra	srt_lin
out_edge:
	movem.l	a0-a2/d6-d7,-(sp)	;save ptrs & counters
	moveq	#0,d5
	moveq	#0,d6
	move.l	(a2),d1		;get bottom line/left edge grafix data
	lsr.l	d1		;clear left-most bit too
*
*  within line loop entry point..
*
out_loop:
	move.l	(a0),d0		;get next top line grafix data
	move.b	d5,d0		;put bit to left of current data in bit 0
	ror.l	d0		;now its L 15 14 13 ... 1 0 R X X X...
*
	move.l	(a1),d2		;get current line data
	move.b	d6,d2		;same trick
	move.l	d2,d3		;d2 is left-shifted current
	ror.l	d3		;d3 is 0 shifted current
	move.l	d3,d4
	ror.l	d4		;d4 is right-shifted current
*
	move.l	d0,d5		;get copy of top line
	move.l	d0,d6		;get 2nd copy
	eor.l	d2,d0		;exclusive neighbor #1
	eor.l	d3,d5		;exclusive neighbor #2
	eor.l	d4,d6		;exclusive neighbor #3
	rol.l	d5		;adjust 0 shifted for final
	rol.l	#2,d6		;adjust right shifted too
	or.l	d5,d0		;form exclusive accumulator
	or.l	d6,d0
*
	move.l	d1,d5		;now start with a copy of bottom line
	move.l	d1,d6		;need second copy
	eor.l	d2,d1		;exclusive neighbor #4
	eor.l	d3,d5		;exclusive neighbor #5
	eor.l	d4,d6		;exclusive neighbor #6
	rol.l	d5		;adjust 0 shifted for final
	rol.l	#2,d6		;adjust right shifted too
	or.l	d1,d0
	or.l	d5,d0
	or.l	d6,d0
*
	eor.l	d3,d2		;exclusive neighbor #7
	eor.l	d3,d4		;exclusive neighbor #8
	rol.l	#2,d4
	or.l	d2,d0
	or.l	d4,d0
	swap	d0
*
	move.w	(a1),d6
	move.w	d6,d5
	eor.w	d0,d5
	and.w	d0,d5
*
	addq.l	#2,a2		;advance bottom line to next word
	move.l	(a2),d1		;get next bottom line grafix data
	move.b	-1(a2),d1	;same trick as with top line
	ror.l	d1		;now its L 15 14 13 ... 1 0 R X X X...
*
	move.w	d5,(a1)+
	move.w	(a0),d5
	move.w	d6,(a0)+
*
	dbra	d7,out_loop	;finish rest of line
*
	movem.l	(sp)+,a0-a2/d6-d7	;save ptrs & counters
	move.l	a2,a1
	adda.w	s_next(a4),a2
	cmpi.w	#1,d6
	bne	srt_lin
	move.l	a1,a2
srt_lin:
	dbra	d6,out_edge
*
*
	movem.l	(sp)+,a0/d0/d3-d4/d7
*
	clr.w	d0			;dst XMIN = 0 now
	adda.w	s_next(a4),a0
	addq.w	#2,d7
*
*	end outline code
*
chk_rota:
*
*  a0 => src ptr, d0 = src XMIN, d4 = src XMAX, d3 = delx-1, d7 = dely-1
*
*   see about rotation...
*
*
	move.w	_CHUP(a6),d5		;get rotation indicator
	beq	no_rota			;br if none
*
*
*************************************************
*
*	rotation in 90 degree increments
*
*
*    the order that monoplane pixels are rotated..
*
*		  Source		Destination
*
*   90 deg:	0 x x x .. x		x x x x .. x
*		1 x x x .. x		. . . . .. .
*		2 x x x .. x		. . . . .. .
*		3 x x x .. x		x x x x .. x
*		. . . . .. .		x x x x .. x
*		. . . . .. .		x x x x .. x
*		n x x x .. .		0 1 2 3 .. n
*
*
*  180 deg:	x .. x x x x		0 1 2 3 .. n
*		. .. . . . .		x x x x .. x
*		. .. . . . .		x x x x .. x
*		x .. x x x x		x x x x .. x
*		x .. x x x x		. . . . .. .
*		x .. x x x x		. . . . .. .
*		n .. 3 2 1 0		x x x x .. x
*
*
*  270 deg:	n x x x .. x		0 1 2 3 .. n
*		. . . . .. .		x x x x .. x
*		. . . . .. .		x x x x .. x
*		3 x x x .. x		x x x x .. x
*		2 x x x .. x		. . . . .. .
*		1 x x x .. x		. . . . .. .
*		0 x x x .. x		x x x x .. x
*
*
*
*
rotation:
	move.l	_scrtchp(a6),a1		;get buffer for destination
	add.w	buffree(a4),a1		;use free buffer
*
	move.w	locweigt(a4),d4
*
	move.w	s_next(a4),d6		;get previous source wrap
*
	cmpi.w	#1800,d5		;upside down rotation?
	beq	upsd_dwn		;br if so
rot90:
	move.w	d7,d1			;d1 = dely - 1 
	add.w	#16,d1			;add 15 to dely
	lsr.w	#4,d1			;# of bytes needed for wrap
	add.w	d1,d1			;force word boundary
	move.w	d1,s_next(a4)		;save dest wrap as src wrap for next
*
	move.l	a1,a2			;a1 -> top of char in dest buffer
	move.w	d1,d2
	mulu	d3,d2			;d1 = (delx-1) * d_next
	adda.l	d2,a2			;a2 -> bottom of char in dest buffer
*
	movem.l	a2/d3/d7,-(sp)		;save destination bottom ptr on stack
*
	cmpi.w	#2700,d5
	beq	bot_src			;br if 270 deg
*
*  90 deg case
*
	add.w	d4,locdesty(a4)		;adjust vert postion
	move.w	d7,d2			;copy dely - 1 to d2
	mulu	d6,d2			; * source wrap
	suba.l	d2,a0			;sub to form top address now
	neg.w	d6			;src wrap is top down (subtract neg)
	neg.w	d1			;dst wrap is bot up (add negative)
	move.l	a2,a1			;use bottom ptr
bot_src:
	not.w	d0			;src xmin
	andi.w	#$F,d0			;bit # to set
	moveq	#0,d4			;form starting src pixel mask
	bset.l	d0,d4			;  by setting start bit of src XMIN
*
	moveq	#0,d0			;clear destination pixel accumulator
*
rot_ylp:
	movem.l	a0-a1/d7,-(sp)		;save height (dely - 1) & ptrs
	move.w	#$8000,d2		;destination pixel mask (start left)
rot_xlp:
	move.w	(a0),d5			;get source word in scratch d5
	and.w	d4,d5			;mask all but current bit
	beq	rot_nor			; br if not set
	or.w	d2,d0			;else, set corresponding destination
rot_nor:
	ror.w	d2			;shift destination mask
	bcc	rot_isrc		;br if not done with destination accum?
rot_ndst:
	move.w	d0,(a1)+		;gotta full word--put out to dest
	moveq	#0,d0			;clear accum
	suba.w	d6,a0			;subtract source_next to source ptr
	dbra	d7,rot_xlp		;inner loop on source height
	bra	rot_nfrg		;skip fringe save	
rot_isrc:
	suba.w	d6,a0			;subtract source_next to source ptr
rot_srt:
	dbra	d7,rot_xlp		;inner loop on source height
*
	move.w	d0,(a1)			;save last accums to destination
	moveq	#0,d0			;refresh accum
rot_nfrg:
	movem.l	(sp)+,a0-a1/d7		;reget ptrs & height
	adda.w	d1,a1			;add dest_next to dest ptr
	ror.w	d4			;shift source mask
	bcc	rot_nsrc
	addq.l	#2,a0			;adjust src ptr for next sgl plane wrd
rot_nsrc:
	dbra	d3,rot_ylp		;outer loop on source width
*
*
rot_done:
	movem.l	(sp)+,a0/d3/d7		;reget former dest as src ptr,delx/dely
	exg	d3,d7			;new delx-1; dely-1
*
	addq.w	#1,d7
	move.w	d7,height(a4)		;save new height
	subq.w	#1,d7
	clr.w	d0			;new src XMIN is leftmost (0)
	move.w	d0,d4			;form new src XMAX 
	add.w	d3,d4			;  using new delx-1
*
	bra	no_rota
*
*   180 degrees---upside yo' head
*
*
upsd_dwn:
	add.w	d4,locdestx(a4)		;adjust horz position
	move.w	d0,d1
	andi.w	#$F,d1
	add.w	d3,d1			;d1 = delx - 1 
	add.w	#16,d1			;add 15 to delx
	lsr.w	#3,d1			;# of bytes needed for wrap
	andi.w	#$FFFE,d1		;force word boundary
	move.w	d1,s_next(a4)		;save dest wrap as src wrap for next
	adda.w	d1,a0			;put src ptr 1 word beyond bottom row
	lsr.w	#1,d1
	subq.w	#1,d1
*
	move.w	d7,-(sp)		;save height
upsd_lp:
	movea.l	a0,a2			;use a2 as working source
	move.w	d1,d2			;copy words per line to temp
line_lp:
	move.w	-(a2),d4		;pick up source word
	moveq	#0,d5			;clear horz flip accum
*
	lsr.w	d4			;now, h-flip 16 bits
	roxl.w	d5
	lsr.w	d4
	roxl.w	d5
	lsr.w	d4
	roxl.w	d5
	lsr.w	d4
	roxl.w	d5
*
	lsr.w	d4
	roxl.w	d5
	lsr.w	d4
	roxl.w	d5
	lsr.w	d4
	roxl.w	d5
	lsr.w	d4
	roxl.w	d5
*
	lsr.w	d4
	roxl.w	d5
	lsr.w	d4
	roxl.w	d5
	lsr.w	d4
	roxl.w	d5
	lsr.w	d4
	roxl.w	d5
*
	lsr.w	d4
	roxl.w	d5
	lsr.w	d4
	roxl.w	d5
	lsr.w	d4
	roxl.w	d5
	lsr.w	d4
	roxl.w	d5
*
	move.w	d5,(a1)+		;store in destination
	dbra	d2,line_lp
*
	suba.w	d6,a0			;move src from bottom up
	dbra	d7,upsd_lp
*
	move.w	(sp)+,d7		;reget dely -1
*
	add.w	d1,d1
	addq.w	#2,d1			;reconstruct dest wrap
	suba.w	d1,a1			;back dest up to begining of last line
	movea.l	a1,a0			;set up new src ptr
*
	add.w	d3,d0
	addq.w	#1,d0
	neg.w	d0
	andi.w	#$F,d0			;location of last bit in src
	move.w	d0,d4
	add.w	d3,d4
*
*
no_rota:
*
*
*
*
*
*
	bra	scrn_blt		;do blit to screen (last one)
*
nxtword:	.dc.b	2,4,0,8,0,0,0,16

*
*  Destination is screen, this must be our last blit
*
*  a0 => src ptr, d0 = src XMIN, d4 = src XMAX, d3 = delx-1, d7 = dely-1
* 
*
scrn_blt:
	move.w	_WRT_MODE(a6),wrt_mod(a4)	;copy current mode to local
*
	move.w	_v_lin_wr(a6),d_next(a4)	;get wrap ready
	move.w	_v_planes(a6),d1		;plane count
	move.w	d1,nbrplane(a4)
	move.b	nxtword-1(pc,d1.w),d1		;offset to next word
*
	move.w	d1,B_D_NXWD(a5)			;save in blit hardware
	subq.w	#2,d1				;back-up value
	move.w	d1,prevpln0(a4)			;   for skew ptr adjust
*
	move.w	_TEXT_FG(a6),forecol(a4)	;set-up colors
	move.w	_TEXT_BG(a6),backcol(a4)
*
	btst.b	#LIGHT,_STYLE+1(a6)		;lite?
	beq	nolite
*
*  Bud lite please..
*
	move.w	_LITEMASK(a6),d1		 ;get mask
	not.w	d1				 ;was it trivial $FFFF?
	beq	nolite				 ;  skip if so
	move.w	d1,litemsk(a4)			 ;else, save inverted mask
	move.b	#(BM_SRC+BM_PAT)/256,B_LOGOP(a5) ;tell blaster to pattern it

nolite:
	btst.b	#SKEW,_STYLE+1(a6)		;skew?
	beq	noskew
	tst.w	skewmsk(a4)			;was skew already performed?
	beq	set_skew			;br if not
	clr.w	skewmsk(a4)			;if so, don't repeat
	bra	noskew
set_skew:
	move.w	#cas1-skewx,skewcase(a4)	;assume case I
	move.w	_SKEWMASK(a6),d1		;save inverted mask
	not.w	d1
	move.w	d1,skewmsk(a4)
noskew:
*
*  d3 = adjusted delx-1
*
	tst.w	clipon(a4)			;need we clip?
	beq	no_clip				;br if not
*
	sub.w	deldelx(a4),d3
	sub.w	deldely(a4),d7
	move.w	delsdx(a4),d2
	move.w	d0,d5
	add.w	d2,d0
	move.w	d0,d6
	move.w	d0,d4
	add.w	d3,d4
	lsr.w	#4,d5
	lsr.w	#4,d6
	sub.w	d5,d6
	add.w	d6,d6
	adda.w	d6,a0
*
	move.w	deldely(a4),d5
	sub.w	delsdy(a4),d5
	mulu	s_next(a4),d5
	suba.l	d5,a0
*
	add.w	locdestx(a4),d2			;d2 = screen DST X min
	move.w	d2,d6
	add.w	d3,d6				;d6 = DST X max
*
	move.l	_v_bas_ad,a1
	move.w	d2,d5				;d5 = DST X min
	move.w	_v_planes(a6),d3
	move.b	shf_tab-1(pc,d3.w),d3		;do concat thing
	andi.w	#$fff0,d5

*04Feb	lsr.w	d3,d5
	asr.w	d3,d5				* 04 Feb 87      preserve sign

	move.w	delsdy(a4),d3
	add.w	d3,_SOURCEY(a6)			* compatibilty with old TEXTBLT

	add.w	locdesty(a4),d3
	add.w	d7,d3
	muls	d_next(a4),d3			* 08 Mar 87  handle negative Y
	adda.l	d3,a1				* a1 -> bottom row of char dst
	adda.w	d5,a1				* a1 -> bottom word of char dst

	addq.w	#1,d7
	move.w	d7,height(a4)		
	bra	blit_mon

shf_tab:
*	planes	1 2   4       8
	dc.b	3,2,0,1,0,0,0,0

no_clip:

	move.w	locdestx(a4),d2			;d2 = screen DST X min
	move.w	d2,d6
	add.w	d3,d6				;d6 = DST X max
*
	move.l	_v_bas_ad,a1
	move.w	d2,d5				;d5 = DST X min
	move.w	_v_planes(a6),d3
	move.b	shf_tab-1(pc,d3.w),d3		;do concat thing
	andi.w	#$fff0,d5

*04Feb	lsr.w	d3,d5
	asr.w	d3,d5				* 04 Feb 87    preserve sign

	move.w	locdesty(a4),d3
	add.w	d7,d3
	muls	d_next(a4),d3			* 08 Mar 87
	adda.l	d3,a1				* 08 Mar 87
	adda.w	d5,a1				* 04 Feb 87
*
blit_mon:
	bsr	norm_blt
no_blit:
*
*  adjust line "A" variables after blit is complete..
*
	move.w	_DELX(a6),d0
	tst.w	_DOUBLE(a6)
	beq	upda_ndb
	move.w	tmp_delx(a4),d0
	move.w	tmp_xacc(a4),_XACC_DDA(a6)
upda_ndb:
	btst.b	#OUTLINE,_STYLE+1(a6)
	beq	upda_not
	addq.w	#2,d0
	bra	upda_xxx	;preserving inconsistency of TEXTBLT
upda_not:
	add.w	locweigt(a4),d0
upda_xxx:
	move.w	_CHUP(a6),d1
	bne	ck90
upda_x:
	add.w	d0,_DESTX(a6)
upda_xx:
	unlk	a4

	movem.l	(sp)+,a5-a6		*** jde 18jun86 ***
	rts
*
*
ck90:
	cmpi.w	#900,d1
	bne	ck180
	sub.w	d0,_DESTY(a6)
	bra	upda_xx
ck180:
	cmpi.w	#1800,d1
	bne	ck270
	sub.w	d0,_DESTX(a6)
	bra	upda_xx
ck270:
	cmpi.w	#2700,d1
	bne	upda_x
	add.w	d0,_DESTY(a6)
	bra	upda_xx

*
*
*
*
*
* in:
*	d0	SRC X min
*	d2	DST X min
*	d4	SRC X max
*	d6	DST X max
*
*
*	a0	points to source start (lower/left corner)
*	a1	points to destination start (lower/left corner)
*
*	a4	points to local "Link" variables
*	a5	points to blaster registers
*	a6	points to Line "A" variable base
*
*
*      ASSUMED SET PRIOR TO ENTRY:
*
*	s_next(a4)	<-width of source form
*	d_next(a4)	<-width of destination form
*	prevpln0(a4)	<-offset to back ptr up from last plane to plane 0
*	height(a4)	<-# of scanlines
*	nbrplane(a4)	<-# of planes
*	forecol(a4)	<-foreground color
*	backcol(a4)	<-background color
*	litemsk(a4)	<-inverted liten mask (=0 if no liten)
*	skewmsk(a4)	<-skew mask (1=shift or %0000000000000000 if none)
*	skewcase(a4)	<-assume cas1
*	
*
*	B_S_NXWD(a5)	<- 2 for monochrome sources
*	B_D_NXWD(a5)	<- 2, 4 or 8 for screen rez destinations
*	B_CT_MSK(a5)	<- $FFFF
*	B_LOGOP(a5)	<- #BM_SRC  or  #BM_SRC+BM+PAT
*
*
*
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
*
*
*
norm_blt:
	move.w	#2,B_S_NXWD(a5)		;source is always mono
*
	moveq.l	#$0F,d1			; d1 <- modulo 16 mask
*
	move.w	d2,d5			; d5 <- D_XMIN
	and.w	d1,d5			; d5 <- D_XMIN mod16
	move.w	d5,d7			; d7 <- D_XMIN mod16	
	add.w	d5,d5			; d5 <- offset into mask table
	move.w	fr_lf_mask(pc,d5.w),d3
	not.w	d3
	swap	d3			; d3[31:16] <- lf fringe mask
*
	move.w	d6,d5			; d5 <- D_XMAX
	and.w	d1,d5			; d5 <- D_XMAX mod16
	add.w	d5,d5			; d5 <- offset into mask table
	move.w	fr_rt_mask(pc,d5.w),d3	; d3[15:00] <- rt fringe mask
*
*
*  create discriminator (and primordial skew count)
*
	move.w	d0,d5			; d5 <- S_XMIN
	and.w	d1,d5			; d5 <- S_XMIN mod16
	sub.w	d5,d7			; d7 <- D_XMIN mod16 - S_XMIN mod16
*
	sub.w	d4,d5			; subtract lo nibbles: S_MIN - S_MAX
	neg.w	d5
	eor.w	d4,d5
	and.w	#$FFF0,d5		; d5 = 0 if dest span can be source +1
*
*  convert X parameters to word displacements
	asr.w	#4,d0			; d0 <- S_XMIN / 16 **4-Feb**
	asr.w	#4,d4			; d4 <- S_XMAX / 16 **4-Feb**
	asr.w	#4,d2			; d2 <- D_XMIN / 16 **4-Feb**
	asr.w	#4,d6			; d6 <- D_XMAX / 16 **4-Feb**
*
*  calculate S_SPAN
*
	move.w	d4,d1			; d1 <- S_XMAX/16
	sub.w	d0,d4			; d4 <- S_SPAN-1
*
*
*  calculate D_SPAN
*
	move.w	d6,d1			; d1 <- D_XMAX/16
	sub.w	d2,d6			; d6 <- D_SPAN -1
*
*  a0 = source block
*
	bgt	fringe_ok		; check for single fringe case
*
	move.l	d3,d5			; merge both masks into one
	clr.w	d5			;force right fringe to 0
	swap	d5			; d3[15:00] <- single fringe mask
	and.l	d5,d3			; d3[31:16] <- single fringe mask
	swap	d3
	tst.w	d4			;see if source span = 2
	bne	do_cas2			;br if so -- case II skew
*
*  single-word case
*
	move.w	d6,d0			; d0 <- B_D_SPAN -1
	addq.w	#1,d0			; d0 <- B_D_SPAN
	move.w	d0,B_D_SPAN(a5)		; load blt with DST word span
*
	move.w	d7,B_S_NXWD(a5)		;NXWD<0:left shift, else:right shift
*
	move.w	s_next(a4),d0
	neg.w	d0
	move.w	d0,B_S_WRAP(a5)
	move.w	d_next(a4),d0
	neg.w	d0
	move.w	d0,B_D_WRAP(a5)
*
	and.w	#$000F,d7		; d7 <- skew count
	ori.w	#BM_GO,d7
*
	bra	init_blt
*
*  Source span > 0
*
fringe_ok:
	tst.w	skewmsk(a4)		;check for skew in effect
	beq	non_sgl			;br if not
*
*  skewing, find case
*
	tst.w	d4			;check for source span = 1
	beq	non_sgl			;if so, do case I

	move.w	#cas4-skewx,d0		;assume case IV
	tst.w	d5
	beq	setcase
*
*  must be II or III
*
	move.w	#cas3-skewx,d0		;assume case III
	cmpi.w	#1,d4			;2 word source span?
	bne	setcase			;br if not (must be 3 or more)
do_cas2:
	move.w	#cas2-skewx,d0
setcase:
	move.w	d0,skewcase(a4)
*
*   end skew casing
*
non_sgl:
*
*  non-single word case..
*
*  a1 => destination block
*
	moveq	#0,d1
*
	move.w	d6,d0			; d0 <- B_D_SPAN -1
	addq.w	#1,d0			; d0 <- B_D_SPAN
	move.w	d0,B_D_SPAN(a5)		; load blt with DST word span

	tst.w	d7			; d7 = Dx&F - Sx&F
	bge	compare_spans
*
	addq.w	#2,d1			; d1[bit1] Sx&F>Dx&F    0:false 1:true
*
compare_spans:
*
	cmp.w	d4,d6
	bne	calculate_wrap
*
	addq.w	#4,d1			; d1[bit2] spans equal  0:false 1:true
*
calculate_wrap:

	move.w	d4,d0			; d0 <- S_SPAN-1
*
	muls	B_S_NXWD(a5),d4		; S_WRAP = S_NXLN - (S_NXWD * S_SPAN-1)
	neg.w	d4
	sub.w	s_next(a4),d4		; d4 <- S_WRAP
*
	muls	B_D_NXWD(a5),d6		; D_WRAP = D_NXLN - (D_NXWD * D_SPAN-1)
	neg.w	d6
	sub.w	d_next(a4),d6		; d6 <- D_WRAP
*
	move.w	d4,B_S_WRAP(a5)
	move.w	d6,B_D_WRAP(a5)
blt_setup:

	and.w	#$000F,d7		; d7 <- skew count
	or.w	blt_ctrl(pc,d1.w),d7	; d7 <- skew count w/ctrl flags & GO
*
*  initialize blt time variables
*
init_blt:
*
save_fringe_masks:
	move.w	d3,B_F2_MSK(a5)		; load right fringe
	swap	d3
	move.w	d3,B_F1_MSK(a5)		; load left fringe
*
*  no pattern.  mono or multi-plane 16 word contiguous patterns.
*
	move.w	litemsk(a4),d6		;lighten requested?
	beq	chk_skew		; br to check on skew if not
	not.w	d6
	lea	B_PATTERN(a5),a5	; a5 -> 1st PATTERN reg
	moveq	#15,d0
litelp:
	move.w	d6,(a5)+
	ror.w	d6
	dbra	d0,litelp
	lea	28(a5),a5		; a5 -> B_SKEW (BLASTER reference reg)
*
chk_skew:
*
*  check skew in here
*
	tst.w	skewmsk(a4)
	bne	do_skew
*
*
*
no_skew:
	move.w	height(a4),d4
	move.w	nbrplane(a4),d5
*
	move.w	backcol(a4),d2		; a queue of logic ops, 1 per plane
	move.w	forecol(a4),d3		; could be set up prior to the blt

	bra	blt_0_count
*
*
*
*   T a B l E   f O r   S e T t I n G   b L t   c O n T r O l   F l A g S
*
*
*		      spans  Sx&F>              pre     flush
*		      equal  Dx&F              fetch    queue
*		      -----  -----             -----    -----
*	      	        0      0		 0        1
*		        0      1		 1	  0
*		        1      0		 0	  0
*		        1      1		 1	  1
*
*
*							0:false 1:true
*
blt_ctrl:
	dc.w	BM_GO+00000+BM_FQ+BM_HOG
	dc.w	BM_GO+BM_PF+00000+BM_HOG
	dc.w	BM_GO+00000+00000+BM_HOG
	dc.w	BM_GO+BM_PF+BM_FQ+BM_HOG
*
*
*
*
*
*
*  the commonly used multi-plane BLASTER control loop


blt_0_loop:

	move.l	a0,B_S_ADDR(a5)		; load blt with SRC addr
	move.l	a1,B_D_ADDR(a5)		; load blt with DST addr
	move.w	d4,B_HEIGHT(a5)		; load # rows to blt

	move.w	wrt_mod(a4),d6		;d6 = 00000000 000wwwww
	lsr.w	#1,d3			;peel off a foreground bit
	addx.w	d6,d6			;d6 = 00000000 00wwwwwf
	lsr.w	#1,d2			;peel background bit
	addx.w	d6,d6			;d6 = 00000000 0wwwwwfb

	move.b	wrmtab(pc,d6),B_LOGOP+1(a5)

*******************************************************************************
	move.w	d7,(a5)			* load control word (GO:1 HOG:0)
*******************************************************************************

	addq.l	#2,a1			; a1 -> new DST plane

blt_0_sync:

	tas	(a5)			; restart bitblt
	nop
	bmi	blt_0_sync

blt_0_count:

	dbra	d5,blt_0_loop

.ifeq	P68030

	movec.l	cacr,d5			; d2 <- cache control register
	bset.l	#11,d5			; set "Clr DATA Cache" bit
	movec.l	d5,cacr			; clear the data cache
.endc
	rts



*  writing mode mapping tables:
*
*
*	fb=	00  01  10  11

wrmtab:
	.dc.b	$0,$0,$3,$3		*replace mode
	.dc.b	$4,$4,$7,$7		*transparent mode
	.dc.b	$6,$6,$6,$6		*XOR mode
	.dc.b	$1,$1,$D,$D		*inverse transparent mode
*
	.dc.b	$0,$F,$0,$F		*mode 0  D' = 0
	.dc.b	$0,$E,$1,$F		*mode 1  D' = S and D
	.dc.b	$0,$D,$2,$F		*mode 2  D' = S and [not D]
	.dc.b	$0,$C,$3,$F		*mode 3  D' = S	(replace)
	.dc.b	$0,$B,$4,$F		*mode 4  D' = [not S] and D
	.dc.b	$0,$A,$5,$F		*mode 5  D' = D
	.dc.b	$0,$9,$6,$F		*mode 6  D' = S xor D (XOR mode)
	.dc.b	$0,$8,$7,$F		*mode 7  D' = S or D  (OR mode)
	.dc.b	$0,$7,$8,$F		*mode 8  D' = not [S or D]
	.dc.b	$0,$6,$9,$F		*mode 9  D' = not [S xor D]
	.dc.b	$0,$5,$A,$F		*mode A  D' = not D
	.dc.b	$0,$4,$B,$F		*mode B  D' = S or [not D]
	.dc.b	$0,$3,$C,$F		*mode C  D' = not S
	.dc.b	$0,$2,$D,$F		*mode D  D' = [not s] or D
	.dc.b	$0,$1,$E,$F		*mode E  D' = not [S and D]
	.dc.b	$0,$0,$F,$F		*mode F  D' = 1
*
blt_adj:
	move.l	-(a0),d0
	neg.w	-(a1)
	moveq.l	#$65,d3
	movea.l	(a3),a0
	moveq.l	#$61,d2
	subq.w	#2,-(a7)
	bsr	blt_adj+$81
	movea.l	$6F76(a4),a0
	bcs	blt_adj+$87
	movea.l	d2,a0
	bcs	blt_adj+$79
	movea.l	a0,a0
	bsr	blt_adj+$7E
	bge	blt_adj+$87
	beq	blt_adj+$40
	rts
*
*
do_skew:
*
*  we're skewin'..
*
	move.w	B_F1_MSK(a5),d0
	swap	d0
	move.w	B_F2_MSK(a5),d0		;get mask
*
next_sec:
	move.w	d0,B_F2_MSK(a5)
	swap	d0
	move.w	d0,B_F1_MSK(a5)		;redo mask
	swap	d0
*
	move.w	nbrplane(a4),d5
	move.w	backcol(a4),d2		; get background color bits in d2
	move.w	forecol(a4),d3		; foreground color bits to lsr in d3
*
	moveq	#0,d4
mo_skew:
	addq.w	#1,d4
	rol.w	skewmsk(a4)
	bcc	mo_skew
*
	sub.w	d4,height(a4)
	ble	dolast
*
	bsr	blt_0_count		;do all planes worth, this block
*
	move.w	(a5),d7			;retrieve skew value
	ori.w	#BM_GO,d7		;set for go in case skew & lighten
	muls	s_next(a4),d4		;**19-Mar** update our own src addr
	suba.l	d4,a0			;**19-Mar** since bltter won't always
*
*
	move.l	B_D_ADDR(a5),a1		; get DST addr from blt
	sub.w	prevpln0(a4),a1		;back up to start at plane 0
	move.w	skewcase(a4),d4
	jmp	skewx(pc,d4.w)

*
dolast:
	add.w	height(a4),d4	
	bra	blt_0_count
*
*
skewx:
*
*  Case I --source span is 1 word
*
cas1:
	addq.w	#1,d7			;advance skew
	bclr.l	#4,d7
	beq	cas1a			;br if skew non-zero
	move.w	#2,B_S_NXWD(a5)
cas1a:
	lsr.l	d0
	cmpi.w	#$8000,d0		;lo word = $8000?
	bne	cas1b			;br over t1 if not
*
	ori.w	#BM_FQ,d7		
	move.w	B_D_WRAP(a5),d6
	sub.w	B_D_NXWD(a5),d6
	move.w	d6,B_D_WRAP(a5)
	addq.w	#1,B_D_SPAN(a5)
cas1b:
	cmpi.l	#$10000,d0		;hi word = 0?
	bcc	next_sec
	swap	d0
	move.w	B_D_NXWD(a5),d6
	add.w	d6,B_D_WRAP(a5)
	adda.w	d6,a1
	subq.w	#1,B_D_SPAN(a5)
	andi.w	#$FFFF-BM_FQ,d7		;"not" BM_FQ
	move.w	d7,d6
	andi.w	#$000F,d6
	beq	next_sec
	move.w	#-2,B_S_NXWD(a5)
	bra	next_sec
*
*  Case II --source span is 2 words, 16 pixels or less wide
*
cas2:
	addq.w	#1,d7			;advance skew
	bclr.l	#4,d7
	beq	cas2a			;br if skew non-zero
	andi.w	#$FFFF-(BM_FQ+BM_PF),d7	;"not" BM_FQ+BM_PF
cas2a:
	lsr.l	d0
	cmpi.l	#$10000,d0		;hi word = 0?
	bcc	cas2b
	swap	d0
	move.w	B_D_NXWD(a5),d6
	add.w	d6,B_D_WRAP(a5)
	adda.w	d6,a1
	subq.w	#1,B_D_SPAN(a5)
	andi.w	#$FFFF-BM_FQ,d7		;may not be needed
	ori.w	#BM_PF,d7
cas2b:
	cmpi.w	#$8000,d0		;lo word = $8000?
	bne	next_sec
*
	move.w	B_D_WRAP(a5),d6
	sub.w	B_D_NXWD(a5),d6
	move.w	d6,B_D_WRAP(a5)
	addq.w	#1,B_D_SPAN(a5)
	ori.w	#BM_FQ+BM_PF,d7		
	move.w	d7,d6
	andi.w	#$F,d6
	bne	next_sec
	andi.w	#$FFFF-(BM_FQ+BM_PF),d7	;"not" BM_FQ+BM_PF
	bra	next_sec
*
*  Case III --source span is 2 or more words, dest span is source or source-1
*
cas3:
	addq.w	#1,d7			;advance skew
	bclr.l	#4,d7
	beq	cas3a			;br if skew non-zero
	andi.w	#$FFFF-(BM_FQ+BM_PF),d7	;"not" BM_FQ+BM_PF
cas3a:
	lsr.l	d0
	roxr.l	d6			;save carry-out in bit #31
	cmpi.l	#$10000,d0		;hi word = 0?
	bcc	cas3b
	ext.l	d0			;move $FFFF to hi word
	move.w	B_D_NXWD(a5),d6
	add.w	d6,B_D_WRAP(a5)
	adda.w	d6,a1
	subq.w	#1,B_D_SPAN(a5)
	ori.w	#BM_PF,d7
	andi.w	#$FFFF-BM_FQ,d7
cas3b:
	lsl.l	d6			;get carry-out
	bcc	next_sec
*
	move.w	#$8000,d0
	move.w	B_D_WRAP(a5),d6
	sub.w	B_D_NXWD(a5),d6
	move.w	d6,B_D_WRAP(a5)
	addq.w	#1,B_D_SPAN(a5)
	ori.w	#BM_FQ+BM_PF,d7		
	move.w	d7,d6
	andi.w	#$000F,d6
	bne	next_sec
	andi.w	#$FFFF-(BM_FQ+BM_PF),d7	;"not" BM_FQ+BM_PF
	bra	next_sec
*
*  Case IV --source span is 2 or more words, dest span is source or source+1
*
cas4:
	addq.w	#1,d7			;advance skew
	bclr.l	#4,d7
	beq	cas4a			;br if skew non-zero
	andi.w	#$FFFF-(BM_FQ+BM_PF),d7	;clear BM_FQ and BM_PF
cas4a:
	lsr.l	d0
	bcc	cas4b
*
	move.w	#$8000,d0
	move.w	B_D_WRAP(a5),d6
	sub.w	B_D_NXWD(a5),d6
	move.w	d6,B_D_WRAP(a5)
	addq.w	#1,B_D_SPAN(a5)
	andi.w	#$FFFF-BM_PF,d7
	ori.w	#BM_FQ,d7		
cas4b:
	cmpi.l	#$10000,d0		;hi word = 0?
	bcc	next_sec
	ext.l	d0			;move $FFFF to hi word
	move.w	B_D_NXWD(a5),d6
	add.w	d6,B_D_WRAP(a5)
	adda.w	d6,a1
	subq.w	#1,B_D_SPAN(a5)
	ori.w	#BM_PF+BM_FQ,d7
	move.w	d7,d6
	andi.w	#$F,d6
	bne	next_sec
	andi.w	#$FFFF-(BM_FQ+BM_PF),d7	;"not" BM_FQ+BM_PF
	bra	next_sec
*
*
***************************************************
*
*  yloop routine  (used by scaling code)
*
*
*  entry:	d1 = d_next		preserved
*		d2 = _DDA_INC		preserved
*		d3 = source bitmask	destroyed
*		d4 = dest bitmask	destroyed
*
*		a0 = source ptr		preserved
*		a1 = destination ptr	adjusted for next
*
*
*		a4 = local ram ptr
*		a5 = bit blit hardware base addr
*		a6 = line A variables
*
*				 	   8086 Equiv
*  reg use:  	d0 = grafix build		bx
*		d1 = d_next			n/a
*		d2 = _DDA_INC			di
*		d3 = source bitmask		dx 
*		d4 = dest bitmask		bp
*		d5 = width			cx
*		d6 = temp			n/a
*		d7 = _XACC_DDA			si
*
*		a0 = source ptr			si
*		a1 = destination ptr		di
*		a2 = source data temp		n/a
*
*
*
yloop:
	movem.l	a0-a1/d3-d7,-(sp)		;save some regs
	clr.w	d0				;clear grafix
	move.w	_DELX(a6),d5
	subq.w	#1,d5				;adjust for dbra
*
	move.w	_XACC_DDA(a6),d7
	bra	nextsrc
innerlp:
	ror.w	#1,d3
	bcc	reploop
nextsrc:
	movea.w	(a0)+,a2
reploop:
	move.w	a2,d6
	and.w	d3,d6
	bne	nrepnor
*
repnor:
	tst.l	d7
	bmi	repnorup
	add.w	d2,d7
	bcc	incsrc
	bra	ordone
repnorup:
	add.w	d2,d7
	bcc	ordone
*
	ror.w	#1,d4
*
	bcc	ordone
	move.w	d0,(a1)+
	clr.w	d0
*
	bra	ordone
nrepnor:
*
	add.w	d2,d7
	bcc	o_no_rep
*
	or.w	d4,d0
	ror.w	d4
	bcc	o_no_rep
	move.w	d0,(a1)+
	clr.w	d0
o_no_rep:
	tst.l	d7
	bpl	incsrc
*
	or.w	d4,d0
ordone:
	ror.w	#1,d4
	bcc	incsrc
nextdst:
	move.w	d0,(a1)+
	clr.w	d0
incsrc:
	dbra	d5,innerlp
repdone:
	move.w	d0,(a1)
	movem.l	(sp)+,a0-a1/d3-d7
	adda.w	d1,a1
	rts

	.end
