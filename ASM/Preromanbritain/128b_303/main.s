; 128 byte 303 emulator
;
; (c) gwEm 2005
;................................................................


		opt	o+			; optimisations on
		section	text
;................................................................
main:		move.w	#$20,-(sp)		; supervisor mode
		trap	#1			;

		lea	$ffff8800.w,a5		; YM base address
		move.l	#$0D000800,(a5)		; buzzer saw tooth waveform

		moveq	#$18,d3			; constant
		moveq	#$09,d5			; d5 = cutoff

		clr.b	$484.w			; key click off

		lea	vbl(pc),a0
		move.l	a0,$70.w		; steal vbl

.endless	bra.s	.endless		; sit around


;................................................................
vbl:		addq.b	#1,d7			; test speed counter
		and.w	#%111,d7		; wrap speed
		bne.s	.fiftyhz		; not time for new pattern position yet

		addq.b	#1,d6			; increment pattern position counter
		and.w	#%11,d6			; wrap pattern

		move.b	$fffffc02.w,d4		; get scan code
		cmpi.b	#$19,d4			; 'P' - increase cutoff
		beq.s	.up
		cmp.b	d3,d4			; 'O' - decrease cutoff
		bne.s	.fiftyhz

.down		cmpi.b	#$09,d5			; test lower limit
		bls.s	.fiftyhz
		subq.b	#2,d5			; decrease cutoff

.up		cmp.b	d3,d5			; test upper limit
		bhs.s	.fiftyhz
		addq.b	#1,d5			; increase cutoff

;.................
.fiftyhz	lea	YMbuffer(pc),a6		; a6 points to mixer

		moveq	#0,d0			; safety
		move.b	pattern(pc,d6.w),d0	; get note for this postion
		move.b	d0,3*2+1(a6)		; set buzzer frequency

		move.l	d5,d1			; compute square wave frequency for acid effect
		sub.w	d7,d1			; d7 holds speed counter - square wave freq drops with time
		lsl.w	#3,d0			; shift buzzer frequency to get square wave freq
		divu	d1,d0
		movep.w	d0,4*2+1(a6)		; set square wave B frequency

;.................
.setuploop	move.w	(a6)+,d0		; get new YM register value
		beq.s	.end
		movep.w	d0,(a5)			; put new register onto YM
		bra.s	.setuploop		; next register

.end		rte


;................................................................
pattern:	dc.b	$77			; buzzer frequencies
		dc.b	$3C			;
		dc.b	$77			;
		dc.b	$1E			;

YMbuffer:	dc.w	$07FE			; mixer
		dc.w	$0810			; channel A volume (activate buzzer)
		dc.w	$0C00			; buzzer freq
		dc.w	$0B00
		dc.w	$0100			; channel A squarewave freq LSB

		section	bss
		ds.w	1			; channel A squarewave freq MSB
		ds.w	1			; null terminate
