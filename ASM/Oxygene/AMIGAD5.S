;
; Paula Emulator Play by Leonard / OXYGENE

; Simple Player by Grazey / PHF 2010
; Uses Timer C rather than VBL now

	
	opt	x+

grz
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp
	
	lea	stack(pc),a7

	move.l	$114.w,old114



	move.l	$84.w,old84

;	Input:	d0 Machine type
;			0: STF (not supported)
;			1: STE
;			2: MegaSTE
;			3: TT
;			4: Falcon
;			5: Falcon CT60

	move.w	#1,d0
	jsr	PaulaEmulator+0
	move.l	a0,pCustomChip
	bsr	init
	
	move.w	#$2700,sr
	move.l	#timer_c,$114.w		; steal timer C
	move.w	#$2300,sr

loop	cmp.b	#$39,$fffffc02.w
	beq.s	quit

	bra.s	loop

quit	move.w	#$2700,sr
	move.l	old114,$114.w
	move.w	#$2300,sr

	suba.l	a0,a0
	jsr	PaulaEmulator+8		; setUserRout NULL
	move.l	pCurrentDriver(pc),d0
	move.l	d0,a0
	jsr	8(a0)			; end music


	lea	$ffff8800.w,a0	
	move.l	#$0707ffff,(a0)
	move.l	#$08080000,(a0)
	move.l	#$09090000,(a0)
	move.l	#$0a0a0000,(a0)

	move.l	old84,$84.w

	move.l	oldsp,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1


init	move.l	#moduleDriver,pCurrentDriver

	lea	module,a0
	move.l	pCustomChip(pc),a1
	move.l	pCurrentDriver(pc),a2
	jsr	(a2)				; music init

	move.l	pCurrentDriver(pc),a0
	addq.w	#4,a0				; Driver+4 = tick
	jsr	PaulaEmulator+8			; setUserRout
	rts
	

R_FREQ	equ	200			; SNDH replay frequency here (200Hz in this example)


;................................................................
timer_c:sub.w	#R_FREQ,tccount		; you can use any replay rate here less than or equal to 200Hz
	bgt.s	.nocall			; dont call zak this time
	add.w	#200,tccount		; syntheses any freq from 200hz system tick
	move.w	sr,-(sp)		; store status word - system friendly, but not needed in a demo i guess
	move.w	#$2500,sr		; enable timer interrupts
	jsr	PaulaEmulator+12	; Paula Tick
	move.w	(sp)+,sr		; restore status word

.nocall	move.l  old114(pc),-(sp)		; go to old vector (system friendly ;) )
        rts

tccount:ds.w	200

	
	ds.l	128
stack:	even

old114			dc.l	0

old84			dc.l	0
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

module	incbin	l:\giana\data\intro.mod	01-giana.dmp


