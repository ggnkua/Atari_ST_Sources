head	1.2;
access;
symbols
	TOS0400:1.2;
locks;
comment	@# @;


1.2
date	92.08.11.00.36.18;	author kbad;	state Exp;
branches;
next	1.1;

1.1
date	92.08.10.23.41.06;	author kbad;	state Exp;
branches;
next	;


desc
@Falcon030 XBIOS DSP bindings
@


1.2
log
@TOS 4.00 Falcon030 first production version
@
text
@
.text
.include atari

;
; DSP Host interface constants
;
ICR	=	$ffffa200		; Interrupt Control Register
CVR	=	$ffffa201		; Command Vector Register
ISR	=	$ffffa202		; Interrupt Status Register
IVR	=	$ffffa203		; Interrupt Vector Register

TRANSLONG	=	$ffffa204	; Long word location to write to 

RXH	=	$ffffa205		; Receive byte High
RXM	=	$ffffa206		; Receive byte Mid
RXL	=	$ffffa207		; Receive byte Low
TXH	=	$ffffa205		; Transmit byte High
TXM	=	$ffffa206		; Transmit byte Mid
TXL	=	$ffffa207		; Transmit byte Low

HOSTVECT =	$3fc			; interrupt vector number 255
HZ200	=	$4ba			; DEBUG 200 hz timer

.globl	_DspDoBlock
.globl	_DspBlkHandShake
.globl	_DspBlkUnpacked
.globl	_DspBlkWords
.globl	_DspBlkBytes
.globl	_DspIOStream	
.globl	_DspInStream
.globl	_DspOutStream
.globl	_DspRemoveInterrupts
.globl	_DspGetWordSize
.globl  _DspSetVectors
.globl  _DspMultBlocks
;

;
;
;	Transfer a block of data to the dsp.  Wait for the "ready to 
; 	send" flag from the dsp.  Grab a block of data from the dsp
;

_DspDoBlock:
	move.l	4(sp),a0			; Input buffer
	move.l	8(sp),d0			; Input buffer size
	move.l	12(sp),a1			; Output buffer pointer
	move.l	16(sp),d1			; Output buffer size
	tst.l	d0
	beq	.wait_for_output		; No input to DSP
	subq	#1,d0
.waitsend:
	btst	#1,ISR				; Wait for DSP to give us data
	beq	.waitsend
.loop1:
	move.b	(a0)+,TXH			; Transfer info to DSP
	move.b	(a0)+,TXM
	move.b	(a0)+,TXL
	dbra	d0,.loop1
.wait_for_output:
	tst.l	d1
	beq	.no_output			; No output expected from DSP
	subq	#1,d1
.waitloop:
	btst	#0,ISR				; Wait for DSP to give us data
	beq	.waitloop
.loop2:
	move.b	RXH,(a1)+			; Grab data from DSP
	move.b	RXM,(a1)+
	move.b	RXL,(a1)+
	dbra	d1,.loop2
.no_output:
	rts

;
;	Same as DoBlock but include handshaking 
;
_DspBlkHandShake:
	move.l	4(sp),a0			; Input buffer
	move.l	8(sp),d0			; Input buffer size
	move.l	12(sp),a1			; Output buffer pointer
	move.l	16(sp),d1			; Output buffer size
	tst.l	d0
	beq	.wait_for_output		; No input to DSP
	subq	#1,d0
.loop1:
	btst	#1,ISR				; Wait for DSP to accept data
	beq	.loop1
	move.b	(a0)+,TXH			; Transfer info to DSP
	move.b	(a0)+,TXM
	move.b	(a0)+,TXL
	dbra	d0,.loop1
.wait_for_output:
	tst.l	d1
	beq	.no_output			; No output expected from DSP
	subq	#1,d1
.loop2:
	btst	#0,ISR				; Wait for DSP to give us data
	beq	.loop2
	move.b	RXH,(a1)+			; Grab data from DSP
	move.b	RXM,(a1)+
	move.b	RXL,(a1)+
	dbra	d1,.loop2
.no_output:
	rts

;
;	Same as DoBlock except get/return data in unpacked 32 bit form
;

_DspBlkUnpacked:
	move.l	4(sp),a0			; Input buffer
	move.l	8(sp),d0			; Input buffer size
	move.l	12(sp),a1			; Output buffer pointer
	move.l	16(sp),d1			; Output buffer size
	tst.l	d0
	beq	.wait_for_output		; No input to DSP
	subq	#1,d0
.waitsend:
	btst	#1,ISR				; Wait for DSP to give us data
	beq	.waitsend
.loop1:
	move.l	(a0)+,TRANSLONG
	dbra	d0,.loop1
.wait_for_output:
	tst.l	d1
	beq	.no_output			; No output expected from DSP
	subq	#1,d1
.waitloop:
	btst	#0,ISR				; Wait for DSP to give us data
	beq	.waitloop
.loop2:
	move.l	TRANSLONG,(a1)+
	dbra	d1,.loop2
.no_output:
	rts


;
;	Same as DoBlock except get/return data in 16 bit form
;

_DspBlkWords:
	move.l	4(sp),a0			; Input buffer
	move.l	8(sp),d0			; Input buffer size
	move.l	12(sp),a1			; Output buffer pointer
	move.l	16(sp),d1			; Output buffer size
	tst.l	d0
	beq	.wait_for_output		; No input to DSP
	subq	#1,d0
.waitsend:
	btst	#1,ISR				; Wait for DSP to give us data
	beq	.waitsend
.loop1:
	move.w	(a0)+,d2
	ext.l	d2
	move.l	d2,TRANSLONG
	dbra	d0,.loop1
.wait_for_output:
	tst.l	d1
	beq	.no_output			; No output expected from DSP
	subq	#1,d1
.waitloop:
	btst	#0,ISR				; Wait for DSP to give us data
	beq	.waitloop
.loop2:
	move.b	RXM,(a1)+
	move.b	RXL,(a1)+
	dbra	d1,.loop2
.no_output:
	rts

;
;	Same as DoBlock except get/return data in 8 bit form
;

_DspBlkBytes:
	move.l	4(sp),a0			; Input buffer
	move.l	8(sp),d0			; Input buffer size
	move.l	12(sp),a1			; Output buffer pointer
	move.l	16(sp),d1			; Output buffer size
	tst.l	d0
	beq	.wait_for_output		; No input to DSP
	subq	#1,d0
.waitsend:
	btst	#1,ISR				; Wait for DSP to give us data
	beq	.waitsend
.loop1:
	move.b	#0,TXH
	move.b	#0,TXM
	move.b	(a0)+,TXL
	dbra	d0,.loop1
.wait_for_output:
	tst.l	d1
	beq	.no_output			; No output expected from DSP
	subq	#1,d1
.waitloop:
	btst	#0,ISR				; Wait for DSP to give us data
	beq	.waitloop
.loop2:
	move.b	RXM,d2				; Hardware bug? Need RXM read
	move.b	RXL,(a1)+
	dbra	d1,.loop2
.no_output:
	rts

;
;	Setup interrupts for input and output
;	send a block of data and receive a block at each interrupt
;

_DspIOStream:
	move.l	4(sp),dsp_inptr		; Save variables for interrupt routine
	move.l	8(sp),dsp_outptr	; Output buffer
	move.l	12(sp),dsp_ibsize	; input block size
	move.l	16(sp),dsp_obsize	; output block size
	move.l	20(sp),dsp_inumblks	; Number of blocks to transfer
	move.l	24(sp),dsp_ibdone	; Address of users blocks done count
	move.l	dsp_ibdone,a0
	move.l	#0,(a0)			; 0 input blocks done	

	move.l	dsp_ibsize,d0
	subq	#1,d0
	move.l	dsp_inptr,a0
.loop1:
	move.b	(a0)+,TXH		; prime pump with data
	move.b	(a0)+,TXM
	move.b	(a0)+,TXL
	dbra	d0,.loop1
	move.l	a0,dsp_inptr
;
	move.l	#dsp_iovect,HOSTVECT	; Set up 68K vector 255
	move.b	#255,IVR		; Tell the DSP
	ori.b	#1,ICR			; Enable receive interrupts
;
	rts

;
;	Interrupt routine for Dsp_IOStream
;
dsp_iovect:
	movem.l	d0/a0,-(sp)
	move.l	dsp_obsize,d0		; First Grab the block from the DSP
	subq	#1,d0
	move.l	dsp_outptr,a0
.loop2:
	move.b	RXH,(a0)+
	move.b	RXM,(a0)+
	move.b	RXL,(a0)+
	dbra	d0,.loop2
	move.l	a0,dsp_outptr		; Save new output pointer
	move.l	dsp_ibdone,a0
	addq.l	#1,(a0)			; Update # blocks transferred
	move.l	(a0),d0
	cmp.l	dsp_inumblks,d0		; Are we done?
	bne	.notdone
	andi.b	#$fe,ICR		; Remove ourselves from interrupts
	jmp	.quit
.notdone:
	move.l	dsp_ibsize,d0		; Not finished, give DSP another block
	subq	#1,d0
	move.l	dsp_inptr,a0
.loop3:
	move.b	(a0)+,TXH		; prime pump with data
	move.b	(a0)+,TXM
	move.b	(a0)+,TXL
	dbra	d0,.loop3
	move.l	a0,dsp_inptr
.quit:
	movem.l	(sp)+,d0/a0
	rte

;
;	Set up an interrupt vector to send data.
;
_DspInStream:
	move.l	4(sp),dsp_inptr		; Save variables for interrupt routine
	move.l	8(sp),dsp_ibsize	; input block size
	move.l	12(sp),dsp_inumblks	; Number of blocks to transfer
	move.l	16(sp),dsp_ibdone	; Address of users # blocks done ptr
	move.l	dsp_ibdone,a0
	move.l	#0,(a0)			; 0 input blocks completed
	move.l	dsp_ibsize,d0
	beq 	.noblocks
	move.l	#dsp_vect,HOSTVECT	; Set up 68K vector 254
	move.b	#255,IVR		; Tell the DSP
	ori.b	#2,ICR			; Enable receive interrupts
.noblocks:
	rts

;
;	Set up an interrupt vector to receive data
;
_DspOutStream:
	move.l	4(sp),dsp_outptr	; Save variables for interrupt routine
	move.l	8(sp),dsp_obsize	; input block size
	move.l	12(sp),dsp_onumblks	; Number of blocks to transfer
	move.l	16(sp),dsp_obdone	; Address of users "number of blocks
	move.l	dsp_obdone,a0		; done.
	move.l	#0,(a0)			; 0 output blocks done
	move.l	dsp_obsize,d0
	beq 	.noblocks
	move.l	#dsp_vect,HOSTVECT	; Set up 68K vector 254
	move.b	#255,IVR		; Tell the DSP
	ori.b	#1,ICR			; Enable receive interrupts
.noblocks:
	rts

;
;	Interrupt routine for Dsp_InStream and Dsp_OutStream
;
dsp_vect:
	movem.l	d0/a0,-(sp)
	btst.b	#0,ISR
	beq	.hndl_input
	move.l	dsp_obsize,d0		; Load up block size	
	subq	#1,d0			; Setup for dbra
	move.l	dsp_outptr,a0		; Setup buffer pointer
.loop1:
	move.b	RXH,(a0)+		; Transfer block of data to DSP
	move.b	RXM,(a0)+
	move.b	RXL,(a0)+
	dbra	d0,.loop1
	move.l	a0,dsp_outptr		; Save new buffer pointer
	move.l	dsp_obdone,a0
	add.l	#1,(a0)			; Update # blocks transferred
	move.l	(a0),d0
	cmp.l	dsp_onumblks,d0		; Are we done?
	bne	.exit			; No, return
	andi.b	#$fe,ICR	
	jmp	.exit
.hndl_input:
	move.l	dsp_ibsize,d0		; Load up block size	
	subq	#1,d0			; Setup for dbra
	move.l	dsp_inptr,a0		; Setup buffer pointer
.loop2:
	move.b	(a0)+,TXH		; Transfer block of data to DSP
	move.b	(a0)+,TXM
	move.b	(a0)+,TXL
	dbra	d0,.loop2
	move.l	a0,dsp_inptr		; Save new buffer pointer
	move.l	dsp_ibdone,a0
	add.l	#1,(a0)			; Update # blocks transferred
	move.l	(a0),d0
	cmp.l	dsp_inumblks,d0		; Are we done?
	bne	.exit			; No, return
	andi.b	#$fd,ICR		; Zero bit 1 of ICR to disable ints.
.exit:
	movem.l	(sp)+,d0/a0
	rte

;
;	Remove DSP interrupts depending on the given value
;	
;	1 - remove output interrupts
;	2 - remove input interrupts
;	3 - remove all interrupts
;

_DspRemoveInterrupts:
	move.w	4(sp),d0
	not.b	d0
	and.b	d0,ICR
	rts
;
;	Return number of bytes in a DSP word
;	This may change on future releases of hardware
;
;
_DspGetWordSize:
	move.w	#3,d0
	rts


_DspSetVectors:
	move.l	#0,dsp_hreceiver	; Clear both interrupt vectors
	move.l	#0,dsp_htransmit
	move.l	4(sp),d0		; Check for a receiver vector
	beq	.no_recvect
	move.l	d0,dsp_hreceiver	; Save receiver vector
	move.l	#dsp_dispatch,HOSTVECT	; Set up 68K vector 254
	move.b	#255,IVR		; Tell the DSP
	ori.b	#1,ICR			; Enable receive interrupts
.no_recvect:
	move.l	8(sp),d0		; Check for a transmit vector
	beq	.no_transvect
	move.l	d0,dsp_htransmit
	move.l	#dsp_dispatch,HOSTVECT	; Set up 68K vector 254
	move.b	#255,IVR		; Tell the DSP
	ori.b	#2,ICR			; Enable receive interrupts
.no_transvect:
	rts

dsp_dispatch:
	movem.l	d0-d2/a0-a2,-(sp)

	btst.b	#0,ISR			; Was this a receive interrupt?
	beq	.hndl_transfer		; Nope, handle transfer
	move.l	dsp_hreceiver,d0	; Get user receive vector
	beq	.hndl_transfer		; If 0L then skip
	move.l	d0,a0
	move.l	#0,d0			; Used for transferring data
	move.b	RXH,d0			; Get the dsp word
	rol.l	#8,d0
	move.b	RXM,d0
	rol.l	#8,d0
	move.b	RXL,d0
	move.l	d0,-(sp)		; push it on the stack
	jsr	(a0)			; jsr to the user routine
	addq.l	#4,sp			; clean up stack
.hndl_transfer:
	btst.b	#1,ISR			; Was it a transfer interrupt?
	beq	.exit			; Nope, exit
	move.l	dsp_htransmit,d0	; Get user transfer vector
	beq	.exit			; exit if it's empty
	move.l	d0,a0
	jsr	(a0)			; Jsr to user transfer routine
	tst.l	d0			; Did d0 come back with a value?
	beq	.exit			; No, just exit
	swap	d0			; Yes, output low 3 bytes of d0
	move.b	d0,TXH			
	rol.l	#8,d0
	move.b	d0,TXM
	rol.l	#8,d0
	move.b	d0,TXL
.exit:
	movem.l	(sp)+,d0-d2/a0-a2
	rte


_DspMultBlocks:
	move.l	4(sp),d0			; Get output block count
	beq	.hndl_input			; If none go handle input
.waitsend:
	btst	#1,ISR				; Wait to send data to DSP
	beq	.waitsend
	move.l	12(sp),a0			; Address of buffer structs
	sub	#1,d0				; setup for dbra
.output_loop:
	move.w	(a0),d1				; d1 = type
	move.l	2(a0),d2			; d2 = size of block
	subq.l	#1,d2
	move.l	6(a0),a1			; a1 = block address
	cmp.w	#0,d1
	beq	.sendlongs
	cmp.w	#1,d1
	beq	.sendints
	cmp.w	#2,d1
	beq	.sendchars
	jmp	.exit				; Error bail out	
.sendlongs:
	move.l	(a1)+,TRANSLONG
	dbra	d2,.sendlongs
	jmp	.output_end
.sendints:
	move.w	(a1)+,d1
	ext.l	d1
	move.l	d1,TRANSLONG
	dbra	d2,.sendints
	jmp	.output_end
.sendchars:
	move.b	#0,TXH
	move.b	#0,TXM
	move.b	(a1)+,TXL
	dbra	d2,.sendchars
.output_end:
	lea	10(a0),a0
	dbra	d0,.output_loop
.hndl_input:
	move.l	8(sp),d0
	beq	.exit
.waitrec:
	btst	#0,ISR	
	beq	.waitrec
	move.l	16(sp),a0			; Address of buffer struct
	sub	#1,d0
.input_loop:
	move.w	(a0),d1				; d1 = type
	move.l	2(a0),d2			; d2 = size of block
	subq.l	#1,d2
	move.l	6(a0),a1			; a1 = block address
	cmp.w	#0,d1
	beq	.reclongs
	cmp.w	#1,d1
	beq	.recints
	cmp.w	#2,d1
	beq	.recchars
	jmp	.exit				; Error bail out	
.reclongs:
	move.l	TRANSLONG,(a1)+
	dbra	d2,.reclongs
	jmp	.input_end
.recints:
	move.b	RXM,(a1)+
	move.b	RXL,(a1)+
	dbra	d2,.recints
	jmp	.input_end
.recchars:
	move.b	RXM,d1				; Hardware bug? RXM needs read
	move.b	RXL,(a1)+
	dbra	d2,.recchars
.input_end:
	lea	10(a0),a0
	dbra	d0,.input_loop
.exit:
	rts

.bss
dsp_hreceiver:  .ds.l	1		; Address of host receive vector
dsp_htransmit:  .ds.l	1		; Address of host transmit vector
dsp_inptr:	.ds.l	1		; Address of application input buffer
dsp_outptr:	.ds.l	1		; Address of application output buffer
dsp_ibsize:	.ds.l	1		; Input block size
dsp_obsize:	.ds.l	1		; Output block size
dsp_inumblks:	.ds.l	1		; Input number of blocks
dsp_onumblks:	.ds.l	1		; Output number of blocks
dsp_ibdone:	.ds.l	1		; Input blocks done
dsp_obdone:	.ds.l	1		; Output blocks done
dsp_ifinished:	.ds.l	1		; Storage for users finished flag
dsp_ofinished:	.ds.l	1		; Ditto above for the output interrupts

.end
@


1.1
log
@Initial revision
@
text
@d1 523
@
