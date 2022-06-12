;---------------------------------------------------------------------------------------------------
; FalconSystem v5 - General Demo/Game System Library for the Falcon 030/060 by Orion_ [2009 - 2013]
;---------------------------------------------------------------------------------------------------

; Videl routine by Anders Eriksson from DHS
; C2P routine by Mikael Kalms from TBL, Improved by MiKRO
; IKBD routine by Patrice Mandin

	machine	68060

;------------------------------------------
; Functions

	public	_SetVidel
	public	_SaveVidel
	public	_RestoreVidel

	public	_SetupInterrupts
	public	_RestoreInterrupts

	public	_CpuSaveState
	public	_CpuEnableFullCacheSuperscalar
	public	_CpuRestoreState

	public	_FastCopy32
	public	_FastClear32
	public	_VFastCopy32
	public	_VFastClear32
	public	_FastCopy16Skip
	public	_FastCopy32Skip16

	public	_FastHLine320_8

	public	_FastC2P_8BPP

	public	_IKBD_Install
	public	_IKBD_Uninstall
	public	_IKBD_MouseOn
	public	_IKBD_MouseOff

;------------------------------------------
; Vars

	; .l
	public	_FS_Timer200Hz
	public	_FS_NewScreenAdrs
	public	_FS_PalettePtr
	public	_FS_VBLFuncPtr
	public	_CpuSaveCACR
	public	_CpuSavePCR

	; .w
	public	_FS_VblAck
	public	_FS_nFrames
	public	_FS_SetNewScreen
	public	_FS_Vmode

	; 128 .b
	public	_IKBD_Keyboard

	; .w
	public	_IKBD_MouseX
	public	_IKBD_MouseY

	; .b
	public	_IKBD_MouseB
	public	_IKBD_Joystick0
	public	_IKBD_Joystick1


;------------------------------------------
; System Setup

_SetupInterrupts:
	move.w	#$2700,sr		; Int Off
	move.l	$70.w,oldVBL
	move.l	$114.w,oldTimerC
	move.l	#VBL,$70.w
	move.l	#TimerC,$114.w
	move.w	#$2300,sr		; Int On
	rts

_RestoreInterrupts:
	move.w	#$2700,sr		; Int Off
	move.l	oldVBL,$70.w
	move.l	oldTimerC,$114.w
	move.w	#$2300,sr		; Int On
	rts

;----

VBL:
	tst.l	_FS_PalettePtr
	beq.s	.nosetpalette

	movem.l	a0-a1/d0,-(a7)
	movea.l	_FS_PalettePtr,a0
	lea	$FFFF9800.w,a1
	move.w	#256-1,d0
.repal:	move.l	(a0)+,(a1)+
	dbra	d0,.repal
	movem.l	(a7)+,a0-a1/d0

.nosetpalette:
	addq.w	#1,_FS_VblAck
	addq.w	#1,_FS_nFrames

	tst.w	_FS_SetNewScreen
	beq.s	.noNewScreen
	movem.l	d0-d1,-(a7)
	move.l	_FS_NewScreenAdrs,d0
	move.l	d0,d1		; 00HHMMLL
	lsr.w	#8,d0		; 00HH00MM
	move.l	d0,$ffff8200.w	; Set High & Mid
	move.b	d1,$ffff820d.w	; Set Low
	movem.l	(a7)+,d0-d1
	clr.w	_FS_SetNewScreen

.noNewScreen:
	tst.l	_FS_VBLFuncPtr
	beq.s	.noHook

;	move.l	#$FFFFFFFF,$FFFF9800.w
	movem.l	a0-a2/d0-d2,-(a7)	; User function VBL Hook
	move.l	_FS_VBLFuncPtr,a0
	jsr	(a0)
	movem.l	(a7)+,a0-a2/d0-d2
;	move.l	#0,$FFFF9800.w

.noHook:
	rte

;----

TimerC:
	addq.l	#1,_FS_Timer200Hz
	move.l	oldTimerC,-(a7)
	rts



;------------------------------------------
; Ikbd: Code by Patrice Mandin

_IKBD_Install:
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	#$2700,sr
	lea	$fffffa00.w,a0
	btst	#6,$9(a0)
	sne	ikbd_ierb
	btst	#6,$15(a0)
	sne	ikbd_imrb
	move.l	$118.w,old_ikbd
	move.l	#ikbd,$118.w
	bset	#6,$fffffa09.w	; IERB
	bset	#6,$fffffa15.w	; IMRB
	bsr	_IKBD_MouseOn
	move.w	#$2300,sr
	movem.l	(sp)+,d0-d1/a0-a1
	rts

_IKBD_Uninstall:
	move.l	a0,-(sp)
	move.w	#$2700,sr
	lea	$fffffa00.w,a0
	bclr	#6,$9(a0)
	tst.b	ikbd_ierb
	beq.s	ikbd_restoreierb
	bset	#6,$9(a0)
ikbd_restoreierb:
	bclr	#6,$15(a0)
	tst.b	ikbd_imrb
	beq.s	ikbd_restoreimrb
	bset	#6,$15(a0)
ikbd_restoreimrb:
	move.l	old_ikbd,$118.w
	lea	$fffffc00.w,a0
ikbd_clearbuffer:
	btst	#0,(a0)
	beq.s	ikbd_buffercleared
	tst.b	2(a0)
	bra.s	ikbd_clearbuffer
ikbd_buffercleared:
	move.w	#$2300,sr
	move.l	(sp)+,a0
	rts

_IKBD_MouseOff:
	move.b #$14,$fffffc02.w
	rts

_IKBD_MouseOn:
	move.b #$08,$fffffc02.w
	rts

ikbd:
	btst	#0,$fffffc00.w
	beq.s	ikbd_endit
	movem.l	d0-d1/a0,-(sp)
	move.b	$fffffc02.w,d0
	cmp.b	#$ff,d0
	beq.s	ikbd_yes_joystick1
	cmp.b	#$f8,d0
	bmi.s	ikbd_no_mouse
	cmp.b	#$fc,d0
	bpl.s	ikbd_no_mouse
ikbd_yes_mouse:
	and.b	#3,d0
	move.b	d0,_IKBD_MouseB
	move.l	#ikbd_mousex,$118.w    ; queue different irq vector for mouse packet
	bra.s	ikbd_endit_stack
ikbd_yes_joystick1:
	move.l	#ikbd_poll_joystick1,$118.w  ; queue joystick irq for next packet
	bra.s	ikbd_endit_stack
ikbd_no_mouse:
	move.b	d0,d1
	lea	_IKBD_Keyboard,a0
	and.l	#$7f,d1			; mask scancode
	tas	d0			
	spl	0(a0,d1.w)		; store -1 in scancode table
ikbd_endit_stack:
	movem.l	(sp)+,d0-d1/a0
ikbd_endit:
	bclr	#6,$fffffa11.w		; acknowledge IKBD interrupt
	rte				; ... and terminate the ISR
ikbd_mousex:
	btst	#0,$fffffc00.w
	beq.s	ikbd_endit
	move.w	d0,-(sp)
	move.b	$fffffc02.w,d0
	ext.w	d0
	add.w	d0,_IKBD_MouseX
	move.w	(sp)+,d0
	move.l	#ikbd_mousey,$118.w
	bra.s	ikbd_endit
ikbd_mousey:
	btst	#0,$fffffc00.w
	beq.s	ikbd_endit
	move.w	d0,-(sp)
	move.b	$fffffc02.w,d0
	ext.w	d0
	add.w	d0,_IKBD_MouseY
	move.w	(sp)+,d0
	move.l	#ikbd,$118.w
	bra.s	ikbd_endit
ikbd_poll_joystick1:
	btst	#0,$fffffc00.w
	beq.s	ikbd_endit
	move.b	$fffffc02.w,_IKBD_Joystick1
	move.l	#ikbd,$118.w
	bra.s	ikbd_endit



;------------------------------------------
; CPU Flags

_CpuSaveState:
	movec	CACR,d0
	movec	PCR,d1
	move.l	d0,_CpuSaveCACR
	move.l	d1,_CpuSavePCR
	rts

_CpuEnableFullCacheSuperscalar:
	move.l	#$A0808000,d0
	movec	PCR,d1
	ori.b	#1,d1
	movec	d0,CACR
	movec	d1,PCR
	rts

_CpuRestoreState:
	move.l	_CpuSaveCACR,d0
	move.l	_CpuSavePCR,d1
	movec	d0,CACR
	movec	d1,PCR
	rts


;------------------------------------------
; Memory Operations

_FastCopy32:	; Multiple of 8 and Not more than 500Kbytes
; a0 = src
; a1 = dst
; d0 = size
	lsr.l	#3,d0
	subq.l	#1,d0
.copy:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,.copy
	rts


_VFastCopy32:	; Multiple of 32
; a0 = src
; a1 = dst
; d0 = size
	movem.l	d3-d7,-(a7)
	lsr.l	#5,d0
	subq.l	#1,d0
.copy:	movem.l	(a0)+,d1-d7/a2
	movem.l	d1-d7/a2,(a1)
	lea	32(a1),a1
	dbra	d0,.copy
	movem.l	(a7)+,d3-d7
	rts


_FastClear32:	; Multiple of 8 and Not more than 500Kbytes
; a0 = dst
; d0 = size
; d1 = data
	lsr.l	#3,d0
	subq.l	#1,d0
.cls:	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra	d0,.cls
	rts


_VFastClear32:	; Multiple of 32
; a0 = dst
; d0 = size
; d1 = data
	movem.l	d3-d6,-(a7)
	add.l	d0,a0
	lsr.l	#5,d0
	subq.l	#1,d0
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,a1
	move.l	d1,a2
.copy:	movem.l	d1-d6/a1-a2,-(a0)
	dbra	d0,.copy
	movem.l	(a7)+,d3-d6
	rts


_FastCopy16Skip:
; a0 = src
; a1 = dst
; d0 = size
; d1 = src 16bits data to skip
	lsr.l	#1,d0
.copy:	move.w	(a0)+,d2
	cmp.w	d1,d2
	beq.s	.ncopy
	move.w	d2,(a1)+
	subq.l	#1,d0
	bne.s	.copy
	rts
.ncopy:	addq.l	#2,a1
	subq.l	#1,d0
	bne.s	.copy
	rts


_FastCopy32Skip16:
; a0 = src
; a1 = dst
; d0 = size (no more than 262144)
; d1 = src 16bits data to skip
	lsr.l	#2,d0

	move.w	d1,d2	; Double d1 16:16
	swap	d1
	move.w	d2,d1

.copy:
	move.l	(a0)+,d2
	cmp.l	d2,d1
	beq.s	.ncopyBoth

	move.l	d2,d3
	swap	d3

	cmp.w	d2,d1
	beq.s	.copyHigh

	cmp.w	d3,d1
	beq.s	.copyLow

	move.l	d2,(a1)+
	dbra	d0,.copy
	rts

.copyLow:
	move.w	d2,2(a1)

.ncopyBoth:
	addq.l	#4,a1
	dbra	d0,.copy
	rts

.copyHigh:
	move.w	d3,(a1)
	addq.l	#4,a1
	dbra	d0,.copy
	rts


;------------------------------------------
; Drawing Routines

; Fast HLine 320x8BPP - by Orion_ [2009]

_FastHLine320_8:
; a0 = screen
; d0 = x1
; d1 = x2
; d2 = y
; d3 = color

	movem.l	d3-d7/a0,-(a7)

	moveq	#15,d5
	move.w	d0,d4	; x1 shift
	move.w	d1,d6	; x2 shift
	and.w	d5,d4	; x1 & 15
	and.w	d5,d6
	sub.w	d6,d5	; 15 - (x2 & 15)

	lsr.w	#4,d0	; x1 div
	lsr.w	#4,d1	; x2 div

	mulu.l	#320,d2	; y * ScreenWidth
	move.w	d0,d6
	lsl.w	#4,d6	; x1 div * ScreenBPP (8 * 2)
	adda.l	d2,a0
	adda.w	d6,a0	; + Screen

	cmp.w	d0,d1
	bne.s	.nwithinsame


	; Within the same 16 pix chunk
	move.w	#$FFFF,d6

	add.w	d4,d5	; x1s + x2s
	lsl.w	d5,d6
	lsr.w	d4,d6

	moveq	#8-1,d5	; ScreenBPP
	move.w	d6,d4
	not.w	d4
.wsBPPloop:
	lsr.w	#1,d3	; color >>= 1
	bcc.s	.wsclr
	or.w	d6,(a0)+
	dbra	d5,.wsBPPloop
	movem.l	(a7)+,d3-d7/a0
	rts
.wsclr:	and.w	d4,(a0)+
	dbra	d5,.wsBPPloop
	movem.l	(a7)+,d3-d7/a0
	rts


.nwithinsame:
	move.w	d1,d7
	sub.w	d0,d7
	subq.w	#1,d7	; x2d - x1d

	move.w	#$FFFF,d6
	lsr.w	d4,d6	; x1s

	moveq	#8-1,d0	; ScreenBPP
	move.w	d6,d1
	move.w	d3,d2	; Save Color
	not.w	d1
.nwsBPPloopS:
	lsr.w	#1,d2	; color >>= 1
	bcc.s	.clr1
	or.w	d6,(a0)+
	dbra	d0,.nwsBPPloopS
	bra.s	.nwsM
.clr1:	and.w	d1,(a0)+
	dbra	d0,.nwsBPPloopS

.nwsM:
	tst.w	d7
	beq.s	.nwsE

	subq.w	#1,d7	; (dbra count)

	move.w	#$FFFF,d6

.nwsBPPloopMl:
	moveq	#8-1,d0	; ScreenBPP
	move.w	d3,d2	; Save Color
.nwsBPPloopM:
	lsr.w	#1,d2	; color >>= 1
	bcc.s	.clr3
	move.w	d6,(a0)+
	dbra	d0,.nwsBPPloopM
	dbra	d7,.nwsBPPloopMl
	bra.s	.nwsE
.clr3:	clr.w	(a0)+
	dbra	d0,.nwsBPPloopM
	dbra	d7,.nwsBPPloopMl

.nwsE:
	move.w	#$FFFF,d6
	lsl.w	d5,d6	; x2s

	moveq	#8-1,d0	; ScreenBPP
	move.w	d6,d1
	move.w	d3,d2	; Save Color
	not.w	d1
.nwsBPPloopE:
	lsr.w	#1,d2	; color >>= 1
	bcc.s	.clr4
	or.w	d6,(a0)+
	dbra	d0,.nwsBPPloopE
	movem.l	(a7)+,d3-d7/a0
	rts
.clr4:	and.w	d1,(a0)+
	dbra	d0,.nwsBPPloopE
	movem.l	(a7)+,d3-d7/a0
	rts


;------------------------------------------
; Fast 8bpp C2P by Kalms

; improved c2p by MiKRO, http://mikro.atari.org

; in	a0	chunky (aligned on 16 bytes boundary)
;	a1	screen (aligned on 4 bytes boundary)
;	d0	size (ex: 320x240)

; time between each write to ST-RAM:
; on 16 MHZ data bus: 2*4*(1/16000000) / (1/66666000) ~ 33 cycles
; on 24 MHZ data bus: 2*4*(1/24000000) / (1/66666000) ~ 22 cycles
; on 060 in "superscalar mode" take 20 instructions ~10 cycles
; on 040 or 060 in normal mode take 20 instructions ~20 cycles

; make sure you have enabled intruction & data & branch cache,
; enabled FIFO buffer for data cache and
; enabled "superscalar mode" in PCR !

_FastC2P_8BPP:
		movem.l	d0-d7/a2-a6,-(sp)
		move.l	a0,a2
		adda.l	d0,a2
;		adda.l	#320*240,a2
		move.l	#$0f0f0f0f,d4
		move.l	#$00ff00ff,d5

		move.l	(a0)+,d0
		move.l	(a0)+,d1
		move.l	(a0)+,d2
		move.l	(a0)+,d3

		move.l	d1,d7
		move.l	d3,d6
		lsr.l	#4,d7
		lsr.l	#4,d6
		eor.l	d0,d7
		eor.l	d2,d6
		and.l	d4,d7
		and.l	d4,d6
		eor.l	d7,d0
		eor.l	d6,d2
		lsl.l	#4,d7
		lsl.l	#4,d6
		eor.l	d7,d1
		eor.l	d6,d3

		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#8,d7
		lsr.l	#8,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	d5,d7
		and.l	d5,d6
		eor.l	d7,d0
		eor.l	d6,d1
		lsl.l	#8,d7
		lsl.l	#8,d6
		eor.l	d7,d2
		eor.l	d6,d3
	
		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#1,d7
		lsr.l	#1,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	#$55555555,d7
		and.l	#$55555555,d6
		eor.l	d7,d0
		eor.l	d6,d1
		add.l	d7,d7
		add.l	d6,d6
		eor.l	d7,d2
		eor.l	d6,d3
	
		move.w	d2,d7
		move.w	d3,d6
		move.w	d0,d2
		move.w	d1,d3
		swap	d2
		swap	d3
		move.w	d2,d0
		move.w	d3,d1
		move.w	d7,d2
		move.w	d6,d3

		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#2,d7
		lsr.l	#2,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	#$33333333,d7
		and.l	#$33333333,d6
		eor.l	d7,d0
		eor.l	d6,d1
		lsl.l	#2,d7
		lsl.l	#2,d6
		eor.l	d7,d2
		eor.l	d6,d3
		
		swap	d0
		swap	d1
		swap	d2
		swap	d3

		movea.l	d0,a6
		movea.l	d2,a5
		movea.l	d1,a4
		movea.l	d3,a3

.c2p_loop:	tst.w	0*16+15(a0)			; line 0 & 1
		tst.w	2*16+15(a0)			; line 2 & 3
		tst.w	4*16+15(a0)			; line 4 & 5
		tst.w	6*16+15(a0)			; line 6 & 7
		tst.w	8*16+15(a0)			; line 8 & 9
		tst.w	10*16+15(a0)			; line 10 & 11
		tst.w	12*16+15(a0)			; line 12 & 13
		tst.w	14*16+15(a0)			; line 14 & 15

		REPT	15
		move.l	(a0)+,d0
		move.l	(a0)+,d1
		move.l	(a0)+,d2
		move.l	(a0)+,d3

		move.l	d1,d7
		move.l	d3,d6
		lsr.l	#4,d7
		lsr.l	#4,d6
		move.l	a3,(a1)+
		eor.l	d0,d7
		eor.l	d2,d6
		and.l	d4,d7
		and.l	d4,d6
		eor.l	d7,d0
		eor.l	d6,d2
		lsl.l	#4,d7
		lsl.l	#4,d6
		eor.l	d7,d1
		eor.l	d6,d3

		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#8,d7
		lsr.l	#8,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	d5,d7
		and.l	d5,d6
		eor.l	d7,d0
		eor.l	d6,d1
		move.l	a4,(a1)+
		lsl.l	#8,d7
		lsl.l	#8,d6
		eor.l	d7,d2
		eor.l	d6,d3
			
		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#1,d7
		lsr.l	#1,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	#$55555555,d7
		and.l	#$55555555,d6
		eor.l	d7,d0
		eor.l	d6,d1
		add.l	d7,d7
		add.l	d6,d6
		eor.l	d7,d2
		eor.l	d6,d3
	
		move.w	d2,d7
		move.w	d3,d6
		move.l	a5,(a1)+
		move.w	d0,d2
		move.w	d1,d3
		swap	d2
		swap	d3
		move.w	d2,d0
		move.w	d3,d1
		move.w	d7,d2
		move.w	d6,d3

		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#2,d7
		lsr.l	#2,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	#$33333333,d7
		and.l	#$33333333,d6
		eor.l	d7,d0
		eor.l	d6,d1
		move.l	a6,(a1)+
		lsl.l	#2,d7
		lsl.l	#2,d6
		eor.l	d7,d2
		eor.l	d6,d3

		swap	d0
		swap	d1
		swap	d2
		swap	d3

		movea.l	d0,a6
		movea.l	d2,a5
		movea.l	d1,a4
		movea.l	d3,a3
		ENDR
		
		cmpa.l	a0,a2
		beq.w	.end_loop
		
		move.l	(a0)+,d0
		move.l	(a0)+,d1
		move.l	(a0)+,d2
		move.l	(a0)+,d3

		move.l	d1,d7
		move.l	d3,d6
		lsr.l	#4,d7
		lsr.l	#4,d6
		move.l	a3,(a1)+
		eor.l	d0,d7
		eor.l	d2,d6
		and.l	d4,d7
		and.l	d4,d6
		eor.l	d7,d0
		eor.l	d6,d2
		lsl.l	#4,d7
		lsl.l	#4,d6
		eor.l	d7,d1
		eor.l	d6,d3

		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#8,d7
		lsr.l	#8,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	d5,d7
		and.l	d5,d6
		eor.l	d7,d0
		eor.l	d6,d1
		move.l	a4,(a1)+
		lsl.l	#8,d7
		lsl.l	#8,d6
		eor.l	d7,d2
		eor.l	d6,d3
			
		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#1,d7
		lsr.l	#1,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	#$55555555,d7
		and.l	#$55555555,d6
		eor.l	d7,d0
		eor.l	d6,d1
		add.l	d7,d7
		add.l	d6,d6
		eor.l	d7,d2
		eor.l	d6,d3
	
		move.w	d2,d7
		move.w	d3,d6
		move.l	a5,(a1)+
		move.w	d0,d2
		move.w	d1,d3
		swap	d2
		swap	d3
		move.w	d2,d0
		move.w	d3,d1
		move.w	d7,d2
		move.w	d6,d3

		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#2,d7
		lsr.l	#2,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	#$33333333,d7
		and.l	#$33333333,d6
		eor.l	d7,d0
		eor.l	d6,d1
		move.l	a6,(a1)+
		lsl.l	#2,d7
		lsl.l	#2,d6
		eor.l	d7,d2
		eor.l	d6,d3

		swap	d0
		swap	d1
		swap	d2
		swap	d3

		movea.l	d0,a6
		movea.l	d2,a5
		movea.l	d1,a4
		movea.l	d3,a3
		
		bra.w	.c2p_loop
		
.end_loop:	move.l	a3,(a1)+
		move.l	a4,(a1)+
		move.l	a5,(a1)+
		move.l	a6,(a1)+
	
		movem.l	(sp)+,d0-d7/a2-a6
		rts



;---------------------------------------
; Videl functions by DHS

_SaveVidel:
	lea.l	$ffff9800.w,a0
	lea.l	save_pal,a1
	move.w	#256-1,d0
.colloop:
	move.l	(a0)+,(a1)+
	dbra	d0,.colloop

	lea.l	save_videl,a0
	move.l	$ffff8200.w,(a0)+
	move.w	$ffff820c.w,(a0)+
	move.l	$ffff8282.w,(a0)+
	move.l	$ffff8286.w,(a0)+
	move.l	$ffff828a.w,(a0)+
	move.l	$ffff82a2.w,(a0)+
	move.l	$ffff82a6.w,(a0)+
	move.l	$ffff82aa.w,(a0)+
	move.w	$ffff82c0.w,(a0)+
	move.w	$ffff82c2.w,(a0)+
	move.l	$ffff820e.w,(a0)+
	move.w	$ffff820a.w,(a0)+
	move.b  $ffff8256.w,(a0)+
	clr.b   (a0)
	cmp.w   #$b0,$ffff8282.w
	sle     (a0)+
	move.w	$ffff8266.w,(a0)+
	move.w	$ffff8260.w,(a0)+

	rts

;---------------------------------------

_SetVidel:	; _FS_Vmode must be set !
	move.w	#$59,-(sp)	; VgetMonitor()
	trap	#14
	addq.l	#2,sp

	tst.w	d0
	bne.s	.vga
	clr.l	d0		; Return Error
	rts

.vga:	lea.l	vm_table,a1
	move.w	_FS_Vmode,d1
	lsl.w	#3,d1		; *4*2
	adda.w	d1,a1

	movea.l	(a1)+,a0	; VGA
	cmp.w	#2,d0
	beq.s	.ok

	movea.l	(a1),a0		; RGB TV
.ok:
	tst.l	a0
	bne	.notnull
	clr.l	d0		; Return Error (640x480 in RGB mode not supported)
	rts

.notnull:
	move.l	(a0)+,$ffff8282.w
	move.l	(a0)+,$ffff8286.w
	move.l	(a0)+,$ffff828a.w
	move.l	(a0)+,$ffff82a2.w
	move.l	(a0)+,$ffff82a6.w
	move.l	(a0)+,$ffff82aa.w
	move.w	(a0)+,$ffff820a.w
	move.w	(a0)+,$ffff82c0.w
	clr.w	$ffff8266.w
	move.l	(a0)+,d0
	bmi.s	.st_comp
	clr.b	$ffff8260.w
	move.w	d0,$ffff8266.w
	bra.s	.set_video
.st_comp:
	clr.w	$ffff8266.w
	swap	d0
	move.b	d0,$ffff8260.w
.set_video:
	move.w	(a0)+,$ffff82c2.w
	move.w	(a0)+,$ffff8210.w

	move.l	#1,d0		; Success
	rts

;---------------------------------------

_RestoreVidel:
	lea.l	save_videl,a0
	clr.w   $ffff8266.w
	move.l	(a0)+,$ffff8200.w
	move.w	(a0)+,$ffff820c.w
	move.l	(a0)+,$ffff8282.w
	move.l	(a0)+,$ffff8286.w
	move.l	(a0)+,$ffff828a.w
	move.l	(a0)+,$ffff82a2.w
	move.l	(a0)+,$ffff82a6.w
	move.l	(a0)+,$ffff82aa.w
	move.w	(a0)+,$ffff82c0.w
	move.w	(a0)+,$ffff82c2.w
	move.l	(a0)+,$ffff820e.w
	move.w	(a0)+,$ffff820a.w
        move.b  (a0)+,$ffff8256.w
        tst.b   (a0)+ 
       	bne.s   .ok
	move.l	a0,-(sp)
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	movea.l	(sp)+,a0
       	move.w  (a0),$ffff8266.w
	bra.s	.video_restored
.ok:	move.w  2(a0),$ffff8260.w
	lea.l	save_videl,a0
	move.w	32(a0),$ffff82c2.w
	move.l	34(a0),$ffff820e.w
.video_restored:
	lea.l	$ffff9800.w,a0
	lea.l	save_pal,a1
	move.w	#256-1,d0
.loop:	move.l	(a1)+,(a0)+
	dbra	d0,.loop
	rts

;---------------------------------------

;------------------------------------------
; Vars
	even

_FS_Timer200Hz:		dc.l	0
_FS_NewScreenAdrs:	dc.l	0
_FS_PalettePtr:		dc.l	0
_FS_VBLFuncPtr:		dc.l	0
_CpuSaveCACR:		dc.l	0
_CpuSavePCR:		dc.l	0
oldVBL:			dc.l	0
oldTimerC:		dc.l	0

_FS_VblAck:		dc.w	0
_FS_nFrames:		dc.w	0
_FS_SetNewScreen:	dc.w	0
_FS_Vmode:		dc.w	0

;---------------------------------------

vm_table:
	dc.l	vm_320_8_vga_60,vm_320_8_rgb_50
	dc.l	vm_320_16_vga_60,vm_320_16_rgb_50
	dc.l	vm_640_8_vga_60,0

vm_320_8_vga_60:
	dc.b	$00,$C6,$00,$8D,$00,$15,$02,$9A,$00,$7B,$00,$97,$04,$19,$03,$FF
	dc.b	$00,$3F,$00,$3D,$03,$FD,$04,$15,$02,$00,$01,$86,$00,$00,$00,$10
	dc.b	$00,$05,$00,$A0

vm_320_8_rgb_50:
	dc.b	$00,$C7,$00,$A0,$00,$1F,$02,$BA,$00,$89,$00,$AB,$02,$71,$02,$65
	dc.b	$00,$2F,$00,$59,$02,$39,$02,$6B,$02,$00,$01,$85,$00,$00,$00,$10
	dc.b	$00,$00,$00,$A0

vm_320_16_vga_60:
	dc.b	$00,$C6,$00,$8D,$00,$15,$02,$AC,$00,$8D,$00,$97,$04,$19,$03,$FF
	dc.b	$00,$3F,$00,$3D,$03,$FD,$04,$15,$02,$00,$01,$86,$00,$00,$01,$00
	dc.b	$00,$05,$01,$40

vm_320_16_rgb_50:
	dc.b	$00,$C7,$00,$A0,$00,$1F,$00,$03,$00,$9B,$00,$AB,$02,$71,$02,$65
	dc.b	$00,$2F,$00,$59,$02,$39,$02,$6B,$02,$00,$01,$85,$00,$00,$01,$00
	dc.b	$00,$00,$01,$40

vm_640_8_vga_60:
	dc.b	$00,$C6,$00,$8D,$00,$15,$02,$AB,$00,$84,$00,$97,$04,$19,$03,$FF
	dc.b	$00,$3F,$00,$3F,$03,$FF,$04,$15,$02,$00,$01,$86,$00,$00,$00,$10
	dc.b	$00,$08,$01,$40

;---------------------------------------
; Bss

	even
save_pal:	ds.l	256
save_videl:	ds.b	50

	even
_IKBD_Keyboard:		ds.b 128
	even
_IKBD_MouseX:		ds.w 1
_IKBD_MouseY:		ds.w 1
	even
_IKBD_MouseB:		ds.b 1
_IKBD_Joystick0:	ds.b 1
_IKBD_Joystick1:	ds.b 1
	even
old_ikbd:	ds.l	1
ikbd_ierb:	ds.b	1
ikbd_imrb:	ds.b	1
	even
