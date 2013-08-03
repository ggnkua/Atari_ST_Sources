
	bra	init
	bra	play
	bra	exit


;	Input:	d0 Machine type
;			0: STF (not supported)
;			1: STE
;			2: MegaSTE
;			3: TT
;			4: Falcon
;			5: Falcon CT60



exit	suba.l	a0,a0
	jsr	PaulaEmulator+8		; setUserRout NULL
	move.l	pCurrentDriver(pc),d0
	move.l	d0,a0
	jsr	8(a0)			; end music

	lea	$ffff8800.w,a0	
	move.l	#$0707ffff,(a0)
	move.l	#$08080000,(a0)
	move.l	#$09090000,(a0)
	move.l	#$0a0a0000,(a0)
	rts


init	move.l	a0,-(sp)
	bsr	PaulaEmulator+0
	move.l	a0,pCustomChip


	move.l	#moduleDriver,pCurrentDriver

	move.l	(sp)+,a0
;	lea	module,a0
	move.l	pCustomChip(pc),a1
	move.l	pCurrentDriver(pc),a2
	jsr	(a2)				; music init

	move.l	pCurrentDriver(pc),a0
	addq.w	#4,a0				; Driver+4 = tick
	jsr	PaulaEmulator+8			; setUserRout
	rts
	

play
;	move.b	$fffffa01.w,pp

	;bclr	#6,$fffffa15.w
	;bclr	#6,$fffffa09.w
	jsr	PaulaEmulator+12	; Paula Tick
	;bset	#6,$fffffa15.w
	;bset	#6,$fffffa09.w

;	bclr	#5,$fffffa0f.w
;	move.b	pp,$fffffa01.w
	rte				; as timer !

pp	ds.b	1
	even
pCustomChip:		ds.l	1


pCurrentDriver		dc.l	0
bEndMusicTrigger	dc.l	0
	even
oldsp	ds.l	1
	
	even



;----------------------------------------------------------------------------
; MUSIC DRIVER
;----------------------------------------------------------------------------

moduleDriver:
	include	modplay.s
	even
moduleDriverEnd:

PaulaEmulator:
	include	paulaem1.s

;module	incbin	l:\giana\data\06-gia~1.mod	01-giana.dmp


