DOTEXT	equ 0


;	clr 	-(sp)				;2				; who needs this?
	move.w 	#$20,-(sp)			;4
	trap 	#1					;2

; ----------------------- helper stuff to find constants, yes Im a lamer....
;	lea		$0,a0
;.next
;	move.l	(a0)+,d0
;	cmp.l	#-1,d0
;	bne		.next
;	move.b	#0,$ffffc123					; $a38 for tos 1.62

;	lea		$0,a0
;	move.l	contrl,d0
;.n
;	move.l	(a0)+,d1
;	cmp.l	d0,d1
;	bne		.n
;		move.b	#0,$ffffc123				; $99c for tos 1.62

DO_POLYGON	equ 0

	IFEQ	DO_POLYGON
	; a4 is start of bss, lets generate a sine
	move.l	a4,a1
SIZE equ 256
	move.w	#SIZE-1,d0								;4
exp_based_sine
	addq.w	#1,d1									;2
	move.l	d1,d2									;2
	muls	d0,d2									;2
	swap	d2										;2
	divs	#(SIZE/2)*(SIZE),d2						;4
	sub.w	d2,SIZE*2(a1)							;4
;	move.w	d2,SIZE*4(a1)							;4
	move.w	d2,(a1)+								;2
	dbra	d0,exp_based_sine						;4		;30

	; lets set up the screen addresses
	move.w	#$44e,a6
	move.l	#$80000,(a6)
	move.l	#$70000,$40.w


	; init line-a
	dc.w	$a000		; init line-a				
	move.l	a0,a5		; save ptr


	moveq	#-4,d6		; t
.lll		
	and.w	#1023,d6

	IFEQ	DOTEXT
		pea		text(pc)
		move	#9,-(sp)
		trap	#1
;		addq.l #2,sp				; we dont need to correct the stack
	ENDC

	; vsync
	move.w	#$25,-(sp)
	trap 	#14
;	addq.l #2,sp				; we dont need to correct the stack

	; clear the screen
	move.l	(a6),a0				; get screen addr
	move.w	#200*40,d7			; 8000 times
.ddx
		move.l	d4,(a0)+
	dbra	d7,.ddx

	; rotatte stuff
	move.w	(a4,d6.w),d4		; sin(t)
	lea		256(a4),a1			; cos
	move.w	(a1,d6.w),d5		; cos(t)
	; now to rotate points
	lea		ptsin,a1
	move.l	a4,a2
;	lea		target,a2
	moveq	#4-1,d7
.dd

;	xx = [cosA * 1]
;	xy = [sinA * 1]
;	yx = [sinA * 1 + 1 * 0 * 0]
;	yy = [-cosA * 1 + 0 * 0 * 0]

		move.l	(a1)+,d0	;x,y
		move.w	d0,d1		;y
		muls	d5,d1		;		d1 = xy
		move.w	d0,d2		;y
		muls	d4,d2		;		d2 = yy
		
		swap	d0			;y,x

		move.w	d0,d3		;x
		muls	d4,d3		;		d3 = xx
		add.l	d1,d3		;		d1 = xx + xy, upper
	
		muls	d5,d0		;		d0 = yx
		sub.l	d2,d0		;		d2 = yx - yy
		swap	d0
		move.w	d0,d3
	
		add.l	#160<<16+102,d3
		move.l	d3,(a2)+
	dbra	d7,.dd


;	xx = [cosA * cosB]
;	xy = [sinA * cosB]
;	yx = [sinA * cosC + cosA * sinB * sinC]
;	yy = [-cosA * cosC + sinA * sinB * sinC]
;	move.w	(a1)+,d0	;x
;	move.w	(a1)+,d1	;y









	subq.w	#4,d6

	moveq	#0,d0
	move.l	a1,12(a5) ; PTSIN
;	move.l	#contrl,4(a5) ; CONTRL
	move.w	#$99c,6(a5) ; CONTRL
	move.w	d7,24(a5) ; COLBIT0
											;			move.w	#1,26(a5) ; COLBIT1
											;			move.w	#1,28(a5) ; COLBIT2
											;			move.w	#1,30(a5) ; COLBIT3
	move.w	d0,36(a5) ; WRMODE
;	move.l	#stipple,46(a5) ; PATPTR
	move.l	#$a38,46(a5)
											;			move.l	d1,46(a5) ; PATPTR
											;			move.w	#1,50(a5) ; PATLEN
											;			move.w	#0,52(a5) ; MFILL
	move.w	d0,54(a5) ; CLIP
	; loop	to draw the polygon
	move.w	d0,40(a5) ; upper Y line

			

	move.w	#199,d7 ; lowest Y line
.loop:
		dc.w $A006
		addq.w	#1,40(a5)
	dbra d7,.loop

	move.l	(a6),d1
	move.l	d1,$ffff8200.w
	move.l	$40,(a6)
	move.l	d1,$40

	jmp		.lll
	ENDC





a set 80*2
b set 69*2

	IFEQ	DOTEXT
text
	dc.b	'BE PRODUCTIVE!!!',13,0
	even
	ENDC

;contrl:
;	dc.w 0,3


ptsin:
		dc.w	-a,-b+(b)/3
		dc.w	0,b+(b)/3
		dc.w	a,-b+(b)/3
		dc.w	-a,-b+(b)/3
target
