; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;          - DSP Host Port I/O -
;        a NoCrew production MCMXCV
;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Main module.

	include	falcmacr.s

	section	text

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1		* Super
	addq.w	#6,sp
	move.l	d0,old_sp

	bsr	start

	move.l	old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1		* Super
	addq.w	#6,sp

	clr.w	-(sp)
	trap	#1		* Pterm0

start	* Upload DSP program
	Dsp_ExecProg	#DSP_start,#(DSP_end-DSP_start)/3,#'NC'

	* Display a, b and c
	move.l	a,d0
	lea	texta,a0
	bsr.s	display_number
	move.l	b,d0
	lea	textb,a0
	bsr.s	display_number
	move.l	c,d0
	lea	textc,a0
	bsr.s	display_number

	* Send data to DSP (24 bit)
	move.l	a,d0	* a
	bsr.s	DSP_host_send
	move.l	b,d0	* b
	bsr.s	DSP_host_send
	move.l	c,d0	* c
	bsr.s	DSP_host_send
	* Get data from DSP (24 bit)
	bsr.s	DSP_host_get	* a+b+c
	lea	text1,a0
	bsr.s	display_number
	bsr.s	DSP_host_get	* a+0.3*c (truncated)
	lea	text2,a0
	bsr.s	display_number
	bsr.s	DSP_host_get	* a-0.8*b (rounded)
	lea	text3,a0
	bsr.s	display_number

	move.w	#8,-(sp)
	trap	#1	* Wait for a key
	addq.w	#2,sp
	rts

DSP_host_get	btst.b	#0,$ffffa202.w
	beq.s	DSP_host_get
	move.l	$ffffa204.w,d0	* Read host data
	rts
DSP_host_send	btst.b	#1,$ffffa202.w
	beq.s	DSP_host_send
	move.l	d0,$ffffa204.w	* Write host data
	rts

* Positive numbers only!
display_number
	lea	buffer+32,a1
	clr.b	-(a1)
.next	clr.l	d1
	divu.l	#10,d1:d0
	add.b	#'0',d1
	move.b	d1,-(a1)
	tst.w	d0
	bne.s	.next
	move.l	a1,-(sp)
	move.w	#9,-(sp)
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	trap	#1
	addq.w	#6,sp
	rts

	section	data
DSP_start
	incbin	host_io.dsp	* DSP binary file
DSP_end

a	dc.l	25
b	dc.l	23
c	dc.l	93

texta	dc.b	$0d,$0a,'a = ',0
textb	dc.b	$0d,$0a,'b = ',0
textc	dc.b	$0d,$0a,'c = ',0
text1	dc.b	$0d,$0a,'a+b+c = ',0
text2	dc.b	$0d,$0a,'a+0.3*c (truncated) = ',0
text3	dc.b	$0d,$0a,'a-0.8*b (rounded) = ',0

	section	bss
old_sp	ds.l	1
buffer	ds.b	32
	end
