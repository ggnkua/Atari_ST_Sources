;=============================================================================
; IKBD_TST.S : Fast Joystick 1 rout
;-----------------------------------------------------------------------------
;	TOBE/MJJPROD
;-----------------------------------------------------------------------------
; tab size = 4
;=============================================================================


;-----------------------------------------------------------------------------
; read the joystick 1 directions & fire + 3 keys in $FFFFFC02 7 6 5 4 3 2 1 0
;                                                             | | | | | | | |
; bit [7] = keyboard escape key state ------------------------+ | | | | | | |
; bit [6] = keyboard return key state --------------------------+ | | | | | |
; bit [5] = keyboard space key state  ----------------------------+ | | | | |
; bit [4] = joystick 1 fire state     ------------------------------+ | | | |
; bit [3] = joystick 1 left state     --------------------------------+ | | |
; bit [2] = joystick 1 right state    ----------------------------------+ | |
; bit [1] = joystick 1 down state     ------------------------------------+ |
; bit [0] = joystick 1 up state       --------------------------------------+
;-----------------------------------------------------------------------------
; to reset the IKBD, write $AA to $FFFFFC02, take care to avoid keypress,
; then you can reupload code.
;-----------------------------------------------------------------------------


;=============================================================================
				TEXT
;=============================================================================


;-----------------------------------------------------------------------------
main:
;-----------------------------------------------------------------------------

	clr.l		-(sp)							; supervisor
	move.w		#$20,-(sp)
	trap		#1
	addq.l		#6,sp

	move.w		#$2700,sr

	move.b		$FFFFFA07.W,old_07				; store interrupts & vbl
	move.b		$FFFFFA09.W,old_09
	move.l		$70.W,old_vbl

	clr.b		$FFFFFA07.W						; disable interrupts
	clr.b		$FFFFFA09.W
	move.l		#vbl,$70.W						; setup vbl

	move.w		#$2300,sr

	;-------------------------------------------------------------------------

	lea			init_code,a0					; setup ikbd
	moveq		#init_code_size,d0

	lea			user_code,a1
	moveq		#user_code_size,d1

	bsr			ikbd_upload

	;-------------------------------------------------------------------------

	pea			msg								; print message
	move.w		#$9,-(sp)
	trap		#1
	addq.l		#6,sp

	moveq		#0,d0
.loop:
	move.b		$FFFFFC02.W,d0					; read byte

	lea			str,a0
	moveq		#7,d1							; convert to binary
.conv:
	btst		d1,d0
	bne.s		.one
	move.b		#'0',(a0)+
	dbra		d1,.conv
	bra.s		.print
.one:
	move.b		#'1',(a0)+
	dbra		d1,.conv

.print:											; print binary
	move.w		d0,-(sp)
	pea			str
	move.w		#$9,-(sp)
	trap		#1
	addq.l		#6,sp
	move.w		(sp)+,d0

	not.b		d0								; check for reset
	and.b		#$E0,d0
	bne.s		.loop							; loop

.release:										; wait for keys release
	btst		#0,$FFFFFC00.W
	beq.s		.release
	move.b		$FFFFFC02.W,d0
	bne.s		.release

	;-------------------------------------------------------------------------

.transmit:
	btst		#1,$FFFFFC00.W					; wait for transmit flag
	beq.s		.transmit
	move.b		#$AA,$FFFFFC02.W				; send reset

	move.w		#$2700,sr

	move.b		old_07,$FFFFFA07.W				; restore interrupts & vbl
	move.b		old_09,$FFFFFA09.W
	move.l		old_vbl,$70.W

	move.w		#$2300,sr

	clr.w		-(sp)							; exit0()
	trap		#1


;-----------------------------------------------------------------------------
vbl:
;-----------------------------------------------------------------------------
	rte											; empty vbl :)


;=============================================================================
;				INCLUDE
;=============================================================================


	INCLUDE		"IKBD_UPL.S"					; reusable ikbd code uploader


;=============================================================================
				DATA
;=============================================================================


;-----------------------------------------------------------------------------

msg:
	dc.b	$A,$D,$A,$D,"Hold then release",$A,$D
	dc.b	"Esc+Space+Return to exit",$A,$D,0
str:
	dc.b	'xxxxxxxx',$D,0
	EVEN

;-----------------------------------------------------------------------------


init_code_size:		equ		10					; size of init code
user_code_size:		equ		83					; size of user code


;-----------------------------------------------------------------------------
init_code:
;-----------------------------------------------------------------------------
	; setup keyboard lines to input
	dc.b	$71,$00,$00			;		and		#$00,$00
	; setup 74LS244 selection & joystick fire buttons
	dc.b	$86,$11				;		ldaa	#$11
	dc.b	$97,$01				;		staa	$01
	; setup keyboard rows [1-7] to output
	dc.b	$72,$FF,$04			;		or		#$FF,$04


;-----------------------------------------------------------------------------
user_code:
;-----------------------------------------------------------------------------
	; bra offset
	dc.b	$0					;			.byte	$0
	; ------------------------------------------------------------------------
	; switch to joystick mode
	dc.b	$71,$FE,$03			;	Joy:	and		#$FE,$03
	dc.b	$71,$00,$05			;			and		#$00,$05
	; read joystick 1 directions
	dc.b	$D6,$07				;	Dirs:	ldab	$07
	dc.b	$53					;			notb
	dc.b	$54,$54,$54,$54		;			lsrb	#4
	; read joystick 1 fire state
	dc.b	$7B,$04,$03			;	Fire:	bit		#$04,$03
	dc.b	$26,$02				;			bne		Keyb	(+2)
	dc.b	$CA,$10				;			orab	#$10
	; ------------------------------------------------------------------------
	; switch to keyboard mode
	dc.b	$72,$01,$03			;	Keyb:	or		#$01,$03
	dc.b	$72,$FF,$05			;			or		#$FF,$05
	; read space state
	dc.b	$CE,$FF,$FB			;	Spc:	ldx		#$FFFB
	dc.b	$DF,$06				;			stx		$06
	dc.b	$7B,$80,$02			;			bit		#$80,$02
	dc.b	$26,$02				;			bne		Ret		(+2)
	dc.b	$CA,$20				;			orab	#$20
	; read return state
	dc.b	$CE,$FF,$EF			;	Ret:	ldx		#$FFEF
	dc.b	$DF,$06				;			stx		$06
	dc.b	$7B,$20,$02			;			bit		#$20,$02
	dc.b	$26,$02				;			bne		Esc		(+2)
	dc.b	$CA,$40				;			orab	#$40
	; read escape state
	dc.b	$CE,$DF,$FF			;	Esc:	ldx		#$DFFF
	dc.b	$DF,$06				;			stx		$06
	dc.b	$7B,$02,$02			;			bit		#$02,$02
	dc.b	$26,$02				;			bne		Wait	(+2)
	dc.b	$CA,$80				;			orab	#$80
	; ------------------------------------------------------------------------
	; send byte
	dc.b	$7B,$20,$11			;	Wait:	bit		#$20,$11
	dc.b	$27,$FB				;			beq		Wait	(-5)
	dc.b	$D7,$13				;			stab	$13
	; check receive flag
	dc.b	$7B,$80,$11			;			bit		#$80,$11
	; loop
	dc.b	$27,$B6				;			beq		Joy		(-74)
	; ------------------------------------------------------------------------
	; reset
	dc.b	$96,$12				;	Reset:	ldaa	$12
	dc.b	$B7,$00,$88			;			staa	$0088
	dc.b	$7E,$F0,$00			;			jmp		#$F000


;=============================================================================
				BSS
;=============================================================================


old_vbl:
	ds.l	1
old_07:
	ds.b	1
old_09:
	ds.b	1


;=============================================================================
				END
;=============================================================================

