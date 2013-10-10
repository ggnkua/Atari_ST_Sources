*
*
*

.include	atari

PTERMRES	=	$31

TRAP14		=	$00B8

_longframe 	=	$59e

.text

.globl 	_DspDoBlock, 	       _DspBlkHandShake,      _DspBlkUnpacked
.globl	_DspInStream,	       _DspOutStream,	      _DspIOStream
.globl	_DspRemoveInterrupts,  _DspGetWordSize,       _DspLock
.globl	_DspUnlock,	       _DspAvailable,	      _DspReserve
.globl	_DspLdProg,	       _DspExProg,	      _DspExBoot
.globl	_DspLodToBinary,       _DspTriggerHC,	      _DspRequestUniqueAbility
.globl	_DspGetProgAbility,    _DspFlushSubroutines,  _DspLdSubroutine
.globl	_DspInqSubrAbility,    _DspRunSubroutine,     _DspHf0
.globl	_DspHf1,	       _DspHf2,	      	      _DspHf3
.globl	_DspBlkWords,	       _DspBlkBytes,	      _DspHStat
.globl  _DspSetVectors,        _DspMultBlocks
.globl	_Dsp_Init


_startup:
	nop
	nop
	nop
	Cconws	#str0			; Print out our sign-on message
	Cconws	#str1
	Cconws	#str2
	Cconws	#str3
	Super
	jsr	_Dsp_Init		; Init Dsp stuff
	
	jsr	install_new_trap
	User

*   Terminate and stay resident

	move.l	4(sp),a0		; a0 -> base page
	clr.w	-(sp)			; return code is zero

	move.l	$0C(a0),d0
	add.l	$14(a0),d0
	add.l	$1C(a0),d0
	add.l	#$100,d0
	move.l	d0,-(sp)		; push the amnt of mem to keep
	move.w	#PTERMRES,-(sp)
	trap	#1
	illegal

install_new_trap:

	move.l	TRAP14,old_xbios	; save old trap 14 vector
	move.l	#new_xbios,TRAP14	; install XBIOS vector
	rts


*+
*   New XBIOS handler: got here via trap 14
*-
new_xbios:
	move.l	usp,a0
	btst.b	#5,(sp)
	beq.s	gotsp
	lea.l	6(sp),a0
	tst.w	_longframe		; _longframe equ $5a0.w
	beq.s	gotsp
	addq.l	#2,a0
gotsp:

	move.w	(a0)+,d0		; Grab the opcode
	cmp.w	#500,d0			; Is it a dsp call?
	blt	.not_our_call		; No pass call through to TOS
	cmp.w	#531,d0
	bgt	.not_our_call
	move.l	sp,savesp		; Save old stack
	lea	stack,sp		; Replace with our stack
	add.l	#24,a0			
	move.l	-(a0),-(sp)		; Push onto our stack, the max
	move.l	-(a0),-(sp)		; number of possible parameters
	move.l	-(a0),-(sp)		; from the parameter block
	move.l	-(a0),-(sp)		; We lose a few cycles here but...
	move.l	-(a0),-(sp)
	move.l	-(a0),-(sp)

	sub.l	#500,d0			; 0 base into our table of routines
	add.w	d0,d0			; opcode * 4 gives index
	add.w	d0,d0
	move.l	_jmptab(pc,d0.w),d0	; get the jump table address
	movea.l	d0,a1
	jsr	(a1)			; Jsr to our dsp routine
	move.l	savesp,sp
	rte				; Return from trap 14
.not_our_call:
	move.l	old_xbios(pc),a0	; Jump to the old xbios routine
	jmp	(a0)

;
;	Dsp jump table of routines
;

_jmptab:
.dc.l 	_DspDoBlock, 	       _DspBlkHandShake,      _DspBlkUnpacked
.dc.l	_DspInStream,	       _DspOutStream,	      _DspIOStream
.dc.l	_DspRemoveInterrupts,  _DspGetWordSize,       _DspLock
.dc.l	_DspUnlock,	       _DspAvailable,	      _DspReserve
.dc.l	_DspLdProg,	       _DspExProg,	      _DspExBoot
.dc.l	_DspLodToBinary,       _DspTriggerHC,	      _DspRequestUniqueAbility
.dc.l	_DspGetProgAbility,    _DspFlushSubroutines,  _DspLdSubroutine
.dc.l	_DspInqSubrAbility,    _DspRunSubroutine,     _DspHf0
.dc.l	_DspHf1,	       _DspHf2,	              _DspHf3
.dc.l	_DspBlkWords,	       _DspBlkBytes,	      _DspHStat
.dc.l	_DspSetVectors,        _DspMultBlocks
;
;
old_xbios:	dc.l	0

*+
* device specific settings
*-

str0:		dc.b    '****************************************',13,10,0
str1:		dc.b    'Atari DSP Host Routines Installed       ',13,10,0
str2:		dc.b	'Date: 7/27/92     Rev 3.0               ',13,10,0
str3:		dc.b    '****************************************',13,10,0


		.even

.bss
savesp:		ds.l	1	; saved stack pointer
		ds.l	200	; 800 bytes for now
stack:		ds.l	1
