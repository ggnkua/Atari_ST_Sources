; 128 byte drum machine
;
; (c) gwEm 2005
;................................................................


		opt	o+		; optimisations on
		section	text
;................................................................
		clr.l	-(sp)		; supervisor mode
		move.w	#$20,-(sp)	;
		trap	#1		;

		lea	vbl(pc),a0
		move.l	a0,$70.w	; steal vbl
endless:	bra.s	endless		; sit around


;................................................................
vbl:		addq.b	#1,d7		; test speed counter
		andi.b	#%111,d7	; wrap speed
		bne.s	.fiftyhz	; not time for new pattern position yet

		addq.b	#1,d6		; increment pattern position counter
		andi.b	#%111,d6	; wrap pattern

;.................
.fiftyhz	lea	pattern(pc),a5	; a5 points to pattern
		lea	YMbuffer(pc),a6	; a6 points to mixer
		move.b	#$FE,2*2+1(a6)	; reset mixer 
					; - channel A active for key click jamming :)

		move.b	(a5,d6.w),d0	; get drums needed in this postion

		btst	#2,d0		; kick drum?
		beq.s	.nokick
		bclr	#1,2*2+1(a6)	; mixer enable squarewave B
		move.b	d7,2*0+1(a6)	; set most signigicant frequency
		addq.b	#2,2*0+1(a6)	; tweak freqency

.nokick		btst	#0,d0		; hi hat?
		beq.s	.nohat
		tst.b	d7		; test if first step in drum sound
		beq.s	.yeshat

.nohat		btst	#1,d0		; snare drum?
		beq.s	.nosnare
.yeshat		move.b	d7,2*1+1(a6)	; noise freq
		bclr	#4,2*2+1(a6)	; mixer enable noise B
.nosnare


;.................
.setupYM	lea	$ffff8800.w,a0	; YM base address
.setuploop	move.w	(a6)+,d0	; get new YM register value
		beq.s	.end		; finished?
		movep.w	d0,(a0)		; put new register onto YM
		bra.s	.setuploop	; next register

.end		rte


;................................................................
pattern:	dc.b	%101		; bit2 = kick 
		dc.b	%001		; bit1 = snare
		dc.b	%011		; bit0 = hat
		dc.b	%001
		dc.b	%001
		dc.b	%101
		dc.b	%011
		dc.b	%001

YMbuffer:	dc.w	$0300		; channel B squarewave frequency
		dc.w	$0600		; noise frequency
		dc.w	$0700		; mixer
		dc.w	$090F		; channel B volume


		section bss
;................................................................
		ds.w	1		; free null terminate for YMbuffer ;)


