; 128 byte theremin
;
; (c) gwEm 2005
;................................................................


		section	text
;................................................................
		move.w	#$20,-(sp)	; supervisor mode
		trap	#1

		move.w	#$2500,sr	; kill vbl interrupt
		moveq	#1,d5		; constant 1
		moveq	#$19,d3		; constant $19

		pea	ikbdstr(pc)	; mouse button scancodes
		move.w	d5,-(sp)	;
		move.w	d3,-(sp)	;
		trap	#14		;

		moveq	#$7F,d7		; start channel A freq

		lea	ikbd(pc),a0
		move.l	a0,$118.w	; steal keyboard interrupt

		lea	$ffff8800.w,a0	; YM base address
setupYM:	lea	YMbuffer(pc),a1
		movep.w d7,5(a1)	; set channel A frequency in buffer
.setuploop	move.w	(a1)+,d0	; get new YM register value
		beq.s	setupYM		; reached end - do it again
		movep.w	d0,(a0)		; put new register onto YM
		bra.s	.setuploop	; next register


;................................................................
ikbd:		lea	YMbuffer+3(pc),a6
		move.b	$fffffc02.w,d6	; get ikbd
		ext.w	d6

		cmp.w	d4,d5		; d4 counts mouse packets
		beq.s	.ikbd_x
		blo.s	.ikbd_y

.ikbd_0		andi.b	#$FC,d6		; mask least significant 2 bits
		cmpi.b	#$F8,d6		; mouse movement?
		beq.s	.endx		; yes, next packet is x
		spl.b	(a6)		; set if key pressed, clear if lifted
		andi.b	#$0F,(a6)
		bra.s	.end

;..................
.ikbd_x		sub.w	d6,d7		; include x motion in channel A frequency
		cmp.w	d3,d7		; high frequency clip (d3 = constant $19)
		bge.s	.lowclip		
		move.w	d3,d7
.lowclip	cmpi.w	#$FFF,d7	; low frequency clip
		ble.s	.endx
		move.w	#$FFF,d7

.endx		addq.w	#1,d4		; next mouse packet
		bra.s	.end

;..................
.ikbd_y		moveq	#0,d4		; y packet recieved, start again

;..................
.end		clr.b	$fffffa11.w	; clear ACIA interrupt
		rte


;................................................................
		section	data
ikbdstr:	dc.b	$07,$04

YMbuffer:	dc.w	$07FE
		dc.w	$0800		; channel A volume, assume already enabled on mixer
		dc.w	$0100		; channel A freq MSB

		section	bss
		ds.w	1		; channel A freq LSB
		ds.w	1		; null terminate