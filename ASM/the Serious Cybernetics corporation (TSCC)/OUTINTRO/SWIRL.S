; Swirl effect, by ray//.tSCc., jan. 2007



SWRL_XWIN 	=	128	; Resolution of the effect window
SWRL_YWIN 	=	128

SWRL_TEX_U_BITS =	8	; Texture resolution (2 ^ BITS)
SWRL_TEX_V_BITS =	8


		data
swrlPalObj: 	dc.w	15		; Swirl palette object
		dc.l	outPal

		dc.w	OUTLOGO_Y-1
swrlFade:	dc.w	1
		dc.l	swrlPalette

		dc.w	SWRL_YWIN-1,15
		dc.l	outPal

;>swrlFade:	dc.w	1
;>		dc.l	swrlPalette

		dc.w	-1


swrlPalette:	include	'swirlpal.i'


		text
rad:		dc.l 0			; Swirl offset (animation counter)


******************************************************
*  Swirl screen demo sequencing routines
******************************************************

swirlInit:     	move.l	#LOGO_X*LOGO_Y,d0
		moveq.l	#TTRAM,d1
		bsr.w	AllocSomeMem
		move.l	d0,tsccPtr

		lea.l	tsccPak,a0
		movea.l	d0,a1
		bsr.w	d_lz77

                movea.l	tsccPtr,a0		; Blit logo onto the screen
                movea.l	screen3(pc),a1
                lea.l	((PHYS_Y-LOGO_Y)/2)*BYTESPERSCL+((BYTESPERSCL-LOGO_X/2)/2)(a1),a1

                move.w	#LOGO_Y-1,d0

.y_blit:	moveq.l	#LOGO_X/2/4-1,d1

.x_blit:	move.l	(a0)+,(a1)+
		dbra	d1,.x_blit

		lea.l	(BYTESPERSCL-LOGO_X/2)(a1),a1
		dbra	d0,.y_blit

		bsr.w	cycleScreens

		lea.l   logoPalObj,a0  	; Fade in intro picture
		bsr.w	installSplitPalette

		move.l	#logoFadeIn,VBLHookPtr

		bra.w	initSwirl	; Init effect

swirlInitFadeOut:
		move.l	#logoFadeOut,VBLHookPtr	; Fade out again

.fizzle_out:	tst.w	logoFade2
		bne.s	.fizzle_out

		bsr.w	clearScreens

		move.l	tsccPtr,d0	; Release image
		bra.w	FreeSomeMem


swirlDeinit:	bsr.w	restoreSwirl
		bra.w	setSemaphore


swirlFadeIn:	lea.l	swrlPalObj,a0	; Fade in
		bsr.w	installSplitPalette

		move.l	#swrlFadeIn,VBLHookPtr
		bra.w	setSemaphore


swirlFadeOut:   move.l	#swrlFadeOut,VBLHookPtr
		bra.w	swirlMain


*********************************************************
*  void swrlFadeIn()
*  void swrlFadeOut()
*
* Fading VBL hook routines.
*********************************************************

swrlFadeIn:	moveq.l	#3,d0
		and.l	$466.w,d0	; Fade every 4th VBL
		bne.s	.break

		moveq.l	#(1<<PHYS_BPP)-1,d0	; Max. brightness

		cmp.w	swrlFade(pc),d0	; Max. brightness approached yet?
		beq.s	.done

		addq.w	#1,swrlFade

.break:		rts

.done:		clr.l	VBLHookPtr
		rts


swrlFadeOut:	moveq.l	#3,d0		; Fade every 4th VBL
		and.l	$466.w,d0
		bne.s	.break

      		tst.w	swrlFade	; Min. brightness approached yet?
		beq.s	.done

		subq.w	#1,swrlFade

.break:		rts

.done:          clr.l	VBLHookPtr
		rts


*********************************************
*  void initSwirl()
*
* Initialise swirl effect.
*********************************************

		text
initSwirl:      move.l	#SWRLBLK_LEN*(SWRL_XWIN/4*SWRL_YWIN)+2,d0	; Allocate swirl arrays
		moveq	#TTRAM,d1
		bsr.w	AllocSomeMem
		move.l	d0,swirlCodePtr

		move.l	#2*(1<<(SWRL_TEX_U_BITS+SWRL_TEX_V_BITS)),d0
		moveq	#TTRAM,d1
		bsr.w	AllocSomeMem
		move.l	d0,swirlTexPtr

; Deflate texture

		lea.l	swirlTexPak,a0
		movea.l swirlTexPtr,a1
		bsr.w	d_lz77

		lea.l	swirlTexPak,a0
		bsr.w	d_lz77

; Preshift texture

		movea.l	swirlTexPtr,a0
		move.w	#2*(1<<(SWRL_TEX_U_BITS+SWRL_TEX_V_BITS))/4-1,d0

.preshift:
	rept	4
		move.b	(a0),d1
		lsl.b	#2,d1
		move.b	d1,(a0)+
	endr
		dbra	d0,.preshift
; Build c2p table

;>		lea.l	c2p,a1
;>		lea.l	.c2pTmp(pc),a0
;>
;>
;>		moveq	#16-1,d0
;>
;>.c2p_cpy_loop:	move.l	(a0)+,d1
;>		move.l	d1,3*4*16(a1)
;>		lsl.l	#2,d1
;>		move.l	d1,2*4*16(a1)
;>		lsl.l	#2,d1
;>		move.l	d1,1*4*16(a1)
;>		lsl.l	#2,d1
;>		move.l	d1,(a1)+
;>		dbra	d0,.c2p_cpy_loop



; Compute atan(x) lut, |x| <= 1

		lea.l	atan-2*257,a0

		move.w	#-257,d0

.atan_loop:	move.w	d0,d2		; atan(x) ~ x/(1+0.28x^2), |x| <= 1
		muls	d2,d2
		lsr.l	#8,d2
		mulu	#(28<<8)/100,d2
		lsr.l	#8,d2
		addi.w	#$0100,d2

		move.w	d0,d1
		ext.l	d1
		asl.l	#8,d1
		divs	d2,d1

		move.w	d1,(a0)+

		addq.w	#1,d0
		cmpi.w	#257,d0
		ble.s	.atan_loop

; Encode polar coordinate table into swirl code

		movea.l swirlCodePtr,a0
		lea.l	atan,a1
		suba.l	a3,a3		; Destination offset

		move.l	#$00070001,d7	; Bitplane interleave

		movea.w #(31415<<8)/20000,a4 ; pi/2 in 8.8 fixedpoint

		move.w	#SWRL_YWIN-1,d0

.y_loop:	move.w	#SWRL_XWIN/4-1,d1

.x_loop:	swap	d1
		move.w	#4-1,d1

		lea	.swirlTmp(pc),a2

.blk_loop:	move.w	(a2)+,(a0)+	; "move.b $xxxx(a0),d0"
		addq.l	#2,a2

; Compute radius
		move.w	d0,d2
		move.l	d1,d3
		swap	d3
		lsl.w	#2,d3
		add.w	d1,d3
		subi.w	#SWRL_YWIN/2,d2 ; dy
		subi.w	#SWRL_XWIN/2,d3 ; dx
		move.w	d2,d5
		move.w	d3,d6

		muls	d5,d5
		muls	d6,d6
		add.l	d5,d6

		beq.s	.zero

; Square root using newton's algorithm

		mulu	#$00049000/(SWRL_XWIN*SWRL_XWIN+SWRL_YWIN*SWRL_XWIN),d6
		move.l	d6,d4
		move.l	d6,d5		; b=a=r

.iterate:	move.l	d4,d6
		divu	d5,d6		; b=r/a
		ext.l	d6
		add.l	d6,d5		; a=(b+a)/2
		asr.l	#1,d5

		cmp.l	d6,d5
		bgt.s	.iterate

.zero:
	ifne 8-SWRL_TEX_V_BITS

		lsr.w	#8-SWRL_TEX_V_BITS,d5 ; Texture v coordinate
	else
		subi.w	#$0080,d5
	endc

; Compute angle

		tst.w	d3
		bne.s	.dx_not_zero	; dx == 0?

		move.w	a4,d6		; atan(dy/dx) = pi/2, dy > 0, dx == 0

		tst.w	d2		; Handle borderline cases
		bpl.s	.cont2

		mulu	#3,d6		; atan(dy/dx) = 3*pi/2, dy < 0, dx == 0
		bra.s	.cont2

.dx_not_zero:	move.w	d2,d4
		ext.l	d4
		asl.l	#8,d4
		divs	d3,d4		; dy/dx, 8.8 fixedpoint

		tst.w	d4		; abs(dy/dx) <= 1 ?
		bpl.s	.pos
		neg.w	d4

.pos:		cmpi.w	#$0100,d4
		bhi.s	.greater

		add.w	d4,d4
		move.w	0(a1,d4.w),d6	; Look up atan (dy/dx), |dy/dx| <= 1
		bra.s	.cont1

.greater:	move.l	#$00010000,d6	; Look up atan(dx/dy), |dy/dx| > 1
		divs	d4,d6
		move.w	d6,d4

		move.w	a4,d6
		add.w	d4,d4
		sub.w	0(a1,d4.w),d6

; Determine quadrant in order to cover the full [0;2pi] range

.cont1: 	tst.w	d2		; dy > 0?
		bmi.s	.quad_34

.quad_12:	tst.w	d3		; dx > 0?
		bpl.s	.cont2		; Quadrant 1, dx > 0, dy > 0
					; angle = atan(|dy/dx|)

		neg.w	d6		; Quadrant 2, dx < 0, dy > 0
		add.w	a4,d6		; angle = pi - atan(|dy/dx|)
		add.w	a4,d6
		bra.s	.cont2

.quad_34:	tst.w	d3		; dx > 0?
		bpl.s	.quad4

.quad3: 	add.w	a4,d6		; Quadrant 3, dx < 0, dy < 0
		add.w	a4,d6
		bra.s	.cont2		; angle = pi + atan(|dy/dy|)

.quad4: 	neg.w	d6		; Quadrant 4, dx > 0, dy < 0

		move.w	a4,d4
		asl.w	#2,d4
		add.w	d4,d6		; angle = 2pi - atan(|dy/dx|)

.cont2: 	ext.l	d6		; Rescale [0;2pi] -> [0;255]
		asl.l	#8,d6
		move.l	a4,d4
		divs	d4,d6
		asr.w	#2,d6		; Texture u coordinate

	ifne 8-SWRL_TEX_U_BITS
		lsr.b	#8-SWRL_TEX_U_BITS,d6
	endc
		sub.b	d5,d6
		lsl.w	#SWRL_TEX_U_BITS,d5

		add.b	d6,d5		; Add angular distortion
	ifne 8-SWRL_TEX_U_BITS
		andi.b	#(1<<SWRL_TEX_V_BITS)-1,d5
	endc
		move.w	d5,(a0)+	; "$xxxx" (Texture offset)
		move.l	(a2)+,(a0)+	; "move/or.l (a1/a2/a3/a4,d0.l),d1"
		dbra	d1,.blk_loop

		move.w	(a2)+,(a0)+	; "movep.l d1,$yyyy(a6)"
		addq.l	#2,a2
		move.w	a3,(a0)+	; "$yyyy" (Destination offset)

		adda.w	d7,a3		; $yyyy += destination increment
		swap	d7		; Bitplane interleave

		swap	d1		; Restore loop counter
		dbra	d1,.x_loop

		move.l	(a2)+,(a0)+
		subi.w	#SWRL_XWIN,-2(a0)

		dbra	d0,.y_loop

		move.w	(a2)+,(a0)+	; "rts"

		rts


; Swirl Code template

.swirlTmp:	move.b	1(a0),d0	; Patch in swirl offsets here
		move.l	0(a1,d0.l),d1
		move.b	1(a0),d0
		or.l	0(a2,d0.l),d1
		move.b	1(a0),d0
		or.l	0(a3,d0.l),d1
		move.b	1(a0),d0
		or.l	0(a4,d0.l),d1
		movep.l d1,1(a6)

		lea.l	BYTESPERSCL(a6),a6 ; Scanline interleave
.swirlTmpEnd:	rts

SWRLBLK_LEN 	=	.swirlTmpEnd-.swirlTmp

;>.c2pTmp:	dc.l	$00000000
;>		dc.l	$03000000
;>		dc.l	$00030000
;>		dc.l	$03030000
;>		dc.l	$00000300
;>		dc.l	$03000300
;>		dc.l	$00030300
;>		dc.l	$03030300
;>		dc.l	$00000003
;>		dc.l	$03000003
;>		dc.l	$00030003
;>		dc.l	$03030003
;>		dc.l	$00000303
;>		dc.l	$03000303
;>		dc.l	$00030303
;>		dc.l	$03030303


*********************************************
*  void restoreSwirl()
*
* Deinitialise swirl effect.
*********************************************

restoreSwirl:	moveq.l	#3-1,d0		; Clear tripple buffer

.cls:		move.w	d0,-(sp)
		movea.l	screen3(pc),a0
		lea.l	OUTLOGO_Y*BYTESPERSCL(a0),a0
		move.l	#(PHYS_Y-2*OUTLOGO_Y)*BYTESPERSCL,d0
		moveq.l	#0,d1
		bsr.w	ClearBlock
		bsr.w	cycleScreens
		
		move.w	(sp)+,d0
		dbra	d0,.cls

		move.l	swirlTexPtr,d0		; Release swirl arrays
		bsr.w	FreeSomeMem
		move.l	swirlCodePtr,d0
		bra.w	FreeSomeMem


*********************************************
*  void plotSwirl(d0.w angle, d1.w radius, a6.l * dstScreen)
*
* Plot swirl effect based on the given angular and
* radial offset.
* a6 points to a 4 bpl destination screen BYTESPERSCL bytes
* per scanline wide.
*********************************************

plotSwirl:	movea.l swirlTexPtr,a0

	ifeq SWRL_TEX_V_BITS-8
		adda.l	#$00008000,a0
	endc
		adda.l	d0,a0

		lea.l	c2p1,a1		; Use the previous set of c2p tables
		lea.l	16*4(a1),a2
		lea.l	16*4(a2),a3
		lea.l	16*4(a3),a4

		moveq.l	#0,d0
		movea.l swirlCodePtr,a5	; Call swirl mapper code
		jmp	(a5)


*********************************************
*  void swirlMain()
*
* Swirl effect animation loop.
*********************************************

swirlMain:	bsr.w	getTime

		cmpi.w	#4,d0		; Don't let keyframe delta drop below 4
		bhs.s	.draw
		moveq.l	#4,d0

.draw:		mulu.w	#130*256/60,d0
		lsr.l	#8,d0
		lsr.w	#11-SWRL_TEX_V_BITS,d0	;#11-SWRL_TEX_V_BITS,d0


		add.b	d0,rad+3
		andi.b	#(1<<SWRL_TEX_U_BITS)-1,rad+3
		add.b	d0,rad+2
		andi.b	#(1<<SWRL_TEX_V_BITS)-1,rad+2
		move.l	rad(pc),d0

		movea.l screen3(pc),a6		; Destination address
		lea.l	(BYTESPERSCL-SWRL_XWIN)/2+80*(SCANLINES-SWRL_YWIN)(a6),a6 ; Center screen window

		bsr.w	plotSwirl
		bra.w	cycleScreens


		data
swirlTexPak:	incbin	'TEXTURE.LZ7'
		even


		bss
swirlCodePtr:	ds.l	1
swirlTexPtr:	ds.l	1
