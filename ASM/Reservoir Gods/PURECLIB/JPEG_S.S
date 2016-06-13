	xdef	rljpeg_init_buffer
	xdef	rljpeg_command
	xdef	rljpeg_pixel_size
	xdef	rljpeg_output_addr

jpgd_picaddr		equ	0
jpgd_nameaddr		equ	4
jpgd_length			equ	8
jpgd_datasize		equ	12
jpgd_inputtype		equ	18
jpgd_outputtype		equ	20
jpgd_ready_flag		equ	22
jpgd_outrout0		equ	28
jpgd_outrout1		equ	32
jpgd_outrout2		equ	36
jpgd_stopdelete		equ	40
jpgd_outrout3		equ	60
jpgd_block_output	equ	64
jpgd_blocks_to_decode	equ	70
jpgd_width			equ	86
jpgd_height			equ	88
jpgd_bytessent		equ	90

rljpeg_init_buffer:
	movem.l	d0/a0-a1,-(a7)

	move.w	1396(a0),-(a7)
	move.l	a0,a1
	move.l	#5288/4-1,d0
.clr:
	clr.l	(a1)+
	dbra	d0,.clr
	move.w	(a7)+,1396(a0)

	move.w	d0,jpgd_ready_flag(a0)			;go!
	move.l	#jpgd_ok,jpgd_outrout0(a0)		;output file flag (dummy)
	move.l	#rljpeg_copy_routine,jpgd_outrout1(a0)
	move.l	#jpgd_ok,jpgd_outrout2(a0)		;dummy
	move.l	#jpgd_rts,jpgd_stopdelete(a0)	;prevents a file deletion!
	move.l	#jpgd_ok,jpgd_outrout3(a0)		;dummy 

	movem.l	(a7)+,d0/a0-a1
	rts

rljpeg_command:
	movem.l	d1-d7/a0-a6,-(a7)	
	cmp.w	#7,d0
	bhs.s	.invalid
	move.l	(rljpeg_offsets,d0.w*4),d0
	jsr		(rljpeg_driver,d0.l)
.invalid:
	movem.l	(a7)+,d1-d7/a0-a6
	rts


rljpeg_copy_routine:
	movem.l	a0-a6/d1-d7,-(a7) 
	movea.l	a0,a6 
	movea.l	jpgd_block_output(a6),a0			;where to get data from
	movea.l	rljpeg_output_addr,a1 				;where to send it to
	moveq	#0,d0 
	moveq	#0,d1 
	moveq	#0,d6
	move.w	jpgd_bytessent(a6),d6				;number of bytes sent
	divu.w	rljpeg_pixel_size,d6
	subq.w	#1,d6 
	move.w	jpgd_blocks_to_decode(a6),-(a7)		;#blocks to decode
.line_loop:
	move.w	d6,d4 
	moveq	#1,d7 
.block_loop:
	moveq	#7,d5 
.pixel_loop:	
	jsr	([rljpeg_pixel_routine.l])

	dbf	d5,.pixel_loop
	dbf	d4,.block_loop
	subq.w	#1,(a7)
	bne.s	.line_loop
	addq.w	#2,a7 

	move.l	a1,rljpeg_output_addr
	moveq	#0,d0 			;flag that it's OK
	movem.l	(a7)+,a0-a6/d1-d7 
	rts 
jpgd_ok:
	moveq	#0,d0
jpgd_rts:
	rts

rljpeg_16_16:
	move.w	(a0)+,(a1)+
	rts

rljpeg_pixel_routine:	dc.l	rljpeg_16_16
rljpeg_pixel_size:	dc.w	1
rljpeg_output_addr:	dc.l	0
rljpeg_offsets:		dc.l	0,0,70,126,134,214,386
rljpeg_driver:		include	"c:\heaven\new\jpegd.dcb"
					ds.b	10240