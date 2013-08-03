	output	a:\getsound.inl

;	clr.l	-(sp)
;	move.w	#32,-(sp)
;	trap	#1
;	addq	#6,sp

	move.w	#$200b,$ffff8932.w 			*DSP-Out-> DAC & DMA-In
	clr.b	$ffff8900.w     			*no DMA-Interrupts
	clr.b	$ffff8936.w     			*record 1 Track
	move.b	#$40,$ffff8921.w 			*16 Bit

* mxalloc - Reserve stram ONLY for audio.
	move.w	#0,-(sp)
	move.l	#8000,-(sp)				* size of dma buffer
	move.w	#$44,-(sp)
	trap	#1
	addq	#8,sp
	move.l	d0,sdmabufadr

	move.b	#$80,$ffff8901.w 			*select Record-Frame-Register
	addq.l	#3,d0
	andi.w	#$fffc,d0
	move.l	d0,d1
	lsr.w	#8,d1
	move.l	d1,$ffff8902.w 				;8903 8905 8907
	move.b	d0,$ffff8907.w
	addi.l	#8000,d0
	move.l	d0,d1
	lsr.w	#8,d1
	move.l	d1,$ffff890e.w
	move.b	d0,$ffff8913.w 

	move.b	#$b0,$ffff8901.w 			*repeated record

	move.l	sdmabufadr,d0
	rts

	IFNE	0

	move.b	#$80,$ffff8901.w 		* Select Record-Frame-Register.
	move.l	$ffff8902.w,d0			* xxHHxxMM
	lsl.w	#8,d0				* xxHHMM00
	move.b	$ffff8907.w,d0			* xxHHMMLL

	rts

	ENDC

sdmabufadr:
	DC.L	0