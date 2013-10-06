**************************************************************************************
*	FADE_S.S
*
*	interrupt based fade rout
*
*	[c] 2001 Reservoir Gods
**************************************************************************************

**************************************************************************************
;	EXPORTS / IMPORTS
**************************************************************************************

	export	Fade_Vbl

	export	gFadeVblActiveFlag

	import	Fade_PalSTE
	import	Video_SetNextPalST

	import	gFadeVblAdd
	import	gFadeVblScale
	import	gpFadeVblTmpPal
	import	gpFadeVblOldPal
	import	gpFadeVblTargetPal



**************************************************************************************
	TEXT
**************************************************************************************

*------------------------------------------------------------------------------------*
* FUNCTION : Fade_Vbl
* ACTION   : does a vbl based fade
* CREATION : 11.04.01 PNK
*------------------------------------------------------------------------------------*

Fade_Vbl:
	
	tst.b	gFadeVblActiveFlag
	beq.s	.nofade

	tas.b	gFadeVblLockFlag
	bne		.nofade

	movem.l	d0-a6,-(a7)

	move.l	gFadeVblAdd,d0
	add.l	d0,gFadeVblScale

	move.w	gFadeVblScale,d1
	cmp.w	#$100,d1
	blt.s	.less
	move.w	#$100,d1
	clr.b	gFadeVblActiveFlag
.less:

	move.l	gpFadeVblTmpPal,a0
	move.l	gpFadeVblOldPal,a1
	moveq	#16,d0
	move.l	gpFadeVblTargetPal,-(a7)
	jsr		Fade_PalSTE
	addq.l	#4,a7

	move.l	gpFadeVblTmpPal,a0
	jsr		Video_SetNextPalST

	movem.l	(a7)+,d0-a6
	clr.b	gFadeVblLockFlag	

.nofade:
	rts


**************************************************************************************
	DATA
**************************************************************************************

gFadeVblLockFlag:	dc.b	0
gFadeVblActiveFlag:	dc.b	0