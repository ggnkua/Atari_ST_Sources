;5x5=21 pixels (kind of a ball shape) blurrer
;Four of these are triggered at once on the last part of the demo
;to generate the effect of the logo blurring/fading
;This routine incbins a chunky representation of the "i've quit." logo,
;which is used for the blur.  Uses the standard algorithm.

; all code by tom :) :) :)


*	PASS:
*	a4 = pointer to x
*	a5 = pointer to y
*	a6 = pointer to 21 element array for output dots!

;	lea	test,a5

* first, have a0 point to the top left of the 5x5 block in chunky buffer
	lea	zero,a0
	adda.w	2(a4),a0		; add x-coord
	moveq	#0,d0			; fetch y
	move.b	3(a5),d0
	lsl.w	#8,d0			; x256
	adda.w	d0,a0
	move.l	a0,a2			; pop it in a2 for safe keeping

* set up reg for quick subs/adds

;	move.l	#chunky,d1	;debug
	move.l	#257,d4
	move.l	#252,d5
	move.l	#251,d6
	move.l	#253,d7

* now, work through each pixel of the 5x5 block, doing the blur

; row one = 3 pixels

	lea	1(a0),a0		; miss first pixel
	REPT 3
	move.l	a0,a1
	suba.l	d4,a1			;a1 now left diagonal to a0
	moveq	#0,d0
	move.b	512(a1),d0		; first column - 3 pixels
	add.b	256(a1),d0
	add.b	(a1)+,d0
	add.b	512(a1),d0		; second column - 3 pixels
	add.b	256(a1),d0
	add.b	(a1)+,d0
	add.b	256(a1),d0		; third column - 2 pixels
	add.b	(a1),d0
	lsr.b	#3,d0			; average - /8
	move.b	d0,(a0)+
	ENDR				; do it three times

	adda.l	d5,a0			; move to second row

; row two = five pixels

	REPT 5
	move.l	a0,a1
	suba.l	d4,a1			;a1 now left diagonal to a0
	moveq	#0,d0
	move.b	512(a1),d0		; first column - 3 pixels
	add.b	256(a1),d0
	add.b	(a1)+,d0
	add.b	512(a1),d0		; second column - 3 pixels
	add.b	256(a1),d0
	add.b	(a1)+,d0
	add.b	256(a1),d0		; third column - 2 pixels
	add.b	(a1),d0
	lsr.b	#3,d0			; average - /8
	move.b	d0,(a0)+
	ENDR				; do it five times

	adda.l	d6,a0			; move to third row

; row three  = five pixels

	REPT 5
	move.l	a0,a1
	suba.l	d4,a1			;a1 now left diagonal to a0
	moveq	#0,d0
	move.b	512(a1),d0		; first column - 3 pixels
	add.b	256(a1),d0
	add.b	(a1)+,d0
	add.b	512(a1),d0		; second column - 3 pixels
	add.b	256(a1),d0
	add.b	(a1)+,d0
	add.b	256(a1),d0		; third column - 2 pixels
	add.b	(a1),d0
	lsr.b	#3,d0			; average - /8
	move.b	d0,(a0)+
	ENDR

	adda.l	d6,a0			; move to fourth row

; row four = five pixels

	REPT 5
	move.l	a0,a1
	suba.l	d4,a1			;a1 now left diagonal to a0
	moveq	#0,d0
	move.b	512(a1),d0		; first column - 3 pixels
	add.b	256(a1),d0
	add.b	(a1)+,d0
	add.b	512(a1),d0		; second column - 3 pixels
	add.b	256(a1),d0
	add.b	(a1)+,d0
	add.b	256(a1),d0		; third column - 2 pixels
	add.b	(a1),d0
	lsr.b	#3,d0			; average - /8
	move.b	d0,(a0)+
	ENDR

	adda.l	d5,a0			; move to fifth row

; row 5 = three pixels

	REPT 3
	move.l	a0,a1
	suba.l	d4,a1			;a1 now left diagonal to a0
	moveq	#0,d0
	move.b	512(a1),d0		; first column - 3 pixels
	add.b	256(a1),d0
	add.b	(a1)+,d0
	add.b	512(a1),d0		; second column - 3 pixels
	add.b	256(a1),d0
	add.b	(a1)+,d0
	add.b	256(a1),d0		; third column - 2 pixels
	add.b	(a1),d0
	lsr.b	#3,d0			; average - /8
	move.b	d0,(a0)+
	ENDR

			

* Now fill output array
	lea	1(a2),a0		; get our pointer back to start of block
	lea	3(a6),a1		; pointer to BYTE of array element
	move.b	(a0)+,(a1)		; first row
	move.b	(a0)+,4(a1)
	move.b	(a0),8(a1)
	adda.l	d7,a0			; move to rows 2-4
ADDIT	SET	12
	REPT	3
	move.b	(a0)+,ADDIT(a1)		
	move.b	(a0)+,ADDIT+4(a1)
	move.b	(a0)+,ADDIT+8(a1)
	move.b	(a0)+,ADDIT+12(a1)
	move.b	(a0),ADDIT+16(a1)
	adda.l	d5,a0
ADDIT	SET	ADDIT+20
	ENDR
	lea	1(a0),a0		
	move.b	(a0)+,ADDIT(a1)		; third row
	move.b	(a0)+,ADDIT+4(a1)
	move.b	(a0),ADDIT+8(a1)

	rts
	
			
	


zero:	ds.b	256*3
chunky:	incbin	perfect.dat
	ds.b	256*3
