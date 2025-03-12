; 128 byte choon
;
; (c) gwEm/PHF 2011
;................................................................

		opt	CHKPC			; ensure PC relative code (usually smaller)
		opt	o+			; optimisations on

		section	text
;................................................................
		move.w	#$20,-(sp)		; supervisor mode
		trap	#1			;

		lea	$ffff8800.w,a6		; YM base address
		move.l	$4F2.w,a1		; random number generator
		
		moveq	#%111,d5		; wrap mask (0->7 only)
		moveq	#5,d6			; d6 is constant 5

		moveq	#%10000100,d1		; kick pattern
		moveq	#%00100010,d2		; snare pattern

		lea	sid(pc),a2		; timer C vector
		move.l	a2,$114.w		;

		move.b	d2,$fffffa1d.w		; timer C divider (and timer D too, oh well ;) 
		
		lea	vbl(pc),a2		; steal VBL
		move.l	a2,$70.w		;

endless:	bra.s	endless			; sit around


;................................................................
vbl:		lea	YMbuffer+1(pc),a0	; a6 points to mixer

		and.w	d5,d4			; wrap speed and test
		bne.s	.fiftyhz		; not time for new pattern position yet

		move.b	(a1)+,d3		; get new note
		and.w	d5,d3			;
		move.b	notes(pc,d3.w),(a0)	; YM buffer
		move.b	(a0),$fffffa23.w	; timer C data register

		move.w	#%0000011111111111,d7	; reset d4 mixer

		rol.b	#1,d1
		bcc.s	.nokick
		eor.w	d5,d7			; enable all squarewaves
.nokick
		rol.b	#1,d2
		bcc.s	.nosnare
		bclr	#4,d7			; enable noise B
.nosnare

;.................
.fiftyhz	addq.b	#1,d4			; increment speed counter
		move.b	d4,2(a0)		; set kick drum frequency
		subq.l	#1,a0

.setuploop	move.w	(a0)+,d0		; get new YM register value
		movep.w	d0,(a6)			; put new register onto YM
		bne.s	.setuploop

		rte


;................................................................
sid:		eor.b	d6,d7
		movep.w	d7,(a6)
		bclr	d6,$fffffa11.w
		rte


;................................................................
notes:		dc.b	253
		;dc.b	239
		dc.b	225
		dc.b	213
		;dc.b	201
		dc.b	190
		;dc.b	179
		dc.b	169
		dc.b	159
		;dc.b	150
		dc.b	142
		;dc.b	134
		dc.b	127

YMbuffer:	dc.w	$0400		; channel C freq
		dc.w	$0300		; channel B freq

		dc.w	$0A0E		; channel C volume
		dc.w	$090F		; channel B volume

		;dc.w	$0000


		section bss
;................................................................
		ds.w	1		; free null terminate for YMbuffer ;)
