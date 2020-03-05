;
; jpeg test source code
; steve tattersall
; jpeg decoder (c) Brainstorm
;
; for maggie 25
;
;
;

		output	e:\jpeg.prg

screen		equ	1		; output to screen?
					; if yes, make sure you're in
					; a 320*xxx truecolour mode!

incbin		equ	1		; if 0, needs the auto folder driver
					; if 1, includes the executable

		move.l	a7,a5
		move.l	4(a5),a5
		move.l	$c(a5),d0
		add.l	$14(a5),d0
		add.l	$1c(a5),d0
		move.l	d0,-(a7)
		move.l	a5,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		lea	12(a7),a7	;reserve enough memory
					;for the program

		pea	jpgd_find_cookie(pc)
		move.w	#$26,-(a7)
		trap	#14
		addq.l	#6,a7

		pea	jpgd_decode(pc)
		move.w	#$26,-(a7)
		trap	#14
		addq.l	#6,a7


		clr.w	-(a7)
		trap	#1

;-----------------------------------------------------------------
;
;
; Example code to decode a sample picture to either memory or
; the default screen address
;
;
;-----------------------------------------------------------------

jpgd_decode:
		ifne	screen
; Set the output to decode directly to the visible screen!
		move.l	$44e.w,jpgd_output_addr
		endc

;
;
; install the process:
		lea	jpgd_buffer(pc),a0
		moveq	#1,d0
		bsr	jpgd_callcommand
		tst.l	d0			;test for failure here

; This part sets how the picture is to be decoded:

		lea	jpgd_buffer(pc),a0
		move.l	#mypic,jpgd_picaddr(a0)
		move.l	#mypiclen,jpgd_length(a0)

; This part sets the input and output type expected
; (Best to specify 24 bit in both cases!)
; See the supplementary doc

		move.w	#3,jpgd_inputtype(a0)	;24bit input from file
		move.w	#3,jpgd_outputtype(a0)	;24bit output to me
		move.w	#4*3,jpgd_pixel_size	;always 4*output size

		move.l	#jpgd_receive_pixel,jpgd_pixel_routine

		bsr	jpgd_setup_decoding

; Now call the actual decoder parts
; a0 remains unchanged so can be reused
		moveq	#4,d0
		bsr	jpgd_callcommand
		moveq	#5,d0
		bsr	jpgd_callcommand
		moveq	#6,d0
		bsr	jpgd_callcommand
; Do a test for failure here:
		tst.l	d0
	
; Now de-install the decoder:
		lea	jpgd_buffer(pc),a0
		moveq	#2,d0
		bsr	jpgd_callcommand
		tst.l	d0

; Wait for the space key before exit:
.sp		cmp.b	#$39,$fffffc02.w
		bne	.sp
		rts



;-----------------------------------------------------------------
; jpgd_setup_decoding:
;
; Next part sets up which routines capture the data that the
; decoder sends back

jpgd_setup_decoding:
		move.w	#$ffff,jpgd_ready_flag(a0)	;go!
		move.l	#jpgd_ok,jpgd_outrout0(a0)
						;output file flag (dummy)
		move.l	#jpgd_copy_routine,jpgd_outrout1(a0)
		move.l	#jpgd_ok,jpgd_outrout2(a0)
						;dummy
		move.l	#jpgd_rts,jpgd_stopdelete(a0)
						;prevents a file deletion!
		move.l	#jpgd_ok,jpgd_outrout3(a0)
						;dummy 
		rts

;-----------------------------------------------------------------
; jpgd_find_cookie:
;
; Code to find the AUTO folder-installed cookie
; (only needed for the AUTO folder version)

jpgd_find_cookie:
		move.l	$5a0.w,a0
.find_cookie:
		tst.l	(a0)
		beq.s	.fail
		cmp.l	#"_jpd",(a0)
		beq.s	.succeed
		addq.l	#8,a0
		bra.s	.find_cookie

.fail:		moveq	#-1,d0
		rts

.succeed:
		move.l	4(a0),a1
		move.l	a1,jpgd_address
		rts


;-----------------------------------------------------------------
; jpgd_callcommand:
;
; executes the routine number passed in d0 where 1<=d0<=6
;

jpgd_callcommand:
		ifeq	incbin
		move.l	jpgd_address,a1
		move.l	(a1,d0.w*4),a1
		jsr	(a1)
		rts
		endc

		ifne	incbin
		jmp	.mylist-4(pc,d0.w*4)
.mylist:
		bra.w	jpgd_driverbin+0
		bra.w	jpgd_driverbin+70
		bra.w	jpgd_driverbin+126
		bra.w	jpgd_driverbin+134
		bra.w	jpgd_driverbin+214
		bra.w	jpgd_driverbin+386
		endc


;-----------------------------------------------------------------
; jpgd_copy_routine:
; jpgd_ok:
; jpgd_rts:
;
; Routines used in the actual decoding process

jpgd_copy_routine:
		movem.l	a0-a6/d1-d7,-(a7) 
		movea.l	a0,a6 
		movea.l	jpgd_block_output(a6),a0
						;where to get data from
		movea.l	jpgd_output_addr,a1 	;where to send it to
		moveq	#0,d0 
		moveq	#0,d1 
		moveq	#0,d6
		move.w	jpgd_bytessent(a6),d6	;number of bytes sent
		divu.w	jpgd_pixel_size,d6
		subq.w	#1,d6 
		move.w	jpgd_blocks_to_decode(a6),-(a7)
						;fetch the number of
						;blocks to decode
.line_loop:
		move.w	d6,d4 
		moveq	#1,d7 
.block_loop:
		moveq	#7,d5 
.pixel_loop:	
		jsr	([jpgd_pixel_routine.l])

		dbf	d5,.pixel_loop
		dbf	d4,.block_loop
		subq.w	#1,(a7)
		bne.s	.line_loop
		addq.w	#2,a7 

		move.l	a1,jpgd_output_addr
		moveq	#0,d0 			;flag that it's OK
		movem.l	(a7)+,a0-a6/d1-d7 
		rts 
jpgd_ok:	moveq	#0,d0
jpgd_rts:	rts


; jpgd_receive_pixel
;
; fetches a 24-bit pixel and outputs it as a 16-bit truecolour value
; change this routine as required!

jpgd_receive_pixel:
		movem.l	d0-d7/a2-a6,-(a7)
		move.b	(a0)+,d1		;ignore red
		move.b	(a0)+,d0		;use the green value
		move.b	(a0)+,d1		;ignore blue
		ext.w	d0
		asr.w	#3,d0			;convert to 5 bits
		mulu.w	#$841,d0
		move.w	d0,(a1)+		;output
		movem.l	(a7)+,d0-d7/a2-a6
		rts


;-----------------------------------------------------------------
; decoder data block structure:
;-----------------------------------------------------------------

jpgd_picaddr		equ	0
jpgd_nameaddr		equ	4
jpgd_length		equ	8
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
jpgd_width		equ	86
jpgd_height		equ	88
jpgd_bytessent		equ	90

;--------------------------------------------------------------------
			section	data
jpgd_address:		ds.l	1
jpgd_pixel_size:	ds.w	1
jpgd_decode_routine:	ds.l	1
jpgd_output_addr:	dc.l	myblock
jpgd_pixel_routine:	ds.l	1


;--------------------------------------------------------------------
mypic			incbin	320x200g.jpg
mypiclen		equ	*-mypic

			ifne	incbin
jpgd_driverbin		incbin	'jpegd.bin'
; The driver needs 10K of blank data after it for internal storage!
			ds.b	10000
			endc

;--------------------------------------------------------------------
			section	bss
jpgd_buffer:		ds.b	5288

; This is the buffer where the output goes by default

myblock:		ds.b	110000


