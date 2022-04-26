	jsr	InstallSample

	cmp.w #$20,d0
	beq KeepSound

KeepSound:



	clr.w	-(sp)		*Gemdos 0(Term)-Avslutar programmet
	trap	#1
*************************
*	Subrutnier	*
*************************
InstallSample: 
	lea	Sample,a0

	move.l	a0,d0
	move.b	d0,$ff8907		*Frame Base Low
	lsr.l	#8,d0
	move.b	d0,$ff8905		*Frame Base Mid
	lsr.w	#8,d0
	move.b	d0,$ff8903		*Frame Base Hi

	move.l	a0,d0
	move.b	d0,$ff890d		*Frame Cnt Low
	lsr.l	#8,d0
	move.b	d0,$ff890b		*Frame Cnt Mid
	lsr.w	#8,d0
	move.b	d0,$ff8909		*Frame Cnt Hi

	lea	EndSample,a0
	move.l	a0,d0
	move.b	d0,$ff8913		*Frame End Low
	lsr.l	#8,d0
	move.b	d0,$ff8911		*Frame End Mid
	lsr.w	#8,d0
	move.b	d0,$ff890f		*Frame End Hi

	move.b #%00000000,$ff8920	*Sound Mode Control
	move.b #%10000000,$ff8921

	move.b #%00000000,$ff8900	*Sound DMA Control
	move.b #%00000011,$ff8901
	rts
*************************************************
*	 (*)=Reset State(Default)		*
*************************************************
*	    Sound Mode Control			*
*************************************************
*   FF8920 0000 0000 m000 00rr			*
*	rr: (*) 00  6258 Hz Sample Rate		*
*		01 12517 Hz Sample Rate		*
*		10 25033 Hz Sample Rate		*
*		11 50066 Hz Sample Rate		*
*						*
*	m:  (*) 0 Stereo Mode			*
*		1 Mono Mode			*
*************************************************
*	     Sound DMA Control			*
*************************************************
*   FF8900 ---- ---- ---- --cc			*
*	cc: (*) 00 Quiet			*
*		01 Play Once			*
*		11 Play Loop			*
*************************************************
 even

SaveSuper: ds.l 1
Sample: incbin A:\peter2.SPL
EndSample: dc.w 0
Strang: 
 dc.b 27,72	*Clr Home
 dc.b 27,102	*Hide Crusor

 end