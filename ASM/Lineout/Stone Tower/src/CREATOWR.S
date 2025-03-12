	COMMENT	HEAD=%111

camwidth:	EQU	160
camheigth:	EQU	100
towerwidth:	EQU	160
towerheigth:	EQU	100

	bra	START

	INCLUDE	INCLOAD.I
	TEXT

START:
	lea	toweroffset_tbl,a0
	bsr	CALC_TOWERTABLE

	lea	towertabname_txt,a0
	lea	toweroffset_tbl,a1
	move.l	#towerwidth*towerheigth*2,d0
	bsr	save

	clr.w	-(sp)
	trap	#1

******** SUBROUTINES ********

CALC_TOWERTABLE:
	movea.l	#-(camwidth<<16),a1		* Xstart
	movea.l	#$00300000,a2			* Ystart
	movea.l	#-(camheigth<<16),a3		* Zstart
	move.l	#camwidth*2<<16/towerwidth,d3	* Hor Xinc
	move.l	#$00000000,d4			* Hor Yinc
	move.l	#$00000000,d5			* Hor Zinc
	movea.l	#$00000000,a4			* Ver Xinc
	movea.l	#$00000000,a5			* ver Yinc
	movea.l	#camheigth*2<<16/towerheigth,a6	* Ver Zinc
	moveq	#towerheigth-1,d7

.yloop:	move.l	a1,d0
	move.l	a2,d1
	move.l	a3,d2
	swap	d7
	move.w	#towerwidth-1,d7

.xloop:
* v := z * r/sqrt(x*x+y*y)
	fmove.l	d0,fp0
	fmove.l	d1,fp1
	fmove.l	d2,fp2
	fdiv.s	#65536,fp0
	fdiv.s	#65536,fp1
	fdiv.s	#65536,fp2
	fmul	fp0,fp0
	fmul	fp1,fp1
	fadd	fp0,fp1
	fsqrt	fp1
	fmove.s	#8000,fp3
	fdiv	fp1,fp3
	fmul	fp2,fp3
	fmove.l	fp3,d6
	andi.w	#%111110000000,d6
	move.w	d6,(a0)

* u := atan2(y, x)
	fmove.l	d1,fp0
	fdiv.l	d0,fp0
	fatan	fp0
	;fmul.s	#40.74466543,fp0
	;fmul.s	#81.48933086,fp0
	fmul.s	#162.9746617,fp0
	fmove.w	fp0,d6
	andi.w	#%111110,d6
	or.w	d6,(a0)+

* Interpolate new vector in horizontal-direction.
	add.l	d3,d0
	add.l	d4,d1
	add.l	d5,d2
	dbra	d7,.xloop

	adda.l	a4,a1
	adda.l	a5,a2
	adda.l	a6,a3
	swap	d7
	dbra	d7,.yloop
	rts

******** DATA AND INCLUDES ********

	DATA

towertabname_txt:
	DC.B	"TOWER.DAT",0
	EVEN

******** RESERVES ********

	BSS

toweroffset_tbl:
	DS.W	towerwidth*towerheigth
