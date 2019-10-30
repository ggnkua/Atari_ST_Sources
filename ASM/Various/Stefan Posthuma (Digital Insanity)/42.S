; 42.S
;
; The most revolutionairy program ever written in the history
; of mankind. This will give the Answer to Everthing!
;
; Original idea by Richard Karsmakers.
; Concepionalisation and further realisation by Richard Karsmakers
; and Stefan Posthuma.
; Programming by Stefan Posthuma.
;
; This program has one little drawback, it will run so long that
; the Universe will have been replaced by something much more inexplicable
; at least a thousand times. I mean billions to the power of billions
; of years.
; So filosophers and scientists world-wide won't have to worry that they
; will be unemployed by this wonderful little program in the near future.

		opt	x+

start		move.l	#$f8000,-(sp)
		bsr	add
		clr.w	-(sp)
		trap	#1

add		move.l	4(sp),a6	; get screen address
		move.l	a6,a5		; store in a5
		move.w	#$7999,d7	; 8000 longwords to fill
.1		move.w	#17,-(sp)	; 17: random
		trap	#14		; call Xbios
		addq.l	#2,sp		; correct stack
		move.l	#$ffffffff,d0	
		move.w	d0,(a5)+	; store random value in screen
		dbra	d7,.1		; next please
		pea	do_add		; push address of add routine
		move.w	#38,-(sp)	; 38: superexec
		trap	#14		; call Xbios
		addq.l	#6,sp		; correct stack
		rts

; this is the actual and magic routine
; it has to be executed in supervisor mode
do_add		move.w	#$2700,sr	; no more interrupts
		move.l	a6,a4		; store screen address in a4
		lea	$fffffc02.w,a3	; address of keyboard data
		lea	32000-4(a6),a6	; set pointer to end of screen
.0		add.l	#1,(a6)		; increase value on screen
		bcc.s	.2		; no overflow
		move.l	a6,a5		; store screen address in a5
.1		cmp.l	a4,a5		; start of screen reached?
		beq.s	.0		; yes, abort
		subq.l	#4,a5		; substract 4
		add.l	#1,(a5)		; add 1 to this one
		bcs.s	.1		; in case of overflow...
.2		cmp.b	#$39,(a3)	; space pressed?
		bne.s	.0		; no, do again!
		rts  			