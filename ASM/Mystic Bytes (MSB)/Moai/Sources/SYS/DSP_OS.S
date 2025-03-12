; DSP routines for HOST<->DSP communication

wait_receive	MACRO
.@\wait:	btst	#0,$ffffa202.w			; Interrrupt Status Register
		beq.b	.@\wait
		ENDM
		
wait_send	MACRO
.@\wait:	btst	#1,$ffffa202.w			; Interrrupt Status Register
		beq.b	.@\wait
		ENDM

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

install_dsp_prg:

; input: a0 - start of dsp prg
;        a1 - end of dsp prg

.loop:		bsr.w	get_dsp_word
		cmpi.w	#0,d0
		bne.b	.no_p
		move.l	#'RPM',d0			; send cmd "receive p memory block"
		bra.b	.send
		
.no_p:		cmpi.w	#1,d0
		bne.b	.no_x
		move.l	#'RXM',d0			; send cmd "receive x memory block"
		bra.b	.send
		
.no_x:		cmpi.w	#2,d0
		bne.b	.no_y
		move.l	#'RYM',d0			; send cmd "receive y memory block"
		bra.b	.send
		
.no_y:		move.l	#bad_p56_text,error_adr
		bra.w	exit
		
.send:		bsr.w	dsp_send_long

		bsr.w	get_dsp_word			; start address
		bsr.w	dsp_send_unsigned_word			;
		
		bsr.w	get_dsp_word			; number of dsp words
		bsr.w	dsp_send_unsigned_word		;
		
		bsr.w	dsp_send_block			; dsp code/data

		cmpa.l	a0,a1
		bne.b	.loop
		rts
		
check_dsp_alive:		
		moveq	#-1,d1
.again:		btst	#0,$ffffa202.w			; Interrrupt Status Register
		dbne	d1,.again
		
		move.l	$ffffa204.w,d0			; i/o data path
		cmpi.l	#'OK!',d0
		bne.b	.dead
		rts
.dead:		move.l	#dead_dsp_text,error_adr
		bra.w	exit		
		
call_dsp_subroutine:
; input: d0.w - number of subroutine
		move.l	d0,-(sp)
		move.l	#'CSR',d0
		bsr.w	dsp_send_long
		move.l	(sp)+,d0
		bsr.w	dsp_send_unsigned_word
		rts

dsp_receive_byte:
; output: d0.b - received byte
		wait_receive
		move.b	$ffffa207.w,d0			; i/o data path lo
		rts

dsp_send_signed_byte:
; input: d0.b - byte to send
		move.l	d0,-(sp)

		wait_send
		extb	d0				; ext to long
		move.l	d0,$ffffa204.w			; i/o data path 00:hi:mi:lo

		move.l	(sp)+,d0
		rts
		
dsp_send_unsigned_byte:
; input: d0.b - byte to send
		move.l	d0,-(sp)

		wait_send
		andi.l	#$000000ff,d0
		move.l	d0,$ffffa204.w			; i/o data path 00:hi:mi:lo

		move.l	(sp)+,d0
		rts

dsp_receive_word:
; output: d0.w - received word
		wait_receive
		move.w	$ffffa206.w,d0			; i/o data path mi:lo
		rts

dsp_send_signed_word:
; input: d0.w - word to send
		move.l	d0,-(sp)

		wait_send
		ext.l	d0				; ext to long
		move.l	d0,$ffffa204.w			; i/o data path 00:hi:mi:lo

		move.l	(sp)+,d0
		rts
		
dsp_send_unsigned_word:
; input: d0.w - word to send
		move.l	d0,-(sp)

		wait_send
		andi.l	#$0000ffff,d0
		move.l	d0,$ffffa204.w			; i/o data path 00:hi:mi:lo

		move.l	(sp)+,d0
		rts

dsp_receive_signed_long:
; output: d0.l - received long (24 bit)
		wait_receive
		move.l	$ffffa204.w,d0			; i/o data path 00:hi:mi:lo
		lsl.l	#8,d0				; get sign
		asr.l	#8,d0
		rts

dsp_receive_unsigned_long:
; output: d0.l - received long (24 bit)
		wait_receive
		move.l	$ffffa204.w,d0			; i/o data path 00:hi:mi:lo
		rts

dsp_send_long:
; input: d0.l - long to send (24 bit)
		wait_send
		move.l	d0,$ffffa204.w			; i/o data path 00:hi:mi:lo
		rts
		
dsp_receive_block:
; input: a0   - pointer to data buffer
;        d0.w - number of dsp words to receive
		subq.w	#1,d0

.loop:		wait_receive
		move.b	$ffffa205.w,(a0)+		; i/o data path hi
		move.w	$ffffa206.w,(a0)+		; i/o data path mi:lo

		dbra	d0,.loop
		rts

dsp_send_block:
; input: a0   - pointer to data buffer
;        d0.w - number of dsp words to send
		subq.w	#1,d0

.loop:		wait_send
		move.b	(a0)+,$ffffa205.w		; i/o data path hi
		move.w	(a0)+,$ffffa206.w		; i/o data path mi:lo

		dbra	d0,.loop
		rts
		
dsp_receive_block8:
; input: a0   - pointer to data buffer
;        d0.w - number of bytes to receive
		subq.w	#1,d0
		
.loop:		wait_receive
		move.b	$ffffa207.w,(a0)+		; i/o data path mi:lo

		dbra	d0,.loop
		rts
		
dsp_send_signed_block8:
; input: a0   - pointer to data to buffer
;        d0.w - number of bytes to send
		move.l	d1,-(sp)
		subq.w	#1,d0
		
.loop:		wait_send
		move.b	(a0)+,d1
		extb	d1				; ext to long
		move.l	d1,$ffffa204.w			; i/o data path 00:hi:mi:lo

		dbra	d0,.loop
		move.l	(sp)+,d1
		rts
		
dsp_send_unsigned_block8:
; input: a0   - pointer to data to buffer
;        d0.w - number of bytes to send
		move.l	d1,-(sp)
		subq.w	#1,d0
		clr.l	d1				; clear hi word
		
.loop:		wait_send
		move.b	(a0)+,d1
		move.l	d1,$ffffa204.w			; i/o data path 00:hi:mi:lo

		dbra	d0,.loop
		move.l	(sp)+,d1
		rts
		
dsp_receive_block16:
; input: a0   - pointer to data buffer
;        d0.w - number of words to receive
		subq.w	#1,d0
		
.loop:		wait_receive
		move.w	$ffffa206.w,(a0)+		; i/o data path mi:lo

		dbra	d0,.loop
		rts
		
dsp_send_signed_block16:
; input: a0   - pointer to data to buffer
;        d0.w - number of words to send
		move.l	d1,-(sp)
		subq.w	#1,d0
		
.loop:		wait_send
		move.w	(a0)+,d1
		ext.l	d1				; ext to long
		move.l	d1,$ffffa204.w			; i/o data path 00:hi:mi:lo

		dbra	d0,.loop
		move.l	(sp)+,d1
		rts
		
dsp_send_unsigned_block16:
; input: a0   - pointer to data to buffer
;        d0.w - number of words to send
		move.l	d1,-(sp)
		subq.w	#1,d0
		clr.l	d1				; clear hi word
		
.loop:		wait_send
		move.w	(a0)+,d1
		move.l	d1,$ffffa204.w			; i/o data path 00:hi:mi:lo

		dbra	d0,.loop
		move.l	(sp)+,d1
		rts

dsp_receive_signed_block32:
; input:  a0   - pointer to data buffer
;         d0.w - number of longs to receive
		move.l	d1,-(sp)
		subq.w	#1,d0
		
.loop:		wait_receive
		move.l	$ffffa204.w,d1			; i/o data path 00:hi:mi:lo
		lsl.l	#8,d1
		asr.l	#8,d1
		move.l	d1,(a0)+

		dbra	d0,.loop
		move.l	(sp)+,d1
		rts
		
dsp_receive_unsigned_block32:
; input:  a0   - pointer to data buffer
;         d0.w - number of longs to receive
		subq.w	#1,d0
		
.loop:		wait_receive
		move.l	$ffffa204.w,(a0)+		; i/o data path 00:hi:mi:lo
		
		dbra	d0,.loop
		rts
		
dsp_send_block32:
; input: a0   - pointer to data buffer ($00xxxxxx)
;        d0.w - number of longs to send
		subq.w	#1,d0
		
.loop:		wait_send
		move.l	(a0)+,$ffffa204.w		; i/o data path 00:hi:mi:lo

		dbra	d0,.loop
		rts
		
get_dsp_word:
; input:  a0   - pointer to p56 data
; output: a0   - updated
;         d0.l - dsp word ($00xxxxxx)

		move.l	(a0),d0
		addq.l	#3,a0
		lsr.l	#8,d0
		rts