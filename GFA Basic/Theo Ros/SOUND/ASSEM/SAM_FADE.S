; sam_fade is a routine to fade a sample in or out (linear)
; aanroep:  ~C:sam_fade%(L:startadr%,L:endadr%)
; 	    startadr%<endadr% --> fade IN
; 	    startadr%>endadr% --> fade OUT

; Theo Ros, 01/10/1997		SAM_FADE.PRG=114 bytes


		movem.l	4(sp),a0/a1	; startadr%, endadr%
		moveq	#1,d4		; counter; ga uit van fade IN
		move.l	a1,d1
		sub.l	a0,d1		; period%=endadr%-startadr%
		bpl.s	calc_step		; >0, so fade IN
		moveq	#-1,d4		; counter now -1 for fade OUT
		neg.l	d1
calc_step:	move.l	d1,d7		; copy period%
		move.l	d1,d6
		lsr.l	#7,d6		; period% DIV 128
		beq.s	exit		; period% too small
		moveq	#0,d0		; maxvolume	
		moveq	#0,d2		; testbyte
		moveq	#0,d5		; periodcounter

fade:		move.b	(a0),d2
		cmpi.w	#127,d2
		bhi.s	hibyte
		cmp.w	d0,d2		; byte<maxvolume?
		bls.s	nextadr		; do nothing
		move.w	d0,d2		; d2=MIN(d2,maxvolume)
		bra.s	putbyte
		
hibyte:		move.w	#255,d3
		sub.w	d0,d3		; 255-maxvolume
		cmp.w	d3,d2		; byte>maxvolume?
		bge.s	nextadr
		move.w	d3,d2		; d2=MAX(d2,255-maxvolume)
		
putbyte:		move.b	d2,(a0)

nextadr:		add.l	d4,a0		; startadr% +1 of -1
		
		add.l	d6,d5		; add period/128
while:		cmp.l	d5,d7		; compare length
		bhi.s	loop
		addq	#1,d0		; volume+1
		sub.l	d7,d5
		bra.s	while
loop:		subq.l	#1,d1		; end of period reached?
		bne.s	fade

exit:		rts