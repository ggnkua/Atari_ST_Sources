;
; GODconv
; 
; April 16, 2004
; Anders Eriksson
; ae@dhs.nu
; 
; subs.s


		section	text

;		input:	d0 == address of text to print
cconws:		move.l	d0,-(sp)				;print text
		move.w	#9,-(sp)				;
		trap	#1					;
		addq.l	#6,sp					;
		rts						;


;		input: 	d0.l == amount of memory to reserve
;		output:	d0.l == address of memory block
mxalloc_fast:	move.w	#3,-(sp)				;mxalloc() - prefer fastram
		move.l	d0,-(sp)				;amount of memory to reserve
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;check if there is enough ram
		bne.s	.ok					;yes

		move.l	#noram_text,exit_text_adr		;no
		bra.w	pterm					;

.ok:		rts



;		wait for keypress
crawcin:	move.w	#7,-(sp)				;crawcin()
		trap	#1					;
		addq.l	#2,sp					;
		rts


		section	text



